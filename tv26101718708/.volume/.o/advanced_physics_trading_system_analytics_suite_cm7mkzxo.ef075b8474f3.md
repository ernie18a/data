Calculation: Volatility = ATR over a configurable lookback
Calculation: Velocity = (close − previous close) / Volatility
Calculation: Acceleration = Velocity − previous bar’s Velocity
Calculation: Normalized volume = min(volume / its simple moving average over a configurable lookback, 5); use 1 if the average is zero
Calculation: Volume work = one-bar percentage change in close × normalized volume
Calculation: Kinetic energy = 0.5 × normalized volume × Velocity²
Calculation: Potential energy = 0.5 × spring constant × ((close − simple moving average of close over the normalized-volume lookback) / Volatility)²; use 1 instead of Volatility if zero
Calculation: Force = normalized volume × Acceleration
Calculation: Normalized entropy = Shannon entropy divided by log₂(5) of the volume-work values over the normalized-volume lookback, binned at −2, −0.5, 0.5, and 2
Calculation: Orderly = normalized entropy ≤ its threshold
Calculation: Bull agreement = count of: Velocity > 0; Acceleration > 0; Force > 0.3; Orderly; Volume work > 0
Calculation: Bear agreement = count of: Velocity < 0; Acceleration < 0; Force < −0.3; Orderly; Volume work < 0
Calculation: Net agreement = Bull agreement − Bear agreement
Calculation: Bullish exhaustion = Kinetic energy > 3 × energy threshold AND Acceleration < 0 AND Velocity > 0
Calculation: Bearish exhaustion = Kinetic energy > 3 × energy threshold AND Acceleration > 0 AND Velocity < 0
Calculation: Coil = Kinetic energy < energy threshold AND Potential energy > 2.5 AND Orderly
Calculation: Spring release = previous bar was a Coil AND Force > 1
Calculation: Flip regime = bullish when Net agreement ≥ 2, bearish when Net agreement ≤ −2; record close and bar index when regime changes into either state
Calculation: Flip height = absolute percentage change between consecutive recorded flip closes; flip duration = bars between their indices
Calculation: Average flip height and duration = averages over the most recent configurable number of flips
Calculation: Time symmetry = average duration of bullish flips / average duration of bearish flips; use 0 if either average is unavailable or bearish average is zero
Calculation: Compression streak = consecutive regime flips whose flip height / average flip height is below the compression ratio; reset when not below
Calculation: Expansion streak = consecutive regime flips whose flip height / average flip height is above the expansion ratio; reset when not above
Calculation: Rolling flip high/low = highest/lowest close among the latest configurable number of recorded flip intervals; unavailable until at least two flips
Long: Acceleration > 0 AND Velocity > velocity threshold AND Kinetic energy > energy threshold AND Volume work > 0 AND Orderly AND NOT Bullish exhaustion OR Potential energy > 2.5 AND close < simple moving average of close over the normalized-volume lookback OR Force > 0.3 OR Bull agreement = 5 AND Net agreement > 0 OR Spring release AND Net agreement > 0 OR Expansion streak ≥ 1 AND rolling flip high is available AND close > rolling flip high AND Net agreement ≥ 2 OR Compression streak ≥ minimum compression streak AND absolute percentage distance from close to rolling flip high ≤ near-extreme threshold AND Net agreement > 0 OR Expansion streak ≥ 1 AND Time symmetry > bullish symmetry threshold AND Net agreement ≥ 2 OR Net agreement ≥ 2 AND Time symmetry > bullish symmetry threshold AND Average flip height > geometry threshold AND Orderly
Short: Acceleration < 0 AND Velocity < −velocity threshold AND Kinetic energy > energy threshold AND Volume work < 0 AND Orderly AND NOT Bearish exhaustion OR Force < −0.3 OR Bear agreement = 5 AND Net agreement < 0 OR Spring release AND Net agreement < 0 OR Expansion streak ≥ 1 AND rolling flip low is available AND close < rolling flip low AND Net agreement ≤ −2 OR Compression streak ≥ minimum compression streak AND absolute percentage distance from close to rolling flip low ≤ near-extreme threshold AND Net agreement < 0 OR Expansion streak ≥ 1 AND Time symmetry < bearish symmetry threshold AND Net agreement ≤ −2 OR Net agreement ≤ −2 AND Time symmetry < bearish symmetry threshold AND Average flip height > geometry threshold AND Orderly
Exit: long, Bullish exhaustion
Exit: short, Bearish exhaustion