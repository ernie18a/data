Calculation: openMA = moving average of open; closeMA = moving average of close, with the same type and same lookback as openMA, both computed on chart-timeframe bars
Long: closeMA >= openMA on the current bar AND closeMA < openMA on the previous bar (closeMA crosses up through openMA)
Short: closeMA < openMA on the current bar AND closeMA >= openMA on the previous bar (closeMA crosses down through openMA)
Exit: long, closeMA < openMA on the current bar AND closeMA >= openMA on the previous bar
Exit: short, closeMA >= openMA on the current bar AND closeMA < openMA on the previous bar