Calculation: Strong trend = fast EMA > medium EMA > slow EMA, or fast EMA < medium EMA < slow EMA; the three EMA lookbacks are ordered short to long
Calculation: AI confidence = min(100, trend score + ADX score + RSI score + MACD score + relative-volume score + MFI score + CCI score + momentum score), where trend score is 20 for a strong trend and 0 otherwise; ADX score is min(ADX / 40 × 15, 15); RSI score is 12 when aligned with trend and between 50 and 70 for an uptrend or between 30 and 50 for a downtrend, otherwise 6 (also 6 with no trend); MACD score is 12 when its line is aligned with trend, otherwise 4; relative-volume score is 12 above 2, 10 above 1.5, 7 above 1, otherwise 4; MFI score is 10 when above 50 in an uptrend or below 50 in a downtrend, otherwise 5; CCI score is 10 when above 0 in an uptrend or below 0 in a downtrend, otherwise 4 (5 with no trend); momentum score is 9 when momentum is aligned with trend, otherwise 3
Calculation: Multi-timeframe trend agreement = the greater of the count of configured timeframes where fast EMA is above slow EMA and the count where fast EMA is below slow EMA; configured timeframes may be higher or lower than the chart timeframe, and use the bar still forming
Calculation: Trailing level = initialize to close; on each bar, if close is above the prior trailing level, take the maximum of that level and close minus ATR × trail factor; otherwise take the minimum of that level and close plus ATR × trail factor
Calculation: Pivot swing high/low = high/low that is greater/less than the highs/lows of the five bars before and after it; recognize it after those five later bars complete
Calculation: Bollinger upper/lower band = 20-bar simple moving average of close plus/minus 2.2 standard deviations
Calculation: Average candle body = 20-bar simple moving average of absolute close minus open
Calculation: Bullish order block = prior bar closes below its open, current bar closes above its open and above prior high, and current body exceeds 1.5 times average candle body; bearish order block is the inverse using prior green bar, current close below prior low, and current body exceeds 1.5 times average candle body
Calculation: Bullish fair value gap = current low > high two bars earlier and current close > open; bearish fair value gap = current high < low two bars earlier and current close < open
Long: fast EMA crosses above medium EMA AND (strong trend is not bearish) AND RSI > 45 AND close > trailing level AND AI confidence ≥ 70 AND multi-timeframe trend agreement ≥ 3
Long: fast EMA crosses above medium EMA AND AI confidence ≥ minimum confidence AND premium-long condition is false
Long: close ≤ lower Bollinger band AND RSI < 30 AND close crosses above lower Bollinger band AND AI confidence ≥ minimum confidence
Long: absolute close minus open > 2 × average candle body AND volume > 1.3 × 20-bar average volume AND close > open
Long: bullish order block
Long: bullish fair value gap AND gap size > 0.2 × ATR
Long: a confirmed pivot swing high exceeds the preceding confirmed pivot swing high, or a confirmed pivot swing low exceeds the preceding confirmed pivot swing low
Long: close crosses above the last confirmed pivot swing high
Long: all six ribbon EMAs are strictly descending by lookback from shortest to longest in value order (shortest EMA > next EMA > … > longest EMA)
Short: fast EMA crosses below medium EMA AND (strong trend is not bullish) AND RSI < 55 AND close < trailing level AND AI confidence ≥ 70 AND multi-timeframe trend agreement ≥ 3
Short: fast EMA crosses below medium EMA AND AI confidence ≥ minimum confidence AND premium-short condition is false
Short: close ≥ upper Bollinger band AND RSI > 70 AND close crosses below upper Bollinger band AND AI confidence ≥ minimum confidence
Short: absolute close minus open > 2 × average candle body AND volume > 1.3 × 20-bar average volume AND close < open
Short: bearish order block
Short: bearish fair value gap AND gap size > 0.2 × ATR
Short: a confirmed pivot swing high is below the preceding confirmed pivot swing high, or a confirmed pivot swing low is below the preceding confirmed pivot swing low
Short: close crosses below the last confirmed pivot swing low
Short: all six ribbon EMAs are strictly ascending by lookback from shortest to longest in value order (shortest EMA < next EMA < … < longest EMA)
Exit: long, low ≤ entry price − ATR at entry × stop-loss factor
Exit: short, high ≥ entry price + ATR at entry × stop-loss factor