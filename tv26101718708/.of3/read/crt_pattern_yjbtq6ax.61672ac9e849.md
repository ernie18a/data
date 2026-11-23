Calculation: Range = high − low of a bar
Calculation: SetupBar = T1 bar where abs(close − open) ÷ Range × 100 ≥ body percent threshold AND Range ≥ candle size multiple × ATR(ATR lookback, T1, last completed bar)
Calculation: ArmedLongSetup = SetupBar R where close(R) < open(R) AND every T1 bar completed after R and before the last completed T1 bar has low ≥ low(R) AND high ≤ low(R) + pullback percent ÷ 100 × Range(R)
Calculation: ArmedShortSetup = SetupBar R where close(R) ≥ open(R) AND every T1 bar completed after R and before the last completed T1 bar has high ≤ high(R) AND low ≥ high(R) − pullback percent ÷ 100 × Range(R)
Calculation: LongFormed = (R, S) where R in ArmedLongSetup, S is a T1 bar where the Long condition held for R, since S completed no chart bar before the current bar has high ≥ high(R), and no T1 bar completed after S and before the current bar has close < low(S)
Calculation: ShortFormed = (R, S) where R in ArmedShortSetup, S is a T1 bar where the Short condition held for R, since S completed no chart bar before the current bar has low ≤ low(R), and no T1 bar completed after S and before the current bar has close > high(S)
Calculation: ZoneEdge = the level chosen by the discount border setting: for LongFormed, midpoint of R, low of R, high of S, open of S, or close of S; for ShortFormed, midpoint of R, high of R, low of S, open of S, or close of S
Long: T1 bar just completed AND low(T1, last completed bar) < low(R) AND close(T1, last completed bar) > low(R) AND high(T1, last completed bar) ≤ low(R) + pullback percent ÷ 100 × Range(R) for some R in ArmedLongSetup
Short: T1 bar just completed AND high(T1, last completed bar) > high(R) AND close(T1, last completed bar) < high(R) AND low(T1, last completed bar) ≥ high(R) − pullback percent ÷ 100 × Range(R) for some R in ArmedShortSetup
Long: LongFormed AND close ≤ ZoneEdge AND close ≥ low(S) AND high < high(R) AND close(T1, last completed bar) ≥ low(S)
Short: ShortFormed AND close ≥ ZoneEdge AND close ≤ high(S) AND low > low(R) AND close(T1, last completed bar) ≤ high(S)
Exit: long, LongFormed AND (high ≥ high(R) OR (T1 bar just completed AND close(T1, last completed bar) < low(S)))
Exit: short, ShortFormed AND (low ≤ low(R) OR (T1 bar just completed AND close(T1, last completed bar) > high(S)))