Calculation: Average volume = mean volume over the preceding completed bars
Calculation: Highest prior spread-weighted volume = maximum of volume × (high − low) over the preceding completed bars, using the same lookback as average volume
Long: close > open AND (volume >= average volume × lower vector-volume threshold OR volume × (high − low) >= highest prior spread-weighted volume)
Short: close <= open AND (volume >= average volume × lower vector-volume threshold OR volume × (high − low) >= highest prior spread-weighted volume)