Long: RSI < oversold threshold AND shorter-lookback chart-timeframe SMA(close) < longer-lookback chart-timeframe SMA(close)
Exit: Long, RSI > overbought threshold AND shorter-lookback chart-timeframe SMA(close) > longer-lookback chart-timeframe SMA(close)
Calculation: higher-timeframe long-lookback SMA = simple moving average of close on a timeframe higher than the chart timeframe; uses the current higher-timeframe bar (still forming in real time; lookahead enabled)
Exit: Long, close crosses below the higher-timeframe long-lookback SMA