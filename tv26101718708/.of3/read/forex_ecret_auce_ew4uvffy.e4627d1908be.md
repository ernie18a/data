Calculation: CRT high = highest high of chart bars within range session on the current day
Calculation: CRT low = lowest low of chart bars within range session on the current day
Calculation: T1 high = high of the last completed T1 bar, as seen on chart bars
Calculation: T1 low = low of the last completed T1 bar, as seen on chart bars
Calculation: Prior T1 high = high of the T1 bar completed before the last completed T1 bar, as seen on chart bars
Calculation: Prior T1 low = low of the T1 bar completed before the last completed T1 bar, as seen on chart bars
Calculation: T2 high = high of the last completed T2 bar, as seen on chart bars
Calculation: T2 low = low of the last completed T2 bar, as seen on chart bars
Calculation: Prior T2 high = high of the T2 bar completed before the last completed T2 bar, as seen on chart bars
Calculation: Prior T2 low = low of the T2 bar completed before the last completed T2 bar, as seen on chart bars
Calculation: ORB high = highest high of chart bars from ORB start for ORB length on the current day
Calculation: ORB low = lowest low of chart bars from ORB start for ORB length on the current day
Calculation: Last swing high = most recent value of PivotHigh(high, swing strength, swing strength)
Calculation: Last swing low = most recent value of PivotLow(low, swing strength, swing strength)
Calculation: Prior swing high = value of PivotHigh immediately before Last swing high
Calculation: Prior swing low = value of PivotLow immediately before Last swing low
Calculation: Key tolerance = if tolerance mode is percent of ATR, then tolerance percent / 100 * ATR(ATR length) of T2 bars at the last completed T2 bar; otherwise tolerance pips * pip size
Calculation: Near key level(price) = for some level among T2 high, T2 low, T2 midpoint, T1 high, T1 low, T1 midpoint, Prior T1 high, Prior T1 low, CRT high, CRT low, CRT midpoint (during sweep session only), ORB high, ORB low, ORB midpoint (after ORB window only), the absolute difference between the level and price is at most Key tolerance
Calculation: Swing low sweep = low < Last swing low AND close > Last swing low AND low has not been below Last swing low on any earlier bar since that swing low was confirmed AND (reversal session filter off OR bar time within reversal session)
Calculation: Swing high sweep = high > Last swing high AND close < Last swing high AND high has not been above Last swing high on any earlier bar since that swing high was confirmed AND (reversal session filter off OR bar time within reversal session)
Calculation: Buy volume = volume * (close - low) / (high - low), or half of volume when high = low
Calculation: Candle delta = 2 * Buy volume - volume
Calculation: Average absolute candle delta = SMA(absolute value of Candle delta, pressure length)
Calculation: Average volume = SMA(volume, pressure length)
Calculation: Volume available = volume has been greater than zero on some bar so far
Calculation: Buy pressure candle = Volume available AND Candle delta > Average absolute candle delta * pressure multiplier AND close > open AND volume > Average volume
Calculation: Sell pressure candle = Volume available AND Candle delta < -(Average absolute candle delta * pressure multiplier) AND close < open AND volume > Average volume
Calculation: Buyer share = 100 * SUM(Buy volume, pressure window) / SUM(volume, pressure window), or 50 when SUM(volume, pressure window) is zero
Calculation: Buy zone = box created on each Buy pressure candle with bottom = low and top = max(min(open, close), low + zone fraction * (high - low)), not created if it overlaps an existing Buy zone; it lasts until a close falls below its bottom
Calculation: Sell zone = box created on each Sell pressure candle with top = high and bottom = min(max(open, close), high - zone fraction * (high - low)), not created if it overlaps an existing Sell zone; it lasts until a close rises above its top
Long: low < CRT low AND close > CRT low AND bar time within sweep session AND no earlier bar in the same sweep session had low < CRT low and close > CRT low
Long: low < T1 low AND close > T1 low AND no earlier bar within the same T1 bar had low < T1 low and close > T1 low
Long: low < T2 low AND close > T2 low AND no earlier bar within the same T2 bar had low < T2 low and close > T2 low
Long: close > ORB high AND bar time within ORB signal period AND no earlier bar within ORB signal period had close > ORB high
Long: Swing low sweep AND (key-level filter off OR Near key level(Last swing low))
Long: Swing low sweep AND Near key level(Last swing low)
Long: close > Last swing high as of the most recent earlier Swing low sweep bar AND that bar is at most MSS window bars back AND no bar since then has had close above that Last swing high, close below that bar's low, or Swing high sweep true
Long: Buy pressure candle
Long: for any Buy zone created on an earlier bar with no close below its bottom through this bar, low <= top AND low[1] > top
Long: Volume available AND Buyer share >= buyer share threshold
Long: T2 high > Prior T2 high AND T2 low > Prior T2 low
Long: T1 high > Prior T1 high AND T1 low > Prior T1 low
Long: Last swing high > Prior swing high AND Last swing low > Prior swing low
Short: high > CRT high AND close < CRT high AND bar time within sweep session AND no earlier bar in the same sweep session had high > CRT high and close < CRT high
Short: high > T1 high AND close < T1 high AND no earlier bar within the same T1 bar had high > T1 high and close < T1 high
Short: high > T2 high AND close < T2 high AND no earlier bar within the same T2 bar had high > T2 high and close < T2 high
Short: close < ORB low AND bar time within ORB signal period AND no earlier bar within ORB signal period had close < ORB low
Short: Swing high sweep AND (key-level filter off OR Near key level(Last swing high))
Short: Swing high sweep AND Near key level(Last swing high)
Short: close < Last swing low as of the most recent earlier Swing high sweep bar AND that bar is at most MSS window bars back AND no bar since then has had close below that Last swing low, close above that bar's high, or Swing low sweep true
Short: Sell pressure candle
Short: for any Sell zone created on an earlier bar with no close above its top through this bar, high >= bottom AND high[1] < bottom
Short: Volume available AND Buyer share < buyer share threshold
Short: T2 high < Prior T2 high AND T2 low < Prior T2 low
Short: T1 high < Prior T1 high AND T1 low < Prior T1 low
Short: Last swing high < Prior swing high AND Last swing low < Prior swing low
Exit: long, high >= (CRT high + CRT low) / 2 OR high >= CRT high
Exit: short, low <= (CRT high + CRT low) / 2 OR low <= CRT low
Exit: long, high >= (T1 high + T1 low) / 2 OR high >= T1 high
Exit: short, low <= (T1 high + T1 low) / 2 OR low <= T1 low
Exit: long, high >= (T2 high + T2 low) / 2 OR high >= T2 high
Exit: short, low <= (T2 high + T2 low) / 2 OR low <= T2 low
Exit: long, close < (ORB high + ORB low) / 2
Exit: short, close > (ORB high + ORB low) / 2