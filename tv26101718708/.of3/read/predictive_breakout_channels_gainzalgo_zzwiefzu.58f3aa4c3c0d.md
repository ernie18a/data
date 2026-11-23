Calculation: Anchored linear-regression channel = From the latest confirmed pivot high or low of high or low, using separate left and right pivot lookbacks (pivot high takes precedence if both confirm together), fit a linear regression to the pivot price and subsequent closes by bar offset from the pivot; channel slope and current regression value are from that fit, and the upper and lower channels are the current regression value plus or minus the channel-width multiplier times the standard deviation of residuals over the anchored observation count, with a minimum sample-count floor.
Calculation: ANOVA F-statistic = [n × sum((SMA(group, n) − mean of the three group SMAs)²) / 2] / [sum((n − 1) × VARIANCE(group, n)) / (3n − 6)], for groups close[1], low[1], and high[1], where n is the ANOVA lookback.
Calculation: ANOVA z-score = (ANOVA F-statistic − SMA(ANOVA F-statistic, ANOVA lookback)) / STDEV(ANOVA F-statistic, ANOVA lookback).
Calculation: RSI = RSI(close, RSI lookback).
Calculation: Trend correlation = Pearson correlation(close, chart bar index, trend-correlation lookback).
Calculation: Volume average = SMA(volume, volume lookback).
Calculation: Short HTF EMA = EMA(close, shorter lookback, T1, current bar still forming, sampled on chart bars).
Calculation: Intermediate HTF EMA = EMA(close, intermediate lookback, T1, current bar still forming, sampled on chart bars).
Calculation: Long HTF EMA = EMA(close, longer lookback, T1, current bar still forming, sampled on chart bars).
Long: Channel slope > channel-slope threshold.
Short: Channel slope <= channel-slope threshold.
Long: RSI > RSI threshold.
Short: RSI <= RSI threshold.
Long: Trend correlation > trend-correlation threshold.
Short: Trend correlation <= trend-correlation threshold.
Long: Higher-timeframe filter enabled AND Short HTF EMA > Intermediate HTF EMA > Long HTF EMA.
Short: Higher-timeframe filter enabled AND Short HTF EMA < Intermediate HTF EMA < Long HTF EMA.
Long: Latest confirmed pivot is a pivot low using the pivot left and right lookbacks.
Short: Latest confirmed pivot is a pivot high using the pivot left and right lookbacks.
Long: Close crosses above the upper anchored linear-regression channel.
Short: Close crosses below the lower anchored linear-regression channel.
Long: (Close crosses above the upper anchored linear-regression channel OR close crosses below the lower anchored linear-regression channel) AND RSI > RSI threshold AND Trend correlation > trend-correlation threshold AND Volume > Volume average AND (higher-timeframe filter disabled OR Short HTF EMA > Intermediate HTF EMA > Long HTF EMA).
Short: (Close crosses above the upper anchored linear-regression channel OR close crosses below the lower anchored linear-regression channel) AND RSI <= RSI threshold AND Trend correlation <= trend-correlation threshold AND Volume > Volume average AND (higher-timeframe filter disabled OR Short HTF EMA < Intermediate HTF EMA < Long HTF EMA).
Long: Close crosses above the upper anchored linear-regression channel AND abs(ANOVA z-score) >= ANOVA z-score threshold AND RSI > RSI threshold AND Trend correlation > trend-correlation threshold AND Volume > Volume average AND (higher-timeframe filter disabled OR Short HTF EMA > Intermediate HTF EMA > Long HTF EMA).
Short: Close crosses below the lower anchored linear-regression channel AND abs(ANOVA z-score) >= ANOVA z-score threshold AND RSI <= RSI threshold AND Trend correlation <= trend-correlation threshold AND Volume > Volume average AND (higher-timeframe filter disabled OR Short HTF EMA < Intermediate HTF EMA < Long HTF EMA).