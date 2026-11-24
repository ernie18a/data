Calculation: Session high = highest(high, bars since the configured session opened)
Calculation: Session low = lowest(low, bars since the configured session opened)
Calculation: Opening-range high = highest(high, bars in the first N minutes after an enabled session opens)
Calculation: Opening-range low = lowest(low, bars in the first N minutes after an enabled session opens)
Long: At a configured session end, if the following session's long level is enabled, mark Session low minus that session's separate long offset; session order is Asia → London → NY Pre-Open → NY AM → NY PM → Asia
Short: At a configured session end, if the following session's short level is enabled, mark Session high plus that session's separate short offset; session order is Asia → London → NY Pre-Open → NY AM → NY PM → Asia
Long: Close crosses either direction over the active long level (preceding Session low minus the following session's long offset), before the next configured session start resets it, with no earlier cross since the level was set
Short: Close crosses either direction over the active short level (preceding Session high plus the following session's short offset), before the next configured session start resets it, with no earlier cross since the level was set
Long: With OR signaling and long enabled and retest disabled, after the opening range is finalized and before its session ends, close > Opening-range high on a confirmed chart bar, if no long signal has fired for that range
Short: With OR signaling and short enabled and retest disabled, after the opening range is finalized and before its session ends, close < Opening-range low on a confirmed chart bar, if no short signal has fired for that range
Long: With OR signaling and long enabled and retest enabled, after a prior confirmed close > Opening-range high has armed the range and before its session ends, low <= Opening-range high AND close > Opening-range high on a confirmed chart bar, if no long signal has fired for that range
Short: With OR signaling and short enabled and retest enabled, after a prior confirmed close < Opening-range low has armed the range and before its session ends, high >= Opening-range low AND close < Opening-range low on a confirmed chart bar, if no short signal has fired for that range
Long: Close crosses above VWAP(typical price, volume, configured anchor), accumulated on chart bars and reset at the configured session or T1 boundary
Short: Close crosses below VWAP(typical price, volume, configured anchor), accumulated on chart bars and reset at the configured session or T1 boundary
Long: When the trend ribbon is shown, EMA(close, fast lookback) >= EMA(close, slow lookback), with the slow lookback forced to exceed the fast lookback
Short: When the trend ribbon is shown, EMA(close, fast lookback) < EMA(close, slow lookback), with the slow lookback forced to exceed the fast lookback