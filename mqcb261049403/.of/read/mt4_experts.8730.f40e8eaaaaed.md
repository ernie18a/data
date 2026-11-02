Calculation: Timeframe alignment = Each fixed-timeframe calculation uses its specified timeframe relative to the chart: higher, lower, or equal depending on the chart timeframe. Shift 0 uses the forming bar; shift 1 uses the last completed bar; larger shifts use earlier completed bars.
Calculation: Step oscillator = On chart bars, process a fixed history from oldest to newest. At each bar calculate the weighted mean of high minus low over a lookback, with weight 1 + (lookback − offset)/lookback for offset 0 at the current bar. Track the running maximum and minimum of this mean; initialize the minimum at the bar one lookback after the start. For each of the minimum, maximum, and their midpoint, round a scaled value to the nearest price increment to obtain a step. Set upper = close + 2 × step and lower = close − 2 × step. Set trend to positive if close exceeds the previous upper, negative if close is below the previous lower, and otherwise retain it. In a positive trend, replace lower with the maximum of current and previous lower; in a negative trend, replace upper with the minimum of current and previous upper. The line is lower + step for a positive trend and upper − step for a negative trend. Round (minimum-step line − maximum-step line + maximum step)/(2 × maximum step) and (midpoint-step line − maximum-step line + maximum step)/(2 × maximum step) separately to a fixed precision; their difference is the oscillator.
Calculation: AO bounds = At initialization, take the minimum and maximum Awesome Oscillator values over the available fixed-timeframe history, including zero in each extreme, and multiply each extreme by a positive scale factor.
Long: On the last completed fixed-timeframe bar, stochastic main > signal AND on the preceding bar main <= signal AND main < a lower threshold.
Short: On the last completed fixed-timeframe bar, stochastic main < signal AND on the preceding bar main >= signal AND main > an upper threshold.
Long: On the last completed fixed-timeframe bar, four median-price SMAs with strictly increasing lookbacks satisfy shortest > second > third AND third − longest >= a positive threshold AND third on the preceding bar <= longest on the last completed bar.
Short: On the last completed fixed-timeframe bar, four median-price SMAs with strictly increasing lookbacks satisfy shortest < second < third AND longest − third >= a positive threshold AND third on the preceding bar >= longest on the last completed bar.
Long: On the last completed fixed-timeframe bar, close-price LWMA > equal-lookback EMA AND LWMA > its preceding value AND EMA > its preceding value.
Short: On the last completed fixed-timeframe bar, close-price LWMA < equal-lookback EMA AND LWMA < its preceding value AND EMA < its preceding value.
Long: On forming bars of three increasing fixed timeframes, stochastic main > signal for the same parameters on each AND on the longest timeframe stochastic main > signal for a longer lookback AND on the last completed longest-timeframe bar close-price LWMA > equal-lookback EMA AND both averages > their preceding values.
Short: On forming bars of three increasing fixed timeframes, stochastic main < signal for the same parameters on each AND on the longest timeframe stochastic main < signal for a longer lookback AND on the last completed longest-timeframe bar close-price LWMA < equal-lookback EMA AND both averages < their preceding values.
Long: On the forming fixed-timeframe bar, shorter close-price SMA − longer close-price SMA > a positive threshold.
Short: On the forming fixed-timeframe bar, shorter close-price SMA − longer close-price SMA < the negative of that threshold.
Long: Current chart-bar low − forming fixed-timeframe median-price SMMA < a negative threshold.
Short: Current chart-bar low − forming fixed-timeframe median-price SMMA > the corresponding positive threshold.
Long: Current chart-bar step oscillator > a positive threshold.
Short: Current chart-bar step oscillator < the negative of that threshold.
Long: On the last completed chart bar, shorter close-price SMA > longer close-price SMA AND on the preceding bar shorter SMA < longer SMA AND current close-price EMA > its preceding value; the EMA has the same lookback as the shorter SMA.
Short: On the last completed chart bar, shorter close-price SMA < longer close-price SMA AND on the preceding bar shorter SMA > longer SMA AND current close-price EMA < its preceding value; the EMA has the same lookback as the shorter SMA.
Long: Forming fixed-timeframe typical-price CCI < a negative threshold.
Short: Forming fixed-timeframe typical-price CCI > the corresponding positive threshold.
Long: Forming fixed-timeframe Awesome Oscillator < its initialized lower bound.
Short: Forming fixed-timeframe Awesome Oscillator > its initialized upper bound.
Long: Current chart-bar MACD main line > its preceding value.
Short: Current chart-bar MACD main line < its preceding value.
Exit: long, price >= entry price + take-profit distance OR price <= entry price − stop-loss distance.
Exit: short, price <= entry price − take-profit distance OR price >= entry price + stop-loss distance.