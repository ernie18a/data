Calculation: Donchian midpoint = (highest(high, lookback) + lowest(low, lookback)) / two
Calculation: Tenkan = Donchian midpoint(high, low, Tenkan lookback)
Calculation: Kijun = Donchian midpoint(high, low, Kijun lookback)
Calculation: Cloud A = ((Tenkan + Kijun) / two)[cloud displacement]
Calculation: Cloud B = Donchian midpoint(high, low, Cloud B lookback)[cloud displacement]
Calculation: Cloud top = max(Cloud A, Cloud B)
Calculation: Cloud bottom = min(Cloud A, Cloud B)
Calculation: Cloud thickness = Cloud top - Cloud bottom
Calculation: RSI slope = RSI(close, RSI lookback) - RSI(close, RSI lookback)[RSI slope lag]
Calculation: MACD slope = MACD histogram(close, fast lookback, slow lookback, signal lookback) - MACD histogram(close, fast lookback, slow lookback, signal lookback)[MACD slope lag]
Calculation: DI momentum = ((positive DI - negative DI) - (positive DI - negative DI)[DI momentum lag]), where positive DI and negative DI are from DMI(high, low, close, DMI lookback)
Calculation: Cloud gap in ATR = (Cloud bottom - close) / max(ATR(ATR lookback), minimum tick size)
Calculation: Cloud thickness in ATR = Cloud thickness / max(ATR(ATR lookback), minimum tick size)
Calculation: Under cloud = full-candle-under-cloud requirement ? high < Cloud bottom : close < Cloud bottom
Calculation: Near cloud = Cloud gap in ATR > zero and Cloud gap in ATR <= maximum Rocket gap in ATR
Calculation: Candle range = high - low
Calculation: Body percentage = abs(close - open) / max(Candle range, minimum tick size)
Calculation: Close position = (close - low) / max(Candle range, minimum tick size)
Calculation: Range in ATR = Candle range / max(ATR(ATR lookback), minimum tick size)
Calculation: Body in ATR = abs(close - open) / max(ATR(ATR lookback), minimum tick size)
Calculation: Upper wick percentage = (high - max(open, close)) / max(Candle range, minimum tick size)
Calculation: Compression in ATR = (highest(high, compression lookback) - lowest(low, compression lookback)) / max(ATR(ATR lookback), minimum tick size)
Calculation: Compressed = Compression in ATR <= maximum compression
Calculation: RSI slope = RSI(close, RSI lookback) - RSI(close, RSI lookback)[RSI slope lag]
Calculation: DI spread = positive DI - negative DI, where positive DI and negative DI are from DMI(high, low, close, DMI lookback)
Calculation: Pressure = (max(RSI slope, pressure floor) * max(Range in ATR, pressure floor)) / max(Cloud gap in ATR * Compression in ATR, pressure floor)
Calculation: Pressure slope = Pressure - Pressure[pressure slope lag]
Calculation: Impulse strength = Body percentage * Close position * Range in ATR
Calculation: Momentum composite = max(RSI slope, zero) + max(MACD slope, zero) + max(DI momentum, zero)
Calculation: Coil quality = Compression in ATR / max(Cloud gap in ATR, coil gap floor)
Calculation: Cloud travel potential = Range in ATR / max(Cloud thickness in ATR, minimum cloud thickness in ATR)
Calculation: Cloud touch = high >= Cloud bottom
Calculation: Cloud pierce percentage = Cloud touch ? (min(high, Cloud top) - Cloud bottom) / max(Cloud thickness, minimum tick size) : zero
Calculation: Kijun gap in ATR = (Kijun - close) / max(ATR(ATR lookback), minimum tick size)
Calculation: Tenkan slope in ATR = (Tenkan - Tenkan[Tenkan slope lag]) / max(ATR(ATR lookback), minimum tick size)
Calculation: Future cloud bullish = Cloud A > Cloud B
Calculation: Clean thrust = Range in ATR >= clean-thrust range threshold AND Impulse strength >= clean-thrust impulse threshold AND Close position >= clean-thrust close-position threshold AND Cloud gap in ATR <= clean-thrust gap threshold
Calculation: Ignition momentum = RSI slope >= ignition RSI-slope threshold AND Momentum composite >= ignition momentum threshold
Calculation: Early cloud conversion = Cloud pierce percentage >= early pierce threshold OR Clean thrust
Calculation: Strong candle rescue = Close position >= rescue close-position threshold AND Body in ATR >= rescue body threshold AND RSI slope >= rescue RSI-slope threshold AND Cloud gap in ATR <= rescue gap threshold
Calculation: Early trap = NOT Strong candle rescue AND NOT Clean thrust AND NOT Future cloud bullish AND Cloud thickness in ATR >= early-trap cloud-thickness threshold AND Upper wick percentage >= early-trap wick threshold
Calculation: Violent cloud engagement = Cloud pierce percentage >= violent pierce threshold AND Range in ATR >= violent range threshold AND Body in ATR >= violent body threshold AND (Close position >= violent close-position threshold OR (Close position >= alternate violent close-position threshold AND Impulse strength >= alternate violent impulse threshold AND Upper wick percentage <= alternate violent wick threshold) OR (Close position >= alternate violent close-position threshold AND Kijun gap in ATR <= violent Kijun-gap threshold AND RSI slope >= violent RSI-slope threshold))
Calculation: Clean rip candle = Strong candle rescue AND Range in ATR >= clean-rip range threshold AND Impulse strength >= clean-rip impulse threshold
Calculation: Rip quality = (Violent cloud engagement OR Clean rip candle) AND RSI slope >= rip RSI-slope threshold AND Cloud gap in ATR <= rip gap threshold AND (Pressure slope >= rip pressure-slope threshold OR Ignition momentum OR Strong candle rescue)
Calculation: God displacement quality = Range in ATR >= God range threshold OR Impulse strength >= God impulse threshold OR (Close position >= God close-position threshold AND Upper wick percentage <= God wick threshold) OR (Range in ATR >= alternate God range threshold AND Kijun gap in ATR <= God Kijun-gap threshold AND RSI slope >= God RSI-slope threshold)
Calculation: Confirmed trap = NOT Rip quality AND NOT Clean thrust AND NOT Future cloud bullish AND Tenkan slope in ATR <= zero AND Kijun gap in ATR >= confirmed-trap Kijun-gap threshold AND Cloud travel potential < confirmed-trap travel threshold AND Cloud pierce percentage <= confirmed-trap pierce threshold
Calculation: Thin-cloud exhaustion = Cloud pierce percentage >= exhaustion pierce threshold AND Cloud thickness in ATR <= exhaustion thickness threshold AND NOT Future cloud bullish AND NOT Violent cloud engagement AND NOT Clean thrust AND NOT Strong candle rescue AND RSI slope < exhaustion RSI-slope threshold
Calculation: Cloud reject probe = Cloud touch AND Cloud pierce percentage >= reject pierce threshold AND Close position <= reject close-position threshold AND Upper wick percentage >= reject wick threshold AND NOT Rip quality AND NOT Strong candle rescue AND NOT Clean thrust
Calculation: Shallow weak probe = Cloud touch AND Cloud pierce percentage <= shallow pierce threshold AND Kijun gap in ATR < zero AND Impulse strength < shallow impulse threshold AND NOT Ignition momentum AND NOT Rip quality AND NOT Strong candle rescue AND NOT Clean thrust
Calculation: Confirmed air pocket = NOT Cloud touch AND NOT Early cloud conversion AND NOT Rip quality AND NOT Clean thrust
Calculation: Post-move Kijun reject = Kijun gap in ATR >= post-move Kijun-gap threshold AND Tenkan slope in ATR <= zero AND Close position <= post-move close-position threshold AND Upper wick percentage >= post-move wick threshold AND RSI slope < post-move RSI-slope threshold AND NOT Rip quality AND NOT Strong candle rescue AND NOT Clean thrust
Calculation: Confirmed soft pop = Cloud touch AND Cloud pierce percentage <= soft-pop pierce threshold AND Cloud travel potential < soft-pop travel threshold AND Tenkan slope in ATR <= soft-pop Tenkan-slope threshold AND RSI slope < soft-pop RSI-slope threshold AND NOT Rip quality AND NOT Violent cloud engagement AND NOT Strong candle rescue
Calculation: God structure quality = Tenkan slope in ATR >= zero OR Impulse strength >= God structure impulse threshold OR Close position >= God structure close-position threshold OR Kijun gap in ATR <= God structure Kijun-gap threshold
Calculation: Thin-cloud overrun trap = Cloud thickness in ATR <= overrun thickness threshold AND Cloud travel potential >= overrun travel threshold AND Cloud pierce percentage >= overrun pierce threshold AND NOT Rip quality AND NOT Strong candle rescue AND NOT Clean thrust
Calculation: Early Kijun overhead trap = Kijun gap in ATR >= early Kijun-gap threshold AND RSI slope < early Kijun RSI-slope threshold AND Cloud pierce percentage <= early Kijun pierce threshold AND NOT Rip quality AND NOT Strong candle rescue AND NOT Clean thrust
Calculation: Weak air-pocket launch = NOT Cloud touch AND NOT God displacement quality AND NOT God structure quality AND NOT Rip quality AND NOT Strong candle rescue AND NOT Clean thrust
Calculation: Shallow God engagement trap = Cloud touch AND Cloud pierce percentage <= shallow God pierce threshold AND Cloud travel potential <= shallow God travel threshold AND Kijun gap in ATR > shallow God Kijun-gap threshold AND Tenkan slope in ATR < shallow God Tenkan-slope threshold AND NOT Violent cloud engagement
Calculation: Confirmed low-momentum pop = RSI slope < low-momentum RSI-slope threshold AND Close position <= low-momentum close-position threshold AND Upper wick percentage >= low-momentum wick threshold AND Impulse strength < low-momentum impulse threshold AND NOT Rip quality AND NOT Violent cloud engagement AND NOT Strong candle rescue
Calculation: Rocket base = Under cloud AND Near cloud AND Compressed AND close > open AND Close position >= Rocket close-position threshold AND Body percentage >= Rocket body threshold
Calculation: God Rocket = Rocket base AND God displacement quality AND God structure quality AND NOT Thin-cloud overrun trap AND NOT Shallow God engagement trap AND ((Cloud gap in ATR <= God gap threshold AND Pressure slope >= God pressure-slope threshold AND Range in ATR >= God range threshold AND Impulse strength >= God impulse threshold AND Close position >= God close-position threshold AND RSI slope >= God RSI-slope threshold AND Coil quality >= God coil-quality threshold AND Momentum composite >= God momentum threshold) OR Rip quality)
Calculation: Confirmed Rocket = Rocket base AND NOT God Rocket AND NOT Confirmed trap AND NOT Cloud reject probe AND NOT Shallow weak probe AND NOT Confirmed air pocket AND NOT Confirmed soft pop AND NOT Thin-cloud overrun trap AND NOT Shallow God engagement trap AND NOT Confirmed low-momentum pop AND Pressure slope >= confirmed pressure-slope threshold AND Pressure >= confirmed pressure threshold AND Cloud gap in ATR <= confirmed gap threshold AND Range in ATR >= confirmed range threshold AND Close position >= confirmed close-position threshold AND RSI slope >= confirmed RSI-slope threshold AND Impulse strength >= confirmed impulse threshold AND (Ignition momentum OR Cloud travel potential >= confirmed travel threshold)
Calculation: Early Rocket = Rocket base AND NOT God Rocket AND NOT Confirmed Rocket AND NOT Early trap AND NOT Thin-cloud exhaustion AND NOT Cloud reject probe AND NOT Shallow weak probe AND NOT Post-move Kijun reject AND NOT Confirmed soft pop AND NOT Thin-cloud overrun trap AND NOT Early Kijun overhead trap AND NOT Weak air-pocket launch AND NOT Shallow God engagement trap AND Pressure >= early pressure threshold AND Cloud gap in ATR <= early gap threshold AND Range in ATR >= early range threshold AND (Early cloud conversion OR Strong candle rescue) AND ((Pressure slope >= early pressure-slope threshold AND RSI slope >= early RSI-slope threshold) OR Clean thrust OR Strong candle rescue)
Calculation: Raw Rocket = God Rocket OR Confirmed Rocket OR Early Rocket
Calculation: Cooldown clear = no Raw Rocket on the prior bar OR bars since Raw Rocket on the prior bar > Rocket cooldown length
Calculation: Rocket = Raw Rocket AND Cooldown clear
Calculation: Advance in ATR = max((close - close[advance lookback ago]) / max(ATR(ATR lookback), minimum tick size), minimum advance)
Calculation: Bars to cloud = Cloud gap in ATR / Advance in ATR
Calculation: Pre-Rocket trap = (Upper wick percentage >= pre-Rocket wick threshold AND Close position <= pre-Rocket close-position threshold) OR (Kijun gap in ATR >= pre-Rocket Kijun-gap threshold AND RSI slope < pre-Rocket RSI-slope threshold) OR (Tenkan slope in ATR <= pre-Rocket Tenkan-slope threshold AND NOT Strong candle rescue)
Calculation: Pre-Rocket score = min(score cap, distance score + timing score + momentum score + candle score + structure score + compression score); distance score awards the highest applicable score for Cloud gap in ATR being at or below its closest, middle, or maximum distance cutoff; timing score awards the highest applicable score for Bars to cloud being at or below its closest, middle, or maximum timing cutoff; momentum score awards the highest applicable score for RSI slope or Momentum composite meeting its strongest, middle, or minimum threshold; candle score awards the highest applicable score for Close position and Body percentage meeting their strongest thresholds, or Close position meeting its middle or minimum threshold; structure score awards its higher score when close > Tenkan and Tenkan slope in ATR >= zero, its middle score when either is true, and zero otherwise; compression score awards its higher score when Compression in ATR <= maximum compression, its lower score when Compression in ATR <= pre-Rocket maximum compression, and zero otherwise
Calculation: Pre-Rocket candidate = pre-Rocket display enabled AND Under cloud AND Cloud gap in ATR > maximum Rocket gap in ATR AND Cloud gap in ATR <= pre-Rocket maximum gap in ATR AND Compression in ATR <= pre-Rocket maximum compression AND close > open AND Close position >= pre-Rocket close-position threshold AND Body percentage >= pre-Rocket body threshold AND RSI slope >= pre-Rocket RSI-slope threshold AND Bars to cloud <= pre-Rocket maximum bars to cloud
Long: Rocket OR (Pre-Rocket candidate AND Pre-Rocket score >= red score threshold AND NOT Rocket)
Calculation: Campaign entry, stop, and signal low = close, Rocket stop, and low, respectively, on the latest Rocket bar
Calculation: Rocket stop = min(min(low, lowest low over Rocket swing lookback) - ATR(ATR lookback) * stop buffer for Rocket tier, close - ATR(ATR lookback) * minimum stop distance for Rocket tier)
Calculation: Rocket campaign active = a Rocket has occurred within the campaign duration and no campaign stop break has occurred since that Rocket; reset these campaign states on each Rocket
Calculation: Campaign high = highest high since the latest Rocket, including the Rocket bar
Calculation: Campaign had push = after the Rocket bar, at least one active campaign bar had (Campaign high - Campaign entry) / max(ATR(ATR lookback), minimum tick size) >= campaign push threshold
Calculation: Campaign stop break = close < Campaign stop OR (low < Campaign stop AND close < Campaign signal low)
Calculation: Campaign weak rejection = Campaign had push AND Close position <= campaign weak-close threshold AND Upper wick percentage >= campaign upper-wick threshold
Calculation: Campaign Tenkan loss = Campaign had push AND close < Tenkan AND close < close[one bar ago]
Calculation: Campaign healthy pullback = Campaign had push AND low > Campaign stop + ATR(ATR lookback) * campaign reload-stop buffer AND Close position >= campaign pullback close-position threshold AND (low <= Tenkan OR low <= Kijun OR close <= Campaign entry + ATR(ATR lookback) * campaign entry buffer)
Calculation: Campaign re-entry setup = a campaign reload was armed on an earlier bar AND close > high[one bar ago] AND close > Tenkan AND RSI slope >= campaign re-entry RSI-slope threshold AND Impulse strength >= campaign re-entry impulse threshold
Long: campaign squares enabled AND Rocket campaign active AND no campaign re-entry has occurred AND NOT Campaign stop break AND Campaign healthy pullback
Long: campaign squares enabled AND Rocket campaign active AND no campaign re-entry has occurred AND no campaign stop break AND Campaign re-entry setup
Exit: long, campaign squares enabled AND Rocket campaign active AND Campaign had push AND no earlier campaign warning or danger AND (Campaign weak rejection OR Campaign Tenkan loss) AND NOT Campaign stop break
Exit: long, campaign squares enabled AND Rocket campaign active AND no earlier campaign danger AND Campaign stop break
Calculation: Support true range average = SMA(true range, support ATR lookback)
Calculation: Support ATR stop = lowest low over support low lookback - Support true range average * support ATR buffer multiplier
Calculation: Frozen support stop = lowest prior Support ATR stop over support reclaim window
Calculation: Support trend pass = trend filter disabled OR close > SMA(close, support trend lookback)
Calculation: Support volume pass = volume filter disabled OR volume > SMA(volume, support volume lookback)
Calculation: Support reclaim armed = a confirmed low below Frozen support stop occurred while the virtual support position was flat, remains within the reclaim window, and has not been cleared by a valid support long; capture the Frozen support stop on the first breach and track the lowest low from that breach onward
Calculation: Support reclaim signal = confirmed bar AND virtual support position flat AND Support reclaim armed AND bars since captured breach <= support reclaim window AND close > captured Frozen support stop AND close > open AND Support trend pass AND Support volume pass
Calculation: Support coil setup = close > Support ATR stop AND (close - Support ATR stop) / Support true range average <= support coil-distance threshold
Calculation: Support coil signal = confirmed bar AND virtual support position flat AND Support coil setup AND close > open AND close > close[one bar ago] AND Support trend pass AND Support volume pass
Calculation: Support signal stop = min(Support ATR stop, reclaim signal ? min(tracked capitulation low, lowest low over support reclaim window) : lowest low over support reclaim window)
Calculation: Support signal risk = close - Support signal stop
Calculation: Valid support long = (Support reclaim signal OR Support coil signal) AND Support signal risk > minimum tick size
Calculation: Support virtual entry = close on the latest valid support long
Calculation: Support virtual initial risk = Support virtual entry - Support signal stop on the latest valid support long
Calculation: Support virtual first and second targets = Support virtual entry + Support virtual initial risk * first target multiple, and Support virtual entry + Support virtual initial risk * second target multiple
Calculation: Support trailing stop = the highest Support ATR stop since the latest valid support long, starting from its initial stop
Calculation: Support active stop = initial stop until the first target is reached, then entry until the second target is reached, then max(entry, Support trailing stop); update target and stop state after each bar
Calculation: Support virtual position flat = no valid support long remains open; a position opens on a valid support long and closes when a later low <= the prior-bar Support active stop, before evaluating that bar's support signal
Long: Valid support long AND Support virtual position flat
Exit: long, support virtual position open AND low <= prior-bar Support active stop
Exit: long, crosses below Support ATR stop
Calculation: Angled Rocket stop = for each retained Rocket stop line, Rocket stop at its start bar + ATR saved at that bar * angled-stop rise per bar * bars since that bar; the line remains active until tagged
Exit: long, trade map enabled AND angled stop enabled AND an active Angled Rocket stop has age greater than zero and low <= that stop line