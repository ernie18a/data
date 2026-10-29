Calculation: Source range = highest high and lowest low over a lookback of prior completed chart bars, excluding the current bar
Calculation: Active expansion levels = freeze the source range at a qualifying close beyond its edge; failure rail is one ATR buffer inside the broken edge; target is one source-range-width multiple beyond the edge, capped by the nearest prior target-side high or low within a longer lookback when that reference lies more than a small ATR distance beyond the edge
Long: Close > source range high AND (close - source range high) / ATR >= minimum edge-break distance
Short: Close < source range low AND (source range low - close) / ATR >= minimum edge-break distance
Exit: long, close < broken range edge OR close < failure rail OR high >= target
Exit: short, close > broken range edge OR close > failure rail OR low <= target