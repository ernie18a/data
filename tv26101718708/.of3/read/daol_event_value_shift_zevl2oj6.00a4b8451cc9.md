Calculation: VWAP = AnchoredVWAP(HLC3, volume, anchor), where anchor is the first chart bar of each T1 period or a selected time
Calculation: Distance = (close - VWAP) / ATR(atr period)[1]
Calculation: Displacement = (VWAP - VWAP[shift lookback]) / ATR(atr period)[1], NA if VWAP[shift lookback] precedes the current anchor
Calculation: Class = NA if Distance or Displacement is NA; else 3 if (Distance >= min distance AND Displacement <= -min displacement) OR (Distance <= -min distance AND Displacement >= min displacement); else 1 if Distance >= min distance AND Displacement >= min displacement; else -1 if Distance <= -min distance AND Displacement <= -min displacement; else 2 if |Distance| >= min distance; else 0
Calculation: Trigger = Class[0] through Class[confirm bars - 1] are all non-NA and equal
Calculation: Confirmed = 0 if Class is NA; else Class if Trigger; else Confirmed[1]
Calculation: Transition = Trigger AND Confirmed != Confirmed[1] AND Trigger occurred on an earlier bar since the current anchor
Long: Class = 1
Long: Confirmed = 1
Long: Transition AND Confirmed = 1
Short: Class = -1
Short: Confirmed = -1
Short: Transition AND Confirmed = -1