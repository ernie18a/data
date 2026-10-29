Calculation: Fast average = short-lookback linear weighted moving average of typical price (high + low + close) / 3 on the chart timeframe, using the forming bar.
Calculation: Slow average = longer-lookback linear weighted moving average of typical price (high + low + close) / 3 on the chart timeframe, using the forming bar.
Calculation: Upper envelope = 5-period exponential moving average of high on the chart timeframe, using the forming bar.
Calculation: Lower envelope = 5-period exponential moving average of low on the chart timeframe, using the forming bar.
Long: absolute value of current bid − close two chart bars ago > retrace distance AND current chart-bar open > lower envelope AND fast average > slow average AND low two chart bars ago < high one chart bar ago AND current RSI > prior RSI on a higher timeframe (current bar still forming; prior bar completed)
Short: absolute value of current ask − close two chart bars ago > retrace distance AND current chart-bar open < upper envelope AND fast average < slow average AND low one chart bar ago < high two chart bars ago AND current RSI < prior RSI on a higher timeframe (current bar still forming; prior bar completed)
Exit: Long position, price <= active long stop-loss level OR price >= long take-profit level
Exit: Short position, price >= active short stop-loss level OR price <= short take-profit level