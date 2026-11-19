Calculation: Zero-lag MACD = ZLEMA(close, shorter lookback) - ZLEMA(close, longer lookback)
Calculation: Zero-lag signal = ZLEMA(Zero-lag MACD, signal lookback)
Calculation: Regular bullish divergence = on a confirmed pivot low of Zero-lag MACD, the current MACD pivot is higher and its corresponding price low is lower than at the preceding confirmed pivot low, with pivot bars no farther apart than the maximum pivot gap; each pivot uses the pivot lookback on both sides
Calculation: Regular bearish divergence = on a confirmed pivot high of Zero-lag MACD, the current MACD pivot is lower and its corresponding price high is higher than at the preceding confirmed pivot high, with pivot bars no farther apart than the maximum pivot gap; each pivot uses the pivot lookback on both sides
Long: Zero-lag MACD crosses above Zero-lag signal
Short: Zero-lag MACD crosses below Zero-lag signal
Long: Zero-lag MACD > Zero-lag signal
Short: Zero-lag MACD <= Zero-lag signal
Long: Zero-lag MACD >= Zero-lag signal
Short: Zero-lag MACD < Zero-lag signal
Long: Zero-lag MACD > 0
Short: Zero-lag MACD <= 0
Long: Regular bullish divergence is confirmed when divergence detection is enabled
Short: Regular bearish divergence is confirmed when divergence detection is enabled
Long: A bullish divergence was confirmed within the divergence-validity lookback
Short: A bearish divergence was confirmed within the divergence-validity lookback
Long: On a confirmed bar, Zero-lag MACD crosses above Zero-lag signal AND (combo mode is disabled OR a bullish divergence was confirmed within the divergence-validity lookback) AND at least the cooldown lookback bars have elapsed since the preceding buy or sell signal AND the current-day signal count is below its maximum
Short: On a confirmed bar, Zero-lag MACD crosses below Zero-lag signal AND (combo mode is disabled OR a bearish divergence was confirmed within the divergence-validity lookback) AND at least the cooldown lookback bars have elapsed since the preceding buy or sell signal AND the current-day signal count is below its maximum