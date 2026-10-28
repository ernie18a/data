Calculation: Heikin-Ashi open = (previous Heikin-Ashi open + previous Heikin-Ashi close) / 2, initialized to (open + close) / 2; close = (open + high + low + close) / 4; high = max(high, Heikin-Ashi open, Heikin-Ashi close); low = min(low, Heikin-Ashi open, Heikin-Ashi close)
Calculation: Strong bullish Heikin-Ashi = Heikin-Ashi close > Heikin-Ashi open AND body > range × neutral-body percentage threshold
Calculation: Strong bearish Heikin-Ashi = Heikin-Ashi close < Heikin-Ashi open AND body > range × neutral-body percentage threshold
Calculation: Daily VWAP = running volume-weighted average of hlc3 since the start of the current day, using current-timeframe bars through the current bar
Calculation: Trend state = bullish when the selected mode is Supertrend with bullish direction or PSAR with close > PSAR; bearish when Supertrend has bearish direction or PSAR with close < PSAR
Long: flat AND strong bullish Heikin-Ashi AND close > EMA8 AND EMA8 > EMA21 AND EMA21 > EMA50 AND bullish trend state AND close > current Daily VWAP
Short: flat AND strong bearish Heikin-Ashi AND close < EMA8 AND EMA8 < EMA21 AND EMA21 < EMA50 AND bearish trend state AND close < current Daily VWAP
Exit: long, trend state changes from bullish to bearish OR Heikin-Ashi close < Heikin-Ashi open OR close crosses below EMA21
Exit: short, trend state changes from bearish to bullish OR Heikin-Ashi close > Heikin-Ashi open OR close crosses above EMA21