Calculation: Active segment = bars since the most recent accepted BOCPD changepoint; detect a changepoint when the maximum-a-posteriori run length falls below its collapse threshold after exceeding its prior threshold, backdate the cut by that run length, and discard cuts that would create a segment shorter than the minimum length.
Calculation: Active-segment slope = OLS slope per bar of close over the active segment.
Calculation: Active-segment mean sigma = mean, over the active segment, of the square root of the EWMA variance of one-step innovations from a local linear trend Kalman filter.
Long: Active-segment slope > flat dead-zone threshold × active-segment mean sigma
Short: Active-segment slope < −flat dead-zone threshold × active-segment mean sigma