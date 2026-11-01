Calculation: Directional score = Count one point for each true condition: close is on the direction's side of session VWAP; chart-timeframe RSI is on the direction's side of its midpoint; MACD line is on the direction's side of its signal line; shorter-period EMA is on the direction's side of longer-period EMA; ADX is above its threshold AND close is on the direction's side of the shorter-period EMA; volume > 0 AND volume > SMA of volume AND close is on the direction's side of open; confirmation-timeframe RSI is on the direction's side of its midpoint. The confirmation timeframe is configurable as higher or lower than the chart timeframe; use its still-forming bar for a higher timeframe and its last available intrabar for a lower timeframe. The external-instrument factor contributes zero when its data is unavailable.
Calculation: Average daily range = SMA of high minus low over completed calendar-day bars. These bars are higher than an intraday chart timeframe; use the last completed daily bar.
Calculation: Current day range = highest high minus lowest low accumulated from chart bars in the current calendar day; on a daily or higher chart, use the current chart bar's high minus low.
Calculation: Entry risk = ATR on the entry bar multiplied by a stop-distance parameter; entry price is the entry bar's close.
Calculation: Working stop = entry price minus entry risk for a long or plus entry risk for a short; if the optional breakeven rule is enabled and the first target was reached on an earlier bar, use entry price instead. The first target is entry price plus entry risk for a long or minus entry risk for a short.
Long: Shorter-period EMA crosses above longer-period EMA AND (confluence gate is disabled OR bullish directional score >= the configured minimum capped at the number of enabled factors) AND (session filter is disabled OR chart timeframe is daily or higher OR bar time is within either configured session window) AND (range filter is disabled OR chart timeframe is weekly or higher OR average daily range is unavailable or nonpositive OR current day range / average daily range < configured threshold) AND (no earlier entry exists OR bars since the most recent entry >= configured minimum).
Short: Shorter-period EMA crosses below longer-period EMA AND (confluence gate is disabled OR bearish directional score >= the configured minimum capped at the number of enabled factors) AND (session filter is disabled OR chart timeframe is daily or higher OR bar time is within either configured session window) AND (range filter is disabled OR chart timeframe is weekly or higher OR average daily range is unavailable or nonpositive OR current day range / average daily range < configured threshold) AND (no earlier entry exists OR bars since the most recent entry >= configured minimum).
Long: The latest trade is open and long AND low <= shorter-period EMA AND low > longer-period EMA.
Short: The latest trade is open and short AND high >= shorter-period EMA AND high < longer-period EMA.
Long: Bullish directional score >= bearish directional score.
Short: Bullish directional score < bearish directional score.
Long: Bullish directional score / number of enabled factors crosses above the configured strong-bias threshold.
Short: Bearish directional score / number of enabled factors crosses above the configured strong-bias threshold.
Long: Shorter-period EMA > longer-period EMA.
Short: Shorter-period EMA <= longer-period EMA.
Long: Close > session VWAP.
Short: Close <= session VWAP.
Long: Chart-timeframe RSI > its midpoint.
Short: Chart-timeframe RSI <= its midpoint.
Long: MACD line > MACD signal line.
Short: MACD line <= MACD signal line.
Long: Confirmation-timeframe RSI > its midpoint.
Short: Confirmation-timeframe RSI <= its midpoint.
Exit: long, bar is after the entry bar AND (low <= working stop OR high >= entry price + entry risk multiplied by the configured final target number); evaluate the stop before the target.
Exit: short, bar is after the entry bar AND (high >= working stop OR low <= entry price - entry risk multiplied by the configured final target number); evaluate the stop before the target.