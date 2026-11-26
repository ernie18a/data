Calculation: prior high = highest high over the most recent completed regular session
Calculation: prior low = lowest low over the most recent completed regular session
Calculation: overnight high = highest high over the most recent overnight session, using only its bars so far if that session is still forming
Calculation: overnight low = lowest low over the most recent overnight session, using only its bars so far if that session is still forming
Calculation: high cluster = abs(overnight high - prior high) <= close * cluster tolerance / 100
Calculation: low cluster = abs(overnight low - prior low) <= close * cluster tolerance / 100
Calculation: prior high active = NOT (high cluster AND prior high < overnight high)
Calculation: overnight high active = NOT (high cluster AND overnight high < prior high)
Calculation: prior low active = NOT (low cluster AND prior low > overnight low)
Calculation: overnight low active = NOT (low cluster AND overnight low > prior low)
Calculation: L = prior high, prior low, overnight high, or overnight low
Calculation: long sweep bar(L) = most recent bar s up to the current bar, within the current regular session, where L active AND low < L AND close[1] > L
Calculation: short sweep bar(L) = most recent bar s up to the current bar, within the current regular session, where L active AND high > L AND close[1] < L
Calculation: long stop(L, e) = lowest low from long sweep bar(L) at bar e through bar e - stop buffer * close(e) / 100
Calculation: short stop(L, e) = highest high from short sweep bar(L) at bar e through bar e + stop buffer * close(e) / 100
Calculation: long target(L, e) = lowest active level above L at bar e
Calculation: short target(L, e) = highest active level below L at bar e
Long: L active AND close > L AND all closes from long sweep bar(L) through the prior bar are <= L AND count of closes at or below L from long sweep bar(L) through the prior bar <= max closes beyond level AND bars from long sweep bar(L) to the current bar <= max bars to reclaim AND min depth <= (L - lowest low from long sweep bar(L) through the current bar) / L * 100 <= max depth AND (close - low) / (high - low) >= reclaim close fraction AND (close > open OR color filter disabled) AND (current bar in window 1 OR current bar in window 2) AND abs(long target(L, current bar) - close) / abs(close - long stop(L, current bar)) >= min R:R
Short: L active AND close < L AND all closes from short sweep bar(L) through the prior bar are >= L AND count of closes at or above L from short sweep bar(L) through the prior bar <= max closes beyond level AND bars from short sweep bar(L) to the current bar <= max bars to reclaim AND min depth <= (highest high from short sweep bar(L) through the current bar - L) / L * 100 <= max depth AND (close - low) / (high - low) <= 1 - reclaim close fraction AND (close < open OR color filter disabled) AND (current bar in window 1 OR current bar in window 2) AND abs(short target(L, current bar) - close) / abs(short stop(L, current bar) - close) >= min R:R
Long: L active AND L <= close
Short: L active AND L > close
Exit: long, low <= long stop(L, entry bar) OR high >= entry price + T1 multiple * (entry price - long stop(L, entry bar)) OR high >= long target(L, entry bar)
Exit: short, high >= short stop(L, entry bar) OR low <= entry price - T1 multiple * (short stop(L, entry bar) - entry price) OR low <= short target(L, entry bar)