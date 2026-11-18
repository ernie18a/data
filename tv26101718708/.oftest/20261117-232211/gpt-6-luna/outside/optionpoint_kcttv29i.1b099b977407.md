Calculation: Fast moving average = selected moving average of selected price source over P1 periods
Calculation: Slow moving average = selected moving average of selected price source over P2 periods
Calculation: Fast average slope = (fast moving average − fast moving average P3 periods ago) / P3
Calculation: Slow average slope = (slow moving average − slow moving average P3 periods ago) / P3
Calculation: In session = chart time is within P4
Calculation: Session ended = P5 AND P6 AND NOT in session AND in session on the prior bar
Short: Fast moving average crosses below slow moving average AND (NOT P7 OR (fast average slope < −P8 AND slow average slope < −P9)) AND (NOT P5 OR in session)
Exit: Short, Session ended