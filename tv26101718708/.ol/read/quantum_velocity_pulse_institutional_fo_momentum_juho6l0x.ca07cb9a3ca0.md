Calculation: price velocity = (close − prior chart bar close) ÷ (high − low), using minimum tick if high equals low
Calculation: relative volume = volume ÷ 50-bar SMA of volume, using 1 as the denominator if the SMA is not positive
Calculation: pulse = price velocity × relative volume
Calculation: acceleration = pulse − pulse from the lookback bars ago, treating a missing prior pulse as 0
Long: acceleration > 0 AND ATR >= 50-bar SMA of ATR AND volume > 20-bar SMA of volume × volume sensitivity AND NOT (on the prior chart bar: acceleration > 0 AND ATR >= 50-bar SMA of ATR AND volume > 20-bar SMA of volume × volume sensitivity)
Short: acceleration < 0 AND ATR >= 50-bar SMA of ATR AND volume > 20-bar SMA of volume × volume sensitivity AND NOT (on the prior chart bar: acceleration < 0 AND ATR >= 50-bar SMA of ATR AND volume > 20-bar SMA of volume × volume sensitivity)