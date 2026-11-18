Calculation: Asia-session maximum = highest high within the configured Asia session
Calculation: Asia-session minimum = lowest low within the configured Asia session
Calculation: Long stop = low[n_stop] on the long signal bar
Calculation: Short stop = high[n_stop] on the short signal bar
Long: During the configured London session window and timezone, no entry has yet been taken in the current T2 reset period, and its first London-window sweep was below the Asia-session minimum (if that bar also swept above the maximum, count it as below) AND close > open AND abs(close - open) > ATR(n_atr) AND low > high[n_gap] AND close(T1, still-forming bar) > SMA(close, n_sma, T1, still-forming bar) AND entry price > Long stop
Short: During the configured London session window and timezone, no entry has yet been taken in the current T2 reset period, and its first London-window sweep was above the Asia-session maximum without also sweeping below the minimum AND close < open AND abs(close - open) > ATR(n_atr) AND high < low[n_gap] AND close(T1, still-forming bar) < SMA(close, n_sma, T1, still-forming bar) AND Short stop > entry price
Exit: long, low <= Long stop OR high >= entry price + (entry price - Long stop) * reward/risk parameter
Exit: short, high >= Short stop OR low <= entry price - (Short stop - entry price) * reward/risk parameter