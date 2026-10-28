Calculation: Estimated buy/sell volume per bar = split volume using the configured method: candle position (buy = volume × (close − low)/(high − low); sell = volume × (high − close)/(high − low), split equally if high = low), candle direction (all volume to the close-versus-open side, split equally if equal), or lower-timeframe candle direction (same close-versus-open rule, summed over intrabars; fall back to candle position if intrabar data is unavailable).
Calculation: Volume delta = sum of estimated buy volume minus estimated sell volume over the configured lookback.
Calculation: Delta score = clamp(50 + 25 × volume delta / 100-bar average of absolute volume delta, 0, 100); use 50 if that average is zero.
Calculation: CVD = cumulative estimated buy volume minus estimated sell volume; CVD state is bullish when CVD is above its EMA and its 5-bar change is positive, bearish when below its EMA and its 5-bar change is negative, otherwise neutral.
Calculation: EMA state is bullish when close > fast EMA > slow EMA; bearish when close < fast EMA < slow EMA; otherwise neutral.
Calculation: Structure state compares the two latest confirmed pivot highs and the two latest confirmed pivot lows: bullish if both latest pivots are higher, bearish if both are lower, otherwise neutral. Pivot highs/lows use equal configured left/right lookbacks.
Calculation: Timeframe bull percentage = weighted average of delta score, CVD score (100/0/50 for bullish/bearish/neutral), EMA score (100/0/50), and structure score (100/0/50). Component weights are configured.
Calculation: Overall bull percentage = weighted average of the visible, available timeframe bull percentages. Each timeframe uses its configured aggregation; by default use its forming bar, or the last completed bar when confirmed-bar mode is enabled.
Calculation: Latest fair value gap = most recent bullish gap (current low > high two bars earlier) or bearish gap (current high < low two bars earlier); bullish zone is [high two bars earlier, current low], bearish zone is [current high, low two bars earlier].
Calculation: Latest order block = the prior opposite candle's high-low zone for the most recent impulse candle, where the impulse body is at least the configured multiple of ATR: bullish impulse closes above open and the prior candle closes below open; bearish impulse closes below open and the prior candle closes above open.
Long: timeframe volume delta > 0
Short: timeframe volume delta < 0
Long: CVD > its EMA AND CVD − CVD five bars earlier > 0
Short: CVD < its EMA AND CVD − CVD five bars earlier < 0
Long: close > fast EMA AND fast EMA > slow EMA
Short: close < fast EMA AND fast EMA < slow EMA
Long: latest confirmed pivot high > preceding confirmed pivot high AND latest confirmed pivot low > preceding confirmed pivot low
Short: latest confirmed pivot high < preceding confirmed pivot high AND latest confirmed pivot low < preceding confirmed pivot low
Long: timeframe bull percentage >= configured bull threshold
Short: timeframe bull percentage <= configured bear threshold
Long: overall bull percentage crosses above configured bull threshold
Short: overall bull percentage crosses below configured bear threshold
Long: every visible timeframe bull percentage >= configured bull threshold
Short: every visible timeframe bull percentage <= configured bear threshold
Long: third configured timeframe changes from bear to bull (bull percentage crosses from <= bear threshold to >= bull threshold)
Short: third configured timeframe changes from bull to bear (bull percentage crosses from >= bull threshold to <= bear threshold)
Long: RSI > 50 (bullish label) OR RSI >= 55 (bullish cell)
Short: RSI < 50 (bearish label) OR RSI <= 45 (bearish cell)
Long: RSI <= 30
Short: RSI >= 70
Long: latest fair value gap is bullish
Short: latest fair value gap is bearish
Long: latest order block is bullish
Short: latest order block is bearish