Calculation: bar delta = volume * (close - open) / (high - low), or 0 if high = low
Calculation: quarter delta(q) = sum over bars from zone creation through this bar of bar delta * overlap share(q), where overlap share(q) = max(0, min(high, quarter q top) - max(low, quarter q bottom)) / (high - low), or 0 if high = low, and quarter 0 is the bottom and quarter 3 the top of the zone height split into four equal parts
Calculation: total absolute quarter delta = |quarter delta(0)| + |quarter delta(1)| + |quarter delta(2)| + |quarter delta(3)|
Calculation: pivot-high zone top = high[pivot length] on the bar where PivotHigh(high, pivot length, pivot length) is not NA
Calculation: pivot-high zone bottom = min(max(open[pivot length], close[pivot length]), pivot-high zone top - thickness factor * ATR(atr length)[pivot length]) on the same bar
Calculation: pivot-low zone bottom = low[pivot length] on the bar where PivotLow(low, pivot length, pivot length) is not NA
Calculation: pivot-low zone top = max(min(open[pivot length], close[pivot length]), pivot-low zone bottom + thickness factor * ATR(atr length)[pivot length]) on the same bar
Calculation: pivot-high zone evaluated = total absolute quarter delta > 0 AND high was not above zone top on any bar from zone creation to the previous bar AND (bar range overlaps zone OR high > zone top)
Calculation: pivot-low zone evaluated = total absolute quarter delta > 0 AND low was not below zone bottom on any bar from zone creation to the previous bar AND (bar range overlaps zone OR low < zone bottom)
Calculation: pivot-high outer share = |quarter delta(3)| / total absolute quarter delta
Calculation: pivot-low outer share = |quarter delta(0)| / total absolute quarter delta
Short: pivot-high zone evaluated AND no earlier Short signal for the zone AND high > zone top AND quarter delta(3) < 0 AND pivot-high outer share > absorption threshold
Short: pivot-high zone evaluated AND no earlier Short signal for the zone AND high > zone top AND pivot-high outer share < exhaustion threshold
Short: pivot-high zone evaluated AND no earlier Short signal for the zone AND close within zone AND quarter delta(3) > 0 AND pivot-high outer share > divergence threshold
Short: pivot-high zone evaluated AND no earlier Short signal for the zone AND high > zone top AND close < (zone top + zone bottom) / 2 AND bar delta < 0 AND |bar delta| / volume > rejection threshold
Long: pivot-low zone evaluated AND no earlier Long signal for the zone AND low < zone bottom AND quarter delta(0) > 0 AND pivot-low outer share > absorption threshold
Long: pivot-low zone evaluated AND no earlier Long signal for the zone AND low < zone bottom AND pivot-low outer share < exhaustion threshold
Long: pivot-low zone evaluated AND no earlier Long signal for the zone AND close within zone AND quarter delta(0) < 0 AND pivot-low outer share > divergence threshold
Long: pivot-low zone evaluated AND no earlier Long signal for the zone AND low < zone bottom AND close > (zone top + zone bottom) / 2 AND bar delta > 0 AND |bar delta| / volume > rejection threshold
Exit: long, close > entry on each of the last hold bars OR bars since entry >= eval window
Exit: short, close < entry on each of the last hold bars OR bars since entry >= eval window