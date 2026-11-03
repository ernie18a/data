Calculation: Baseline = SMA of EMA of close, both with the same lookback.
Calculation: Step = SMA of EMA of high minus low, both with the same lookback; its lookback is longer than the baseline lookback.
Calculation: Confirmed pivot high or low = a high or low with the same number of bars on each side that satisfies the pivot-high or pivot-low condition; update the latest and previous pivots only when the right-side bars have completed.
Calculation: Bullish structure = latest confirmed pivot high > previous confirmed pivot high AND latest confirmed pivot low > previous confirmed pivot low. Bearish structure = latest confirmed pivot high < previous confirmed pivot high AND latest confirmed pivot low < previous confirmed pivot low.
Calculation: Bullish regime = baseline > previous baseline AND the sum of the following comparisons meets a threshold: close > baseline + step, close > baseline + a larger multiple of step, latest pivot high > previous pivot high, latest pivot low > previous pivot low. Bearish regime = baseline < previous baseline AND the sum of the following comparisons meets the same threshold: close < baseline - step, close < baseline - the larger multiple of step, latest pivot high < previous pivot high, latest pivot low < previous pivot low.
Calculation: Volatility expansion = short-lookback ATR divided by long-lookback ATR > a threshold AND EMA of that ratio minus one > SMA of that EMA. Squeeze = short-lookback ATR < a fraction of long-lookback ATR AND short-lookback ATR < SMA of short-lookback ATR.
Calculation: Bar delta = volume when close > open, negative volume when close < open, otherwise zero. Delta oscillator = (short-lookback EMA of bar delta - long-lookback EMA of bar delta) divided by the greater of a positive floor and the rolling maximum of the absolute EMA difference. Bullish delta = delta oscillator > a positive threshold AND delta oscillator > its EMA. Bearish delta = delta oscillator < the negative of that threshold AND delta oscillator < its EMA.
Calculation: Bullish break state = the latest confirmed crossing of close above the current latest pivot high, tested using the current and previous close against that same pivot high, occurred after the latest confirmed crossing of close below the current latest pivot low, tested the same way. Bearish break state = the latest such downward crossing occurred after the latest such upward crossing; neither state is active before its first crossing.
Calculation: Bullish sweep = low < latest confirmed pivot low - an ATR multiple AND close > that pivot low. Bearish sweep = high > latest confirmed pivot high + the same ATR multiple AND close < that pivot high.
Calculation: Long confluence score = sum of the indicators for bullish regime, bullish structure, volatility expansion, absence of squeeze, bullish delta, bullish break state, and bullish sweep. Short confluence score = sum of the corresponding bearish indicators, using the same volatility expansion and absence of squeeze.
Calculation: Initial risk distance = ATR on the entry-signal bar multiplied by a stop parameter. The first and second targets are entry-signal close plus or minus this distance multiplied by respective reward parameters, with the second target farther away. The initial stop is entry-signal close minus the risk distance for a long or plus it for a short.
Calculation: Trailing distance = ATR on the bar that detects the first target multiplied by a trailing parameter, subject to a minimum price increment. After that detection, the trailing order activates when price moves this distance in the favorable direction from entry price; its stop follows the most favorable price reached after activation at the fixed trailing distance.
Long: A pivot low is confirmed.
Short: A pivot high is confirmed.
Long: Bullish regime.
Short: Bearish regime.
Long: Bullish structure.
Short: Bearish structure.
Long: Bullish delta.
Short: Bearish delta.
Long: Short-lookback delta EMA crosses above long-lookback delta EMA AND bullish regime.
Short: Short-lookback delta EMA crosses below long-lookback delta EMA AND bearish regime.
Long: Position is flat AND bullish regime AND long confluence score >= its threshold AND volatility expansion if the optional volatility gate is enabled.
Short: Position is flat AND bearish regime AND short confluence score >= its threshold AND volatility expansion if the optional volatility gate is enabled.
Long: Position is flat AND pullback entries are enabled AND bullish regime AND absolute distance between close and baseline < a fraction of step AND low <= baseline + a smaller fraction of step AND close > baseline AND bullish delta AND volatility expansion if the optional volatility gate is enabled.
Short: Position is flat AND pullback entries are enabled AND bearish regime AND absolute distance between close and baseline < the same fraction of step AND high >= baseline - the smaller fraction of step AND close < baseline AND bearish delta AND volatility expansion if the optional volatility gate is enabled.
Long: Position is flat AND squeeze entries are enabled AND previous bar is in a squeeze AND current bar is not in a squeeze AND bullish regime AND bullish delta.
Short: Position is flat AND squeeze entries are enabled AND previous bar is in a squeeze AND current bar is not in a squeeze AND bearish regime AND bearish delta.
Long: Position is flat AND short-lookback delta EMA crosses above long-lookback delta EMA AND bullish regime AND no squeeze AND volatility expansion if the optional volatility gate is enabled.
Short: Position is flat AND short-lookback delta EMA crosses below long-lookback delta EMA AND bearish regime AND no squeeze AND volatility expansion if the optional volatility gate is enabled.
Long: Position is flat AND sweep entries are enabled AND bullish sweep AND bullish delta.
Short: Position is flat AND sweep entries are enabled AND bearish sweep AND bearish delta.
Exit: long, low <= initial stop OR high >= first target for the first partial position OR high >= second target for the remaining position while its target order remains active.
Exit: short, high >= initial stop OR low <= first target for the first partial position OR low <= second target for the remaining position while its target order remains active.
Exit: long, trailing is enabled AND first target has been detected AND trailing order is active AND low <= trailing stop; detection cancels the remaining second-target order.
Exit: short, trailing is enabled AND first target has been detected AND trailing order is active AND high >= trailing stop; detection cancels the remaining second-target order.
Exit: long, bearish regime.
Exit: short, bullish regime.