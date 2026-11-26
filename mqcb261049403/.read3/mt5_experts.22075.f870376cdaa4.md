Calculation: D = smooth((100 × DeMarker(DeMarker lookback) − 50) × selected volume (tick volume or volume), selected smoothing method, smoothing length, smoothing phase), calculated on T1 bars; chart bars read D[1] from the last completed T1 bar and D[0] from the T1 bar still forming
Calculation: V = smooth(selected volume (tick volume or volume), selected smoothing method, smoothing length, smoothing phase), calculated on T1 bars; chart bars read V[1] from the last completed T1 bar and V[0] from the T1 bar still forming
Long: D[1] > upper level 1 × V[1] AND D[1] <= upper level 2 × V[1] AND D[0] <= upper level 1 × V[0]
Long: D[1] > upper level 2 × V[1] AND D[0] <= upper level 2 × V[0]
Short: D[1] < lower level 1 × V[1] AND D[1] >= lower level 2 × V[1] AND D[0] >= lower level 1 × V[0]
Short: D[1] < lower level 2 × V[1] AND D[0] >= lower level 2 × V[0]