Calculation: Negative Volume Index (NVI) = prior NVI + (close − prior close) / prior close when volume is lower than prior-bar volume; otherwise prior NVI (starting at 0)
Calculation: normalized NVI = (NVI − 15-bar EMA of NVI) × 100 / (90-bar highest EMA of NVI − 90-bar lowest EMA of NVI)
Long: normalized NVI > prior-bar normalized NVI AND normalized NVI > 0 AND prior-bar normalized NVI < 0
Short: normalized NVI < prior-bar normalized NVI AND normalized NVI < 0 AND prior-bar normalized NVI > 0
Exit: long, long-entry condition was true two bars earlier
Exit: short, short-entry condition was true two bars earlier