Calculation: T1 bias = 1 if close[1] > EMA(close, T1 EMA length)[1], -1 if close[1] < EMA(close, T1 EMA length)[1], else 0; computed on T1 bars, read on chart bars as the value of the last completed T1 bar
Calculation: Box open bar = the most recent bar where highest(high, range lookback) - lowest(low, range lookback) <= compression multiple x ATR(ATR length), no setup is active before that bar, and bars since the most recent breakout or fizzle >= setup gap
Calculation: Accumulation start = max(Box open bar - range lookback + 1, most recent breakout or fizzle bar before Box open bar + 1)
Calculation: Box top = highest(high, range lookback) on the Box open bar, then max(Box top[1], high) on each later bar until the first bar whose close is above Box top[1] or below Box bottom[1]
Calculation: Box bottom = lowest(low, range lookback) on the Box open bar, then min(Box bottom[1], low) on each later bar until the first bar whose close is above Box top[1] or below Box bottom[1]
Calculation: Profile = histogram over profile rows of equal height spanning Box bottom to Box top at bar b-1, where b is the setup's breakout bar; each bar from Accumulation start to b-1 adds its volume split evenly across the rows between its low and high
Calculation: POC = midpoint of the lowest Profile row with the largest volume
Calculation: VAL = bottom edge of the lowest row of the value area, where the value area starts at the POC row and repeatedly adds the neighboring row with more volume (upper neighbor on ties; a missing neighbor is never added) until it holds at least value-area percent / 100 x total Profile volume
Calculation: VAH = top edge of the highest row of the value area
Calculation: Long setup = (bar b is the first bar after Box open bar whose close is outside the box) AND close at b > Box top at bar b-1 AND bars from Accumulation start to b >= min accumulation bars AND (HTF filter off OR T1 bias at b = 1) AND (for every bar j from Box open bar to b-1: Box top[j] - Box bottom[j] <= abandon multiple x compression multiple x ATR(ATR length) at j AND j - Accumulation start <= max accumulation bars) AND bars since b <= max pullback wait AND (close >= VAL on every bar from b to now) AND (a first touch bar k in (b, now] exists with low <= POC + POC zone half-width percent / 100 x (Box top - Box bottom at bar b-1)) AND (no bar from k to now-1 has close > POC AND close > open)
Calculation: Short setup = (bar b is the first bar after Box open bar whose close is outside the box) AND close at b < Box bottom at bar b-1 AND bars from Accumulation start to b >= min accumulation bars AND (HTF filter off OR T1 bias at b = -1) AND (for every bar j from Box open bar to b-1: Box top[j] - Box bottom[j] <= abandon multiple x compression multiple x ATR(ATR length) at j AND j - Accumulation start <= max accumulation bars) AND bars since b <= max pullback wait AND (close <= VAH on every bar from b to now) AND (a first touch bar k in (b, now] exists with high >= POC - POC zone half-width percent / 100 x (Box top - Box bottom at bar b-1)) AND (no bar from k to now-1 has close < POC AND close < open)
Calculation: SL distance = SL percent / 100 x entry price in fixed-percent mode, or SL ATR multiple x ATR(ATR length) at the entry bar in ATR mode
Calculation: TP distance = TP percent / 100 x entry price in fixed-percent mode, or TP ATR multiple x ATR(ATR length) at the entry bar in ATR mode
Calculation: Before EOD = EOD flatten off OR bar time in New York is before EOD time
Calculation: Post-exit cooldown elapsed = post-exit cooldown off OR bars since last exit >= time-exit cooldown if last exit was a time or EOD exit, else >= profit-exit cooldown if last exit was profitable, else >= loss-exit cooldown
Long: engine on AND flat after this bar's exits AND Before EOD AND bars since last entry >= entry cooldown AND Post-exit cooldown elapsed AND Long setup AND close > POC AND close > open
Short: engine on AND flat after this bar's exits AND Before EOD AND bars since last entry >= entry cooldown AND Post-exit cooldown elapsed AND Short setup AND close < POC AND close < open
Exit: long, bars since entry >= 1 AND low <= entry price - SL distance
Exit: long, bars since entry >= 1 AND high >= entry price + TP distance
Exit: long, bars since entry >= max bars in trade
Exit: long, EOD flatten on AND bar time in New York >= EOD time
Exit: short, bars since entry >= 1 AND high >= entry price + SL distance
Exit: short, bars since entry >= 1 AND low <= entry price - TP distance
Exit: short, bars since entry >= max bars in trade
Exit: short, EOD flatten on AND bar time in New York >= EOD time