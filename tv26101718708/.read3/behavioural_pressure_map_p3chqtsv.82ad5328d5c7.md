Calculation: CohortWeight(j) = volume[j] * 0.5^(j / recency half-life)
Calculation: CostBasisWeight(b) = sum of CohortWeight(j) over j in the cohort lookback where HLC3[j] lies in bin b, where bins b are price-bin count equal-width bins spanning the lowest low to the highest high over the cohort lookback
Calculation: Pressure = 100 * (Gain - Loss) / (Gain + Loss), where Gain = sum over j in the cohort lookback with HLC3[j] < close of CohortWeight(j) * ((close - HLC3[j]) / HLC3[j])^gain curvature, and Loss = loss aversion * sum over j in the cohort lookback with HLC3[j] > close of CohortWeight(j) * ((HLC3[j] - close) / HLC3[j])^loss curvature
Calculation: RegimeLevel = 0 if regime filter is off, else round(market regime classification) if abs(market regime classification) <= regime validity bound, else na
Calculation: Cooled = (no node-rejection long or short has fired yet) OR (bars since the last node-rejection long or short fired >= minimum bars between signals)
Long: low <= center of the bin below close with the largest positive CostBasisWeight + node proximity * ATR(ATR length) AND Pressure > pressure threshold AND Cooled AND RegimeLevel >= 0
Short: high >= center of the bin above close with the largest positive CostBasisWeight - node proximity * ATR(ATR length) AND Pressure < -pressure threshold AND Cooled AND RegimeLevel <= 0
Long: Pressure crosses above pressure threshold
Short: Pressure crosses below -pressure threshold
Long: Pressure >= pressure threshold
Short: Pressure <= -pressure threshold
Long: Pressure >= 0
Short: Pressure < 0