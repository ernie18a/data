Calculation: swing high(L) = most recent non-na value of pivot high(high, L, L)
Calculation: swing low(L) = most recent non-na value of pivot low(low, L, L)
Calculation: low sweep = low < swing low(sweep pivot length) AND close > swing low(sweep pivot length) AND (min(open, close) - low) / (high - low) > sweep wick fraction
Calculation: high sweep = high > swing high(sweep pivot length) AND close < swing high(sweep pivot length) AND (high - max(open, close)) / (high - low) > sweep wick fraction
Calculation: displacement candle = displacement filter off OR abs(close - open) > ATR(high, low, close, short ATR length) * displacement multiple
Calculation: chop filter passed = chop filter off OR ATR(high, low, close, short ATR length) > ATR(high, low, close, long ATR length) * chop ATR minimum
Calculation: volume filter passed = volume filter off OR volume > SMA(volume, volume average length) * volume multiple
Calculation: A++ session filter passed = strict session filter off OR (NY AM enabled AND bar time in New York is in NY AM window) OR (NY PM enabled AND bar time in New York is in NY PM window) OR (London enabled AND bar time in New York is in London window)
Calculation: premium zone = close > (3 * highest(high, PD lookback) + lowest(low, PD lookback)) / 4
Calculation: discount zone = close < (highest(high, PD lookback) + 3 * lowest(low, PD lookback)) / 4
Calculation: NY session open price = open of the most recent bar at the NY session open
Calculation: bullish FVG = bar where low > high[2] AND low - high[2] >= FVG min ticks * tick size; zone bottom high[2], zone top low
Calculation: bearish FVG = bar where high < low[2] AND low[2] - high >= FVG min ticks * tick size; zone bottom high, zone top low[2]
Calculation: inverted bullish FVG = bullish FVG among the most recent FVG max per direction bullish FVGs that has a close below its bottom at or before this bar and no high above its top after that close through this bar
Calculation: inverted bearish FVG = bearish FVG among the most recent FVG max per direction bearish FVGs that has a close above its top at or before this bar and no low below its bottom after that close through this bar
Calculation: active bullish FVG = bullish FVG among the most recent FVG max per direction bullish FVGs with no close below its bottom through this bar
Calculation: active bearish FVG = bearish FVG among the most recent FVG max per direction bearish FVGs with no close above its top through this bar
Calculation: active bullish OB = bullish OB among the most recent OB max per direction bullish OBs with no close below its mitigation level through this bar; bullish OB = bar where close > high[1] AND close - open > ATR(high, low, close, short ATR length) * OB displacement multiple, zone bottom min(open[1], close[1]), zone top max(open[1], close[1]); mitigation level = bottom + (top - bottom) * (1 - OB mitigation fraction)
Calculation: active bearish OB = bearish OB among the most recent OB max per direction bearish OBs with no close above its mitigation level through this bar; bearish OB = bar where close < low[1] AND open - close > ATR(high, low, close, short ATR length) * OB displacement multiple, zone top max(open[1], close[1]), zone bottom min(open[1], close[1]); mitigation level = top - (top - bottom) * (1 - OB mitigation fraction)
Calculation: bullish iFVG overlap = bar range overlaps an inverted bearish FVG
Calculation: bearish iFVG overlap = bar range overlaps an inverted bullish FVG
Calculation: bullish OB overlap = bar range overlaps an active bullish OB
Calculation: bearish OB overlap = bar range overlaps an active bearish OB
Calculation: bullish SMT = a pivot low(low, SMT pivot length, SMT pivot length) is confirmed on this bar AND it is below the previous confirmed pivot low AND (S&P 500 low at that pivot bar > S&P 500 low at the previous pivot bar OR Dow Jones low at that pivot bar > Dow Jones low at the previous pivot bar)
Calculation: bearish SMT = a pivot high(high, SMT pivot length, SMT pivot length) is confirmed on this bar AND it is above the previous confirmed pivot high AND (S&P 500 high at that pivot bar < S&P 500 high at the previous pivot bar OR Dow Jones high at that pivot bar < Dow Jones high at the previous pivot bar)
Calculation: bullish CISD = close > close[1] AND close[1] > close[2] AND most recent CISD is not bullish AND bars since most recent CISD >= CISD min bars
Calculation: bearish CISD = close < close[1] AND close[1] < close[2] AND most recent CISD is not bearish AND bars since most recent CISD >= CISD min bars
Calculation: bullish confirmation = (low sweep AND sweep pattern enabled AND close > open AND displacement candle AND close - swing low(sweep pivot length) <= ATR(high, low, close, short ATR length) * max entry distance) OR (bullish iFVG overlap AND iFVG pattern enabled AND close > open AND displacement candle) OR (bullish OB overlap AND close > open AND displacement candle)
Calculation: bearish confirmation = (high sweep AND sweep pattern enabled AND close < open AND displacement candle AND swing high(sweep pivot length) - close <= ATR(high, low, close, short ATR length) * max entry distance) OR (bearish iFVG overlap AND iFVG pattern enabled AND close < open AND displacement candle) OR (bearish OB overlap AND close < open AND displacement candle)
Calculation: bullish confluence count = number of true among: bullish confirmation; bars since last bullish SMT <= SMT recent window; bars since last low sweep <= sweep recency window; close > swing high(CHoCH pivot length) OR most recent CHoCH direction is bullish; bar range overlaps an active bullish FVG OR bullish iFVG overlap OR bullish OB overlap; bullish CISD; discount zone; close > NY session open price
Calculation: bearish confluence count = number of true among: bearish confirmation; bars since last bearish SMT <= SMT recent window; bars since last high sweep <= sweep recency window; close < swing low(CHoCH pivot length) OR most recent CHoCH direction is bearish; bar range overlaps an active bearish FVG OR bearish iFVG overlap OR bearish OB overlap; bearish CISD; premium zone; close < NY session open price
Calculation: stop distance = ATR(high, low, close, short ATR length) at the entry bar * stop multiple
Long: bullish confirmation AND bullish confluence count >= A++ min confluences AND A++ session filter passed AND chop filter passed AND volume filter passed AND (premium filter warn-only OR NOT premium zone) AND bars since last long setup > cooldown bars
Long: bullish confirmation AND bullish confluence count >= B min confluences AND bullish confluence count < A++ min confluences AND chop filter passed AND bars since last long setup > cooldown bars
Short: bearish confirmation AND bearish confluence count >= A++ min confluences AND A++ session filter passed AND chop filter passed AND volume filter passed AND (premium filter warn-only OR NOT discount zone) AND bars since last short setup > cooldown bars
Short: bearish confirmation AND bearish confluence count >= B min confluences AND bearish confluence count < A++ min confluences AND chop filter passed AND bars since last short setup > cooldown bars
Long: ((low < swing low(sweep pivot length) AND sweep pattern enabled) OR (bullish iFVG overlap AND iFVG pattern enabled) OR (bullish SMT AND SMT pattern enabled)) AND chop filter passed AND bars since last early long > early cooldown bars
Short: ((high > swing high(sweep pivot length) AND sweep pattern enabled) OR (bearish iFVG overlap AND iFVG pattern enabled) OR (bearish SMT AND SMT pattern enabled)) AND chop filter passed AND bars since last early short > early cooldown bars
Long: close > top of a bearish FVG among the most recent FVG max per direction bearish FVGs with no close above its top before this bar
Short: close < bottom of a bullish FVG among the most recent FVG max per direction bullish FVGs with no close below its bottom before this bar
Long: bullish SMT
Short: bearish SMT
Long: close > swing high(CHoCH pivot length) AND most recent CHoCH direction is not bullish
Short: close < swing low(CHoCH pivot length) AND most recent CHoCH direction is not bearish
Long: bullish CISD
Short: bearish CISD
Long: low sweep
Short: high sweep
Exit: long, bars after entry up to first exit AND (low <= entry price - stop distance OR high >= entry price + stop distance * first target multiple)
Exit: short, bars after entry up to first exit AND (high >= entry price + stop distance OR low <= entry price - stop distance * first target multiple)