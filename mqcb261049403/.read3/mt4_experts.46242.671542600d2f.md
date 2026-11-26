Calculation: Grid level(i) = lower range boundary + (range width / grid-order count) × i
Long: hour(datetime) < end-time AND (grid level(i) ≤ close OR (executed-order count > execution-count threshold AND tracked order-ticket count = grid-order count − replenishment offset AND penultimate executed price ≤ close))
Short: hour(datetime) < end-time AND (grid level(i) > close OR (executed-order count > execution-count threshold AND tracked order-ticket count = grid-order count − replenishment offset AND penultimate executed price > close))
Calculation: Long stop-loss level = entry price − (close at order placement − entry price) × stop-loss multiplier
Calculation: Long take-profit level = entry price + (close at order placement − entry price) × take-profit multiplier
Calculation: Short stop-loss level = entry price + (entry price − close at order placement) × stop-loss multiplier
Calculation: Short take-profit level = entry price − (entry price − close at order placement) × take-profit multiplier
Exit: long, low ≤ long stop-loss level OR high ≥ long take-profit level OR (hour(datetime) ≥ end-time AND force-close-at-end enabled)
Exit: short, high ≥ short stop-loss level OR low ≤ short take-profit level OR (hour(datetime) ≥ end-time AND force-close-at-end enabled)