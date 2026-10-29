Calculation: RVIDiff = smoothed difference between the Relative Vigor Index main line and signal line, calculated on the indicator timeframe (same as the chart timeframe in the documented setup); use completed bars.
Long: RVIDiff[2] >= RVIDiff[1] AND RVIDiff[1] < RVIDiff[0]
Short: RVIDiff[2] <= RVIDiff[1] AND RVIDiff[1] > RVIDiff[0]
Exit: short, RVIDiff[1] < RVIDiff[0]
Exit: long, RVIDiff[1] > RVIDiff[0]