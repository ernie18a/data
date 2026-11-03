Calculation: Stop distance = configured fixed price distance, or ATR multiplied by the stop-loss factor at entry; ATR uses the last completed bar of the chart timeframe or of a configured higher or lower timeframe.
Calculation: Target distance = configured fixed price distance, or ATR multiplied by the take-profit factor at entry; ATR uses the last completed bar of the chart timeframe or of a configured higher or lower timeframe.
Long: RSI of the selected price on the last completed chart bar > lower threshold AND RSI on the preceding chart bar <= lower threshold AND (session filter disabled OR current hour is within the configured session, including its start and excluding its end).
Short: RSI of the selected price on the last completed chart bar < upper threshold AND RSI on the preceding chart bar >= upper threshold AND (session filter disabled OR current hour is within the configured session, including its start and excluding its end).
Exit: long, RSI of the selected price on the last completed chart bar < upper threshold AND RSI on the preceding chart bar >= upper threshold AND (RSI on the last completed chart bar <= lower threshold OR RSI on the preceding chart bar > lower threshold).
Exit: short, RSI of the selected price on the last completed chart bar > lower threshold AND RSI on the preceding chart bar <= lower threshold.
Exit: long, stop loss enabled AND low <= entry price - stop distance.
Exit: long, take profit enabled AND high >= entry price + target distance.
Exit: short, stop loss enabled AND high >= entry price + stop distance.
Exit: short, take profit enabled AND low <= entry price - target distance.