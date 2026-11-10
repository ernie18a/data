Calculation: Session levels = the running highest high and lowest low of chart bars whose opening times fall within each specified premarket or Asia session in New York time. Reset premarket levels at each new daily bar and Asia levels at the start of each Asia session; retain each level until its next reset.
Calculation: High sweep = high > level + minimum price distance AND close < level AND no earlier high sweep of that level since its reset. The levels are the high of the last completed higher-timeframe daily bar, the premarket high, and the Asia high. Reset sweep eligibility at each new daily bar and additionally reset Asia eligibility at the start of the Asia session.
Calculation: Low sweep = low < level - minimum price distance AND close > level AND no earlier low sweep of that level since its reset. The levels are the low of the last completed higher-timeframe daily bar, the premarket low, and the Asia low. Reset sweep eligibility at each new daily bar and additionally reset Asia eligibility at the start of the Asia session.
Calculation: Pending sweep = the first sweep of a given direction while no sweep of that direction is pending; retain it through the confirmation window and clear it after the first matching displacement or when the window expires. A sweep on the bar that clears an existing pending sweep does not replace it.
Calculation: Displacement = high - low > multiplier × simple moving average of high - low, including the current chart bar.
Long: Low sweep.
Short: High sweep.
Long: Displacement AND close > open.
Short: Displacement AND close < open.
Long: Pending low sweep occurred at least one chart bar ago and no more than the confirmation-window length ago AND displacement AND close > open.
Short: Pending high sweep occurred at least one chart bar ago and no more than the confirmation-window length ago AND displacement AND close < open.
Long: A higher-timeframe bar has just completed AND its low > the high of the higher-timeframe bar two bars before it.
Short: A higher-timeframe bar has just completed AND its high < the low of the higher-timeframe bar two bars before it.