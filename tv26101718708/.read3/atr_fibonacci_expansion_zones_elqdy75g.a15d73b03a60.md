Calculation: PeriodHigh = highest high of chart bars from the start of the T1 period containing the current bar through the current bar
Calculation: PeriodLow = lowest low of chart bars from the start of the T1 period containing the current bar through the current bar
Calculation: BarsSincePeriodHigh = bars since the earliest chart bar of that T1 period whose high equals PeriodHigh
Calculation: BarsSincePeriodLow = bars since the earliest chart bar of that T1 period whose low equals PeriodLow
Calculation: PeriodMid = (PeriodHigh + PeriodLow) / 2
Long: PeriodHigh > PeriodLow AND (BarsSincePeriodHigh < BarsSincePeriodLow OR (BarsSincePeriodHigh = BarsSincePeriodLow AND close >= PeriodMid))
Short: PeriodHigh > PeriodLow AND (BarsSincePeriodLow < BarsSincePeriodHigh OR (BarsSincePeriodHigh = BarsSincePeriodLow AND close < PeriodMid))
Long: close >= open
Short: close < open