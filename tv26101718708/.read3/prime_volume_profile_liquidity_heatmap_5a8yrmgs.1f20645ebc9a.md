Calculation: Heatmap bin midpoint(i) = current T1 low + (current T1 high - current T1 low) * (i + 0.5) / heatmap resolution, for each integer i from 0 through heatmap resolution - 1, using chart bars and the still-forming T1 period's running high and low
Long: close > Heatmap bin midpoint(i)
Short: close <= Heatmap bin midpoint(i)