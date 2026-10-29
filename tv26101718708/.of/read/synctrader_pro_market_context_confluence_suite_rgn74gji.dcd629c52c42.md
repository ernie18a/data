Calculation: Bar offsets use [0] for the current bar and [n] for n bars ago. A cross above means the current value is greater and its previous value was less than or equal; a cross below is the converse.
Calculation: Fractal levels = the latest confirmed pivot high and pivot low, each with the same number of bars on both sides. Update a pivot only after its right-side bars have completed.
Calculation: Fractal direction = initially bullish; set bullish when high crosses above the latest fractal high, bearish when low crosses below the latest fractal low, and otherwise retain the previous direction. An upward cross takes priority if both occur.
Calculation: Gap direction = initially bullish; set bullish when low > high[2], bearish when high < low[2], and otherwise retain the previous direction.
Calculation: Regime = initialize to range. Bollinger width is (upper Bollinger band - lower Bollinger band) / Bollinger basis. Enter squeeze when width < its longer-lookback SMA times a squeeze-entry multiplier AND the Bollinger bands are inside the Keltner channel; retain squeeze until width > its SMA times a larger squeeze-exit multiplier OR the bands are no longer inside the channel. Enter trend when ADX >= its entry threshold; retain trend while ADX >= its lower exit threshold. The candidate is squeeze if squeeze is active, otherwise trend if trend is active, otherwise range. Change regime only after the candidate persists for the configured number of completed bars.
Calculation: Trendline levels = either project the line through the two latest confirmed same-type fractals, or project a line anchored at the latest fractal whose slope is sum((bar index - pivot index) * (high or low - pivot price)) / sum((bar index - pivot index)^2), using bars after the pivot through the previous bar. High fractals produce the upper level and low fractals the lower level.
Calculation: Rising segments = starting at the current low, find the nearest earlier lower low within the segment lookback; repeat from that low, then repeat from the second low. Falling segments use the nearest earlier higher highs in the same way.
Calculation: Bias score = EMA of the weighted average of fractal direction and gap direction, with the gap weight reduced during squeeze and an additional neutral component included in the denominator, plus the enabled trendline and segment contributions. For each contribution, set its state to +1 on its bullish condition, -1 on its bearish condition, bullish taking priority, and otherwise multiply its prior state by a decay factor; average enabled states, clamp to a symmetric limit, and reduce the result when ATR / SMA of ATR is below a threshold. Clamp the sum to [-1,1], multiply by a regime factor smaller in squeeze than range and smaller in range than trend, and further reduce it at each reached range-exhaustion threshold. Convert to a centered score as midpoint + scale times that result. For intraday chart bars, range exhaustion is the forming higher-timeframe session range divided by the average range of completed higher-timeframe sessions; otherwise it is the current bar range divided by its SMA.
Calculation: Confirmed bias = initially neutral. From neutral, become bullish when the bias score is >= the bullish entry threshold for the required consecutive completed bars, or bearish when it is <= the bearish entry threshold for the required consecutive completed bars. From bullish, become neutral when the score is <= the lower bullish exit threshold for the required consecutive completed bars; from bearish, become neutral when it is >= the higher bearish exit threshold for the required consecutive completed bars. Evaluate entry only while neutral.
Calculation: Inside bar at offset n = high[n] < high[n+1] AND low[n] > low[n+1].
Calculation: Basic bullish fakey = an inside bar exists within the configured recent bars AND current low is below that inside bar's low AND current close is above its high. Basic bearish fakey = an inside bar exists within the same recent bars AND current high is above that inside bar's high AND current close is below its low.
Calculation: Extended bullish fakey = (inside bar[1] AND low < low[1] AND close > open[1] AND close > open) OR (inside bar[2] AND close[1] < low[2] AND close > close[1] AND high > high[1]) OR (inside bar[1] AND low < low[2] AND close > close[1] AND close > open) OR (inside bar[2] AND close[1] < low[3] AND close > open AND close > open[1]).
Calculation: Extended bearish fakey = (inside bar[1] AND high > high[1] AND close < open[1] AND close < open) OR (inside bar[2] AND close[1] > high[2] AND close < close[1] AND low < low[1]) OR (inside bar[1] AND high > high[2] AND close < open AND close < close[1]) OR (inside bar[2] AND close[1] > high[3] AND close < open AND close < close[1]).
Long: High crosses above the latest confirmed fractal high.
Short: Low crosses below the latest confirmed fractal low.
Long: Gap direction = bullish.
Short: Gap direction = bearish.
Long: Fractal direction = bullish.
Short: Fractal direction = bearish.
Long: The same gap-direction or fractal-direction comparison holds on a higher or lower timeframe, using either its last completed bar or its still-forming bar.
Short: The same gap-direction or fractal-direction comparison holds on a higher or lower timeframe, using either its last completed bar or its still-forming bar.
Long: Low > high[2] on the chart timeframe OR the last completed higher or lower timeframe bar's low > the high two bars before it.
Short: High < low[2] on the chart timeframe OR the last completed higher or lower timeframe bar's high < the low two bars before it.
Long: Confirmed bias = bullish OR bias score > bullish score-color threshold.
Short: Confirmed bias = bearish OR bias score < bearish score-color threshold.
Long: Confirmed bias = bullish on a higher or lower timeframe, using either its last completed bar or its still-forming bar; calculate the bias score and regime on that timeframe.
Short: Confirmed bias = bearish on a higher or lower timeframe, using either its last completed bar or its still-forming bar; calculate the bias score and regime on that timeframe.
Long: Shorter EMA of close > longer EMA of close on the previous bar.
Short: Shorter EMA of close <= longer EMA of close on the previous bar.
Long: SMA or EMA of close >= its previous value.
Short: SMA or EMA of close < its previous value.
Long: Close > upper trendline level.
Short: Close < lower trendline level.
Long: High > high[1] AND three rising segments exist.
Short: Low < low[1] AND three falling segments exist.
Long: The selected price low or close < its lowest value over the preceding lookback AND RSI, MACD line, or MACD signal line > its lowest value over the same preceding lookback; OR the selected price low or close > its preceding lookback low AND the oscillator < its preceding lookback low.
Short: The selected price high or close > its highest value over the preceding lookback AND RSI, MACD line, or MACD signal line < its highest value over the same preceding lookback; OR the selected price high or close < its preceding lookback high AND the oscillator > its preceding lookback high.
Long: Low = highest low over the lookback including the current bar AND the previous emitted lookback-extreme decision was short or neither direction has yet been emitted.
Short: High = lowest high over the lookback including the current bar AND the previous emitted lookback-extreme decision was long or neither direction has yet been emitted.
Long: High > high[1] AND low < low[1] AND close < low[1].
Short: High > high[1] AND low < low[1] AND close > high[1].
Long: Low[1] < low[2] AND low[1] < low[3] AND close[1] > low[2].
Short: High[1] > high[2] AND high[1] > high[3] AND close[1] < high[2].
Long: Basic bullish fakey is true and was false on the previous bar OR extended bullish fakey is true and was false on the previous bar.
Short: Basic bearish fakey is true and was false on the previous bar OR extended bearish fakey is true and was false on the previous bar.