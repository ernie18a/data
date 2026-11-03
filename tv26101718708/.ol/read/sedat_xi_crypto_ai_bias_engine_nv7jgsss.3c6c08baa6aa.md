Calculation: Scan timeframe = configured independently of the chart timeframe; it may be higher, equal, or lower. Use the scan-timeframe bar available at each chart bar (last completed in historical data; still forming in live data)
Calculation: High volume = scan-timeframe volume > its moving average over a lookback × volume multiplier
Calculation: Bull breakout = scan-timeframe close > the highest scan-timeframe high over the breakout lookback, excluding the current bar AND high volume
Calculation: Bear breakout = scan-timeframe close < the lowest scan-timeframe low over the breakout lookback, excluding the current bar AND high volume
Calculation: Directional score = +2 for short-term EMA > medium-term EMA > long-term EMA, −2 for short-term EMA < medium-term EMA < long-term EMA, otherwise 0; add +1 if close > long-term EMA, otherwise −1; add +1 if RSI > its upper threshold, −1 if RSI < its lower threshold, otherwise 0; add +2 for bull breakout, −2 for bear breakout, and +1 for high volume
Long: bull breakout OR (not bear breakout AND directional score > 0)
Short: bear breakout OR (not bull breakout AND directional score < 0)