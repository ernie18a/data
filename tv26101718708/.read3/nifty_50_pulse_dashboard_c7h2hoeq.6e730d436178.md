Calculation: Buy turnover percentage = 100 × Σ(volume(T1, current still-forming bar) × close(T1, current still-forming bar) × (high(T1, current still-forming bar) > low(T1, current still-forming bar) ? (close(T1, current still-forming bar) − low(T1, current still-forming bar)) / (high(T1, current still-forming bar) − low(T1, current still-forming bar)) : 0.5)) / Σ(volume(T1, current still-forming bar) × close(T1, current still-forming bar)) across constituent stocks, evaluated on chart bars from current T1 values when the denominator is positive
Long: Buy turnover percentage >= bullish threshold
Short: Buy turnover percentage <= bearish threshold
Calculation: Basket buy percentage = 100 × Σ(volume × close × close-location fraction) / Σ(volume × close) across stocks with available data on T1; close-location fraction = (close − low) / (high − low) when high > low, otherwise 0.5
Long: Basket buy percentage ≥ bullish threshold
Short: Basket buy percentage ≤ bearish threshold