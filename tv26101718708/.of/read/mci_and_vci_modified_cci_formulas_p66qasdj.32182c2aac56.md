Calculation: OBV = cumulative sum of volume when ohlc4 rises from the prior bar, minus volume when ohlc4 falls; add zero when unchanged
Calculation: Rolling mean(x, L) = sum of x over the last L bars / L
Calculation: Recursive median(x, L) = initialize r to current x; for each offset i from 0 through L, set r to current x if r equals zero, otherwise set r to (r + x[i]) / 2
Calculation: MCI = (close - EMA(close, L)) / AMDA / interval, where AMDA = (abs(stdev(Recursive median(EMA(close, L), L), B)) + abs(stdev(Rolling mean(EMA(close, L), L), B))) / 2
Calculation: VCI = (OBV - EMA(OBV, L)) / AMDV / interval, where AMDV = (abs(stdev(Recursive median(SMA(OBV, L), L), B)) + abs(stdev(Rolling mean(SMA(OBV, L), L), B))) / 2; MCI and VCI use the same L, B, and interval parameters
Long: MCI crosses above 0 AND current VCI > MCI from two bars earlier
Short: MCI crosses below 0 AND current VCI < MCI from two bars earlier