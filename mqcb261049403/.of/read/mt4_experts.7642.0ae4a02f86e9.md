Calculation: Session high = highest high of completed bars in the configured pivot session, using bars from a higher timeframe than the chart timeframe
Calculation: Session low = lowest low of completed bars in the configured pivot session, using bars from a higher timeframe than the chart timeframe
Calculation: Pivot point = (session high + session low + session close) / 3, where session close is the open of the first bar in the session
Long: current price < session low OR current price > session low
Short: current price < session high OR current price > session high
Exit: long, price <= session low minus the stop offset OR price >= pivot point
Exit: short, price >= session high plus the stop offset OR price <= pivot point