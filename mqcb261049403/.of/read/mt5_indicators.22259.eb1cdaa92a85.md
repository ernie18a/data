Calculation: SATL-filtered price = sum of the current and preceding 98 chart-bar prices, weighted by the fixed 99-tap SATL filter coefficients.
Calculation: Signal candle close = JMA-smoothed SATL-filtered close, using a shared JMA length and phase for all candle fields.
Calculation: Signal candle open = JMA-smoothed SATL-filtered open, except use the previous signal candle close when absolute chart-bar open minus close is at most the gap threshold.
Long: Signal candle open < signal candle close
Short: Signal candle open > signal candle close