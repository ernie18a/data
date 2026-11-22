Calculation: ATR = ATR(high, low, close, ATR length)
Calculation: Baseline = SMA(close, MA length) if MA type is SMA; EMA(close, MA length) if MA type is EMA; HMA(close, MA length) if MA type is HMA; VWAP(hlc3, volume, session reset at each new T1 bar) if MA type is VWAP
Calculation: BandUnit = ATR if band mode is ATR; StDev(close, MA length) if band mode is Bollinger; VWAP standard deviation(hlc3, volume, session reset at each new T1 bar) if band mode is VWAP standard deviation
Calculation: LowerBand = Baseline - BandUnit * initial entry gap
Calculation: UpperBand = Baseline + BandUnit * initial entry gap
Calculation: LongZone = close <= LowerBand if Reversal mode; close >= UpperBand if Trending mode
Calculation: ShortZone = close >= UpperBand if Reversal mode; close <= LowerBand if Trending mode
Calculation: HABullish = Heikin-Ashi close > Heikin-Ashi open
Calculation: HABearish = Heikin-Ashi close < Heikin-Ashi open
Calculation: TradingWindowOpen = prop mode disabled OR New York time-of-day of datetime is from window start (inclusive) to window end (exclusive), wrapping past midnight when window start is not earlier than window end
Calculation: LongLock = a trade has exited, no entry has occurred since that exit, every close from the exit bar onward is in LongZone, and close > exit bar close - ATR * scale step
Calculation: ShortLock = a trade has exited, no entry has occurred since that exit, every close from the exit bar onward is in ShortZone, and close < exit bar close + ATR * scale step
Calculation: LongStop = initial entry price - ATR * SL multiplier until high first reaches average entry price + ATR * TP multiplier; from that bar onward, the maximum over bars since then (inclusive) of high - ATR * TP multiplier
Calculation: ShortStop = initial entry price + ATR * SL multiplier until low first reaches average entry price - ATR * TP multiplier; from that bar onward, the minimum over bars since then (inclusive) of low + ATR * TP multiplier
Long: long entries enabled AND position side is flat AND LongZone true on each of the last bars threshold bars AND NOT LongLock AND TradingWindowOpen
Short: short entries enabled AND position side is flat AND ShortZone true on each of the last bars threshold bars AND NOT ShortLock AND TradingWindowOpen
Long: position side is long AND close <= last entry price - ATR * scale step AND TradingWindowOpen AND (HA scale disabled OR (HABullish AND HABearish[1]))
Short: position side is short AND close >= last entry price + ATR * scale step AND TradingWindowOpen AND (HA scale disabled OR (HABearish AND HABullish[1]))
Exit: long, BE trail disabled AND (high >= average entry price + ATR * TP multiplier OR low <= initial entry price - ATR * SL multiplier)
Exit: long, BE trail enabled AND low <= LongStop
Exit: short, BE trail disabled AND (low <= average entry price - ATR * TP multiplier OR high >= initial entry price + ATR * SL multiplier)
Exit: short, BE trail enabled AND high >= ShortStop
Exit: long, NOT TradingWindowOpen
Exit: short, NOT TradingWindowOpen