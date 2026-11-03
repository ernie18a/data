Calculation: AI confidence = capped sum of scores for trend-stack strength, ADX strength, RSI alignment with fast/slow EMA direction, MACD alignment with that direction, relative volume, MFI alignment, CCI alignment, and momentum versus its EMA; each factor’s score follows its direction-specific thresholds.
Calculation: Quantum trailing stop = initialize at close; each bar, if close is above the prior stop, set stop to the greater of the prior stop and close minus ATR; otherwise set it to the lesser of the prior stop and close plus ATR. ATR lookback and multiplier are parameters.
Calculation: Higher/lower-timeframe trend count = number of the four selected timeframes whose fast EMA is above (bullish count) or below (bearish count) its slow EMA. Aggregate base bars to each selected timeframe and use its bar still forming.
Calculation: RSI divergence = at a confirmed RSI pivot low, bullish when its RSI value is higher than the preceding RSI pivot low, its corresponding price low is lower, and RSI is below its oversold threshold; at a confirmed RSI pivot high, bearish when its RSI value is lower than the preceding RSI pivot high, its corresponding price high is higher, and RSI is above its overbought threshold.
Long: fast EMA crosses above slow EMA AND RSI > oversold-entry threshold AND close > Quantum trailing stop AND AI confidence >= premium threshold AND (bullish higher/lower-timeframe trend count >= confirmation threshold OR bearish higher/lower-timeframe trend count >= confirmation threshold)
Long: fast EMA crosses above slow EMA AND AI confidence >= standard threshold AND NOT (RSI > oversold-entry threshold AND close > Quantum trailing stop AND AI confidence >= premium threshold AND (bullish higher/lower-timeframe trend count >= confirmation threshold OR bearish higher/lower-timeframe trend count >= confirmation threshold))
Long: close <= lower Bollinger Band AND RSI < oversold threshold AND close crosses above lower Bollinger Band AND AI confidence >= standard threshold
Long: absolute(close - open) > average absolute candle body AND volume > average volume AND close > open
Long: bullish RSI divergence
Long: fast EMA > medium EMA > slow EMA > slower EMA > longer EMA > longest EMA
Long: fast EMA > slow EMA
Long: previous candle is bearish AND current candle is bullish AND close > previous high AND current candle body > average candle body
Long: low > high from two bars earlier AND close > open AND lower Bollinger Band gap > ATR-scaled minimum
Long: confirmed swing high > preceding confirmed swing high OR confirmed swing low > preceding confirmed swing low
Long: close crosses above the latest confirmed swing high
Short: fast EMA crosses below slow EMA AND RSI < overbought-entry threshold AND close < Quantum trailing stop AND AI confidence >= premium threshold AND (bearish higher/lower-timeframe trend count >= confirmation threshold OR bullish higher/lower-timeframe trend count >= confirmation threshold)
Short: fast EMA crosses below slow EMA AND AI confidence >= standard threshold AND NOT (RSI < overbought-entry threshold AND close < Quantum trailing stop AND AI confidence >= premium threshold AND (bearish higher/lower-timeframe trend count >= confirmation threshold OR bullish higher/lower-timeframe trend count >= confirmation threshold))
Short: close >= upper Bollinger Band AND RSI > overbought threshold AND close crosses below upper Bollinger Band AND AI confidence >= standard threshold
Short: absolute(close - open) > average absolute candle body AND volume > average volume AND close < open
Short: bearish RSI divergence
Short: fast EMA < medium EMA < slow EMA < slower EMA < longer EMA < longest EMA
Short: fast EMA < slow EMA
Short: previous candle is bullish AND current candle is bearish AND close < previous low AND current candle body > average candle body
Short: high < low from two bars earlier AND close < open AND upper Bollinger Band gap > ATR-scaled minimum
Short: confirmed swing high < preceding confirmed swing high OR confirmed swing low < preceding confirmed swing low
Short: close crosses below the latest confirmed swing low
Exit: long, low <= entry price - ATR at entry * stop-loss multiplier
Exit: short, high >= entry price + ATR at entry * stop-loss multiplier