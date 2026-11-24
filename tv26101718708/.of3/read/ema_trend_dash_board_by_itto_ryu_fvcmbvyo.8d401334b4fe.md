Calculation: Bull EMA-pair count = sum of EMA(close, fast lookback) > EMA(close, next-shortest lookback), EMA(close, next-shortest lookback) > EMA(close, trend lookback), EMA(close, trend lookback) > EMA(close, next-longest lookback), and EMA(close, next-longest lookback) > EMA(close, longest lookback), with fast lookback < next-shortest lookback < trend lookback < next-longest lookback < longest lookback
Calculation: Bear EMA-pair count = sum of EMA(close, fast lookback) < EMA(close, next-shortest lookback), EMA(close, next-shortest lookback) < EMA(close, trend lookback), EMA(close, trend lookback) < EMA(close, next-longest lookback), and EMA(close, next-longest lookback) < EMA(close, longest lookback)
Calculation: Price-above count = count of the five EMAs below close
Calculation: Trend EMA percent slope = if EMA(close, trend lookback)[n bars ago] is zero then zero, otherwise 100 × (EMA(close, trend lookback) − EMA(close, trend lookback)[n bars ago]) / EMA(close, trend lookback)[n bars ago]
Calculation: Trend EMA slope is rising = trend EMA percent slope > 0 AND absolute trend EMA percent slope >= trend-slope flat threshold
Calculation: Trend EMA slope is falling = trend EMA percent slope < 0 AND absolute trend EMA percent slope >= trend-slope flat threshold
Calculation: Gap percentage = if EMA(close, trend lookback) is zero then zero, otherwise 100 × (EMA(close, fast lookback) − EMA(close, trend lookback)) / EMA(close, trend lookback)
Calculation: Gap change = absolute gap percentage − absolute gap percentage[n bars ago]
Calculation: Gap is expanding = gap change > gap-momentum threshold
Calculation: Gap is compressing = gap change < −gap-momentum threshold
Calculation: Bull stack = bull EMA-pair count >= stack-alignment threshold
Calculation: Bear stack = bear EMA-pair count >= stack-alignment threshold
Calculation: Bull score = price-above count × price-position weight + bull EMA-pair count × pair-order weight + (trend EMA slope is rising ? slope weight : 0) + (gap is expanding AND bull stack ? gap-expansion weight : 0)
Calculation: Bear score = (five − price-above count) × price-position weight + bear EMA-pair count × pair-order weight + (trend EMA slope is falling ? slope weight : 0) + (gap is expanding AND bear stack ? gap-expansion weight : 0)
Calculation: Strong bull signal = bull score >= strong-score threshold AND bull stack
Calculation: Clear bull signal = bull score >= clear-signal threshold AND price-above count >= required-above count AND NOT strong bull signal
Calculation: Weak bull signal = bull score > bear score AND bull score >= weak-score threshold AND NOT strong bull signal AND NOT clear bull signal
Calculation: Strong bear signal = bear score >= strong-score threshold AND bear stack
Calculation: Clear bear signal = bear score >= clear-signal threshold AND (five − price-above count) >= required-below count AND NOT strong bear signal
Calculation: Weak bear signal = bear score > bull score AND bear score >= weak-score threshold AND NOT strong bear signal AND NOT clear bear signal
Calculation: Last aligned stack direction = bullish when bull stack, bearish when bear stack, otherwise retain the most recent non-neutral direction
Calculation: Bullish higher-timeframe trend = bull stack AND price-above count >= required-above count AND trend EMA slope is rising
Calculation: Bearish higher-timeframe trend = bear stack AND (five − price-above count) >= required-below count AND trend EMA slope is falling
Long: strong bull signal OR clear bull signal OR weak bull signal
Short: strong bear signal OR clear bear signal OR weak bear signal
Long: bull score >= bear score
Short: bull score < bear score
Long: bull stack
Short: bear stack
Long: bull stack AND price-above count >= required-above count AND trend EMA slope is rising
Short: bear stack AND (five − price-above count) >= required-below count AND trend EMA slope is falling
Long: close > EMA(close, fast lookback)
Short: EMA(close, fast lookback) crosses below EMA(close, trend lookback)
Long: EMA(close, fast lookback) crosses above EMA(close, trend lookback)
Long: gap is expanding
Short: gap is compressing
Long: trend EMA slope is rising
Short: trend EMA slope is falling
Long: EMA(close, longest lookback) percent slope over n bars is > 0 AND its absolute value >= long-EMA slope flat threshold
Short: EMA(close, longest lookback) percent slope over n bars is < 0 AND its absolute value >= long-EMA slope flat threshold
Long: bull stack AND ((close crosses above EMA(close, fast lookback) AND bars since the most recent bull-stack bar with low <= EMA(close, next-shortest lookback) <= pullback maximum bars) OR (low <= EMA(close, next-shortest lookback) AND close > EMA(close, fast lookback) AND close >= open)) AND the same raw condition was false on the previous bar
Short: bear stack AND ((close crosses below EMA(close, fast lookback) AND bars since the most recent bear-stack bar with high >= EMA(close, next-shortest lookback) <= pullback maximum bars) OR (high >= EMA(close, next-shortest lookback) AND close < EMA(close, fast lookback) AND close <= open)) AND the same raw condition was false on the previous bar
Long: EMA(close, trend lookback) crosses above EMA(close, longest lookback)
Short: EMA(close, trend lookback) crosses below EMA(close, longest lookback)
Long: on chart bars, for any enabled T1, T2, or T3 greater than the chart timeframe, bullish higher-timeframe trend using that timeframe's last completed bar when closed-bars-only is enabled, otherwise its still-forming bar
Short: on chart bars, for any enabled T1, T2, or T3 greater than the chart timeframe, bearish higher-timeframe trend using that timeframe's last completed bar when closed-bars-only is enabled, otherwise its still-forming bar
Long: bull stack AND gap is compressing AND bull score >= bear score
Short: bear stack AND gap is compressing AND bull score < bear score
Exit: long, neither stack is aligned AND last aligned stack direction is bullish AND bull score >= bear score AND bull score >= weak-score threshold AND bull score < clear-signal threshold
Exit: short, neither stack is aligned AND last aligned stack direction is bearish AND bull score < bear score AND bear score >= weak-score threshold AND bear score < clear-signal threshold
Long: neither stack is aligned AND last aligned stack direction is not bullish AND bull score >= bear score AND bull score >= weak-score threshold
Short: neither stack is aligned AND last aligned stack direction is not bearish AND bull score < bear score AND bear score >= weak-score threshold