Calculation: Standard relative volume = current chart-bar volume / its shorter-lookback simple average.
Calculation: Same-time-slot relative volume = current chart-bar volume / the average volume of earlier completed chart bars with the same hour and minute in the selected timezone.
Calculation: Buy volume = sum of volume from lower-timeframe bars whose close is above their open; sell volume = sum from lower-timeframe bars whose close is below their open. Use the current chart bar’s available lower-timeframe bars.
Calculation: Volume delta = buy volume − sell volume.
Calculation: Z-score = (value − its simple moving average) / its standard deviation, using the same lookback for both.
Long: close > open AND (volume meets any configured large-volume threshold under the selected SMA, relative, or z-score method OR relative volume meets any configured large-relative-volume threshold under the selected SMA, relative, or z-score method)
Short: close <= open AND (volume meets any configured large-volume threshold under the selected SMA, relative, or z-score method OR relative volume meets any configured large-relative-volume threshold under the selected SMA, relative, or z-score method)
Long: volume delta > 0 AND positive-delta relative volume meets any configured large-delta threshold under the selected SMA, relative, or z-score method
Short: volume delta < 0 AND negative-delta relative volume meets any configured large-delta threshold under the selected SMA, relative, or z-score method
Long: buy volume meets any configured large-buy-volume threshold under the selected SMA, relative, or z-score method
Short: sell volume meets any configured large-sell-volume threshold under the selected SMA, relative, or z-score method