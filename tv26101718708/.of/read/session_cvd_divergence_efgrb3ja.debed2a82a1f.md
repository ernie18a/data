Calculation: Bar volume delta = volume × (2 × (close − low) / (high − low) − 1); use 0 when high = low
Calculation: Session CVD = running sum of bar volume delta, reset to 0 at each session open
Calculation: CVD pivot high/low = a CVD local maximum/minimum over the configured number of bars on each side, confirmed after the bars on the right complete; use the price high/low and session at the pivot bar
Long: Successive CVD pivot lows are in the same session AND the later price low < the earlier price low AND the later CVD pivot low > the earlier CVD pivot low
Long: Successive CVD pivot lows are in the same session AND the later price low > the earlier price low AND the later CVD pivot low < the earlier CVD pivot low
Short: Successive CVD pivot highs are in the same session AND the later price high > the earlier price high AND the later CVD pivot high < the earlier CVD pivot high
Short: Successive CVD pivot highs are in the same session AND the later price high < the earlier price high AND the later CVD pivot high > the earlier CVD pivot high