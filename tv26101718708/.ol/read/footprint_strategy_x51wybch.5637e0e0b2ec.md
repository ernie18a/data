Calculation: Buy imbalance count = number of price rows in the current chart bar where buy volume meets the imbalance threshold, using lower-timeframe bars within the chart bar
Calculation: Sell imbalance count = number of price rows in the current chart bar where sell volume meets the imbalance threshold, using lower-timeframe bars within the chart bar
Calculation: Buy imbalance line = extended line formed by consecutive buy-imbalanced price rows meeting the minimum stacked-level requirement
Long: close < open AND higher-timeframe close is rising versus its previous bar (use the current higher-timeframe bar, which may still be forming) AND buy imbalance count > sell imbalance count
Long: footprint buy volume > footprint sell volume, both accumulated from lower-timeframe bars within the chart bar, AND at least one buy imbalance line exists
Exit: Long, high >= entry price × (1 + take-profit percentage) OR (stop loss enabled AND low <= entry price × (1 − stop-loss percentage))