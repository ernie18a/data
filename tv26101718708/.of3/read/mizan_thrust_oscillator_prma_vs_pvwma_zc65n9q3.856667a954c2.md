Calculation: momentum weight = EMA(RSI(close, RSI lookback), RSI smoothing lookback) * peak scaling parameter / 100
Calculation: adaptive average = recursively update close using alpha = 1 / L, initialized to close, where L = clamp(moving average period / (1 + adaptation sensitivity * abs((momentum weight - center parameter) / center parameter)), minimum adaptive lookback, maximum adaptive lookback)
Calculation: thrust oscillator = adaptive average - sum(close * volume * momentum weight, moving average period) / sum(volume * momentum weight, moving average period); use close for the weighted average when its denominator is zero
Long: thrust oscillator crosses above zero OR (thrust oscillator >= 0 AND thrust oscillator > thrust oscillator[1])
Short: thrust oscillator crosses below zero OR (thrust oscillator < 0 AND thrust oscillator < thrust oscillator[1])
Exit: long, thrust oscillator >= 0 AND thrust oscillator < thrust oscillator[1]
Exit: short, thrust oscillator < 0 AND thrust oscillator > thrust oscillator[1]