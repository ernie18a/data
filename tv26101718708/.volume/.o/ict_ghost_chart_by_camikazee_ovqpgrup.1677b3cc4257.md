Calculation: ATR = average true range
Calculation: EMAfast, EMAmid, EMAslow = exponential moving averages of close, ordered shortest to longest
Calculation: Volume spike = volume > average volume over a shorter lookback × a multiplier
Calculation: Confirmed swing high/low = pivot high/low confirmed after the same number of bars on each side
Calculation: Recent high/low = highest high / lowest low over a lookback, excluding the current bar
Calculation: Previous-day high/low = high/low of the last completed daily bar
Calculation: HTF equilibrium = midpoint of the highest high and lowest low over a lookback on the configured higher timeframe, including its still-forming bar
Calculation: Bullish displacement = close > open AND candle body > ATR × configured displacement multiplier; bearish displacement is the inverse
Calculation: Bullish FVG = current low > high two bars ago; bearish FVG = current high < low two bars ago
Calculation: High-quality FVG = candle body > ATR × a configured threshold; the higher quality tier also requires a volume spike
Calculation: Bullish FVG size = current low − high two bars ago; bearish FVG size = low two bars ago − current high
Calculation: Bullish sweep = low < previous-day low AND close > previous-day low, OR low < recent low AND close > recent low; bearish sweep = high > previous-day high AND close < previous-day high, OR high > recent high AND close < recent high
Calculation: Bullish MSS = a bullish sweep occurred within a configured maximum age AND current close > latest confirmed swing high AND current open < that swing high AND candle body > ATR × configured MSS threshold AND bullish displacement confirmation AND price is farther than a configured ATR distance from EMAfast AND, if enabled, EMAfast is rising over a configured lookback AND, if enabled, EMAs are bullishly ordered
Calculation: Bearish MSS = a bearish sweep occurred within a configured maximum age AND current close < latest confirmed swing low AND current open > that swing low AND candle body > ATR × configured MSS threshold AND bearish displacement confirmation AND price is farther than a configured ATR distance from EMAfast AND, if enabled, EMAfast is falling over a configured lookback AND, if enabled, EMAs are bearishly ordered
Calculation: Displacement confirmation for MSS = two consecutive displacement candles, or one displacement candle whose body exceeds a stricter configured ATR threshold
Calculation: Bullish CHOCH/BOS raw break = close crosses above latest confirmed swing high; bearish raw break = close crosses below latest confirmed swing low
Calculation: Structure displacement = candle body > ATR × configured structure threshold in the break direction
Calculation: Market state = direction of the latest confirmed internal CHOCH or BOS; starts neutral
Calculation: Bullish CHOCH = bullish raw break AND (confirmed-CHOCH filtering disabled OR market state is neutral/bearish AND bullish structure displacement); bearish CHOCH is the inverse
Calculation: Bullish BOS = bullish raw break AND bullish structure displacement AND market state is bullish; bearish BOS is the inverse
Calculation: External structure breaks = close crosses above/below the latest confirmed external swing high/low; external bullish/bearish CHOCH additionally requires neutral/opposite market state and structure displacement; external bullish/bearish BOS requires structure displacement
Calculation: Structure Engine 2 break = close crosses above/below the latest confirmed internal or swing pivot; each pivot can trigger once, and internal and swing engines maintain separate directional states
Calculation: Bullish/bearish Engine 2 CHOCH = corresponding Engine 2 break while that engine's prior state is opposite; otherwise its break is BOS
Calculation: Bullish inducement = low < latest confirmed inducement pivot low − ATR × configured sweep threshold AND close > that pivot AND lower wick ≥ ATR × configured wick threshold AND cooldown and new-level conditions pass AND, if enabled, market state is neutral/bullish; bearish inducement is the inverse
Calculation: Bullish exhaustion = high > prior high AND close < prior high AND, if strict filtering is enabled, upper wick > ATR × configured threshold AND a bearish sweep occurred if required AND price is above HTF equilibrium if required; bearish exhaustion is the inverse using a lower wick, bullish sweep, and price below equilibrium
Calculation: Bullish SMT = this instrument makes a lower low over a lookback while the configured correlated instrument does not; bearish SMT = this instrument makes a higher high while the correlated instrument does not
Calculation: Bullish trade score = 2 each for bullish sweep, bullish MSS, bullish displacement, bullish SMT, and close below HTF equilibrium; plus 1 each for an allowed ICT time window and volume spike
Calculation: Bearish trade score = 2 each for bearish sweep, bearish MSS, bearish displacement, bearish SMT, and close above HTF equilibrium; plus 1 each for an allowed ICT time window and volume spike
Calculation: Bullish probability score = 2 each for bullish sweep and SMT, 3 for bullish MSS, 2 each for bullish CHOCH, bullish BOS, and bullish displacement, and 1 each for close below HTF equilibrium, volume spike, allowed ICT time window, and bullish EMA ordering
Calculation: Bearish probability score = the inverse-side equivalents of the bullish probability score
Calculation: Bullish trend score = one point each for close > EMAfast, EMAfast > EMAmid, EMAmid > EMAslow, and close < HTF equilibrium; bearish trend score uses the inverse EMA comparisons and close > HTF equilibrium
Calculation: Bullish impulse size passes when |current high − lowest low over the configured longer dealing-leg lookback, excluding current bar| ≥ ATR × configured minimum; bearish impulse size uses |highest high over that lookback, excluding current bar − current low|
Calculation: Allowed ICT time window = within any configured London, New York, Silver Bullet, or Macro window
Long: bullish sweep
Long: bullish MSS
Long: bullish CHOCH
Long: bullish BOS
Long: external bullish CHOCH
Long: external bullish BOS
Long: bullish Engine 2 break (each pivot triggers once)
Long: bullish inducement
Long: bearish exhaustion
Long: bullish SMT
Long: bullish FVG AND high-quality FVG AND FVG size ≥ ATR × configured minimum AND middle candle body ≥ ATR × configured displacement threshold
Long: bullish MSS AND bullish FVG AND close < HTF equilibrium AND allowed ICT time window AND (configured FVG mode is aggressive OR (mode is balanced AND bullish trade score ≥ configured minimum AND (displacement filter disabled OR bullish displacement)) OR (mode is conservative AND bullish trade score ≥ configured A+ threshold AND (displacement filter disabled OR bullish displacement) AND (volume filter disabled OR volume spike))) AND bullish trend score ≥ configured minimum if trend-score filtering is enabled AND bullish impulse size passes AND bullish probability score ≥ configured minimum if probability-score filtering is enabled
Short: bearish sweep
Short: bearish MSS
Short: bearish CHOCH
Short: bearish BOS
Short: external bearish CHOCH
Short: external bearish BOS
Short: bearish Engine 2 break (each pivot triggers once)
Short: bearish inducement
Short: bullish exhaustion
Short: bearish SMT
Short: bearish FVG AND high-quality FVG AND FVG size ≥ ATR × configured minimum AND middle candle body ≥ ATR × configured displacement threshold
Short: bearish MSS AND bearish FVG AND close > HTF equilibrium AND allowed ICT time window AND (configured FVG mode is aggressive OR (mode is balanced AND bearish trade score ≥ configured minimum AND (displacement filter disabled OR bearish displacement)) OR (mode is conservative AND bearish trade score ≥ configured A+ threshold AND (displacement filter disabled OR bearish displacement) AND (volume filter disabled OR volume spike))) AND bearish trend score ≥ configured minimum if trend-score filtering is enabled AND bearish impulse size passes AND bearish probability score ≥ configured minimum if probability-score filtering is enabled