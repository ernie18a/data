Calculation: RSI = relative strength index of signal-timeframe close, using the current bar, which may still be forming
Calculation: Stochastic RSI = smoothed stochastic of RSI, using the current signal-timeframe bar, which may still be forming
Calculation: MFI = money flow index of typical price and volume, using the current signal-timeframe bar, which may still be forming
Calculation: Trend average = simple moving average of signal-timeframe close over a longer lookback than the oscillator lookbacks, using the current bar, which may still be forming
Calculation: Buy score = count of RSI ≤ buy threshold, Stochastic RSI ≤ buy threshold, and MFI ≤ buy threshold
Calculation: Sell score = count of RSI ≥ sell threshold, Stochastic RSI ≥ sell threshold, and MFI ≥ sell threshold
Long: Buy score ≥ 2 AND Buy score > Sell score AND close < Trend average AND (this condition was false on the previous bar OR Buy score ≥ required score)
Long: Buy score ≥ 2 AND Buy score > Sell score AND close ≥ Trend average AND (this condition was false on the previous bar OR Buy score ≥ required score)
Exit: long, Sell score ≥ 2 AND Sell score > Buy score AND (this condition was false on the previous bar OR Sell score ≥ required score)
Exit: long, Sell score ≥ required score