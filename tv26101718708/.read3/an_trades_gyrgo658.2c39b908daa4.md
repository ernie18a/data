Calculation: T1 FVG sample = on chart bars when the requested T1 bar index changes, use requested T1 high/low with lookahead off (last completed T1 bar historically, still-forming T1 bar in real time).
Long: HTF FVG display enabled AND T1 FVG sample AND T1 high[gap offset] < T1 low
Short: HTF FVG display enabled AND T1 FVG sample AND T1 low[gap offset] > T1 high
Calculation: T1 bias = direction of the latest enabled T1 FVG event, neutral before any event; bearish takes precedence if both events occur on the same chart bar.
Long: T1 bias is bullish
Short: T1 bias is bearish
Long: raw FVG display enabled AND high[gap offset] < low
Short: raw FVG display enabled AND low[gap offset] > high
Calculation: Recent bullish sweep = low < the latest confirmed Pivot Low(low, swing lookback, swing lookback) AND close > that pivot, occurring no more than the sweep-validity bars ago, including the current bar.
Calculation: Recent bearish sweep = high > the latest confirmed Pivot High(high, swing lookback, swing lookback) AND close < that pivot, occurring no more than the sweep-validity bars ago, including the current bar.
Long: Recent bullish sweep
Short: Recent bearish sweep
Calculation: Bullish CISD = close > the open of the latest unconsumed bearish delivery bar; a delivery bar has high > low and abs(close - open) / (high - low) >= delivery body-ratio threshold; clear the reference after the condition occurs.
Calculation: Bearish CISD = close < the open of the latest unconsumed bullish delivery bar; a delivery bar has high > low and abs(close - open) / (high - low) >= delivery body-ratio threshold; clear the reference after the condition occurs.
Long: Bullish CISD
Short: Bearish CISD
Calculation: Bullish SMT divergence = traded-instrument low < the lowest traded-instrument low in the preceding SMT lookback chart bars AND comparison-instrument low > the lowest comparison-instrument low in those bars.
Calculation: Bearish SMT divergence = traded-instrument high > the highest traded-instrument high in the preceding SMT lookback chart bars AND comparison-instrument high < the highest comparison-instrument high in those bars.
Long: Bullish SMT divergence
Short: Bearish SMT divergence
Calculation: Nearest DOL distances = distance from close to the nearest of the latest DOL-history-limit confirmed Pivot Highs above close and Pivot Lows below close, separately; unavailable if no such level exists.
Calculation: Opposing DOL(side) = DOL filter enabled AND both nearest DOL distances exist AND (lower distance < upper distance for long; upper distance < lower distance for short).
Calculation: Adverse wick(side) = lower wick, min(open, close) - low, > ATR(ATR lookback) * wick multiplier for long; upper wick, high - max(open, close), > ATR(ATR lookback) * wick multiplier for short.
Calculation: Bullish IFVG condition = an active bearish FVG, formed when high < low[gap offset], is overlapped and closes above its top, OR the current bar overlaps an active bullish IFVG entry region. Track up to the FVG tracking limit of active source gaps per direction, discarding the oldest when full; on overlap, a close below the source gap bottom removes a bearish gap without inversion and a close within its boundaries marks it touched. The bullish IFVG entry region is the full source gap unless previously touched, then its bottom-to-midpoint half; expire it on a close above its top.
Calculation: Bearish IFVG condition = an active bullish FVG, formed when low > high[gap offset], is overlapped and closes below its bottom, OR the current bar overlaps an active bearish IFVG entry region. On overlap, a close above the source gap top removes a bullish gap without inversion and a close within its boundaries marks it touched. The bearish IFVG entry region is the full source gap unless previously touched, then its midpoint-to-top half; expire it on a close below its bottom.
Long: Bullish IFVG condition
Short: Bearish IFVG condition
Calculation: Long entry condition = Recent bullish sweep AND Bullish IFVG condition AND (CISD requirement disabled OR Bullish CISD) AND (SMT requirement disabled OR Bullish SMT divergence) AND NOT Opposing DOL(long) AND (wick filter disabled OR NOT Adverse wick(long)).
Calculation: Short entry condition = Recent bearish sweep AND Bearish IFVG condition AND (CISD requirement disabled OR Bearish CISD) AND (SMT requirement disabled OR Bearish SMT divergence) AND NOT Opposing DOL(short) AND (wick filter disabled OR NOT Adverse wick(short)).
Long: Long entry condition
Short: Short entry condition
Calculation: Directional score(side) = HTF-alignment weight when T1 bias matches side, neutral-HTF adjustment when T1 bias is neutral, and zero when opposite; plus recent-sweep weight, full or midpoint-only IFVG weight, CISD weight, SMT weight, and side-specific DOL-target weight when each applies; minus the opposing-DOL penalty and adverse-wick penalty when each applies. Use a separate parameter for each weight and penalty.
Calculation: Active directional score = long score when Long entry condition is true; otherwise short score when Short entry condition is true; otherwise the greater directional score.
Long: neither Long entry condition nor Short entry condition AND Directional score(long) >= Directional score(short)
Short: neither Long entry condition nor Short entry condition AND Directional score(long) < Directional score(short)
Long: Long entry condition AND Active directional score >= A+ threshold
Short: Short entry condition AND Active directional score >= A+ threshold