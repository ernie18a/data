Calculation: premarket high = highest high of T1 bars inside the premarket session on the current trading day, including the T1 bar still forming
Calculation: premarket low = lowest low of T1 bars inside the premarket session on the current trading day, including the T1 bar still forming
Calculation: fast EMA = EMA(close, shortest lookback, T1 bars, bar still forming)
Calculation: middle EMA = EMA(close, middle lookback, T1 bars, bar still forming)
Calculation: slow EMA = EMA(close, longest lookback, T1 bars, bar still forming)
Long: on chart bars taking T1 values, close of T1 bar still forming > premarket high AND T1 bar time outside premarket session
Short: on chart bars taking T1 values, close of T1 bar still forming < premarket low AND T1 bar time outside premarket session
Long: on chart bars taking T1 values, close of T1 bar still forming > fast EMA AND fast EMA > middle EMA AND middle EMA > slow EMA
Short: on chart bars taking T1 values, close of T1 bar still forming < fast EMA AND fast EMA < middle EMA AND middle EMA < slow EMA
Long: on chart bars taking T2 values, high of T2 bar still forming > high of last completed T2 bar
Short: on chart bars taking T2 values, low of T2 bar still forming < low of last completed T2 bar