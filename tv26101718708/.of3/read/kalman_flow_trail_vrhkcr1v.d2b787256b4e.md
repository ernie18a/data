Calculation: Structure impulse = +1 when close crosses above the latest unbroken pivot high, −1 when close crosses below the latest unbroken pivot low, otherwise 0; pivots use P bars on each side, clear the crossed pivot after a break, and clear the opposite pivot when a break reverses the previous break direction.
Long: Close crosses above the latest unbroken pivot high.
Short: Close crosses below the latest unbroken pivot low.
Calculation: Fast and slow Kalman estimates = Kalman(close, process noise = response / shorter Kalman length, measurement noise) and Kalman(close, process noise = response / longer Kalman length, the same measurement noise).
Calculation: Adaptive trail = initialize at the fast Kalman estimate; thereafter add alpha × (fast Kalman estimate − prior trail) and push factor × bias × agreement × ATR(length) to the prior trail, where activity = RMA(abs(structure impulse), lookback), bias = RMA(structure impulse, the same lookback), alpha = 2/(longer smoothing length + 1) + [2/(shorter smoothing length + 1) − 2/(longer smoothing length + 1)] × min(1, activity), and agreement = 1 when bias and the ordering of fast and slow Kalman estimates agree, otherwise the disagreement factor; when both pivot levels exist, also add anchor factor × activity × (midpoint of the pivot levels − trail).
Calculation: Flow direction initializes bullish when close is at or above the adaptive trail and bearish otherwise; afterward it turns bullish when close is above the adaptive trail plus ATR(length) × boundary multiplier and (slope confirmation is disabled or the trail is rising), turns bearish when close is below the adaptive trail minus ATR(length) × boundary multiplier and (slope confirmation is disabled or the trail is falling), and otherwise retains its prior direction.
Long: Flow direction is bullish.
Short: Flow direction is bearish.
Long: Flow direction changes from bearish to bullish.
Short: Flow direction changes from bullish to bearish.
Long: Fast Kalman estimate is above its prior value.
Short: Fast Kalman estimate is below its prior value.
Long: Close on T1 bars is above the adaptive trail calculated on T1 bars; the requested value is from the still-forming T1 bar in realtime and the completed T1 bar historically.
Short: Close on T1 bars is below the adaptive trail calculated on T1 bars; the requested value is from the still-forming T1 bar in realtime and the completed T1 bar historically.
Long: Close on T2 bars is above the adaptive trail calculated on T2 bars; the requested value is from the still-forming T2 bar in realtime and the completed T2 bar historically.
Short: Close on T2 bars is below the adaptive trail calculated on T2 bars; the requested value is from the still-forming T2 bar in realtime and the completed T2 bar historically.
Long: Close on T3 bars is above the adaptive trail calculated on T3 bars; the requested value is from the still-forming T3 bar in realtime and the completed T3 bar historically.
Short: Close on T3 bars is below the adaptive trail calculated on T3 bars; the requested value is from the still-forming T3 bar in realtime and the completed T3 bar historically.
Long: Close on T4 bars is above the adaptive trail calculated on T4 bars; the requested value is from the still-forming T4 bar in realtime and the completed T4 bar historically.
Short: Close on T4 bars is below the adaptive trail calculated on T4 bars; the requested value is from the still-forming T4 bar in realtime and the completed T4 bar historically.
Long: Close on T5 bars is above the adaptive trail calculated on T5 bars; the requested value is from the still-forming T5 bar in realtime and the completed T5 bar historically.
Short: Close on T5 bars is below the adaptive trail calculated on T5 bars; the requested value is from the still-forming T5 bar in realtime and the completed T5 bar historically.
Long: Chart-bar close is above the adaptive trail calculated on T6 bars and requested onto chart bars; the T6 value is from the still-forming bar in realtime and the completed bar historically.
Short: Chart-bar close is below the adaptive trail calculated on T6 bars and requested onto chart bars; the T6 value is from the still-forming bar in realtime and the completed bar historically.