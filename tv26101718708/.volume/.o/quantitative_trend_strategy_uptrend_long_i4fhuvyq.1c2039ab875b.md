Calculation: Confirmed pivot high/low close = the close at a local maximum/minimum, confirmed after the specified number of bars to its right have completed; use the latest confirmed pivot of each type.
Long: close > latest confirmed pivot high close
Short: close < latest confirmed pivot low close
Exit: Long, close >= entry price AND a pivot high and pivot low are both confirmed on this bar AND pivot high close < pivot low close
Exit: Short, close <= entry price AND a pivot low and pivot high are both confirmed on this bar AND pivot low close > pivot high close
Exit: Long, close <= entry price × (1 − stop-loss fraction) OR close >= entry price × (1 + take-profit fraction), only when close <= latest confirmed pivot high close
Exit: Short, close >= entry price × (1 + stop-loss fraction) OR close <= entry price × (1 − take-profit fraction), only when close >= latest confirmed pivot low close