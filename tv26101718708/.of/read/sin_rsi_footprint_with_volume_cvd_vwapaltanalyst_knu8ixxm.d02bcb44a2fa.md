Calculation: Crossover node = a completed lower-timeframe bar within the chart bar where the shorter-lookback RSI of the selected price source crosses above or below the longer-lookback RSI of the same source; calculate a separate RSI of that source at each node.
Calculation: Stack group = consecutive crossover nodes within a chart bar whose RSI values fall in the same one of ten equal RSI intervals and are on the same side of the RSI baseline; a node inside the inclusive hide range separates visible groups. Use the first node’s RSI for the group’s decisions.
Calculation: Matrix row RSI = the mean RSI of crossover nodes whose lower-timeframe closes fall in the same equal-width row of the chart bar’s low-to-high range; clamp the row index to the available rows.
Long: Stack group first RSI is outside the inclusive hide range AND first RSI > RSI baseline.
Short: Stack group first RSI is outside the inclusive hide range AND first RSI <= RSI baseline.
Long: Stack group first RSI is outside the inclusive hide range AND first RSI <= lower buy threshold.
Short: Stack group first RSI is outside the inclusive hide range AND first RSI >= upper sell threshold.
Long: Matrix row RSI is outside the inclusive hide range AND matrix row RSI <= lower buy threshold.
Short: Matrix row RSI is outside the inclusive hide range AND matrix row RSI >= upper sell threshold.