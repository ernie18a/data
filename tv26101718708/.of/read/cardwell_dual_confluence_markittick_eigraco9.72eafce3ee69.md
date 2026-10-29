Calculation: Fast momentum = RMA of RSI, using a shorter RMA length than the slow momentum RMA; compare values on the last two completed chart bars
Calculation: Bullish momentum cross = fast momentum was at or below slow momentum two chart bars ago and above it one chart bar ago
Calculation: Bearish momentum cross = fast momentum was at or above slow momentum two chart bars ago and below it one chart bar ago
Calculation: Bullish regime = chart close source is above its SMA and chart RSI is within inclusive configured bullish bounds for the configured number of consecutive completed chart bars
Calculation: Bearish regime = chart close source is below its SMA and chart RSI is within inclusive configured bearish bounds for the configured number of consecutive completed chart bars
Calculation: Bullish regime transition = bullish regime is true and was not true on the previous chart bar
Calculation: Bearish regime transition = bearish regime is true and was not true on the previous chart bar
Calculation: Cross-regime confluence = bullish (or bearish) momentum cross and matching regime transition occur within the configured bar window
Calculation: Higher-timeframe regime = bullish or bearish regime evaluated on the last completed bar of a higher timeframe
Calculation: Entry levels = previous completed chart bar close plus or minus the chart ATR measured when the signal is accepted, multiplied by configured stop-loss or take-profit factors; place stop and targets below entry for long positions and above entry for short positions
Long: (both-required mode is off AND (bullish momentum cross OR bullish regime transition) OR both-required mode is on AND cross-regime confluence is bullish) AND (higher-timeframe filter is off OR higher-timeframe regime is bullish) AND (ADX filter is off OR ADX is at least its configured minimum) AND no accepted signal occurred within the configured cooldown bars
Short: (both-required mode is off AND (bearish momentum cross OR bearish regime transition) OR both-required mode is on AND cross-regime confluence is bearish) AND (higher-timeframe filter is off OR higher-timeframe regime is bearish) AND (ADX filter is off OR ADX is at least its configured minimum) AND no accepted signal occurred within the configured cooldown bars
Exit: long, chart low is at or below the long stop-loss level OR chart high is at or above any of the long take-profit levels OR a short entry is accepted
Exit: short, chart high is at or above the short stop-loss level OR chart low is at or below any of the short take-profit levels OR a long entry is accepted