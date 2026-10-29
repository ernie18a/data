Calculation: RTI = EMA(100 × (close − lowest low over a lookback) ÷ (highest high over the same lookback − lowest low over the same lookback)), using chart-timeframe bars
Calculation: RTI state = LONG when RTI > upper band; SHORT when RTI < lower band; otherwise retain the previous state
Calculation: Macro-covered state = FLAT when RTI state is SHORT and close > chart-timeframe slow EMA; otherwise retain RTI state
Calculation: Daily AlphaTrend state = on daily bars, calculate ATR as the simple moving average of true range; set the up band to low − ATR × coefficient and down band to high + ATR × coefficient. Calculate momentum as MFI when the 20-bar volume average is positive, otherwise RSI. Initialize AlphaTrend at hl2; thereafter, when momentum ≥ 50, set it to the greater of the up band and its previous value, otherwise set it to the lesser of the down band and its previous value. Set state LONG on a crossover of AlphaTrend above its value two daily bars earlier, SHORT on a crossunder, and otherwise retain its previous state. Use the last completed daily state.
Calculation: Gated state = FLAT when the macro-covered state is LONG and the last completed daily AlphaTrend state is SHORT, or the macro-covered state is SHORT and the last completed daily AlphaTrend state is LONG; otherwise retain the macro-covered state
Calculation: Laguerre filter = (L0 + 2 × L1 + 2 × L2 + L3) ÷ 6, with L0 = (1 − gamma) × close + gamma × previous L0; L1 = −gamma × L0 + previous L0 + gamma × previous L1; L2 = −gamma × L1 + previous L1 + gamma × previous L2; L3 = −gamma × L2 + previous L2 + gamma × previous L3. Seed each initial value with close.
Calculation: Laguerre state = LONG when the Laguerre filter is greater than its value a slope lookback ago; SHORT when it is less; otherwise retain its previous state. Set it to FLAT when it is SHORT and close > chart-timeframe slow EMA.
Long: Gated state > 0 AND previous Gated state ≤ 0
Short: Gated state < 0 AND previous Gated state ≥ 0
Long: Laguerre state > 0
Short: Laguerre state < 0
Long: Gated state > 0 AND Laguerre state > 0
Short: Gated state < 0 AND Laguerre state < 0
Long: Last completed daily AlphaTrend state > 0
Short: Last completed daily AlphaTrend state < 0
Exit: Long, Gated state ≤ 0
Exit: Short, Gated state ≥ 0