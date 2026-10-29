Calculation: RSI = Relative Strength Index of close; an upper saturation episode starts when RSI is at or above the upper threshold, tracks the highest high and highest RSI, and ends when RSI closes below the upper threshold; a lower episode starts when RSI is at or below the lower threshold, tracks the lowest low and lowest RSI, and ends when RSI closes above the lower threshold. Use confirmed chart-timeframe bars.
Calculation: Exhaustion high zone = the wick range from the highest high of an upper episode to that bar’s body top; exhaustion low zone = the wick range from that episode’s lowest low to that bar’s body bottom. Pad a thinner range to the minimum ATR-based thickness; reject a zone taller than the maximum ATR-based height. Use chart-timeframe ATR.
Calculation: Zone score = saturation-depth points + climax-volume point + fast-fade point + episode-divergence point + wick-quality point. Depth earns more points at the deeper RSI threshold; climax volume means extreme-bar volume exceeds its moving average; fast fade means RSI returns inside the threshold within the fade window after its peak; divergence means a more extreme price extreme than the previous same-side episode with a less extreme peak RSI; wick quality means the extreme bar’s rejection wick exceeds the specified fraction of its body.
Long: A lower saturation episode ends and its exhaustion low zone passes the zone-height guard.
Long: Close is within an active exhaustion low zone and that zone has not previously been touched.
Long: A new exhaustion low zone has a premium score (A or S grade).
Short: An upper saturation episode ends and its exhaustion high zone passes the zone-height guard.
Short: Close is within an active exhaustion high zone and that zone has not previously been touched.
Short: A new exhaustion high zone has a premium score (A or S grade).
Exit: long, close is below the bottom of an active exhaustion low zone.
Exit: short, close is above the top of an active exhaustion high zone.