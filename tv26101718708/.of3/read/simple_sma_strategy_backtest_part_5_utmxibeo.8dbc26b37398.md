Calculation: Direction state = 1 when trigger source > SMA(selected source sampled from T1, lookback chart bars), -1 when trigger source < that SMA, otherwise the previous direction state (initially 0); historical T1 samples use the latest completed bar, and realtime samples use the T1 bar still forming
Calculation: Session active = time(T2, selected session) is not NA, evaluated on chart bars
Long: ((direction state changes to 1 AND reverse setting is off) OR (direction state changes to -1 AND reverse setting is on)) AND session active
Short: ((direction state changes to -1 AND reverse setting is off) OR (direction state changes to 1 AND reverse setting is on)) AND session active
Long: alerts enabled AND direction state changes to 1
Short: alerts enabled AND direction state changes to -1
Exit: long, alerts enabled AND direction state changes to 0
Exit: short, alerts enabled AND direction state changes to 0
Long: bar painting enabled AND position is open AND direction state = 1
Short: bar painting enabled AND position is open AND direction state = -1
Exit: long, high > entry price + take-profit parameter OR low < entry price - stop-loss parameter OR session active is false
Exit: short, low < entry price - take-profit parameter OR high > entry price + stop-loss parameter OR session active is false