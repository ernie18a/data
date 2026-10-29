Calculation: Smoothed RSI = EMA of RSI(close), using a shorter EMA lookback than the RSI lookback
Long: datetime is within the configured backtest date range AND short-lookback SMA(close) > longer-lookback VWMA(high) AND on the previous bar SMA(close) <= VWMA(high)
Long: datetime is within the configured backtest date range AND Smoothed RSI > oversold level AND on the previous bar Smoothed RSI <= oversold level
Short: datetime is within the configured backtest date range AND longer-lookback VWMA(high) > short-lookback SMA(close) AND on the previous bar VWMA(high) <= SMA(close)
Short: datetime is within the configured backtest date range AND Smoothed RSI > overbought level AND on the previous bar Smoothed RSI <= overbought level