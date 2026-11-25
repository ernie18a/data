Long: crosses above EMA(close, fast length) AND crosses above EMA(close, trigger length)
Short: crosses below EMA(close, fast length) AND crosses below EMA(close, trigger length)
Long: EMA(close, fast length) crosses above EMA(close, trigger length)
Short: EMA(close, fast length) crosses below EMA(close, trigger length)
Long: EMA(close, fast length) > EMA(close, trigger length)
Short: EMA(close, fast length) <= EMA(close, trigger length)
Long: EMA(close, fast length) >= EMA(close, fast length)[1]
Short: EMA(close, fast length) < EMA(close, fast length)[1]
Long: EMA(close, trigger length) >= EMA(close, trigger length)[1]
Short: EMA(close, trigger length) < EMA(close, trigger length)[1]
Long: EMA(close, fast length, T1, current bar) > EMA(close, trigger length, T1, current bar), sampled on chart bars, separately for each of the six EMA dashboard timeframes T1–T6
Short: EMA(close, fast length, T1, current bar) <= EMA(close, trigger length, T1, current bar), sampled on chart bars, separately for each of the six EMA dashboard timeframes T1–T6
Long: chart close > EMA(close, fast length, T1, current bar), separately for each of the six EMA dashboard timeframes T1–T6
Short: chart close <= EMA(close, fast length, T1, current bar), separately for each of the six EMA dashboard timeframes T1–T6
Long: chart close > EMA(close, trigger length, T1, current bar), separately for each of the six EMA dashboard timeframes T1–T6
Short: chart close <= EMA(close, trigger length, T1, current bar), separately for each of the six EMA dashboard timeframes T1–T6
Long: chart close > EMA(close, slow length, T1, current bar), separately for each of the six EMA dashboard timeframes T1–T6
Short: chart close <= EMA(close, slow length, T1, current bar), separately for each of the six EMA dashboard timeframes T1–T6
Long: RSI(close, MTF RSI lookback, S1, current bar) >= bullish-neutral boundary, sampled on chart bars, separately for each of the six MTF RSI timeframes S1–S6
Short: RSI(close, MTF RSI lookback, S1, current bar) <= bearish-neutral boundary, sampled on chart bars, separately for each of the six MTF RSI timeframes S1–S6
Calculation: BOP hit rates by previous-candle color = since initialization, each cumulative count of current bars reaching the previous bar's high or low divided by the count of bars with that previous-candle color; refresh each rate only when its corresponding high-reach or low-reach comparison is true
Long: close[1] > open[1] AND green-candle high hit rate >= green-candle low hit rate OR close[1] <= open[1] AND red-candle high hit rate >= red-candle low hit rate
Short: close[1] > open[1] AND green-candle high hit rate < green-candle low hit rate OR close[1] <= open[1] AND red-candle high hit rate < red-candle low hit rate
Long: ZigZag(high, low, lookback) marks a high pivot above the previous high pivot OR a low pivot above the previous low pivot
Short: ZigZag(high, low, lookback) marks a high pivot below the previous high pivot OR a low pivot below the previous low pivot
Long: RSI pivot low(RSI(close, divergence RSI lookback), left lookback, right lookback) has a higher RSI value and a lower selected price-source value than the previous RSI pivot low, with pivot spacing within the configured range; selected price source is low for wicks or min(open, close) for bodies
Long: RSI pivot low(RSI(close, divergence RSI lookback), left lookback, right lookback) has a lower RSI value and a higher selected price-source value than the previous RSI pivot low, with pivot spacing within the configured range; selected price source is low for wicks or min(open, close) for bodies
Short: RSI pivot high(RSI(close, divergence RSI lookback), left lookback, right lookback) has a lower RSI value and a higher selected price-source value than the previous RSI pivot high, with pivot spacing within the configured range; selected price source is high for wicks or max(open, close) for bodies
Short: RSI pivot high(RSI(close, divergence RSI lookback), left lookback, right lookback) has a higher RSI value and a lower selected price-source value than the previous RSI pivot high, with pivot spacing within the configured range; selected price source is high for wicks or max(open, close) for bodies
Long: on the current live bar, at least the predictive minimum bars after the last confirmed RSI pivot low, selected price source is below that pivot's price and RSI(close, divergence RSI lookback) is above that pivot's RSI value; selected price source is low for wicks or min(open, close) for bodies
Long: on the current live bar, at least the predictive minimum bars after the last confirmed RSI pivot low, selected price source is above that pivot's price and RSI(close, divergence RSI lookback) is below that pivot's RSI value; selected price source is low for wicks or min(open, close) for bodies
Short: on the current live bar, at least the predictive minimum bars after the last confirmed RSI pivot high, selected price source is above that pivot's price and RSI(close, divergence RSI lookback) is below that pivot's RSI value; selected price source is high for wicks or max(open, close) for bodies
Short: on the current live bar, at least the predictive minimum bars after the last confirmed RSI pivot high, selected price source is below that pivot's price and RSI(close, divergence RSI lookback) is above that pivot's RSI value; selected price source is high for wicks or max(open, close) for bodies
Long: a confirmed swing high is above the previous swing high OR a confirmed swing low is above the previous swing low, using the configured pivot strength on the chart timeframe and on each enabled higher timeframe's completed bars, evaluated on chart bars
Short: a confirmed swing high is below the previous swing high OR a confirmed swing low is below the previous swing low, using the configured pivot strength on the chart timeframe and on each enabled higher timeframe's completed bars, evaluated on chart bars