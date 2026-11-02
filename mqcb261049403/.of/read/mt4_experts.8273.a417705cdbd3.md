Calculation: Triple-smoothed close = EMA of the SMMA of the SMMA of close, all using the same lookback.
Calculation: TRIX = (triple-smoothed close - previous triple-smoothed close) / previous triple-smoothed close.
Calculation: Signal = EMA of TRIX, using a lookback different from the triple-smoothed close lookback.
Long: TRIX > signal AND previous TRIX <= previous signal.
Short: TRIX < signal AND previous TRIX >= previous signal.
Exit: long, TRIX < signal AND previous TRIX >= previous signal.
Exit: short, TRIX > signal AND previous TRIX <= previous signal.
Exit: long, low <= entry price - enabled stop-loss distance OR high >= entry price + enabled take-profit distance.
Exit: short, high >= entry price + enabled stop-loss distance OR low <= entry price - enabled take-profit distance.