Calculation: Upper rail = rolling highest high over a configurable lookback
Calculation: Lower rail = rolling lowest low over a configurable lookback
Calculation: Trend = 1 after close crosses above the prior bar's upper rail, -1 after close crosses below the prior bar's lower rail, otherwise the prior trend (initially 0)
Calculation: Equilibrium = midpoint of the rails adjusted toward the average of EMA and VWMA of the clamped close position within the rail range, then clamped within the channel
Calculation: Equilibrium curl down = equilibrium < its prior value AND its prior value <= its value two bars ago
Calculation: Equilibrium curl up = equilibrium > its prior value AND its prior value >= its value two bars ago
Calculation: Bearish reversal score = 0.20 × bearish close pressure + 0.22 × upper-wick percentage + 0.15 × bearish body pressure + 0.13 × participation score + 0.18 × bearish momentum-state score + 0.12 × bearish rail score
Calculation: Bullish reversal score = 0.20 × bullish close pressure + 0.22 × lower-wick percentage + 0.15 × bullish body pressure + 0.13 × participation score + 0.18 × bullish momentum-state score + 0.12 × bullish rail score
Calculation: Close-position percentage = (close - low) / (high - low) × 100; use 50 when high = low
Calculation: Body percentage = absolute(close - open) / (high - low) × 100; use 0 when high = low
Calculation: Upper-wick percentage = (high - max(open, close)) / (high - low) × 100; use 0 when high = low
Calculation: Lower-wick percentage = (min(open, close) - low) / (high - low) × 100; use 0 when high = low
Calculation: Bearish close pressure = 100 - close-position percentage
Calculation: Bullish close pressure = close-position percentage
Calculation: Bearish body pressure = body percentage if close < open, otherwise 0.20 × body percentage
Calculation: Bullish body pressure = body percentage if close > open, otherwise 0.20 × body percentage
Calculation: Channel-position percentage = clamped (close - lower rail) / (upper rail - lower rail) × 100; use 50 if the rail range is not greater than the minimum tick
Calculation: Bearish rail score = clamp((channel-position percentage - 45) / 55 × 100, 0, 100)
Calculation: Bullish rail score = clamp((55 - channel-position percentage) / 55 × 100, 0, 100)
Calculation: Momentum state = hysteretic up/down states for EMA-smoothed momentum and its change; momentum is EMA(close) minus its value at a shorter lookback, then EMA-smoothed; its change is the smoothed momentum minus its value at a shorter lookback. Each state turns up above its own EMA of absolute value times a buffer percentage and stays up while above the negative buffer. Bearish momentum-state score = 100 when momentum is up and its change is down, 70 when both are down, 25 when both are up, otherwise 45. Bullish momentum-state score = 100 when momentum is down and its change is up, 70 when both are up, 25 when both are down, otherwise 45
Calculation: Participation score = 50 when volume average is unavailable; if volume / its longer-term average is at least 1.35 or bar range / its longer-term average is at least 1.20, clamp (volume ratio / 1.8 × 100) to 0–100; otherwise clamp (volume ratio / 2.2 × 100) to 20–80
Calculation: Bearish rejection = upper-wick percentage >= 25 OR (close < open AND body percentage >= 35) OR close-position percentage <= 42
Calculation: Bullish rejection = lower-wick percentage >= 25 OR (close > open AND body percentage >= 35) OR close-position percentage >= 58
Calculation: Bearish reversal pressure = trend is up, trend is not changing, close >= equilibrium, channel-position percentage >= 60, (equilibrium curls down OR equilibrium slope relative to rail range <= 0.05 OR bearish rejection), and bearish reversal score >= its threshold
Calculation: Bullish reversal pressure = trend is down, trend is not changing, close <= equilibrium, channel-position percentage <= 40, (equilibrium curls up OR equilibrium slope relative to rail range >= -0.05 OR bullish rejection), and bullish reversal score >= its threshold
Long: close >= open OR bullish reversal pressure, no chop suppression, and current bar is at least the cooldown interval after the previous warning
Short: close < open OR bearish reversal pressure, no chop suppression, and current bar is at least the cooldown interval after the previous warning