Calculation: cRSI = RSI of close using a half-cycle-length RMA of gains and losses, phase-adjusted by half the vibration lag, then smoothed with torque 2/(vibration+1) against its previous value
Calculation: cRSI lower band = lowest cRSI level at which at least the leveling fraction of the cRSI values in the twice-cycle-length window are below it; upper band = highest level at which at least that fraction are at or above it
Calculation: cRSI WMA = weighted moving average of cRSI
Calculation: cRSI top/bottom = a local top/bottom formed by two or three consecutive rises/falls followed by a reversal; use the configured detector lookback
Calculation: Strong impulse = cRSI top with the preceding cRSI at or above the upper band; weak impulse = cRSI top with the preceding cRSI below the upper band and current cRSI above its WMA
Calculation: Wave A = cRSI bottom with preceding cRSI below the lower band, unless it completes wave C or E; wave B = a cRSI top below its WMA or below 50 that follows wave A during an uninterrupted corrective phase; wave C = a cRSI bottom below its WMA or below the lower band that follows wave B; wave D = wave B following wave C; wave E = wave C following wave D; wave F = wave B following wave E; wave G = wave C following wave F. For each follow-on wave, search backward up to the configured history limit and stop if the corrective phase ends.
Calculation: Regular bullish divergence = at a cRSI low, cRSI is higher than at the previous cRSI low and close is lower; hidden bullish divergence = at a cRSI low, cRSI is lower and close is higher
Calculation: Regular bearish divergence = at a cRSI high, cRSI is lower than at the previous cRSI high and close is higher; hidden bearish divergence = at a cRSI high, cRSI is higher and close is lower
Calculation: Signal cooldown = a signal is suppressed if the same signal occurred within the configured preceding-bar lookback
Long: cRSI crosses above its WMA OR (wave A OR wave C) AND regular bullish divergence OR wave E with the longer detector lookback OR wave G with the shorter detector lookback; within either configured trading session when session filtering is enabled; signal cooldown has elapsed
Long: regular bullish divergence OR hidden bullish divergence
Long: Strong impulse OR weak impulse
Short: (Strong impulse OR (cRSI is above the upper band AND cRSI is falling) OR (cRSI was above the upper band one or two bars ago AND cRSI is falling)) AND upper band is above its configured high level; within either configured trading session when session filtering is enabled; signal cooldown has elapsed
Short: regular bearish divergence OR hidden bearish divergence
Exit: Long or short, an enabled close-all session reaches its configured stop hour and stop minute