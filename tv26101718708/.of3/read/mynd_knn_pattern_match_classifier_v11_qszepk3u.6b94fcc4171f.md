Calculation: Z(x) = (x - SMA(x, normalization lookback)) / STDEV(x, normalization lookback), or 0 if STDEV(x, normalization lookback) is 0
Calculation: F = (Z(RSI(close, RSI length)), Z(ROC(close, ROC length)), Z(volume), Z(NATR(close, ATR length)))
Calculation: Labeled buffer = the most recent max history size values of (F[prediction horizon], 1 if close > close[prediction horizon] else 0), each evaluated at a bar before the current bar
Calculation: KNN score = 100 * SUM(w * o) / SUM(w) over the min(K nearest neighbors, COUNT(Labeled buffer)) pairs (F', o) in Labeled buffer with the smallest D, where D = sqrt(RSI weight * (F_1 - F'_1)^2 + ROC weight * (F_2 - F'_2)^2 + volume weight * (F_3 - F'_3)^2 + NATR weight * (F_4 - F'_4)^2) and w = 1 / (1 + D) if distance weighting is on, else 1
Long: KNN score crosses above bullish threshold AND COUNT(Labeled buffer) >= minimum sample size
Long: KNN score >= bullish threshold
Short: KNN score crosses below bearish threshold AND COUNT(Labeled buffer) >= minimum sample size
Short: KNN score <= bearish threshold