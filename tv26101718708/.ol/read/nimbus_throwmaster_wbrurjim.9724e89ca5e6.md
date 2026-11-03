Calculation: Tenkan = midpoint of the highest high and lowest low over the shorter lookback
Calculation: Kijun = midpoint of the highest high and lowest low over the longer lookback
Calculation: Span A = midpoint of Tenkan and Kijun
Calculation: Span B = midpoint of the highest high and lowest low over a lookback longer than the Kijun lookback
Calculation: Current cloud top and bottom = higher and lower of Span A and Span B, respectively, from displacement minus one bars ago
Calculation: Alignment score = +1 if close is above the current cloud, -1 if below it, or 0 if inside it; plus +1 if Tenkan > Kijun or -1 otherwise; plus +1 if Span A > Span B or -1 otherwise; plus +1 if close > close from displacement minus one bars ago or -1 otherwise
Long: Tenkan crosses above Kijun OR close crosses above the current cloud top AND alignment score >= 3
Short: Tenkan crosses below Kijun OR close crosses below the current cloud bottom AND alignment score <= -3