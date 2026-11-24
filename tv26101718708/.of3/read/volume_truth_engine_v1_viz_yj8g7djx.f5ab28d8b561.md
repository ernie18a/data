Calculation: Per-bar volume delta = sum of T2 volume where close > open minus sum of T2 volume where close < open, with doji volume split equally; or, when candle proxy is selected or T2 data is unavailable, volume * (2 * close - high - low) / (high - low), or 0 when high = low
Calculation: Delta ratio = per-bar volume delta / selected source volume total, or 0 when the total is 0; on each chart bar, aggregate available T2 bars within it, including any still forming
Calculation: Body ratio = abs(close - open) / (high - low), or 0 when high = low
Calculation: Small-body threshold = adaptive thresholds enabled ? percentile(body ratio, adaptive lookback, lower-body percentile) : fixed small-body threshold
Calculation: Large-body threshold = adaptive thresholds enabled ? percentile(body ratio, adaptive lookback, upper-body percentile) : fixed large-body threshold
Calculation: Absorption delta threshold = max(adaptive thresholds enabled ? percentile(abs(delta ratio), adaptive lookback, delta percentile) : fixed delta threshold, delta threshold floor)
Calculation: Price near swing high = highest(high, swing lookback) - close <= swing proximity * ATR(ATR lookback)
Calculation: Price near swing low = close - lowest(low, swing lookback) <= swing proximity * ATR(ATR lookback)
Calculation: Chart trend state = on chart bars, use VWMA(close, trend lookback), anchored VWAP(hlc3, VWAP anchor parameter), or, in order-flow mode, an up or down candle whose body exceeds SMA(abs(close - open), trend lookback), according to trend mode; in VWMA and anchored VWAP modes, qualify bullish or bearish only when close is more than ATR-distance multiplier * ATR(ATR lookback) above or below the reference, unless the ATR filter is disabled; set bullish state when bullish qualifies, strong if delta ratio > trend delta threshold and weak otherwise; set bearish state when bearish qualifies, strong if delta ratio < -trend delta threshold and weak otherwise; otherwise retain prior state, initially neutral; update at chart-bar close when close confirmation is enabled and while the bar forms otherwise
Calculation: Higher-timeframe state = on T1 bars, compare close with VWMA(close, higher-timeframe VWMA lookback); above the VWMA, state is strong bullish if the candle-proxy delta ratio exceeds the trend delta threshold and weak bullish otherwise; below it, strong bearish if the ratio is below the negative threshold and weak bearish otherwise; equal to it, neutral; chart bars use the prior chart-bar sample of the non-lookahead T1 state, representing the last completed T1 bar
Calculation: HTF filter passes(direction) = true unless HTF is enabled and filter mode is strict; in strict mode, long passes when the higher-timeframe state is not bearish and short passes when it is not bullish
Calculation: Confluence score(direction) = count of: HTF enabled and higher-timeframe state agrees with direction; chart trend state agrees with direction; Z-score(volume, volume lookback) exceeds the confluence volume threshold; delta ratio agrees with direction beyond the trend delta threshold; price is near the swing low for long or swing high for short
Calculation: Cumulative volume delta = running sum of per-bar volume delta since the session boundary on intraday chart bars or the T3 boundary on other chart bars
Long: chart trend state is bullish
Short: chart trend state is bearish
Long: higher-timeframe state is bullish
Short: higher-timeframe state is bearish
Long: delta ratio > 0
Short: delta ratio < 0
Long: cumulative volume delta > 0
Short: cumulative volume delta < 0
Long: chart trend state changes from neutral or bearish to bullish
Short: chart trend state changes from neutral or bullish to bearish
Long: price is near swing low AND delta ratio > absorption delta threshold AND Z-score(volume, volume lookback) > absorption volume threshold AND ((HTF filter passes(long) AND confluence score(long) >= minimum confluence score) OR (HTF enabled AND filter mode is soft AND higher-timeframe state is bearish))
Short: price is near swing high AND delta ratio < -absorption delta threshold AND Z-score(volume, volume lookback) > absorption volume threshold AND ((HTF filter passes(short) AND confluence score(short) >= minimum confluence score) OR (HTF enabled AND filter mode is soft AND higher-timeframe state is bullish))
Long: body ratio < small-body threshold AND Z-score(volume, volume lookback) > effort volume threshold AND price is near swing low AND HTF filter passes(long) AND confluence score(long) >= minimum confluence score
Short: body ratio < small-body threshold AND Z-score(volume, volume lookback) > effort volume threshold AND price is near swing high AND HTF filter passes(short) AND confluence score(short) >= minimum confluence score
Long: Z-score(volume, volume lookback) >= spike Z-score threshold AND close > open AND body ratio > large-body threshold AND high > low AND (high - close) / (high - low) < close-to-extreme fraction AND chart trend state is bullish AND HTF filter passes(long)
Short: Z-score(volume, volume lookback) >= spike Z-score threshold AND close < open AND body ratio > large-body threshold AND high > low AND (close - low) / (high - low) < close-to-extreme fraction AND chart trend state is bearish AND HTF filter passes(short)
Long: Z-score(volume, volume lookback) >= spike Z-score threshold AND close < open AND body ratio > large-body threshold AND price is near swing low AND chart trend state is neutral or bullish AND HTF filter passes(long)
Short: Z-score(volume, volume lookback) >= spike Z-score threshold AND close > open AND body ratio > large-body threshold AND price is near swing high AND chart trend state is neutral or bearish AND HTF filter passes(short)
Long: Z-score(volume, volume lookback) >= spike Z-score threshold AND body ratio < small-body threshold AND price is near swing low AND HTF filter passes(long)
Short: Z-score(volume, volume lookback) >= spike Z-score threshold AND body ratio < small-body threshold AND price is near swing high AND HTF filter passes(short)
Long: close > open AND volume > SMA(volume, volume lookback) AND Z-score(volume, volume lookback) < spike Z-score threshold
Short: close < open AND volume > SMA(volume, volume lookback) AND Z-score(volume, volume lookback) < spike Z-score threshold