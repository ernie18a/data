Calculation: Momentum layer = clamp((HMA(MFI of typical price or RSI of close) − 50) × 2 × positive amplification, −100, 100); replace an unavailable HMA with 50 before centering. Use a series of increasing HMA lengths.
Calculation: Current layer = clamp(100 × positive scale × (HMA(VWMA(close)) − HMA(VWMA(close)) two bars ago) / HMA(VWMA(close)) two bars ago, −100, 100), using zero when the earlier HMA is unavailable or zero; alternatively, clamp HMA(signed ADX) to −100 through 100, replacing unavailable values with zero. Signed ADX equals ADX when +DI ≥ −DI and −ADX otherwise. Use a series of increasing HMA lengths.
Calculation: Confluence lookback = the lesser of the slope lookback and the displayed history length. The selected momentum layer is the lower middle layer of its ordered series; the selected current layer is the lower middle layer of its ordered series.
Calculation: Layer-pair average = the average of two adjacent layers of the same series. For past terrain strips, evaluate it at the midpoint bar of the displayed history; for forecast strips, evaluate it on the current bar. For momentum mesh segments, evaluate it at each displayed mesh-sampled bar.
Long: selected momentum layer > its value one confluence lookback ago AND selected current layer > its value one confluence lookback ago
Short: selected momentum layer < its value one confluence lookback ago AND selected current layer < its value one confluence lookback ago
Long: any momentum layer-pair average > 0
Short: any momentum layer-pair average < 0
Long: any current layer-pair average ≥ 0 AND the sum of the absolute values of its two layers > 0
Short: any current layer-pair average < 0
Exit: long, selected momentum layer ≤ its value one confluence lookback ago OR selected current layer ≤ its value one confluence lookback ago
Exit: short, (selected momentum layer ≤ its value one confluence lookback ago OR selected current layer ≤ its value one confluence lookback ago) AND (selected momentum layer ≥ its value one confluence lookback ago OR selected current layer ≥ its value one confluence lookback ago)