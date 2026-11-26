Calculation: K = selected SMA, EMA, or WMA(StochRSI(RSI(configured RSI source, RSI lookback), RSI lookback), K lookback)
Calculation: D = SMA(K, D lookback)
Calculation: trend-zone state = (DEMA(RSI(OHLC4, RSI lookback), shorter EMA lookback) > DEMA(RSI(OHLC4, RSI lookback), longer EMA lookback) AND close > open AND close > VWAP(configured VWAP source)) ? long : (DEMA(RSI(OHLC4, RSI lookback), shorter EMA lookback) < DEMA(RSI(OHLC4, RSI lookback), longer EMA lookback) AND close < open AND close < VWAP(configured VWAP source)) ? short : prior trend-zone state, initially neutral
Long: RSI(configured RSI source, RSI lookback) crosses above oversold AND flat AND long trading enabled AND datetime >= configured start time AND datetime <= configured end time
Short: RSI(configured RSI source, RSI lookback) crosses below overbought AND flat AND short trading enabled AND datetime >= configured start time AND datetime <= configured end time
Long: trend-zone state is long
Short: trend-zone state is short
Long: K > oversold AND D < overbought AND K > D AND change(K) > 0 AND change(D) > 0
Short: K < overbought AND D > oversold AND K < D AND change(K) < 0 AND change(D) < 0
Exit: long, RSI(configured RSI source, RSI lookback) crosses above overbought AND long trading enabled AND datetime >= configured start time AND datetime <= configured end time
Exit: short, RSI(configured RSI source, RSI lookback) crosses below oversold AND short trading enabled AND datetime >= configured start time AND datetime <= configured end time
Exit: long, low <= entry price * (1 - stop-loss percentage) OR high >= entry price * (1 + target-profit percentage)
Exit: short, high >= entry price * (1 + stop-loss percentage) OR low <= entry price * (1 - target-profit percentage)