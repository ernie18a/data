Calculation: Structural center = mean of Donchian midpoint(tenkan lookback), Donchian midpoint(kijun lookback), their mean, and Donchian midpoint(span-B lookback)
Calculation: Price band midpoint = SMA(hl2, band lookback)
Calculation: Mean bar range = SMA(high - low, band lookback)
Calculation: Regime lower bound = max(structural center - SMA(abs(close - open), body lookback) * body tolerance multiplier, price band midpoint - mean bar range * band scale / 100)
Calculation: Regime upper bound = min(structural center + SMA(abs(close - open), body lookback) * body tolerance multiplier, price band midpoint + mean bar range * band scale / 100)
Calculation: Relative range = mean bar range / max(SMA(mean bar range, band lookback), minimum tick)
Calculation: Directional regime = 1 when close > regime upper bound and close > structural center; -1 when close < regime lower bound and close < structural center; otherwise its previous value, initially 0
Calculation: Normalized candle force = 100 times the sum over the pressure lookback of signed candle bodies weighted by min(abs(close - open) / SMA(abs(close - open), pressure lookback), body weight cap), divided by pressure lookback times body weight cap; use zero weight when the average body is zero
Calculation: Pressure channel location = clamp(100 * (close - (price band midpoint - channel offset)) / max(2 * channel offset, minimum tick) - 50, -100, 100), where channel offset = SMA(high - low, pressure lookback) * channel scale / 100 * (1 + SMA(abs(close - open), pressure lookback) / max(SMA(high - low, pressure lookback), positive denominator floor))
Calculation: Pressure blend = EMA(normalized candle force * candle-force blend weight + pressure channel location * channel blend weight, pressure smoothing)
Calculation: Pressure signal = SMA(pressure blend, pressure signal lookback)
Calculation: Mapped center = lowest(low, mapping lookback) + EMA(RSI(close, RSI lookback), RSI smoothing) * max(highest(high, mapping lookback) - lowest(low, mapping lookback), minimum tick) / 100 * mapping stretch
Calculation: Upward mapping = close > mapped center and EMA(mapped center - mapped center[1], mapping-slope smoothing) >= 0
Calculation: Downward mapping = close < mapped center and EMA(mapped center - mapped center[1], mapping-slope smoothing) <= 0
Calculation: Bullish pressure = pressure blend > pressure threshold and pressure blend > pressure signal
Calculation: Bearish pressure = pressure blend < -pressure threshold and pressure blend < pressure signal
Calculation: Demand zone = latest bar with volume > SMA(volume, volume lookback) * volume impulse and close > open; its top is that bar's high and its bottom is max(that bar's low, that bar's close - ATR(zone lookback) * zone height); active while current bar index minus its creation bar index <= zone decay bars
Calculation: Supply zone = latest bar with volume > SMA(volume, volume lookback) * volume impulse and close < open; its bottom is that bar's low and its top is min(that bar's high, that bar's close + ATR(zone lookback) * zone height); active while current bar index minus its creation bar index <= zone decay bars
Calculation: Demand contact = demand zone active and close is between its bottom and top, inclusive
Calculation: Supply contact = supply zone active and close is between its bottom and top, inclusive
Calculation: Bullish structure = (latest confirmed pivot low, using pivot lookback bars on each side, is within structure decay bars of its pivot bar and close is above it) or demand contact
Calculation: Bearish structure = (latest confirmed pivot high, using pivot lookback bars on each side, is within structure decay bars of its pivot bar and close is below it) or supply contact
Calculation: Higher-timeframe bias = on each chart bar, compare the last completed T1 close with the last completed EMA(close, higher-timeframe EMA lookback, T1); return 1 if greater, -1 if less, otherwise 0
Calculation: Wave direction = the sign of the sum over the wave lookback of one-bar close directions when the selected method uses a multi-bar direction, using the prior bar's one-bar close direction when that sum is zero; otherwise use the current one-bar close direction
Calculation: Wave state = on confirmed chart bars, use wave direction if nonzero and otherwise retain the prior state, initially 0
Calculation: Wave accumulation = wave size plus prior accumulation when current and prior wave states match, otherwise wave size; wave size is abs(close - open) plus (high - low) * shadow fraction when shadow use is enabled, otherwise abs(close - open)
Calculation: Wave strength = wave accumulation / SMA(wave accumulation, twice the wave lookback), or 0 when that SMA is zero
Calculation: Bullish wave = wave state is 1 and wave strength >= wave-strength threshold
Calculation: Bearish wave = wave state is -1 and wave strength >= wave-strength threshold
Calculation: Bullish release = confirmed chart bar, Relative range[1] <= compression threshold, Relative range > compression threshold, and bullish wave
Calculation: Bearish release = confirmed chart bar, Relative range[1] <= compression threshold, Relative range > compression threshold, and bearish wave
Calculation: Directional score = directional regime + one vote for bullish pressure or minus one for bearish pressure + one vote for upward mapping or minus one for downward mapping + one vote for bullish structure or minus one for bearish structure + one vote for bullish wave or minus one for bearish wave + higher-timeframe bias when its filter is enabled
Long: directional regime > 0
Short: directional regime < 0
Long: confirmed chart bar and directional regime is 1 and its prior value was not 1
Short: confirmed chart bar and directional regime is -1 and its prior value was not -1
Long: pressure blend >= pressure signal
Short: pressure blend < pressure signal
Long: upward mapping
Short: downward mapping
Long: bullish structure
Short: bearish structure
Long: wave state is 1
Short: wave state is -1
Long: directional score > 0
Short: directional score < 0
Long: bullish release
Short: bearish release
Long: long entries enabled, position flat or short, confirmed chart bar, directional regime >= 0, at least the stack-count parameter of bullish pressure, upward mapping, bullish structure, and bullish wave, higher-timeframe filter disabled or higher-timeframe bias >= 0, and (release required and (bullish release or bullish wave) or release not required and bullish wave and Relative range > compression threshold), and (demand retest required and demand contact or demand retest not required and (bullish structure or close > structural center)), and (confirmed pressure blend cross above pressure signal or close crosses above mapped center or close crosses above structural center)
Short: short entries enabled, position flat or long, confirmed chart bar, directional regime <= 0, at least the stack-count parameter of bearish pressure, downward mapping, bearish structure, and bearish wave, higher-timeframe filter disabled or higher-timeframe bias <= 0, and (release required and (bearish release or bearish wave) or release not required and bearish wave and Relative range > compression threshold), and (supply retest required and supply contact or supply retest not required and (bearish structure or close < structural center)), and (confirmed pressure blend cross below pressure signal or close crosses below mapped center or close crosses below structural center)
Calculation: Long initial stop = entry price - ATR(risk lookback) * stop multiple
Calculation: Long target = entry price + ATR(risk lookback) * stop multiple * reward-to-risk parameter
Calculation: Long trail activation price = entry price + max(entry price - long initial stop, minimum tick) * trail activation parameter
Calculation: Long trailing level = absent until high >= long trail activation price; then max of the prior trailing level, if present, and close - ATR(risk lookback) * trail distance parameter; otherwise retain the prior trailing level
Calculation: Effective long stop = max(long initial stop, long trailing level when present)
Calculation: Short initial stop = entry price + ATR(risk lookback) * stop multiple
Calculation: Short target = entry price - ATR(risk lookback) * stop multiple * reward-to-risk parameter
Calculation: Short trail activation price = entry price - max(short initial stop - entry price, minimum tick) * trail activation parameter
Calculation: Short trailing level = absent until low <= short trail activation price; then min of the prior trailing level, if present, and close + ATR(risk lookback) * trail distance parameter; otherwise retain the prior trailing level
Calculation: Effective short stop = min(short initial stop, short trailing level when present)
Exit: long, low <= effective long stop or high >= long target
Exit: short, high >= effective short stop or low <= short target
Exit: long, regime-failure exit enabled and confirmed chart bar and (directional regime < 0 or pressure blend < 0 or downward mapping)
Exit: short, regime-failure exit enabled and confirmed chart bar and (directional regime > 0 or pressure blend > 0 or upward mapping)
Exit: long or short, elapsed chart bars since entry >= maximum bars in trade