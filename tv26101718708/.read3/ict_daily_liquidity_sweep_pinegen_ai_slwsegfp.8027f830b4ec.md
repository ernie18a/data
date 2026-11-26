Calculation: completed Asian-session low = lowest(low, current day's Asian-session bars)
Calculation: completed Asian-session high = highest(high, current day's Asian-session bars)
Calculation: completed London-session low = lowest(low, current day's London-session bars)
Calculation: completed London-session high = highest(high, current day's London-session bars)
Calculation: previous T1 low = low(T1, last completed bar, taken on chart bars)
Calculation: previous T1 high = high(T1, last completed bar, taken on chart bars)
Calculation: prior swing low = lowest(low, swing lookback)[1] on chart bars
Calculation: prior swing high = highest(high, swing lookback)[1] on chart bars
Calculation: long stop price = entry-signal bar low − stop-buffer parameter × pip size
Calculation: short stop price = entry-signal bar high + stop-buffer parameter × pip size
Calculation: initial long risk = abs(entry-signal bar close − long stop price)
Calculation: initial short risk = abs(short stop price − entry-signal bar close)
Long: position is flat AND UTC hour of bar datetime >= entry-window start AND UTC hour of bar datetime < entry-window end AND ((Asian-session range is complete AND low < completed Asian-session low AND close > completed Asian-session low) OR (previous T1 low is available AND low < previous T1 low AND close > previous T1 low) OR (London-sweep filter is enabled AND London-session range is complete AND low < completed London-session low AND close > completed London-session low) OR (swing-sweep filter is enabled AND low < prior swing low AND close > prior swing low))
Short: position is flat AND UTC hour of bar datetime >= entry-window start AND UTC hour of bar datetime < entry-window end AND ((Asian-session range is complete AND high > completed Asian-session high AND close < completed Asian-session high) OR (previous T1 high is available AND high > previous T1 high AND close < previous T1 high) OR (London-sweep filter is enabled AND London-session range is complete AND high > completed London-session high AND close < completed London-session high) OR (swing-sweep filter is enabled AND high > prior swing high AND close < prior swing high))
Exit: long, low <= long stop price OR high >= entry-signal bar close + initial long risk × TP1 R:R parameter OR high >= entry-signal bar close + initial long risk × TP2 R:R parameter OR (UTC hour of bar datetime = entry-window end AND minute of bar datetime = 0)
Exit: short, high >= short stop price OR low <= entry-signal bar close − initial short risk × TP1 R:R parameter OR low <= entry-signal bar close − initial short risk × TP2 R:R parameter OR (UTC hour of bar datetime = entry-window end AND minute of bar datetime = 0)