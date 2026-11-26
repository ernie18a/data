Calculation: band(percent, floor) = max(percent * ATR(T1, ATR length, last completed T1 bar), floor * tick)
Calculation: premarket high = highest high of premarket-session bars of the latest premarket session, including the current bar while that session is open
Calculation: premarket low = lowest low of premarket-session bars of the latest premarket session, including the current bar while that session is open
Calculation: prior-session high = highest high of RTH bars of the latest RTH session completed before the latest roll boundary
Calculation: prior-session low = lowest low of RTH bars of the latest RTH session completed before the latest roll boundary
Calculation: prior close = close of the last RTH bar before the latest roll boundary
Calculation: weekly high = highest high of chart bars within the still-forming T2 bar, including the current bar
Calculation: weekly low = lowest low of chart bars within the still-forming T2 bar, including the current bar
Calculation: upLevel = premarket high, prior-session high, prior close, or weekly high, each evaluated separately
Calculation: dnLevel = premarket low, prior-session low, prior close, or weekly low, each evaluated separately
Calculation: usableUp = no close above upLevel since its last value change or session renewal (roll for prior-session and prior-close levels, RTH open for premarket levels), AND no setup on upLevel resolved within the last coil window bars, AND (upLevel unchanged for maturity bars OR upLevel is a prior-session, prior-close, or premarket level after the premarket session closed)
Calculation: usableDn = no close below dnLevel since its last value change or session renewal (roll for prior-session and prior-close levels, RTH open for premarket levels), AND no setup on dnLevel resolved within the last coil window bars, AND (dnLevel unchanged for maturity bars OR dnLevel is a prior-session, prior-close, or premarket level after the premarket session closed)
Calculation: longCoil = no close above upLevel in the last coil window bars including the current bar, AND highest(high, coil window) >= upLevel - band(proximity percent, proximity floor), AND highest(high, coil window) - lowest(low, coil window) <= band(coil height percent, coil height floor), AND usableUp
Calculation: shortCoil = no close below dnLevel in the last coil window bars including the current bar, AND lowest(low, coil window) <= dnLevel + band(proximity percent, proximity floor), AND highest(high, coil window) - lowest(low, coil window) <= band(coil height percent, coil height floor), AND usableDn
Calculation: longRange = highest(high, range window)[1] <= upLevel + band(proximity percent, proximity floor), AND upLevel - lowest(low, range window)[1] <= band(range cap percent, range cap floor), AND usableUp
Calculation: shortRange = lowest(low, range window)[1] >= dnLevel - band(proximity percent, proximity floor), AND highest(high, range window)[1] - dnLevel <= band(range cap percent, range cap floor), AND usableDn
Calculation: bullMomentum = close > open AND close - open >= band(momentum percent, momentum floor)
Calculation: bearMomentum = close < open AND open - close >= band(momentum percent, momentum floor)
Calculation: longBreak = (longCoil[1] AND close > upLevel[1] + break buffer * tick) OR (longRange AND NOT longCoil[1] AND close[1] <= upLevel AND close > upLevel + break buffer * tick)
Calculation: shortBreak = (shortCoil[1] AND close < dnLevel[1] - break buffer * tick) OR (shortRange AND NOT shortCoil[1] AND close[1] >= dnLevel AND close < dnLevel - break buffer * tick)
Calculation: openLong = a long setup armed on this bar or earlier, with no close below its broken level and no retest since arming through this bar, AND bars since break <= timeout
Calculation: swungLong = openLong AND armed at least swing bars ago AND no bar in the last swing bars set a new high since the break
Calculation: openShort = a short setup armed on this bar or earlier, with no close above its broken level and no retest since arming through this bar, AND bars since break <= timeout
Calculation: swungShort = openShort AND armed at least swing bars ago AND no bar in the last swing bars set a new low since the break
Long: longBreak AND bullMomentum
Long: first bar within confirmation window bars after a bar with longBreak AND NOT bullMomentum, on which close > broken level AND no close below broken level since that bar AND (bullMomentum OR (low > high[2] AND low - high[2] >= band(FVG percent, FVG floor)))
Long: openLong[1] AND NOT swungLong[1] AND bars since break <= timeout AND low <= broken level + retest tolerance * tick AND close >= broken level
Long: swungLong[1] AND low <= max((anchor + swing high) / 2, broken level), where anchor = lowest(low, coil window) at a coil break or min(lowest(low, range window)[1], broken level) at a range break, and swing high = highest high since the break as of the swing-confirmation bar
Exit: long, close < broken level AND openLong[1] AND NOT swungLong[1]
Short: shortBreak AND bearMomentum
Short: first bar within confirmation window bars after a bar with shortBreak AND NOT bearMomentum, on which close < broken level AND no close above broken level since that bar AND (bearMomentum OR (high < low[2] AND low[2] - high >= band(FVG percent, FVG floor)))
Short: openShort[1] AND NOT swungShort[1] AND bars since break <= timeout AND high >= broken level - retest tolerance * tick AND close <= broken level
Short: swungShort[1] AND high >= min((anchor + swing low) / 2, broken level), where anchor = highest(high, coil window) at a coil break or max(highest(high, range window)[1], broken level) at a range break, and swing low = lowest low since the break as of the swing-confirmation bar
Exit: short, close > broken level AND openShort[1] AND NOT swungShort[1]