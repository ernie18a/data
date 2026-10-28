Calculation: Stochastic RSI = the signal-timeframe RSI normalized between its lowest and highest values over the Stochastic RSI lookback, then smoothed; use the signal-timeframe bar still forming
Calculation: Buy score = count of RSI ≤ buy RSI threshold, Stochastic RSI ≤ buy Stochastic RSI threshold, and MFI ≤ buy MFI threshold
Calculation: Sell score = count of RSI ≥ sell RSI threshold, Stochastic RSI ≥ sell Stochastic RSI threshold, and MFI ≥ sell MFI threshold
Long: Buy score ≥ required score
Exit: long, Sell score ≥ required score OR Sell score ≥ 2 AND Sell score > Buy score