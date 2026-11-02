Calculation: Structure pivots = For each of two lookbacks, internal shorter than swing, track a leg initially bearish. If the high that many bars ago exceeds every high since then, set the leg bearish; otherwise, if the low that many bars ago is below every low since then, set it bullish. On a change to bearish, record that earlier high as the latest high pivot; on a change to bullish, record that earlier low as the latest low pivot. Reset the corresponding pivot's crossed flag when a new pivot is recorded.
Calculation: Support and resistance = The latest confirmed pivot low and pivot high, respectively, using configurable left and right confirmation lengths, made available one bar after confirmation.
Calculation: Volume oscillator = 100 × (shorter-period EMA of volume − longer-period EMA of volume) / longer-period EMA of volume.
Calculation: Gap threshold = Either zero or twice the cumulative sum, over chart bars, of the absolute completed gap-timeframe candle change divided by the chart bar index; add a candle change only on the first chart bar of a new gap-timeframe bar. Candle change = (close − open) / (open × 100).
Long: Close crosses above an uncrossed swing high pivot; mark that pivot crossed.
Short: Close crosses below an uncrossed swing low pivot; mark that pivot crossed.
Long: Close crosses above an uncrossed internal high pivot AND the internal high pivot differs from the swing high pivot AND, if the optional confluence filter is enabled, high − max(close, open) > min(close, open − low); mark that pivot crossed.
Short: Close crosses below an uncrossed internal low pivot AND the internal low pivot differs from the swing low pivot AND, if the optional confluence filter is enabled, high − max(close, open) < min(close, open − low); mark that pivot crossed.
Long: A new swing low pivot is greater than or equal to the previous swing low pivot.
Short: A new swing low pivot is below the previous swing low pivot.
Long: A new swing high pivot is above the previous swing high pivot.
Short: A new swing high pivot is less than or equal to the previous swing high pivot.
Long: Close crosses above resistance AND open − low <= close − open AND volume oscillator > volume threshold.
Long: Close crosses above resistance AND open − low > close − open.
Short: Close crosses below support AND open − close >= high − open AND volume oscillator > volume threshold.
Short: Close crosses below support AND open − close < high − open.
Long: A new higher-timeframe bar starts AND its forming low > the high of the higher-timeframe bar two bars earlier AND the last completed higher-timeframe close > that earlier high AND the last completed higher-timeframe candle change > gap threshold.
Short: A new higher-timeframe bar starts AND its forming high < the low of the higher-timeframe bar two bars earlier AND the last completed higher-timeframe close < that earlier low AND the negative of the last completed higher-timeframe candle change > gap threshold.