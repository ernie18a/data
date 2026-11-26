Calculation: First MA = selected MA type 1(first source, first lookback, applicable shared type parameters)
Calculation: Second MA = selected MA type 2(second source, second lookback, applicable shared type parameters)
Calculation: Third MA = selected MA type 3(third source, third lookback, applicable shared type parameters)
Calculation: Fourth MA = selected MA type 4(fourth source, fourth lookback, applicable shared type parameters)
Calculation: Shared type parameters = KAMA fast and slow endpoints, AMA fast and slow lengths, FRAMA fast and slow channels, instantaneous trend alpha, Laguerre alpha, LSMA offset, and PWMA power
Calculation: Cycle net = favorable excursion / entry price − drawdown weight × adverse excursion / entry price; a cycle starts at its crossover-bar close and its high and low extremes include the terminating opposite-cross bar; for a long cycle favorable excursion is highest high − entry and adverse excursion is entry − lowest low, with these reversed for a short cycle
Calculation: Cycle grade(x) = full-grade parameter if x > cycle-net cutoff, partial-grade parameter if x > 0, otherwise 0
Calculation: Cross quality score(direction, pair) = average of the cycle grade of the latest completed same-direction cycle and the cycle grade of the negative net of the latest completed opposite-direction cycle; for each missing cycle use the no-history grade when no-history crosses are allowed, otherwise 0
Calculation: Weighted pair score = sum across up to three enabled pairs with both MAs available, adding the vote unit when Fast MA > Slow MA and subtracting it otherwise; disabled or unavailable pairs add 0
Calculation: Bullish trend state = in strict-hierarchy mode, First MA > Second MA AND (Third MA absent OR Second MA > Third MA) AND (Fourth MA absent OR Third MA > Fourth MA); in custom-pairs mode, every enabled pair with both MAs available meets its configured Fast/Slow relation; in weighted-score mode, Weighted pair score ≥ bullish threshold
Calculation: Bearish trend state = in strict-hierarchy mode, First MA < Second MA AND (Third MA absent OR Second MA < Third MA) AND (Fourth MA absent OR Third MA < Fourth MA); in custom-pairs mode, every enabled pair with both MAs available meets the inverse of its configured Fast/Slow relation; in weighted-score mode, Weighted pair score ≤ −bearish threshold
Long: First MA and Second MA are available AND First MA > Second MA
Short: First MA and Second MA are available AND First MA ≤ Second MA
Long: Second MA and Third MA are available AND Second MA > Third MA
Short: Second MA and Third MA are available AND Second MA ≤ Third MA
Long: Third MA and Fourth MA are available AND Third MA > Fourth MA
Short: Third MA and Fourth MA are available AND Third MA ≤ Fourth MA
Long: First MA crosses above Second MA AND (smart cross filter is disabled OR Cross quality score(long, First/Second pair) ≥ minimum quality score)
Short: First MA crosses below Second MA AND (smart cross filter is disabled OR Cross quality score(short, First/Second pair) ≥ minimum quality score)
Long: Third MA is available AND Second MA crosses above Third MA AND (smart cross filter is disabled OR Cross quality score(long, Second/Third pair) ≥ minimum quality score)
Short: Third MA is available AND Second MA crosses below Third MA AND (smart cross filter is disabled OR Cross quality score(short, Second/Third pair) ≥ minimum quality score)
Long: Fourth MA is available AND Third MA crosses above Fourth MA AND (smart cross filter is disabled OR Cross quality score(long, Third/Fourth pair) ≥ minimum quality score)
Short: Fourth MA is available AND Third MA crosses below Fourth MA AND (smart cross filter is disabled OR Cross quality score(short, Third/Fourth pair) ≥ minimum quality score)
Long: Bullish trend state
Short: Bearish trend state
Exit: long, (First MA crosses below Second MA OR neither Bullish trend state nor Bearish trend state) AND none of the Short conditions above