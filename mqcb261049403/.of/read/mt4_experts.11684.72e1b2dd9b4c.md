Calculation: RSI = RSI of the configured applied price over the configured period on the configured RSI timeframe (its relation to the chart timeframe is unspecified), using the bar still forming.
Long: RSI < lower threshold OR (an existing long position is losing by more than the configured pending gap AND RSI < upper threshold)
Short: RSI > upper threshold OR (an existing short position is losing by more than the configured pending gap AND RSI > lower threshold)
Exit: long, high > entry price + configured take-profit distance OR low <= highest high since entry − configured trailing-stop distance
Exit: short, low < entry price − configured take-profit distance OR high >= lowest low since entry + configured trailing-stop distance