Calculation: Structure pivot high = PivotHigh(high, half-length of the next odd structure lookback)
Calculation: Structure pivot low = PivotLow(low, half-length of the next odd structure lookback)
Calculation: Upward structure break = on a confirmed bar, close > latest unbroken pivot high when the close-break setting is enabled, otherwise high > it; if both pivot levels break, keep the upward break only when close >= open
Calculation: Downward structure break = on a confirmed bar, close < latest unbroken pivot low when the close-break setting is enabled, otherwise low < it; if both pivot levels break, keep the downward break only when close < open
Calculation: Rejection-wick percentage = rejection-wick size / (high - low) as a percentage; lower-wick size = min(open, close) - low, upper-wick size = high - max(open, close)
Calculation: Bullish FVG setup = low > high[2] AND close[1] > low[1] + ATR(FVG ATR lookback)[1] * FVG displacement threshold
Calculation: Bearish FVG setup = low[2] > high AND close[1] < high[1] - ATR(FVG ATR lookback)[1] * FVG displacement threshold
Calculation: FVG overlap = max(zone bottoms) < min(zone tops)
Calculation: FVG overlap filtering = when enabled, remove older same-direction gaps overlapping the newest gap of that direction, then remove bullish gaps overlapping the newest bearish gap and bearish gaps overlapping the newest bullish gap
Calculation: Bullish Fibonacci entry zone = interval between anchor + unit * shallow entry ratio and anchor + unit * deep entry ratio, where anchor is the latest pivot low or CHoCH-bar low if unavailable, and unit is CHoCH-bar high - anchor
Calculation: Bearish Fibonacci entry zone = interval between anchor + unit * shallow entry ratio and anchor + unit * deep entry ratio, where anchor is the latest pivot high or CHoCH-bar high if unavailable, and unit is CHoCH-bar low - anchor
Calculation: Bullish liquidity trendline = line from the preceding LL liquidity level to the first confirmed post-bullish-CHoCH pivot low above that level
Calculation: Bearish liquidity trendline = line from the preceding HH liquidity level to the first confirmed post-bearish-CHoCH pivot high below that level
Long: Upward structure break AND prior structure direction bearish
Short: Downward structure break AND prior structure direction bullish
Long: Upward structure break AND active CHoCH direction bullish AND prior structure direction bullish
Short: Downward structure break AND active CHoCH direction bearish AND prior structure direction bearish
Long: Candidate engine enabled AND active CHoCH direction nonzero AND latest pivot high remains unbroken
Short: Candidate engine enabled AND active CHoCH direction nonzero AND latest pivot low remains unbroken
Long: Active CHoCH direction bullish AND rejected-block pivot low's center bar is after the CHoCH bar AND sequence has not advanced past rejected-block formation AND Rejection-wick percentage >= minimum wick percentage AND lower-wick size meets the minimum ATR wick filter, if enabled
Short: Active CHoCH direction bearish AND rejected-block pivot high's center bar is after the CHoCH bar AND sequence has not advanced past rejected-block formation AND Rejection-wick percentage >= minimum wick percentage AND upper-wick size meets the minimum ATR wick filter, if enabled
Long: A bullish rejected block is armed on a confirmed bar after formation when low > its top, then a later confirmed bar touches it (low <= top AND high >= bottom) without an intervening close below its bottom
Short: A bearish rejected block is armed on a confirmed bar after formation when high < its bottom, then a later confirmed bar touches it (low <= top AND high >= bottom) without an intervening close above its top
Long: FVG engine enabled AND Bullish FVG setup[1] is confirmed on the current closed bar
Short: FVG engine enabled AND Bearish FVG setup[1] is confirmed on the current closed bar
Long: After a bullish rejected-block retest, the latest bullish BOS and bullish FVG confirmation occur within the FVG/BOS association window
Short: After a bearish rejected-block retest, the latest bearish BOS and bearish FVG confirmation occur within the FVG/BOS association window
Long: After bullish FVG/BOS association, on a later confirmed bar low < final bullish FVG top AND the gap is not invalidated by the selected mitigation rule; body-extreme mode invalidates when min(open, close) < bottom, wick mode when low < bottom, and midpoint mode when low < midpoint
Short: After bearish FVG/BOS association, on a later confirmed bar high > final bearish FVG bottom AND the gap is not invalidated by the selected mitigation rule; body-extreme mode invalidates when max(open, close) > top, wick mode when high > top, and midpoint mode when high > midpoint
Long: FVG engine enabled AND breaker mode selected AND a retained bearish FVG is mitigated on a confirmed bar; body-extreme mode requires max(open, close) > top, wick mode high > top, and midpoint mode high > midpoint
Short: FVG engine enabled AND breaker mode selected AND a retained bullish FVG is mitigated on a confirmed bar; body-extreme mode requires min(open, close) < bottom, wick mode low < bottom, and midpoint mode low < midpoint
Long: Fibonacci zones and entry box enabled AND valid bullish CHoCH displacement exceeds the instrument minimum price increment AND price has touched the bullish Fibonacci entry zone AND a confirmed close is above its top; signal occurs once per CHoCH
Short: Fibonacci zones and entry box enabled AND valid bearish CHoCH displacement exceeds the instrument minimum price increment in magnitude AND price has touched the bearish Fibonacci entry zone AND a confirmed close is below its bottom; signal occurs once per CHoCH
Long: ATR boundaries enabled AND the first confirmed break after a CHoCH is above CHoCH-bar high + ATR(boundary lookback on CHoCH bar) * boundary multiplier, using close when the close-break setting is enabled and high otherwise; simultaneous boundary breaks resolve by close >= open
Short: ATR boundaries enabled AND the first confirmed break after a CHoCH is below CHoCH-bar low - ATR(boundary lookback on CHoCH bar) * boundary multiplier, using close when the close-break setting is enabled and low otherwise; simultaneous boundary breaks resolve by close < open
Long: Liquidity trendline enabled AND a bearish liquidity trendline is validated AND, on a later confirmed bar, close > trendline when the line close-break setting is enabled, otherwise high > trendline; signal occurs once
Short: Liquidity trendline enabled AND a bullish liquidity trendline is validated AND, on a later confirmed bar, close < trendline when the line close-break setting is enabled, otherwise low < trendline; signal occurs once
Long: The reference market's latest pivot-break direction is bullish, using the structure pivot lookback and break-source setting; reference data is sampled at the chart timeframe and may use the forming bar
Short: The reference market's latest pivot-break direction is bearish, using the structure pivot lookback and break-source setting; reference data is sampled at the chart timeframe and may use the forming bar
Long: PlusDI(DMI lookback) >= MinusDI(DMI lookback) on the current chart bar, including a forming bar
Short: PlusDI(DMI lookback) < MinusDI(DMI lookback) on the current chart bar, including a forming bar
Long: ROC(close, momentum lookback) > 0 on the current chart bar, including a forming bar
Short: ROC(close, momentum lookback) < 0 on the current chart bar, including a forming bar
Long: Elder Force Index(close, volume, smoothing lookback) > 0 on the current chart bar, including a forming bar
Short: Elder Force Index(close, volume, smoothing lookback) < 0 on the current chart bar, including a forming bar