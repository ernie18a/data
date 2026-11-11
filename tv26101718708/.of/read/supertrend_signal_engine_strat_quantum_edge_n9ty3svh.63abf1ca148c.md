Calculation: Volatility = either ATR or the simple moving average of true range, using the same lookback.
Calculation: Trailing bands = selected price source minus and plus a multiplier times volatility. For the lower band, if the previous close is above the previous lower band, use the greater of the current raw lower band and previous lower band; otherwise use the current raw lower band. For the upper band, if the previous close is below the previous upper band, use the lesser of the current raw upper band and previous upper band; otherwise use the current raw upper band. When a previous band is unavailable, use the current raw band in its place.
Calculation: Trend state = initially bullish; change bearish to bullish when close is above the previous upper band, or bullish to bearish when close is below the previous lower band; otherwise retain the previous state.
Calculation: Bias moving averages = shorter- and longer-lookback moving averages of close, both either EMA or SMA. Evaluate each configured timeframe independently: use the last completed bar for a higher timeframe, the last completed intrabar within the chart bar for a lower timeframe, and the chart bar for the chart timeframe.
Long: Trend state is bullish AND previous trend state is bearish.
Short: Trend state is bearish AND previous trend state is bullish.
Long: Trend state is bullish.
Short: Trend state is bearish.
Long: On the previous bar, bars since the bullish trend flip < bars since the bearish trend flip.
Short: On the previous bar, bars since the bullish trend flip > bars since the bearish trend flip.
Long: Shorter-lookback bias moving average >= longer-lookback bias moving average.
Short: Shorter-lookback bias moving average < longer-lookback bias moving average.
Exit: short, trend state is bullish AND previous trend state is bearish AND bar datetime is within the inclusive configured date window.
Exit: long, trend state is bearish AND previous trend state is bullish AND bar datetime is within the inclusive configured date window.