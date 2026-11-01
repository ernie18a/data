Calculation: Volatility = ATR of close-price true range over the volume-average lookback.
Calculation: Velocity = (close − previous close) / volatility; use 0 when volatility is 0. Acceleration = velocity − previous velocity.
Calculation: Mass = volume / SMA of volume over the physics lookback, capped at a positive maximum; use 1 when the volume average is 0. Force = mass × acceleration. Volume work = percentage change in close from the previous bar × mass.
Calculation: Kinetic energy = mass × velocity² / 2. Potential energy = spring coefficient × ((close − SMA of close over the physics lookback) / volatility)² / 2; use 1 as the denominator when volatility is 0.
Calculation: Normalized entropy = Shannon entropy of volume work over the physics lookback divided by the maximum entropy for five bins. The bins are below the negative outer boundary, from the negative outer boundary inclusive to the negative inner boundary exclusive, between the negative and positive inner boundaries inclusive, above the positive inner boundary through the positive outer boundary inclusive, and above the positive outer boundary.
Calculation: Bull agreement = count of velocity > 0, acceleration > 0, force > positive force threshold, entropy <= entropy threshold, and volume work > 0. Bear agreement = count of velocity < 0, acceleration < 0, force < negative force threshold, entropy <= entropy threshold, and volume work < 0. Net agreement = bull agreement − bear agreement; the force thresholds are symmetric around 0.
Calculation: Physics regime starts neutral and switches to bullish when net agreement reaches the positive regime threshold, or bearish when it reaches the symmetric negative threshold; a flip is recorded only when the regime changes. Store each flip's close, bar index, and new direction, retaining a fixed maximum number of recent flips.
Calculation: Average flip height = mean of 100 × absolute close change / starting close for consecutive retained flip pairs; use 0 for a zero starting close and use 0 for the average until at least three flips exist. Time symmetry = average bars between flips ending bullish divided by average bars between flips ending bearish; use 0 until at least three flips exist or either average is unavailable or the bearish average is 0.
Calculation: Compression and expansion streaks start at 0 and change only on a flip with a preceding flip. Divide the latest flip-pair height percentage by the current average flip height, using 1 if the average is 0. If the ratio is below the compression threshold, increment compression and reset expansion; if above the higher expansion threshold, increment expansion and reset compression; otherwise reset both.
Calculation: Rolling flip high and low = maximum and minimum flip closes among the most recent rolling-lookback-plus-one retained flips; both are unavailable until at least two flips exist. Distance to flip high = 100 × (rolling flip high − close) / close; distance to flip low = 100 × (close − rolling flip low) / close. Use 0 for either distance when its flip extreme is unavailable or close <= 0.
Calculation: Composite score = net agreement / maximum dimension count × agreement weight + symmetry adjustment × symmetry weight + geometry adjustment × geometry weight + (1 − normalized entropy) × entropy weight, where symmetry adjustment is time symmetry − 1 when time symmetry > 0 and otherwise 0, and geometry adjustment is ln(average flip height / reference height) when average flip height > 0 and otherwise 0. Rank score = composite score + net agreement / agreement divisor + (time symmetry − 1) × the same symmetry weight.
Long: Velocity > 0.
Short: Velocity < 0.
Long: Acceleration > 0.
Short: Acceleration < 0.
Long: Volume work > 0.
Short: Volume work < 0.
Long: Force > positive force threshold.
Short: Force < negative force threshold.
Long: Acceleration > 0 AND velocity > positive velocity threshold AND kinetic energy > energy threshold AND volume work > 0 AND normalized entropy <= entropy threshold.
Short: Acceleration < 0 AND velocity < negative velocity threshold AND kinetic energy > energy threshold AND volume work < 0 AND normalized entropy <= entropy threshold; the velocity thresholds are symmetric around 0.
Long: Net agreement > 0.
Short: Net agreement < 0.
Long: Time symmetry > bullish symmetry threshold.
Short: Time symmetry < bearish symmetry threshold; the bullish threshold is higher than the bearish threshold.
Long: Composite score > bullish composite threshold.
Short: Composite score < bearish composite threshold.
Long: Rank score > bullish rank threshold.
Short: Rank score < bearish rank threshold.
Long: Bull agreement = maximum dimension count AND net agreement > 0.
Short: Bear agreement = maximum dimension count AND net agreement < 0.
Long: Previous-bar kinetic energy < energy threshold AND previous-bar potential energy > potential-energy threshold AND previous-bar normalized entropy <= entropy threshold AND force > release-force threshold AND net agreement > 0.
Short: Previous-bar kinetic energy < energy threshold AND previous-bar potential energy > potential-energy threshold AND previous-bar normalized entropy <= entropy threshold AND force > release-force threshold AND net agreement < 0.
Long: Compression streak >= minimum compression streak AND absolute distance to flip high <= near-extreme percentage AND net agreement > 0.
Short: Compression streak >= minimum compression streak AND absolute distance to flip low <= near-extreme percentage AND net agreement < 0.
Long: Expansion streak >= 1 AND rolling flip high is available AND close > rolling flip high AND net agreement >= positive regime threshold.
Short: Expansion streak >= 1 AND rolling flip low is available AND close < rolling flip low AND net agreement <= negative regime threshold.
Long: Expansion streak >= 1 AND time symmetry > bullish symmetry threshold AND net agreement >= positive regime threshold.
Short: Expansion streak >= 1 AND time symmetry < bearish symmetry threshold AND net agreement <= negative regime threshold.
Long: Net agreement >= positive regime threshold AND time symmetry > bullish symmetry threshold AND average flip height > geometry threshold AND normalized entropy <= entropy threshold.
Short: Net agreement <= negative regime threshold AND time symmetry < bearish symmetry threshold AND average flip height > geometry threshold AND normalized entropy <= entropy threshold.
Exit: long, kinetic energy > energy threshold × exhaustion multiplier AND acceleration < 0 AND velocity > 0.
Exit: short, kinetic energy > energy threshold × exhaustion multiplier AND acceleration > 0 AND velocity < 0.