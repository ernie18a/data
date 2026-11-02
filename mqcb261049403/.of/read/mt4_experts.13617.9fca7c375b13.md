Calculation: Trailing stop = for a long position, the highest price since entry minus the trailing distance, activated only after price rises more than the trailing distance above entry; for a short position, the lowest price since entry plus the trailing distance, activated only after price falls more than the trailing distance below entry.
Long: No long position AND shorter-period moving average > longer-period moving average AND (distance filter disabled OR shorter-period moving average - longer-period moving average > minimum distance) AND (trade-time filter disabled OR time is within the configured trading window) AND (reversal mode enabled OR no short position). Moving averages use the chart timeframe or a configured higher or lower timeframe, using the bar still forming.
Short: No short position AND shorter-period moving average < longer-period moving average AND (distance filter disabled OR longer-period moving average - shorter-period moving average > minimum distance) AND (trade-time filter disabled OR time is within the configured trading window) AND (reversal mode enabled OR no long position). Moving averages use the chart timeframe or a configured higher or lower timeframe, using the bar still forming.
Long: Turn enabled AND short position AND price >= short entry price + turn distance.
Short: Turn enabled AND long position AND price <= long entry price - turn distance.
Long: Turn disabled AND long position AND step-up enabled AND price >= highest open long entry price + step-up distance.
Long: Turn disabled AND long position AND step-down enabled AND price <= lowest open long entry price - step-down distance.
Short: Turn disabled AND short position AND step-up enabled AND price <= lowest open short entry price - step-up distance.
Short: Turn disabled AND short position AND step-down enabled AND price >= highest open short entry price + step-down distance.
Exit: long, Turn disabled AND reversal mode enabled AND shorter-period moving average < longer-period moving average AND (distance filter disabled OR longer-period moving average - shorter-period moving average > minimum distance) AND (trade-time filter disabled OR time is within the configured trading window).
Exit: short, Turn disabled AND reversal mode enabled AND shorter-period moving average > longer-period moving average AND (distance filter disabled OR shorter-period moving average - longer-period moving average > minimum distance) AND (trade-time filter disabled OR time is within the configured trading window).
Exit: long, stop loss enabled AND price <= entry price - stop-loss distance.
Exit: short, stop loss enabled AND price >= entry price + stop-loss distance.
Exit: long, take profit enabled AND price >= entry price + take-profit distance.
Exit: short, take profit enabled AND price <= entry price - take-profit distance.
Exit: long, Turn disabled AND trailing stop enabled AND price <= trailing stop.
Exit: short, Turn disabled AND trailing stop enabled AND price >= trailing stop.
Exit: long, Turn enabled AND price <= entry price - turn distance.
Exit: short, Turn enabled AND price >= entry price + turn distance.