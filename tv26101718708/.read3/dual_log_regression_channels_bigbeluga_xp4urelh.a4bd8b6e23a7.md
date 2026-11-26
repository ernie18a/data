Calculation: Log-regression endpoint(lookback, x) = exp(intercept + slope × x), where intercept and slope are the ordinary least-squares coefficients of log(close[n]) on n+1 for n=0 through lookback−1
Long: Log-regression endpoint(longer lookback, 0) > Log-regression endpoint(longer lookback, longer lookback)
Short: Log-regression endpoint(longer lookback, 0) <= Log-regression endpoint(longer lookback, longer lookback)
Long: Log-regression endpoint(shorter lookback, 0) > Log-regression endpoint(shorter lookback, shorter lookback)
Short: Log-regression endpoint(shorter lookback, 0) <= Log-regression endpoint(shorter lookback, shorter lookback)