Calculation: MitigationClose(tf) = close of the last completed tf bar if chart timeframe < tf, otherwise close of the current chart bar
Calculation: BullFVG(tf) = low(tf)[1] > high(tf)[3], evaluated on the first chart bar of each new tf bar, where [n] = n-th last completed tf bar; bottom = high(tf)[3], top = low(tf)[1]
Calculation: BearFVG(tf) = high(tf)[1] < low(tf)[3], evaluated on the first chart bar of each new tf bar, where [n] = n-th last completed tf bar; bottom = high(tf)[1], top = low(tf)[3]
Calculation: LiveBullFVG(tf) = BullFVG(tf) formed at bar s, where at the current bar age <= expiry(tf), MitigationClose(tf) >= bottom on every bar from s to the previous bar, no LiveBearIFVG(tf) overlaps it on any bar from s to the previous bar, and if tf is T3, no LiveBullFVG(T4) overlaps it on any bar from s to the current bar
Calculation: LiveBearFVG(tf) = BearFVG(tf) formed at bar s, where at the current bar age <= expiry(tf), MitigationClose(tf) <= top on every bar from s to the previous bar, no LiveBullIFVG(tf) overlaps it on any bar from s to the previous bar, and if tf is T3, no LiveBearFVG(T4) overlaps it on any bar from s to the current bar
Calculation: LiveBullIFVG(tf) = bullish IFVG created at bar s from a LiveBearFVG(tf) with MitigationClose(tf) > its top at s, with the same range as that FVG, where at the current bar age <= expiry(tf), MitigationClose(tf) >= bottom on every bar from s to the previous bar, no LiveBearFVG(tf) overlaps it on any bar from s to the previous bar, and if tf is T3, no LiveBullIFVG(T4) overlaps it on any bar from s to the current bar
Calculation: LiveBearIFVG(tf) = bearish IFVG created at bar s from a LiveBullFVG(tf) with MitigationClose(tf) < its bottom at s, with the same range as that FVG, where at the current bar age <= expiry(tf), MitigationClose(tf) <= top on every bar from s to the previous bar, no LiveBullFVG(tf) overlaps it on any bar from s to the previous bar, and if tf is T3, no LiveBearIFVG(T4) overlaps it on any bar from s to the current bar
Long: BullFVG(T1) AND chart timeframe <= T1
Long: BullFVG(T2)
Long: BullFVG(T3) AND chart timeframe <= T3 AND no LiveBullFVG(T4) overlaps it
Long: BullFVG(T4) AND chart timeframe <= T4
Long: MitigationClose(T1) > top of some LiveBearFVG(T1) AND chart timeframe <= T1
Long: MitigationClose(T2) > top of some LiveBearFVG(T2)
Long: MitigationClose(T3) > top of some LiveBearFVG(T3) AND chart timeframe <= T3 AND no LiveBullIFVG(T4) overlaps that FVG's range
Long: MitigationClose(T4) > top of some LiveBearFVG(T4) AND chart timeframe <= T4
Short: BearFVG(T1) AND chart timeframe <= T1
Short: BearFVG(T2)
Short: BearFVG(T3) AND chart timeframe <= T3 AND no LiveBearFVG(T4) overlaps it
Short: BearFVG(T4) AND chart timeframe <= T4
Short: MitigationClose(T1) < bottom of some LiveBullFVG(T1) AND chart timeframe <= T1
Short: MitigationClose(T2) < bottom of some LiveBullFVG(T2)
Short: MitigationClose(T3) < bottom of some LiveBullFVG(T3) AND chart timeframe <= T3 AND no LiveBearIFVG(T4) overlaps that FVG's range
Short: MitigationClose(T4) < bottom of some LiveBullFVG(T4) AND chart timeframe <= T4