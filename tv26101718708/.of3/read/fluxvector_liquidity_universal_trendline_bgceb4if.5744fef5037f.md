Calculation: Candle range = max(high - low, range floor parameter)
Calculation: Volume normalization = volume / max(SMA(volume, flow lookback), epsilon parameter)
Calculation: Liquidity density = volume normalization / max(candle range / nz(close, missing-close fallback parameter), epsilon parameter)
Calculation: Directional volume pressure = ((body weight parameter × (close - open) / candle range + wick weight parameter × ((close - low) - (high - close)) / candle range) × volume normalization) / sqrt(max(volume normalization, epsilon parameter))
Calculation: Realized volatility = standard deviation of log(selected source price / nz(previous selected source price, selected source price)), using the volatility lookback parameter
Calculation: Realized-volatility curvature = current realized volatility - curvature multiplier parameter × prior realized volatility + realized volatility from two bars ago, with unavailable results replaced by zero
Calculation: Impact efficiency = abs(change(selected source price)) / (candle range + epsilon parameter) × sqrt(max(volume normalization, epsilon parameter))
Calculation: Adaptive activity score = z-score(directional volume pressure, score lookback) + z-score(liquidity density, score lookback) - z-score(realized-volatility curvature, score lookback)
Calculation: Adaptive response = minimum response parameter + (maximum response parameter - minimum response parameter) × min(response ceiling parameter, sigmoid(adaptive activity score) × (impact blend offset parameter + impact blend scale parameter × sigmoid(impact efficiency)))
Calculation: Flow adjustment = EMA(directional volume pressure, max(minimum smoothing lookback parameter, flow lookback / smoothing divisor parameter)) × candle range
Calculation: Adaptive price line = selected source price on the first bar; thereafter, prior adaptive price line + adaptive response × ((selected source price - prior adaptive price line) + flow adjustment weight parameter × flow adjustment)
Calculation: Price-line slope = adaptive price line - prior adaptive price line, using the current line when the prior line is unavailable
Calculation: One-bar projection = adaptive price line + projection multiplier parameter × price-line slope
Long: (close < adaptive price line AND one-bar projection > adaptive price line) OR selected source price crosses above adaptive price line OR price-line slope crosses above slope baseline parameter OR price-line slope > slope baseline parameter
Short: (close > adaptive price line AND one-bar projection < adaptive price line) OR selected source price crosses below adaptive price line OR price-line slope crosses below slope baseline parameter OR price-line slope < slope baseline parameter