Calculation: pivot feature vector = [P - open[0], 2P - L - open[0], P + H - L - open[0], H + 2(P - L) - open[0], 2P - H - open[0], P - H + L - open[0], L - 2(H - P) - open[0]], where H = highest high and L = lowest low over bars 1 through 5, and P = (H + L + close[1]) / 3
Calculation: category distance = the minimum Euclidean distance from the pivot feature vector to the stored vectors in that category
Long: buy-category distance < sell-category distance AND buy-category distance < hold-category distance
Short: sell-category distance < buy-category distance AND sell-category distance < hold-category distance
Exit: long, (stop-loss parameter != 0 AND low <= entry price - stop-loss parameter * point size) OR (take-profit parameter != 0 AND high >= entry price + take-profit parameter * point size)
Exit: short, (stop-loss parameter != 0 AND high >= entry price + stop-loss parameter * point size) OR (take-profit parameter != 0 AND low <= entry price - take-profit parameter * point size)