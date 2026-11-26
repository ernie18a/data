Calculation: In time window = datetime >= configured start time AND datetime <= configured end time
Calculation: Window net change(P) = ((close - open[P]) / open[P]) * 100
Calculation: Window high change(P) = ((highest(high, P + 1) - open[P]) / open[P]) * 100
Calculation: Window low change(P) = ((lowest(low, P + 1) - open[P]) / open[P]) * 100
Calculation: Prior-open high change(P) = ((highest(high, P + 1) - open[1]) / open[1]) * 100
Calculation: Prior-open low change(P) = ((lowest(low, P + 1) - open[1]) / open[1]) * 100
Calculation: Previous-bar change = ((close[1] - open[1]) / open[1]) * 100
Calculation: Dip pattern = Window net change(P) < 0 AND Window high change(P) > 0 AND Window low change(P) < 0 AND Prior-open high change(P) > 0 AND Prior-open low change(P) < 0 AND Previous-bar change < 0
Calculation: Peak pattern = Window net change(P) > 0 AND Window high change(P) > 0 AND Window low change(P) > 0 AND Prior-open high change(P) > 0 AND Prior-open low change(P) < 0 AND Previous-bar change > 0
Calculation: Upper RSI reference = round(mean of RSI(source, shared RSI and MACD signal lookback)[i] for i = 0 through upper RSI lookback when each value > upper RSI minimum)
Calculation: Lower RSI reference = round(mean of RSI(source, shared RSI and MACD signal lookback)[i] for i = 5, 10, ... through lower RSI lookback when each value < lower RSI minimum)
Calculation: Smoothed RSI = EMA(RSI(source, shared RSI and MACD signal lookback), shared RSI and MACD signal lookback)
Calculation: Fast RSI trend = DEMA(Smoothed RSI, fast lookback)
Calculation: Slow RSI trend = DEMA(Smoothed RSI, slow lookback)
Calculation: Bullish RSI trend = Fast RSI trend > Slow RSI trend AND Smoothed RSI >= Smoothed RSI[1]
Calculation: Bearish RSI trend = Fast RSI trend < Slow RSI trend AND Smoothed RSI <= Smoothed RSI[1]
Calculation: Stochastic K = selected SMA, EMA, or WMA of Stochastic(close, high source, low source, stochastic lookback), using K smoothing lookback
Calculation: Stochastic D = SMA(Stochastic K, D lookback)
Calculation: Long RSI filter = Smoothed RSI > RSI(source, shared RSI and MACD signal lookback) AND Stochastic K < Stochastic D
Calculation: Short RSI filter = Smoothed RSI < RSI(source, shared RSI and MACD signal lookback) AND Stochastic D < Stochastic K
Long: Bullish RSI trend
Short: Bearish RSI trend
Long: Stochastic K > oversold AND Stochastic D < overbought AND Stochastic K > Stochastic D AND Stochastic K > Stochastic K[1] AND Stochastic D > Stochastic D[1]
Short: Stochastic K < overbought AND Stochastic D > oversold AND Stochastic K < Stochastic D AND Stochastic K < Stochastic K[1] AND Stochastic D < Stochastic D[1]
Long: MACD(close, fast lookback, slow lookback, shared RSI and MACD signal lookback).line > MACD(close, fast lookback, slow lookback, shared RSI and MACD signal lookback).signal AND Stochastic K > 50 AND RSI(source, shared RSI and MACD signal lookback) > 50
Short: MACD(close, fast lookback, slow lookback, shared RSI and MACD signal lookback).line < MACD(close, fast lookback, slow lookback, shared RSI and MACD signal lookback).signal
Long: Connors RSI mode selected AND close > SMA(close, middle Connors MA lookback) AND close < SMA(close, long Connors MA lookback) AND RSI(source, shared RSI and MACD signal lookback) <= oversold
Short: Connors RSI mode selected AND close < SMA(close, middle Connors MA lookback) AND close > SMA(close, long Connors MA lookback) AND RSI(source, shared RSI and MACD signal lookback) <= overbought
Long: MACD(close, fast lookback, slow lookback, shared RSI and MACD signal lookback).line > MACD(close, fast lookback, slow lookback, shared RSI and MACD signal lookback).signal AND RSI(source, shared RSI and MACD signal lookback) < Lower RSI reference AND Window net change(P) < 0 AND In time window
Short: MACD(close, fast lookback, slow lookback, shared RSI and MACD signal lookback).line < MACD(close, fast lookback, slow lookback, shared RSI and MACD signal lookback).signal AND RSI(source, shared RSI and MACD signal lookback) > Upper RSI reference AND Window net change(P) > 0 AND In time window
Long: Long trades enabled AND Stochastic mode selected AND crossover(Stochastic K, Stochastic D) AND Stochastic K > Stochastic K[1] AND Stochastic D > Stochastic D[1] AND Stochastic K < RSI(source, shared RSI and MACD signal lookback) AND Stochastic D < RSI(source, shared RSI and MACD signal lookback) AND In time window
Short: Short trades enabled AND Stochastic mode selected AND crossunder(Stochastic K, Stochastic D) AND Stochastic K < Stochastic K[1] AND Stochastic D < Stochastic D[1] AND Stochastic K < RSI(source, shared RSI and MACD signal lookback) AND Stochastic D < RSI(source, shared RSI and MACD signal lookback) AND In time window
Long: Long trades enabled AND RSI crossing-back mode selected AND Long RSI filter AND crossover(RSI(source, shared RSI and MACD signal lookback), oversold) AND Window net change(P) > 0 AND In time window
Short: Short trades enabled AND RSI crossing-back mode selected AND Short RSI filter AND crossunder(RSI(source, shared RSI and MACD signal lookback), overbought) AND Window net change(P) < 0 AND In time window
Long: Long trades enabled AND MACD mode selected AND Long RSI filter AND MACD(close, fast lookback, slow lookback, shared RSI and MACD signal lookback).line > MACD(close, fast lookback, slow lookback, shared RSI and MACD signal lookback).signal AND RSI(source, shared RSI and MACD signal lookback) < Lower RSI reference AND Window net change(P) < 0 AND In time window
Short: Short trades enabled AND MACD mode selected AND Short RSI filter AND MACD(close, fast lookback, slow lookback, shared RSI and MACD signal lookback).line < MACD(close, fast lookback, slow lookback, shared RSI and MACD signal lookback).signal AND RSI(source, shared RSI and MACD signal lookback) > Upper RSI reference AND Window net change(P) > 0 AND In time window
Long: Long trades enabled AND Connors RSI mode selected AND Long RSI filter AND SMA(close, middle Connors MA lookback) < SMA(close, long Connors MA lookback) AND SMA(close, long Connors MA lookback) > close AND RSI(source, shared RSI and MACD signal lookback) <= oversold AND Dip pattern AND In time window
Short: Short trades enabled AND Connors RSI mode selected AND Short RSI filter AND SMA(close, short Connors MA lookback) > SMA(close, middle Connors MA lookback) AND open > SMA(close, long Connors MA lookback) AND RSI(source, shared RSI and MACD signal lookback) >= overbought AND Peak pattern AND In time window
Long: Long trades enabled AND EMA mode selected AND crossover(Smoothed RSI, Slow RSI trend) AND crossover(Smoothed RSI, Fast RSI trend) AND Bullish RSI trend AND In time window
Short: Short trades enabled AND EMA mode selected AND crossunder(Smoothed RSI, Fast RSI trend) AND crossunder(Smoothed RSI, Slow RSI trend) AND Bearish RSI trend AND In time window
Long: Long trades enabled AND no alternate mode selected AND RSI(source, shared RSI and MACD signal lookback) < oversold AND Dip pattern AND In time window
Short: Short trades enabled AND no alternate mode selected AND Short RSI filter AND RSI(source, shared RSI and MACD signal lookback) > overbought AND Peak pattern AND In time window
Exit: long, short trades enabled AND EMA mode selected AND crossunder(Fast RSI trend, Slow RSI trend) AND Bearish RSI trend AND In time window
Exit: long, low <= entry price * (1 - stop-loss percentage) OR high >= entry price * (1 + target-profit percentage)
Exit: short, high >= entry price * (1 + stop-loss percentage) OR low <= entry price * (1 - target-profit percentage)