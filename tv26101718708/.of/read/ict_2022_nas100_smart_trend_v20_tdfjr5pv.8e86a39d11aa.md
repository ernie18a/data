Calculation: Session = the union of enabled local-time intervals, each inclusive at its start and exclusive at its end, using the bar's opening datetime in the configured timezone.
Calculation: Confirmed pivot high/low = a high/low with the specified equal number of bars on each side required for a pivot; it becomes available on the confirmation bar.
Calculation: Local high/low = the most recently confirmed pivot high/low, reset at the first bar entering a session and updated when a pivot is confirmed, including pivots confirmed outside sessions. Reset the local high after a long entry signal and the local low after a short entry signal.
Calculation: Swept high/low = a persistent flag set when a session bar's high/low is strictly above/below the current local high/low. Reset both flags at the first bar entering a session; reset the swept-low flag after a long entry signal and the swept-high flag after a short entry signal. Update pivots and sweep flags before evaluating entry signals.
Calculation: Displacement = the current absolute candle body is greater than a multiplier times the simple moving average of absolute candle bodies over preceding bars, excluding the current bar, and that average is greater than zero.
Calculation: Higher-timeframe trend average = EMA calculated on the chart timeframe from the higher-timeframe close series, with the last completed higher-timeframe close carried forward across chart bars.
Calculation: Long/short stop distance = ATR times a multiplier when ATR stops are enabled; otherwise, respectively, absolute current close minus previous low or absolute previous high minus current close. Compare this price distance with a minimum expressed in price units.
Long: A pivot low is confirmed.
Short: A pivot high is confirmed.
Long: Swept-low flag is true AND its previous-bar value is false.
Short: Swept-high flag is true AND its previous-bar value is false.
Long: Displacement AND bar opening time is in a session AND close > open.
Short: Displacement AND bar opening time is in a session AND close <= open.
Long: Higher-timeframe close > higher-timeframe trend average.
Short: Higher-timeframe close <= higher-timeframe trend average.
Long: Long trading is enabled AND close > local high AND displacement AND bar opening time is in a session AND (sweep requirement is disabled OR swept-low flag is true) AND (trend filter is disabled OR higher-timeframe close > higher-timeframe trend average) AND bars since the last entry signal > cooldown AND position is flat AND long stop distance >= minimum stop distance.
Short: Short trading is enabled AND close < local low AND displacement AND bar opening time is in a session AND (sweep requirement is disabled OR swept-high flag is true) AND (trend filter is disabled OR higher-timeframe close < higher-timeframe trend average) AND bars since the last entry signal > cooldown AND position is flat AND short stop distance >= minimum stop distance.
Exit: long, low <= entry-signal-bar close minus the long stop distance fixed on that bar OR high >= entry-signal-bar close plus that distance times the reward-to-risk multiplier.
Exit: short, high >= entry-signal-bar close plus the short stop distance fixed on that bar OR low <= entry-signal-bar close minus that distance times the reward-to-risk multiplier.