Calculation: large body = abs(close - open) > SMA(abs(close - open), body lookback) × body size multiplier
Calculation: bullish structure = at least two confirmed pivot highs and lows exist AND latest confirmed pivot high > preceding confirmed pivot high AND latest confirmed pivot low > preceding confirmed pivot low
Calculation: bearish structure = at least two confirmed pivot highs and lows exist AND latest confirmed pivot high < preceding confirmed pivot high AND latest confirmed pivot low < preceding confirmed pivot low
Calculation: confirmed supply and demand zones = at each confirmed pivot high or low, create an interval from pivot price × (1 - zone tolerance) to pivot price × (1 + zone tolerance); if a new same-type pivot lies within the first existing interval, increment its count, otherwise create an interval with count one; retain all intervals and confirm an interval when its count >= minimum zone rejections
Calculation: demand-zone membership = close lies within any confirmed interval formed from pivot lows
Calculation: supply-zone membership = close lies within any confirmed interval formed from pivot highs
Calculation: upward structure break = at least two confirmed pivot highs exist AND close > the second most recent confirmed pivot high AND close[1] <= that same current pivot-high level
Calculation: downward structure break = at least two confirmed pivot lows exist AND close < the second most recent confirmed pivot low AND close[1] >= that same current pivot-low level
Calculation: bullish retest = an upward structure break has armed an unconsumed retest AND low <= the current second most recent confirmed pivot high × (1 + zone tolerance) AND close > that pivot-high level; consume the retest when this condition occurs
Calculation: bearish retest = a downward structure break has armed an unconsumed retest AND high >= the current second most recent confirmed pivot low × (1 - zone tolerance) AND close < that pivot-low level; consume the retest when this condition occurs
Calculation: long score = count of true conditions: bullish structure, demand-zone membership, upward structure break, bullish retest, close > VWAP(hlc3, reset at each T1 boundary, calculated on chart bars including the current bar), EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback), RSI(close, RSI lookback) > RSI threshold
Calculation: short score = count of true conditions: bearish structure, supply-zone membership, downward structure break, bearish retest, close < VWAP(hlc3, reset at each T1 boundary, calculated on chart bars including the current bar), EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback), RSI(close, RSI lookback) < RSI threshold
Calculation: cooldown = swing length × scalp cooldown multiplier on chart timeframes T2, T3, or T4; otherwise swing length × regular cooldown multiplier
Calculation: entry lock = while a long or short signal position is active, increment the loss count when its score < low-score threshold AND score >= minimum score minus score-release offset; reset the count and clear the lock on a new signal; activate the lock when the count >= maximum-loss parameter
Calculation: long entry price = high of the chart bar that triggers the long entry
Calculation: short entry price = low of the chart bar that triggers the short entry
Calculation: long initial stop = low of the long-entry signal bar - ATR(ATR lookback) × applicable stop multiplier; use the scalp stop buffer on chart timeframes T2, T3, or T4, otherwise use the regular stop multiplier
Calculation: short initial stop = high of the short-entry signal bar + ATR(ATR lookback) × applicable stop multiplier; use the scalp stop buffer on chart timeframes T2, T3, or T4, otherwise use the regular stop multiplier
Calculation: long initial risk = long entry price - long initial stop
Calculation: short initial risk = short initial stop - short entry price
Long: confirmed pivot high > preceding confirmed pivot high
Short: confirmed pivot high <= preceding confirmed pivot high
Long: confirmed pivot low > preceding confirmed pivot low
Short: confirmed pivot low <= preceding confirmed pivot low
Long: bullish structure
Short: bearish structure
Long: large body AND close > open
Short: large body AND close < open
Long: demand-zone membership
Short: supply-zone membership
Long: demand-zone membership AND NOT demand-zone membership on the prior chart bar
Short: supply-zone membership AND NOT supply-zone membership on the prior chart bar
Long: upward structure break
Short: downward structure break
Long: bullish retest
Short: bearish retest
Long: low < Lowest(low, liquidity lookback) on the prior chart bar AND close > that prior-bar low
Short: high > Highest(high, liquidity lookback) on the prior chart bar AND close < that prior-bar high
Long: close > VWAP(hlc3, reset at each T1 boundary, calculated on chart bars including the current bar)
Short: close < VWAP(hlc3, reset at each T1 boundary, calculated on chart bars including the current bar)
Long: EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback)
Short: EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback)
Short: EMA(close, shorter EMA lookback) <= EMA(close, longer EMA lookback)
Long: RSI(close, RSI lookback) > RSI threshold
Short: RSI(close, RSI lookback) < RSI threshold
Long: long score >= minimum score AND position side is flat AND entry lock is inactive AND (no prior long signal OR chart bars since the prior long signal > cooldown)
Short: short score >= minimum score AND position side is flat AND entry lock is inactive AND (no prior short signal OR chart bars since the prior short signal > cooldown)
Exit: long, long score < minimum score minus score-release offset OR long score < low-score threshold
Exit: short, short score < minimum score minus score-release offset OR short score < low-score threshold
Exit: long, low <= long initial stop
Exit: short, high >= short initial stop
Exit: long, high >= long entry price + long initial risk × first target multiple
Exit: short, low <= short entry price - short initial risk × first target multiple
Exit: long, after high reaches long entry price + long initial risk × second target multiple, low <= long entry price
Exit: short, after low reaches short entry price - short initial risk × second target multiple, high >= short entry price
Exit: long, high >= long entry price + long initial risk × third target multiple
Exit: short, low <= short entry price - short initial risk × third target multiple