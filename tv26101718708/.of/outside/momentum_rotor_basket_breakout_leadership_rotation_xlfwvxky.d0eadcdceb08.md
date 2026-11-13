Long-only, single-position strategy on the chart symbol, gated by relative strength against a user-defined basket of symbols that must include the chart symbol. If the chart symbol is not in the basket, never trade.

Each bar, on the chart's timeframe and with no lookahead, compute every basket member's N-bar rate of change of close. Rank the members from highest to lowest. The chart symbol is the 'leader' when it ranks first.

Entry (long): while flat, enter long at the bar close when all of these hold: (1) the chart symbol is the basket leader; (2) its close is above the highest high of the previous M bars, excluding the current bar; (3) if the regime filter is enabled, its close is above a long simple moving average of close; (4) the computed position size is positive. Size = a fixed fraction of equity divided by the stop distance, where stop distance = a multiple of ATR below the entry close.

Exit, two independent mechanisms. (a) Bracket: on entry, place a protective stop at the entry close minus the ATR multiple, and a profit target at the entry close plus a reward:risk multiple times the stop distance. (b) Rotation exit: while long, if the chart symbol is no longer the basket leader, close the position at market. Optionally require it to have been non-leader for K consecutive bars while in the position; the counter resets to zero whenever it is leader again or when flat.

There are no short trades and no options. Breadth, leader-streak count, and the table/visuals are display-only and do not affect decisions.