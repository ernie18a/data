Calculation: swing high = highest high from the bar that recorded the last swing low onward, recorded at the first completed T1 bar after that swing low where high < previous T1 bar high, or close < previous T1 bar low, or low < last swing low, or this bar sets that highest high and closes below its open
Calculation: swing low = lowest low from the bar that recorded the last swing high onward, recorded at the first completed T1 bar after that swing high where low > previous T1 bar low, or close > previous T1 bar high, or high > last swing high, or this bar sets that lowest low and closes above its open
Calculation: trend state = +1 if last completed T1 bar close > last swing high, -1 if last completed T1 bar close < last swing low, otherwise unchanged; swing values as of the previous T1 bar
Calculation: support level = lower of open and close of a swing low bar, committed when the next swing high is recorded
Calculation: resistance level = higher of open and close of a swing high bar, committed when the next swing low is recorded
Calculation: break offset(level) = break offset ticks * tick size, or break offset percent * level / 100, by mode
Calculation: state(support level) = SG if no completed T1 bar since commitment had lower of open and close < (level - break offset(level)); G if such a bar exists and current chart close >= level; otherwise L
Calculation: state(resistance level) = G if a completed T1 bar since commitment had higher of open and close > (level + break offset(level)) and current chart close > level; RL if such a bar exists and current chart close <= level; otherwise R
Long: chart timeframe is intraday and at most T2 AND trend state = +1 AND forming T1 bar low >= last swing low
Long: forming T1 bar high > last swing high AND trend state != +1
Long: trend state = +1 AND trend state on previous chart bar != +1
Long: among the nearest below-count levels below current chart close, some level has state SG or G
Short: chart timeframe is intraday and at most T2 AND trend state = -1 AND forming T1 bar high <= last swing high
Short: forming T1 bar low < last swing low AND trend state != -1
Short: trend state = -1 AND trend state on previous chart bar != -1
Short: lower of open and close of last completed T1 bar < (support level - break offset(support level)) for a support level that was in state SG before that bar
Short: among the nearest above-count levels above current chart close, some level has state RL