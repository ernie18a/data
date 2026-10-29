Calculation: Blau TVI = smooth(100 × (U₂ − D₂) / (U₂ + D₂), final lookback), where U₁ and D₁ are the selected moving average of up-ticks and down-ticks, U₂ and D₂ are the selected moving average of U₁ and D₁ using a separate second-stage lookback, and up-ticks = (volume + (close − open) / instrument point size) / 2, down-ticks = volume − up-ticks. Use the selected volume series and smoothing method. Evaluate on the selected indicator timeframe, using completed bars.
Long: Blau TVI[t−2] > Blau TVI[t−1] AND Blau TVI[t] > Blau TVI[t−1]
Short: Blau TVI[t−2] < Blau TVI[t−1] AND Blau TVI[t] < Blau TVI[t−1]
Exit: long, Blau TVI[t−2] < Blau TVI[t−1] AND Blau TVI[t] < Blau TVI[t−1]
Exit: short, Blau TVI[t−2] > Blau TVI[t−1] AND Blau TVI[t] > Blau TVI[t−1]