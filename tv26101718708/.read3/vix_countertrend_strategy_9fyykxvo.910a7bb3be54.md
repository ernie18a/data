Long: close(T1, current bar still forming, mapped to chart bars)[1] >= panic threshold AND close(T1, current bar still forming, mapped to chart bars) crosses below SMA(close, lookback parameter, T1 bars including the current bar still forming), using T1 values mapped to chart bars, on the previous chart bar
Calculation: Chart bars since entry = 0 while flat; increment by 1 on each chart bar while long
Exit: Long, (exit mode selects holding-period exit AND chart bars since entry >= holding-period parameter) OR (exit mode selects retreat exit AND close(T1, current bar still forming, mapped to chart bars) <= retreat threshold) OR (exit mode selects either exit AND (chart bars since entry >= holding-period parameter OR close(T1, current bar still forming, mapped to chart bars) <= retreat threshold))
Long: VIX close one chart bar ago >= P1 AND VIX close crossed below its T1 SMA(P2) one chart bar ago
Exit: long, holding-period mode selected AND bars held >= P3
Exit: long, VIX-retreat mode selected AND VIX close <= P4
Exit: long, both-exit mode selected AND (bars held >= P3 OR VIX close <= P4)