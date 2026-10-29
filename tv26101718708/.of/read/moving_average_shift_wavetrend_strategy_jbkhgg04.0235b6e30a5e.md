Calculation: Selected moving average = selected moving average type applied to hl2
Calculation: Momentum oscillator = Hull moving average of the change in (hl2 minus selected moving average) divided by the rolling 99th-percentile interpolated value of that difference; percentile lookback is longer than the oscillator change lookback
Calculation: Long-term trend EMA = EMA of hl2
Calculation: ATR median = rolling median of ATR
Calculation: Entry-wave state = false initially; reset to false when the oscillator crosses zero; set to true on either entry
Calculation: Long trailing reference = highest high since entering the long position
Calculation: Short trailing reference = lowest low since entering the short position
Long: hl2 >= selected moving average AND momentum oscillator > 0 AND momentum oscillator > its prior value AND long-term trend EMA > its prior value AND ATR > ATR median AND exchange-time hour >= session start hour AND exchange-time hour < session end hour AND entry-wave state = false
Short: hl2 < selected moving average AND momentum oscillator < 0 AND momentum oscillator < its prior value AND long-term trend EMA < its prior value AND ATR > ATR median AND exchange-time hour >= session start hour AND exchange-time hour < session end hour AND entry-wave state = false
Exit: long, high >= long take-profit price OR low <= long stop-loss price OR momentum oscillator < 0 AND momentum oscillator < its prior value AND hl2 < selected moving average OR close < long trailing reference multiplied by (1 − trailing-stop percentage)
Exit: short, low <= short take-profit price OR high >= short stop-loss price OR momentum oscillator > 0 AND momentum oscillator > its prior value AND hl2 > selected moving average OR close > short trailing reference multiplied by (1 + trailing-stop percentage)