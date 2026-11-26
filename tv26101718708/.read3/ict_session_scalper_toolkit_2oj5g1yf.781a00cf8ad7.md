Calculation: Large body = abs(close - open) > displacement multiple * SMA(abs(close - open), body lookback)
Calculation: Displacement up = close > open AND Large body
Calculation: Displacement down = close < open AND Large body
Calculation: Bullish FVG = zone with bottom high[2] and top low, created when low > high[2] AND Displacement up[1]; latest max FVGs kept
Calculation: Bearish FVG = zone with bottom high and top low[2], created when high < low[2] AND Displacement down[1]; latest max FVGs kept
Calculation: Bullish IFVG validation = first chart close above the top of a Bearish FVG
Calculation: Bearish IFVG validation = first chart close below the bottom of a Bullish FVG
Calculation: HTF zone = on each new bar of T1 or T2, from its last completed bars: bullish zone with bottom high[2] and top low when low > high[2], or bearish zone with bottom high and top low[2] when high < low[2]; zone removed on a chart close below its bottom (bullish) or above its top (bearish); latest max HTF zones kept
Calculation: Dealing midpoint = (Highest(high, dealing lookback) + Lowest(low, dealing lookback)) / 2
Calculation: Midnight open = open of the latest midnight bar
Calculation: Day gap midpoint = (prior bar close + open) / 2 at the latest daily reopen not on Sunday
Calculation: Week gap midpoint = (prior bar close + open) / 2 at the latest daily reopen on Sunday
Calculation: Sellside pool = a level added on its confirmation bar as PivotLow(low, pivot length, pivot length) starting at 1 touch, or on the first bar after the Asia session as the Asia session low starting at the equal touch count, or at each daily reopen as the last completed T2 low starting at the equal touch count; a new level within equal-level multiple * ATR(long lookback) of the first unswept Sellside pool merges into it at the lower level and adds 1 touch; latest max pools kept
Calculation: Buyside pool = a level added on its confirmation bar as PivotHigh(high, pivot length, pivot length) starting at 1 touch, or on the first bar after the Asia session as the Asia session high starting at the equal touch count, or at each daily reopen as the last completed T2 high starting at the equal touch count; a new level within equal-level multiple * ATR(long lookback) of the first unswept Buyside pool merges into it at the higher level and adds 1 touch; latest max pools kept
Calculation: Sellside sweep = low < level of an unswept Sellside pool, including pools added on this bar; that pool becomes swept
Calculation: Buyside sweep = high > level of an unswept Buyside pool, including pools added on this bar; that pool becomes swept
Calculation: Bullish SMT = low < Lowest(low, SMT swing window)[1] AND NOT (correlated low < Lowest(correlated low, SMT swing window)[1])
Calculation: Bearish SMT = high > Highest(high, SMT swing window)[1] AND NOT (correlated high > Highest(correlated high, SMT swing window)[1])
Calculation: Recent bullish SMT = Bullish SMT on this bar or within the last max sweep-to-entry bars
Calculation: Recent bearish SMT = Bearish SMT on this bar or within the last max sweep-to-entry bars
Calculation: Long armed = bars since most recent Sellside sweep <= max sweep-to-entry bars AND no Long entry on an earlier bar since that sweep
Calculation: Short armed = bars since most recent Buyside sweep <= max sweep-to-entry bars AND no Short entry on an earlier bar since that sweep
Calculation: Long displacement = Long armed AND Displacement up on or after the most recent Sellside sweep bar
Calculation: Short displacement = Short armed AND Displacement down on or after the most recent Buyside sweep bar
Calculation: Stop cap = point-cap mode ? (bar in New York killzone ? NY point cap : London point cap) : ATR cap multiple * ATR(short lookback)
Calculation: Long stop = lowest low on or after the most recent Sellside sweep bar - stop buffer
Calculation: Short stop = highest high on or after the most recent Buyside sweep bar + stop buffer
Long: Long displacement AND (Bullish IFVG validation OR (low <= top AND close >= bottom of a bullish zone (Bullish FVG, or Bearish FVG after Bullish IFVG validation) with no chart close below its bottom yet, first such bar after its creation or validation)) AND bar in killzone AND close - Long stop <= Stop cap AND (bool(an HTF zone contains close or Long stop) + bool(abs(close - Midnight open) < ATR(short lookback) OR abs(close - Day gap midpoint) < ATR(short lookback) OR abs(close - Week gap midpoint) < ATR(short lookback)) + bool(Recent bullish SMT) + bool(most recent Sellside sweep took a pool with touch count >= equal touch count) + bool(count of unswept Buyside pools above close within wide range multiple * ATR(short lookback) >= pool count threshold) + bool(close <= Dealing midpoint) - bool(count of unswept Sellside pools below close within narrow range multiple * ATR(short lookback) >= pool count threshold)) >= grade threshold
Short: Short displacement AND (Bearish IFVG validation OR (high >= bottom AND close <= top of a bearish zone (Bearish FVG, or Bullish FVG after Bearish IFVG validation) with no chart close above its top yet, first such bar after its creation or validation)) AND bar in killzone AND Short stop - close <= Stop cap AND (bool(an HTF zone contains close or Short stop) + bool(abs(close - Midnight open) < ATR(short lookback) OR abs(close - Day gap midpoint) < ATR(short lookback) OR abs(close - Week gap midpoint) < ATR(short lookback)) + bool(Recent bearish SMT) + bool(most recent Buyside sweep took a pool with touch count >= equal touch count) + bool(count of unswept Sellside pools below close within wide range multiple * ATR(short lookback) >= pool count threshold) + bool(close > Dealing midpoint) - bool(count of unswept Buyside pools above close within narrow range multiple * ATR(short lookback) >= pool count threshold)) >= grade threshold
Long: Displacement up
Long: Bullish IFVG validation
Long: Sellside sweep
Long: Bullish SMT AND Sellside sweep
Long: Long armed
Long: Long displacement
Long: close > Midnight open
Long: close <= Dealing midpoint
Long: Recent bullish SMT
Short: Displacement down
Short: Bearish IFVG validation
Short: Buyside sweep
Short: Bearish SMT AND Buyside sweep
Short: Short armed
Short: Short displacement
Short: close <= Midnight open
Short: close > Dealing midpoint
Short: Recent bearish SMT AND NOT Recent bullish SMT