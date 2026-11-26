Calculation: smoothed entropy score = WMA((100 − 100H/log₂(5)) × (1 if B ≥ 0, otherwise −1) × volume multiplier, score-smoothing lookback), where H = −Σ(pᵢ log₂ pᵢ), treating 0 log₂ 0 as 0; B = 2p₁ + p₂ − p₄ − 2p₅; and p₁ through p₅ are the proportions over the state-frequency lookback of RSI values, using the RSI lookback, respectively: ≥ upper extreme cutoff; ≥ upper trend cutoff and < upper extreme cutoff; > lower trend cutoff and < upper trend cutoff; > lower extreme cutoff and ≤ lower trend cutoff; ≤ lower extreme cutoff.
Long: no position is open AND smoothed entropy score > neutral threshold
Short: no position is open AND smoothed entropy score < −neutral threshold
Exit: long, smoothed entropy score < neutral threshold − exit buffer
Exit: short, smoothed entropy score > −neutral threshold + exit buffer
Long: position side is long AND smoothed entropy score > extreme threshold
Short: position side is short AND smoothed entropy score < −extreme threshold
Long: smoothed entropy score crosses above extreme threshold
Short: smoothed entropy score crosses below −extreme threshold