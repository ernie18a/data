Calculation: Normalized price movement = signed price movement divided by its lookback simple moving average of absolute price movement; signed movement is close minus open or the high-low range signed by close versus open.
Calculation: Normalized volume pressure = volume multiplied by (close − open) divided by the maximum of high − low and minimum tick size, then divided by its lookback simple moving average of absolute pressure.
Calculation: Price-volume imbalance = −(normalized price movement − normalized volume pressure) × absolute normalized price movement.
Calculation: Main oscillator = adaptive logistic smoothing of a moving average of price-volume imbalance.
Calculation: Signal line = adaptive logistic smoothing of a moving average of the main oscillator, using a shorter lookback than the main oscillator’s moving average.
Calculation: Stored pressure = adaptive logistic smoothing of the recursively accumulated main oscillator, where the prior accumulated value is weighted by (lookback − 1) / lookback.
Calculation: Correction pressure = tanh of stored pressure divided by its lookback simple moving average of absolute stored pressure, then smoothed by an exponential moving average.
Long: Main oscillator > its previous value OR signal line > its previous value OR correction pressure ≥ 0
Short: Main oscillator < its previous value OR signal line < its previous value OR correction pressure < 0