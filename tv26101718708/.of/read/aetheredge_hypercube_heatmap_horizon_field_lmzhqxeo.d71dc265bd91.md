Calculation: Standardized features = Clip momentum ((close − close at an earlier bar) / ATR), volatility (standard deviation of close changes / ATR), volume surprise ((volume − volume moving average) / volume standard deviation), and trend ((shorter-lookback EMA of close − longer-lookback EMA of close) / ATR) to [−4, 4]. RSI polarity is twice (RSI − its midpoint) / half its range, clipped to [−4, 4].
Calculation: Dynamic attention weights = For each standardized feature, exp(absolute feature / attention temperature), divided by the sum of these values across all five features.
Calculation: Directional bias = attention-weighted sum of standardized momentum, trend, and RSI polarity.
Long: Directional bias > 0
Short: Directional bias < 0