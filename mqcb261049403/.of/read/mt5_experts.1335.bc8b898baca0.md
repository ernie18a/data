Calculation: OsHMA = fast-period Hull moving average of close minus slow-period Hull moving average of close (fast period shorter than slow period), calculated on the configured indicator timeframe (higher or lower than the chart timeframe) using completed bars
Long: (previous OsHMA > 0 AND latest completed OsHMA <= 0) OR (OsHMA two bars ago > previous OsHMA AND latest completed OsHMA > previous OsHMA)
Short: (previous OsHMA < 0 AND latest completed OsHMA >= 0) OR (OsHMA two bars ago < previous OsHMA AND latest completed OsHMA < previous OsHMA)
Exit: long, previous OsHMA < 0 OR OsHMA two bars ago < previous OsHMA
Exit: short, previous OsHMA > 0 OR OsHMA two bars ago > previous OsHMA