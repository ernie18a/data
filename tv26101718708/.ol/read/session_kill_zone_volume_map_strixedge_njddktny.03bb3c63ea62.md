Calculation: Opening-range high/low = highest high / lowest low during the configured opening period from each configured session’s start.
Calculation: Previous session high/low = highest high / lowest low of the prior completed London, New York, or Asia session.
Long: In a configured session, opening range is complete, this is the first bar since completion whose close > that session’s opening-range high, and volume > chart-timeframe volume SMA × configured multiplier
Long: Close crosses above any prior completed London, New York, or Asia session high and volume > chart-timeframe volume SMA × configured multiplier
Short: In a configured session, opening range is complete, this is the first bar since completion whose close < that session’s opening-range low, and volume > chart-timeframe volume SMA × configured multiplier
Short: Close crosses below any prior completed London, New York, or Asia session low and volume > chart-timeframe volume SMA × configured multiplier