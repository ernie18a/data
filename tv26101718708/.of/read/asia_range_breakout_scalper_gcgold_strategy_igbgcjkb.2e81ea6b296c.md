Calculation: Asia-session high = highest high during the configured Asia session of the current New York day; lock when that session ends
Calculation: Asia-session low = lowest low during the configured Asia session of the current New York day; lock when that session ends
Calculation: Breakout buffer = configured tick count × tick size
Long: range is locked AND (session filter disabled OR trade window is active) AND close > Asia-session high + breakout buffer AND (trend filter disabled OR close > EMA) AND position is flat AND trades today < daily trade limit
Short: range is locked AND (session filter disabled OR trade window is active) AND close < Asia-session low − breakout buffer AND (trend filter disabled OR close < EMA) AND position is flat AND trades today < daily trade limit
Exit: long, low <= entry price − stop ATR multiple × ATR OR high >= entry price + target ATR multiple × ATR
Exit: short, high >= entry price + stop ATR multiple × ATR OR low <= entry price − target ATR multiple × ATR
Exit: long, low <= trailing stop OR high >= entry price + target ATR multiple × ATR, when trailing stop mode is enabled
Exit: short, high >= trailing stop OR low <= entry price − target ATR multiple × ATR, when trailing stop mode is enabled
Exit: long, trade window ends while session use and close-at-window-end are enabled
Exit: short, trade window ends while session use and close-at-window-end are enabled