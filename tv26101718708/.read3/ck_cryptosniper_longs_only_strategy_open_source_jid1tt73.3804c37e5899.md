Calculation: most recent bullish-cross time = datetime on the latest chart bar where close(T1, still-forming bar) crosses above open(T1, still-forming bar), using T1 values on chart bars; carry forward otherwise
Calculation: most recent bearish-cross time = datetime on the latest chart bar where close(T1, still-forming bar) crosses below open(T1, still-forming bar), using T1 values on chart bars; carry forward otherwise
Long: most recent bullish-cross time crosses above most recent bearish-cross time
Exit: long, most recent bearish-cross time crosses above most recent bullish-cross time
Long: most recent bullish-cross time[1] > most recent bearish-cross time[1]
Exit: long, most recent bearish-cross time[1] > most recent bullish-cross time[1]