Calculation: Heiken-Ashi close = (open + high + low + close) / 4; Heiken-Ashi open = first (open + close) / 2, then previous Heiken-Ashi open and close averaged.
Calculation: Signal score = sum of enabled votes: +1/-1 for bullish/bearish Heiken-Ashi candle, Supertrend direction, and Heiken-Ashi close above/below the UT Bot trailing stop; ties contribute 0.
Calculation: UT Bot trailing stop = recursive stop at UT Bot source (Heiken-Ashi close) minus/plus the ATR-based loss; when source and prior source are both above/below prior stop, trail by the maximum/minimum of prior stop and source minus/plus loss; otherwise use source minus/plus loss according to which side of prior stop the source is on.
Calculation: Bollinger Bands = simple moving average of close ± a standard-deviation multiple; use the same lookback and multiplier for both bands.
Calculation: SMC pivots = swing highs/lows confirmed when the high/low at the swing lookback is strictly above/below all highs/lows since it; internal pivots use a shorter lookback. A pivot is unbroken until close crosses it; bullish/bearish structure bias updates on each such cross.
Calculation: ZigZag pivots = rolling highest high or lowest low over the ZigZag depth; track alternating high/low pivots, direction, and minimum bars between reversals. Classify highs against the previous high as higher/lower and lows against the previous low as higher/lower.
Long: Signal score > 0
Short: Signal score < 0
Long: MA1 crosses above MA2 OR MA2 crosses above MA3, where MA1 is shorter-term than MA2 and MA2 is shorter-term than MA3
Short: MA1 crosses below MA2 OR MA2 crosses below MA3, where MA1 is shorter-term than MA2 and MA2 is shorter-term than MA3
Long: Close crosses above an unbroken internal or swing pivot high
Short: Close crosses below an unbroken internal or swing pivot low
Long: Two bars ago close is below the lower Bollinger Band and is a down candle, one bar ago close is above the lower band and is an up candle, and current close is above the previous bar's high
Short: Two bars ago close is above the upper Bollinger Band and is an up candle, one bar ago close is below the upper band and is a down candle, and current close is below the previous bar's low
Long: A confirmed Marco pivot low is accepted after an opposite-type pivot when its percentage deviation from the previous pivot exceeds ATR(10) / close × 100 × the deviation parameter, or when no previous pivot exists
Short: A confirmed Marco pivot high is accepted after an opposite-type pivot when its percentage deviation from the previous pivot exceeds ATR(10) / close × 100 × the deviation parameter, or when no previous pivot exists
Long: Bullish ZigZag label is higher high OR higher low
Short: Bearish ZigZag label is lower high OR lower low
Long: Bullish fair value gap, with auto threshold disabled or the gap exceeding 0.5 × ATR(200): low two bars ago > current high
Short: Bearish fair value gap, with auto threshold disabled or the gap exceeding 0.5 × ATR(200): high two bars ago < current low