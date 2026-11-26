Calculation: PriorHigh = high of last completed T1 bar, on chart bars
Calculation: PriorLow = low of last completed T1 bar, on chart bars
Calculation: ZoneHalf = zone multiple * ATR(ATR length), evaluated on the first chart bar of each T1 bar and held for that T1 bar
Calculation: TouchesHigh = high >= PriorHigh - ZoneHalf AND low <= PriorHigh + ZoneHalf
Calculation: TouchesLow = high >= PriorLow - ZoneHalf AND low <= PriorLow + ZoneHalf
Calculation: NearestTouch = the touched one of PriorHigh and PriorLow closest to close (PriorHigh on tie), or none if neither is touched
Calculation: AbsorptionBar = volume > SMA(volume, volume lookback)[1] * volume multiple AND (small-body test on AND high - low > 0 AND abs(close - open) <= (high - low) * body fraction OR small-body test off AND high - low < SMA(high - low, range lookback)[1] * range multiple) AND (TouchesHigh OR TouchesLow OR level filter off)
Calculation: ClusterStart = AbsorptionBar AND NOT (NearestTouch is a level AND NearestTouch = NearestTouch at the last ClusterStart bar before this bar AND bars since the last AbsorptionBar before this bar <= cluster gap)
Calculation: NewLowTouch = TouchesLow AND NOT (bars since the last TouchesLow bar before this bar <= cluster gap AND PriorLow = PriorLow at that bar)
Calculation: StopLevel = PriorLow - ZoneHalf - stop buffer * ATR(ATR length)
Calculation: RegularHours = time of datetime in session time zone >= session start AND < session end
Long: ((ClusterStart[1] AND NearestTouch[1] = PriorLow[1]) OR (NewLowTouch[1] AND NOT AbsorptionBar[1])) AND RegularHours[1] AND RegularHours AND open - StopLevel[1] >= min risk * ATR(ATR length)[1] AND open <= PriorLow[1] + max chase * ATR(ATR length)[1]
Exit: long, low <= StopLevel at the bar before entry OR high >= entry price + target multiple * (entry price - StopLevel at the bar before entry) OR bars since entry, counting entry bar, >= horizon length