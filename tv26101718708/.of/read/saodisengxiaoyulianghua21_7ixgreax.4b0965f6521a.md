Calculation: Heikin-Ashi open = (previous Heikin-Ashi open + previous Heikin-Ashi close) / 2, initialized to (open + close) / 2; Heikin-Ashi close = (open + high + low + close) / 4.
Calculation: Two-EMA cross = the shorter EMA of close crosses the longer EMA of close on the current bar, or, in lookback mode, crossed exactly the configured number of bars ago with no subsequent cross and remains on the crossed side.
Calculation: Alternation state = the direction of the most recent confirmed leading signal before alternation; update it on every confirmed leading signal, giving long priority if both directions confirm.
Long: Heikin-Ashi close >= Heikin-Ashi open.
Short: Heikin-Ashi close < Heikin-Ashi open.
Long: close > open.
Short: close <= open.
Long: Schaff Trend Cycle >= upper threshold.
Short: Schaff Trend Cycle <= lower threshold.
Long: Supertrend direction changes from down to up.
Short: Supertrend direction changes from up to down.
Long: Two-EMA cross is upward AND the leading indicator is the two-EMA cross AND all enabled confirmation conditions pass AND the leading-signal expiry condition passes AND either alternation is disabled OR the previous alternation state is short.
Short: Two-EMA cross is downward AND the leading indicator is the two-EMA cross AND all enabled confirmation conditions pass AND the leading-signal expiry condition passes AND either alternation is disabled OR the previous alternation state is long.
Exit: long, a short signal occurs after a bar without a short signal AND the bar is inside the enabled backtest period.
Exit: short, a long signal occurs after a bar without a long signal AND the bar is inside the enabled backtest period.