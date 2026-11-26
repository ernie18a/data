Calculation: Ratio(lookback, T) = close / SMA(close, lookback, T, last completed bar)
Calculation: Scale(x, deep anchor, expensive anchor) = min(100, max(0, (x - expensive anchor) / (deep anchor - expensive anchor) * 100))
Calculation: Drawdown = 1 - close / Highest(high, all bars so far)
Calculation: CostBasis = average of the non-missing values in {Scale(Ratio(weekly MA lookback, T2), weekly deep anchor, weekly expensive anchor), Scale(Ratio(two-year MA lookback, T1), two-year deep anchor, two-year expensive anchor), Scale(Ratio(daily MA lookback, T1), daily deep anchor, daily expensive anchor)}
Calculation: OverheatCount = count of true in {Ratio(weekly MA lookback, T2) >= weekly overheat multiple, RSI(close, RSI lookback, T2, last completed bar) >= RSI overheat level, Ratio(daily MA lookback, T1) >= daily overheat multiple}
Calculation: Score = sum of weight * component over non-missing components / sum of weights of non-missing components, with components CostBasis (cost-basis weight), Scale(Drawdown, drawdown deep anchor, drawdown expensive anchor) (drawdown weight), and Scale(RSI(close, RSI lookback, T2, last completed bar), RSI deep anchor, RSI expensive anchor) (RSI weight)
Long: Score crosses above accumulation threshold
Long: Score crosses above deep accumulation threshold AND (Drawdown >= generational drawdown gate OR Ratio(weekly MA lookback, T2) <= deep-tier weekly MA multiple gate)
Long: Score crosses above generational threshold AND Drawdown >= generational drawdown gate
Exit: long, Score crosses below trim threshold
Exit: long, Score crosses below euphoria threshold AND OverheatCount >= euphoria sign minimum AND OverheatCount < cycle-top sign minimum
Exit: long, Score crosses below euphoria threshold AND OverheatCount >= cycle-top sign minimum