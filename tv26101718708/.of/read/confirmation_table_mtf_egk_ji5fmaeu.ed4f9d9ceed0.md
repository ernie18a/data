Calculation: Trend timeframe = the chart timeframe or a selected higher or lower timeframe; on a higher timeframe, use the last completed bar historically and the still-forming bar in real time; on a lower timeframe, use the last available intrabar in each chart bar.
Calculation: Entry timeframe = the chart timeframe or a selected higher or lower timeframe, with the same completed-bar and intrabar rules as the trend timeframe.
Calculation: Trend bullish predicates, evaluated on the trend timeframe = shorter EMA(close) > longer EMA(close); MACD line > signal line AND MACD line > 0; ADX > threshold AND +DI > -DI; SuperTrend direction is bullish. The MACD line is the difference between the same shorter and longer EMAs, and its signal is an EMA of that difference.
Calculation: Trend bearish predicates, evaluated on the trend timeframe = shorter EMA(close) < longer EMA(close); MACD line < signal line AND MACD line < 0; ADX > threshold AND -DI > +DI; SuperTrend direction is bearish.
Calculation: Structure bias, evaluated on the entry timeframe = retain the latest confirmed pivot high and pivot low, each confirmed after equal numbers of bars on either side. Update bias to bullish when close > latest pivot high; otherwise update it to bearish when close < latest pivot low; otherwise retain the previous bias. Initial bias is neutral.
Calculation: Entry bullish predicates, evaluated on the entry timeframe = RSI > its midpoint; OBV > SMA(OBV) AND OBV > previous OBV; shorter SMA(volume) > longer SMA(volume) AND volume > longer SMA(volume); structure bias is bullish; ATR > SMA(ATR).
Calculation: Entry bearish predicates, evaluated on the entry timeframe = RSI < its midpoint; OBV < SMA(OBV) AND OBV < previous OBV; shorter SMA(volume) < longer SMA(volume) AND volume < longer SMA(volume); structure bias is bearish; ATR <= SMA(ATR). The longer volume SMA is the same one used in both volume comparisons.
Calculation: Bullish and bearish trend scores = the respective counts of true trend predicates for enabled modules. Trend count = the number of enabled trend modules.
Calculation: Bullish and bearish entry scores = the respective counts of true entry predicates for enabled modules. Entry count = the number of enabled entry modules.
Long: Shorter EMA(close) > longer EMA(close) on the trend timeframe.
Short: Shorter EMA(close) < longer EMA(close) on the trend timeframe.
Long: MACD line > signal line AND MACD line > 0 on the trend timeframe.
Short: MACD line < signal line AND MACD line < 0 on the trend timeframe.
Long: ADX > threshold AND +DI > -DI on the trend timeframe.
Short: ADX > threshold AND -DI > +DI on the trend timeframe.
Long: SuperTrend direction is bullish on the trend timeframe.
Short: SuperTrend direction is bearish on the trend timeframe.
Long: RSI > its midpoint on the entry timeframe.
Short: RSI < its midpoint on the entry timeframe.
Long: OBV > SMA(OBV) AND OBV > previous OBV on the entry timeframe.
Short: OBV < SMA(OBV) AND OBV < previous OBV on the entry timeframe.
Long: Shorter SMA(volume) > longer SMA(volume) AND volume > longer SMA(volume) on the entry timeframe.
Short: Shorter SMA(volume) < longer SMA(volume) AND volume < longer SMA(volume) on the entry timeframe.
Long: Structure bias is bullish on the entry timeframe.
Short: Structure bias is bearish on the entry timeframe.
Long: Bullish trend score > bearish trend score.
Short: Bearish trend score > bullish trend score.
Long: Bullish entry score > bearish entry score.
Short: Bearish entry score > bullish entry score.
Long: Bullish trend score = trend count.
Short: Bullish trend score != trend count AND bearish trend score = trend count.
Long: Bullish entry score = entry count.
Short: Bullish entry score != entry count AND bearish entry score = entry count.