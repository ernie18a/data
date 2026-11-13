Calculation: ATR = Wilder average true range on chart timeframe, last completed bar
Calculation: SignalOpen = open of the bar on which the entry condition was met (entry order fills at next bar open); ATR_sig = ATR on that bar
Calculation: LongStop = initially SignalOpen - m_stop*ATR_sig; on every later bar while long, LongStop = max(previous LongStop, close - m_stop*ATR) (only rises)
Calculation: ShortStop = initially SignalOpen + m_stop*ATR_sig; on every later bar while short, ShortStop = min(previous ShortStop, close + m_stop*ATR) (only falls)
Calculation: LongTarget = SignalOpen + m_tp*ATR_sig, fixed after entry; ShortTarget = SignalOpen - m_tp*ATR_sig, fixed after entry; m_tp > m_stop
Calculation: BarsHeld = number of bars elapsed since the signal bar
Long: no open position AND close > highest high of the N bars preceding the current bar (current bar excluded) AND close > SMA(close, trend length) (trend length longer than N) AND volume > k * SMA(volume, volume length) (k > 1)
Short: no open position AND close < lowest low of the N bars preceding the current bar (current bar excluded) AND close < SMA(close, trend length) (same trend length as in Long, longer than N) AND volume > k * SMA(volume, volume length) (same k and volume length as in Long)
Exit: long, low <= LongStop OR high >= LongTarget OR BarsHeld >= T (time exit evaluated on bar close, exits at next bar open)
Exit: short, high >= ShortStop OR low <= ShortTarget OR BarsHeld >= T (time exit evaluated on bar close, exits at next bar open)