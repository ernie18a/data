Calculation: EMA stack = shorter-lookback EMA > intermediate-lookback EMA > longer-lookback EMA
Calculation: Consecutive closes above intermediate-lookback EMA = count of consecutive bars with close above that EMA, reset to zero otherwise
Calculation: Share of closes above shorter-lookback EMA = percentage of bars in its lookback with close above that EMA
Calculation: Cloud bounce count = count over its lookback of bars where low is within the configured percentage above the intermediate-lookback EMA and close is above the shorter-lookback EMA
Calculation: Distance above shorter-lookback EMA = (close − shorter-lookback EMA) / shorter-lookback EMA × 100
Calculation: ATR percentage = ATR / close × 100
Calculation: Distance above rolling annual low = (close − rolling annual low) / rolling annual low × 100
Long: close is at or above the shorter-lookback EMA AND distance above the shorter-lookback EMA is at or below the configured dip limit AND consecutive closes above the intermediate-lookback EMA meet the configured minimum AND cloud bounce count meets the configured minimum AND EMA stack holds AND shorter-lookback EMA is above its value at the configured earlier lookback AND ATR percentage meets its configured minimum AND distance above rolling annual low meets its configured minimum
Exit: long, close is below the configured exit EMA (intermediate-lookback EMA or shorter-lookback EMA); when both are configured, close is below either