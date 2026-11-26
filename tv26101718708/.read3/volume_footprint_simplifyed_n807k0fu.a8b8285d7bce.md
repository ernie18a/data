Calculation: Candle body = abs(close - open)
Calculation: Lower wick = min(close, open) - low
Calculation: Upper wick = high - max(close, open)
Calculation: Bear-trap candidate = on a chart bar with available footprint rows, count of negative-delta rows >= minimum signed-row count AND count of negative-delta rows among the lowest-price max(one row, floor(total rows × trap-zone fraction)) rows > row-majority fraction × total negative-delta rows AND (candle-shape filter disabled OR (candle body > 0 AND lower wick >= long-wick/body ratio × candle body AND upper wick <= short-wick/body ratio × candle body))
Calculation: Bull-trap candidate = on a chart bar with available footprint rows, count of positive-delta rows >= minimum signed-row count AND count of positive-delta rows among the highest-price max(one row, floor(total rows × trap-zone fraction)) rows > row-majority fraction × total positive-delta rows AND (candle-shape filter disabled OR (candle body > 0 AND upper wick >= long-wick/body ratio × candle body AND lower wick <= short-wick/body ratio × candle body))
Long: Bear-trap candidate AND (NOT Bull-trap candidate OR footprint bar delta > 0)
Short: Bull-trap candidate AND (NOT Bear-trap candidate OR footprint bar delta < 0)
Long: footprint available AND count of footprint rows > 0 AND footprint bar delta < 0 AND close > open
Short: footprint available AND count of footprint rows > 0 AND footprint bar delta > 0 AND close < open
Calculation: Active bear-trap POC midpoint = midpoint of the POC footprint row on the latest long bear-trap signal bar; replace on each new long bear-trap signal and clear when a long squeeze fires
Calculation: Active bull-trap POC midpoint = midpoint of the POC footprint row on the latest short bull-trap signal bar; replace on each new short bull-trap signal and clear when a short squeeze fires
Long: active bear-trap POC midpoint exists AND previous-bar low <= active bear-trap POC midpoint AND close > active bear-trap POC midpoint
Short: active bull-trap POC midpoint exists AND previous-bar high >= active bull-trap POC midpoint AND close < active bull-trap POC midpoint