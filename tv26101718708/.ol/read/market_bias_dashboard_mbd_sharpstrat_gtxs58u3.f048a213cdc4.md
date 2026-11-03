Calculation: Swing structure = bullish when the latest two confirmed pivot highs and latest two confirmed pivot lows are both rising; bearish when both are falling; otherwise neutral. Confirm each pivot using the same configurable number of chart bars on each side.
Calculation: Range position = (close − lowest low over the lookback) / (highest high − lowest low) × 100.
Calculation: Smoothed swing size = EMA of abs(close − close[lookback]); compare it with the same EMA shifted back by that lookback. Accelerating = current > earlier × 1.05; fading = current < earlier × 0.95.
Calculation: ATR ratio = ATR over the short lookback / SMA of that ATR over a longer lookback. Expanding = ratio ≥ 1.1; coiling = ratio ≤ the configurable threshold.
Calculation: Bias score = +1 for bullish structure, +1 if range position > 55, +1 if momentum is accelerating, +1 if volatility is expanding; −1 for bearish structure, −1 if range position < 45, and −1 if momentum is fading. All other components contribute 0.
Long: Swing structure is bullish
Long: Range position ≥ 60
Long: Momentum is accelerating
Long: Volatility is expanding
Long: Bias score > 0, and volatility is not coiling, and structure did not flip from bullish to bearish or bearish to bullish on this bar
Long: On the higher timeframe, bias score > 0 and volatility is not coiling. Use the higher-timeframe bar as available, including while it is still forming.
Short: Swing structure is bearish
Short: Range position ≤ 40
Short: Momentum is fading
Short: Bias score < 0, and volatility is not coiling, and structure did not flip from bullish to bearish or bearish to bullish on this bar
Short: On the higher timeframe, bias score < 0 and volatility is not coiling. Use the higher-timeframe bar as available, including while it is still forming.