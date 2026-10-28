Calculation: ATR = simple moving average of true range from the previous bar, over a configurable lookback
Calculation: AlphaTrend = if the previous-bar Money Flow Index is at least 50, the greater of the prior AlphaTrend and the previous bar's low minus ATR times a configurable multiplier; otherwise, the lesser of the prior AlphaTrend and the previous bar's high plus ATR times that multiplier
Calculation: Breakout momentum = breakout override enabled AND absolute difference between the previous and two-bars-ago closes > ATR from the previous bar times a configurable sensitivity
Calculation: Bars since prior long signal = reset to 0 when the long signal from the previous bar is true; otherwise increment by 1
Calculation: Bars since prior short signal = reset to 0 when the short signal from the previous bar is true; otherwise increment by 1
Long: (AlphaTrend[1] > AlphaTrend[3] AND AlphaTrend[2] <= AlphaTrend[4]) OR (Breakout momentum AND close[1] > AlphaTrend[1] AND close[2] <= AlphaTrend[2]); AND bars since prior long signal > bars since prior short signal
Short: (AlphaTrend[1] < AlphaTrend[3] AND AlphaTrend[2] >= AlphaTrend[4]) OR (Breakout momentum AND close[1] < AlphaTrend[1] AND close[2] >= AlphaTrend[2]); AND bars since prior short signal > bars since prior long signal
Exit: long, bars since prior long signal < bars since prior short signal AND close[1] < AlphaTrend[1]
Exit: short, bars since prior short signal < bars since prior long signal AND close[1] > AlphaTrend[1]