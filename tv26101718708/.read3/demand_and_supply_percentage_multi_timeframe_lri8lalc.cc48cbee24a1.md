Calculation: Demand(T) = if high(T) - low(T) != 0 then 100 * (close(T) - low(T)) / (high(T) - low(T)) else 50, using T-bar values returned on each chart bar (last completed on historical bars and still forming in real time); T1 through T5 are separate timeframes ordered longest to shortest
Calculation: Supply(T) = 100 - Demand(T)
Long: Demand(T1) > threshold
Long: Demand(T2) > threshold
Long: Demand(T3) > threshold
Long: Demand(T4) > threshold
Long: Demand(T5) > threshold
Short: Supply(T1) > threshold
Short: Supply(T2) > threshold
Short: Supply(T3) > threshold
Short: Supply(T4) > threshold
Short: Supply(T5) > threshold