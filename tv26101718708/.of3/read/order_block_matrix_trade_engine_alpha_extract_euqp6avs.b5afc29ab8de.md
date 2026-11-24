Calculation: Block-processing window = scan-window setting disabled OR bar_index > last_bar_index - scan-window length.
Calculation: Bullish order block = on a confirmed chart bar in the block-processing window, either close[L-1] < open[L-1] AND close[n] >= open[n] for every n from 0 through L-2, OR high[L] - low[L] > ATR(high, low, close, ATR lookback)[L] * displacement range multiplier AND close[L] > open[L] AND low[L] < low[L+1]. Its top is high[L-1], and its bottom is either low[L-1] or min(high[L-1], low[L-1] + ATR(high, low, close, ATR lookback) * breadth-width ATR multiplier), selected by the boundary-method parameter. Creating it removes older bullish blocks whose zones overlap or touch. Before signal checks on each processed bar, remove it if the mitigation parameter selects min(close, open) < bottom or low < bottom.
Calculation: Bearish order block = on a confirmed chart bar in the block-processing window, either close[L-1] > open[L-1] AND close[n] <= open[n] for every n from 0 through L-2, OR high[L] - low[L] > ATR(high, low, close, ATR lookback)[L] * displacement range multiplier AND close[L] < open[L] AND high[L] > high[L+1]. Its bottom is low[L-1], and its top is either high[L-1] or max(low[L-1], high[L-1] - ATR(high, low, close, ATR lookback) * breadth-width ATR multiplier), selected by the boundary-method parameter. Creating it removes older bearish blocks whose zones overlap or touch. Before signal checks on each processed bar, remove it if the mitigation parameter selects max(close, open) > top or high > top.
Calculation: Order-block strength = volume[L-1] / SMA(volume, volume-baseline lookback) when SMA(volume, volume-baseline lookback) > 0; otherwise 0.
Calculation: Eligible bullish block = active bullish block whose order-block strength >= minimum strength and whose trigger-method parameter selects either close between its bottom and top or low <= its bottom AND close >= its bottom.
Calculation: Eligible bearish block = active bearish block whose order-block strength >= minimum strength and whose trigger-method parameter selects either close between its bottom and top or high >= its top AND close <= its top.
Calculation: Selected bullish block = eligible bullish block with the greatest strength, choosing the newest block when strengths tie.
Calculation: Selected bearish block = eligible bearish block with the greatest strength, choosing the newest block when strengths tie.
Calculation: Entry price = close on the confirmed entry bar.
Calculation: Long stop = selected bullish block bottom at entry if the stop-method parameter selects the block edge; otherwise entry price - ATR(high, low, close, ATR lookback) on the entry bar * ATR stop multiplier.
Calculation: Long target = entry price + abs(entry price - long stop) * reward-risk parameter.
Calculation: Short stop = selected bearish block top at entry if the stop-method parameter selects the block edge; otherwise entry price + ATR(high, low, close, ATR lookback) on the entry bar * ATR stop multiplier.
Calculation: Short target = entry price - abs(entry price - short stop) * reward-risk parameter.
Long: A bullish order block is created.
Short: A bearish order block is created.
Long: Block-processing window AND an active bullish block has close >= its bottom AND close <= its top.
Short: Block-processing window AND an active bearish block has close >= its bottom AND close <= its top.
Long: Block-processing window AND an active bullish block has low <= its bottom AND close >= its bottom.
Short: Block-processing window AND an active bearish block has high >= its top AND close <= its top.
Long: Trade engine enabled AND flat AND bar confirmed AND a selected bullish block exists.
Short: Trade engine enabled AND flat AND bar confirmed AND a selected bearish block exists AND no selected bullish block exists.
Exit: Long, trade engine enabled AND bar_index > entry bar AND (low <= long stop OR high >= long target).
Exit: Short, trade engine enabled AND bar_index > entry bar AND (high >= short stop OR low <= short target).