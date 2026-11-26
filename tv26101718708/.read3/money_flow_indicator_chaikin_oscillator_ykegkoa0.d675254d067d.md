Calculation: Body flow(lookback) = SUM(IF((high - low) * volume > 0, (close - open) / (high - low) * volume, 0), lookback)
Calculation: Oscillator = EMA(Body flow(longer of the two lookback parameters), longer of the two lookback parameters) - EMA(Body flow(shorter of the two lookback parameters), shorter of the two lookback parameters)
Calculation: Direction state = IF(Oscillator > 0, 1, IF(Oscillator < 0, -1, previous direction state or 0))
Calculation: Trade direction = IF(the reversal parameter is enabled, -Direction state, Direction state)
Long: Trade direction = 1
Short: Trade direction = -1