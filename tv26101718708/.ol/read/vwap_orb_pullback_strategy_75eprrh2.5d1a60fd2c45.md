Calculation: Opening range high = highest high from 09:30 New York time through the configured opening-range end time, reset each New York day
Calculation: Opening range low = lowest low from 09:30 New York time through the configured opening-range end time, reset each New York day
Long: close > opening range high AND close > VWAP AND close > short-term EMA(close) AND low <= VWAP AND datetime is after the opening-range end time
Short: close < opening range low AND close < VWAP AND close < short-term EMA(close) AND high >= VWAP AND datetime is after the opening-range end time
Exit: long, low <= close - ATR OR high >= close + ATR × configured risk/reward ratio
Exit: short, high >= close + ATR OR low <= close - ATR × configured risk/reward ratio