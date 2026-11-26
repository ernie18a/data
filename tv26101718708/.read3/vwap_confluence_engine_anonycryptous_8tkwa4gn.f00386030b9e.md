Calculation: VWRSI(bars) = 100 - 100 / (1 + RMA(max(close - close[1], 0) * volume / SMA(volume, volume smoothing length), RSI length) / RMA(max(close[1] - close, 0) * volume / SMA(volume, volume smoothing length), RSI length))
Calculation: BullState = close > VWAP(hlc3, volume, anchor period) AND VWRSI(chart bars) > RSI midline AND (NOT MFI confirmation enabled OR MFI(hlc3, volume, MFI length) > MFI midline) AND (NOT HTF filter enabled OR (close > VWAP(hlc3, volume, session anchor, T1 bars, last completed bar) AND VWRSI(T1 bars, last completed bar) > HTF RSI midline))
Calculation: BearState = close < VWAP(hlc3, volume, anchor period) AND VWRSI(chart bars) < RSI midline AND (NOT MFI confirmation enabled OR MFI(hlc3, volume, MFI length) < MFI midline) AND (NOT HTF filter enabled OR (close < VWAP(hlc3, volume, session anchor, T1 bars, last completed bar) AND VWRSI(T1 bars, last completed bar) < HTF RSI midline))
Calculation: Neutral = NOT BullState AND NOT BearState
Calculation: BullDivergence(pivot window) = PivotLow(VWRSI, pivot window, pivot window) is not NA AND VWRSI[pivot window] > VWRSI at the bar of the previous PivotLow AND low[pivot window] < low at the bar of the previous PivotLow
Calculation: BearDivergence(pivot window) = PivotHigh(VWRSI, pivot window, pivot window) is not NA AND VWRSI[pivot window] < VWRSI at the bar of the previous PivotHigh AND high[pivot window] > high at the bar of the previous PivotHigh
Calculation: BullDivergenceHeld(pivot window, hold length) = count(BullDivergence(pivot window) over the last hold length bars, including this bar) > 0
Calculation: BearDivergenceHeld(pivot window, hold length) = count(BearDivergence(pivot window) over the last hold length bars, including this bar) > 0
Calculation: MtfBull(Tk) = close(Tk bars, last completed bar) > VWAP(hlc3, volume, session anchor, Tk bars, last completed bar) AND VWRSI(Tk bars, last completed bar) > MTF RSI midline
Calculation: MtfBear(Tk) = close(Tk bars, last completed bar) < VWAP(hlc3, volume, session anchor, Tk bars, last completed bar) AND VWRSI(Tk bars, last completed bar) < MTF RSI midline
Long: BullState
Long: BullState AND NOT BullState[1]
Long: BullDivergence(pivot window)
Long: BullDivergenceHeld(pivot window, hold length)
Long: MtfBull(T3)
Long: MtfBull(T4)
Long: MtfBull(T5)
Long: MtfBull(T6)
Long: MtfBull(T7)
Long: MtfBull(T8)
Long: close > VWAP(hlc3, volume, session anchor, T2 bars, last completed bar) AND VWRSI(T2 bars, last completed bar) > RSI midline
Short: BearState
Short: BearState AND NOT BearState[1]
Short: BearDivergence(pivot window)
Short: BearDivergenceHeld(pivot window, hold length) AND NOT BullDivergenceHeld(pivot window, hold length)
Short: MtfBear(T3)
Short: MtfBear(T4)
Short: MtfBear(T5)
Short: MtfBear(T6)
Short: MtfBear(T7)
Short: MtfBear(T8)
Short: close < VWAP(hlc3, volume, session anchor, T2 bars, last completed bar) AND VWRSI(T2 bars, last completed bar) < RSI midline
Exit: long, Neutral
Exit: long, Neutral AND NOT Neutral[1]
Exit: short, Neutral
Exit: short, Neutral AND NOT Neutral[1]