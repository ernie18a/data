Calculation: Gap percentage = (current bar open − previous bar close) / previous bar close × 100.
Calculation: Relative volume = current bar volume / average volume of the preceding lookback bars, excluding the current bar.
Long: Gap percentage ≥ minimum gap size AND (relative-volume filter disabled OR relative volume ≥ minimum relative volume) AND (SMA filter disabled OR current bar open > previous bar’s simple moving average of close)
Long: Gap percentage ≥ minimum gap size AND (relative-volume filter disabled OR relative volume ≥ minimum relative volume) AND SMA filter enabled AND current bar open ≤ previous bar’s simple moving average of close
Short: Gap percentage ≤ −minimum gap size AND (relative-volume filter disabled OR relative volume ≥ minimum relative volume) AND (SMA filter disabled OR current bar open < previous bar’s simple moving average of close)
Short: Gap percentage ≤ −minimum gap size AND (relative-volume filter disabled OR relative volume ≥ minimum relative volume) AND SMA filter enabled AND current bar open ≥ previous bar’s simple moving average of close
Exit: long, evaluation horizon = 0 AND any long or short entry condition
Exit: long, evaluation horizon > 0 AND any long or short entry condition was true evaluation-horizon bars ago
Exit: short, evaluation horizon = 0 AND any long or short entry condition
Exit: short, evaluation horizon > 0 AND any long or short entry condition was true evaluation-horizon bars ago