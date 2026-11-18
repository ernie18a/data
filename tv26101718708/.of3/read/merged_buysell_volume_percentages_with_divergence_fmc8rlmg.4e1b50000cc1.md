Calculation: SessionHigh(S) = highest high from the first chart bar of session S through the current chart bar
Calculation: SessionLow(S) = lowest low from the first chart bar of session S through the current chart bar
Calculation: SessionVolume(S) = sum of volume from the first chart bar of session S through the current chart bar
Calculation: SessionBuyVolume(S) = if SessionHigh(S) != SessionLow(S), SessionVolume(S) * (close - SessionLow(S)) / (SessionHigh(S) - SessionLow(S)), else 0
Calculation: SessionSellVolume(S) = if SessionHigh(S) != SessionLow(S), SessionVolume(S) * (SessionHigh(S) - close) / (SessionHigh(S) - SessionLow(S)), else 0
Calculation: SessionBuyPercent(S) = if SessionBuyVolume(S) + SessionSellVolume(S) > 0, Round(SessionBuyVolume(S) / (SessionBuyVolume(S) + SessionSellVolume(S)) * 100, 0.01), else 0
Calculation: SessionSellPercent(S) = if SessionBuyVolume(S) + SessionSellVolume(S) > 0, Round(SessionSellVolume(S) / (SessionBuyVolume(S) + SessionSellVolume(S)) * 100, 0.01), else 0
Long: during Session1 or Session2, SessionBuyPercent(S) > SessionSellPercent(S)
Short: during Session1 or Session2, SessionBuyPercent(S) <= SessionSellPercent(S)
Long: during Session1, SessionBuyPercent(Session1) crosses above SessionSellPercent(Session1) AND both percentages exceed the minimum percentage parameter OR during Session2, SessionBuyPercent(Session2) crosses above SessionSellPercent(Session2) AND both percentages exceed the minimum percentage parameter
Short: during Session1, SessionSellPercent(Session1) crosses above SessionBuyPercent(Session1) AND both percentages exceed the minimum percentage parameter OR during Session2, SessionSellPercent(Session2) crosses above SessionBuyPercent(Session2) AND both percentages exceed the minimum percentage parameter