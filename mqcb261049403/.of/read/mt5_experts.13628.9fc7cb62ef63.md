Calculation: Fine-tuning moving average = weighted average of the configured price over a lookback window; each bar’s weight is the normalized product of three configurable rank-and-shift weight factors, with one factor increasing across the window, one decreasing, and one weighted by distance from the window midpoint. Use three consecutive completed bars on the configured indicator timeframe, which may be higher or lower than the chart timeframe; call their values oldest, middle, and newest.
Long: oldest value > middle value AND middle value < newest value
Short: oldest value < middle value AND middle value > newest value
Exit: long, middle value > newest value
Exit: short, middle value < newest value