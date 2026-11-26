Calculation: Pressure = (selected price field - MA(selected price field, MA lookback, MA type)) / max(Highest(abs(selected price field - MA(selected price field, MA lookback, MA type)), normalization lookback), tick-size floor) * 100%
Calculation: Pressure slope = EMA(Pressure, signal-smoothing lookback) - EMA(Pressure, signal-smoothing lookback)[1]
Calculation: Pressure spread = Pressure - EMA(Pressure, signal-smoothing lookback)
Calculation: Pressure stability = score ceiling - min(score ceiling, abs(Pressure spread) + abs(Pressure slope) * stability slope weight)
Calculation: Squeeze score = max(0, score ceiling - min(score ceiling, Highest(EMA(Pressure, signal-smoothing lookback), normalization lookback) - Lowest(EMA(Pressure, signal-smoothing lookback), normalization lookback) + abs(Pressure spread) * squeeze spread weight))
Calculation: Pressure state = on confirmed bars, choose the first matching candidate in this order: signal >= extreme level gives 3; signal <= -extreme level gives -3; slope > 0 AND signal > warning level gives 2; slope < 0 AND signal < -warning level gives -2; abs(slope) < compression slope threshold AND abs(signal) < warning level * compression warning fraction gives 0; signal > 0 gives 1; signal < 0 gives -1; otherwise 0. Reset pending-since to the current bar whenever the candidate differs from the active state; accept a differing candidate when elapsed bars since pending-since meet the state-hold parameter, and set the active state directly to the candidate whenever it is 0.
Long: confirmed crossover(EMA(Pressure, signal-smoothing lookback), 0)
Short: confirmed crossunder(EMA(Pressure, signal-smoothing lookback), 0)
Long: confirmed EMA(Pressure, signal-smoothing lookback) > warning level AND Pressure > EMA(Pressure, signal-smoothing lookback)
Short: confirmed EMA(Pressure, signal-smoothing lookback) < -warning level AND Pressure < EMA(Pressure, signal-smoothing lookback)
Long: confirmed Pressure state > Pressure state[1]
Short: confirmed Pressure state < Pressure state[1]
Long: Pressure state > 0
Short: Pressure state < 0
Long: Pressure state > 0 AND EMA(Pressure, signal-smoothing lookback) >= SMA(EMA(Pressure, signal-smoothing lookback), max(minimum median lookback, median lookback multiplier * signal-smoothing lookback))
Short: Pressure state < 0 AND EMA(Pressure, signal-smoothing lookback) <= SMA(EMA(Pressure, signal-smoothing lookback), max(minimum median lookback, median lookback multiplier * signal-smoothing lookback))
Long: Pressure stability > stability color threshold
Short: Pressure stability <= stability color threshold
Long: Squeeze score > squeeze color threshold
Short: Squeeze score <= squeeze color threshold
Exit: long, confirmed Pressure[1] >= extreme level AND Pressure < extreme level
Exit: short, confirmed Pressure[1] <= -extreme level AND Pressure > -extreme level
Exit: long, confirmed Pressure state = 3 AND EMA(Pressure, signal-smoothing lookback) < warning level
Exit: short, confirmed Pressure state = -3 AND EMA(Pressure, signal-smoothing lookback) > -warning level