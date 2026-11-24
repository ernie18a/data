Calculation: Relative ratio(A, B) = close of A / close of B on the current (still-forming) T2 bar, mapped to chart bars
Calculation: Relative ratio EMA(A, B) = EMA(Relative ratio(A, B), ratio EMA lookback) on the current (still-forming) T2 bar, mapped to chart bars
Calculation: Relative ratio ROC(A, B) = ROC(Relative ratio(A, B), ratio ROC lookback) on the current (still-forming) T2 bar, mapped to chart bars
Calculation: Global liquidity impulse = arithmetic mean of the enabled, available ROC values over the liquidity impulse lookback for the U.S. central-bank balance sheet, European central-bank balance sheet multiplied by EUR/USD, Japanese central-bank balance sheet divided by USD/JPY, and U.S. M2, calculated on the current (still-forming) T1 bar and mapped to chart bars
Calculation: Fast liquidity average = EMA(Global liquidity impulse, shorter GLI EMA lookback) on the current (still-forming) T1 bar, mapped to chart bars
Calculation: Slow liquidity average = EMA(Global liquidity impulse, longer GLI EMA lookback) on the current (still-forming) T1 bar, mapped to chart bars
Calculation: Liquidity acceleration = EMA(change(Global liquidity impulse), acceleration smoothing lookback) on the current (still-forming) T1 bar, mapped to chart bars
Long: Global liquidity impulse > 0
Short: Global liquidity impulse < 0
Long: Liquidity acceleration > acceleration neutral band
Short: Liquidity acceleration < -acceleration neutral band
Long: Relative ratio(high-yield corporate bond prices, Treasury bond prices) > Relative ratio EMA(high-yield corporate bond prices, Treasury bond prices) AND Relative ratio ROC(high-yield corporate bond prices, Treasury bond prices) > 0
Short: Relative ratio(high-yield corporate bond prices, Treasury bond prices) < Relative ratio EMA(high-yield corporate bond prices, Treasury bond prices) AND Relative ratio ROC(high-yield corporate bond prices, Treasury bond prices) < 0
Long: Relative ratio(broad stock prices, Treasury bond prices) > Relative ratio EMA(broad stock prices, Treasury bond prices) AND Relative ratio ROC(broad stock prices, Treasury bond prices) > 0
Short: Relative ratio(broad stock prices, Treasury bond prices) < Relative ratio EMA(broad stock prices, Treasury bond prices) AND Relative ratio ROC(broad stock prices, Treasury bond prices) < 0
Long: Relative ratio(broad stock prices, broad bond prices) > Relative ratio EMA(broad stock prices, broad bond prices) AND Relative ratio ROC(broad stock prices, broad bond prices) > 0
Short: Relative ratio(broad stock prices, broad bond prices) < Relative ratio EMA(broad stock prices, broad bond prices) AND Relative ratio ROC(broad stock prices, broad bond prices) < 0
Long: Relative ratio(growth and technology-heavy stock prices, broad stock prices) > Relative ratio EMA(growth and technology-heavy stock prices, broad stock prices) AND Relative ratio ROC(growth and technology-heavy stock prices, broad stock prices) > 0
Short: Relative ratio(growth and technology-heavy stock prices, broad stock prices) < Relative ratio EMA(growth and technology-heavy stock prices, broad stock prices) AND Relative ratio ROC(growth and technology-heavy stock prices, broad stock prices) < 0
Long: Relative ratio(semiconductor stock prices, growth and technology-heavy stock prices) > Relative ratio EMA(semiconductor stock prices, growth and technology-heavy stock prices) AND Relative ratio ROC(semiconductor stock prices, growth and technology-heavy stock prices) > 0
Short: Relative ratio(semiconductor stock prices, growth and technology-heavy stock prices) < Relative ratio EMA(semiconductor stock prices, growth and technology-heavy stock prices) AND Relative ratio ROC(semiconductor stock prices, growth and technology-heavy stock prices) < 0
Long: Relative ratio(small-cap stock prices, broad stock prices) > Relative ratio EMA(small-cap stock prices, broad stock prices) AND Relative ratio ROC(small-cap stock prices, broad stock prices) > 0
Short: Relative ratio(small-cap stock prices, broad stock prices) < Relative ratio EMA(small-cap stock prices, broad stock prices) AND Relative ratio ROC(small-cap stock prices, broad stock prices) < 0