Calculation: TVI = Blau TVI(close, selected volume field, smoothing method, first smoothing lookback, second smoothing lookback, third smoothing lookback, phase)
Calculation: HTF TVI = Blau TVI(close, selected volume field, smoothing method, first smoothing lookback, second smoothing lookback, third smoothing lookback, phase, calculated on T1 bars including the still-forming bar and mapped to chart bars by timestamp)
Long: TVI > 0 AND TVI != TVI[1]
Short: TVI < 0 AND TVI != TVI[1]
Long: HTF TVI > 0 AND HTF TVI != its value on the previous T1 bar
Short: HTF TVI < 0 AND HTF TVI != its value on the previous T1 bar