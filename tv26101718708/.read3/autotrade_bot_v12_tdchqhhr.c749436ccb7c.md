Calculation: Chart HMA = HMA(close, HMA lookback parameter) on chart bars
Calculation: HMA rising = current Chart HMA >= Chart HMA on the immediately preceding chart bar >= Chart HMA on the chart bar before that
Calculation: HMA falling = current Chart HMA <= Chart HMA on the immediately preceding chart bar <= Chart HMA on the chart bar before that
Calculation: T1 EMA = EMA(close, T1 EMA lookback parameter, current T1 bar with lookahead off, including its forming value when available), sampled on chart bars
Calculation: T1 EMA rising = current T1 EMA sample >= sample on the immediately preceding chart bar >= sample on the chart bar before that
Calculation: T1 EMA falling = current T1 EMA sample <= sample on the immediately preceding chart bar <= sample on the chart bar before that
Calculation: Smoothed Williams %R = EMA(Williams %R(high, low, close, Williams %R lookback parameter), Williams %R EMA lookback parameter) on chart bars
Calculation: Latest low-sweep high/low = high/low of the most recent chart bar where low < lowest(low[1], sweep-lookback parameter)
Calculation: Latest high-sweep high/low = high/low of the most recent chart bar where high > highest(high[1], sweep-lookback parameter)
Calculation: Pending low sweep = set on each low sweep, storing that bar's high and low; a later low sweep replaces them; remains pending through the first pending bar with close > open, close > latest low-sweep high, close > Chart HMA, HMA rising, close > T1 EMA, and T1 EMA rising, then clears after that bar
Calculation: Pending high sweep = set on each high sweep, storing that bar's high and low; a later high sweep replaces them; remains pending through the first pending bar with shorts enabled, close < open, close < latest high-sweep low, close < Chart HMA, HMA falling, close < T1 EMA, and T1 EMA falling, then clears after that bar
Calculation: Higher low = latest low-sweep low > preceding low-sweep low, when both exist
Calculation: Lower high = latest high-sweep high < preceding high-sweep high, when both exist
Calculation: Recent oversold = Williams %R(high, low, close, Williams %R lookback parameter) <= oversold-level parameter on the current chart bar or any of the preceding oversold/overbought-lookback parameter chart bars
Calculation: Recent overbought = Williams %R(high, low, close, Williams %R lookback parameter) >= -(100 + oversold-level parameter) on the current chart bar or any of the preceding oversold/overbought-lookback parameter chart bars
Calculation: Long stop = on a flat-position Long signal, latest low-sweep low minus one minimum price increment, retained for that position
Calculation: Long target = on a flat-position Long signal, signal-bar close + reward-to-risk parameter × max(signal-bar close − Long stop, minimum price increment), retained for that position
Calculation: Short stop = on a flat-position Short signal, latest high-sweep high plus one minimum price increment, retained for that position
Calculation: Short target = on a flat-position Short signal, signal-bar close − reward-to-risk parameter × max(Short stop − signal-bar close, minimum price increment), retained for that position
Long: Pending low sweep AND close > open AND close > latest low-sweep high AND close > Chart HMA AND HMA rising AND close > T1 EMA AND T1 EMA rising AND Williams %R(high, low, close, Williams %R lookback parameter) > Smoothed Williams %R AND (Recent oversold OR Higher low)
Short: shorts enabled AND Pending high sweep AND close < open AND close < latest high-sweep low AND close < Chart HMA AND HMA falling AND close < T1 EMA AND T1 EMA falling AND Williams %R(high, low, close, Williams %R lookback parameter) < Smoothed Williams %R AND (Recent overbought OR Lower high)
Exit: Long, low <= Long stop OR high >= Long target
Exit: Short, high >= Short stop OR low <= Short target