Calculation: Lower zone touch = low <= LINREG(HLC3, P_regression_length, 0) - max(ATR(P_zone_ATR_length), minimum tick) * P_zone_entry_distance
Calculation: Upper zone touch = high >= LINREG(HLC3, P_regression_length, 0) + max(ATR(P_zone_ATR_length), minimum tick) * P_zone_entry_distance
Calculation: Close location = (close - low) / max(high - low, minimum tick)
Calculation: Lower zone event = lower zone touch AND ((low < LOWEST(low, P_liquidity_lookback)[1] AND close > LOWEST(low, P_liquidity_lookback)[1]) OR (close location >= P_rejection_threshold AND close > open))
Calculation: Upper zone event = upper zone touch AND ((high > HIGHEST(high, P_liquidity_lookback)[1] AND close < HIGHEST(high, P_liquidity_lookback)[1]) OR (close location <= 1 - P_rejection_threshold AND close < open))
Calculation: Volume baseline = EMA(volume with missing values replaced by zero, P_internal_lookback)
Calculation: Stretch = (HLC3 - EMA(HLC3, P_internal_lookback)) / max(ATR(P_internal_lookback), minimum tick)
Calculation: Velocity = (HLC3 - HLC3[P_velocity_lookback]) / (max(ATR(P_internal_lookback), minimum tick) * sqrt(P_velocity_lookback))
Calculation: Recoil = velocity - EMA(velocity, P_velocity_lookback)
Calculation: Rejection bias = ((high - max(open, close)) - (min(open, close) - low)) / max(high - low, minimum tick)
Calculation: Volume surge = if volume baseline > 0, clamp((volume with missing values replaced by zero) / volume baseline - 1, 0, P_volume_surge_cap), otherwise 0
Calculation: Participating rejection = rejection bias * (1 + P_volume_rejection_weight * volume surge)
Calculation: Composite field = EMA(P_stretch_weight * stretch + P_velocity_weight * velocity + P_recoil_weight * recoil + P_rejection_weight * participating rejection, P_field_smoothing)
Calculation: Natural oscillator = P_midpoint + P_midpoint * composite field / (1 + abs(composite field))
Calculation: Upper extreme age = consecutive chart bars with natural oscillator >= P_upper_extreme
Calculation: Lower extreme age = consecutive chart bars with natural oscillator <= P_lower_extreme
Calculation: Extreme age = max(upper extreme age, lower extreme age)
Calculation: Spring release = 1 / (1 + max(extreme age - P_release_delay, 0) * P_release_rate)
Calculation: Spring = P_midpoint + (natural oscillator - P_midpoint) * spring release
Calculation: Tension = min(abs(spring - P_midpoint) / P_midpoint, P_tension_cap)
Calculation: Adaptive gravity alpha = P_gravity_base_alpha * (1 - P_gravity_tension_factor * tension)
Calculation: Gravity = spring on the first bar; otherwise prior gravity + adaptive gravity alpha * (spring - prior gravity)
Long: lower zone event AND bar closes
Long: bars since lower zone event <= P_zone_permission_memory AND Spring crosses above Gravity AND LOWEST(Spring, P_arming_lookback) <= P_lower_extreme AND Spring < P_midpoint AND composite field > composite field[1] AND bar closes
Short: upper zone event AND bar closes
Short: bars since upper zone event <= P_zone_permission_memory AND Spring crosses below Gravity AND HIGHEST(Spring, P_arming_lookback) >= P_upper_extreme AND Spring > P_midpoint AND composite field < composite field[1] AND bar closes