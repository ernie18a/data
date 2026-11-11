Calculation: Trend vote = sum of three scores, each +1 if the first value is greater, -1 if less, and 0 if equal: shorter-period close EMA versus longer-period close EMA; close versus longer-period close EMA; longer-period close EMA versus its value a specified number of bars earlier. Calculate on the chart timeframe using the current bar and on each enabled equal or higher timeframe using either the last completed bar or the bar still forming, according to the confirmed-bars setting. The chart timeframe is always included separately; exclude unavailable votes and configured timeframes lower than the chart timeframe.
Calculation: Alignment = (number of included trend votes greater than zero minus number less than zero) divided by the number of included votes, including zero votes.
Long: Any included trend vote > 0
Short: Any included trend vote < 0
Long: Alignment >= positive alignment threshold
Short: Alignment <= negative alignment threshold