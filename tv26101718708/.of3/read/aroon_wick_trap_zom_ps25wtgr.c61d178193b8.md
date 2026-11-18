Calculation: Long setup = low < lowest low of the prior Donchian lookback bars AND min(open, close) - low > ATR(ATR lookback) * wick multiplier
Calculation: Short setup = high > highest high of the prior Donchian lookback bars AND high - max(open, close) > ATR(ATR lookback) * wick multiplier
Calculation: Long score = count of true conditions among Aroon Up(Aroon lookback) > Aroon Down(Aroon lookback), (CMF(CMF lookback) > 0 OR CMF(CMF lookback) > CMF(CMF lookback)[1]), and Long setup
Calculation: Short score = count of true conditions among Aroon Down(Aroon lookback) > Aroon Up(Aroon lookback), (CMF(CMF lookback) < 0 OR CMF(CMF lookback) < CMF(CMF lookback)[1]), and Short setup
Long: Long setup AND Long score = signal-score threshold - one
Long: Long setup AND Long score >= signal-score threshold AND current chart bar index - prior raw long-signal bar index > cooldown bars (prior index initializes to zero)
Short: Short setup AND Short score = signal-score threshold - one
Short: Short setup AND Short score >= signal-score threshold AND current chart bar index - prior raw short-signal bar index > cooldown bars (prior index initializes to zero)