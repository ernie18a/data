Calculation: Relative volume = volume / max(SMA(volume, volume lookback), 1)
Calculation: Volatility ratio = ATR(short lookback) / ATR(long lookback); volatility is compressed below its threshold and expanded above its threshold
Calculation: Displacement candle = abs(close - open) / ATR(ATR lookback) >= body-ATR threshold AND abs(close - open) / max(high - low, minimum price increment) >= body-range threshold AND close > open for bullish or close < open for bearish
Calculation: A bullish or bearish structure break occurs when the configured break price (close, or high for an upward break and low for a downward break) exceeds the latest live confirmed pivot high or falls below the latest live confirmed pivot low, using either the internal or swing pivot lookback; classify it as CHoCH when prior structure direction was opposite, otherwise BOS; clear the broken pivot and update direction
Calculation: A bullish fair value gap forms when low > high[gap-separation lookback] AND the intervening candle closes above that earlier high; gap size must meet the minimum percentage and, when enabled, the ATR gap threshold; when enabled, the intervening candle must be bullish displacement. A bearish gap is the inverse using high < low[gap-separation lookback], the intervening close below the earlier low, and bearish displacement
Calculation: Fair value gap quality = clamp(weighted sum of normalized gap size, EMA trend alignment, higher-timeframe structure alignment, relative volume tier, premium/discount location, structure-break status, killzone status, and volatility-regime tier, quality floor, quality ceiling); active zones retain direction and quality until invalidated, inverted, or expired; price is inside a zone when the bar range overlaps it, and a CE tap occurs when low reaches the midpoint of a bullish zone or high reaches the midpoint of a bearish zone
Calculation: An inverse fair value gap forms when an active zone is fully filled and the close passes through its far boundary; when enabled, require displacement in the inversion direction and a structure break in that direction
Calculation: A bullish order block is the first earlier bearish candle within the order-block lookback before a bullish displacement candle; a bearish order block is the first earlier bullish candle before bearish displacement. A fresh bullish block retests when the bar overlaps its range and closes above its bottom; a fresh bearish block retests when it overlaps and closes below its top; a block breaks on a close beyond its far boundary
Calculation: Trend filter is bullish when close > EMA(close, shorter trend lookback) > EMA(close, longer trend lookback), and bearish when close < EMA(close, shorter trend lookback) < EMA(close, longer trend lookback)
Calculation: Swing range midpoint = average of the latest confirmed swing pivot high and low; discount is close below this midpoint and premium is close above it
Calculation: Bullish and bearish trendline breaks occur on the first bar close beyond the corresponding extrapolated pivot trendline; trendline slope is selected from ATR, standard deviation, or linear-regression slope, divided by the swing lookback and multiplied by the slope multiplier
Calculation: Opening range high and low are the highest high and lowest low during the configured session; an upward or downward opening-range break occurs after that session when close is above the high or below the low
Calculation: Daily context is read on chart bars from T1: the current T1 open and the last completed T1 high and low
Calculation: Higher-timeframe liquidity, structure, premium/discount, and fair value gap context are calculated on their respective T2, T3, and T4 bars and sampled on chart bars with lookahead off; bullish liquidity is a sell-side sweep or sell-side area, bearish liquidity is a buy-side sweep or buy-side area; structure direction follows the latest unbroken pivot break; premium/discount compares close with the midpoint of the latest pivot range
Calculation: Bull and bear confluence scores are weighted sums of, respectively: active FVG overlap, FVG quality tiers, structure break, CHoCH, liquidity sweep, trendline break, trend filter, higher-timeframe structure, discount or premium, order-block retest, inverse FVG, killzone, daily open and prior-day levels, relative-volume tier, volatility tier, and the corresponding higher-timeframe score. The higher-timeframe score weights liquidity code, context structure event or direction, macro structure direction, context premium/discount, context FVG direction and quality, and context inverse FVG direction
Calculation: Automatic confluence threshold is the profile base threshold adjusted upward for compressed volatility, trend chop, and low relative volume, and downward for momentum expansion and strong trend, then clamped to its configured bounds; otherwise use the configured effective threshold
Calculation: Bull and bear sentiment points are weighted votes for structure direction, liquidity sweep, discount or premium or FVG or order-block context, momentum outside squeeze, strong ADX with DI direction, VWAP side excluding the corresponding extreme, volume pressure, and a killzone bonus for the side leading before that bonus; sentiment percentage = bull points / (bull points + bear points), or neutral when the total is zero
Calculation: Momentum oscillator = linear regression of close minus the average of the midpoint between highest high and lowest low and SMA(close), all over the momentum lookback; momentum signal = SMA(momentum oscillator, signal lookback); bullish momentum is oscillator above signal and bearish momentum is oscillator below signal
Calculation: Bullish volume pressure occurs when volume * (close - low) / max(high - low, minimum price increment), divided by volume and expressed as a percentage, meets the buy-pressure threshold; bearish pressure occurs when its complement meets the sell-pressure threshold
Long: bullish fair value gap forms
Short: bearish fair value gap forms
Long: an active bearish fair value gap inverts into a bullish inverse fair value gap
Short: an active bullish fair value gap inverts into a bearish inverse fair value gap
Long: a bullish internal or swing structure break occurs, including BOS or CHoCH
Short: a bearish internal or swing structure break occurs, including BOS or CHoCH
Long: an active sell-side liquidity zone is swept with the configured close-back-inside or close-through-zone confirmation
Short: an active buy-side liquidity zone is swept with the configured close-back-inside or close-through-zone confirmation
Long: for the crypto market profile, low < low[1] AND close > low[1]
Short: for the crypto market profile, high > high[1] AND close < high[1]
Long: the upper trendline break state changes from inactive to active
Short: the lower trendline break state changes from inactive to active
Long: bull score >= effective confluence threshold AND bull score > bear score AND this condition was false on the previous bar
Short: bear score >= effective confluence threshold AND bear score > bull score AND this condition was false on the previous bar
Long: bull sentiment percentage crosses above its configured dominance threshold
Short: bull sentiment percentage crosses below its configured bearish-dominance threshold
Long: bullish momentum becomes true after being false on the previous bar
Short: bearish momentum becomes true after being false on the previous bar
Long: a bullish demand reaction occurs (bullish order-block retest, price in a bullish FVG, bullish CE tap, or bullish inverse FVG) AND a bullish CHoCH, bullish structure break, or bullish trend filter occurs
Short: a bearish supply reaction occurs (bearish order-block retest, price in a bearish FVG, bearish CE tap, or bearish inverse FVG) AND a bearish CHoCH, bearish structure break, or bearish trend filter occurs
Long: a fresh bearish order block has failed and its range retests as support
Short: a fresh bullish order block has failed and its range retests as resistance
Long: resistance is broken by a close above the latest swing high plus the ATR support/resistance band AND relative volume meets its minimum AND volatility is expanded or volume exceeds its moving average
Short: support is broken by a close below the latest swing low minus the ATR support/resistance band AND relative volume meets its minimum AND volatility is expanded or volume exceeds its moving average
Long: sell-side liquidity was swept and a bullish CHoCH occurs
Short: buy-side liquidity was swept and a bearish CHoCH occurs
Long: a bullish inverse FVG forms OR price is inside a bullish FVG, taps its midpoint, and its quality meets the high-quality threshold
Short: a bearish inverse FVG forms OR price is inside a bearish FVG, taps its midpoint, and its quality meets the high-quality threshold
Long: a bullish BOS, upper trendline break, or opening-range upward break occurs AND higher-timeframe structure is non-bearish or the trend filter is bullish
Short: a bearish BOS, lower trendline break, or opening-range downward break occurs AND higher-timeframe structure is non-bullish or the trend filter is bearish
Long: the trend filter is bullish AND higher-timeframe structure is bullish AND close is in discount
Short: the trend filter is bearish AND higher-timeframe structure is bearish AND close is in premium
Long: a sell-side sweep occurs on T2 AND a bullish CHoCH or structure break occurs AND T3 or T4 structure is non-bearish
Short: a buy-side sweep occurs on T2 AND a bearish CHoCH or structure break occurs AND T3 or T4 structure is non-bullish
Long: a bullish FVG is active on T3, its quality meets the minimum, its range overlaps the current T3 bar, and the chart bar taps a bullish CE or overlaps a bullish FVG
Short: a bearish FVG is active on T3, its quality meets the minimum, its range overlaps the current T3 bar, and the chart bar taps a bearish CE or overlaps a bearish FVG
Long: the market is not in a time blackout or compressed-volatility/low-volume condition AND a demand reaction and bullish CHoCH or structure break or trend filter occur
Short: the market is not in a time blackout or compressed-volatility/low-volume condition AND a supply reaction and bearish CHoCH or structure break or trend filter occur
Long: the market is not in a time blackout or compressed-volatility/low-volume condition AND a bullish breaker retest occurs
Short: the market is not in a time blackout or compressed-volatility/low-volume condition AND a bearish breaker retest occurs
Long: the market is not in a time blackout or compressed-volatility/low-volume condition AND a resistance volume break occurs
Short: the market is not in a time blackout or compressed-volatility/low-volume condition AND a support volume break occurs
Long: bias is neutral; buy a sell-side liquidity sweep
Short: bias is neutral; sell a buy-side liquidity sweep