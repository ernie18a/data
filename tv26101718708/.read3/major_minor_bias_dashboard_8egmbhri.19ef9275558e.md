Calculation: Major upper boundary(T) = max(EMA(close, fast (shorter) lookback for T, T, current possibly-forming bar), EMA(close, slow (longer) lookback for T, T, current possibly-forming bar)) + (major ATR buffer enabled ? ATR(major ATR lookback, T, current possibly-forming bar) * major ATR multiplier : 0), evaluated on chart bars from current T values; T1 and T2 have separate fast and slow lookbacks and share the major ATR parameters
Calculation: Major lower boundary(T) = min(EMA(close, fast (shorter) lookback for T, T, current possibly-forming bar), EMA(close, slow (longer) lookback for T, T, current possibly-forming bar)) - (major ATR buffer enabled ? ATR(major ATR lookback, T, current possibly-forming bar) * major ATR multiplier : 0), evaluated on chart bars from current T values; T1 and T2 have separate fast and slow lookbacks and share the major ATR parameters
Calculation: Minor upper boundary(T3) = max(EMA(close, fast (shorter) lookback, T3, current possibly-forming bar), EMA(close, slow (longer) lookback, T3, current possibly-forming bar)) + (minor ATR buffer enabled ? ATR(minor ATR lookback, T3, current possibly-forming bar) * minor ATR multiplier : 0), evaluated on chart bars from current T3 values
Calculation: Minor lower boundary(T3) = min(EMA(close, fast (shorter) lookback, T3, current possibly-forming bar), EMA(close, slow (longer) lookback, T3, current possibly-forming bar)) - (minor ATR buffer enabled ? ATR(minor ATR lookback, T3, current possibly-forming bar) * minor ATR multiplier : 0), evaluated on chart bars from current T3 values
Calculation: Mini upper boundary(T4) = max(EMA(close, fast (shorter) lookback, T4, current possibly-forming bar), EMA(close, slow (longer) lookback, T4, current possibly-forming bar)) + (mini ATR buffer enabled ? ATR(mini ATR lookback, T4, current possibly-forming bar) * mini ATR multiplier : 0), evaluated on chart bars from current T4 values
Calculation: Mini lower boundary(T4) = min(EMA(close, fast (shorter) lookback, T4, current possibly-forming bar), EMA(close, slow (longer) lookback, T4, current possibly-forming bar)) - (mini ATR buffer enabled ? ATR(mini ATR lookback, T4, current possibly-forming bar) * mini ATR multiplier : 0), evaluated on chart bars from current T4 values
Calculation: Previous-day midpoint = (high of last completed T1 bar + low of last completed T1 bar) / 2, carried to chart bars
Calculation: Opening-range midpoint = (maximum chart-bar high during the configured session + minimum chart-bar low during the configured session) / 2, available after that session ends
Long: T1 close > Major upper boundary(T1)
Short: T1 close < Major lower boundary(T1)
Long: T2 close > Major upper boundary(T2)
Short: T2 close < Major lower boundary(T2)
Long: previous-day filter enabled AND current chart close > previous-day midpoint (if selected) AND current chart close > previous T1 close (if selected)
Short: previous-day filter enabled AND current chart close < previous-day midpoint (if selected) AND current chart close < previous T1 close (if selected)
Long: T3 close > Minor upper boundary(T3)
Short: T3 close < Minor lower boundary(T3)
Long: VWAP filter enabled AND current chart close > session VWAP(hlc3)
Short: VWAP filter enabled AND current chart close < session VWAP(hlc3)
Long: opening-range filter enabled AND opening range ready AND current chart close > opening-range midpoint
Short: opening-range filter enabled AND opening range ready AND current chart close < opening-range midpoint
Long: T1 close > Major upper boundary(T1) AND T2 close > Major upper boundary(T2) AND (previous-day filter disabled OR (current chart close > previous-day midpoint if selected AND current chart close > previous T1 close if selected))
Short: T1 close < Major lower boundary(T1) AND T2 close < Major lower boundary(T2) AND (previous-day filter disabled OR (current chart close < previous-day midpoint if selected AND current chart close < previous T1 close if selected))
Long: T3 close > Minor upper boundary(T3) AND (VWAP filter disabled OR current chart close > session VWAP(hlc3)) AND (opening-range filter disabled OR (opening range ready AND current chart close > opening-range midpoint))
Short: T3 close < Minor lower boundary(T3) AND (VWAP filter disabled OR current chart close < session VWAP(hlc3)) AND (opening-range filter disabled OR (opening range ready AND current chart close < opening-range midpoint))
Long: T1 close > Major upper boundary(T1) AND T2 close > Major upper boundary(T2) AND (previous-day filter disabled OR (current chart close > previous-day midpoint if selected AND current chart close > previous T1 close if selected)) AND T3 close > Minor upper boundary(T3) AND (VWAP filter disabled OR current chart close > session VWAP(hlc3)) AND (opening-range filter disabled OR (opening range ready AND current chart close > opening-range midpoint))
Short: T1 close < Major lower boundary(T1) AND T2 close < Major lower boundary(T2) AND (previous-day filter disabled OR (current chart close < previous-day midpoint if selected AND current chart close < previous T1 close if selected)) AND T3 close < Minor lower boundary(T3) AND (VWAP filter disabled OR current chart close < session VWAP(hlc3)) AND (opening-range filter disabled OR (opening range ready AND current chart close < opening-range midpoint))
Long: T4 close > Mini upper boundary(T4)
Short: T4 close < Mini lower boundary(T4)
Long: mini bias enabled AND T4 close > Mini upper boundary(T4) AND (mini VWAP filter disabled OR T4 close > session VWAP(hlc3))
Short: mini bias enabled AND T4 close < Mini lower boundary(T4) AND (mini VWAP filter disabled OR T4 close < session VWAP(hlc3))
Long: mini bias enabled AND T4 close > Mini upper boundary(T4) AND (mini VWAP filter disabled OR T4 close > session VWAP(hlc3)) AND mini bias was not Long on the previous chart bar
Short: mini bias enabled AND T4 close < Mini lower boundary(T4) AND (mini VWAP filter disabled OR T4 close < session VWAP(hlc3)) AND mini bias was not Short on the previous chart bar