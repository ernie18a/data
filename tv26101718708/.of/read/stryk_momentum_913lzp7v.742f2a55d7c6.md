Calculation: Estimated delta = sum signed volume over lower-timeframe bars within the chart bar; sign is positive if close > open, negative if close < open, otherwise positive if close > previous lower-timeframe close, negative if close < it, and zero otherwise. If no lower-timeframe bars are available, use chart-bar volume with the sign of close − open.
Calculation: Forming higher-timeframe delta = sum estimated delta of chart bars in the higher-timeframe bar still forming.
Calculation: Profile = assign lower-timeframe volume to price bins at each lower-timeframe close; point of control is the bin with greatest volume. Value-area bounds are obtained by expanding from that bin toward the adjacent occupied bin with greater volume, choosing the upper bin on ties, until the selected fraction of profile volume is included.
Calculation: Range-distributed profile = distribute each higher-timeframe bar's volume equally across evenly spaced price bins between its low and high, subject to a maximum number of bins per bar; calculate point of control and value-area bounds as for Profile. The rolling window includes the higher-timeframe bar still forming.
Calculation: Structure = +1 after close exceeds the latest confirmed pivot high, −1 after close falls below the latest confirmed pivot low, and otherwise its previous value; initialize at zero. A pivot is confirmed only after its right-hand pivot bars have completed.
Calculation: Rolling VWAP and deviation = volume-weighted mean and standard deviation of chart-bar typical price over a rolling number of chart bars equivalent to a selected number of higher-timeframe bars, including the current chart bar.
Calculation: Divergence state = at each newly confirmed pivot high, compare that pivot's high and its RSI with those at the previous pivot high; bearish divergence holds if price is higher and RSI is lower. At each newly confirmed pivot low, bullish divergence holds if price is lower and RSI is higher. Each state persists until the next pivot of its type reevaluates it; activating either clears the other.
Long: Forming higher-timeframe delta > 0.
Short: Forming higher-timeframe delta < 0.
Long: A weighted average of forming higher-timeframe delta divided by its accumulated volume and chart-bar delta divided by its volume > 0.
Short: A weighted average of forming higher-timeframe delta divided by its accumulated volume and chart-bar delta divided by its volume < 0.
Long: Estimated delta > 0.
Short: Estimated delta < 0.
Long: Close > the latest confirmed pivot high on the chart timeframe OR close > the latest confirmed pivot high calculated on the higher timeframe using its last completed bar.
Short: Close < the latest confirmed pivot low on the chart timeframe OR close < the latest confirmed pivot low calculated on the higher timeframe using its last completed bar.
Long: Structure = +1.
Short: Structure = −1.
Long: Close > an EMA of an EMA of the selected price source.
Short: Close < an EMA of an EMA of the selected price source.
Long: Close > the high of the previous completed daily session.
Short: Close < the low of the previous completed daily session.
Long: Close > the high so far of the current or most recent selected intraday session.
Short: Close < the low so far of the current or most recent selected intraday session.
Long: Close > rolling VWAP AND the standardized distance from rolling VWAP is below the positive exhaustion threshold OR close > rolling VWAP AND estimated delta >= 0.
Short: Close < rolling VWAP AND the standardized distance from rolling VWAP is above the negative exhaustion threshold OR close < rolling VWAP AND estimated delta <= 0.
Long: Close > open.
Short: Close < open.
Long: RSI > its midpoint AND bearish divergence state is inactive OR bullish divergence state is active.
Short: RSI < its midpoint AND bullish divergence state is inactive OR bearish divergence state is active.
Long: Close > the upper value-area bound of the profile of the current session so far.
Short: Close < the lower value-area bound of the profile of the current session so far.
Long: Close > the upper value-area bound of the previous chart bar's profile OR close is inside that value area AND close > its point of control and the inside-value lean parameter > 0.
Short: Close < the lower value-area bound of the previous chart bar's profile OR close is inside that value area AND close < its point of control and the inside-value lean parameter > 0.
Long: Close > the upper value-area bound of either the last completed higher-timeframe bar's profile or a rolling range-distributed higher-timeframe profile OR close is inside that value area AND close > its point of control and the inside-value lean parameter > 0.
Short: Close < the lower value-area bound of either the last completed higher-timeframe bar's profile or a rolling range-distributed higher-timeframe profile OR close is inside that value area AND close < its point of control and the inside-value lean parameter > 0.
Long: Close > profile point of control + a selected fraction of the profile reference range, using either the previous chart bar's profile or the last completed higher-timeframe bar's profile or a rolling range-distributed higher-timeframe profile.
Short: Close < profile point of control − a selected fraction of the profile reference range, using either the previous chart bar's profile or the last completed higher-timeframe bar's profile or a rolling range-distributed higher-timeframe profile.
Long: Rolling range-distributed higher-timeframe profile point of control > the point of control of the same-length profile a selected number of higher-timeframe bars earlier.
Short: Rolling range-distributed higher-timeframe profile point of control < the point of control of the same-length profile a selected number of higher-timeframe bars earlier.
Long: Close > the upper value-area bound of an independently selected rolling range-distributed higher-timeframe profile.
Short: Close < the lower value-area bound of an independently selected rolling range-distributed higher-timeframe profile.