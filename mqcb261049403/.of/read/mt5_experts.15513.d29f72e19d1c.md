Calculation: Twice-smoothed OHLC = apply a first smoothing, then a second smoothing, to each OHLC price series. Use the selected signal bar and the preceding bar on the indicator timeframe; when that timeframe differs from the chart timeframe, use aggregated bars.
Long: signal-bar twice-smoothed close > signal-bar twice-smoothed open AND preceding bar twice-smoothed close <= preceding bar twice-smoothed open
Short: signal-bar twice-smoothed close < signal-bar twice-smoothed open AND preceding bar twice-smoothed close >= preceding bar twice-smoothed open
Exit: short, signal-bar twice-smoothed close > signal-bar twice-smoothed open
Exit: long, signal-bar twice-smoothed close < signal-bar twice-smoothed open