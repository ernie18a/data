Calculation: Upper and lower extension levels = current-bar EMA of close × (1 ± extension distance percentage / 100), respectively.
Calculation: Average volume = simple average of the volume of the previous N completed bars, excluding the current bar.
Calculation: Candle range = high − low; upper wick = high − max(open, close); lower wick = min(open, close) − low.
Calculation: Upper and lower wick percentages = respective wick ÷ candle range × 100 (0 if range is 0).
Calculation: Close position = (close − low) ÷ candle range × 100 (50 if range is 0).
Long: At candle close, low ≤ lower extension level AND average volume > 0 AND volume ≥ average volume × volume multiplier AND lower wick percentage ≥ minimum rejection wick percentage AND close position ≥ minimum close recovery percentage AND (wick dominance filter disabled OR lower wick > upper wick).
Short: At candle close, high ≥ upper extension level AND average volume > 0 AND volume ≥ average volume × volume multiplier AND upper wick percentage ≥ minimum rejection wick percentage AND close position ≤ 100 − minimum close recovery percentage AND (wick dominance filter disabled OR upper wick > lower wick).