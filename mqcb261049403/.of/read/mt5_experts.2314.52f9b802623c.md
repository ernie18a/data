Calculation: Rising sequence = for every one of a configurable number of consecutive bars ending at the signal bar, both high and low are strictly greater than those of the preceding bar.
Calculation: Falling sequence = for every one of the same number of consecutive bars ending at the signal bar, both high and low are strictly less than those of the preceding bar.
Calculation: Signal bar = a configurable bar offset on the chart timeframe or a configurable higher or lower timeframe; offset zero uses the forming bar, and a positive offset uses a completed bar.
Long: Rising sequence at the signal bar.
Short: Falling sequence at the signal bar.
Exit: long, the most recent rising or falling sequence at or before the signal bar is a falling sequence OR low <= entry price minus the enabled stop-loss distance OR high >= entry price plus the enabled take-profit distance.
Exit: short, the most recent rising or falling sequence at or before the signal bar is a rising sequence OR high >= entry price plus the enabled stop-loss distance OR low <= entry price minus the enabled take-profit distance.