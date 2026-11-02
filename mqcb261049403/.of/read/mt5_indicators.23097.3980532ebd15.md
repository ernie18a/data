Calculation: One-sided Gaussian average of a price series = weighted average of the current and preceding N-1 values, with weight exp(-9*i²/(N+1)²) at lag i, normalized by the sum of the weights.
Calculation: Range oscillator = 200*(one-sided Gaussian average of (high+low+2*close)/4 minus the minimum one-sided Gaussian average of low over the current and preceding lookback bars)/(the maximum one-sided Gaussian average of high over those bars minus that minimum) - 100; use 0 when the denominator is 0. Use the same Gaussian length for all three averages.
Calculation: Higher-timeframe oscillator = range oscillator calculated on higher-timeframe bars, sampled from the bar still forming at the first chart bar of each higher-timeframe bar and held until the next higher-timeframe bar.
Long: Chart-timeframe range oscillator > 0.
Short: Chart-timeframe range oscillator < 0.
Long: Higher-timeframe oscillator > 0.
Short: Higher-timeframe oscillator < 0.