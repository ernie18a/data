Calculation: confirmed bar = live updating enabled OR bar is closed
Calculation: atr = ATR(ATR length)
Calculation: upper rail = Highest(high[1], trap lookback)
Calculation: lower rail = Lowest(low[1], trap lookback)
Calculation: upper probe = max((high - upper rail) / atr, 0)
Calculation: lower probe = max((lower rail - low) / atr, 0)
Calculation: upper trap thesis = high > upper rail + atr * min probe ATR AND close < upper rail AND close > (upper rail + lower rail) / 2
Calculation: lower trap thesis = low < lower rail - atr * min probe ATR AND close > lower rail AND close < (upper rail + lower rail) / 2
Calculation: candidate side = 1 if upper trap thesis AND (NOT lower trap thesis OR upper probe >= lower probe), else -1 if lower trap thesis, else 0
Calculation: trap live = active side[1] != 0 AND NOT qualified failure[1] AND trap age[1] + 1 <= failure window
Calculation: new trap = confirmed bar AND NOT trap live AND ((candidate side = 1 AND bull return allowed) OR (candidate side = -1 AND bear return allowed))
Calculation: trap age = 0 if new trap, else trap age[1] + 1
Calculation: active side = candidate side if new trap, else active side[1] if trap live, else 0
Calculation: trap edge = upper rail if new trap AND candidate side = 1; lower rail if new trap AND candidate side = -1; else trap edge[1]
Calculation: trap depth = high - upper rail if new trap AND candidate side = 1; lower rail - low if new trap AND candidate side = -1; else trap depth[1]
Calculation: trap probe = upper probe if new trap AND candidate side = 1; lower probe if new trap AND candidate side = -1; else trap probe[1]
Calculation: returned through edge = (active side = 1 AND close > trap edge + atr * control return buffer ATR) OR (active side = -1 AND close < trap edge - atr * control return buffer ATR)
Calculation: return closes = (returned through edge ? return closes[1] + 1 : 0) if confirmed bar AND active side != 0, else return closes[1]
Calculation: qualified failure = confirmed bar AND returned through edge AND return closes >= control return closes AND failure score >= minimum failure score
Calculation: move = active side * (close - trap edge)
Calculation: follow-through = ramp(move / atr, follow-through low bound, follow-through high bound)
Calculation: persistence = ramp(return closes, 0, max(control return closes, 1))
Calculation: failure score = 100 * clamp(false-break weight * tent(trap probe, min probe ATR, ideal probe ATR, large probe ATR) + recovery weight * ramp(move / trap depth, recovery low bound, recovery high bound) + follow-through weight * follow-through + volume weight * ramp(volume / SMA(volume, volume baseline length), volume low bound, volume high bound) + acceptance weight * clamp(acceptance close-location weight * close location + acceptance persistence weight * persistence + acceptance follow-through weight * follow-through, 0, 1) + persistence weight * persistence, 0, 1), where close location = (close - low) / (high - low) if active side = 1, else (high - close) / (high - low)
Calculation: ramp(x, lo, hi) = clamp((x - lo) / (hi - lo), 0, 1)
Calculation: tent(x, lo, ideal, hi) = ramp(x, lo, ideal) if x <= ideal, else 1 - ramp(x, ideal, hi), with lo < ideal < hi
Long: new trap AND candidate side = -1
Short: new trap AND candidate side = 1
Long: qualified failure AND active side = 1
Long: qualified failure AND active side = 1 AND failure score >= minimum alert score
Short: qualified failure AND active side = -1
Short: qualified failure AND active side = -1 AND failure score >= minimum alert score