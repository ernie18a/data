Calculation: Analysis timeframes = three ordered timeframes, from shortest to longest; each may be higher than, equal to, or lower than the chart timeframe. On each, evaluate the current, still-forming bar and preceding completed bars; for a lower timeframe, use the latest available bar.
Calculation: AC[i] = Accelerator Oscillator on an analysis timeframe, where i=0 is the current bar and increasing i refers to older bars.
Calculation: Bullish AC condition = (AC[1] > AC[2] AND AC[2] > AC[3] AND AC[0] < 0 AND AC[0] > AC[1]) OR (AC[0] > AC[1] AND AC[1] > AC[2] AND AC[0] > 0).
Calculation: Bearish AC condition = (AC[1] < AC[2] AND AC[2] < AC[3] AND AC[0] > 0 AND AC[0] < AC[1]) OR (AC[0] < AC[1] AND AC[1] < AC[2] AND AC[0] < 0).
Calculation: Neutral AC condition = ((AC[1] < AC[2] OR AC[2] < AC[3]) AND AC[0] < 0 AND AC[0] > AC[1]) OR (AC[0] > AC[1] AND AC[1] < AC[2] AND AC[0] > 0) OR ((AC[1] > AC[2] OR AC[2] > AC[3]) AND AC[0] > 0 AND AC[0] < AC[1]) OR (AC[0] < AC[1] AND AC[1] > AC[2] AND AC[0] < 0).
Calculation: AC direction = bullish or bearish when the corresponding AC condition holds, neutral when the neutral condition holds, otherwise its previous value; initialize neutral.
Calculation: Directional score on each analysis timeframe = the count of five close SMAs with distinct, increasing lookbacks whose current value is respectively greater than or less than their previous-bar value, plus three times the indicator that AC direction is respectively bullish or bearish. Equal SMA values contribute to neither score.
Long: On any analysis timeframe, any one of the five current close SMAs > its previous-bar value.
Short: On any analysis timeframe, any one of the five current close SMAs < its previous-bar value.
Long: Bullish AC condition holds on any analysis timeframe.
Short: Bearish AC condition holds on any analysis timeframe.
Long: Bullish directional score > bearish directional score on any analysis timeframe.
Short: Bearish directional score > bullish directional score on any analysis timeframe.
Long: Bullish directional score > entry threshold on every analysis timeframe.
Short: Bearish directional score > entry threshold on every analysis timeframe.