Calculation: T1 Delta = volume when close > the previous close on T1 bars, −volume when close < the previous close on T1 bars, otherwise 0
Calculation: Max Delta % = 100 × the maximum of 0 and the chronological cumulative sum of T1 Delta within the T2 bar / the sum of absolute T1 Delta within that T2 bar; use 0 if the denominator is 0. Accumulate T1 values on chart bars while the T2 bar is forming.
Calculation: Min Delta % = 100 × the absolute value of the minimum of 0 and the chronological cumulative sum of T1 Delta within the T2 bar / the sum of absolute T1 Delta within that T2 bar; use 0 if the denominator is 0. Accumulate T1 values on chart bars while the T2 bar is forming.
Long: Max Delta % > zero-value threshold
Short: Min Delta % > zero-value threshold