Calculation: Chart RSI = RSI(close, RSI lookback) on chart bars
Calculation: T1 RSI = RSI(close, T1 RSI lookback, T1, still-forming bar), sampled on chart bars
Calculation: RSI-2 = RSI(close, RSI-2 lookback) on chart bars when the selected timeframe is the chart timeframe; otherwise RSI(close, RSI-2 lookback, T2, still-forming bar), sampled on chart bars
Calculation: MFI = MFI(hlc3, MFI lookback) on chart bars
Calculation: Price average = SMA(close, price-average lookback) on chart bars
Calculation: U/D volume ratio = sum(volume where close > open, U/D lookback) / sum(volume where close < open, U/D lookback), or the up-volume sum when the down-volume sum is zero
Calculation: Volume ratio = volume / SMA(volume, volume-average lookback)
Calculation: Volume run rate = (volume ratio - volume-ratio baseline) × percentage scale
Calculation: Bull-flow score = flow-score point weight for each true condition among Chart RSI > RSI bullish threshold, MFI > MFI bullish threshold, U/D volume ratio > U/D bullish threshold, close > Price average, and rising(close, price-rising lookback)
Calculation: Bear-flow score = flow-score point weight for each true condition among Chart RSI < RSI weak threshold, MFI < MFI bearish threshold, U/D volume ratio < U/D bearish threshold, close < Price average, and falling(close, price-rising lookback)
Calculation: Flow score = Bull-flow score - Bear-flow score
Calculation: Smoothed up-pressure = EMA(max(Chart RSI - RSI midpoint, zero) / RSI midpoint × pressure scale, pressure-smoothing lookback)
Calculation: Smoothed down-pressure = EMA(max(RSI midpoint - Chart RSI, zero) / RSI midpoint × pressure scale, pressure-smoothing lookback)
Calculation: Bullish expansion state = Smoothed up-pressure > expansion-pressure threshold AND Volume run rate > expansion-rate threshold
Calculation: Smoothed volume delta = EMA(volume when close > open, otherwise zero, volume-flow smoothing lookback) - EMA(volume when close < open, otherwise zero, volume-flow smoothing lookback)
Calculation: Twiggs flow = EMA((close - open) / (high - low when nonzero, otherwise range-fallback value) × volume, Twiggs lookback)
Long: low = lowest(low, divergence lookback) AND Chart RSI > lowest(Chart RSI, divergence lookback) AND Chart RSI[divergence lookback] = lowest(Chart RSI, divergence lookback)
Short: high = highest(high, divergence lookback) AND Chart RSI < highest(Chart RSI, divergence lookback) AND Chart RSI[divergence lookback] = highest(Chart RSI, divergence lookback)
Long: close > VWAP(hlc3)
Short: close <= VWAP(hlc3)
Long: U/D volume ratio >= U/D bullish threshold
Short: U/D volume ratio <= U/D bearish threshold
Long: Chart RSI > RSI bullish threshold AND MFI > MFI bullish threshold
Short: Chart RSI < RSI weak threshold AND MFI < MFI bearish threshold
Long: Chart RSI > RSI strong threshold OR (Chart RSI <= RSI strong threshold AND Chart RSI > RSI bullish threshold)
Short: Chart RSI <= RSI strong threshold AND Chart RSI <= RSI bullish threshold AND Chart RSI < RSI weak threshold
Long: T1 RSI >= RSI bullish threshold
Short: T1 RSI <= RSI weak threshold
Long: RSI-2 >= RSI-2 bullish threshold
Short: RSI-2 <= RSI-2 bearish threshold
Long: MFI >= MFI bullish threshold
Short: MFI <= MFI bearish threshold
Long: Twiggs flow > zero
Short: Twiggs flow <= zero
Long: Smoothed volume delta > zero
Short: Smoothed volume delta <= zero
Long: Bull-flow score > Bear-flow score
Short: Bear-flow score > Bull-flow score
Long: Flow score >= flow-score display threshold
Short: Flow score <= -flow-score display threshold
Long: Bullish expansion state OR (NOT Bullish expansion state AND Smoothed up-pressure > pressure-strength threshold)
Short: NOT Bullish expansion state AND Smoothed up-pressure <= pressure-strength threshold AND Smoothed down-pressure > pressure-strength threshold
Long: Flow score > flow-score alert threshold AND Flow score[1] <= flow-score alert threshold
Short: Flow score < -flow-score alert threshold AND Flow score[1] >= -flow-score alert threshold
Long: Bullish expansion state AND NOT Bullish expansion state[1]