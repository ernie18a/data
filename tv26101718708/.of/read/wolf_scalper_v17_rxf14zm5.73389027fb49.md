Calculation: Bullish liquidity sweep = current low is below the latest confirmed pivot low and current close is above that pivot low, with the lower wick exceeding the configured fraction of the bar's range
Calculation: Bearish liquidity sweep = current high is above the latest confirmed pivot high and current close is below that pivot high, with the upper wick exceeding the configured fraction of the bar's range
Calculation: Bullish iFVG inversion = close crosses above the top of an un-inverted bearish fair value gap (the gap exists when current high is below the low two bars earlier, by at least the configured minimum gap size)
Calculation: Bearish iFVG inversion = close crosses below the bottom of an un-inverted bullish fair value gap (the gap exists when current low is above the high two bars earlier, by at least the configured minimum gap size)
Calculation: Bullish order block = the prior bar's open-close body after a bar closes above the preceding high with a bullish body larger than the configured ATR multiple; it remains active until close falls below its configured mitigation level
Calculation: Bearish order block = the prior bar's open-close body after a bar closes below the preceding low with a bearish body larger than the configured ATR multiple; it remains active until close rises above its configured mitigation level
Calculation: Bullish confirmed setup = a permitted bullish liquidity sweep, bullish iFVG zone, or active bullish order block, with a bullish current candle and required displacement; a sweep must also be within the configured maximum distance from the latest swing low
Calculation: Bearish confirmed setup = a permitted bearish liquidity sweep, bearish iFVG zone, or active bearish order block, with a bearish current candle and required displacement; a sweep must also be within the configured maximum distance from the latest swing high
Calculation: Bullish confluence score = sum of: bullish confirmed setup; recent bullish SMT; recent bullish liquidity sweep; bullish CHoCH or bullish trend state; price in bullish FVG, bullish iFVG, or bullish order block; bullish CISD; price in discount; close above the current day's 9:30 New York open
Calculation: Bearish confluence score = sum of: bearish confirmed setup; recent bearish SMT; recent bearish liquidity sweep; bearish CHoCH or bearish trend state; price in bearish FVG, bearish iFVG, or bearish order block; bearish CISD; price in premium; close below the current day's 9:30 New York open
Long: bullish confirmed setup AND bullish confluence score meets the B minimum AND (score is below the A++ minimum OR the A++ session, volume, and premium/discount gates pass) AND ATR(14) > ATR(50) × chop threshold AND (volume filter is disabled OR volume > volume moving average × volume threshold) AND (premium/discount blocking is disabled OR close is not in premium) AND same-side signal cooldown has elapsed
Long: lower low than the previous confirmed pivot low AND higher low in either comparison instrument at the corresponding pivot
Long: bullish CISD (two consecutive rising closes, or three consecutive rising closes), when its direction alternation and minimum spacing rules permit
Long: bullish CHoCH (close above the latest confirmed pivot high while trend state is not bullish)
Long: bullish liquidity sweep AND close > open
Long: bullish iFVG inversion
Long: price overlaps an active bullish iFVG zone
Long: early bullish condition (permitted sweep testing, bullish iFVG overlap, or bullish SMT) AND not in chop AND early-signal cooldown elapsed
Short: bearish confirmed setup AND bearish confluence score meets the B minimum AND (score is below the A++ minimum OR the A++ session, volume, and premium/discount gates pass) AND ATR(14) > ATR(50) × chop threshold AND (volume filter is disabled OR volume > volume moving average × volume threshold) AND (premium/discount blocking is disabled OR close is not in discount) AND same-side signal cooldown has elapsed
Short: higher high than the previous confirmed pivot high AND lower high in either comparison instrument at the corresponding pivot
Short: bearish CISD (two consecutive falling closes, or three consecutive falling closes), when its direction alternation and minimum spacing rules permit
Short: bearish CHoCH (close below the latest confirmed pivot low while trend state is not bearish)
Short: bearish liquidity sweep AND close < open
Short: bearish iFVG inversion
Short: price overlaps an active bearish iFVG zone
Short: early bearish condition (permitted sweep testing, bearish iFVG overlap, or bearish SMT) AND not in chop AND early-signal cooldown elapsed
Exit: long, low <= entry price - ATR(14) × stop multiple OR high >= entry price + ATR(14) × stop multiple × first-target multiple
Exit: short, high >= entry price + ATR(14) × stop multiple OR low <= entry price - ATR(14) × stop multiple × first-target multiple