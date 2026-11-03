Calculation: Heikin-Ashi close = (current open + high + low + close) / 4
Calculation: Heikin-Ashi open = (previous bar open + previous bar close) / 2
Calculation: Heikin-Ashi low = min(current low, (previous bar Heikin-Ashi open + previous bar Heikin-Ashi close) / 2, current Heikin-Ashi close)
Calculation: Long stop = entry price − risk factor × ATR until high ≥ entry price + breakeven factor × ATR; then entry price. After breakeven, if trailing is enabled, update to max(previous stop, close − trailing factor × ATR).
Calculation: Short stop = entry price + risk factor × ATR until low ≤ entry price − breakeven factor × ATR; then entry price. After breakeven, if trailing is enabled, update to min(previous stop, close + trailing factor × ATR).
Long: flat AND within configured backtest date range AND long entries enabled AND (Heikin-Ashi close crosses SMA of close in either direction OR (Money Flow Index calculated from Heikin-Ashi low is below its oversold threshold AND Heikin-Ashi close > SMA of close))
Short: flat AND within configured backtest date range AND short entries enabled AND (Heikin-Ashi close crosses below SMA of close OR (Money Flow Index calculated from Heikin-Ashi close is above its overbought threshold AND Heikin-Ashi close < SMA of close))
Exit: Long, low ≤ long stop OR high ≥ entry price + reward factor × ATR
Exit: Short, high ≥ short stop OR low ≤ entry price − reward factor × ATR