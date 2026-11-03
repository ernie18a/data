Calculation: RSI = Relative Strength Index on the higher-timeframe last completed bar
Calculation: Stochastic RSI = smoothed Stochastic RSI on the higher-timeframe last completed bar
Calculation: MFI = Money Flow Index on the higher-timeframe last completed bar
Calculation: Trend average = simple moving average of close on the higher-timeframe last completed bar
Calculation: Buy score = count of RSI ≤ its buy threshold, Stochastic RSI ≤ its buy threshold, and MFI ≤ its buy threshold
Calculation: Sell score = count of RSI ≥ its sell threshold, Stochastic RSI ≥ its sell threshold, and MFI ≥ its sell threshold
Calculation: Buy zone = buy score ≥ 2 AND buy score > sell score
Calculation: Sell zone = sell score ≥ 2 AND sell score > buy score
Long: Buy zone AND close < trend average
Long: Buy zone AND close ≥ trend average
Exit: long, Sell zone OR sell score ≥ required score