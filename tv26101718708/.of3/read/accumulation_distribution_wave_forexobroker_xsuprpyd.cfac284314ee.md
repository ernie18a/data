Calculation: A/D Wave = Accumulation/Distribution - EMA(Accumulation/Distribution, wave EMA lookback)
Long: A/D Wave > wave slope threshold AND A/D Wave[1] <= wave slope threshold
Short: A/D Wave < -wave slope threshold AND A/D Wave[1] >= -wave slope threshold
Long: close <= lowest(close, divergence lookback) AND Accumulation/Distribution > highest(Accumulation/Distribution, divergence lookback)
Short: close >= highest(close, divergence lookback) AND Accumulation/Distribution < highest(Accumulation/Distribution, divergence lookback)
Long: close crosses above EMA(close, entry EMA lookback)
Short: close crosses below EMA(close, entry EMA lookback)
Long: A/D Wave > wave slope threshold AND close crosses above EMA(close, entry EMA lookback) AND (divergence-only mode disabled OR (close <= lowest(close, divergence lookback) AND Accumulation/Distribution > highest(Accumulation/Distribution, divergence lookback))) AND (session restriction disabled OR current bar is in the session window) AND current position is not long AND cooldown elapsed since chart start or last signal AND bar is confirmed
Short: A/D Wave < -wave slope threshold AND close crosses below EMA(close, entry EMA lookback) AND (divergence-only mode disabled OR (close >= highest(close, divergence lookback) AND Accumulation/Distribution < highest(Accumulation/Distribution, divergence lookback))) AND (session restriction disabled OR current bar is in the session window) AND current position is not short AND cooldown elapsed since chart start or last signal AND bar is confirmed