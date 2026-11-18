Calculation: Prior-session midpoint = (high[1](T1, last completed bar sampled on chart bars) + low[1](T1, last completed bar sampled on chart bars)) / 2
Calculation: First-window high = maximum high of current-session chart bars in the first configured time window
Calculation: Second-window high = maximum high of current-session chart bars in the second configured time window
Calculation: Second-window low = minimum low of current-session chart bars in the second configured time window
Long: (close crosses above high[1](T1, last completed bar sampled on chart bars) OR (chart-bar time > entry-time parameter AND (close crosses above first-window high OR close crosses above second-window high))) AND close > prior-session midpoint
Short: (close crosses below low[1](T1, last completed bar sampled on chart bars) OR (chart-bar time > entry-time parameter AND close crosses below second-window low)) AND close < prior-session midpoint
Exit: long, low <= second-window low - stop-buffer parameter
Exit: short, high >= second-window high + stop-buffer parameter