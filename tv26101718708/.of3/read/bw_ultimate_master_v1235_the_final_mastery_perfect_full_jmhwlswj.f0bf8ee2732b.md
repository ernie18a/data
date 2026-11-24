Calculation: T-frame AO = Awesome Oscillator(hl2, shorter lookback, longer lookback) on the current, still-forming T bar, calculated on T bars and sampled on chart bars; T1 through T7 are ordered longest to shortest
Calculation: T-frame AC = Accelerator Oscillator(hl2, shorter AO lookback, longer AO lookback, AC smoothing lookback) on the current, still-forming T bar, calculated on T bars and sampled on chart bars; chart AC uses chart bars
Calculation: T-frame RSI = RSI(close, RSI lookback) on the current, still-forming T bar, calculated on T bars and sampled on chart bars
Calculation: HTF scores = bullish score sums separate T1, T2, and T3 weight parameters when the corresponding AO is positive; bearish score sums those weights when the corresponding AO is negative
Calculation: HTF bullish alignment = bullish score > bearish score AND bullish score >= minimum score parameter
Calculation: HTF bearish alignment = bearish score > bullish score AND bearish score >= minimum score parameter
Calculation: Signal cooldown clear = bars since previous signal > cooldown-bars parameter OR no previous signal price OR abs(close - previous signal close) > ATR(lookback) * cooldown-distance parameter
Calculation: Candle body = max(abs(close - open), minimum-body parameter)
Calculation: Alligator spread = max(SMMA(hl2, longest lookback), SMMA(hl2, middle lookback), SMMA(hl2, shortest lookback)) - min(SMMA(hl2, longest lookback), SMMA(hl2, middle lookback), SMMA(hl2, shortest lookback))
Long: AO(Ti) > 0 on any current Ti bar, i = 1..7
Short: AO(Ti) <= 0 on any current Ti bar, i = 1..7
Long: On any Ti, (AC(Ti) >= 0 AND AC(Ti) > AC(Ti)[1]) OR (AC(Ti) < 0 AND AC(Ti) >= AC(Ti)[1])
Short: On any Ti, (AC(Ti) >= 0 AND AC(Ti) <= AC(Ti)[1]) OR (AC(Ti) < 0 AND AC(Ti) < AC(Ti)[1])
Long: On any Ti, when a new confirmed PivotLow(low, divergence lookback, divergence lookback) occurs, it is below the preceding confirmed price pivot low AND the RSI PivotLow paired with it is above the RSI PivotLow paired with the preceding price pivot low
Short: On any Ti, when a new confirmed PivotHigh(high, divergence lookback, divergence lookback) occurs, it is above the preceding confirmed price pivot high AND the RSI PivotHigh paired with it is below the RSI PivotHigh paired with the preceding price pivot high
Long: close > open of the daily reference-time bar
Short: close <= open of the daily reference-time bar
Long: HTF bullish alignment
Short: HTF bearish alignment
Long: HTF bullish alignment AND AO(T4) > 0 AND AO(T5) > 0
Short: HTF bearish alignment AND AO(T4) < 0 AND AO(T5) < 0
Long: Alligator spread >= ATR(lookback) * spread-threshold parameter AND SMMA(hl2, shortest lookback) > SMMA(hl2, middle lookback) > SMMA(hl2, longest lookback)
Short: Alligator spread >= ATR(lookback) * spread-threshold parameter AND SMMA(hl2, shortest lookback) < SMMA(hl2, middle lookback) < SMMA(hl2, longest lookback)
Long: Signal cooldown clear AND ((at least the confluence-count parameter of these four conditions: close crosses above the latest confirmed PivotHigh(high, swing-pivot lookback, swing-pivot lookback); bullish engulfing OR bullish pin bar; low <= EMA(close, lookback) AND close > EMA(close, lookback); HTF bullish alignment AND chart Accelerator Oscillator > its previous chart-bar value) AND RSI(close, lookback) <= long-block threshold parameter)
Short: Signal cooldown clear AND ((at least the confluence-count parameter of these four conditions: close crosses below the latest confirmed PivotLow(low, swing-pivot lookback, swing-pivot lookback); bearish engulfing OR bearish pin bar; high >= EMA(close, lookback) AND close < EMA(close, lookback); HTF bearish alignment AND chart Accelerator Oscillator < its previous chart-bar value) AND RSI(close, lookback) >= short-block threshold parameter)
Long: Signal cooldown clear AND a low sweep (low <= lowest(low, sweep lookback)[1]) is followed within the sweep-validity parameter by a close crossing above the latest confirmed PivotHigh(high, swing-pivot lookback, swing-pivot lookback); at each such MSS, store level = avg(lowest(low, order-block lookback), close) and, on the MSS bar or while waiting, signal when low <= stored level AND close > open; keep waiting until triggered, with a later MSS replacing the stored level
Short: Signal cooldown clear AND a high sweep (high >= highest(high, sweep lookback)[1]) is followed within the sweep-validity parameter by a close crossing below the latest confirmed PivotLow(low, swing-pivot lookback, swing-pivot lookback); at each such MSS, store level = avg(highest(high, order-block lookback), close) and, on the MSS bar or while waiting, signal when high >= stored level AND close < open; keep waiting until triggered, with a later MSS replacing the stored level