Calculation: Volume-weighted vigor = for each bar, sum over a longer lookback of (lookback − offset + 1) times the four-bar weighted sum of volume × (close − open), divided by the corresponding sum using volume × (high − low); use weights 1, 8, 8, 1 from newest to oldest, and use the numerator when the denominator is zero.
Calculation: Vigor difference = shorter-lookback Relative Vigor Index main line minus (4 × current volume-weighted vigor + 3 × its previous value + 2 × its value two bars ago + its value three bars ago) / 10.
Calculation: Difference signal = selectable SMA, EMA, SMMA, LWMA, Jurik moving average, ultralinear smoothing, parabolic moving average, T3, VIDYA, or Kaufman adaptive moving average of the vigor difference.
Long: Vigor difference > previous-bar difference signal.
Short: Vigor difference < previous-bar difference signal.
Long: Last completed bar's vigor difference < difference signal two bars ago AND vigor difference two bars ago > difference signal three bars ago.
Short: Last completed bar's vigor difference > difference signal two bars ago AND vigor difference two bars ago < difference signal three bars ago.