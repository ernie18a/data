Calculation: Reference range high/low = highest high and lowest low across bars in the configured reference interval
Calculation: Prior structural high/low = highest high and lowest low over the configured lookback, sampled on the bar immediately before the reference interval begins
Calculation: Double sweep complete = within the configured projection after the reference interval, at least one bar has high above the reference range high and close at or below it, and at least one bar has low below the reference range low and close at or above it
Calculation: Long scale-out target = midpoint between the reference range high and prior structural high, when the prior structural high is above the range high
Calculation: Short scale-out target = midpoint between the reference range low and prior structural low, when the prior structural low is below the range low
Long: during the configured projection after the reference interval AND double sweep complete AND close > reference range high AND no prior long entry signal in this interval
Short: during the configured projection after the reference interval AND double sweep complete AND close < reference range low AND no prior short entry signal in this interval
Exit: long, after a long entry signal AND high >= long scale-out target
Exit: long, after a long entry signal AND high >= prior structural high
Exit: short, after a short entry signal AND low <= short scale-out target
Exit: short, after a short entry signal AND low <= prior structural low