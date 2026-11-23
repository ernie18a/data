Calculation: BullishBar = trend source > SMA(trend source, trend length) AND RSI(RSI source, RSI length) >= bull RSI low AND RSI(RSI source, RSI length) <= bull RSI high
Calculation: BearishBar = trend source < SMA(trend source, trend length) AND RSI(RSI source, RSI length) >= bear RSI low AND RSI(RSI source, RSI length) <= bear RSI high
Calculation: BarsInRow(condition) = condition ? BarsInRow(condition)[1] + 1 : 0
Calculation: MarketState = 1 if BarsInRow(BullishBar) >= regime confirm bars; -1 if BarsInRow(BearishBar) >= regime confirm bars; 0 otherwise
Long: MarketState == 1
Short: MarketState == -1
Long: MarketState == 1 AND MarketState[1] != 1 AND (HTF confirmation disabled OR BullishBar(T1, last completed bar)) AND (ADX filter disabled OR ADX(ADX length) >= ADX minimum) AND datetime >= history start date
Short: MarketState == -1 AND MarketState[1] != -1 AND (HTF confirmation disabled OR BearishBar(T1, last completed bar)) AND (ADX filter disabled OR ADX(ADX length) >= ADX minimum) AND datetime >= history start date
Exit: long, low <= entry price - ATR(ATR length) at entry * stop multiple
Exit: long, high >= entry price + ATR(ATR length) at entry * selected TP multiple
Exit: short, high >= entry price + ATR(ATR length) at entry * stop multiple
Exit: short, low <= entry price - ATR(ATR length) at entry * selected TP multiple