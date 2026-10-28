Calculation: Fast and slow EMAs = exponential moving averages of close, with the fast EMA using a shorter lookback than the slow EMA.
Calculation: ATR = average true range.
Calculation: Volume ratio = volume / simple moving average of volume.
Calculation: Bullish and bearish pivot levels = confirmed pivot highs and lows using equal left- and right-side lookbacks; retain the most recently confirmed level.
Calculation: Liquidity pivot levels = pivot highs and lows using a longer left-side than right-side lookback; retain the most recently confirmed level.
Calculation: Immediate pivot high and low = pivot high or low using a left-side lookback and no right-side bars.
Calculation: Session opening range high and low = highest high and lowest low from the start of the NY, London, or Asia session through the end of its shorter or longer opening period; use the completed range for breakout comparisons.
Calculation: Range high and low = highest high and lowest low over a lookback; range size = range high − range low.
Calculation: ADX = EMA of DX, where +DM is up move when it exceeds down move and is positive, otherwise zero; −DM is down move when it exceeds up move and is positive, otherwise zero; +DI and −DI are 100 times the EMA of their respective DM divided by ATR; DX is 100 times the absolute difference of +DI and −DI divided by their sum.
Calculation: Range mode = ADX below its threshold AND ATR below its own moving average times a compression threshold AND range size below ATR times the range lookback times a size threshold.
Long: Fast EMA > slow EMA AND low <= fast EMA + ATR * pullback threshold AND close > fast EMA AND previous close <= current fast EMA AND close > open AND close > previous high AND volume ratio >= 1.
Short: Fast EMA < slow EMA AND high >= fast EMA − ATR * pullback threshold AND close < fast EMA AND previous close >= current fast EMA AND close < open AND close < previous low AND volume ratio >= 1.
Long: Fast EMA > slow EMA AND low <= fast EMA + ATR * pullback threshold AND close > fast EMA AND previous close <= current fast EMA AND close > open AND close > previous high AND volume ratio >= 1 AND candle body / (high − low) >= body threshold AND ATR > its shorter-lookback simple moving average AND volume ratio >= higher-volume threshold AND time is in an enabled trading session AND close is not within ATR of the immediate pivot high.
Short: Fast EMA < slow EMA AND high >= fast EMA − ATR * pullback threshold AND close < fast EMA AND previous close >= current fast EMA AND close < open AND close < previous low AND volume ratio >= 1 AND candle body / (high − low) >= body threshold AND ATR > its shorter-lookback simple moving average AND volume ratio >= higher-volume threshold AND time is in an enabled trading session AND close is not within ATR of the immediate pivot low.
Long: A confirmed pivot resistance exists AND previous close > resistance AND low <= resistance * proximity factor above 1 AND close > resistance AND close > open.
Short: A confirmed pivot support exists AND previous close < support AND high >= support * proximity factor below 1 AND close < support AND close < open.
Long: Fast EMA > slow EMA AND previous low > previous fast EMA AND low <= fast EMA * proximity factor above 1 AND close > fast EMA AND close > open.
Short: Fast EMA < slow EMA AND previous high < previous fast EMA AND high >= fast EMA * proximity factor below 1 AND close < fast EMA AND close < open.
Long: Completed session opening range is set AND no earlier upside break of that range occurred in the session AND close > opening range high AND previous close <= opening range high.
Short: Completed session opening range is set AND no earlier downside break of that range occurred in the session AND close < opening range low AND previous close >= opening range low.
Long: A liquidity pivot low exists AND low < liquidity pivot low AND close > liquidity pivot low AND close > open.
Short: A liquidity pivot high exists AND high > liquidity pivot high AND close < liquidity pivot high AND close < open.
Long: A confirmed pivot high exists AND close > latest confirmed pivot high AND previous close <= the prior-bar value of the latest confirmed pivot high.
Short: A confirmed pivot low exists AND close < latest confirmed pivot low AND previous close >= the prior-bar value of the latest confirmed pivot low.
Long: Range mode AND low <= range low * proximity factor above 1 AND close > open AND close > range low AND volume > volume moving average.
Short: Range mode AND high >= range high * proximity factor below 1 AND close < open AND close < range high AND volume > volume moving average.
Long: Previous bar was in range mode AND close > current range high AND volume > volume moving average * higher-volume threshold.
Short: Previous bar was in range mode AND close < current range low AND volume > volume moving average * higher-volume threshold.