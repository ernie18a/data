Calculation: Accumulation/Distribution line = cumulative sum of ((2 × close − high − low) / (high − low)) × tick volume.
Calculation: Chaikin oscillator = shorter-lookback smoothed Accumulation/Distribution line minus longer-lookback smoothed Accumulation/Distribution line.
Calculation: Signal line = moving average of the Chaikin oscillator.
Calculation: Flat-adjusted oscillator and signal line = both 0.00000001 when (upper Bollinger band − middle Bollinger band) / price point is below the flat threshold; otherwise use their respective raw values.
Long: On the configured signal timeframe, the flat-adjusted oscillator is below the flat-adjusted signal line on the second-most-recent completed bar AND above it on the most-recent completed bar.
Short: On the configured signal timeframe, the flat-adjusted oscillator is above the flat-adjusted signal line on the second-most-recent completed bar AND below it on the most-recent completed bar.
Exit: short, on the configured signal timeframe, the flat-adjusted oscillator is below the flat-adjusted signal line on the second-most-recent completed bar AND above it on the most-recent completed bar.
Exit: long, on the configured signal timeframe, the flat-adjusted oscillator is above the flat-adjusted signal line on the second-most-recent completed bar AND below it on the most-recent completed bar.