Calculation: Stoch RSI = moving average of 100 × (RSI − lowest RSI over the Stoch RSI lookback) ÷ (highest RSI over that lookback − lowest RSI over that lookback), smoothed over a shorter lookback; use higher-timeframe bars, including the bar still forming
Calculation: Buy score = count of RSI at or below its low threshold, Stoch RSI at or below its low threshold, and MFI at or below its low threshold
Calculation: Sell score = count of RSI at or above its high threshold, Stoch RSI at or above its high threshold, and MFI at or above its high threshold
Calculation: Required score = full score in strict mode; otherwise, the greater of full score minus one and two
Long: Buy score >= required score OR (buy score >= 2 AND buy score > sell score)
Exit: Long, sell score >= required score OR (sell score >= 2 AND sell score > buy score)