Calculation: EMA_fast, EMA_mid = EMAs of close; EMA_fast lookback is shorter than EMA_mid lookback
Calculation: MA_trend = SMA or EMA of close with a lookback longer than both EMAs, computed on a higher timeframe than the chart, using the last completed higher-timeframe bar (previous bar's value)
Calculation: Band = MA_trend +/- k * ATR(chart timeframe, same lookback as MA_trend); Upper = MA_trend + k*ATR, Lower = MA_trend - k*ATR
Calculation: TrendA = +1 if min(open,close) > Upper AND EMA_fast > EMA_mid; -1 if max(open,close) < Lower AND EMA_fast <= EMA_mid; otherwise 0
Calculation: TrendLine (B) = EMA(raw, smoothing), computed from bars of a fixed timeframe higher than the chart, using the still-forming bar as of the current chart bar close. On those bars: E = EMA(close, n), A = ATR(n), U = E + m*A, L = E - m*A. raw = L (value at that bar) when close > U; raw = U (value at that bar) when close < L; otherwise raw = previous raw (initially the first close)
Calculation: Parabolic SAR (standard, chart timeframe); SARflip = (SAR < close) differs from (SAR < close) on the previous bar
Long: not already long AND TrendA == +1
Short: not already short AND TrendA == -1
Long: EMA_mid crosses over MA_trend
Short: EMA_mid crosses under MA_trend
Long: bar is completed AND not already long AND close > TrendLine AND SAR <= close AND close > open
Short: bar is completed AND not already short AND close <= TrendLine AND SAR >= close AND close < open
Exit: long, TrendA != +1
Exit: short, TrendA != -1
Exit: long, low crosses below entry price * (1 - stop%)
Exit: short, high crosses above entry price * (1 + stop%)
Exit: long, bar is completed AND (close <= TrendLine OR SAR > close OR SARflip)
Exit: short, bar is completed AND (close > TrendLine OR SAR < close OR SARflip)