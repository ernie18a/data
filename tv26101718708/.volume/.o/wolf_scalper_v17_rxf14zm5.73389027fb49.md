Calculation: ATR = average true range; the same ATR is used for displacement, chop, and entry-distance checks
Calculation: Pivot high/low = a high/low with the configured number of lower/higher bars on each side; use the latest confirmed pivot
Calculation: Bullish FVG = current low is above the high two bars earlier; bearish FVG = current high is below the low two bars earlier
Calculation: Bullish iFVG event = close crosses above the top of an un-inverted bearish FVG; bearish iFVG event = close crosses below the bottom of an un-inverted bullish FVG
Calculation: Bullish order block = prior candle body, created when close exceeds the prior high and the current bullish body exceeds ATR; bearish order block = prior candle body, created when close falls below the prior low and the current bearish body exceeds ATR
Calculation: Bullish CISD = two or three consecutive rising closes; bearish CISD = two or three consecutive falling closes
Calculation: Bullish CHoCH = close exceeds the latest confirmed pivot high while the recorded trend is not bullish; bearish CHoCH = close falls below the latest confirmed pivot low while the recorded trend is not bearish. Update trend to the triggered direction
Calculation: Discount = close below the midpoint between the midpoint and the lowest low of the range lookback; premium = close above the midpoint between the midpoint and the highest high of that range
Calculation: Bullish confluences = sum of: confirmed bullish setup, recent bullish sweep, bullish trend or CHoCH, price in bullish FVG/iFVG/order block, bullish CISD, discount, and close above the current day's 9:30 New York open. Bearish confluences use the corresponding bearish conditions, premium, and close below that open
Long: Bullish CISD
Long: Bullish CHoCH
Long: A low sweeps below the latest confirmed pivot low, closes back above it, and the lower wick exceeds the configured fraction of the candle range
Long: A high sweeps above the latest confirmed pivot high, closes back below it, the upper wick exceeds the configured fraction of the candle range, and close > open
Long: Bullish iFVG event
Long: Price overlaps a bullish inverted FVG, close > open, and bullish body > configured ATR multiple
Long: Price overlaps a bullish order block, close > open, and bullish body > configured ATR multiple
Long: Low < latest confirmed pivot low, or price overlaps a bullish inverted FVG, or a bullish SMT event occurs; chop filter passes; more than two bars since the prior early-long marking
Long: Confirmed bullish setup AND bullish confluences >= A++ minimum AND (strict session gate disabled OR within an enabled NY AM, NY PM, or London session) AND chop filter passes AND (volume filter disabled OR volume exceeds its configured multiple of its moving average) AND (premium blocking enabled OR close is not in premium) AND no bullish signal within the configured cooldown
Long: Confirmed bullish setup AND bullish confluences >= B minimum AND bullish confluences < A++ minimum AND chop filter passes AND no bullish signal within the configured cooldown
Short: Bearish CISD
Short: Bearish CHoCH
Short: A high sweeps above the latest confirmed pivot high, closes back below it, and the upper wick exceeds the configured fraction of the candle range
Short: A low sweeps below the latest confirmed pivot low, closes back above it, the lower wick exceeds the configured fraction of the candle range, and close < open
Short: Bearish iFVG event
Short: Price overlaps a bearish inverted FVG, close < open, and bearish body > configured ATR multiple
Short: Price overlaps a bearish order block, close < open, and bearish body > configured ATR multiple
Short: High > latest confirmed pivot high, or price overlaps a bearish inverted FVG, or a bearish SMT event occurs; chop filter passes; more than two bars since the prior early-short marking
Short: Confirmed bearish setup AND bearish confluences >= A++ minimum AND (strict session gate disabled OR within an enabled NY AM, NY PM, or London session) AND chop filter passes AND (volume filter disabled OR volume exceeds its configured multiple of its moving average) AND (discount blocking enabled OR close is not in discount) AND no bearish signal within the configured cooldown
Short: Confirmed bearish setup AND bearish confluences >= B minimum AND bearish confluences < A++ minimum AND chop filter passes AND no bearish signal within the configured cooldown