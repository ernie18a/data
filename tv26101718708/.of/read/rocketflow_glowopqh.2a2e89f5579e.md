Calculation: Ichimoku cloud = upper and lower of the two Ichimoku spans, using their displaced values from earlier bars on the chart timeframe
Calculation: Cloud gap (ATR) = (cloud lower - close) / ATR
Calculation: Cloud thickness (ATR) = (cloud upper - cloud lower) / ATR
Calculation: Compression (ATR) = (highest high - lowest low over the configured compression lookback) / ATR
Calculation: Close position = (close - low) / (high - low)
Calculation: Body fraction = abs(close - open) / (high - low)
Calculation: Range (ATR) = (high - low) / ATR
Calculation: Body (ATR) = abs(close - open) / ATR
Calculation: RSI slope = RSI - RSI from the configured earlier chart bar
Calculation: Impulse strength = body fraction * close position * range (ATR)
Calculation: MACD histogram slope = MACD histogram - its value from the configured earlier chart bar
Calculation: DI momentum = (positive DI - negative DI) - its value from the configured earlier chart bar
Calculation: Momentum composite = max(RSI slope, 0) + max(MACD histogram slope, 0) + max(DI momentum, 0)
Calculation: Pressure = (max(RSI slope, 0.1) * max(range (ATR), 0.1)) / max(cloud gap (ATR) * compression (ATR), 0.1)
Calculation: Pressure slope = pressure - its value from the configured earlier chart bar
Calculation: Coil quality = compression (ATR) / max(cloud gap (ATR), 0.05)
Calculation: Cloud travel potential = range (ATR) / max(cloud thickness (ATR), 0.10)
Calculation: Cloud pierce fraction = 0 if high is below cloud lower; otherwise (min(high, cloud upper) - cloud lower) / (cloud upper - cloud lower)
Calculation: Kijun gap (ATR) = (Kijun - close) / ATR
Calculation: Tenkan slope (ATR) = (Tenkan - Tenkan from the configured earlier chart bar) / ATR
Calculation: Clean thrust = range (ATR) >= configured minimum AND impulse strength >= configured minimum AND close position >= configured minimum AND cloud gap (ATR) <= configured maximum
Calculation: Strong candle rescue = close position >= configured minimum AND body (ATR) >= configured minimum AND RSI slope >= configured minimum AND cloud gap (ATR) <= configured maximum
Calculation: Ignition momentum = RSI slope >= configured minimum AND momentum composite >= configured minimum
Calculation: Rip quality = (violent cloud engagement OR clean rip candle) AND RSI slope >= configured minimum AND cloud gap (ATR) <= configured maximum AND (pressure slope >= configured minimum OR ignition momentum OR strong candle rescue); violent cloud engagement and clean rip candle use the source's candle, cloud pierce, RSI, Kijun, and impulse comparisons
Calculation: God displacement quality = range (ATR) >= configured minimum OR impulse strength >= configured minimum OR (close position >= configured minimum AND upper wick fraction <= configured maximum) OR (range (ATR) >= configured minimum AND Kijun gap (ATR) <= configured maximum AND RSI slope >= configured minimum)
Calculation: God structure quality = Tenkan slope (ATR) >= 0 OR impulse strength >= configured minimum OR close position >= configured minimum OR Kijun gap (ATR) <= configured maximum
Calculation: Base Rocket conditions = price is under the cloud (close below its lower edge, or the full candle below it when that option is enabled) AND cloud gap (ATR) > 0 and <= configured maximum AND compression (ATR) <= configured maximum AND close > open AND close position >= configured minimum AND body fraction >= configured minimum
Calculation: God Rocket = base Rocket conditions AND god displacement quality AND god structure quality AND NOT thin cloud overrun trap AND NOT shallow God engagement trap AND ((cloud gap (ATR) <= configured maximum AND pressure slope, range (ATR), impulse strength, close position, RSI slope, coil quality, and momentum composite each meet their configured minimums) OR rip quality); thin cloud overrun trap and shallow God engagement trap use the source's cloud, momentum, and structure comparisons
Calculation: Confirmed Rocket = base Rocket conditions AND NOT God Rocket AND NOT confirmed trap block AND NOT cloud reject probe AND NOT shallow weak probe AND NOT confirmed air pocket AND NOT confirmed soft pop AND NOT thin cloud overrun trap AND NOT shallow God engagement trap AND NOT confirmed low momentum pop AND pressure slope, pressure, cloud gap (ATR), range (ATR), close position, RSI slope, and impulse strength meet their configured thresholds AND (ignition momentum OR cloud travel potential >= configured minimum); each excluded trap uses the source's cloud, candle, momentum, and structure comparisons
Calculation: Early Rocket = base Rocket conditions AND NOT God Rocket AND NOT Confirmed Rocket AND NOT early trap block AND NOT thin cloud exhaustion AND NOT cloud reject probe AND NOT shallow weak probe AND NOT post-move Kijun reject AND NOT confirmed soft pop AND NOT thin cloud overrun trap AND NOT early Kijun overhead trap AND NOT weak air pocket launch AND NOT shallow God engagement trap AND pressure, cloud gap (ATR), and range (ATR) meet their configured thresholds AND (early cloud conversion OR strong candle rescue) AND ((pressure slope and RSI slope meet their configured minimums) OR clean thrust OR strong candle rescue); each excluded trap uses the source's cloud, candle, momentum, and structure comparisons
Calculation: Rocket cooldown clear = no Rocket occurred during the configured cooldown period before the current bar
Calculation: Final Rocket = God Rocket OR Confirmed Rocket OR Early Rocket, and Rocket cooldown clear
Calculation: Pre-Rocket score = sum of the source's distance, timing, momentum, candle, Tenkan structure, and compression scores, capped at 100; each component uses its configured threshold comparisons
Calculation: Pre-Rocket candidate = price is under the cloud AND cloud gap (ATR) > configured near-cloud maximum and <= configured pre-Rocket maximum AND compression (ATR) <= configured pre-Rocket maximum AND close > open AND close position and body fraction meet configured minimums AND RSI slope meets its configured minimum AND bars-to-cloud <= configured maximum AND NOT pre-trap; bars-to-cloud is cloud gap (ATR) divided by max((close - close from the configured earlier chart bar) / ATR, 0.01); pre-trap uses the source's upper-wick, close-position, Kijun-gap, RSI-slope, and Tenkan-slope comparisons
Calculation: Pre-Rocket red = pre-Rocket candidate AND score >= configured red minimum AND score < configured yellow minimum
Calculation: Pre-Rocket yellow = pre-Rocket candidate AND score >= configured yellow minimum AND score < configured green minimum
Calculation: Pre-Rocket dark green = pre-Rocket candidate AND score >= configured green minimum
Calculation: ATR support stop = lowest low over the configured lookback - configured multiple of the configured simple moving average of true range
Calculation: Frozen support stop = lowest ATR support stop among the configured number of preceding bars
Calculation: Support reclaim setup = while flat, a confirmed bar's low breaks below the frozen support stop; within the configured reclaim window, close > captured frozen support stop AND close > open AND enabled trend and volume filters pass
Calculation: Support coil setup = while flat, close > ATR support stop AND (close - ATR support stop) / configured ATR <= configured maximum AND close > open AND close > prior close AND enabled trend and volume filters pass
Calculation: Support long is valid = support reclaim setup OR support coil setup, AND close - min(ATR support stop, relevant recent swing low, and for reclaim the captured capitulation low) > minimum tick
Calculation: Campaign stop break = close < the stop recorded at the Rocket signal OR (low < that stop AND close < the Rocket signal bar's low)
Calculation: Campaign exit warning = after a Rocket push of at least the configured ATR amount, (close position <= configured maximum AND upper wick fraction >= configured minimum OR close < Tenkan AND close < prior close), and NOT campaign stop break
Calculation: Campaign danger = campaign stop break
Calculation: Campaign healthy pullback = after the configured Rocket push, low > recorded stop + configured ATR buffer AND close position >= configured minimum AND (low <= Tenkan OR low <= Kijun OR close <= Rocket entry + configured ATR allowance)
Calculation: Campaign re-entry setup = reload was armed by a healthy pullback AND close > prior high AND close > Tenkan AND RSI slope and impulse strength meet configured minimums
Calculation: Support virtual active stop = initial stop until first risk target is reached; entry price until second target is reached; thereafter max(entry price, highest ATR support stop since entry)
Calculation: Support stop hit = low <= support virtual active stop
Calculation: Angled trailing stop hit = for any active Rocket stop, after its signal bar, low <= signal stop + signal-bar ATR * configured rise per bar * bars since signal
Long: Final Rocket
Long: Pre-Rocket red OR Pre-Rocket yellow OR Pre-Rocket dark green
Long: Support long is valid AND flat
Long: Campaign healthy pullback
Long: Campaign re-entry setup
Exit: long, Campaign exit warning OR Campaign danger OR Angled trailing stop hit
Exit: long, Support stop hit