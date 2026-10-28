Calculation: OHLC4 = (open + high + low + close) / 4
Calculation: DEMA(x, n) = 2 × EMA(x, n) − EMA(EMA(x, n), n)
Calculation: StochRSI = 100 × (RSI − lowest RSI over the RSI lookback) / (highest RSI over the RSI lookback − lowest RSI over the RSI lookback)
Calculation: K = selected SMA, EMA, or WMA of StochRSI; D = SMA of K
Long: RSI of selected price source crosses above oversold AND position is flat AND long trading is enabled AND datetime is within the configured backtest window
Short: RSI of selected price source crosses below overbought AND position is flat AND short trading is enabled AND datetime is within the configured backtest window
Long: DEMA of RSI(OHLC4) with the shorter lookback > DEMA of RSI(OHLC4) with the longer lookback AND close > open AND close > session VWAP of selected source
Short: DEMA of RSI(OHLC4) with the shorter lookback < DEMA of RSI(OHLC4) with the longer lookback AND close < open AND close < session VWAP of selected source
Long: K > oversold AND D < overbought AND K > D AND K is rising AND D is rising
Short: K < overbought AND D > oversold AND K < D AND K is falling AND D is falling
Exit: long, RSI of selected price source crosses above overbought AND long trading is enabled AND datetime is within the configured backtest window
Exit: short, RSI of selected price source crosses below oversold AND short trading is enabled AND datetime is within the configured backtest window
Exit: long, low ≤ entry price × (1 − stop-loss fraction) OR high ≥ entry price × (1 + target-profit fraction)
Exit: short, high ≥ entry price × (1 + stop-loss fraction) OR low ≤ entry price × (1 − target-profit fraction)