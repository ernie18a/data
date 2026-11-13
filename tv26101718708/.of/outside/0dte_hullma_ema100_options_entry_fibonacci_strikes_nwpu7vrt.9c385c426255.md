Instrument: the underlying, on an intraday (5-minute) chart. The action is to buy same-day-expiry options, calls or puts, based on the underlying's own price. No exit or sell rule exists, and only entries are defined.

Indicators on the close: (1) a Hull moving average, treated as rising when its value is above the previous bar's value and as falling otherwise; (2) a slow EMA that sets the allowed direction.

Flip events: a falling flip occurs when the Hull was rising on the previous bar and is not rising now. A rising flip occurs when the Hull was not rising on the previous bar and is rising now.

Per-bar state: count bars since the start of the current day, resetting on a new day. A bar counts as after the open only when this count is at least a small skip number.

Put setup (bearish): true on a bar when all of these hold: a falling flip occurred on this bar or within the last N bars (a small confirmation window); close is below the slow EMA; the bar is after the open. This lets the Hull flip first and price confirm below the EMA up to N bars later. If confirmation never arrives inside the window, the setup lapses.

Call setup (bullish): the mirror image. A rising flip occurred within the last N bars, close is above the slow EMA, and the bar is after the open.

Trigger: fire only on the bar where a setup becomes true after being false on the previous bar. Suppress it if fewer than a cooldown number of bars have passed since the last accepted trigger of either direction. The cooldown timer restarts on every accepted trigger. Accepted triggers are put (buy a put) or call (buy a call). The slow EMA allows only one direction at a time, so put and call never both apply.

Strike and target selection (guides which option strike to buy): on a trigger, measure a reference swing range as the latest confirmed swing high minus the latest confirmed swing low. Pivots are confirmed only after a symmetric number of bars on each side. An alternative is the prior day's high minus low. Require both swing levels to exist and the range to be positive, otherwise record no strike targets, though the trigger still counts for cooldown. Take the trigger bar's close as entry. For a put, candidate strikes or price targets are the entry minus each of three Fibonacci fractions (about 0.382, 0.5, 0.618) of the range, all below entry. For a call, they are the entry plus the same fractions of the range, all above entry. Pick a strike near one of these levels.

Not used for decisions: higher-timeframe EMA trend readings are informational only and never filter or trigger.