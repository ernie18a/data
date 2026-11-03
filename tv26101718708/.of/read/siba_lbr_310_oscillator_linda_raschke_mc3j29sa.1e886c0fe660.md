Calculation: Fast oscillator = SMA of close over a shorter lookback minus SMA of close over a longer lookback.
Calculation: Signal line = SMA of the fast oscillator over an independent lookback.
Calculation: Histogram = fast oscillator minus signal line.
Calculation: Oscillator pivot = a confirmed pivot high or low of the fast oscillator using independent left and right lookbacks; evaluate divergence on the confirmation bar, and use the price high or low at the oscillator pivot bar.
Calculation: Higher-timeframe signal line = the signal line calculated on higher-timeframe bars; on historical bars use the last completed higher-timeframe bar, and on a realtime bar use the higher-timeframe bar still forming.
Long: Signal line crosses above zero.
Short: Signal line crosses below zero.
Long: Signal line > 0.
Short: Signal line < 0.
Long: Histogram >= 0.
Short: Histogram < 0.
Long: Fast oscillator > its previous value.
Short: Fast oscillator <= its previous value.
Long: Fast oscillator >= 0.
Short: Fast oscillator < 0.
Long: Fast oscillator crosses above signal line AND signal line > 0 AND (first-cross restriction disabled OR no previous qualifying long first-cross signal since initialization or the latest signal-line cross above zero) AND (higher-timeframe filter disabled OR higher-timeframe signal line > 0).
Short: Fast oscillator crosses below signal line AND signal line < 0 AND (first-cross restriction disabled OR no previous qualifying short first-cross signal since initialization or the latest signal-line cross below zero) AND (higher-timeframe filter disabled OR higher-timeframe signal line < 0).
Long: Signal line > its previous value AND fast oscillator > its previous value AND the fast oscillator fell on at least the specified consecutive number of preceding bars AND (higher-timeframe filter disabled OR higher-timeframe signal line > 0).
Short: Signal line < its previous value AND fast oscillator < its previous value AND the fast oscillator rose on at least the specified consecutive number of preceding bars AND (higher-timeframe filter disabled OR higher-timeframe signal line < 0).
Long: Previous fast oscillator < negative band multiplier times the previous rolling standard deviation of the fast oscillator AND fast oscillator > its previous value.
Short: Previous fast oscillator > band multiplier times the previous rolling standard deviation of the fast oscillator AND fast oscillator < its previous value.
Long: A new oscillator pivot low is confirmed AND its oscillator value > the preceding oscillator pivot low value AND its price low < the price low at the preceding oscillator pivot low AND the number of bars between their confirmation bars minus one is within the specified inclusive range.
Short: A new oscillator pivot high is confirmed AND its oscillator value < the preceding oscillator pivot high value AND its price high > the price high at the preceding oscillator pivot high AND the number of bars between their confirmation bars minus one is within the specified inclusive range.