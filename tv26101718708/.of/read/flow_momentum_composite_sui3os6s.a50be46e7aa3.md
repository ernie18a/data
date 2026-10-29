Calculation: Momentum Core = smooth the 0–100-clamped value of 50 + (source − source from its lookback bars ago) / ATR over that lookback × sensitivity; use the selected moving-average method.
Calculation: Balance Line = Momentum Core calculation with its own lookback and slower smoothing than the Momentum Core.
Calculation: Flow Pressure = smooth 50 + 50 × summed directional pressure / summed weights over its lookback; use signed volume (volume for up candles, negative volume for down candles, zero for dojis) when volume varies and volume mode is enabled, otherwise use (close − open) / (high − low) with weight 1 per bar. Use volume as the weight in volume mode.
Calculation: Structure Trend = persistent bullish state, initially bullish; turn bearish when close falls below EMA(close) − ATR × band multiplier, and turn bullish when close rises above EMA(close) + ATR × band multiplier.
Calculation: K-nearest-neighbor vote = compare current (Momentum Core / 100, Flow Pressure / 100, and Structure Trend encoded as 1 bullish or 0 bearish) with prior observations using Euclidean distance; take the K nearest labels (1 if that observation’s close exceeded its prior close, otherwise 0), weighted by 1 / (distance + 0.05), and express the weighted vote as a percentage. Use the most recent observations up to the memory limit; when the neighbors’ mean distance exceeds the confidence limit, set the vote to 50%.
Calculation: Tension = Momentum Core − Balance Line.
Calculation: Composite score = percentage of total component weights earned by the five components that agree with the candle direction: Core above 50 and rising for an up candle, below 50 and falling for a down candle; Flow above/below 50; bullish/bearish Structure Trend; KNN vote above 60% / below 40%; and Tension positive and increasing / negative and decreasing on two consecutive bars.
Long: close > open AND Composite score ≥ signal threshold AND no prior long score signal since Momentum Core last crossed 50
Long: Momentum Core crosses above the oversold level
Long: A confirmed Momentum Core pivot low is higher than its previous pivot low AND the corresponding price low is lower than its previous pivot low
Long: Momentum Core ≥ Balance Line
Long: Momentum Core ≥ 50
Long: Flow Pressure ≥ 50
Long: Structure Trend is bullish
Long: KNN vote ≥ 60%
Short: close < open AND Composite score ≥ signal threshold AND no prior short score signal since Momentum Core last crossed 50
Short: Momentum Core crosses below the overbought level
Short: A confirmed Momentum Core pivot high is lower than its previous pivot high AND the corresponding price high is higher than its previous pivot high
Short: Momentum Core < Balance Line
Short: Momentum Core < 50
Short: Flow Pressure < 50
Short: Structure Trend is bearish
Short: KNN vote ≤ 40%