Calculation: Anchored VWAP and standard-deviation bands = volume-weighted mean and population standard deviation of HLC3, accumulated from the selected anchor-period reset; include the current forming bar and suppress bands during the first five bars after reset.
Calculation: Profile POC, VAH, and VAL = distribute each current-timeframe bar's volume among price buckets by its high-low midpoint over the rolling profile lookback, including the current forming bar; POC is the fullest bucket, and expand the value area from POC by adding the fuller adjacent bucket until the configured share of total volume is reached.
Calculation: Estimated bar delta = volume × (2 × close − high − low) / (high − low); use zero when high equals low.
Calculation: Session CVD = cumulative estimated bar delta since the selected VWAP anchor-period reset, including the current bar.
Calculation: CVD divergence pivots = confirmed price swing highs and lows using equal left and right lookbacks; compare CVD at each pivot with CVD at the previous pivot of the same type.
Calculation: Relative volume = current volume divided by its rolling average; use the same average for volume-spike and sweep filters.
Calculation: Initial Balance High and Low = highest high and lowest low during the configured opening duration after each anchor-period reset; use forming bars while the range is being built, then freeze it once the duration has elapsed.
Calculation: Confluence score = sum signed contributions for close versus anchored VWAP, close outside the profile value area, session delta percentage, CVD versus its short-term EMA, and relative volume; bound the delta contribution, then cap the absolute score at its maximum.
Long: confirmed bullish CVD divergence: current confirmed swing low < previous swing low AND CVD at current swing low > CVD at previous swing low AND swing-low difference > configured ATR multiple of current-timeframe ATR.
Long: low < highest low of the preceding configured sweep lookback AND close > that preceding low AND relative volume ≥ configured sweep threshold AND close > open.
Long: volume ≥ rolling average volume × configured spike threshold AND close > open.
Long: Initial Balance is complete AND close > Initial Balance High AND no earlier upside break has occurred in the current anchor period.
Long: confluence score ≥ 0 AND absolute confluence score ≥ configured alert threshold.
Short: confirmed bearish CVD divergence: current confirmed swing high > previous swing high AND CVD at current swing high < CVD at previous swing high AND swing-high difference > configured ATR multiple of current-timeframe ATR.
Short: high > highest high of the preceding configured sweep lookback AND close < that preceding high AND relative volume ≥ configured sweep threshold AND close < open.
Short: volume ≥ rolling average volume × configured spike threshold AND close < open.
Short: Initial Balance is complete AND close < Initial Balance Low AND no earlier downside break has occurred in the current anchor period.
Short: confluence score < 0 AND absolute confluence score ≥ configured alert threshold.