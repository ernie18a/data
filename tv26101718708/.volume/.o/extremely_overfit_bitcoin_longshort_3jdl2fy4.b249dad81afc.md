Calculation: Recent volatility = standard deviation of close over a lookback divided by the square root of that lookback
Calculation: Fast channel upper/lower = EMA(close, fast lookback) × (1 ± fast margin) ± recent volatility × volatility factor
Calculation: Slow channel upper/lower = EMA(EMA(close, slow lookback), slow lookback) × (1 ± slow margin) ± recent volatility × volatility factor
Calculation: Fast HMA = Hull moving average of close over a short lookback
Calculation: Dynamic trend gate = absolute value of (standard deviation of close over the trend lookback / close × restrictiveness adjustment × 100) is below trend sensitivity plus (close minus close at the longer trend lookback) / close × long-term trend weight
Calculation: Trend up/down = (current close − close at the trend lookback) / current close > 0 / < 0
Calculation: Tpeak low = fast HMA < fast channel upper AND fast channel lower < slow channel lower
Calculation: Tpeak high = fast HMA > fast channel upper AND fast channel upper > slow channel upper
Calculation: Volume decrease = EMA(volume, volume lookback) < EMA(previous bar's volume EMA × (1 − volume cutoff), short smoothing lookback)
Calculation: ROC allowance = absolute value of EMA(ROC(close, ROC lookback), smoothing lookback) < ROC cutoff OR (absolute value ≥ ROC cutoff AND ((fast channel lower < slow channel lower AND fast HMA < fast channel lower) for longs, or (fast channel upper > slow channel upper AND fast HMA > fast channel upper) for shorts)
Calculation: OBV allowance = correlation of close and OBV over a lookback > correlation threshold
Calculation: Peak high = fast HMA > fast channel upper AND fast channel lower > slow channel upper
Calculation: Peak low = fast HMA < fast channel lower AND fast channel upper < slow channel lower
Calculation: Long stop = entry price × (1 − stop percentage × (1 + price deviation / close) / 100), where price deviation = standard deviation of close over the trend lookback × (1 + stop flexibility / 5)
Calculation: Short stop = entry price × (1 + stop percentage × (1 + price deviation / close) / 100), where price deviation = standard deviation of close over the trend lookback × (1 + stop flexibility / 5)
Long: Tpeak low AND OBV allowance AND ((dynamic trend gate AND trend up AND current close < previous close AND volume decrease AND ROC allowance) OR NOT dynamic trend gate) AND position is not short
Short: Tpeak high AND OBV allowance AND ((dynamic trend gate AND trend down AND current close > previous close AND volume decrease AND ROC allowance) OR NOT dynamic trend gate) AND position is not long
Exit: long, Peak high OR close ≤ long stop
Exit: short, Peak low OR close ≥ short stop