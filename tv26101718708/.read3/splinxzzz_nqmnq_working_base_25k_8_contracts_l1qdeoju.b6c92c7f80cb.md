Calculation: Demand bounds = latest confirmed Pivot Low(low, pivot lookback on both sides) plus or minus zone width
Calculation: Supply bounds = latest confirmed Pivot High(high, pivot lookback on both sides) plus or minus zone width
Calculation: Recent range = Highest(high, range lookback) - Lowest(low, range lookback)
Calculation: T1 net profit change = current strategy net profit - strategy net profit at the start of T1
Calculation: Long stop = demand bottom
Calculation: Long risk = setup bar close - Long stop
Calculation: Long target = setup bar close + Long risk * reward-risk multiple
Calculation: Short stop = supply top
Calculation: Short risk = Short stop - setup bar close
Calculation: Short target = setup bar close - Short risk * reward-risk multiple
Long: T1 net profit change > -loss limit AND demand zone exists AND low <= demand top AND close > demand top AND ((low < Lowest(low, sweep lookback)[1] AND close > Lowest(low, sweep lookback)[1]) OR (low < low[1] AND close > open)) AND close > open AND close - open > ATR(ATR lookback) * displacement multiple AND close > EMA(close, EMA lookback) AND Recent range > ATR(ATR lookback) * chop multiple
Long: T1 net profit change > -loss limit AND demand zone exists AND low <= demand top AND close > demand top AND ((low < Lowest(low, sweep lookback)[1] AND close > Lowest(low, sweep lookback)[1]) OR (low < low[1] AND close > open)) AND close > open AND close - open > ATR(ATR lookback) * displacement multiple AND close > EMA(close, EMA lookback) AND Recent range > ATR(ATR lookback) * chop multiple AND position side is flat or short AND Long risk > minimum tick size
Short: T1 net profit change > -loss limit AND supply zone exists AND high >= supply bottom AND close < supply bottom AND ((high > Highest(high, sweep lookback)[1] AND close < Highest(high, sweep lookback)[1]) OR (high > high[1] AND close < open)) AND close < open AND open - close > ATR(ATR lookback) * displacement multiple AND close < EMA(close, EMA lookback) AND Recent range > ATR(ATR lookback) * chop multiple
Short: T1 net profit change > -loss limit AND supply zone exists AND high >= supply bottom AND close < supply bottom AND ((high > Highest(high, sweep lookback)[1] AND close < Highest(high, sweep lookback)[1]) OR (high > high[1] AND close < open)) AND close < open AND open - close > ATR(ATR lookback) * displacement multiple AND close < EMA(close, EMA lookback) AND Recent range > ATR(ATR lookback) * chop multiple AND position side is flat or long AND Short risk > minimum tick size
Exit: long, low <= Long stop OR high >= Long target OR T1 net profit change <= -loss limit
Exit: short, high >= Short stop OR low <= Short target OR T1 net profit change <= -loss limit