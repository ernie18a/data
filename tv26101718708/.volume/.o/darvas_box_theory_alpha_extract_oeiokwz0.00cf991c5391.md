Calculation: Active Darvas box = after no box is active, set its ceiling to the highest high and floor to the lowest low over the same lookback; keep both fixed until price breaks either boundary, then clear the box. Start a box only when its height is at least a configured multiple of ATR; if the rising-box filter is enabled, also require its ceiling to exceed the previous completed box ceiling.
Calculation: Upward box break = with an active box, selected price > ceiling in close mode, or current high > ceiling in wick mode.
Calculation: Downward box break = with an active box, selected price < floor in close mode, or current low < floor in wick mode, and no upward box break on that bar.
Calculation: Volume confirmation = disabled, or current volume >= its moving average times a configured multiplier.
Calculation: Trend confirmation = disabled, or selected price > its EMA.
Calculation: Base stop = box floor in floor mode, box ceiling in breached-ceiling mode, or selected price minus ATR times a configured multiplier in ATR mode. When higher-box trailing is enabled, advance the stop to the greater of its prior value and the base stop on a confirmed upward break above the previous box ceiling, and on an add signal.
Long: Upward box break AND volume confirmation AND trend confirmation AND flat position
Long: Upward box break AND volume confirmation AND trend confirmation AND long position AND selected price > entry price
Short: Downward box break AND flat position
Exit: long, selected price < trailing stop OR downward box break