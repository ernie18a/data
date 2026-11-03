Calculation: Tenkan = midpoint of the highest high and lowest low over the shorter Ichimoku lookback
Calculation: Kijun = midpoint of the highest high and lowest low over a longer lookback than Tenkan
Calculation: Senkou A = average of Tenkan and Kijun
Calculation: Senkou B = midpoint of the highest high and lowest low over a lookback longer than Kijun
Calculation: Current cloud top = greater of Senkou A and Senkou B from the chart bar one displacement period less one bar ago
Calculation: Current cloud bottom = lesser of Senkou A and Senkou B from the chart bar one displacement period less one bar ago
Calculation: Strong bullish cross = Tenkan crosses above Kijun and Tenkan is above current cloud top
Calculation: Neutral bullish cross = Tenkan crosses above Kijun and Tenkan is between or equal to current cloud bottom and top
Calculation: Weak bullish cross = Tenkan crosses above Kijun and Tenkan is below current cloud bottom
Calculation: Strong bearish cross = Tenkan crosses below Kijun and Tenkan is below current cloud bottom
Calculation: Neutral bearish cross = Tenkan crosses below Kijun and Tenkan is between or equal to current cloud bottom and top
Calculation: Weak bearish cross = Tenkan crosses below Kijun and Tenkan is above current cloud top
Calculation: Higher-timeframe Tenkan and Kijun = same respective Ichimoku calculations on a higher timeframe, using the value available at the current chart bar (last completed bar historically; still-forming bar in realtime)
Long: Any bullish cross tier selected for long entry AND (higher-timeframe Tenkan > higher-timeframe Kijun if the higher-timeframe filter is enabled) AND long trading mode enabled AND position size <= 0
Short: Any bearish cross tier selected for short entry AND (higher-timeframe Tenkan <= higher-timeframe Kijun if the higher-timeframe filter is enabled) AND short trading mode enabled AND position size >= 0
Exit: Long, any bearish cross tier selected for long exit OR (ATR stop mode and low <= close - ATR × stop multiplier) OR (ATR stop mode and high >= close + ATR × target multiplier) OR (fixed-percent stop enabled and low <= entry price × (1 - stop percent)) OR (fixed-percent target enabled and high >= entry price × (1 + target percent))
Exit: Short, any bullish cross tier selected for short exit OR (ATR stop mode and high >= close + ATR × stop multiplier) OR (ATR stop mode and low <= close - ATR × target multiplier) OR (fixed-percent stop enabled and high >= entry price × (1 + stop percent)) OR (fixed-percent target enabled and low <= entry price × (1 - target percent))