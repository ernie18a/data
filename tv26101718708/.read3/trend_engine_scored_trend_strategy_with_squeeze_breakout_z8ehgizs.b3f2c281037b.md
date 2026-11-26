Calculation: Tracker on each bar series = initialize bullish at low − WMA(TrueRange, tracker lookback) × tracker multiplier; while bullish, set it to the greater of its prior value and low − WMA(TrueRange, tracker lookback) × tracker multiplier, then flip bearish and reset to high + WMA(TrueRange, tracker lookback) × tracker multiplier when close is below it; while bearish, set it to the lesser of its prior value and high + WMA(TrueRange, tracker lookback) × tracker multiplier, then flip bullish and reset to low − WMA(TrueRange, tracker lookback) × tracker multiplier when close is above it
Calculation: Equilibrium = HMA(LinearRegression(close, regression lookback), smoothing lookback)
Calculation: Trend score = 100 × sum of enabled votes / max(1, number of enabled votes), with votes of +1 or −1 for bullish or bearish Tracker direction, close above or not above Equilibrium, Equilibrium above or not above its prior value, RSI above or not above the RSI midpoint, RSI above or not above SMA(RSI, RSI-average lookback), and +DI above or not above −DI
Calculation: Squeeze = for each of the last required squeeze bars, highest(high, range lookback) − lowest(low, range lookback) ≤ ATR(ATR lookback) × range-width multiplier; an active zone starts with its top at the range high and its bottom at the range low
Calculation: Initial stop = the selected Tracker, ATR, percentage, or swing stop; the long ATR stop is reference price − ATR(risk lookback) × stop multiplier, the short ATR stop is reference price + ATR(risk lookback) × stop multiplier, the long percentage stop is reference price × (1 − stop percentage / 100), the short percentage stop is reference price × (1 + stop percentage / 100), the long swing stop is lowest(low, swing lookback) − ATR(risk lookback) × swing buffer, and the short swing stop is highest(high, swing lookback) + ATR(risk lookback) × swing buffer; if a selected stop is not beyond the reference price on the losing side, use the ATR stop; the None mode has no initial stop
Calculation: Protective stop = Initial stop, ratcheted to the reference price after target 1 if breakeven is enabled; when trailing is enabled and active, ratchet it toward profit using Tracker when Tracker direction matches the position, or using the best favorable high or low since the signal minus or plus ATR(risk lookback) × trailing multiplier; trailing activates immediately or after target 1 as configured
Calculation: Target i = none when targets are disabled; in R mode, reference price + position side × risk × target-i parameter, where risk is the distance from reference price to Initial stop or, if there is no Initial stop, ATR(risk lookback) × stop multiplier; in ATR mode, reference price + position side × ATR(risk lookback) × target-i parameter; in percentage mode, reference price × (1 + position side × target-i parameter / 100)
Calculation: Breakout trailing stop = after a confirmed close breaks an active zone, the highest high since the upward breakout − ATR(breakout ATR lookback) × breakout trail multiplier for an upward breakout, or the lowest low since the downward breakout + ATR(breakout ATR lookback) × breakout trail multiplier for a downward breakout; ratchet the stop only toward profit
Long: Tracker direction is bullish
Short: Tracker direction is bearish
Long: Tracker direction changes from bearish to bullish
Short: Tracker direction changes from bullish to bearish
Long: Trend score ≥ bullish bias threshold
Short: Trend score ≤ −bullish bias threshold
Long: If strength-gradient candle coloring is selected, Trend score > 0
Short: If strength-gradient candle coloring is selected, Trend score < 0
Long: RSI > SMA(RSI, RSI-average lookback)
Short: RSI ≤ SMA(RSI, RSI-average lookback)
Long: RSI[1] < RSI[2] AND RSI > RSI[1] AND RSI[1] ≤ oversold threshold, when RSI exhaustion markings are enabled
Short: RSI[1] > RSI[2] AND RSI < RSI[1] AND RSI[1] ≥ overbought threshold, when RSI exhaustion markings are enabled
Long: Tracker direction on any enabled T1–T5 is bullish, using the configured last-completed or still-forming T bar sampled on chart bars
Short: Tracker direction on any enabled T1–T5 is bearish, using the configured last-completed or still-forming T bar sampled on chart bars
Long: Trend score on any enabled T1–T5 ≥ bullish bias threshold, using the configured last-completed or still-forming T bar sampled on chart bars
Short: Trend score on any enabled T1–T5 ≤ −bullish bias threshold, using the configured last-completed or still-forming T bar sampled on chart bars
Long: RSI on any enabled T1–T5 ≤ oversold threshold, using the configured last-completed or still-forming T bar sampled on chart bars
Short: RSI on any enabled T1–T5 ≥ overbought threshold, using the configured last-completed or still-forming T bar sampled on chart bars
Long: A confirmed close above the top of an active squeeze zone
Short: A confirmed close below the bottom of an active squeeze zone
Long: An upward breakout trail is active
Short: A downward breakout trail is active
Long: Tracker direction turns bullish AND no signal has occurred in this Tracker trend AND (the turn is on this bar OR delayed entry is enabled and the turn was within the delayed-entry window) AND every enabled entry filter passes AND the date is within the enabled backtest window AND long trading is enabled; entry filters are Trend score ≥ minimum score, ADX ≥ minimum ADX, RSI ≥ long RSI minimum, close > Equilibrium, volume unavailable or zero or volume > SMA(volume, volume lookback) × volume multiplier, bullish Tracker directions on at least min(required timeframe count, enabled timeframe count) of T1–T5 using the configured last-completed or still-forming T bars sampled on chart bars, no prior signal or at least the cooldown bars since the last signal, and the consolidation filter is off or blocks only while a squeeze zone is active or requires an upward breakout within the breakout-match window
Short: Tracker direction turns bearish AND no signal has occurred in this Tracker trend AND (the turn is on this bar OR delayed entry is enabled and the turn was within the delayed-entry window) AND every enabled entry filter passes AND the date is within the enabled backtest window AND short trading is enabled; entry filters are Trend score ≤ −minimum score, ADX ≥ minimum ADX, RSI ≤ short RSI maximum, close < Equilibrium, volume unavailable or zero or volume > SMA(volume, volume lookback) × volume multiplier, bearish Tracker directions on at least min(required timeframe count, enabled timeframe count) of T1–T5 using the configured last-completed or still-forming T bars sampled on chart bars, no prior signal or at least the cooldown bars since the last signal, and the consolidation filter is off or blocks only while a squeeze zone is active or requires a downward breakout within the breakout-match window
Exit: long, low ≤ Protective stop
Exit: short, high ≥ Protective stop
Exit: long, high ≥ any enabled target among the configured number of targets
Exit: short, low ≤ any enabled target among the configured number of targets
Exit: long, if opposite-flip exits are enabled and Tracker direction changes from bullish to bearish
Exit: short, if opposite-flip exits are enabled and Tracker direction changes from bearish to bullish
Exit: long, if maximum bars in trade is enabled and elapsed chart bars since entry reach the maximum
Exit: short, if maximum bars in trade is enabled and elapsed chart bars since entry reach the maximum
Exit: long, if the backtest date limit is enabled and datetime is after its end date
Exit: short, if the backtest date limit is enabled and datetime is after its end date
Exit: long, an upward breakout trail is active AND a confirmed close < Breakout trailing stop
Exit: short, a downward breakout trail is active AND a confirmed close > Breakout trailing stop