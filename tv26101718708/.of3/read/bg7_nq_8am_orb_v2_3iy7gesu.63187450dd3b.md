Calculation: opening-range high = maximum high during the configured opening-range window, reset each day
Calculation: opening-range low = minimum low during the configured opening-range window, reset each day
Calculation: buffer distance = buffer-tick parameter × tick-size parameter
Long: outside the configured opening-range window after its high is set, close > opening-range high AND close <= opening-range high + buffer distance
Short: outside the configured opening-range window after its low is set, close < opening-range low AND close >= opening-range low - buffer distance