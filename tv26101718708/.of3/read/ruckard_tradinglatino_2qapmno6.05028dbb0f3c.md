Calculation: Rolling VPOC = price-weighted midpoint of the highest-volume price bin in a rolling high-low range, allocating each bar's volume uniformly across its high-low range
Calculation: Support VPOC = highest rolling VPOC below current low over the support lookback, or current low if none
Calculation: Resistance VPOC = lowest rolling VPOC above current high over the support lookback, or current high if none
Calculation: Long stop price = max(support VPOC, entry price * (1 - minimum stop distance))
Calculation: Short stop price = min(resistance VPOC, entry price * (1 + minimum stop distance))
Calculation: Long trail activation price = entry price * ((reward-to-risk ratio * (1 + (entry price - long stop price) / entry price) * (1 + trail offset factor) + fee fraction) / (1 - fee fraction))
Calculation: Short trail activation price = entry price * ((1 / (reward-to-risk ratio * (1 + (short stop price - entry price) / entry price) * (1 + trail offset factor)) - fee fraction) / (1 + fee fraction))
Calculation: Long trail offset = long trail activation price * (long trail activation price / entry price - 1) * trail offset factor
Calculation: Short trail offset = short trail activation price * (1 - short trail activation price / entry price) * trail offset factor
Long: On chart bars, EMA(source, shorter lookback) > EMA(source, longer lookback) on each of the two last completed T1 bars
Short: On chart bars, EMA(source, shorter lookback) < EMA(source, longer lookback) on each of the two last completed T1 bars
Long: Squeeze Momentum value <= 0 and >= its prior value, or Squeeze Momentum value > 0 and > its prior value
Short: Squeeze Momentum value > 0 and <= its prior value, or Squeeze Momentum value <= 0 and < its prior value
Long: max(open, close) < EMA(source, longer lookback) + (EMA(source, shorter lookback) - EMA(source, longer lookback)) * near-EMA percentage
Short: min(open, close) > EMA(source, longer lookback) + (EMA(source, longer lookback) - EMA(source, shorter lookback)) * near-EMA percentage
Long: max(open, close) > support VPOC
Short: min(open, close) < resistance VPOC
Long: higher-timeframe EMA long advice AND Squeeze Momentum long advice AND close > support VPOC AND close * (1 - base stop-loss fraction) <= support VPOC AND (close / support VPOC < 1 + minimum stop distance OR 1 - support VPOC / close < maximum stop distance) AND time since previous order open >= cooldown duration
Short: higher-timeframe EMA short advice AND Squeeze Momentum short advice AND close < resistance VPOC AND close * (1 + base stop-loss fraction) >= resistance VPOC AND (resistance VPOC / close < 1 + minimum stop distance OR resistance VPOC / close - 1 < maximum stop distance) AND time since previous order open >= cooldown duration
Exit: long, (higher-timeframe EMA short advice AND NOT Squeeze Momentum short advice) OR (Squeeze Momentum short advice AND NOT higher-timeframe EMA short advice) OR (bars since entry >= order-age lookback AND close < entry price * (1 - minimum old-order loss fraction)) OR low <= long stop price OR (high >= long trail activation price AND low <= highest high since activation - long trail offset)
Exit: short, (higher-timeframe EMA long advice AND NOT Squeeze Momentum long advice) OR (Squeeze Momentum long advice AND NOT higher-timeframe EMA long advice) OR (bars since entry >= order-age lookback AND close > entry price * (1 + minimum old-order loss fraction)) OR high >= short stop price OR (low <= short trail activation price AND high >= lowest low since activation + short trail offset)