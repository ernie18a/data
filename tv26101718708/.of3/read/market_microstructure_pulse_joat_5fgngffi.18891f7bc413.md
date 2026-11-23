Calculation: tick direction = for each T1 bar within the chart bar, +1 if its close is above the previous T1 bar's close within the chart bar, -1 if below, 0 if equal or if it is the first T1 bar of the chart bar
Calculation: up-tick count = number of T1 bars within the chart bar with tick direction = +1
Calculation: down-tick count = number of T1 bars within the chart bar with tick direction = -1
Calculation: tick count = up-tick count + down-tick count
Calculation: tick imbalance = (up-tick count - down-tick count) / tick count
Calculation: flow oscillator = EMA(if volume weighting then tick-imbalance weight * tick imbalance + volume-imbalance weight * ((sum of T1 volume within the chart bar with tick direction = +1 - sum of T1 volume within the chart bar with tick direction = -1) / sum of T1 volume within the chart bar with tick direction != 0) else tick imbalance, oscillator EMA length)
Calculation: buy tick share = 100 * up-tick count / tick count
Calculation: sell tick share = 100 * down-tick count / tick count
Calculation: dominant aggression side = +1 if the last T1 bar within the chart bar with tick direction != 0 has tick direction +1, -1 if it has tick direction -1, 0 if there is none
Calculation: max up-tick run = longest run of +1 tick directions within the chart bar, where 0 neither extends nor breaks the run and -1 breaks it
Calculation: max down-tick run = longest run of -1 tick directions within the chart bar, where 0 neither extends nor breaks the run and +1 breaks it
Long: flow oscillator > 0
Short: flow oscillator < 0
Long: flow oscillator crosses above zero
Short: flow oscillator crosses below zero
Long: flow oscillator > extreme threshold
Short: flow oscillator < -extreme threshold
Long: flow oscillator crosses above extreme threshold
Short: flow oscillator crosses below -extreme threshold
Long: buy tick share >= imbalance threshold AND tick count >= minimum tick count
Short: sell tick share >= imbalance threshold AND buy tick share < imbalance threshold AND tick count >= minimum tick count
Long: flow oscillator crosses above extreme threshold AND dominant aggression side = +1 AND max up-tick run >= streak minimum
Short: flow oscillator crosses below -extreme threshold AND dominant aggression side = -1 AND max down-tick run >= streak minimum
Long: dominant aggression side = +1 AND dominant aggression side[1] = -1 AND max up-tick run >= streak minimum AND bars since previous flip marker >= flip cooldown
Short: dominant aggression side = -1 AND dominant aggression side[1] = +1 AND max down-tick run >= streak minimum AND bars since previous flip marker >= flip cooldown
Long: dominant aggression side = +1
Short: dominant aggression side = -1