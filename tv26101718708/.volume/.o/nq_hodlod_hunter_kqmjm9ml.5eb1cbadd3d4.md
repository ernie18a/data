Calculation: RTH = bars from 09:30 through 16:00 America/New_York
Calculation: Previous-day close = close of the last completed daily bar
Calculation: Previous-day ATR = ATR of the last completed daily bar
Calculation: HOD targets = previous-day close + previous-day ATR × target multiplier; the second target uses the larger multiplier
Calculation: LOD targets = previous-day close − previous-day ATR × target multiplier; the second target uses the larger multiplier
Calculation: RTH VWAP bands = VWAP and ±2 volume-weighted standard deviations, accumulated from the RTH open using each bar’s typical price (high + low + close) / 3 and volume
Long: RTH AND (abs(low − either LOD target) ≤ 0.3 × current-timeframe ATR OR abs(low − lower RTH VWAP band) ≤ 0.3 × current-timeframe ATR) AND (min(open, close) − low ≥ 0.4 × current-timeframe ATR) AND close > open AND low ≤ RTH session low AND low = lowest low over a short lookback
Short: RTH AND (abs(high − either HOD target) ≤ 0.3 × current-timeframe ATR OR abs(high − upper RTH VWAP band) ≤ 0.3 × current-timeframe ATR) AND (high − max(open, close) ≥ 0.4 × current-timeframe ATR) AND close < open AND high ≥ RTH session high AND high = highest high over a short lookback