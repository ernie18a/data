Calculation: VWAP = session volume-weighted average of (high + low + close) / 3, including the current bar
Calculation: Pullback cycle = activate when close > VWAP, ((abs(low - VWAP) / VWAP) × 100 ≤ tolerance OR (low ≤ VWAP AND close ≥ VWAP)), and ((close - VWAP) / VWAP × 100 ≤ maximum extension); remain active until close > VWAP by more than the maximum extension or close < VWAP; allow only one long signal per cycle
Calculation: Bullish engulfing = close > open AND previous close < previous open AND close ≥ previous open AND open ≤ previous close
Calculation: Wick rejection = high > low AND (min(open, close) - low) / (high - low) ≥ 0.5 AND low ≤ VWAP × (1 + tolerance / 100) AND close > open
Calculation: Higher low = low > the lowest low of the preceding lookback bars AND close > open
Long: Pullback cycle active AND close > VWAP AND ((close - VWAP) / VWAP × 100 ≤ maximum extension) AND (close > open OR bullish engulfing OR wick rejection OR higher low) AND no earlier long signal in the current cycle
Calculation: Stop loss = min(lowest low over the lookback ending on the current bar, current VWAP) × (1 - stop buffer / 100)
Calculation: Third target = entry price + (entry price - stop loss) × third risk/reward multiple
Exit: Long, low ≤ stop loss OR high ≥ third target