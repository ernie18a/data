Calculation: BullBreak = on a new T1 bar, last completed T1 close > latest PivotHigh(T1, pivot left, pivot right, last completed bar) not yet broken by a BullBreak
Calculation: BearBreak = on a new T1 bar, last completed T1 close < latest PivotLow(T1, pivot left, pivot right, last completed bar) not yet broken by a BearBreak
Calculation: BullRun = number of BullBreak events since the latest BearBreak, or since the start
Calculation: BearRun = number of BearBreak events since the latest BullBreak, or since the start
Calculation: Warmed = completed T1 bar count >= max(warmup floor, origin lookback + pivot left + pivot right + 2)
Calculation: BullOrigin = most recent T1 bar with close < open among the origin lookback T1 bars before the last completed T1 bar
Calculation: BearOrigin = most recent T1 bar with close > open among the origin lookback T1 bars before the last completed T1 bar
Calculation: BullDisplacement = last completed T1 close - BullOrigin low >= displacement multiplier * ATR(T1, ATR length, last completed bar)
Calculation: BearDisplacement = BearOrigin high - last completed T1 close >= displacement multiplier * ATR(T1, ATR length, last completed bar)
Calculation: BullFVG = BullOrigin high < low of the completed T1 bar two bars after BullOrigin
Calculation: BearFVG = BearOrigin low > high of the completed T1 bar two bars after BearOrigin
Calculation: BullZoneFormed = BullBreak AND BullRun >= required break count AND Warmed AND BullOrigin exists AND ((require-both ON AND BullDisplacement AND BullFVG) OR (require-both OFF AND (BullDisplacement OR BullFVG)))
Calculation: BearZoneFormed = BearBreak AND BearRun >= required break count AND Warmed AND BearOrigin exists AND ((require-both ON AND BearDisplacement AND BearFVG) OR (require-both OFF AND (BearDisplacement OR BearFVG)))
Calculation: BullZoneActive = BullZoneFormed OR (BullZoneActive on prior bar AND NOT BullOff AND NOT BearBreak); BullZone top and bottom = BullOrigin high and low at formation
Calculation: BearZoneActive = BearZoneFormed OR (BearZoneActive on prior bar AND NOT BearOff AND NOT BullBreak); BearZone top and bottom = BearOrigin high and low at formation
Calculation: BullOff = BullZoneActive on prior bar AND ((new T1 bar AND last completed T1 close < BullZone bottom on prior bar) OR (new T1 bar AND T1 bars since formation > maximum zone age) OR BullZoneFormed)
Calculation: BearOff = BearZoneActive on prior bar AND ((new T1 bar AND last completed T1 close > BearZone top on prior bar) OR (new T1 bar AND T1 bars since formation > maximum zone age) OR BearZoneFormed)
Calculation: BullTouch = BullZoneActive AND low <= BullZone top AND no earlier chart bar since formation had low <= BullZone top
Calculation: BearTouch = BearZoneActive AND high >= BearZone bottom AND no earlier chart bar since formation had high >= BearZone bottom
Long: BullBreak
Long: BullZoneFormed
Long: BullTouch AND high >= BullZone bottom
Short: BearBreak
Short: BearZoneFormed
Short: BearTouch AND low <= BearZone top
Exit: long, BullOff OR (BullTouch AND high < BullZone bottom)
Exit: short, BearOff OR (BearTouch AND low > BearZone top)