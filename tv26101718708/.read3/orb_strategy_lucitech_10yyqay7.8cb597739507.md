Calculation: ORB high = highest high of bars with time inside [ORB start, ORB end) within the most recent ORB window
Calculation: ORB low = lowest low of bars with time inside [ORB start, ORB end) within the most recent ORB window
Calculation: ORB midpoint = (ORB high + ORB low) / 2
Calculation: Long breakout = close crosses above ORB high AND bar time outside [ORB start, ORB end) AND bar time before ORB cutoff
Calculation: Short breakout = close crosses below ORB low AND bar time outside [ORB start, ORB end) AND bar time before ORB cutoff
Calculation: RVOL = volume / SMA(volume, RVOL lookback) if SMA(volume, RVOL lookback) > 0, else 1
Calculation: Long stop level = low - ATR(ATR length, smoothing type) * ATR multiplier if stop type is ATR; low[candle length] if stop type is Candle; ORB midpoint if stop type is Midline; evaluated on the entry bar
Calculation: Short stop level = high + ATR(ATR length, smoothing type) * ATR multiplier if stop type is ATR; high[candle length] if stop type is Candle; ORB midpoint if stop type is Midline; evaluated on the entry bar
Calculation: Long target level = entry price + risk reward * (entry price - Long stop level)
Calculation: Short target level = entry price - risk reward * (Short stop level - entry price)
Calculation: Long breakeven reached = breakeven R > 0 AND high >= entry price + breakeven R * (entry price - Long stop level)
Calculation: Short breakeven reached = breakeven R > 0 AND low <= entry price - breakeven R * (Short stop level - entry price)
Long: Long breakout AND no Long breakout on an earlier bar since start of the most recent ORB window
Long: Long breakout AND no Long breakout on an earlier bar since start of the most recent ORB window AND (time filter off OR bar time in [time filter start, time filter end]) AND (day filter off OR day of week of bar is an allowed day) AND (month filter off OR month of bar is an allowed month) AND (position filter off OR allow long) AND (RVOL filter off OR RVOL >= RVOL threshold) AND position side is flat AND Long stop level < close
Short: Short breakout AND no Short breakout on an earlier bar since start of the most recent ORB window
Short: Short breakout AND no Short breakout on an earlier bar since start of the most recent ORB window AND (time filter off OR bar time in [time filter start, time filter end]) AND (day filter off OR day of week of bar is an allowed day) AND (month filter off OR month of bar is an allowed month) AND (position filter off OR allow short) AND (RVOL filter off OR RVOL >= RVOL threshold) AND position side is flat AND Short stop level > close
Exit: Long, bar after entry AND (high >= Long target level OR low <= Long stop level OR (Long breakeven reached on an earlier bar after entry AND low <= entry price))
Exit: Short, bar after entry AND (low <= Short target level OR high >= Short stop level OR (Short breakeven reached on an earlier bar after entry AND high >= entry price))