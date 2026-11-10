Calculation: Signal-timeframe indicators = RSI of close, smoothed stochastic RSI, MFI of typical price and volume, and SMA of close, all calculated on the selected signal timeframe. For a higher signal timeframe, use the last completed signal-timeframe bar on historical chart bars; for a lower signal timeframe, use the last signal-timeframe bar within the chart bar. For the chart timeframe, use the current chart bar.
Calculation: Smoothed stochastic RSI = SMA of 100 × (RSI − lowest RSI over the stochastic lookback) / max(highest RSI over the stochastic lookback − lowest RSI over the stochastic lookback, a small positive floor).
Calculation: Buy score = one point each for RSI at or below its buy threshold, smoothed stochastic RSI at or below its buy threshold, and MFI at or below its buy threshold, plus one point if the optional manual sentiment input is enabled and set to extreme fear.
Calculation: Sell score = one point each for RSI at or above its sell threshold, smoothed stochastic RSI at or above its sell threshold, and MFI at or above its sell threshold, plus one point if the optional manual sentiment input is enabled and set to extreme greed.
Calculation: Maximum score = the number of indicator components plus one if manual sentiment is enabled. Required score = maximum score in strict mode; otherwise the greater of maximum score minus one and two. Manual sentiment is a fixed input, not a historical data series.
Long: Chart close < signal-timeframe SMA.
Long: Chart close >= signal-timeframe SMA.
Long: RSI <= buy RSI threshold.
Long: Smoothed stochastic RSI <= buy stochastic RSI threshold.
Long: MFI <= buy MFI threshold.
Long: Buy score >= 2 AND buy score > sell score AND chart close < signal-timeframe SMA.
Long: Buy score >= 2 AND buy score > sell score AND chart close >= signal-timeframe SMA.
Long: Buy score >= required score AND buy score >= 2 AND buy score > sell score.
Long: Buy score == maximum score.
Exit: long, RSI >= sell RSI threshold.
Exit: long, smoothed stochastic RSI >= sell stochastic RSI threshold.
Exit: long, MFI >= sell MFI threshold.
Exit: long, sell score >= 2 AND sell score > buy score.
Exit: long, sell score >= required score.
Exit: long, sell score == maximum score.