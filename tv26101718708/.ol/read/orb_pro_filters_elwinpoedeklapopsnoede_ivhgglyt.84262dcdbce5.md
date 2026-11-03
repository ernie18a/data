Calculation: Opening-range high = highest high during the opening-range period, reset each day
Calculation: Opening-range low = lowest low during the opening-range period, reset each day
Calculation: EMA = exponential moving average of close
Long: close > opening-range high AND previous close <= opening-range high AND during the US session AND outside the opening-range period AND close > EMA
Short: close < opening-range low AND previous close >= opening-range low AND during the US session AND outside the opening-range period AND close < EMA
Exit: long, low <= opening-range low OR high >= entry price + (entry price - opening-range low)
Exit: short, high >= opening-range high OR low <= entry price - (opening-range high - entry price)