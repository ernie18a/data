Calculation: volume-weighted-price RSI = RSI(RMA(hlc3 * volume, 1) / RMA(volume, 1), RSI lookback)
Long: volume-weighted-price RSI crosses above long-entry threshold AND close > SMA(close, long-term lookback) AND datetime >= test start AND datetime <= test end
Exit: long, volume-weighted-price RSI crosses below exit threshold