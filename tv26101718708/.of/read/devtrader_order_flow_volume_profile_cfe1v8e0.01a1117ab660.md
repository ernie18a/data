Calculation: Classified buy/sell volume = on each lower-timeframe bar, assign its volume to buy if its close is above the previous lower-timeframe close, or if equal and its close is above its open; assign to sell for the converse; split evenly if neither. For the first lower-timeframe bar, compare its close with the chart bar open.
Calculation: Delta percentage = 100 × (classified buy volume − classified sell volume) / total classified volume.
Calculation: Relative volume = current total classified volume / its moving average; the average uses a longer lookback than a single bar.
Calculation: Session and day delta percentages = 100 × cumulative classified volume delta / cumulative total classified volume within the current configured session or calendar day, respectively.
Calculation: Session CVD = cumulative classified volume delta within the current configured session.
Calculation: Confirmed price pivots = swing highs or lows confirmed by bars on both sides, using equal left and right lookbacks.
Long: Delta percentage ≥ directional pressure threshold.
Long: Delta percentage ≥ extreme delta threshold AND relative volume ≥ minimum participation threshold.
Long: Session delta percentage ≥ extreme delta threshold AND the session has reached its maturity bar count AND has no missing pressure bars.
Long: Day delta percentage ≥ extreme delta threshold AND the day has reached its maturity bar count AND has no missing pressure bars.
Long: Delta percentage ≤ −extreme delta threshold AND relative volume ≥ minimum participation threshold AND (close > open OR (close − low) / max(high − low, minimum price increment) ≥ absorption close edge).
Long: A confirmed price pivot low is lower than the preceding confirmed pivot low in the same session AND session CVD at the new pivot is higher than at the preceding pivot.
Short: Delta percentage ≤ −directional pressure threshold.
Short: Delta percentage ≤ −extreme delta threshold AND relative volume ≥ minimum participation threshold.
Short: Session delta percentage ≤ −extreme delta threshold AND the session has reached its maturity bar count AND has no missing pressure bars.
Short: Day delta percentage ≤ −extreme delta threshold AND the day has reached its maturity bar count AND has no missing pressure bars.
Short: Delta percentage ≥ extreme delta threshold AND relative volume ≥ minimum participation threshold AND (close < open OR (close − low) / max(high − low, minimum price increment) ≤ absorption close edge).
Short: A confirmed price pivot high is higher than the preceding confirmed pivot high in the same session AND session CVD at the new pivot is lower than at the preceding pivot.