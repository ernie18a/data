Calculation: TF_S, TF_L, TF_W = three timeframes all higher than the chart timeframe, with TF_S < TF_L < TF_W. Every TF_S, TF_L and TF_W value used below is the chart bar's close compared against the data of the most recent bar of that timeframe, without lookahead.
Calculation: Score = 0 when the compared value is unavailable. Otherwise it is +1 / -1 / 0 as specified for each factor below. All factors are evaluated on the close of each completed chart bar.
Calculation: F1 = +1 if close > open of the currently forming TF_L bar, else -1
Calculation: F2 = +1 if close > high of the last completed TF_L bar; -1 if close < low of the last completed TF_L bar; else 0
Calculation: F3 = +1 if close > open of the currently forming TF_W bar, else -1
Calculation: F4 = +1 if close > EMA of closes on TF_L (value as of the last completed TF_L bar), else -1
Calculation: F5 = +1 if close > EMA of closes on TF_S (value as of the last completed TF_S bar), else -1; EMA length is the same as in F4
Calculation: F6 = +1 if close > session VWAP of hlc3 (resets each session), else -1
Calculation: F7 = regime-aware RSI of chart closes. Trending = ADX (Wilder, computed on a timeframe higher than the chart, value from the last completed bar) >= trend threshold. If trending: +1 if RSI > RSI midline, -1 if RSI < RSI midline, else 0. If not trending (including ADX unavailable): +1 if RSI < oversold level, -1 if RSI > overbought level, else 0
Calculation: F8 = direction of the last completed TF_S candle: +1 if close > open, -1 if close < open, else 0
Calculation: F9 = direction of the last completed TF_L candle: +1 if close > open, -1 if close < open, else 0
Calculation: F10 = market structure on a selected structure timeframe (TF_L or TF_S), using swing highs and swing lows (a pivot is a bar whose high/low is the extreme of N bars on each side, confirmed only after N bars have followed). +1 if the latest confirmed swing high > the previous swing high AND the latest confirmed swing low > the previous swing low; -1 if both are lower; else 0
Calculation: Tally = F1 + F2 + F3 + F4 + F5 + F6 + F7 + F8 + F9 + F10
Long: Tally > 0
Short: Tally < 0