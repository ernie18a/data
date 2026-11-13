Calculation: LoD = low of the current higher-timeframe bar (the day) still forming, taken at the entry bar and held fixed while in the position
Calculation: R = entry price - LoD
Exit: long, low <= entry price - f_k * R for each of three stage fractions f_1 < f_2 < f_3 (each between 0 and 1, f_3 being the largest); each stage closes one third of the position when first touched
Exit: long, high >= entry price + m * R, where m is a chosen multiple of R (closes the position)