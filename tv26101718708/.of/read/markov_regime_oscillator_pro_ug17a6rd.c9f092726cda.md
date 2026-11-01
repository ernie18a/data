Calculation: Adjusted return = log(close / close[N]) minus N times the long-window SMA of one-bar log returns when drift adjustment is enabled and that SMA is available; otherwise use the unadjusted return.
Calculation: Bull and bear boundaries = the same volatility multiplier times the standard deviation of one-bar log returns over a volatility window times sqrt(N) in adaptive mode; otherwise use separately configurable fixed positive boundaries.
Calculation: Oscillator = adjusted return divided by the bull boundary when adjusted return is nonnegative, otherwise by the bear boundary, multiplied by an oscillator scale and clipped to symmetric limits; use zero if the selected boundary is unavailable or nonpositive or adjusted return is unavailable.
Calculation: Velocity = oscillator minus its value a velocity window ago, or zero if that history is unavailable. Velocity threshold = a positive base times the square root of the velocity window divided by a reference window.
Calculation: Regime = unavailable if adjusted return is unavailable or adaptive volatility is unavailable; otherwise bull if adjusted return > bull boundary AND momentum filtering is disabled OR adjusted return > bull boundary AND velocity > 0; otherwise bear if adjusted return < negative bear boundary AND momentum filtering is disabled OR adjusted return < negative bear boundary AND velocity < 0; otherwise sideways. Apply the same calculation to the last completed higher-timeframe bar for higher-timeframe regime.
Calculation: Confirmed regime change = current regime is available AND has persisted for at least the hold window AND differs from the last signalled regime. The last signalled regime starts unavailable and is updated only on a confirmed regime change; comparisons with an unavailable value are false.
Calculation: Signal = EMA, HMA, ALMA, or SMA of the oscillator over a configurable smoothing window; ALMA uses configurable offset and width.
Calculation: Pending fraction = max(adjusted return / bull boundary, negative adjusted return / bear boundary), using zero for either ratio when its boundary is unavailable or nonpositive or adjusted return is unavailable.
Calculation: Forecast probabilities = count every consecutive available regime transition in a three-state matrix, optionally multiplying existing counts by an exponential half-life decay factor before each increment. Maintain separate matrices for transitions whose source regime age is below or at least a configurable age threshold. Select the full matrix or the matrix matching the current regime age; add a smoothing prior to each cell and normalize each row. Starting with probability one on the current regime, repeatedly multiply by this matrix for a configurable forecast horizon; use sideways as the starting regime when the current regime is unavailable.
Long: Regime = bull
Short: Regime = bear
Long: Confirmed regime change = true AND regime = bull AND a prior signalled regime exists
Short: Confirmed regime change = true AND regime = bear AND a prior signalled regime exists
Exit: long, confirmed regime change = true AND regime = bear AND a prior signalled regime exists
Exit: long OR short, confirmed regime change = true AND regime = sideways AND a prior signalled regime exists
Long: Oscillator >= positive pending level
Short: Oscillator < negative pending level
Long: Oscillator >= 0
Short: Oscillator < 0
Long: Velocity > velocity threshold
Short: Velocity < negative velocity threshold
Long: Regime = sideways AND pending fraction >= pending threshold AND adjusted return > 0
Short: Regime = sideways AND pending fraction >= pending threshold AND adjusted return <= 0
Long: Oscillator > signal
Short: Oscillator < signal
Long: Oscillator crosses above signal AND higher-timeframe filtering is disabled OR oscillator crosses above signal AND higher-timeframe confluence is disabled OR oscillator crosses above signal AND higher-timeframe regime = chart-timeframe regime
Short: Oscillator crosses below signal AND higher-timeframe filtering is disabled OR oscillator crosses below signal AND higher-timeframe confluence is disabled OR oscillator crosses below signal AND higher-timeframe regime = chart-timeframe regime
Long: Drift adjustment is enabled AND long-window SMA of one-bar log returns > 0
Short: Drift adjustment is enabled AND long-window SMA of one-bar log returns < 0
Long: Forecast bull probability >= forecast bear probability AND forecast bull probability >= forecast sideways probability
Short: Forecast bear probability > forecast bull probability AND forecast bear probability >= forecast sideways probability