Calculation: NetBreadth = NewHighs(breadthPeriod) - NewLows(breadthPeriod)
Calculation: BreadthMA = MA(NetBreadth, maLength, maType)
Calculation: PositiveRun = number of consecutive bars ending at current bar with NetBreadth > 0
Calculation: NegativeRun = number of consecutive bars ending at current bar with NetBreadth < 0
Long: PositiveRun >= streakLength
Short: NegativeRun >= streakLength
Long: BreadthMA > BreadthMA[1]
Short: BreadthMA < BreadthMA[1]
Long: NetBreadth > 0
Short: NetBreadth <= 0