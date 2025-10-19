;; Role-based Governance Contract
;; Dynamic voting power based on roles: builders, designers, marketers

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-unauthorized (err u101))
(define-constant err-invalid-role (err u102))
(define-constant err-proposal-not-found (err u103))
(define-constant err-already-voted (err u104))
(define-constant err-voting-ended (err u105))

;; Role definitions with voting power
(define-constant BUILDER u3)
(define-constant DESIGNER u2)
(define-constant MARKETER u1)

;; Data vars
(define-data-var proposal-counter uint u0)

;; Data maps
(define-map user-roles principal uint)
(define-map proposals 
    uint 
    {
        title: (string-ascii 100),
        description: (string-ascii 500),
        proposer: principal,
        yes-votes: uint,
        no-votes: uint,
        end-block: uint,
        executed: bool
    }
)
(define-map votes {proposal-id: uint, voter: principal} bool)

;; Role management functions
(define-public (assign-role (user principal) (role uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (not (is-eq user tx-sender)) err-unauthorized)
        (asserts! (or (is-eq role BUILDER) (is-eq role DESIGNER) (is-eq role MARKETER)) err-invalid-role)
        (map-set user-roles user role)
        (ok true)
    )
)

(define-read-only (get-user-role (user principal))
    (default-to u0 (map-get? user-roles user))
)

(define-read-only (get-voting-power (user principal))
    (get-user-role user)
)

;; Proposal functions
(define-public (create-proposal (title (string-ascii 100)) (description (string-ascii 500)) (voting-period uint))
    (let 
        (
            (proposal-id (+ (var-get proposal-counter) u1))
            (user-role (get-user-role tx-sender))
        )
        (asserts! (> user-role u0) err-unauthorized)
        (asserts! (> (len title) u0) err-invalid-role)
        (asserts! (> (len description) u0) err-invalid-role)
        (asserts! (and (> voting-period u0) (<= voting-period u1440)) err-invalid-role)
        (map-set proposals proposal-id
            {
                title: title,
                description: description,
                proposer: tx-sender,
                yes-votes: u0,
                no-votes: u0,
                end-block: (+ block-height voting-period),
                executed: false
            }
        )
        (var-set proposal-counter proposal-id)
        (ok proposal-id)
    )
)

(define-public (vote (proposal-id uint) (vote-yes bool))
    (let
        (
            (proposal (unwrap! (map-get? proposals proposal-id) err-proposal-not-found))
            (voter-power (get-voting-power tx-sender))
            (vote-key {proposal-id: proposal-id, voter: tx-sender})
        )
        (asserts! (> voter-power u0) err-unauthorized)
        (asserts! (is-none (map-get? votes vote-key)) err-already-voted)
        (asserts! (<= block-height (get end-block proposal)) err-voting-ended)

        (map-set votes vote-key true)

        (if vote-yes
            (map-set proposals proposal-id
                (merge proposal {yes-votes: (+ (get yes-votes proposal) voter-power)})
            )
            (map-set proposals proposal-id
                (merge proposal {no-votes: (+ (get no-votes proposal) voter-power)})
            )
        )
        (ok true)
    )
)

;; Read-only functions
(define-read-only (get-proposal (proposal-id uint))
    (map-get? proposals proposal-id)
)

(define-read-only (has-voted (proposal-id uint) (voter principal))
    (is-some (map-get? votes {proposal-id: proposal-id, voter: voter}))
)

(define-read-only (get-proposal-result (proposal-id uint))
    (match (map-get? proposals proposal-id)
        proposal 
        (if (> (get yes-votes proposal) (get no-votes proposal))
            (some "PASSED")
            (some "FAILED")
        )
        none
    )
)

(define-read-only (get-total-proposals)
    (var-get proposal-counter)
)

;; Execute proposal (placeholder - implement specific actions as needed)
(define-public (execute-proposal (proposal-id uint))
    (let
        (
            (proposal (unwrap! (map-get? proposals proposal-id) err-proposal-not-found))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (> block-height (get end-block proposal)) err-voting-ended)
        (asserts! (not (get executed proposal)) err-unauthorized)
        (asserts! (> (get yes-votes proposal) (get no-votes proposal)) err-unauthorized)

        (map-set proposals proposal-id
            (merge proposal {executed: true})
        )
        (ok true)
    )
)