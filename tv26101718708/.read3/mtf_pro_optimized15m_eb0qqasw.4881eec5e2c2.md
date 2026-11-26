Calculation: Strong-body fraction = abs(close - open) / max(high - low, minimum tick increment)
Calculation: Long setup high = high of the latest flat chart bar satisfying close(T1) > EMA(close, shared EMA lookback, T1) AND close(T2) > EMA(close, shared EMA lookback, T2) AND close > EMA(close, shared EMA lookback, chart timeframe) AND RSI(close, RSI lookback) > RSI threshold AND strong-body fraction > strong-body-fraction threshold AND close crosses above EMA(close, shared EMA lookback, chart timeframe); T1 is longer than T2, both requested onto chart bars with lookahead off (last completed bar historically, still-forming bar in realtime); replace on each newer qualifying bar and retain until a long entry
Calculation: Short setup low = low of the latest flat chart bar satisfying close(T1) < EMA(close, shared EMA lookback, T1) AND close(T2) < EMA(close, shared EMA lookback, T2) AND close < EMA(close, shared EMA lookback, chart timeframe) AND RSI(close, RSI lookback) < RSI threshold AND strong-body fraction > strong-body-fraction threshold AND close crosses below EMA(close, shared EMA lookback, chart timeframe); T1 is longer than T2, both requested onto chart bars with lookahead off (last completed bar historically, still-forming bar in realtime); replace on each newer qualifying bar and retain until a short entry
Long: Flat at chart-bar start AND long setup high exists AND high > long setup high
Short: Flat at chart-bar start AND short setup low exists AND low < short setup low
Calculation: Long initial stop = low of the chart bar immediately before the long setup bar
Calculation: Long initial risk = entry price - long initial stop
Calculation: Long stop = long initial stop until any chart-bar high since entry reaches entry price + long initial risk × breakeven-risk multiple; thereafter entry price
Calculation: Long target = entry price + long initial risk × reward/risk multiple
Calculation: Short initial stop = high of the chart bar immediately before the short setup bar
Calculation: Short initial risk = short initial stop - entry price
Calculation: Short stop = short initial stop until any chart-bar low since entry reaches entry price - short initial risk × breakeven-risk multiple; thereafter entry price
Calculation: Short target = entry price - short initial risk × reward/risk multiple
Exit: Long, low <= long stop OR high >= long target
Exit: Short, high >= short stop OR low <= short target