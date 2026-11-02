Calculation: Session range = for each enabled session, when a session bar occurred N chart bars ago, take the highest high and lowest low of the most recent 2N chart bars, including the current bar; if multiple ranges are created on the same bar, use the first session in configured order.
Calculation: Large trade index = 50 + 50 × MA(close − close N bars ago, N) / ATR(N), using the selected EMA, SMA, or WMA; replace an unavailable lagged close with zero.
Calculation: Breakout orders = at the close of a session-range bar within the configured backtest dates, place or replace a buy stop at the range high and a sell stop at the range low. Orders remain pending until filled, replaced, or canceled; cancel the opposite order when a position opens.
Calculation: Stop and target levels = when a new session range is created within the configured backtest dates, set each side's target at its breakout order price plus or minus its configured fixed target distance, and its stop at its breakout order price minus or plus either its configured fixed stop distance or ATR on that range bar multiplied by a configured factor. Retain these levels until replaced by a later session range.
Long: Pending buy stop exists AND high >= buy stop price.
Short: Pending sell stop exists AND low <= sell stop price.
Exit: Long, low <= long stop level OR high >= long target level.
Exit: Short, high >= short stop level OR low <= short target level.
Exit: Long, previous bar's large trade index <= 50 when its filter is enabled OR previous bar's Andean Oscillator bull component <= bear component when its filter is enabled.
Exit: Short, previous bar's large trade index >= -50 when its filter is enabled OR previous bar's Andean Oscillator bear component <= bull component when its filter is enabled.
Exit: Long, current bar is in an enabled session.
Exit: Short, current bar is in an enabled session.