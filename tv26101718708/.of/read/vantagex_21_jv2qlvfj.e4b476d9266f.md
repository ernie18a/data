Calculation: Session VWAP = sum(typical price × volume) / sum(volume) over chart bars in the selected exchange-time session; reset at the exact session start, update during the session, and retain the last value outside it. Typical price = (high + low + close) / 3. The selectable sessions are 03:00–11:00 and 09:30–16:00.
Calculation: Rolling base = the most recently recorded highest high and lowest low over the base lookback. Record both on every bar where highest high minus lowest low over that lookback is less than the compression factor × the sum of bar ranges over that lookback AND volume summed over that lookback is greater than the volume concentration factor × the volume SMA over the longer volume lookback × the base lookback. Update the base before evaluating breakouts on the same bar.
Calculation: Previous New York session = chart bars in the most recently completed 09:30–16:00 America/New_York session, locked when the session ends. Its open is the first bar's open, close is the last bar's close, high and low are the extrema, and volume is the sum of volume.
Calculation: Previous session base = previous New York session range > 0 AND absolute session body / session range < compression threshold AND session volume > volume concentration factor × the SMA of volume from the last completed daily bar over its daily lookback.
Calculation: Previous session close position = (previous New York session close − session low) / (session high − session low), or the midpoint if the session range is zero.
Calculation: Stochastic RSI K = SMA of the RSI's position within its rolling lowest-to-highest range, scaled from zero to the oscillator's maximum; use zero when that range is zero. Stochastic RSI D = SMA of K, using a separately configurable smoothing lookback.
Long: close > an EMA of close on the chart timeframe, independently for each of four increasing EMA lookbacks.
Short: close < an EMA of close on the chart timeframe, independently for each of four increasing EMA lookbacks.
Long: close > an EMA of close on each of three independently selected non-chart timeframes, independently for each of four increasing EMA lookbacks. For a higher timeframe, use the last completed bar on historical bars and the still-forming bar in real time; for a lower timeframe, use its last bar within the chart bar.
Short: close < an EMA of close on each of three independently selected non-chart timeframes, independently for each of four increasing EMA lookbacks. For a higher timeframe, use the last completed bar on historical bars and the still-forming bar in real time; for a lower timeframe, use its last bar within the chart bar.
Long: shorter-lookback EMA > longer-lookback EMA, independently for four pairs on the chart timeframe. In increasing lookback order the EMA lengths are A < B < C < D < E < F < G; the pairs are A/C, B/E, D/F, and F/G. The four close-versus-EMA comparisons use B, D, F, and G.
Short: shorter-lookback EMA < longer-lookback EMA for each of the same four pairs.
Long: close > session VWAP.
Short: close < session VWAP.
Long: close > open.
Short: close < open.
Long: high > rolling base high AND close > rolling base high AND high − low > breakout factor × SMA of bar range over the base lookback AND close > open AND close > previous close.
Short: low < rolling base low AND close < rolling base low AND high − low > breakout factor × SMA of bar range over the base lookback AND close < open AND close < previous close.
Long: previous New York session range > 0 AND session close > session open AND absolute session body / session range > directional efficiency threshold AND previous session base = false.
Short: previous New York session range > 0 AND session close < session open AND absolute session body / session range > directional efficiency threshold AND previous session base = false.
Long: previous session close position > bullish bias threshold.
Short: previous session close position < bearish bias threshold AND previous session close position <= bullish bias threshold.
Long: RSI rounded to one decimal place > RSI midpoint.
Short: RSI rounded to one decimal place < RSI midpoint.
Long: Stochastic RSI K > Stochastic RSI D.
Short: Stochastic RSI K < Stochastic RSI D.