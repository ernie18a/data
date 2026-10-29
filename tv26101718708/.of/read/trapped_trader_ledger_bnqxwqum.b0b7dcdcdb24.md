Calculation: Price bins = divide the range from the rolling lowest low to the rolling highest high into equal bins; assign each bar’s close to a bin, clamping to the range endpoints.
Calculation: Per-bin buy volume = rolling sum of volume × (close − low) / max(high − low, minimum tick) for bars assigned to that bin.
Calculation: Per-bin sell volume = rolling sum of volume × (high − close) / max(high − low, minimum tick) for bars assigned to that bin.
Long: Per-bin buy volume > per-bin sell volume AND per-bin buy volume + per-bin sell volume > 0
Short: Per-bin buy volume ≤ per-bin sell volume AND per-bin buy volume + per-bin sell volume > 0