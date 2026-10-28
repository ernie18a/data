Calculation: RVOL = current bar volume / simple moving average of volume over the preceding lookback bars, excluding the current bar
Long: close > Hull moving average AND RVOL > RVOL threshold
Short: close < Hull moving average AND RVOL > RVOL threshold
Exit: Long, low <= entry price * (1 - stop-loss %) OR high >= entry price * (1 + take-profit %)
Exit: Short, high >= entry price * (1 + stop-loss %) OR low <= entry price * (1 - take-profit %)