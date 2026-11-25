Calculation: Price Source = EMA(close, smoothing period) when smoothing switch is on, else close
Calculation: Z-score = (Price Source - EMA(Price Source, z period)) / StDev(Price Source, z period), or 0 when StDev(Price Source, z period) is not positive
Calculation: Upward Compression = 1 / (1 + exp(-Z-score))
Calculation: Downward Compression = 1 / (1 + exp(Z-score))
Calculation: Top Multiplier = upper base multiplier * (1 - Upward Compression * upper compression)
Calculation: Bottom Multiplier = lower base multiplier * (1 - Downward Compression * lower compression)
Calculation: T1 Volatility Rank = PercentRank(EMA(StDev(T1 close, volatility period), volatility smoothing period), percentile window), on T1 bars at last completed T1 bar, or neutral value when unavailable
Calculation: Volatility Adjustment = 1 + volatility weight * T1 Volatility Rank / 100
Calculation: Top Width = Top Multiplier * ATR(anchor window) * Volatility Adjustment
Calculation: Bottom Width = Bottom Multiplier * ATR(anchor window) * Volatility Adjustment
Calculation: Raw Top = anchor weight * Highest(Price Source, anchor window) + (1 - anchor weight) * LinReg(Price Source, anchor window, 0) - Top Width
Calculation: Raw Bottom = anchor weight * Lowest(Price Source, anchor window) + (1 - anchor weight) * LinReg(Price Source, anchor window, 0) + Bottom Width
Calculation: Band Top = max(Raw Top, Raw Bottom)
Calculation: Band Bottom = min(Raw Top, Raw Bottom)
Calculation: Band Midline = EMA((Band Top + Band Bottom) / 2, midline period)
Calculation: Execution Bar = bar closed when strict execution switch is on, else true
Calculation: Buy Condition = (execution mode M1 AND barssince(Price Source crosses above Band Midline) <= crossover window AND Price Source > Band Midline AND LinReg(Price Source, anchor window, 0) > LinReg(Price Source, anchor window, 0)[1] AND Execution Bar) OR (execution mode M2 AND Price Source crosses above Band Midline AND Execution Bar) OR (execution mode M3 AND Price Source crosses above Band Bottom AND Execution Bar)
Calculation: Sell Condition = (execution mode M1 AND barssince(Price Source crosses below Band Midline) <= crossover window AND Price Source < Band Midline AND LinReg(Price Source, anchor window, 0) < LinReg(Price Source, anchor window, 0)[1] AND Execution Bar) OR (execution mode M2 AND Price Source crosses below Band Midline AND Execution Bar) OR (execution mode M3 AND Price Source crosses below Band Top AND Execution Bar)
Calculation: Bullish Regime = Buy Condition OR (Bullish Regime[1] AND NOT Sell Condition)
Calculation: Best Period = candidate period with the largest absolute Correlation(LN(T1 close), bar index, candidate period), on T1 bars
Calculation: Trend Stop = Highest(T1 close, Best Period) * (1 - trend stop percent / 100), on T1 bars at last completed T1 bar
Calculation: Event Stop = T1 close[post-event window - 1] * (1 - event stop percent / 100), on T1 bars at last completed T1 bar
Calculation: Post-Event R = Correlation(LN(T1 close), bar index, post-event window), on T1 bars at last completed T1 bar
Long: Buy Condition AND NOT Bullish Regime[1]
Short: Sell Condition AND Bullish Regime[1]
Long: Bullish Regime
Short: NOT Bullish Regime
Long: T1 close > Trend Stop AND T1 close[1] <= Trend Stop[1]
Long: T1 close > Trend Stop
Exit: long, T1 close[1] > Trend Stop[1] AND T1 close <= Trend Stop
Exit: long, T1 close <= Trend Stop
Long: T1 close > Event Stop AND T1 close[1] <= Event Stop[1]
Long: T1 close > Event Stop
Exit: long, T1 close[1] > Event Stop[1] AND T1 close <= Event Stop
Exit: long, T1 close <= Event Stop
Long: Post-Event R >= 0
Short: Post-Event R < 0