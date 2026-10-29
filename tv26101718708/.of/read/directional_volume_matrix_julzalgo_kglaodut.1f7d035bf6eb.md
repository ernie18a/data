Calculation: Estimated buy and sell volume per bar = divide bar volume in proportion to buy and sell strengths. Buy strength weights close position within the high-low range, lower-wick share of total body-plus-wick size, and positive body-to-range ratio; sell strength weights inverse close position, upper-wick share, and negative body-to-range ratio. Normalize the estimates so they sum to bar volume.
Calculation: Total buy volume and total sell volume = sum the respective estimated volumes over the same recent lookback.
Calculation: Delta = total buy volume − total sell volume
Calculation: Imbalance = absolute delta ÷ (total buy volume + total sell volume)
Long: close ≥ open OR total buy volume > total sell volume AND delta > 0 AND imbalance > its previous value
Short: close < open OR total sell volume > total buy volume AND delta < 0 AND imbalance > its previous value