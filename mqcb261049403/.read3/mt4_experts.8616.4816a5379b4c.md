Calculation: selected high = high(P_H bars ago, T2, current forming bar if P_H is zero, otherwise last completed bar), sampled on chart bars
Calculation: selected low = low(P_L bars ago, T2, current forming bar if P_L is zero, otherwise last completed bar), sampled on chart bars
Calculation: range = selected high - selected low
Calculation: high precedes low = datetime(selected high bar) < datetime(selected low bar)
Calculation: high-first lower level = selected low + range × P1
Calculation: high-first upper level = selected low + range × P2
Calculation: low-first lower level = selected high - range × P4
Calculation: low-first upper level = selected high - range × P3
Calculation: reference low = low(P_SR bars ago, T1, current forming bar if P_SR is zero, otherwise last completed bar), sampled on chart bars
Calculation: reference high = high(P_SR bars ago, T1, current forming bar if P_SR is zero, otherwise last completed bar), sampled on chart bars
Long: high precedes low AND close < high-first lower level
Long: NOT high precedes low AND close < low-first lower level
Short: high precedes low AND close > high-first upper level
Short: NOT high precedes low AND close > low-first upper level
Long: close > EMA(close, P_MA, T1, current forming bar) AND ((high precedes low AND close > high-first lower level AND close < high-first upper level) OR (NOT high precedes low AND close > low-first lower level AND close < low-first upper level)) AND close > reference high
Long: close > EMA(close, P_MA, T1, current forming bar) AND NOT high precedes low AND close < low-first lower level AND close < reference high
Long: close < EMA(close, P_MA, T1, current forming bar) AND high precedes low AND close < high-first lower level AND close < reference high
Short: close > EMA(close, P_MA, T1, current forming bar) AND NOT high precedes low AND close > low-first upper level AND close < reference high
Short: close < EMA(close, P_MA, T1, current forming bar) AND ((high precedes low AND close > high-first lower level AND close < high-first upper level) OR (NOT high precedes low AND close > low-first lower level AND close < low-first upper level)) AND close < reference low
Short: close < EMA(close, P_MA, T1, current forming bar) AND high precedes low AND close > high-first upper level AND close < reference high
Exit: long, close < reference low
Exit: short, close > reference high