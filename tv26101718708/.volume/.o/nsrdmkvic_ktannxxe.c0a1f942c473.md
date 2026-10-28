Calculation: Higher-timeframe RSI = RSI of source close on higher-timeframe bars, using the still-forming bar
Calculation: Short and long EMAs = EMAs of close on MTF bars, using the still-forming bar; the short EMA has a shorter lookback than the long EMA
Calculation: Volume threshold = median of the prior three bar volumes and three zero values
Calculation: VZO = 100 × EMA(signed volume, lookback) / EMA(volume, same lookback), where signed volume is volume if close > prior close, otherwise negative volume
Long: prior sampled higher-timeframe RSI < low threshold AND current higher-timeframe RSI >= low threshold AND (EMA filter is off OR short-lookback EMA > long-lookback EMA) AND volume > volume threshold AND close > open AND VZO <= negative lower VZO threshold
Short: prior sampled higher-timeframe RSI > high threshold AND current higher-timeframe RSI <= high threshold AND (EMA filter is off OR short-lookback EMA < long-lookback EMA) AND volume > volume threshold AND open > close AND VZO >= lower VZO threshold
Exit: long, low <= entry price × (1 − stop-loss fraction) OR high >= entry price × (1 + take-profit fraction)