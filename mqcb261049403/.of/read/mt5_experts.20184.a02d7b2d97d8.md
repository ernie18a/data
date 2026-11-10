Calculation: Entry MA = moving average of a configurable price series on a configurable timeframe; use its bar still forming at the start of the chart bar. The timeframe may be higher than, lower than, or equal to the chart timeframe.
Calculation: Exit MA = moving average of the same configurable price series and smoothing method on a timeframe that may be higher than, lower than, or equal to the chart timeframe; use its last completed bar and the preceding bar. Its lookback is independent of the entry MA lookback.
Calculation: Down-cross = exit MA on the last completed exit-timeframe bar > that bar's close AND exit MA on the preceding bar < that bar's close.
Calculation: Up-cross = exit MA on the last completed exit-timeframe bar < that bar's close AND exit MA on the preceding bar > that bar's close.
Long: No long position AND previous chart bar's low > entry MA AND down-cross = false AND up-cross = false.
Short: No short position AND previous chart bar's high < entry MA AND down-cross = false AND up-cross = false AND (a long position exists OR previous chart bar's low <= entry MA).
Exit: Long, down-cross = true.
Exit: Short, up-cross = true.
Exit: Long, stop loss enabled AND price <= entry price minus stop-loss distance.
Exit: Long, take profit enabled AND price >= entry price plus take-profit distance.
Exit: Short, stop loss enabled AND price >= entry price plus stop-loss distance.
Exit: Short, take profit enabled AND price <= entry price minus take-profit distance.