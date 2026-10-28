Calculation: Daily ATR = ATR from the last completed daily bar.
Calculation: Daily fast and slow EMA = fast and slow EMAs of close from the last completed daily bar; their prior values are from successively earlier completed daily bars.
Calculation: Daily opening price = open of the current daily bar.
Calculation: Major and tactical liquidity levels = highest high and lowest low over the longer and shorter lookbacks of completed daily bars, respectively.
Calculation: Daily expected-move bands = current daily open ± daily open × standard deviation of daily log returns over the volatility lookback, from the last completed daily bar, × square root of the horizon × configured multiplier.
Calculation: RV expansion = daily return volatility from the last completed daily bar is greater than its moving average from the last completed daily bar.
Calculation: Bullish/bearish sweep = current bar crosses below the lower / above the upper of a major level, tactical level, or expected-move band, then closes back above / below that level.
Calculation: Sweep score = 3 for a major sweep, otherwise 2 for a tactical or expected-move sweep, plus one for each additional swept level beyond the first.
Calculation: Strong relative volume = current volume divided by the average for the same intraday time slot over prior sessions (or the recent-bar average when unavailable or not using intraday slot normalization) meets the configured threshold.
Calculation: Bullish/bearish displacement = candle body points up/down, its size relative to daily ATR and its fraction of bar range meet configured thresholds, and its close is sufficiently near the high/low.
Calculation: Bullish/bearish internal structure break = close crosses above the prior-bar high / below the prior-bar low of the internal structure lookback.
Calculation: Bullish/bearish swing structure break = close crosses above the latest confirmed swing high / below the latest confirmed swing low; a confirmed swing uses configured left and right bars.
Calculation: Bullish/bearish BOS = bullish/bearish swing structure break and the latest confirmed swing high is higher / latest confirmed swing low is lower than the preceding confirmed swing of that type.
Calculation: Bullish/bearish structure confirmation = swing break if required; otherwise swing break or enabled internal structure break.
Calculation: Trend alignment = daily fast EMA > / < daily slow EMA and daily slow EMA > / < its prior value.
Calculation: Bullish/bearish continuation regime = daily fast EMA rises / falls and current close is above / below it.
Calculation: Bullish/bearish transition regime = current close is above / below daily fast EMA, its daily-ATR-normalized slope is above the configured lower bound / below the configured upper bound, and bearish / bullish trend alignment is absent.
Calculation: Bullish/bearish fast-EMA reclaim = close crosses above / below daily fast EMA.
Calculation: Bullish/bearish continuation break = continuation regime and close crosses above / below the prior-bar extreme over the continuation lookback.
Calculation: Bullish/bearish transition break = close crosses above / below the prior-bar extreme over the transition lookback.
Calculation: Bullish/bearish recent transition structure = an internal break, swing break, or bullish/bearish BOS occurred within the configured recent-structure window.
Calculation: Bullish/bearish continuation score = 2 for continuation regime; +1 for same-direction swing sequence; +1 for same-direction internal break; +2 for same-direction BOS or +1 for other same-direction swing break; +1 for same-direction displacement, strong relative volume, and RV expansion; bullish also gets +1 when enabled VIX is below its basis.
Calculation: Bullish/bearish transition score = 2 for transition regime; +1 for recent transition structure, same-direction displacement, strong relative volume, and RV expansion.
Calculation: Bullish/bearish reversal score = sweep score; +2 for enabled trend alignment; +3 for same-direction BOS or +2 for other swing break, else +1 for enabled internal break; +1 each for reclaim (close above/below daily open or intraday VWAP), strong relative volume, same-direction displacement, RV expansion, and enabled VIX above its upper band for bullish / below its basis for bearish.
Calculation: Bullish/bearish reversal setup = a confirmed, exclusive bullish/bearish sweep arms the setup; within the confirmation window, the reversal score meets the trend-aligned minimum or the higher countertrend minimum, trend alignment or the configured countertrend sweep eligibility holds, and any required structure confirmation holds. The sweep bar itself is not an entry bar. A setup invalidates if its close exceeds the swept low/high by the configured daily-ATR buffer; it expires after the confirmation window.
Calculation: Bullish/bearish continuation setup = continuation break, same-direction swing or internal structure break, extension from daily fast EMA within the configured daily-ATR ceiling, continuation score meets its minimum, and bar is confirmed.
Calculation: Bullish/bearish transition qualification = fast-EMA reclaim arms for the configured window; while active, transition regime, recent structure, extension within the configured daily-ATR ceiling, and transition score meeting its minimum qualify it. Qualification remains executable for the configured execution window.
Calculation: Reversal stop = swept low minus / swept high plus the configured daily-ATR buffer.
Calculation: Continuation stop = the tighter of the prior continuation breakout extreme adjusted by its configured daily-ATR buffer and the latest confirmed swing low/high, when that swing exists.
Calculation: Transition stop = the tighter of daily fast EMA, prior transition breakout extreme adjusted by its configured daily-ATR buffer, and latest confirmed swing low/high, when that swing exists.
Calculation: A route has valid risk when its entry close is on the protective side of its stop and the distance is no greater than the configured maximum daily-ATR risk.
Calculation: Entry readiness = flat position, daily ATR available, and no exit cooldown in effect.
Calculation: Reversal route = new reversal setup; continuation route = new continuation setup; transition route = executable transition qualification. For each side, reversal has priority over transition, which has priority over continuation.
Calculation: Exit structure breach = opposing swing break and close breaches the best same-side confirmed swing structure locked since entry by the configured daily-ATR buffer.
Calculation: Runner trail = after favorable close movement reaches the configured multiple of initial risk, use the more protective of the extreme since entry adjusted by the configured daily-ATR trail distance and locked swing structure adjusted by its configured buffer.
Long: bullish sweep.
Short: bearish sweep.
Long: entry readiness AND (reversal route AND valid reversal risk OR no reversal route AND transition route AND valid transition risk OR no reversal or transition route AND continuation route AND valid continuation risk).
Short: entry readiness AND NOT long entry AND (reversal route AND valid reversal risk OR no reversal route AND transition route AND valid transition risk OR no reversal or transition route AND continuation route AND valid continuation risk).
Exit: long, low <= initial stop OR confirmed exit structure breach OR minimum holding period met AND runner active AND low <= runner trail OR minimum holding period met AND take-profit enabled AND high >= entry price + initial risk × configured reward multiple.
Exit: short, high >= initial stop OR confirmed exit structure breach OR minimum holding period met AND runner active AND high >= runner trail OR minimum holding period met AND take-profit enabled AND low <= entry price - initial risk × configured reward multiple.