Calculation: Reference high and reference low = high and low of the designated T1 reference bar for the date, after it completes, used on chart bars
Calculation: Reference range = reference high - reference low
Calculation: Shallow level = reference high - reference range * shallow retracement proportion
Calculation: Deep level = reference high - reference range * deep retracement proportion, where deep retracement proportion > shallow retracement proportion
Long: reference bar captured AND no earlier breakout has occurred on the date AND close > reference high
Short: reference bar captured AND no earlier breakout has occurred on the date AND close < reference low
Long: long setup active AND no trade has been taken on the date AND low <= shallow level AND close > open
Short: short setup active AND no trade has been taken on the date AND high >= deep level AND close < open
Exit: long, high >= entry price + reward-to-risk multiple * abs(entry price - deep level) OR low <= deep level
Exit: short, low <= entry price - reward-to-risk multiple * abs(shallow level - entry price) OR high >= shallow level