Calculation: Multiplier = MAX(minimum multiplier, base multiplier + (PERCENTRANK(ATR(high, low, close, ATR lookback), volatility rank lookback) / 100 - 0.5) * 2 * adaptive range)
Calculation: UpperBand = raw upper if (raw upper < UpperBand[1] OR close[1] > UpperBand[1]), otherwise UpperBand[1]; raw upper = band source + Multiplier * ATR(high, low, close, ATR lookback)
Calculation: LowerBand = raw lower if (raw lower > LowerBand[1] OR close[1] < LowerBand[1]), otherwise LowerBand[1]; raw lower = band source - Multiplier * ATR(high, low, close, ATR lookback)
Calculation: Direction = 1 if (Direction[1] = -1 AND close > UpperBand[1]); -1 if (Direction[1] = 1 AND close < LowerBand[1]); otherwise Direction[1]
Long: Direction = 1
Long: Direction[1] = -1 AND Direction = 1 AND close > EMA(close, trend EMA lookback) AND (momentum confluence = off OR (momentum type = RSI AND RSI(close, RSI lookback) > RSI midline) OR (momentum type = MACD AND MACD histogram(close, shorter lookback, longer lookback, MACD signal lookback) > 0))
Short: Direction = -1
Short: Direction[1] = 1 AND Direction = -1 AND close < EMA(close, trend EMA lookback) AND (momentum confluence = off OR (momentum type = RSI AND RSI(close, RSI lookback) < RSI midline) OR (momentum type = MACD AND MACD histogram(close, shorter lookback, longer lookback, MACD signal lookback) < 0))