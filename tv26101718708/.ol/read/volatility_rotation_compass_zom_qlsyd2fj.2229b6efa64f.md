Calculation: Choppiness Index = 100 × log10(sum of 1-bar ATR over lookback ÷ (highest high − lowest low over the same lookback)) ÷ log10(lookback); 0 when the range is zero
Calculation: Volume z-score = (current volume − volume SMA over lookback) ÷ population standard deviation of volume over the same lookback; 0 when standard deviation is zero
Calculation: Vortex spread = sum of abs(high − prior bar low) over lookback ÷ sum of 1-bar ATR over the same lookback − sum of abs(low − prior bar high) over lookback ÷ sum of 1-bar ATR over the same lookback
Calculation: Compass = EMA of clamp(Vortex spread × 100 × (100 − Choppiness Index) ÷ 50 × clamp(1 + 0.2 × volume z-score, 0.5, 2), −100, 100)
Long: Compass > 18 AND prior bar Compass ≤ 18 AND Choppiness Index < prior bar Choppiness Index AND volume z-score > 0
Short: Compass < −18 AND prior bar Compass ≥ −18 AND Choppiness Index < prior bar Choppiness Index AND volume z-score > 0