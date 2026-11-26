Calculation: RSI long condition = RSI(close, RSI lookback) < oversold threshold AND RSI(close, RSI lookback)[1] <= oversold threshold AND (trend filter disabled OR close > EMA(close, trend-filter lookback))
Calculation: RSI short condition = RSI(close, RSI lookback) > overbought threshold AND RSI(close, RSI lookback)[1] >= overbought threshold AND (trend filter disabled OR close < EMA(close, trend-filter lookback))
Calculation: SuperTrend long condition = SuperTrend direction(factor parameter, ATR lookback) < 0 AND SuperTrend direction(factor parameter, ATR lookback)[1] > 0
Calculation: SuperTrend short condition = SuperTrend direction(factor parameter, ATR lookback) > 0 AND SuperTrend direction(factor parameter, ATR lookback)[1] < 0
Calculation: MACD long condition = MACD line(close, fast lookback, slow lookback, signal lookback) > MACD signal line(close, fast lookback, slow lookback, signal lookback) AND MACD line(close, fast lookback, slow lookback, signal lookback)[1] <= MACD signal line(close, fast lookback, slow lookback, signal lookback)[1]
Calculation: MACD short condition = MACD line(close, fast lookback, slow lookback, signal lookback) < MACD signal line(close, fast lookback, slow lookback, signal lookback) AND MACD line(close, fast lookback, slow lookback, signal lookback)[1] >= MACD signal line(close, fast lookback, slow lookback, signal lookback)[1]
Calculation: Triple EMA long condition = EMA(close, shortest lookback) > EMA(close, intermediate lookback) AND EMA(close, intermediate lookback) > EMA(close, longest lookback) AND (EMA(close, shortest lookback)[1] <= EMA(close, intermediate lookback)[1] OR EMA(close, shortest lookback)[2] <= EMA(close, intermediate lookback)[2])
Calculation: Triple EMA short condition = EMA(close, shortest lookback) < EMA(close, intermediate lookback) AND EMA(close, intermediate lookback) < EMA(close, longest lookback) AND (EMA(close, shortest lookback)[1] >= EMA(close, intermediate lookback)[1] OR EMA(close, shortest lookback)[2] >= EMA(close, intermediate lookback)[2])
Calculation: Bollinger long condition = close < lower Bollinger Band(close, lookback, deviation multiplier) AND close[1] <= lower Bollinger Band(close, lookback, deviation multiplier)[1]
Calculation: Bollinger short condition = close > upper Bollinger Band(close, lookback, deviation multiplier) AND close[1] >= upper Bollinger Band(close, lookback, deviation multiplier)[1]
Long: RSI long condition
Long: SuperTrend long condition
Long: MACD long condition
Long: Triple EMA long condition
Long: Bollinger long condition
Long: at least minimum confirmations of RSI long condition, SuperTrend long condition, MACD long condition, Triple EMA long condition, and Bollinger long condition are true
Short: RSI short condition
Short: SuperTrend short condition
Short: MACD short condition
Short: Triple EMA short condition
Short: Bollinger short condition
Short: at least minimum confirmations of RSI short condition, SuperTrend short condition, MACD short condition, Triple EMA short condition, and Bollinger short condition are true
Exit: long, take-profit/stop-loss enabled AND (high >= close[1] * (1 + take-profit percentage / 100) OR low <= close[1] * (1 - stop-loss percentage / 100))
Exit: short, take-profit/stop-loss enabled AND (low <= close[1] * (1 - take-profit percentage / 100) OR high >= close[1] * (1 + stop-loss percentage / 100))