Exit: long, low <= entry price - stop-loss distance OR (high reaches entry price + trailing activation distance AND low <= highest high since activation - trailing offset)
Exit: short, high >= entry price + stop-loss distance OR (low reaches entry price - trailing activation distance AND high >= lowest low since activation + trailing offset)
Long: NVT Signal(T1, P1) < P2 AND chart date is on or after (P4, P5, P6) AND chart date is on or before (P7, P8, P9)
Short: NVT Signal(T1, P1) > P3 AND chart date is on or after (P4, P5, P6) AND chart date is on or before (P7, P8, P9)
Exit: long, NVT Signal(T1, P1) > P3
Exit: short, NVT Signal(T1, P1) < P2