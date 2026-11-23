Calculation: midline = MA(MA(envelope source, envelope length, midline type), midline smoothing length, midline smoothing type)
Calculation: envelope width = envelope multiplier * ATR(envelope length)
Calculation: envelope scale = max(envelope width / max(nz(envelope width[envelope length], envelope width), denominator floor), scale floor)
Calculation: envelope price(level, side) = midline + sign(side) * level * envelope width * envelope scale
Calculation: profit percent = (close - entry price) / entry price * 100 * sign(position side)
Calculation: peak profit percent = highest profit percent since entry
Long: datetime within date range AND long enabled AND external buy signal crosses above signal threshold
Long: datetime within date range AND long enabled AND long line-cross enabled AND close crosses long line-cross source in long line-cross direction
Short: datetime within date range AND short enabled AND external sell signal crosses above signal threshold
Short: datetime within date range AND short enabled AND short line-cross enabled AND close crosses short line-cross source in short line-cross direction
Exit: long, datetime within date range AND close on opposite enabled AND reverse on opposite disabled AND external sell signal crosses above signal threshold
Exit: long, datetime within date range AND close on opposite enabled AND reverse on opposite disabled AND short line-cross enabled AND close crosses short line-cross source in short line-cross direction
Exit: short, datetime within date range AND close on opposite enabled AND reverse on opposite disabled AND external buy signal crosses above signal threshold
Exit: short, datetime within date range AND close on opposite enabled AND reverse on opposite disabled AND long line-cross enabled AND close crosses long line-cross source in long line-cross direction
Exit: long, take-profit enabled AND profit percent >= take-profit percent
Exit: short, take-profit enabled AND profit percent >= take-profit percent
Exit: long, stop-loss enabled AND profit percent <= -(stop-loss percent)
Exit: short, stop-loss enabled AND profit percent <= -(stop-loss percent)
Exit: long, break-even enabled AND peak profit percent >= break-even percent AND low <= entry price
Exit: short, break-even enabled AND peak profit percent >= break-even percent AND high >= entry price
Exit: long, long SL enabled AND long SL trail disabled AND low <= envelope price(long SL level, long SL side) at entry bar
Exit: long, long SL enabled AND long SL trail enabled AND low <= envelope price(long SL trail level, long SL trail side)[1]
Exit: long, long TP1 enabled AND long TP1 trail disabled AND high >= envelope price(long TP1 level, long TP1 side) at entry bar
Exit: long, long TP1 enabled AND long TP1 trail enabled AND high >= envelope price(long TP1 trail level, long TP1 trail side)[1]
Exit: long, long TP2 enabled AND high >= envelope price(long TP2 level, long TP2 side) at entry bar
Exit: long, long TP3 enabled AND high >= envelope price(long TP3 level, long TP3 side) at entry bar
Exit: short, short SL enabled AND short SL trail disabled AND high >= envelope price(short SL level, short SL side) at entry bar
Exit: short, short SL enabled AND short SL trail enabled AND high >= envelope price(short SL trail level, short SL trail side)[1]
Exit: short, short TP1 enabled AND short TP1 trail disabled AND low <= envelope price(short TP1 level, short TP1 side) at entry bar
Exit: short, short TP1 enabled AND short TP1 trail enabled AND low <= envelope price(short TP1 trail level, short TP1 trail side)[1]
Exit: short, short TP2 enabled AND low <= envelope price(short TP2 level, short TP2 side) at entry bar
Exit: short, short TP3 enabled AND low <= envelope price(short TP3 level, short TP3 side) at entry bar