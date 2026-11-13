Calculation: EMAfast, EMAslow = EMA of close; EMAfast has a shorter lookback than EMAslow
Calculation: VWAP = volume-weighted average of (high+low+close)/3, reset each day
Calculation: PDH, PDL = high and low of the last completed bar of a higher (daily) timeframe, i.e. the previous day
Calculation: PMH, PML = highest high and lowest low so far today over the premarket bars (before the regular session)
Calculation: DayHigh, DayLow = highest high and lowest low so far in today's regular session, including the current bar
Calculation: tol = small percentage tolerance around a level
Calculation: LongLevel = the first of PDH, PMH (in that order) that satisfies low <= L*(1+tol) AND close > L; none if neither does
Calculation: ShortLevel = the first of PDL, PML (in that order) that satisfies high >= L*(1-tol) AND close < L; none if neither does
Calculation: EntryLevel = LongLevel or ShortLevel as of the entry bar (none if the entry was triggered only by the EMAfast tap); DayHigh/DayLow as of the entry bar are stored as EntryDayHigh/EntryDayLow
Long: flat AND trades entered today < daily maximum AND bar time is inside the early entry window of the regular session AND close > VWAP AND EMAfast > EMAslow AND close > EMAslow AND close > EMAfast AND (close > PDH OR close > PMH) AND close > open AND (LongLevel exists OR low <= EMAfast)
Short: flat AND trades entered today < daily maximum AND bar time is inside the early entry window of the regular session AND close < VWAP AND EMAfast < EMAslow AND close < EMAslow AND close < EMAfast AND (close < PDL OR close < PML) AND close < open AND (ShortLevel exists OR high >= EMAfast)
Exit: long, close < EMAfast OR (EntryLevel exists AND close < EntryLevel) -> close all
Exit: long, low <= EMAslow -> close all
Exit: long, high > EntryDayHigh -> close half of the position (once)
Exit: short, close > EMAfast OR (EntryLevel exists AND close > EntryLevel) -> close all
Exit: short, high >= EMAslow -> close all
Exit: short, low < EntryDayLow -> close half of the position (once)
Exit: any, bar time is inside the end-of-day window before the regular session close -> close all