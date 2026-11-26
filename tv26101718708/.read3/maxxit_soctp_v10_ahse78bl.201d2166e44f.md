Calculation: ClosesAbove(level) = close[k] > level for all k from 0 to closes required minus 1
Calculation: ClosesBelow(level) = close[k] < level for all k from 0 to closes required minus 1
Calculation: LongArm = low < trigger level on some bar after the last exit or the start and before this bar
Calculation: ShortArm = high > trigger level on some bar after the last exit or the start and before this bar
Calculation: LongTpArm = take-profit enabled AND take-profit mode is close AND high > take-profit level on some bar after the entry bar through this bar
Calculation: ShortTpArm = take-profit mode is close AND low < take-profit level on some bar after the entry bar through this bar
Long: position side is flat AND LongArm AND ClosesAbove(trigger level)
Short: position side is flat AND ShortArm AND ClosesBelow(trigger level)
Exit: long, low < stop-loss level
Exit: long, take-profit enabled AND take-profit mode is touch AND high > take-profit level
Exit: long, LongTpArm AND ClosesBelow(take-profit level)
Exit: long, stop-loss disabled AND not LongTpArm AND ClosesBelow(trigger level)
Exit: short, stop-loss enabled AND high > stop-loss level
Exit: short, take-profit mode is touch AND low < take-profit level
Exit: short, ShortTpArm AND ClosesAbove(take-profit level)
Exit: short, stop-loss disabled AND not ShortTpArm AND ClosesAbove(trigger level)