Calculation: Resistance(T) = high(T, still-forming bar sampled on chart bars) + ATR(lookback, T, still-forming bar sampled on chart bars)
Calculation: Support(T) = low(T, still-forming bar sampled on chart bars) - ATR(lookback, T, still-forming bar sampled on chart bars)
Calculation: Scheduled upper level = max(high(T5, last completed bar sampled on chart bars) + buffer, close + broker minimum stop distance + spread)
Calculation: Scheduled lower level = min(low(T5, last completed bar sampled on chart bars) - buffer, close - broker minimum stop distance - spread)
Calculation: Upper breakout level A = if time of day equals scheduled time then Scheduled upper level else if Resistance(T1) > close then Resistance(T1) + buffer else if Resistance(T2) > close then Resistance(T2) + buffer else close + anchor distance + buffer; T1 is shorter than T2 and both use still-forming bars sampled on chart bars
Calculation: Lower breakout level A = if time of day equals scheduled time then Scheduled lower level else if Support(T1) < close then Support(T1) - buffer else if Support(T2) < close then Support(T2) - buffer else close - anchor distance - buffer; T1 is shorter than T2 and both use still-forming bars sampled on chart bars
Calculation: Upper breakout level B = if time of day equals scheduled time then Scheduled upper level else if Resistance(T3) > close then Resistance(T3) + buffer + spread else if Resistance(T4) > close then Resistance(T4) + buffer + spread else close + anchor distance + buffer + spread; T3 is shorter than T4 and both use still-forming bars sampled on chart bars
Calculation: Lower breakout level B = if time of day equals scheduled time then Scheduled lower level else if Support(T3) < close then Support(T3) - buffer - spread else if Support(T4) < close then Support(T4) - buffer - spread else close - anchor distance - buffer - spread; T3 is shorter than T4 and both use still-forming bars sampled on chart bars
Long: high >= Upper breakout level A
Long: high >= Upper breakout level B
Short: low <= Lower breakout level A
Short: low <= Lower breakout level B
Calculation: Net position profit = open-position profit + commission + swap
Calculation: Basket net profit = sum of net position profit over the configured account scope
Calculation: Basket target = rounded minimum tradable lot size
Calculation: Basket rollback = basket target × rollback fraction
Calculation: Previous basket net profit = immediately previous recorded basket net profit after reaching the basket target
Calculation: Emergency loss threshold = account balance × loss-limit percentage
Long: basket net profit < -Emergency loss threshold AND total short lots > total long lots AND emergency loss lock is inactive
Short: basket net profit < -Emergency loss threshold AND total long lots > total short lots AND emergency loss lock is inactive
Calculation: Recovering profit = sum of net position profit for open positions opened after the emergency hedge order
Calculation: Aggregate loss = absolute sum of negative net position profit for open positions
Exit: long, basket net profit >= basket target AND basket net profit <= Previous basket net profit - Basket rollback AND trending mode is disabled
Exit: short, basket net profit >= basket target AND basket net profit <= Previous basket net profit - Basket rollback AND trending mode is disabled
Exit: long, trending mode is enabled AND basket net profit >= basket target AND stop-loss price <= entry price
Exit: short, trending mode is enabled AND basket net profit >= basket target AND stop-loss price <= entry price
Exit: long, Recovering profit > Aggregate loss
Exit: short, Recovering profit > Aggregate loss
Exit: long, stop-loss distance is positive AND low <= entry price - stop-loss distance
Exit: short, stop-loss distance is positive AND high >= entry price + stop-loss distance
Calculation: Long favorable excursion = highest high since entry - entry price
Calculation: Short favorable excursion = entry price - lowest low since entry
Calculation: Long emergency trailing level = entry price + Long favorable excursion - emergency trailing distance
Calculation: Short emergency trailing level = entry price - Short favorable excursion + emergency trailing distance
Exit: long, emergency loss lock is active AND Long favorable excursion > emergency trailing distance + minimum profit distance AND low <= Long emergency trailing level
Exit: short, emergency loss lock is active AND Short favorable excursion > emergency trailing distance + minimum profit distance AND high >= Short emergency trailing level
Calculation: Long stepped trailing level = entry price + (floor((Long favorable excursion - trail start) / trail amount) - step lag) × trail amount
Calculation: Short stepped trailing level = entry price - (floor((Short favorable excursion - trail start) / trail amount) - step lag) × trail amount
Exit: long, trail start is positive AND Long favorable excursion >= trail start AND Long favorable excursion > broker minimum stop distance AND low <= entry price
Exit: short, trail start is positive AND Short favorable excursion >= trail start AND Short favorable excursion > broker minimum stop distance AND high >= entry price
Exit: long, trail amount is positive AND floor((Long favorable excursion - trail start) / trail amount) >= one increment AND low <= Long stepped trailing level
Exit: short, trail amount is positive AND floor((Short favorable excursion - trail start) / trail amount) >= one increment AND high >= Short stepped trailing level
Calculation: Long delayed target = close at the first observation when holding time exceeds the duration threshold, position profit is negative, no take-profit is set, and take-profit distance is positive, plus take-profit distance
Calculation: Short delayed target = close at the first observation when holding time exceeds the duration threshold, position profit is negative, no take-profit is set, and take-profit distance is positive, minus take-profit distance
Exit: long, high >= Long delayed target
Exit: short, low <= Short delayed target