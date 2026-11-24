Calculation: CPR upper(bar) = max((high + low) / 2, 2 * (high + low + close) / 3 - (high + low) / 2)
Calculation: CPR lower(bar) = min((high + low) / 2, 2 * (high + low + close) / 3 - (high + low) / 2)
Long: on chart bars, close(T1, current bar) > CPR upper(T1)[1]
Long: on chart bars, bias mode = pair mode AND close(broad market index, last completed chart bar) > CPR upper(T1 of broad market index)[1] AND close(banking index, last completed chart bar) > CPR upper(T1 of banking index)[1]
Long: on chart bars, close(T2, current bar) > CPR upper(T2)[1]
Long: on chart bars, close(T3, current bar) > CPR upper(T3)[1]
Long: on chart bars, close(current chart bar) > classic pivot R1(T1)[1]
Long: on chart bars, open(T1, current bar) > classic pivot R1(T1)[1]
Long: on chart bars, chart timeframe shorter than T1 AND close(current chart bar) >= VWAP(source, anchored at start of current T1 bar)
Long: on chart bars, CPR lower(T1)[2] < CPR lower(T1)[1] AND CPR upper(T1)[2] < CPR upper(T1)[1] AND CPR lower(T1)[2] < CPR upper(T1)[1] AND (CPR lower(T1)[3] <= CPR lower(T1)[2] OR CPR upper(T1)[3] <= CPR upper(T1)[2])
Long: on chart bars, CPR lower(T1)[3] > CPR lower(T1)[2] AND CPR upper(T1)[3] > CPR upper(T1)[2] AND CPR lower(T1)[2] < CPR lower(T1)[1] AND CPR upper(T1)[2] < CPR upper(T1)[1]
Short: on chart bars, close(T1, current bar) < CPR lower(T1)[1]
Short: on chart bars, bias mode = pair mode AND close(broad market index, last completed chart bar) < CPR lower(T1 of broad market index)[1] AND close(banking index, last completed chart bar) < CPR lower(T1 of banking index)[1]
Short: on chart bars, close(T2, current bar) < CPR lower(T2)[1]
Short: on chart bars, close(T3, current bar) < CPR lower(T3)[1]
Short: on chart bars, close(current chart bar) < classic pivot S1(T1)[1]
Short: on chart bars, open(T1, current bar) < classic pivot S1(T1)[1]
Short: on chart bars, chart timeframe shorter than T1 AND close(current chart bar) < VWAP(source, anchored at start of current T1 bar)
Short: on chart bars, CPR lower(T1)[2] > CPR lower(T1)[1] AND CPR upper(T1)[2] > CPR upper(T1)[1] AND CPR lower(T1)[2] > CPR upper(T1)[1]
Short: on chart bars, CPR lower(T1)[3] < CPR lower(T1)[2] AND CPR upper(T1)[3] < CPR upper(T1)[2] AND CPR lower(T1)[2] > CPR lower(T1)[1] AND CPR upper(T1)[2] > CPR upper(T1)[1] AND CPR lower(T1)[2] > CPR upper(T1)[2]