Calculation: ADR(n) = average of high minus low over the last n completed bars of a higher timeframe
Calculation: Inner/outer distance = the smaller/larger of the short-lookback and long-lookback ADRs, each multiplied by one half
Calculation: Buyer zone = current higher-timeframe bar's open minus outer/inner distance; seller zone = current higher-timeframe bar's open plus inner/outer distance
Long: zones are available AND (high >= buyer-zone low AND low <= buyer-zone high OR close > seller-zone high AND previous close <= previous seller-zone high)
Short: zones are available AND (high >= seller-zone low AND low <= seller-zone high OR close < buyer-zone low AND previous close >= previous buyer-zone low)