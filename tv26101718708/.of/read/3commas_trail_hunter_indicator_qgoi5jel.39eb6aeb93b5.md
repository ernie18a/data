Calculation: MA cross = shorter-period SMA or EMA of close crosses below the longer-period average of the same type on the selected timeframe; for a higher timeframe use the last completed bar, and for a lower timeframe use the last completed lower-timeframe bar within the chart bar. Carry the last mapped result forward between updates.
Calculation: CCI cross = CCI of close crosses below an oversold threshold on its selected timeframe; for a higher timeframe use the last completed bar, and for a lower timeframe use the last completed lower-timeframe bar within the chart bar. Carry the last mapped result forward between updates.
Calculation: Entry peak = maximum of entry price and chart-bar highs from the entry bar through the current bar, inclusive.
Long: CCI signal enabled AND CCI cross.
Short: MA signal enabled AND MA cross.
Long: No open deal AND ((combination mode is AND AND each enabled signal has occurred within the keep-alive window measured in chart bars AND at least one enabled signal occurs on the current bar) OR (combination mode is OR AND (MA cross OR CCI cross))).
Exit: long, trailing enabled AND entry peak >= entry price × (1 + take-profit fraction) AND low <= entry peak × (1 - trailing-deviation fraction).
Exit: long, trailing disabled AND high >= entry price × (1 + take-profit fraction).
Exit: long, stop loss enabled AND low <= entry price × (1 - stop-loss fraction).