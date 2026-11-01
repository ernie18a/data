Calculation: Timeframe set = three ordered timeframes, shortest to longest; each may be higher than, equal to, or lower than the chart timeframe. For each timeframe, use its forming bar and preceding completed bars.
Calculation: AC[i] = Accelerator Oscillator on the timeframe set, with i=0 for the forming bar and i=1, 2, 3 for successive completed bars.
Calculation: Bullish AC condition = (AC[1] > AC[2] AND AC[2] > AC[3] AND AC[0] < 0 AND AC[0] > AC[1]) OR (AC[0] > AC[1] AND AC[1] > AC[2] AND AC[0] > 0).
Calculation: Bearish AC condition = (AC[1] < AC[2] AND AC[2] < AC[3] AND AC[0] > 0 AND AC[0] < AC[1]) OR (AC[0] < AC[1] AND AC[1] < AC[2] AND AC[0] < 0).
Calculation: Neutral AC condition = ((AC[1] < AC[2] OR AC[2] < AC[3]) AND AC[0] < 0 AND AC[0] > AC[1]) OR (AC[0] > AC[1] AND AC[1] < AC[2] AND AC[0] > 0) OR ((AC[1] > AC[2] OR AC[2] > AC[3]) AND AC[0] > 0 AND AC[0] < AC[1]) OR (AC[0] < AC[1] AND AC[1] > AC[2] AND AC[0] < 0).
Calculation: Directional scores for each timeframe = count of rising or falling close SMAs, respectively, across five increasingly long lookbacks, plus a larger weight for the corresponding AC condition. Initialize the AC contribution to zero; set it to the bullish or bearish weight when the respective AC condition holds, reset both contributions to zero when the neutral AC condition holds, and otherwise retain their previous values. The AC weight is three times the weight of one SMA.
Long: On any timeframe in the set, any one of the five close SMAs on the forming bar > the same SMA on the preceding completed bar.
Short: On any timeframe in the set, any one of the five close SMAs on the forming bar < the same SMA on the preceding completed bar.
Long: On any timeframe in the set, the bullish AC condition holds.
Short: On any timeframe in the set, the bearish AC condition holds.
Long: On any timeframe in the set, bullish score > bearish score.
Short: On any timeframe in the set, bearish score > bullish score.
Long: Bullish score on each timeframe in the set > the entry threshold.
Short: Bearish score on each timeframe in the set > the entry threshold.