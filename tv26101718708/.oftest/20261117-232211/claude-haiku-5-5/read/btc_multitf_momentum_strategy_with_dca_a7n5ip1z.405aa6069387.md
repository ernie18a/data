Calculation: StochK = STOCH(RSI(close, RSI_LEN, T3, last completed bar), STOCH_LEN) on chart bars
Calculation: StochD = SMA(StochK, D_LEN) on chart bars
Calculation: AverageTrueRange = ATR(ATR_LEN) on chart bars
Long: close > EMA(close, EMA_LEN, T1, last completed bar) AND RSI(close, RSI_LEN, T2, last completed bar) < LONG_RSI_LIMIT AND StochK crosses above StochD AND StochK < OVERSOLD
Long: position side is long AND low <= entry price - AverageTrueRange * NEAR_DCA_ATR
Long: position side is long AND low <= entry price - AverageTrueRange * FAR_DCA_ATR
Short: close < EMA(close, EMA_LEN, T1, last completed bar) AND RSI(close, RSI_LEN, T2, last completed bar) > SHORT_RSI_LIMIT AND StochK crosses below StochD AND StochK > OVERBOUGHT
Short: position side is short AND high >= entry price + AverageTrueRange * NEAR_DCA_ATR
Short: position side is short AND high >= entry price + AverageTrueRange * FAR_DCA_ATR
Exit: Long, low <= entry price - AverageTrueRange * STOP_ATR OR high >= entry price + AverageTrueRange * TP_ATR OR low <= highest high since entry - AverageTrueRange * TRAIL_ATR
Exit: Short, high >= entry price + AverageTrueRange * STOP_ATR OR low <= entry price - AverageTrueRange * TP_ATR OR high >= lowest low since entry + AverageTrueRange * TRAIL_ATR