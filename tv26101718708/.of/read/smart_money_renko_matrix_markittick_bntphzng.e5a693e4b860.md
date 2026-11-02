Calculation: Confirmed Renko bar = the last completed ATR-sized Renko bar requested at the chart timeframe or a higher timeframe; carry its open and close forward across chart bars until the next completed Renko bar is available.
Calculation: Directional streak = consecutive chart bars on which the confirmed Renko close is respectively greater than or less than its open; reset the corresponding streak to zero otherwise.
Calculation: MTF bullish or bearish score = count of three higher timeframes for which the chart close is respectively above or below the simple moving average of closes, calculated using the last completed bar of each higher timeframe. All three averages use the same lookback.
Calculation: Wick cluster count = for each side separately, count consecutive chart bars with a wick on that side whose extreme is within an ATR-scaled distance of the stored extreme; otherwise, if a wick exists, store its extreme and reset the count to one, or reset the count to zero if no wick exists. Retain the stored extreme until it is replaced.
Calculation: Locked stop = at each filtered first directional streak bar, use the confirmed Renko close minus an ATR multiple for a bullish signal or plus an ATR multiple for a bearish signal. If structure-based stops are enabled and a qualifying prior order block exists, instead use the bottom of the block with the nearest top below the bullish signal's Renko close, or the top of the block with the nearest bottom above the bearish signal's Renko close. Each filtered first directional streak bar creates a block bounded by that Renko open and close; retain a limited number of blocks and exclude the newly created block when selecting the stop. Lock the stop until the next filtered first directional streak bar.
Long: Confirmed Renko close > confirmed Renko open.
Short: Confirmed Renko close < confirmed Renko open.
Long: MTF bullish score >= convergence threshold.
Short: MTF bearish score >= convergence threshold.
Long: Bullish directional streak = 1 AND (MTF filter disabled OR MTF bullish score >= convergence threshold) AND (session filter disabled OR bar datetime is within the configured UTC session).
Short: Bearish directional streak = 1 AND (MTF filter disabled OR MTF bearish score >= convergence threshold) AND (session filter disabled OR bar datetime is within the configured UTC session).
Long: Low < lowest low of the preceding lookback bars AND close > that lowest low AND close > open.
Short: High > highest high of the preceding lookback bars AND close < that highest high AND close < open.
Long: Lower wick cluster count >= cluster threshold.
Short: Upper wick cluster count >= cluster threshold.
Exit: long, close < locked stop.
Exit: short, close > locked stop.