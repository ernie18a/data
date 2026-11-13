Calculation: LowBar = volume > previous bar volume AND low < previous bar low
Calculation: HighBar = volume > previous bar volume AND high > previous bar high
Calculation: SwingLow active = LowBar true on the current bar and the two preceding bars; SwingHigh active = same with HighBar
Calculation: ConfirmedSwingLow = SwingLow not active on the current bar AND SwingLow active on the previous bar; ConfirmedSwingHigh = same with SwingHigh
Calculation: SwingLowRegion of a run = [bottom = lowest low, top = highest high] over all bars of the consecutive SwingLow-active run, including the two bars preceding its first active bar; SwingHighRegion likewise with SwingHigh runs
Calculation: DailyLowRegion = within the current calendar day, the SwingLowRegion with the lowest bottom among runs confirmed so far (a run active at the day's first bar, or ended on the previous day's last bar, counts); na if none. DailyHighRegion = the SwingHighRegion with the highest top among runs confirmed so far, same rules
Calculation: PrevLowRegion / PrevHighRegion = final DailyLowRegion / DailyHighRegion of the previous day; PrevLowRegion2 / PrevHighRegion2 = those of the day before the previous day
Long: ConfirmedSwingLow
Long: PrevHighRegion.top > PrevHighRegion2.top
Long: (previous bar open < PrevHighRegion.bottom AND previous bar close >= PrevHighRegion.bottom) OR (previous bar open < DailyHighRegion.bottom AND previous bar close >= DailyHighRegion.bottom)
Short: ConfirmedSwingHigh
Short: PrevLowRegion.bottom < PrevLowRegion2.bottom
Short: (previous bar open > PrevLowRegion.top AND previous bar close <= PrevLowRegion.top) OR (previous bar open > DailyLowRegion.top AND previous bar close <= DailyLowRegion.top)