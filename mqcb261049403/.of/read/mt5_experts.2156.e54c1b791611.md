Calculation: Fast and slow rates = for each bar, (current smoothed price - previous smoothed price) / previous smoothed price, or 0 if the previous smoothed price is 0. Smooth the same selected OHLC-derived price with the same selected moving-average method and shorter and longer lookbacks, respectively. The default method is T3 with effective length 1 + (lookback - 1) / 2. Calculate on the selected indicator timeframe, which may be the chart timeframe or higher or lower; use the last completed indicator bar by default, or the forming bar if selected. Earlier values refer to preceding indicator bars.
Long: Fast rate > 0 AND previous fast rate <= 0
Long: Fast rate > previous fast rate AND previous fast rate < fast rate two bars ago
Long: Fast rate > slow rate AND previous fast rate <= previous slow rate
Short: Fast rate < 0 AND previous fast rate >= 0
Short: Fast rate < previous fast rate AND previous fast rate > fast rate two bars ago
Short: Fast rate < slow rate AND previous fast rate >= previous slow rate
Exit: long, fast rate < 0
Exit: long, fast rate < previous fast rate
Exit: long, fast rate < slow rate
Exit: short, fast rate > 0
Exit: short, fast rate > previous fast rate
Exit: short, fast rate > slow rate
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance