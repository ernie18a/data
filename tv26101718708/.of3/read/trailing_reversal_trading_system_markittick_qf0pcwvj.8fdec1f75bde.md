Calculation: upper swing series = high when the extreme-source setting selects highs and lows, otherwise close, optionally smoothed by the selected SMA, EMA, RMA, WMA, or HMA using the smoothing lookback
Calculation: lower swing series = low when the extreme-source setting selects highs and lows, otherwise close, optionally smoothed by the same selected moving average and lookback
Calculation: running swing high = running maximum of the upper swing series and its bar while direction is undefined or up; hold it as the pivot high while direction is down, and reset it to the current upper swing series on a down-to-up reversal
Calculation: running swing low = running minimum of the lower swing series and its bar while direction is undefined or down; hold it as the pivot low while direction is up, and reset it to the current lower swing series on an up-to-down reversal
Calculation: swing direction = undefined initially; set to up on an up reversal and down on a down reversal, otherwise retain its direction
Calculation: pivot low = running swing low at an up reversal
Calculation: pivot high = running swing high at a down reversal
Calculation: up-threshold condition = swing direction is undefined or down, the current bar is after the bar that set the running swing low, and upper swing series >= running swing low × (1 + reversal percentage / 100)
Calculation: down-threshold condition = swing direction is undefined or up, the current bar is after the bar that set the running swing high, and lower swing series <= running swing high × (1 - reversal percentage / 100)
Calculation: up reversal = up-threshold condition AND (NOT down-threshold condition OR swing direction is defined OR the running swing low was set later than the running swing high OR both were set on the same bar and close >= their midpoint)
Calculation: down reversal = down-threshold condition AND (NOT up-threshold condition OR swing direction is defined OR the running swing high was set later than the running swing low OR both were set on the same bar and close < their midpoint)
Calculation: ordered target risk multiples = the three separately configured target risk multiples sorted from lowest to highest
Calculation: long stop = max(pivot low, entry price - ATR(high, low, close, ATR lookback) × stop ATR multiple)
Calculation: short stop = min(pivot high, entry price + ATR(high, low, close, ATR lookback) × stop ATR multiple)
Calculation: initial risk = absolute distance between entry price and stop
Calculation: long targets = entry price + initial risk multiplied by the first, second, and third ordered target risk multiples, respectively
Calculation: short targets = entry price - initial risk multiplied by the first, second, and third ordered target risk multiples, respectively
Long: up reversal
Short: down reversal
Long: up reversal AND signal bar confirmed AND NOT (signal lock enabled AND current bar is latest) AND (HTF filter disabled OR T1 is below the chart timeframe OR last completed T1 close > EMA(close, HTF EMA lookback, T1, last completed bar)) AND (ADX filter disabled OR previous confirmed chart bar's ADX(high, low, close, ADX lookback, same ADX lookback) >= ADX minimum) AND ATR is available AND stop and all targets > 0 AND initial risk > minimum tick AND long stop < entry price AND first long target rounded to minimum tick > entry price rounded to minimum tick, with entry price = signal bar close
Short: down reversal AND signal bar confirmed AND NOT (signal lock enabled AND current bar is latest) AND (HTF filter disabled OR T1 is below the chart timeframe OR last completed T1 close < EMA(close, HTF EMA lookback, T1, last completed bar)) AND (ADX filter disabled OR previous confirmed chart bar's ADX(high, low, close, ADX lookback, same ADX lookback) >= ADX minimum) AND ATR is available AND stop and all targets > 0 AND initial risk > minimum tick AND short stop > entry price AND first short target rounded to minimum tick < entry price rounded to minimum tick, with entry price = signal bar close
Exit: long, long position was active at the start of a bar after its entry bar AND target 1 had not been reached before that bar AND high >= first long target
Exit: long, long position was active at the start of a bar after its entry bar AND target 2 had not been reached before that bar AND high >= second long target
Exit: long, long position was active at the start of a bar after its entry bar AND high >= third long target
Exit: long, long position was active at the start of a bar after its entry bar AND bar confirmed AND close < long stop AND high < third long target
Exit: long, long position was active at the start of a bar after its entry bar AND bar confirmed AND NOT (signal lock enabled AND current bar is latest) AND down reversal AND close >= long stop AND high < third long target
Exit: short, short position was active at the start of a bar after its entry bar AND target 1 had not been reached before that bar AND low <= first short target
Exit: short, short position was active at the start of a bar after its entry bar AND target 2 had not been reached before that bar AND low <= second short target
Exit: short, short position was active at the start of a bar after its entry bar AND low <= third short target
Exit: short, short position was active at the start of a bar after its entry bar AND bar confirmed AND close > short stop AND low > third short target
Exit: short, short position was active at the start of a bar after its entry bar AND bar confirmed AND NOT (signal lock enabled AND current bar is latest) AND up reversal AND close <= short stop AND low > third short target