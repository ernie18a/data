Calculation: Close location = (close - low) / (high - low)
Long: Close > close at any of the short, medium, or long return lookbacks
Short: Close <= close at any of the short, medium, or long return lookbacks OR close at that lookback is unavailable
Long: Chaikin Money Flow > 0
Short: Chaikin Money Flow <= 0
Long: Close > shorter-period EMA of close AND shorter-period EMA of close > longer-period EMA of close
Short: Close < shorter-period EMA of close AND shorter-period EMA of close < longer-period EMA of close
Long: Volume / SMA of volume > volume-surge threshold AND high > low AND close location > upper close-location threshold AND close > open
Short: Volume / SMA of volume > volume-surge threshold AND high > low AND close location < lower close-location threshold AND close < open