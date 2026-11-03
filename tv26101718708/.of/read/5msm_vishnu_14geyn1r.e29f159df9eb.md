Calculation: Price source = a selectable OHLC-derived chart-bar price, optionally calculated from Heikin-Ashi bars.
Calculation: MACD histogram = the difference between a shorter-period and a longer-period SMA or EMA of a selectable price source, minus an SMA or EMA of that difference.
Calculation: Alligator averages = smoothed moving averages of (high + low) / 2, initialized with an SMA and subsequently updated as (previous average × (length − 1) + current source) / length; lips, teeth, and jaw use respectively shorter, intermediate, and longer lengths. Use their unshifted values.
Calculation: Anchored VWAP = cumulative volume-weighted selectable price source since the start of a selectable calendar period; it is unavailable when the selected hide-on-daily-or-higher option applies.
Calculation: Range filter = let range be a positive multiplier times an EMA of an EMA of the absolute one-bar change in price source; the second EMA length is twice the first length minus one. Starting with previous filter value zero, if source > previous filter, set filter to max(previous filter, source − range); otherwise set it to min(previous filter, source + range). Its direction is the sign of its most recent nonzero change, initially zero.
Calculation: ATR trailing stop = starting with previous stop zero, let loss be ATR multiplied by a positive parameter. If current and previous closes are both above the previous stop, use max(previous stop, close − loss); if both are below it, use min(previous stop, close + loss); otherwise use close − loss when close > previous stop, and close + loss otherwise.
Calculation: ATR-based long stop = selectable current open, current close, or lowest low over a lookback, minus ATR multiplied by a positive parameter.
Calculation: Opening-range high and low = high and low of the first bar of each day on a higher timeframe, carried forward for the rest of that day; use the last completed higher-timeframe bar.
Calculation: Active VWAP exit stop = when the corresponding VWAP exit condition is true, submit or update a stop at current anchored VWAP; once submitted, it remains active until filled or the position closes. A long stop fills when a subsequent bar's low reaches the stop, and a short stop fills when a subsequent bar's high reaches it; a gap through the stop fills at that bar's open.
Long: Position side is not long AND MACD histogram > 0 AND close > lips AND open > lips AND bar time is within the configured session AND anchored VWAP < close AND range filter direction > 0 AND high > teeth AND lips > jaw AND previous close − previous open < a threshold.
Short: Position side is not short AND MACD histogram < 0 AND close < lips AND open < lips AND bar time is within the configured session AND anchored VWAP > close AND range filter direction < 0 AND high < teeth AND lips < jaw AND previous open − previous close < a threshold.
Long: Price source > range filter AND price source differs from its previous value AND range filter direction > 0.
Short: Price source < range filter AND price source differs from its previous value AND range filter direction < 0.
Long: Close > ATR trailing stop.
Short: Close <= ATR trailing stop.
Long: Close > teeth AND close > opening-range high AND each of the preceding configurable number of closes < current opening-range high AND bar time is within the configured session.
Short: Close < teeth AND close < opening-range low AND each of the preceding configurable number of closes > current opening-range low AND bar time is within the configured session.
Exit: long, close < lips AND MACD histogram < a negative threshold AND a VWAP stop is submitted or updated; exit when the active VWAP exit stop fills.
Exit: short, close > lips AND MACD histogram > a positive threshold AND a VWAP stop is submitted or updated; exit when the active VWAP exit stop fills.
Exit: long, high > teeth AND low < teeth AND close < teeth AND previous close > previous teeth.
Exit: short, high > teeth AND low < teeth AND close > teeth AND previous close < previous teeth.
Exit: long, high > entry price + a profit threshold AND open < entry price + that threshold.
Exit: short, low < entry price − a profit threshold AND open > entry price − that threshold.
Exit: long, previous close < previous teeth AND previous close < entry price AND previous teeth <= previous ATR-based long stop.
Exit: short, previous close > previous teeth AND previous close > entry price AND previous teeth <= previous ATR-based long stop.