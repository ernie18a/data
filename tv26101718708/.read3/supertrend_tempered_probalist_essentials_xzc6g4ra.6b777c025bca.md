Calculation: Multiplier = adaptive mode ? min(upper clamp, max(lower clamp, base multiplier * ATR(shorter lookback) / ATR(longer lookback))) : base multiplier
Calculation: Trend = direction of Supertrend(price source, ATR(shorter lookback), Multiplier), bullish or bearish
Calculation: Strength = abs(close - line of Supertrend(price source, ATR(shorter lookback), Multiplier)) / ATR(shorter lookback)
Calculation: Flip(d, n) = Trend[n] = d AND Trend[n+1] != d
Calculation: Outcome(d) = sign(d) * (close - close[horizon]) / close[horizon] * 100, on bars where Flip(d, horizon), with sign(bullish) = 1 and sign(bearish) = -1
Calculation: RecentBacked(d) = for the last recent-window Outcome(d) values (all, if fewer): count >= recent minimum sample AND WilsonLowerBound(share of values > 0, count, Wilson z) > win-rate threshold AND median of values > 0
Long: Trend = bullish
Short: Trend = bearish
Long: Flip(bullish, 0)
Short: Flip(bearish, 0)
Long: Flip(bullish, confirmation bars)
Short: Flip(bearish, confirmation bars)
Long: Flip(bullish, confirmation bars) AND Strength[confirmation bars] >= strength threshold
Short: Flip(bearish, confirmation bars) AND Strength[confirmation bars] >= strength threshold
Long: Flip(bullish, confirmation bars) AND RecentBacked(bullish)
Short: Flip(bearish, confirmation bars) AND RecentBacked(bearish)
Long: Flip(bullish, confirmation bars) AND Strength[confirmation bars] >= strength threshold AND RecentBacked(bullish)
Short: Flip(bearish, confirmation bars) AND Strength[confirmation bars] >= strength threshold AND RecentBacked(bearish)
Long: Trend[1] on T1 bars = bullish, taken from last completed T1 bar
Short: Trend[1] on T1 bars = bearish, taken from last completed T1 bar