Calculation: Weighted TRIX = sum of five TRIX values of the selected price, using successively longer periods and configurable weights; the second and third TRIX use the same weight.
Calculation: Signal line = Weighted TRIX / smoothing period + previous signal line * (smoothing period - 1) / smoothing period; initialize it to the first weighted TRIX / smoothing period after the TRIX warm-up.
Calculation: Indicator values = Weighted TRIX and signal line calculated on the chart timeframe for the indicator, or on a configurable higher or lower timeframe for the expert. For the expert, use the selected signal bar: the still-forming bar when its offset is zero, otherwise the selected completed bar; compare with the immediately preceding bar on that timeframe.
Long: Chart-timeframe Weighted TRIX > signal line.
Short: Chart-timeframe Weighted TRIX < signal line.
Long: Expert signal-bar Weighted TRIX > signal line AND preceding-bar Weighted TRIX < signal line.
Short: Expert signal-bar Weighted TRIX < signal line AND preceding-bar Weighted TRIX > signal line.
Exit: long, expert signal-bar Weighted TRIX < signal line.
Exit: short, expert signal-bar Weighted TRIX > signal line.
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.