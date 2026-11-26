Calculation: Momentum Core = selected MA(clamp(50 + (price source - price source[n]) / ATR(n) × sensitivity, 0, 100), smoothing), with separate lookback and smoothing parameters for Momentum Core and Balance Line and a shared MA method and sensitivity.
Calculation: Flow Pressure = selected MA(50 + 50 × sum(flow contribution, lookback) / sum(flow weight, lookback), smoothing), where flow contribution is signed volume for up/down candles when volume is available, otherwise (close - open) / (high - low); flow weight is volume when available, otherwise 1; volume is available when its standard deviation over a parameterized lookback is positive and candle mode is disabled; use 50 when the weight sum is zero.
Calculation: Structure direction starts bullish, turns bearish when close < EMA(close, lookback) - ATR(lookback) × band multiplier, and turns bullish when close > EMA(close, lookback) + ATR(lookback) × band multiplier; otherwise it retains its prior direction.
Calculation: Tension = Momentum Core - Balance Line.
Calculation: KNN Vote = inverse-distance-weighted percentage of upward next-bar outcomes among the K nearest historical observations, using Euclidean distance over (Momentum Core / 100, Flow Pressure / 100, bullish Structure direction as 1 and bearish as 0), weights 1 / (distance + distance offset), and 50 when average neighbor distance exceeds a distance limit.
Calculation: Bullish score percentage = 100 × (Momentum weight when Momentum Core > 50 and Momentum Core > Momentum Core[1] + Flow weight when Flow Pressure > 50 + Structure weight when Structure direction is bullish + KNN weight when KNN Vote > bullish score cutoff + Tension weight when Tension > 0, Tension[1] > 0, and Tension > Tension[1]) / sum of all five weights; use 0 when the weight sum is zero.
Calculation: Bearish score percentage = 100 × (Momentum weight when Momentum Core < 50 and Momentum Core < Momentum Core[1] + Flow weight when Flow Pressure < 50 + Structure weight when Structure direction is bearish + KNN weight when KNN Vote < bearish score cutoff + Tension weight when Tension < 0, Tension[1] < 0, and Tension < Tension[1]) / sum of all five weights; use 0 when the weight sum is zero.
Long: close > open AND bullish score percentage >= score threshold AND (one-signal-per-wave is disabled OR no earlier long score signal since Momentum Core last crossed 50).
Short: close < open AND bearish score percentage >= score threshold AND (one-signal-per-wave is disabled OR no earlier short score signal since Momentum Core last crossed 50).
Long: Momentum Core crosses above oversold level.
Short: Momentum Core crosses below overbought level.
Long: At a confirmed Momentum Core pivot low, low at the pivot < low at the prior confirmed pivot low AND Momentum Core at the pivot > Momentum Core at the prior confirmed pivot low.
Short: At a confirmed Momentum Core pivot high, high at the pivot > high at the prior confirmed pivot high AND Momentum Core at the pivot < Momentum Core at the prior confirmed pivot high.
Long: KNN Vote >= bullish KNN bias threshold AND prior KNN Bias was not bullish.
Short: KNN Vote <= bearish KNN bias threshold AND prior KNN Bias was not bearish.
Long: close > open AND prior close < prior open.
Short: close < open AND prior close > prior open.
Long: Momentum Core >= Balance Line.
Short: Momentum Core < Balance Line.
Long: Flow Pressure >= 50.
Short: Flow Pressure < 50.
Long: Structure direction is bullish.
Short: Structure direction is bearish.
Long: KNN Vote >= bullish KNN bias threshold.
Short: KNN Vote <= bearish KNN bias threshold.
Long: Tension > 0.
Short: Tension < 0.
Long: Tension > 0 AND Tension[1] > 0 AND Tension > Tension[1].
Short: Tension < 0 AND Tension[1] < 0 AND Tension < Tension[1].
Long: Bullish score percentage >= 51.
Short: Bearish score percentage >= 51.