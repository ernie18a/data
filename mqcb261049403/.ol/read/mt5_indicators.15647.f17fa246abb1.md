Calculation: Channel upper threshold = highest high over the lookback bars minus the risk fraction of the highest-high to lowest-low range over those bars.
Calculation: Channel lower threshold = lowest low over the lookback bars plus the risk fraction of the highest-high to lowest-low range over those bars.
Calculation: Long trailing stop = channel lower threshold, ratcheted upward so it never decreases while the long trend is active.
Calculation: Short trailing stop = channel upper threshold, ratcheted downward so it never increases while the short trend is active.
Long: close > previous bar's channel upper threshold AND previous bar was in a short trend
Short: close < previous bar's channel lower threshold AND previous bar was in a long trend
Exit: long, close < previous bar's long trailing stop
Exit: short, close > previous bar's short trailing stop