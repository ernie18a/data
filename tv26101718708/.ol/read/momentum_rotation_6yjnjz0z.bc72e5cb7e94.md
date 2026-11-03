Calculation: Momentum = percentage change in an asset’s close from its long-term lookback close
Calculation: Trend = asset’s close is above its long-term simple moving average
Calculation: Score = momentum plus a positive trend bonus when Trend is true, otherwise a negative trend bonus
Calculation: Best asset = eligible asset with the highest Score; resolve ties in the source’s fixed candidate priority order
Long: first trading day of the month AND Best asset’s Trend is true
Exit: long, first trading day of the month