Calculation: Estimated buy volume = max(0, volume × (close − low) / (high − low)) when high > low; otherwise max(0, volume / 2).
Calculation: Estimated sell volume = max(0, volume × (high − close) / (high − low)) when high > low; otherwise max(0, volume / 2).
Calculation: Total buy and sell volumes = sums of their respective estimated volumes over the current chart bar and a configurable number of preceding chart bars.
Long: Total buy volume >= total sell volume.
Long: Total buy volume > total sell volume AND volume has been greater than its simple moving average for at least a configurable number of consecutive chart bars, including the current bar.
Short: Total sell volume > total buy volume.