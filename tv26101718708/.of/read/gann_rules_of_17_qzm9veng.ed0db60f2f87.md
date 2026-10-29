Calculation: Rule 1 = current day is Friday AND high equals the highest high of the last 5 chart-timeframe bars
Calculation: Rule 2 = current day is Friday AND low equals the lowest low of the last 5 chart-timeframe bars
Calculation: Rule 3 = current day is Tuesday AND low equals the lowest low of the last 5 chart-timeframe bars AND close > open
Calculation: Rule 4 = current day is Wednesday AND high equals the highest high of the last 5 chart-timeframe bars AND close < open
Calculation: Rule 5 = high equals the highest high of the last 20 chart-timeframe bars AND high > prior bar's high
Calculation: Rule 6 = low equals the lowest low of the last 20 chart-timeframe bars AND low < prior bar's low
Calculation: Moving average = configured moving average of close
Calculation: Rule 7 = close crosses above the moving average
Calculation: Rule 8 = close > close 4 bars ago AND high > high 4 bars ago AND at least 2 of the last 3 close-to-close changes are declines
Calculation: Rule 9 = close > close 8 bars ago AND high > high 8 bars ago AND at least 3 of the last 5 close-to-close changes are declines
Calculation: ATR = 14-bar average true range
Calculation: Rule 10 = close - open >= 2 * ATR
Calculation: Rule 11 = high equals the highest high of the last 3 chart-timeframe bars AND close > moving average AND high > prior bar's high
Calculation: Rule 12 = |high 5 bars ago - low| > |high 10 bars ago - low 5 bars ago| AND |high 5 bars ago - low| > 1.5 * ATR
Calculation: Rule 13 = |close - (highest high of the last 10 bars + lowest low of the last 10 bars) / 2| <= ATR
Calculation: Rule 14 = low < low 2 bars ago AND low < low 4 bars ago AND close > open
Calculation: Rule 15 = high > high 2 bars ago AND high > high 4 bars ago AND close < open
Calculation: Average ATR = 20-bar simple moving average of ATR
Calculation: Rule 16 = ATR > 1.5 * average ATR AND |close - open| >= ATR
Calculation: Rule 17 = (high equals the highest high of the last 60 chart-timeframe bars AND high > prior bar's high) OR (low equals the lowest low of the last 60 chart-timeframe bars AND low < prior bar's low)
Calculation: Bull score = count of true conditions among Rule 1, Rule 3, Rule 5, Rule 7, Rule 10, Rule 11, Rule 14; Rule 8 AND close > moving average; Rule 13 AND close > moving average; Rule 16 AND close > moving average; Rule 17 AND high equals the highest high of the last 60 bars
Calculation: Bear score = count of true conditions among Rule 2, Rule 4, Rule 6, Rule 12, Rule 15; Rule 9 AND close < moving average; Rule 13 AND close < moving average; Rule 16 AND close < moving average; Rule 17 AND low equals the lowest low of the last 60 bars
Long: bull score >= minimum rule count AND bull score > bear score
Short: bear score >= minimum rule count AND bear score > bull score