Calculation: Body size = |close − open|
Calculation: Upper wick = high − max(open, close)
Calculation: Lower wick = min(open, close) − low
Calculation: Total wick ratio = (upper wick + lower wick) / (body size + upper wick + lower wick)
Long: selected instrument and chart timeframe are enabled AND body size ≥ configured minimum body size AND total wick ratio ≤ configured maximum AND close > open AND (aggressive mode OR lower wick < upper wick) AND (consolidation validation disabled OR each of the configured number of immediately preceding chart bars has a body size < current body size) AND (EMA filter disabled OR close > EMA)
Short: selected instrument and chart timeframe are enabled AND body size ≥ configured minimum body size AND total wick ratio ≤ configured maximum AND close < open AND (aggressive mode OR upper wick < lower wick) AND (consolidation validation disabled OR each of the configured number of immediately preceding chart bars has a body size < current body size) AND (EMA filter disabled OR close < EMA)
