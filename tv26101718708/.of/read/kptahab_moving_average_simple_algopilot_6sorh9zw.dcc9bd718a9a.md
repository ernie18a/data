Calculation: Moving average = independently selected SMA, EMA, WMA, VWMA, or HMA of close; HMA of length n is WMA(2 × WMA(close, round(n / 2)) − WMA(close, n), round(sqrt(n))).
Calculation: Profit target(p) = average entry price × (1 + p) for a long position, or average entry price / (1 + p) for a short position, where p is the target percentage expressed as a fraction.
Calculation: Stop = for fixed mode, average entry price × (1 − stop fraction) for a long or × (1 + stop fraction) for a short; for trailing mode, initialize at that fixed level, multiply the previous stop by the ratio of current to previous average entry price whenever the average entry changes, then take the maximum of that stop and close × (1 − stop fraction) for a long, or the minimum of that stop and close × (1 + stop fraction) for a short. If breakeven is enabled and, since entry, the previous bar's high was strictly above the current first partial profit target for a long or its low was strictly below that target for a short, constrain the stop to at least the average entry for a long or at most the average entry for a short.
Long: Short-term moving average crosses above long-term moving average.
Short: Short-term moving average crosses below long-term moving average.
Long: Close > long-term moving average.
Short: Close < long-term moving average.
Long: Position is long AND loss repurchase is enabled AND close < average entry price × (1 − repurchase fraction) AND bar close is within the enabled date range AND the bar is in an enabled session with bar close before session end AND no opposing signal requests a reversal close.
Short: Position is short AND loss repurchase is enabled AND close > average entry price × (1 + repurchase fraction) AND bar close is within the enabled date range AND the bar is in an enabled session with bar close before session end AND no opposing signal requests a reversal close.
Exit: long, reversal-close mode is enabled AND short-term moving average crosses below long-term moving average.
Exit: short, reversal-close mode is enabled AND short-term moving average crosses above long-term moving average.
Exit: long, high >= final profit target OR high >= an enabled partial profit target; each partial target closes its configured fraction of the position.
Exit: short, low <= final profit target OR low <= an enabled partial profit target; each partial target closes its configured fraction of the position.
Exit: long, stop mode is enabled AND low <= stop.
Exit: short, stop mode is enabled AND high >= stop.
Exit: long, session filter is enabled AND the bar is outside the enabled session OR session filter is enabled AND the bar is in the enabled session AND bar close >= session end.
Exit: short, session filter is enabled AND the bar is outside the enabled session OR session filter is enabled AND the bar is in the enabled session AND bar close >= session end.