Calculation: Trend state = neutral until the first pivot break; bullish after a close crosses above the most recent unbroken confirmed pivot high, bearish after a close crosses below the most recent unbroken confirmed pivot low.
Calculation: Hull acceleration = (HMA(close, ribbon length) - HMA(close, ribbon length)[1]) - (HMA(close, ribbon length)[1] - HMA(close, ribbon length)[2]).
Calculation: Zone strength = clamp(round(zone strength scale × mean(volume from the origin candle through the configured recent-side span after it and older-side span before it) / (SMA(volume, volume-average lookback) if positive, otherwise 1)), 0, zone strength cap).
Calculation: Active bullish zone = a zone created by a bullish BoS or CHoCH selected by the zone-trigger setting, using the most recent prior bearish candle within origin lookback as its bounds; create only if Zone strength meets the creation minimum; retain among the most recently created zone-count limit and while the origin age is within the age limit; mark mitigated when close is below its bottom.
Calculation: Active bearish zone = a zone created by a bearish BoS or CHoCH selected by the zone-trigger setting, using the most recent prior bullish candle within origin lookback as its bounds; create only if Zone strength meets the creation minimum; retain among the most recently created zone-count limit and while the origin age is within the age limit; mark mitigated when close is above its top.
Long: HMA(close, ribbon length) > HMA(close, ribbon length)[ribbon displacement].
Short: HMA(close, ribbon length) <= HMA(close, ribbon length)[ribbon displacement].
Long: HMA(close, ribbon length) < HMA(close, ribbon length)[ribbon displacement] AND Hull acceleration > 0 AND HMA(close, ribbon length) > HMA(close, ribbon length)[1].
Short: HMA(close, ribbon length) > HMA(close, ribbon length)[ribbon displacement] AND Hull acceleration < 0 AND HMA(close, ribbon length) < HMA(close, ribbon length)[1].
Long: trend state is bullish.
Short: trend state is bearish.
Long: close crosses above the most recent unbroken confirmed PivotHigh(high, pivot lookback, pivot lookback).
Short: close crosses below the most recent unbroken confirmed PivotLow(low, pivot lookback, pivot lookback).
Long: a newly confirmed PivotHigh(high, pivot lookback, pivot lookback) exists and no prior confirmed pivot high exists, or it is higher than the prior confirmed pivot high.
Short: a newly confirmed PivotHigh(high, pivot lookback, pivot lookback) exists, a prior confirmed pivot high exists, and it is no higher than the prior confirmed pivot high.
Long: a newly confirmed PivotLow(low, pivot lookback, pivot lookback) exists and no prior confirmed pivot low exists, or it is higher than the prior confirmed pivot low.
Short: a newly confirmed PivotLow(low, pivot lookback, pivot lookback) exists, a prior confirmed pivot low exists, and it is no higher than the prior confirmed pivot low.
Long: a bullish close-cross above the most recent unbroken confirmed pivot high is selected by the zone-trigger setting, a prior bearish candle exists within origin lookback, and Zone strength meets the creation minimum.
Short: a bearish close-cross below the most recent unbroken confirmed pivot low is selected by the zone-trigger setting, a prior bullish candle exists within origin lookback, and Zone strength meets the creation minimum.
Long: an active bullish zone has strength at least the signal minimum, its early-touch state is already true or its first low-in-zone touch occurs on this bar, and close crosses above the zone bottom.
Long: an active bullish zone has strength at least the signal minimum, its low is within the zone bounds while the prior bar's low was outside them, it has not previously had an early touch, and no active bullish zone meets the confirmed-long condition on this bar.
Short: an active bearish zone has strength at least the signal minimum, its early-touch state is already true or its first high-in-zone touch occurs on this bar, and close crosses below the zone top.
Short: an active bearish zone has strength at least the signal minimum, its high is within the zone bounds while the prior bar's high was outside them, it has not previously had an early touch, and no active bearish zone meets the confirmed-short condition on this bar.
Exit: long, close crosses below the most recent unbroken confirmed pivot low while trend state before the break is neutral or bullish.
Exit: short, close crosses above the most recent unbroken confirmed pivot high while trend state before the break is neutral or bearish.