Calculation: Stretch = Apply a selectable EMA, RMA, SMA, WMA, or no smoothing, optionally twice, to the weighted average of (typical price − EMA of typical price) / max(ATR, positive denominator floor), calculated for short, medium, and long EMA periods with matching ATR periods.
Calculation: Velocity = Apply the same smoothing choice and passes as Stretch to the weighted average of (current EMA of typical price − its value at a prior bar) / max(ATR, positive denominator floor), using the same three EMA and matching ATR periods and weights as Stretch. The short, medium, and long EMAs use respectively shorter, medium, and longer lookbacks. Divide each weighted sum by the greater of the sum of weights and a small positive floor.
Long: Velocity >= 0 AND Stretch >= 0
Long: Velocity >= 0 AND Stretch < 0
Short: Velocity < 0 AND Stretch >= 0
Short: Velocity < 0 AND Stretch < 0