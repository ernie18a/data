Calculation: Smoothed FATL = apply a configurable smoother to the 39-bar FATL digital filter of a selected price derived from open, high, low, and close, on the configured indicator timeframe.
Calculation: Smoothed SATL = apply a configurable smoother to the 65-bar SATL digital filter of the same selected price, on the configured indicator timeframe.
Long: Smoothed FATL on the preceding completed indicator-timeframe bar <= Smoothed SATL on that bar AND Smoothed FATL on the latest completed indicator-timeframe bar > Smoothed SATL on that bar
Short: Smoothed FATL on the preceding completed indicator-timeframe bar >= Smoothed SATL on that bar AND Smoothed FATL on the latest completed indicator-timeframe bar < Smoothed SATL on that bar
Exit: long, Smoothed FATL on the latest completed indicator-timeframe bar < Smoothed SATL on that bar
Exit: short, Smoothed FATL on the latest completed indicator-timeframe bar > Smoothed SATL on that bar