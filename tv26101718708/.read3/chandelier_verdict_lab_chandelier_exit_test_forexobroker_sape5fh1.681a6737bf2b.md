Calculation: Minimum stop distance = max(ATR(real OHLC, lookback) × distance factor, minimum price increment × tick multiple)
Calculation: Selected long stop level = Chandelier long stop line, lowest(execution low, swing lookback) including the entry bar, or ZLSMA(signal close, lookback), according to the stop choice
Calculation: Selected short stop level = Chandelier short stop line, highest(execution high, swing lookback) including the entry bar, or ZLSMA(signal close, lookback), according to the stop choice
Calculation: Long stop = min(selected long stop level, entry price − minimum stop distance), evaluated at entry
Calculation: Short stop = max(selected short stop level, entry price + minimum stop distance), evaluated at entry
Calculation: Initial risk distance = absolute value of entry price − initial stop
Long: On a confirmed chart bar at or before the end datetime, ChandelierExit(signal OHLC, ATR lookback, multiplier, close or high/low extremums) changes direction from short to long, with required indicator values defined
Short: On a confirmed chart bar at or before the end datetime, ChandelierExit(signal OHLC, ATR lookback, multiplier, close or high/low extremums) changes direction from long to short, with required indicator values defined
Long: On a confirmed chart bar at or before the end datetime, Chandelier Buy and signal close > ZLSMA(signal close, lookback), with required indicator values defined
Short: On a confirmed chart bar at or before the end datetime, Chandelier Sell and signal close < ZLSMA(signal close, lookback), with required indicator values defined
Long: On a confirmed chart bar at or before the end datetime, after Chandelier Buy and before the wait limit expires while Chandelier direction remains long, signal close > ZLSMA(signal close, lookback), with required indicator values defined
Short: On a confirmed chart bar at or before the end datetime, after Chandelier Sell and before the wait limit expires while Chandelier direction remains short, signal close < ZLSMA(signal close, lookback), with required indicator values defined
Long: On a confirmed chart bar at or before the end datetime, Chandelier Buy and ZLSMA(signal close, lookback) > its prior-bar value, with required indicator values defined
Short: On a confirmed chart bar at or before the end datetime, Chandelier Sell and ZLSMA(signal close, lookback) < its prior-bar value, with required indicator values defined
Long: On a confirmed chart bar at or before the end datetime, after Chandelier Buy, a green candle closes above ZLSMA(signal close, lookback) after its prior close was at or below the prior ZLSMA value, on the signal bar or within the wait limit while Chandelier direction remains long
Short: On a confirmed chart bar at or before the end datetime, after Chandelier Sell, a red candle closes below ZLSMA(signal close, lookback) after its prior close was at or above the prior ZLSMA value, on the signal bar or within the wait limit while Chandelier direction remains short
Exit: long, after the entry bar on a confirmed chart bar at or before the end datetime, execution low <= long stop
Exit: short, after the entry bar on a confirmed chart bar at or before the end datetime, execution high >= short stop
Exit: long, after the entry bar on a confirmed chart bar at or before the end datetime, execution high >= entry price + initial risk distance × reward-to-risk, unless the stop is hit first
Exit: short, after the entry bar on a confirmed chart bar at or before the end datetime, execution low <= entry price − initial risk distance × reward-to-risk, unless the stop is hit first
Exit: long, after the entry bar on a confirmed chart bar at or before the end datetime, Chandelier Sell, unless the stop is hit first
Exit: short, after the entry bar on a confirmed chart bar at or before the end datetime, Chandelier Buy, unless the stop is hit first
Exit: long, after the entry bar on a confirmed chart bar at or before the end datetime, signal close < ZLSMA(signal close, lookback), unless the stop is hit first
Exit: short, after the entry bar on a confirmed chart bar at or before the end datetime, signal close > ZLSMA(signal close, lookback), unless the stop is hit first
Exit: long, after the entry bar on a confirmed chart bar at or before the end datetime, execution high reaches the reward-to-risk target to close half, then signal close < ZLSMA(signal close, lookback) to close the remainder, unless the stop is hit first
Exit: short, after the entry bar on a confirmed chart bar at or before the end datetime, execution low reaches the reward-to-risk target to close half, then signal close > ZLSMA(signal close, lookback) to close the remainder, unless the stop is hit first
Exit: long, after the entry bar on a confirmed chart bar at or before the end datetime, (signal close < ZLSMA(signal close, lookback) and execution close < entry price) OR Chandelier Sell, unless the stop is hit first
Exit: short, after the entry bar on a confirmed chart bar at or before the end datetime, (signal close > ZLSMA(signal close, lookback) and execution close > entry price) OR Chandelier Buy, unless the stop is hit first