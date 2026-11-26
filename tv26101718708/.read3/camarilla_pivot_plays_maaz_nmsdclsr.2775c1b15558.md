Calculation: relative volume = volume / SMA(volume, lookback)
Long: prior selected session close > preceding selected session close
Long: low crosses below Camarilla S3(prior selected session close, high, low) AND close > Camarilla S3(prior selected session close, high, low)
Long: close crosses above Camarilla R4(prior selected session close, high, low) AND (volume filter disabled OR relative volume >= threshold) AND close > open
Short: prior selected session close < preceding selected session close
Short: high crosses above Camarilla R3(prior selected session close, high, low) AND close < Camarilla R3(prior selected session close, high, low)
Short: close crosses below Camarilla S4(prior selected session close, high, low) AND (volume filter disabled OR relative volume >= threshold) AND close < open