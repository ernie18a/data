Calculation: Fast momentum change = current close minus close at a shorter lookback; slow momentum change = current close minus close at a longer lookback.
Calculation: CHO score = ((fast momentum change − slow momentum change) / (fast momentum change + slow momentum change) × 100 + 100) / 2; use 0 for the ratio when slow momentum change equals negative fast momentum change.
Calculation: Momentum score = 100 × (current momentum − lowest momentum over a rolling lookback) / (highest momentum over that lookback − lowest momentum over that lookback); use 50 when the highest and lowest are equal. Momentum is close minus close at a lookback.
Calculation: Composite score = 0.6 × CHO score + 0.4 × Momentum score.
Calculation: Range market = ((rolling highest high − rolling lowest low) / ATR < 3 AND composite score > 30 AND composite score < 70) OR ((rolling highest high − rolling lowest low) / ATR < 2.5 AND composite score > 35 AND composite score < 65) OR ((high − low) / average high-low range < 0.8 AND composite score > 40 AND composite score < 60).
Calculation: Bullish engulfing = close > open AND close > previous open AND open < previous close.
Calculation: Bearish engulfing = close < open AND close < previous open AND open > previous close.
Calculation: Hammer = lower wick > 2 × body AND upper wick < 0.3 × body AND total range > 0.
Calculation: Shooting star = upper wick > 2 × body AND lower wick < 0.3 × body AND total range > 0.
Calculation: Morning star = candle two bars ago is bearish AND previous body ≤ 0.1 × previous range AND current candle is bullish AND close > midpoint of candle two bars ago.
Calculation: Evening star = candle two bars ago is bullish AND previous body ≤ 0.1 × previous range AND current candle is bearish AND close < midpoint of candle two bars ago.
Calculation: Large bullish body = close > open AND body > ATR × 0.8.
Calculation: Large bearish body = close < open AND body > ATR × 0.8.
Calculation: Liquidity high = rolling highest high; liquidity low = rolling lowest low. For sweep checks, use the levels from the previous bar.
Long: composite score ≥ 70 OR composite score ≥ 55 AND composite score < 70 OR composite score > previous composite score OR low < previous liquidity low AND close > previous liquidity low OR bullish engulfing OR hammer OR morning star OR large bullish body.
Short: composite score < 40 OR (composite score ≥ 30 AND composite score < 45) OR composite score < previous composite score OR high > previous liquidity high AND close < previous liquidity high OR bearish engulfing OR shooting star OR evening star OR large bearish body.
Exit: 