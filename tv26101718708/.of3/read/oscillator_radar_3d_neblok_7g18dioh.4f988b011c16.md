Calculation: Osc values = for each enabled oscillator, EMA(clamp(raw, 0, 100), smoothing length), with raw set to midpoint when undefined or when a denominator is zero; raw is RSI(source, length), SMA(Stochastic %K(source, high, low, length), stoch smoothing length), MFI(typical price, length), DMI balance(length), (Aroon Oscillator(length) + 100) / 2, (Correlation(source, bar index, length) + 1) / 2 * 100, Bollinger %B(source, length, band multiplier) * 100, or Up bars(source, length)
Calculation: DMI balance(length) = 100 * DI+(length) / (DI+(length) + DI-(length))
Calculation: Up bars(source, length) = 100 * (number of the last length bars where source > source[1]) / length
Calculation: Mean oscillator = average of Osc values
Calculation: Bull zone count = number of Osc values >= bull zone level
Calculation: Bear zone count = number of Osc values <= bear zone level
Long: Mean oscillator >= bull bias level
Long: Mean oscillator > mid level
Long: Bull zone count >= confluence count AND Bull zone count[1] < confluence count
Short: Mean oscillator <= bear bias level
Short: Mean oscillator < mid level
Short: Bear zone count >= confluence count AND Bear zone count[1] < confluence count