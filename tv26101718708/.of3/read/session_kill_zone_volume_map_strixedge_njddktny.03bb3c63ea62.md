Calculation: For each configured UTC session, opening-range high = maximum(high) from its first chart bar through the first chart bar whose time is at least the configured opening-range duration after that first bar
Calculation: For each configured UTC session, opening-range low = minimum(low) from its first chart bar through the first chart bar whose time is at least the configured opening-range duration after that first bar
Calculation: For each configured UTC session, previous session high = maximum(high) during its most recently completed occurrence
Calculation: For each configured UTC session, previous session low = minimum(low) during its most recently completed occurrence
Long: During an enabled configured UTC session, after its opening range completes, close > its opening-range high, no earlier bar in that session closed above that high, and volume > SMA(volume, lookback) × multiplier
Short: During an enabled configured UTC session, after its opening range completes, close < its opening-range low, no earlier bar in that session closed below that low, and volume > SMA(volume, lookback) × multiplier
Long: Close crosses above the previous session high of any configured UTC session and volume > SMA(volume, lookback) × multiplier
Short: Close crosses below the previous session low of any configured UTC session and volume > SMA(volume, lookback) × multiplier