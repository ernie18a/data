Calculation: Running high = highest high since the most recent long or short signal; initialize to the first bar’s high and reset to the signal bar’s high after each signal
Calculation: Running low = lowest low since the most recent long or short signal; initialize to the first bar’s low and reset to the signal bar’s low after each signal
Calculation: Last signal direction = 0 initially; set to 1 on a long signal and -1 on a short signal
Long: (Last signal direction <= 0 AND Running high - low >= move threshold AND close > open) OR (EMA(9) > session VWAP AND prior EMA(9) <= prior session VWAP)
Short: (Last signal direction >= 0 AND high - Running low >= move threshold AND close < open) OR (EMA(9) < session VWAP AND prior EMA(9) >= prior session VWAP)