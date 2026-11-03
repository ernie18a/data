Calculation: Volume ratio = EMA of (short-term SMA of volume / max(long-term SMA of volume, 1)).
Calculation: Entry risk distance = ATR on the entry bar multiplied by the stop-loss multiplier; retain this distance for the position.
Long: Close > highest high over the preceding breakout lookback bars AND ((volume ratio >= normal-volume ceiling AND volume ratio < high-volume threshold) OR volume ratio >= high-volume threshold).
Short: Close < lowest low over the preceding breakout lookback bars AND ((volume ratio >= normal-volume ceiling AND volume ratio < high-volume threshold) OR volume ratio >= high-volume threshold).
Exit: long, low <= entry price - entry risk distance OR high >= entry price + entry risk distance * reward-to-risk ratio, including on the entry bar.
Exit: short, high >= entry price + entry risk distance OR low <= entry price - entry risk distance * reward-to-risk ratio, including on the entry bar.