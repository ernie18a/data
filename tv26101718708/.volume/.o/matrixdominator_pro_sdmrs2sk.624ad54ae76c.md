Calculation: ATR = average true range on the chart bars
Calculation: Short/long ATR ratio = ATR with a shorter lookback divided by ATR with a longer lookback
Calculation: Trend = bullish after the close crosses above the latest confirmed swing high; bearish after it crosses below the latest confirmed swing low; otherwise retain the prior trend
Calculation: Bullish/bearish sweep = price trades above the latest confirmed swing high / below the latest confirmed swing low, then closes back below / above it
Calculation: Displacement = absolute close-open > ATR × displacement threshold
Calculation: Bullish/bearish fair value gap = current low > high two bars earlier / current high < low two bars earlier, with gap size meeting the minimum ATR-based size; in strict mode also require displacement; in all mode omit the size and displacement filters
Calculation: Relative volume spike = volume > its moving average
Calculation: Candle delta = moving average of the recent values of ((close-low) - (high-close)) / (high-low); bullish when above a positive threshold, bearish when below its negative
Calculation: Premium/discount position = (close - lowest low in the range lookback) / (highest high - lowest low); discount below the lower zone threshold, premium above the upper zone threshold
Calculation: Higher-timeframe bias = for each of three progressively longer timeframes, compare the fast EMA with the slow EMA; bullish if at least two comparisons are bullish, bearish if at least two are bearish, otherwise neutral. Use the current forming higher-timeframe bars; on daily or higher chart bars use progressively longer weekly, monthly, and quarterly bars
Calculation: Higher-timeframe candle direction = compare close with open of the first higher timeframe bar; use the current forming bar (weekly on daily or higher charts)
Calculation: Order block = after a displacement candle, use the candle from the impulse lookback before it if that candle has the opposite direction; bullish block bounds are its low to high, bearish block bounds are its low to high, capped at the maximum ATR-based height
Calculation: Order-block score = start at 2; add 2 for a directionally relevant sweep, and 1 each for a matching fair value gap, matching trend, aligned non-neutral higher-timeframe bias when that filter is enabled, relative volume spike, matching discount/premium zone, strong displacement, matching higher-timeframe candle when enabled, matching active higher-timeframe order-block zone, and matching candle delta; cap at 10, then add any reclaim boost and cap at 10
Calculation: Session allowed = daily or higher chart, or session filter disabled, or current time is within an enabled London, New York, or Asian session
Calculation: Reclaimed order block = an inactive, untriggered block closes back beyond its far edge within the reclaim window; reactivate it once and boost its score
Calculation: Entry = midpoint of the order-block bounds
Calculation: Stop and target = for long, stop below the block low by an ATR buffer; for short, stop above the block high by an ATR buffer; first target is entry plus (long) or minus (short) the entry-to-stop risk times the first risk-reward multiple
Long: bullish sweep AND displacement
Short: bearish sweep AND displacement
Long: close crosses above the latest confirmed swing high
Short: close crosses below the latest confirmed swing low
Long: discount position AND bullish trend AND range high > range low
Short: premium position AND bearish trend AND range high > range low
Long: position is in the golden zone AND bullish trend AND close < prior close AND range high > range low
Short: position is in the golden zone AND bearish trend AND close > prior close AND range high > range low
Long: an active, untriggered bullish order block has score >= minimum score AND session allowed AND higher-timeframe aligned (or filter disabled, or bias neutral) AND short/long ATR ratio is not below the compression threshold when chop blocking is enabled AND low <= block midpoint AND close > block low AND trend is bullish
Short: an active, untriggered bearish order block has score >= minimum score AND session allowed AND higher-timeframe aligned (or filter disabled, or bias neutral) AND short/long ATR ratio is not below the compression threshold when chop blocking is enabled AND high >= block midpoint AND close < block high AND trend is bearish
Exit: long, high >= first target OR low <= stop
Exit: short, low <= first target OR high >= stop