Calculation: Strat bar type = inside when high ≤ previous high and low ≥ previous low; outside when high > previous high and low < previous low; 2U when high > previous high and low ≥ previous low; 2D when low < previous low and high ≤ previous high
Calculation: Failed 2D = a completed 2D bar whose close is above its open
Calculation: Failed 2U = a completed 2U bar whose close is below its open
Calculation: Long entry level = prior completed bar's high plus a configurable tick offset, except after a Failed 2D, when it is the prior completed bar's high plus one minimum tick
Calculation: Short entry level = prior completed bar's low minus a configurable tick offset, except after a Failed 2U, when it is the prior completed bar's low minus one minimum tick
Calculation: Structural long stop = prior completed bar's low minus the configured tick offset, except after a Failed 2D, when it is the prior completed bar's low minus one minimum tick
Calculation: Structural short stop = prior completed bar's high plus the configured tick offset, except after a Failed 2U, when it is the prior completed bar's high plus one minimum tick
Calculation: Full bullish continuity = every required selected higher-timeframe bar still forming has its current price above its open; full bearish continuity = every required selected higher-timeframe bar still forming has its current price below its open
Long: current bar's high ≥ long entry level AND (continuity filter disabled or no higher timeframes required or full bullish continuity) AND configured entry, stop, and target levels are valid
Short: current bar's low ≤ short entry level AND (continuity filter disabled or no higher timeframes required or full bearish continuity) AND configured entry, stop, and target levels are valid
Long: current completed bar is a Failed 2D
Short: current completed bar is a Failed 2U
Exit: long, current bar's low ≤ structural long stop OR current bar's high ≥ configured take-profit price OR configured maximum holding-bar count is reached and the bar closes
Exit: short, current bar's high ≥ structural short stop OR current bar's low ≤ configured take-profit price OR configured maximum holding-bar count is reached and the bar closes