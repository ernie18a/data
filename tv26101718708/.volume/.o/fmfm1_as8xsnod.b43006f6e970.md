Calculation: short EMA = EMA(close, shorter lookback); medium EMA = EMA(open, medium lookback); long EMA = EMA(close, longer lookback)
Calculation: MA spread = maximum of the three EMAs − minimum of the three EMAs
Calculation: separation threshold = ATR × percentage
Calculation: TMA = SMA((high + low) / 2, lookback)
Calculation: MACD line = shorter-lookback EMA(close) − longer-lookback EMA(close)
Calculation: MACD signal line = EMA(MACD line, shorter lookback than the MACD line EMAs)
Long: short EMA > medium EMA AND MA spread > separation threshold OR MACD line ≥ MACD signal line OR TMA > previous TMA AND previous TMA ≤ TMA two bars ago
Short: medium EMA > short EMA AND MA spread > separation threshold OR MACD line < MACD signal line OR TMA < previous TMA AND previous TMA ≥ TMA two bars ago