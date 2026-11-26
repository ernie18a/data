Calculation: Opening-range high/low = highest high/lowest low on chart bars during the configured New York opening-range session, reset each day; ready after the session ends
Calculation: Prior T1 high/low = high/low of the last completed T1 bar, sampled on chart bars
Calculation: Session VWAP standard deviation = sqrt(max(volume-weighted mean of hlc3 squared minus VWAP(hlc3)^2, 0)), accumulated on chart bars and reset each day
Calculation: Flow score = relative-volume points + range/ATR points + body/range points + VWAP-deviation points; relative volume = volume/SMA(volume, volume lookback), range/ATR = (high-low)/ATR(ATR lookback), body/range = abs(close-open)/(high-low), and VWAP deviation = abs(close-VWAP(hlc3))/session VWAP standard deviation; zero when a denominator is zero; relative volume awards high/middle/low tier points at its separately parameterized thresholds, and each other component awards high/low tier points at its separately parameterized thresholds
Calculation: Bullish sweep = opening range ready AND ((high > prior T1 high AND close < prior T1 high) OR (low < prior T1 low AND close > prior T1 low) OR (high > opening-range high AND close < opening-range high) OR (low < opening-range low AND close > opening-range low))
Calculation: Bearish sweep = opening range ready AND ((high > prior T1 high AND close < prior T1 high) OR (low < prior T1 low AND close > prior T1 low) OR (high > opening-range high AND close < opening-range high) OR (low < opening-range low AND close > opening-range low))
Calculation: Bullish structure break = close crosses above the latest confirmed pivot high, using the pivot-strength parameter on both sides
Calculation: Bearish structure break = close crosses below the latest confirmed pivot low, using the pivot-strength parameter on both sides
Calculation: Bullish trendline break = close crosses above the line through the latest two confirmed pivot highs
Calculation: Bearish trendline break = close crosses below the line through the latest two confirmed pivot lows
Calculation: Bullish FVG = low > high[2] AND low - high[2] >= ATR(ATR lookback) * minimum FVG-size multiplier
Calculation: Bearish FVG = high < low[2] AND low[2] - high >= ATR(ATR lookback) * minimum FVG-size multiplier
Calculation: Bearish IFVG event = close below the lower boundary of a retained bullish FVG
Calculation: Bullish IFVG event = close above the upper boundary of a retained bearish FVG
Calculation: Bullish order-block trigger = bullish structure break AND close > open AND high - low >= ATR(ATR lookback) * minimum displacement multiplier
Calculation: Bearish order-block trigger = bearish structure break AND close < open AND high - low >= ATR(ATR lookback) * minimum displacement multiplier
Calculation: Bullish opening-range retest = on a later chart bar within confirmation memory after a bullish close crossing above opening-range high, low <= opening-range high + minimum price increment * retest-tick parameter AND close > opening-range high
Calculation: Bearish opening-range retest = on a later chart bar within confirmation memory after a bearish close crossing below opening-range low, high >= opening-range low - minimum price increment * retest-tick parameter AND close < opening-range low
Calculation: Bullish confirmation count = count of true conditions: bullish sweep within sweep memory; bullish trendline break within confirmation memory; bullish structure break within structure memory; close > session VWAP; close > open AND flow score >= strong-flow threshold; bullish FVG or bullish IFVG event or bullish order-block trigger within confirmation memory; bullish opening-range retest within confirmation memory or opening range ready AND close > opening-range high
Calculation: Bearish confirmation count = count of true conditions: bearish sweep within sweep memory; bearish trendline break within confirmation memory; bearish structure break within structure memory; close < session VWAP; close < open AND flow score >= strong-flow threshold; bearish FVG or bearish IFVG event or bearish order-block trigger within confirmation memory; bearish opening-range retest within confirmation memory or opening range ready AND close < opening-range low
Long: bullish sweep
Short: bearish sweep
Long: bullish sweep occurred within sweep memory
Short: bearish sweep occurred within sweep memory
Long: bullish structure break
Short: bearish structure break
Long: bullish structure break occurred within structure memory
Short: bearish structure break occurred within structure memory
Long: bullish trendline break
Short: bearish trendline break
Long: bullish trendline break occurred within confirmation memory
Short: bearish trendline break occurred within confirmation memory
Long: bullish FVG
Short: bearish FVG
Long: close above the lower boundary of a retained bearish FVG
Short: close below the lower boundary of a retained bullish FVG
Long: bullish order-block trigger AND a bearish candle occurs within the opposite-candle search lookback
Short: bearish order-block trigger AND a bullish candle occurs within the opposite-candle search lookback
Long: close > open AND flow score >= bubble flow-score threshold AND no bullish flow bubble occurred within the bubble cooldown
Short: close < open AND flow score >= bubble flow-score threshold AND no bearish flow bubble occurred within the bubble cooldown
Long: close > open AND flow score >= strong-flow threshold
Short: close < open AND flow score >= strong-flow threshold
Long: close > session VWAP
Short: close < session VWAP
Long: bullish FVG or bullish IFVG event or bullish order-block trigger occurred within confirmation memory
Short: bearish FVG or bearish IFVG event or bearish order-block trigger occurred within confirmation memory
Long: opening range ready AND close > opening-range high OR bullish opening-range retest occurred within confirmation memory
Short: opening range ready AND close < opening-range low OR bearish opening-range retest occurred within confirmation memory
Long: bullish confirmation count >= minimum confirmations AND bullish confirmation count > bearish confirmation count
Short: bearish confirmation count >= minimum confirmations AND bearish confirmation count > bullish confirmation count