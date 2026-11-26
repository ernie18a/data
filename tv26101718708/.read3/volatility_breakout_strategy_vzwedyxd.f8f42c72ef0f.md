Calculation: Long entry level = on chart bars, close of the last completed T1 bar + breakout multiplier × (high of the last completed T1 bar − low of the last completed T1 bar), refreshed when the prior chart bar’s UTC hour minus the current chart bar’s UTC hour > hour-gap threshold
Calculation: Long stop level = (low of the last completed T1 bar + long entry level) / 2, refreshed when the prior chart bar’s UTC hour minus the current chart bar’s UTC hour > hour-gap threshold
Calculation: Short entry level = on chart bars, close of the last completed T1 bar − breakout multiplier × (high of the last completed T1 bar − low of the last completed T1 bar), refreshed when the prior chart bar’s UTC hour minus the current chart bar’s UTC hour > hour-gap threshold
Calculation: Short stop level = (high of the last completed T1 bar + short entry level) / 2, refreshed when the prior chart bar’s UTC hour minus the current chart bar’s UTC hour > hour-gap threshold
Long: high of current chart bar > long entry level AND no open position AND (trend filter disabled OR long entry level / long stop level > short stop level / short entry level)
Short: short entry enabled AND low of current chart bar < short entry level AND no open position AND (trend filter disabled OR long entry level / long stop level < short stop level / short entry level)
Exit: long, prior chart bar’s UTC hour minus current chart bar’s UTC hour > hour-gap threshold OR close of current chart bar < long stop level
Exit: short, prior chart bar’s UTC hour minus current chart bar’s UTC hour > hour-gap threshold OR close of current chart bar > short stop level
Calculation: Long breakout level = T1 close + (T1 high - T1 low) * P1
Calculation: Short breakout level = T1 close - (T1 high - T1 low) * P1
Long: chart close > Long breakout level
Short: chart close < Short breakout level
Exit: long, UTC day rollover OR chart close < (T1 low + Long breakout level) / 2
Exit: short, UTC day rollover OR chart close > (T1 high + Short breakout level) / 2