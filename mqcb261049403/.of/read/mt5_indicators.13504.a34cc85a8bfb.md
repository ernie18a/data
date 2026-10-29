Calculation: Impulse MACD = (weighted-price SMA − high-price SMMA) when the weighted-price SMA is above the high-price SMMA; (weighted-price SMA − low-price SMMA) when it is below the low-price SMMA; otherwise 0
Calculation: Signal line = trailing average of the Impulse MACD over a shorter lookback than the Impulse MACD’s high/low SMMA lookback; when Impulse MACD is 0, carry forward the previous Signal line value
Long: Impulse MACD > 0 OR Impulse MACD > Signal line
Short: Impulse MACD < 0 OR Impulse MACD < Signal line
Long: Higher-timeframe Impulse MACD > 0 OR Higher-timeframe Impulse MACD > Higher-timeframe Signal line (higher-timeframe bar still forming)
Short: Higher-timeframe Impulse MACD < 0 OR Higher-timeframe Impulse MACD < Higher-timeframe Signal line (higher-timeframe bar still forming)