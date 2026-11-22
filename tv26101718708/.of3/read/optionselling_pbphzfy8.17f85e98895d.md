Calculation: Fast moving average = P1-type moving average of P2 price source over P3 bars
Calculation: Slow moving average = P4-type moving average of P5 price source over P6 bars
Calculation: Within session = chart bar time is within P12 session
Short: Fast moving average crosses below slow moving average AND (P7 is false OR (the change in fast moving average over P8 bars divided by P8 is below negative P9 AND the change in slow moving average over P8 bars divided by P8 is below negative P10)) AND (P11 is false OR within session)
Exit: Short, fast moving average crosses above slow moving average
Exit: Short, P11 is true AND P13 is true AND current bar is outside session AND the previous bar was within session