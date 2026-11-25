Calculation: Shorter-lookback median-price SMA = SMA((high + low) / 2, shorter lookback, on T1 bars, current bar still forming)
Calculation: Longer-lookback median-price SMA = SMA((high + low) / 2, longer lookback, on T1 bars, current bar still forming)
Calculation: Median-price SMMA = SMMA((high + low) / 2, price-smoothing lookback, on T1 bars, current bar still forming)
Long: Parabolic SAR(acceleration-step parameter, maximum-step parameter, on T1 bars, current bar still forming) < Median-price SMMA
Short: Parabolic SAR(acceleration-step parameter, maximum-step parameter, on T1 bars, current bar still forming) >= Median-price SMMA
Long: Shorter-lookback median-price SMA > its value 2 T1 bars ago AND Shorter-lookback median-price SMA < Median-price SMMA
Short: Shorter-lookback median-price SMA <= its value 2 T1 bars ago AND Shorter-lookback median-price SMA >= Median-price SMMA
Long: Longer-lookback median-price SMA > its value 2 T1 bars ago AND Longer-lookback median-price SMA < Median-price SMMA
Short: Longer-lookback median-price SMA <= its value 2 T1 bars ago AND Longer-lookback median-price SMA >= Median-price SMMA