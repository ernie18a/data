<!-- tradingview-pine-id: PUB;eb18f74d0a044eb59369a9b70702c634 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Statistical Mapping - True + Midnight Open

Source: https://www.tradingview.com/script/BSkg3lT1-Statistical-Mapping-True-Midnight-Open/

## Description

⚠️⚠️ IMPORTANT — READ BEFORE USING ⚠️⚠️

This indicator is an educational and analytical tool. It is not financial advice, not a signal service, and not a trading system. It does not tell you when to buy or sell.

Every number it shows is a HISTORICAL FREQUENCY measured on past data. It is not a probability, not a forecast, and not a guarantee. Markets change; a level that was reached on 70% of the last 90 days may be reached far less often over the next 90. Past behaviour never guarantees future behaviour.

Do not size positions off these levels alone. Do not treat a "Reach" percentage as an edge. Use this tool to understand context — how far this market normally travels — and combine it with your own analysis, your own risk management, and your own testing.

You are solely responsible for your trading decisions and any losses that result from them.

════════════════════════════════════════

WHAT THIS IS, IN ONE PARAGRAPH

Every trading day has a shape. Price opens, usually pokes a little way in the wrong direction, then travels in the direction it is actually going to close. Statistical Mapping measures both of those distances across the last N days and draws them on your chart as five levels around today's open. It tells you, before the day develops, roughly how far this market normally pulls back and roughly how far it normally runs.

════════════════════════════════════════

THE FIVE LEVELS

Working from the top of the screen down:

  +D   Upside distribution objective
  -M   Upside manipulation area
   O   The anchor open
  +M   Downside manipulation area
  -D   Downside distribution objective

"Distribution" (D) is travel in the direction the period closed. "Manipulation" (M) is travel against it, before the period resolved.

So on a day that closes UP:
  - the run from the open up to the high is DISTRIBUTION
  - the dip from the open down to the low is MANIPULATION

And on a day that closes DOWN, the mirror image.

That is why the levels are not symmetrical, and why -M sits above the open while +M sits below it. +D and -D are objectives. +M and -M are the areas where a move typically fakes out before doing what it was going to do anyway.

════════════════════════════════════════

CALCULATION METHODS:

BOTH MEDIAN & MEAN
[image]https://www.tradingview.com/x/bEvnMRK8/[/image]

MEAN ONLY
[image]https://www.tradingview.com/x/XHAHbUiT/[/image]

MEDIAN ONLY
[image]https://www.tradingview.com/x/uYq20g62/[/image]

---------------

TIMEFRAME EXAMPLES:

1 WEEK
[image]https://www.tradingview.com/x/0fIZvcBS/[/image]

4 HOUR
[image]https://www.tradingview.com/x/cS8CLy3k/[/image]

1 HOUR
[image]https://www.tradingview.com/x/RZXckxbL/[/image]

---------------

OPTION TO CHOOSE THE NEW YORK MIDNIGHT OPEN AS THE DAILY OPENING PRICE
[image]https://www.tradingview.com/x/qEtKDIOh/[/image]

════════════════════════════════════════

HOW IT IS CALCULATED

For each of the last N completed periods (default 90 days), the script records:

  Direction  = up if close > open, down if close < open

  If the period closed UP:
      Distribution sample = high - open
      Manipulation sample = open - low

  If the period closed DOWN:
      Distribution sample = open - low
      Manipulation sample = high - open

It then takes the mean or the median of each set of samples and projects those two distances from the CURRENT period's open:

  +D = today's open + distribution
  -M = today's open + manipulation
  +M = today's open - manipulation
  -D = today's open - distribution

Mean is the arithmetic average — it is pulled around by outlier days such as CPI, FOMC or gap opens. Median is the middle value — it ignores those outliers and is usually the tighter, more realistic number.

"Both" mode draws a shaded zone spanning from the mean to the median instead of a single line. The WIDTH of that zone is itself information: a wide zone means the sample is skewed by a handful of violent days; a narrow zone means the market has been behaving consistently.

════════════════════════════════════════

THE STATISTICS TABLE — AND WHY IT MATTERS

For each level the table reports:

  Level   the level name
  Price   where the level currently sits
  Dist    how far that is from the anchor open, in price
  Reach   see below
  Hit     whether the current period has already traded through the level

In **Both** mode the chart draws a ZONE from the mean to the median, and the table reports the **near edge** of that zone — whichever of the two sits closer to the anchor open. That is the first price of the zone price actually reaches, so it is the number that matters in practice. Price, Dist, Reach and Hit all use that same near edge, so every column describes the same price, and the far edge stays visible on the chart as the other side of the band. Alerts use it too.

Hover any column header for a full explanation of that column. A compact footer row shows the mapping period, anchor mode, method, how many periods were actually usable, and how the sample splits between up-closing and down-closing periods.

IF YOU RUN BOTH MAPPING PERIODS AT ONCE

The table describes ONE mapping period at a time. Two periods have entirely different levels, distances and statistics, and interleaving them would produce a table nobody could read.

By default that is MAPPING PERIOD 1 — the first of the two timeframe slots. You can point it at period 2 instead with "Show Statistics For" in the statistics table settings.

If the period you pick is not on screen — its levels are hidden because your chart timeframe is not lower than it — the table falls back to the other one rather than showing you nothing.

The footer's first cell always names the period the table is describing, right next to the anchor mode and the calculation method, so you can confirm which one you are reading at a glance. The chart draws both sets of levels regardless; only the table is limited to one.

WHAT "REACH" MEANS, PLAINLY

Reach answers one question: out of the days in your lookback, how many of them actually got this far?

Worked example. Lookback is 90 days. +D sits 419 points above today's open, and Reach shows 25.6%.

That means: on 23 of the last 90 days, price traded 419 points or more above THAT day's open at some point during the day. On the other 67 days, it never got that far.

Nothing more than that. It is a count of past days, expressed as a percentage.

Why it is useful: a level on its own is just a line. Reach tells you whether that line marks something ordinary or something rare.

  Low Reach  (say 15-25%)  — price rarely gets here. An extended target. If price
                             is already here, the day has done unusual work.
  High Reach (say 70-80%)  — price gets here on most days. Routine. Reaching it
                             tells you very little on its own.

The footer shows how many periods were actually usable and the up/down split, so you can always see the sample the numbers rest on.

Reach is a count of what happened on past days. It is not a probability of it happening today, and it is not a forecast.

════════════════════════════════════════

SAMPLE SELECTION — WHICH PAST PERIODS GET MEASURED

This is the setting that decides what the statistics actually describe, and it matters more than any other.

MATCHED (the default)
Only periods from the SAME SLOT are measured.

On an intraday mapping period that means the same time of day. With a 1H mapping at 09:15, the numbers come from the 09:00-10:00 hour of each of the previous days. At 10:00 the indicator switches to the 10:00-11:00 hour of those same days. On a 1D mapping period it means the same weekday — a Thursday is measured against previous Thursdays.

ROLLING
The last N periods in a row, whatever time of day they happened to be.

WHY THIS EXISTS

Markets do not behave the same at every hour. The New York open and the middle of the Asian session are different animals. Average them together and you get a number that describes neither.

The practical consequence is specific: on a 1H mapping, a rolling average of the last 90 hours is dominated by quiet hours, because most hours are quiet. Project that at 09:30 and the levels sit far too close in — price blows through them in the first ten minutes and the map looks broken. It is not broken; it was answering the wrong question. Matched sampling asks the right one: how far does THIS hour usually travel?

The same applies on a daily mapping. Mondays and Fridays do not behave like Wednesdays.

WHAT IT DOES TO "LOOKBACK"

In Matched mode, Lookback counts OCCURRENCES of the slot rather than consecutive periods. Lookback 90 on a 1H mapping means the last 90 appearances of that hour — roughly 90 trading days, not 90 hours. That is a much longer reach into history, which has one consequence worth knowing about, below.

WHEN IT DOES NOT APPLY

A 1W mapping period contains one of each slot, so there is nothing to match against. The indicator uses Rolling there and says so on the chart rather than pretending otherwise.

HONEST LIMITATION

Reaching back 90 occurrences of a slot means reaching back 90 days of data. On coarser mapping periods — 30m, 1H, 4H, 1D — that fits comfortably. On finer ones, 15m and below, it needs more intraday history than the script is given, so the sample comes up short.

The indicator does not hide this. The footer shows the real count as, for example, "n 46/90", and a notice explains that fewer samples were available and why. The levels remain valid; they simply rest on a smaller sample, and you can decide whether that is enough. Lowering Lookback removes the notice.

The table footer names the active slot, so you can always see exactly which pool the numbers came from — "1H 09:00" rather than just "1H".

ONE THING TO SET ONCE

That slot label has a time zone setting, in the statistics table section. It defaults to New York, which is the reference most index-futures and FX traders keep their charts on. If your chart is set to anything else, change it to match.

This is not laziness — Pine scripts genuinely cannot read TradingView's chart Time Zone setting. TradingView treats it as a display preference and gives scripts no access to it. So if you have changed your chart away from Exchange time, the label has no way of knowing until you tell it.

The practical case: MNQ trades on CME, whose exchange time zone is Chicago. A chart left on Exchange time therefore runs an hour behind New York. Set this to whatever your chart shows, once, and forget it.

It affects the LABEL ONLY. Slot grouping, every level, every statistic and every Reach figure are completely unaffected — changing time zone shifts every bar by the same amount, so exactly the same periods are grouped together either way.

════════════════════════════════════════

WHICH LEVELS GET REACHED ON WHICH KIND OF DAY

This falls straight out of how the levels are built, and it is worth understanding because it is most of what makes the tool useful.

+M and -M sit close to the open, because a typical day's counter-move is small. They get reached on most days — including slow, quiet, range-bound ones. Look at your own Reach column and they will usually be the two highest numbers in the table. That is exactly why price touching +M or -M, on its own, tells you very little. It is the normal texture of a day, not an event.

+D and -D sit much further out, because they represent a full typical day's directional travel. Price only gets there when the day has already moved further from its open than an average day manages. In practice that means TRENDING DAYS and HIGH-VOLATILITY DAYS — expansion sessions, news days, days that pick a direction in the morning and hold it. On a quiet range day price frequently never comes close to either one.

So the two pairs are answering different questions:

  Price at +M / -M   ->  ordinary. The day is doing what days do.
  Price at +D / -D   ->  this day is not ordinary. It has already
                         behaved like a trend or expansion day.

That second line is the practical one. Reaching a distribution level is itself information about the character of the session, before you form any view about what happens next.

Two honest caveats. First, this is a description of what the levels mean, not a prediction — nothing here says today will be a trend day. Second, "volatile" and "trending" are not the same thing and the tool does not distinguish them: a violent chop that swings 400 points in one direction and back can reach +D just as a smooth trend can. The level tells you the distance was covered, not how or in what order.

════════════════════════════════════════

HOW THIS DIFFERS FROM ADR / AVERAGE DAILY RANGE

ADR takes the average of (high - low) over N days and usually draws a band above and below either the open or the previous close. It answers one question: how big is a typical day?

Statistical Mapping answers a different and, I would argue, more useful set of questions.

WHERE IT GOES FURTHER THAN ADR

1. It compares like with like. ADR averages the last N days as one undifferentiated pool. On an intraday mapping period this indicator averages only the SAME TIME OF DAY — the 09:00 hour against previous 09:00 hours — and on a daily period only the same weekday. No ADR variant does this, and it is the difference between a projection that survives the New York open and one that price walks through in the first ten minutes.

2. It separates the range into direction. ADR gives you one number for the whole candle. Stat Map splits that candle into the part that travelled with the close and the part that travelled against it, and measures them separately. That is the difference between "the day is usually 300 points" and "the day usually pulls back 90 points before running 210".

3. It is asymmetric, and deliberately so. Because up-days and down-days are measured on their own terms, the upside and downside levels are not mirror images. ADR bands almost always are.

4. It offers the median, not just the mean. A single CPI day can inflate an ADR reading for weeks. The median is immune to that. Being able to flip between the two — and to see the gap between them in "Both" mode — is a diagnostic in its own right.

5. It reports how often each level was actually reached. This is the big one. ADR draws a line and stops. Stat Map tells you the historical frequency behind every line it draws.

6. It supports a NY Midnight anchor. For 24-hour markets the exchange's own daily open is often an arbitrary moment. Many traders work from 00:00 New York instead. The script rebuilds whole days around that time and recomputes every statistic from scratch, rather than just shifting a line.

7. It works on any mapping period, not only daily. Set it to 1W and you get the same decomposition for the weekly candle.

WHERE ADR IS THE BETTER TOOL, OR WHERE THIS ONE IS WEAKER

Being straight about this matters more than selling it.

1. It is more complicated. ADR is one number and anyone can use it in thirty seconds. This has five levels with a specific meaning each, and it will confuse a beginner who has not read the definitions above.

2. It needs a directional close to classify a period. A day that closes exactly at its open contributes to neither sample set. This is rare but it means the sample count can be slightly below your lookback setting.

3. The classification is only known in hindsight. A period is labelled up or down by its CLOSE. That is fine for building statistics from finished days, but it means the levels drawn on today's open are built on a mix of past up-days and past down-days — the script does not and cannot know which kind of day today will be. Both sides are drawn precisely because that is unknowable.

4. It is not adaptive within the period. The levels are fixed at the open and do not adjust as volatility develops during the session. ADR-style tools have the same limitation, but it is worth stating.

5. It says nothing about sequence or timing. It tells you how far, not when, and not in what order. A day that runs to +D at 09:45 and a day that grinds there by 15:55 look identical to this tool.

6. Regime changes take time to show up. With a 90-period lookback, a genuine shift in volatility takes weeks to be fully reflected. Shorten the lookback if you want faster adaptation — and accept a noisier, less stable reading in exchange.

Neither tool replaces the other. ADR sizes the day. This maps it.

════════════════════════════════════════

HOW TO USE IT — PRACTICAL

FOR BEGINNERS, START HERE
Put it on a 15m chart with the defaults, set Calculation method to Median, and just watch it for two weeks without trading it. Notice how often price dips to +M early and then turns. Notice how often +D holds as a high for the day. You are building an intuition for how far this market actually moves — which is the single most common thing new traders have no feel for.

There is no single "correct" way to trade this. The levels describe the shape of a period; which part of that shape is useful depends entirely on what you trade. The sections below cover the common approaches, and the range section is as important as the trend one.

INTRADAY / DAY TRADING
The manipulation levels (+M and -M) are where the tool earns its keep. If you are looking for longs and price has come down into +M, you are at the area where up-days have historically found their low. That is a location to look for your own entry trigger — not a signal by itself. The distribution levels (+D and -D) work the other way: they are where you consider taking profit rather than initiating, because price reaching there means the day has already done a typical day's work in that direction.

The anchor open (O) is a simple bias line. Above it, you are on the bullish side of the period; below it, the bearish side.

RANGE, CONSOLIDATION AND MEAN-REVERSION
This is the other half of the tool, and it is easy to miss if you only read the section above.

Most days are not trend days. On an ordinary session price spends its time between +M and -M, oscillating around the anchor open, and never comes close to +D or -D. That is not the tool failing — it is the tool telling you what kind of day it is.

For anyone trading ranges, consolidations, or short mean-reversion, the useful structure is the inner three levels and nothing else:

  -M   the upper edge of the ordinary daily range
   O   the middle, and the level price returns to most often
  +M   the lower edge of the ordinary daily range

Look at the Reach figures for +M and -M on your instrument. They are typically the two highest numbers in the table — commonly 55-80%. That is the whole point: these are levels price reaches on most days, including quiet ones. Approaches built around them are naturally higher-frequency and lower reward-to-risk than approaches built around +D and -D, which is a trade-off, not a flaw. Fading -M back toward the open, or buying +M back toward the open, is a coherent way to use this.

The anchor open is the natural target for that kind of trade, and often the natural invalidation for the opposite one.

TWO HONEST WARNINGS ABOUT THIS

First, and this matters: Reach measures how often price GOT to a level. It does not measure how often price REVERSED there. Those are completely different questions and this indicator only answers the first. A 75% Reach on -M means price traded there on three days in four — it says nothing whatever about what happened next. Do not read a high Reach as a high win rate.

Second, the trades that make range approaches work are the same trades that get destroyed on trend days. The day you fade -M is the day price runs to +D. That is precisely why the distribution levels are on the chart at the same time: if price is pushing through -M with conviction rather than stalling at it, the map is telling you this may not be a range day. Use the whole structure, not half of it.

SCALPING
Use the Reach column as a filter. If price is sitting just past a level with a 20% reach, the market is already in unusual territory for the session and further continuation in that direction has historically been the exception, not the rule. Conversely a level with 70% reach is barely a level at all — price gets there on most days and it is poor evidence of anything.

Also watch the Hit column. Once +D is ticked for the day, the remaining upside to a typical day's extension is spent.

SWING TRADING
Put 1W in mapping period 1, untick period 2, and drop the chart to 1D or 4H. (Slot
1 rather than slot 2 on purpose: alerts only ever fire from slot 1 — see ALERTS
below.) You now get the same decomposition for the weekly candle: how far a week typically pulls back before running, and how far it typically runs. Weekly +M often lines up with the sort of pullback entry swing traders wait for.

You can also run both at once — 1D and 1W together — on a 1H or 4H chart, to see where the daily and weekly structures agree.

CHOOSING MEAN vs MEDIAN
Median for normal conditions and for tighter, more conservative targets. Mean when you want the levels to account for the fat tail — around known event risk, for example. Both, when you want to see how far apart they are, because that gap is a direct read on how outlier-driven the recent sample has been.

════════════════════════════════════════

IMPORTANT BEHAVIOUR YOU SHOULD KNOW ABOUT

THE TIMEFRAME RULE — please read this one, it is the most common confusion

Your chart timeframe must be STRICTLY LOWER than the mapping period.

  Mapping 1D  ->  chart must be 4H, 1H, 15m, 5m, 1m ...
  Mapping 1W  ->  chart must be 1D, 4H, 1H ...

On a 1D chart the 1D levels will NOT appear. This is correct and intended: a period cannot be projected forward across a chart bar that already contains it. The script tells you so in a message at the bottom of the chart rather than failing silently. If you find that message annoying once you understand the rule, you can switch it off in the settings.

NY MIDNIGHT ANCHOR PRECISION
Days are rebuilt from 1-hour data, inside that data's own context rather than from your chart's bars. 00:00 New York falls on an hourly boundary for the futures, forex and crypto markets this mode is intended for, so the reconstruction is exact.

Because the reconstruction never touches chart bars, the anchor and every level are identical on every chart timeframe. A 5m chart, a 1H chart and a 4H chart all show the same prices.

The anchor mode applies to the 1D mapping only. Any other mapping period always uses that period's own true open.

DAYLIGHT SAVING TIME
Handled automatically, and worth explaining because it is a common source of doubt.

The script uses America/New_York, which is a full timezone rule rather than a fixed UTC offset. The anchor therefore tracks local New York clock time all year — EST in winter, EDT in summer — and its position relative to UTC shifts on its own at each changeover. You never need to adjust anything.

The two changeover days are 23 and 25 hours long. Days are rebuilt by watching the New York calendar date change, not by counting a fixed number of bars, so those two days are measured correctly as well: one simply contains one hour less of data, the other one hour more.

WHY THERE IS NO CUSTOM TIMEZONE OPTION
This is deliberate, for three reasons.

First, a technical one. Days are reconstructed from 1-hour bars, which is exact only because midnight New York lands on an hourly boundary. Several timezones are offset by a half or quarter hour — India, Iran, Nepal, parts of Australia — and there midnight falls in the middle of an hourly bar. The reconstruction would be quietly wrong rather than visibly broken, which is the worst kind of wrong.

Second, a conceptual one. The New York midnight open is a specific reference point that a large amount of flow actually keys off. It is not an arbitrary parameter. A free-form timezone box would imply every choice is equally meaningful, and most are not.

Third, an honest one about method. Offering a dial that changes every number in the table invites tuning it until the levels look good on the chart in front of you. That is curve-fitting, and it makes the statistics worse while feeling like it makes them better.

If you want a different anchor, the True Daily Open mode already gives you the exchange's own reference, which is the other genuinely meaningful one.

SAMPLE SIZE
If your data history cannot supply the number of periods you asked for, the table footer shows what was actually used and a message appears on the chart. The statistics are still valid, they are just built on fewer samples. Be more sceptical of a Reach figure built on 20 periods than one built on 200.

WHAT "TRUE DAILY OPEN" MEANS ON YOUR INSTRUMENT
It is the open of the 1D candle exactly as TradingView builds it for that symbol — so it follows each market's own session definition rather than imposing one:

  US stocks          09:30 New York (regular session)
  Euronext stocks    09:00 local exchange time
  CME index futures  18:00 New York, previous day
  Other futures      that product's own session start, which differs by complex (grains, energy, metals and softs do not all open at the same time)
  Forex and CFDs     typically 17:00 New York
  Crypto             00:00 UTC

One thing worth knowing: for instruments with a pre/post market, the daily candle follows YOUR CHART'S extended-hours setting. Turn extended hours on for a US stock and the daily open becomes the pre-market open rather than 09:30. That is consistent with what you see on the chart, but it does mean two traders looking at the same stock with different session settings will see different levels. If that matters to you, fix your chart's session setting and leave it alone.

If you trade something unusual and want to be sure, put the indicator on a 1H chart and compare the O line against the open of the daily candle on a 1D chart. They should match to the tick.

THE SAME ON EVERY CHART TIMEFRAME
Everything the script draws is read from the mapping period's own context, never rebuilt from chart bars. Put a 1W mapping on a 1D chart, then a 4H, then a 1H, then a 5m: the anchor, all five levels and every statistic are the same prices every time.

That is a deliberate design decision, not a detail. Rebuilding the anchor from chart bars cannot guarantee it, because bar alignment, session definitions, holidays and gaps all differ between timeframes — and a level that moves when you change timeframe is worse than no level at all.

REPAINTING
No level moves once it is drawn. Every level is fixed the moment its period opens and stays there until the next period begins.

Being precise about how that holds, since the script does use lookahead:

  1. Every statistic — the means, the medians, the Reach percentages, the
     sample counts — is computed from COMPLETED periods only. The forming
     period's high, low and close never enter any of them. This is the part
     that would leak the future, and it does not.

  2. The five levels are built from those statistics plus the current period's
     OPENING price, and drawn between its start and end timestamps. All three
     of those are known the instant the period begins, so reading them ahead is
     not future information. This is the standard, documented way to anchor a
     higher-timeframe open.

  3. One further value is read: the current period's running high and low. It
     feeds exactly one thing — the Hit column, which reports whether the period
     SO FAR has traded through a level — and that column is only ever drawn on
     the last bar, where "so far" means right now. No level, no statistic and no
     alert depends on it, and nothing about it is plotted historically.

Point 3 is worth stating plainly because it is the kind of thing that deserves scrutiny in an open-source script. It is read from the period's own context rather than rebuilt from chart bars for a concrete reason: on a live chart, a script is not guaranteed to calculate over the full period, so counting back through chart bars can silently measure only a recent slice of it — and do so differently in Bar Replay than in real time.

WHEN THERE IS NOT ENOUGH HISTORY
If the symbol does not have as many completed periods as your Lookback asks for — 90 weekly periods is nearly two years, and plenty of symbols do not have that — the script does not hide anything and does not error out.

It uses every period that does exist, shows the real count in the table footer as for example "n 47/90", and puts a notice at the bottom of the chart telling you the sample is smaller than you requested. The levels remain valid; they simply rest on fewer samples, and you can decide whether that is enough for you. Lowering Lookback to a number the symbol can actually supply removes the notice.

The statistics table never disappears because of missing data. If a value genuinely cannot be computed it reads n/a, so you can always see what the script is and is not able to do.

════════════════════════════════════════

SETTINGS

1 — MAPPING PERIODS
Two independent slots, each with its own on/off toggle. Defaults are 1D on, 1W off.
Daily anchor mode: True Daily Open, or NY Midnight Open (00:00 America/New_York).
Lookback: how many completed periods feed the statistics. Default 90. In Matched sampling this counts occurrences of the current slot.
Sample Selection: Matched or Rolling. Defaults to Matched. See the section above.
Calculation method: Mean, Median, or Both. Defaults to Both.

2 — "BOTH" MODE ZONES
Fill colours for the mean-to-median zones. Sits directly under Calculation method because it only has an effect when that is set to Both.

3 — LEVEL LINES, COLOURS & LABELS
Colour, line style and thickness for each of the five levels, listed in the same top-to-bottom order they appear on the chart. Level labels can be turned off.

4 — STATISTICS TABLE
On/off; which mapping period it describes (defaults to period 1); slot label time zone (defaults to New York; set it to match your chart); position (all eight edge and corner slots, including top and bottom centre; defaults to Middle Right); text size (defaults to Normal).

5 — ALERTS
Which levels can fire, and what counts as reaching one.

6 — WARNINGS
On/off for the on-chart notices described above. The warning panel automatically places itself away from the statistics table, so the two never overlap wherever you put the table.

════════════════════════════════════════

ALERTS

Six alert conditions are available:

  +D reached
  -M reached
  Open crossed
  +M reached
  -D reached
  Any enabled level

ALERTS COME FROM MAPPING PERIOD 1 ONLY. Worth stating plainly, because nothing on
screen will tell you otherwise: if you untick mapping period 1 and run only period
2, these six conditions still appear in TradingView's dropdown and you can still
create the alert — it simply never fires. If you want alerts on a particular
period, put that period in SLOT 1.

Settings section 5 controls two things. First, which levels are allowed to fire — untick a level and it will never trigger, even if you created an alert for it. Second, what counts as reaching a level:

  Touches the level (wick)  — fires as soon as any part of the bar reaches the
                              level. Earlier and more sensitive.
  Closes beyond the level   — fires only when a bar CLOSES past it. Later, and
                              fewer false triggers.

TO CREATE AN ALERT

  1. Set the tickboxes in section 5 the way you want them, then press Ok.
  2. Right-click the chart and choose Add alert (or press Alt+A).
  3. In the Condition dropdown at the top, select "Stat-Map (Gigi)".
  4. In the second dropdown, pick the level you want. Use "Any enabled level" if
     you would rather have one alert covering all of them.
  5. Set Trigger to "Once Per Bar Close" for confirmed signals, or "Once Per Bar"
     for intrabar.
  6. Press Create. Repeat for each level you want separately.

The levels jumping to new prices at the start of a period never by itself sends an alert. A genuine touch on that opening bar does, though — an opening bar that runs from the anchor open straight into a level is a real event, and both the Hit column and the alerts treat it as one.

════════════════════════════════════════

Open source under the Mozilla Public License 2.0. You are welcome to read, learn from and build on the code.

Feedback and bug reports are genuinely welcome — if you find a symbol or timeframe where something looks wrong, please say so.

— Gigi_Luigino

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gigi_Luigino

//@version=6

// =====================================================================================
//  STATISTICAL MAPPING - TRUE + MIDNIGHT OPEN
//  Author: Gigi_Luigino
//
//  WHAT IT DOES
//  ------------
//  For a chosen mapping period (1D and/or 1W) the script measures, over the last N
//  completed periods, how far price travelled AWAY from the period open in the
//  direction of the close ("distribution", D) and how far it travelled AGAINST the
//  close before resolving ("manipulation", M).
//
//  It then projects the average (mean) or typical (median) of those two distances
//  from the CURRENT period's open, producing five levels:
//
//      +D   distribution projected above the open
//      -M   manipulation projected above the open
//       O   the anchor open itself
//      +M   manipulation projected below the open
//      -D   distribution projected below the open
//
//  DESIGN NOTES ON ANCHORING AND NON-REPAINTING
//  -------------------------------------------
//  Everything the script draws is taken from the MAPPING PERIOD'S OWN CONTEXT, never
//  rebuilt from chart bars. That is what makes the output identical on every chart
//  timeframe: put a 1W mapping on a 1D, 4H, 1H or 5m chart and the anchor, the levels and
//  the statistics are the same prices every time. Deriving the anchor from chart bars
//  cannot guarantee that, because chart bar alignment, sessions, holidays and gaps all
//  differ between timeframes.
//
//  barmerge.lookahead_on is used, and it is used SAFELY. Two rules make that true:
//    1. Only `time`, `time_close` and `open` of the CURRENT period are read with it.
//       A period's opening price and its start/end timestamps are all known the instant
//       that period begins, so this is not future information - it is the standard,
//       documented way to anchor a higher-timeframe open.
//    2. Every statistic is computed from COMPLETED periods only (offsets 1..lookback
//       inside the mapping period's context). The forming period's high, low and close
//       are never read. This is the part that would leak the future, and it does not.
//  The levels are therefore fixed the moment a period opens and never move again.
//
//  UI LAYOUT NOTE (read before editing any input title)
//  ---------------------------------------------------
//  Pine gives no alignment control in the settings dialog. Non-inline rows share one
//  label column whose width is set by the WIDEST non-inline title in the whole panel;
//  inline rows place each widget straight after its own title. The Unicode pad
//  constants below (PAD_W / PAD_M) are the only way to align inline rows.
//  Changing the text of any title changes the layout. "+M / -M Zone Colour" is the
//  current load-bearing non-inline title - shortening it will shift the whole column.
// =====================================================================================

// max_bars_back covers the deepest history read in the script: the statistics read open[i]
// back to `lookback` (max 500) inside the mapping period's context. Pine's default buffer
// is 300, which would fail at high Lookback settings.
indicator("Statistical Mapping - True + Midnight Open", "Stat-Map (Gigi)", overlay = true, max_lines_count = 20, max_labels_count = 20, max_boxes_count = 20, max_bars_back = 500)

// -------------------------------------------------------------------------------------
// UI ALIGNMENT PAD CHARACTERS
// TradingView strips trailing ASCII spaces from input titles but not these two.
// Widths below were MEASURED from a rendered settings panel by least-squares fit over
// all five level rows (residuals under 0.6 px), NOT assumed from font metrics:
//   PAD_W = U+2007 FIGURE SPACE  -> 17.39 px  (at 2x device pixels)
//   PAD_M = U+2005 FOUR-PER-EM   ->  6.26 px
// U+200A HAIR SPACE measured ~1 px and is not usable as a tuning unit, so it is not used.
// -------------------------------------------------------------------------------------
const string PAD_W = " "
const string PAD_M = " "

// Level-row titles, padded so every colour swatch lands on a common anchor.
// Verified against a rendered panel: +D, -M and +M landed identically; O and -D were
// the only rows still drifting, so both were re-expressed with W-heavy combinations.
// PAD_M carries the larger relative measurement error, so using fewer of them makes the
// result more robust: total PAD_M count across the section went from 16 to 7.
// Predicted residual spread is about 0.6 px at 2x = 0.31 CSS px.
//
// The anchor cannot sit left of the +M row's zero-padding position, because padding can
// only ADD width, never remove it. +M has the widest natural title and therefore sets
// the hard minimum for the whole section.
const string T_PLUSD  = "+D" + PAD_W + PAD_W
const string T_MINUSM = "-M" + PAD_W + PAD_W
const string T_OPEN   = "O"  + PAD_W + PAD_W + PAD_W
const string T_PLUSM  = "+M" + PAD_W + PAD_M + PAD_M
const string T_MINUSD = "-D" + PAD_M + PAD_M + PAD_M + PAD_M + PAD_M + PAD_M

// -------------------------------------------------------------------------------------
// CONSTANTS
// -------------------------------------------------------------------------------------
const string GROUP_TF     = "1  ›  MAPPING PERIODS"
const string GROUP_BOTH   = "2  ›  \"BOTH\" MODE ZONES"
const string GROUP_STYLE  = "3  ›  LEVEL LINES, COLOURS & LABELS"
const string GROUP_TABLE  = "4  ›  STATISTICS TABLE"
const string GROUP_ALERTS = "5  ›  ALERTS"
const string GROUP_WARN   = "6  ›  WARNINGS"

const string TRIG_TOUCH = "Touches the level (wick)"
const string TRIG_CLOSE = "Closes beyond the level"

const string ANCHOR_TRUE_DAILY  = "True Daily Open"
const string ANCHOR_NY_MIDNIGHT = "NY Midnight Open"

// Pine cannot read the chart's Time Zone setting - TradingView treats it as display-only
// and scripts have no visibility over it. So the slot label needs to be told which zone to
// print in. This affects the LABEL ONLY: slot grouping and every level are unaffected,
// because changing zone shifts every bar by the same amount and so groups them identically.
const string TZ_EXCHANGE  = "Exchange"
const string TZ_UTC       = "UTC"
const string TZ_NEWYORK   = "New York"
const string TZ_CHICAGO   = "Chicago"
const string TZ_LONDON    = "London"
const string TZ_FRANKFURT = "Frankfurt"
const string TZ_TOKYO     = "Tokyo"
const string TZ_SYDNEY    = "Sydney"

const string SAMPLE_MATCHED = "Matched"
const string SAMPLE_ROLLING = "Rolling"

// Ceiling on the per-slot store. 300 covers a 5-minute mapping period (288 slots in a day);
// anything finer falls back to Rolling. Pine caps a matrix at 100,000 elements, so rows
// multiplied by Lookback must stay under that - guarded explicitly at startup.
const int    MAX_SLOTS = 300

const string METHOD_MEAN   = "Mean"
const string METHOD_MEDIAN = "Median"
const string METHOD_BOTH   = "Both"

const string STYLE_SOLID  = "────"
const string STYLE_DASHED = "----"
const string STYLE_DOTTED = "...."

const string POS_TL = "Top Left"
const string POS_TC = "Top Center"
const string POS_TR = "Top Right"
const string POS_ML = "Middle Left"
const string POS_MR = "Middle Right"
const string POS_BL = "Bottom Left"
const string POS_BC = "Bottom Center"
const string POS_BR = "Bottom Right"

const string AUTHOR_CREDIT = "Gigi_Luigino"

const string TABLE_SLOT_1 = "Mapping Period 1"
const string TABLE_SLOT_2 = "Mapping Period 2"

const string NY_TZ         = "America/New_York"
const string NY_SOURCE_TF  = "60"


// Tooltips -----------------------------------------------------------------------------
const string TT_TF1 = "Mapping period 1. Tick to enable.\n\nIF BOTH PERIODS ARE ENABLED, THIS ONE IS WHAT THE STATISTICS TABLE DESCRIBES. The table only ever covers one period at a time. To point it at period 2 instead, use \"Show Statistics For\" in the statistics table section. The chart draws both sets of levels either way.\n\nIMPORTANT: the chart timeframe must be STRICTLY LOWER than this period for the levels to be drawn. A 1D mapping needs a 4H, 1H, 15m, 5m... chart. On a 1D chart or higher the 1D levels are hidden by design, because a period cannot be projected across itself."

const string TT_TF2 = "Mapping period 2 (optional, off by default).\n\nWith both periods enabled the statistics table describes period 1, not this one, unless you point it here with \"Show Statistics For\" in the statistics table section. The chart draws both sets of levels either way. Same rule: the chart timeframe must be STRICTLY LOWER than this period.\n\nA 1W mapping therefore needs a 1D chart or lower."

const string TT_ANCHOR = "Which open the levels are measured from.\n\n• True Daily Open — the exchange's own daily open, i.e. the open of the 1D candle you see on the chart.\n\n• NY Midnight Open — 00:00 America/New_York. Days are rebuilt from 1-hour data so the statistics stay fast and work correctly in Bar Replay.\n\nAPPLIES TO THE 1D MAPPING ONLY. If a mapping period is set to anything other than 1D (for example 1W) it always uses that period's true open and this setting is ignored.\n\nNY days are rebuilt from 1-hour data inside the anchor's own context, so the anchor and every level are identical on every chart timeframe. Midnight New York falls on an hourly boundary for the futures, forex and crypto markets this mode is built for, which is what makes the reconstruction exact.\n\nDAYLIGHT SAVING is handled automatically. America/New_York is a full timezone rule, not a fixed offset, so the anchor follows local New York clock time all year (EST in winter, EDT in summer) and shifts relative to UTC on its own. The two changeover days are 23 and 25 hours long; days are rebuilt from the New York calendar date rather than by counting bars, so those two days are measured correctly as well."

const string TT_SAMPLING = "Which past periods the statistics are measured from.\n\nMATCHED - only periods from the SAME SLOT.\n\nOn an intraday mapping period that means the same time of day. With a 1H mapping at 09:15, the statistics come from the 09:00-10:00 hour of each of the previous days. At 10:00 it switches to the 10:00-11:00 hour of those days. On a 1D mapping period it means the same weekday: a Thursday is measured against previous Thursdays.\n\nROLLING - the last N periods in a row, whatever time of day they were.\n\nWHY MATCHED IS THE DEFAULT\nMarkets do not behave the same at every hour. The 09:30 New York open and the 03:00 Asian session have completely different character. Averaging them together produces a number that describes neither, which is why range projections often look far too small at the open. Matching the slot compares like with like.\n\nWHAT THIS DOES TO LOOKBACK\nIn Matched mode Lookback counts OCCURRENCES of the slot, not consecutive periods. Lookback 90 on a 1H mapping means the last 90 appearances of that hour - roughly 90 trading days, not 90 hours.\n\nMatched has no meaning on a 1W mapping period, since a week contains one of each, so it falls back to Rolling there and says so on the chart."

const string TT_LOOKBACK = "How many COMPLETED mapping periods feed the statistics.\n\nIn \"Matched\" sampling this counts OCCURRENCES of the current slot rather than consecutive periods: on a 1H mapping, 90 means the last 90 appearances of this hour, roughly 90 trading days.\n\n90 daily periods is roughly one quarter of trading. Smaller = more reactive to the current regime. Larger = more stable but slower to adapt.\n\nThe statistics table shows how many periods were actually usable — if that number is well below your setting, your data history or plan is the limit, not the script."

const string TT_METHOD = "How the historical distances are summarised.\n\n• Mean — the arithmetic average. Sensitive to outlier days (news, gaps).\n\n• Median — the middle value. Ignores outliers, usually the tighter and more realistic target.\n\n• Both — draws a shaded zone between the mean and the median instead of a single line. The zone width is itself information: wide means the sample is skewed by outliers, narrow means the days are consistent."

const string TT_ROW_PLUSD  = "+D  Upside distribution.\nColour, line style, thickness.\n\nOn an up day this is how far price typically ran ABOVE the open before the close. Treated as an upside objective.\n\nWHEN IS IT USUALLY REACHED?\nOn trending days and on high-volatility days. Reaching +D means the day has already travelled further above its open than a typical day manages, so by definition it is not a quiet, range-bound session. On calm days price often never gets near it.\n\nThat is a description of what the level means, not a prediction about today."
const string TT_ROW_MINUSM = "-M  Upside manipulation.\nColour, line style, thickness.\n\nOn a DOWN day this is how far price typically poked ABOVE the open before rolling over. Treated as an upside trap / short area.\n\nWHEN IS IT USUALLY REACHED?\nOn most days, including quiet ones - it sits close to the open. Check the Reach column: -M is normally one of the highest numbers in the table. Because it is reached so often, price touching it on its own tells you very little."
const string TT_ROW_OPEN   = "O  The anchor open (True Daily or NY Midnight).\nColour, line style, thickness.\n\nEverything else is measured from this line. Price above it = bullish side of the period, below = bearish side."
const string TT_ROW_PLUSM  = "+M  Downside manipulation.\nColour, line style, thickness.\n\nOn an UP day this is how far price typically dipped BELOW the open before rallying. Treated as a downside trap / long area.\n\nWHEN IS IT USUALLY REACHED?\nOn most days, including quiet ones - it sits close to the open. Check the Reach column: +M is normally one of the highest numbers in the table. Because it is reached so often, price touching it on its own tells you very little."
const string TT_ROW_MINUSD = "-D  Downside distribution.\nColour, line style, thickness.\n\nOn a down day this is how far price typically ran BELOW the open before the close. Treated as a downside objective.\n\nWHEN IS IT USUALLY REACHED?\nSame as +D but to the downside: on trending and high-volatility days. A quiet session usually stalls well above it.\n\nThat is a description of what the level means, not a prediction about today."

const string TT_LABELS = "Draw the level name (e.g. \"1D +D\") at the right end of each line. Hovering a label shows its exact price."

const string TT_ZONE_M = "Fill colour for the +M and -M zones when Calculation method is set to \"Both\". The zone spans from the mean to the median."
const string TT_ZONE_D = "Fill colour for the +D and -D zones when Calculation method is set to \"Both\". The zone spans from the mean to the median."

const string TT_TABLE = "Show the statistics panel.\n\nIt describes ONE mapping period at a time. Which one is set by \"Show Statistics For\" below, and named in the footer's first cell.\n\nFor each level it reports:\n\n• Price — where the level sits right now.\n\n• Dist — how far that is from the anchor open, in price.\n\n• Reach — out of the periods in the lookback, the percentage that travelled AT LEAST this far from their own open, in this direction.\n\nWorked example: if the lookback is 90 days, +D sits 419 points above the open and Reach shows 25.6%, that means: on 23 of the last 90 days, price traded 419 points or more above that day's open at some point. On the other 67 days it never got that far.\n\nSo a LOW Reach marks a level price rarely gets to — an extended target. A HIGH Reach marks a level price reaches on most days — routine, and weak evidence of anything on its own.\n\n• Hit — whether the CURRENT period has already traded through the level.\n\nReach is a historical frequency measured on past data. It is not a probability and not a forecast."

const string TT_TABLE_SLOT = "Which mapping period the table describes.\n\nThe table only ever describes ONE period, because the two have entirely different levels, distances and statistics - interleaving them would be unreadable.\n\nIf both periods are enabled, this chooses between them. If the period you pick is not currently on screen (its levels are hidden because your chart timeframe is not lower than it), the table falls back to the other one rather than showing nothing.\n\nThe footer's first cell always names the period the table is describing, next to the anchor mode and the calculation method, so you can confirm which one you are reading at a glance."

const string TT_SLOT_TZ = "Which time zone the slot label in the table footer is printed in.\n\nDefaults to New York, since that is the reference most index-futures and FX traders keep their charts on. If your chart is set to anything else, change this to match it.\n\nSET THIS TO MATCH YOUR CHART. Pine scripts cannot read TradingView's chart Time Zone setting - it is treated as a display preference that scripts have no access to - so if you have changed your chart away from Exchange time, the label has no way of knowing unless you tell it here.\n\nExample: MNQ trades on CME, whose exchange time zone is Chicago. If your chart is set to New York, the label reads one hour earlier than your chart until you set this to New York.\n\nThis affects the LABEL ONLY. Slot grouping, every level, every statistic and the Reach figures are completely unaffected by this setting - changing time zone shifts every bar by the same amount, so exactly the same periods are grouped together either way."

const string TT_TABLE_POS  = "Where the statistics panel sits on the chart.\n\nThe warnings panel automatically places itself in the opposite band, so the two never overlap wherever you put this."
const string TT_TABLE_SIZE = "Text size of the statistics panel."

const string TT_ALERT_ROW = "Tick the levels you want alerts for. Unticked levels never fire, even if you created an alert for them.\n\nHOW TO ACTUALLY CREATE THE ALERT (TradingView will not do it for you):\n\n1. Set these tickboxes the way you want them, then press Ok.\n2. Right-click the chart and choose Add alert, or press the Alt+A shortcut.\n3. In the Condition dropdown at the top, select \"Stat Map (Gigi)\".\n4. In the second dropdown, pick the level you want, for example \"+D reached\". There is one entry per level, plus \"Any enabled level\" which fires for every level you have ticked above.\n5. Set Trigger to \"Once Per Bar Close\" if you want confirmed signals only, or \"Once Per Bar\" for intrabar.\n6. Press Create.\n\nRepeat for each level you want separately. If you would rather have one single alert covering all of them, use \"Any enabled level\" in step 4."

const string TT_ALERT_TRIGGER = "When should the alert be sent?\n\nTOUCHES THE LEVEL (WICK)\nThe alert is sent the moment price first touches the line, even if it bounces straight back off it. You hear about it early, but you will get more alerts, and some of them will be brief pokes that go nowhere.\n\nCLOSES BEYOND THE LEVEL\nThe alert waits for a whole bar to finish on the far side of the line. You hear about it later, but most of the brief pokes get filtered out.\n\nNot sure? Start with Touches. It matches what most people mean by \"price reached the level\". Switch to Closes if you find you are getting too many alerts.\n\nEither setting: the lines jumping to their new prices at the start of a new period never by itself sends an alert. A genuine touch on that opening bar does, though - an opening bar that runs from the open straight into a level is a real event."

const string TT_WARN = "Show a small notice at the bottom of the chart when the indicator cannot draw everything you asked for — most often because the chart timeframe is not lower than the mapping period, or because there is not enough history for your lookback.\n\nTurn this off once you are comfortable with the behaviour."

// -------------------------------------------------------------------------------------
// INPUTS - 1. MAPPING PERIODS
// -------------------------------------------------------------------------------------
enableTf1Input = input.bool(true, "", group = GROUP_TF, inline = "tf1")
tf1Input       = input.timeframe("D", "", group = GROUP_TF, inline = "tf1", tooltip = TT_TF1)
enableTf2Input = input.bool(false, "", group = GROUP_TF, inline = "tf2")
tf2Input       = input.timeframe("W", "", group = GROUP_TF, inline = "tf2", tooltip = TT_TF2)

anchorModeInput = input.string(ANCHOR_TRUE_DAILY, "Daily Anchor Mode", options = [ANCHOR_TRUE_DAILY, ANCHOR_NY_MIDNIGHT], group = GROUP_TF, tooltip = TT_ANCHOR)
lookbackInput   = input.int(90, "Lookback (Periods)", minval = 10, maxval = 500, group = GROUP_TF, tooltip = TT_LOOKBACK)
samplingInput   = input.string(SAMPLE_MATCHED, "Sample Selection", options = [SAMPLE_MATCHED, SAMPLE_ROLLING], group = GROUP_TF, tooltip = TT_SAMPLING)
calcMethodInput = input.string(METHOD_BOTH, "Calculation Method", options = [METHOD_MEAN, METHOD_MEDIAN, METHOD_BOTH], group = GROUP_TF, tooltip = TT_METHOD)

// -------------------------------------------------------------------------------------
// INPUTS - 2. "BOTH" MODE ZONES
// Sits directly under Calculation method because it only has an effect in "Both" mode.
// NOTE: "+M / -M Zone Colour" is the widest non-inline title in the panel and therefore
// sets the shared label column width. Shortening it moves every non-inline widget.
// -------------------------------------------------------------------------------------
bothManipulationBoxColorInput = input.color(color.new(color.rgb(242, 54, 69), 90), "+M / -M Zone Colour", group = GROUP_BOTH, tooltip = TT_ZONE_M)
bothDistributionBoxColorInput = input.color(color.new(color.rgb(130, 130, 130), 90), "+D / -D Zone Colour", group = GROUP_BOTH, tooltip = TT_ZONE_D)

// -------------------------------------------------------------------------------------
// INPUTS - 3. LEVEL LINES, COLOURS & LABELS
// Rows are declared top-to-bottom in the same order they appear on the chart.
// -------------------------------------------------------------------------------------
plusDColorInput  = input.color(color.rgb(130, 130, 130), T_PLUSD, group = GROUP_STYLE, inline = "plusD")
plusDStyleInput  = input.string(STYLE_SOLID, "", options = [STYLE_SOLID, STYLE_DASHED, STYLE_DOTTED], group = GROUP_STYLE, inline = "plusD")
plusDWidthInput  = input.int(2, "", minval = 1, maxval = 4, group = GROUP_STYLE, inline = "plusD", tooltip = TT_ROW_PLUSD)

minusMColorInput = input.color(color.rgb(242, 54, 69), T_MINUSM, group = GROUP_STYLE, inline = "minusM")
minusMStyleInput = input.string(STYLE_SOLID, "", options = [STYLE_SOLID, STYLE_DASHED, STYLE_DOTTED], group = GROUP_STYLE, inline = "minusM")
minusMWidthInput = input.int(2, "", minval = 1, maxval = 4, group = GROUP_STYLE, inline = "minusM", tooltip = TT_ROW_MINUSM)

openColorInput   = input.color(color.rgb(130, 130, 130), T_OPEN, group = GROUP_STYLE, inline = "open")
openStyleInput   = input.string(STYLE_SOLID, "", options = [STYLE_SOLID, STYLE_DASHED, STYLE_DOTTED], group = GROUP_STYLE, inline = "open")
openWidthInput   = input.int(1, "", minval = 1, maxval = 4, group = GROUP_STYLE, inline = "open", tooltip = TT_ROW_OPEN)

plusMColorInput  = input.color(color.rgb(242, 54, 69), T_PLUSM, group = GROUP_STYLE, inline = "plusM")
plusMStyleInput  = input.string(STYLE_SOLID, "", options = [STYLE_SOLID, STYLE_DASHED, STYLE_DOTTED], group = GROUP_STYLE, inline = "plusM")
plusMWidthInput  = input.int(2, "", minval = 1, maxval = 4, group = GROUP_STYLE, inline = "plusM", tooltip = TT_ROW_PLUSM)

minusDColorInput = input.color(color.rgb(130, 130, 130), T_MINUSD, group = GROUP_STYLE, inline = "minusD")
minusDStyleInput = input.string(STYLE_SOLID, "", options = [STYLE_SOLID, STYLE_DASHED, STYLE_DOTTED], group = GROUP_STYLE, inline = "minusD")
minusDWidthInput = input.int(2, "", minval = 1, maxval = 4, group = GROUP_STYLE, inline = "minusD", tooltip = TT_ROW_MINUSD)

showLabelsInput  = input.bool(true, "Show Level Labels", group = GROUP_STYLE, tooltip = TT_LABELS)

// -------------------------------------------------------------------------------------
// INPUTS - 4. STATISTICS TABLE
// -------------------------------------------------------------------------------------
showTableInput  = input.bool(true, "Show Statistics Table", group = GROUP_TABLE, tooltip = TT_TABLE)
tableSlotInput  = input.string(TABLE_SLOT_1, "Show Statistics For", options = [TABLE_SLOT_1, TABLE_SLOT_2], group = GROUP_TABLE, tooltip = TT_TABLE_SLOT)
slotTzInput     = input.string(TZ_NEWYORK, "Slot Time Zone", options = [TZ_EXCHANGE, TZ_UTC, TZ_NEWYORK, TZ_CHICAGO, TZ_LONDON, TZ_FRANKFURT, TZ_TOKYO, TZ_SYDNEY], group = GROUP_TABLE, tooltip = TT_SLOT_TZ)
tablePosInput   = input.string(POS_MR, "Table Position", options = [POS_TL, POS_TC, POS_TR, POS_ML, POS_MR, POS_BL, POS_BC, POS_BR], group = GROUP_TABLE, tooltip = TT_TABLE_POS)
tableSizeInput  = input.string("Normal", "Table Text Size", options = ["Tiny", "Small", "Normal"], group = GROUP_TABLE, tooltip = TT_TABLE_SIZE)

// -------------------------------------------------------------------------------------
// INPUTS - 5. ALERTS
// -------------------------------------------------------------------------------------
alertTriggerInput = input.string(TRIG_TOUCH, "Trigger When Price", options = [TRIG_TOUCH, TRIG_CLOSE], group = GROUP_ALERTS, tooltip = TT_ALERT_TRIGGER)
alertPlusDInput   = input.bool(true,  "+D", group = GROUP_ALERTS, inline = "alertRow")
alertMinusMInput  = input.bool(true,  "-M", group = GROUP_ALERTS, inline = "alertRow")
alertOpenInput    = input.bool(false, "O",  group = GROUP_ALERTS, inline = "alertRow")
alertPlusMInput   = input.bool(true,  "+M", group = GROUP_ALERTS, inline = "alertRow")
alertMinusDInput  = input.bool(true,  "-D", group = GROUP_ALERTS, inline = "alertRow", tooltip = TT_ALERT_ROW)

// -------------------------------------------------------------------------------------
// INPUTS - 6. WARNINGS
// -------------------------------------------------------------------------------------
showWarningsInput = input.bool(true, "Show On-Chart Warnings", group = GROUP_WARN, tooltip = TT_WARN)

// -------------------------------------------------------------------------------------
// SMALL HELPERS
// -------------------------------------------------------------------------------------
f_timeframeDisplay(string timeframeInput) =>
    string lbl = timeframeInput == "" ? "Chart" : timeframeInput
    float minuteValue = str.tonumber(lbl)
    if not na(minuteValue)
        int minuteCount = int(minuteValue)
        lbl := minuteCount >= 60 and minuteCount % 60 == 0 ? str.tostring(int(minuteCount / 60)) + "H" : str.tostring(minuteCount) + "m"
    lbl := lbl == "D" or lbl == "1D" ? "1D" : lbl
    lbl := lbl == "W" or lbl == "1W" ? "1W" : lbl
    lbl := lbl == "M" or lbl == "1M" ? "1M" : lbl
    lbl

f_isDailyTimeframe(string timeframeInput, bool chartIsDaily) =>
    timeframeInput == "" ? chartIsDaily : timeframeInput == "D" or timeframeInput == "1D" or timeframeInput == "1440"

f_timeframeSeconds(simple string timeframeInput) =>
    timeframeInput == "" ? timeframe.in_seconds(timeframe.period) : timeframe.in_seconds(timeframeInput)

// The chart timeframe must be STRICTLY LOWER than the mapping period. This is not a bug:
// a period cannot be projected forward across a chart bar that already contains it.
f_slotVisibleOnChart(simple string timeframeInput) =>
    int chartSeconds = timeframe.in_seconds(timeframe.period)
    int slotSeconds = f_timeframeSeconds(timeframeInput)
    not na(chartSeconds) and not na(slotSeconds) and chartSeconds < slotSeconds

f_nyKey(int sourceTime) =>
    na(sourceTime) ? na : year(sourceTime, NY_TZ) * 10000 + month(sourceTime, NY_TZ) * 100 + dayofmonth(sourceTime, NY_TZ)

f_nextNyMidnight(int sourceTime) =>
    na(sourceTime) ? na : timestamp(NY_TZ, year(sourceTime, NY_TZ), month(sourceTime, NY_TZ), dayofmonth(sourceTime, NY_TZ) + 1, 0, 0)

f_calcMean(array<float> samples) =>
    float total = 0.0
    int count = 0
    int n = array.size(samples)
    if n > 0
        for i = 0 to n - 1
            float s = array.get(samples, i)
            if not na(s)
                total += s
                count += 1
    count > 0 ? total / count : na

f_calcMedian(array<float> samples) =>
    array<float> clean = array.new_float()
    int n = array.size(samples)
    if n > 0
        for i = 0 to n - 1
            float s = array.get(samples, i)
            if not na(s)
                array.push(clean, s)
    int valid = array.size(clean)
    float med = na
    if valid > 0
        array.sort(clean, order.ascending)
        int mid = int(math.floor(valid / 2.0))
        med := valid % 2 == 1 ? array.get(clean, mid) : (array.get(clean, mid - 1) + array.get(clean, mid)) / 2.0
    med


f_minNa(float a, float b) =>
    na(a) ? b : na(b) ? a : math.min(a, b)

// Share of past periods whose excursion reached at least `distance`.
f_reachPct(array<float> excursions, float distance) =>
    float pct = na
    int n = array.size(excursions)
    if n > 0 and not na(distance)
        int hits = 0
        int valid = 0
        for i = 0 to n - 1
            float e = array.get(excursions, i)
            if not na(e)
                valid += 1
                if e >= distance
                    hits += 1
        pct := valid > 0 ? 100.0 * hits / valid : na
    pct

// -------------------------------------------------------------------------------------
// STATISTICS ENGINE
// Both variants read ONLY completed periods. No lookahead is used anywhere.
// -------------------------------------------------------------------------------------

// True-open statistics, evaluated inside the mapping period's own context.
//
// SAMPLE SELECTION
// Each completed period is filed into a SLOT and the statistics are read back from the slot
// the current period belongs to. What defines a slot depends on the mode:
//
//   Matched, intraday period  -> time of day. A 1H mapping files the 09:00 hour separately
//                                from the 10:00 hour, so the 09:00 levels are built only
//                                from previous 09:00 hours.
//   Matched, daily period     -> weekday. Thursdays are measured against previous Thursdays.
//   Rolling                   -> one slot for everything, i.e. the last N periods in a row.
//
// Three numbers per period are stored - upward excursion, downward excursion and direction.
// Distribution, manipulation, both reach figures and the up/down split all derive from those,
// so three matrices cover it rather than six.
//
// ORDER MATTERS HERE. The statistics are read from the store BEFORE the current period is
// written into it. That is what keeps a period out of its own statistics.
//
// Writing happens only on a CONFIRMED bar. Pine does not roll back collections between
// realtime ticks the way it rolls back plain variables, so writing on an unconfirmed bar
// would file the same period again on every tick and quietly corrupt the sample.
f_htfStats(simple int lookback, simple string method, simple bool matched, simple bool weekdayMode, simple int rows) =>
    var matrix<float> mUp    = matrix.new<float>(rows, lookback, na)
    var matrix<float> mDn    = matrix.new<float>(rows, lookback, na)
    var matrix<float> mDir   = matrix.new<float>(rows, lookback, na)
    var map<int, int> slotRow = map.new<int, int>()
    var array<int>    slotPtr = array.new_int(rows, 0)
    var int nextRow = 0

    int slotKey = matched ? (weekdayMode ? dayofweek(time_close - 1, syminfo.timezone) : hour(time, syminfo.timezone) * 60 + minute(time, syminfo.timezone)) : 0

    // ---- READ: the current period's slot, as the store stands right now ----
    array<float> distSamples  = array.new_float()
    array<float> manipSamples = array.new_float()
    array<float> upExc        = array.new_float()
    array<float> dnExc        = array.new_float()
    int bullCount = 0
    int bearCount = 0

    if map.contains(slotRow, slotKey)
        int readRow = map.get(slotRow, slotKey)
        array<float> rowUp  = matrix.row(mUp,  readRow)
        array<float> rowDn  = matrix.row(mDn,  readRow)
        array<float> rowDir = matrix.row(mDir, readRow)
        for i = 0 to lookback - 1
            float u = array.get(rowUp,  i)
            float d = array.get(rowDn,  i)
            float r = array.get(rowDir, i)
            if not na(u) and not na(d) and not na(r)
                array.push(upExc, u)
                array.push(dnExc, d)
                if r > 0
                    array.push(distSamples, u)
                    array.push(manipSamples, d)
                    bullCount += 1
                if r < 0
                    array.push(distSamples, d)
                    array.push(manipSamples, u)
                    bearCount += 1

    float dMean   = f_calcMean(distSamples)
    float dMedian = f_calcMedian(distSamples)
    float mMean   = f_calcMean(manipSamples)
    float mMedian = f_calcMedian(manipSamples)

    // In "Both" mode the chart draws a zone spanning mean to median. The number that
    // matters is the NEAR edge - the first price of that zone price actually reaches - so
    // the reported distance, its Reach and the Hit test all use the smaller of the two.
    // Whichever is smaller is nearer the open on both sides, so one rule covers up and down.
    float dUse = method == METHOD_MEDIAN ? dMedian : method == METHOD_BOTH ? f_minNa(dMean, dMedian) : dMean
    float mUse = method == METHOD_MEDIAN ? mMedian : method == METHOD_BOTH ? f_minNa(mMean, mMedian) : mMean

    // ---- WRITE: file this period, now that it can no longer affect its own numbers ----
    if barstate.isconfirmed
        bool ok = not na(open) and not na(high) and not na(low) and not na(close) and high >= math.max(open, close) and low <= math.min(open, close)
        if ok
            int writeRow = na
            if map.contains(slotRow, slotKey)
                writeRow := map.get(slotRow, slotKey)
            if na(writeRow) and nextRow < rows
                writeRow := nextRow
                map.put(slotRow, slotKey, writeRow)
                nextRow += 1
            if not na(writeRow)
                int ptr = array.get(slotPtr, writeRow)
                matrix.set(mUp,  writeRow, ptr, high - open)
                matrix.set(mDn,  writeRow, ptr, open - low)
                matrix.set(mDir, writeRow, ptr, close > open ? 1.0 : close < open ? -1.0 : 0.0)
                array.set(slotPtr, writeRow, (ptr + 1) % lookback)

    // time / time_close / open belong to the CURRENT period and are safe under lookahead:
    // all three are known the instant the period begins.
    //
    // high and low are the current period's RUNNING extremes. They feed one thing only -
    // the Hit column, which reports whether the period so far has traded through a level -
    // and that column is drawn on the last bar alone, where "so far" means right now. No
    // plotted level, no statistic and no alert depends on them. They are read from the
    // period's own context rather than rebuilt from chart bars because chart-bar history is
    // not reliably available: on a live chart the script may calculate over only a short
    // recent window, which silently truncates any backward scan.
    [dMean, dMedian, mMean, mMedian, f_reachPct(upExc, dUse), f_reachPct(upExc, mUse), f_reachPct(dnExc, mUse), f_reachPct(dnExc, dUse), array.size(upExc), bullCount, bearCount, time, time_close, open, high, low]

// Push one finalised NY-midnight day into the rolling sample arrays.
f_pushNyPeriod(float o, float h, float l, float c, simple int lookback, array<float> dS, array<float> mS, array<float> uE, array<float> dE, array<int> dirs) =>
    bool ok = not na(o) and not na(h) and not na(l) and not na(c) and h >= math.max(o, c) and l <= math.min(o, c)
    if ok
        int dir = c > o ? 1 : c < o ? -1 : 0
        float dSample = dir == 1 ? h - o : dir == -1 ? o - l : na
        float mSample = dir == 1 ? o - l : dir == -1 ? h - o : na
        array.push(dirs, dir)
        array.push(uE, h - o)
        array.push(dE, o - l)
        if not na(dSample) and dSample >= 0.0
            array.push(dS, dSample)
        if not na(mSample) and mSample >= 0.0
            array.push(mS, mSample)
        while array.size(dirs) > lookback
            array.shift(dirs)
        while array.size(uE) > lookback
            array.shift(uE)
        while array.size(dE) > lookback
            array.shift(dE)
        while array.size(dS) > lookback
            array.shift(dS)
        while array.size(mS) > lookback
            array.shift(mS)
    ok

// NY-midnight statistics, rebuilt from 1-hour bars.
// 1H is used rather than 1m because 00:00 New York falls on an hourly boundary for the
// instruments this anchor is meant for, so the aggregation is exact, ~60x cheaper, stays
// inside TradingView's request limits, and behaves correctly under Bar Replay.
f_nyStats(simple int lookback, simple string method) =>
    var array<float> distSamples  = array.new_float()
    var array<float> manipSamples = array.new_float()
    var array<float> upExc        = array.new_float()
    var array<float> dnExc        = array.new_float()
    var array<int>   dirs         = array.new_int()
    var int   aStart = na
    var float aOpen  = na
    var float aHigh  = na
    var float aLow   = na
    var float aClose = na
    var int   aKey   = na
    var bool  started = false

    int k = f_nyKey(time)
    bool usable = not na(time) and not na(open) and not na(high) and not na(low) and not na(close) and not na(k)

    // Separate `if` statements (never if/else) so that every branch is void and Pine does
    // not have to reconcile branch return types.
    if usable
        bool isNewDay = not started or k != aKey
        if isNewDay and started
            f_pushNyPeriod(aOpen, aHigh, aLow, aClose, lookback, distSamples, manipSamples, upExc, dnExc, dirs)
        if isNewDay
            aStart  := time
            aOpen   := open
            aHigh   := high
            aLow    := low
            aClose  := close
            aKey    := k
            started := true
        if not isNewDay
            aHigh  := math.max(aHigh, high)
            aLow   := math.min(aLow, low)
            aClose := close

    int bullCount = 0
    int bearCount = 0
    int dn = array.size(dirs)
    if dn > 0
        for i = 0 to dn - 1
            int d = array.get(dirs, i)
            if d == 1
                bullCount += 1
            if d == -1
                bearCount += 1

    float dMean   = f_calcMean(distSamples)
    float dMedian = f_calcMedian(distSamples)
    float mMean   = f_calcMean(manipSamples)
    float mMedian = f_calcMedian(manipSamples)
    // In "Both" mode the chart draws a zone spanning mean to median. The number that
    // matters is the NEAR edge - the first price of that zone price actually reaches - so
    // the reported distance, its Reach and the Hit test all use the smaller of the two.
    // Whichever is smaller is nearer the open on both sides, so one rule covers up and down.
    float dUse = method == METHOD_MEDIAN ? dMedian : method == METHOD_BOTH ? f_minNa(dMean, dMedian) : dMean
    float mUse = method == METHOD_MEDIAN ? mMedian : method == METHOD_BOTH ? f_minNa(mMean, mMedian) : mMean

    // aHigh / aLow are the running extremes of the NY day being built. Same purpose and
    // same restriction as the high / low returned by f_htfStats above.
    [dMean, dMedian, mMean, mMedian, f_reachPct(upExc, dUse), f_reachPct(upExc, mUse), f_reachPct(dnExc, mUse), f_reachPct(dnExc, dUse), array.size(upExc), bullCount, bearCount, aStart, aOpen, aHigh, aLow]

// -------------------------------------------------------------------------------------
// PROJECTION
// -------------------------------------------------------------------------------------
f_projectLevels(float currentOpen, string method, float dMean, float dMedian, float mMean, float mMedian) =>
    float plusDMean   = na(currentOpen) or na(dMean)   ? na : currentOpen + dMean
    float minusMMean  = na(currentOpen) or na(mMean)   ? na : currentOpen + mMean
    float plusMMean   = na(currentOpen) or na(mMean)   ? na : currentOpen - mMean
    float minusDMean  = na(currentOpen) or na(dMean)   ? na : currentOpen - dMean
    float plusDMed    = na(currentOpen) or na(dMedian) ? na : currentOpen + dMedian
    float minusMMed   = na(currentOpen) or na(mMedian) ? na : currentOpen + mMedian
    float plusMMed    = na(currentOpen) or na(mMedian) ? na : currentOpen - mMedian
    float minusDMed   = na(currentOpen) or na(dMedian) ? na : currentOpen - dMedian

    float plusD  = method == METHOD_MEDIAN ? plusDMed  : plusDMean
    float minusM = method == METHOD_MEDIAN ? minusMMed : minusMMean
    float plusM  = method == METHOD_MEDIAN ? plusMMed  : plusMMean
    float minusD = method == METHOD_MEDIAN ? minusDMed : minusDMean

    [plusD, minusM, currentOpen, plusM, minusD, plusDMean, minusMMean, plusMMean, minusDMean, plusDMed, minusMMed, plusMMed, minusDMed]

// -------------------------------------------------------------------------------------
// DRAWING HELPERS
// -------------------------------------------------------------------------------------
// In "Both" mode the chart draws a ZONE spanning mean to median rather than one line, so
// the honest test for "has price reached this level" is the NEAR edge of that zone - the
// moment price first enters what is actually drawn. Testing the mean alone leaves the tick
// off while price is visibly inside the shaded band, which is confusing and simply wrong.
f_hitRef(float selected, float meanValue, float medianValue, bool bothMode, bool isAbove) =>
    float reference = selected
    if bothMode and not na(meanValue) and not na(medianValue)
        reference := isAbove ? math.min(meanValue, medianValue) : math.max(meanValue, medianValue)
    reference

// Inserts thousands separators. Pine's number formatting has no grouping option, so the
// digits are walked from the right and a comma dropped in after every third one. Sign and
// decimal part are split off first so that neither picks up a comma.
f_thousands(string src) =>
    string sign = str.startswith(src, "-") ? "-" : ""
    string body = sign == "-" ? str.substring(src, 1) : src
    int dotPos = str.pos(body, ".")
    string intPart = na(dotPos) ? body : str.substring(body, 0, dotPos)
    string fracPart = na(dotPos) ? "" : str.substring(body, dotPos)
    string grouped = ""
    int digits = str.length(intPart)
    if digits > 0
        for i = 0 to digits - 1
            grouped := str.substring(intPart, digits - 1 - i, digits - i) + grouped
            if (i + 1) % 3 == 0 and i < digits - 1
                grouped := "," + grouped
    sign + grouped + fracPart

f_fmtPrice(float v) =>
    na(v) ? "n/a" : f_thousands(str.tostring(v, format.mintick))

f_fmtPct(float v) =>
    na(v) ? "n/a" : str.tostring(v, "#.#") + "%"

f_lineStyle(string s) =>
    s == STYLE_DASHED ? line.style_dashed : s == STYLE_DOTTED ? line.style_dotted : line.style_solid

f_tzOf(string choice) =>
    choice == TZ_UTC ? "UTC" : choice == TZ_NEWYORK ? "America/New_York" : choice == TZ_CHICAGO ? "America/Chicago" : choice == TZ_LONDON ? "Europe/London" : choice == TZ_FRANKFURT ? "Europe/Berlin" : choice == TZ_TOKYO ? "Asia/Tokyo" : choice == TZ_SYDNEY ? "Australia/Sydney" : syminfo.timezone

// Names the slot the statistics were drawn from, so the table always states what it is
// describing. Derived from the period's own start time, which is already to hand.
// For a weekday slot the label is taken from the period's CLOSE, not its open. A futures
// daily bar opens the previous evening - Monday's session begins Sunday 17:00 Chicago - so
// reading the open would label Monday as "Sun". The close lands inside the trade date.
f_slotLabel(int startTime, int endTime, bool matched, bool weekday, string tfLabel, string tzName) =>
    string out = tfLabel
    if matched
        if weekday and not na(endTime)
            int d = dayofweek(endTime - 1, tzName)
            string dayName = d == dayofweek.monday ? "Mon" : d == dayofweek.tuesday ? "Tue" : d == dayofweek.wednesday ? "Wed" : d == dayofweek.thursday ? "Thu" : d == dayofweek.friday ? "Fri" : d == dayofweek.saturday ? "Sat" : "Sun"
            out := tfLabel + " " + dayName
        if not weekday and not na(startTime)
            out := tfLabel + " " + str.format_time(startTime, "HH:mm", tzName)
    out

f_tablePosition(string p) =>
    p == POS_TL ? position.top_left : p == POS_TC ? position.top_center : p == POS_ML ? position.middle_left : p == POS_MR ? position.middle_right : p == POS_BL ? position.bottom_left : p == POS_BC ? position.bottom_center : p == POS_BR ? position.bottom_right : position.top_right

// True for every position in the bottom band, whichever side of it.
f_isBottomPosition(string p) =>
    p == POS_BL or p == POS_BC or p == POS_BR

f_tableSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : size.small

f_touchedUp(float runHigh, float level) =>
    not na(runHigh) and not na(level) and runHigh >= level

f_touchedDown(float runLow, float level) =>
    not na(runLow) and not na(level) and runLow <= level

// The NY-midnight open is labelled "00:00" rather than "<tf> O" so it can never be
// confused with the exchange's own daily open.
f_levelLabel(string tfLabel, string levelText, bool isNyAnchorOpen) =>
    isNyAnchorOpen ? "00:00" : tfLabel + " " + levelText

f_hideLabel(label lb) =>
    if not na(lb)
        label.set_text(lb, "")
        label.set_tooltip(lb, "")
        label.set_color(lb, color.new(color.white, 100))
        label.set_textcolor(lb, color.new(color.white, 100))

f_hideLineOnly(line ln) =>
    if not na(ln)
        line.set_xy1(ln, time, close)
        line.set_xy2(ln, time, close)
        line.set_color(ln, color.new(color.gray, 100))

f_hideBox(box bx) =>
    if not na(bx)
        box.set_lefttop(bx, time, close)
        box.set_rightbottom(bx, time, close)
        box.set_bgcolor(bx, color.new(color.white, 100))
        box.set_border_color(bx, color.new(color.white, 100))

f_hideLevelLine(line ln, label lb) =>
    f_hideLineOnly(ln)
    f_hideLabel(lb)

f_renderLevelLine(bool enabled, bool showLabels, line ln, label lb, int startTime, int endTime, float price, color col, string styleText, int width, string labelText) =>
    bool canRender = enabled and not na(startTime) and not na(endTime) and endTime > startTime and not na(price)
    if canRender
        if not na(ln)
            line.set_xy1(ln, startTime, price)
            line.set_xy2(ln, endTime, price)
            line.set_color(ln, col)
            line.set_width(ln, width)
            line.set_style(ln, f_lineStyle(styleText))
        if showLabels and not na(lb)
            label.set_x(lb, endTime)
            label.set_y(lb, price)
            label.set_text(lb, labelText)
            label.set_tooltip(lb, labelText + ": " + f_fmtPrice(price))
            label.set_color(lb, color.new(col, 100))
            label.set_textcolor(lb, col)
            label.set_style(lb, label.style_label_left)
            label.set_size(lb, size.small)
        if not showLabels
            f_hideLabel(lb)
    else
        f_hideLevelLine(ln, lb)

f_renderLevelBox(bool enabled, bool showLabels, box bx, label lb, int startTime, int endTime, float meanPrice, float medianPrice, color labelColor, color fillColor, string labelText) =>
    bool canRender = enabled and not na(startTime) and not na(endTime) and endTime > startTime and not na(meanPrice) and not na(medianPrice)
    if canRender
        float top = math.max(meanPrice, medianPrice)
        float bottom = math.min(meanPrice, medianPrice)
        float mid = (top + bottom) / 2.0
        if not na(bx)
            box.set_lefttop(bx, startTime, top)
            box.set_rightbottom(bx, endTime, bottom)
            box.set_bgcolor(bx, fillColor)
            box.set_border_color(bx, color.new(fillColor, 100))
        if showLabels and not na(lb)
            label.set_x(lb, endTime)
            label.set_y(lb, mid)
            label.set_text(lb, labelText)
            label.set_tooltip(lb, labelText + "\nMean: " + f_fmtPrice(meanPrice) + "\nMedian: " + f_fmtPrice(medianPrice) + "\nZone width: " + f_fmtPrice(math.abs(meanPrice - medianPrice)))
            label.set_color(lb, color.new(labelColor, 100))
            label.set_textcolor(lb, labelColor)
            label.set_style(lb, label.style_label_left)
            label.set_size(lb, size.small)
        if not showLabels
            f_hideLabel(lb)
    else
        f_hideBox(bx)
        f_hideLabel(lb)

f_renderLevels(bool enabled, bool showLabels, string tfLabel, bool nyAnchor, string method, int startTime, int endTime, float plusD, float minusM, float openLevel, float plusM, float minusD, float plusDMean, float minusMMean, float plusMMean, float minusDMean, float plusDMed, float minusMMed, float plusMMed, float minusDMed, line plusDLine, label plusDLabel, box plusDBox, line minusMLine, label minusMLabel, box minusMBox, line openLine, label openLabel, line plusMLine, label plusMLabel, box plusMBox, line minusDLine, label minusDLabel, box minusDBox) =>
    bool bothMode = method == METHOD_BOTH
    string plusDText  = f_levelLabel(tfLabel, "+D", false)
    string minusMText = f_levelLabel(tfLabel, "-M", false)
    string openText   = f_levelLabel(tfLabel, "O", nyAnchor)
    string plusMText  = f_levelLabel(tfLabel, "+M", false)
    string minusDText = f_levelLabel(tfLabel, "-D", false)

    if bothMode
        f_hideLineOnly(plusDLine)
        f_hideLineOnly(minusMLine)
        f_hideLineOnly(plusMLine)
        f_hideLineOnly(minusDLine)
        f_renderLevelBox(enabled, showLabels, plusDBox, plusDLabel, startTime, endTime, plusDMean, plusDMed, plusDColorInput, bothDistributionBoxColorInput, plusDText)
        f_renderLevelBox(enabled, showLabels, minusMBox, minusMLabel, startTime, endTime, minusMMean, minusMMed, minusMColorInput, bothManipulationBoxColorInput, minusMText)
        f_renderLevelLine(enabled, showLabels, openLine, openLabel, startTime, endTime, openLevel, openColorInput, openStyleInput, openWidthInput, openText)
        f_renderLevelBox(enabled, showLabels, plusMBox, plusMLabel, startTime, endTime, plusMMean, plusMMed, plusMColorInput, bothManipulationBoxColorInput, plusMText)
        f_renderLevelBox(enabled, showLabels, minusDBox, minusDLabel, startTime, endTime, minusDMean, minusDMed, minusDColorInput, bothDistributionBoxColorInput, minusDText)
    else
        f_hideBox(plusDBox)
        f_hideBox(minusMBox)
        f_hideBox(plusMBox)
        f_hideBox(minusDBox)
        f_renderLevelLine(enabled, showLabels, plusDLine, plusDLabel, startTime, endTime, plusD, plusDColorInput, plusDStyleInput, plusDWidthInput, plusDText)
        f_renderLevelLine(enabled, showLabels, minusMLine, minusMLabel, startTime, endTime, minusM, minusMColorInput, minusMStyleInput, minusMWidthInput, minusMText)
        f_renderLevelLine(enabled, showLabels, openLine, openLabel, startTime, endTime, openLevel, openColorInput, openStyleInput, openWidthInput, openText)
        f_renderLevelLine(enabled, showLabels, plusMLine, plusMLabel, startTime, endTime, plusM, plusMColorInput, plusMStyleInput, plusMWidthInput, plusMText)
        f_renderLevelLine(enabled, showLabels, minusDLine, minusDLabel, startTime, endTime, minusD, minusDColorInput, minusDStyleInput, minusDWidthInput, minusDText)

// -------------------------------------------------------------------------------------
// DRAWING OBJECTS
// -------------------------------------------------------------------------------------
var line  s1PlusDLine  = na
var line  s1MinusMLine = na
var line  s1OpenLine   = na
var line  s1PlusMLine  = na
var line  s1MinusDLine = na
var label s1PlusDLabel  = na
var label s1MinusMLabel = na
var label s1OpenLabel   = na
var label s1PlusMLabel  = na
var label s1MinusDLabel = na
var box   s1PlusDBox  = na
var box   s1MinusMBox = na
var box   s1PlusMBox  = na
var box   s1MinusDBox = na

var line  s2PlusDLine  = na
var line  s2MinusMLine = na
var line  s2OpenLine   = na
var line  s2PlusMLine  = na
var line  s2MinusDLine = na
var label s2PlusDLabel  = na
var label s2MinusMLabel = na
var label s2OpenLabel   = na
var label s2PlusMLabel  = na
var label s2MinusDLabel = na
var box   s2PlusDBox  = na
var box   s2MinusMBox = na
var box   s2PlusMBox  = na
var box   s2MinusDBox = na

if barstate.isfirst
    s1PlusDLine  := line.new(time, close, time, close, xloc = xloc.bar_time, color = color.new(plusDColorInput, 100), width = plusDWidthInput)
    s1MinusMLine := line.new(time, close, time, close, xloc = xloc.bar_time, color = color.new(minusMColorInput, 100), width = minusMWidthInput)
    s1OpenLine   := line.new(time, close, time, close, xloc = xloc.bar_time, color = color.new(openColorInput, 100), width = openWidthInput)
    s1PlusMLine  := line.new(time, close, time, close, xloc = xloc.bar_time, color = color.new(plusMColorInput, 100), width = plusMWidthInput)
    s1MinusDLine := line.new(time, close, time, close, xloc = xloc.bar_time, color = color.new(minusDColorInput, 100), width = minusDWidthInput)
    s1PlusDLabel  := label.new(time, close, "", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(plusDColorInput, 100), textcolor = color.new(plusDColorInput, 100), size = size.small)
    s1MinusMLabel := label.new(time, close, "", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(minusMColorInput, 100), textcolor = color.new(minusMColorInput, 100), size = size.small)
    s1OpenLabel   := label.new(time, close, "", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(openColorInput, 100), textcolor = color.new(openColorInput, 100), size = size.small)
    s1PlusMLabel  := label.new(time, close, "", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(plusMColorInput, 100), textcolor = color.new(plusMColorInput, 100), size = size.small)
    s1MinusDLabel := label.new(time, close, "", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(minusDColorInput, 100), textcolor = color.new(minusDColorInput, 100), size = size.small)
    s1PlusDBox  := box.new(time, close, time, close, xloc = xloc.bar_time, bgcolor = color.new(bothDistributionBoxColorInput, 100), border_color = color.new(bothDistributionBoxColorInput, 100))
    s1MinusMBox := box.new(time, close, time, close, xloc = xloc.bar_time, bgcolor = color.new(bothManipulationBoxColorInput, 100), border_color = color.new(bothManipulationBoxColorInput, 100))
    s1PlusMBox  := box.new(time, close, time, close, xloc = xloc.bar_time, bgcolor = color.new(bothManipulationBoxColorInput, 100), border_color = color.new(bothManipulationBoxColorInput, 100))
    s1MinusDBox := box.new(time, close, time, close, xloc = xloc.bar_time, bgcolor = color.new(bothDistributionBoxColorInput, 100), border_color = color.new(bothDistributionBoxColorInput, 100))
    s2PlusDLine  := line.new(time, close, time, close, xloc = xloc.bar_time, color = color.new(plusDColorInput, 100), width = plusDWidthInput)
    s2MinusMLine := line.new(time, close, time, close, xloc = xloc.bar_time, color = color.new(minusMColorInput, 100), width = minusMWidthInput)
    s2OpenLine   := line.new(time, close, time, close, xloc = xloc.bar_time, color = color.new(openColorInput, 100), width = openWidthInput)
    s2PlusMLine  := line.new(time, close, time, close, xloc = xloc.bar_time, color = color.new(plusMColorInput, 100), width = plusMWidthInput)
    s2MinusDLine := line.new(time, close, time, close, xloc = xloc.bar_time, color = color.new(minusDColorInput, 100), width = minusDWidthInput)
    s2PlusDLabel  := label.new(time, close, "", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(plusDColorInput, 100), textcolor = color.new(plusDColorInput, 100), size = size.small)
    s2MinusMLabel := label.new(time, close, "", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(minusMColorInput, 100), textcolor = color.new(minusMColorInput, 100), size = size.small)
    s2OpenLabel   := label.new(time, close, "", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(openColorInput, 100), textcolor = color.new(openColorInput, 100), size = size.small)
    s2PlusMLabel  := label.new(time, close, "", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(plusMColorInput, 100), textcolor = color.new(plusMColorInput, 100), size = size.small)
    s2MinusDLabel := label.new(time, close, "", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(minusDColorInput, 100), textcolor = color.new(minusDColorInput, 100), size = size.small)
    s2PlusDBox  := box.new(time, close, time, close, xloc = xloc.bar_time, bgcolor = color.new(bothDistributionBoxColorInput, 100), border_color = color.new(bothDistributionBoxColorInput, 100))
    s2MinusMBox := box.new(time, close, time, close, xloc = xloc.bar_time, bgcolor = color.new(bothManipulationBoxColorInput, 100), border_color = color.new(bothManipulationBoxColorInput, 100))
    s2PlusMBox  := box.new(time, close, time, close, xloc = xloc.bar_time, bgcolor = color.new(bothManipulationBoxColorInput, 100), border_color = color.new(bothManipulationBoxColorInput, 100))
    s2MinusDBox := box.new(time, close, time, close, xloc = xloc.bar_time, bgcolor = color.new(bothDistributionBoxColorInput, 100), border_color = color.new(bothDistributionBoxColorInput, 100))

// -------------------------------------------------------------------------------------
// CONFIGURATION RESOLUTION + HARD ERRORS
// -------------------------------------------------------------------------------------
string tf1Display = f_timeframeDisplay(tf1Input)
string tf2Display = f_timeframeDisplay(tf2Input)
bool tf1IsDaily = f_isDailyTimeframe(tf1Input, timeframe.isdaily)
bool tf2IsDaily = f_isDailyTimeframe(tf2Input, timeframe.isdaily)

int chartSeconds = timeframe.in_seconds(timeframe.period)
int tf1Seconds = f_timeframeSeconds(tf1Input)
int tf2Seconds = f_timeframeSeconds(tf2Input)

// Resolved at global scope so the qualifier is unambiguously `simple`, which time(),
// time_close() and request.security() all require.
simple string tf1Src = tf1Input == "" ? timeframe.period : tf1Input
simple string tf2Src = tf2Input == "" ? timeframe.period : tf2Input

if barstate.isfirst
    if enableTf1Input and enableTf2Input and tf1Seconds == tf2Seconds
        runtime.error("Statistical Mapping: both mapping periods are set to the same timeframe (" + tf1Display + "). Two identical periods would draw two identical sets of levels on top of each other. Open the settings and either change one period or untick one of the two boxes.")
    if enableTf1Input and na(tf1Seconds)
        runtime.error("Statistical Mapping: mapping period 1 (\"" + tf1Input + "\") is not a timeframe this symbol supports. Open the settings and choose a standard period such as 1D or 1W.")
    if enableTf2Input and na(tf2Seconds)
        runtime.error("Statistical Mapping: mapping period 2 (\"" + tf2Input + "\") is not a timeframe this symbol supports. Open the settings and choose a standard period such as 1D or 1W.")

// ---- SAMPLE SELECTION RESOLUTION -----------------------------------------------------
// Matched sampling needs to know how many slots a day holds, how far back to fetch, and
// whether the mapping period even has slots. A week has one of each, so 1W falls back to
// Rolling. Everything here is input-qualified so it can size a matrix and a request.
f_slotsPerDay(simple int periodSeconds) =>
    int perDay = periodSeconds <= 0 ? 1 : int(math.ceil(86400.0 / periodSeconds))
    math.min(perDay + 4, MAX_SLOTS)

simple bool wantMatched = samplingInput == SAMPLE_MATCHED
simple bool tf1Intraday = not na(tf1Seconds) and tf1Seconds < 86400
simple bool tf2Intraday = not na(tf2Seconds) and tf2Seconds < 86400
simple bool tf1Weekday  = not na(tf1Seconds) and tf1Seconds >= 86400 and tf1Seconds < 604800
simple bool tf2Weekday  = not na(tf2Seconds) and tf2Seconds >= 86400 and tf2Seconds < 604800
simple bool tf1Matched  = wantMatched and (tf1Intraday or tf1Weekday)
simple bool tf2Matched  = wantMatched and (tf2Intraday or tf2Weekday)
simple int  tf1Rows     = tf1Matched ? (tf1Weekday ? 8 : f_slotsPerDay(tf1Seconds)) : 1
simple int  tf2Rows     = tf2Matched ? (tf2Weekday ? 8 : f_slotsPerDay(tf2Seconds)) : 1

// How much history each request needs. Matched sampling has to reach back far enough to
// collect Lookback OCCURRENCES of a slot, which is Lookback days rather than Lookback bars.
// The ceiling keeps the script inside a sane compute budget: on finer mapping periods the
// sample simply comes up short, which the footer count and the warning panel already report
// honestly rather than hiding.
const int   MATCHED_BAR_CEILING = 4500
f_calcBars(simple bool matched, simple bool weekday, simple int periodSeconds, simple int lookback) =>
    int needed = matched ? (weekday ? lookback * 6 : lookback * int(math.ceil(86400.0 / periodSeconds))) + 100 : lookback + 10
    matched ? math.min(needed, MATCHED_BAR_CEILING) : needed

// Pine caps a matrix at 100,000 elements and Matched sampling keeps one sample set per
// slot, so a fine mapping period multiplied by a large Lookback can exceed it. Checked here
// rather than with the other startup errors because it needs the resolution above.
if barstate.isfirst
    if tf1Rows * lookbackInput > 95000 or tf2Rows * lookbackInput > 95000
        runtime.error("Statistical Mapping: this combination of mapping period and Lookback needs more per-slot storage than Pine allows. \"Matched\" sampling keeps one sample set for every time slot, so a fine mapping period multiplied by a large Lookback exceeds the limit. Lower the Lookback setting, choose a coarser mapping period, or set Sample Selection to \"Rolling\".")

bool nyAnchorSelected = anchorModeInput == ANCHOR_NY_MIDNIGHT
bool s1UseNy = enableTf1Input and nyAnchorSelected and tf1IsDaily
bool s2UseNy = enableTf2Input and nyAnchorSelected and tf2IsDaily
bool s1Visible = enableTf1Input and f_slotVisibleOnChart(tf1Input)
bool s2Visible = enableTf2Input and f_slotVisibleOnChart(tf2Input)

// Resolved once, at input qualification, so the table helpers stay input-qualified.
tablePos      = f_tablePosition(tablePosInput)
tableTextSize = f_tableSize(tableSizeInput)

// The warning panel is placed in a different horizontal band to the statistics table so
// the two can never overlap, whichever corner the user chose for the table.
// Warnings sit in the opposite band to the table so the two can never collide - which now
// matters more, since Bottom Center is a position the table itself can occupy.
warnPos = showTableInput and f_isBottomPosition(tablePosInput) ? position.top_center : position.bottom_center

// -------------------------------------------------------------------------------------
// DATA
// One call per mapping period returns BOTH the completed-period statistics and the current
// period's anchor (its start time, end time and opening price), all evaluated inside that
// period's own context. See the lookahead note in the header - this is the safe usage.
// The NY source is only given a real history budget when the NY anchor is actually in use.
// -------------------------------------------------------------------------------------
[tf1DMean, tf1DMed, tf1MMean, tf1MMed, tf1ReachPlusD, tf1ReachMinusM, tf1ReachPlusM, tf1ReachMinusD, tf1N, tf1Bull, tf1Bear, tf1Start, tf1End, tf1Open, tf1High, tf1Low] = request.security(syminfo.tickerid, tf1Src, f_htfStats(lookbackInput, calcMethodInput, tf1Matched, tf1Weekday, tf1Rows), barmerge.gaps_off, barmerge.lookahead_on, calc_bars_count = f_calcBars(tf1Matched, tf1Weekday, tf1Seconds, lookbackInput))
[tf2DMean, tf2DMed, tf2MMean, tf2MMed, tf2ReachPlusD, tf2ReachMinusM, tf2ReachPlusM, tf2ReachMinusD, tf2N, tf2Bull, tf2Bear, tf2Start, tf2End, tf2Open, tf2High, tf2Low] = request.security(syminfo.tickerid, tf2Src, f_htfStats(lookbackInput, calcMethodInput, tf2Matched, tf2Weekday, tf2Rows), barmerge.gaps_off, barmerge.lookahead_on, calc_bars_count = f_calcBars(tf2Matched, tf2Weekday, tf2Seconds, lookbackInput))
[nyDMean, nyDMed, nyMMean, nyMMed, nyReachPlusD, nyReachMinusM, nyReachPlusM, nyReachMinusD, nyN, nyBull, nyBear, nySecStart, nySecOpen, nySecHigh, nySecLow] = request.security(syminfo.tickerid, NY_SOURCE_TF, f_nyStats(lookbackInput, calcMethodInput), barmerge.gaps_off, barmerge.lookahead_on, calc_bars_count = anchorModeInput == ANCHOR_NY_MIDNIGHT ? lookbackInput * 26 + 300 : 10)

// -------------------------------------------------------------------------------------
// ANCHORS
// -------------------------------------------------------------------------------------
// Every value below comes from the mapping period's own context, so the result does not
// depend on the chart timeframe in any way.
int   nyEnd   = f_nextNyMidnight(nySecStart)

int   s1Start = s1UseNy ? nySecStart : tf1Start
int   s1End   = s1UseNy ? nyEnd      : tf1End
float s1Open  = s1UseNy ? nySecOpen  : tf1Open
int   s2Start = s2UseNy ? nySecStart : tf2Start
int   s2End   = s2UseNy ? nyEnd      : tf2End
float s2Open  = s2UseNy ? nySecOpen  : tf2Open

float s1DMean = s1UseNy ? nyDMean : tf1DMean
float s1DMed  = s1UseNy ? nyDMed  : tf1DMed
float s1MMean = s1UseNy ? nyMMean : tf1MMean
float s1MMed  = s1UseNy ? nyMMed  : tf1MMed
float s2DMean = s2UseNy ? nyDMean : tf2DMean
float s2DMed  = s2UseNy ? nyDMed  : tf2DMed
float s2MMean = s2UseNy ? nyMMean : tf2MMean
float s2MMed  = s2UseNy ? nyMMed  : tf2MMed

float s2ReachPlusD  = s2UseNy ? nyReachPlusD  : tf2ReachPlusD
float s2ReachMinusM = s2UseNy ? nyReachMinusM : tf2ReachMinusM
float s2ReachPlusM  = s2UseNy ? nyReachPlusM  : tf2ReachPlusM
float s2ReachMinusD = s2UseNy ? nyReachMinusD : tf2ReachMinusD
int   s2SampleN     = s2UseNy ? nyN    : tf2N
int   s2BullN       = s2UseNy ? nyBull : tf2Bull
int   s2BearN       = s2UseNy ? nyBear : tf2Bear

float s1ReachPlusD  = s1UseNy ? nyReachPlusD  : tf1ReachPlusD
float s1ReachMinusM = s1UseNy ? nyReachMinusM : tf1ReachMinusM
float s1ReachPlusM  = s1UseNy ? nyReachPlusM  : tf1ReachPlusM
float s1ReachMinusD = s1UseNy ? nyReachMinusD : tf1ReachMinusD
int   s1SampleN     = s1UseNy ? nyN    : tf1N
int   s1BullN       = s1UseNy ? nyBull : tf1Bull
int   s1BearN       = s1UseNy ? nyBear : tf1Bear

[s1PlusD, s1MinusM, s1OpenLvl, s1PlusM, s1MinusD, s1PlusDMean, s1MinusMMean, s1PlusMMean, s1MinusDMean, s1PlusDMed, s1MinusMMed, s1PlusMMed, s1MinusDMed] = f_projectLevels(s1Open, calcMethodInput, s1DMean, s1DMed, s1MMean, s1MMed)
[s2PlusD, s2MinusM, s2OpenLvl, s2PlusM, s2MinusD, s2PlusDMean, s2MinusMMean, s2PlusMMean, s2MinusDMean, s2PlusDMed, s2MinusMMed, s2PlusMMed, s2MinusDMed] = f_projectLevels(s2Open, calcMethodInput, s2DMean, s2DMed, s2MMean, s2MMed)


// Reference prices used for the Hit column and for alerts. In Mean or Median mode these
// are simply the drawn line; in Both mode they are the near edge of the drawn zone.
bool isBothMode = calcMethodInput == METHOD_BOTH
float s1HitPlusD  = f_hitRef(s1PlusD,  s1PlusDMean,  s1PlusDMed,  isBothMode, true)
float s1HitMinusM = f_hitRef(s1MinusM, s1MinusMMean, s1MinusMMed, isBothMode, true)
float s1HitPlusM  = f_hitRef(s1PlusM,  s1PlusMMean,  s1PlusMMed,  isBothMode, false)
float s1HitMinusD = f_hitRef(s1MinusD, s1MinusDMean, s1MinusDMed, isBothMode, false)
float s2HitPlusD  = f_hitRef(s2PlusD,  s2PlusDMean,  s2PlusDMed,  isBothMode, true)
float s2HitMinusM = f_hitRef(s2MinusM, s2MinusMMean, s2MinusMMed, isBothMode, true)
float s2HitPlusM  = f_hitRef(s2PlusM,  s2PlusMMean,  s2PlusMMed,  isBothMode, false)
float s2HitMinusD = f_hitRef(s2MinusD, s2MinusDMean, s2MinusDMed, isBothMode, false)

// The current period's running extremes, read from the mapping period's own context.
// These feed the Hit column only - see the note on f_htfStats.
float s1CtxHigh = s1UseNy ? nySecHigh : tf1High
float s1CtxLow  = s1UseNy ? nySecLow  : tf1Low
float s2CtxHigh = s2UseNy ? nySecHigh : tf2High
float s2CtxLow  = s2UseNy ? nySecLow  : tf2Low

// The table follows whichever mapping period is actually on screen. Period 1 wins when
// both are visible; if only period 2 is enabled the table shows that one instead of
// silently disappearing.
// One table, two possible mapping periods. This picks which one it describes: the period
// you chose, unless that period is not on screen, in which case it falls back to the other
// rather than showing nothing. The footer's first cell names the period in use.
bool   tblSlot2   = (tableSlotInput == TABLE_SLOT_2 and s2Visible) or (not s1Visible and s2Visible)
bool   tblVisible = s1Visible or s2Visible
string tblTf      = tblSlot2 ? tf2Display : tf1Display
int    tblStart   = tblSlot2 ? s2Start     : s1Start
int    tblEnd     = tblSlot2 ? s2End       : s1End
bool   tblMatched = tblSlot2 ? tf2Matched  : tf1Matched
bool   tblWeekday = tblSlot2 ? tf2Weekday  : tf1Weekday
bool   tblUseNy   = tblSlot2 ? s2UseNy    : s1UseNy
float  tblOpen    = tblSlot2 ? s2Open     : s1Open
float  tblRchPD   = tblSlot2 ? s2ReachPlusD  : s1ReachPlusD
float  tblRchMM   = tblSlot2 ? s2ReachMinusM : s1ReachMinusM
float  tblRchPM   = tblSlot2 ? s2ReachPlusM  : s1ReachPlusM
float  tblRchMD   = tblSlot2 ? s2ReachMinusD : s1ReachMinusD
float  tblHitPD   = tblSlot2 ? s2HitPlusD    : s1HitPlusD
float  tblHitMM   = tblSlot2 ? s2HitMinusM   : s1HitMinusM
float  tblHitPM   = tblSlot2 ? s2HitPlusM    : s1HitPlusM
float  tblHitMD   = tblSlot2 ? s2HitMinusD   : s1HitMinusD
float  tblCtxHigh = tblSlot2 ? s2CtxHigh   : s1CtxHigh
float  tblCtxLow  = tblSlot2 ? s2CtxLow    : s1CtxLow


float tblRunHigh = tblCtxHigh
float tblRunLow  = tblCtxLow
int    tblN       = tblSlot2 ? s2SampleN  : s1SampleN
int    tblBull    = tblSlot2 ? s2BullN    : s1BullN
int    tblBear    = tblSlot2 ? s2BearN    : s1BearN

// -------------------------------------------------------------------------------------
// RENDER
// -------------------------------------------------------------------------------------
f_renderLevels(s1Visible, showLabelsInput, tf1Display, s1UseNy, calcMethodInput, s1Start, s1End, s1PlusD, s1MinusM, s1OpenLvl, s1PlusM, s1MinusD, s1PlusDMean, s1MinusMMean, s1PlusMMean, s1MinusDMean, s1PlusDMed, s1MinusMMed, s1PlusMMed, s1MinusDMed, s1PlusDLine, s1PlusDLabel, s1PlusDBox, s1MinusMLine, s1MinusMLabel, s1MinusMBox, s1OpenLine, s1OpenLabel, s1PlusMLine, s1PlusMLabel, s1PlusMBox, s1MinusDLine, s1MinusDLabel, s1MinusDBox)
f_renderLevels(s2Visible, showLabelsInput, tf2Display, s2UseNy, calcMethodInput, s2Start, s2End, s2PlusD, s2MinusM, s2OpenLvl, s2PlusM, s2MinusD, s2PlusDMean, s2MinusMMean, s2PlusMMean, s2MinusDMean, s2PlusDMed, s2MinusMMed, s2PlusMMed, s2MinusDMed, s2PlusDLine, s2PlusDLabel, s2PlusDBox, s2MinusMLine, s2MinusMLabel, s2MinusMBox, s2OpenLine, s2OpenLabel, s2PlusMLine, s2PlusMLabel, s2PlusMBox, s2MinusDLine, s2MinusDLabel, s2MinusDBox)

// -------------------------------------------------------------------------------------
// STATISTICS TABLE
// -------------------------------------------------------------------------------------
// A Pine table column is exactly as wide as its widest cell, and there is no way to make
// a cell span columns. The previous layout put a full sentence of explanation in column 0,
// which stretched that one column across half the chart and left every level name floating
// in whitespace. The fix is simply to keep every single cell short: the long explanations
// now live in cell tooltips (hover any header), and the title row is gone because the
// indicator name is already shown in the chart legend.
const string TT_CELL_LEVEL = "The five projected levels, listed in the same top-to-bottom order they appear on the chart."
const string TT_CELL_PRICE = "Where each level currently sits.\n\nIn \"Both\" mode the chart draws a ZONE running from the mean to the median, and this column reports the NEAR EDGE of that zone - whichever of the two sits closer to the anchor open. That is the first price of the zone that price actually reaches, so it is the number that matters in practice.\n\nDist, Reach and Hit all use the same near edge, so every column in this table describes the same price. The far edge is visible on the chart as the other side of the shaded band."
const string TT_CELL_DIST  = "Distance from the anchor open.\nPositive = above the open, negative = below it."
const string TT_CELL_REACH = "In \"Both\" mode this is measured against the near edge of the zone, matching the Price column.\n\nOut of the periods in the lookback, the percentage that travelled AT LEAST this far from their own open, in this direction.\n\nExample: lookback 90, +D is 419 points above the open, Reach reads 25.6%. That means on 23 of the last 90 days price traded 419 points or more above that day's open at some point. On the other 67 days it never got that far.\n\nLow Reach marks a level price rarely gets to - an extended target, typical of trending or high-volatility days. High Reach marks a level price reaches on most days, which on its own tells you very little.\n\nThis is a count of what happened on past days. It is not a probability and not a forecast."
const string TT_CELL_HIT   = "A tick means the CURRENT period has already traded through this level. A dot means it has not.\n\nIn \"Both\" mode the chart draws a ZONE from the mean to the median rather than a single line, so the tick appears as soon as price enters that zone - it tests the near edge of the shaded band, not the mean shown in the Price column. That is why a tick can appear while price is still short of the Price figure. Alerts use the same rule, so what you see and what you are notified about always agree."
const string TT_CELL_FOOT  = "Mapping period, anchor mode and calculation method currently in use.\n\nThen: completed periods actually used out of the lookback you asked for, and how that sample splits between periods that closed up and periods that closed down."

// Pine does not allow function declarations inside a local scope, so this lives here and
// takes the table as a parameter rather than reaching for a global.
float NA_FLOAT = na

f_levelRow(table t, int row, string name, float price, float openRef, float reach, bool hit, bool isOpenRow, color col) =>
    table.cell(t, 0, row, name, text_color = col, text_size = tableTextSize, text_halign = text.align_center)
    table.cell(t, 1, row, f_fmtPrice(price), text_color = col, text_size = tableTextSize, text_halign = text.align_right)
    table.cell(t, 2, row, isOpenRow ? "—" : f_fmtPrice(price - openRef), text_color = col, text_size = tableTextSize, text_halign = text.align_right)
    table.cell(t, 3, row, isOpenRow ? "—" : f_fmtPct(reach), text_color = col, text_size = tableTextSize, text_halign = text.align_right)
    table.cell(t, 4, row, isOpenRow ? "—" : (hit ? "✓" : "·"), text_color = col, text_size = tableTextSize, text_halign = text.align_center)

var table statsTable = na
if barstate.isfirst
    statsTable := table.new(tablePos, 5, 8, border_width = 1)

if barstate.islast
    // Deliberately NOT gated on the data being available: a table showing n/a alongside a
    // warning is informative, whereas a table that silently disappears is not.
    bool drawTable = showTableInput and tblVisible
    if drawTable
        color txt = color.new(color.gray, 0)
        color dim = color.new(color.gray, 30)
        color bg  = color.new(color.gray, 92)

        table.cell(statsTable, 0, 0, "Level", text_color = txt, bgcolor = bg, text_size = tableTextSize, text_halign = text.align_center,  tooltip = TT_CELL_LEVEL)
        table.cell(statsTable, 1, 0, "Price", text_color = txt, bgcolor = bg, text_size = tableTextSize, text_halign = text.align_center, tooltip = TT_CELL_PRICE)
        table.cell(statsTable, 2, 0, "Dist",  text_color = txt, bgcolor = bg, text_size = tableTextSize, text_halign = text.align_center, tooltip = TT_CELL_DIST)
        table.cell(statsTable, 3, 0, "Reach", text_color = txt, bgcolor = bg, text_size = tableTextSize, text_halign = text.align_center, tooltip = TT_CELL_REACH)
        table.cell(statsTable, 4, 0, "Hit",   text_color = txt, bgcolor = bg, text_size = tableTextSize, text_halign = text.align_center, tooltip = TT_CELL_HIT)

        f_levelRow(statsTable, 1, "+D", tblHitPD,  tblOpen, tblRchPD, f_touchedUp(tblRunHigh, tblHitPD),   false, plusDColorInput)
        f_levelRow(statsTable, 2, "-M", tblHitMM, tblOpen, tblRchMM, f_touchedUp(tblRunHigh, tblHitMM),   false, minusMColorInput)
        f_levelRow(statsTable, 3, "O",  tblOpen,   tblOpen, NA_FLOAT, false,                               true,  openColorInput)
        f_levelRow(statsTable, 4, "+M", tblHitPM,  tblOpen, tblRchPM, f_touchedDown(tblRunLow, tblHitPM),  false, plusMColorInput)
        f_levelRow(statsTable, 5, "-D", tblHitMD, tblOpen, tblRchMD, f_touchedDown(tblRunLow, tblHitMD),  false, minusDColorInput)

        // Compact status footer. Every cell is kept short on purpose - see the note above.
        table.cell(statsTable, 0, 6, f_slotLabel(tblStart, tblEnd, tblMatched, tblWeekday, tblTf, f_tzOf(slotTzInput)), text_color = dim, bgcolor = bg, text_size = tableTextSize, text_halign = text.align_center,   tooltip = TT_CELL_FOOT)
        table.cell(statsTable, 1, 6, tblUseNy ? "NY 00:00" : "True open", text_color = dim, bgcolor = bg, text_size = tableTextSize, text_halign = text.align_center, tooltip = TT_CELL_FOOT)
        table.cell(statsTable, 2, 6, calcMethodInput, text_color = dim, bgcolor = bg, text_size = tableTextSize, text_halign = text.align_center, tooltip = TT_CELL_FOOT)
        table.cell(statsTable, 3, 6, "n " + str.tostring(tblN) + "/" + str.tostring(lookbackInput), text_color = dim, bgcolor = bg, text_size = tableTextSize, text_halign = text.align_center, tooltip = TT_CELL_FOOT)
        table.cell(statsTable, 4, 6, str.tostring(tblBull) + "/" + str.tostring(tblBear), text_color = dim, bgcolor = bg, text_size = tableTextSize, text_halign = text.align_center, tooltip = TT_CELL_FOOT)

        // Author attribution. Deliberately the author's NAME only - no handle, no link, no
        // logo - and rendered at the smallest size in faded grey. TradingView's House Rules
        // prohibit advertising on charts, and Vendor Requirements single out chart text that
        // exists only to display a name. A plain credit on your own open-source work is
        // attribution rather than promotion, and size.tiny keeps it from widening any column.
        table.cell(statsTable, 0, 7, AUTHOR_CREDIT, text_color = color.new(color.gray, 55), text_size = size.tiny, text_halign = text.align_left)
        table.cell(statsTable, 1, 7, "")
        table.cell(statsTable, 2, 7, "")
        table.cell(statsTable, 3, 7, "")
        table.cell(statsTable, 4, 7, "")
    else
        table.clear(statsTable, 0, 0, 4, 7)

// -------------------------------------------------------------------------------------
// WARNINGS
// -------------------------------------------------------------------------------------
// Each line is built with its own padding and warning glyph so the panel reads as a
// tidy block. No trailing newline is appended - a trailing newline renders as an empty
// final row and leaves an obvious gap under the text.
f_addWarn(string existing, string addition) =>
    (str.length(existing) > 0 ? existing + "\n" : "") + "   ⚠   " + addition + "   "

var table warnTable = na
if barstate.isfirst
    warnTable := table.new(warnPos, 1, 1, border_width = 0, frame_width = 1, frame_color = color.new(color.orange, 45))

if barstate.islast
    string warn = ""
    if not enableTf1Input and not enableTf2Input
        warn := f_addWarn(warn, "No mapping period is enabled — tick a box in the settings.")
    if enableTf1Input and not s1Visible
        warn := f_addWarn(warn, "The " + tf1Display + " levels are hidden because your chart timeframe (" + f_timeframeDisplay(timeframe.period) + ") is not LOWER than " + tf1Display + ".  Switch the chart to a lower timeframe.  This is expected behaviour, not an error.")
    if enableTf2Input and not s2Visible
        warn := f_addWarn(warn, "The " + tf2Display + " levels are hidden because your chart timeframe (" + f_timeframeDisplay(timeframe.period) + ") is not LOWER than " + tf2Display + ".  Switch the chart to a lower timeframe.")
    if nyAnchorSelected and not tf1IsDaily and not tf2IsDaily
        warn := f_addWarn(warn, "NY Midnight Open is selected but no mapping period is set to 1D, so it is having no effect.")
    if wantMatched and enableTf1Input and not tf1Matched and s1Visible
        warn := f_addWarn(warn, "Sample Selection is set to Matched, but a " + tf1Display + " mapping period has only one slot per period, so there is nothing to match against. It is using Rolling for this period.")
    if wantMatched and enableTf2Input and not tf2Matched and s2Visible
        warn := f_addWarn(warn, "Sample Selection is set to Matched, but a " + tf2Display + " mapping period has only one slot per period, so there is nothing to match against. It is using Rolling for this period.")
    if tblVisible and not na(tblN) and tblN > 0 and tblN < lookbackInput
        warn := f_addWarn(warn, "Only " + str.tostring(tblN) + " of the requested " + str.tostring(lookbackInput) + " " + tblTf + " " + (tblMatched ? "matching " : "") + tblTf + " periods are available, so the statistics use " + str.tostring(tblN) + " samples instead of " + str.tostring(lookbackInput) + "." + (tblMatched ? "  Matched sampling needs one occurrence of this slot per day, so it reaches back much further than Rolling does." : "") + "  The levels are still valid - they simply rest on a smaller sample.  Lower the Lookback setting to remove this notice.")
    if tblVisible and (na(tblN) or tblN == 0)
        warn := f_addWarn(warn, "No completed " + tblTf + " periods could be read for this symbol, so no levels can be projected.  This usually means the symbol has almost no history at that period.")


    bool showWarn = showWarningsInput and str.length(warn) > 0
    if showWarn
        table.cell(warnTable, 0, 0, warn, text_color = color.new(color.orange, 0), bgcolor = color.new(color.orange, 85), text_size = size.normal, text_halign = text.align_left, text_valign = text.align_center)
    else
        table.clear(warnTable, 0, 0)

// -------------------------------------------------------------------------------------
// ALERTS (mapping period 1)
//
// Two guards make these alerts trustworthy:
//   1. A level moves the instant a new mapping period starts. Requiring the level to be
//      UNCHANGED since the previous bar stops a false trigger firing at every boundary.
//   2. The event functions are evaluated on EVERY bar and only then combined with the
//      user's toggles. Putting the toggle first would let short-circuit evaluation skip
//      the call and corrupt the function's bar history.
// -------------------------------------------------------------------------------------
// `firstBar` marks the opening bar of a mapping period. On that bar the previous bar
// belongs to the PREVIOUS period, so comparing against it is meaningless - and demanding
// the level be unchanged since then would make a genuine first-bar touch unreportable.
// This is the same defect the Hit column had: an opening bar that runs from the anchor
// open straight into a level is a real event and must be treated as one.
f_levelEvent(float lvl, bool above, simple string mode, bool firstBar) =>
    bool valid = not na(lvl) and (firstBar or (not na(lvl[1]) and lvl == lvl[1]))
    bool touched = above ? (high >= lvl and (firstBar or high[1] < lvl)) : (low <= lvl and (firstBar or low[1] > lvl))
    bool closedThrough = above ? (close > lvl and (firstBar or close[1] <= lvl)) : (close < lvl and (firstBar or close[1] >= lvl))
    valid and (mode == TRIG_CLOSE ? closedThrough : touched)

// The open can be approached from either side, so it is treated as a two-way cross.
f_openEvent(float lvl, simple string mode) =>
    bool stable = not na(lvl) and not na(lvl[1]) and lvl == lvl[1]
    bool touched = (high >= lvl and low <= lvl) and not (high[1] >= lvl and low[1] <= lvl)
    bool closedThrough = (close > lvl and close[1] <= lvl) or (close < lvl and close[1] >= lvl)
    stable and (mode == TRIG_CLOSE ? closedThrough : touched)

// The opening bar of a mapping period. The anchor open line itself is deliberately NOT
// given this treatment: an opening bar always contains its own open, so a "touch" there
// would be trivially true on every single period.
bool s1FirstBar = not na(s1Start) and (na(s1Start[1]) or s1Start != s1Start[1])

bool rawPlusD  = f_levelEvent(s1HitPlusD,  true,  alertTriggerInput, s1FirstBar)
bool rawMinusM = f_levelEvent(s1HitMinusM, true,  alertTriggerInput, s1FirstBar)
bool rawOpen   = f_openEvent(s1OpenLvl, alertTriggerInput)
bool rawPlusM  = f_levelEvent(s1HitPlusM,  false, alertTriggerInput, s1FirstBar)
bool rawMinusD = f_levelEvent(s1HitMinusD, false, alertTriggerInput, s1FirstBar)

bool alertReady = s1Visible and not na(s1Open)

bool evPlusD  = alertReady and alertPlusDInput  and rawPlusD
bool evMinusM = alertReady and alertMinusMInput and rawMinusM
bool evOpen   = alertReady and alertOpenInput   and rawOpen
bool evPlusM  = alertReady and alertPlusMInput  and rawPlusM
bool evMinusD = alertReady and alertMinusDInput and rawMinusD

alertcondition(evPlusD,  "+D reached",   "Statistical Mapping - price reached +D, the upside distribution objective, on {{ticker}}")
alertcondition(evMinusM, "-M reached",   "Statistical Mapping - price reached -M, the upside manipulation area, on {{ticker}}")
alertcondition(evOpen,   "Open crossed", "Statistical Mapping - price crossed the anchor open on {{ticker}}")
alertcondition(evPlusM,  "+M reached",   "Statistical Mapping - price reached +M, the downside manipulation area, on {{ticker}}")
alertcondition(evMinusD, "-D reached",   "Statistical Mapping - price reached -D, the downside distribution objective, on {{ticker}}")
alertcondition(evPlusD or evMinusM or evOpen or evPlusM or evMinusD, "Any enabled level", "Statistical Mapping - price reached one of the enabled levels on {{ticker}}")
````
