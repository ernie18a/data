Calculation: Fast RSI = RSI(close, RSI lookback) on T1 bars, using the selected signal bar, which may be forming or last completed
Calculation: Slow RSI = MovingAverage(Fast RSI, smoothing lookback, MA method) on T1 bars, using the selected signal bar, which may be forming or last completed
Calculation: Long trailing stop = highest high since entry minus trailing distance, updated in trailing-step increments after price advances beyond the trailing distance plus trailing step
Calculation: Short trailing stop = lowest low since entry plus trailing distance, updated in trailing-step increments after price falls beyond the trailing distance plus trailing step
Long: Fast RSI crosses above Slow RSI AND both are below 50
Short: Fast RSI crosses below Slow RSI AND both are above 50
Exit: long, stop loss enabled AND low <= entry price - stop-loss distance OR take profit enabled AND high >= entry price + take-profit distance OR trailing stop enabled AND high > entry price + trailing distance + trailing step AND low <= Long trailing stop
Exit: short, stop loss enabled AND high >= entry price + stop-loss distance OR take profit enabled AND low <= entry price - take-profit distance OR trailing stop enabled AND low < entry price - trailing distance - trailing step AND high >= Short trailing stop