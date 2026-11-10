Calculation: A, B, C, D = four independently configured timeframes in descending order of duration. Each may be higher than, equal to, or lower than the chart timeframe. For a higher timeframe, use the last completed bar on historical chart bars and the bar still forming on realtime chart bars. For a lower timeframe, use the last available intrabar within each chart bar.
Calculation: A high and A low = highest high and lowest low over a lookback of A bars including the current A bar.
Calculation: B high and B low = highest high and lowest low over a lookback of B bars including the current B bar.
Calculation: Previous B high and previous B low = highest high and lowest low over a separate lookback of B bars ending before the current B bar.
Calculation: Previous C sweep high and previous C sweep low = highest high and lowest low over a sweep lookback of C bars ending before the current C bar.
Calculation: Previous C structure high and previous C structure low = highest high and lowest low over a separate structure lookback of C bars ending before the current C bar.
Calculation: C range = C high - C low.
Long: A short-period EMA > A long-period EMA.
Long: A close > A long-period EMA.
Long: (A high - A close) / A close >= minimum room fraction.
Long: B close <= B low + (B high - B low) * zone fraction.
Long: B close < (B high + B low) / 2.
Long: Current B bar low <= previous B low OR absolute value of (B close - previous B low) / B close <= liquidity proximity fraction.
Long: C low < previous C sweep low AND C close > previous C sweep low.
Long: C range > 0 AND (min(C open, C close) - C low) / C range >= minimum wick fraction AND C close > C low + C range / 2.
Long: C close > previous C structure high.
Long: C close > C open AND absolute value of (C close - C open) > C ATR * displacement multiplier.
Long: D low > D high two bars earlier occurred within the configured number of D bars, including the current D bar.
Long: D close > previous D bar high AND D close > D open.
Short: A short-period EMA < A long-period EMA.
Short: A close < A long-period EMA.
Short: (A close - A low) / A close >= minimum room fraction.
Short: B close >= B high - (B high - B low) * zone fraction.
Short: B close > (B high + B low) / 2.
Short: Current B bar high >= previous B high OR absolute value of (B close - previous B high) / B close <= liquidity proximity fraction.
Short: C high > previous C sweep high AND C close < previous C sweep high.
Short: C range > 0 AND (C high - max(C open, C close)) / C range >= minimum wick fraction AND C close < C high - C range / 2.
Short: C close < previous C structure low.
Short: C close < C open AND absolute value of (C close - C open) > C ATR * displacement multiplier.
Short: D high < D low two bars earlier occurred within the configured number of D bars, including the current D bar.
Short: D close < previous D bar low AND D close < D open.