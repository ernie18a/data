Calculation: Per configured timeframe, buy share = round(100 × (close − low) / max(high − low, minimum tick)), clipped to 0–100; delta = volume × (2 × (close − low) / max(high − low, minimum tick) − 1); CVD = cumulative sum of delta. Use that timeframe’s requested bars, including its currently forming bar.
Calculation: Bullish timeframe = CVD rising for 3 bars; bearish timeframe = CVD falling for 3 bars.
Calculation: Bull score = count of enabled bullish timeframes; bear score = count of enabled bearish timeframes. Weighted bull and bear scores sum 1, 2, 3, and 4 respectively for each enabled bullish or bearish timeframe in configured slot order.
Calculation: Alignment score = greater of bull score and bear score. Bias threshold = 3 when at least 3 timeframes are enabled, 2 when 2 are enabled, otherwise 1.
Calculation: Average ADX = arithmetic mean of ADX across enabled timeframes. Fresh count = number of enabled timeframes where minutes since the most recent change in its CVD rising/falling state is at most the configured freshness limit. Build count = number of enabled timeframes where the 2-bar direction of the EMA-smoothed CVD is rising.
Long: bull score ≥ bias threshold
Long: bull score < bias threshold AND bear score < bias threshold AND enabled TF1 and TF2 are both bullish AND weighted bull score > weighted bear score
Long: weighted bull score > weighted bear score AND weighted bull score ≥ 6 AND average ADX ≥ 22 AND fresh count ≥ 2
Long: weighted bull score > weighted bear score AND bull score ≥ min(2, enabled timeframe count) AND average ADX ≥ 18 AND build count ≥ min(2, enabled timeframe count)
Long: enabled TF1 and TF2 are both bullish AND weighted bull score > weighted bear score AND average ADX ≥ 18 AND build count ≥ 2
Long: average ADX ≥ 18 AND build count ≥ min(2, enabled timeframe count) AND fresh count ≥ 1 AND alignment score ≥ min(2, enabled timeframe count) AND weighted bull score > weighted bear score
Long: weighted bull score > weighted bear score
Short: bear score ≥ bias threshold
Short: bull score < bias threshold AND bear score < bias threshold AND enabled TF1 and TF2 are both bearish AND weighted bear score > weighted bull score
Short: weighted bear score > weighted bull score AND weighted bear score ≥ 6 AND average ADX ≥ 22 AND fresh count ≥ 2
Short: weighted bear score > weighted bull score AND bear score ≥ min(2, enabled timeframe count) AND average ADX ≥ 18 AND build count ≥ min(2, enabled timeframe count)
Short: enabled TF1 and TF2 are both bearish AND weighted bear score > weighted bull score AND average ADX ≥ 18 AND build count ≥ 2
Short: average ADX ≥ 18 AND build count ≥ min(2, enabled timeframe count) AND fresh count ≥ 1 AND alignment score ≥ min(2, enabled timeframe count) AND weighted bear score > weighted bull score
Short: weighted bear score > weighted bull score
Exit: