Calculation: Session VWAP = cumulative sum of ((high + low + close) / 3 × volume) divided by cumulative volume, reset at the selected session start, updated during that session, and held constant outside it; the selectable sessions are London 03:00–11:00 or New York 09:30–16:00 in the exchange timezone.
Calculation: Rolling base = the most recently recorded highest high and lowest low over a rolling lookback, updated before testing breakouts whenever (highest high − lowest low) < compression factor × sum of bar ranges over that lookback AND sum of volume over that lookback > volume factor × SMA of volume over a separate, longer lookback × rolling lookback length.
Calculation: Previous New York session = the most recently completed regular session in America/New_York, from 09:30 to 16:00; its open is the first session bar's open, close is the last session bar's close, high and low are the session extremes, and volume is the sum of session-bar volumes. Update these values on the first bar outside the session.
Calculation: Previous session base = previous New York session range > 0 AND absolute session body / session range < compression factor AND session volume > volume factor × SMA of volume from completed higher-timeframe daily bars.
Calculation: Previous session close position = (previous New York session close − session low) / session range, or 0.5 when the range is zero.
Long: Close > open.
Short: Close < open.
Long: Close > EMA of close, independently for each of four lengths ordered shortest to longest, on the chart timeframe or on each of three successively longer requested timeframes; for a higher requested timeframe use its still-forming bar in real time and its last completed bar on historical bars, and for a lower requested timeframe use its last available intrabar.
Short: Close < EMA of close, independently for each of the same lengths and timeframes.
Long: Shorter EMA of close > longer EMA of close, independently for each of four chart-timeframe pairs; their lengths are ordered first-pair shorter < second-pair shorter < first-pair longer < third-pair shorter < second-pair longer < third-pair longer = fourth-pair shorter < fourth-pair longer.
Short: Shorter EMA of close < longer EMA of close, independently for each of the same pairs.
Long: Close > session VWAP.
Short: Close < session VWAP.
Long: High > rolling base high AND close > rolling base high AND high − low > breakout factor × SMA of bar range over the rolling base lookback AND close > open AND close > previous close.
Short: Low < rolling base low AND close < rolling base low AND high − low > breakout factor × SMA of bar range over the rolling base lookback AND close < open AND close < previous close.
Long: Previous New York session range > 0 AND session close > session open AND absolute session body / session range > breakout factor / 2 AND previous session base = false.
Short: Previous New York session range > 0 AND session close < session open AND absolute session body / session range > breakout factor / 2 AND previous session base = false.
Long: Previous session close position > upper bias threshold.
Short: Previous session close position < lower bias threshold AND previous session close position <= upper bias threshold.
Long: RSI rounded to one decimal place > RSI midpoint.
Short: RSI rounded to one decimal place < RSI midpoint.
Long: Stochastic RSI %K > %D.
Short: Stochastic RSI %K < %D.