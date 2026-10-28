Calculation: Kernel regression = weighted average of the current and prior closes over a lookback; each close i bars back has weight exp(-i² / (2 × (lookback / 2)²).
Long: EMA of close crosses above kernel regression (current EMA > current regression AND previous EMA ≤ previous regression)
Short: EMA of close crosses below kernel regression (current EMA < current regression AND previous EMA ≥ previous regression)
Long: Close < close four bars earlier for exactly 9 consecutive bars
Short: Close > close four bars earlier for exactly 9 consecutive bars
Long: Heikin-Ashi close crosses above the higher of the EMA of close and kernel regression (previous Heikin-Ashi close ≤ previous higher value AND current Heikin-Ashi close > current higher value) AND Heikin-Ashi close > Heikin-Ashi open