Long: Higher-timeframe SMA(open) crosses below higher-timeframe SMA(close) AND the higher-timeframe bar is still forming AND the configured test period is active AND long entries are enabled AND no position is open
Short: Higher-timeframe SMA(open) crosses above higher-timeframe SMA(close) AND the higher-timeframe bar is still forming AND the configured test period is active AND short entries are enabled AND no position is open
Exit: long, highest high since entry >= entry price × (1 + configured take-profit %) AND low <= highest high since entry × (1 − configured trailing-profit %)
Exit: long, low <= entry price × (1 − configured stop-loss %)
Exit: long, low <= highest high since entry × (1 − configured trailing-stop %)
Exit: long, higher-timeframe SMA(open) crosses above higher-timeframe SMA(close) AND stop-loss and trailing-stop exits are disabled
Exit: short, lowest low since entry <= entry price × (1 − configured take-profit %) AND high >= lowest low since entry × (1 + configured trailing-profit %)
Exit: short, high >= entry price × (1 + configured stop-loss %)
Exit: short, high >= lowest low since entry × (1 + configured trailing-stop %)
Exit: short, higher-timeframe SMA(open) crosses below higher-timeframe SMA(close) AND stop-loss and trailing-stop exits are disabled