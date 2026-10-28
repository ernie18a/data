Calculation: Opening-range high = highest high from 9:30 a.m. New York time through the configured opening-range end, including the bar still forming; reset each day.
Calculation: Opening-range low = lowest low from 9:30 a.m. New York time through the configured opening-range end, including the bar still forming; reset each day.
Long: datetime is after the opening-range end AND close > opening-range high AND close > VWAP AND close > EMA(9) AND low <= VWAP
Short: datetime is after the opening-range end AND close < opening-range low AND close < VWAP AND close < EMA(9) AND high >= VWAP
Exit: long, low <= entry price - ATR(14) OR high >= entry price + ATR(14) × risk/reward ratio
Exit: short, high >= entry price + ATR(14) OR low <= entry price - ATR(14) × risk/reward ratio