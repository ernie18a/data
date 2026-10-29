Calculation: Raw lower stop = highest high over the ATR lookback minus the ATR multiplier times ATR; ratchet it upward while trend is up by taking the greater of the raw lower stop and the prior lower stop.
Calculation: Raw upper stop = lowest low over the ATR lookback plus the ATR multiplier times ATR; ratchet it downward while trend is down by taking the lesser of the raw upper stop and the prior upper stop.
Calculation: Chandelier trend = up when close is above the prior upper stop, down when close is below the prior lower stop, otherwise retain the prior trend.
Long: Chandelier trend changes from down to up
Short: Chandelier trend changes from up to down
Long: On a configured timeframe higher or lower than the chart timeframe, the last completed bar has an active lower stop
Short: On a configured timeframe higher or lower than the chart timeframe, the last completed bar has an active upper stop