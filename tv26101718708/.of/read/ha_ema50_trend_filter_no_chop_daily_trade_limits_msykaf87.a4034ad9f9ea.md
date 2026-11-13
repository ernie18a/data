Calculation: Notation = t is the latest completed bar when decisions are evaluated; x[n] is the value n bars before t; every entry and exit fills at the open of the bar after t.
Calculation: HA = Heikin-Ashi on chart-timeframe bars: haClose=(open+high+low+close)/4; haOpen=(previous haOpen+previous haClose)/2, first bar (open+close)/2; green if haClose>=haOpen, else red.
Calculation: EMA = exponential moving average of close; ATR = average true range.
Calculation: Crosses = number of bars in a lookback window ending at t-1 where (close>EMA) differs from the same test on the previous bar.
Calculation: NoChop = ATR[1] >= a fraction (below 1) of the longer-term SMA of ATR[1] AND (highest high minus lowest low over a window ending at t-1) >= a multiple (above 1) of ATR[1] AND Crosses <= a small cap.
Calculation: Slope = |EMA[1]-EMA[1+k]| >= a multiple of ATR[1].
Calculation: DayOK = bar time of day is inside a fixed intraday session window AND number of entries made on the current calendar day < a cap AND number of losing closed trades on the current calendar day < a smaller cap.
Calculation: StructStopLong = low[k]-buffer for the smallest k in 1..L where HA[k] is red (no stop if none); StructStopShort = high[k]+buffer for the smallest k in 1..L where HA[k] is green (no stop if none).
Calculation: LongStop = set at t when entering: StructStopLong (or alternatively close[0]-fixed distance); after any bar closes with close-entry >= a trigger distance, LongStop = max(LongStop, entry+small offset). ShortStop = mirror: StructStopShort (or close[0]+fixed distance); after close<=entry-trigger distance, ShortStop = min(ShortStop, entry-small offset).
Long: flat AND HA[1] green AND HA[2] green AND close[1]>EMA[1] AND EMA[1]>EMA[1+k] AND Slope AND NoChop AND DayOK
Short: flat AND HA[1] red AND HA[2] red AND close[1]<EMA[1] AND EMA[1]<EMA[1+k] AND Slope AND NoChop AND DayOK
Exit: long, HA[0] is red OR low<=LongStop OR (optional take profit) high>=close at signal bar + fixed distance
Exit: short, HA[0] is green OR high>=ShortStop OR (optional take profit) low<=close at signal bar - fixed distance