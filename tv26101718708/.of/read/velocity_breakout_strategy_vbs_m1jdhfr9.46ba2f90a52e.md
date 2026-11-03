Calculation: EMA trend = short-lookback EMA of close compared with long-lookback EMA of close.
Calculation: Trailing stop and direction = initialize the stop and direction to zero. On each bar, use the smaller ATR multiplier when the position is long, close is above entry price, and ADX is below its threshold; otherwise use the larger multiplier. Let loss be that multiplier times ATR. If current and previous closes are both above the previous stop, the stop is the greater of the previous stop and close minus loss. If both closes are below the previous stop, it is the lesser of the previous stop and close plus loss. Otherwise, it is close minus loss when close is above the previous stop, and close plus loss otherwise. Set direction to long when previous close is below the previous stop and current close is above it; set direction to short when previous close is above the previous stop and current close is below it; otherwise retain the previous direction.
Calculation: Bear-market low = initialize to the first low; reset to the current low on a downward EMA trend crossover; while the short EMA is at or below the long EMA, update it to the lesser of its previous value and the current low.
Calculation: Master range = initialize to the first bar's high and low, or its body high and low if the body-only setting is selected. Before updating the range on each bar, test whether the previous range is armed. If close is outside the range, replace the range with the current bar's selected bounds and reset its count and armed state. Otherwise increment the count and arm the range when the count reaches the required follow-up-bar count.
Calculation: Reload armed state = initially armed; arm when close exceeds the highest high over a lookback ending on the previous bar; disarm after a reload decision.
Calculation: Discount boundary = lowest low over the dealing-range lookback plus a configurable fraction of the difference between the highest high and lowest low over that lookback.
Calculation: Volume anomaly = volume exceeds its moving average plus a configurable multiple of its standard deviation over the same lookback.
Long: Short EMA > long EMA.
Short: Short EMA < long EMA.
Long: Short EMA crosses above long EMA on a completed bar.
Short: Short EMA crosses below long EMA on a completed bar.
Long: Volume anomaly AND short EMA < long EMA.
Short: Volume anomaly AND short EMA > long EMA.
Long: A pivot high confirmed using equal lookback and forward windows > the preceding confirmed pivot high, OR a pivot low confirmed using equal lookback and forward windows > the preceding confirmed pivot low.
Short: A pivot high confirmed using equal lookback and forward windows < the preceding confirmed pivot high, OR a pivot low confirmed using equal lookback and forward windows < the preceding confirmed pivot low.
Long: Close <= discount boundary.
Short: Close > discount boundary.
Long: Short EMA crosses above long EMA on a completed bar AND (higher-low filter disabled OR lowest low over the structure lookback > bear-market low) AND (close minus lowest low over the structure lookback) / lowest low over the structure lookback <= maximum run-up fraction AND (chop filter disabled OR shorter-lookback ATR >= longer-lookback ATR).
Long: Previous master range is armed AND close > previous master range high AND close >= open AND (trend filter disabled OR (short EMA > long EMA AND trailing-stop direction is long)) AND (chop filter disabled OR shorter-lookback ATR >= longer-lookback ATR).
Long: Short EMA > long EMA AND reload armed state is armed AND lowest low over the touch lookback <= current short EMA AND (discount filter disabled OR close <= discount boundary) AND ((close > short EMA AND close >= open) OR (min(open, close) minus low > a configurable multiple of abs(close minus open) AND close >= open)) AND trailing-stop direction is long AND bar is completed AND short EMA does not cross above long EMA on this bar AND (chop filter disabled OR shorter-lookback ATR >= longer-lookback ATR).
Exit: long, trailing-stop direction changes from long to short.
Exit: long, short EMA crosses below long EMA on a completed bar.