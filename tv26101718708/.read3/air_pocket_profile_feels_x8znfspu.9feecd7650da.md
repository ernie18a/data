Calculation: Step = (highest(high, L) - lowest(low, L)) / N
Calculation: Profile(row) = sum over the last L bars of each bar's volume times a linear function of |close - open| / (high - low), divided equally among the rows of height Step, counted up from lowest(low, L), that the bar's high-low range covers
Calculation: POC = midpoint price of the row of Profile with the largest value
Calculation: Node = midpoint prices of up to K nodes on the latest bar: for K rounds, take the highest not-yet-taken interior local maximum of Profile (a row whose value is not below either adjacent row) other than the POC row, mark it taken, and keep it if its value > F * the largest Profile value and its midpoint is at least S * Step from the midpoint of every kept node
Calculation: Hit(node) = bar's high >= node - G * Step AND bar's low <= node + G * Step
Calculation: Reaction(node) = number of bars among the last R bars, including the current bar, where Hit(node)
Calculation: Anchor shift = (POC - POC[W]) / POC[W] * 100
Long: for some node: Hit(node)[R] AND NOT Hit(node)[R+1] AND Reaction(node) >= ceil(R * H)
Short: for some node: Hit(node)[R] AND NOT Hit(node)[R+1] AND Reaction(node) < ceil(R * H)
Long: Anchor shift >= T
Short: Anchor shift <= -T