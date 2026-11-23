Calculation: BullSweep = low[1] < Lowest(low[2], sweep depth) AND (close[1] > close[2] if body-close option is on, else close[1] > open[1]), on T1 bars at the last completed bar
Calculation: BearSweep = high[1] > Highest(high[2], sweep depth) AND (close[1] < close[2] if body-close option is on, else close[1] < open[1]), on T1 bars at the last completed bar
Calculation: Ribbon(T) = 1 if Above > 0 AND Below <= lag limit, else -1 if Below > 0 AND Above <= lag limit, else 0, where Above = count of enabled EMA periods p1..p8 with close[1] > EMA(close, p)[1] and Below = count of enabled EMA periods with close[1] < EMA(close, p)[1], on T bars at the last completed bar
Calculation: BullFVG(T) = low[1] > high[3], on T bars at the last completed bar; its zone runs from high[3] (bottom) to low[1] (top)
Calculation: BearFVG(T) = high[1] < low[3], on T bars at the last completed bar; its zone runs from high[1] (bottom) to low[3] (top)
Calculation: BullOB(T) = close[1] > open[1] AND abs(close[1] - open[1]) > SMA(abs(close - open), OB length)[1], on T bars at the last completed bar
Calculation: BearOB(T) = close[1] < open[1] AND abs(close[1] - open[1]) > SMA(abs(close - open), OB length)[1], on T bars at the last completed bar
Calculation: ADRPercent = (high - low) * 100 / SMA(high - low, ADR length)[1], on T4 bars at the last completed bar
Calculation: Swept(Long) = count of i from 2 to swept window where low[1] < low[i]; Swept(Short) = count of i from 2 to swept window where high[1] > high[i]; on T1 bars at the last completed bar
Calculation: Setup(Long) = time(T1) != time(T1)[1] AND BullSweep AND (ADR filter option is off OR ADRPercent <= ADR max) AND (alignment option is off OR (Ribbon(T1) = 1 AND Ribbon(T2) = 1)), on chart bars
Calculation: Setup(Short) = time(T1) != time(T1)[1] AND BearSweep AND (ADR filter option is off OR ADRPercent <= ADR max) AND (alignment option is off OR (Ribbon(T1) = -1 AND Ribbon(T2) = -1)), on chart bars
Calculation: Entry = close[1] of T1 bars at the last completed bar, taken on the setup bar (the chart bar where Setup(Long) or Setup(Short) is true)
Calculation: Stop = low[1] of T1 bars at the last completed bar, taken on the setup bar of a long setup; high[1] for a short setup
Calculation: Target = liquidity level if liquidity-target option is on and the liquidity level is beyond Entry +/- abs(Entry - Stop), else Entry +/- R multiple * abs(Entry - Stop) (+ for long, - for short); liquidity level = Highest(high[1], liquidity lookback) for long, Lowest(low[1], liquidity lookback) for short, on T1 bars at the last completed bar, taken on the setup bar
Calculation: LondonTookAsia = since the most recent Asia window start (New York time), some chart bar inside the London KZ window had high > Asia high or low < Asia low, where Asia high = highest high and Asia low = lowest low of chart bars inside the Asia window
Calculation: Score(Long) = max(0, [Swept(Long) >= swept threshold] + [chart bar inside London KZ or NY KZ window] + [wick-in-FVG option is on AND (Stop <= top AND Entry > bottom) for the most recent BullFVG zone of T1, or for that of T2, recorded on an earlier chart bar] + [BullOB(T2) OR BullFVG(T2)] - [Asia rule option is on AND chart bar inside NY KZ window AND NOT LondonTookAsia]), taken on the setup bar
Calculation: Score(Short) = max(0, [Swept(Short) >= swept threshold] + [chart bar inside London KZ or NY KZ window] + [wick-in-FVG option is on AND (Stop >= bottom AND Entry < top) for the most recent BearFVG zone of T1, or for that of T2, recorded on an earlier chart bar] + [BearOB(T2) OR BearFVG(T2)] - [Asia rule option is on AND chart bar inside NY KZ window AND NOT LondonTookAsia]), taken on the setup bar
Calculation: Grade(side) = A+ if Score(side) >= A+ threshold, else A if Score(side) >= A threshold, else B
Long: Setup(Long)
Long: Setup(Long) AND Grade(Long) >= alert grade, with B < A < A+
Long: latest setup is long AND setup age <= validity window in chart bars AND no zone marked since that setup AND ((H1 OB option is on AND BullOB(T2)) OR (H1 FVG option is on AND BullFVG(T2)) OR (15m FVG option is on AND BullFVG(T3)))
Short: Setup(Short)
Short: Setup(Short) AND Grade(Short) >= alert grade, with B < A < A+
Short: latest setup is short AND setup age <= validity window in chart bars AND no zone marked since that setup AND ((H1 OB option is on AND BearOB(T2)) OR (H1 FVG option is on AND BearFVG(T2)) OR (15m FVG option is on AND BearFVG(T3)))
Exit: long, NOT Setup(Long) AND (low <= Stop OR high >= Target)
Exit: short, NOT Setup(Short) AND (high >= Stop OR low <= Target)