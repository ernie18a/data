Calculation: Clip(x, lower bound, upper bound) = min(max(x, lower bound), upper bound)
Calculation: Standardized score(x, lookback) = 0 when stdev(x, lookback) is zero or unavailable; otherwise (x - SMA(x, lookback)) / stdev(x, lookback)
Calculation: Bar span = max(high - low, minimum price increment)
Calculation: Close-location value = Clip(((close - low) / bar span - midpoint fraction) * location scale, lower clip bound, upper clip bound)
Calculation: Directional pressure = Clip(body weight * sign(close - open) * abs(close - open) / bar span + close-location weight * close-location value, lower clip bound, upper clip bound)
Calculation: Delta volume = volume * directional pressure
Calculation: Order-flow imbalance = Clip(volume > 0 ? delta volume / volume : 0, lower clip bound, upper clip bound)
Calculation: CVD score = Clip(Standardized score(LinReg(cumulative sum(delta volume), CVD slope lookback, offset 0) - LinReg(cumulative sum(delta volume), CVD slope lookback, offset 1), standardization lookback) / score normalization scale, lower clip bound, upper clip bound)
Calculation: VWAP score = Clip((ATR(high, low, close, ATR lookback) > 0 ? (close - VWAP(hlc3)) / ATR(high, low, close, ATR lookback) : 0) / score normalization scale, lower clip bound, upper clip bound)
Calculation: Spread risk = max(Standardized score(close != 0 ? bar span / close : 0, standardization lookback), 0)
Calculation: Amihud risk = max(Standardized score(abs(log(close / close[1])) / max(volume * close, dollar-volume floor), standardization lookback), 0)
Calculation: Liquidity score = Clip(Standardized score(volume / bar span, standardization lookback) / score normalization scale, lower clip bound, upper clip bound)
Calculation: VPIN risk = max(Standardized score(SMA(abs(delta volume), VPIN lookback) / max(SMA(volume, VPIN lookback), VPIN volume floor), standardization lookback), 0)
Calculation: Directional component = OFI weight * order-flow imbalance + CVD weight * CVD score + close-location weight * close-location value + VWAP weight * VWAP score
Calculation: Liquidity confirmation = sign(directional component) * max(liquidity score, 0)
Calculation: Risk penalty = risk baseline + spread penalty weight * spread risk + VPIN penalty weight * VPIN risk + Amihud penalty weight * Amihud risk
Calculation: Composite score = EMA((directional component + liquidity confirmation weight * liquidity confirmation) / risk penalty, score smoothing lookback)
Calculation: Rise probability = probability scale * logistic(composite score * probability sensitivity)
Long: rise probability > long probability threshold AND composite score > minimum absolute score AND (EMA trend filter disabled OR EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback)) AND (signal cadence is every qualifying bar OR at least one of these entry conditions was false on the preceding chart bar)
Short: rise probability < short probability threshold AND composite score < -minimum absolute score AND (EMA trend filter disabled OR EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback)) AND (signal cadence is every qualifying bar OR at least one of these entry conditions was false on the preceding chart bar)
Long: rise probability >= long probability threshold
Short: rise probability <= short probability threshold
Long: rise probability >= probability midpoint threshold
Short: rise probability < probability midpoint threshold
Long: composite score >= 0
Short: composite score < 0
Long: order-flow imbalance >= 0
Short: order-flow imbalance < 0
Long: CVD score >= 0
Short: CVD score < 0
Long: VWAP score >= 0
Short: VWAP score < 0
Long: EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback)
Short: EMA(close, shorter EMA lookback) <= EMA(close, longer EMA lookback)