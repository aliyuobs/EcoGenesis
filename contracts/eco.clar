;; EcoGenesis Smart Contract
;; Records and analyzes biodiversity metrics across various biomes

;; Constants
(define-constant project-owner tx-sender)
(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_ENTRY_NOT_FOUND (err u101))
(define-constant ERR_INVALID_PARAMETER (err u102))
(define-constant ERR_DUPLICATE_ENTRY (err u103))
(define-constant ERR_FORBIDDEN_OPERATION (err u104))
(define-constant ERR_INVALID_PRESERVATION_STATE (err u105))
(define-constant ERR_NULL_QUANTITY (err u106))
(define-constant ERR_INVALID_BIOME_ID (err u107))
(define-constant ERR_INVALID_ORGANISM_ID (err u108))

;; Data structures
(define-map biome-catalog 
    { biome-id: uint }
    {
        biome-label: (string-ascii 50),
        location-description: (string-ascii 100),
        area-size: uint,
        genesis-block: uint,
        modification-block: uint
    }
)

(define-map organism-catalog
    { organism-id: uint }
    {
        common-name: (string-ascii 50),
        scientific-name: (string-ascii 100),
        population-size: uint,
        host-biome-id: uint,
        preservation-state: (string-ascii 20),
        last-census-block: uint
    }
)

(define-map biome-diversity-metrics
    { biome-id: uint }
    {
        cataloged-organisms-count: uint,
        diversity-index: uint,
        at-risk-organisms-count: uint,
        last-assessment-block: uint
    }
)

;; Data storage
(define-data-var next-biome-id uint u1)
(define-data-var next-organism-id uint u1)
(define-data-var registered-biomes-count uint u0)
(define-data-var registered-organisms-count uint u0)

;; Authorization check
(define-private (is-project-owner)
    (is-eq tx-sender project-owner)
)

;; Enhanced string validation function
(define-private (validate-text-input (input (string-ascii 100)))
    (let 
        (
            (input-length (len input))
        )
        (asserts! (> input-length u0) ERR_INVALID_PARAMETER)
        (asserts! (<= input-length u100) ERR_INVALID_PARAMETER)
        (ok input)
    )
)

;; Biome management functions
(define-public (register-biome 
                (biome-label (string-ascii 50)) 
                (location-description (string-ascii 100)) 
                (area-size uint))
    (begin
        (asserts! (is-project-owner) ERR_OWNER_ONLY)
        (asserts! (> (len biome-label) u0) ERR_INVALID_PARAMETER)
        (asserts! (> area-size u0) ERR_NULL_QUANTITY)
        
        (let
            (
                (new-biome-id (var-get next-biome-id))
                (validated-location (unwrap! (validate-text-input location-description) ERR_INVALID_PARAMETER))
            )
            ;; Check the validation result before using
            (asserts! (is-some (some validated-location)) ERR_INVALID_PARAMETER)
            
            (map-insert biome-catalog
                { biome-id: new-biome-id }
                {
                    biome-label: biome-label,
                    location-description: validated-location,
                    area-size: area-size,
                    genesis-block: block-height,
                    modification-block: block-height
                }
            )
            
            (map-insert biome-diversity-metrics
                { biome-id: new-biome-id }
                {
                    cataloged-organisms-count: u0,
                    diversity-index: u0,
                    at-risk-organisms-count: u0,
                    last-assessment-block: block-height
                }
            )
            
            (var-set next-biome-id (+ new-biome-id u1))
            (var-set registered-biomes-count (+ (var-get registered-biomes-count) u1))
            (ok new-biome-id)
        )
    )
)

(define-public (update-biome-details 
                (biome-id uint)
                (new-label (string-ascii 50))
                (new-location (string-ascii 100))
                (new-area-size uint))
    (begin
        (asserts! (is-project-owner) ERR_OWNER_ONLY)
        (asserts! (> (len new-label) u0) ERR_INVALID_PARAMETER)
        (asserts! (> new-area-size u0) ERR_NULL_QUANTITY)
        (asserts! (is-biome-registered biome-id) ERR_INVALID_BIOME_ID)
        
        (let
            (
                (existing-biome-data (unwrap! (map-get? biome-catalog { biome-id: biome-id }) ERR_ENTRY_NOT_FOUND))
                (validated-location (unwrap! (validate-text-input new-location) ERR_INVALID_PARAMETER))
            )
            ;; Check the validation result before using
            (asserts! (is-some (some validated-location)) ERR_INVALID_PARAMETER)
            
            (ok
                (map-set biome-catalog
                    { biome-id: biome-id }
                    {
                        biome-label: new-label,
                        location-description: validated-location,
                        area-size: new-area-size,
                        genesis-block: (get genesis-block existing-biome-data),
                        modification-block: block-height
                    }
                )
            )
        )
    )
)

;; Organism management functions
(define-public (register-organism 
                (common-name (string-ascii 50))
                (scientific-name (string-ascii 100))
                (initial-population (uint))
                (host-biome-id uint)
                (preservation-state (string-ascii 20)))
    (begin
        (asserts! (is-project-owner) ERR_OWNER_ONLY)
        (asserts! (> (len common-name) u0) ERR_INVALID_PARAMETER)
        (asserts! (> initial-population u0) ERR_NULL_QUANTITY)
        (asserts! (is-biome-registered host-biome-id) ERR_INVALID_BIOME_ID)
        (asserts! (or (is-eq preservation-state "threatened")
                     (is-eq preservation-state "stable")
                     (is-eq preservation-state "endangered")
                     (is-eq preservation-state "extinct")) ERR_INVALID_PRESERVATION_STATE)
        
        (let
            (
                (new-organism-id (var-get next-organism-id))
                (current-biome-metrics (unwrap! (map-get? biome-diversity-metrics { biome-id: host-biome-id }) ERR_ENTRY_NOT_FOUND))
                (validated-scientific-name (unwrap! (validate-text-input scientific-name) ERR_INVALID_PARAMETER))
            )
            ;; Check the validation result before using
            (asserts! (is-some (some validated-scientific-name)) ERR_INVALID_PARAMETER)
            
            (map-insert organism-catalog
                { organism-id: new-organism-id }
                {
                    common-name: common-name,
                    scientific-name: validated-scientific-name,
                    population-size: initial-population,
                    host-biome-id: host-biome-id,
                    preservation-state: preservation-state,
                    last-census-block: block-height
                }
            )
            
            (map-set biome-diversity-metrics
                { biome-id: host-biome-id }
                {
                    cataloged-organisms-count: (+ (get cataloged-organisms-count current-biome-metrics) u1),
                    diversity-index: (+ (get diversity-index current-biome-metrics) u1),
                    at-risk-organisms-count: (if (is-eq preservation-state "threatened")
                                             (+ (get at-risk-organisms-count current-biome-metrics) u1)
                                             (get at-risk-organisms-count current-biome-metrics)),
                    last-assessment-block: block-height
                }
            )
            
            (var-set next-organism-id (+ new-organism-id u1))
            (var-set registered-organisms-count (+ (var-get registered-organisms-count) u1))
            (ok new-organism-id)
        )
    )
)

(define-public (update-organism-census 
                (organism-id uint)
                (new-population-count uint)
                (new-preservation-state (string-ascii 20)))
    (let
        (
            (current-organism-data (unwrap! (map-get? organism-catalog { organism-id: organism-id }) ERR_ENTRY_NOT_FOUND))
            (current-biome-metrics (unwrap! (map-get? biome-diversity-metrics 
                { biome-id: (get host-biome-id current-organism-data) }) ERR_ENTRY_NOT_FOUND))
        )
        (asserts! (is-project-owner) ERR_OWNER_ONLY)
        (asserts! (>= new-population-count u0) ERR_INVALID_PARAMETER)
        (asserts! (or (is-eq new-preservation-state "threatened")
                     (is-eq new-preservation-state "stable")
                     (is-eq new-preservation-state "endangered")
                     (is-eq new-preservation-state "extinct")) ERR_INVALID_PRESERVATION_STATE)
        (asserts! (is-organism-registered organism-id) ERR_INVALID_ORGANISM_ID)
        
        (map-set organism-catalog
            { organism-id: organism-id }
            {
                common-name: (get common-name current-organism-data),
                scientific-name: (get scientific-name current-organism-data),
                population-size: new-population-count,
                host-biome-id: (get host-biome-id current-organism-data),
                preservation-state: new-preservation-state,
                last-census-block: block-height
            }
        )
        
        ;; Update at-risk organism count if status changed
        (if (not (is-eq (get preservation-state current-organism-data) new-preservation-state))
            (map-set biome-diversity-metrics
                { biome-id: (get host-biome-id current-organism-data) }
                {
                    cataloged-organisms-count: (get cataloged-organisms-count current-biome-metrics),
                    diversity-index: (get diversity-index current-biome-metrics),
                    at-risk-organisms-count: (if (is-eq new-preservation-state "threatened")
                                             (+ (get at-risk-organisms-count current-biome-metrics) u1)
                                             (- (get at-risk-organisms-count current-biome-metrics) u1)),
                    last-assessment-block: block-height
                }
            )
            true
        )
        (ok true)
    )
)

;; Read-only functions
(define-read-only (get-biome-details (biome-id uint))
    (map-get? biome-catalog { biome-id: biome-id })
)

(define-read-only (get-organism-details (organism-id uint))
    (map-get? organism-catalog { organism-id: organism-id })
)

(define-read-only (get-biome-diversity-metrics (biome-id uint))
    (map-get? biome-diversity-metrics { biome-id: biome-id })
)

(define-read-only (get-total-biomes)
    (ok (var-get registered-biomes-count))
)

(define-read-only (get-total-organisms)
    (ok (var-get registered-organisms-count))
)

;; Helper functions
(define-read-only (is-biome-registered (biome-id uint))
    (is-some (map-get? biome-catalog { biome-id: biome-id }))
)

(define-read-only (is-organism-registered (organism-id uint))
    (is-some (map-get? organism-catalog { organism-id: organism-id }))
)