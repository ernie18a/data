Calculation: CumDev(k) = sum for i from 1 to k of (first safety deviation * deviation step multiplier^(i - 1))
Calculation: FilledSafety = count of safety orders filled since the current position opened
Long: RSI(close, entry RSI length, T1, last completed bar) crosses below entry RSI level AND no position is open AND datetime is between window start and window end
Long: RSI(close, AO RSI length, T2, last completed bar) < AO RSI level AND close <= entry price * (1 - CumDev(FilledSafety + 1) / 100) AND FilledSafety < maximum safety orders AND a long position is open AND datetime is between window start and window end
Exit: long, close >= average entry price * (1 + take-profit percent / 100)