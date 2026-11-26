Calculation: S = MA(MA(selected applied-price series, first smoothing method, first lookback, first phase), second smoothing method, max(1, floor(sqrt(first lookback))), second phase); calculate on chart bars, or on T1 bars and carry the still-forming T1-bar value onto chart bars
Long: S[0] > S[1]
Short: S[0] < S[1]
Long: S[n] > S[n+1] AND S[n+1] <= S[n+2], where n is the configurable signal-bar offset
Short: S[n] < S[n+1] AND S[n+1] >= S[n+2], where n is the configurable signal-bar offset