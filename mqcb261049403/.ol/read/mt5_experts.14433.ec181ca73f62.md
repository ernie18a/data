Calculation: Gap = second-stage smoothing of (high − first-stage smoothing of open) on the signal bar minus second-stage smoothing of (high − first-stage smoothing of close) on the immediately preceding bar; both stages use the indicator timeframe, which may be higher or lower than the chart timeframe, and the first-stage lookback is longer than the second-stage lookback. Evaluate on completed bars.
Long: Gap > 0 AND previous Gap <= 0
Short: Gap < 0 AND previous Gap >= 0
Exit: long, Gap < 0
Exit: short, Gap > 0