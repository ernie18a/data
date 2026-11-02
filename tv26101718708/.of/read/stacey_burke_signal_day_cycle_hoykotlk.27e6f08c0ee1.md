Calculation: Completed day = OHLC accumulated from chart bars between successive higher-timeframe day boundaries; classify it on the first chart bar of the next day. The prior day is the preceding completed day.
Calculation: Up cycle = consecutive completed days whose high exceeds the prior day's high and whose low is at least the prior day's low. Down cycle = consecutive completed days whose low is below the prior day's low and whose high is at most the prior day's high. Reset both counts on any other day.
Calculation: First red day = completed-day close < open AND prior-day close > open AND, if the swing filter is enabled, prior-day high >= every high in the selected lookback of completed days ending with the prior day. First green day = completed-day close > open AND prior-day close < open AND, if the swing filter is enabled, prior-day low <= every low in the same lookback.
Calculation: Failed high = completed-day high > prior-day high AND close < prior-day high AND close > prior-day low AND low >= prior-day low. Failed low = completed-day low < prior-day low AND close > prior-day low AND close < prior-day high AND high <= prior-day high. Day zero = a failed high immediately following a failed low OR a failed low immediately following a failed high.
Calculation: Directional bias = on each completed day, select the first applicable case in this order: first red day gives short; first green day gives long; day zero gives neutral; the day immediately after a first red or first green day retains that direction; an up or down cycle of the fade length or one day longer gives the opposite direction; an up or down cycle of the shorter continuation length gives the cycle direction; otherwise neutral. The fade length is one day longer than the continuation length. For a long bias, store the completed day's low as its invalidation level; for a short bias, store its high. The bias remains invalidated for the rest of the day after any chart close crosses beyond that level.
Calculation: Strike level = for an up cycle, the greater of the last completed day's high and the forming higher-timeframe day's running high, minus a fixed price distance; for a down cycle, the lesser of the last completed day's low and the forming higher-timeframe day's running low, plus the same distance. Reset the strike-touch flag at each day boundary.
Calculation: Confirmed swing high or low = a chart-bar high or low that is a pivot with the same selected number of bars on each side; it becomes available after the right-side bars complete. Each new confirmed swing replaces the previous swing of the same kind and is unbroken until a chart close first exceeds its high or falls below its low, respectively.
Long: First green day.
Short: First red day.
Long: Completed-day high > prior-day high AND completed-day low < prior-day low AND completed-day close > open.
Short: Completed-day high > prior-day high AND completed-day low < prior-day low AND completed-day close <= open.
Long: Directional bias = long AND bias invalidated = false.
Short: Directional bias = short AND bias invalidated = false.
Long: Up-cycle count = fade length.
Short: Down-cycle count = fade length.
Long: Down-cycle count = fade length.
Short: Up-cycle count = fade length.
Long: Up-cycle count > 0 AND chart low <= strike level AND no earlier strike touch in the current day.
Short: Down-cycle count > 0 AND chart high >= strike level AND no earlier strike touch in the current day.
Long: Completed Wednesday close >= every tracked completed-day close in the current week through Wednesday.
Short: Completed Wednesday close < the highest tracked completed-day close in the current week through Wednesday AND completed Wednesday close <= every tracked completed-day close in that week.
Long: Chart close > latest confirmed unbroken swing high.
Short: Chart close < latest confirmed unbroken swing low.