Calculation: Ribbon averages = five moving averages of a selected price source, ordered from shortest to longest lookback; the source is open, close, (high + low) / 2, (high + low + close) / 3, or (open + high + low + close) / 4. All averages use the same selected type: EMA, WMA, SMA, HMA, or VWMA. Optional additional averages use the same source and type.
Calculation: Up alignment = number of adjacent pairs among the five ribbon averages for which the shorter-lookback average is greater than the longer-lookback average.
Calculation: Down alignment = number of adjacent pairs among the five ribbon averages for which the shorter-lookback average is less than the longer-lookback average.
Long: The third-shortest ribbon average crosses above the fourth-shortest ribbon average.
Short: The third-shortest ribbon average crosses below the fourth-shortest ribbon average.
Long: The shortest ribbon average crosses above the second-shortest ribbon average.
Short: The shortest ribbon average crosses below the second-shortest ribbon average.
Long: Up alignment equals the number of adjacent ribbon pairs AND previous-bar up alignment is less than the number of adjacent ribbon pairs.
Short: Down alignment equals the number of adjacent ribbon pairs AND previous-bar down alignment is less than the number of adjacent ribbon pairs.
Long: The third-shortest ribbon average is greater than the fourth-shortest ribbon average AND up alignment is at least the required alignment threshold.
Short: The third-shortest ribbon average is less than or equal to the fourth-shortest ribbon average AND down alignment is at least the required alignment threshold.
Long: Up alignment is greater than or equal to down alignment.
Short: Up alignment is less than down alignment.
Long: For any adjacent ribbon pair, the shorter-lookback average is greater than the longer-lookback average.
Short: For any adjacent ribbon pair, the shorter-lookback average is less than or equal to the longer-lookback average.
Long: Any enabled ribbon or additional average is greater than its value a specified number of bars earlier.
Short: Any enabled ribbon or additional average is less than or equal to its value the same number of bars earlier.
Long: Close is greater than both selected higher-timeframe moving averages calculated from the last completed higher-timeframe bar.
Short: Close is less than both selected higher-timeframe moving averages calculated from the last completed higher-timeframe bar.
Long: The third-shortest ribbon average calculated on the last completed higher-timeframe bar is greater than the fourth-shortest ribbon average calculated on that bar.
Short: The third-shortest ribbon average calculated on the last completed higher-timeframe bar is less than or equal to the fourth-shortest ribbon average calculated on that bar.