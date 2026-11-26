Calculation: Candidate top = the previous bar's high and low when highestbars(high, structural lookback) = 1; replace it on each new qualifying bar and clear it after a valid short signal.
Calculation: Candidate bottom = the previous bar's high and low when lowestbars(low, structural lookback) = 1; replace it on each new qualifying bar and clear it after a valid long signal.
Calculation: Long signal stop = candidate bottom low − ATR(ATR lookback) × stop buffer, stored at each valid long signal.
Calculation: Short signal stop = candidate top high + ATR(ATR lookback) × stop buffer, stored at each valid short signal.
Long: while a bottom candidate is active, on a later bar close[1] > candidate bottom high + ATR(ATR lookback) × breakout buffer if close confirmation is enabled, otherwise high[1] > the same level; volume filter disabled or volume[1] > SMA(volume, volume lookback)[1] × volume multiplier; session filter disabled or bar datetime is within the configured session; and no prior signal or at least the minimum signal gap bars since the prior signal.
Short: while a top candidate is active, on a later bar close[1] < candidate top low − ATR(ATR lookback) × breakout buffer if close confirmation is enabled, otherwise low[1] < the same level; volume filter disabled or volume[1] > SMA(volume, volume lookback)[1] × volume multiplier; session filter disabled or bar datetime is within the configured session; and no prior signal or at least the minimum signal gap bars since the prior signal.
Long: bearish bias is active and close[1] > the latest short signal stop.
Short: bullish bias is active and close[1] < the latest long signal stop.
Calculation: Trade entry price = close[1] when a new trade level is created.
Calculation: Trade stop breach is recorded when, for a long, close[1] <= the trade stop if close confirmation is enabled or low[1] <= the trade stop otherwise; for a short, close[1] >= the trade stop if close confirmation is enabled or high[1] >= the trade stop otherwise. Keep the breach recorded until a new trade level is created.
Calculation: Long trade stop = long signal stop at a new long trade level; on a same-side signal before any recorded stop breach, use the greater of the previous trade stop and the latest long signal stop.
Calculation: Short trade stop = short signal stop at a new short trade level; on a same-side signal before any recorded stop breach, use the lesser of the previous trade stop and the latest short signal stop.
Calculation: Initial risk = absolute value of trade entry price − initial trade stop.
Calculation: Current risk = absolute value of trade entry price − current trade stop.
Calculation: Long target 1 = trade entry price + initial risk × target multiple 1.
Calculation: Long target 2 = trade entry price + current risk × target multiple 2; recalculate on each same-side signal before any recorded stop breach.
Calculation: Long target 3 = trade entry price + current risk × target multiple 3; recalculate on each same-side signal before any recorded stop breach.
Calculation: Short target 1 = trade entry price − initial risk × target multiple 1.
Calculation: Short target 2 = trade entry price − current risk × target multiple 2; recalculate on each same-side signal before any recorded stop breach.
Calculation: Short target 3 = trade entry price − current risk × target multiple 3; recalculate on each same-side signal before any recorded stop breach.
Exit: long, trade levels are enabled, an active long trade level exists, target 1 has not previously been hit, and high >= long target 1.
Exit: long, trade levels are enabled, an active long trade level exists, target 2 has not previously been hit, and high >= long target 2.
Exit: long, trade levels are enabled, an active long trade level exists, target 3 has not previously been hit, and high >= long target 3.
Exit: short, trade levels are enabled, an active short trade level exists, target 1 has not previously been hit, and low <= short target 1.
Exit: short, trade levels are enabled, an active short trade level exists, target 2 has not previously been hit, and low <= short target 2.
Exit: short, trade levels are enabled, an active short trade level exists, target 3 has not previously been hit, and low <= short target 3.