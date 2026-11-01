Calculation: Ahoora direction = -1 if low < moving average of low; otherwise +1 if high > moving average of high; otherwise 0. Both moving averages use the same lookback and method.
Calculation: Pivot = (previous pivot-day high + previous pivot-day low + previous pivot-day close) / 3. A pivot day is determined by the configured time-zone offset, with Sunday grouped with Monday and Saturday grouped with Friday.
Calculation: ATR offsets A, B, C, D = ATRs with the same lookback on four successively longer timeframes, sampled at the start of the previous pivot day using the bar still forming on each timeframe. Each timeframe may be higher or lower than the chart timeframe. Convert each ATR to the displayed price increment using the configured price scale; truncate B to an integer before conversion.
Calculation: Upper levels U1, U2, U3 and lower levels L1, L2, L3 = at the start of each pivot day, if chart-bar close > EMA of close, U1 = Pivot + B, U2 = U1 + B, U3 = Pivot + D + C - A, L1 = Pivot - C, L2 = L1 - B, L3 = Pivot - D - C; if chart-bar close < EMA of close, U1 = Pivot + C, U2 = U1 + B, U3 = Pivot + D + C, L1 = Pivot - B, L2 = L1 - B, L3 = Pivot - D - C + A. Hold these levels until the next pivot day. The EMA and ATRs use the same lookback.
Calculation: Directional score = for each of five progressively longer close SMAs, add one point when the SMA is rising for the bullish score or falling for the bearish score; add three points to the bullish score if (AC[1] > AC[2] AND AC[2] > AC[3] AND AC[0] < 0 AND AC[0] > AC[1]) OR (AC[0] > AC[1] AND AC[1] > AC[2] AND AC[0] > 0); add three points to the bearish score if (AC[1] < AC[2] AND AC[2] < AC[3] AND AC[0] > 0 AND AC[0] < AC[1]) OR (AC[0] < AC[1] AND AC[1] < AC[2] AND AC[0] < 0). AC is the Accelerator Oscillator; index 0 is the bar still forming and subsequent indices are earlier completed bars. Calculate the score separately on each of three progressively higher timeframes, each of which may be higher or lower than the chart timeframe.
Long: Ahoora direction = +1
Short: Ahoora direction = -1
Long: high >= U1 OR high >= U1 + B/3 OR high >= U1 + B/2
Short: low <= L1 OR low <= L1 - B/3 OR low <= L1 - B/2
Long: close > U1
Short: close < L1
Long: bullish directional score on each of the three timeframes > half the maximum score
Short: bearish directional score on each of the three timeframes > half the maximum score
Exit: long, low <= L1 OR (entry price = U1 AND high >= U2) OR (entry price = U1 + B/3 AND high >= U3)
Exit: short, high >= U1 OR (entry price = L1 AND low <= L2) OR (entry price = L1 - B/3 AND low <= L3)
Exit: long, high >= U1 OR high >= U2 OR high >= U3 OR low <= L3
Exit: short, low <= L1 OR low <= L2 OR low <= L3 OR high >= U3