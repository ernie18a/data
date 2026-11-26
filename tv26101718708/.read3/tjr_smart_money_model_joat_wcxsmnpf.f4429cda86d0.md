Calculation: Safe ATR = ATR(ATR lookback), falling back to minimum tick size when unavailable or nonpositive
Calculation: Bullish fair-value gap = low > high[2] AND low - high[2] > minimum gap size × safe ATR
Calculation: Bearish fair-value gap = high < low[2] AND low[2] - high > minimum gap size × safe ATR
Calculation: Long equilibrium = midpoint of the bullish MSS bar high and swept low
Calculation: Short equilibrium = midpoint of the bearish MSS bar low and swept high
Calculation: Long entry zone = [high[2], low] when a bullish fair-value gap forms on the MSS bar; otherwise long equilibrium ± equilibrium-zone pad × safe ATR
Calculation: Short entry zone = [high, low[2]] when a bearish fair-value gap forms on the MSS bar; otherwise short equilibrium ± equilibrium-zone pad × safe ATR
Long: low < latest confirmed pivot low and close > that pivot low
Short: high > latest confirmed pivot high and close < that pivot high
Long: close > latest confirmed pivot high that has not already been broken; each pivot high can trigger once and the break sets bullish bias
Short: close < latest confirmed pivot low that has not already been broken; each pivot low can trigger once and the break sets bearish bias
Long: a new confirmed pivot low is below the preceding confirmed pivot low AND correlated-instrument low at the corresponding pivot bars is not lower
Short: a new confirmed pivot high is above the preceding confirmed pivot high AND correlated-instrument high at the corresponding pivot bars is not higher
Long: (close - open) > displacement multiple × safe ATR AND close[1] < open[1]
Short: (open - close) > displacement multiple × safe ATR AND close[1] > open[1]
Long: close >= open
Short: close < open
Long: after a sell-side sweep, a bullish structure break with (close - open) > displacement multiple × safe ATR occurs on or within the sweep-to-MSS window; the resulting zone uses the long entry-zone calculation, and price taps it when low <= zone top AND close >= zone bottom AND close >= open
Short: after a buy-side sweep, a bearish structure break with (open - close) > displacement multiple × safe ATR occurs on or within the sweep-to-MSS window; the resulting zone uses the short entry-zone calculation, and price taps it when high >= zone bottom AND close <= zone top AND close <= open
Long entry: a long-zone tap occurs AND (SMT filter is disabled OR bullish SMT is true) AND (session filter is disabled OR the bar is inside an enabled configured session window in its configured timezone) AND minimum signal spacing is met; the tap consumes the setup before spacing and side-priority filtering
Short entry: a short-zone tap occurs AND (SMT filter is disabled OR bearish SMT is true) AND (session filter is disabled OR the bar is inside an enabled configured session window in its configured timezone) AND no long entry candidate exists AND minimum signal spacing is met; the tap consumes the setup before spacing and side-priority filtering
Calculation: Long risk = abs(entry price - (swept low - stop padding × safe ATR)), falling back to safe ATR when zero
Calculation: Short risk = abs(entry price - (swept high + stop padding × safe ATR)), falling back to safe ATR when zero
Calculation: Long stop = entry price - long risk; long first target = entry price + long risk × first-target R
Calculation: Short stop = entry price + short risk; short first target = entry price - short risk × first-target R
Exit: long, on the first completed bar with high >= long first target OR (low <= long stop AND high < long first target)
Exit: short, on the first completed bar with low <= short first target OR (high >= short stop AND low > short first target)