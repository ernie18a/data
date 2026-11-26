# Vizard - FOMC Day Model for NQ & ES

- url: https://www.tradingview.com/script/PuHOf43g-Vizard-FOMC-Day-Model-for-NQ-ES/
- type: indicator
- pine_id: PUB;3c77a9e2d4c6425cadc955d9a2d47b99
- version: 3.0

## Description

[image]https://www.tradingview.com/x/U5D5EKp7/[/image][image]https://www.tradingview.com/x/tknBTAU8/[/image][b]Vizard[/b] maps FOMC decision days (statement 14:00 ET, press conference 14:30) on Nasdaq and S&P futures, and the meeting's first day before them. It covers four things:
• the structure the statement trades into;
• how far FOMC days with today's setup usually move, at today's ADR20;
• each stage live against the dollar;
• the Fed path the market prices, from fed funds futures.
Every ✓ row held in 2018–24 and again in 2025–26. [i]It is a map of how FOMC days usually behave, not a signal generator.[/i]
 
 
[b]WHAT IT DRAWS ON PRICE[/b]
 [image]https://www.tradingview.com/x/Fnqu5cht/[/image]
• [b]Statement and press conference:[/b] the 14:00–14:30 and 14:30–16:14 windows are shaded. The 14:00 and 14:30 opens extend right of price through the next day.
• [b]Snapshots:[/b] fixed labels at 14:00 and 14:30 give price against the 09:30 open and the week's open, and stage 1's move.
• [b]Day 1:[/b] the first meeting day's high and low are drawn live, then carried into the decision day.
• [b]RTH gap:[/b] the prior 16:14 close, its 50% level, and the gap in eighths over NY AM on the FOMC day and the day after, with the quarter next to the open shaded.
• [b]Statement shock cone:[/b] from the 14:00 open to 16:15, how far price had travelled by each 5 minutes on past FOMC days, up and down separately. It is scaled to today's ADR20. The inner band held half of FOMC days and the outer band 80%. Before 14:00 a faint preview sits at the current price.
 
 [image]https://www.tradingview.com/x/H02FmFVo/[/image]
[b]STAGES CARD[/b]
 
Stage 1 is 14:00 → 14:30 (the statement). Stage 2 is 14:30 → 16:14 (the press conference to the RTH close). The card has three parts.
 
[b]SETUP[/b] runs live until 13:59, then stays fixed for the rest of the day and the day after.
• Where price sits in the month's range so far: [i]premium[/i] (top quarter), [i]middle[/i] or [i]discount[/i] (bottom quarter).
• Its distance from the month's open, in points and ADR: [i]over[/i] or [i]under[/i] means more than 1 ADR away.
• Its place against the prior day's high and low, and the move since 18:00. Each shows how often FOMC days in that spot made a new day high or low after 14:00. Above PDH, the day's low broke after 14:00 on only 28% of NQ FOMC days (29% on ES).
• DXY's last 4 weeks.
 
[b]EXPECT[/b] gives how far FOMC days with that setup moved, as a median and 80th percentile in points at today's ADR20:
• stage 1, split by SEP meetings (the ones with new dots);
• stage 2;
• the range after 14:00.
A stretched month moved most: on NQ the range after 14:00 ran 1.38 ADR from a discount and 0.74 from a premium.
 
Results that held ([b]✓[/b]) appear when today's setup matches. All of them are on ES:
• month premium: the 16:14 close finished above the 14:00 price on [b]65%[/b] of FOMC days vs 36%;
• month discount: a new day low after 14:00 on all 7;
• over 1 ADR above the month's open: the range after 14:00 was [b]0.67[/b] ADR vs 1.12;
• over 1 ADR below it: the next NY AM closed up [b]88%[/b] vs 43% (8 days);
• SEP meetings: stage 1 was three times the size, [b]0.29[/b] ADR vs 0.10.
On NQ no setup held in both periods, and the card says so.
 
[b]LIVE[/b] shows each stage in points against its expected size, beside DXY's move in the same window, measured in DXY's own ADR20.
• Once DXY moves big (0.25 ADR in stage 1, 0.5 in stage 2), the index went the other way:
  – stage 1: [b]86%[/b] of the time on NQ and [b]100%[/b] on ES;
  – stage 2: [b]85%[/b] on NQ and [b]93%[/b] on ES.
  – With a smaller DXY move it was 57–73%.
• A big DXY move in the same direction as the index is the rare case, and is coloured red.
• [i]This confirms a stage, it does not call it:[/i] DXY's first 10 minutes did not lead the rest of the stage, and stage 1 did not predict stage 2.
• The morning RTH gap traded back through the prior close by 16:14 on [b]74%[/b] of NQ FOMC days vs 61% (ES 76% vs 60%).
• The day after FOMC, NY AM never traded back past the open-side quarter of the gap on [b]28%[/b] of days vs 18% (NQ).
 
A broad search over everything knowable at 13:59 found no feature that called the direction after 14:00 out of sample. That is why the card sizes the day rather than picking a side.
 [image]https://www.tradingview.com/x/sHJmqone/[/image]
 
[b]FED CARD AND FED MAP[/b]
 
Seventeen monthly [b]CBOT 30-day fed funds futures[/b] are read live and worked out with the same steps as CME Group's FedWatch Tool:
• each contract settles to 100 − the month's average effective rate;
• meetings are chained and combined as a probability tree.
Checked against CME's own page for 12 Oct 2026, every meeting was within 0.06 percentage points.
 
• [b]Fed card[/b] (its own corner):
  – the next meeting's two outcomes and their odds;
  – the most likely target range for the three meetings after;
  – the change since yesterday's close.
  On a decision day after 14:00 it shows the surprise against the 13:59 pricing.
• [b]Fed map[/b] (indicator pane, beside the clock): a heat table with one column per meeting and one row per 25bp target range. Each cell holds the odds, the most likely range is in bold and today's range is marked. Below it:
  – the expected change in bp;
  – its move over 1 day (since 13:59 after a decision) and over 5 days;
  – the market against the Fed's dot-plot median at each year's last meeting.
  The heat, header and marker colours are adjustable.
 
 
[b]EVENT CLOCK AND TALLY[/b]
 
• [b]Event clock (pane):[/b] today's running range from 18:00 (or net move) is drawn against FOMC days, FOMC day 1 or normal days at the same time of day. It shows the median path with 25–75% and 10–90% bands, in half-hour steps scaled to today's ADR20. A NOW status reads [i]Above[/i], [i]Inside[/i] or [i]Below[/i] the middle half.
• [b]Tally card:[/b]
  – the last N FOMC days' up and down closes (trading day and RTH) and their average RTH gap;
  – where price sits in this week's and this month's range by octant;
  – the next decision day.
  [i]The octant is a locator, not a tested signal.[/i]
 
 
[b]LAYOUTS[/b]
 
[b]Full[/b] shows every row, and each card can sit in its own corner. [b]Mobile[/b] folds each card for a phone:
• the tally with the clock in one NOW row;
• one Fed row;
• a seven-row stages card.
Full explanations stay in each cell's tooltip.
 
 [image]https://www.tradingview.com/x/8kceE7oR/[/image]
[b]HOW TO USE[/b]
 
• Built for [b]NQ / MNQ[/b] and [b]ES / MES[/b] (continuous or front month). On other symbols the cards say they show NQ figures.
• 1 to 15-minute charts suit the structure; the clock needs 60 minutes or lower.
• For a phone, use a separate chart layout with [i]Layout = Mobile[/i], since chart layouts sync across devices.
• After each Summary of Economic Projections (March, June, September, December), update the three dot-plot inputs.
 
 
[b]DATA AND METHOD[/b]
 
• NQ and ES 1-minute data, Jan 2018 – Oct 2026 (ES to Aug 2026): 67 FOMC decision days each.
• Training period [b]2018–24[/b], test period [b]2025–26[/b]. A row gets a ✓ only if it passed p < 0.05 over the full sample and sat on the same side in both periods. About 300 tests were run, so treat the ✓ rows as the steadiest descriptions, not proven edges.
• DXY rows: DXY futures, Feb 2023 – Jul 2026 (28 NQ and 29 ES FOMC days). On the chart they read TVC:DXY, which can be changed in the inputs.
• [b]ADR20[/b] = mean (high − low) of the last 20 complete trading days.
• FOMC dates come from the Federal Reserve and are loaded to Dec 2027. Add new years in S_FOMC and raise LAST_DATE.
• No higher-timeframe value leaks future data. The month so far is built from completed daily bars plus the chart's own day; the weekly range is read only on the last bar.
 
 
[b]LIMITATIONS[/b]
 
[i]These are historical frequencies on 67 events: useful context, not guarantees.[/i] Same-window DXY rows describe how a stage finishes and cannot be known in advance. TradingView delays CBOT data without a CBOT subscription; when ZQ contracts are missing or stale, the Fed card and map can differ from CME's page. Nothing here is financial advice.
 
 
[b][image]https://www.tradingview.com/x/U5D5EKp7/ https://www.tradingview.com/x/Fnqu5cht/ https://www.tradingview.com/x/H02FmFVo/ https://www.tradingview.com/x/sHJmqone/ https://www.tradingview.com/x/8kceE7oR/ https://www.tradingview.com/x/tknBTAU8/ https://www.tradingview.com/x/gymFjOif/[/image]CREDITS[/b]
 
The Fed odds follow the method of CME Group's FedWatch Tool. Vizard is not affiliated with CME Group. ICT concepts ([i]Michael J. Huddleston[/i]): premium and discount, the RTH gap and its 50% level. Written from scratch; open source under MPL 2.0.

## Source Code

````pine
//@version=6
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Unclehk2000
//
// Vizard · Models 9–10: the FOMC decision day (9 Vizard, statement 14:00, press conference 14:30 ET) and the meeting's
// first day (10 Pesquisa). On the price chart: the statement and press-conference windows, the day-1 high and low carried
// into the decision day (live on day 1), the RTH gap with its octants, the statement shock cone, and three cards, each
// placed on its own: the event tally, the Fed odds, and the FOMC stages card (the 13:59 setup against the month, its open,
// the prior day and DXY; the sizes FOMC days with that setup made, at today's ADR20; the stages live against DXY).
// Indicator pane, side by side: the event clock (today's running range against this event's days, half-hour by half-hour)
// and the Fed map, a heat table of each upcoming meeting's target-range odds from CBOT 30-day fed funds futures.
// Built for NQ / MNQ and ES / MES. Every number was recomputed on their 1-minute data, Jan 2018 – Oct 2026 (ES to Aug 2026);
// a green key (✓) held in 2018–24 and again in 2025–26 (p < 0.05 over the full sample, same side in both periods).
// Release dates were checked against the BLS and Federal Reserve schedules and are loaded to Dec 2027; update once a year.
// Clock after Kyōka Suigetsu. Written from scratch.
// Concepts: ICT (Michael J. Huddleston).

indicator("Vizard", "Vizard", overlay = false, max_boxes_count = 300, max_lines_count = 400, max_labels_count = 400, max_polylines_count = 60)

TZ = "America/New_York"

// ═══════════════════════════════════════════════════════════════ Inputs
grpW = "View"
paneI   = input.string("Clock + Fed map", "Pane", options = ["Clock + Fed map", "Event clock", "Fed map", "Cards only"], group = grpW, tooltip = "What the indicator pane shows. Event clock: today's running range (or net move) against FOMC days at the same time of day. Fed map: the heat table of the Fed path the market prices, from 30-day fed funds futures. Cards only: neither (the clock card stays where you put it).", display = display.none)
clkMet  = input.string("Range", "Clock measure", options = ["Range", "Net move"], group = grpW, tooltip = "Range: the day's high − low so far. Net move: price − the 18:00 open. Both in points, against the same measure on this event's days (2018–26), scaled to today's ADR20 of the trading day. Needs an intraday chart of 60 minutes or lower.", display = display.none)
themeI  = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = grpW, tooltip = "Auto follows the chart background.", display = display.none)
layI    = input.string("Desktop", "Layout", options = ["Desktop", "Mobile"], group = grpW, tooltip = "Desktop: every row. Mobile: narrow cards for a phone screen, the clock folded into the tally's NOW row; the full wording stays in the tooltips. Each card has its own place. For a phone, use a separate chart layout set to Mobile, since layouts sync across devices.", display = display.none)
crdSzI  = input.string("Small", "Card text", options = ["Tiny", "Small", "Normal"], group = grpW, display = display.none)

grpE = "Event day"
anchorI  = input.string("Trading day (18:00)", "Day", options = ["Trading day (18:00)", "NY midnight", "RTH (09:30–16:14)"], group = grpE, tooltip = "Which day counts as the event day for the cards.\nTrading day: the CME day, 18:00 → 17:00 ET.\nNY midnight: 00:00 → 17:00 ET.\nRTH: 09:30 → 16:14 ET (close of the 16:14 bar).\nThe clock always runs on the trading day.", display = display.none)
markEv   = input.bool(true, "Mark releases", group = grpE, inline = "g3", display = display.none)
markD    = input.int(90, "and model structure for the last (days)", minval = 5, maxval = 400, group = grpE, inline = "g3", display = display.none)

grpS = "Model structure"
showStr = input.bool(true, "Draw the model's levels and windows", group = grpS, display = display.none)
cLvl    = input.color(#ffb300, "Levels", group = grpS, inline = "s1", display = display.none)
cGh     = input.color(#ab47bc, "Model", group = grpS, inline = "s1", display = display.none)
offI    = 12
cWin    = input.color(color.new(#2962ff, 90), "Windows", group = grpS, inline = "s1", display = display.none)
showWO  = input.bool(true, "Week open, 14:00 and 14:30 opens", group = grpS, inline = "s2", tooltip = "The week's open (Sunday 18:00) and, on FOMC days, the open of the 14:00 and 14:30 candles, each extended to the right of price.", display = display.none)
showSnp = input.bool(true, "Snapshots", group = grpS, inline = "s2", tooltip = "Fixed labels on FOMC days, printed once and left where they were: at 14:00, price against the 09:30 open and the week open; at 14:30, stage 1's move and the same two distances. Needs a chart of 30 minutes or less.", display = display.none)
showOct = input.bool(true, "RTH gap octants over NY AM", group = grpS, inline = "s3", tooltip = "FOMC day: the RTH gap (prior 16:14 close → 09:30 open) in eighths from 09:30 to 11:00, the 50% line bold and the quarter next to the open shaded.", display = display.none)
cOq     = input.color(color.new(#26a69a, 78), "Open-side quarter", group = grpS, inline = "s3", display = display.none)
showCone = input.bool(true, "Statement shock cone", group = grpS, inline = "s4", tooltip = "FOMC day, from the 14:00 open to 16:15: how far price had travelled by each 5 minutes on past FOMC days (2018–26), up and down separately, scaled to today's ADR20. Inner band: half of FOMC days stayed inside; outer band: 80%. Price outside the outer band = a bigger reaction than 4 in 5 past statements by that time. Before 14:00 a faint preview sits at the current price.", display = display.none)


grpK = "Event clock (indicator pane)"
clkOn  = paneI == "Clock + Fed map" or paneI == "Event clock"
kBands = input.bool(true, "10–90 and 25–75 bands", group = grpK, display = display.none)
kRef   = input.bool(true, "Reference path", group = grpK, tooltip = "On event days: the normal-day median. On other days: the next event's median, so you can see how its day usually unfolds.", display = display.none)
kPast  = input.bool(true, "Earlier days, faded", group = grpK, display = display.none)

grpP    = "Fed map (indicator pane, beside the clock)"
showMap = paneI == "Clock + Fed map" or paneI == "Fed map"
mapPos  = input.string("Top left", "Position", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = grpP, inline = "p0", tooltip = "The Fed path the market prices, from CBOT 30-day fed funds futures with CME FedWatch's steps: one column per upcoming meeting, one row per 25bp target range, each cell the odds of that range after the meeting. Under it: the expected change from today's rate, its move since yesterday's close (since 13:59 after a decision) and over 5 days, and the gap to the Fed's own dots at each year's last meeting. Shares the pane with the event clock.", display = display.none)
mapN    = input.int(8, "Meetings", minval = 3, maxval = 10, group = grpP, inline = "p1", display = display.none)
mapMin  = input.float(3.0, "rows from %", minval = 0.0, maxval = 20.0, step = 0.5, group = grpP, inline = "p1", tooltip = "A target range gets a row once any meeting gives it at least this share (ten rows at most).", display = display.none)
cHtHi   = input.color(#5c6bc0, "Heat", group = grpP, inline = "p2", display = display.none)
cHtLo   = input.color(color.new(#5c6bc0, 86), "→", group = grpP, inline = "p2", display = display.none)
cMapH   = input.color(#283593, "Header", group = grpP, inline = "p2", display = display.none)
cMapC   = input.color(#ffb300, "Today", group = grpP, inline = "p2", tooltip = "Heat: the colour of the highest odds, then of the lowest; each cell shades between the two. Header: the title bar. Today: the marker on the current target range.", display = display.none)

grpR = "Cards (price chart)"
showEv  = input.bool(true, "Event tally", group = grpR, inline = "r1", display = display.none)
crdPos  = input.string("Top right", "", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = grpR, inline = "r1", display = display.none)
talN    = input.int(12, "last", minval = 3, maxval = 60, group = grpR, inline = "r1", tooltip = "The last N FOMC days (up / down closes, average RTH gap), where price sits in this week's and this month's range in octants (top quarter = premium, bottom quarter = discount), and the next meeting.", display = display.none)
showCk  = input.bool(true, "Clock card", group = grpR, inline = "r3", display = display.none)
ckOn    = input.string("Indicator pane", "", options = ["Price chart", "Indicator pane"], group = grpR, inline = "r3", display = display.none)
ckPos   = input.string("Top right", "", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = grpR, inline = "r3", display = display.none)
cAcF    = input.color(#5c6bc0, "Accents · Fed", group = grpR, inline = "r4", display = display.none)
cAcD    = input.color(#00897b, "DXY", group = grpR, inline = "r4", tooltip = "Stripe and header colours of the Fed card and the DXY rows. The tally, clock and stages cards use the Model colour.", display = display.none)

grpM = "DXY"
dxySym  = input.symbol("TVC:DXY", "DXY", group = grpM, tooltip = "Read for the stages card: DXY's 4-week move and its moves in stage 1 and 2, in DXY's own ADR20.", display = display.none)
grpF    = "Fed odds · 30-day fed funds futures"
showFd  = input.bool(true, "Fed card", group = grpF, inline = "f0", display = display.none)
fdPos   = input.string("Middle right", "", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = grpF, inline = "f0", tooltip = "Odds for the next FOMC meetings from CBOT 30-day fed funds futures, worked out with the same steps as CME FedWatch. Mobile: one row.", display = display.none)
fdRoot  = input.string("CBOT:ZQ", "Contracts", group = grpF, tooltip = "TradingView prefix of the monthly 30-day fed funds contracts (CBOT:ZQZ2026 = Dec 2026). Seventeen months are loaded, from last month on. Without a CBOT data subscription TradingView delays them.", display = display.none)
sepAs   = input.string("16 Sep 2026", "Fed dots as of", group = grpF, inline = "f1", display = display.none)
sepY    = input.int(2026, "from", minval = 2025, maxval = 2035, group = grpF, inline = "f1", display = display.none)
sep1    = input.float(4.125, "Year-end medians", step = 0.125, group = grpF, inline = "f2", display = display.none)
sep2    = input.float(4.125, "", step = 0.125, group = grpF, inline = "f2", display = display.none)
sep3    = input.float(3.875, "", step = 0.125, group = grpF, inline = "f2", tooltip = "The Fed's dot plot: median year-end federal funds rate in the latest Summary of Economic Projections, for the first year and the two after (midpoint of the target range). Defaults read off the 16 Sep 2026 dot plot: 4.125 (2026), 4.125 (2027), 3.875 (2028). Update after each SEP (March, June, September, December). The Fed map sets them beside the market's path.", display = display.none)
grpV    = "FOMC stages card"
showSg  = input.bool(true, "Stages card", group = grpV, inline = "v0", tooltip = "SETUP: where price stands against the month's range, the month's open, the prior day and the 18:00 open, and DXY's last 4 weeks (live, then fixed at 13:59 on the FOMC day). EXPECT: how far FOMC days with that setup moved in stage 1, stage 2 and after 14:00, at today's ADR20, and any result that held. LIVE (FOMC day): each stage against DXY, and the morning gap. The day after FOMC lives in Hollow (Model 12).", display = display.none)
sgOn    = input.string("Price chart", "", options = ["Price chart", "Indicator pane"], group = grpV, inline = "v0", display = display.none)
sgPos   = input.string("Bottom left", "", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = grpV, inline = "v0", display = display.none)

// ═══════════════════════════════════════════════════════════════ Data
// Release dates (ET), verified 11 Oct 2026. FOMC = decision day (statement 14:00). CPI and NFP at 08:30.
// 2025 lapse: Oct 2025 CPI and jobs reports never published; later releases moved (all as published by BLS).
// UPDATE ONCE A YEAR: add the next year's FOMC dates (federalreserve.gov, out by mid-year) and BLS CPI / Employment
// Situation dates (bls.gov/schedule, out each autumn), then raise LAST_DATE.
S_FOMC = "20180131,20180321,20180502,20180613,20180801,20180926,20181108,20181219,"
     + "20190130,20190320,20190501,20190619,20190731,20190918,20191030,20191211,"
     + "20200129,20200429,20200610,20200729,20200916,20201105,20201216,20210127,"
     + "20210317,20210428,20210616,20210728,20210922,20211103,20211215,20220126,"
     + "20220316,20220504,20220615,20220727,20220921,20221102,20221214,20230201,"
     + "20230322,20230503,20230614,20230726,20230920,20231101,20231213,20240131,"
     + "20240320,20240501,20240612,20240731,20240918,20241107,20241218,20250129,"
     + "20250319,20250507,20250618,20250730,20250917,20251029,20251210,20260128,"
     + "20260318,20260429,20260617,20260729,20260916,20261028,20261209,20270127,"
     + "20270317,20270428,20270609,20270728,20270915,20271027,20271208"
S_CPI  = "20180112,20180214,20180313,20180411,20180510,20180612,20180712,20180810,20180913,20181011,20181114,20181212,"
     + "20190111,20190213,20190312,20190410,20190510,20190612,20190711,20190813,20190912,20191010,20191113,20191211,"
     + "20200114,20200213,20200311,20200410,20200512,20200610,20200714,20200812,20200911,20201013,20201112,20201210,"
     + "20210113,20210210,20210310,20210413,20210512,20210610,20210713,20210811,20210914,20211013,20211110,20211210,"
     + "20220112,20220210,20220310,20220412,20220511,20220610,20220713,20220810,20220913,20221013,20221110,20221213,"
     + "20230112,20230214,20230314,20230412,20230510,20230613,20230712,20230810,20230913,20231012,20231114,20231212,"
     + "20240111,20240213,20240312,20240410,20240515,20240612,20240711,20240814,20240911,20241010,20241113,20241211,"
     + "20250115,20250212,20250312,20250410,20250513,20250611,20250715,20250812,20250911,20251024,20251218,20260113,"
     + "20260213,20260311,20260410,20260512,20260610,20260714,20260812,20260911,20261014,20261110,20261210,20270113,"
     + "20270211,20270310,20270413,20270512,20270610,20270714,20270811,20270914,20271014,20271110,20271210"
S_NFP  = "20180105,20180202,20180309,20180406,20180504,20180601,20180706,20180803,20180907,20181005,20181102,20181207,"
     + "20190104,20190201,20190308,20190405,20190503,20190607,20190705,20190802,20190906,20191004,20191101,20191206,"
     + "20200110,20200207,20200306,20200403,20200508,20200605,20200702,20200807,20200904,20201002,20201106,20201204,"
     + "20210108,20210205,20210305,20210402,20210507,20210604,20210702,20210806,20210903,20211008,20211105,20211203,"
     + "20220107,20220204,20220304,20220401,20220506,20220603,20220708,20220805,20220902,20221007,20221104,20221202,"
     + "20230106,20230203,20230310,20230407,20230505,20230602,20230707,20230804,20230901,20231006,20231103,20231208,"
     + "20240105,20240202,20240308,20240405,20240503,20240607,20240705,20240802,20240906,20241004,20241101,20241206,"
     + "20250110,20250207,20250307,20250404,20250502,20250606,20250703,20250801,20250905,20251120,20251216,20260109,"
     + "20260211,20260306,20260403,20260508,20260605,20260702,20260807,20260904,20261002,20261106,20261204,20270108,"
     + "20270205,20270305,20270402,20270507,20270604,20270702,20270806,20270903,20271008,20271105,20271203"
LAST_DATE = 20271210

// Event clock, trading day 18:00 → 17:00 ET in 46 half-hour steps, ×1000 of ADR20 (trading day). Per day type (own
// events, then normal): range q10/25/50/75/90 ×46, net move q10/25/50/75/90 ×46, median share of the day's range done ×46.
CK_NQ = "868:8E8S8[8b8o8}8}8}8}9,9.91949;9>9>9Q9U9^9f9h9h9h9h9n:*:::>:>;-;O;[;];c;l;l;q;|=(>=>e>e>v?<8C8N8U8b8}9'94969>9>9A9C9C9O9^9_9a9f9u9x:.:<:N:[:_:_:l:w;%;';';`;x<1<E<I<Q<S<S<Y>6?S@.@M"
     + "@uA/8Z8q8~9-9I9]9d9s9z:#:2:2:3:5:9:B:J:J:h:p;.;1;8;:;I;I;J;V;X;j<!<O<z=3=?=X=c=m=t>)?d@rB5BkC@Cq8z9J9V9u:@:O:z:z;2;2;F;F;F;F;N;W;d;d<G<G<R<W<]<]<]<h<u=-=L=W=Z>`?!?K?U?U?U?e?e?iAjD["
     + "E9F]GEGE:C;_;_;_<?<N<`<`<j=+=+=+=+=+=1=1=1=1=P=P=g=g=~>/>K>K>t>v?)@k@k@vC&CWCWCzD-D-D-D-DyFkHfJ)J+J=7-6S6e6a6d6l6]6Q6l6z6l6Y6d6Q6X6k6e6f6v6q6U6T6E6D6@6Y6U65666F6H5Z4W4N493p4C4=3[4n"
     + "4.3#1W.q-I-f7L7@717;7:7?797;7J7R7T7T7G7M7V7U7]7d7c7a7E7F7G7L777O7T7M7n7>7.6b6D6@6Z5t6$5|6)6=5m5U4_4+4~4L7p7l7d7w8#7p8*8/8+878K8W8H8P8U8Q8L8G8U8R8G8E8]8Z8M8]8Y8e8Q8q8d8O968b8F8V8C8a"
     + "8p8e9C9b988x9$8I898<8K8K8t9)92939J9Y9[9U9M9A9K9o9g9x9y:):':%9}9z:!9|:=:.9t9}:8;:;2;!;_<.<-;[;{;w<f>6?y>x>q?G9-8z9$9g9_9_:):@:;:O:c:R:D:]:n:|;#;6;F;@;S;m;t;^;c;l;v<K<J<K;b=r?-@/?p?Z"
     + "?e>|>m@#@U@lA`BfC1Ch8W8c8v8}9?9M9T9i9w9w:-:4:4:::::?:?:I:U:]:m:{;2;2;2;2;@;G;P;k;y<f=9=^>+>6>6>:>:>;?UA2A{BZBZBZ80898D8P8^8a8n8z8}8}9!9!9)9)919>9M9N9V9V9c9u9u:*:+:G:J:Q:Q:W:w;O;v;{"
     + "<1<j=!=&=&=;=B=U=U=U=U=U8>8I8T8]8x9$939>9@9O9O9O9O9S9X9i9l9p:(:<:?:K:_:c:c:g;(;/;=;G;U<T<s=H=R=w>$>M>S>U>f>k?8?F?M?M8P8g8p8y9@9O9W9o9q9{9|:%:,:,:.:?:?:T:s;,;@;S;Y;m<!<*<><B<F<L<f=E"
     + ">T?+?>?I?U?y@&@4@8@I@L@_@wA/8{9*979G9p:6:@:H:[:a:t:~;2;B;O;O;U;U;w<8<A<j<r=2=A=A=X=l>6>F>K@-@;A8AWB-B-B-B1B1B1BSB_C:CCCo9J9V:):h;P;W<7<C<C<u<|=%=%=%=-=^>%>%>*>l?#?+?+?+?o@;@;@sA+AQ"
     + "AQB]BqD!DQDbE+EnEnEnEnEnEnEnF8Gq6z7*6Z6]655p5q5h5c5r5m585P5&5!5&5M5/5K4~4Q4I4U494$4>4B4%4N4+3a2b210g0j0V1/160g1N1!1@1(0s0e0R7J7B7D7/6x7$6j6X6T6L6=6@6F6V6M6U6H6P6N6>6?6+5p5x676H5l5i"
     + "5|5[5U4p4:3e3Y3k3|3j3:3]2{3>3/2p3I3Y7a7d7l7e7U7Z7V7T7L7M7K7Q7O7S7W7e7c7b7a7f757`7I7G7;7k7z7g8*7x7P7L6y7*6k7!7.757Z7Y7Q737H7V7Y7m8.88818;8M8K8K8_8I8W8[8H8N8Z8i8V8d8g8j8t8x9:9N9-9:9E"
     + "9z:%9l9i:(:::T:I:j:d:v;V;@;);c<D;N;G<2<E8b8g8K8n9)9E9Z9H9M9f9I9[9f9V9n9i9n9n:F:u:r;9;2;];Q;t<%<(<:<H<t<R<t=&=i=j>^=t=j=X=W>P>p?B?S@38d8q8}979]9k:,:<:E:L:b:h:l:n:n;*;*;6;@;a<%<=<H<P"
     + "<U<x=4===b=l=y?I?k@Y@jA2ADAdAmAxB1BOBZBZBZBZ8<8E8N8Z8l8v9$9,9295989:9?9@9B9J9R9Y9l9s9~:*:4:9:=:B:I:T:b:l:q;V;w<0<A<L<Y<b<k<v=$=(=+=7=F=H8K8W8f8v9/9>9H9S9^9c9g9j9l9o9u9~:-:5:I:U:f:n"
     + ":t:|;&;.;6;>;F;U;`<Q<~=<=T=h=z=~>3>;>I>S>Y>j>q>s8k8~949D9d9t:&:5:C:K:S:W:_:b:h:q:~;0;H;V;f;u;|<'<.<<<G<N<[<r=#>'>Y?)?E?[?s@+@4@E@O@a@sA*A9A=9C9[9{:1:[:{;2;E;O;Y;e;k;s;v;~<,<@<R<n<}"
     + "=9=G=Z=c=r>!>,>>>Q>q?#@0A&APAzB6BPBgBxC,CBCXCuDADLDV:K:u;1;V;x<@<R<n=3===@=T=]=d=n=x>;>K>g?(?I?R?v@.@8@G@U@g@uA9AHBoCaDGE(ENEjF.FEFoG-GIGiH-HCHR6u6c6Q6C615p5X5V5K5D5A5>53545)5)5&4m"
     + "4`4V4G4G4:4-4+444,3c3`3P3Q2Q1W1C1!0~0r0U0E0F/z/v/K/E/2/#7C7>777.6}6|6w6r6m6i6l6j6m6g6c6a6X6]6N6F6@6@686464616?606/6&5{5N555+5/4{4g4n4h4m4U4C4B4G4A4@7k7m7r7s7w7u7w7u7w7v7u7u7u7w7x7{"
     + "8%8#8%8&81828,868/878;8@8484808*8*8:858=8C8>85858E8D8H8E8L8N888?8L8R8c8l8w8|9!9&9'9+9*91939?9H9M9V9`9e9o9s9x9r9}9x9x:$:6:3:m;,;%;A;_;];k;l<&<0<9<;<O<Q<b8k8x909<9X9g9v:0:0:6:>:G:M:I"
     + ":O:]:g:s:|;4;K;L;T;V;c;[;^;h<)<?<C=K=a>/>F>t?%???R?Z?T?f@;@5@4@B8|949K9c:(:::O:_:n:u;#;(;,;3;=;E;U;g<%<8<K<W<e<r<~=+=7=L=]=~>.?H@)@^A*AKAcAuB,BDBZBZBZBZBZBZ"
CK_ES = "8=8?8G8U8d8k8r9#9)9)9096969;9;9@9@9@9I9Q9Z9e9l9t9t9t:*:-:/:>:B:W:j:o:o:v;);.;B;B<p=_>&>p>q>q8C8U8g8k8}9*919@9J9J9J9L9L9O9U9[9]9f9t9|:2:<:F:O:O:O:R:U:a:c:c;+;_;q;t<-<=<C<S<S>(?8?p@!"
     + "@/@q8f8x9$9=9Q9f9u9|:*:.:/:::<:@:X:_:h:i:t:x;-;9;H;L;P;P;_;f;l;u;u<]=!=.=I=X=X=X=d=y?KA0BoDBDCDU949?9b:*:T:q;9;9;^;_;_;_;_;c;n;n<(<(<I<I<[<[<]<e=7=>=>=>=@=c=d=|>a?#?#?<?V?^?a?aAjDN"
     + "E`F|GDGT:/:n:{;-<&<=<g<g<m=Q=Q=Q=Q=Q=Q=Q=Q=Q=e={={={>2>2>Z>g>l?'?'?s?y@XBHC%C%C>CHCHCHDcFEHDJcLFMCMG6w6T6U6C6D6.6F6:6l6g6[6P6K6;6C6j6|6v6j6l6^6N6C6I6E6M6M6@6h6/695&4d4d4|4(4,3g3b3r"
     + "2?24/f-X,>,q7B777=7=74717*6z7K7=797*7'7372707E7D7r7G76757=7F767U7a7G797B7:6n6D6<6=6(6#5l5k6L5.5M3N2c212*7t7k7f7n7~7x7{818?8C8J8O8F8J8Z8N8F8U8T8S8Y8I8P8Y8[8J8a8j8R8[878(8Y8.8K8N898Q"
     + "7q8/8S918%7A7o8?8-8-8I8P8y9*9<9:9P9a9]9v9h9o9T9v9l9k:-:+:3:!:(:09}:#:%9o9w9d9c:a;):Z;';3:o:f:l:t;V=,>c=t>-=|8r8c929p9|:.:J:N:Y:c:Z:O:J:w:Z:n;E;D;7;2;~<,;p;{;f;n<3<H<D<B<;='>B>M=r>!"
     + ">Q>:=]=S>aAfA%A,B7Bh8[8g8o8~9B9I9I9X9a9n9q:':':-:8:@:H:M:M:W:q:r:y:|:|;-;1;A;A;Z;e<I<|=#=%=@=i=i=j=}?aA@B6BZBZBZ878>8O8X8i8t9'9*9+98989;9;9?9G9I9Q9T9d9d9o9w9w:8:=:=:E:Q:h:o:~;0;9;>"
     + ";>;_;_;_;_;i<(<(<U<U<U='8E8Q8]8e9&9)979I9K9L9Q9Q9R9R9^9h9{:#:3:K:g:q:{;-;0;:;:;F;P;q;w<s=9=A=d=}>&>&>&>3>U>y>y?'?'?'8V8k8s9%9B9U9_9o9x:!:.:1:5:A:F:U:[:m:u;1;G;S;i<(<8<M<x<x=4=I=Q={"
     + ">>>k?F?_?c?w?w@2@2@:@F@T@T@h8~9<9L9Q9w:4:b:g:t:t:w;!;3;4;4;B;`;n<8<@='=S=V=V=V=l=l=s>!>M>{?U?x@@A,AVAyB*BDBcBiC(CBD.D2D29M9_:B;9<+<+<]<o<}=&=/=4=4=4=I=I=`=`=|>r?3?H?K?K@0@1@7@g@gAa"
     + "AaC?DsF>FKFZFqFqFxFxF~G%G%G%GxH>6~6t6[6_605p5W5Q5V5f5M5e5g5Y5?5<5A4i5P4u474>4=4<4=4P3|3X3=3R3p2r2F1]0r080n/z/{1F0m1+1P1y1;1'7E7?7>7(6y6w6j6d6R6[6S6A6S6k6N6V6H6X6_6J6X6<6O5{6.6<5t6-"
     + "645q5h4m5!573z4+4S4M4P4b5,4:434F4&4>7g7e7l7k7T7`7b7e7T7b7U7X7M7Q7I7g7V7Z7p7j7o7g7a7T7O7x8)7k8;858)7I7^6m7Y767Z7$7Y7S7W7N7G727]7=8'8881858C8A8N8T8b8p8Y8V8g8c8t9&8v8r928}979F9@9F9W:i"
     + ":M:m:G9u:S:':2:K:d:`;(;T:};F:[;_;D:|;=;C8^8r8a8j8{9A9V9V9l9R9Z9r:$:#:B:4:M:0:H:{;2:o;.;4;<<'<;<8<-<D<c=P<P===Q=u=~>q>O>c>F>Y?6?|@)@G8m8s9.9K9q:*:?:N:V:_:k:v:y:};,;P;[;d;{<J<^<k<q=1"
     + "=A=Q=W=b>,>N>_?<?v@cA9AKAfAlB!B4BFBZBZBZBZBZ8>8G8S8`8q8}9(9196989<9>9B9D9H9L9T9[9j9v:#:):/:5:<:C:J:O:Z:i:m;7;T;m;y<(<-<4<<<J<X<h<p=&=-=38P8^8n8|959C9M9X9_9e9i9m9o9s9y:%:/:7:K:Z:f:p"
     + ":y:~;(;.;5;=;G;];h<2<S<q=/=?=Q=]=g=o=x>(>3>U>^>`8p9&999K9l9}:/:?:I:Q:X:Z:a:g:m:w;);1;K;_;n;v<#<,<6<?<K<U<b<}=1=p>B>e?#?/?I?_?n?y@.@>@V@p@~A&9H9d:':>:_:};6;P;^;l;q;x;}<*</<;<K<]<~=7"
     + "=P=m=}>/>:>F>M>b>p?$?2@(@oA?AgA~B:BWBvC@COCcC|DDDODT:P;#;<;a</<B<a=3=E=[=a=i=x=}>0>=>Y>k?5?P?a?n@%@2@M@_@vA>AKAhB)C.CyDZE#EUEsF4FeG,GdGrHII3I;IM6o6^6K6@6)5s5[5O5G5C575:5%5.4v4w5)4o"
     + "4Q4K464+4(4'3r3w3}3^3Q373>2Z271|1R1C0{0S0N0=0@/{/f/A/M/=7B7<757(6{6v6n6m6b6`6h6b6_6]6Y6Z6P6N6@656<6764626+616.6/6,6#5|5p5W5O5O575,5.5&4|4r4q4s4M4E4?7m7p7q7r7q7q7s7w7w7s7x7v7x7y7s7w"
     + "7{8!8$8*8+8+8*8.80878/818/828488818<888=84838=8C8F8U8N8F8N8H8:8B8L8Q8c8n8t8t8}9$9(9)9.9/929<9H9J9P9]9l9n9w9x9z9{:*:0:.:<:8:W:p:y;%;);G;J;R;m;z<&<3<D<N<Q8m8x909@9]9g9s:%:-:3:<:A:J:Q"
     + ":N:[:j:d:};4;I;V;V;_;b;p;n;l<!<7<>='=P=h>9>H>a?*?5?Y?a?s@#@D@E@J9%9=9V9o:4:H:Z:j:{;(;0;5;=;A;K;R;f;s<2<H<a<p<~=,===E=T=d=w>6>F?6?z@@@fA.AHAZAxB5BMBZBZBZBZBZ"

int  AN    = anchorI == "Trading day (18:00)" ? 0 : anchorI == "NY midnight" ? 1 : 2
bool isES  = syminfo.root == "ES" or syminfo.root == "MES"
bool isNQ  = syminfo.root == "NQ" or syminfo.root == "MNQ"
string symR   = isES ? "ES" : "NQ"                           // whose statistics the cards show
string symTag = isNQ or isES ? syminfo.root : syminfo.root + " (" + symR + " DATA)"
NF  = 24
CKB = 506

parseDates(string s) =>
    array<int> out = array.new<int>()
    for p in str.split(s, ",")
        out.push(int(str.tonumber(p)))
    out
parseStats(string s) =>
    array<float> out = array.new<float>()
    for r in str.split(s, ";")
        for p in str.split(r, ",")
            out.push(str.tonumber(p))
    out
// clock and cone data are packed two characters per value: (index in P92) × 92 + (index in P92) − 2000, then ÷ 1000
P92 = "!#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~"
unpackMilli(string s) =>
    array<float> out = array.new<float>()
    for i = 0 to int(str.length(s) / 2) - 1
        out.push((str.pos(P92, str.substring(s, 2 * i, 2 * i + 1)) * 92 + str.pos(P92, str.substring(s, 2 * i + 1, 2 * i + 2)) - 2000) / 1000.0)
    out
parseMilli(string s) =>
    array<float> out = array.new<float>()
    for r in str.split(s, ";")
        for p in str.split(r, ",")
            out.push(str.tonumber(p) / 1000.0)
    out

var array<int>   FO = parseDates(S_FOMC)
var array<int>   CP = parseDates(S_CPI)
var array<int>   NP = parseDates(S_NFP)
var array<float> CK = unpackMilli(isES ? CK_ES : CK_NQ)
ck(int i, int m, int k, int j) => CK.get(i * CKB + m * 230 + k * 46 + j)
ckSh(int i, int j) => CK.get(i * CKB + 460 + j)
// value at a point inside half-hour step j (f = 0 → end of step j − 1, f = 1 → end of step j); the day starts at 0
ckAt(int i, int m, int k, int j, float f) =>
    float b  = ck(i, m, k, j)
    float a0 = j > 0 ? ck(i, m, k, j - 1) : 0.0
    a0 + (b - a0) * f
ckShAt(int i, int j, float f) =>
    float b  = ckSh(i, j)
    float a0 = j > 0 ? ckSh(i, j - 1) : 0.0
    a0 + (b - a0) * f

// ═══════════════════════════════════════════════════════════════ Helpers
bgLum = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)
dark  = themeI == "Dark" or (themeI == "Auto" and bgLum < 128)
cBg   = dark ? #0e1117 : #ffffff
cTx   = dark ? #e6e9ef : #131722
cSub  = dark ? #9aa3b5 : #4a5163
cMu   = dark ? #5d6476 : #9aa1b2
cWarn = #ff5252
cHot  = dark ? #ff8a65 : #d84315
cCold = dark ? #64b5f6 : #1565c0
cOk   = dark ? #66bb6a : #2e7d32
crdSz = crdSzI == "Tiny" ? size.tiny : crdSzI == "Small" ? size.small : size.normal
posOf(string s) =>
    switch s
        "Top left"      => position.top_left
        "Top center"    => position.top_center
        "Top right"     => position.top_right
        "Middle left"   => position.middle_left
        "Middle right"  => position.middle_right
        "Bottom left"   => position.bottom_left
        "Bottom center" => position.bottom_center
        => position.bottom_right

dateKey(int t) => year(t, TZ) * 10000 + month(t, TZ) * 100 + dayofmonth(t, TZ)
keyTime(int k) => timestamp(TZ, int(k / 10000), int(k / 100) % 100, k % 100, 12, 0)
keyAt(int k, int m) => timestamp(TZ, int(k / 10000), int(k / 100) % 100, k % 100, int(m / 60), m % 60)
addDays(int k, int n) => dateKey(keyTime(k) + n * 86400000)
anchorKey(int an, int t) => an == 0 ? dateKey(t + 6 * 3600000) : dateKey(t)
inWin(int an, int m) => an == 0 ? true : an == 1 ? m < 1020 : m >= 570 and m < 975
winBars(int an) => an == 0 ? 92 : an == 1 ? 68 : 27
pf(float v) => str.tostring(v, format.mintick)
x2(float v) => str.tostring(v, "0.00") + "×"
p0(float v) => str.tostring(v * 100, "0") + "%"
fmtDay(int k) => str.format_time(keyTime(k), "EEE dd MMM", TZ)
dowOf(int k) => dayofweek(keyTime(k), TZ)
hhmm(int m) => (m / 60 < 10 ? "0" : "") + str.tostring(int(m / 60)) + ":" + (m % 60 < 10 ? "0" : "") + str.tostring(m % 60)
// end of half-hour step j of the trading day, as minutes after midnight ET
stepEnd(int j) => (1080 + 30 * (j + 1)) % 1440

// day type: 0 FOMC · 1 NFP · 2 CPI · 3 day after FOMC · 4 FOMC day 1 · 5 NFP week Mon–Thu · 6 normal
dayType(int k, int pk) =>
    int  dw  = dowOf(k)
    bool hol = false
    if dw >= 2 and dw <= 5
        for j = 1 to 6 - dw
            if NP.includes(addDays(k, j))
                hol := true
    FO.includes(k) ? 0 : NP.includes(k) ? 1 : CP.includes(k) ? 2 : FO.includes(pk) ? 3 : FO.includes(addDays(k, 1)) ? 4 : hol ? 5 : 6
typeShort(int ty) =>
    switch ty
        0 => "FOMC"
        1 => "NFP"
        2 => "CPI"
        3 => "FOMC +1"
        4 => "FOMC D1"
        5 => "NFP week"
        => "Normal"
nextOf(array<int> a, int k) =>
    int r = na
    for d in a
        if d >= k
            r := d
            break
    r
inDays(int k, int today) => int(math.round((keyTime(k) - keyTime(today)) / 86400000.0))
whenTxt(int k, int today) =>
    int dd = inDays(k, today)
    fmtDay(k) + (dd == 0 ? " · today" : dd == 1 ? " · tomorrow" : " · in " + str.tostring(dd) + "d")
// approximate percentile of x within q10 / q25 / q50 / q75 / q90
pctQ(float x, float q10, float q25, float q50, float q75, float q90) =>
    float p = na
    if not na(x) and not na(q10) and not na(q90)
        if x < q10
            p := 5.0
        else if x <= q25
            p := 10.0 + 15.0 * (x - q10) / math.max(q25 - q10, 1e-9)
        else if x <= q50
            p := 25.0 + 25.0 * (x - q25) / math.max(q50 - q25, 1e-9)
        else if x <= q75
            p := 50.0 + 25.0 * (x - q50) / math.max(q75 - q50, 1e-9)
        else if x <= q90
            p := 75.0 + 15.0 * (x - q75) / math.max(q90 - q75, 1e-9)
        else
            p := 95.0
    p
pTxt(float p) => na(p) ? "—" : p <= 5.0 ? "<P10" : p >= 95.0 ? ">P90" : "≈P" + str.tostring(p, "0")
pill(string s) => s == "Above" ? "▲ ABOVE" : s == "Below" ? "▼ BELOW" : s == "Inside" ? "● INSIDE" : "—"

// ═══════════════════════════════════════════════════════════════ Model profiles (recomputed 2018–26)
pfName(int k) =>
    switch k
        0 => "M9 VIZARD · FOMC 14:00"
        1 => "M10 PESQUISA · FOMC day 1"
        => ""
ownTy(int k) =>
    switch k
        0 => 0
        1 => 4
        => 6
TAL_NQ = "20180131,-1,-1,36.75,0.529;20180321,-1,-1,-30.5,-0.441;20180502,-1,-1,8.75,0.131;20180613,-1,-1,20.0,0.278;20180801,-1,1,8.75,0.12;20180926,-1,-1,1.0,0.013;20181108,-1,-1,-39.0,-0.54;20181219,-1,-1,27.0,0.418;"
     + "20190130,1,1,73.5,1.107;20190320,1,1,7.75,0.105;20190501,-1,-1,35.5,0.455;20190619,1,1,4.25,0.056;20190731,-1,-1,26.0,0.327;20190918,1,1,-14.25,-0.181;20191030,1,1,12.5,0.155;20191211,1,1,12.5,0.149;"
     + "20200129,-1,-1,45.25,0.497;20200429,1,1,139.75,1.603;20200610,1,1,87.0,0.874;20200729,1,1,49.0,0.465;20200916,-1,-1,-0.75,-0.007;20201105,1,1,238.75,2.025;20201216,1,1,16.75,0.133;20210127,-1,-1,-179.5,-1.323;"
     + "20210317,1,1,-148.0,-1.124;20210428,1,-1,-6.5,-0.047;20210616,-1,-1,15.25,0.109;20210728,1,-1,89.25,0.599;20210922,1,1,79.5,0.531;20211103,1,1,22.75,0.143;20211215,1,1,-12.75,-0.08;20220126,1,-1,406.0,2.886;"
     + "20220316,1,1,182.75,1.36;20220504,1,1,-11.75,-0.09;20220615,1,1,146.0,1.291;20220727,1,1,148.5,1.222;20220921,-1,-1,14.0,0.117;20221102,-1,-1,29.75,0.263;20221214,-1,-1,-24.25,-0.205;20230201,1,1,32.25,0.266;"
     + "20230322,-1,-1,0.5,0.004;20230503,-1,-1,19.0,0.144;20230614,1,1,-3.0,-0.02;20230726,-1,1,-96.0,-0.611;20230920,-1,-1,33.5,0.218;20231101,1,1,50.0,0.346;20231213,1,1,14.5,0.089;20240131,-1,-1,-167.0,-0.951;"
     + "20240320,1,1,43.25,0.237;20240501,1,-1,-59.25,-0.337;20240612,1,1,147.5,0.766;20240731,1,1,576.5,3.067;20240918,-1,-1,41.25,0.212;20241107,1,1,116.0,0.555;20241218,-1,-1,-18.25,-0.083;20250129,1,-1,29.5,0.137;"
     + "20250319,1,1,67.5,0.346;20250507,1,1,24.0,0.121;20250618,1,-1,41.5,0.191;20250730,1,1,31.0,0.132;20250917,-1,-1,-15.75,-0.065;20251029,1,-1,109.0,0.417;20251210,1,1,-37.25,-0.145;20260128,1,0,,;"
     + "20260318,-1,-1,-98.75,-0.395;20260429,-1,-1,20.0,0.074;20260617,-1,-1,217.75,0.718;20260729,-1,-1,-4.0,-0.014;20260916,-1,-1,99.25,0.342"
TAL_END_NQ = 20261009
TAL_ES = "20180131,1,-1,9.5,0.336;20180321,-1,-1,-3.75,-0.138;20180502,-1,-1,-2.75,-0.104;20180613,-1,-1,4.75,0.17;20180801,-1,-1,-4.5,-0.159;20180926,-1,-1,1.0,0.034;20181108,-1,1,-12.25,-0.435;20181219,-1,-1,12.5,0.493;"
     + "20190130,1,1,14.25,0.54;20190320,-1,-1,0.5,0.018;20190501,-1,-1,3.5,0.119;20190619,1,1,-1.25,-0.043;20190731,-1,-1,4.25,0.141;20190918,1,1,-4.75,-0.158;20191030,1,1,2.5,0.082;20191211,1,1,1.5,0.048;"
     + "20200129,-1,-1,13.0,0.397;20200429,1,1,46.25,1.613;20200610,-1,-1,6.25,0.195;20200729,1,1,8.0,0.249;20200916,-1,-1,9.25,0.272;20201105,1,1,55.75,1.622;20201216,1,1,6.0,0.163;20210127,-1,-1,-45.0,-1.169;"
     + "20210317,1,1,-20.0,-0.505;20210428,1,-1,3.25,0.078;20210616,-1,-1,2.0,0.047;20210728,1,-1,15.25,0.348;20210922,1,1,32.0,0.738;20211103,1,1,-3.25,-0.07;20211215,1,1,3.75,0.081;20220126,1,-1,78.0,1.799;"
     + "20220316,1,1,46.5,1.095;20220504,1,1,3.0,0.072;20220615,1,1,41.25,1.104;20220727,1,1,25.5,0.649;20220921,-1,-1,13.5,0.348;20221102,-1,-1,1.0,0.026;20221214,-1,-1,-3.75,-0.092;20230201,1,1,-6.25,-0.153;"
     + "20230322,-1,-1,-1.5,-0.037;20230503,-1,-1,4.75,0.115;20230614,1,1,3.5,0.08;20230726,-1,1,-16.75,-0.364;20230920,-1,-1,10.75,0.239;20231101,1,1,15.75,0.374;20231213,1,1,0.0,0.0;20240131,-1,-1,-19.0,-0.384;"
     + "20240320,1,1,0.25,0.005;20240501,1,-1,-6.5,-0.128;20240612,1,-1,44.75,0.831;20240731,1,1,99.25,1.823;20240918,-1,-1,5.25,0.093;20241107,1,1,20.25,0.34;20241218,-1,-1,-1.0,-0.017;20250129,-1,-1,-4.75,-0.078;"
     + "20250319,1,1,13.75,0.245;20250507,1,1,14.0,0.249;20250618,1,-1,7.75,0.13;20250730,1,1,8.25,0.129;20250917,-1,-1,-2.25,-0.034;20251029,-1,-1,18.0,0.26;20251210,1,1,-3.25,-0.047;20260128,1,-1,16.0,0.228;"
     + "20260318,-1,-1,-27.5,-0.409;20260429,-1,-1,-10.0,-0.139;20260617,-1,-1,13.0,0.173;20260729,-1,-1,-10.75,-0.144"
TAL_END_ES = 20260828
TAL_NAME = "FOMC"
talIs(int k, int pk) => FO.includes(k)
ownCk(int k) =>
    switch k
        0 => 0
        1 => 1
        => 0
ckName(int k) =>
    switch k
        0 => "FOMC"
        1 => "FOMC D1"
        2 => "Normal"
        => ""
ckN(int k, bool es) =>
    switch k
        0 => es ? "68" : "68"
        1 => es ? "64" : "64"
        2 => es ? "1416" : "1342"
        => ""
ownProfile(int tk, int pk, int today) =>
    int  k   = 0
    bool now = false
    int  d   = na
    if FO.includes(tk)
        now := true
        d := tk
    else if FO.includes(addDays(tk, 1))
        k := 1
        now := true
        d := tk
    else
        int rf = na(tk) ? today : math.max(tk, today)
        int f  = nextOf(FO, rf)
        int f2 = na(f) ? na : addDays(f, -1) >= rf ? f : nextOf(FO, addDays(f, 1))
        k := 1
        d := na(f2) ? na : addDays(f2, -1)
    [k, now, d]
ownNext(int today) =>
    int f  = nextOf(FO, today)
    int f2 = na(f) ? na : addDays(f, -1) >= today ? f : nextOf(FO, addDays(f, 1))
    ["FOMC day 1", na(f2) ? na : addDays(f2, -1), "FOMC 14:00", f]

// ADR20, built on 15-minute bars so it needs little chart history: mean (high − low) ÷ open of the last 20 complete
// days (at least 15). One for the chosen day, one for the trading day (the clock).
adrCalc(int an) =>
    var array<float> rs = array.new<float>()
    var float o = na
    var float h = na
    var float l = na
    var int   n = 0
    int  m  = hour(time, TZ) * 60 + minute(time, TZ)
    int  dk = anchorKey(an, time)
    bool iw = inWin(an, m)
    bool st = iw and (not iw[1] or dk != dk[1])
    if st
        if n >= 0.94 * winBars(an) and o > 0
            rs.push((h - l) / o)
            if rs.size() > 20
                rs.shift()
        o := open
        h := high
        l := low
        n := 1
    else if iw and not na(o)
        h := math.max(h, high)
        l := math.min(l, low)
        n += 1
    rs.size() >= 15 ? rs.avg() : na
ADRtd = request.security(syminfo.tickerid, "15", adrCalc(0))
// Higher-timeframe requests. None of them leaks future data:
// · the weekly high / low are read only on the last bar (the WEEK row), where nothing lies ahead;
// · the month so far comes from daily bars before today's bar updates it, plus the chart's own day so far, so it can be
//   read at 13:59 on any FOMC day; the month's open is known once the month's first bar opens.
[wO, wH, wL, wC] = request.security(syminfo.tickerid, "W", [open, high, low, close], lookahead = barmerge.lookahead_on)
float dxL = request.security(dxySym, timeframe.isintraday ? timeframe.period : "D", close, ignore_invalid_symbol = true)
mtd() =>
    var float h = na
    var float l = na
    var float o = na
    bool  nw = na(time_tradingday[1]) or month(time_tradingday, "UTC") != month(time_tradingday[1], "UTC")
    float pH = nw ? na : h
    float pL = nw ? na : l
    if nw
        h := high
        l := low
        o := open
    else
        h := math.max(h, high)
        l := math.min(l, low)
    [pH, pL, o]
[mtH, mtL, mtO] = request.security(syminfo.tickerid, "D", mtd(), lookahead = barmerge.lookahead_on)
// DXY's ADR20 (completed days) and its close 20 trading days back
[dxA, dx20] = request.security(dxySym, "D", [ta.sma(high - low, 20)[1], close[20]], lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)

// ═══════════════════════════════════════════════════════════════ Today, live
int  tfM  = math.max(1, int(timeframe.in_seconds() / 60))
int  mod  = hour(time, TZ) * 60 + minute(time, TZ)
int  calK = dateKey(time)
int  key  = anchorKey(AN, time)
bool iwin = inWin(AN, mod)
bool dSt  = iwin and (not iwin[1] or key != key[1])
var float dO = na
var float dH = na
var float dL = na
var float dC = na
var int   dX = na                                         // bar_index of the day's first bar (lines start here)
// drawings placed by bar_index are anchored through `time`, so lines that start at the day's first bar need its
// history: a 1-minute trading day is ~1,380 bars, far past the buffer Pine sizes on its own
max_bars_back(time, 5000)
var int   dK = na
var int   pK = na
var int   dT = 6
if dSt
    pK := dK
    dK := key
    dO := open
    dH := high
    dL := low
    dX := bar_index
    dT := dayType(key, pK)
else if iwin and not na(dO)
    dH := math.max(dH, high)
    dL := math.min(dL, low)
if iwin and not na(dO)
    dC := close

// trading-day (18:00) and RTH trackers for the model levels and the clock
int  tdK   = anchorKey(0, time)
bool tdSt  = tdK != tdK[1]
var float tdO  = na
var float tdH  = na
var float tdL  = na
var float ptdH = na
var float ptdL = na
var int   tdX  = na
var int   tdPK = na
if tdSt
    tdPK := tdK[1]
    ptdH := tdH
    ptdL := tdL
    tdO  := open
    tdH  := high
    tdL  := low
    tdX  := bar_index
else
    tdH := math.max(nz(tdH, high), high)
    tdL := math.min(nz(tdL, low), low)
bool rthSt = mod >= 570 and mod < 975 and (mod[1] < 570 or mod[1] >= 975 or calK != calK[1])
var float rthC  = na
var float rH    = na
var float rL    = na
var float gapPC = na
var float gapCE = na
var float rthO  = na
var float tgGap = na
var float tgPct = na
var int   tgKey = na
if rthSt
    rthO  := open
    tgKey := calK
    tgGap := na(rthC) ? na : open - rthC
    tgPct := na(rthC) or rthC == 0 ? na : (open / rthC - 1) * 100
    gapPC := rthC
    gapCE := na(rthC) ? na : (rthC + open) / 2
    rH    := high
    rL    := low
else if mod >= 570 and mod < 975
    rH := math.max(rH, high)
    rL := math.min(rL, low)
if mod >= 570 and mod < 975
    rthC := close
// the month so far, today included (the month-to-date high and low)
float mHi = math.max(nz(mtH, tdH), tdH)
float mLo = math.min(nz(mtL, tdL), tdL)
bool recent = time > timenow - markD * 86400000
// event-day records the chart itself finds; where they exist they take precedence over the built-in ones, and they
// keep the tally current after the built-in history ends
var array<int>   LTd = array.new<int>()
var array<int>   LTt = array.new<int>()
var array<int>   LTr = array.new<int>()
var array<float> LTg = array.new<float>()
var array<float> LTp = array.new<float>()
var int   prvTdO_k = na
var float prvTdO   = na
var int   prvTdPK  = na
int  talEnd = isES ? TAL_END_ES : isNQ ? TAL_END_NQ : 0
if tdSt and not na(prvTdO) and prvTdO_k == tdK[1] and talIs(tdK[1], prvTdPK)
    bool rOk = tgKey == tdK[1] and not na(rthO)
    LTd.push(tdK[1])
    LTt.push(int(math.sign(close[1] - prvTdO)))
    LTr.push(rOk ? int(math.sign(rthC - rthO)) : 0)
    LTg.push(rOk ? tgGap : na)
    LTp.push(rOk ? tgPct : na)
if tdSt
    prvTdO   := open
    prvTdO_k := tdK
    prvTdPK  := tdPK
var float dxTdO = na
if tdSt
    dxTdO := dxL[1]
varip int beat = 0
if barstate.isrealtime
    beat += 1

// ═══════════════════════════════════════════════════════════════ Fed odds (CBOT 30-day fed funds futures)
// The same steps as CME FedWatch. A ZQ contract settles to 100 − the month's average effective fed funds rate. A decision
// takes effect the next day, so a meeting on day d of an N-day month splits it d / N − d (chaining rule: see fdRates). (end − start) ÷ 25bp gives the odds of the two nearest move sizes, and later meetings combine as a
// probability tree. Checked on CME's own FedWatch page for 12 Oct 2026 (ZQ prices and odds for eight meetings): within
// 0.06 percentage points everywhere.
// Seventeen calendar months from the one before the last bar's month, fixed when the script loads, so the same contracts
// are requested on every bar.
FDN = 17
var int fdY = year(last_bar_time, TZ)
var int fdM = month(last_bar_time, TZ)
fdYM(int i) =>
    int t = fdY * 12 + fdM - 2 + i
    [int(math.floor(t / 12)), t % 12 + 1]
fdTk(int i) =>
    [y, m] = fdYM(i)
    fdRoot + str.substring("FGHJKMNQUVXZ", m - 1, m) + str.tostring(y)
fdDim(int y, int m) => m == 2 ? (y % 4 == 0 ? 29 : 28) : m == 4 or m == 6 or m == 9 or m == 11 ? 30 : 31
fdDay(int y, int m) =>
    int d = 0
    for k in FO
        if int(k / 10000) == y and int(k / 100) % 100 == m
            d := k % 100
    d
string fdTf = timeframe.isintraday ? timeframe.period : "D"
// the seventeen ZQ months, one dynamic request each (Pine v6 runs request.security() inside loops)
// each month's price on the previous bar (rolled back with the bar like any var)
var array<float> fdZp = array.new<float>(FDN, na)
array<float> fdZ = array.new<float>(FDN, na)
for i = 0 to FDN - 1
    fdZ.set(i, request.security(fdTk(i), fdTf, close, ignore_invalid_symbol = true))
// end-of-day prices of the last six trading days (FDN per day, oldest first), and the 13:59 prices on a decision day
var array<float> fdH   = array.new<float>()
var array<float> fd14  = array.new<float>(FDN, na)
var int          fd14K = na
if tdSt and not na(fdZp.get(2))
    for v in fdZp
        fdH.push(v)
    while fdH.size() > 6 * FDN
        fdH.shift()
if FO.includes(calK) and mod >= 840 and (mod[1] < 840 or calK[1] != calK)
    fd14  := fdZp.copy()
    fd14K := calK
fdZp := fdZ.copy()

// the grid's calendar, worked out once: meeting day (0 = none), days in the month, meeting key (yyyymmdd)
var array<int> FMD = array.new<int>()
var array<int> FND = array.new<int>()
var array<int> FKY = array.new<int>()
if barstate.isfirst
    for i = 0 to FDN - 1
        [y, m] = fdYM(i)
        int d = fdDay(y, m)
        FMD.push(d)
        FND.push(fdDim(y, m))
        FKY.push(y * 10000 + m * 100 + d)
// start and end rate (%) of every meeting month in the grid, and the grid's meeting keys
// CME's chaining (checked on its 12 Oct 2026 screen to 0.06 pp): the end rate comes from the next month (its average when
// it has no meeting, else its start solved from its own contract, chained back from the next month without a meeting);
// the start is the prior month's average when that month has no meeting, else solved from the meeting month itself
fdRates(array<float> Z) =>
    array<float> A = array.new<float>(FDN, na)
    for i = 0 to FDN - 1
        if Z.size() > i
            float p = Z.get(i)
            A.set(i, na(p) ? na : 100.0 - p)
    array<float> S  = array.new<float>(FDN, na)
    array<float> E  = array.new<float>(FDN, na)
    array<float> SS = array.new<float>(FDN, na)
    for i = FDN - 1 to 0
        int   d = FMD.get(i)
        float a = A.get(i)
        if d > 0 and not na(a)
            float en = na
            if i < FDN - 1
                en := FMD.get(i + 1) == 0 ? A.get(i + 1) : SS.get(i + 1)
            if not na(en)
                E.set(i, en)
                SS.set(i, (a * FND.get(i) - en * (FND.get(i) - d)) / d)
    for i = 0 to FDN - 1
        int   d = FMD.get(i)
        float a = A.get(i)
        if d > 0 and not na(a)
            float st = SS.get(i)
            if i > 0
                if FMD.get(i - 1) == 0 and not na(A.get(i - 1))
                    st := A.get(i - 1)
            S.set(i, st)
            if na(E.get(i)) and not na(st) and FND.get(i) > d
                E.set(i, (a * FND.get(i) - st * d) / (FND.get(i) - d))
    [S, E, FKY]
// one meeting: the two nearest move sizes (in 25bp steps) and their odds
fdNode(float dl) =>
    float st = dl / 0.25
    float k  = math.floor(math.abs(st))
    float r  = math.abs(st) - k
    int   sg = st >= 0 ? 1 : -1
    [int(sg * k), int(sg * (k + 1)), 1.0 - r, r]
// the tree: odds over the total change (−20 … +20 steps) after one more meeting
fdStep(array<float> p, float dl) =>
    [k1, k2, w1, w2] = fdNode(dl)
    array<float> q = array.new<float>(41, 0.0)
    for x = 0 to 40
        float v = p.get(x)
        if v > 0
            int a = x + k1
            int b = x + k2
            if a >= 0 and a <= 40
                q.set(a, q.get(a) + v * w1)
            if b >= 0 and b <= 40
                q.set(b, q.get(b) + v * w2)
    q
// the next (up to) four meetings: keys, expected rate after each (%), the most likely total step and its odds, the next
// meeting's two outcomes and odds, the current target range's lower bound and the rate now
fdCalc(array<float> Z, int today, bool after) =>
    [S, E, KY] = fdRates(Z)
    array<int>   K  = array.new<int>()
    array<float> EA = array.new<float>()
    array<int>   MK = array.new<int>()
    array<float> MP = array.new<float>()
    float base = na
    float lo0  = na
    int   k1   = na
    int   k2   = na
    float w1   = na
    float w2   = na
    array<float> P = array.new<float>(41, 0.0)
    P.set(20, 1.0)
    for i = 0 to FDN - 1
        int ky = KY.get(i)
        if ky % 100 > 0 and (ky > today or (ky == today and not after)) and K.size() < 4
            float s = S.get(i)
            float e = E.get(i)
            if na(s) or na(e)
                break
            if K.size() == 0
                base := s
                lo0  := math.floor((s + 0.0001) / 0.25) * 0.25
                [a1, a2, b1, b2] = fdNode(e - s)
                k1 := a1
                k2 := a2
                w1 := b1
                w2 := b2
            P := fdStep(P, e - s)
            int   bk = 20
            float bp = 0.0
            for x = 0 to 40
                if P.get(x) > bp
                    bp := P.get(x)
                    bk := x
            K.push(ky)
            EA.push(e)
            MK.push(bk - 20)
            MP.push(bp)
    [K, EA, MK, MP, k1, k2, w1, w2, lo0, base]
fdWord(int k) => na(k) ? "—" : k == 0 ? "hold" : k < 0 ? "cut " + str.tostring(-25 * k) : "hike " + str.tostring(25 * k)
fdRng(float lo0, int k) => na(lo0) or na(k) ? "—" : str.tostring((lo0 + 0.25 * k) * 100, "0") + "–" + str.tostring((lo0 + 0.25 * (k + 1)) * 100, "0")
fdOdd(int k, int a1, int a2, float b1, float b2) => na(k) or na(a1) ? na : (k == a1 ? b1 : 0.0) + (k == a2 ? b2 : 0.0)
fdSg(float v, string f) => na(v) ? "—" : (v >= 0 ? "+" : "−") + str.tostring(math.abs(v), f)
fdDate(int k) => str.upper(str.format_time(keyTime(k), "dd MMM", TZ))
fdMv(int k, float lo) => (k == 0 ? "hold " : k < 0 ? "cut " : "hike ") + fdRng(lo, k)
cFd = cAcF

// ═══════════════════════════════════════════════════════════════ FOMC stages (Vizard)
// Stage 1 = 14:00 open → 14:29 close (the statement); stage 2 = 14:30 open → 16:14 close (press conference to the RTH close).
// long ES / NQ texts: one template, the numbers that differ filled in once at load ({0}, {1}, … ← the |-separated values)
fillT(string t, string v) =>
    string out = t
    array<string> p = str.split(v, "|")
    for i = 0 to p.size() - 1
        out := str.replace_all(out, "{" + str.tostring(i) + "}", p.get(i))
    out
// Shock cone: typical distance from the 14:00 open by 5-minute step to 16:15 (ADR20 ×1000): up 50% · up 80% · down 50% · down 80%, FOMC days 2018–26
CONE_NQ = "909G9M9W9W9W9k:(:?:U:Z:^:o;(;(;(;(;(;,;,;.;4;;;<;O;`;`:T:r:r;m;s;t;t<,<^=<=L=]=i=q=q=q=z=z={={={={={>#>#>G>Z8s8~9+919<9J9W9Z9^9^9|:,:5:6:A:A:A:E:M:[:[:|;0;0;5;X;]:^:v;:;=;F;F<.<|=&"
     + "=G=[>+>+>+>+>;>;>N?'?B?E?U?q@F@e@n@n"
CONE_ES = "9?9D9F9d9d9k9t:,:c:l;';';,;,;,;,;,;,;1;1;1;1;1;=;=;=;@;!;?;W;d;d;d;n<4<U=B=R=V=r>O>W>c?%?,?1?1?1?1?1?1?1?1?19(949;9F9N9N9V9m:&:):,:/:::;:S:S:j:w;B;R;j;p;p;q<$<$<$:e:v;7;V;];]<.<^=9"
     + "=g>/>N>_>f>o?3?_?_@&@=@gA8AIAjB7B7B7"
var string VZT_GF = fillT("FOMC morning RTH gap (prior 16:14 close → 09:30 open) traded back through the prior close by 16:14 on {0}% of {1} FOMC days vs {2}% on ordinary days (2018–24 {3}% vs {4}%, 2025–26 {5}% vs {6}%; held). Before 14:00 only {7}% vs {8}%: the extra fills come after the statement. Don't expect the morning gap to stay open.", isES ? "76|67|60|76|60|77|62|52|56" : "74|68|61|69|62|92|57|56|58")
// The stages card's statistics (HYDRA FOMC study: 67 FOMC days 2018–26 per symbol, read at 13:59, in ADR20 of the trading day)
//  0–3   |stage 1| median and 80th percentile: SEP meetings, then the others
//  4–9   |stage 2| median and 80th percentile with price in the month's discount (bottom quarter), middle, premium (top quarter)
//  10–15 the range after 14:00 (14:00–16:14 high − low), same groups
//  16–21 new day high and new day low after 14:00 (%): above PDH, inside the prior day, below PDL
//  22–27 the same after a move since 18:00 above +0.4 ADR, within ±0.4, below −0.4
var array<float> VS = parseStats(isES ? "0.29,0.46,0.10,0.26,0.52,1.08,0.51,0.95,0.29,0.66,1.48,1.76,0.95,1.43,0.77,1.30,93,29,60,74,50,50,83,25,65,69,33,83" : "0.29,0.46,0.08,0.20,0.48,0.90,0.47,0.91,0.29,0.50,1.38,1.46,0.90,1.35,0.74,1.02,83,28,56,61,75,50,78,22,63,63,33,33")
var string VZT_HD = "The FOMC decision day in three parts. SETUP: where price stands against the month's range, the month's open, the prior day and the 18:00 open, and DXY's last 4 weeks (live, then fixed at 13:59). EXPECT: how far FOMC days with that setup moved, 2018–26 (67 meetings, " + symR + " 1-minute data), at today's ADR20. LIVE: today's stages against DXY. Green key = held in 2018–24 and again in 2025–26 (p < 0.05); every other figure describes, it does not signal. No 13:59 feature called the direction after 14:00 (HYDRA: none survived the locked 2025–26 test)."
var string VZT_MON = fillT("FOMC days 2018–26 by the month's position at 13:59 (discount = bottom quarter · middle · premium = top quarter; n {0}): |stage 2| median {1} · {2} · {3} ADR, range after 14:00 {4} · {5} · {6} ADR, new day low after 14:00 {7} · {8} · {9}. A stretched month into the statement (discount) came with the biggest reactions, a premium with the smallest. The EXPECT rows use this group.", isES ? "7 · 26 · 34|0.52|0.51|0.29|1.48|0.95|0.77|100%|62%|56%" : "7 · 29 · 31|0.48|0.47|0.29|1.38|0.90|0.74|71%|52%|45%")
var string VZT_MO = isES ? "Over / under = more than 1 ADR from the month's open at 13:59. ES, held: over it (n 33) |stage 2| ran 0.25 vs 0.53 ADR and the range after 14:00 0.67 vs 1.12; under it (n 8) the next NY AM (09:30–11:00) closed up 88% vs 43%." : "Over / under = more than 1 ADR from the month's open at 13:59. NQ: over it (n 31) |stage 2| ran 0.27 vs 0.47 ADR (p 0.08, not held); under it (n 9) no lean."
var string VZT_PD = fillT("Right: how often the day made a new high (H) and a new low (L) after 14:00, FOMC days 2018–26 with price at 13:59 above PDH (n {0}) H {1}% L {2}% · inside the prior day (n {3}) H {4}% L {5}% · below PDL (n {6}) H {7}% L {8}%. Above PDH the day's low usually held (p {9}); too few 2025–26 cases to count as held.", isES ? "14|93|29|47|60|74|6|50|50|0.003" : "18|83|28|41|56|61|8|75|50|0.02")
var string VZT_18 = fillT("Move since the 18:00 open at 13:59, in ADR; strong = beyond ±0.4. Right: new day high (H) and low (L) after 14:00. Strong up (n {0}) H {1}% L {2}% · within (n {3}) H {4}% L {5}% · strong down (n {6}) H {7}% L {8}%. After a strong run into 14:00 the low rarely broke (p {9}); too few 2025–26 cases to count as held.", isES ? "12|83|25|49|65|69|6|33|83|0.003" : "18|78|22|46|63|63|3|33|33|0.005")
var string VZT_D4 = fillT("DXY's change over the last 20 trading days at 13:59, in DXY's ADR20. FOMC days Feb 2023 – Jul 2026 with DXY up over 4 weeks (n 11): stage 2 closed up 27% vs {0}% otherwise (2023–24 29%, 2025–26 25%; p {1}). Consistent, not significant: no ✓. Right: the stage-2 up rate on today's side.", isES ? "61|0.08" : "65|0.05")
var string VZT_E1 = fillT("|Stage 1| (14:00 open → 14:29 close): median and 80th percentile of FOMC days 2018–26 at today's ADR20. SEP meetings (March, June, September, December: new dots and projections) moved {0} vs {1} ADR at the median{2}", isES ? "0.29|0.10|; held (2018–24 0.33 vs 0.09, 2025–26 0.14 vs 0.11)." : "0.29|0.08| (p < 0.001, but 2025–26 only 0.06: not held).")
VZT_E2 = "|Stage 2| (14:30 open → 16:14 close) and the range after 14:00 (14:00–16:14 high − low): median and 80th percentile of FOMC days 2018–26 with price in the same part of the month at 13:59, at today's ADR20. Sizes for stops and targets: which way it goes did not hold on either symbol."
VZT_LV = "Today's stage so far (points from its open) and DXY's move in the same window, in DXY's ADR20. ×typ = against the EXPECT median. ⇄ = the other way to DXY, ⇉ = the same way. BIG = DXY has moved at least 0.25 of its ADR20 in stage 1, or 0.5 in stage 2 (about its median move): the other-way rate below applies."
var string VZT_DR = fillT("{0} against DXY futures in the same window, FOMC days Feb 2023 – Jul 2026. Stage 1 with DXY ≥ 0.25 ADR20: other way {1}% (n {2}; 2023–24 {3}%, 2025–26 {4}%; held) vs {5}% when smaller, and {0}'s |stage 1| ran {6} ADR vs 0.06. Stage 2 with DXY ≥ 0.5 ADR20: {7}% (n {8}; {9}% · {10}%; held) vs 73%. It confirms the move, it does not call it: DXY's first 10 minutes did not lead the rest of the stage, and stage 1 did not predict stage 2.", isES ? "ES|100|15|100|100|64|0.26|93|14|100|86" : "NQ|86|14|90|75|57|0.25|85|13|100|67")
VZV_GF = isES ? "76%" : "74%"
VZB_GF = isES ? "60%" : "61%"
VZV_D1 = isES ? "100%" : "86%"
VZB_D1 = isES ? "64%" : "57%"
VZV_D2 = isES ? "93%" : "85%"
bool vzF   = FO.includes(calK)
// the week's open
var int   wkX  = na
var float wkOp = na
if ta.change(time("W")) != 0
    wkX  := bar_index
    wkOp := open
// the setup at price c with the day's high h and low l so far: position in the month's range (0–1), distance from the
// month's open, beyond the prior day's range (ADR; 0 = inside), move since 18:00 (ADR), ADR20 (pts), DXY's 4 weeks (its ADR20)
ctxOf(float c, float h, float l, float dx) =>
    float a  = ADRtd * tdO
    float mh = math.max(nz(mtH, h), h)
    float ml = math.min(nz(mtL, l), l)
    float p  = mh > ml ? (c - ml) / (mh - ml) : na
    float m  = a > 0 ? (c - mtO) / a : na
    float d  = na(ptdH) or not (a > 0) ? na : c > ptdH ? (c - ptdH) / a : c < ptdL ? (c - ptdL) / a : 0.0
    float s  = a > 0 ? (c - tdO) / a : na
    float x  = dxA > 0 ? (dx - dx20) / dxA : na
    [p, m, d, s, a, x]
// stage prices on the FOMC day (and DXY at the same moments), and the setup fixed at 13:59
var int   vzK  = na
var float s14O = na
var int   s14X = na
var float s30O = na
var int   s30X = na
var float s1C  = na
var float s2C  = na
var float x14  = na
var float x30  = na
var float x1C  = na
var float x2C  = na
var int   k59  = na
var float cxP  = na
var float cxM  = na
var float cxD  = na
var float cxS  = na
var float cxA  = na
var float cxX  = na
bool at14 = vzF and mod >= 840 and mod < 870 and (mod[1] < 840 or calK[1] != calK) and nz(vzK) != calK
if at14
    vzK  := calK
    s14O := open
    s14X := bar_index
    x14  := dxL[1]
    s30O := na
    s30X := na
    s1C  := na
    s2C  := na
    x30  := na
    x1C  := na
    x2C  := na
    [p_, m_, d_, q_, a_, z_] = ctxOf(close[1], tdH[1], tdL[1], dxL[1])
    k59 := calK
    cxP := p_
    cxM := m_
    cxD := d_
    cxS := q_
    cxA := a_
    cxX := z_
bool at30 = vzK == calK and na(s30O) and mod >= 870 and mod < 975
if at30
    s30O := open
    s30X := bar_index
    s1C  := close[1]
    x30  := dxL[1]
    x1C  := dxL[1]
if vzK == calK and not na(s30O) and na(s2C) and mod >= 975
    s2C := close[1]
    x2C := dxL[1]
// the morning gap on the FOMC day (filled?)
var int gfT = na
if rthSt
    gfT := na
if vzF and tgKey == calK and mod >= 570 and mod < 975 and na(gfT) and not na(gapPC) and rthO != gapPC
    if (rthO > gapPC and low <= gapPC) or (rthO < gapPC and high >= gapPC)
        gfT := time
// the stages card's table
var table TV  = na
var int   tvO = 0
SGR = layI == "Mobile" ? 7 : 18
if barstate.isfirst and showSg
    tvO := sgPos == "Top left" or sgPos == "Top center" or (sgPos == "Top right" and sgOn == "Indicator pane") ? 1 : 0
    if sgOn == "Price chart"
        TV := table.new(posOf(sgPos), 5, SGR + tvO, bgcolor = #00000000, frame_width = 0, border_width = 0, force_overlay = true)
    else
        TV := table.new(posOf(sgPos), 5, SGR + tvO, bgcolor = #00000000, frame_width = 0, border_width = 0)
    if tvO == 1
        TV.cell(0, 0, "", height = sgOn == "Price chart" ? 3.5 : 7.0, bgcolor = #00000000)
        TV.merge_cells(0, 0, 4, 0)
    TV.merge_cells(1, tvO, 3, tvO)
var array<float> CN = unpackMilli(isES ? CONE_ES : CONE_NQ)
cnAt(int sr, int k) => CN.get(sr * 27 + k)
// one band of the shock cone as a closed shape, from 14:00 to step kEnd (5-minute steps), around price o (ADR a in price)
coneBand(int dk, float o, float a, int su, int sd, int kEnd, color fc, color lc) =>
    array<chart.point> pts = array.new<chart.point>()
    pts.push(chart.point.from_time(keyAt(dk, 840), o))
    for k = 0 to kEnd
        pts.push(chart.point.from_time(keyAt(dk, 845 + 5 * k), o + cnAt(su, k) * a))
    for k = kEnd to 0
        pts.push(chart.point.from_time(keyAt(dk, 845 + 5 * k), o - cnAt(sd, k) * a))
    polyline.new(pts, curved = false, closed = true, xloc = xloc.bar_time, line_color = lc, fill_color = fc, force_overlay = true)
var array<polyline> VPC = array.new<polyline>()
vzSg(float v) => na(v) ? "—" : (v >= 0 ? "+" : "−") + str.tostring(math.abs(v), format.mintick)
vzAr(float v) => na(v) or v == 0 ? "·" : v > 0 ? "▲" : "▼"
// Level lines and their end labels that run to a time later today (16:14, 17:00, the NFP release) are cut at the latest
// bar and grow with it.
var array<line>  GL  = array.new<line>()
var array<int>   GLE = array.new<int>()
var array<label> GT  = array.new<label>()
var array<int>   GTE = array.new<int>()
trimL(line l, int e) =>
    if e > time
        l.set_x2(time)
        GL.push(l)
        GLE.push(e)
    l
trimT(label t, int e) =>
    if e > time
        t.set_x(time)
        GT.push(t)
        GTE.push(e)
    t

// ═══════════════════════════════════════════════════════════════ Model structure on the price chart
bool vF  = FO.includes(calK)
bool vOn = showStr and recent
if vOn and tdSt and FO.includes(tdK) and not na(ptdH)
    trimL(line.new(time, ptdH, keyAt(tdK, 1019), ptdH, xloc = xloc.bar_time, color = cLvl, width = 1, style = line.style_dashed, force_overlay = true), keyAt(tdK, 1019))
    trimL(line.new(time, ptdL, keyAt(tdK, 1019), ptdL, xloc = xloc.bar_time, color = cLvl, width = 1, style = line.style_dashed, force_overlay = true), keyAt(tdK, 1019))
    trimT(label.new(keyAt(tdK, 1019), ptdH, "D1 high", xloc = xloc.bar_time, color = #00000000, textcolor = cLvl, style = label.style_label_left, size = size.tiny, tooltip = "FOMC day 1 high (trading day). The decision day took it 67% of the time vs 56% for any next day.", force_overlay = true), keyAt(tdK, 1019))
    trimT(label.new(keyAt(tdK, 1019), ptdL, "D1 low", xloc = xloc.bar_time, color = #00000000, textcolor = cLvl, style = label.style_label_left, size = size.tiny, tooltip = "FOMC day 1 low (trading day). The decision day took it 52% of the time vs 44% for any next day.", force_overlay = true), keyAt(tdK, 1019))
if vOn and vF and mod <= 840 and mod + tfM > 840
    line.new(keyAt(calK, 840), close, keyAt(calK, 840), close + syminfo.mintick, xloc = xloc.bar_time, extend = extend.both, color = color.new(cLvl, 50), style = line.style_dotted, force_overlay = true)
    trimT(label.new(keyAt(calK, 840), high, "statement", xloc = xloc.bar_time, color = #00000000, textcolor = cGh, style = label.style_label_down, size = size.tiny, force_overlay = true), keyAt(calK, 840))
if vOn and vF and mod <= 870 and mod + tfM > 870
    line.new(keyAt(calK, 870), close, keyAt(calK, 870), close + syminfo.mintick, xloc = xloc.bar_time, extend = extend.both, color = color.new(cLvl, 50), style = line.style_dotted, force_overlay = true)
    trimT(label.new(keyAt(calK, 870), high, "press conf.", xloc = xloc.bar_time, color = #00000000, textcolor = cGh, style = label.style_label_down, size = size.tiny, force_overlay = true), keyAt(calK, 870))
if vOn and vF and rthSt and not na(gapPC)
    trimL(line.new(time, gapPC, keyAt(calK, 974), gapPC, xloc = xloc.bar_time, color = color.new(cLvl, 40), style = line.style_dotted, force_overlay = true), keyAt(calK, 974))
    trimL(line.new(time, gapCE, keyAt(calK, 974), gapCE, xloc = xloc.bar_time, color = color.new(cLvl, 20), style = line.style_dotted, force_overlay = true), keyAt(calK, 974))
    trimT(label.new(keyAt(calK, 974), gapCE, "gap 50%", xloc = xloc.bar_time, color = #00000000, textcolor = cLvl, style = label.style_label_left, size = size.tiny, tooltip = "RTH gap 50% = (prior 16:14 close + 09:30 open) ÷ 2. FOMC days filled the full gap 74% of the time vs 63%.", force_overlay = true), keyAt(calK, 974))
bgcolor(vOn and vF and mod >= 840 and mod < 870 ? cWin : vOn and vF and mod >= 870 and mod < 975 ? color.new(cWin, math.min(100, color.t(cWin) + 4)) : na, title = "Statement and press conference", force_overlay = true)
// FOMC day: the 14:00 and 14:30 opens to the RTH close, and fixed snapshots of the displacement at 14:00 and 14:30
if vOn and showWO and at14
    trimL(line.new(time, open, keyAt(calK, 974), open, xloc = xloc.bar_time, color = color.new(cGh, 15), width = 1, force_overlay = true), keyAt(calK, 974))
if vOn and showWO and at30
    trimL(line.new(time, open, keyAt(calK, 974), open, xloc = xloc.bar_time, color = color.new(cGh, 35), width = 1, style = line.style_dashed, force_overlay = true), keyAt(calK, 974))
if vOn and showSnp and at14 and tgKey == calK and not na(rthO)
    label.new(bar_index - 1, open, "14:00\n" + vzSg(open - rthO) + " vs 09:30\n" + vzSg(open - wkOp) + " vs week open", color = color.new(cGh, 25), textcolor = #ffffff, style = label.style_label_right, size = size.tiny, tooltip = "Snapshot at the statement (14:00 open), fixed: distance from today's 09:30 open and from the week's open (Sunday 18:00).", force_overlay = true)
if vOn and showSnp and at30 and tgKey == calK and not na(rthO) and not na(s14O)
    label.new(bar_index, low, "14:30 · S1 " + vzSg(close[1] - s14O) + "\n" + vzSg(open - rthO) + " vs 09:30\n" + vzSg(open - wkOp) + " vs week open", color = color.new(cGh, 45), textcolor = #ffffff, style = label.style_label_up, size = size.tiny, tooltip = "Snapshot at the press conference (14:30 open), fixed: stage 1's move (14:00 → 14:29 close), and the distance from today's 09:30 open and from the week's open.", force_overlay = true)
// FOMC day: the full shock cone, drawn once the day's 16:15 bar prints
if vOn and showCone and vzK == calK and not na(s14O) and not na(ADRtd) and mod >= 975 and mod[1] < 975
    for cb = 0 to 1
        coneBand(calK, s14O, ADRtd * s14O, 1 - cb, 3 - cb, 26, color.new(cGh, cb == 0 ? 91 : 85), cb == 0 ? color.new(cGh, 72) : #00000000)
// FOMC day: the RTH gap in eighths over NY AM, 50% bold, the quarter next to the open shaded
if vOn and showOct and rthSt and vF and not na(gapPC) and rthO != gapPC
    float gp = rthO - gapPC
    int   te = keyAt(calK, 660)
    line  l6 = na
    line  l8 = na
    for k = 0 to 8
        line l = trimL(line.new(time, gapPC + gp * k / 8, te, gapPC + gp * k / 8, xloc = xloc.bar_time, color = k == 4 ? cLvl : k >= 6 ? color.new(cOq, 10) : color.new(cLvl, k == 0 ? 30 : 65), style = k == 4 ? line.style_dashed : line.style_dotted, width = k == 4 ? 2 : 1, force_overlay = true), te)
        if k == 6
            l6 := l
        if k == 8
            l8 := l
    linefill.new(l6, l8, cOq)
    trimT(label.new(te, gapPC + gp * 0.875, "open-side ¼", xloc = xloc.bar_time, color = #00000000, textcolor = color.new(cOq, 0), style = label.style_label_left, size = size.tiny, tooltip = "The quarter of this morning's RTH gap next to the 09:30 open. " + VZT_GF, force_overlay = true), te)
    trimT(label.new(te, gapPC + gp * 0.5, "gap 50%", xloc = xloc.bar_time, color = #00000000, textcolor = cLvl, style = label.style_label_left, size = size.tiny, tooltip = VZT_GF, force_overlay = true), te)
bgcolor(vOn and showOct and vF and mod >= 570 and mod < 660 ? color.new(cOq, math.min(100, color.t(cOq) + 14)) : na, title = "NY AM, FOMC day", force_overlay = true)

if GL.size() > 0
    for i = GL.size() - 1 to 0
        int e = GLE.get(i)
        GL.get(i).set_x2(math.min(e, time))
        if time >= e
            GL.remove(i)
            GLE.remove(i)
if GT.size() > 0
    for i = GT.size() - 1 to 0
        int e = GTE.get(i)
        GT.get(i).set_x(math.min(e, time))
        if time >= e
            GT.remove(i)
            GTE.remove(i)

// ═══════════════════════════════════════════════════════════════ Event clock (indicator pane)
bool clkTF = timeframe.isintraday and timeframe.in_seconds() <= 3600
bool clkGo = clkOn and clkTF
bool clkR  = clkMet == "Range"
int  mSel  = clkR ? 0 : 1
NCK = 3
REL = "840,870"
var int  ckI   = NCK - 1                                     // today's baseline: this event if today is one, else normal
var bool ckEv  = false
var int  ckEvI = 0                                           // this indicator's event for today / the next one
if tdSt or barstate.isfirst
    [k_, now_, d_] = ownProfile(tdK, tdPK, tdK)
    ckEv  := now_
    ckEvI := ownCk(k_)
    ckI   := now_ ? ownCk(k_) : NCK - 1
int   elM  = (mod - 1080 + 1440) % 1440
float eEnd = math.min(1380.0, elM + tfM)
int   jB   = math.min(45, math.max(0, int(math.ceil(eEnd / 30.0)) - 1))
float fB   = math.max(0.0, math.min(1.0, (eEnd - 30.0 * jB) / 30.0))
float scP  = tdO * ADRtd
float vPts = clkR ? tdH - tdL : close - tdO
float vAdr = scP > 0 ? vPts / scP : na
float q25B = ckAt(ckI, mSel, 1, jB, fB)
float q75B = ckAt(ckI, mSel, 3, jB, fB)
string stB = na(vAdr) ? "" : vAdr > q75B ? "Above" : vAdr < q25B ? "Below" : "Inside"
bool  isTd = anchorKey(0, last_bar_time) == tdK
color liveC = stB == "Above" ? cHot : stB == "Below" ? cCold : cTx
plot(clkGo and isTd and not tdSt ? vPts : na, "Today", color = liveC, linewidth = 3, style = plot.style_linebr, display = display.all - display.status_line)
plot(clkGo and kPast and not isTd and not tdSt ? vPts : na, "Earlier days", color = color.new(cSub, 75), linewidth = 1, style = plot.style_linebr, display = display.all - display.status_line)
// invisible headroom: with the clock card at the top of the pane, the scale leaves room above the bands for it
bool  ckTop = (showCk and ckOn == "Indicator pane" and str.startswith(ckPos, "Top")) or (showMap and str.startswith(mapPos, "Top"))
float hdrm  = clkGo and scP > 0 ? math.max(ck(ckI, mSel, 4, 45), ck(NCK - 1, mSel, 4, 45)) * scP * (ckTop ? 1.75 : 1.1) : na
plot(hdrm, "Headroom", color = #00000000, editable = false, display = display.pane)

var array<polyline> KP = array.new<polyline>()
var array<line>     KL = array.new<line>()
var array<label>    KT = array.new<label>()
kPath(int i, int m, int k, int t0, float sc, color lc, int lw, string ls) =>
    array<chart.point> pts = array.new<chart.point>()
    pts.push(chart.point.from_time(t0, 0.0))
    for j = 0 to 45
        pts.push(chart.point.from_time(t0 + (j + 1) * 1800000, ck(i, m, k, j) * sc))
    polyline.new(pts, curved = false, closed = false, xloc = xloc.bar_time, line_color = lc, line_width = lw, line_style = ls)
kBand(int i, int m, int kUp, int kDn, int t0, float sc, color fc) =>
    array<chart.point> pts = array.new<chart.point>()
    pts.push(chart.point.from_time(t0, 0.0))
    for j = 0 to 45
        pts.push(chart.point.from_time(t0 + (j + 1) * 1800000, ck(i, m, kUp, j) * sc))
    for j = 45 to 0
        pts.push(chart.point.from_time(t0 + (j + 1) * 1800000, ck(i, m, kDn, j) * sc))
    polyline.new(pts, curved = false, closed = true, xloc = xloc.bar_time, line_color = #00000000, fill_color = fc)

drawCore1() =>
    if barstate.islast
        for p in KP
            p.delete()
        for l in KL
            l.delete()
        for t in KT
            t.delete()
        KP.clear()
        KL.clear()
        KT.clear()
        if clkGo and scP > 0
            int   t0  = keyAt(addDays(tdK, -1), 1080)
            int   tE  = t0 + 46 * 1800000
            color ce  = ckEv ? cGh : cSub
            int   iR  = ckEv ? NCK - 1 : ckEvI
            color cR  = ckEv ? cMu : color.new(cGh, 25)
            if kBands
                KP.push(kBand(ckI, mSel, 4, 0, t0, scP, color.new(ce, 90)))
                KP.push(kBand(ckI, mSel, 3, 1, t0, scP, color.new(ce, 80)))
            KP.push(kPath(ckI, mSel, 2, t0, scP, ce, 2, line.style_solid))
            KT.push(label.new(tE, ck(ckI, mSel, 2, 45) * scP, ckName(ckI) + " median " + pf(ck(ckI, mSel, 2, 45) * scP), xloc = xloc.bar_time, color = #00000000, textcolor = ce, style = label.style_label_left, size = size.tiny))
            if kRef
                KP.push(kPath(iR, mSel, 2, t0, scP, cR, 1, line.style_dashed))
                KT.push(label.new(tE, ck(iR, mSel, 2, 45) * scP, ckName(iR) + (ckEv ? "" : " (next)") + " " + pf(ck(iR, mSel, 2, 45) * scP), xloc = xloc.bar_time, color = #00000000, textcolor = cR, style = label.style_label_left, size = size.tiny))
            for s in str.split(REL, ",")
                float rm = str.tonumber(s)
                if not na(rm)
                    int tr = keyAt(tdK, int(rm))
                    KL.push(line.new(tr, 0.0, tr, scP, xloc = xloc.bar_time, extend = extend.both, color = color.new(cGh, ckEv ? 30 : 70), style = line.style_dotted))
    true
drawCore1()

// ═══════════════════════════════════════════════════════════════ Drawings right of price (rebuilt on the last bar)
var array<box>   RB = array.new<box>()
var array<line>  RL = array.new<line>()
var array<label> RT = array.new<label>()
clearRight() =>
    for b in RB
        b.delete()
    for l in RL
        l.delete()
    for t in RT
        t.delete()
    RB.clear()
    RL.clear()
    RT.clear()

// ═══════════════════════════════════════════════════════════════ Cards
// Price chart: three cards, each its own table in its own corner: the event tally, the Fed odds and the FOMC stages. Each
// card is an accent stripe, a header bar with a status pill and a tinted body. The clock card (indicator pane by default)
// uses the same style. Five columns: stripe · key · wording · value · comparison.
SC = 5
cBody  = dark ? #161a23 : #f4f6f9
cBody2 = dark ? #1c2130 : #e9edf3
cNeu   = dark ? #3a3f4b : #d1d4dc
cDxc   = cAcD
cPrem  = dark ? #ef5350 : #d32f2f
cDisc  = dark ? #66bb6a : #2e7d32
bool mob = layI == "Mobile"
EV_N = mob ? 6 : 8                    // Full: header · sub · DAY · RTH · GAP · WEEK · MONTH · NEXT; Mobile: header · NOW · DAY · GAP · WK · MO
FD_N = mob ? 1 : 8                    // Fed card: header · sub · 2 odds · 3 path · today / 5D; Mobile: one row
KR   = 5
var table TS  = na
var table TF  = na
var table TK  = na
var int   tsO = 0
var int   tfO = 0
var int   tkO = 0
gapOf(string on, string p) => p == "Top left" or p == "Top center" or (p == "Top right" and on == "Indicator pane")
if barstate.isfirst
    if showEv
        tsO := gapOf("Price chart", crdPos) ? 1 : 0
        TS  := table.new(posOf(crdPos), SC, EV_N + tsO, bgcolor = #00000000, frame_width = 0, border_width = 0, force_overlay = true)
        if tsO == 1
            TS.cell(0, 0, "", height = 3.5, bgcolor = #00000000)
            TS.merge_cells(0, 0, SC - 1, 0)
        TS.merge_cells(1, tsO, 3, tsO)
        if not mob
            TS.merge_cells(2, tsO + EV_N - 1, SC - 1, tsO + EV_N - 1)
    if showFd
        tfO := gapOf("Price chart", fdPos) ? 1 : 0
        TF  := table.new(posOf(fdPos), SC, FD_N + tfO, bgcolor = #00000000, frame_width = 0, border_width = 0, force_overlay = true)
        if tfO == 1
            TF.cell(0, 0, "", height = 3.5, bgcolor = #00000000)
            TF.merge_cells(0, 0, SC - 1, 0)
        if not mob
            TF.merge_cells(1, tfO, 3, tfO)
    if showCk
        tkO := gapOf(ckOn, ckPos) ? 1 : 0
        if ckOn == "Price chart"
            TK := table.new(posOf(ckPos), SC, KR + tkO, bgcolor = #00000000, frame_width = 0, border_width = 0, force_overlay = true)
        else
            TK := table.new(posOf(ckPos), SC, KR + tkO, bgcolor = #00000000, frame_width = 0, border_width = 0)
        if tkO == 1
            TK.cell(0, 0, "", height = ckOn == "Price chart" ? 3.5 : 7.0, bgcolor = #00000000)
            TK.merge_cells(0, 0, SC - 1, 0)
        TK.merge_cells(1, tkO, 3, tkO)
// card cells
tc(table t, int c, int r, string s, color fg, color bg, string tip = "", string ha = text.align_left, bool b = false) =>
    t.cell(c, r, s, text_color = fg, bgcolor = bg, text_size = crdSz, text_halign = ha, tooltip = tip, text_font_family = font.family_monospace, text_formatting = b ? text.format_bold : text.format_none)
stripe(table t, int r, color col) =>
    t.cell(0, r, "", bgcolor = col, width = 0.25)
// card cells are queued (one CRow per row / cell, in call order) and written by cardFlush() at the end of the script:
// Pine expands every helper call into the compiled code, so writing the cells in one place keeps Vizard under the token cap
type CRow
    table  t
    int    k
    int    r
    int    c   = 0
    color  col
    string s1  = ""
    string s2  = ""
    string s3  = ""
    string s4  = ""
    string tip = ""
    bool   b   = false
    color  f1
    color  f2
    string ha  = "left"
var CQ = array.new<CRow>()
cardHead(table t, int r, color col, string title, string tip, string pill, color pfg, color pbg) =>
    CQ.push(CRow.new(t, 1, r, 0, col, title, "", "", pill, tip, false, pfg, pbg))
cardSub(table t, int r, color col, string txt, string a1, string a2) =>
    CQ.push(CRow.new(t, 2, r, 0, col, "", txt, a1, a2))
// key is a ✓ pill when held, else a muted label; value in bold
cardRow(table t, int r, color col, string key, bool held, string lab, string v, string b, string tip, color vfg = na, color bfg = na) =>
    CQ.push(CRow.new(t, 0, r, 0, col, key, lab, v, b, tip, held, vfg, bfg))
cardWide(table t, int r, color col, string key, string txt, string tip, color fg) =>
    CQ.push(CRow.new(t, 3, r, 0, col, key, txt, "", "", tip, false, fg))
tcQ(table t, int c, int r, string s, color fg, color bg, string tip = "", string ha = text.align_left, bool b = false) =>
    CQ.push(CRow.new(t, 4, r, c, na, s, "", "", "", tip, b, fg, bg, ha))
stripeQ(table t, int r, color col) =>
    CQ.push(CRow.new(t, 5, r, 0, col))
// text gauges for the monospace cells
gauge(float frac) =>
    string out = "░░░░░░░░░░"
    if not na(frac)
        int k = int(math.round(math.max(0.0, math.min(1.0, frac)) * 10))
        out := str.repeat("█", k) + str.repeat("░", 10 - k)
    out
// five-cell battery for the mobile card
gauge5(float frac) =>
    string out = "░░░░░"
    if not na(frac)
        int k = int(math.round(math.max(0.0, math.min(1.0, frac)) * 5))
        out := str.repeat("█", k) + str.repeat("░", 5 - k)
    out
meter(float p) =>
    string out = "──────────"
    if not na(p)
        int k = int(math.round(math.max(0.0, math.min(100.0, p)) / 10.0))
        out := str.repeat("─", k) + "●" + str.repeat("─", 10 - k)
    out
octBar(int o) =>
    string out = ""
    for i = 1 to 8
        out += i == o ? "█" : "░"
    out
// where price sits in a range, in octants (1 = bottom eighth … 8 = top eighth)
octOf(float px, float h, float l) => na(h) or na(l) or h <= l ? na : math.min(8, int(math.floor((px - l) / (h - l) * 8)) + 1)
zoneOf(float h, float l) =>
    int    o  = octOf(close, h, l)
    string z  = na(o) ? "—" : o >= 7 ? "PREM" : o <= 2 ? "DISC" : "EQ"
    color  zb = na(o) ? cBody : o >= 7 ? cPrem : o <= 2 ? cDisc : cNeu
    color  zf = na(o) or (o > 2 and o < 7) ? cTx : #ffffff
    [o, z, zb, zf]
zoneTip(int o, float h, float l, string what) =>
    "This " + what + "'s range so far " + pf(l) + " – " + pf(h) + ": price is " + (na(o) ? "—" : p0((close - l) / (h - l))) + " of the way up (octant " + (na(o) ? "—" : str.tostring(o)) + " of 8), " + (na(l) ? "—" : pf(close - l)) + " above the low and " + (na(h) ? "—" : pf(h - close)) + " below the high (right). Top quarter (octants 7–8) = premium, bottom quarter (1–2) = discount. A locator, not a tested signal."
zoneRow(table t, int r, color col, string key, float h, float l, string what) =>
    [o, z, zb, zf] = zoneOf(h, l)
    string tip = zoneTip(o, h, l, what)
    stripeQ(t, r, col)
    tcQ(t, 1, r, key, cMu, cBody, tip, text.align_center)
    tcQ(t, 2, r, octBar(o) + " O" + (na(o) ? "—" : str.tostring(o)), cTx, cBody, tip)
    tcQ(t, 3, r, z, zf, zb, tip, text.align_center, true)
    tcQ(t, 4, r, na(h) ? "—" : "−" + str.tostring(h - close, "0"), cMu, cBody, tip, text.align_center)
// tally accumulator: 0 count · 1 up · 2 down · 3 RTH up · 4 RTH down · 5 gaps · 6 Σgap · 7 Σ|gap| · 8 Σ|gap %| · 9 gaps up
talAcc(array<float> acc, int t_, int r_, float g_, float p_) =>
    acc.set(0, acc.get(0) + 1)
    acc.set(1, acc.get(1) + (t_ > 0 ? 1 : 0))
    acc.set(2, acc.get(2) + (t_ < 0 ? 1 : 0))
    acc.set(3, acc.get(3) + (r_ > 0 ? 1 : 0))
    acc.set(4, acc.get(4) + (r_ < 0 ? 1 : 0))
    if not na(g_)
        acc.set(5, acc.get(5) + 1)
        acc.set(6, acc.get(6) + g_)
        acc.set(7, acc.get(7) + math.abs(g_))
        acc.set(8, acc.get(8) + (na(p_) ? 0.0 : math.abs(p_)))
        acc.set(9, acc.get(9) + (g_ > 0 ? 1 : 0))
// built-in event-day records for the tally (NQ / MNQ and ES / MES; other symbols use the chart's own history)
var array<int>   TEd = array.new<int>()
var array<int>   TEt = array.new<int>()
var array<int>   TEr = array.new<int>()
var array<float> TEg = array.new<float>()
var array<float> TEp = array.new<float>()
if barstate.isfirst
    string src = isES ? TAL_ES : isNQ ? TAL_NQ : ""
    if src != ""
        for rec in str.split(src, ";")
            array<string> f = str.split(rec, ",")
            if f.size() >= 3
                TEd.push(int(str.tonumber(f.get(0))))
                TEt.push(int(str.tonumber(f.get(1))))
                TEr.push(int(str.tonumber(f.get(2))))
                TEg.push(f.size() > 3 ? str.tonumber(f.get(3)) : na)
                TEp.push(f.size() > 4 ? str.tonumber(f.get(4)) : na)

// ═══════════════════════════════════════════════════════════════ Draw (last bar)
drawCore2() =>
    if barstate.islast
        clearRight()
        bool   pend = AN == 2 and mod < 570                      // RTH not open yet: the model sits on the last price
        int    tKey = pend ? calK : dK
        int    today = calK
        [pk, pNow, pDay] = ownProfile(tKey, pend ? dK : pK, today)
        int    mTy  = ownTy(pk)                                  // this indicator's own event, never another event's
        bool   live = pNow and not pend
        bool   hasD = not pend and not na(dO)
        float  O    = hasD ? dO : close
        // ── cards
        string dot = barstate.isrealtime ? (beat % 2 == 0 ? "●" : "○") : "◆"
        int    dd   = na(pDay) ? na : inDays(pDay, today)
        string ev   = typeShort(mTy)
        [n1t, n1k, n2t, n2k] = ownNext(today)
        bool   warn = inDays(LAST_DATE, today) < 60
        // tally of the last N event days (both layouts): this chart's own records first, then built-in ones older than those
        array<float> acc = array.new_float(10, 0.0)
        string seq = ""
        int    d0  = na
        if showEv
            if LTd.size() > 0
                for i = LTd.size() - 1 to 0
                    if acc.get(0) < talN
                        talAcc(acc, LTt.get(i), LTr.get(i), LTg.get(i), LTp.get(i))
                        seq := (LTt.get(i) > 0 ? "▲" : LTt.get(i) < 0 ? "▼" : "·") + seq
                        d0 := LTd.get(i)
            int oldest = LTd.size() > 0 ? LTd.get(0) : 99999999
            if TEd.size() > 0
                for i = TEd.size() - 1 to 0
                    if acc.get(0) < talN and TEd.get(i) < oldest
                        talAcc(acc, TEt.get(i), TEr.get(i), TEg.get(i), TEp.get(i))
                        seq := (TEt.get(i) > 0 ? "▲" : TEt.get(i) < 0 ? "▼" : "·") + seq
                        d0 := TEd.get(i)
        int    nT   = int(acc.get(0))
        int    uT   = int(acc.get(1))
        int    dT_  = int(acc.get(2))
        int    uR   = int(acc.get(3))
        int    dR_  = int(acc.get(4))
        int    nG   = int(acc.get(5))
        float  gAvg = nG > 0 ? acc.get(6) / nG : na
        float  gAbs = nG > 0 ? acc.get(7) / nG : na
        string since = na(d0) ? "" : " since " + str.format_time(keyTime(d0), "MMM yyyy", TZ)
        string srcT = TEd.size() > 0 ? " Built-in " + symR + " records run to " + str.format_time(keyTime(talEnd), "dd MMM yyyy", TZ) + "; later days, and any this chart loads itself, come from the chart's own bars." : " Records come from this chart's own bars (built-in history covers NQ / MNQ and ES / MES)."
        string tTip = "Trading day (18:00 → 17:00) close vs open on the last " + str.tostring(nT) + " " + TAL_NAME + " days" + since + ", oldest → newest: " + seq + ". RTH (09:30 → 16:14): ▲ " + str.tostring(uR) + " ▼ " + str.tostring(dR_) + ". A tally, not a forecast: across 2018–26 the up-close rate on these days was not different from normal days." + srcT
        string gTip = "RTH gap = 09:30 open − prior trading day's 16:14 close. Average over the last " + str.tostring(nG) + " " + TAL_NAME + " days: " + (na(gAvg) ? "—" : pf(gAvg)) + " pts; average size " + (na(gAbs) ? "—" : pf(gAbs) + " pts (" + str.tostring(acc.get(8) / nG, "0.00") + "%)") + "; gapped up on " + str.tostring(int(acc.get(9))) + " of " + str.tostring(nG) + "."
        string nxT  = na(n2k) ? "beyond loaded dates" : "FOMC " + str.format_time(keyTime(n2k), "dd MMM", TZ) + (n2k == today ? " · today" : " · " + str.tostring(inDays(n2k, today)) + "d") + (warn ? " · UPDATE" : "")
        string nxTip = "Next decision: " + (na(n2k) ? "beyond the loaded dates" : fmtDay(n2k) + " (statement 14:00 ET), the meeting's day 1 " + fmtDay(addDays(n2k, -1))) + ". Release dates are built in up to " + str.format_time(keyTime(LAST_DATE), "dd MMM yyyy", TZ) + ": add next year's dates (federalreserve.gov, bls.gov/schedule) to S_FOMC, S_CPI and S_NFP, then raise LAST_DATE."
        string hdT  = pfName(pk) + ". Recomputed on " + symR + " 1-minute data 2018–26." + (isNQ or isES ? "" : " This chart is " + syminfo.root + ": the figures are " + symR + "'s.")
        string pill_ = pNow ? "TODAY" : na(dd) ? "—" : dd == 1 ? "TMRW" : "IN " + str.tostring(dd) + "D"
        if showEv and not na(TS)
            int r0 = tsO
            cardHead(TS, r0, cGh, dot + " VIZARD · " + ev + " · " + symTag, hdT + " " + nxTip, mob and warn ? "UPDATE" : pill_, mob and warn or not pNow ? #ffffff : cGh, mob and warn ? cWarn : pNow ? #ffffff : color.new(#000000, 55))
            if not mob
                cardSub(TS, r0 + 1, cGh, "last " + str.tostring(nT) + " " + TAL_NAME + " days", "▲", "▼")
                cardRow(TS, r0 + 2, cGh, "DAY", false, gauge(uT + dT_ > 0 ? float(uT) / (uT + dT_) : na) + " " + (uT + dT_ > 0 ? p0(float(uT) / (uT + dT_)) : "—"), str.tostring(uT), str.tostring(dT_), tTip, cDisc, cPrem)
                cardRow(TS, r0 + 3, cGh, "RTH", false, gauge(uR + dR_ > 0 ? float(uR) / (uR + dR_) : na) + " " + (uR + dR_ > 0 ? p0(float(uR) / (uR + dR_)) : "—"), str.tostring(uR), str.tostring(dR_), "RTH 09:30 → 16:14 close vs open on the same days (days without RTH data are left out).", cDisc, cPrem)
                cardRow(TS, r0 + 4, cGh, "GAP", false, "avg gap · ▲" + str.tostring(int(acc.get(9))) + "/" + str.tostring(nG), na(gAvg) ? "—" : (gAvg >= 0 ? "+" : "") + str.tostring(gAvg, "0.0"), na(gAbs) ? "—" : "±" + str.tostring(gAbs, "0.0"), gTip)
                for zi = 0 to 1
                    zoneRow(TS, r0 + 5 + zi, cGh, zi == 0 ? "WEEK" : "MONTH", zi == 0 ? wH : mHi, zi == 0 ? wL : mLo, zi == 0 ? "week" : "month")
                cardWide(TS, r0 + EV_N - 1, cGh, "NEXT", nxT, nxTip, na(n1k) or warn ? cWarn : cTx)
            else
                // mobile: NOW reads the clock in one row, then the tally in short form
                if clkTF and not na(vAdr)
                    float  q50m = ckAt(ckI, mSel, 2, jB, fB)
                    string nTip = "Today so far (" + (clkR ? "range" : "net move") + " from the 18:00 open) against " + ckName(ckI) + " days at this time: median " + pf(q50m * scP) + ", middle half " + pf(q25B * scP) + "–" + pf(q75B * scP) + " pts at today's ADR20 (" + x2(q50m) + " typical, " + x2(vAdr) + " today). Above / below = outside that middle half."
                    cardRow(TS, r0 + 1, cGh, "NOW", false, (clkR ? "range " : "net ") + (clkR or vPts < 0 ? "" : "+") + str.tostring(vPts, "0"), x2(vAdr), "", nTip)
                    tcQ(TS, 4, r0 + 1, str.upper(stB), stB == "Inside" ? cTx : #ffffff, stB == "Above" ? cHot : stB == "Below" ? cCold : cNeu, nTip, text.align_center, true)
                else
                    cardRow(TS, r0 + 1, cGh, "NOW", false, not clkTF ? "clock: ≤ 60 min" : "needs 15+ days", "", "", "")
                cardRow(TS, r0 + 2, cGh, "DAY", false, "last " + str.tostring(nT) + " " + gauge5(uT + dT_ > 0 ? float(uT) / (uT + dT_) : na), "▲" + str.tostring(uT), "▼" + str.tostring(dT_), tTip, cDisc, cPrem)
                cardRow(TS, r0 + 3, cGh, "GAP", false, "avg · ▲" + str.tostring(int(acc.get(9))) + "/" + str.tostring(nG), na(gAvg) ? "—" : (gAvg >= 0 ? "+" : "") + str.tostring(gAvg, "0.0"), na(gAbs) ? "—" : "±" + str.tostring(gAbs, "0.0"), gTip)
                for zi = 0 to 1
                    zoneRow(TS, r0 + 4 + zi, cGh, zi == 0 ? "WK" : "MO", zi == 0 ? wH : mHi, zi == 0 ? wL : mLo, zi == 0 ? "week" : "month")
        // ── clock card
        if showCk and not na(TK)
            string bN   = ckName(ckI)
            string eN   = ckName(ckEvI)
            string nowT = hhmm(int(math.min(1439.0, (elM + tfM + 1080) % 1440)))
            int    r0   = tkO
            cardHead(TK, r0, cGh, dot + " " + str.upper("Vizard") + " · CLOCK · " + nowT + " ET", "Today's running range (or net move) from the 18:00 open against the same time of day on " + bN + " days, 2018–26: paths from " + ckN(ckI, isES) + " " + bN + " days" + (ckI != NCK - 1 ? " and " + ckN(NCK - 1, isES) + " normal days" : "") + ", half-hour steps, scaled by today's ADR20" + (scP > 0 ? " (" + pf(scP) + " pts)." : "."), ckEv ? eN + " DAY" : "NORMAL", ckEv ? cGh : #ffffff, ckEv ? #ffffff : color.new(#000000, 55))
            if not clkTF or na(vAdr)
                cardRow(TK, r0 + 1, cGh, "CLOCK", false, not clkTF ? "needs an intraday chart ≤ 60 min" : "needs 15+ days of history", "", "", "")
                cardRow(TK, r0 + 2, cGh, "", false, "", "", "", "")
                cardRow(TK, r0 + 3, cGh, "", false, "", "", "", "")
            else
                float q10 = ckAt(ckI, mSel, 0, jB, fB)
                float q50 = ckAt(ckI, mSel, 2, jB, fB)
                float q90 = ckAt(ckI, mSel, 4, jB, fB)
                float pc  = pctQ(vAdr, q10, q25B, q50, q75B, q90)
                string mW = clkR ? "range" : "net"
                color sBg = stB == "Above" ? cHot : stB == "Below" ? cCold : cNeu
                color sFg = stB == "Inside" ? cTx : #ffffff
                cardRow(TK, r0 + 1, cGh, "NOW", false, mW + " " + (clkR ? "" : vPts >= 0 ? "+" : "") + pf(vPts) + " pts", x2(vAdr), "", "Today so far, in ADR20 of the trading day.")
                tcQ(TK, 4, r0 + 1, pill(stB), sFg, sBg, "Above / below = outside the middle half (25–75%) of " + bN + " days at this time.", text.align_center, true)
                cardRow(TK, r0 + 2, cGh, "vs " + bN, false, meter(pc) + " " + pTxt(pc), "typ " + x2(q50), "", bN + " days by " + nowT + ": median " + pf(q50 * scP) + ", middle half " + pf(q25B * scP) + "–" + pf(q75B * scP) + " pts (" + mW + ", at today's ADR20).", stB == "Above" ? cHot : stB == "Below" ? cCold : cTx)
                float sh = ckShAt(ckI, jB, fB)
                float rgT = tdH - tdL
                cardRow(TK, r0 + 3, cGh, "DONE", false, gauge(sh) + " " + p0(sh), sh >= 0.25 ? "→ " + pf(rgT / sh) : "—", "pts", "Median share of the final day range already made by this time on " + bN + " days; right: today's range so far ÷ that share, a rough full-day figure (shown from 25% on).")
            float bestD = -1.0
            int   bestJ = 0
            for j = 0 to 45
                float dj = ck(ckEvI, 0, 2, j) - (j > 0 ? ck(ckEvI, 0, 2, j - 1) : 0.0)
                if dj > bestD
                    bestD := dj
                    bestJ := j
            float nD = ck(NCK - 1, 0, 2, bestJ) - (bestJ > 0 ? ck(NCK - 1, 0, 2, bestJ - 1) : 0.0)
            cardRow(TK, r0 + 4, cGh, "BUSIEST", false, hhmm(stepEnd(bestJ - 1)) + "–" + hhmm(stepEnd(bestJ)), "+" + x2(bestD), "norm +" + x2(nD), "The half hour in which the median running range of " + eN + " days grows most, against normal days in the same half hour.", ckEv ? cGh : cTx)
    true
drawCore2()

// ═══════════════════════════════════════════════════════════════ Model-specific cards (their own last-bar blocks: Pine caps the size of one if block)
drawLast1() =>
    if barstate.islast
        int xd = bar_index + offI
        if showStr and FO.includes(addDays(tdK, 1)) and not na(tdX)
            RL.push(line.new(tdX, tdH, xd, tdH, color = cLvl, style = line.style_dashed, force_overlay = true))
            RL.push(line.new(tdX, tdL, xd, tdL, color = cLvl, style = line.style_dashed, force_overlay = true))
            RT.push(label.new(tdX, tdH, "D1 high (live)", color = #00000000, textcolor = cLvl, style = label.style_label_lower_left, size = size.tiny, tooltip = "Today is FOMC day 1: its high and low carry into the decision day.", force_overlay = true))
            RT.push(label.new(tdX, tdL, "D1 low (live)", color = #00000000, textcolor = cLvl, style = label.style_label_upper_left, size = size.tiny, force_overlay = true))
        // the shock cone, live on the FOMC day: from 14:00 it runs a few minutes ahead of price; before 14:00 a faint preview
        for p in VPC
            p.delete()
        VPC.clear()
        if showCone and vzF and not na(ADRtd)
            if vzK == calK and not na(s14O) and mod < 975
                int kE = math.min(26, int((mod - 840) / 5) + 2)
                for cb = 0 to 1
                    VPC.push(coneBand(calK, s14O, ADRtd * s14O, 1 - cb, 3 - cb, kE, color.new(cGh, cb == 0 ? 91 : 85), cb == 0 ? color.new(cGh, 72) : #00000000))
                RT.push(label.new(keyAt(calK, 845 + 5 * kE), s14O + cnAt(1, kE) * ADRtd * s14O, "80% of FOMC days", xloc = xloc.bar_time, color = #00000000, textcolor = color.new(cGh, 20), style = label.style_label_lower_left, size = size.tiny, tooltip = "By " + hhmm(845 + 5 * kE) + " ET, 80% of FOMC days (2018–26) had gone no further than this above the 14:00 open, and the inner band held half of them. Scaled by today's ADR20.", force_overlay = true))
            else if mod >= 570 and mod < 840
                VPC.push(coneBand(calK, close, ADRtd * close, 1, 3, 26, color.new(cGh, 95), color.new(cGh, 82)))
        // week open, and the FOMC day's 14:00 and 14:30 opens, extended to the right of price
        if showWO and not na(wkX) and not na(wkOp)
            RL.push(line.new(math.max(wkX, bar_index - 4900), wkOp, xd, wkOp, color = color.new(cLvl, 15), style = line.style_dashed, force_overlay = true))
            RT.push(label.new(bar_index + 2, wkOp, "week open " + pf(wkOp), color = #00000000, textcolor = cLvl, style = label.style_label_left, size = size.tiny, force_overlay = true))
        if showWO and vzF and vzK == calK and not na(s14X) and bar_index - s14X < 4900
            RL.push(line.new(s14X, s14O, xd, s14O, color = color.new(cGh, 15), force_overlay = true))
            RT.push(label.new(bar_index + 2, s14O, "14:00 open " + pf(s14O), color = #00000000, textcolor = cGh, style = label.style_label_left, size = size.tiny, force_overlay = true))
            if not na(s30X)
                RL.push(line.new(s30X, s30O, xd, s30O, color = color.new(cGh, 35), style = line.style_dashed, force_overlay = true))
                RT.push(label.new(bar_index + 2, s30O, "14:30 open " + pf(s30O), color = #00000000, textcolor = color.new(cGh, 25), style = label.style_label_left, size = size.tiny, force_overlay = true))
    true
drawLast1()

drawLast2() =>
    if barstate.islast
        int    today = calK
        string dot   = barstate.isrealtime ? (beat % 2 == 0 ? "●" : "○") : "◆"
        // ── Fed card (CME FedWatch steps on CBOT ZQ): shared values for both layouts
        bool fdEv  = FO.includes(today)
        bool fdAft = fdEv and mod >= 840
        [fK, fE, fMK, fMP, fk1, fk2, fw1, fw2, fLo, fBase] = fdCalc(fdZ, today, fdAft)
        int  fdHn = fdH.size()
        array<float> fdZ1 = fdHn >= FDN ? fdH.slice(fdHn - FDN, fdHn) : array.new<float>()
        array<float> fdZ5 = fdHn >= 5 * FDN ? fdH.slice(fdHn - 5 * FDN, fdHn - 4 * FDN) : array.new<float>()
        array<float> yE = array.new<float>()
        array<float> wE = array.new<float>()
        int   yk1 = na
        int   yk2 = na
        float yw1 = na
        float yw2 = na
        for pv = 0 to 1
            [hK, hE, hMK, hMP, hk1, hk2, hw1, hw2, hLo, hBase] = fdCalc(pv == 0 ? fdZ1 : fdZ5, today, fdAft)
            if pv == 0
                yE  := hE
                yk1 := hk1
                yk2 := hk2
                yw1 := hw1
                yw2 := hw2
            else
                wE  := hE
        bool  fOk  = fK.size() > 0
        int   kA   = na(fw1) ? na : fw1 >= fw2 ? fk1 : fk2
        int   kB   = na(fw1) ? na : fw1 >= fw2 ? fk2 : fk1
        float pA   = na(fw1) ? na : math.max(fw1, fw2)
        float pB   = na(fw1) ? na : math.min(fw1, fw2)
        float dA   = 100 * (pA - fdOdd(kA, yk1, yk2, yw1, yw2))
        float dB   = 100 * (pB - fdOdd(kB, yk1, yk2, yw1, yw2))
        float mv5  = fOk and wE.size() > 0 ? 100 * (fE.get(0) - wE.get(0)) : na
        // decision day after 14:00: what was decided, the surprise against 13:59 pricing and how the next meeting repriced
        bool  fDone = fdAft and fd14K == today
        int   fDec  = na
        float fSur  = na
        float fPx   = na
        float fPr   = na
        int   fNx   = na
        if fDone
            [S1, E1, KY1] = fdRates(fd14)
            [S2, E2, KY2] = fdRates(fdZ)
            int iT = KY1.indexof(today)
            if iT >= 0
                if not na(E2.get(iT)) and not na(S2.get(iT))
                    fDec := int(math.round((E2.get(iT) - S2.get(iT)) / 0.25))
                if not na(E1.get(iT)) and not na(S1.get(iT))
                    [c1, c2, q1, q2] = fdNode(E1.get(iT) - S1.get(iT))
                    fPr := fdOdd(fDec, c1, c2, q1, q2)
                fSur := 100 * (E2.get(iT) - E1.get(iT))
                if iT < FDN - 1
                    for i = iT + 1 to FDN - 1
                        if KY2.get(i) % 100 > 0 and na(fNx)
                            fNx := KY2.get(i)
                            fPx := 100 * (E2.get(i) - E1.get(i))
        string fPill = fDone ? "DECIDED" : not fOk ? "NO DATA" : str.upper(fdWord(kA)) + " " + p0(pA)
        color  fPbg  = fDone or not fOk or kA == 0 ? cNeu : kA < 0 ? cCold : cHot
        color  fPfg  = fDone or not fOk or kA == 0 ? cTx : #ffffff
        string fTip  = "Odds for the next FOMC meetings from CBOT 30-day fed funds futures, with the same steps as CME FedWatch: each contract settles to 100 − the month's average effective fed funds rate; the month after a meeting (or before it) anchors the rate after (or before) the decision, which takes effect the next day; the change ÷ 25bp gives the odds of the two nearest moves, combined across meetings as a probability tree. Checked against CME's own FedWatch page for 12 Oct 2026: all eight meetings within 0.06 percentage points. A live readout, not yet a tested signal: rows that held on NQ / ES come once the ZQ history is tested. TradingView delays CBOT data without a subscription."
        string pTip  = "Expected rate after this meeting against the rate now (bp), the most likely target range by then and its odds (probability tree over the meetings in between). Right: change since yesterday's close, bp."

        if showFd and not na(TF) and not mob
            int r0 = tfO
            cardHead(TF, r0, cFd, dot + " FED · " + (fOk ? fdDate(fK.get(0)) : "NO ZQ DATA"), fTip, fPill, fPfg, fPbg)
            cardSub(TF, r0 + 1, cFd, "now " + (fOk ? fdRng(fLo, 0) : "—"), "odds", "1d")
            string oTip = "The next meeting's two outcomes: the expected change ÷ 25bp sits between two move sizes, and its distance to each is the odds. Right: change since yesterday's close, in percentage points."
            cardRow(TF, r0 + 2, cFd, "NEXT", false, fOk ? fdMv(kA, fLo) : "—", fOk ? p0(pA) : "—", na(dA) ? "—" : fdSg(dA, "0"), oTip)
            cardRow(TF, r0 + 3, cFd, "", false, fOk ? fdMv(kB, fLo) : "", fOk ? p0(pB) : "", na(dB) ? "" : fdSg(dB, "0"), oTip, cMu)
            for j = 1 to 3
                if j < fK.size()
                    float cb = 100 * (fE.get(j) - fBase)
                    float d1 = j < yE.size() ? 100 * (fE.get(j) - yE.get(j)) : na
                    cardRow(TF, r0 + 3 + j, cFd, fdDate(fK.get(j)), false, fdRng(fLo, fMK.get(j)) + " " + p0(fMP.get(j)), fdSg(cb, "0") + "bp", fdSg(d1, "0.0"), pTip)
            if fDone
                cardRow(TF, r0 + 7, cFd, "14:00", false, fdWord(fDec) + " · priced " + (na(fPr) ? "—" : p0(fPr)), fdSg(fSur, "0.0") + "bp", na(fNx) ? "" : str.upper(str.format_time(keyTime(fNx), "MMM", TZ)) + " " + fdSg(fPx, "0"), "Decision day. Surprise = change in the expected rate after today's meeting from 13:59 to now (the classic fed funds futures surprise), with the odds the decision had at 13:59. Right: how the next meeting's expected rate moved since 13:59, bp.", math.abs(nz(fSur)) >= 5 ? cHot : cTx)
            else if fdEv
                cardRow(TF, r0 + 7, cFd, "TODAY", false, "14:00 · priced " + (na(pA) ? "—" : p0(pA)), "", "", "Decision day: the statement lands at 14:00 ET, the press conference at 14:30. After 14:00 this row shows the surprise against the 13:59 pricing.")
            else
                cardRow(TF, r0 + 7, cFd, "5D", false, "next mtg, 5 days", fdSg(mv5, "0.0") + "bp", "", "Change in the expected rate after the next meeting over the last five trading days (bp). Up = cuts priced out or hikes priced in.")
        if showFd and not na(TF) and mob
            string mTx = fDone ? "surprise " + fdSg(fSur, "0.0") + "bp" : not fOk ? "no ZQ data" : str.format_time(keyTime(fK.get(0)), "d MMM", TZ) + " " + fdWord(kA)
            string mVl = fDone ? (na(fNx) ? "—" : str.format_time(keyTime(fNx), "MMM", TZ) + " " + fdSg(fPx, "0")) : fOk ? p0(pA) : "—"
            string mTip = fTip + (fOk ? " Now " + fdRng(fLo, 0) + "; next meeting " + fdDate(fK.get(0)) + ": " + fdWord(kA) + " " + p0(pA) + ", " + fdWord(kB) + " " + p0(pB) + (fK.size() > 1 ? "; by " + fdDate(fK.get(fK.size() - 1)) + " " + fdSg(100 * (fE.get(fE.size() - 1) - fBase), "0") + "bp, most likely " + fdRng(fLo, fMK.get(fMK.size() - 1)) + " (" + p0(fMP.get(fMP.size() - 1)) + ")" : "") + "." : "")
            cardRow(TF, tfO, cFd, "FED", false, mTx, mVl, "", mTip, fDone and math.abs(nz(fSur)) >= 5 ? cHot : cTx)
            tcQ(TF, 4, tfO, fDone ? "DONE" : str.upper(fdWord(kA)), fPfg, fPbg, mTip, text.align_center, true)
    true
drawLast2()

// ═══════════════════════════════════════════════════════════════ Fed map (indicator pane)
// A heat table beside the event clock: one column per upcoming meeting, one row per 25bp target range, each cell the odds of
// that range after the meeting (the probability tree through every meeting before it). Under it: the expected change from
// today's rate, its move since yesterday's close (since 13:59 on a decision day after 14:00) and over 5 days, and the
// market against the Fed's dot-plot median at each year's last meeting.
var table TFM = na
var int   tmO = 0
if barstate.isfirst and showMap
    tmO := gapOf("Indicator pane", mapPos) ? 1 : 0
    TFM := table.new(posOf(mapPos), 11, 17 + tmO, bgcolor = #00000000, frame_width = 0, border_color = chart.bg_color, border_width = 1)
mapCell(int c, int r, string s, color fg, color bg, string tip = "", bool b = false) =>
    TFM.cell(c, r, s, text_color = fg, bgcolor = bg, text_size = crdSz, text_halign = text.align_center, tooltip = tip, text_font_family = font.family_monospace, text_formatting = b ? text.format_bold : text.format_none)
drawMap() =>
    if barstate.islast and not na(TFM)
        TFM.clear(0, 0, 10, 16 + tmO)
        if tmO == 1
            TFM.cell(0, 0, "", height = 7.0, bgcolor = #00000000)
        int  today = calK
        bool aft   = FO.includes(today) and mod >= 840
        bool d14   = aft and fd14K == today
        int  hn    = fdH.size()
        [S, E, KY]   = fdRates(fdZ)
        [S1, E1, K1] = fdRates(d14 ? fd14 : hn >= FDN ? fdH.slice(hn - FDN, hn) : array.new<float>())
        [S5, E5, K5] = fdRates(hn >= 5 * FDN ? fdH.slice(hn - 5 * FDN, hn - 4 * FDN) : array.new<float>())
        array<int> up = array.new<int>()
        for i = 0 to FDN - 1
            int ky = KY.get(i)
            if ky % 100 > 0 and (ky > today or (ky == today and not aft)) and not na(S.get(i)) and not na(E.get(i)) and up.size() < mapN
                up.push(i)
        int r0 = tmO
        int nc = up.size()
        if nc == 0
            mapCell(0, r0, "FED MAP · no CBOT ZQ data", #ffffff, cMapH)
        else
            float base = S.get(up.get(0))
            float lo0  = math.floor((base + 0.0001) / 0.25) * 0.25
            matrix<float> PM = matrix.new<float>(41, nc, 0.0)
            array<float>  P  = array.new<float>(41, 0.0)
            P.set(20, 1.0)
            int xHi = 20
            int xLo = 20
            for j = 0 to nc - 1
                P := fdStep(P, E.get(up.get(j)) - S.get(up.get(j)))
                for x = 0 to 40
                    PM.set(x, j, P.get(x))
                    if P.get(x) * 100 >= mapMin
                        xHi := math.max(xHi, x)
                        xLo := math.min(xLo, x)
            xLo := math.max(xLo, xHi - 9)
            [k1, k2, w1, w2] = fdNode(E.get(up.get(0)) - S.get(up.get(0)))
            int    kA  = w1 >= w2 ? k1 : k2
            string tip = "From CBOT 30-day fed funds futures with CME FedWatch's steps (checked on CME's own page for 12 Oct 2026: within 0.06 pp). Cells: the odds (%) of each target range after each meeting, bold = most likely. Below: the expected change from today's rate (bp), its move since " + (d14 ? "13:59" : "yesterday's close") + " and over 5 days (bp; up = cuts priced out), and the market against the Fed's dot-plot median (SEP " + sepAs + ") at each year's last meeting. TradingView delays CBOT data without a subscription."
            mapCell(0, r0, "FED MAP · " + fdDate(KY.get(up.get(0))) + " " + str.upper(fdWord(kA)) + " " + p0(math.max(w1, w2)) + " · now " + fdRng(lo0, 0), #ffffff, cMapH, tip, true)
            TFM.merge_cells(0, r0, nc, r0)
            int rB = r0 + 3 + xHi - xLo                                 // first row under the ranges
            for j = 0 to nc - 1
                int   i   = up.get(j)
                int   yr  = int(KY.get(i) / 10000)
                bool  eoy = j < nc - 1 ? int(KY.get(up.get(j + 1)) / 10000) != yr : int(KY.get(i) / 100) % 100 == 12
                float sep = yr == sepY ? sep1 : yr == sepY + 1 ? sep2 : yr == sepY + 2 ? sep3 : na
                bool  dt  = eoy and not na(sep)
                float bx  = 0.0
                for x = xLo to xHi
                    bx := math.max(bx, PM.get(x, j))
                mapCell(j + 1, r0 + 1, fdDate(KY.get(i)), cTx, cBody2, tip, true)
                for x = xHi to xLo
                    float p = PM.get(x, j)
                    bool  v = p >= 0.005
                    mapCell(j + 1, r0 + 2 + xHi - x, v ? str.tostring(100 * p, "0") : "·", p >= 0.45 ? #ffffff : v ? cTx : cMu, v ? color.from_gradient(p, 0.0, 0.7, cHtLo, cHtHi) : cBody, fdDate(KY.get(i)) + " · " + fdRng(lo0, x - 20) + ": " + str.tostring(100 * p, "0.0") + "%", v and p == bx)
                float c1 = 100 * (E.get(i) - E1.get(i))
                float c5 = 100 * (E.get(i) - E5.get(i))
                mapCell(j + 1, rB, fdSg(100 * (E.get(i) - base), "0"), cTx, cBody2, tip, true)
                mapCell(j + 1, rB + 1, fdSg(c1, "0.0"), na(c1) or math.abs(c1) < 0.5 ? cMu : c1 > 0 ? cHot : cCold, cBody, tip)
                mapCell(j + 1, rB + 2, fdSg(c5, "0.0"), na(c5) or math.abs(c5) < 0.5 ? cMu : c5 > 0 ? cHot : cCold, cBody, tip)
                mapCell(j + 1, rB + 3, dt ? fdSg(100 * (E.get(i) - sep), "0") : "", cTx, cBody, dt ? "Fed dot plot (SEP " + sepAs + "): median end-" + str.tostring(yr) + " rate " + str.tostring(sep, "0.000") + "%. The market prices " + str.tostring(E.get(i), "0.000") + "% after " + fdDate(KY.get(i)) + ": " + fdSg(100 * (E.get(i) - sep), "0") + "bp against the Fed's own median." : tip)
            for x = xHi to xLo
                bool cur = x == 20
                mapCell(0, r0 + 2 + xHi - x, fdRng(lo0, x - 20) + (cur ? " ◀" : "  "), cur ? cMapC : cTx, cBody2, tip, cur)
            mapCell(0, r0 + 1, "RANGE", cMu, cBody2, tip)
            mapCell(0, rB, "EXP bp", cMu, cBody2, tip)
            mapCell(0, rB + 1, d14 ? "Δ 13:59" : "Δ 1D", cMu, cBody2, tip)
            mapCell(0, rB + 2, "Δ 5D", cMu, cBody2, tip)
            mapCell(0, rB + 3, "vs DOTS", cMu, cBody2, tip)
    true
drawMap()

// ═══════════════════════════════════════════════════════════════ FOMC stages card (last bar)
// part of the month's range: 0 discount (bottom quarter) · 1 middle · 2 premium (top quarter)
zIdx(float p) => na(p) ? 1 : p >= 0.75 ? 2 : p <= 0.25 ? 0 : 1
zWd(int z) => z == 2 ? "PREM" : z == 0 ? "DISC" : "MID"
sgP(float v) => na(v) ? "—" : str.tostring(v, "0")
sgS(float v) => na(v) ? "—" : (v >= 0 ? "+" : "−") + str.tostring(math.abs(v), "0")
hl(int i) => "H" + str.tostring(VS.get(i), "0") + " L" + str.tostring(VS.get(i + 1), "0")
liveTx(float sv, float dv) => na(sv) ? "—" : sgS(sv) + " · DXY " + (na(dv) ? "—" : vzAr(dv) + str.tostring(math.abs(dv), "0.00"))
// same window against DXY: ⇄ other way · ⇉ same way · BIG once DXY's move reaches thr of its ADR20
dxPill(float dv, float sv, float thr) =>
    bool ok  = not (na(dv) or na(sv) or dv == 0 or sv == 0)
    bool big = ok and math.abs(dv) >= thr
    bool oth = ok and math.sign(dv) != math.sign(sv)
    [not ok ? "—" : (oth ? "⇄" : "⇉") + (big ? " BIG" : ""), big ? #ffffff : cTx, not ok ? cBody : big ? (oth ? cOk : cWarn) : cNeu]
drawSg() =>
    if barstate.islast and showSg and not na(TV)
        int    today = calK
        string dot   = barstate.isrealtime ? (beat % 2 == 0 ? "●" : "○") : "◆"
        bool   fz    = not na(k59) and k59 == calK
        [lp, lm, ld, ls, la, lx] = ctxOf(close, tdH, tdL, dxL)
        float  p   = fz ? cxP : lp
        float  m   = fz ? cxM : lm
        float  d   = fz ? cxD : ld
        float  s   = fz ? cxS : ls
        float  a   = fz ? cxA : la
        float  x   = fz ? cxX : lx
        int    z   = zIdx(p)
        int    oc  = na(p) ? na : math.min(8, int(math.floor(p * 8)) + 1)
        int    mo3 = na(m) ? 1 : m > 1 ? 0 : m < -1 ? 2 : 1                   // over · near · under the month's open
        int    pg  = na(d) ? 1 : d > 0 ? 0 : d < 0 ? 2 : 1                    // above PDH · inside · below PDL
        int    sg  = na(s) ? 1 : s > 0.4 ? 0 : s < -0.4 ? 2 : 1               // strong up · within · strong down
        int    nxF = nextOf(FO, today)
        int    ddF = na(nxF) ? na : inDays(nxF, today)
        int    mk  = vzF ? today : nxF
        bool   sep = not na(mk) and (int(mk / 100) % 100) % 3 == 0
        float  e1  = VS.get(sep ? 0 : 2) * a
        float  e2  = VS.get(4 + 2 * z) * a
        bool   st  = vzK == calK
        bool   in2 = st and not na(s30O)
        float  sv1 = st and not na(s14O) ? (na(s1C) ? close : s1C) - s14O : na
        float  sv2 = in2 ? (na(s2C) ? close : s2C) - s30O : na
        float  dv1 = st and not na(x14) and dxA > 0 ? ((na(x1C) ? dxL : x1C) - x14) / dxA : na
        float  dv2 = in2 and not na(x30) and dxA > 0 ? ((na(x2C) ? dxL : x2C) - x30) / dxA : na
        float  r1  = na(sv1) or not (e1 > 0) ? na : math.abs(sv1) / e1
        float  r2  = na(sv2) or not (e2 > 0) ? na : math.abs(sv2) / e2
        [t1, f1, b1] = dxPill(dv1, sv1, 0.25)
        [t2, f2, b2] = dxPill(dv2, sv2, 0.5)
        color  pfg = vzF ? cGh : #ffffff
        color  pbg = vzF ? #ffffff : color.new(#000000, 55)
        string mTp = "Price at " + (na(p) ? "—" : p0(p)) + " of the month's range so far (" + (fz ? "13:59" : "live") + "). " + VZT_MON
        string oTp = "Month's open " + pf(mtO) + ": " + fdSg(m, "0.0") + " ADR (" + sgS(m * a) + " pts). " + VZT_MO
        string pdT = na(d) ? "prior day —" : d > 0 ? "above PDH " + sgS(d * a) : d < 0 ? "below PDL " + sgS(d * a) : "inside prior day"
        string gNw = not na(gfT) ? "filled " + str.format_time(gfT, "HH:mm", TZ) : tgKey == calK and not na(gapPC) ? "open · " + str.tostring(math.abs(close - gapPC), "0") + " to go" : "from 09:30"
        string d4  = na(x) ? "" : "S2▲" + (x > 0 ? "27%" : isES ? "61%" : "65%")
        int    r   = tvO
        if not mob
            cardHead(TV, r, cGh, dot + " FOMC STAGES · " + symTag, VZT_HD, vzF ? "TODAY" : na(ddF) ? "—" : "IN " + str.tostring(ddF) + "D", pfg, pbg)
            cardSub(TV, r + 1, cGh, fz ? "SETUP AT 13:59" : "SETUP · LIVE", "ADR", "")
            cardRow(TV, r + 2, cGh, "MONTH", false, octBar(oc) + " " + (na(p) ? "—" : p0(p)), "", "", mTp)
            tcQ(TV, 4, r + 2, zWd(z), z == 1 ? cTx : #ffffff, z == 2 ? cPrem : z == 0 ? cDisc : cNeu, mTp, text.align_center, true)
            cardRow(TV, r + 3, cGh, "MO", false, "vs month open " + sgS(m * a), fdSg(m, "0.0"), "", oTp)
            tcQ(TV, 4, r + 3, mo3 == 0 ? "OVER" : mo3 == 2 ? "UNDER" : "NEAR", mo3 == 1 ? cTx : #ffffff, mo3 == 0 ? cHot : mo3 == 2 ? cCold : cNeu, oTp, text.align_center, true)
            cardRow(TV, r + 4, cGh, "PD", false, pdT, pg == 1 ? "" : fdSg(d, "0.0"), hl(16 + 2 * pg), "Against the prior trading day's high (PDH) and low (PDL). " + VZT_PD, na, cSub)
            cardRow(TV, r + 5, cGh, "18:00", false, "since 18:00 " + sgS(s * a), fdSg(s, "0.0"), hl(22 + 2 * sg), VZT_18, sg == 0 ? cDisc : sg == 2 ? cPrem : na, cSub)
            cardRow(TV, r + 6, cDxc, "DXY 4W", false, "DXY 4 weeks " + vzAr(x), fdSg(x, "0.0"), d4, VZT_D4, na, cSub)
            cardSub(TV, r + 7, cGh, "EXPECT · ADR " + sgP(a), "med", "80%")
            cardRow(TV, r + 8, cGh, "S1", isES and sep, "14:00–14:30" + (sep ? " · SEP" : ""), "±" + sgP(e1), "±" + sgP(VS.get(sep ? 1 : 3) * a), VZT_E1)
            cardRow(TV, r + 9, cGh, "S2", false, "14:30–16:14 · " + zWd(z), "±" + sgP(e2), "±" + sgP(VS.get(5 + 2 * z) * a), VZT_E2)
            cardRow(TV, r + 10, cGh, "RANGE", false, "after 14:00 · " + zWd(z), sgP(VS.get(10 + 2 * z) * a), sgP(VS.get(11 + 2 * z) * a), VZT_E2)
            if not isES
                cardRow(TV, r + 11, cGh, "EDGE", false, "none held on NQ", "", "", "No 13:59 setup held on NQ in both 2018–24 and 2025–26. Closest: premium, range after 14:00 0.74 vs 0.99 ADR (p 0.08); above PDH, new low after 14:00 28% vs 59% (p 0.02, flipped in 2025–26); strong up since 18:00, new low 22% vs 61% (p 0.005, flipped). NQ's tested information is in the sizes above and the DXY rows.")
            else if z == 2
                cardRow(TV, r + 11, cGh, "EDGE", true, "up 14:00 → 16:14", "65%", "36%", "ES, held: in the month's premium at 13:59 (n 34) the 16:14 close finished above the 14:00 price on 65% of FOMC days vs 36% of the others (2018–24 69% vs 36%; 2025–26 40% vs 38%, barely; p 0.02). The only direction result that held, and only on ES.")
            else if z == 0
                cardRow(TV, r + 11, cGh, "EDGE", true, "new low after 14:00", "100%", "58%", "ES, held: in the month's discount at 13:59 every FOMC day (7 of 7, 2 in 2025–26) made a new day low after 14:00 vs 58% of the others (p 0.03). Small sample.")
            if isES and mo3 == 0
                cardRow(TV, r + 12, cGh, "EDGE", true, "range after 14:00", sgP(0.67 * a), sgP(1.12 * a), "ES, held: more than 1 ADR over the month's open at 13:59 (n 33) the range after 14:00 ran 0.67 vs 1.12 ADR (2018–24 0.69 vs 1.18, 2025–26 0.63 vs 0.74; p 0.001) and |stage 2| 0.25 vs 0.53 (p 0.004). Value: this setup at today's ADR20; right: the others.")
            else if isES and mo3 == 2
                cardRow(TV, r + 12, cGh, "EDGE", true, "next NY AM up", "88%", "43%", "ES, held: more than 1 ADR under the month's open at 13:59 (n 8) the next day's NY AM (09:30 → 11:00) closed up 88% vs 43% (2018–24 80%, 2025–26 3 of 3; p 0.02). Small sample.")
            else if isES and z == 1
                cardRow(TV, r + 12, cGh, "EDGE", false, "none held here", "", "", "ES results that held need a month premium or discount, or price more than 1 ADR from the month's open, at 13:59. Today's setup is in the middle on both.")
            if vzF
                cardSub(TV, r + 13, cDxc, "LIVE · vs DXY", "×typ", "DXY")
                cardRow(TV, r + 14, cGh, "S1", false, st ? liveTx(sv1, dv1) : "from 14:00", na(r1) ? "" : x2(r1), "", VZT_LV, nz(r1) >= 1 ? cHot : na)
                tcQ(TV, 4, r + 14, t1, f1, b1, VZT_LV, text.align_center, true)
                cardRow(TV, r + 15, cGh, "S2", false, in2 ? liveTx(sv2, dv2) : "from 14:30", na(r2) ? "" : x2(r2), "", VZT_LV, nz(r2) >= 1 ? cHot : na)
                tcQ(TV, 4, r + 15, t2, f2, b2, VZT_LV, text.align_center, true)
                cardRow(TV, r + 16, cDxc, "DXY ⇄", true, "big DXY → other way", in2 ? VZV_D2 : VZV_D1, in2 ? "73%" : VZB_D1, VZT_DR)
                cardRow(TV, r + 17, cGh, "GAP", true, "gap " + gNw, VZV_GF, VZB_GF, VZT_GF)
        else
            cardHead(TV, r, cGh, dot + " STAGES · " + symTag, VZT_HD, vzF ? "TODAY" : na(ddF) ? "—" : str.tostring(ddF) + "D", pfg, pbg)
            cardRow(TV, r + 1, cGh, "MO", false, octBar(oc) + " " + zWd(z), fdSg(m, "0.0"), na(p) ? "—" : p0(p), mTp + " " + oTp, mo3 == 0 ? cHot : mo3 == 2 ? cCold : na)
            cardRow(TV, r + 2, cGh, "EXP", isES and sep, "S1 ±" + sgP(e1) + " S2 ±" + sgP(e2), sgP(VS.get(10 + 2 * z) * a), "rng", VZT_E1 + " " + VZT_E2)
            cardRow(TV, r + 3, cGh, "PD", false, (pg == 0 ? "> PDH " : pg == 2 ? "< PDL " : "in PD ") + hl(16 + 2 * pg), pg == 1 ? "" : fdSg(d, "0.0"), "", VZT_PD)
            if vzF
                cardRow(TV, r + 4, cGh, in2 ? "S2" : "S1", false, in2 ? liveTx(sv2, dv2) : st ? liveTx(sv1, dv1) : "from 14:00", na(in2 ? r2 : r1) ? "" : x2(in2 ? r2 : r1), "", VZT_LV)
                tcQ(TV, 4, r + 4, in2 ? t2 : t1, in2 ? f2 : f1, in2 ? b2 : b1, VZT_LV, text.align_center, true)
                cardRow(TV, r + 5, cDxc, "DXY", true, "big → other way", in2 ? VZV_D2 : VZV_D1, "", VZT_DR)
                cardRow(TV, r + 6, cGh, "GAP", true, gNw, VZV_GF, VZB_GF, VZT_GF)
            else
                cardRow(TV, r + 4, cDxc, "DXY 4W", false, "DXY 4w " + vzAr(x) + " " + d4, fdSg(x, "0.0"), "", VZT_D4)
    true
drawSg()

// ═══ Write the queued card cells, in the order they were queued
cardFlush() =>
    if CQ.size() > 0
        for q in CQ
            table t = q.t
            int   r = q.r
            switch q.k
                0 =>
                    stripe(t, r, q.col)
                    tc(t, 1, r, q.s1, q.b ? #ffffff : cMu, q.b ? cOk : cBody, q.tip, text.align_center, q.b)
                    tc(t, 2, r, q.s2, cTx, cBody, q.tip)
                    tc(t, 3, r, q.s3, na(q.f1) ? cTx : q.f1, cBody, q.tip, text.align_center, true)
                    tc(t, 4, r, q.s4, na(q.f2) ? cMu : q.f2, cBody, q.tip, text.align_center)
                1 =>
                    stripe(t, r, q.col)
                    tc(t, 1, r, q.s1, #ffffff, q.col, q.tip, text.align_left, true)
                    tc(t, 4, r, q.s4, q.f1, q.f2, "", text.align_center, true)
                2 =>
                    stripe(t, r, q.col)
                    tc(t, 1, r, "", cMu, cBody2)
                    tc(t, 2, r, q.s2, cMu, cBody2)
                    tc(t, 3, r, q.s3, cMu, cBody2, "", text.align_center)
                    tc(t, 4, r, q.s4, cMu, cBody2, "", text.align_center)
                3 =>
                    stripe(t, r, q.col)
                    tc(t, 1, r, q.s1, cMu, cBody, "", text.align_center)
                    tc(t, 2, r, q.s2, q.f1, cBody, q.tip)
                4 =>
                    tc(t, q.c, r, q.s1, q.f1, q.f2, q.tip, q.ha, q.b)
                =>
                    stripe(t, r, q.col)
        CQ.clear()
    true
cardFlush()
````
