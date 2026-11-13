Calculation: ORH, ORL = high and low of the day's opening-range bar (the bar at a fixed session-open time of day, chart timeframe); defined from that bar onward, reset each new day
Calculation: ATR = Average True Range on the chart timeframe, taken at the opening-range bar's completion and held fixed for the day
Calculation: LongLevel = ORH + ATR * k; ShortLevel = ORL - ATR * k (k is a positive sensitivity multiplier)
Long: no entry yet taken today AND ORH and ORL are defined AND bar is after the opening-range bar AND bar time is before the end-of-session cutoff AND high >= LongLevel (stop order, fills at LongLevel)
Short: no entry yet taken today AND ORH and ORL are defined AND bar is after the opening-range bar AND bar time is before the end-of-session cutoff AND low <= ShortLevel (stop order, fills at ShortLevel)
Long: ORH > ORL AND close > open of the current bar (bias marking)
Short: NOT (ORH > ORL AND close > open of the current bar) (bias marking)
Exit: long, high >= entry price + take-profit distance OR low <= entry price - stop-loss distance (take-profit distance larger than stop-loss distance)
Exit: short, low <= entry price - take-profit distance OR high >= entry price + stop-loss distance (take-profit distance larger than stop-loss distance)