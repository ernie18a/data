Calculation: Smoothed stochastic RSI = simple moving average of 100 × (RSI − lowest RSI over the stochastic lookback) / max(highest RSI over the stochastic lookback − lowest RSI over the stochastic lookback, a small positive floor).
Calculation: Buy score = number of true conditions among RSI ≤ buy RSI threshold, smoothed stochastic RSI ≤ buy stochastic RSI threshold, and MFI ≤ buy MFI threshold, plus a fixed manual extreme-fear contribution when the sentiment filter is enabled.
Calculation: Sell score = number of true conditions among RSI ≥ sell RSI threshold, smoothed stochastic RSI ≥ sell stochastic RSI threshold, and MFI ≥ sell MFI threshold, plus a fixed manual extreme-greed contribution when the sentiment filter is enabled.
Calculation: Maximum score = the number of indicator conditions plus one when the sentiment filter is enabled. Each manual sentiment contribution is either zero or one and is fixed for the backtest; extreme fear and extreme greed cannot both contribute one.
Calculation: Required score = maximum score in strict mode; otherwise, the greater of maximum score minus one and two.
Calculation: RSI, smoothed stochastic RSI, and MFI use the last completed higher-timeframe bar, with their most recently completed values carried forward between higher-timeframe closes. RSI uses close; MFI uses typical price and volume.
Long: RSI ≤ buy RSI threshold OR smoothed stochastic RSI ≤ buy stochastic RSI threshold OR MFI ≤ buy MFI threshold.
Long: Buy score ≥ required score.
Long: Buy score ≥ two AND buy score > sell score.
Long: Buy score ≥ two AND buy score > sell score AND the preceding chart bar did not satisfy both conditions.
Exit: long, RSI ≥ sell RSI threshold OR smoothed stochastic RSI ≥ sell stochastic RSI threshold OR MFI ≥ sell MFI threshold.
Exit: long, sell score ≥ required score.
Exit: long, sell score ≥ two AND sell score > buy score.
Exit: long, sell score ≥ two AND sell score > buy score AND the preceding chart bar did not satisfy both conditions.