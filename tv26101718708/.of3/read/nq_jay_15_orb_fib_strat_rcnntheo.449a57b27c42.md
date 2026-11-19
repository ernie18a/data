Calculation: Opening-range high = maximum high of bars in the configured opening-range session and timezone
Calculation: Opening-range low = minimum low of bars in the configured opening-range session and timezone
Calculation: Opening-range range = opening-range high - opening-range low
Calculation: Long shallow retracement level = opening-range high - opening-range range × shallow retracement parameter
Calculation: Long middle retracement level = opening-range high - opening-range range × middle retracement parameter
Calculation: Long deep retracement level = opening-range high - opening-range range × deep retracement parameter
Calculation: Short shallow retracement level = opening-range low + opening-range range × shallow retracement parameter
Calculation: Short middle retracement level = opening-range low + opening-range range × middle retracement parameter
Calculation: Short deep retracement level = opening-range low + opening-range range × deep retracement parameter
Long: opening range is complete AND no breakout has occurred since the current opening-range session began AND close > opening-range high
Short: opening range is complete AND no breakout has occurred since the current opening-range session began AND close < opening-range low
Long: a bullish opening-range breakout has occurred since the current opening-range session began AND no long setup has occurred in that session AND low <= long shallow retracement level AND high >= long deep retracement level AND candle confirmation is disabled OR close > open AND 60% close confirmation is disabled OR close > long middle retracement level
Short: a bearish opening-range breakout has occurred since the current opening-range session began AND no short setup has occurred in that session AND high >= short shallow retracement level AND low <= short deep retracement level AND candle confirmation is disabled OR close < open AND 60% close confirmation is disabled OR close < short middle retracement level