Calculation: buyVol, sellVol = for the chart bar, over all completed bars of a lower timeframe than the chart timeframe that fall inside that chart bar: sum volume of lower bars with close>open into buyVol, sum volume of lower bars with close<open into sellVol, and split volume of lower bars with close==open equally between the two
Calculation: totalVol = buyVol + sellVol
Calculation: avgVol = simple moving average of totalVol over the latest N chart bars including the current bar
Calculation: safeSell = sellVol, or 1 if sellVol is 0; safeBuy = buyVol, or 1 if buyVol is 0
Long: (totalVol > avgVol*k1 AND sellVol > buyVol AND close >= open AND (close-low) > (high-close)) OR (totalVol > avgVol*k2 AND close > open AND buyVol/safeSell >= r) OR (close == high AND buyVol > 0 AND sellVol > 0 AND totalVol > avgVol*k3)
Short: (totalVol > avgVol*k1 AND buyVol > sellVol AND close <= open AND (high-close) > (close-low)) OR (totalVol > avgVol*k2 AND close < open AND sellVol/safeBuy >= r) OR (close == low AND buyVol > 0 AND sellVol > 0 AND totalVol > avgVol*k3)
(Parameter relations: k2 is a stricter volume multiple than k1 and k3, and k3 is not larger than k1; r is a ratio greater than 1.)