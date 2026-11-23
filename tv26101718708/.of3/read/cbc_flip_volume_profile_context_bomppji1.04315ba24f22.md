Calculation: ControlState = 1 if close > high[1] AND close > open AND (high - low) >= min flip range * ATR(atr period); -1 if close < low[1] AND close < open AND (high - low) >= min flip range * ATR(atr period); otherwise ControlState[1]
Calculation: POC = VolumeProfilePOC(lookback, bins, (high + low + close) / 3, volume) over the lookback bars ending at the current bar
Calculation: VAH = VolumeProfileVAH(lookback, bins, value area %, (high + low + close) / 3, volume) over the lookback bars ending at the current bar
Calculation: VAL = VolumeProfileVAL(lookback, bins, value area %, (high + low + close) / 3, volume) over the lookback bars ending at the current bar
Calculation: LastDisplayed = class and direction of the latest bar on which a BRK, REV, or VA Long or Short rule holds, otherwise LastDisplayed[1]
Calculation: LongGuideLow = low if the REV long rule holds on this bar; otherwise LongGuideLow[1] if LongGuideLow[1] != undefined AND high < POC AND low >= LongGuideLow[1] AND no BRK, REV, or VA short rule holds on this bar; otherwise undefined
Calculation: ShortGuideHigh = high if the REV short rule holds on this bar; otherwise ShortGuideHigh[1] if ShortGuideHigh[1] != undefined AND low > POC AND high <= ShortGuideHigh[1] AND no BRK, REV, or VA long rule holds on this bar; otherwise undefined
Long: ControlState = 1 AND ControlState[1] != 1 AND close > VAH AND close - VAH <= (VAH - POC) * max extension % / 100 AND LastDisplayed[1] != BRK long
Long: ControlState = 1 AND ControlState[1] != 1 AND close <= POC AND LastDisplayed[1] != REV long
Long: ControlState = 1 AND ControlState[1] != 1 AND close > POC AND close <= VAH AND in-value flips enabled AND LastDisplayed[1] != VA long
Long: ControlState = 1
Short: ControlState = -1 AND ControlState[1] != -1 AND close < VAL AND VAL - close <= (POC - VAL) * max extension % / 100 AND LastDisplayed[1] != BRK short
Short: ControlState = -1 AND ControlState[1] != -1 AND close >= POC AND LastDisplayed[1] != REV short
Short: ControlState = -1 AND ControlState[1] != -1 AND close < POC AND close >= VAL AND in-value flips enabled AND LastDisplayed[1] != VA short
Short: ControlState = -1
Exit: long, LongGuideLow[1] != undefined AND (high >= POC OR low < LongGuideLow[1])
Exit: short, ShortGuideHigh[1] != undefined AND (low <= POC OR high > ShortGuideHigh[1])