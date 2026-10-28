Calculation: Leading MA = selected moving average of the selected price source over its selected lookback, shifted by its selected offset
Calculation: Leading MA 2 = Leading MA shifted by an additional selected offset
Calculation: Leading MA 3 = Leading MA shifted by another selected offset
Calculation: Lagging MA = selected moving average of its selected price source over its selected lookback, shifted by its selected offset
Long: selected risk trigger: selected leading source > Leading MA OR selected leading source > Leading MA 2 OR selected leading source > Leading MA 3 OR selected lagging source > Lagging MA OR Leading MA > Lagging MA
Short: selected risk trigger: selected leading source < Leading MA OR selected leading source < Leading MA 2 OR selected leading source < Leading MA 3 OR selected lagging source < Lagging MA OR Leading MA < Lagging MA
Exit: long, low <= entry price * (1 - selected stop-loss fraction)
Exit: short, high >= entry price * (1 + selected stop-loss fraction)