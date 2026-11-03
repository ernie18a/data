Calculation: RSI = 14-bar RSI of close
Calculation: Confirmed swing high/low = pivot high/low with equal left and right lookbacks
Calculation: Bullish RSI divergence = current confirmed price pivot low < previous confirmed price pivot low AND RSI at current pivot > RSI at previous pivot
Calculation: Bearish RSI divergence = current confirmed price pivot high > previous confirmed price pivot high AND RSI at current pivot < RSI at previous pivot
Calculation: Bullish structure break = the two latest confirmed swing lows are descending AND the two latest confirmed swing highs are descending AND close > latest confirmed swing high
Calculation: Bearish structure break = the two latest confirmed swing highs are ascending AND the two latest confirmed swing lows are ascending AND close < latest confirmed swing low
Calculation: Squeeze momentum = 20-bar linear regression of (close − average((20-bar highest high + 20-bar lowest low)/2, 20-bar SMA of close))
Calculation: Squeeze fired = previous bar's 20-bar, 1.5-standard-deviation Bollinger Bands were inside the 20-bar EMA ± 1.5 × 20-bar ATR channel AND current Bollinger Bands are not inside that channel
Calculation: Relative volume = volume / 20-bar SMA of volume
Long: bullish RSI divergence OR bullish structure break AND not the previous bar's bullish structure break OR squeeze fired AND squeeze momentum > 0 OR squeeze momentum > 0 AND previous squeeze momentum <= 0 AND abs(squeeze momentum) > 1 AND relative volume >= 0.8 AND time is outside the Asia session
Short: bearish RSI divergence OR bearish structure break AND not the previous bar's bearish structure break OR squeeze fired AND squeeze momentum < 0 OR squeeze momentum < 0 AND previous squeeze momentum >= 0 AND abs(squeeze momentum) > 1 AND relative volume >= 0.8 AND time is outside the Asia session
Exit: long, low <= active stop OR high >= active target
Exit: short, high >= active stop OR low <= active target