Calculation: slow line = ZLEMA(close, longer lookback)
Calculation: fast line = ZLEMA(close, shorter lookback)
Calculation: channel high = highest(high, range lookback)[1]
Calculation: channel low = lowest(low, range lookback)[1]
Calculation: clear zone = NOT(channel high - channel low <= no-print range size AND close <= channel high AND close >= channel low) AND ABS(close - slow line) >= ATR(ATR lookback) * line block ATR multiple
Calculation: long signal = clear zone AND close > channel high + breakout buffer AND fast line > slow line AND close > slow line AND slow line - slow line[1] > ATR(ATR lookback) * min slope ATR multiple AND ABS(fast line - slow line) > ATR(ATR lookback) * min separation ATR multiple AND high - low > ATR(ATR lookback) * min candle range ATR multiple AND close > high[1] AND close > open AND most recent long or short signal was not long AND bars since most recent long or short signal >= cooldown bars
Calculation: short signal = clear zone AND close < channel low - breakout buffer AND fast line < slow line AND close < slow line AND slow line - slow line[1] < -ATR(ATR lookback) * min slope ATR multiple AND ABS(fast line - slow line) > ATR(ATR lookback) * min separation ATR multiple AND high - low > ATR(ATR lookback) * min candle range ATR multiple AND close < low[1] AND close < open AND most recent long or short signal was not short AND bars since most recent long or short signal >= cooldown bars
Calculation: T1 long = long signal on T1 bars at last completed bar AND NOT long signal on T1 bars at last completed bar one chart bar earlier AND most recent T1 long or short was not long
Calculation: T1 short = short signal on T1 bars at last completed bar AND NOT short signal on T1 bars at last completed bar one chart bar earlier AND most recent T1 long or short was not short
Long: long signal
Long: long signal on T2 bars at last completed bar AND NOT long signal on T2 bars at last completed bar one chart bar earlier
Long: T1 long
Short: short signal
Short: short signal on T2 bars at last completed bar AND NOT short signal on T2 bars at last completed bar one chart bar earlier
Short: T1 short
Exit: long, entered by long signal AND high >= entry price + main TP distance
Exit: short, entered by short signal AND low <= entry price - main TP distance
Exit: long, entered by T1 long AND high >= entry price + T1 TP distance
Exit: short, entered by T1 short AND low <= entry price - T1 TP distance