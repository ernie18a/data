Calculation: Instantaneous trendline T = let P be (high + low) / 2 and a be a coefficient; initialize T to 0 for the first three bars, set T = (P + 2 * previous P + P two bars ago) / 4 for the next eight bars, and thereafter set T = (a - a² / 4) * P + (a² / 2) * previous P - (a - 3 * a² / 4) * P two bars ago + 2 * (1 - a) * previous T - (1 - a)² * T two bars ago.
Calculation: Trigger = 2 * T - T two bars ago.
Long: Chart-timeframe trigger > chart-timeframe instantaneous trendline.
Short: Chart-timeframe trigger < chart-timeframe instantaneous trendline.
Long: Higher-timeframe trigger > higher-timeframe instantaneous trendline, using the higher-timeframe bar still forming.
Short: Higher-timeframe trigger < higher-timeframe instantaneous trendline, using the higher-timeframe bar still forming.