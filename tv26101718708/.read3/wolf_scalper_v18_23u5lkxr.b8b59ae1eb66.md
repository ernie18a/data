Calculation: bullish sweep = a latest confirmed PivotLow(low, sweep lookback, sweep lookback) exists, low < that pivot, close > that pivot, and (min(open, close) - low) / (high - low) > minimum wick fraction
Calculation: bearish sweep = a latest confirmed PivotHigh(high, sweep lookback, sweep lookback) exists, high > that pivot, close < that pivot, and (high - max(open, close)) / (high - low) > minimum wick fraction
Calculation: bullish SMT = a newly confirmed PivotLow(low, SMT lookback, SMT lookback) is below the preceding confirmed PivotLow and at least one reference instrument's low on the corresponding chart-timeframe pivot bar is above its low on the preceding pivot bar
Calculation: bearish SMT = a newly confirmed PivotHigh(high, SMT lookback, SMT lookback) is above the preceding confirmed PivotHigh and at least one reference instrument's high on the corresponding chart-timeframe pivot bar is below its high on the preceding pivot bar
Calculation: bullish CISD = close > close[1] AND close[1] > close[2] AND the prior CISD label direction is not bullish AND bars since the prior CISD label >= minimum CISD interval AND the chart bar is confirmed
Calculation: bearish CISD = close < close[1] AND close[1] < close[2] AND the prior CISD label direction is not bearish AND bars since the prior CISD label >= minimum CISD interval AND the chart bar is confirmed
Calculation: bullish CHoCH = close > latest confirmed PivotHigh(high, CHoCH lookback, CHoCH lookback) AND current trend direction is not bullish
Calculation: bearish CHoCH = close < latest confirmed PivotLow(low, CHoCH lookback, CHoCH lookback) AND current trend direction is not bearish
Calculation: bullish FVG = low > high[2] AND low - high[2] >= minimum tick size × minimum FVG ticks
Calculation: bearish FVG = high < low[2] AND low[2] - high >= minimum tick size × minimum FVG ticks
Calculation: bullish IFVG inversion = close > the upper boundary of a retained, non-inverted bearish FVG
Calculation: bearish IFVG inversion = close < the lower boundary of a retained, non-inverted bullish FVG
Calculation: bullish IFVG overlap = the current bar's range overlaps a retained inverted bearish FVG
Calculation: bearish IFVG overlap = the current bar's range overlaps a retained inverted bullish FVG
Calculation: bullish order block = close > high[1] AND close - open > ATR(short lookback) × bullish OB displacement multiple AND abs(close[1] - open[1]) <= ATR(short lookback) × maximum OB body size
Calculation: bearish order block = close < low[1] AND open - close > ATR(short lookback) × bearish OB displacement multiple AND abs(close[1] - open[1]) <= ATR(short lookback) × maximum OB body size
Calculation: bullish OB overlap = the current bar's range overlaps a retained bullish order block formed from the prior bar's body
Calculation: bearish OB overlap = the current bar's range overlaps a retained bearish order block formed from the prior bar's body
Calculation: displacement passes = displacement filter disabled OR abs(close - open) > ATR(short lookback) × displacement multiple
Calculation: chop filter passes = chop filter disabled OR ATR(short lookback) > ATR(long lookback) × minimum ATR ratio
Calculation: volume filter passes = volume filter disabled OR volume > SMA(volume, volume lookback) × volume multiple
Calculation: premium = close > (Highest(high, premium lookback) + (Highest(high, premium lookback) + Lowest(low, premium lookback)) / 2) / 2
Calculation: discount = close < ((Highest(high, premium lookback) + Lowest(low, premium lookback)) / 2 + Lowest(low, premium lookback)) / 2
Calculation: bullish confirmed setup = (sweep pattern enabled AND bullish sweep AND close > open AND displacement passes AND (no confirmed sweep pivot low exists OR close - latest confirmed sweep pivot low <= ATR(short lookback) × maximum entry distance)) OR (iFVG pattern enabled AND bullish IFVG overlap AND close > open AND displacement passes) OR (bullish OB overlap AND close > open AND displacement passes)
Calculation: bearish confirmed setup = (sweep pattern enabled AND bearish sweep AND close < open AND displacement passes AND (no confirmed sweep pivot high exists OR latest confirmed sweep pivot high - close <= ATR(short lookback) × maximum entry distance)) OR (iFVG pattern enabled AND bearish IFVG overlap AND close < open AND displacement passes) OR (bearish OB overlap AND close < open AND displacement passes)
Calculation: bullish confluence count = I(bullish confirmed setup) + I(BarsSince(bullish SMT) <= SMT recent window) + I(BarsSince(bullish sweep) <= sweep recent window) + I(bullish CHoCH OR current trend direction is bullish) + I(bullish FVG overlap OR bullish IFVG overlap OR bullish OB overlap) + I(bullish CISD) + I(discount) + I(close > stored New York open)
Calculation: bearish confluence count = I(bearish confirmed setup) + I(BarsSince(bearish SMT) <= SMT recent window) + I(BarsSince(bearish sweep) <= sweep recent window) + I(bearish CHoCH OR current trend direction is bearish) + I(bearish FVG overlap OR bearish IFVG overlap OR bearish OB overlap) + I(bearish CISD) + I(premium) + I(close < stored New York open)
Long: bullish sweep AND chart bar confirmed
Short: bearish sweep AND chart bar confirmed
Long: bullish SMT
Short: bearish SMT
Long: bullish CISD
Short: bearish CISD
Long: bullish CHoCH
Short: bearish CHoCH
Long: bullish FVG AND chart bar confirmed
Short: bearish FVG AND chart bar confirmed
Long: bullish IFVG inversion
Short: bearish IFVG inversion
Long: bullish order block AND chart bar confirmed
Short: bearish order block AND chart bar confirmed
Long: (sweep pattern enabled AND latest confirmed sweep pivot low exists AND low < that pivot OR iFVG pattern enabled AND bullish IFVG overlap OR SMT pattern enabled AND bullish SMT) AND chop filter passes AND more than the early-signal cooldown bars since the prior early long mark AND current bar is realtime
Short: (sweep pattern enabled AND latest confirmed sweep pivot high exists AND high > that pivot OR iFVG pattern enabled AND bearish IFVG overlap OR SMT pattern enabled AND bearish SMT) AND chop filter passes AND more than the early-signal cooldown bars since the prior early short mark AND current bar is realtime
Long: bullish confirmed setup AND bullish confluence count >= A++ minimum confluences AND (strict-session gate disabled OR current time is in an enabled New York morning, New York afternoon, or London session window) AND chop filter passes AND volume filter passes AND (premium blocking disabled OR NOT premium) AND more than the signal-cooldown bars since the prior marked long B or A++ setup AND chart bar confirmed
Short: bearish confirmed setup AND bearish confluence count >= A++ minimum confluences AND (strict-session gate disabled OR current time is in an enabled New York morning, New York afternoon, or London session window) AND chop filter passes AND volume filter passes AND (premium/discount blocking disabled OR NOT discount) AND more than the signal-cooldown bars since the prior marked short B or A++ setup AND chart bar confirmed
Long: bullish confirmed setup AND bullish confluence count >= B minimum confluences AND bullish confluence count < A++ minimum confluences AND chop filter passes AND more than the signal-cooldown bars since the prior marked long B or A++ setup AND chart bar confirmed
Short: bearish confirmed setup AND bearish confluence count >= B minimum confluences AND bearish confluence count < A++ minimum confluences AND chop filter passes AND more than the signal-cooldown bars since the prior marked short B or A++ setup AND chart bar confirmed