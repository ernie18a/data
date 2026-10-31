Calculation: Oscillator = apply the same selected moving-average method, length and other smoothing parameters to high, low and close separately; compute 100 × (smoothed close − smoothed low) / max(smoothed high − smoothed low, minimum price increment); smooth that result again using the same method and parameters, then subtract 50.
Long: Level mode AND (oscillator > upper level OR (oscillator <= upper level AND oscillator > middle level))
Short: Level mode AND oscillator <= upper level AND oscillator <= middle level AND (oscillator < lower level OR oscillator < middle level)
Long: Direction mode AND oscillator != middle level AND oscillator > previous oscillator
Short: Direction mode AND oscillator != middle level AND oscillator < previous oscillator