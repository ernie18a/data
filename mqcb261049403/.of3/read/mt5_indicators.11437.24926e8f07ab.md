Calculation: Smoothed up volume = MA(MA((volume + (close - open) / minimum price increment) / 2, first lookback, smoothing method, phase), second lookback, smoothing method, phase)
Calculation: Smoothed down volume = MA(MA(volume - (volume + (close - open) / minimum price increment) / 2, first lookback, smoothing method, phase), second lookback, smoothing method, phase)
Calculation: Blau TVI = MA(100 × (Smoothed up volume - Smoothed down volume) / (Smoothed up volume + Smoothed down volume), third lookback, smoothing method, phase)
Long: Blau TVI > 0 AND Blau TVI != Blau TVI[1]
Short: Blau TVI < 0 AND Blau TVI != Blau TVI[1]