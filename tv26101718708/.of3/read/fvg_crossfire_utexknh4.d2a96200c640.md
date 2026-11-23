Calculation: SessionBreak = (chart is intraday AND (T1 changes at bar OR T1 changes at bar[1])) OR ((chart is intraday OR chart is T1) AND (T2 changes at bar OR T2 changes at bar[1])), where T changes at bar when the bar's forming T value differs from the T value of bar[1]
Calculation: BullFVG = low > high[2] AND (low - high[2]) / close * 100 >= minimum gap AND NOT SessionBreak AND bar is among the last window bars; range from high[2] to low
Calculation: BearFVG = high < low[2] AND (low[2] - high) / close * 100 >= minimum gap AND NOT SessionBreak AND bar is among the last window bars; range from high to low[2]
Calculation: Overlap(A, B) = max(A.bottom, B.bottom) < min(A.top, B.top); range from max(A.bottom, B.bottom) to min(A.top, B.top)
Calculation: Contact(Z) = high >= Z.bottom AND low <= Z.top
Calculation: LiveZone = crossfire zone created or flipped on an earlier bar and not yet flipped or mitigated; direction = direction of its creating or flipping FVG; range = creating or flipping overlap, widened by each creation overlap merged into it when merge option is on
Calculation: BullBase = BullFVG stored on its bar unless it overlaps a bearish LiveZone or a BearBase; at its bar top = low and bottom = high[2]; on each bar more than delay bars after its bar, top = max(min(top, fill[delay]), bottom), where fill = low if fill wick mode, else close; removed when a BearFVG overlaps it or top <= bottom
Calculation: BearBase = BearFVG stored on its bar unless it overlaps a bullish LiveZone or a BullBase; at its bar top = low[2] and bottom = high; on each bar more than delay bars after its bar, bottom = min(max(bottom, fill[delay]), top), where fill = high if fill wick mode, else close; removed when a BullFVG overlaps it or top <= bottom
Long: BullFVG AND exists BearBase B such that Overlap(B, BullFVG) AND NOT (merge option AND the range of Overlap(B, BullFVG) overlaps a bullish LiveZone)
Long: BullFVG AND exists bearish LiveZone Z such that Overlap(Z, BullFVG)
Long: exists bullish LiveZone Z such that Contact(Z) AND NOT (Z was created or flipped before bar[1] AND Contact(Z)[1]) AND NOT (BearFVG AND Overlap(Z, BearFVG))
Short: BearFVG AND exists BullBase B such that Overlap(B, BearFVG) AND NOT (merge option AND the range of Overlap(B, BearFVG) overlaps a bearish LiveZone)
Short: BearFVG AND exists bullish LiveZone Z such that Overlap(Z, BearFVG)
Short: exists bearish LiveZone Z such that Contact(Z) AND NOT (Z was created or flipped before bar[1] AND Contact(Z)[1]) AND NOT (BullFVG AND Overlap(Z, BullFVG))
Exit: Long, exists bullish LiveZone Z such that NOT (BearFVG AND Overlap(Z, BearFVG)) AND (low if zone wick mode, else close) <= Z.bottom
Exit: Short, exists bearish LiveZone Z such that NOT (BullFVG AND Overlap(Z, BullFVG)) AND (high if zone wick mode, else close) >= Z.top