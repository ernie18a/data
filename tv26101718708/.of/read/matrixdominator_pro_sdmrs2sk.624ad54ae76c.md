Calculation: Average true range = average true range over a lookback
Calculation: Bullish structure = close crosses above the latest confirmed pivot high; bearish structure = close crosses below the latest confirmed pivot low
Calculation: Order block = the high-low range of the bar before an opposite-color bar, when the current candle has displacement; bullish if current close > open and the earlier bar close < open, bearish if current close < open and the earlier bar close > open
Calculation: Order block score = base score plus bonuses for an opposing liquidity sweep, same-direction fair value gap, matching structure, aligned higher-timeframe bias, volume spike, discount for longs or premium for shorts, strong displacement, aligned higher-timeframe candle, matching higher-timeframe order-block zone, and matching volume delta; cap at 10
Calculation: Higher-timeframe bias = each of three higher-timeframe fast EMAs compared with its slower EMA; bullish if at least two are higher, bearish if at least two are lower, otherwise neutral. Use the current higher-timeframe bar while it is forming and the last completed bar historically.
Calculation: Fair value gap = bullish when current low > high two bars earlier; bearish when current high < low two bars earlier
Calculation: Discount/premium position = (close − lowest low in lookback) / (highest high in lookback − lowest low in lookback); discount < 0.382, premium > 0.618
Calculation: Volume spike = volume > its longer-term simple moving average × threshold
Calculation: Volume delta = short-term average of ((close − low) − (high − close)) / (high − low); bullish above threshold, bearish below its negative
Calculation: Higher-timeframe order block = a higher-timeframe candle with body > ATR × threshold and opposite color to the preceding candle; zone is the preceding candle's high-low range. Use the current higher-timeframe bar while forming and the last completed bar historically.
Calculation: Regime ratio = shorter-lookback ATR / longer-lookback ATR; compression when below threshold
Calculation: Long entry price = midpoint of bullish order block; stop = block low − ATR × buffer; first target = entry + (entry − stop) × reward multiple
Calculation: Short entry price = midpoint of bearish order block; stop = block high + ATR × buffer; first target = entry − (stop − entry) × reward multiple
Long: bullish order block is active, untriggered, and score meets minimum; session filter passes; higher-timeframe bias is bullish or neutral; regime is not blocked compression; low ≤ order-block midpoint; close > block low; bullish structure
Long: bullish liquidity sweep (high > latest pivot high AND close < latest pivot high AND displacement)
Long: bullish structure break (close crosses above latest confirmed pivot high)
Long: discount position AND bullish structure AND range is positive
Long: golden-zone position (0.618 to 0.786) AND bullish structure AND close < prior close AND range is positive
Long: bullish order block reclaim (previously invalidated bullish block, within reclaim window, close > block high)
Short: bearish order block is active, untriggered, and score meets minimum; session filter passes; higher-timeframe bias is bearish or neutral; regime is not blocked compression; high ≥ order-block midpoint; close < block high; bearish structure
Short: bearish liquidity sweep (low < latest pivot low AND close > latest pivot low AND displacement)
Short: bearish structure break (close crosses below latest confirmed pivot low)
Short: premium position AND bearish structure AND range is positive
Short: golden-zone position (0.618 to 0.786) AND bearish structure AND close > prior close AND range is positive
Short: bearish order block reclaim (previously invalidated bearish block, within reclaim window, close < block low)
Exit: Long, high ≥ first target OR low ≤ stop
Exit: Short, low ≤ first target OR high ≥ stop