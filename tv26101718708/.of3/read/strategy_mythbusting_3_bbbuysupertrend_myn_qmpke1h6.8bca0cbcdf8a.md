Calculation: selected basis = EMA(selected source, basis lookback) when EMA mode is selected, otherwise SMA(selected source, basis lookback)
Calculation: long crossover signal = no long crossover signal since the latest short crossover signal or start AND crossover(EMA(selected source, fast EMA lookback), selected basis) AND close > selected basis AND Awesome Oscillator(hl2, shorter AO lookback, longer AO lookback) > Awesome Oscillator(hl2, shorter AO lookback, longer AO lookback)[1]
Calculation: short crossover signal = no short crossover signal since the latest long crossover signal or start AND crossunder(EMA(selected source, fast EMA lookback), selected basis) AND close < selected basis AND Awesome Oscillator(hl2, shorter AO lookback, longer AO lookback) <= Awesome Oscillator(hl2, shorter AO lookback, longer AO lookback)[1]
Long: long crossover signal
Short: short crossover signal
Long: EMA(selected source, fast EMA lookback) > selected basis
Short: EMA(selected source, fast EMA lookback) < selected basis
Long: Supertrend(factor, ATR lookback) direction < 0
Short: Supertrend(factor, ATR lookback) direction > 0
Long: long crossover signal AND Supertrend(factor, ATR lookback) direction < 0 AND (ADX filter disabled OR ADX(DI lookback, smoothing lookback) > ADX threshold) AND trade direction permits long AND position side is not long
Short: short crossover signal AND Supertrend(factor, ATR lookback) direction > 0 AND (ADX filter disabled OR ADX(DI lookback, smoothing lookback) > ADX threshold) AND trade direction permits short AND position side is not short
Exit: Long, high >= entry price * (1 + take-profit target 1 percent / 100) OR high >= entry price * (1 + take-profit target 2 percent / 100) OR high >= entry price * (1 + take-profit target 3 percent / 100) OR high >= entry price * (1 + take-profit target 4 percent / 100) OR close < entry price * (1 - stop-loss percent / 100)
Exit: Short, low <= entry price * (1 - take-profit target 1 percent / 100) OR low <= entry price * (1 - take-profit target 2 percent / 100) OR low <= entry price * (1 - take-profit target 3 percent / 100) OR low <= entry price * (1 - take-profit target 4 percent / 100) OR close > entry price * (1 + stop-loss percent / 100)