Calculation: Risk close A = close of risk input A's current T1 bar, including the still-forming bar, sampled on each chart bar
Calculation: Risk close B = close of risk input B's current T1 bar, including the still-forming bar, sampled on each chart bar
Calculation: Risk average A = EMA(Risk close A, risk EMA lookback A) on chart bars
Calculation: Risk average B = EMA(Risk close B, risk EMA lookback B) on chart bars
Calculation: Risk A rising = Risk close A > Risk average A AND Risk close A > Risk close A[1], where [1] is the previous chart bar's sample
Calculation: Risk B rising = Risk close B > Risk average B AND Risk close B > Risk close B[1], where [1] is the previous chart bar's sample
Calculation: Trend average = EMA(source, trend lookback)
Calculation: Smoothed range = EMA(EMA(abs(source - source[1]), range lookback), 2 * range lookback - 1) * range multiplier
Calculation: Range filter = if source > prior range filter then max(source - Smoothed range, prior range filter) else min(source + Smoothed range, prior range filter), with prior range filter initialized to 0
Calculation: Rising filter count = if Range filter > Range filter[1] then prior count + 1 else if Range filter < Range filter[1] then 0 else prior count, initialized to 0
Calculation: Falling filter count = if Range filter < Range filter[1] then prior count + 1 else if Range filter > Range filter[1] then 0 else prior count, initialized to 0
Calculation: Signal state = if source > Trend average AND source > Range filter AND Rising filter count > 0 AND Risk close A < caution level AND NOT (Risk close B > Risk average B AND Risk close B > Risk close B[1]) AND Risk close A < Risk average A AND Risk close A < Risk close A[1] then long else if Risk close A >= panic level OR (Risk A rising AND Risk B rising) OR (Risk close A >= danger level AND Risk A rising) OR (source < Trend average AND source < Range filter AND Falling filter count > 0) then defensive else if source > Trend average AND source > Range filter AND Rising filter count > 0 AND NOT (Risk close A >= panic level OR (Risk A rising AND Risk B rising)) then neutral else prior Signal state, initially neutral
Long: Signal state is long AND Signal state on the prior chart bar is not long
Exit: long, Signal state is defensive AND Signal state on the prior chart bar is not defensive