Calculation: Smoothed RSI/DeMarker composite = configured moving average of (RSI + 100 × DeMarker) / 2, using the same lookback for RSI and DeMarker; calculate on the configured indicator timeframe, which may be higher or lower than the chart timeframe.
Long: Composite at the signal bar > composite one bar earlier AND composite two bars earlier ≥ composite one bar earlier
Short: Composite at the signal bar < composite one bar earlier AND composite two bars earlier ≤ composite one bar earlier
Exit: Long, composite one bar earlier > composite at the signal bar
Exit: Short, composite one bar earlier < composite at the signal bar