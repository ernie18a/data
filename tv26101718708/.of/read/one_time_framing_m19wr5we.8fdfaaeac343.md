Calculation: Inside = high < previous bar high AND low > previous bar low
Calculation: UpRun = counter updated only on non-Inside bars: UpRun+1 if low > previous bar low, else reset to 0; unchanged on Inside bars. DnRun = same, using high < previous bar high
Calculation: Armed = current bar is not Inside AND a most-recent Inside bar exists, not older than the expiry limit (in bars), and not yet consumed. InsideHigh/InsideLow = high/low of that most-recent Inside bar (a newer Inside bar replaces it). The setup is consumed on any bar where ConfUp or ConfDn is true, whether or not a position change results
Calculation: ConfUp = Armed AND close > InsideHigh AND low > previous bar low. ConfDn = Armed AND close < InsideLow AND high < previous bar high
Long: (position is flat AND current bar is not Inside AND UpRun >= required run length - 1) OR (position is not long AND ConfUp; if short, this reverses to long immediately)
Short: (position is flat AND current bar is not Inside AND DnRun >= required run length - 1) OR (position is not short AND ConfDn; if long, this reverses to short immediately)
Exit: long, current bar is not Inside AND UpRun < required run length - 1 AND NOT ConfDn (go flat; no same-bar re-entry)
Exit: short, current bar is not Inside AND DnRun < required run length - 1 AND NOT ConfUp (go flat; no same-bar re-entry)