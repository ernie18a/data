Calculation: Smoothed MFI lines = apply the same selected smoothing method to the Money Flow Index using a set of smoothing lengths in an arithmetic progression from shortest to longest.
Calculation: Positive count = number of smoothed MFI lines whose current value is greater than their previous-bar value; negative count = number whose current value is less than or equal to their previous-bar value.
Calculation: Positive and negative trend lines = separately smooth the positive and negative counts with the same selected smoothing method and length.
Calculation: Ultralinear smoothing = for input x, let a = 3 / (length + 2), b = 1 - a; initialize all six state variables to the first input, then update sequentially: f1 = b*f1 + a*x; f2 = a*f1 + b*f2; v1 = 1.5*f1 - 0.5*f2; f3 = b*f3 + a*v1; f4 = a*f3 + b*f4; v2 = 1.5*f3 - 0.5*f4; f5 = b*f5 + a*v2; f6 = a*f5 + b*f6; output = 1.5*f5 - 0.5*f6.
Calculation: Parabolic smoothing = fit a quadratic by least squares to the input over the smoothing length, ordered from oldest to newest, and output the fitted value at the newest bar.
Long: Positive trend line > negative trend line
Short: Positive trend line < negative trend line