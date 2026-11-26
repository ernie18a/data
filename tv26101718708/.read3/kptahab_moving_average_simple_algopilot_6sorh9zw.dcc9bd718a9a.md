Calculation: MA(source, lookback, type) = moving average of source over lookback, where type is SMA, EMA, WMA, VWMA, or HMA
Calculation: EntryWindow = bar close time is at or after start datetime AND bar is in market session AND bar close time is before market session end
Calculation: BuySignal = signal source is MA AND MA(close, shorter lookback, short MA type) crosses above MA(close, longer lookback, long MA type) OR signal source is external AND external signal = 1
Calculation: SellSignal = signal source is MA AND MA(close, shorter lookback, short MA type) crosses below MA(close, longer lookback, long MA type) OR signal source is external AND external signal = -1
Calculation: LongReversalClose = reversal mode is on AND SellSignal is true
Calculation: ShortReversalClose = reversal mode is on AND BuySignal is true
Calculation: LongBreakevenArmed = (LongBreakevenArmed[1] OR high[1] > entry price * (1 + first target percent / 100)) AND position side[1] is long
Calculation: LongTrailStop = max(prior, close * (1 - stop percent / 100)), where prior is entry price * (1 - stop percent / 100) on the first bar of a long position, otherwise LongTrailStop[1] * entry price / entry price[1]
Calculation: ShortBreakevenArmed = (ShortBreakevenArmed[1] OR low[1] < entry price / (1 + first target percent / 100)) AND position side[1] is short
Calculation: ShortTrailStop = min(prior, close * (1 + stop percent / 100)), where prior is entry price * (1 + stop percent / 100) on the first bar of a short position, otherwise ShortTrailStop[1] * entry price / entry price[1]
Long: BuySignal is true AND long enabled AND position side is flat AND EntryWindow is true
Short: SellSignal is true AND short enabled AND position side is flat AND EntryWindow is true
Long: position side is long AND close < entry price * (1 - repurchase percent / 100) AND repurchase enabled AND EntryWindow is true AND LongReversalClose is false
Short: position side is short AND close > entry price * (1 + repurchase percent / 100) AND repurchase enabled AND EntryWindow is true AND ShortReversalClose is false
Exit: long, LongReversalClose is true
Exit: short, ShortReversalClose is true
Exit: long, bar is outside market session OR bar close time is at or after market session end
Exit: short, bar is outside market session OR bar close time is at or after market session end
Exit: long, low <= entry price * (1 - stop percent / 100) AND stop mode is fixed
Exit: long, low <= LongTrailStop[1] AND stop mode is trailing
Exit: long, close < LongTrailStop AND stop mode is trailing
Exit: long, low <= entry price AND LongBreakevenArmed is true AND stop enabled AND breakeven enabled
Exit: short, high >= entry price * (1 + stop percent / 100) AND stop mode is fixed
Exit: short, high >= ShortTrailStop[1] AND stop mode is trailing
Exit: short, close > ShortTrailStop AND stop mode is trailing
Exit: short, high >= entry price AND ShortBreakevenArmed is true AND stop enabled AND breakeven enabled
Exit: long, high >= entry price * (1 + first target percent / 100) AND first target enabled
Exit: long, high >= entry price * (1 + second target percent / 100) AND second target enabled
Exit: long, high >= entry price * (1 + final target percent / 100)
Exit: short, low <= entry price / (1 + first target percent / 100) AND first target enabled
Exit: short, low <= entry price / (1 + second target percent / 100) AND second target enabled
Exit: short, low <= entry price / (1 + final target percent / 100)