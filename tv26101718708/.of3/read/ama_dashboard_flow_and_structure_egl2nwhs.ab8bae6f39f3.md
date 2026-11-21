Calculation: Typical price = (High + Low + Close) / 3
Calculation: Trend side = 1 if bar index >= max(short KAMA length, long KAMA length) AND Close > KAMA(Typical price, short KAMA length, KAMA fast end, KAMA slow end) AND Close > KAMA(Typical price, long KAMA length, KAMA fast end, KAMA slow end); -1 if the same bar index condition AND Close < both KAMAs; otherwise 0
Calculation: Slope angle = arctan((Typical price - Typical price[angle lookback]) / angle lookback / ATR(ATR length)) x 180 / pi
Calculation: Strength label = Counter if Trend side x Slope angle <= 0; Very Strong if |Slope angle| > strong angle AND |Slope angle| > |Slope angle[1]|; Strong if |Slope angle| > strong angle; Improving Moderate if |Slope angle| > moderate angle AND |Slope angle| > |Slope angle[1]|; Moderate if |Slope angle| > moderate angle; Improving Weak if |Slope angle| > |Slope angle[1]|; otherwise Weak
Calculation: Strength points = Strength points table entry for Strength label (Very Strong, Strong, Improving Moderate, Moderate, Improving Weak, Weak); 0 otherwise
Calculation: Angle change = Trend side x (Slope angle - Slope angle[momentum length])
Calculation: Previous angle change = Trend side x (Slope angle[1] - Slope angle[momentum length + 1])
Calculation: Consistency = (1 / momentum length) x sum over i from 0 to momentum length - 1 of sign(Trend side x (Slope angle[i] - Slope angle[i + 1]))
Calculation: Signed consistency = -Consistency if Angle change < 0, otherwise Consistency
Calculation: Momentum label = Strongly Strengthening if Angle change > 0 AND |Angle change| > |Previous angle change| AND Signed consistency > consistency threshold; Strengthening if Angle change > 0 AND Signed consistency > consistency threshold; Weakly Strengthening if Angle change > 0 AND 0 < Signed consistency <= consistency threshold; Strongly Weakening if Angle change < 0 AND |Angle change| > |Previous angle change| AND Signed consistency > consistency threshold; Weakening if Angle change < 0 AND Signed consistency > consistency threshold; Weakly Weakening if Angle change < 0 AND 0 < Signed consistency <= consistency threshold; otherwise Stable
Calculation: Momentum points = Momentum points table entry for Momentum label (Strongly Strengthening, Strengthening, Weakly Strengthening, Stable, Weakly Weakening, Weakening); 0 otherwise
Calculation: Has volume = true if Has volume[1] is true or Volume > 0; otherwise false (false on the first bar)
Calculation: Relative volume = Volume / SMA(Volume, volume length), or 0 if that SMA is 0
Calculation: Flow strength = |CMF(volume length)| x min(Relative volume, relative volume cap)
Calculation: Close position = (Close - Low) / (High - Low), or 0.5 if High = Low
Calculation: Flow label = No volume if Has volume is false; Strong Buying if CMF(volume length) > 0 AND Close > VWAP(Typical price) AND Close position > close-high threshold; Accumulation if CMF(volume length) > 0 AND Close > VWAP(Typical price) AND Close position <= close-high threshold; Strong Selling if CMF(volume length) < 0 AND Close < VWAP(Typical price) AND Close position < close-low threshold; Distribution if CMF(volume length) < 0 AND Close < VWAP(Typical price) AND Close position >= close-low threshold; otherwise Neutral
Calculation: Flow with trend = (Trend side = 1 AND Flow label is Strong Buying or Accumulation) OR (Trend side = -1 AND Flow label is Strong Selling or Distribution)
Calculation: Flow against trend = (Trend side = 1 AND Flow label is Strong Selling or Distribution) OR (Trend side = -1 AND Flow label is Strong Buying or Accumulation)
Calculation: Flow points = 0 if Has volume is false; otherwise (hard-with points if Flow with trend AND Flow label is Strong Buying or Strong Selling; soft-with points if Flow with trend; against points if Flow against trend; neutral points otherwise) x flow weight + (strong-flow points if Flow with trend AND Flow strength > flow strength threshold; weak-flow points if Flow with trend AND Flow strength <= flow strength threshold; 0 otherwise) x flow strength weight
Calculation: Total points = Strength points x trend weight + Momentum points x momentum weight + (ROC bonus if sign(ROC(ROC length)) = Trend side, otherwise 0) + Flow points
Calculation: Maximum points = Very Strong points x trend weight + Strongly Strengthening points x momentum weight + ROC bonus + (if Has volume: hard-with points x flow weight + strong-flow points x flow strength weight, otherwise 0)
Calculation: Share of maximum = Total points / Maximum points
Calculation: Volatility ratio = ATR(volatility length) / SMA(ATR(volatility length), volatility length)
Calculation: Grading available = Trend side != 0 AND Slope angle, Slope angle[momentum length + 1], ATR(ATR length) and Volatility ratio are all defined
Calculation: Grade letter = none if Grading available is false; A++ if Share of maximum >= A++ cutoff; A+ if Share of maximum >= A+ cutoff; A if Share of maximum >= A cutoff; B+ if Share of maximum >= B+ cutoff; otherwise B
Calculation: Distance = |Close - KAMA(Typical price, short KAMA length, KAMA fast end, KAMA slow end)| / ATR(ATR length)
Calculation: Location label = At the AMA if Distance <= at-AMA multiple x Volatility ratio; Stretched if Distance <= stretched multiple x Volatility ratio; otherwise Far
Calculation: Setup tier = 1 if Location label = At the AMA AND Distance <= at-AMA distance limit AND Grade letter is A++, A+ or A; 2 if Location label = Stretched AND Distance <= stretched distance limit AND Grade letter is A++, A+, A or B+; otherwise 0
Calculation: Swing high = High[swing bars] if High[swing bars] > High[i] for every i from 0 to 2 x swing bars except i = swing bars; otherwise NA
Calculation: Swing low = Low[swing bars] if Low[swing bars] < Low[i] for every i from 0 to 2 x swing bars except i = swing bars; otherwise NA
Calculation: Last high = Swing high if Swing high is defined on this bar, otherwise Last high[1]
Calculation: Last low = Swing low if Swing low is defined on this bar, otherwise Last low[1]
Calculation: Break high = Close > Last high AND Broke high[1] is false
Calculation: Break low = Close < Last low AND Broke low[1] is false
Calculation: Broke high = false if Swing high is defined on this bar; otherwise Broke high[1] OR (Break high AND Short flip is false AND (Structure[1] = +1 OR Long flip))
Calculation: Broke low = false if Swing low is defined on this bar; otherwise Broke low[1] OR (Break low AND Long flip is false AND (Structure[1] = -1 OR Short flip))
Calculation: Protected high = Last high if Short flip OR (Structure[1] = -1 AND Break low AND Long flip is false AND Last high is defined); NA if Long flip; otherwise Protected high[1]
Calculation: Protected low = Last low if Long flip OR (Structure[1] = +1 AND Break high AND Short flip is false AND Last low is defined); NA if Short flip; otherwise Protected low[1]
Calculation: Structure = +1 if Long flip; -1 if Short flip; otherwise Structure[1] (0 on the first bar)
Calculation: Long flip = (Structure[1] = 0 AND Break high AND Last low is defined) OR (Structure[1] = -1 AND Protected high is defined AND Close > Protected high AND Last low is defined)
Calculation: Short flip = (Structure[1] = 0 AND NOT (Break high AND Last low is defined) AND Break low AND Last high is defined) OR (Structure[1] = +1 AND Protected low is defined AND Close < Protected low AND Last high is defined)
Long: Trend side = 1
Short: Trend side = -1
Long: Setup tier > 0 AND Trend side = 1
Long: Setup tier > 0 AND (Setup tier[1] = 0 OR Trend side != Trend side[1]) AND Trend side = 1
Short: Setup tier > 0 AND Trend side = -1
Short: Setup tier > 0 AND (Setup tier[1] = 0 OR Trend side != Trend side[1]) AND Trend side = -1
Long: Long flip = true
Short: Short flip = true