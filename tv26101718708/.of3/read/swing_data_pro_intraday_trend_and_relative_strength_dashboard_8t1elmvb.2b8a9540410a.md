Calculation: TodayOpen = open of the still-forming T1 bar, taken on chart bars
Calculation: SessionVWAP = VWAP(hlc3), reset each session, on chart bars
Calculation: UDRatio = SUM(volume where close > close[1], UD lookback) / SUM(volume where close < close[1], UD lookback), on chart bars
Calculation: RVOL = if RVOL method is time-matched and chart is intraday: 100 * session volume so far / mean of session volume so far at the same time offset over the prior RVOL lookback sessions; otherwise 100 * volume / SMA(volume[1], RVOL lookback), on chart bars
Calculation: MktPlus = COUNT(true among: S&P 500 index close >= open, Nasdaq-100 index close >= open, Bitcoin close >= open, sector index close >= open), each on the still-forming T1 bar, taken on chart bars
Long: close >= TodayOpen AND close >= SessionVWAP
Long: close >= TodayOpen AND close >= SessionVWAP AND RVOL >= bull RVOL threshold AND UDRatio >= bull UD threshold
Short: close < TodayOpen AND close < SessionVWAP
Short: close < TodayOpen AND close < SessionVWAP AND RVOL >= bear RVOL threshold AND UDRatio <= bear UD threshold
Long: MktPlus >= long MktPlus threshold
Short: MktPlus < short MktPlus threshold
Calculation: PrevT1High = high of last completed T1 bar, on chart bars
Calculation: PrevT1Low = low of last completed T1 bar, on chart bars
Calculation: PreMarketHigh = highest high of chart bars in the current day's pre-market session
Calculation: PreMarketLow = lowest low of chart bars in the current day's pre-market session
Calculation: CurrT2High = high of the still-forming T2 bar containing the chart bar, on chart bars
Calculation: CurrT2Low = low of the still-forming T2 bar containing the chart bar, on chart bars
Calculation: PrevT2High = high of last completed T2 bar, on chart bars
Long: close crosses above TodayOpen
Short: close crosses below TodayOpen
Long: close crosses above PrevT1High
Short: close crosses below PrevT1High
Long: close crosses above PrevT1Low
Short: close crosses below PrevT1Low
Long: close crosses above PreMarketHigh
Short: close crosses below PreMarketHigh
Long: close crosses above PreMarketLow
Short: close crosses below PreMarketLow
Long: close crosses above SessionVWAP
Short: close crosses below SessionVWAP
Long: close crosses above CurrT2High
Short: close crosses below CurrT2High
Long: close crosses above CurrT2Low
Short: close crosses below CurrT2Low
Long: close crosses above PrevT2High
Short: close crosses below PrevT2High
Calculation: T1Body = ABS(close - open), on T1 bars
Calculation: T1Range = high - low, on T1 bars
Calculation: T1UpperWick = high - MAX(open, close), on T1 bars
Calculation: T1LowerWick = MIN(open, close) - low, on T1 bars
Calculation: BullEngulfing = on last completed T1 bar: close > open AND close[1] < open[1] AND open <= MIN(open[1], close[1]) AND close >= MAX(open[1], close[1]) AND T1Body >= engulfing body ratio * T1Body[1] AND T1Body[1] >= engulfing prior-body fraction * T1Range[1] AND T1Body >= engulfing body fraction * T1Range
Calculation: DragonflyDoji = on last completed T1 bar: T1Range > 0 AND T1Body <= doji body fraction * T1Range AND T1LowerWick >= doji lower-wick fraction * T1Range AND T1UpperWick <= doji upper-wick fraction * T1Range
Calculation: MorningStar = on last completed T1 bar: close[2] < open[2] AND T1Body[2] >= morning-star first-body fraction * T1Range[2] AND T1Body[1] <= morning-star middle-body fraction * T1Body[2] AND close > open AND close >= MIN(open[2], close[2]) + morning-star close-level fraction * T1Body[2] AND T1Body >= morning-star last-body fraction * T1Range
Calculation: PiercingLine = on last completed T1 bar: close[1] < open[1] AND T1Body[1] >= piercing first-body fraction * T1Range[1] AND open < low[1] AND close > open AND close >= MIN(open[1], close[1]) + piercing close-level fraction * T1Body[1] AND close < open[1] AND T1Body >= piercing body fraction * T1Range
Calculation: Hammer = on last completed T1 bar: T1Range > 0 AND T1Body <= hammer body fraction * T1Range AND T1LowerWick >= hammer wick multiple * T1Body AND T1UpperWick <= hammer upper-wick fraction * T1Range AND MIN(open, close) >= low + hammer body-position fraction * T1Range AND close[1] < open[1]
Calculation: BullHarami = on last completed T1 bar: close[1] < open[1] AND T1Body[1] >= harami first-body fraction * T1Range[1] AND close > open AND open > MIN(open[1], close[1]) AND close < MAX(open[1], close[1]) AND T1Body <= harami body fraction * T1Body[1]
Calculation: BullishSoldierBar = on T1 bars: close > open AND T1Body >= soldier body fraction * T1Range AND T1UpperWick <= soldier upper-wick fraction * T1Range
Calculation: ThreeWhiteSoldiers = on last completed T1 bar: BullishSoldierBar[2] AND BullishSoldierBar[1] AND BullishSoldierBar AND close[1] > close[2] AND close > close[1] AND open[1] > open[2] AND open[1] < close[2] AND open > open[1] AND open < close[1]
Long: BullEngulfing = true
Long: DragonflyDoji = true
Long: MorningStar = true
Long: PiercingLine = true
Long: Hammer = true
Long: BullHarami = true
Long: ThreeWhiteSoldiers = true
Long: COUNT(true among BullEngulfing, DragonflyDoji, MorningStar, PiercingLine, Hammer, BullHarami, ThreeWhiteSoldiers) >= multiple-pattern threshold