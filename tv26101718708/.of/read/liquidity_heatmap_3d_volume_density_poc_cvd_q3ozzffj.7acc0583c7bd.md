Calculation: Bar buy fraction = clamp((close - low) / max(high - low, minimum price increment), 0, 1)
Calculation: Cumulative volume delta = sum over the rolling heatmap window of volume × (2 × bar buy fraction − 1)
Long: volume / average volume over preceding bars ≥ bubble threshold AND bar buy fraction ≥ 0.5
Long: cumulative volume delta ≥ 0 AND price is not within the wall-proximity threshold of the strongest active liquidity wall
Short: volume / average volume over preceding bars ≥ bubble threshold AND bar buy fraction < 0.5
Short: cumulative volume delta < 0 AND price is not within the wall-proximity threshold of the strongest active liquidity wall