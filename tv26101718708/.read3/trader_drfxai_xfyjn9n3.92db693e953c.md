Calculation: Smoothed range(x, lookback, multiplier) = EMA(EMA(abs(x - x[1]), lookback), 2 * lookback - 1) * multiplier
Calculation: Range filter(x, range) = x when no prior value; max(x - range, prior filter) when x > prior filter; otherwise min(x + range, prior filter)
Calculation: Swing levels(L) = switch to high state when high[L] > Highest(high, L), emitting high[L] on a switch from low state; switch to low state when low[L] < Lowest(low, L), emitting low[L] on a switch from high state; otherwise retain state and levels
Long: close crosses above Supertrend(close, ATR multiplier, ATR lookback)
Short: close crosses below Supertrend(close, ATR multiplier, ATR lookback)
Long: close > Supertrend(close, ATR multiplier, ATR lookback)
Short: close <= Supertrend(close, ATR multiplier, ATR lookback)
Long: Cirrus Cloud enabled AND Range filter(close, Smoothed range(close, shorter lookback, shorter multiplier)) >= Range filter(close, Smoothed range(close, longer lookback, longer multiplier))
Short: Cirrus Cloud enabled AND Range filter(close, Smoothed range(close, shorter lookback, shorter multiplier)) < Range filter(close, Smoothed range(close, longer lookback, longer multiplier))
Long: show-trend candles enabled AND internal trend state is bullish
Short: show-trend candles enabled AND internal trend state is not bullish
Long: close(T1, still-forming bar), on chart bars taking values from T1, > EMA(close, T1 EMA lookback, T1, still-forming bar)
Short: close(T1, still-forming bar), on chart bars taking values from T1, < EMA(close, T1 EMA lookback, T1, still-forming bar)
Long: close(T2, still-forming bar), on chart bars taking values from T2, > EMA(close, T2 EMA lookback, T2, still-forming bar)
Short: close(T2, still-forming bar), on chart bars taking values from T2, < EMA(close, T2 EMA lookback, T2, still-forming bar)
Long: close(T3, still-forming bar), on chart bars taking values from T3, > EMA(close, T3 EMA lookback, T3, still-forming bar)
Short: close(T3, still-forming bar), on chart bars taking values from T3, < EMA(close, T3 EMA lookback, T3, still-forming bar)
Long: a confirmed pivot low of low and a confirmed pivot low of RSI(close, RSI lookback) occur on the same chart bar, and the price pivot is below and the RSI pivot above the previous jointly confirmed price and RSI pivot lows; pivot left and right lookbacks are equal
Short: a confirmed pivot high of high and a confirmed pivot high of RSI(close, RSI lookback) occur on the same chart bar, and the price pivot is above and the RSI pivot below the previous jointly confirmed price and RSI pivot highs; pivot left and right lookbacks are equal
Long: close crosses above the latest unbroken swing high from Swing levels(swing lookback)
Short: close crosses below the latest unbroken swing low from Swing levels(swing lookback)
Long: close crosses above the latest unbroken internal swing high from Swing levels(internal lookback) AND internal swing high != swing high AND (confluence filter disabled OR high - max(close, open) > min(close, open - low))
Short: close crosses below the latest unbroken internal swing low from Swing levels(internal lookback) AND internal swing low != swing low AND (confluence filter disabled OR high - max(close, open) < min(close, open - low))
Long: a qualifying long Supertrend crossover occurs during either configured GMT session AND close(T1, still-forming bar) > EMA(close, T1 EMA lookback, T1, still-forming bar) on chart bars taking values from T1 AND ADX(DI lookback, smoothing lookback) > base ADX threshold AND ADX(DI lookback, smoothing lookback) > chart-timeframe retest ADX threshold AND no bearish RSI divergence occurred within the divergence-retention lookback while RSI(close, RSI lookback) >= overbought threshold; then, within the pending wait period and at least two chart bars later, high - low > 0 AND abs(close - open) / (high - low) >= chart-timeframe minimum body ratio AND low <= signal close AND close >= signal close - ATR(14) * retest-zone multiplier AND close > open
Short: a qualifying short Supertrend crossover occurs during either configured GMT session AND close(T1, still-forming bar) < EMA(close, T1 EMA lookback, T1, still-forming bar) on chart bars taking values from T1 AND ADX(DI lookback, smoothing lookback) > base ADX threshold AND ADX(DI lookback, smoothing lookback) > chart-timeframe retest ADX threshold AND no bullish RSI divergence occurred within the divergence-retention lookback while RSI(close, RSI lookback) <= oversold threshold; then, within the pending wait period and at least two chart bars later, high - low > 0 AND abs(close - open) / (high - low) >= chart-timeframe minimum body ratio AND high >= signal close AND close <= signal close + ATR(14) * retest-zone multiplier AND close < open
Calculation: FVG percent change = 100 * (close[1,T4] - open[1,T4]) / open[1,T4), using T4 values on chart bars; FVG threshold = 0 when automatic threshold is disabled, otherwise 2 * cumulative sum of abs(FVG percent change) on chart bars where T4 changes / chart bar index
Long: FVG enabled AND first chart bar of a new T4 bar AND high[2,T4] < low(T4, still-forming bar) AND high[2,T4] < close[1,T4] AND FVG percent change > FVG threshold
Short: FVG enabled AND first chart bar of a new T4 bar AND low[2,T4] > high(T4, still-forming bar) AND low[2,T4] > close[1,T4] AND -FVG percent change > FVG threshold