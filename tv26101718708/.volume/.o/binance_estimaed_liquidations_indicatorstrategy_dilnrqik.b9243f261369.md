Calculation: Premium = Binance futures volume minus Coinbase spot volume; set to zero when close > open
Calculation: Trigger = if MA mode is enabled, WMA(Premium, short lookback) vs WMA(Premium, longer lookback); else if difference mode is enabled, Premium vs threshold; else, if smooth mode is enabled, SuperSmoother(WMA(Premium, short lookback), 1.5 × short lookback) vs threshold; otherwise WMA(Premium, short lookback) vs threshold
Calculation: SuperSmoother(x, n) = c1 × x + c2 × previous output + c3 × output from two bars earlier, where a = exp(−√2π/n), c2 = 2a cos(√2π/n), c3 = −a², and c1 = 1 − c2 − c3
Long: Trigger crosses above its comparison series AND close > long-term WMA(close) AND the configured date restriction passes
Short: Trigger crosses below its comparison series AND shorts are enabled AND the configured date restriction passes
Exit: long, high >= entry price + configured exit offset OR low <= entry price − configured exit offset
Exit: short, high >= entry price + configured exit offset OR low <= entry price − configured exit offset