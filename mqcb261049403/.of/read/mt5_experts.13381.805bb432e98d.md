Calculation: Trigger = sign(shorter-period moving average minus longer-period moving average) + sign(shorter-period RSI minus longer-period RSI), using independently selectable moving-average methods and price inputs and independently selectable RSI price inputs; sign is 1, 0, or -1 according to whether its argument is positive, zero, or negative.
Long: Chart-timeframe trigger > 0.
Short: Chart-timeframe trigger < 0.
Long: Signal-timeframe trigger > 0 AND preceding signal-timeframe trigger <= 0.
Short: Signal-timeframe trigger < 0 AND preceding signal-timeframe trigger >= 0.
Exit: long, signal-timeframe trigger < 0.
Exit: short, signal-timeframe trigger > 0.
Exit: long, low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance.
Exit: short, high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance.
Calculation: Signal-timeframe trigger = trigger calculated on a selectable timeframe, which may be the chart timeframe or a higher or lower timeframe; use a selectable bar offset, including the last completed bar or the bar still forming. The preceding trigger uses the immediately preceding bar of that timeframe.