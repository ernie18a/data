Calculation: Oscillator(p) = a selectable moving average of p minus FATL(p), calculated on the selected price series p.
Long: Oscillator(selected price) > 0 AND Oscillator(selected price) > its previous value OR Oscillator(selected price) < 0 AND Oscillator(selected price) > its previous value
Short: Oscillator(selected price) > 0 AND Oscillator(selected price) < its previous value OR Oscillator(selected price) < 0 AND Oscillator(selected price) < its previous value
Long: Oscillator(close) > Oscillator(open), using chart-timeframe bars
Short: Oscillator(close) < Oscillator(open), using chart-timeframe bars
Long: Oscillator(close) >= Oscillator(open), using the still-forming higher-timeframe bar sampled on its first chart-timeframe bar and held until the next higher-timeframe bar
Short: Oscillator(close) < Oscillator(open), using the still-forming higher-timeframe bar sampled on its first chart-timeframe bar and held until the next higher-timeframe bar