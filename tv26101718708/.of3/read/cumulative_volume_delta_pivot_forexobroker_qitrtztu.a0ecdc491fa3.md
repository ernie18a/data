Calculation: CVD = prior CVD + volume × signed-volume factor, initialized at 0; when close-position signing is selected, the factor is 0 if high = low, otherwise 2 × (close − low) / (high − low) − 1; otherwise it is 1 if close > prior close, −1 if close < prior close, and 0 otherwise
Long: CVD pivot low confirmed using the pivot-length parameter on each side
Short: CVD pivot high confirmed using the pivot-length parameter on each side
Long: close crosses above EMA(close, reclaim lookback)
Short: close crosses below EMA(close, reclaim lookback)
Long: a CVD pivot low is confirmed AND the most recent confirmed price pivot is a low no more than the pivot-align-window parameter bars ago
Short: a CVD pivot high is confirmed AND the most recent confirmed price pivot is a high no more than the pivot-align-window parameter bars ago
Long: CVD > EMA(CVD, CVD-slope lookback) AND close crosses above EMA(close, reclaim lookback) AND (confluence-only mode is disabled OR a bullish pivot confluence occurs) AND (session restriction is disabled OR the bar is in the configured session) AND position is flat or short AND the cooldown parameter bars have elapsed since the last signal AND the chart bar is confirmed
Short: CVD < EMA(CVD, CVD-slope lookback) AND close crosses below EMA(close, reclaim lookback) AND (confluence-only mode is disabled OR a bearish pivot confluence occurs) AND (session restriction is disabled OR the bar is in the configured session) AND position is flat or long AND the cooldown parameter bars have elapsed since the last signal AND the chart bar is confirmed