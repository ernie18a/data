Calculation: Fast line = Jurik moving average of FATL applied to a selected OHLC-derived price; FATL is the weighted sum of current and preceding prices with coefficients, newest first: [0.4360409450, 0.3658689069, 0.2460452079, 0.1104506886, -0.0054034585, -0.0760367731, -0.0933058722, -0.0670110374, -0.0190795053, 0.0259609206, 0.0502044896, 0.0477818607, 0.0249252327, -0.0047706151, -0.0272432537, -0.0338917071, -0.0244141482, -0.0055774838, 0.0128149838, 0.0226522218, 0.0208778257, 0.0100299086, -0.0036771622, -0.0136744850, -0.0160483392, -0.0108597376, -0.0016060704, 0.0069480557, 0.0110573605, 0.0095711419, 0.0040444064, -0.0023824623, -0.0067093714, -0.0072003400, -0.0047717710, 0.0005541115, 0.0007860160, 0.0130129076, 0.0040364019].
Calculation: Slow line = a selected moving average applied to another selected moving average of a selected OHLC-derived price; the two smoothing stages have independently configurable methods and parameters.
Long: Chart-timeframe fast line > its previous-bar value.
Short: Chart-timeframe fast line < its previous-bar value.
Long: Chart-timeframe slow line > its previous-bar value.
Short: Chart-timeframe slow line < its previous-bar value.
Long: At the first chart bar of a higher timeframe, the still-forming higher-timeframe fast line > its previous higher-timeframe bar value.
Short: At the first chart bar of a higher timeframe, the still-forming higher-timeframe fast line = its previous higher-timeframe bar value.
Long: At the first chart bar of a higher timeframe, the still-forming higher-timeframe slow line < its previous higher-timeframe bar value.
Short: At the first chart bar of a higher timeframe, the still-forming higher-timeframe slow line > its previous higher-timeframe bar value.
Long: On completion of a fast-timeframe bar, the fast line on that bar > its previous-bar value AND its previous-bar value <= its value two fast-timeframe bars ago AND the slow line on the last completed higher-timeframe bar > its previous higher-timeframe bar value.
Short: On completion of a fast-timeframe bar, the fast line on that bar < its previous-bar value AND its previous-bar value >= its value two fast-timeframe bars ago AND the slow line on the last completed higher-timeframe bar < its previous higher-timeframe bar value.
Exit: long, on completion of a fast-timeframe bar, the slow line on the last completed higher-timeframe bar < its previous higher-timeframe bar value OR the fast line on the completed fast-timeframe bar > its previous-bar value.
Exit: short, on completion of a fast-timeframe bar, the slow line on the last completed higher-timeframe bar > its previous higher-timeframe bar value OR the fast line on the completed fast-timeframe bar < its previous-bar value.
Exit: long, low <= entry price - stop distance OR high >= entry price + profit distance.
Exit: short, high >= entry price + stop distance OR low <= entry price - profit distance.