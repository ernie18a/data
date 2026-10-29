Calculation: Swing high/low = confirmed pivot high/low with equal left and right lookbacks
Calculation: Bullish/bearish structure trend = +1/-1 after the close crosses above the latest swing high / below the latest swing low, respectively; otherwise retain the prior trend
Calculation: Displacement = absolute candle body > ATR × the mode-dependent multiplier
Calculation: Bullish/bearish sweep = high > latest swing high and close < it / low < latest swing low and close > it, respectively
Calculation: Bullish/bearish FVG = current low > high two bars earlier / current high < low two bars earlier, respectively; require gap size at least ATR × minimum gap fraction, and in strict mode also require displacement
Calculation: Discount/premium = close is below 38.2% / above 61.8% of the rolling high-low range, respectively
Calculation: HTF bias = sum the directions (+1/-1/0) of three higher-timeframe fast-versus-slow EMA comparisons; bias is bullish at sum ≥ 2, bearish at sum ≤ -2, otherwise neutral. Use last completed higher-timeframe bars
Calculation: HTF aligned = HTF bias is neutral or matches the trade direction
Calculation: Compression = short-lookback ATR / longer-lookback ATR < compression threshold
Calculation: OB score = 2 base points, plus 2 for the directionally confirming sweep; plus 1 each for matching FVG, matching structure trend, aligned HTF bias when its filter is enabled, volume > 1.5 × 20-bar volume average, direction-matching discount/premium, strong displacement (body > 1.5 × displacement threshold), matching higher-timeframe candle color when enabled, price inside a same-direction higher-timeframe order block when enabled, and matching delta (5-bar average of ((close − low) − (high − close)) / (high − low) > 0.15 for bullish or < −0.15 for bearish); cap at 10
Calculation: Bullish/bearish OB = the high-low range of the opposite-color candle impulse-lookback-plus-one bars earlier, created when the current candle has matching direction and displacement; cap zone height at ATR × maximum OB height
Calculation: OB midpoint = (OB top + OB bottom) / 2
Calculation: Golden zone = close is between 61.8% and 78.6% of the rolling high-low range
Long: bullish OB is active, untriggered, and score ≥ minimum; session filter passes; HTF is aligned; compression block is off or compression is false; low ≤ OB midpoint; close > OB bottom; bullish structure trend
Long: close is in discount; bullish structure trend; rolling high-low range > 0
Long: close is in golden zone; bullish structure trend; close < prior close; rolling high-low range > 0
Long: low < latest swing low; close > latest swing low; displacement
Long: close crosses above latest swing high (prior close ≤ that swing high)
Long: bullish OB was invalidated within the reclaim window and close > its top
Short: bearish OB is active, untriggered, and score ≥ minimum; session filter passes; HTF is aligned; compression block is off or compression is false; high ≥ OB midpoint; close < OB top; bearish structure trend
Short: close is in premium; bearish structure trend; rolling high-low range > 0
Short: close is in golden zone; bearish structure trend; close > prior close; rolling high-low range > 0
Short: high > latest swing high; close < latest swing high; displacement
Short: close crosses below latest swing low (prior close ≥ that swing low)
Short: bearish OB was invalidated within the reclaim window and close < its bottom
Exit: long, high ≥ entry + risk × reward multiple OR low ≤ OB bottom − ATR × stop buffer
Exit: short, low ≤ entry − risk × reward multiple OR high ≥ OB top + ATR × stop buffer