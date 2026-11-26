Calculation: ATR = ATR(high, low, close, ATR length)
Calculation: adaptive multiplier = base multiplier * (dynamic multiplier enabled ? clamp(ATR / SMA(ATR, volatility lookback), low bound, high bound) : 1)
Calculation: trend direction = SuperTrend direction(high, low, close, ATR, adaptive multiplier)
Calculation: trend line = SuperTrend line(high, low, close, ATR, adaptive multiplier)
Calculation: fast EMA = EMA(close, shorter lookback)
Calculation: slow EMA = EMA(close, longer lookback)
Calculation: EMA slope = fast EMA - fast EMA[slope lookback]
Calculation: long EMA filter = EMA filter disabled OR (EMA mode M1 AND fast EMA > slow EMA) OR (EMA mode M2 AND close > fast EMA) OR (EMA mode M3 AND close > slow EMA) OR (EMA mode M4 AND EMA slope > 0)
Calculation: short EMA filter = EMA filter disabled OR (EMA mode M1 AND fast EMA < slow EMA) OR (EMA mode M2 AND close < fast EMA) OR (EMA mode M3 AND close < slow EMA) OR (EMA mode M4 AND EMA slope < 0)
Calculation: volume filter = volume filter disabled OR volume > SMA(volume, volume lookback) * volume multiplier
Long: trend direction crosses above 0 AND long EMA filter AND volume filter
Long: trend direction crosses above 0 AND NOT (long EMA filter AND volume filter)
Long: trend direction crosses above 0
Long: trend direction = 1
Long: trend direction = 1 AND long EMA filter AND volume filter
Short: trend direction crosses below 0 AND short EMA filter AND volume filter
Short: trend direction crosses below 0 AND NOT (short EMA filter AND volume filter)
Short: trend direction crosses below 0
Short: trend direction = -1
Short: trend direction = -1 AND short EMA filter AND volume filter
Exit: long, low <= trend line - SL buffer * ATR
Exit: short, high >= trend line + SL buffer * ATR