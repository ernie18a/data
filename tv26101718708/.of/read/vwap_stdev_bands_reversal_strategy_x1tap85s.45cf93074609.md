Calculation: VWAP = volume-weighted average of (high+low)/2 since the start of the current trading day (session), reset at each new session
Calculation: Dev = sqrt(max(volume-weighted mean of ((high+low)/2)^2 - VWAP^2, 0)) over the same session window
Calculation: Up(k) = VWAP + k*Dev; Dn(k) = VWAP - k*Dev; two multipliers are used: kE (extreme) and kS (second), with kE > kS
Calculation: SessionOK = bars since session start >= warmup count AND (previous session's bar count unknown OR bars since session start < previous session's bar count - cutoff count)
Calculation: ArmedLong = per-bar state, updated in this order: (1) false at a new session start; (2) false if bars since it was armed > expiry count; (3) set true (age reset to 0) if SessionOK AND (low <= Dn(kE) OR close < Dn(kS)); (4) if close > open, the state is used for this bar's decision and then set false, whether or not a Long fires (a bullish bar with close > VWAP cancels the arm without entry)
Calculation: ArmedShort = mirror of ArmedLong: set true if SessionOK AND (high >= Up(kE) OR close > Up(kS)); bearish bar (close < open) uses it then sets it false
Calculation: LongStop = lowest low of the last n bars including the current bar; ShortStop = highest high of the last n bars including the current bar
Calculation: LongRR = (Up(kS) - close)/(close - LongStop) if close - LongStop > 0 else 0; ShortRR = (close - Dn(kS))/(ShortStop - close) if ShortStop - close > 0 else 0
Long: ArmedLong AND close > open AND close <= VWAP AND LongRR >= minimum RR AND position is flat or short (a short position is reversed); entry price = signal bar close
Short: ArmedShort AND close < open AND close >= VWAP AND ShortRR >= minimum RR AND position is flat or long (a long position is reversed); entry price = signal bar close
Exit: long, low <= LongStop OR high >= Up(kS), both levels fixed at the entry signal bar, OR the Short condition is true
Exit: short, high >= ShortStop OR low <= Dn(kS), both levels fixed at the entry signal bar, OR the Long condition is true