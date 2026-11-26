Calculation: Upper-wick rejection = a latest confirmed Pivot High(high, pivot lookback, pivot lookback) exists AND high > that pivot high AND close < open AND high - max(open, close) >= abs(close - open) * wick/body ratio
Calculation: Lower-wick rejection = a latest confirmed Pivot Low(low, pivot lookback, pivot lookback) exists AND low < that pivot low AND close > open AND min(open, close) - low >= abs(close - open) * wick/body ratio
Calculation: EMA trend state = neutral initially; bullish after EMA(close, shorter lookback, T1, bar still forming) crosses above EMA(close, longer lookback, T1, bar still forming), remaining bullish until it crosses below; bearish after it crosses below, remaining bearish until it crosses above; both EMAs are sampled on chart bars and the longer lookback exceeds the shorter lookback
Long: Lower-wick rejection
Long: Lower-wick rejection AND EMA trend state is bullish AND close > EMA(close, longer lookback, T1, bar still forming), sampled on chart bars
Short: Upper-wick rejection
Short: Upper-wick rejection AND EMA trend state is bearish AND close < EMA(close, longer lookback, T1, bar still forming), sampled on chart bars
Exit: long, low <= entry-signal-bar low - ATR(ATR lookback) * stop multiplier OR high >= entry-signal-bar close + ATR(ATR lookback) * take-profit multiplier * reward-risk ratio
Exit: short, high >= entry-signal-bar high + ATR(ATR lookback) * stop multiplier OR low <= entry-signal-bar close - ATR(ATR lookback) * take-profit multiplier * reward-risk ratio