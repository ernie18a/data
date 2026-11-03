Calculation: Net volume delta = up-volume minus down-volume aggregated from lower-timeframe bars within the current chart bar; use the lower timeframe and current chart bar, including the still-forming bar.
Calculation: Delta strength = absolute value of (net volume delta minus its rolling mean) divided by its rolling standard deviation.
Calculation: Cumulative delta = rolling sum of net volume delta.
Calculation: Price and cumulative-delta pivots = local highs or lows confirmed using equal lookback on both sides; compare consecutive corresponding pivots.
Calculation: Relative volume = current volume divided by its rolling average volume.
Calculation: Body ratio = absolute(close − open) divided by (high − low), using one minimum price increment when the range is zero.
Calculation: Upper and lower wick ratios = upper or lower wick length divided by candle range, using one minimum price increment when the range is zero.
Calculation: Intrabar VWAP = volume-weighted average of lower-timeframe typical prices (high + low + close) / 3 within the current chart bar; use lower-timeframe bars within the current, possibly still-forming chart bar.
Calculation: Higher-timeframe trend = higher-timeframe close compared with its EMA; use the higher timeframe's current bar with lookahead off.
Long: Net volume delta > 0 AND its strength exceeds the rolling percentile threshold AND relative volume meets its minimum AND bubble size meets the display threshold [and, when confirmed-only is enabled, the chart bar is complete].
Short: Net volume delta < 0 AND its strength exceeds the rolling percentile threshold AND relative volume meets its minimum AND bubble size meets the display threshold [and, when confirmed-only is enabled, the chart bar is complete].
Long: Net volume delta < 0 AND close >= open AND low breaks the prior rolling low AND close > that prior low AND delta strength meets its absorption minimum AND relative volume meets its minimum.
Short: Net volume delta > 0 AND close < open AND high breaks the prior rolling high AND close < that prior high AND delta strength meets its absorption minimum AND relative volume meets its minimum.
Long: A price pivot low is below the previous price pivot low AND its corresponding cumulative-delta pivot low is above the previous one.
Short: A price pivot high is above the previous price pivot high AND its corresponding cumulative-delta pivot high is below the previous one.
Long: Close < open AND lower wick ratio >= its rejection threshold AND volume > 1.5 × rolling average volume AND body ratio < its small-body threshold.
Short: Close >= open AND upper wick ratio >= its rejection threshold AND volume > 1.5 × rolling average volume AND body ratio < its small-body threshold.
Long: Close < open AND volume < 0.75 × rolling average volume AND body ratio < its small-body threshold.
Short: Close >= open AND volume < 0.75 × rolling average volume AND body ratio < its small-body threshold.
Long: Net volume delta > 0 AND confluence score >= its high-confluence threshold.
Short: Net volume delta < 0 AND confluence score >= its high-confluence threshold.
Calculation: Confluence score = clamp to 0–5 the sum of: delta aligned with candle direction, relative volume meets its minimum, delta strength meets its aggressive threshold, a high or low sweep, and an expansive candle without either rejection wick; add 1 when delta direction agrees with the higher-timeframe trend, subtract 1 when opposed, and add 1 when positive delta closes above intrabar VWAP or negative delta closes below it. An absorption signal raises the score to at least 4.
Long: Net volume delta > 0 AND confluence score >= 4.
Short: Net volume delta < 0 AND confluence score >= 4.