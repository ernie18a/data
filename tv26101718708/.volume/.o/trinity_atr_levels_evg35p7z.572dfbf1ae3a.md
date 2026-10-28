Calculation: Prior-period close = close of the last completed selected level-period bar
Calculation: ATR = average true range of the selected level-period bars, using the last completed bar
Calculation: Upper/lower trigger = prior-period close ± trigger share × ATR
Calculation: Upper/lower 38.2%, 50%, 61.8%, 78.6%, and 1 ATR levels = prior-period close ± the corresponding ATR fraction
Calculation: 10-minute EMA8 = 8-period EMA of 10-minute closes, using the last completed 10-minute bar
Calculation: Phase Oscillator = 3-period EMA of ((hourly close − 21-period hourly EMA) / (3 × 14-period hourly ATR)) × 100, using the last completed 1-hour bar; compare with the prior completed 1-hour value for direction
Long: confirmed chart-bar close crosses above the upper trigger (previous relevant close ≤ trigger and current close > trigger), optionally clearing an entry buffer; only during the configured signal session and timeframe, when the long entry budget and cooldown allow
Long: a confirmed chart-bar close first crosses above the upper 38.2% level while long is active
Long: after the upper 38.2% level has been reached while long is active, the bar low ≤ upper trigger and confirmed close > upper trigger
Long: after the upper 38.2% level has been reached while long is active, the bar low ≤ 10-minute EMA8 and confirmed close > 10-minute EMA8, with close ≤ upper 61.8%; use chart bars no slower than 10 minutes
Long: during the first hour of the configured session, a completed 10-minute close > prior-period close, the preceding completed 10-minute close ≤ prior-period close and ≥ lower trigger
Short: confirmed chart-bar close crosses below the lower trigger (previous relevant close ≥ trigger and current close < trigger), optionally clearing an entry buffer; only during the configured signal session and timeframe, when the short entry budget and cooldown allow
Short: a confirmed chart-bar close first crosses below the lower 38.2% level while short is active
Short: after the lower 38.2% level has been reached while short is active, the bar high ≥ lower trigger and confirmed close < lower trigger
Short: after the lower 38.2% level has been reached while short is active, the bar high ≥ 10-minute EMA8 and confirmed close < 10-minute EMA8, with close ≥ lower 61.8%; use chart bars no slower than 10 minutes
Short: during the first hour of the configured session, a completed 10-minute close < prior-period close, the preceding completed 10-minute close ≥ prior-period close and ≤ upper trigger
Exit: long, confirmed chart-bar close < upper trigger
Exit: short, confirmed chart-bar close > lower trigger
Exit: long, confirmed chart-bar close crosses above upper 61.8% (previous close ≤ level and current close > level); scale out at least half
Exit: short, confirmed chart-bar close crosses below lower 61.8% (previous close ≥ level and current close < level); scale out at least half
Exit: long, price reaches upper 1 ATR level
Exit: short, price reaches lower 1 ATR level