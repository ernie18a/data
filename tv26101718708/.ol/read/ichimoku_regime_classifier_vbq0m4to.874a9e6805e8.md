Calculation: Daily Tenkan = midpoint of the highest high and lowest low over a shorter lookback on higher-timeframe bars, using the last completed bar
Calculation: Daily Kijun = midpoint of the highest high and lowest low over a longer lookback than Tenkan on higher-timeframe bars, using the last completed bar
Calculation: Daily cloud spans = Span A, the midpoint of Tenkan and Kijun, and Span B, the midpoint of the highest high and lowest low over a still longer lookback; use their prior displaced values on higher-timeframe bars, using the last completed bar
Calculation: Daily Kumo upper/lower = maximum/minimum of the prior displaced Daily cloud spans
Calculation: Daily ADX = Average Directional Index on higher-timeframe bars, using the last completed bar
Long: Daily close > Daily Kumo upper AND Daily ADX > threshold AND Daily Tenkan > Daily Kijun AND Daily close > its value at a longer lookback
Short: Daily close < Daily Kumo lower AND Daily ADX > threshold AND Daily Tenkan < Daily Kijun AND Daily close < its value at a longer lookback