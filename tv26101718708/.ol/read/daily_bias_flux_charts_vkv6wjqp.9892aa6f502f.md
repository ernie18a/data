Calculation: Tracked liquidity levels = highs and lows of the last completed 1-hour, 4-hour, and daily bars (higher timeframes), plus the highs and lows of the last completed Asia, London, and New York sessions.
Calculation: High-side sweep = current bar high > a tracked high AND previous bar high <= that level; low-side sweep = current bar low < a tracked low AND previous bar low >= that level.
Calculation: High-side reversal = current bar high > a tracked high AND current bar close < that level; low-side reversal = current bar low < a tracked low AND current bar close > that level.
Calculation: Session profile = complex if the completed session swept both sides; bullish reversal if it swept only lows and closed above the lowest swept low; bearish reversal if it swept only highs and closed below the highest swept high; otherwise manipulation if it swept one side, or consolidation if it swept neither.
Calculation: Structure confirmation = current chart close > the high of the last completed 5-minute or 15-minute bar (lower timeframes), or current chart close < the low of the last completed 5-minute or 15-minute bar (lower timeframes).
Calculation: Current remembered event = the latest sweep or reversal among tracked levels, retaining the latest event per level source until that source's level refreshes or a newer event for that source occurs.
Long: low-side sweep of any tracked liquidity level.
Short: high-side sweep of any tracked liquidity level.
Long: current session is active AND previous session profile is consolidation AND current remembered event is a low-side reversal AND structure confirmation is bullish.
Short: current session is active AND previous session profile is consolidation AND current remembered event is a high-side reversal AND structure confirmation is bearish.
Long: current session is active AND previous session profile is manipulation from a low-side sweep AND current remembered event is a low-side reversal AND structure confirmation is bullish.
Short: current session is active AND previous session profile is manipulation from a high-side sweep AND current remembered event is a high-side reversal AND structure confirmation is bearish.
Long: current session is active AND previous session profile is a bullish reversal AND structure confirmation is bullish.
Short: current session is active AND previous session profile is a bearish reversal AND structure confirmation is bearish.