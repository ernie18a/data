Calculation: volume delta = volume delta aggregated from T1 intrabars within each chart bar, including available intrabars of the forming bar
Calculation: delta strength = abs((volume delta - SMA(volume delta, delta lookback)) / StDev(volume delta, delta lookback)), calculated on chart bars
Calculation: rolling CVD = SUM(volume delta, CVD lookback chart bars)
Calculation: relative-volume pass = relative-volume filter disabled OR RelativeVolume(volume, volume lookback) >= minimum relative volume
Calculation: bubble filter measure = delta strength when delta-strength filtering is selected; otherwise abs(volume delta)
Calculation: bubble cutoff = linear-interpolated rolling percentile(bubble filter measure, delta lookback, bubble percentile)
Calculation: body ratio = abs(close - open) / (high - low), or zero when high equals low
Calculation: upper-wick ratio = (high - max(open, close)) / (high - low), or zero when high equals low
Calculation: lower-wick ratio = (min(open, close) - low) / (high - low), or zero when high equals low
Calculation: high sweep = high > Highest(high of prior bars, sweep lookback) AND close < Highest(high of prior bars, sweep lookback)
Calculation: low sweep = low < Lowest(low of prior bars, sweep lookback) AND close > Lowest(low of prior bars, sweep lookback)
Calculation: confluence score = clip to its score range the sum of delta/candle alignment, relative-volume pass, delta strength above the aggressive-delta threshold, either sweep, and the enabled candle-structure test, plus the enabled HTF alignment adjustment and delta-aligned intrabar-VWAP adjustment; on absorption, raise the score to at least the absorption score floor. The structure test passes when disabled or when body ratio >= minimum body ratio and neither a bullish candle has upper-wick ratio >= wick-rejection threshold nor a bearish candle has lower-wick ratio >= wick-rejection threshold. The HTF adjustment rewards aligned delta and trend and penalizes opposed delta and trend; the VWAP adjustment rewards aligned delta and close.
Long: volume delta > 0 AND bubble filter measure > bubble cutoff AND relative-volume pass AND (confirmation-only mode disabled OR chart bar is confirmed)
Short: volume delta < 0 AND bubble filter measure > bubble cutoff AND relative-volume pass AND (confirmation-only mode disabled OR chart bar is confirmed)
Long: volume delta > 0
Short: volume delta <= 0
Long: HTF trend filter enabled AND current T2 close > EMA(close, HTF EMA lookback, T2, current bar), sampled on chart bars with lookahead off
Short: HTF trend filter enabled AND current T2 close < EMA(close, HTF EMA lookback, T2, current bar), sampled on chart bars with lookahead off
Long: rolling CVD > rolling CVD[1]
Short: rolling CVD <= rolling CVD[1]
Long: close > VWAP(hlc3, volume, T1 intrabars within the current chart bar)
Short: close < VWAP(hlc3, volume, T1 intrabars within the current chart bar)
Long: absorption detection enabled AND volume delta < 0 AND close >= open AND low sweep AND delta strength >= minimum absorption delta strength AND relative-volume pass
Short: absorption detection enabled AND volume delta > 0 AND close < open AND high sweep AND delta strength >= minimum absorption delta strength AND relative-volume pass
Short: VSA detection enabled AND close >= open AND upper-wick ratio >= VSA wick threshold AND volume > SMA(volume, volume lookback) * high-volume multiplier AND body ratio < up-thrust body limit
Long: VSA detection enabled AND close < open AND lower-wick ratio >= VSA wick threshold AND volume > SMA(volume, volume lookback) * high-volume multiplier AND body ratio < spring body limit
Short: VSA detection enabled AND close >= open AND volume < SMA(volume, volume lookback) * low-volume multiplier AND body ratio < no-demand body limit
Long: VSA detection enabled AND close < open AND volume < SMA(volume, volume lookback) * low-volume multiplier AND body ratio < no-supply body limit
Short: CVD divergence detection enabled AND current price pivot high and current rolling-CVD pivot high are confirmed on the same chart bar AND current price pivot high > the previous matched price pivot high AND current rolling-CVD pivot high < the previous matched rolling-CVD pivot high; PivotHigh uses the CVD pivot lookback on both sides
Long: CVD divergence detection enabled AND current price pivot low and current rolling-CVD pivot low are confirmed on the same chart bar AND current price pivot low < the previous matched price pivot low AND current rolling-CVD pivot low > the previous matched rolling-CVD pivot low; PivotLow uses the CVD pivot lookback on both sides
Long: confluence score >= strong-state threshold AND volume delta > 0 AND no absorption signal AND no CVD divergence AND no VSA pattern
Short: confluence score >= strong-state threshold AND volume delta <= 0 AND no absorption signal AND no CVD divergence AND no VSA pattern