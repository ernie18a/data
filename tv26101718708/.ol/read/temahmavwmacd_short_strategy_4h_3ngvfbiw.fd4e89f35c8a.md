Calculation: VWMACD histogram = (EMA(volume × close, shorter lookback) / EMA(volume, shorter lookback) − EMA(volume × close, longer lookback) / EMA(volume, longer lookback)) − EMA(VWMACD, signal lookback)
Calculation: TEMA spread = shorter-lookback TEMA of HLC3 − longer-lookback TEMA of HLC3
Short: VWMACD histogram < 0 AND close < HMA AND TEMA spread < 0
Exit: short, VWMACD histogram > 0 OR close > HMA OR TEMA spread crosses above 0 OR low ≤ entry price − close × take-profit percentage OR high ≥ entry price + close × stop-loss percentage