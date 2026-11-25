Calculation: Panel FVG direction state on T = bullish initially; update to bullish when low > high[2], to bearish when high < low[2], otherwise retain; evaluate on T bars using the forming bar in preview mode or the last completed bar in strict-confirm mode, then carry the state to chart bars.
Calculation: Panel fractal-break direction state on T = bullish initially; update to bullish when high crosses above the latest confirmed pivot high, to bearish when low crosses below the latest confirmed pivot low, otherwise retain; use confirmed pivots with separate left and right strengths, evaluate on T bars using the forming bar in preview mode or the last completed bar in strict-confirm mode, then carry the state to chart bars.
Calculation: T bias state = a confirmed neutral/bullish/bearish state with score derived from an EMA of the weighted mean of panel FVG and fractal-break states, with the FVG weight reduced in squeeze regime; apply regime and average-range exhaustion gates to the score, enter bullish or bearish after separate entry thresholds persist for the entry lookback, and return to neutral after separate exit thresholds persist for the exit lookback; evaluate on T bars using the forming bar in preview mode or the last completed bar in strict-confirm mode, then carry the state to chart bars.
Calculation: Chart regime state = squeeze when Bollinger bandwidth is below its average times the squeeze-entry multiplier and the Bollinger bands are inside the Keltner channel; squeeze ends when bandwidth exceeds its average times the squeeze-exit multiplier or the Bollinger bands leave the Keltner channel. Trend state enters and exits using separate ADX thresholds. After candidate persistence, classify as squeeze, else trend, else range; update on confirmed chart bars.
Calculation: Confirmed chart bias state = a neutral/bullish/bearish state from score 50 + 50 × clamped directional score × confidence gate. Directional score is the clamped sum of an EMA of the weighted mean of FVG state, optional fractal-break state, and a zero KAMA component, plus a clamped overlay. Each enabled trendline or segment component becomes +1 on its long signal, −1 on its short signal, and otherwise decays from its prior value; average enabled components and scale by the ATR-to-average-ATR low-volatility factor. Confidence gate is 1 in trend, lower in range and squeeze, and is multiplied by separate ADR warning and exhaustion factors when current-day range as a percentage of average daily range reaches their thresholds. Enter bullish or bearish after separate score thresholds persist for the entry lookback; return to neutral after separate exit thresholds persist for the exit lookback. Update on confirmed chart bars.
Calculation: Trendline resistance and support = lines through the two latest confirmed pivot highs and lows when bars-per-side is nonzero; when it is zero, anchor each line at the latest confirmed pivot and use the through-origin regression slope of intervening highs or lows, excluding the current bar.
Calculation: Three rising-low segments = current low and three successively lower earlier lows, with each successive low found within the segment lookback. Three falling-high segments = current high and three successively higher earlier highs, with each successive high found within the segment lookback.
Calculation: Inside bar = high < high[1] AND low > low[1].
Calculation: L12 eligibility initially permits either direction; after a long marker, only a short marker is eligible, and after a short marker, only a long marker is eligible.
Long: low > high[2]
Short: high < low[2]
Long: on a chart bar beginning a new T1 bar, low of the prior completed T1 bar > high three T1 bars ago
Short: on a chart bar beginning a new T1 bar, high of the prior completed T1 bar < low three T1 bars ago
Long: on a chart bar beginning a new T2 bar, low of the prior completed T2 bar > high three T2 bars ago
Short: on a chart bar beginning a new T2 bar, high of the prior completed T2 bar < low three T2 bars ago
Long: panel FVG direction state on T3 is bullish
Short: panel FVG direction state on T3 is bearish
Long: panel FVG direction state on T4 is bullish
Short: panel FVG direction state on T4 is bearish
Long: panel FVG direction state on T5 is bullish
Short: panel FVG direction state on T5 is bearish
Long: panel FVG direction state on T6 is bullish
Short: panel FVG direction state on T6 is bearish
Long: panel FVG direction state on T7 is bullish
Short: panel FVG direction state on T7 is bearish
Long: panel FVG direction state on T8 is bullish
Short: panel FVG direction state on T8 is bearish
Long: panel FVG direction state on T9 is bullish
Short: panel FVG direction state on T9 is bearish
Long: high crosses above the latest confirmed chart pivot high
Short: low crosses below the latest confirmed chart pivot low
Long: panel fractal-break direction state on T3 is bullish
Short: panel fractal-break direction state on T3 is bearish
Long: panel fractal-break direction state on T4 is bullish
Short: panel fractal-break direction state on T4 is bearish
Long: panel fractal-break direction state on T5 is bullish
Short: panel fractal-break direction state on T5 is bearish
Long: panel fractal-break direction state on T6 is bullish
Short: panel fractal-break direction state on T6 is bearish
Long: panel fractal-break direction state on T7 is bullish
Short: panel fractal-break direction state on T7 is bearish
Long: panel fractal-break direction state on T8 is bullish
Short: panel fractal-break direction state on T8 is bearish
Long: panel fractal-break direction state on T9 is bullish
Short: panel fractal-break direction state on T9 is bearish
Long: panel bias state on T3 is bullish
Short: panel bias state on T3 is bearish
Long: panel bias state on T4 is bullish
Short: panel bias state on T4 is bearish
Long: panel bias state on T5 is bullish
Short: panel bias state on T5 is bearish
Long: panel bias state on T6 is bullish
Short: panel bias state on T6 is bearish
Long: panel bias state on T7 is bullish
Short: panel bias state on T7 is bearish
Long: panel bias state on T8 is bullish
Short: panel bias state on T8 is bearish
Long: panel bias state on T9 is bullish
Short: panel bias state on T9 is bearish
Long: EMA(close, shorter lookback) > EMA(close, longer lookback)
Short: EMA(close, shorter lookback) < EMA(close, longer lookback)
Long: close > current trendline support projection
Short: close < current trendline resistance projection
Long: low = highest(low, lookback) AND an L12 long marker is eligible AND the chart bar is confirmed
Short: high = lowest(high, lookback) AND an L12 short marker is eligible AND the chart bar is confirmed
Long: (low < lowest(low-or-close, lookback)[1] AND selected oscillator > lowest(selected oscillator, lookback)[1]) OR (low > lowest(low-or-close, lookback)[1] AND selected oscillator < lowest(selected oscillator, lookback)[1]); selected oscillator is RSI or the MACD line or signal line
Short: (high > highest(high-or-close, lookback)[1] AND selected oscillator < highest(selected oscillator, lookback)[1]) OR (high < highest(high-or-close, lookback)[1] AND selected oscillator > highest(selected oscillator, lookback)[1]); selected oscillator is RSI or the MACD line or signal line
Long: high > high[1] AND three rising-low segments are present AND the chart bar is confirmed
Short: low < low[1] AND three falling-high segments are present AND the chart bar is confirmed
Long: high > high[1] AND low < low[1] AND close < low[1] AND the chart bar is confirmed
Short: high > high[1] AND low < low[1] AND close > high[1] AND the chart bar is confirmed
Long: low[1] < low[2] AND low[1] < low[3] AND close[1] > low[2]
Short: high[1] > high[2] AND high[1] > high[3] AND close[1] < high[2]
Long: (Inside[1] AND low < low[1] AND close > open[1] AND close > open) OR (Inside[2] AND close[1] < low[2] AND close > close[1] AND high > high[1]) OR (Inside[1] AND low < low[2] AND close > close[1] AND close > open) OR (Inside[2] AND close[1] < low[3] AND close > open AND close > open[1]) OR any of the following for k in 1 through 4: Inside[k] AND low < low[k] AND close > high[k]; signal condition must be newly true and the chart bar confirmed
Short: (Inside[1] AND high > high[1] AND close < open[1] AND close < open) OR (Inside[2] AND close[1] > high[2] AND close < close[1] AND low < low[1]) OR (Inside[1] AND high > high[2] AND close < open AND close < close[1]) OR (Inside[2] AND close[1] > high[3] AND close < open AND close < close[1]) OR any of the following for k in 1 through 4: Inside[k] AND high > high[k] AND close < low[k]; signal condition must be newly true and the chart bar confirmed
Long: confirmed chart bias state is bullish
Short: confirmed chart bias state is bearish
Long: confirmed chart bias state changes from neutral to bullish
Short: confirmed chart bias state changes from neutral to bearish