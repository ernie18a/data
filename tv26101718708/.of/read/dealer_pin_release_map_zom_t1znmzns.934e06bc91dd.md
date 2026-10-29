Calculation: Magnet = nearest strike-step multiple to close
Calculation: Magnet range = max(ATR × magnet-width, minimum tick)
Calculation: Pin edges = previous bar’s magnet ± current magnet range
Calculation: Relative volume = volume / moving average of volume
Calculation: ATR ratio = ATR / long-lookback EMA of ATR
Calculation: Candle body share = abs(close − open) / max(high − low, minimum tick)
Calculation: Upper wick = high − max(open, close); lower wick = min(open, close) − low
Calculation: Delta pressure = EMA((((close − low) − (high − close)) / max(high − low, minimum tick)) × volume / max(moving average of volume, 1) × 100, smoothing lookback)
Calculation: Pin score = clamp(clamp(1 − abs(close − Magnet) / magnet range, 0, 1) × 58 + clamp((1.20 − ATR ratio) / 0.55, 0, 1) × 26 + clamp(1.25 − relative volume, 0, 1) × 16, 0, 100)
Calculation: Prior pin score = highest pin score over the release lookback, excluding the current bar
Calculation: Release energy = clamp((prior pin score − 45) × 0.72 + (ATR ratio − 1) × 38 + (relative volume − 1) × 16 + abs(delta pressure) × 0.20 + clamp(abs(close − previous bar’s magnet) / magnet range, 0, 2.2) × 16, 0, 100)
Long: No signal within cooldown bars AND prior pin score ≥ fade threshold AND close > upper pin edge AND previous close ≤ upper pin edge AND ATR ratio > expansion threshold AND relative volume > expansion threshold AND candle body share > expansion threshold AND release energy ≥ release threshold AND delta pressure > 0
Long: No signal within cooldown bars AND low ≤ Magnet − 0.72 × magnet range AND close > Magnet − 0.38 × magnet range AND lower wick > 1.25 × upper wick AND delta pressure > previous bar’s delta pressure AND highest pin score over the last 4 bars ≥ fade threshold
Short: No signal within cooldown bars AND prior pin score ≥ fade threshold AND close < lower pin edge AND previous close ≥ lower pin edge AND ATR ratio > expansion threshold AND relative volume > expansion threshold AND candle body share > expansion threshold AND release energy ≥ release threshold AND delta pressure < 0
Short: No signal within cooldown bars AND high ≥ Magnet + 0.72 × magnet range AND close < Magnet + 0.38 × magnet range AND upper wick > 1.25 × lower wick AND delta pressure < previous bar’s delta pressure AND highest pin score over the last 4 bars ≥ fade threshold