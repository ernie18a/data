Calculation: Trend RSI = RSI of (open + high + low + close) / 4
Calculation: Fast trend line = double EMA of Trend RSI using the shorter EMA lookback; double EMA = 2 × EMA(series) − EMA(EMA(series))
Calculation: Slow trend line = double EMA of Trend RSI using the longer EMA lookback
Calculation: Stochastic RSI = stochastic value of RSI of the configured price source, using the same lookback for the stochastic range as for RSI
Calculation: K = selected SMA, EMA, or WMA of Stochastic RSI
Calculation: D = SMA of K
Long: Long trading is enabled AND position is flat AND datetime is within the configured backtest window AND RSI of the configured price source crosses above the oversold threshold
Long: Fast trend line > Slow trend line AND close > open AND close > VWAP of the configured source
Long: K > oversold threshold AND D < overbought threshold AND K > D AND K is rising AND D is rising
Short: Short trading is enabled AND position is flat AND datetime is within the configured backtest window AND RSI of the configured price source crosses below the overbought threshold
Short: Fast trend line < Slow trend line AND close < open AND close < VWAP of the configured source
Short: K < overbought threshold AND D > oversold threshold AND K < D AND K is falling AND D is falling
Exit: Long, datetime is within the configured backtest window AND RSI of the configured price source crosses above the overbought threshold OR low <= entry price × (1 − stop-loss fraction) OR high >= entry price × (1 + target-profit fraction)
Exit: Short, datetime is within the configured backtest window AND RSI of the configured price source crosses below the oversold threshold OR high >= entry price × (1 + stop-loss fraction) OR low <= entry price × (1 − target-profit fraction)