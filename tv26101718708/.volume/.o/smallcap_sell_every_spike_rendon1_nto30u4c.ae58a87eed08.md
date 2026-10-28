Calculation: Longer-lookback volume SMA = simple moving average of volume using a longer lookback than the relative-volume average
Calculation: Shorter-lookback volume SMA = simple moving average of volume using a shorter lookback than the spike-volume average
Calculation: Relative volume = current volume / shorter-lookback volume SMA
Calculation: Float rotation = current session cumulative volume / float shares
Calculation: Session VWAP = cumulative volume-weighted typical price (high + low + close) / 3, reset each day
Calculation: Upper-wick percentage = (high − max(open, close)) / (high − low) × 100
Long: 
Short: Close is within the configured price band AND relative volume is at least its minimum AND float rotation is not above its hard limit AND rate of change over its lookback is at least its minimum AND high − low is at least ATR × its range multiplier AND volume is greater than the longer-lookback volume SMA × its multiplier AND high equals the highest high over the longer of the rate-of-change lookback and the fixed minimum high lookback AND cooldown since the prior entry has elapsed AND today's entry count is below its cap AND (upper-wick filter is disabled OR upper-wick percentage is at least its minimum) AND (VWAP-cross filter is disabled OR close crosses below session VWAP)
Exit: short, high is at least entry price + ATR-at-entry × stop multiple OR low is at most entry price − ATR-at-entry × either target multiple OR low is at most entry price × (1 − either percentage target)