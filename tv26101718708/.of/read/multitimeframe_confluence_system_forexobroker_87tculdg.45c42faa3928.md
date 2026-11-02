Calculation: For the chart timeframe and each enabled higher timeframe, calculate trend, momentum and structure using the chart bar at its close and the last completed higher-timeframe bar, respectively; on historical bars, a newly completed higher-timeframe result becomes available at the close of its final constituent chart bar.
Calculation: Bullish trend = shorter-term close EMA > longer-term close EMA AND close > trend close EMA; bearish trend = shorter-term close EMA < longer-term close EMA AND close < trend close EMA. The trend EMA has a longer lookback than the other two EMAs.
Calculation: Bullish momentum = RSI > bullish threshold AND (MACD confirmation disabled OR MACD histogram >= 0); bearish momentum = RSI <= bullish threshold AND RSI < bearish threshold AND (MACD confirmation disabled OR MACD histogram <= 0). The MACD uses a shorter and a longer EMA and an EMA signal line.
Calculation: A confirmed pivot high or low is a high or low identified with equal numbers of bars on each side; it becomes available only after the right-hand bars have completed. Bullish structure = latest confirmed pivot high > previous confirmed pivot high AND latest confirmed pivot low > previous confirmed pivot low; bearish structure = latest confirmed pivot high < previous confirmed pivot high AND latest confirmed pivot low < previous confirmed pivot low.
Calculation: Bullish or bearish confluence = count of the chart timeframe and enabled higher timeframes for which every enabled trend, momentum and structure requirement matches that direction. Disabled requirements always pass; both directions can pass on the same timeframe.
Long: Bullish trend OR bullish momentum OR bullish structure on the chart timeframe or an enabled higher timeframe.
Short: Bearish trend OR bearish momentum OR bearish structure on the chart timeframe or an enabled higher timeframe.
Long: Bullish confluence >= minimum confluence.
Short: Bearish confluence >= minimum confluence.
Long: Bullish confluence >= minimum confluence minus one AND bearish confluence < minimum confluence.
Short: Bearish confluence >= minimum confluence minus one AND bullish confluence < minimum confluence minus one.
Long: Bullish confluence >= minimum confluence AND chart bar index minus the previous bullish signal bar index >= cooldown; initialize the previous bullish signal bar index to zero and update it when this condition passes.
Short: Bearish confluence >= minimum confluence AND chart bar index minus the previous bearish signal bar index >= cooldown; initialize the previous bearish signal bar index to zero and update it when this condition passes.
Long: Chart RSI <= upper extreme threshold AND (chart RSI < lower extreme threshold OR chart RSI > bullish threshold).
Short: Chart RSI > upper extreme threshold OR (chart RSI >= lower extreme threshold AND chart RSI <= bullish threshold AND chart RSI < bearish threshold).
Long: Chart MACD histogram > 0.
Short: Chart MACD histogram < 0.