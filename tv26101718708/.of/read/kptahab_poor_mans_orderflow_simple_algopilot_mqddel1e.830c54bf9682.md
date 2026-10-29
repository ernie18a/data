Calculation: Body ratio = absolute(close − open) / (high − low); 0 if high = low
Calculation: Average volume = mean volume over the previous N chart bars, excluding the current bar
Calculation: Volume spike = volume > average volume × volume multiplier
Calculation: Average range = mean(high − low) over the previous N chart bars, using the same N as average volume
Calculation: Long absorption = body ratio < body-ratio threshold AND volume spike AND close < open
Calculation: Short absorption = body ratio < body-ratio threshold AND volume spike AND close > open
Calculation: Long absorption cluster = count of long absorption bars in the current and previous cluster-lookback chart bars ≥ cluster threshold
Calculation: Short absorption cluster = count of short absorption bars in the current and previous cluster-lookback chart bars ≥ cluster threshold
Calculation: Long impulse = body ratio > 0.7 AND volume spike AND high − low > average range × impulse-range multiplier AND close > open
Calculation: Short impulse = body ratio > 0.7 AND volume spike AND high − low > average range × impulse-range multiplier AND close < open
Calculation: Recent long absorption = the most recent long absorption among the previous entry-lookback chart bars, if any
Calculation: Recent short absorption = the most recent short absorption among the previous entry-lookback chart bars, if any
Calculation: Long pullback entry = recent long absorption exists AND previous close ≤ its high AND close > open AND close > its high
Calculation: Short pullback entry = recent short absorption exists AND previous close ≥ its low AND close < open AND close < its low
Calculation: Long cluster-and-impulse = long absorption cluster AND long impulse
Calculation: Short cluster-and-impulse = short absorption cluster AND short impulse
Calculation: Long confirmed entry = long absorption cluster AND long pullback entry
Calculation: Short confirmed entry = short absorption cluster AND short pullback entry
Long: long pullback entry OR long confirmed entry OR long impulse OR long cluster-and-impulse
Short: short pullback entry OR short confirmed entry OR short impulse OR short cluster-and-impulse
Exit: Long, low ≤ long stop price OR high ≥ entry × (1 + first target %) OR high ≥ entry × (1 + second target %) OR high ≥ entry × (1 + final target %) OR configured close-long signal OR configured reversal short-entry signal
Exit: Short, high ≥ short stop price OR low ≤ entry / (1 + first target %) OR low ≤ entry / (1 + second target %) OR low ≤ entry / (1 + final target %) OR configured close-short signal OR configured reversal long-entry signal