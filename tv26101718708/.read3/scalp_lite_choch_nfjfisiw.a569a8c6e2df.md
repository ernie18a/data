Calculation: Fast EMA = EMA(close, shorter lookback)
Calculation: Slow EMA = EMA(close, longer lookback)
Calculation: Exit SMA = SMA(close, separate exit lookback)
Calculation: VWAP = VWAP((high + low + close) / 3)
Calculation: Average volume = SMA(volume, lookback)
Calculation: ATR = ATR(lookback)
Calculation: Confirmed swing high = Pivot High(high, left-bar parameter, right-bar parameter)
Calculation: Confirmed swing low = Pivot Low(low, left-bar parameter, right-bar parameter)
Calculation: Opening-range high = highest high during the session opening-range duration
Calculation: Opening-range low = lowest low during the session opening-range duration
Calculation: CHoCH long initial stop = latest confirmed swing low − ATR × stop-buffer parameter, or entry price − ATR × fallback multiple if no swing low; when the stop-distance cap is enabled, use the greater of that value and entry price − ATR × cap parameter
Calculation: CHoCH short initial stop = latest confirmed swing high + ATR × stop-buffer parameter, or entry price + ATR × fallback multiple if no swing high; when the stop-distance cap is enabled, use the lesser of that value and entry price + ATR × cap parameter
Calculation: CHoCH long risk = max(entry price − CHoCH long initial stop, minimum price increment)
Calculation: CHoCH short risk = max(CHoCH short initial stop − entry price, minimum price increment)
Calculation: CHoCH long TP1 = entry price + CHoCH long risk × TP1-R parameter
Calculation: CHoCH short TP1 = entry price − CHoCH short risk × TP1-R parameter
Calculation: CHoCH long TP2 = entry price + CHoCH long risk × TP2-R parameter
Calculation: CHoCH short TP2 = entry price − CHoCH short risk × TP2-R parameter
Long: Fast EMA crosses above Slow EMA
Short: Fast EMA crosses below Slow EMA
Long: (deferred-cross mode is disabled AND Fast EMA crosses above Slow EMA) OR (deferred-cross mode is enabled AND (an unconsumed upward cross is pending since the latest opposite cross OR the first in-session bar after session open or a new day has no pending cross, Fast EMA > Slow EMA, and no bullish signal is active)); Fast EMA > Slow EMA; bar is confirmed; VWAP filter is disabled or close > VWAP; volume filter is disabled or volume > Average volume × volume multiplier; cooldown is disabled or bars since the last signal ≥ cooldown parameter; session filter is disabled or bar is in the configured trading session; opening blackout is disabled or bar is outside it
Short: (deferred-cross mode is disabled AND Fast EMA crosses below Slow EMA) OR (deferred-cross mode is enabled AND (an unconsumed downward cross is pending since the latest opposite cross OR the first in-session bar after session open or a new day has no pending cross, Fast EMA < Slow EMA, and no bearish signal is active)); Fast EMA < Slow EMA; bar is confirmed; VWAP filter is disabled or close < VWAP; volume filter is disabled or volume > Average volume × volume multiplier; cooldown is disabled or bars since the last signal ≥ cooldown parameter; session filter is disabled or bar is in the configured trading session; opening blackout is disabled or bar is outside it
Exit: Long, EMA9 crosses below Exit SMA
Exit: Short, EMA9 crosses above Exit SMA
Long: CHoCH is enabled; a confirmed swing high exists; close crosses above that swing high + ATR × minimum-break parameter; structural state is neutral or bearish
Short: CHoCH is enabled; a confirmed swing low exists; close crosses below that swing low − ATR × minimum-break parameter; structural state is neutral or bullish
Long: after the session opening range completes, close crosses above the opening-range high
Short: after the session opening range completes, close crosses below the opening-range low
Long: CHoCH is enabled and flat; bullish structure break is armed and either pullback mode is disabled or, after the break bar and within the wait-bar parameter, low ≤ broken swing high + ATR × retest-buffer parameter and close > broken swing high; EMA filter is disabled or Fast EMA > Slow EMA; VWAP filter is disabled or close > VWAP; volume filter is disabled or volume > Average volume × volume multiplier; bar is in the configured session and outside any enabled blackout
Short: CHoCH is enabled and flat; bearish structure break is armed and either pullback mode is disabled or, after the break bar and within the wait-bar parameter, high ≥ broken swing low − ATR × retest-buffer parameter and close < broken swing low; EMA filter is disabled or Fast EMA < Slow EMA; VWAP filter is disabled or close < VWAP; volume filter is disabled or volume > Average volume × volume multiplier; bar is in the configured session and outside any enabled blackout
Exit: Long, low ≤ current CHoCH stop OR (runner mode is disabled AND high ≥ CHoCH long TP2); after TP1, move the stop to entry when breakeven is enabled and before the first roll; on each runner roll, move the stop per the selected rule (prior TP1, Fast EMA, close − ATR × ATR-trail multiplier, or unchanged) and extend the targets by the prior target spacing, subject to the per-bar roll limit
Exit: Short, high ≥ current CHoCH stop OR (runner mode is disabled AND low ≤ CHoCH short TP2); after TP1, move the stop to entry when breakeven is enabled and before the first roll; on each runner roll, move the stop per the selected rule (prior TP1, Fast EMA, close + ATR × ATR-trail multiplier, or unchanged) and extend the targets by the prior target spacing, subject to the per-bar roll limit