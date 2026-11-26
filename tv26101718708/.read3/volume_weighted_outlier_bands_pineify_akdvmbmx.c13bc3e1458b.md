Calculation: robust center = median(price source[1..robust lookback])
Calculation: robust scale = 1.4826 * median(abs(price source[1..robust lookback] - robust center))
Calculation: volume median = median(volume[1..robust lookback])
Calculation: relative volume = volume / volume median
Calculation: raw robust Z = (price source - robust center) / robust scale
Calculation: weighted robust Z = raw robust Z * sqrt(clamp(relative volume, minimum volume weight, maximum volume weight))
Calculation: effective center-return threshold = min(center-return threshold, min(context threshold, outlier threshold - 0.25) - 0.10)
Calculation: analysis ready = bar index > robust lookback AND all prior robust-lookback price-source and volume samples are non-missing AND robust scale > 0 AND volume > 0 AND volume median > 0 AND SMA((volume[1..robust lookback] is non-missing AND > 0) ? 1 : 0, robust lookback) >= minimum volume coverage
Calculation: confirmed state starts neutral; on confirmed chart bars, reset to neutral if analysis is not ready; otherwise set to supported upper if weighted robust Z >= outlier threshold AND relative volume >= supported volume floor, else supported lower if weighted robust Z <= -outlier threshold AND relative volume >= supported volume floor, else thin upper if raw robust Z >= outlier threshold AND relative volume <= thin volume ceiling, else thin lower if raw robust Z <= -outlier threshold AND relative volume <= thin volume ceiling, else neutral if abs(weighted robust Z) <= effective center-return threshold, else retain the prior confirmed state
Long: on a confirmed chart bar, confirmed state changes to supported upper from a different state
Short: on a confirmed chart bar, confirmed state changes to supported lower from a different state
Exit: long, on a confirmed chart bar, analysis is ready AND confirmed state changes from non-neutral to neutral
Exit: short, on a confirmed chart bar, analysis is ready AND confirmed state changes from non-neutral to neutral