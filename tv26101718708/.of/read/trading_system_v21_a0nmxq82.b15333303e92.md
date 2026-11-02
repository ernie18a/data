Calculation: Short and long EMAs are EMAs of close, with the short EMA using a shorter lookback.
Calculation: Active swing levels are confirmed pivot highs or lows with equal left and right lookbacks; retain at most a configurable number of the most recently confirmed levels per side, including taken levels. A level becomes taken on the first bar after or including confirmation whose close breaks it or whose wick sweeps it.
Calculation: Active fair value gaps are created when low > high two bars ago for a bullish gap, or high < low two bars ago for a bearish gap. Their bounds are those two prices. Retain at most a configurable number of the most recently created gaps per direction. An unflipped bullish gap flips bearish when close < its lower bound; an unflipped bearish gap flips bullish when close > its upper bound. A flipped bullish-origin gap is removed when close > its upper bound; a flipped bearish-origin gap is removed when close < its lower bound. Remove gaps older than a configurable maximum age, unless age-based removal is disabled; process a flip or opposite-bound removal before age-based removal.
Long: Short EMA crosses above long EMA.
Short: Short EMA crosses below long EMA.
Long: Short EMA > long EMA AND low <= short EMA AND close > short EMA AND short EMA did not cross above long EMA on the current bar.
Short: Short EMA < long EMA AND high >= short EMA AND close < short EMA AND short EMA did not cross below long EMA on the current bar.
Long: Short EMA > long EMA AND low <= long EMA AND close > long EMA.
Short: Short EMA < long EMA AND high >= long EMA AND close < long EMA.
Long: Short EMA > long EMA AND close > short EMA AND previous close <= previous short EMA.
Short: Short EMA < long EMA AND close < short EMA AND previous close >= previous short EMA.
Long: Close two bars ago < open two bars ago AND previous close > previous open AND previous low > low two bars ago AND previous close < open two bars ago AND close > previous high AND close > open.
Short: Close two bars ago > open two bars ago AND previous close < previous open AND previous high < high two bars ago AND previous close > open two bars ago AND close < previous low AND close < open.
Long: Previous close < previous open AND close > open AND close > previous high AND close - open > a configurable fraction of previous high - previous low.
Short: Previous close > previous open AND close < open AND close < previous low AND open - close > a configurable fraction of previous high - previous low.
Long: Low > high two bars ago.
Short: High < low two bars ago.
Long: Close > upper bound of an active unflipped bearish fair value gap.
Short: Close < lower bound of an active unflipped bullish fair value gap.
Long: Low < an untaken active swing low AND close >= that level.
Short: High > an untaken active swing high AND close <= that level.