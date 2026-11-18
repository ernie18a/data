Calculation: fast average = moving average of fast source by fast type over fast length
Calculation: slow average = moving average of slow source by slow type over slow length
Calculation: in session = bar time is within trading session
Short: no position open AND fast average < slow average AND fast average on previous bar >= slow average on previous bar AND (NOT slope filter enabled OR ((fast average - fast average from slope lookback bars ago) / slope lookback < -fast slope threshold AND (slow average - slow average from slope lookback bars ago) / slope lookback < -slow slope threshold)) AND (NOT intraday filter enabled OR in session)
Exit: short, fast average > slow average AND fast average on previous bar <= slow average on previous bar
Exit: short, intraday filter enabled AND forced close enabled AND NOT in session AND in session on previous bar