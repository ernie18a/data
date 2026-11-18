Calculation: relative volume = if SMA(volume, volume-average lookback) > 0, volume / SMA(volume, volume-average lookback), else 1.0
Long: close >= open AND bull bubbles enabled AND relative volume >= minimum display ratio AND relative volume < tiny threshold
Long: close >= open AND bull bubbles enabled AND relative volume >= minimum display ratio AND relative volume >= tiny threshold AND relative volume < small threshold
Long: close >= open AND bull bubbles enabled AND relative volume >= minimum display ratio AND relative volume >= small threshold AND relative volume < medium threshold
Long: close >= open AND bull bubbles enabled AND relative volume >= minimum display ratio AND relative volume >= medium threshold
Short: close < open AND bear bubbles enabled AND relative volume >= minimum display ratio AND relative volume < tiny threshold
Short: close < open AND bear bubbles enabled AND relative volume >= minimum display ratio AND relative volume >= tiny threshold AND relative volume < small threshold
Short: close < open AND bear bubbles enabled AND relative volume >= minimum display ratio AND relative volume >= small threshold AND relative volume < medium threshold
Short: close < open AND bear bubbles enabled AND relative volume >= minimum display ratio AND relative volume >= medium threshold