Calculation: intraday bar count = number of chart bars since the start of the trading session
Long: RSI(close, RSI lookback) crosses above EMA(RSI(close, RSI lookback), RSI EMA lookback) AND volume > SMA(volume, volume lookback) AND intraday bar count is not exit-bar parameter
Short: RSI(close, RSI lookback) < EMA(RSI(close, RSI lookback), RSI EMA lookback) AND intraday bar count is not exit-bar parameter
Exit: long, intraday bar count equals exit-bar parameter
Exit: short, intraday bar count equals exit-bar parameter