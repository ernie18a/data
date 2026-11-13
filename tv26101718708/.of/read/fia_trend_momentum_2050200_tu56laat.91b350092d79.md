Calculation: EMA stack = bullish when EMA(close, short lookback) > EMA(close, medium lookback) > EMA(close, long lookback); bearish when the order is reversed. The chart stack uses chart-timeframe bars. The HTF stack uses bars of a timeframe higher than the chart, taking the last completed higher-timeframe bar.
Calculation: MACD = classic MACD of close (fast EMA < slow EMA), with signal line and histogram = MACD line - signal line.
Calculation: LongScore = 2*(chart stack bullish) + (RSI > RSI midline) + (MACD line > signal line) + (histogram > previous bar histogram) + (HTF stack bullish)
Calculation: ShortScore = 2*(chart stack bearish) + (RSI < RSI midline) + (MACD line < signal line) + (histogram < previous bar histogram) + (HTF stack bearish)
Calculation: LongPullback = chart stack bullish AND low <= short EMA AND close > short EMA AND RSI > previous bar RSI AND RSI > a fixed level slightly below the RSI midline AND MACD line > signal line AND HTF stack bullish
Calculation: ShortPullback = chart stack bearish AND high >= short EMA AND close < short EMA AND RSI < previous bar RSI AND RSI < a fixed level slightly above the RSI midline AND MACD line < signal line AND HTF stack bearish
Calculation: LongTrigger = LongScore >= a minimum score close to the maximum possible score AND HTF stack bullish AND (LongPullback OR MACD line crosses above signal line on this bar)
Calculation: ShortTrigger = ShortScore >= the same minimum score AND HTF stack bearish AND (ShortPullback OR MACD line crosses below signal line on this bar)
Long: LongTrigger is true on this bar AND LongTrigger was false on the previous bar
Short: ShortTrigger is true on this bar AND ShortTrigger was false on the previous bar