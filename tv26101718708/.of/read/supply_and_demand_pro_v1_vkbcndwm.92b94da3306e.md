Calculation: Strong bullish trend = fast EMA > mid EMA > slow EMA and RSI > midline
Calculation: Strong bearish trend = fast EMA < mid EMA < slow EMA and RSI < midline
Calculation: Early bullish momentum = (fast EMA > mid EMA OR close > fast EMA) and RSI > midline
Calculation: Early bearish momentum = (fast EMA < mid EMA OR close < fast EMA) and RSI < midline
Calculation: Bullish structure break = close > the prior lookback bars' highest high and preceding close <= that high
Calculation: Bearish structure break = close < the prior lookback bars' lowest low and preceding close >= that low
Calculation: Bullish break is recent = a bullish structure break occurred within the configured signal window
Calculation: Bearish break is recent = a bearish structure break occurred within the configured signal window
Calculation: Bullish demand-zone setup = on a higher-timeframe bar, the bullish body exceeds the longer lookback average absolute body by the configured multiple, and the body three bars earlier is smaller than that average by the configured factor; use the latest completed higher-timeframe bar
Calculation: Bearish supply-zone setup = on a higher-timeframe bar, the bearish body exceeds the longer lookback average absolute body by the configured multiple, and the body three bars earlier is smaller than that average by the configured factor; use the latest completed higher-timeframe bar
Calculation: Long risk distance = entry price minus the signal-bar low or preceding-bar low, whichever is lower, adjusted downward by the configured stop buffer
Calculation: Short risk distance = the signal-bar high or preceding-bar high, whichever is higher, adjusted upward by the configured stop buffer
Long: bullish demand-zone setup
Long: early bullish momentum and RSI > midline plus configured breakout margin and NOT strong bearish trend and bullish break is recent and bullish structure break on current bar and within configured session and no buy signal within the configured cooldown
Long: strong bullish trend and NOT strong bearish trend and bullish break is recent and within configured session and no buy signal within the configured cooldown and (no prior X-buy signal OR more than the configured continuation delay bars since the latest X-buy)
Short: bearish supply-zone setup
Short: early bearish momentum and RSI < midline minus configured breakout margin and NOT strong bullish trend and bearish break is recent and bearish structure break on current bar and within configured session and no sell signal within the configured cooldown
Short: strong bearish trend and NOT strong bullish trend and bearish break is recent and within configured session and no sell signal within the configured cooldown and (no prior X-sell signal OR more than the configured continuation delay bars since the latest X-sell)
Exit: long, high >= entry price + long risk distance multiplied by any configured take-profit multiple AND preceding low < that target
Exit: short, low <= entry price - short risk distance multiplied by any configured take-profit multiple AND preceding high > that target