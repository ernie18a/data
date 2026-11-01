Calculation: Support and resistance levels = the latest confirmed pivot low or high, respectively, of close or low/high, using a shared left lookback and either a shorter or longer right lookback; also retain the two preceding longer-right pivots of each side.
Calculation: Near a level = abs(close - level) / level < distance threshold.
Calculation: Support/resistance space = (latest longer-right pivot high - latest longer-right pivot low) / latest longer-right pivot low.
Calculation: Bullish divergence = a low pivot is confirmed AND its value is below the preceding low pivot AND the latest confirmed RSI pivot low is above the preceding RSI pivot low. Price and RSI pivots are detected independently with equal left and right lookbacks.
Calculation: Bearish divergence = a high pivot is confirmed AND its value is above the preceding high pivot AND the latest confirmed RSI pivot high is below the preceding RSI pivot high. Price and RSI pivots are detected independently with equal left and right lookbacks.
Calculation: Raw support buy = (low < latest longer-right pivot low AND close > that pivot low OR close is near any retained pivot low) AND latest longer-right pivot high > latest longer-right pivot low AND support/resistance space > distance threshold AND RSI <= oversold threshold AND RSI > previous RSI.
Calculation: Raw resistance sell = (high > latest longer-right pivot high AND close < that pivot high OR close is near any retained pivot high) AND latest longer-right pivot high > latest longer-right pivot low AND support/resistance space > distance threshold AND RSI >= near-overbought threshold AND RSI < previous RSI.
Calculation: Liquidity setup = when no turtle-soup trade or unresolved setup exists, save the highest high and lowest low over a rolling number of chart bars equal to the higher-timeframe duration divided by the chart-timeframe duration; this is a rolling chart-bar window including the current bar, not a completed higher-timeframe bar. On a later bar, a low below the saved low selects a long setup; otherwise a high above the saved high selects a short setup. Keep the setup until execution and do not start another until the trade exits.
Calculation: Turtle-soup stop = at execution, for a long, the lowest low over the execution lookback including the entry bar minus an ATR multiple; for a short, the highest high over that lookback plus an ATR multiple. The long target is entry price plus a reward/risk multiple of abs(entry price - stop); the short target is entry price minus that amount. Entry price is the broken prior-window extreme. Freeze stop and target at entry; evaluate exits on the entry bar as well.
Calculation: Trail source = chart close or chart-timeframe Heikin-Ashi close, selected by the filtering setting.
Calculation: ATR trail = initialize the previous trail to zero. Let loss be chart ATR times a sensitivity parameter, optionally reduced according to chart timeframe. If current and previous trail source are both above the previous trail, use max(previous trail, current source - loss); if both are below it, use min(previous trail, current source + loss); otherwise use current source - loss when current source > previous trail, and current source + loss otherwise.
Calculation: Trail direction = initially neutral; set to long when previous trail source < previous trail AND current source > previous trail, set to short when previous source > previous trail AND current source < previous trail, otherwise retain the preceding direction.
Calculation: Structure-leg pivot = for each of two lookbacks, one shorter than the other, compare the high and low at that lookback with the highest high and lowest low of the intervening chart bars. A higher high starts a bearish leg; otherwise a lower low starts a bullish leg. Retain the corresponding pivot high or low only when the leg changes, and allow each pivot to be broken once.
Long: raw support buy AND previous bar's raw support buy is false.
Short: raw resistance sell AND previous bar's raw resistance sell is false.
Long: bullish divergence.
Short: bearish divergence.
Long: high three bars ago < low one bar ago.
Short: low three bars ago > high one bar ago.
Long: close crosses above an unbroken structure-leg pivot high.
Short: close crosses below an unbroken structure-leg pivot low.
Long: liquidity setup selects long AND a later bar's high > highest high over the execution lookback ending on the preceding bar.
Short: liquidity setup selects short AND a later bar's low < lowest low over the execution lookback ending on the preceding bar.
Long: trail source crosses above ATR trail.
Short: trail source crosses below ATR trail.
Long: trail direction = long AND close >= ATR trail + an ATR buffer.
Short: trail direction = short AND close <= ATR trail - an ATR buffer.
Exit: long, high >= turtle-soup target OR low <= turtle-soup stop.
Exit: short, low <= turtle-soup target OR high >= turtle-soup stop.