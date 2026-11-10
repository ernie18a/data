Calculation: Positive directional movement = current high minus previous high if that difference is positive and greater than previous low minus current low; otherwise zero.
Calculation: Negative directional movement = previous low minus current low if that difference is positive and greater than current high minus previous high; otherwise zero.
Calculation: Smoothed directional movement = Wilder smoothing of the corresponding directional movement, initialized to zero and calculated starting at the third bar. Calculate on the chart timeframe or on the still-forming bar of a higher timeframe.
Long: Smoothed positive directional movement > smoothed negative directional movement.
Short: Smoothed negative directional movement > smoothed positive directional movement.