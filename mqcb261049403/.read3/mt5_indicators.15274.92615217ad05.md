Calculation: Adaptive-line change = current Adaptive Moving Line(close, fractal lookback, lag) minus its previous-bar value
Calculation: T1 adaptive-line change = Adaptive Moving Line(close, fractal lookback, lag) change, computed on T1 bars using the still-forming bar and mapped to chart bars
Long: Adaptive Moving Line(close, fractal lookback, lag) on the current chart bar > its previous-bar value
Short: Adaptive Moving Line(close, fractal lookback, lag) on the current chart bar < its previous-bar value
Long: Adaptive-line change rounded to instrument digits plus rounding-precision offset > multiplier × standard deviation(adaptive-line change, standard-deviation lookback), rounded to the same precision
Short: Adaptive-line change rounded to instrument digits plus rounding-precision offset < −multiplier × standard deviation(adaptive-line change, standard-deviation lookback), rounded to the same precision
Long: Adaptive Moving Line(close, fractal lookback, lag) on the still-forming T1 bar > its preceding T1-bar value
Short: Adaptive Moving Line(close, fractal lookback, lag) on the still-forming T1 bar < its preceding T1-bar value
Long: T1 adaptive-line change rounded to instrument digits plus rounding-precision offset > multiplier × standard deviation(T1 adaptive-line change, standard-deviation lookback), rounded to the same precision
Short: T1 adaptive-line change rounded to instrument digits plus rounding-precision offset < −multiplier × standard deviation(T1 adaptive-line change, standard-deviation lookback), rounded to the same precision