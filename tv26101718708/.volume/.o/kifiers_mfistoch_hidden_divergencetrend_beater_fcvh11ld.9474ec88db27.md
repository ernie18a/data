Calculation: ranging = EMA of (ATR(14) / close) with shorter lookback < EMA of (ATR(14) / close) with longer lookback
Calculation: bullish divergence = confirmed price pivot low is higher than the previous price pivot low AND confirmed MFI pivot low is higher than the previous MFI pivot low
Calculation: trend filter = OBV > EMA(OBV) AND ranging is false
Long: Stochastic >= 50 AND MFI crosses above 50 AND VWMA > SMA AND close >= VWMA AND trend filter
Long: bullish divergence AND VWMA > SMA AND close >= VWMA AND Stochastic >= 50 AND ranging AND position is flat, during the signal bar or within the next 5 bars
Exit: long, close >= entry price × (1 + take-profit percentage) OR close <= support level captured when entering