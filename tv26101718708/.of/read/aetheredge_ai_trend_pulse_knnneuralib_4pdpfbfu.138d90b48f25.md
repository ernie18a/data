Calculation: f1 = clip((close - SMA(close, n1)) / ATR(n1), -a, a)
Calculation: f2 = clip(ATR(short period) / ATR(long period), lo, hi)
Calculation: f3 = clip(volume / SMA(volume, n2) * sign(close - open), -a, a)
Calculation: f4 = (close_HTF1 > EMA(close, n3)_HTF1 ? 0.5 : -0.5) + (close_HTF2 > EMA(close, n3)_HTF2 ? 0.5 : -0.5); HTF1 and HTF2 are both higher timeframes than the chart, HTF2 is higher than HTF1, and both use the still-forming higher-timeframe bar (its current close)
Calculation: f5 = (RSI(close, n4) - 50) / 50
Calculation: f6 = clip(ROC(close, m) / stdev(ROC(close, m), p), -a, a), or 0 if the stdev is 0; p is a longer window than m
Calculation: w_x = rolling correlation over the last L bars between feature x and (close - close[h]), NaN replaced by 0, for x = f1..f6
Calculation: score = c * (w_f1*f1 + w_f2*f3 + w_f4*f4 + w_f5*f5 + w_f6*f6) + (1 - c) * f1, with 0 < c <= 1; w_f2 (the correlation of f2) weights f3; f2 itself and w_f3 are not used
Calculation: memory = the last L pairs (score[h], sign(close - close[h])); one pair is appended every bar (current bar included, before voting) and the oldest is dropped beyond L; L is the same window as the correlation window
Calculation: vote = if the memory holds at least K pairs, the mean of the labels of the K pairs whose stored score has the smallest absolute difference from the current score; otherwise 0
Calculation: prob = prob[1] + r * (1 / (1 + exp(-2.5 * vote)) - prob[1]), with prob initialized to 0.5 and 0 < r <= 1
Long: prob >= upper threshold AND prob[1] < upper threshold (upper threshold > 0.5)
Short: prob <= lower threshold AND prob[1] > lower threshold (lower threshold < 0.5)