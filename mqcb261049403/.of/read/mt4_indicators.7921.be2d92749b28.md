Calculation: Prior trading day = the last completed trading day in the configured destination time zone; calculate its high, low, and close from its bars.
Calculation: Pivot = (prior trading day high + prior trading day low + prior trading day close) / 3.
Calculation: Reference price = current trading day open when daily-open mode is enabled; otherwise Pivot.
Calculation: Buy levels = Reference price plus the configured shorter and longer offsets, respectively.
Calculation: Sell levels = Reference price minus the configured shorter and longer offsets, respectively.
Long: Current price is within the configured tolerance of the buy level using the shorter offset.
Long: Current price is within the configured tolerance of the buy level using the longer offset.
Short: Current price is within the configured tolerance of the sell level using the shorter offset.
Short: Current price is within the configured tolerance of the sell level using the longer offset.
Long: ADX positive directional indicator > ADX negative directional indicator.
Short: ADX positive directional indicator < ADX negative directional indicator.
Long: Force Index > 0.
Short: Force Index < 0.
Long: RSI > 50.
Short: RSI < 50.
Long: At least two of ADX positive directional indicator > ADX negative directional indicator, Force Index > 0, and RSI > 50.
Short: At least two of ADX positive directional indicator < ADX negative directional indicator, Force Index < 0, and RSI < 50.
Exit: Long position, current price >= buy level using the longer offset OR current price <= buy level using the shorter offset minus the configured stop offset.
Exit: Long position, current price >= buy level using the longer offset plus the configured target offset OR current price <= buy level using the shorter offset minus the configured breakout stop offset.
Exit: Short position, current price <= sell level using the longer offset OR current price >= sell level using the shorter offset plus the configured stop offset.
Exit: Short position, current price <= sell level using the longer offset minus the configured target offset OR current price >= sell level using the shorter offset plus the configured breakout stop offset.