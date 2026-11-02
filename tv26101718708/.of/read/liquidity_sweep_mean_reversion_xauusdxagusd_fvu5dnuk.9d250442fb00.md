Calculation: Bullish sweep = low < the lowest low of either the shorter or longer lookback of preceding bars AND close > that same lowest low.
Calculation: Bearish sweep = high > the highest high of either the shorter or longer lookback of preceding bars AND close < that same highest high.
Calculation: Active bullish or bearish sweep = the corresponding raw sweep occurred on the current bar or within a configurable number of preceding bars; use the most recent corresponding sweep.
Calculation: Confirmed swing high or low = a pivot high or low confirmed after an equal configurable number of bars on each side; use the most recently confirmed pivot, including one confirmed on the current bar.
Calculation: Fast and slow SMMA = Wilder's smoothed moving averages of close, with the fast length shorter than the slow length.
Calculation: VWAP = cumulative volume-weighted average of (high + low + close) / 3, reset at the selected calendar-period anchor.
Calculation: Long stop = the most recent bullish sweep low multiplied by one minus a configurable buffer fraction; short stop = the most recent bearish sweep high multiplied by one plus the buffer fraction.
Calculation: Long target = highest high over the shorter liquidity lookback including the current bar; short target = lowest low over that lookback including the current bar.
Calculation: Long reward-to-risk = absolute value of (long target minus close) divided by absolute value of (close minus long stop); short reward-to-risk = absolute value of (close minus short target) divided by absolute value of (short stop minus close). Set the ratio to zero when its denominator is zero.
Long: Bullish sweep.
Short: Bearish sweep.
Long: Active bullish sweep AND close > latest confirmed swing high.
Short: Active bearish sweep AND close < latest confirmed swing low.
Long: Close > VWAP.
Short: Close <= VWAP.
Long: Long reward-to-risk >= configurable minimum AND bar opening time is within the configured inclusive UTC session, or the session filter is disabled, AND (conservative mode AND active bullish sweep AND close > latest confirmed swing high AND (fast SMMA crosses above slow SMMA OR close > fast SMMA) AND close > VWAP OR balanced mode AND bullish sweep AND (fast SMMA crosses above slow SMMA OR close crosses above fast SMMA) AND close > VWAP OR aggressive mode AND bullish sweep AND (sweep VWAP filter is disabled OR close > VWAP)).
Short: Short reward-to-risk >= configurable minimum AND bar opening time is within the configured inclusive UTC session, or the session filter is disabled, AND (conservative mode AND active bearish sweep AND close < latest confirmed swing low AND (fast SMMA crosses below slow SMMA OR close < fast SMMA) AND close < VWAP OR balanced mode AND bearish sweep AND (fast SMMA crosses below slow SMMA OR close crosses below fast SMMA) AND close < VWAP OR aggressive mode AND bearish sweep AND (sweep VWAP filter is disabled OR close < VWAP)).
Exit: Long, low <= long stop frozen on the entry-signal bar OR high >= long target frozen on the entry-signal bar.
Exit: Short, high >= short stop frozen on the entry-signal bar OR low <= short target frozen on the entry-signal bar.
Exit: Long, partial exit is enabled AND no partial exit has occurred in this position AND close crosses above fast SMMA; close the configured fraction of the position.
Exit: Short, partial exit is enabled AND no partial exit has occurred in this position AND close crosses below fast SMMA; close the configured fraction of the position.