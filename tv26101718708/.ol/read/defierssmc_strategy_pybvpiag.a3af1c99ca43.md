Calculation: Confirmed swing high/low = a bar whose high/low is the highest/lowest across the configured number of bars before and after it; use only after the following bars confirm it.
Calculation: Bullish/bearish structure event = confirmed close above the latest swing high while trend is nonbullish / below the latest swing low while trend is nonbearish (BOS), or above the latest lower high while trend is bearish / below the latest higher low while trend is bullish (CHoCH). A CHoCH is also MSS when the candle body is at least the configured ATR multiple.
Calculation: Bullish/bearish trend state = +1/-1 after the respective structure event; otherwise retain the prior state.
Calculation: Bullish/bearish liquidity sweep = high above a buy-side liquidity level and close below it / low below a sell-side liquidity level and close above it. Liquidity levels are formed by pairs of confirmed swing highs/lows within the configured clustering tolerance.
Calculation: Recent bullish/bearish structure = bullish/bearish trend state with a structure event within the configured recency lookback.
Calculation: Recent bullish/bearish sweep = latest sweep was a sell-side/buy-side sweep and is within the configured sweep recency lookback.
Calculation: Equilibrium = midpoint of the latest confirmed swing high and swing low.
Calculation: Bullish/bearish point of interest = current bar range intersects an active, unmitigated bullish/bearish order block or fair value gap, or the OTE zone between the 62% and 79% retracement levels of the latest swing range. An order block is the nearest prior opposite-color candle within the configured search lookback after a BOS, with volume at least the configured multiple of its moving average; a fair value gap is the gap between the current bar and the bar two bars earlier, at least the configured ATR multiple in size, and not fully mitigated.
Calculation: Long/short factor score = 100 × (0.25 × aligned higher-timeframe bias × session weight + 0.20 × recent aligned structure + 0.20 × recent aligned liquidity sweep + 0.20 × aligned point of interest + 0.15 × correct discount/premium location). The higher-timeframe bias is the last completed bar's close above/below its 50-period EMA. Session weight is 1, or the configured reduced weight outside allowed sessions.
Calculation: Long/short factor count = number of active aligned factors among higher-timeframe bias, recent structure, recent sweep, point of interest, and discount/premium location; a point of interest counts when present at least at OTE strength.
Long: confirmed bullish BOS or CHoCH
Long: confirmed bullish MSS
Long: confirmed sell-side liquidity sweep
Long: flat position AND allowed to open longs AND not blocked by opposing higher-timeframe bias AND not blocked by session filter AND long score >= regime-adjusted score threshold AND long factor count >= configured minimum AND every enabled mandatory long factor is active AND potential reward-to-risk >= configured minimum
Short: confirmed bearish BOS or CHoCH
Short: confirmed bearish MSS
Short: confirmed buy-side liquidity sweep
Short: flat position AND allowed to open shorts AND not blocked by opposing higher-timeframe bias AND not blocked by session filter AND short score >= regime-adjusted score threshold AND short factor count >= configured minimum AND every enabled mandatory short factor is active AND potential reward-to-risk >= configured minimum
Exit: long, low <= active stop OR (high >= first profit target and first target has not been taken) OR high >= second profit target
Exit: short, high >= active stop OR (low <= first profit target and first target has not been taken) OR low <= second profit target