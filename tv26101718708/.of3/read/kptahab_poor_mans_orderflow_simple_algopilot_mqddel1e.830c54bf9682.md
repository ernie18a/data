Calculation: body ratio = high > low ? abs(close - open) / (high - low) : 0
Calculation: volume spike = volume > SMA(volume[1], volume lookback) × volume multiplier
Calculation: average candle range = SMA((high - low)[1], volume lookback)
Calculation: long absorption = body ratio < absorption body-ratio threshold AND volume spike AND close < open
Calculation: short absorption = body ratio < absorption body-ratio threshold AND volume spike AND close > open
Calculation: long impulse = body ratio > impulse body-ratio threshold AND volume spike AND high - low > average candle range × impulse range multiplier AND close > open
Calculation: short impulse = body ratio > impulse body-ratio threshold AND volume spike AND high - low > average candle range × impulse range multiplier AND close < open
Calculation: long absorption cluster = count of long absorptions in the current and preceding cluster lookback bars ≥ cluster threshold
Calculation: short absorption cluster = count of short absorptions in the current and preceding cluster lookback bars ≥ cluster threshold
Calculation: long pullback setup = a long absorption exists in the preceding entry lookback bars AND close[1] ≤ the high of the most recent such absorption AND close > open AND close exceeds that high
Calculation: short pullback setup = a short absorption exists in the preceding entry lookback bars AND close[1] ≥ the low of the most recent such absorption AND close < open AND close is below that low
Calculation: cluster-confirmed long = long absorption cluster AND long pullback setup
Calculation: cluster-confirmed short = short absorption cluster AND short pullback setup
Calculation: selected long signal = external source selected AND external signal = +1, OR internal source selected AND the signal mode selects a long pullback setup, cluster-confirmed long, long impulse, or long absorption cluster AND long impulse
Calculation: selected short signal = external source selected AND external signal = -1, OR internal source selected AND the signal mode selects a short pullback setup, cluster-confirmed short, short impulse, or short absorption cluster AND short impulse
Calculation: selected close-long signal = external source selected AND external signal = -2, OR internal source selected AND the close mode selects a confirmed short absorption cluster AND short impulse, a confirmed short impulse, or a confirmed cluster-confirmed short
Calculation: selected close-short signal = external source selected AND external signal = +2, OR internal source selected AND the close mode selects a confirmed long absorption cluster AND long impulse, a confirmed long impulse, or a confirmed cluster-confirmed long
Calculation: entry time filter passes = time_close is within enabled date bounds AND (intraday session filter disabled OR the bar is within a selected weekday's session and time_close is before its end)
Calculation: losing-trade filter passes = maximum losing-trades filter disabled OR total losing-trade count is below its configured limit
Calculation: long close request = explicit signal closes are allowed AND selected close-long signal OR reversals are allowed AND selected short signal
Calculation: short close request = explicit signal closes are allowed AND selected close-short signal OR reversals are allowed AND selected long signal
Calculation: session-close condition = intraday session filter enabled AND (bar is outside the selected session OR bar is within the session and time_close is at or after its end)
Calculation: long target price(p) = entry price × (1 + p / 100)
Calculation: short target price(p) = entry price / (1 + p / 100)
Calculation: long fixed stop price = entry price × (1 - stop percentage / 100)
Calculation: short fixed stop price = entry price × (1 + stop percentage / 100)
Calculation: long trailing stop resets to entry price × (1 - stop percentage / 100) on a new long position; otherwise it is max(previous long trailing stop × current entry price / prior entry price when the average entry changes, close × (1 - stop percentage / 100))
Calculation: short trailing stop resets to entry price × (1 + stop percentage / 100) on a new short position; otherwise it is min(previous short trailing stop × current entry price / prior entry price when the average entry changes, close × (1 + stop percentage / 100))
Calculation: long first-target-reached state resets when flat or on a new position and persists once the prior bar's high exceeds the long first target price
Calculation: short first-target-reached state resets when flat or on a new position and persists once the prior bar's low falls below the short first target price
Long: long pullback setup OR cluster-confirmed long OR long impulse OR long absorption cluster AND long impulse OR external source selected AND external signal = +1
Short: short pullback setup OR cluster-confirmed short OR short impulse OR short absorption cluster AND short impulse OR external source selected AND external signal = -1
Long: selected long signal AND long entries enabled AND no open position AND entry time filter passes AND losing-trade filter passes
Short: selected short signal AND short entries enabled AND no open position AND entry time filter passes AND losing-trade filter passes
Long: long position AND loss repurchase enabled AND entry time filter passes AND NOT session-close condition AND NOT long close request AND close < entry price × (1 - repurchase loss distance / 100)
Short: short position AND loss repurchase enabled AND entry time filter passes AND NOT session-close condition AND NOT short close request AND close > entry price × (1 + repurchase loss distance / 100)
Exit: Long, long close request
Exit: Short, short close request
Exit: Long, session-close condition
Exit: Short, session-close condition
Exit: Long, first partial target enabled AND high ≥ long target price(first target percentage)
Exit: Short, first partial target enabled AND low ≤ short target price(first target percentage)
Exit: Long, second partial target enabled AND high ≥ long target price(second target percentage)
Exit: Short, second partial target enabled AND low ≤ short target price(second target percentage)
Exit: Long, high ≥ long target price(final target percentage)
Exit: Short, low ≤ short target price(final target percentage)
Exit: Long, fixed stop mode enabled AND low ≤ long fixed stop price
Exit: Short, fixed stop mode enabled AND high ≥ short fixed stop price
Exit: Long, trailing stop mode enabled AND low ≤ long trailing stop
Exit: Short, trailing stop mode enabled AND high ≥ short trailing stop
Exit: Long, long first-target-reached state AND breakeven-after-first-target enabled AND stop enabled AND (current stop absent OR current stop < entry price) AND low ≤ entry price
Exit: Short, short first-target-reached state AND breakeven-after-first-target enabled AND stop enabled AND (current stop absent OR current stop > entry price) AND high ≥ entry price