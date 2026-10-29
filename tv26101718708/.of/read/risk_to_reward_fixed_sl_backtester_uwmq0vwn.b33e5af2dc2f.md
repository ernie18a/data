Calculation: Initial long stop = on the entry bar, choose one: close minus ATR factor × 14-bar RMA of true range; lowest low over the pivot lookback; or low minus VWAP-stop multiplier × absolute value of (14-bar sum of (VWAP of true range × volume) / 14-bar sum of volume)
Calculation: Long take-profit = on the entry bar, choose one: entry close + risk/reward ratio × absolute value of (entry close − initial long stop); or entry close × (1 + fixed take-profit percentage)
Calculation: Break-even trigger = entry close + break-even risk/reward ratio × absolute value of (entry close − initial long stop)
Calculation: Active long stop = initial long stop until the break-even trigger is reached; thereafter, entry price × (1 + configured percentage above entry)
Long: selected external indicator value = configured signal value AND position is flat AND (date-range limit is disabled OR bar time is within the configured date range)
Exit: long, low ≤ active long stop OR high ≥ long take-profit