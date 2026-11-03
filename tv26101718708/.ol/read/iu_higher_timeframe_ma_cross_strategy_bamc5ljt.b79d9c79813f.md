Long: MA1 (shorter-lookback moving average on its configured higher timeframe, using the last completed bar) crosses above MA2 (longer-lookback moving average on its configured higher timeframe, using the last completed bar) AND chart bar is confirmed AND position is flat
Short: MA1 (shorter-lookback moving average on its configured higher timeframe, using the last completed bar) crosses below MA2 (longer-lookback moving average on its configured higher timeframe, using the last completed bar) AND chart bar is confirmed AND position is flat
Calculation: Long stop = low of the chart bar immediately before entry
Calculation: Short stop = high of the chart bar immediately before entry
Calculation: Long target = entry price + (entry price - long stop) × risk-to-reward ratio
Calculation: Short target = entry price - (short stop - entry price) × risk-to-reward ratio
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target