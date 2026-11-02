Calculation: Confirmed pivot high or low = a high or low that is respectively the highest or lowest among bars within an equal lookback and lookahead on the chart timeframe; recognize it only when the lookahead has completed, using TradingView pivot tie handling.
Calculation: Active structure level = the most recently confirmed pivot high or low for a given lookback; replace it when a new pivot of the same kind is confirmed and mark it unused until the first close beyond it. Maintain separate longer-lookback swing and shorter-lookback internal levels.
Calculation: Structure trend = initially neutral; set it bullish when close first exceeds an unused pivot high and bearish when close first falls below an unused pivot low. Maintain separate swing and internal trends; internal breaks count only when the internal pivot price differs from the corresponding swing pivot price.
Calculation: Daily VWAP = cumulative sum of typical price multiplied by volume divided by cumulative volume, resetting at each new day; undefined when cumulative volume is zero.
Long: A chart-timeframe swing pivot low is confirmed.
Short: A chart-timeframe swing pivot high is confirmed.
Long: Close > unused swing pivot high OR close > unused internal pivot high AND internal pivot high != swing pivot high.
Short: Close < unused swing pivot low OR close < unused internal pivot low AND internal pivot low != swing pivot low.
Long: Swing structure trend = bullish OR internal structure trend = bullish.
Short: Swing structure trend = bearish OR internal structure trend = bearish.
Long: Last completed higher-timeframe close > its EMA.
Short: Last completed higher-timeframe close <= its EMA.
Long: Low > high two bars ago AND previous close > high two bars ago AND low - high two bars ago >= an ATR multiple.
Short: High < low two bars ago AND previous close < low two bars ago AND low two bars ago - high >= an ATR multiple.
Long: MACD line > MACD signal line.
Short: MACD line <= MACD signal line.
Long: Close > any of three EMAs with short, intermediate, and long lookbacks.
Short: Close <= any of three EMAs with short, intermediate, and long lookbacks.
Long: Close > daily VWAP.
Short: Close <= daily VWAP.
Long: RSI > midpoint AND RSI < overbought threshold.
Short: RSI <= midpoint AND RSI > oversold threshold.