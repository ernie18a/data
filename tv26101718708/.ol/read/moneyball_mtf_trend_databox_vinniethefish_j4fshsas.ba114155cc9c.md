Calculation: DEMA = 2 × EMA(close) − EMA(EMA(close)), using the same lookback for both EMAs
Calculation: TEMA = 3 × EMA(close) − 3 × EMA(EMA(close)) + EMA(EMA(EMA(close))), using the same lookback for all EMAs
Long: On each requested timeframe, close > the selected SMA, EMA, DEMA, or TEMA; use the last completed bar for higher timeframes and the latest completed bar for lower timeframes
Short: On each requested timeframe, close ≤ the selected SMA, EMA, DEMA, or TEMA; use the last completed bar for higher timeframes and the latest completed bar for lower timeframes