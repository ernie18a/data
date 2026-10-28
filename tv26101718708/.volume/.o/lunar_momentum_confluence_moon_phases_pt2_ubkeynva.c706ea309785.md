Calculation: Lunar bias = −cos(2π × lunar age / synodic month), where lunar age is the elapsed fraction of a synodic month since a known new moon, calculated from the bar timestamp
Calculation: Bull momentum score = weighted sum of bullish trend, close above slow EMA, RSI above its threshold (with an extra component for exceeding it further), bullish MACD histogram, close above session VWAP, bullish volume participation, and higher-timeframe bullish alignment; clamp to 0–100
Calculation: Bear momentum score = weighted sum of bearish trend, close below slow EMA, RSI below its threshold (with an extra component for falling further below it), bearish MACD histogram, close below session VWAP, bearish volume participation, and higher-timeframe bearish alignment; clamp to 0–100
Calculation: Long confluence = 0.74 × bull momentum score + 0.26 × max(lunar bias, 0) × 100, with a full-moon bonus; clamp to 0–100
Calculation: Short confluence = 0.74 × bear momentum score + 0.26 × max(−lunar bias, 0) × 100, with a new-moon bonus; clamp to 0–100
Calculation: Bullish trend = close above trend EMA AND fast EMA above slow EMA AND fast EMA rising
Calculation: Bearish trend = close below trend EMA AND fast EMA below slow EMA AND fast EMA falling
Calculation: Bullish volume participation = relative volume above its threshold AND close above open AND close in the upper portion of the bar AND body size above an ATR-based minimum
Calculation: Bearish volume participation = relative volume above its threshold AND close below open AND close in the lower portion of the bar AND body size above an ATR-based minimum
Calculation: Long trigger = (close above the highest high of prior bars over the breakout lookback AND close above open) OR (lowest low over the pullback lookback at or below fast EMA AND close above fast EMA AND close above open AND close above prior close)
Calculation: Short trigger = (close below the lowest low of prior bars over the breakout lookback AND close below open) OR (highest high over the pullback lookback at or above fast EMA AND close below fast EMA AND close below open AND close below prior close)
Calculation: Long stop = lowest low over the swing lookback minus an ATR-based buffer
Calculation: Short stop = highest high over the swing lookback plus an ATR-based buffer
Calculation: Long target 2 = entry price + long risk × target 2 risk multiple, where long risk is the greater of entry price minus long stop and a minimum tick-based risk
Calculation: Short target 2 = entry price − short risk × target 2 risk multiple, where short risk is the greater of short stop minus entry price and a minimum tick-based risk
Long: confirmed bar AND long direction enabled AND long cooldown elapsed AND lunar bias above its threshold AND bull momentum score above its minimum AND long confluence above its minimum AND long trigger AND (higher-timeframe close above trend EMA AND fast EMA above slow EMA, using the last completed higher-timeframe bar, unless the higher-timeframe filter is disabled)
Short: confirmed bar AND short direction enabled AND short cooldown elapsed AND lunar bias below the negative threshold AND bear momentum score above its minimum AND short confluence above its minimum AND short trigger AND (higher-timeframe close below trend EMA AND fast EMA below slow EMA, using the last completed higher-timeframe bar, unless the higher-timeframe filter is disabled)
Exit: long, low at or below long stop OR high at or above long target 2 OR short decision
Exit: short, high at or above short stop OR low at or below short target 2 OR long decision