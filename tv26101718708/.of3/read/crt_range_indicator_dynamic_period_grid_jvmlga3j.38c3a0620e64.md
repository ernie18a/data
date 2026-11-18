Calculation: Master range high/low = on T1 bars, initialize to high/low; when close > master range high OR close < master range low, reset both to high/low; chart bars use values from the still-forming T1 bar
Long: low < master range low AND close > master range low
Short: high > master range high AND close < master range high
Exit: long, high >= master range high
Exit: short, low <= master range low