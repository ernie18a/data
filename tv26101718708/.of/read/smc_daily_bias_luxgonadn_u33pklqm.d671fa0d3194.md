Calculation: Reference timeframe = a configurable timeframe that may be higher than, lower than, or equal to the chart timeframe; use the last completed reference bar for previous-bar values and confirmed pivots, and the still-forming reference bar for its open. When the reference timeframe is lower, use the last completed reference bar within each chart bar.
Calculation: Pivot high or low = a high or low confirmed after an equal configurable number of reference or chart bars on each side. For each timeframe and pivot kind, compare the latest pivot with the previously recorded pivot: type is +1 if greater, -1 if less than or equal, and 0 until two pivots have been recorded. For reference pivots, map the completed reference-timeframe pivot result to chart bars with gaps filled, and update the recorded pivot on every chart bar where the mapped result is present, including repeated values.
Calculation: Previous-candle vote = +1 if the last completed reference bar's close is above its open, -1 if below, otherwise 0.
Calculation: Reference-structure vote = +1 if the latest reference pivot-high and pivot-low types are both +1, -1 if both are -1, otherwise 0.
Calculation: Open vote = +1 if chart close is above the still-forming reference bar's open, -1 if below, otherwise 0.
Calculation: Combined score = previous-candle vote + reference-structure vote + open vote.
Calculation: Swing midpoint = (latest confirmed chart-timeframe pivot high + latest confirmed chart-timeframe pivot low) / 2; use the same chart-timeframe pivot lookback for both.
Long: Previous-candle vote = +1 OR reference-structure vote = +1 OR open vote = +1 OR combined score >= 2.
Short: Previous-candle vote = -1 OR reference-structure vote = -1 OR open vote = -1 OR combined score <= -2.
Long: Latest chart-timeframe pivot-high type = +1 AND latest chart-timeframe pivot-low type = +1.
Short: Latest chart-timeframe pivot-high type = -1 AND latest chart-timeframe pivot-low type = -1.
Long: Chart close < swing midpoint.
Short: Chart close > swing midpoint.