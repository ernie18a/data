Calculation: Market-structure score = +2 when the latest confirmed swing high and low are both higher than their respective previous confirmed swings; −2 when both are lower; otherwise 0. Confirm swing pivots using equal left and right lookbacks.
Calculation: EMA-stack score = +2 when fast EMA > mid EMA > slow EMA and close > fast EMA; +1 when that EMA order holds and close < fast EMA; −2 when fast EMA < mid EMA < slow EMA and close < fast EMA; −1 when that order holds and close > fast EMA; otherwise 0. Use progressively longer EMA lengths.
Calculation: Daily-anchored VWAP score = +2 when close is above VWAP and its percentage change over the lookback exceeds the flat threshold; +1 when close is above VWAP and the change does not exceed the negative flat threshold; −2 when close is below VWAP and the change is below the negative flat threshold; −1 when close is below VWAP and the change does not exceed the positive flat threshold; otherwise 0.
Calculation: Higher-timeframe trend score = +2 when both higher-timeframe closes are above their same-length EMAs; +1 when one is above and the other equals its EMA; −2 when both are below; −1 when one is below and the other equals its EMA; otherwise 0. Use the latest available bars of two higher timeframes, one shorter than the other, with the same EMA length.
Calculation: RSI score = +2 at or above the upper regime threshold; +1 above 50 but below that threshold; −2 at or below the lower regime threshold; −1 below 50 but above that threshold; otherwise 0.
Calculation: Relative-volume score = the sign of the sum of the market-structure, EMA-stack, VWAP, higher-timeframe, and RSI scores, multiplied by +2 when volume / its moving average is at or above the high-volume threshold, −1 when at or below the low-volume threshold, or +0.5 otherwise.
Calculation: Liquidity score = count unmitigated tracked session highs above close minus count unmitigated tracked session lows below close; score +1 when there are no highs above and at least one low below; −1 when there are no lows below and at least one high above; otherwise score +2 for a difference ≥3, +1 for a difference of 1–2, −2 for a difference ≤−3, −1 for a difference of −1 to −2, and 0 for a difference of 0. Track completed Asia, London, and NY session highs/lows and the previous completed daily high/low; clear a level once a bar's high reaches it (high) or low reaches it (low). Use the session bars aggregated from the input data.
Calculation: Composite score = the weighted sum of the seven component scores, divided by twice the sum of their weights, then multiplied by 10.
Long: Market-structure score > 0
Long: EMA-stack score > 0
Long: Daily-anchored VWAP score > 0
Long: Higher-timeframe trend score > 0
Long: RSI score > 0
Long: Relative-volume score > 0
Long: Liquidity score > 0
Long: Composite score > chop threshold
Short: Market-structure score < 0
Short: EMA-stack score < 0
Short: Daily-anchored VWAP score < 0
Short: Higher-timeframe trend score < 0
Short: RSI score < 0
Short: Relative-volume score < 0
Short: Liquidity score < 0
Short: Composite score < −chop threshold