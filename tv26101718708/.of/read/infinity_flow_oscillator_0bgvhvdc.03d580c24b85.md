Calculation: RMI flow = 2 × (RMI − 50), where RMI uses the source minus its momentum-lookback value, Wilder-smoothed positive and negative changes, and the usual relative-strength formula.
Calculation: MFI flow = 2 × (Money Flow Index using typical price and volume − 50).
Calculation: WaveTrend flow = WaveTrend oscillator divided by its scale factor and clamped to −100…100; the oscillator uses fast-smoothed typical-price deviation and a slower-smoothed normalized deviation.
Calculation: ATR ratio = current ATR divided by its simple moving average over a longer lookback.
Calculation: Compression = clamp((1 − ATR ratio) × 100, 0, 100); compression is on when it is at or above its threshold.
Calculation: Expansion = clamp((ATR ratio − 1) × 100, −100, 100).
Calculation: Directional bias = 1 when close is at or above its EMA, otherwise −1.
Calculation: Flow = EMA of the clamped weighted average of RMI flow, MFI flow, WaveTrend flow, and expansion × directional bias; signal = EMA of flow.
Long: flow crosses above signal AND flow > −strong level OR flow crosses above strong level OR flow crosses above extreme level OR compression was on on the previous bar and is off now AND flow > 0 AND flow > signal.
Short: flow crosses below signal AND flow < strong level OR flow crosses below −strong level OR flow crosses below −extreme level OR compression was on on the previous bar and is off now AND flow < 0 AND flow < signal.