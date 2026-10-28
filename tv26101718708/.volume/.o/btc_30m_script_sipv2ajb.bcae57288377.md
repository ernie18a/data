Calculation: Stochastic RSI K = smoothed stochastic of RSI; D = smoothed K
Calculation: Long stop price = entry price × (1 − configured loss percentage)
Long: Within the configured date range AND K crosses above D AND K is below the oversold threshold AND MACD is below its signal line AND MACD histogram is below zero AND MFI is below its configured threshold
Short: Within the configured date range AND K crosses below D AND K is above the overbought threshold AND MACD is above its signal line AND MACD histogram is above zero AND MFI is above its configured threshold
Exit: Long, low ≤ long stop price