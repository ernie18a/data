Calculation: Fusion average = mean(EMA(close, fusion length), SMA(close, fusion length), WMA(close, fusion length), ALMA(close, fusion length, ALMA offset, ALMA sigma), VWAP(hlc3))
Calculation: Fusion slow = EMA(Fusion average, slow fusion sensitivity); Fusion fast = EMA(Fusion average, fast fusion sensitivity), where fast fusion sensitivity is shorter than slow fusion sensitivity
Calculation: Fusion bullish state = close > Fusion slow AND Fusion slow > its prior-bar value
Calculation: Fusion bearish state = close < Fusion slow AND Fusion slow < its prior-bar value
Calculation: Accepted fusion long signal = Fusion bullish state AND prior-bar Fusion state was bearish or neutral AND (the last accepted fusion signal was short or no signal, OR bars since the last accepted long signal >= fusion signal cooldown)
Calculation: Accepted fusion short signal = Fusion bearish state AND prior-bar Fusion state was bullish or neutral AND (the last accepted fusion signal was long or no signal, OR bars since the last accepted short signal >= fusion signal cooldown)
Calculation: Fast, slow, and turtle Williams %R = Williams %R(high, low, close, their respective periods), with the fast period shorter than the slow period and the slow period shorter than the turtle period
Calculation: Fast WPR velocity = fast Williams %R minus its prior-bar value; absolute velocity = absolute value of Fast WPR velocity
Calculation: UTC session = Asian, London, overlap, New York afternoon, or New York close, according to the respective UTC hour-boundary parameters
Calculation: Session velocity base = the session-specific velocity-base parameter
Calculation: Velocity thresholds = weak threshold, ideal minimum, ideal maximum, strong threshold, and extreme threshold, each equal to its respective velocity multiplier parameter times Session velocity base
Calculation: Velocity quality = ideal when absolute velocity is between the ideal minimum and ideal maximum inclusive, strong when above the ideal maximum and at most the strong threshold, extreme when above the strong threshold, and weak otherwise
Calculation: Slow WPR slope = (slow Williams %R - slow Williams %R at the trend lookback) / trend lookback; turtle WPR slope = (turtle Williams %R - turtle Williams %R at the trend lookback) / trend lookback
Calculation: Bullish divergence = the latest confirmed pivot low is lower than the preceding confirmed pivot low, its fast Williams %R value is higher than at the preceding pivot low, the latest pivot is within the pivot recency limit, and the pivot separation is between the minimum and maximum pivot-separation parameters
Calculation: Bearish divergence = the latest confirmed pivot high is higher than the preceding confirmed pivot high, its fast Williams %R value is lower than at the preceding pivot high, the latest pivot is within the pivot recency limit, and the pivot separation is between the minimum and maximum pivot-separation parameters
Calculation: Buy divergence trigger = Bullish divergence AND Fast WPR velocity > weak velocity threshold; sell divergence trigger = Bearish divergence AND Fast WPR velocity < negative weak velocity threshold
Calculation: Buy extreme-snap trigger = prior fast Williams %R < extreme-snap oversold threshold AND Fast WPR velocity > weak velocity threshold AND (turtle Williams %R > extreme-snap turtle threshold OR slow Williams %R > extreme-snap slow threshold) AND fast Williams %R crosses above the oversold parameter; sell extreme-snap trigger = prior fast Williams %R > extreme-snap overbought threshold AND Fast WPR velocity < negative weak velocity threshold AND (turtle Williams %R < extreme-snap turtle threshold OR slow Williams %R < extreme-snap slow threshold) AND fast Williams %R crosses below the overbought parameter
Calculation: Buy exhaustion trigger = prior fast Williams %R < exhaustion oversold threshold AND (turtle Williams %R > exhaustion turtle threshold OR slow Williams %R > exhaustion slow threshold) AND Fast WPR velocity > weak velocity threshold AND fast Williams %R crosses above the oversold parameter; sell exhaustion trigger = prior fast Williams %R > exhaustion overbought threshold AND (turtle Williams %R < exhaustion turtle threshold OR slow Williams %R < exhaustion slow threshold) AND Fast WPR velocity < negative weak velocity threshold AND fast Williams %R crosses below the overbought parameter
Calculation: Strong uptrend = turtle Williams %R > strong-uptrend turtle threshold AND slow Williams %R > strong-uptrend slow threshold; very strong uptrend = turtle Williams %R > very-strong-uptrend turtle threshold AND slow Williams %R > very-strong-uptrend slow threshold; moderate uptrend = turtle Williams %R > moderate-uptrend turtle threshold AND slow Williams %R > moderate-uptrend slow threshold
Calculation: Strong downtrend = turtle Williams %R < strong-downtrend turtle threshold AND slow Williams %R < strong-downtrend slow threshold; very strong downtrend = turtle Williams %R < very-strong-downtrend turtle threshold AND slow Williams %R < very-strong-downtrend slow threshold; moderate downtrend = turtle Williams %R < moderate-downtrend turtle threshold AND slow Williams %R < moderate-downtrend slow threshold
Calculation: Buy continuation trigger = fast Williams %R crosses above the oversold parameter AND (very strong uptrend OR strong uptrend) AND (slow WPR slope > its uptrend slope threshold OR turtle WPR slope > its uptrend slope threshold); sell continuation trigger = fast Williams %R crosses below the overbought parameter AND (very strong downtrend OR strong downtrend) AND (slow WPR slope < its downtrend slope threshold OR turtle WPR slope < its downtrend slope threshold)
Calculation: Buy pullback trigger = fast Williams %R crosses above the oversold parameter AND (moderate uptrend OR slow Williams %R > pullback slow-WPR threshold) AND Fast WPR velocity > weak velocity threshold; sell pullback trigger = fast Williams %R crosses below the overbought parameter AND (moderate downtrend OR slow Williams %R < pullback slow-WPR threshold) AND Fast WPR velocity < negative weak velocity threshold
Calculation: All-oversold = fast Williams %R < its triple-buy threshold AND slow Williams %R < its triple-buy threshold AND turtle Williams %R < its triple-buy threshold; all-overbought = fast Williams %R > its triple-sell threshold AND slow Williams %R > its triple-sell threshold AND turtle Williams %R > its triple-sell threshold
Calculation: Buy triple trigger = All-oversold AND Fast WPR velocity > weak velocity threshold AND fast Williams %R crosses above the oversold parameter; sell triple trigger = all-overbought AND Fast WPR velocity < negative weak velocity threshold AND fast Williams %R crosses below the overbought parameter
Calculation: Buy signal count = number of true buy divergence, buy extreme-snap, buy exhaustion, buy continuation, buy pullback, and buy triple triggers; sell signal count = number of true sell divergence, sell extreme-snap, sell exhaustion, sell continuation, sell pullback, and sell triple triggers
Calculation: Buy stacking bonus = the high stacking bonus when buy signal count >= its high-count threshold, the low stacking bonus when count >= its low-count threshold, otherwise zero; sell stacking bonus is defined the same way from sell signal count and the corresponding sell parameters
Calculation: Buy confidence = clamp to the confidence range the sum of: turtle-WPR buy points selected by its buy thresholds; fast-WPR buy points selected by its buy thresholds; the highest-priority applicable trigger points in order triple, continuation, divergence, extreme-snap, exhaustion, pullback; velocity-quality points; UTC session quality divided by its divisor; EMA points (price above the long EMA and short EMA above long EMA, or price above the long EMA); buy stacking bonus; minus the applicable absolute-velocity penalty, RSI penalty, Asian-session or New-York-close penalty, and low-volume penalty
Calculation: Sell confidence = clamp to the confidence range the sum of: turtle-WPR sell points selected by its sell thresholds; fast-WPR sell points selected by its sell thresholds; the highest-priority applicable trigger points in order triple, continuation, divergence, extreme-snap, exhaustion, pullback; velocity-quality points; UTC session quality divided by its divisor; EMA points (price below the long EMA and short EMA below long EMA, or price below the long EMA); sell stacking bonus; minus the applicable absolute-velocity penalty, RSI penalty, Asian-session or New-York-close penalty, and low-volume penalty
Calculation: Valid buy signal = at least one buy trigger AND Buy confidence >= minimum confidence; valid sell signal = at least one sell trigger AND Sell confidence >= minimum confidence
Calculation: Strong-uptrend gate thresholds = the respective uptrend gate parameters, raised by the strict-mode adjustment when strict mode is enabled; strong-downtrend gate thresholds = the respective downtrend gate parameters, lowered by that adjustment when strict mode is enabled
Calculation: Bull recovery = fast Williams %R > its lowest value over the recovery lookback plus the minimum recovery move AND that lowest value < the recovery oversold threshold; bear recovery = fast Williams %R < its highest value over the recovery lookback minus the minimum recovery move AND that highest value > the recovery overbought threshold
Calculation: Gated buy signal = Valid buy signal AND (not a strong-downtrend gate OR recovery is enabled AND Bull recovery); gated sell signal = Valid sell signal AND (not a strong-uptrend gate OR recovery is enabled AND bear recovery)
Calculation: Alpha long entry = current accepted fusion trend is long AND Gated buy signal AND (date filter disabled OR chart-bar datetime is within the date range)
Calculation: Alpha short entry = current accepted fusion trend is short AND Gated sell signal AND (date filter disabled OR chart-bar datetime is within the date range)
Calculation: Alpha long exit = current accepted fusion trend is long AND a long entry has occurred since the latest accepted fusion signal AND Gated sell signal AND (date filter disabled OR chart-bar datetime is within the date range); Alpha short exit is the corresponding short-trend condition with Gated buy signal
Calculation: UT source = Heikin-Ashi close when the Heikin-Ashi option is enabled, otherwise close; UT loss = UT key-value parameter times ATR(UT ATR period)
Calculation: UT trailing stop = if UT source and its prior-bar value are both above the prior stop, the greater of the prior stop and UT source minus UT loss; if both are below the prior stop, the lesser of the prior stop and UT source plus UT loss; otherwise UT source minus UT loss when UT source is above the prior stop, or UT source plus UT loss when it is not
Calculation: UT buy signal = UT source > UT trailing stop AND EMA(UT source, UT EMA period) crosses above UT trailing stop; UT sell signal = UT source < UT trailing stop AND UT trailing stop crosses above EMA(UT source, UT EMA period)
Calculation: Algo basis = EMA(close + (close - close at floor((Algo length - one) / two) bars ago), Algo length); Algo band width = highest(ATR(Algo length), Algo length times its band-lookback multiplier) times the band multiplier
Calculation: Algo trend state = long on a close crossover above Algo basis plus Algo band width, short on a close crossunder below Algo basis minus Algo band width, otherwise retain its prior state
Calculation: Algo trend state on each of T1, T2, T3, T4, and T5 is calculated on that timeframe's bars and sampled on chart bars from its still-forming bar; after that bar closes its completed value is used
Long: Fusion bullish state
Short: Fusion bearish state
Long: Fusion fast > Fusion slow
Short: Fusion fast < Fusion slow
Long: Accepted fusion long signal
Short: Accepted fusion short signal
Long: Alpha long entry
Short: Alpha short entry
Exit: long, Alpha long exit
Exit: short, Alpha short exit
Long: UT source > UT trailing stop
Short: UT source < UT trailing stop
Long: UT buy signal
Short: UT sell signal
Long: Algo trend state is long
Short: Algo trend state is short
Long: Algo trend state crosses above zero
Short: Algo trend state crosses below zero
Long: close crosses above Algo basis AND Algo trend state is long on the current and prior bars
Short: close crosses below Algo basis AND Algo trend state is short on the current and prior bars
Long: Algo trend state on T1 is long
Short: Algo trend state on T1 is short
Long: Algo trend state on T2 is long
Short: Algo trend state on T2 is short
Long: Algo trend state on T3 is long
Short: Algo trend state on T3 is short
Long: Algo trend state on T4 is long
Short: Algo trend state on T4 is short
Long: Algo trend state on T5 is long
Short: Algo trend state on T5 is short
Long: Alpha long entry AND UT buy signal AND close crosses above Algo basis AND Algo trend state is long on the current and prior bars
Short: Alpha short entry AND UT sell signal AND close crosses below Algo basis AND Algo trend state is short on the current and prior bars