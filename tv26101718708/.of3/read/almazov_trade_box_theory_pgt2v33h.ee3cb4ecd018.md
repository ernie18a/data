Calculation: reference high = highest chart-bar high in the preceding available completed T1 period; exclude the initial partial T1 period
Calculation: reference low = lowest chart-bar low in the preceding available completed T1 period; exclude the initial partial T1 period
Calculation: reference range = reference high - reference low
Calculation: effective body = max(abs(close - open), minimum price tick)
Calculation: candle range = high - low
Calculation: upper wick = high - max(open, close)
Calculation: lower wick = min(open, close) - low
Calculation: body percentage = abs(close - open) / candle range × 100
Calculation: long stop = reference low at entry - stop-buffer parameter × minimum price tick; fixed until exit
Calculation: short stop = reference high at entry + stop-buffer parameter × minimum price tick; fixed until exit
Calculation: long initial risk = entry price - long stop
Calculation: short initial risk = short stop - entry price
Calculation: long target = entry price + long initial risk × target-multiple parameter; fixed until exit
Calculation: short target = entry price - short initial risk × target-multiple parameter; fixed until exit
Long: on confirmed chart-bar close, reference range is available and > 0 AND no setup is active AND no setup exited on this chart bar AND no chart bar in the current T1 period has high > reference high or low < reference low AND candle range > 0 AND lower wick >= effective body × minimum main-wick/effective-body ratio parameter AND upper wick <= effective body × maximum opposite-wick/effective-body ratio parameter AND body percentage <= maximum body-range percentage parameter AND (direction filter is disabled OR close > open) AND low <= reference low + reference range × zone-width parameter AND high >= reference low AND close - long stop > minimum price tick
Short: on confirmed chart-bar close, reference range is available and > 0 AND no setup is active AND no setup exited on this chart bar AND no chart bar in the current T1 period has high > reference high or low < reference low AND candle range > 0 AND upper wick >= effective body × minimum main-wick/effective-body ratio parameter AND lower wick <= effective body × maximum opposite-wick/effective-body ratio parameter AND body percentage <= maximum body-range percentage parameter AND (direction filter is disabled OR close < open) AND high >= reference high - reference range × zone-width parameter AND low <= reference high AND short stop - close > minimum price tick AND no qualifying Long condition exists on this chart bar
Exit: Long, after the entry chart bar, on a confirmed chart-bar close with low <= long stop OR high >= long target; if both levels are touched, the stop takes priority
Exit: Short, after the entry chart bar, on a confirmed chart-bar close with high >= short stop OR low <= short target; if both levels are touched, the stop takes priority