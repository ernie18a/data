Calculation: Last pivot high = most recent non-NA PivotHigh(high, pivot lookback, pivot lookback), or current high if none
Calculation: Last pivot low = most recent non-NA PivotLow(low, pivot lookback, pivot lookback), or current low if none
Calculation: Origin body mid = (open + close) / 2
Calculation: Prior range mid = (Last pivot high + Last pivot low) / 2
Calculation: Reclaim boundary(side, L) = Origin body mid when boundary mode is origin body mid; Prior range mid when boundary mode is prior range mid; Last pivot low when boundary mode is last internal swing and side is bullish; Last pivot high when boundary mode is last internal swing and side is bearish; otherwise Prior range mid when a PivotHigh and a PivotLow have both been confirmed and Prior range mid is above L when side is bullish or below L when side is bearish, else Origin body mid
Calculation: Bullish sweep(L) = Low < L - sweep penetration * ATR(atr lookback) AND Close > L AND Close > Reclaim boundary(bullish, L)
Calculation: Bearish sweep(L) = High > L + sweep penetration * ATR(atr lookback) AND Close < L AND Close < Reclaim boundary(bearish, L)
Calculation: Session end = bar is outside session window AND previous bar is inside session window
Calculation: Session high = highest high of in-session bars since the last session start
Calculation: Session low = lowest low of in-session bars since the last session start
Long: Bullish sweep(Last pivot low)
Long: session sweep detection enabled AND Session end AND Bullish sweep(Session low)
Long: Bullish sweep(Last pivot low)[observation window]
Long: session sweep detection enabled AND Session end[observation window] AND Bullish sweep(Session low)[observation window]
Short: Bearish sweep(Last pivot high)
Short: session sweep detection enabled AND Session end AND Bearish sweep(Session high)
Short: Bearish sweep(Last pivot high)[observation window]
Short: session sweep detection enabled AND Session end[observation window] AND Bearish sweep(Session high)[observation window]