Calculation: Prior T1 high = high of the last completed T1 bar, carried onto chart bars with gaps off and lookahead off
Calculation: Prior T1 low = low of the last completed T1 bar, carried onto chart bars with gaps off and lookahead off
Calculation: Prior-range midpoint = (prior T1 high + prior T1 low) / 2
Calculation: Midpoint band = abs(prior T1 high - prior T1 low) × midpoint-band parameter
Calculation: Confirmation-symbol OHLC = confirmation instrument OHLC at chart timeframe, sampled on chart bars with gaps off and lookahead off; the current bar may still be forming
Calculation: Swing high = latest confirmed Pivot High(high, pivot lookback, pivot lookback) on chart bars
Calculation: Swing low = latest confirmed Pivot Low(low, pivot lookback, pivot lookback) on chart bars
Calculation: Bearish sweep reference = prior T1 high if no swing high exists, otherwise max(prior T1 high, swing high)
Calculation: Bullish sweep reference = prior T1 low if no swing low exists, otherwise min(prior T1 low, swing low)
Calculation: Bearish liquidity sweep = high > bearish sweep reference AND close < bearish sweep reference
Calculation: Bullish liquidity sweep = low < bullish sweep reference AND close > bullish sweep reference
Calculation: Bearish MSS = swing low exists AND close < swing low
Calculation: Bullish MSS = swing high exists AND close > swing high
Calculation: Bearish displacement = high - low > ATR(ATR lookback) × displacement multiplier AND (high - low > 0 ? abs(close - open) / (high - low) : 0) >= minimum body ratio AND close <= low + (high - low) × close-near-edge parameter
Calculation: Bullish displacement = high - low > ATR(ATR lookback) × displacement multiplier AND (high - low > 0 ? abs(close - open) / (high - low) : 0) >= minimum body ratio AND close >= high - (high - low) × close-near-edge parameter
Calculation: Bearish SMT = chart high > highest(chart high[1], SMT lookback) AND confirmation-symbol high <= highest(confirmation-symbol high[1], SMT lookback)
Calculation: Bullish SMT = chart low < lowest(chart low[1], SMT lookback) AND confirmation-symbol low >= lowest(confirmation-symbol low[1], SMT lookback)
Calculation: Short confirmation = selected confirmation mode uses either confirmation-symbol close < EMA(confirmation-symbol close, EMA lookback, chart timeframe, current bar), that condition OR bearish SMT, or confirmation-symbol close <= that EMA
Calculation: Long confirmation = selected confirmation mode uses either confirmation-symbol close > EMA(confirmation-symbol close, EMA lookback, chart timeframe, current bar), that condition OR bullish SMT, or confirmation-symbol close >= that EMA
Calculation: Valid bearish FVG = high < low[2] AND low[2] - high >= minimum FVG size in ticks × minimum tick size; zone bottom = high and zone top = low[2]
Calculation: Valid bullish FVG = low > high[2] AND low - high[2] >= minimum FVG size in ticks × minimum tick size; zone bottom = high[2] and zone top = low
Calculation: Short bias permitted = configured bias permits short trades
Calculation: Long bias permitted = configured bias permits long trades
Calculation: Entry session permitted = chart time is within the configured primary session or an enabled secondary session, in the configured timezone, AND the weekday restriction permits that day
Calculation: Active bearish FVG zone and short stop = zone from the latest qualifying bearish setup, retained until consumed by an entry or expired after setup lookback × expiry multiplier chart bars; a later setup replaces it; stop = max(setup-bar high, bearish sweep reference at setup) + stop-buffer parameter × minimum tick size
Calculation: Active bullish FVG zone and long stop = zone from the latest qualifying bullish setup, retained until consumed by an entry or expired after setup lookback × expiry multiplier chart bars; a later setup replaces it; stop = min(setup-bar low, bullish sweep reference at setup) - stop-buffer parameter × minimum tick size
Calculation: Long initial risk = entry price - long setup stop
Calculation: Short initial risk = short setup stop - entry price
Long: Bullish liquidity sweep
Long: Bullish MSS
Long: Entry session permitted AND long bias permitted AND close < prior-range midpoint - midpoint band AND bullish liquidity sweep, bullish displacement, and bullish MSS have each occurred within the setup lookback chart bars AND valid bullish FVG AND long confirmation
Short: Bearish liquidity sweep
Short: Bearish MSS
Short: Entry session permitted AND short bias permitted AND close > prior-range midpoint + midpoint band AND bearish liquidity sweep, bearish displacement, and bearish MSS have each occurred within the setup lookback chart bars AND valid bearish FVG AND short confirmation
Long: position is flat AND entries opened since the current T1 boundary < daily trade-limit parameter AND Entry session permitted AND Long bias permitted AND Long confirmation AND active bullish FVG zone exists AND high >= its bottom AND low <= its top AND close - long setup stop > minimum tick size AND close - long setup stop <= maximum stop-distance parameter
Short: position is flat AND entries opened since the current T1 boundary < daily trade-limit parameter AND Entry session permitted AND Short bias permitted AND Short confirmation AND active bearish FVG zone exists AND high >= its bottom AND low <= its top AND short setup stop - close > minimum tick size AND short setup stop - close <= maximum stop-distance parameter
Exit: Long, low <= the long setup stop until high reaches entry price + long initial risk × break-even trigger parameter, then low <= max(long setup stop, entry price), OR high >= entry price + long initial risk × target parameter
Exit: Short, high >= the short setup stop until low reaches entry price - short initial risk × break-even trigger parameter, then high >= min(short setup stop, entry price), OR low <= entry price - short initial risk × target parameter
Calculation: Allowed session = within the configured New York Open session OR (the configured New York PM session is enabled AND the time is within it), subject to the configured time zone and Monday block setting
Calculation: Prior-day midpoint = (prior T1 high + prior T1 low) / 2
Calculation: Prior-day midpoint band = abs(prior T1 high - prior T1 low) × configured midpoint-band percentage
Calculation: Bearish sweep reference = prior T1 high if no confirmed Pivot High exists; otherwise max(prior T1 high, latest confirmed Pivot High)
Calculation: Bullish sweep reference = prior T1 low if no confirmed Pivot Low exists; otherwise min(prior T1 low, latest confirmed Pivot Low)
Calculation: Candle body-to-range ratio = abs(close - open) / (high - low)
Calculation: Bearish displacement = high - low > ATR(configured length) × configured ATR multiple AND candle body-to-range ratio ≥ configured minimum AND close ≤ low + (high - low) × configured close-edge percentage
Calculation: Bullish displacement = high - low > ATR(configured length) × configured ATR multiple AND candle body-to-range ratio ≥ configured minimum AND close ≥ high - (high - low) × configured close-edge percentage
Calculation: Bearish liquidity sweep = traded-instrument high > bearish sweep reference AND traded-instrument close < bearish sweep reference
Calculation: Bullish liquidity sweep = traded-instrument low < bullish sweep reference AND traded-instrument close > bullish sweep reference
Calculation: Bearish fair-value gap = traded-instrument high < traded-instrument low at the configured FVG offset AND the difference is at least configured minimum gap ticks × tick size
Calculation: Bullish fair-value gap = traded-instrument low > traded-instrument high at the configured FVG offset AND the difference is at least configured minimum gap ticks × tick size
Calculation: Bearish SMT divergence = traded-instrument high > its highest high over the preceding configured SMT lookback AND S&P 500 high ≤ its highest high over the same preceding bars
Calculation: Bullish SMT divergence = traded-instrument low < its lowest low over the preceding configured SMT lookback AND S&P 500 low ≥ its lowest low over the same preceding bars
Calculation: Bearish S&P 500 confirmation = (confirmation mode is strict AND S&P 500 close < EMA of S&P 500 close at configured length) OR (confirmation mode is balanced AND (S&P 500 close < that EMA OR bearish SMT divergence)) OR (confirmation mode is loose AND S&P 500 close ≤ that EMA)
Calculation: Bullish S&P 500 confirmation = (confirmation mode is strict AND S&P 500 close > EMA of S&P 500 close at configured length) OR (confirmation mode is balanced AND (S&P 500 close > that EMA OR bullish SMT divergence)) OR (confirmation mode is loose AND S&P 500 close ≥ that EMA)
Calculation: Active bearish fair-value gap = latest bearish fair-value gap recorded by a bearish setup, retained until more than configured expiry multiplier × setup lookback chart bars after setup or a short entry; its stop level is max(setup-bar high, bearish sweep reference at setup) + configured stop-buffer ticks × tick size
Calculation: Active bullish fair-value gap = latest bullish fair-value gap recorded by a bullish setup, retained until more than configured expiry multiplier × setup lookback chart bars after setup or a long entry; its stop level is min(setup-bar low, bullish sweep reference at setup) - configured stop-buffer ticks × tick size
Long: allowed session AND bias setting is bullish or mixed AND traded-instrument close > prior-day midpoint + prior-day midpoint band AND a bullish liquidity sweep occurred within the configured setup lookback AND bullish displacement occurred within that lookback AND traded-instrument close exceeded a latest confirmed Pivot High within that lookback AND bullish fair-value gap AND bullish S&P 500 confirmation
Short: allowed session AND bias setting is bearish or mixed AND traded-instrument close < prior-day midpoint - prior-day midpoint band AND a bearish liquidity sweep occurred within the configured setup lookback AND bearish displacement occurred within that lookback AND traded-instrument close fell below a latest confirmed Pivot Low within that lookback AND bearish fair-value gap AND bearish S&P 500 confirmation
Long: position is flat AND trades today < configured daily trade limit AND allowed session AND traded-instrument high ≥ active bullish fair-value gap lower bound AND traded-instrument low ≤ its upper bound AND traded-instrument close - active bullish fair-value gap stop level > configured minimum stop-distance ticks × tick size AND that distance ≤ configured maximum stop distance AND bias setting is bullish or mixed AND bullish S&P 500 confirmation
Short: position is flat AND trades today < configured daily trade limit AND allowed session AND traded-instrument high ≥ active bearish fair-value gap lower bound AND traded-instrument low ≤ its upper bound AND active bearish fair-value gap stop level - traded-instrument close > configured minimum stop-distance ticks × tick size AND that distance ≤ configured maximum stop distance AND bias setting is bearish or mixed AND bearish S&P 500 confirmation