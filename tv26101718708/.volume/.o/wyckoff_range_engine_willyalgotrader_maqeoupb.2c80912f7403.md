Calculation: ATR = Average True Range on the current chart bars.
Calculation: Effort ratio = volume divided by its simple moving average, or (high − low) divided by its simple moving average when volume is unavailable; leg effort is the mean ratio over the leg.
Calculation: Confirmed swing = running high/low confirmed when a bar closes at least a parameterized ATR reversal from that extreme; retain the completed leg's mean effort, peak effort, ATR length, and bar count.
Calculation: Climax run score = 30×clamp(mean run effort−1) + 30×clamp((peak run effort−1)/3) + 20×clamp((run ATR length−2)/6) + 20×clamp((run ATR length/run bars)/0.5); clamp each term to [0,1]. The run walks back through consecutive falling highs and lower lows for a selling climax, or rising lows and higher highs for a buying climax.
Calculation: Active range coordinate u = (price − bottom)/(top − bottom) for accumulation, and (top − price)/(top − bottom) for distribution; u=0 is the climax edge and u=1 the reaction edge.
Calculation: Active range = confirmed climax extreme plus a reaction-side confirmed swing whose height is at least a parameterized ATR minimum and retraces at least a parameterized fraction of the climax run; discard if reaction confirmation times out or range height exceeds its parameterized maximum.
Calculation: Spring/UTAD event = after a prior secondary test, a climax-side confirmed swing beyond the climax edge whose confirmation bar closes back inside the range, or whose later close reclaims the range within a parameterized deadline; a pending break that fails reclaim is a range failure.
Calculation: SOS/SOW event = after a secondary test or Spring/UTAD, close beyond the reaction edge by a parameterized ATR buffer, with current leg mean effort and/or ATR length meeting their respective parameterized thresholds (configurable AND/OR); leg runs from the last climax-side swing.
Calculation: LPS/LPSY event = first climax-side confirmed swing after SOS/SOW, within a parameterized search window, with u at least a parameterized floor.
Long: Selling-climax swing and its run has peak effort ≥ parameterized threshold, run score ≥ parameterized threshold, and required lower-low trend context.
Short: Buying-climax swing and its run has peak effort ≥ parameterized threshold, run score ≥ parameterized threshold, and required higher-high trend context.
Long: Accumulation Spring event OR accumulation SOS event OR accumulation LPS event.
Short: Distribution UTAD event OR distribution SOW event OR distribution LPSY event.
Long: Accumulation secondary-test swing has 0 ≤ u ≤ parameterized test zone, while the maximum number of tests is not reached.
Short: Distribution secondary-test swing has 0 ≤ u ≤ parameterized test zone, while the maximum number of tests is not reached.
Long: After an accumulation Spring, the next climax-side swing is above the Spring low, has u ≤ parameterized test zone, and its leg effort is lower than the Spring leg effort.
Short: After a distribution UTAD, the next climax-side swing is below the UTAD high, has u ≤ parameterized test zone, and its leg effort is lower than the UTAD leg effort.
Long: After the first secondary test, a reaction-side swing exceeds the reaction edge, does not qualify as SOS, and its confirmation close has u ≤ 1.
Short: After the first secondary test, a reaction-side swing exceeds the reaction edge, does not qualify as SOW, and its confirmation close has u ≤ 1.
Exit: Long, low ≤ active stop OR high ≥ final profit target OR an enabled opposite short signal.
Exit: Short, high ≥ active stop OR low ≤ final profit target OR an enabled opposite long signal.