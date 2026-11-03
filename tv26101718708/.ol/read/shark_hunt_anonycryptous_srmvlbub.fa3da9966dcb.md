Calculation: ATR = Average True Range
Calculation: Bullish liquidity zone = A confirmed swing low plus an ATR-scaled zone above it; bearish liquidity zone = a confirmed swing high plus an ATR-scaled zone below it. Confirm each swing using bars on both sides on the chart timeframe; use only after the right-side bars have completed.
Calculation: Zone impulse score = weighted combination of candle body/range, volume/rolling average volume, and candle range/ATR; for nearby zones of the same side, retain the higher-scoring zone.
Calculation: Lower-wick rejection = lower wick / (high - low); upper-wick rejection = upper wick / (high - low).
Calculation: Bullish price failure = low breaks below the latest confirmed pivot low and close returns above it, with the prior bar's low at or above the pivot; bearish price failure = high breaks above the latest confirmed pivot high and close returns below it, with the prior bar's high at or below the pivot. Use a five-bar left and right pivot lookback on the chart timeframe; act only after confirmation.
Calculation: Bullish absorption = current bar closes above open, previous bar closes below open, current close exceeds previous open, and current open is below previous close; bearish absorption = the inverse.
Calculation: Bullish wick trap = lower wick exceeds twice the candle body and half an ATR; bearish wick trap = upper wick exceeds twice the candle body and half an ATR.
Calculation: Bullish imbalance = current low exceeds the high two bars earlier and the middle bar closes above open; bearish imbalance = current high is below the low two bars earlier and the middle bar closes below open.
Calculation: Bullish level retest = after a close crosses above a confirmed pivot high, a later bar touches or dips below that level and closes at or above it, before the retest is invalidated by a close below; bearish level retest = after a close crosses below a confirmed pivot low, a later bar touches or rises above that level and closes at or below it, before invalidation by a close above. Use confirmed five-bar pivots on the chart timeframe.
Long: On a confirmed bar, bullish price failure.
Short: On a confirmed bar, bearish price failure.
Long: Bullish absorption.
Short: Bearish absorption.
Long: Bullish wick trap.
Short: Bearish wick trap.
Long: Bullish imbalance.
Short: Bearish imbalance.
Long: Bullish level retest.
Short: Bearish level retest.
Long: Failure-entry mode is enabled; a fresh confirmed pivot-low failure has a lower wick at least the configured ATR multiple and rejection percentage, meets the optional rolling-average-volume threshold, and passes the same-direction cooldown.
Short: Failure-entry mode is enabled; a fresh confirmed pivot-high failure has an upper wick at least the configured ATR multiple and rejection percentage, meets the optional rolling-average-volume threshold, and passes the same-direction cooldown.
Long: Failure-entry mode is disabled; a fresh eligible bullish zone has low below its lower boundary by at least the configured penetration percentage, close above that boundary, passes the optional volume and lower-wick rejection filters, meets the zone hold threshold, passes the bullish cooldown, and passes each enabled bullish price-failure, wick-trap, and absorption gate.
Short: Failure-entry mode is disabled; a fresh eligible bearish zone has high above its upper boundary by at least the configured penetration percentage, close below that boundary, passes the optional volume and upper-wick rejection filters, meets the zone hold threshold, passes the bearish cooldown, and passes each enabled bearish price-failure, wick-trap, and absorption gate.
Calculation: Stop price = for a long, the selected zone boundary or sweep-wick extreme minus the configured ATR buffer; for a short, the selected zone boundary or sweep-wick extreme plus the configured ATR buffer. Failure entries use the selected pivot level or failure-wick extreme instead.
Calculation: Profit target = entry price plus (long) or minus (short) the absolute entry-to-stop distance multiplied by the configured reward/risk ratio.
Exit: Long, high >= profit target OR low <= stop price.
Exit: Short, low <= profit target OR high >= stop price.