Calculation: PEMA direction = rising when PEMA(close, lookback, T1) > PEMA(close, lookback, T1)[1], falling when lower, and otherwise unchanged from its previous direction
Long: Long entry permitted AND, on T1 bars using the last completed bar, PEMA direction changes from non-rising to rising
Short: Short entry permitted AND, on T1 bars using the last completed bar, PEMA direction changes from non-falling to falling
Exit: long, Time exit enabled AND elapsed time since entry exceeds the holding-duration parameter in minutes
Exit: short, Time exit enabled AND elapsed time since entry exceeds the holding-duration parameter in minutes