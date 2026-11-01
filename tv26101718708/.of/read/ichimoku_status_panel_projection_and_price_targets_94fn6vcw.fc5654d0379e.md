Calculation: Ichimoku midpoint = (highest high + lowest low) / 2 over a lookback; optionally use close for both high and low. The conversion, base, and leading-span-B lookbacks are respectively short, intermediate, and long. Leading span A is the average of the conversion and base midpoints. The current cloud is the two leading spans displaced by a configurable number of bars; the lagging-span cloud is the two leading spans displaced by twice that number.
Calculation: Directional score = sum of seven values, each +1 for its bullish comparison, -1 for its bearish comparison, and 0 otherwise: close versus conversion midpoint; close versus base midpoint; conversion versus base midpoint; close versus close at the displacement; close versus the lagging-span cloud, with inside or equal to its boundary neutral; close versus the current cloud, with inside or equal to its boundary neutral; and base midpoint versus its previous value.
Calculation: Projected midpoint = the midpoint after the first current rolling high or low leaves its window, using the extremes remaining in that window and assuming no new extremes. Project the conversion and base midpoints separately. At the earlier projected change, substitute the projected value for each midpoint whose change is due; at the later change, use both projected values. A projection is unavailable when its remaining high or low is unavailable.
Calculation: Candle direction = 0 when high equals low or absolute close minus open is at most a configurable fraction of high minus low; otherwise +1 when close is above open and -1 when close is below open.
Calculation: Streak direction = the direction of the most recent nonzero candle direction within a configurable search limit. Streak length = the number of consecutive bars back from the current bar, up to a configurable maximum, before the first candle of the opposite direction; zero-direction candles count in the streak.
Calculation: Interposed pattern in a configured window = the first and last candles have the pattern direction and exactly the configured number of interior candles have a different direction, including zero. Use three window sizes in increasing order; the first two have the same smaller number of different interior candles and the largest has a larger number.
Calculation: Wave direction = direction of the latest three alternating confirmed high and low pivots, with each pivot confirmed after the same configurable number of bars on each side and consecutive pivots of the same kind merged into the more extreme one. A wave ending in a low points up; one ending in a high points down. Optionally, if close breaks the latest wave's starting pivot and the preceding three-pivot wave exists and its starting pivot is unbroken, use that preceding wave. A bullish wave is broken when close is below its starting low; a bearish wave is broken when close is above its starting high.
Long: close > conversion midpoint
Short: close < conversion midpoint
Long: close > base midpoint
Short: close < base midpoint
Long: conversion midpoint > base midpoint
Short: conversion midpoint < base midpoint
Long: close > close at the displacement
Short: close < close at the displacement
Long: close > upper boundary of the lagging-span cloud
Short: close < lower boundary of the lagging-span cloud
Long: close > upper boundary of the current cloud
Short: close < lower boundary of the current cloud
Long: base midpoint > previous base midpoint
Short: base midpoint < previous base midpoint
Long: directional score > 0
Short: directional score < 0
Long: (conversion midpoint > base midpoint OR (conversion midpoint = base midpoint AND base midpoint > previous base midpoint)) AND close > close at the displacement AND close > upper boundary of the current cloud AND base midpoint >= previous base midpoint
Short: (conversion midpoint < base midpoint OR (conversion midpoint = base midpoint AND base midpoint < previous base midpoint)) AND close < close at the displacement AND close < lower boundary of the current cloud AND base midpoint <= previous base midpoint
Long: conversion midpoint <= base midpoint AND (conversion midpoint at the earlier projected change > base midpoint at that change OR conversion midpoint at the later projected change > base midpoint at that change)
Short: conversion midpoint > base midpoint AND (conversion midpoint at the earlier projected change <= base midpoint at that change OR conversion midpoint at the later projected change <= base midpoint at that change)
Long: streak direction = +1 AND streak length >= minimum streak tier
Short: streak direction = -1 AND streak length >= minimum streak tier
Long: bullish interposed pattern exists
Short: bearish interposed pattern exists
Long: wave direction = up
Short: wave direction = down