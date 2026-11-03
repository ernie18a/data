Calculation: Smoothed KWAN = apply the configured smoother to 100 × DeMarker × MFI / Momentum, using 100 when Momentum is zero; calculate on the configured indicator timeframe (which may be higher or lower than the chart timeframe) using completed bars.
Long: Smoothed KWAN[t] > Smoothed KWAN[t-1] AND Smoothed KWAN[t-1] <= Smoothed KWAN[t-2]
Short: Smoothed KWAN[t] < Smoothed KWAN[t-1] AND Smoothed KWAN[t-1] >= Smoothed KWAN[t-2]
Exit: long, Smoothed KWAN[t] < Smoothed KWAN[t-1] AND Smoothed KWAN[t-1] >= Smoothed KWAN[t-2]
Exit: short, Smoothed KWAN[t] > Smoothed KWAN[t-1] AND Smoothed KWAN[t-1] <= Smoothed KWAN[t-2]