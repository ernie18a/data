Calculation: bullish engulfing = current close > current open AND previous close < previous open AND current real-body size > previous real-body size AND current body top > previous body top
Calculation: bearish engulfing = current close < current open AND previous close > previous open AND current real-body size > previous real-body size AND current body bottom < previous body bottom
Calculation: bullish engulfing state = bars since the most recent bullish engulfing < bars since the most recent bearish engulfing
Calculation: bullish MA state = bars since the most recent close crossing above the selected moving average < bars since the most recent close crossing below it
Calculation: bullish condition = bullish engulfing state AND bullish MA state
Calculation: bearish condition = bars since the most recent bearish engulfing < bars since the most recent bullish engulfing AND bars since the most recent close crossing below the selected moving average < bars since the most recent close crossing above it
Calculation: bearish condition = bearish engulfing state AND bearish MA state
Calculation: bullish signal = bars since the most recent bullish condition crossing below bars since the most recent bearish condition
Calculation: bearish signal = bars since the most recent bullish condition crossing above bars since the most recent bearish condition
Calculation: bullish trend = bars since the most recent bearish signal > bars since the most recent bullish signal
Calculation: bearish trend = bars since the most recent bearish signal < bars since the most recent bullish signal
Calculation: selected moving average = selected moving-average type of selected price source over the selected lookback
Calculation: long target = most recent bullish signal close + selected USD profit goal
Calculation: long stop = most recent bullish signal close - selected USD stop goal
Calculation: short target = most recent bearish signal close - selected USD profit goal
Calculation: short stop = most recent bearish signal close + selected USD stop goal
Long: bullish signal AND datetime >= selected start datetime AND datetime <= selected stop datetime
Short: bearish signal AND datetime >= selected start datetime AND datetime <= selected stop datetime
Exit: long, previous close < current selected moving average OR (bullish trend AND high >= long target) OR (bullish trend AND low <= long stop), while datetime >= selected start datetime AND datetime <= selected stop datetime
Exit: short, previous close > current selected moving average OR (bearish trend AND low <= short target) OR (bearish trend AND high >= short stop), while datetime >= selected start datetime AND datetime <= selected stop datetime