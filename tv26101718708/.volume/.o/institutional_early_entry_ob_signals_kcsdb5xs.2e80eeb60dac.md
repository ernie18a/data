Calculation: Previous structure high/low = highest high / lowest low over the longer structure lookback, excluding the current bar
Calculation: Bullish/bearish structure break = current close > previous structure high / < previous structure low
Calculation: Bullish/bearish order block = high and low of the latest bearish/bullish candle, captured when a bullish/bearish structure break occurs
Calculation: Active order block = latest structure break's order block, while its break is no more than the order block validity lookback bars ago; it is inactive if a newer opposite break occurred
Calculation: Bullish/bearish order block retest = current bar overlaps the active bullish/bearish order block range
Calculation: Order block midpoint = average of its high and low
Calculation: EMA trend confirmation = aggressive: close above/below the shorter EMA; balanced: shorter EMA above/below the longer EMA and close above/below the shorter EMA; conservative: balanced conditions and shorter EMA rising/falling
Calculation: Volume confirmation = volume exceeds its moving average times a multiplier, or volume confirmation is disabled
Calculation: Stochastic confirmation = disabled, or smoothed stochastic K > D or K > 50 for long; K < D or K < 50 for short
Calculation: Long/short signal = respective order block retest AND EMA trend confirmation AND RSI above the buy threshold / below the sell threshold AND volume confirmation AND stochastic confirmation for confirmed signals; early signals omit stochastic confirmation and rejection
Calculation: Long/short rejection = close > open OR close > bullish midpoint / close < open OR close < bearish midpoint
Calculation: Long stop/target = bullish order block low minus ATR buffer / signal-bar close plus the distance from close to stop times the risk-reward ratio
Calculation: Short stop/target = bearish order block high plus ATR buffer / signal-bar close minus the distance from stop to close times the risk-reward ratio
Long: early long signal AND NOT confirmed long signal OR confirmed long signal AND previous bar had no confirmed long signal AND close minus long stop exceeds minimum tick
Short: early short signal AND NOT confirmed short signal OR confirmed short signal AND previous bar had no confirmed short signal AND short stop minus close exceeds minimum tick
Exit: long, latest valid entry is long AND (low <= its stored stop OR high >= its stored target)
Exit: short, latest valid entry is short AND (high >= its stored stop OR low <= its stored target)