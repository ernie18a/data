Calculation: Drift-adjusted return = log(current close / close N bars ago) − N × average one-bar log return over a longer lookback; omit the drift term when drift adjustment is off.
Calculation: Regime threshold = either k × standard deviation of one-bar log returns over a lookback × √N, or a fixed percentage threshold; Bull when drift-adjusted return > its threshold, Bear when it < negative its threshold, otherwise Sideways. When momentum agreement is enabled, Bull also requires positive oscillator velocity and Bear requires negative oscillator velocity.
Calculation: Oscillator = drift-adjusted return divided by the applicable regime threshold, multiplied by 100 and clipped to ±300.
Calculation: Oscillator velocity = oscillator − oscillator from a shorter lookback ago.
Calculation: Signal line = selected smoothing of the oscillator (EMA, HMA, ALMA, or SMA).
Long: Regime changes to Bull and persists for the minimum hold; exclude the initial regime classification. OR oscillator crosses above the signal line. OR regime is Sideways, drift-adjusted return is positive, and its magnitude is at least 70% of the Bull threshold.
Short: Regime changes to Bear and persists for the minimum hold; exclude the initial regime classification. OR oscillator crosses below the signal line. OR regime is Sideways, drift-adjusted return is negative, and its magnitude is at least 70% of the Bear threshold.
Exit: Long, regime changes to Bear or Sideways and persists for the minimum hold.
Exit: Short, regime changes to Bull or Sideways and persists for the minimum hold.