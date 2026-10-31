Calculation: Momentum = selected price minus its value one lookback earlier, on the indicator timeframe; use the last completed bar, or the still-forming bar when configured. The indicator timeframe may be the chart timeframe, higher, or lower.
Calculation: Direction line = lookback multiplied by the selected moving average of momentum using the same lookback.
Calculation: Trend line = absolute value of the direction line minus (twice the lookback multiplied by the same moving average of absolute momentum using twice the lookback, minus current absolute momentum).
Long: Direction line > trend line AND previous indicator bar's direction line <= previous indicator bar's trend line.
Short: Direction line < trend line AND previous indicator bar's direction line >= previous indicator bar's trend line.
Exit: long, direction line < trend line OR low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance.
Exit: short, direction line > trend line OR high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance.