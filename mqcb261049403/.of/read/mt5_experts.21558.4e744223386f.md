Calculation: Upper channel = DEMA of high plus a vertical price offset, evaluated a configurable number of bars earlier; the DEMA of high and DEMA of low use the same period.
Calculation: Lower channel = DEMA of low minus the same vertical price offset, evaluated the same number of bars earlier as the upper channel.
Calculation: Expert channel = upper and lower channels computed with no horizontal or vertical offset on a configurable timeframe that may be higher or lower than the chart timeframe; use a selected completed bar or the still-forming bar, and its immediately preceding bar.
Long: chart close > upper channel AND chart close >= lower channel
Short: chart close < lower channel
Long: expert timeframe close > expert upper channel AND expert timeframe close >= expert lower channel AND (preceding expert timeframe close <= preceding expert upper channel OR preceding expert timeframe close < preceding expert lower channel)
Short: expert timeframe close < expert lower channel AND preceding expert timeframe close >= preceding expert lower channel
Exit: long, expert timeframe close < expert lower channel
Exit: short, expert timeframe close > expert upper channel AND expert timeframe close >= expert lower channel
Exit: long, low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance
Exit: short, high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance