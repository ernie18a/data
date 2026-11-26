Calculation: VWAP component = clamp(VWAP-location coefficient × sign(close − daily-anchored VWAP) + VWAP-slope coefficient × sign(VWAP − VWAP[one chart bar ago]), component-score range); calculate on chart bars and reset the VWAP anchor at each day boundary.
Calculation: TICK component = clamp(EMA(configured TICK-series close at chart timeframe, TICK smoothing lookback) / TICK scale, component-score range); include only when its enable toggle is on and the value is available.
Calculation: VOLD component = clamp(z-score(configured up-volume-series close − configured down-volume-series close, shared z-score lookback) / shared z-score scale, component-score range); include only when its enable toggle is on and both values are available.
Calculation: ADD component = clamp(configured advance-decline-series close at chart timeframe / ADD scale, component-score range); include only when its enable toggle is on and the value is available.
Calculation: CVD = cumulative sum on chart bars of volume when close > open, negative volume when close < open, or zero when equal or volume is unavailable; reset at each day boundary.
Calculation: CVD component = clamp(z-score(CVD − CVD[CVD-change lookback], shared z-score lookback) / shared z-score scale, component-score range); include when volume is available and positive.
Calculation: MACD component = clamp(MACD histogram(close, fast lookback, slow lookback, signal lookback) / (ATR(ATR lookback) × MACD-to-ATR scale), component-score range); include when the histogram is available.
Calculation: MFI component = clamp((MFI(hlc3, MFI lookback) − MFI midpoint) / MFI scale, component-score range); include when volume is available and positive and MFI is available.
Calculation: low-VIX regime = configured volatility-index series close at chart timeframe < VIX threshold when its enable toggle is on and its value is available; otherwise true.
Calculation: RSI component = positive extreme score when RSI(close, RSI lookback) < extreme-oversold threshold; negative extreme score when it > extreme-overbought threshold; positive moderate score when it < oversold threshold; negative moderate score when it > overbought threshold; otherwise zero. Include only in the low-VIX regime.
Calculation: master score = weighted mean of the VWAP, TICK, VOLD, ADD, CVD, MACD, MFI, and RSI components, using a separate weight parameter for each; include only components meeting their stated availability, enable, and regime conditions, and return zero when the total included weight is zero.
Calculation: buffer = ATR-buffer multiple × ATR(ATR lookback) in ATR mode, otherwise point buffer.
Calculation: put short strike = floor-to-strike-increment(close − buffer); call short strike = ceil-to-strike-increment(close + buffer).
Calculation: sigma = max(expected-move input when positive, otherwise ATR(ATR lookback) × sqrt(max(one chart bar, POP horizon in chart bars)), positive sigma floor).
Calculation: drift = master score × directional-drift factor × sigma.
Calculation: put POP percent = 100 × standard-normal-CDF((close + drift − put short strike) / sigma).
Calculation: call POP percent = 100 × standard-normal-CDF((call short strike − close − drift) / sigma).
Long: VWAP component > component-arrow threshold
Short: VWAP component < negative component-arrow threshold
Long: TICK component > component-arrow threshold
Short: TICK component < negative component-arrow threshold
Long: VOLD component > component-arrow threshold
Short: VOLD component < negative component-arrow threshold
Long: ADD component > component-arrow threshold
Short: ADD component < negative component-arrow threshold
Long: CVD component > component-arrow threshold
Short: CVD component < negative component-arrow threshold
Long: MACD component > component-arrow threshold
Short: MACD component < negative component-arrow threshold
Long: MFI component > component-arrow threshold
Short: MFI component < negative component-arrow threshold
Long: RSI component > component-arrow threshold
Short: RSI component < negative component-arrow threshold
Long: master score > score threshold
Short: master score < negative score threshold
Long: master score crosses above score threshold AND put POP percent >= minimum POP
Short: master score crosses below negative score threshold AND call POP percent >= minimum POP
Long: master score > negative score threshold AND put POP percent >= minimum POP
Short: master score < score threshold AND call POP percent >= minimum POP
Calculation: Master score = weighted mean of active component scores, or zero if none are active; each score is clamped to the normalized score limit. VWAP score = clamp(VWAP location factor × (close above T1-anchored VWAP ? normalized score limit : close below it ? negative normalized score limit : zero) + VWAP slope amount × (VWAP rising ? one : falling ? negative one : zero)). TICK score = clamp(EMA(TICK, TICK period) / TICK scale). VOLD score = clamp(Z-score(up volume minus down volume, Z-score period) / Z-score divisor). Breadth score = clamp(advance-decline breadth / breadth scale). Delta score = clamp(Z-score(CVD minus CVD lag bars earlier, Z-score period) / Z-score divisor), where CVD resets at T1 and each bar adds volume when close exceeds open, subtracts volume when close is below open, and adds zero otherwise. MACD score = clamp(MACD histogram(close, MACD fast period, MACD slow period, MACD signal period) / (ATR(ATR period) × MACD ATR factor)). MFI score = clamp((MFI(hlc3, MFI period) − MFI midpoint) / MFI scale). RSI score = normalized score limit when RSI(close, RSI period) is below the extreme low; negative normalized score limit when above the extreme high; positive RSI reversion contribution when below the mild low; negative RSI reversion contribution when above the mild high; otherwise zero. Include each component's separate weight in the weighted mean only when its data is valid and its enable parameter is on, if it has one; enable the RSI component when VIX filtering is off, VIX is unavailable, or VIX is below its threshold. Parameters: separate VWAP, TICK, VOLD, breadth, delta, MACD, MFI, and RSI weights; separate TICK, breadth, VIX-filter, and external-volume enable parameters; normalized score limit; VWAP location factor and slope amount; TICK period and scale; Z-score period and divisor; CVD lag; breadth scale; MACD fast, slow, and signal periods; ATR period and MACD ATR factor; MFI period, midpoint, and scale; RSI period, extreme low and high, mild low and high, and reversion contribution; VIX threshold.
Calculation: Expected move = maximum of the sigma floor and the positive expected-move override, or ATR(ATR period) × square root of the maximum of the minimum horizon and bars to expiration when there is no positive override.
Calculation: Directional drift = master score × directional drift factor × expected move.
Calculation: Put POP percentage = one hundred times the standard normal CDF of (close + directional drift − floor-to-strike-increment(close − selected strike buffer)) / expected move, where selected strike buffer is ATR(buffer period) × ATR buffer multiplier in ATR mode, otherwise the point buffer.
Calculation: Call POP percentage = one hundred times the standard normal CDF of (ceil-to-strike-increment(close + selected strike buffer) − close − directional drift) / expected move, where selected strike buffer is ATR(buffer period) × ATR buffer multiplier in ATR mode, otherwise the point buffer.
Long: master score > signal threshold
Short: master score < negative signal threshold
Option: sell put, master score > negative signal threshold AND Put POP percentage ≥ minimum POP percentage
Option: sell call, master score < signal threshold AND Call POP percentage ≥ minimum POP percentage
Option: sell put, master score crosses above signal threshold AND Put POP percentage ≥ minimum POP percentage
Option: sell call, master score crosses below negative signal threshold AND Call POP percentage ≥ minimum POP percentage