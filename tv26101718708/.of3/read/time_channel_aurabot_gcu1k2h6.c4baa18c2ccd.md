Calculation: ResistanceFit = value at current bar of the least-squares line through (bar index, high) of analysis-window bars, refit on only those with high >= the same line before refit - touch tolerance * ATR(high, low, close, ATR lookback) taken at analysis window end
Calculation: SupportFit = value at current bar of the least-squares line through (bar index, low) of analysis-window bars, refit on only those with low <= the same line before refit + touch tolerance * ATR(high, low, close, ATR lookback) taken at analysis window end
Calculation: ResistanceLevel = ResistanceFit + ATR(high, low, close, ATR lookback) * (channel width + resistance nudge)
Calculation: SupportLevel = SupportFit - ATR(high, low, close, ATR lookback) * (channel width + support nudge)
Calculation: BreakSize = minimum points if break size mode is Points; ATR(high, low, close, ATR lookback) * minimum ATR multiple if mode is ATR; 0 if mode is Off
Calculation: QualifiedBreak = +1 if close > ResistanceLevel and close - ResistanceLevel >= BreakSize; -1 if close < SupportLevel and SupportLevel - close >= BreakSize; 0 otherwise
Long: QualifiedBreak = +1 AND bar is outside analysis window AND no earlier nonzero QualifiedBreak since last analysis window ended
Short: QualifiedBreak = -1 AND bar is outside analysis window AND no earlier nonzero QualifiedBreak since last analysis window ended
Calculation: ReadBreak = +1 if close > ResistanceLevel, -1 if close < SupportLevel, 0 otherwise, on only the first bar since last analysis window ended that is outside analysis window, before projection end, and has close > ResistanceLevel or close < SupportLevel
Calculation: ReadBars = max(1, round(read window minutes / bar length in minutes))
Calculation: ReadHold = +1 if ReadBreak[ReadBars] = +1 and SMA(close, ReadBars) > ResistanceLevel; -1 if ReadBreak[ReadBars] = -1 and SMA(close, ReadBars) < SupportLevel; 0 otherwise
Long: ReadHold = +1
Short: ReadHold = -1
Short: ReadBreak[ReadBars] = +1 AND SMA(close, ReadBars) <= ResistanceLevel
Long: ReadBreak[ReadBars] = -1 AND SMA(close, ReadBars) >= SupportLevel
Calculation: ZoneBars = max(1, floor(zone window minutes / bar length in minutes))
Long: first bar where ReadHold has been +1 since last analysis window ended AND ReadBreak = +1 within last ZoneBars bars AND low > high[2]
Short: first bar where ReadHold has been -1 since last analysis window ended AND ReadBreak = -1 within last ZoneBars bars AND high < low[2]