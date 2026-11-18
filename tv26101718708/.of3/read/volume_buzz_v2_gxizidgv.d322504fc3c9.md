Calculation: Regular-session volume buzz = T1 volume / average available volume from the prior lookback sessions at the same regular-session T1 slot * 100; calculate on T1 bars and use the latest completed T1 value on chart bars.
Calculation: Premarket volume buzz = current premarket-session cumulative T3 volume / average cumulative volume of the prior lookback premarket sessions * 100; calculate on T3 bars using the still-forming T3 bar, and use the T3 value on chart bars with lookahead off.
Calculation: After-hours volume buzz = current after-hours-session cumulative T3 volume / average cumulative volume of the prior lookback after-hours sessions * 100; calculate on T3 bars using the still-forming T3 bar, and use the T3 value on chart bars with lookahead off.
Long: Regular-session volume buzz >= regular-session threshold AND current T2 close >= current T2 open.
Short: Regular-session volume buzz >= regular-session threshold AND current T2 close < current T2 open.
Long: During premarket AND premarket volume buzz >= extended-session threshold AND chart close >= previous completed T2 close.
Short: During premarket AND premarket volume buzz >= extended-session threshold AND chart close < previous completed T2 close.
Long: During after-hours AND after-hours volume buzz >= extended-session threshold AND chart close >= previous completed T2 close.
Short: During after-hours AND after-hours volume buzz >= extended-session threshold AND chart close < previous completed T2 close.