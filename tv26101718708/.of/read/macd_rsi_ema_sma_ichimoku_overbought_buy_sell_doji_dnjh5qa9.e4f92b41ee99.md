Calculation: A[n] = the value of A n chart bars ago; n = 0 means the current bar.
Calculation: SMA MACD = short-period SMA(source) − longer-period SMA(source); its signal = SMA(SMA MACD); its histogram = SMA MACD − signal.
Calculation: EMA spread = short-period EMA(close) − longer-period EMA(close).
Calculation: Candle body B = close − open; absolute body M = abs(B); upper wick U = high − max(open, close); lower wick L = min(open, close) − low.
Calculation: Smoothed PPO D = SMA(100 × (short-period EMA(source) − longer-period EMA(source)) / longer-period EMA(source)).
Calculation: Oscillator trough = D[1] < D[0] AND D[1] < D[2]; oscillator peak = D[1] > D[0] AND D[1] > D[2].
Calculation: Price trough = low[1] < low[0] AND low[1] < low[2], OR low[1] = low[2] AND low[1] < low[0] AND low[1] < low[3], OR low[1] = low[2] AND low[1] = low[3] AND low[1] < low[0] AND low[1] < low[4], OR low[1] = low[2] AND low[1] = low[3] AND low[1] != 0 AND low[1] = low[4] AND low[1] < low[0] AND low[1] < low[5].
Calculation: Price peak = high[1] > high[0] AND high[1] > high[2], OR high[1] = high[2] AND high[1] > high[0] AND high[1] > high[3], OR high[1] = high[2] AND high[1] = high[3] AND high[1] > high[0] AND high[1] > high[4], OR high[1] = high[2] AND high[1] = high[3] AND high[1] != 0 AND high[1] = high[4] AND high[1] > high[0] AND high[1] > high[5].
Calculation: Latest price trough or peak = low[1] or high[1] at the most recent corresponding price trough or peak. Latest and previous oscillator troughs or peaks = D[1] at the most recent and second-most-recent corresponding oscillator events.
Calculation: Delayed price trough = low[1] on a price trough less than 3 bars after an oscillator trough; delayed price peak = high[1] on a price peak less than 3 bars after an oscillator peak. Otherwise each is unavailable.
Calculation: Trough filter = lowest latest price trough over the last 4 bars when the latest price trough occurred less than 5 bars ago; peak filter = highest latest price peak over the last 4 bars when the latest price peak occurred less than 5 bars ago. Otherwise each is unavailable. Previous oscillator trough price filter and previous oscillator peak price filter are the respective filter values at the second-most-recent oscillator trough and peak.
Calculation: Long-lookback trough reference = lowest low over a long lookback, sampled at the second-most-recent price trough; long-lookback peak reference = highest high over the same lookback, sampled at the second-most-recent price peak.
Calculation: Heikin-Ashi close = (open + high + low + close) / 4; Heikin-Ashi open = average of the preceding Heikin-Ashi open and close; Heikin-Ashi high = max(high, Heikin-Ashi open, Heikin-Ashi close); Heikin-Ashi low = min(low, Heikin-Ashi open, Heikin-Ashi close). Initialize the first Heikin-Ashi open as (open + close) / 2.
Calculation: Pattern candles are either chart OHLC or Heikin-Ashi OHLC. Pattern range = pattern high − pattern low; pattern body = abs(pattern close − pattern open). A small-wick-balanced body has pattern body < pattern range × body-fraction threshold AND pattern high − max(pattern open, pattern close) > pattern range × wick-fraction threshold AND min(pattern open, pattern close) − pattern low > pattern range × wick-fraction threshold; body-fraction threshold = 1 − 2 × wick-fraction threshold.
Calculation: Prior bearish candles = each candle in the selected consecutive prior-candle lookback has pattern open > pattern close; prior bullish candles = each has pattern open < pattern close. Prior size passes when the minimum body-size filter is disabled OR every candle in that lookback has pattern body > the minimum body size.
Calculation: Bullish contained doji = pattern open[1] >= max(pattern open, pattern close) AND pattern close[1] <= min(pattern open, pattern close) AND prior size passes AND small-wick-balanced body. Bearish contained doji = pattern close[1] >= max(pattern open, pattern close) AND pattern open[1] <= min(pattern open, pattern close) AND prior size passes AND small-wick-balanced body.
Calculation: Bullish harami = bullish contained doji AND prior bearish candles AND (pattern open <= pattern close OR pattern body < half a minimum price increment). Bearish harami = bearish contained doji AND prior bullish candles AND (pattern open >= pattern close OR pattern body < half a minimum price increment).
Long: RSI(close) <= oversold entry threshold AND close >= long-period SMA(close) AND short-period EMA(close) != 0.
Short: RSI(close) >= overbought entry threshold AND close <= long-period SMA(close) AND longer-period EMA(close) != 0.
Exit: long, RSI(close) >= overbought exit threshold AND longer-period EMA(close) != 0.
Exit: short, low <= shorter-period EMA(close) AND RSI(close) <= oversold exit threshold.
Exit: long, take-profit enabled AND high >= entry price + take-profit distance OR stop-loss enabled AND low <= entry price − stop-loss distance OR trailing stop enabled AND high since entry reaches entry price + activation distance AND low <= highest high since trailing activation − trailing offset.
Exit: short, take-profit enabled AND low <= entry price − take-profit distance OR stop-loss enabled AND high >= entry price + stop-loss distance OR trailing stop enabled AND low since entry reaches entry price − activation distance AND high >= lowest low since trailing activation + trailing offset.
Long: long-period SMA(source) > its preceding value.
Short: long-period SMA(source) <= its preceding value.
Long: short-period SMA(source) > medium-period SMA(source) AND long-period SMA(source) > its preceding value AND close > medium-period SMA(source).
Short: short-period SMA(source) < medium-period SMA(source) AND long-period SMA(source) < its preceding value AND close < medium-period SMA(source).
Long: close > short-period SMA(source) AND close > medium-period SMA(source) AND close > long-period SMA(source) AND medium-period SMA(source) > its preceding value.
Short: close < short-period SMA(source) AND close < medium-period SMA(source) AND close < long-period SMA(source) AND medium-period SMA(source) < its preceding value.
Long: medium-period SMA(source) > long-period SMA(source) AND SMA MACD histogram crosses above zero AND SMA MACD > 0 AND short-period SMA(source) > medium-period SMA(source) AND close at the medium SMA lookback offset > current long-period SMA(source).
Short: medium-period SMA(source) < long-period SMA(source) AND SMA MACD histogram crosses below zero AND SMA MACD < 0 AND short-period SMA(source) < medium-period SMA(source) AND close at the medium SMA lookback offset < current long-period SMA(source).
Long: RSI(close) <= oversold threshold AND RSI(close)[1] <= oversold threshold AND volume[1] >= volume.
Short: RSI(close) >= overbought threshold AND RSI(close)[1] >= overbought threshold AND volume[1] >= volume.
Long: EMA spread > EMA spread[1].
Short: EMA spread <= EMA spread[1].
Long: B > −2 × B[1] AND B[1] < 0 AND B > 0 AND B[2] < 0.
Short: −B > 2 × B[1] AND B[1] > 0 AND B < 0 AND B[2] > 0.
Long: 10 × B < M AND high − low > 10 × M AND B[1] < 0.
Short: 10 × B < M AND high − low > 10 × M AND B[1] > 0.
Long: 10 × B < M AND 10 × L < M AND U > 5 × M AND B[1] < 0.
Short: 10 × B < M AND 10 × U < M AND L > 5 × M AND B[1] > 0.
Long: B > 2 × M AND B[1] > 2 × M[1] AND B[2] > 2 × M[2] AND B >= 0.
Short: 2 × B < M AND high − low > 10 × M AND B[1] > 0.
Calculation: Ichimoku midpoint for a lookback = (highest high + lowest low) / 2 over that lookback. Leading span A = average of the shorter-lookback and medium-lookback midpoints; leading span B = the longer-lookback midpoint.
Long: leading span A >= leading span B.
Short: leading span A < leading span B.
Long: low[2] < low AND low[2] < low[1] AND low[2] < low[3] AND low[2] < low[4] AND high[1] < max(high[3], high[2]) AND high > max(high[3], high[2]).
Long: low[1] < low AND low[1] < low[2] AND low[1] < low[3] AND high > max(high[2], high[1]).
Short: high[2] > high AND high[2] >= high[1] AND high[2] > high[3] AND high[2] > high[4] AND low[1] > min(low[3], low[2]) AND low < min(low[3], low[2]).
Short: high[1] > high AND high[1] > high[2] AND high[1] > high[3] AND low < min(low[2], low[1]).
Long: oscillator trough AND latest price trough < previous oscillator trough price filter AND latest oscillator trough > previous oscillator trough.
Long: delayed price trough < previous oscillator trough price filter AND latest oscillator trough > previous oscillator trough.
Long: long-term divergence enabled AND oscillator trough AND latest oscillator trough > lowest D over the long lookback AND latest price trough < long-lookback trough reference.
Long: long-term divergence enabled AND latest oscillator trough > lowest D over the long lookback AND delayed price trough < long-lookback trough reference.
Short: oscillator peak AND latest price peak > previous oscillator peak price filter AND latest oscillator peak < previous oscillator peak.
Short: delayed price peak > previous oscillator peak price filter AND latest oscillator peak < previous oscillator peak.
Short: long-term divergence enabled AND oscillator peak AND latest oscillator peak < highest D over the long lookback AND latest price peak > long-lookback peak reference.
Short: long-term divergence enabled AND latest oscillator peak < highest D over the long lookback AND delayed price peak > long-lookback peak reference.
Long: oscillator trough AND D[1] != 0.
Short: oscillator peak AND D[1] != 0.
Long: close > EMA(close) AND low <= EMA(close) AND open > EMA(close) OR open < EMA(close) AND close > EMA(close).
Short: close < EMA(close) AND high >= EMA(close) AND open < EMA(close) OR open > EMA(close) AND close < EMA(close).
Long: bullish harami OR bullish contained doji AND prior bearish candles AND bullish harami is false AND bearish harami is false AND harami-only mode is disabled.
Short: bearish harami OR bearish contained doji AND prior bullish candles AND bullish harami is false AND bearish harami is false AND harami-only mode is disabled.