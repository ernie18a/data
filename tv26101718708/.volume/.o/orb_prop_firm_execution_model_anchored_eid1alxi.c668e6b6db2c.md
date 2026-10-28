Calculation: Opening range high/low = highest high/lowest low during the initial session opening range; fixed once that range ends
Calculation: Session-anchored VWAP = cumulative typical price × volume since session open divided by cumulative volume since session open
Calculation: Close moving average = moving average of close
Calculation: Volume moving average = moving average of volume
Long: Opening range is ready AND close crosses above opening range high AND close > session-anchored VWAP AND close > close moving average AND close moving average > its previous value AND volume > volume moving average × a threshold AND NOT (high > opening range high AND close < opening range high)
Short: Opening range is ready AND close crosses below opening range low AND close < session-anchored VWAP AND close < close moving average AND close moving average < its previous value AND volume > volume moving average × a threshold AND NOT (low < opening range low AND close > opening range low)