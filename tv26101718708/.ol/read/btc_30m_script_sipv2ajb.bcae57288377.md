Calculation: Long stop price = entry price × (1 − stop-loss percentage)
Long: datetime > configured start timestamp AND datetime < configured end timestamp AND Stochastic RSI %K crosses above %D AND %K < oversold threshold AND MACD line < MACD signal line AND MACD histogram < 0 AND MFI < configured maximum
Short: datetime > configured start timestamp AND datetime < configured end timestamp AND Stochastic RSI %K crosses below %D AND %K > overbought threshold AND MACD line > MACD signal line AND MACD histogram > 0 AND MFI > configured minimum
Exit: long, low ≤ long stop price