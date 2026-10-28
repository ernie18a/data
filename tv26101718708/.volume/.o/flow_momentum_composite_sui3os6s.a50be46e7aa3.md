Calculation: Momentum Core = clamp(50 + (close - close[n]) / ATR(n) × sensitivity, 0, 100), smoothed by a moving average
Calculation: Balance Line = Momentum Core calculated with its own, typically longer, lookback and smoothing
Calculation: Flow Pressure = moving average of the n-bar sum of signed volume (volume signed by candle direction) divided by summed volume, scaled to 0–100; when volume is unavailable or candle mode is forced, use signed candle body/range with unit weights
Calculation: Structure Trend = EMA(close, n) ± ATR(n) × multiplier bands; trend switches bearish when close breaks below the lower band and bullish when close breaks above the upper band, otherwise retains its prior state
Calculation: KNN Vote = distance-weighted percentage of up-close labels among the K nearest past observations in Momentum Core, Flow Pressure, and Structure Trend feature space; labels use the next bar's close direction, observations are limited to a rolling memory, and votes are neutralized when mean neighbor distance exceeds a threshold
Calculation: Bullish Tension = Momentum Core − Balance Line; bearish Tension = Momentum Core − Balance Line
Calculation: Composite Score = percentage of total component weights earned by components agreeing with candle direction: Core above 50 and rising (or below 50 and falling), Flow above 50 (or below 50), bullish (or bearish) Structure Trend, KNN Vote above 60% (or below 40%), and same-side Tension deepening on consecutive bars
Long: close > open AND Composite Score ≥ threshold
Long: Momentum Core crosses above the oversold level
Long: A confirmed price pivot low is lower than the preceding confirmed pivot low AND Momentum Core at the pivot is higher than at the preceding confirmed pivot low
Short: close < open AND Composite Score ≥ threshold
Short: Momentum Core crosses below the overbought level
Short: A confirmed price pivot high is higher than the preceding confirmed pivot high AND Momentum Core at the pivot is lower than at the preceding confirmed pivot high