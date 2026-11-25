Calculation: Divide each chart bar’s high-low range into equal price rows using a row-height parameter; round range divided by row height to get the row count, bounded by minimum and maximum row-count parameters.
Calculation: Price-row buy volume = sum of lower-timeframe T1 bar volume allocated to the row by the fraction of each bar’s high-low range overlapping the row, for T1 bars whose close is above their open, plus half that allocation for bars whose close equals their open; use the T1 bars assigned to each chart bar, including the T1 bar still forming on the current chart bar.
Calculation: Price-row sell volume = sum of lower-timeframe T1 bar volume allocated to the row by the fraction of each bar’s high-low range overlapping the row, for T1 bars whose close is below their open, plus half that allocation for bars whose close equals their open; use the T1 bars assigned to each chart bar, including the T1 bar still forming on the current chart bar.
Calculation: Price-row delta ratio = (price-row buy volume − price-row sell volume) / (price-row buy volume + price-row sell volume), or 0 when total row volume is 0.
Calculation: Bar delta = sum across price rows of (price-row buy volume − price-row sell volume).
Long: A run of at least the minimum consecutive-row parameter has price-row delta ratio >= the bullish imbalance threshold.
Short: A run of at least the minimum consecutive-row parameter has price-row delta ratio <= −the bearish imbalance threshold.
Long: The number of price rows >= the absorption row-count parameter AND close < open AND the sum of buy volume in the bottom absorption row-count rows / their total volume >= the absorption threshold.
Short: The number of price rows >= the absorption row-count parameter AND close > open AND the sum of sell volume in the top absorption row-count rows / their total volume >= the absorption threshold.
Long: low < lowest low of the preceding divergence lookback bars AND bar delta > 0.
Short: high > highest high of the preceding divergence lookback bars AND bar delta < 0.
Long: Bar delta on the last completed chart bar > 0 AND bar delta on the preceding chart bar <= 0.
Short: Bar delta on the last completed chart bar < 0 AND bar delta on the preceding chart bar >= 0.
Long: The row count >= the minimum unfinished-business row-count parameter AND bottom-row total volume > 0 AND bottom-row sell volume / total volume >= the unfinished-business threshold.
Short: The row count >= the minimum unfinished-business row-count parameter AND top-row total volume > 0 AND top-row buy volume / total volume >= the unfinished-business threshold.