Long: RSI on the selected RSI timeframe (which may be higher or lower than the chart timeframe), using the available bar value (last completed on historical bars; still forming in real time), is below the long threshold AND position is flat
Short: RSI on the selected RSI timeframe (which may be higher or lower than the chart timeframe), using the available bar value (last completed on historical bars; still forming in real time), is above the short threshold AND position is flat
Calculation: Take-profit price distance = take-profit USD amount / position quantity
Calculation: Stop-loss price distance = stop-loss USD amount / position quantity
Exit: long, high >= entry price + take-profit price distance OR low <= entry price - stop-loss price distance
Exit: short, low <= entry price - take-profit price distance OR high >= entry price + stop-loss price distance