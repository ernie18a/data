Calculation: OBV = cumulative volume, adding volume when close rises, subtracting volume when close falls, and adding zero when unchanged
Calculation: Detrended OBV = OBV − its simple moving average over a lookback
Long: longer-lookback EMA(close) > shorter-lookback EMA(close) AND current Detrended OBV > 0 AND previous Detrended OBV <= 0
Exit: long, high >= entry price + close × profit-target-percent OR low <= entry price − close × loss-limit-percent