Calculation: Linear regression momentum = linear regression, over a lookback, of close minus the average of (the average of the lookback highest high and lowest low) and the lookback simple moving average of close
Calculation: Volume surge = close > open AND close > prior bar high AND volume > 1.5 × 20-bar simple moving average of volume
Long: close > long-term exponential moving average AND linear regression momentum > 0
Long: NOT (close > long-term exponential moving average AND linear regression momentum > 0) AND (volume surge OR (linear regression momentum > 0 AND linear regression momentum > its prior-bar value))
Short: close < long-term exponential moving average AND NOT (volume surge OR (linear regression momentum > 0 AND linear regression momentum > its prior-bar value))