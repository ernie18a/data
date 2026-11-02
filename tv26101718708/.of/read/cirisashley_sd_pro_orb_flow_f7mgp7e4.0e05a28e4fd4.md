Calculation: Fast and slow EMAs = EMAs of chart-bar close, with the fast lookback shorter than the slow lookback.
Calculation: Confirmed pivot high or low = a high or low confirmed after the specified number of right-side bars against the specified number of left-side bars; retain the latest confirmed value and update it before evaluating the current bar.
Calculation: Range ADX = EMA of DX, where positive directional movement is high minus previous high when positive and greater than previous low minus low, otherwise zero; negative directional movement is previous low minus low when positive and greater than high minus previous high, otherwise zero; positive and negative DI are the respective directional-movement EMAs divided by ATR; DX is the absolute DI difference divided by their sum. The directional-movement EMAs, ATR, and DX EMA use the same lookback.
Calculation: Range high and low = highest high and lowest low over the same lookback, including the current bar.
Calculation: Opening-range high and low = extrema of chart bars collected from a parameterized session open until its parameterized range end; maintain shorter and longer ranges for each of three parameterized sessions. Include the range-end bar for the shorter range of the first session and both ranges of the other sessions; exclude it for the longer range of the first session. Reset at each session open and retain the completed levels until the next reset.
Calculation: Opening-range break state = for each range and direction, record whether close has crossed its corresponding completed level since the latest session open; reset both states at that open. A cross above requires current close > current level AND previous close <= current level; a cross below requires current close < current level AND previous close >= current level.
Long: Fast EMA > slow EMA.
Short: Fast EMA < slow EMA.
Long: Close of the still-forming higher-timeframe bar > its EMA.
Short: Close of the still-forming higher-timeframe bar <= its EMA.
Long: Fast EMA > slow EMA AND low <= fast EMA + ATR multiplied by a threshold AND close > fast EMA AND previous close <= current fast EMA AND close > open AND close > previous high AND volume >= SMA of volume.
Short: Fast EMA < slow EMA AND high >= fast EMA - ATR multiplied by a threshold AND close < fast EMA AND previous close >= current fast EMA AND close < open AND close < previous low AND volume >= SMA of volume.
Long: Previous close > latest confirmed resistance pivot high AND low <= that pivot high multiplied by an upper tolerance factor AND close > that pivot high AND close > open; the pivot uses equal left and right lookbacks.
Short: Previous close < latest confirmed support pivot low AND high >= that pivot low multiplied by a lower tolerance factor AND close < that pivot low AND close < open; the pivot uses equal left and right lookbacks.
Long: Fast EMA > slow EMA AND previous low > previous fast EMA AND low <= fast EMA multiplied by an upper tolerance factor AND close > fast EMA AND close > open.
Short: Fast EMA < slow EMA AND previous high < previous fast EMA AND high >= fast EMA multiplied by a lower tolerance factor AND close < fast EMA AND close < open.
Long: Previous close < previous open AND close > open AND close - open > ATR multiplied by a threshold.
Short: Previous close > previous open AND close < open AND open - close > ATR multiplied by a threshold.
Long: Low > high two bars earlier.
Short: High < low two bars earlier.
Long: A completed opening range exists AND close crosses above its high AND, for the first session, its upward break state was false before this bar.
Short: A completed opening range exists AND close crosses below its low AND, for the first session, its downward break state was false before this bar.
Long: A completed opening range exists AND its upward break state is true AND the current date is the session-open date.
Short: A completed opening range exists AND its downward break state is true AND its upward break state is false AND the current date is the session-open date.
Long: Low < latest confirmed liquidity pivot low AND close > that pivot low AND close > open; the pivot has a shorter right-side than left-side lookback.
Short: High > latest confirmed liquidity pivot high AND close < that pivot high AND close < open; the pivot has a shorter right-side than left-side lookback.
Long: Close > latest confirmed structure pivot high AND previous close <= previous bar's latest confirmed structure pivot high AND fast EMA != slow EMA; the pivot uses equal left and right lookbacks.
Short: Close < latest confirmed structure pivot low AND previous close >= previous bar's latest confirmed structure pivot low AND fast EMA != slow EMA; the pivot uses equal left and right lookbacks.
Long: Range ADX < threshold AND ATR < its SMA multiplied by a compression threshold AND range high - range low < ATR multiplied by the range lookback and a threshold AND low <= range low multiplied by an upper tolerance factor AND close > open AND close > range low AND volume > SMA of volume.
Short: Range ADX < threshold AND ATR < its SMA multiplied by a compression threshold AND range high - range low < ATR multiplied by the range lookback and a threshold AND high >= range high multiplied by a lower tolerance factor AND close < open AND close < range high AND volume > SMA of volume.
Long: Previous bar's range ADX < threshold AND previous ATR < its SMA multiplied by a compression threshold AND previous range high - previous range low < previous ATR multiplied by the range lookback and a threshold AND close > current range high AND volume > SMA of volume multiplied by a threshold.
Short: Previous bar's range ADX < threshold AND previous ATR < its SMA multiplied by a compression threshold AND previous range high - previous range low < previous ATR multiplied by the range lookback and a threshold AND close < current range low AND volume > SMA of volume multiplied by a threshold.