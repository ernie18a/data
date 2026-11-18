Calculation: fast moving average = moving average(fast source, fast length, fast type)
Calculation: slow moving average = moving average(slow source, slow length, slow type)
Calculation: fast average slope = (fast moving average - fast moving average[lookback]) / lookback
Calculation: slow average slope = (slow moving average - slow moving average[lookback]) / lookback
Calculation: session active = current time is within configured session
Short: fast moving average crosses below slow moving average AND (slope filter disabled OR (fast average slope < -fast slope threshold AND slow average slope < -slow slope threshold)) AND (intraday filter disabled OR session active)
Exit: short, fast moving average crosses above slow moving average OR (intraday filter enabled AND close at session end enabled AND NOT session active AND prior bar session active)