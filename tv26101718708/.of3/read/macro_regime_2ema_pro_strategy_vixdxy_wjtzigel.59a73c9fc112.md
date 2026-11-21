Calculation: RegimeState(I, T) = ON if (C - M) / M < -distance band AND (M - M[slope lookback]) / M[slope lookback] < -slope band; OFF if (C - M) / M > distance band AND (M - M[slope lookback]) / M[slope lookback] > slope band; otherwise NEUTRAL; where C = close of instrument I, M = MA(C, regime MA length, regime MA type), C and M are on the last completed bar of T, M[slope lookback] is counted in bars of T; T is T1 or T2, and T1 is longer than T2
Calculation: InstrumentState(I) = for mode main+confirm: WARN if (RegimeState(I, T1) = ON AND RegimeState(I, T2) = OFF) OR (RegimeState(I, T1) = OFF AND RegimeState(I, T2) = ON), else ON if RegimeState(I, T1) = ON AND RegimeState(I, T2) != OFF, else OFF if RegimeState(I, T1) = OFF AND RegimeState(I, T2) != ON, else NEUTRAL; for mode strict: WARN as in main+confirm, else ON if RegimeState(I, T1) = ON AND RegimeState(I, T2) = ON, else OFF if RegimeState(I, T1) = OFF AND RegimeState(I, T2) = OFF, else NEUTRAL; for mode main-only: ON if RegimeState(I, T1) = ON, OFF if RegimeState(I, T1) = OFF, else NEUTRAL; for mode confirm-only: ON if RegimeState(I, T2) = ON, OFF if RegimeState(I, T2) = OFF, else NEUTRAL
Calculation: Count(s) = number of enabled regime instruments I with InstrumentState(I) = s
Calculation: Majority = ceil(number of enabled regime instruments / 2)
Calculation: LongGate = Count(ON) >= Majority AND Count(ON) > Count(OFF) AND (warning trades enabled OR Count(WARN) = 0)
Calculation: ShortGate = Count(OFF) >= Majority AND Count(OFF) > Count(ON) AND (warning trades enabled OR Count(WARN) = 0)
Calculation: LongSetup = trade long enabled AND close > EMA(close, shorter lookback) AND close > EMA(close, longer lookback) AND LongGate
Calculation: ShortSetup = trade short enabled AND close < EMA(close, shorter lookback) AND close < EMA(close, longer lookback) AND ShortGate
Calculation: HighestHigh = max(high) over bars from entry bar through current bar
Calculation: LowestLow = min(low) over bars from entry bar through current bar
Calculation: LongStop = max(entry price * (1 - initial stop % / 100), entry price * (1 + break-even buffer % / 100) if break-even enabled AND HighestHigh >= entry price * (1 + initial stop % * break-even trigger R / 100), HighestHigh * (1 - trailing callback % / 100) if trailing enabled AND (trailing activation disabled OR HighestHigh >= entry price * (1 + trailing activation % / 100)))
Calculation: ShortStop = min(entry price * (1 + initial stop % / 100), entry price * (1 - break-even buffer % / 100) if break-even enabled AND LowestLow <= entry price * (1 - initial stop % * break-even trigger R / 100), LowestLow * (1 + trailing callback % / 100) if trailing enabled AND (trailing activation disabled OR LowestLow <= entry price * (1 - trailing activation % / 100)))
Long: LongSetup AND (entry mode is every-flat-opportunity OR NOT LongSetup[1]) AND (position side is flat OR (reversal enabled AND position side is short))
Short: ShortSetup AND (entry mode is every-flat-opportunity OR NOT ShortSetup[1]) AND (position side is flat OR (reversal enabled AND position side is long))
Exit: long, exit on opposite regime enabled AND ShortGate
Exit: long, exit on EMA loss enabled AND NOT (close > EMA(close, shorter lookback) AND close > EMA(close, longer lookback))
Exit: long, time exit enabled AND bars since entry >= time exit bars
Exit: long, partial take profit enabled AND high >= entry price * (1 + initial stop % * partial take profit R / 100)
Exit: long, low <= LongStop[1]
Exit: short, exit on opposite regime enabled AND LongGate
Exit: short, exit on EMA loss enabled AND NOT (close < EMA(close, shorter lookback) AND close < EMA(close, longer lookback))
Exit: short, time exit enabled AND bars since entry >= time exit bars
Exit: short, partial take profit enabled AND low <= entry price * (1 - initial stop % * partial take profit R / 100)
Exit: short, high >= ShortStop[1]