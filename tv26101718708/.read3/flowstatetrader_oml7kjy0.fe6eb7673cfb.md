Calculation: ATR = ATR(atr period)
Calculation: AvgVolume = SMA(volume, atr period)
Calculation: LowestLow = Lowest(low, lookback)
Calculation: HighestHigh = Highest(high, lookback)
Calculation: TrendMA = MA(close, trend period, trend MA type)
Calculation: UptrendOK = trend filter off OR close > TrendMA
Calculation: DowntrendOK = trend filter off OR close < TrendMA
Calculation: LocalHour = (hour of datetime in UTC + zone UTC offset) mod 24
Calculation: IsWeekend = datetime falls on Saturday or Sunday
Calculation: TradingTimeOK = time filter off OR ((LocalHour from start hour to end hour inclusive, wrapping past midnight when start hour > end hour) AND NOT (avoid lunch on AND LocalHour >= lunch start hour AND LocalHour < lunch end hour) AND (weekends only off OR IsWeekend) AND (weekdays only off OR NOT IsWeekend))
Calculation: LongTP1 = LowestLow + ATR * reward-to-risk ratio * TP1 multiplier
Calculation: LongTP2 = LowestLow + ATR * reward-to-risk ratio * TP2 multiplier
Calculation: ShortTP1 = HighestHigh - ATR * reward-to-risk ratio * TP1 multiplier
Calculation: ShortTP2 = HighestHigh - ATR * reward-to-risk ratio * TP2 multiplier
Calculation: LongStop = if trailing stop on AND some bar since entry has close - entry price >= trail activation multiplier * ATR, then highest of (close - trail distance multiplier * ATR) over the bars since entry where close - entry price >= trail activation multiplier * ATR, else LowestLow - stop ATR multiplier * ATR
Calculation: ShortStop = if trailing stop on AND some bar since entry has entry price - close >= trail activation multiplier * ATR, then lowest of (close + trail distance multiplier * ATR) over the bars since entry where entry price - close >= trail activation multiplier * ATR, else HighestHigh + stop ATR multiplier * ATR
Long: close > LowestLow - ATR * buffer multiplier AND low <= LowestLow AND volume > AvgVolume AND UptrendOK AND TradingTimeOK AND position side is flat
Short: close < HighestHigh + ATR * buffer multiplier AND high >= HighestHigh AND volume > AvgVolume AND DowntrendOK AND TradingTimeOK AND position side is flat
Exit: Long, low <= LongStop
Exit: Long, high >= LongTP1
Exit: Long, high >= LongTP2 AND partial close on
Exit: Short, high >= ShortStop
Exit: Short, low <= ShortTP1
Exit: Short, low <= ShortTP2 AND partial close on