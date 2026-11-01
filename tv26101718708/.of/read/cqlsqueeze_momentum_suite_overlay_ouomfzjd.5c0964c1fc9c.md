Calculation: Squeeze momentum = linear-regression endpoint over the momentum lookback of source minus the average of (the average of the lookback highest high and lowest low) and the selected moving average of source over the same lookback.
Calculation: Trend locator = (source - selected moving average of source) / (0.015 × mean absolute deviation over the same lookback of either source or abs(source - its moving average)).
Calculation: Hull average = selected Hull variant of source: HMA, EMA-based Hull, triple-weighted Hull, or adaptive Hull. The EMA-based Hull is EMA(2 × EMA(source, length/2) - EMA(source, length), round(sqrt(length))). The triple-weighted Hull is WMA(3 × WMA(source, length/3) - WMA(source, length/2) - WMA(source, length), length), evaluated with half the selected Hull length. The adaptive Hull is WMA(2 × WMA(source, length/2) - WMA(source, length), floor(sqrt(length))).
Calculation: Divergence pivots = confirmed pivot lows or highs of squeeze momentum, using specified left and right pivot lookbacks. Evaluate divergence on the confirmation bar. Compare the current pivot with either the immediately preceding pivot or the pivot two occurrences back; their separation must be within the specified minimum and maximum. For a two-occurrence comparison, the intervening oscillator low must be strictly above, or the intervening oscillator high strictly below, the straight line connecting the compared oscillator pivots. At each pivot confirmation, the corresponding price low or high is the lowest or highest close over the right pivot lookback plus two bars ending on that confirmation bar.
Long: Squeeze momentum >= 0.
Short: Squeeze momentum < 0.
Long: Squeeze momentum > its simple moving average.
Short: Squeeze momentum <= its simple moving average.
Long: Squeeze momentum >= its simple moving average.
Short: Squeeze momentum < its simple moving average.
Long: +DI >= -DI.
Short: +DI < -DI.
Long: +DI >= -DI AND ADX >= trend threshold AND the same combined condition was false on the previous bar.
Short: +DI < -DI AND ADX >= trend threshold AND the same combined condition was false on the previous bar.
Long: Trend locator > positive threshold.
Short: Trend locator < negative threshold of equal magnitude.
Long: Hull average crosses above its value two bars earlier.
Short: Hull average crosses below its value two bars earlier.
Long: Hull average > its value two bars earlier.
Short: Hull average <= its value two bars earlier.
Long: A divergence pivot low is confirmed AND current squeeze momentum < 0 AND ((current pivot oscillator > compared pivot oscillator AND current corresponding price low < compared price low) OR (current pivot oscillator < compared pivot oscillator AND current corresponding price low > compared price low)).
Short: A divergence pivot high is confirmed AND current squeeze momentum > 0 AND ((current pivot oscillator < compared pivot oscillator AND current corresponding price high > compared price high) OR (current pivot oscillator > compared pivot oscillator AND current corresponding price high < compared price high)).