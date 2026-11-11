Calculation: Requested series = evaluate the expression on each configured timeframe; for a higher timeframe, historical bars use the final value of the higher-timeframe bar mapped from its first chart bar, while the current bar uses the still-forming value; for a lower timeframe, use the first intrabar; for the chart timeframe, use the chart bar.
Calculation: Smoothed stochastic RSI = SMA of 100 × (RSI of close − lowest RSI) / (highest RSI − lowest RSI), using a configurable RSI length, stochastic lookback, and smoothing length; use 50 when the highest and lowest RSI are equal, and use 50 if the result is unavailable. Calculate on each configured stochastic RSI timeframe before mapping to chart bars.
Calculation: Price-low pivot = requested low equals its lowest value over a configurable chart-bar lookback including the current bar.
Calculation: Price-high pivot = requested high equals its highest value over the same chart-bar lookback including the current bar.
Calculation: Bullish divergence = price-low pivot AND requested low < requested low at the previous price-low pivot AND smoothed stochastic RSI > smoothed stochastic RSI at that previous pivot AND smoothed stochastic RSI <= oversold threshold plus a configurable offset.
Calculation: Bearish divergence = price-high pivot AND requested high > requested high at the previous price-high pivot AND smoothed stochastic RSI < smoothed stochastic RSI at that previous pivot AND smoothed stochastic RSI >= overbought threshold minus a configurable offset.
Long: Requested close > EMA or SMA of close calculated on the same configured trend timeframe.
Short: Requested close <= EMA or SMA of close calculated on the same configured trend timeframe, AND both values are available.
Long: Count of configured trend timeframes with close > selected moving average > count with close <= selected moving average, excluding unavailable values.
Short: Count of configured trend timeframes with close <= selected moving average > count with close > selected moving average, excluding unavailable values.
Long: Smoothed stochastic RSI <= oversold threshold on any configured stochastic RSI timeframe.
Short: Smoothed stochastic RSI >= overbought threshold on any configured stochastic RSI timeframe.
Long: Bullish divergence on any configured stochastic RSI timeframe.
Short: Bearish divergence AND no bullish divergence on the same configured stochastic RSI timeframe.