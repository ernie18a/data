Calculation: RSI divergence = absolute difference between current RSI and RSI from a longer lookback, divided by the longer-lookback RSI.
Calculation: Volume spike = current volume > average volume over a lookback × a volume-spike factor.
Calculation: Fast moving average = simple moving average of close over a shorter lookback.
Calculation: Slow moving average = simple moving average of close over a longer lookback.
Long: RSI < oversold threshold AND RSI divergence > divergence threshold AND volume spike AND close < fast moving average AND close < slow moving average
Short: RSI > overbought threshold AND RSI divergence > divergence threshold AND volume spike AND close > fast moving average AND close > slow moving average
Short: EMA(shortest) > EMA(next longer) > EMA(next longer) > EMA(next longer) AND EMA(fourth longest) >= EMA(second longest) >= EMA(longest) AND higher-timeframe MACD < higher-timeframe MACD signal line AND chart-timeframe MACD crosses below its signal line (current MACD < signal line AND previous MACD >= previous signal line); use the higher timeframe's current bar (forming in real time, confirmed in historical data)
Exit: short, close < EMA(longest) AND chart-timeframe MACD crosses above its signal line (current MACD > signal line AND previous MACD <= previous signal line)