Calculation: Oscillator = smooth the selected bar price with a longer-period moving average; subtract that average from the price, then smooth the difference twice in sequence with shorter-period moving averages, the first longer than the second. Use the same smoothing method throughout.
Calculation: Signal = smooth the oscillator with the same method over a period longer than the oscillator's second smoothing period.
Calculation: Higher-timeframe oscillator and signal = calculate the oscillator and signal on higher-timeframe bars, using the higher-timeframe bar still forming at the first chart bar of each higher-timeframe interval; hold those values until the next higher-timeframe interval.
Long: Oscillator > 0
Short: Oscillator < 0
Long: Oscillator > signal
Short: Oscillator < signal
Long: Higher-timeframe oscillator > 0
Short: Higher-timeframe oscillator < 0
Long: Higher-timeframe oscillator > higher-timeframe signal
Short: Higher-timeframe oscillator < higher-timeframe signal