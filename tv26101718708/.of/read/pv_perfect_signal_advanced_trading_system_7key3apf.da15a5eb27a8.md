Calculation: Fast EMA = exponential moving average of close with a shorter lookback than the slow EMA and trend-filter EMA
Calculation: Slow EMA = exponential moving average of close with a longer lookback than the fast EMA and shorter lookback than the trend-filter EMA
Calculation: Trend-filter EMA = exponential moving average of close with a longer lookback than the fast and slow EMAs
Calculation: SuperTrend = SuperTrend calculated from bars on the chart timeframe
Calculation: RSI = relative strength index of close
Calculation: Volume average = simple moving average of volume
Calculation: Strong volume = current volume > volume average × configured volume-spike multiplier × 1.3
Calculation: Volume spike = current volume > volume average × configured volume-spike multiplier
Calculation: Volume rising = current volume > each of the preceding configured volume-trend bars
Calculation: Upward volume divergence = close > close three bars earlier AND the average volume of the current and preceding two bars < volume average × 0.8
Calculation: Downward volume divergence = close < close three bars earlier AND the average volume of the current and preceding two bars < volume average × 0.8
Calculation: Uptrend = fast EMA > slow EMA AND close > trend-filter EMA AND SuperTrend direction is bullish
Calculation: Downtrend = fast EMA < slow EMA AND close < trend-filter EMA AND SuperTrend direction is bearish
Calculation: Sideways market = Bollinger Band width as a percentage of its basis < configured threshold OR (sideways filter enabled AND ADX < configured threshold)
Calculation: Demand-zone proximity = close is within configured tolerance of the nearest valid demand pivot zone, or within 1.5 times that tolerance; zone must have at least the configured number of tests
Calculation: Supply-zone proximity = close is within configured tolerance of the nearest valid supply pivot zone, or within 1.5 times that tolerance; zone must have at least the configured number of tests
Calculation: Institutional buy = demand-zone proximity AND (absolute(close − open) > ATR × configured big-candle multiplier) AND close > open AND strong volume
Calculation: Institutional sell = supply-zone proximity AND (absolute(close − open) > ATR × configured big-candle multiplier) AND close < open AND strong volume
Calculation: V-shape recovery = close is at least configured recovery threshold × 0.6 above the lowest low of the configured lookback AND close is at least configured recovery threshold below the highest high AND RSI < 40 AND RSI > extreme-oversold RSI threshold AND strong volume AND volume rising AND close > prior close AND NOT upward volume divergence
Calculation: Inverse V-shape decline = close is at least configured recovery threshold × 0.6 below the highest high of the configured lookback AND close is at least configured recovery threshold above the lowest low AND RSI > 60 AND RSI < extreme-overbought RSI threshold AND strong volume AND volume rising AND close < prior close AND NOT downward volume divergence
Calculation: RSI recovery = RSI was below the extreme-oversold threshold in any of the prior three bars AND RSI > prior RSI > RSI two bars earlier AND strong volume AND close > prior close AND NOT upward volume divergence
Calculation: RSI decline = RSI was above the extreme-overbought threshold in any of the prior three bars AND RSI < prior RSI < RSI two bars earlier AND strong volume AND close < prior close AND NOT downward volume divergence
Calculation: Bull score = 1 point each for (uptrend), (close > fast EMA AND close > VWAP), (fast EMA crosses above slow EMA), (RSI > 50 AND RSI < configured overbought threshold), (volume spike AND NOT upward volume divergence), (low > SuperTrend); plus 2 points each for (institutional buy AND NOT sideways market), ((V-shape recovery OR RSI recovery) AND NOT sideways market)
Calculation: Bear score = 1 point each for (downtrend), (close < fast EMA AND close < VWAP), (fast EMA crosses below slow EMA), (RSI < 50 AND RSI > configured oversold threshold), (volume spike AND NOT downward volume divergence), (high < SuperTrend); plus 2 points each for (institutional sell AND NOT sideways market), ((inverse V-shape decline OR RSI decline) AND NOT sideways market)
Calculation: Strong upward momentum = fast EMA > prior fast EMA AND close > prior close AND close > open AND strong volume AND NOT upward volume divergence
Calculation: Strong downward momentum = fast EMA < prior fast EMA AND close < prior close AND close < open AND strong volume AND NOT downward volume divergence
Long: (bull score ≥ configured minimum AND bear score < 3 AND bars since last signal ≥ configured minimum AND current time is at least configured wait interval after market open OR early-entry conditions) AND NOT sideways market AND NOT upward volume divergence AND price rising AND fast EMA rising AND (NOT downtrend OR (volume > volume average × configured counter-trend multiplier AND volume rising))
Long: Institutional buy AND NOT sideways market
Long: V-shape recovery OR RSI recovery, AND NOT sideways market
Long: Early-entry conditions = early entry enabled AND (institutional buy OR V-shape recovery OR RSI recovery) AND strong upward momentum AND NOT sideways market AND current time is at least configured wait interval after market open AND last signal direction is not long AND bars since last signal ≥ 2 AND (NOT downtrend OR volume > volume average × configured volume-spike multiplier × 2)
Short: (bear score ≥ configured minimum AND bull score < 3 AND bars since last signal ≥ configured minimum AND current time is at least configured wait interval after market open OR early-entry conditions) AND NOT sideways market AND NOT downward volume divergence AND price falling AND fast EMA falling AND (NOT uptrend OR (volume > volume average × configured counter-trend multiplier AND volume rising))
Short: Institutional sell AND NOT sideways market
Short: Inverse V-shape decline OR RSI decline, AND NOT sideways market
Short: Early-entry conditions = early entry enabled AND (institutional sell OR inverse V-shape decline OR RSI decline) AND strong downward momentum AND NOT sideways market AND current time is at least configured wait interval after market open AND last signal direction is not short AND bars since last signal ≥ 2 AND (NOT uptrend OR volume > volume average × configured volume-spike multiplier × 2)
Exit: Long, short signal
Exit: Short, long signal