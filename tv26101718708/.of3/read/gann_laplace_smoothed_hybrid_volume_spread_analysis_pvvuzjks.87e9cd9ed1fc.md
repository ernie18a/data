Calculation: PointSeries = PointSeries extended per bar, where each appended value is one point event p: if high > high[1] and low > low[1], append low then high; else if high < high[1] and low < low[1], append high then low; else if (high >= high[1] and low < low[1]) or (high > high[1] and low <= low[1]), append low then high if close > open, otherwise high then low; else append nothing; before a pair of events, if the newest point of PointSeries is above both or below both pair values, first a point event repeats the second-newest point
Calculation: SwingA(p, X, Y) = returns 1 and appends p to Y if (y0 >= y1 and x0 < y1) or (y0 <= y1 and x0 > y1) or (y0 >= y1 and x0 < x1 and x0 < x2 and x1 < x3 and x2 < x3) or (y0 <= y1 and x0 > x1 and x0 > x2 and x1 > x3 and x2 > x3); else returns 2 and replaces y0 with p if (y0 >= y1 and p >= y0) or (y0 <= y1 and p <= y0); else returns 0 and leaves Y unchanged; x0 to x3 and y0 to y1 are newest-first values of X and Y
Calculation: SwingB(p, Y, m) = updates Y and m, with y0 to y2 newest-first values of Y, up = (y0 >= y1), down = (y0 <= y1); if m = 0, check in order: (A) returns 2 and replaces y0 with p if (up and p >= y0) or (down and p <= y0); (B) returns 1 and appends p if (up and p < y1) or (down and p > y1); (C) returns 1, appends p and sets m = p if (up and y1 < p < y0) or (down and y0 < p < y1); if m > 0, check in order: (D) returns 1, appends p and sets m = 0 if (up and p < y1) or (down and p > y1); (E) returns 2, replaces y0 with p and sets m = 0 if (up and p > y2) or (down and p < y2); (F) returns 2, replaces y0 with p and sets m = p if (up and p <= y2 and p >= y0) or (down and p >= y2 and p <= y0); if none applies, returns 0 and leaves Y and m unchanged
Calculation: ChoChLevel(Y) = y2 if (y3 > y2 and y3 < y1 and y0 < y2) or (y3 < y2 and y3 > y1 and y0 > y2), otherwise undefined; y0 to y3 are newest-first values of Y
Calculation: ChoChMark(Y, sw) = ChoChLevel(Y) if sw is on and Y changed on this point event and ChoChLevel(Y) is defined, otherwise the previous ChoChMark(Y, sw)
Calculation: UpMark(M) = true if M > M[1], false if M < M[1], otherwise the previous UpMark(M)
Calculation: Level1 = Level1 updated by SwingA(p, PointSeries, Level1) on each point event p
Calculation: SubLevel1 = SubLevel1 updated by SwingB(p, SubLevel1, SubMark1) on each point event p where Level1 changed on p
Calculation: Level2 = Level2 updated by SwingA(p, SubLevel1, Level2) on each point event p where SubLevel1 changed on p
Calculation: SubLevel2 = SubLevel2 updated by SwingB(p, SubLevel2, SubMark2) on each point event p where Level2 changed on p
Calculation: Level3 = Level3 updated by SwingA(p, SubLevel2, Level3) on each point event p where SubLevel2 changed on p
Calculation: Mark1 = ChoChMark(Level1, SwitchChoChLevel1)
Calculation: Mark2 = ChoChMark(SubLevel1, SwitchChoChSubLevel1)
Calculation: Mark3 = ChoChMark(Level2, SwitchChoChLevel2)
Calculation: Mark4 = ChoChMark(SubLevel2, SwitchChoChSubLevel2)
Calculation: Mark5 = ChoChMark(Level3, SwitchChoChLevel3)
Calculation: BullTrigger = (Mark1 != Mark1[1]) and Mark1 < high and Mark1 > close[1] and (UpMark(Mark2) or UpMark(Mark3) or UpMark(Mark4) or UpMark(Mark5))
Calculation: BearTrigger = (Mark1 != Mark1[1]) and Mark1 > low and Mark1 < close[1] and (not UpMark(Mark2) or not UpMark(Mark3) or not UpMark(Mark4) or not UpMark(Mark5))
Calculation: ConfirmedUp = SwitchToggle and UpMark(Mark2) and UpMark(Mark3) and UpMark(Mark4) and UpMark(Mark5)
Calculation: GannPosition = 0 if (BearTrigger and not SwitchShort) or not ((BullTrigger and not SwitchShort) or ConfirmedUp); else 1 if (BullTrigger or ConfirmedUp) and not (BearTrigger and not SwitchShort); else -1 if BearTrigger and SwitchShort; else GannPosition[1]
Calculation: AdaptiveLength = min(AdaptiveLength[1] / (2 if GannPosition != GannPosition[1] else 1) + abs(GannPosition), LengthA)
Calculation: SpreadLength = AdaptiveLength if SwitchGannVZO else LengthA + GannPosition
Calculation: SmoothedPrice(x) = DoubleFourier(x) if SwitchDoubleFourier else x
Calculation: VolumeSpread = (EMA(SmoothedPrice(close), SpreadLength) - EMA(SmoothedPrice(open), SpreadLength)) * (volume / FourierSmooth(FFT(volume), volume[1], MaxSmoothLength) if SwitchSmoothedVolume else volume / volume[1])
Calculation: SpreadMA = EMA(VolumeSpread, LengthB)
Long: SpreadMA > 0 and VolumeSpread > 0
Short: SpreadMA < 0 and VolumeSpread < 0
Exit: long, not (SpreadMA > 0 and VolumeSpread > 0) and SwitchCloseAll and (GannPosition = 0 or not SwitchGannEntry)
Exit: short, not (SpreadMA < 0 and VolumeSpread < 0) and SwitchCloseAll and (GannPosition = 0 or not SwitchGannEntry)
Long: (BullTrigger or ConfirmedUp) and not (BearTrigger and not SwitchShort)
Short: BearTrigger and SwitchShort
Exit: long, (BearTrigger and not SwitchShort) or not ((BullTrigger and not SwitchShort) or ConfirmedUp)
Exit: short, (BearTrigger and not SwitchShort) or not ((BullTrigger and not SwitchShort) or ConfirmedUp)