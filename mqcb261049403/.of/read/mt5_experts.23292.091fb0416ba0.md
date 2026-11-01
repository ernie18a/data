Calculation: Trigger = sign(shorter-lookback moving average − longer-lookback moving average) + sign(shorter-lookback RSI − longer-lookback RSI); use independently configurable applied prices and moving-average methods. Each sign is −1, 0, or 1. Calculate on the chart timeframe for the indicator; for each trading side, calculate independently on a configurable higher or lower timeframe using either the last completed bar or the bar still forming, according to the signal-bar setting.
Long: Trigger > 0
Short: Trigger < 0
Long: Trigger > 0 AND Trigger on the preceding indicator bar <= 0
Short: Trigger < 0 AND Trigger on the preceding indicator bar >= 0
Exit: long, long-side Trigger < 0 OR low <= entry price − stop-loss distance OR high >= entry price + take-profit distance
Exit: short, short-side Trigger > 0 OR high >= entry price + stop-loss distance OR low <= entry price − take-profit distance