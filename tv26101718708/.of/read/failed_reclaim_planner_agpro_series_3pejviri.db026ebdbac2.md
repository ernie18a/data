Calculation: Confirmed swing high/low = a high/low that is the highest/lowest across the configured left and right chart bars, known after the right bars complete
Calculation: Close location = (close - low) / max(high - low, minimum price increment)
Calculation: Upper/lower wick share = upper/lower wick length divided by max(high - low, minimum price increment)
Calculation: Shelf break buffer = ATR × sensitivity-dependent multiplier
Calculation: Shelf half-width = max(ATR × configured shelf-buffer multiple, minimum price increment)
Calculation: Reclaim failure pad = ATR × confirmation-mode-dependent multiplier
Calculation: Volume score = clamp(45 + (volume / max(SMA(volume, configured lookback), 1) - 1) × 42, 0, 100)
Calculation: Failure score = clamp(0.18 × retest-depth score + 0.28 × close-rejection score + 0.20 × wick score + 0.14 × volume score + 0.10 × room score + 0.10 × follow-through score, 0, 100)
Long: close > latest confirmed swing high + shelf break buffer AND close location ≥ 0.52 AND no active bullish shelf OR an active bullish shelf is retested within its configured window (low ≤ shelf level + shelf half-width) AND close > shelf level + reclaim failure pad AND close location ≥ 0.52 AND lower wick share ≥ sensitivity-dependent minimum AND failure score ≥ configured minimum
Short: close < latest confirmed swing low - shelf break buffer AND close location ≤ 0.48 AND no active bearish shelf OR an active bearish shelf is retested within its configured window (high ≥ shelf level - shelf half-width) AND close < shelf level - reclaim failure pad AND close location ≤ 0.48 AND upper wick share ≥ sensitivity-dependent minimum AND failure score ≥ configured minimum