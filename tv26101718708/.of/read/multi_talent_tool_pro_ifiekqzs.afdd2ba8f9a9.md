Calculation: body = abs(close - open)
Calculation: upper_wick = high - max(open, close)
Calculation: lower_wick = min(open, close) - low
Calculation: HTF bar = bar of a timeframe higher than the chart timeframe; HTF[0] is the still-forming bar, HTF[2] is the bar two bars before it
Long: fast EMA(close) crosses above slow EMA(close) (fast lookback shorter than slow lookback)
Long: body > 0 AND lower_wick >= k1 * body AND upper_wick <= k2 * body (k1 > 1 > k2 > 0)
Long: previous bar close < previous bar open AND close > open AND close >= previous open AND open <= previous close AND (close - open) > (previous open - previous close)
Long: HTF[0] close >= HTF[2] open
Short: fast EMA(close) crosses below slow EMA(close) (fast lookback shorter than slow lookback)
Short: body > 0 AND upper_wick >= k1 * body AND lower_wick <= k2 * body (k1 > 1 > k2 > 0)
Short: previous bar close > previous bar open AND close < open AND open >= previous close AND close <= previous open AND (open - close) > (previous close - previous open)
Short: HTF[0] close < HTF[2] open