Calculation: Gap(T, M) = on T bars, 1 if low > high[2] and (low - high[2]) / tick >= M; -1 if high < low[2] and (low[2] - high) / tick >= M; otherwise 0
Calculation: Zone(T, M) = [top, bottom] of the current T bar's gap, used when Gap(T, M) is not 0; body top = max(open, close), body bottom = min(open, close); if Gap(T, M) = 1: top = min(open, close) if min(open, close) >= max(open, close)[1] - tick, otherwise low; bottom = max(open, close)[2] if min(open, close)[1] >= max(open, close)[2] - tick, otherwise high[2]; if Gap(T, M) = -1: top = min(open, close)[2] if max(open, close)[1] <= min(open, close)[2] + tick, otherwise low[2]; bottom = max(open, close) if max(open, close) <= min(open, close)[1] + tick, otherwise high
Calculation: OpeningGap(T, P) = on T bars, within the current P period: from the bar whose open time is at the reopen clock time in the reopen time zone onward, the range [max(open, close[1]), min(open, close[1])] of that bar if max - min >= tick; none before that bar, and none if that range is narrower than tick
Calculation: ParentFirstGap(T, P, M) = on T bars, 0 until, within the current P period, the first bar t such that Gap(T, M) is not 0, bar t-1 is in the same P period as bar t, and either OpeningGap(T, P) at t is none or min(top, opening top) - max(bottom, opening bottom) < tick, where top and bottom are Zone(T, M) at t and opening top and bottom are OpeningGap(T, P) at t; from bar t to the end of the P period it equals Gap(T, M) of bar t; chart bars take the value of the last completed T bar
Calculation: SessionFirstGap(T, W, M) = on T bars, 0 until, within the current run of consecutive bars inside window W, the first bar t where Gap(T, M) is not 0; from bar t to the end of the run it equals Gap(T, M) of bar t; chart bars take the value of the last completed T bar
Calculation: MacroWindowActive = the bar's clock time in the macro time zone lies in any macro window, where a macro window spans its start to its end, and wraps past midnight when its end is not after its start
Long: ParentFirstGap(T1, T2, MA(T1)) = 1 AND ParentFirstGap(T1, T2, MA(T1))[1] = 0
Short: ParentFirstGap(T1, T2, MA(T1)) = -1 AND ParentFirstGap(T1, T2, MA(T1))[1] = 0
Long: ParentFirstGap(T3, T4, MH1) = 1 AND ParentFirstGap(T3, T4, MH1)[1] = 0 AND chart timeframe <= T10
Short: ParentFirstGap(T3, T4, MH1) = -1 AND ParentFirstGap(T3, T4, MH1)[1] = 0 AND chart timeframe <= T10
Long: ParentFirstGap(T5, T6, MH2) = 1 AND ParentFirstGap(T5, T6, MH2)[1] = 0 AND chart timeframe <= T11
Short: ParentFirstGap(T5, T6, MH2) = -1 AND ParentFirstGap(T5, T6, MH2)[1] = 0 AND chart timeframe <= T11
Long: ParentFirstGap(T4, T8, MH3) = 1 AND ParentFirstGap(T4, T8, MH3)[1] = 0 AND chart timeframe <= T12
Short: ParentFirstGap(T4, T8, MH3) = -1 AND ParentFirstGap(T4, T8, MH3)[1] = 0 AND chart timeframe <= T12
Long: ParentFirstGap(T6, T9, MH4) = 1 AND ParentFirstGap(T6, T9, MH4)[1] = 0 AND chart timeframe < T6
Short: ParentFirstGap(T6, T9, MH4) = -1 AND ParentFirstGap(T6, T9, MH4)[1] = 0 AND chart timeframe < T6
Long: SessionFirstGap(T7, WAM, MS) = 1 AND SessionFirstGap(T7, WAM, MS)[1] = 0 AND chart timeframe <= T3
Short: SessionFirstGap(T7, WAM, MS) = -1 AND SessionFirstGap(T7, WAM, MS)[1] = 0 AND chart timeframe <= T3
Long: SessionFirstGap(T7, WPM, MS) = 1 AND SessionFirstGap(T7, WPM, MS)[1] = 0 AND chart timeframe <= T3
Short: SessionFirstGap(T7, WPM, MS) = -1 AND SessionFirstGap(T7, WPM, MS)[1] = 0 AND chart timeframe <= T3
Long: close >= open AND MacroWindowActive AND chart timeframe = T7
Short: close < open AND MacroWindowActive AND chart timeframe = T7