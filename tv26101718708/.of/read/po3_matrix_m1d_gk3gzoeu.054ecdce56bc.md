Calculation: Higher-timeframe range mean = mean(high - low) over the selected snapshot; for the main layer include the forming bar, and for the intermediate and faster layers use completed bars only. All three layers are higher than the chart timeframe; the intermediate and faster layers are shorter than the main layer.
Calculation: Swing high/low = a bar whose high/low is strictly beyond both neighboring bars' highs/lows. A true swing high additionally has an up-to-down candle transition across either the older neighbor and swing bar or the swing bar and newer neighbor; a true swing low has a down-to-up transition across either pair. Up means close > open; down means close < open.
Calculation: Failed high/low raid = a later bar exceeds a swing high/low with its high/low and closes strictly back inside it, with no intervening bar exceeding that swing. The swing must be at least two bars older than the raid. Use the forming or a completed bar on the main layer and completed bars on the intermediate and faster layers.
Calculation: Bullish/bearish structure shift = the first close strictly above/below a true swing high/low, at least two bars after the swing. On the main layer use the forming or a completed breaking bar; optionally require an earlier first-time wick raid of a swing low/high and optionally require the breaking bar's range >= a multiple of the main-layer range mean OR its low > the high two bars earlier for bullish shifts OR its high < the low two bars earlier for bearish shifts. On the intermediate and faster layers use completed bars and neither optional filter.
Calculation: Bullish/bearish fair value gap = three completed higher-timeframe bars where the newest low > the oldest high for bullish, or newest high < oldest low for bearish, AND the gap height >= a multiple of that layer's range mean AND the middle bar closes in the gap direction with body size >= another multiple of that mean. The initial zone is between those two non-overlapping extremes. Optionally extend either zone edge to include an adjacent body gap whose wicks overlap.
Calculation: Bullish/bearish suspension block = a consecutive run of at least three completed main-layer bars, all closing above/below their opens, each opening strictly above/below the previous close, with no oversized time gap between consecutive bars; the zone lies between the oldest close and newest open and its height >= a multiple of the main-layer range mean.
Calculation: Zone direction = the original direction until a subsequent close crosses strictly beyond its far edge; thereafter the opposite direction until a later close crosses strictly beyond the opposite edge, when the zone is spent. For main-layer zones use subsequent higher-timeframe bars including the forming bar; for intermediate and faster gaps use subsequent chart bars. A spent zone retains its original direction if retained.
Calculation: Bullish/bearish reversal = a completed higher-timeframe bar wicks through a true swing low/high and closes strictly back inside, then on that bar or within a lookback of completed bars closes at least a displacement threshold above/below the lowest/highest wick since the raid. Cancel if a subsequent close crosses back beyond the raided level before displacement. The threshold is a price amount or a fraction of the last completed higher-timeframe day range; the faster layers use a window scaled to the main-layer duration and limited by their snapshot depth.
Calculation: Normalized EMA angle = round(degrees(acos(1 / sqrt(1 + rise^2)))) with the sign of the EMA change, where rise = (previous EMA - current EMA) / current typical price * (scale / (highest high - lowest low)) * lowest low over a chart-bar lookback.
Long: A failed low raid occurs.
Short: A failed high raid occurs.
Long: A bullish structure shift occurs.
Short: A bearish structure shift occurs.
Long: A bullish fair value gap or suspension block has bullish zone direction.
Short: A bearish fair value gap or suspension block has bearish zone direction.
Long: A bearish fair value gap or suspension block has inverted zone direction.
Short: A bullish fair value gap or suspension block has inverted zone direction.
Long: A bullish reversal occurs.
Short: A bearish reversal occurs.
Long: Chart close < midpoint of the forming main-layer bar's high and low.
Short: Chart close >= midpoint of the forming main-layer bar's high and low.
Long: Normalized EMA angle > chop threshold.
Short: Normalized EMA angle < -chop threshold.
Long: The forming main-layer bar's close >= its open.
Short: The forming main-layer bar's close < its open.