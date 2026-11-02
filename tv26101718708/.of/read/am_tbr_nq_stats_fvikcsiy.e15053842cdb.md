Calculation: Session open = the chart-bar open at the start of the weekday session window in New York time.
Calculation: Session volatility = sample standard deviation of percentage close-to-close changes over a lookback of completed daily bars, using the last completed daily bar; daily bars are higher timeframe than the chart.
Calculation: Touch levels = session open × (1 ± a positive multiplier × session volatility / 100).
Calculation: First touch = the first bar in the session window whose high reaches the upper touch level or whose low reaches the lower touch level. Scan lower-timeframe bars within each chart bar in order, using completed bars and the bar still forming if present. If both levels are reached in the same scanned bar, select the level closer to that bar's open, selecting the upper level on a tie. If lower-timeframe data is unavailable, apply the same rule to the chart bar.
Long: Session volatility > 0 AND the first touch is of the lower touch level.
Short: Session volatility > 0 AND the first touch is of the upper touch level.
Exit: Long, after the lower-level first touch and before the session window ends, high >= session open; on the touch chart bar, scan from the touch lower-timeframe bar onward and require lower-timeframe data.
Exit: Short, after the upper-level first touch and before the session window ends, low <= session open; on the touch chart bar, scan from the touch lower-timeframe bar onward and require lower-timeframe data.
Exit: Long OR short, the session window ends.