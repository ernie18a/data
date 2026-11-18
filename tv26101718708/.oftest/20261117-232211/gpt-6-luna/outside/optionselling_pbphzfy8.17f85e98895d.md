Calculation: Fast moving average = selected moving average of fast source using fast type and fast length
Calculation: Slow moving average = selected moving average of slow source using slow type and slow length
Calculation: Fast moving-average slope = (fast moving average − fast moving average slope-lookback bars ago) / slope lookback
Calculation: Slow moving-average slope = (slow moving average − slow moving average slope-lookback bars ago) / slope lookback
Short: fast moving average crosses below slow moving average AND (slope filter disabled OR (fast moving-average slope < −fast slope threshold AND slow moving-average slope < −slow slope threshold)) AND (intraday filter disabled OR within trading session)
Exit: short, intraday filter enabled AND close-before-market-end enabled AND outside trading session AND previous bar within trading session