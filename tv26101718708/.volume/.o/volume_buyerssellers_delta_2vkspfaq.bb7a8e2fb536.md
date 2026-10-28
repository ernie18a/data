Calculation: Buyer volume = volume × (bullish candle body fraction + half the upper-wick fraction); bearish candles have zero bullish body fraction. Use 0.50 for body fraction and 0.25 for each wick fraction when high = low.
Calculation: Seller volume = volume × (bearish candle body fraction + half the lower-wick fraction); bullish candles have zero bearish body fraction. Use 0.50 for body fraction and 0.25 for each wick fraction when high = low.
Calculation: Buyer percentage = 100 × sum of buyer volume over the lookback bars / sum of buyer and seller volume over those bars; use 50 when the sum is zero.
Calculation: Seller percentage = 100 × sum of seller volume over the lookback bars / sum of buyer and seller volume over those bars; use 50 when the sum is zero.
Calculation: Delta percentage = buyer percentage − seller percentage.
Long: Buyer percentage ≥ the buyer-dominance threshold
Long: Buyer percentage > the strong-buying threshold
Long: Delta percentage > the positive-delta threshold
Long: Current high > the highest high in the preceding divergence lookback bars AND Delta percentage < its value divergence-lookback bars ago AND Delta percentage > 0
Short: Seller percentage ≥ the seller-dominance threshold
Short: Seller percentage > the strong-selling threshold
Short: Delta percentage < the negative-delta threshold
Short: Current low < the lowest low in the preceding divergence lookback bars AND Delta percentage > its value divergence-lookback bars ago AND Delta percentage < 0