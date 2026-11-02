Calculation: OsMA = MACD main line minus its simple moving average signal line, using close.
Calculation: Force Index = exponential moving average of (close minus previous close) multiplied by volume.
Calculation: Trailing stop = initially entry price minus the stop-loss distance for a long or plus it for a short; at each new chart bar, if price has moved favorably from entry by more than the trailing distance plus the trailing step and the proposed stop improves the existing stop by more than the trailing step, set the stop to current price minus the trailing distance for a long or plus it for a short.
Long: OsMA on the last completed indicator-timeframe bar < OsMA on the preceding indicator-timeframe bar AND Force Index on the last completed indicator-timeframe bar > 0.
Short: OsMA on the last completed indicator-timeframe bar > OsMA on the preceding indicator-timeframe bar AND Force Index on the last completed indicator-timeframe bar < 0.
Exit: long, price <= trailing stop OR price >= entry price plus the take-profit distance.
Exit: short, price >= trailing stop OR price <= entry price minus the take-profit distance.