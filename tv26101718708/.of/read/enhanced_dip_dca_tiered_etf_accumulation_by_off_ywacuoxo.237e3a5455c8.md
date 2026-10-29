Calculation: Reference high = all-time high or rolling 52-week high, as configured
Calculation: Drawdown = close / reference high - 1
Calculation: Trend regime = Bull when close > long-term SMA; Caution when close is not above the SMA but is above the SMA reduced by the bear buffer; otherwise Bear
Long: Drawdown <= negative Tier 3 threshold AND Tier 3 has not fired since drawdown recovered to within the re-arm threshold of the reference high AND close > 0
Long: Drawdown <= negative Tier 2 threshold AND Trend regime is Bull or Caution AND Tier 2 has not fired since drawdown recovered to within the re-arm threshold of the reference high AND close > 0
Long: Drawdown <= negative Tier 1 threshold AND Trend regime is Bull AND (RSI confirmation is disabled OR RSI < its threshold) AND Tier 1 has not fired since drawdown recovered to within the re-arm threshold of the reference high AND close > 0