Calculation: Bull and bear lines = apply the FATL filter to the selected bar price; smooth the result with the same smoothing method at a series of progressively longer periods. Count the smoothed series that rise versus their preceding bar as bullish; count all others, including unchanged series, as bearish. Smooth each count separately with the same smoothing method and period. For the trading system, calculate these lines on the indicator timeframe, which may be higher or lower than the chart timeframe, using its last completed bar; optionally use its still-forming bar.
Long: bull line > bear line
Short: bull line < bear line
Long: bull line > bear line AND previous bull line < previous bear line
Short: bull line < bear line AND previous bull line > previous bear line
Exit: long, bull line < bear line OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, bull line > bear line OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance