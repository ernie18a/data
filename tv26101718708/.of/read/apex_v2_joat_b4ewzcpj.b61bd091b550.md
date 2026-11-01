Calculation: Cross-timeframe sampling = calculate each requested series on three ordered timeframes; for a higher timeframe use its last completed bar on historical chart bars, and for a lower timeframe use its last intrabar within the chart bar.
Calculation: VWAP deviation = (close − session VWAP of typical price) divided by either a multiple of the standard deviation of close, the standard deviation of close, or the standard deviation of close − VWAP; return zero if the denominator is not positive. Each module has its own method and thresholds.
Calculation: Absorption confirmations = for each requested timeframe, count a positive or negative confirmation when the absolute VWAP deviation reaches that timeframe’s threshold, volume exceeds its volume SMA times a multiplier, and volume divided by its independently calculated volume SMA reaches the relative-volume threshold.
Calculation: Directional bias = (1 − momentum weight) times (number of up candles − number of down candles) divided by the lookback, plus momentum weight times the mean of (close − previous close) / previous close over the same lookback.
Calculation: Structure proximity = absolute difference between close and a confirmed pivot level divided by close; examine the most recent retained pivot lows for support and pivot highs for resistance.
Calculation: Divergence count = count simultaneous confirmed price and RSI pivots where the price pivot and RSI pivot confirmed exactly one pivot-lookback earlier are both defined and price makes a lower low while RSI makes a higher low, or price makes a higher high while RSI makes a lower high, respectively. Reset both counts on chart bars whose zero-based index is divisible by the reset interval, after counting that bar.
Calculation: Absorption coefficient = volume divided by its SMA, or one if the SMA is not positive, multiplied by one minus absolute candle body divided by candle range; use zero for the body-to-range ratio when the range is zero. Signed absorption is positive for close > open and negative otherwise.
Calculation: Buy and sell toxicity = respectively, the sum of volume on up candles closing above a threshold fraction of their range, and the sum on down candles closing below a lower threshold fraction, each divided by total volume over the toxicity lookback; use zero when total volume is zero. A zero-range candle has a midpoint range position.
Calculation: Flow confidence = the sum of weighted points for absorption coefficient above its threshold, either toxicity above the toxicity threshold, and either toxicity above a separate lower threshold.
Calculation: Oscillator gap = absolute difference between VWAP deviation and the z-score of the stochastic close position within the rolling highest-high to lowest-low range; use the midpoint when that range is zero and zero for the z-score when its standard deviation is not positive. Calculate the oscillator from chart bars and sample it in each requested timeframe.
Calculation: Anchor confirmations = separately count requested timeframes whose VWAP deviation is negative and reaches its absolute threshold, whose deviation is positive and reaches its absolute threshold, and whose oscillator gap reaches its own timeframe threshold.
Calculation: Zero-lag basis = EMA of close + (close − close at a lag of floor((EMA length − 1) / 2)). Trend score adds one for each basis value in a specified historical offset range that is below the current basis and subtracts one otherwise. Volatility width is a multiplier times the highest ATR over a lookback longer than the ATR length; the ATR and basis use the same length.
Calculation: Bullish module count = count enabled conditions: negative absorption confirmations reach the required count; directional bias > positive threshold; structure proximity to a recent pivot low < proximity threshold; bullish divergence count reaches its threshold; close < lower Bollinger Band AND RSI < oversold threshold; signed absorption > zero AND absorption coefficient > threshold AND flow confidence reaches its threshold; negative anchor confirmations AND oscillator-gap confirmations each reach their required counts; close < selected moving average of close times one minus a deviation fraction; trend score > uptrend threshold AND close > zero-lag basis + volatility width.
Calculation: Bearish module count = count enabled conditions: positive absorption confirmations reach the required count; directional bias < negative threshold; structure proximity to a recent pivot high < proximity threshold; bearish divergence count reaches its threshold; close > upper Bollinger Band AND RSI > overbought threshold; signed absorption < zero AND absorption coefficient > threshold AND flow confidence reaches its threshold; positive anchor confirmations AND oscillator-gap confirmations each reach their required counts; close > selected moving average of close times one plus a deviation fraction; trend score < downtrend threshold AND close < zero-lag basis − volatility width.
Calculation: Qualified bullish or bearish count = the corresponding module count reaches the confluence threshold when confluence is enabled, or is greater than zero otherwise, with that trade direction enabled. If both directions qualify, retain only the direction with the larger count; retain neither on a tie.
Long: Qualified bullish count is true.
Short: Qualified bearish count is true.
Long: Negative absorption confirmations reach the required count.
Short: Positive absorption confirmations reach the required count.
Long: Directional bias > positive threshold.
Short: Directional bias < negative threshold.
Long: Structure proximity to a recent pivot low < proximity threshold.
Short: Structure proximity to a recent pivot high < proximity threshold.
Long: Bullish divergence count reaches its threshold.
Short: Bearish divergence count reaches its threshold.
Long: Close < lower Bollinger Band AND RSI < oversold threshold.
Short: Close > upper Bollinger Band AND RSI > overbought threshold.
Long: Absorption coefficient > threshold AND signed absorption > zero.
Short: Absorption coefficient > threshold AND signed absorption < zero.
Long: Absorption coefficient does not exceed its threshold AND buy toxicity > toxicity threshold.
Short: Absorption coefficient does not exceed its threshold AND buy toxicity does not exceed its threshold AND sell toxicity > toxicity threshold.
Long: Negative anchor confirmations reach the required count AND oscillator-gap confirmations reach their required count.
Short: Positive anchor confirmations reach the required count AND oscillator-gap confirmations reach their required count.
Long: Close < selected moving average of close times one minus a deviation fraction.
Short: Close > selected moving average of close times one plus a deviation fraction.
Long: Trend score > uptrend threshold AND close > zero-lag basis + volatility width.
Short: Trend score < downtrend threshold AND close < zero-lag basis − volatility width.
Exit: long, qualified bearish count is true.
Exit: short, qualified bullish count is true.
Exit: long, stop loss is enabled AND low reaches the entry-signal close times one minus the stop fraction.
Exit: short, stop loss is enabled AND high reaches the entry-signal close times one plus the stop fraction.
Exit: long, stop loss AND take profit are enabled AND high reaches the entry-signal close times one plus the target fraction.
Exit: short, stop loss AND take profit are enabled AND low reaches the entry-signal close times one minus the target fraction.
Exit: long, stop loss AND trailing stop are enabled AND the target price has been reached AND low reaches the highest price since activation minus the trailing offset.
Exit: short, stop loss AND trailing stop are enabled AND the target price has been reached AND high reaches the lowest price since activation plus the trailing offset.
Calculation: Trailing offset = entry-signal close times the trailing fraction, interpreted as a number of minimum price ticks; the target price is the entry-signal close adjusted by the target fraction.