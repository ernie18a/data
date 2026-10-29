Calculation: Opening-range high = highest high of chart-timeframe bars timestamped within the configured opening-range interval
Calculation: Opening-range low = lowest low of chart-timeframe bars timestamped within the configured opening-range interval
Calculation: ATR = average true range over its configured lookback on the chart timeframe, using the last completed bar
Calculation: Long entry stop = opening-range high + configured entry buffer
Calculation: Short entry stop = opening-range low − configured entry buffer
Calculation: Initial long stop = opening-range low − configured buffer when range-based stops are selected; otherwise entry price − ATR × configured stop multiple
Calculation: Initial short stop = opening-range high + configured buffer when range-based stops are selected; otherwise entry price + ATR × configured stop multiple
Calculation: Profit target = entry price + initial risk × configured reward-to-risk multiple for longs; entry price − initial risk × configured reward-to-risk multiple for shorts
Long: opening range formed AND opening-range high − opening-range low ≥ ATR × configured minimum-range multiple AND current time is before the configured trade cutoff AND trades taken today < configured daily limit AND previous completed chart-timeframe bar high > opening-range high
Short: opening range formed AND opening-range high − opening-range low ≥ ATR × configured minimum-range multiple AND current time is before the configured trade cutoff AND trades taken today < configured daily limit AND previous completed chart-timeframe bar low < opening-range low
Exit: long, low ≤ current protective stop OR high ≥ profit target OR current time ≥ configured session close OR (weekday is Friday AND current time ≥ configured Friday close) OR (current time ≥ configured trade cutoff AND bars held ≥ configured holding limit)
Exit: short, high ≥ current protective stop OR low ≤ profit target OR current time ≥ configured session close OR (weekday is Friday AND current time ≥ configured Friday close) OR (current time ≥ configured trade cutoff AND bars held ≥ configured holding limit)