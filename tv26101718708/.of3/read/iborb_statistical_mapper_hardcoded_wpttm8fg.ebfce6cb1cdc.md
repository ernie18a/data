Calculation: WindowHigh(window) = highest high of chart bars within window, per session
Calculation: WindowLow(window) = lowest low of chart bars within window, per session
Calculation: FormedFirst(window) = High if the first completed T1 bar within window whose high ≥ WindowHigh(window) is at or before the first completed T1 bar within window whose low ≤ WindowLow(window), otherwise Low
Calculation: CloseSide(window) = Upper if the close of the first chart bar after window ≥ (WindowHigh(window) + WindowLow(window)) / 2, otherwise Lower
Long: CloseSide(initial balance window) = Upper
Short: CloseSide(initial balance window) = Lower
Long: FormedFirst(shorter opening range window) = Low AND CloseSide(shorter opening range window) = Upper
Short: FormedFirst(shorter opening range window) = High AND CloseSide(shorter opening range window) = Lower
Long: FormedFirst(longer opening range window) = Low AND CloseSide(longer opening range window) = Upper
Short: FormedFirst(longer opening range window) = High AND CloseSide(longer opening range window) = Lower