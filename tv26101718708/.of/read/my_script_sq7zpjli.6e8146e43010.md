Calculation: VolSpike = volume > SMA(volume, volume lookback) * multiplier (multiplier > 1)
Calculation: SwingHigh / SwingLow = highest high / lowest low over the lookback window of bars ending at the previous bar (current bar excluded)
Calculation: HTFBull = close of the higher-timeframe bar still forming > EMA(close, shorter period) of that timeframe AND that shorter-period EMA > EMA(close, longer period) of that timeframe; HTFBear = the mirror (close < shorter EMA < longer EMA)
Calculation: SweepUp (evaluated on a bar) = low < SwingLow * (1 + small tolerance %) AND close > SwingLow AND high > open AND VolSpike
Calculation: SweepDown (evaluated on a bar) = high > SwingHigh * (1 - small tolerance %) AND close < SwingHigh AND low < open AND VolSpike
Calculation: BullFVG = low > high of 2 bars ago AND (low - high of 2 bars ago) >= minimum gap size; BearFVG = low of 2 bars ago > high AND (low of 2 bars ago - high) >= minimum gap size
Calculation: BullWick = (min(open, close) - low) / (high - low) >= minimum wick ratio AND close > open; BearWick = (high - max(open, close)) / (high - low) >= minimum wick ratio AND close < open
Calculation: Entry = open of the signal bar; Buffer = Entry * small buffer %; LongStop = SwingLow as of the sweep bar (the bar before the signal bar) - Buffer; ShortStop = SwingHigh as of the sweep bar + Buffer; Risk = |Entry - Stop|; LongTP1/LongTP2 = Entry + Risk * RR1/RR2; ShortTP1/ShortTP2 = Entry - Risk * RR1/RR2 (RR2 > RR1)
Long: HTFBull AND SweepUp on the previous bar AND BullFVG on the current bar AND BullWick on the current bar AND VolSpike on the current bar
Short: HTFBear AND SweepDown on the previous bar AND BearFVG on the current bar AND BearWick on the current bar AND VolSpike on the current bar
Exit: long, low <= LongStop OR high >= LongTP1 OR high >= LongTP2
Exit: short, high >= ShortStop OR low <= ShortTP1 OR low <= ShortTP2