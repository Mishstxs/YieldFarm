;; STX Yield Farm Contract
;; A simple yield farming contract where users can stake STX tokens to earn rewards

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-balance (err u101))
(define-constant err-no-stake (err u102))
(define-constant err-invalid-amount (err u103))

;; Data Variables
(define-data-var total-staked uint u0)
(define-data-var reward-rate uint u100) ;; 1% per block (100 basis points)
(define-data-var contract-active bool true)

;; Data Maps
(define-map user-stakes
    principal
    {
        amount: uint,
        last-claim-block: uint
    }
)

(define-map user-rewards
    principal
    uint
)

;; Read-only functions
(define-read-only (get-user-stake (user principal))
    (default-to 
        { amount: u0, last-claim-block: u0 }
        (map-get? user-stakes user)
    )
)

(define-read-only (get-user-rewards (user principal))
    (default-to u0 (map-get? user-rewards user))
)

(define-read-only (get-total-staked)
    (var-get total-staked)
)

(define-read-only (get-reward-rate)
    (var-get reward-rate)
)

(define-read-only (is-contract-active)
    (var-get contract-active)
)

(define-read-only (calculate-pending-rewards (user principal))
    (let
        (
            (stake-info (get-user-stake user))
            (blocks-passed (- stacks-block-height (get last-claim-block stake-info)))
            (stake-amount (get amount stake-info))
        )
        (if (> stake-amount u0)
            (/ (* stake-amount (var-get reward-rate) blocks-passed) u10000)
            u0
        )
    )
)

;; Public functions
(define-public (stake (amount uint))
    (let
        (
            (current-stake (get-user-stake tx-sender))
            (new-amount (+ (get amount current-stake) amount))
        )
        (asserts! (var-get contract-active) (err u104))
        (asserts! (> amount u0) err-invalid-amount)
        
        ;; Transfer STX from user to contract
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        
        ;; Update user stake
        (map-set user-stakes tx-sender
            {
                amount: new-amount,
                last-claim-block: stacks-block-height
            }
        )
        
        ;; Update total staked
        (var-set total-staked (+ (var-get total-staked) amount))
        
        (ok amount)
    )
)

(define-public (unstake (amount uint))
    (let
        (
            (current-stake (get-user-stake tx-sender))
            (staked-amount (get amount current-stake))
        )
        (asserts! (var-get contract-active) (err u104))
        (asserts! (> amount u0) err-invalid-amount)
        (asserts! (>= staked-amount amount) err-insufficient-balance)
        
        ;; Claim pending rewards first
        (try! (claim-rewards))
        
        ;; Update user stake
        (map-set user-stakes tx-sender
            {
                amount: (- staked-amount amount),
                last-claim-block: stacks-block-height
            }
        )
        
        ;; Update total staked
        (var-set total-staked (- (var-get total-staked) amount))
        
        ;; Transfer STX back to user
        (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
        
        (ok amount)
    )
)

(define-public (claim-rewards)
    (let
        (
            (pending-rewards (calculate-pending-rewards tx-sender))
            (current-rewards (get-user-rewards tx-sender))
            (current-stake (get-user-stake tx-sender))
        )
        (asserts! (var-get contract-active) (err u104))
        (asserts! (> (get amount current-stake) u0) err-no-stake)
        
        ;; Update last claim block
        (map-set user-stakes tx-sender
            {
                amount: (get amount current-stake),
                last-claim-block: stacks-block-height
            }
        )
        
        ;; Add pending rewards to user rewards
        (map-set user-rewards tx-sender (+ current-rewards pending-rewards))
        
        (ok pending-rewards)
    )
)

(define-public (withdraw-rewards (amount uint))
    (let
        (
            (available-rewards (get-user-rewards tx-sender))
        )
        (asserts! (var-get contract-active) (err u104))
        (asserts! (> amount u0) err-invalid-amount)
        (asserts! (>= available-rewards amount) err-insufficient-balance)
        
        ;; Update user rewards
        (map-set user-rewards tx-sender (- available-rewards amount))
        
        ;; Transfer reward STX to user
        (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
        
        (ok amount)
    )
)

;; Admin functions
(define-public (set-reward-rate (new-rate uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set reward-rate new-rate)
        (ok new-rate)
    )
)

(define-public (toggle-contract (active bool))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set contract-active active)
        (ok active)
    )
)

(define-public (fund-contract (amount uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (ok amount)
    )
)