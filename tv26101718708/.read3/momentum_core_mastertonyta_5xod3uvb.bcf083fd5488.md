Calculation: Z-score(x, lookback) = (x - SMA(x, lookback)) / population standard deviation(x, lookback), or 0 when the standard deviation is 0
Calculation: Squash(x) = scale parameter × (2 / (1 + exp(-x × steepness parameter)) - 1)
Calculation: Momentum = Squash(weighted mean of Z-score(TSI(close, short lookback, long lookback), z-score lookback), Z-score((close - close[ROC lookback]) / ATR(ATR lookback), z-score lookback), Z-score(change(RSI(close, RSI lookback), velocity lookback), z-score lookback), Z-score(change(OBV, OBV lookback) / (SMA(volume, volume-average lookback) × OBV lookback), z-score lookback), and Z-score(MACD histogram(close, fast lookback, slow lookback, signal lookback), z-score lookback), using a separate weight for each component; use 0 when the weights sum to 0)
Calculation: Wave = Squash(Z-score(MACD histogram(close, fast lookback, slow lookback, signal lookback), the same z-score lookback used for Momentum))
Calculation: Acceleration = EMA(change(Momentum, one chart bar), acceleration lookback)
Calculation: Regime gate passes when disabled, or when ADX(DI lookback, smoothing lookback) >= ADX threshold and volume / SMA(volume, the same volume-average lookback used for OBV normalization) >= relative-volume threshold
Calculation: Momentum direction starts bullish, becomes bullish when Acceleration > deadzone, becomes bearish when Acceleration < -deadzone, and otherwise retains its previous direction
Calculation: Confirmed regime starts neutral, becomes bullish after Momentum direction is bullish and the regime gate passes for the confirmation lookback consecutively, becomes bearish after Momentum direction is bearish and the regime gate passes for the confirmation lookback consecutively, and otherwise retains its previous state
Long: Regime gate passes AND Momentum direction is bullish
Short: Regime gate passes AND Momentum direction is bearish
Long: Background display is enabled AND Confirmed regime is bullish
Short: Background display is enabled AND Confirmed regime is bearish
Long: Momentum crosses above 0 AND the regime gate passes
Short: Momentum crosses below 0 AND the regime gate passes
Long: Divergence is enabled AND a confirmed PivotLow(Momentum, left lookback, right lookback) occurs AND the current momentum pivot low > the preceding momentum pivot low AND the price low at the current pivot < the price low at the preceding pivot
Short: Divergence is enabled AND a confirmed PivotHigh(Momentum, left lookback, right lookback) occurs AND the current momentum pivot high < the preceding momentum pivot high AND the price high at the current pivot > the price high at the preceding pivot
Long: Wave display is enabled AND Wave >= 0
Short: Wave display is enabled AND Wave < 0
Long: Wave crosses above 0
Short: Wave crosses below 0
Long: Wave < 0 AND Wave > Wave[1] AND Wave[1] <= Wave[2]
Short: Wave > 0 AND Wave <= Wave[1] AND Wave[1] > Wave[2]
Exit: long, Momentum > upper exhaustion threshold AND Acceleration < 0
Exit: short, Momentum < lower exhaustion threshold AND Acceleration > 0