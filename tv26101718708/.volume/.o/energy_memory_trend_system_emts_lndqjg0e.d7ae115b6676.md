Calculation: Directional Memory Engine (DME) = EMA-smoothed value of sqrt(ATR) × ln(volume + 1) × rate of change of close
Calculation: Trend state = initialize neutral; on each bar, set bullish if DME is above its upper Bollinger band and prior state is not bullish; otherwise set bearish if DME is below its lower Bollinger band and prior state is not bearish; otherwise retain prior state
Long: DME > upper Bollinger band of DME AND prior trend state is not bullish
Short: DME < lower Bollinger band of DME AND prior trend state is not bearish