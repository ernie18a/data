Calculation: HTF_EMA(T) = EMA(close, ema_lookback, T, last completed bar)[1]
Calculation: StochK = SMA(StochRSI(close, rsi_lookback, stoch_lookback), k_smoothing)
Calculation: StochD = SMA(StochK, d_smoothing)
Calculation: ATR_value = ATR(atr_lookback)
Long: close > HTF_EMA(T1) AND close > HTF_EMA(T2) AND close > HTF_EMA(T3) AND StochK crosses above StochD AND position side is flat
Short: close < HTF_EMA(T1) AND close < HTF_EMA(T2) AND close < HTF_EMA(T3) AND StochK crosses below StochD AND position side is flat
Exit: long, low <= entry price - sl_multiplier * ATR_value OR high >= entry price + tp_multiplier * ATR_value
Exit: short, high >= entry price + sl_multiplier * ATR_value OR low <= entry price - tp_multiplier * ATR_value