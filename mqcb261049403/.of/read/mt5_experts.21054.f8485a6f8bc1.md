Calculation: Derivative = Jurik moving average of 100 × (weighted close − weighted close a configurable number of bars earlier) / that number of bars; weighted close = (high + low + 2 × close) / 4. For the trading decisions, calculate it on a higher timeframe using the last completed bar and earlier completed bars.
Calculation: State = A when derivative > 0 AND derivative >= previous derivative; B when derivative > 0 AND derivative < previous derivative; C when derivative < 0 AND derivative > previous derivative; D when derivative < 0 AND derivative <= previous derivative; Z when derivative = 0.
Long: (state = A AND previous state != A) OR (state = C AND (previous state = D OR previous state = Z))
Short: (state = D AND previous state != D) OR (state = B AND (previous state = A OR previous state = Z))
Exit: long, state = B OR state = D
Exit: short, state = A OR state = C
Exit: long, low <= entry price − stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price − take-profit distance