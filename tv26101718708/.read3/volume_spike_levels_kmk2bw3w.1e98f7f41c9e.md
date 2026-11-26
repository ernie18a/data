Calculation: concentration = (volume / SMA(volume, volume lookback)) / max(abs(close - open) / SMA(abs(close - open), volume lookback), body floor), undefined unless both SMA values are positive
Calculation: liveBurst = openBurst[1] AND (bar index - lastSpike[1]) <= confirmation window
Calculation: upBreak = marker mode is confirmed direction AND liveBurst AND ((confirmation mode is wick AND high > high(trigger[1])) OR (confirmation mode is body AND max(open, close) > high(trigger[1])) OR (confirmation mode is close AND close > high(trigger[1])))
Calculation: downBreak = marker mode is confirmed direction AND liveBurst AND ((confirmation mode is wick AND low < low(trigger[1])) OR (confirmation mode is body AND min(open, close) < low(trigger[1])) OR (confirmation mode is close AND close < low(trigger[1])))
Calculation: registeredSpike = ((volume >= SMA(volume, volume lookback) * weak multiplier) OR (strength mode is graded AND volume >= SMA(volume, volume lookback) * medium multiplier) OR (strength mode is graded AND volume >= SMA(volume, volume lookback) * strong multiplier)) AND concentration is defined AND NOT upBreak AND NOT downBreak
Calculation: openBurst = registeredSpike OR (liveBurst AND NOT upBreak AND NOT downBreak)
Calculation: lastSpike = bar index IF registeredSpike ELSE lastSpike[1]
Calculation: trigger = bar index IF registeredSpike AND (NOT liveBurst OR concentration > concentration(trigger[1])) ELSE trigger[1]
Long: upBreak
Short: downBreak