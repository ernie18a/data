Calculation: Directional midpoint = average of EMA(close, shorter EMA lookback) and HMA(close, max(shorter HMA minimum lookback, shorter EMA lookback − shorter HMA offset))
Calculation: Structural midpoint = average of EMA(close, longer EMA lookback) and HMA(close, max(longer HMA minimum lookback, longer EMA lookback − longer HMA offset))
Calculation: Regime strength = clamp(0, 100, (abs(directional midpoint − structural midpoint) / ATR(ATR lookback), treating a zero denominator as zero) × spread weight + abs((close − rolling lowest low over heat lookback) / max(rolling highest high over heat lookback − rolling lowest low over heat lookback, tick size) × 100 − 50) × heat-deviation weight)
Calculation: Regime persistence = a counter that increments when directional midpoint > structural midpoint has the same truth value as on the previous chart bar, and resets to zero otherwise
Calculation: Liquidity bias = (buy-bin volume − sell-bin volume) / max(buy-bin volume + sell-bin volume, liquidity volume floor), where the rolling high-to-low price range over the liquidity lookback is divided into liquidity bins, each bar's volume is assigned to the bin containing its (high + low + close) / 3 using that range, and close >= open assigns volume to buy bins while close < open assigns it to sell bins
Calculation: Bullish context = directional midpoint > structural midpoint AND regime strength >= regime strength floor AND regime persistence >= regime persistence floor AND liquidity bias > liquidity bias floor AND close >= EMA(close, liquidity reference lookback) AND close > (latest confirmed pivot low, or rolling lowest low over swing lookback if none) AND close > EMA(close, longer EMA lookback)
Calculation: Bearish context = directional midpoint <= structural midpoint AND regime strength >= regime strength floor AND regime persistence >= regime persistence floor AND liquidity bias < −liquidity bias floor AND close <= EMA(close, liquidity reference lookback) AND close < (latest confirmed pivot high, or rolling highest high over swing lookback if none) AND close < EMA(close, longer EMA lookback)
Calculation: Pressure RSI = RSI(MOM(close, shift momentum lookback), shift RSI lookback)
Calculation: Displacement = clamp(0, 100, (abs(EMA(close, shorter EMA lookback) − EMA(close, longer EMA lookback)) / ATR(ATR lookback), treating a zero denominator as zero) × displacement spread weight + abs(pressure RSI − 50))
Calculation: Bullish shift = confirmed chart bar AND displacement >= displacement floor AND pressure RSI > upper shift RSI threshold AND close > EMA(close, shorter EMA lookback) AND directional midpoint > structural midpoint
Calculation: Bearish shift = confirmed chart bar AND displacement >= displacement floor AND pressure RSI < lower shift RSI threshold AND close < EMA(close, shorter EMA lookback) AND directional midpoint < structural midpoint
Calculation: Bullish continuation = confirmed chart bar AND continuation triggers enabled AND pressure RSI >= continuation pressure floor AND close > directional midpoint AND low <= EMA(close, shorter EMA lookback)
Calculation: Bearish continuation = confirmed chart bar AND continuation triggers enabled AND pressure RSI <= 100 − continuation pressure floor AND close < directional midpoint AND high >= EMA(close, shorter EMA lookback)
Calculation: Bullish gap = confirmed chart bar AND sufficient gap history AND low > high[gap lookback] AND high[intermediate-bar lookback] > high[gap lookback] AND (low − high[gap lookback]) / max(standard deviation of (low − high[gap lookback]) over gap normalization lookback, tick size) > gap size threshold
Calculation: Bearish gap = confirmed chart bar AND sufficient gap history AND high < low[gap lookback] AND low[intermediate-bar lookback] < low[gap lookback] AND (low[gap lookback] − high) / max(standard deviation of (low[gap lookback] − high) over gap normalization lookback, tick size) > gap size threshold
Calculation: Bullish trigger = bullish gap OR bullish shift OR bullish continuation
Calculation: Bearish trigger = bearish gap OR bearish shift OR bearish continuation
Long: bullish context
Short: bearish context
Long: liquidity bias >= 0
Short: liquidity bias < 0
Long: pressure RSI >= RSI midpoint
Short: pressure RSI < RSI midpoint
Long: bullish shift
Short: bearish shift
Long: bullish continuation
Short: bearish continuation
Long: bullish trigger
Short: bearish trigger
Long: bullish context AND displacement >= displacement floor
Short: bearish context AND displacement >= displacement floor
Long: confirmed chart bar AND bullish context AND bullish trigger AND position is flat or short
Short: confirmed chart bar AND bearish context AND bearish trigger AND position is flat or long
Calculation: Initial long stop = min(signal-bar close − ATR(ATR lookback) × stop ATR multiple, min(signal-bar low, latest confirmed pivot low or rolling lowest low over swing lookback if none) − ATR(ATR lookback) × long invalidation buffer)
Calculation: Initial short stop = max(signal-bar close + ATR(ATR lookback) × stop ATR multiple, max(signal-bar high, latest confirmed pivot high or rolling highest high over swing lookback if none) + ATR(ATR lookback) × short invalidation buffer)
Calculation: Long initial risk = max(signal-bar close − initial long stop, tick size × minimum-risk tick count)
Calculation: Short initial risk = max(initial short stop − signal-bar close, tick size × minimum-risk tick count)
Calculation: First and second long targets = signal-bar close + long initial risk × their respective target R parameters
Calculation: First and second short targets = signal-bar close − short initial risk × their respective target R parameters
Calculation: Active long stop starts at the initial long stop and, when trailing is enabled and regime strength >= strong-regime threshold, ratchets upward each position bar to max(previous active long stop, rolling lowest low over trailing lookback − ATR(ATR lookback) × long trailing buffer)
Calculation: Active short stop starts at the initial short stop and, when trailing is enabled and regime strength >= strong-regime threshold, ratchets downward each position bar to min(previous active short stop, rolling highest high over trailing lookback + ATR(ATR lookback) × short trailing buffer)
Exit: long, low <= active long stop OR high >= first long target OR high >= second long target
Exit: short, high >= active short stop OR low <= first short target OR low <= second short target