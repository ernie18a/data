Calculation: Faster selected average = EMA(close, shorter lookback) when paired with either slower average; EMA(close, medium lookback) when paired with the longest average.
Calculation: Slower selected average = EMA(close, medium lookback) when paired with the shortest average; HMA(close, longer lookback) when paired with either longer EMA.
Long: Faster selected average crosses above slower selected average.
Short: Faster selected average crosses below slower selected average.
Long: Faster selected average > slower selected average.
Short: Faster selected average <= slower selected average.
Long: Faster selected average crosses above slower selected average AND close > HMA(close, higher-timeframe lookback, T1, still-forming bar sampled on chart bars).
Short: Faster selected average crosses below slower selected average AND close < HMA(close, higher-timeframe lookback, T1, still-forming bar sampled on chart bars).
Long: On each enabled screened instrument's T2–T11 bars, bars since its faster selected average crossed above its slower selected average < bars since they crossed below; calculate on the instrument's still-forming timeframe bar.
Short: On each enabled screened instrument's T2–T11 bars, bars since its faster selected average crossed below its slower selected average < bars since they crossed above; calculate on the instrument's still-forming timeframe bar.
Long: More than half of enabled screened instruments have bars since their upward cross < bars since their downward cross.
Short: More than half of enabled screened instruments have bars since their downward cross < bars since their upward cross.
Calculation: Initial long stop = entry price - ATR(ATR lookback) * ATR stop multiplier in ATR risk mode; otherwise entry price * (1 - stop percentage / 100).
Calculation: Initial short stop = entry price + ATR(ATR lookback) * ATR stop multiplier in ATR risk mode; otherwise entry price * (1 + stop percentage / 100).
Calculation: Long target = entry price + ATR(ATR lookback) * ATR stop multiplier * risk/reward parameter in ATR risk mode; otherwise entry price * (1 + target percentage / 100).
Calculation: Short target = entry price - ATR(ATR lookback) * ATR stop multiplier * risk/reward parameter in ATR risk mode; otherwise entry price * (1 - target percentage / 100).
Calculation: Long risk/reward = (close - entry price) / (entry price - initial long stop).
Calculation: Short risk/reward = (entry price - close) / (initial short stop - entry price).
Calculation: Maximum long risk/reward since entry = highest long risk/reward since entry.
Calculation: Maximum short risk/reward since entry = highest short risk/reward since entry.
Calculation: Advanced long stop = max(entry price, close - ATR(ATR lookback) * trailing ATR multiplier).
Calculation: Advanced short stop = min(entry price, close + ATR(ATR lookback) * trailing ATR multiplier).
Exit: long, fixed stop/target management selected AND (low <= initial long stop OR high >= long target).
Exit: short, fixed stop/target management selected AND (high >= initial short stop OR low <= short target).
Exit: long, breakeven management selected AND (low <= (maximum long risk/reward since entry >= breakeven trigger ? entry price : initial long stop) OR high >= long target).
Exit: short, breakeven management selected AND (high >= (maximum short risk/reward since entry >= breakeven trigger ? entry price : initial short stop) OR low <= short target).
Exit: long, partial-close-plus-breakeven or trailing management selected AND this is the first bar since entry with long risk/reward >= partial-close trigger.
Exit: short, partial-close-plus-breakeven or trailing management selected AND this is the first bar since entry with short risk/reward >= partial-close trigger.
Exit: long, partial-close-plus-breakeven management selected AND (low <= (maximum long risk/reward since entry >= partial-close trigger ? entry price : initial long stop) OR high >= long target).
Exit: short, partial-close-plus-breakeven management selected AND (high >= (maximum short risk/reward since entry >= partial-close trigger ? entry price : initial short stop) OR low <= short target).
Exit: long, trailing management selected AND (low <= (maximum long risk/reward since entry >= partial-close trigger ? advanced long stop : initial long stop) OR high >= long target).
Exit: short, trailing management selected AND (high >= (maximum short risk/reward since entry >= partial-close trigger ? advanced short stop : initial short stop) OR low <= short target).