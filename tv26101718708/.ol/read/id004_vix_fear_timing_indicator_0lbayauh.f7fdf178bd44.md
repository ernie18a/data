Calculation: Pullback = close is at least the parameterized percentage below the highest high over the parameterized lookback
Calculation: RSI recovery = RSI is rising and either crosses above the oversold level or is above the recovery level
Calculation: Recent oversold = lowest RSI over the recent oversold lookback is below the oversold threshold
Calculation: Price recovery = close > fast EMA OR close > previous bar high
Calculation: Oversold reclaim = lowest RSI over its reclaim lookback < reclaim threshold AND RSI > recovery level AND RSI > previous RSI
Calculation: Bollinger reclaim = low < lower Bollinger Band AND close > lower Bollinger Band
Calculation: Support reclaim = low < prior rolling swing low AND close > that swing low
Calculation: Bullish divergence = low < prior rolling swing low AND RSI > prior rolling RSI low AND RSI < its upper limit
Calculation: Strong lower wick = (min(open, close) - low) / (high - low) >= parameterized wick fraction, when high > low
Calculation: MACD histogram improving = MACD histogram > previous MACD histogram
Calculation: Structure shift = (close > prior rolling swing high AND close > fast EMA AND MACD histogram improving) OR (close > fast EMA AND low > previous low AND MACD histogram improving)
Calculation: Volume confirmation = volume >= longer-lookback average volume
Calculation: Volume spike = volume > parameterized multiple of longer-lookback average volume
Calculation: Bullish engulfing = close > open AND close > previous high AND open <= previous close
Calculation: Capitulation = volume spike AND strong lower wick AND high - low > parameterized multiple of ATR
Calculation: Higher-timeframe RSI rising = higher-timeframe RSI > its previous higher-timeframe value
Calculation: Higher-timeframe MACD histogram improving = higher-timeframe MACD histogram > its previous higher-timeframe value
Calculation: Higher-timeframe danger = higher-timeframe close < higher-timeframe 200-period EMA AND higher-timeframe 50-period EMA < 200-period EMA AND higher-timeframe RSI < danger threshold AND higher-timeframe RSI is not rising; use higher-timeframe bars, evaluated from the latest completed higher-timeframe bar
Calculation: Rare-fear recovery override = rare VIX event AND (higher-timeframe RSI rising OR higher-timeframe MACD histogram improving) AND (structure shift OR bullish candle OR close > fast EMA)
Calculation: Regime allowed = NOT higher-timeframe danger OR rare-fear recovery override
Calculation: Crash = percentage drop from the highest high in the short lookback > max(parameterized multiple of Buy drop threshold, parameterized multiple of ATR as a percentage of close) AND volume > parameterized multiple of average volume AND close < fast EMA
Calculation: VIX percentile = percentile rank of VIX close over its longer lookback, using VIX bars at the chart timeframe
Calculation: VIX stress = VIX close >= absolute stress threshold OR VIX percentile >= stress percentile OR increase in VIX percentile >= jump threshold OR rare VIX event
Calculation: Strong VIX stress = rare VIX event OR (absolute VIX stress AND percentile stress) OR (percentile jump AND (absolute VIX stress OR percentile stress)
Calculation: Rare VIX event = VIX percentile >= rare-event percentile OR VIX close >= rare-event level
Calculation: VIX fear cooling = VIX stress AND (VIX close < previous VIX close OR VIX percentile < previous VIX percentile OR rare VIX event)
Calculation: VIX DCA2 cooling = (recent highest VIX percentile over a lookback >= very-high threshold AND current VIX percentile <= that peak minus cooling amount) OR (rare VIX event AND VIX fear cooling) OR (recent peak >= very-high threshold AND VIX percentile is falling AND current percentile >= stress percentile)
Calculation: Buy quality score = 1 each for Pullback, Recent oversold, RSI recovery, Price recovery, Oversold reclaim, Bollinger reclaim, Strong lower wick, MACD histogram improving, Volume confirmation, strong VIX stress, and VIX fear cooling; 2 each for Support reclaim, Bullish divergence, and Structure shift; 2 for Rare VIX event
Calculation: DCA1 technical score = 2 each for Bullish divergence and Support reclaim; 1 each for Bollinger reclaim, Strong lower wick, bullish candle, MACD histogram improving, and Oversold reclaim
Calculation: DCA1 technical confirmation = (Bullish divergence AND RSI > previous RSI) OR (Bollinger reclaim AND (Strong lower wick OR bullish candle OR MACD histogram improving)) OR ((Support reclaim OR Strong lower wick) AND (RSI > previous RSI OR Volume confirmation)) OR (DCA1 technical score >= parameterized threshold)
Calculation: DCA1 quality score = DCA1 technical score + 1 each for VIX stress, strong VIX stress, and VIX fear cooling + 2 for Rare VIX event
Calculation: DCA2 condition C1 = (((higher-timeframe RSI < threshold AND higher-timeframe RSI rising AND higher-timeframe candle bullish) OR higher-timeframe MACD histogram improving) AND (bullish candle OR close > fast EMA))
Calculation: DCA2 condition C2 = Capitulation OR (previous bar was Capitulation AND current candle bullish AND close > midpoint of previous bar)
Calculation: DCA2 condition C3 = Structure shift AND RSI > previous RSI
Calculation: DCA2 technical score = 2 each for C1, C2, and C3; 1 each for Strong lower wick, Bullish engulfing, Volume spike, and higher-timeframe MACD histogram improving
Calculation: DCA2 technical confirmation = C1 OR C2 OR C3 OR (DCA2 technical score >= parameterized threshold)
Calculation: DCA2 quality score = DCA2 technical score + 1 each for VIX stress, strong VIX stress, and VIX fear cooling + 2 each for Rare VIX event and VIX DCA2 cooling + 1 for recent VIX peak >= very-high threshold
Long: state is flat AND cooldown has elapsed since last reset AND Pullback AND Recent oversold AND RSI recovery AND Price recovery AND Regime allowed AND NOT Crash AND VIX passes Buy filter (VIX filter off OR VIX data missing and missing data is allowed OR VIX stress OR VIX fear cooling; in very-strict mode require strong VIX stress OR Rare VIX event) AND (VIX filter off OR Buy quality score >= parameterized minimum)
Long: state is Buy-only AND bars since Buy are within the adaptive DCA1 timing window AND close < Buy entry price AND low <= Buy entry price * (1 - parameterized DCA1 drop fraction) AND price zone has been armed for at least the parameterized confirmation delay AND (bullish candle OR close > previous high OR close > fast EMA OR close > DCA1 zone) AND Regime allowed AND NOT Crash AND DCA1 technical confirmation AND VIX passes DCA1 filter (VIX filter off OR VIX data missing and missing data is allowed OR Rare VIX event OR strong VIX stress; in very-strict mode require Rare VIX event OR (strong VIX stress AND VIX fear cooling)) AND (VIX filter off OR DCA1 quality score >= parameterized minimum)
Long: state is Buy-and-DCA1 AND bars since DCA1 are within the adaptive DCA2 timing window AND close < average of Buy and DCA1 entry prices AND low <= DCA1 entry price * (1 - parameterized DCA2 drop fraction) AND price zone has been armed for at least the parameterized confirmation delay AND (bullish candle OR close > previous high OR Structure shift OR close > DCA2 zone) AND Regime allowed AND NOT Crash AND DCA2 technical confirmation AND VIX passes DCA2 filter (VIX filter off OR VIX data missing and missing data is allowed OR VIX DCA2 cooling; in very-strict mode also require recent VIX peak >= rare-event percentile OR Rare VIX event) AND (VIX filter off OR DCA2 quality score >= parameterized minimum)
