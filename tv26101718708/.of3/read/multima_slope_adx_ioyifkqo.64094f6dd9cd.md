Calculation: BaseMA = ALMA(close, ma length, ALMA offset, ALMA sigma) when ma type is ALMA; EMA(close, ma length) when ma type is EMA; VWMA(close, ma length) when ma type is VWMA; HMA(close, ma length) when ma type is Hull MA; EMA(close, ma length) * (1 + TSI(close, TSI short length, TSI long length)) when ma type is TSI
Calculation: Slope = MOM(BaseMA, slope lookback)
Calculation: ADX = ADX(adx period, adx period)
Calculation: ADX filter passes = ADX filter off OR (ADX >= ADX threshold AND (ADX must rise off OR ADX > ADX[1]))
Calculation: Exit event = position side is flat AND position side[1] is not flat
Calculation: Bars since exit = barssince(Exit event), or bar index if no Exit event yet
Calculation: Slope at last exit = valuewhen(Exit event, Slope[1], 0), or 0 if no Exit event yet
Calculation: Mid-trend re-entry long = mid-trend re-entry on AND Slope > 0 AND Slope > Slope at last exit AND Slope > Slope[1] AND (acceleration filter off OR barssince(Slope <= Slope[1]) >= accel bars)
Calculation: Mid-trend re-entry short = mid-trend re-entry on AND Slope < 0 AND Slope < Slope at last exit AND Slope < Slope[1] AND (acceleration filter off OR barssince(Slope >= Slope[1]) >= accel bars)
Calculation: Volatility multiplier = ATR(smart ATR length) / SMA(ATR(smart ATR length), smart ATR SMA length) when both are positive, else 1
Calculation: SL fraction = ATR(auto ATR length) * auto SL multiplier / close when auto calc on, else SL percent
Calculation: Trail start fraction = ATR(auto ATR length) * auto TS start multiplier / close when auto calc on, else trail start percent * (Volatility multiplier when smart trail on, else 1)
Calculation: Trail distance fraction = ATR(auto ATR length) * auto TS follow multiplier / close when auto calc on, else trail distance percent * (Volatility multiplier when smart trail on, else 1)
Calculation: Highest high since entry = highest high from the entry bar through the current bar
Calculation: Lowest low since entry = lowest low from the entry bar through the current bar
Calculation: Long stop price = entry price * (1 - SL fraction) on the entry bar, else MAX(Long stop price[1], Highest high since entry * (1 - SL fraction))
Calculation: Short stop price = entry price * (1 + SL fraction) on the entry bar, else MIN(Short stop price[1], Lowest low since entry * (1 + SL fraction))
Calculation: KSI = (TR^2 / (volume * EMA(volume, KSI volume length))) * KSI multiplier when volume * EMA(volume, KSI volume length) > 0, else 0
Calculation: KSI signal = EMA(KSI, KSI signal length)
Calculation: Spike = spike level > 0 AND (KSI crosses above spike level OR KSI > spike level)
Calculation: KSI filter passes = (avoid spike filter off OR NOT Spike) AND (avoid squeeze filter off OR NOT (KSI < near-zero level AND KSI signal < near-zero level)) AND (only strong momentum filter off OR KSI > KSI signal) AND (avoid weakness filter off OR KSI >= KSI signal)
Calculation: Exit VWMA = VWMA(close, VWMA exit length)
Calculation: Exit long signal = (cross exit on AND close crosses below BaseMA) OR (VWMA exit on AND close crosses below Exit VWMA) OR (slope exit on AND (barssince(NOT (Slope < Slope[1] AND Slope > 0)) >= slope exit bars OR Slope crosses below 0)) OR (KSI exit on AND Spike)
Calculation: Exit short signal = (cross exit on AND close crosses above BaseMA) OR (VWMA exit on AND close crosses above Exit VWMA) OR (slope exit on AND (barssince(NOT (Slope > Slope[1] AND Slope < 0)) >= slope exit bars OR Slope crosses above 0)) OR (KSI exit on AND Spike)
Long: slope entry on AND position side is not short AND (position side is flat OR NOT Exit long signal) AND Bars since exit >= reentry cooldown AND ADX filter passes AND KSI filter passes AND (Slope crosses above 0 OR Mid-trend re-entry long)
Long: cross entry on AND position side is not short AND (position side is flat OR NOT Exit long signal) AND Bars since exit >= reentry cooldown AND ADX filter passes AND KSI filter passes AND (close crosses above BaseMA OR Mid-trend re-entry long)
Short: slope entry on AND position side is not long AND (position side is flat OR NOT Exit short signal) AND Bars since exit >= reentry cooldown AND ADX filter passes AND KSI filter passes AND (Slope crosses below 0 OR Mid-trend re-entry short)
Short: cross entry on AND position side is not long AND (position side is flat OR NOT Exit short signal) AND Bars since exit >= reentry cooldown AND ADX filter passes AND KSI filter passes AND (close crosses below BaseMA OR Mid-trend re-entry short)
Exit: long, Exit long signal
Exit: long, stop on AND low <= Long stop price[1]
Exit: long, take profit on AND high >= entry price * (1 + take profit percent)
Exit: long, trailing on AND Highest high since entry >= entry price * (1 + Trail start fraction) AND low <= Highest high since entry - entry price * Trail distance fraction
Exit: short, Exit short signal
Exit: short, stop on AND high >= Short stop price[1]
Exit: short, take profit on AND low <= entry price * (1 - take profit percent)
Exit: short, trailing on AND Lowest low since entry <= entry price * (1 - Trail start fraction) AND high >= Lowest low since entry + entry price * Trail distance fraction