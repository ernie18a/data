Calculation: Body-weighted volume = (1 if close > open, otherwise -1) × abs(close - open) ÷ (high - low + range offset) × volume
Long: Body-weighted volume > volume × circle threshold
Short: Body-weighted volume < -volume × circle threshold