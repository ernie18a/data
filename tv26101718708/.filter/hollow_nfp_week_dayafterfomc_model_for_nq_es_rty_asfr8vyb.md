# Hollow - NFP Week & Day-After-FOMC Model for NQ, ES & RTY

- url: https://www.tradingview.com/script/aSfr8vyB-Hollow-NFP-Week-Day-After-FOMC-Model-for-NQ-ES-RTY/
- type: indicator
- pine_id: PUB;a167a79ac0c6412cbfcbed909f2c067a
- version: 2.0

## Description

[b]Hollow[/b] maps the two days around the big releases that nobody marks: Monday–Thursday of NFP week (Model 11) and the day after FOMC (Model 12, Full Bringer). It covers five things:
• the levels those days trade around;
• how far days with today's setup usually move, at today's ADR20;
• NY AM and RTH live against the dollar;
• Shirosaki, a table of what held for today's setup;
• today's range against the typical day of its kind.
The figures are pooled across NQ, ES and RTY: 329 NFP weeks (970 symbol-days) and 67 days after FOMC (196 symbol-days). A ✓ row held in 2018–24, again in 2025–26, and on each of the three markets. [i]It is a map of how these days usually behave, not a signal generator.[/i]
https://www.tradingview.com/x/Wlb18cPk/


[b]WHAT IT DRAWS ON PRICE[/b]

• [b]NFP week's opening gap:[/b] the prior week's last close and Sunday's 18:00 open, with their midpoint, drawn to the NFP release. Its midpoint traded by the release in 96% of NFP weeks.
• [b]FOMC high and low:[/b] the FOMC day's high and low (its 18:00–17:00 session), carried through the next day to 16:14.
• [b]RTH gap:[/b] on Hollow days, the prior 16:14 close and the gap's 50% from 09:30.
• [b]Gap octants (day after FOMC):[/b] the gap in eighths over NY AM, the 50% line bold and the quarter next to the open shaded.
• [b]Settlement window (NFP week):[/b] 16:15–17:00 shaded.
• [b]NFP and FOMC flags:[/b] above the release bar, tied by a stem to the 08:30 or 14:00 open.
• [b]Week open:[/b] carried right of price.
https://www.tradingview.com/x/lF7j3NRD/

[b]STAGES CARD[/b]

The card reads whichever Hollow day is current or next. The header pill shows where price sits in the month's range: [i]discount[/i] (bottom quarter), [i]middle[/i] or [i]premium[/i] (top quarter). It comes first because it is the setup that sized these days most.

[b]SETUP[/b] runs live, then is fixed at 09:29. Each row shows the odds for its group:
• the day after FOMC: the FOMC day's afternoon (14:00 → 16:14), with how often the next RTH took the FOMC high and low;
• the month's octant;
• NFP week: the distance from the month's open;
• the prior day's high and low (the FOMC day's the day after);
• the move since 18:00;
• the RTH gap (before 09:30, the gap if it opened now);
• VIX against its 20-day average.

[b]EXPECT[/b] (before 09:30) gives the median and 80th percentile at today's ADR20 for NY AM and the RTH range, then the settlement window and the next day (NFP week) or the next day and the open-side quarter (the day after FOMC).

[b]LIVE[/b] (from 09:30) shows:
• NY AM and RTH in points, against DXY's move in the same window;
• the range since 09:30 against the expected median;
• the gap's 50% and fill, with the time each was hit.


[b]SHIROSAKI (INDICATOR PANE)[/b]

Shirosaki lists what held for today's setup, in points at today's ADR20. Once RTH opens, its gap rows show what happened today, and its DXY rows carry a live pill.

[b]NFP week:[/b]
• [b]RTH range[/b] by the month's position: [b]0.94[/b] ADR from a discount vs [b]0.66[/b] from a premium ✓. A second row lists the other size groups active today and whether they all point bigger or smaller:
  – VIX more than 10% over its average: 0.97 ✓; more than 10% under: 0.59 ✓;
  – more than 1 ADR under the month's open: 0.90 ✓; over: 0.67 ✓;
  – below the prior day's low 0.93 ✓; above its high 0.66 ✓; an overnight down more than 0.4 ADR 1.06 ✓.
• [b]New high / low after 09:30[/b] for the most specific group active today:
  – overnight down more than 0.4 ADR: new high 27% ✓, new low 78% ✓;
  – above the prior day's high: new high 76% ✓, new low 43% ✓;
  – from a monthly discount: new high 45% ✓, new low 76% ✓.
• [b]The RTH gap:[/b]
  – a small gap (within 0.25 ADR): 50% by 10:00 [b]82%[/b] ✓, filled by 16:14 [b]83%[/b] ✓;
  – a gap up more than 0.25 ADR: 50% by 10:00 32% ✓, filled 37% ✓;
  – the open-side quarter held through NY AM: 32% on a gap up, 6% on a small gap ✓.
• [b]DXY:[/b] once DXY's move over RTH reached 0.26 of its ADR20, the index went the other way [b]70%[/b] vs 42% ✓ (NY AM, 0.19: 60% vs 54% ✓, barely).

[b]Day after FOMC:[/b]
• [b]Did RTH take the FOMC high / low?[/b]
  – from a monthly premium: high 76% ✓, low 22% ✓; from a discount: high 9% ✓, low 86% ✓;
  – after an FOMC afternoon up: high 73% ✓, low 28% ✓; down: high 24% ✓, low 61% ✓;
  – a gap up more than 0.25 ADR: high 68% ✓, low 22% ✓; a gap down: high 15% ✓, low 78% ✓.
• [b]RTH range:[/b] VIX more than 10% over its average 1.26 ADR ✓; under 0.74 ✓.
• [b]New high / low after 09:30:[/b] after an overnight up more than 0.4 ADR, new high 81% ✓ and new low 26% ✓.
• [b]The gap:[/b] a small gap filled 81% ✓ and its 50% traded in NY AM 80% ✓.
• [b]DXY:[/b] once DXY's RTH move reached 0.52 of its ADR20, the index went the other way [b]81%[/b] vs 41% ✓.

[b]Side:[/b] a HYDRA search over everything knowable at 09:29 found no feature that called the direction out of sample on either day. Of 90 pre-specified direction tests, 5 passed the ✓ rule, about what chance gives at that many tries. Shirosaki's SIDE row shows the two that lean 60 / 40 or more, and says so in its tooltip:
• NFP week, after an overnight up more than 0.4 ADR: RTH closed up 69% vs 54% ✓;
• day after FOMC, with VIX within 10% of its average: NY AM went down 64% vs 42% ✓ (barely held in 2025–26).
Otherwise it reads [i]none held: size the day[/i].


[b]EVENT CLOCK AND TALLY[/b]

• [b]Event clock (pane):[/b] today's running range from 18:00 (or its net move) against NFP-week days, days after FOMC or normal days at the same time of day. It shows the median path with 25–75% and 10–90% bands, in half-hour steps at today's ADR20. A NOW status reads [i]Above[/i], [i]Inside[/i] or [i]Below[/i] the middle half.
• [b]Tally card:[/b]
  – the last N days after FOMC: up and down closes and their average RTH gap;
  – where price sits in this week's and this month's range, by octant;
  – the next Hollow day.
  [i]The octant is a locator, not a tested signal.[/i]


[b]SETTINGS[/b]

[b]View[/b] sits at the top, the same as in my other indicators:
• [b]Pane:[/b] clock + Shirosaki, the clock, Shirosaki, or cards only;
• [b]Clock measure:[/b] range or net move;
• [b]Theme:[/b] Auto follows the chart;
• [b]Layout:[/b] Desktop or Mobile;
• [b]Card text:[/b] tiny, small or normal.

[b]Model structure[/b] has on/off, colour and style for the NFP week's opening gap and the FOMC high / low, plus the gap octants, the settlement window, the week open, the RTH gap and the label size.

[b]Mobile[/b] folds the cards for a phone: a five-row stages card and a six-row Shirosaki. The full wording stays in the tooltips.


[b]HOW TO USE[/b]

• Built for [b]NQ / MNQ[/b], [b]ES / MES[/b] and [b]RTY / M2K[/b], continuous or front month. On other symbols the clock and tally show NQ's figures.
• 1 to 15-minute charts suit the levels. The live rows need 30 minutes or less, and the clock 60 minutes or less.
• Make the indicator pane tall enough for Shirosaki.
• For a phone, use a separate chart layout with [i]Layout = Mobile[/i], since chart layouts sync across devices.


[b]DATA AND METHOD[/b]

• NQ, ES and RTY front-month 1-minute data, Jan 2018 – Oct 2026.
• HYDRA: about 410 candidate features × 15 targets on 2018–24, kept against 20 shifted-target nulls, then a locked 2025–26 test and the same sign on each symbol.
• A row gets a ✓ only if all of these held:
  – p < 0.05 with errors clustered by date;
  – the same side in 2018–24 and in 2025–26;
  – the same side on each of NQ, ES and RTY.
• Many group tests were run across the calendar models, so treat the ✓ rows as the steadiest descriptions, not proven edges. The rows with the most days behind them (the gap on NFP-week days, the RTH range by month position and VIX, the FOMC high / low by month position) are the most dependable. The day-after-FOMC rows rest on 67 days.
• DXY rows: DXY futures, Feb 2023 – Jul 2026. On the chart they read TVC:DXY, which can be changed in the inputs.
• [b]ADR20[/b] = mean (high − low) of the last 20 complete trading days.
• NFP and FOMC dates come from the BLS and Federal Reserve schedules and are loaded to Dec 2027.
• No higher-timeframe value leaks future data.


[b]LIMITATIONS[/b]

[i]These are historical frequencies: useful context, not guarantees.[/i] Same-window DXY rows describe how the session finishes and cannot be known in advance. In Bar Replay, TradingView may not feed TVC:DXY minute by minute, so the DXY pills can read near zero there. Nothing here is financial advice.


[b]CREDITS[/b]

ICT concepts ([i]Michael J. Huddleston[/i]): the RTH gap and its 50%, the opening gap, premium and discount. Event clock after Kyōka Suigetsu. Part of the Hueco Mundo set; Shirosaki is Ichigo's inner hollow. Written from scratch; open source under MPL 2.0.

## Source Code

````pine
//@version=6
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Unclehk2000
//
// Hollow · Models 11–12: Monday–Thursday of NFP week (11 Hollow) and the day after FOMC (12 Full Bringer).
// On the price chart: the NFP week's opening gap (the prior week's last close, Sunday's open and its midpoint) drawn to
// the release, the 16:15–17:00 settlement window, the FOMC day's RTH high and low carried into the next day, the RTH gap
// (prior 16:14 close and its 50%) and, the day after FOMC, that gap in eighths over NY AM with the open-side quarter
// shaded; NFP and FOMC flags tied to their opens. Two cards, each in its own corner: the day-after-FOMC tally and the
// stages card, which reads whichever of the two days is current or next, led by where price sits in the month's range.
// Indicator pane: the event clock, and Shirosaki, the HYDRA findings table: what held for today's setup, in points at
// today's ADR20.
// Built for NQ / MNQ, ES / MES and RTY / M2K. The stages card and Shirosaki are pooled across NQ, ES and RTY 1-minute
// data, Jan 2018 – Oct 2026 (329 NFP weeks, 67 days after FOMC); the clock and tally use the chart's own symbol. A green
// key (✓) held: p < 0.05 with errors clustered by date, the same side in 2018–24 and 2025–26 and on each symbol.
// Release dates were checked against the BLS and Federal Reserve schedules and are loaded to Dec 2027; update once a year.
// Clock after Kyōka Suigetsu. Written from scratch.
// Concepts: ICT (Michael J. Huddleston).

indicator("Hollow", "Hollow", overlay = false, max_boxes_count = 300, max_lines_count = 400, max_labels_count = 400, max_polylines_count = 60)

TZ = "America/New_York"

// ═══════════════════════════════════════════════════════════════ Inputs
grpW = "View"
paneI   = input.string("Clock + Shirosaki", "Pane", options = ["Clock + Shirosaki", "Event clock", "Shirosaki", "Cards only"], group = grpW, tooltip = "What the indicator pane shows. Event clock: today's running range (or net move) against NFP-week days or the day after FOMC at the same time of day. Shirosaki: the HYDRA findings table for today's setup. Cards only: neither (the clock card stays where you put it).", display = display.none)
clkMet  = input.string("Range", "Clock measure", options = ["Range", "Net move"], group = grpW, tooltip = "Range: the day's high − low so far. Net move: price − the 18:00 open. Both in points, against the same measure on NFP-week days or the day after FOMC (2018–26), scaled to today's ADR20 of the trading day. Needs an intraday chart of 60 minutes or lower.", display = display.none)
themeI  = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = grpW, tooltip = "Auto follows the chart background.", display = display.none)
layI    = input.string("Desktop", "Layout", options = ["Desktop", "Mobile"], group = grpW, tooltip = "Desktop: every row. Mobile: narrow cards for a phone screen, the clock folded into the tally's NOW row; the full wording stays in the tooltips. Each card has its own place. For a phone, use a separate chart layout set to Mobile, since layouts sync across devices.", display = display.none)
crdSzI  = input.string("Small", "Card text", options = ["Tiny", "Small", "Normal"], group = grpW, display = display.none)

grpE = "Event day"
anchorI  = input.string("Trading day (18:00)", "Day", options = ["Trading day (18:00)", "NY midnight", "RTH (09:30–16:14)"], group = grpE, tooltip = "Which day counts as the event day for the tally.\nTrading day: the CME day, 18:00 → 17:00 ET.\nNY midnight: 00:00 → 17:00 ET.\nRTH: 09:30 → 16:14 ET (close of the 16:14 bar).\nThe clock always runs on the trading day.", display = display.none)
markEv   = input.bool(true, "Mark releases", group = grpE, inline = "g3", display = display.none)
markD    = input.int(90, "and model structure for the last (days)", minval = 5, maxval = 400, group = grpE, inline = "g3", display = display.none)

grpS = "Model structure"
showStr = input.bool(true, "Draw the model's levels and windows", group = grpS, display = display.none)
cLvl    = input.color(#ffb300, "Levels", group = grpS, inline = "s1", display = display.none)
cGh     = input.color(#26a69a, "Model", group = grpS, inline = "s1", display = display.none)
lblI    = input.string("Tiny", "Labels", options = ["Tiny", "Small", "Normal"], group = grpS, inline = "s1", display = display.none)
offI    = 12
showNW  = input.bool(true, "NFP week's opening gap", group = grpS, inline = "n0", display = display.none)
cNW     = input.color(#ffb300, "", group = grpS, inline = "n0", display = display.none)
stNW    = input.string("Dashed", "", options = ["Solid", "Dashed", "Dotted"], group = grpS, inline = "n0", tooltip = "The prior week's last close and Sunday's 18:00 open (dotted), with the midpoint, drawn to the NFP release.", display = display.none)
showFH  = input.bool(true, "FOMC high / low the day after", group = grpS, inline = "f0", display = display.none)
cFH     = input.color(#ffb300, "", group = grpS, inline = "f0", display = display.none)
stFH    = input.string("Dashed", "", options = ["Solid", "Dashed", "Dotted"], group = grpS, inline = "f0", tooltip = "The FOMC day's high and low (its 18:00–17:00 session), carried through the next day to 16:14. Shirosaki's FH / FL rows are how often the next RTH took them.", display = display.none)
showOct = input.bool(true, "Day after FOMC: gap octants over NY AM", group = grpS, inline = "s3", tooltip = "The day after FOMC: its RTH gap (FOMC day's 16:14 close → 09:30 open) in eighths from 09:30 to 11:00, the 50% line bold and the quarter next to the open shaded.", display = display.none)
cOq     = input.color(color.new(#26a69a, 78), "", group = grpS, inline = "s3", display = display.none)
showSet = input.bool(true, "NFP week: settlement window 16:15–17:00", group = grpS, inline = "w0", display = display.none)
cWin    = input.color(color.new(#2962ff, 90), "", group = grpS, inline = "w0", display = display.none)
showWO  = input.bool(true, "Week open", group = grpS, inline = "o0", display = display.none)
showGap = input.bool(true, "RTH gap", group = grpS, inline = "o0", tooltip = "The week's open (Sunday 18:00), carried right of price. RTH gap: the prior 16:14 close and the gap's 50% on Hollow days, from 09:30.", display = display.none)

grpK = "Event clock (indicator pane)"
clkOn  = paneI == "Clock + Shirosaki" or paneI == "Event clock"
kBands = input.bool(true, "10–90 and 25–75 bands", group = grpK, display = display.none)
kRef   = input.bool(true, "Reference path", group = grpK, tooltip = "On these days: the normal-day median. On other days: the next one's median, so you can see how its day usually unfolds.", display = display.none)
kPast  = input.bool(true, "Earlier days, faded", group = grpK, display = display.none)

grpR = "Cards (price chart)"
showEv  = input.bool(true, "Event tally", group = grpR, inline = "r1", display = display.none)
crdPos  = input.string("Top right", "", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = grpR, inline = "r1", display = display.none)
talN    = input.int(12, "last", minval = 3, maxval = 60, group = grpR, inline = "r1", tooltip = "The last N days after FOMC (up / down closes, average RTH gap), where price sits in this week's and this month's range in octants (top quarter = premium, bottom quarter = discount), and the next NFP week and day after FOMC.", display = display.none)
showCk  = input.bool(true, "Clock card", group = grpR, inline = "r3", display = display.none)
ckOn    = input.string("Indicator pane", "", options = ["Price chart", "Indicator pane"], group = grpR, inline = "r3", display = display.none)
ckPos   = input.string("Top right", "", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = grpR, inline = "r3", display = display.none)
cAcD    = input.color(#78909c, "Accent · DXY", group = grpR, inline = "r4", tooltip = "Stripe colour of the DXY rows. The tally, clock and stages cards use the Model colour.", display = display.none)

grpM = "DXY · VIX"
dxySym  = input.symbol("TVC:DXY", "DXY", group = grpM, inline = "m0", display = display.none)
vixSym  = input.symbol("CBOE:VIX", "VIX", group = grpM, inline = "m0", tooltip = "Read for the stages card: DXY's NY AM and RTH moves in its own ADR20, and VIX's prior close against its 20-day average.", display = display.none)
grpV    = "Stages card"
showSg  = input.bool(true, "Stages card", group = grpV, inline = "v0", tooltip = "Reads the current or next Hollow day: NFP week Monday–Thursday or the day after FOMC. The header pill is where price sits in the month's range (discount = bottom quarter, premium = top quarter), the setup that sized these days most. SETUP (live, then fixed at 09:29): the month, its open (NFP week) or the FOMC afternoon (the day after), the prior day (the FOMC day's range the day after), the overnight, the RTH gap and VIX. EXPECT (before 09:30): how far such days moved, at today's ADR20. LIVE (after 09:30): NY AM and RTH against DXY, the range since 09:30, the gap's 50% and fill. Pooled from NQ, ES and RTY. Needs a chart of 30 minutes or less for the live rows.", display = display.none)
sgOn    = input.string("Price chart", "", options = ["Price chart", "Indicator pane"], group = grpV, inline = "v0", display = display.none)
sgPos   = input.string("Bottom left", "", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = grpV, inline = "v0", display = display.none)
grpH    = "Shirosaki: HYDRA findings (indicator pane)"
showSh  = paneI == "Clock + Shirosaki" or paneI == "Shirosaki"
shPos   = input.string("Top left", "Position", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = grpH, inline = "h0", tooltip = "Shirosaki lists what held on pooled NQ + ES + RTY days for today's setup (NFP week Monday–Thursday or the day after FOMC), in points at today's ADR20, with the gap events live. Make the pane taller to fit it.", display = display.none)
cSh     = input.color(#546e7a, "Accent", group = grpH, inline = "h0", display = display.none)
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
CK_NQ = "8?8F8P8X8s8|9,929;9;9;9B9F9K9Q9V9_9i9p9z:,:-:>:B:P:S:V:Y:d:x:y;^<)<C<F<N<_<n<|=+=0=@=I=T=q=q8O8]8k8v919C9R9a9f9m9p9r9|:%:,:4:@:H:]:l:};#;(;,;4;;;?;F;U;h;w<e=6=S=|>/>6><>F>U>d>k>q?)"
     + "???D8t9-9@9V9v:0:A:M:Y:b:e:e:p:y;0;3;>;O;h;t<(<6<><K<S<X<c<i<t=,==>8?&?Z?x@&@B@C@H@S@k@rA+AQA[A]9_9|:>:V;%;A;a;n;x<!<(<4<?<B<P<S<_<q=:=K=[=h=~>+>5><>S>a>v?3?I@dAgB<B_ByC+C9C[D8DfE#"
     + "E9EbElEl:z;C;l;q<?<P<l=*=2=R=]=d=n>/>5>B>d>~?9?Y@'@:@U@U@Z@aA'A,A7A;AKC=DzEsFLFqFyG7G_HJHVHiIpJ7J9JI6`6]6L6E6%5}5t5s5U5I5Q5<5-585.4s4t4u4;4T4R444'3~3p4=3s3d3S3G322*1@0%0N/H/I/F00/a"
     + "/3.X.t.D.R.W7=737.7!7#6r6l6]6^6]6V6]6I6J6C6J6@6J6K6V6P6-626.6/6:63655z5`5_5I5-5A5&4z4l4e4e4z4|4O4-4A4+4$7e7f7g7g7l7j7k7m7m7m7r7u7n7l7o7q7l7p828.878<8/84878%8&8-878%8(80868;8N8c8K8<"
     + "8C8L8I8Q8]8z8r8d8.8;8E8L8Z8i8y9&8z8w9!9#9)9/9.929C9R9X9a9b9c9g9v:#9{:!:$:/:.:%:f:q;-;L;Z;r;r;o<4<7<?<^<x<z<z8w9(9D9U9_9y:':F:M:]:l:_:i:o:q:u;2;9;P;D;Z;X<%;p<1;w<'<-<J<N<U=/=i>9>k?_"
     + "?w?t?a?d@5@M@]@y@kA&9)9<9T9i:1:?:X:p:v;+;7;7;>;D;K;S;g;r<-<@<Q<k<q=&=0=7=C=I=Y={>(?4?|@P@{A6ANAgAuB/BJBZBZBZBZBZ8E8N8[8e8p8x9.9B9M9U9`9`9`9l9l9l9l9s:7:N:S:n:};';K;O;R;X;g<-<9<a=U=s"
     + ">G>]?.?B?C?C?Q?S?T?T?T?T8T8d8r8|9,9B9Y9p9y:,:3:7:7:9:F:H:S:f:~;;;M;h;u<,<5<5<A<U<i<|=4>B?6?f?|?|?~@!@4@R@d@m@v@xA;A[9$979M9T9}:-:M:T:r:~;1;8;8;:;:;a;t<$<Q<q=P=Y=Y=Y=c=n>#>#>'>{?%@9"
     + "A9AhAhBdBdBxBxCCCECICsD_DnE#9W:):O:l;L;W<#<E<k<|=6=I=I=T=Y=Y=d=i>(>Z?/?|@*@-@-@.@.@A@I@~@~BrD5DhE,EWF*F*F7G?GJGgGgGgHcI.:M:c;K;[=N=N=V=}>7>7>k>y>y>y?;?;?U?t@X@x@xA&ATA]AcAdAkB5B?C)"
     + "CvDvEyFgHNI2I2IgJMJmJ|KML%LILIM'7!7%6u6s6^6J6>5]5Z5}5x5.4g5O525C4z3q3V2E3=2}2O2y2A1p1i1a1o0m1V0n1)05/`.q-y./.9.4,#+_+:*q*p+97Z7L7Y7^7V7^7F7@7B7#7&6w7=7'6~6Z6s6P5p695r5l5V5Q5O5]5G5b"
     + "565'4k4~4>3N3R2Q3K3?3-2|3F3@3.3,4-4!81858?8<8O8u8q8v8|8Z8~8w8`8h8a8g8H8]909P8}8v8r8j9,9N8E9)8}8[8]9+839!8m9n808m8T9=8<848j8)8s8v8i8v9-9F9g9s:%:5:B:^:b:e:N:F:N:U:G:d;);F:~:s;N;<;1;3"
     + ";L;E;b;z;h=B>?>p>:?$>t?!@A?)>;>|?]?-?G?p9F9J:.:e;-;5;^;^;i<><C<O;|<1<7<.;x<'<O<y=(=O>?>;>->#=T=a>%>n>G?WAWAQB2B^B7B/BrCQCIBRAiBrBsC<8j9#969J9d9v:6:K:S:b:f:s:|:};!;$;5;?;]<%<@<B<Z<_"
     + "<e<e<p<v=7=q>&?J?y@]@pA+A7AHAJAwB8BZBZBZBZBZ8<8E8N8Z8l8v9$9,9295989:9?9@9B9J9R9Y9l9s9~:*:4:9:=:B:I:T:b:l:q;V;w<0<A<L<Y<b<k<v=$=(=+=7=F=H8K8W8f8v9/9>9H9S9^9c9g9j9l9o9u9~:-:5:I:U:f:n"
     + ":t:|;&;.;6;>;F;U;`<Q<~=<=T=h=z=~>3>;>I>S>Y>j>q>s8k8~949D9d9t:&:5:C:K:S:W:_:b:h:q:~;0;H;V;f;u;|<'<.<<<G<N<[<r=#>'>Y?)?E?[?s@+@4@E@O@a@sA*A9A=9C9[9{:1:[:{;2;E;O;Y;e;k;s;v;~<,<@<R<n<}"
     + "=9=G=Z=c=r>!>,>>>Q>q?#@0A&APAzB6BPBgBxC,CBCXCuDADLDV:K:u;1;V;x<@<R<n=3===@=T=]=d=n=x>;>K>g?(?I?R?v@.@8@G@U@g@uA9AHBoCaDGE(ENEjF.FEFoG-GIGiH-HCHR6u6c6Q6C615p5X5V5K5D5A5>53545)5)5&4m"
     + "4`4V4G4G4:4-4+444,3c3`3P3Q2Q1W1C1!0~0r0U0E0F/z/v/K/E/2/#7C7>777.6}6|6w6r6m6i6l6j6m6g6c6a6X6]6N6F6@6@686464616?606/6&5{5N555+5/4{4g4n4h4m4U4C4B4G4A4@7k7m7r7s7w7u7w7u7w7v7u7u7u7w7x7{"
     + "8%8#8%8&81828,868/878;8@8484808*8*8:858=8C8>85858E8D8H8E8L8N888?8L8R8c8l8w8|9!9&9'9+9*91939?9H9M9V9`9e9o9s9x9r9}9x9x:$:6:3:m;,;%;A;_;];k;l<&<0<9<;<O<Q<b8k8x909<9X9g9v:0:0:6:>:G:M:I"
     + ":O:]:g:s:|;4;K;L;T;V;c;[;^;h<)<?<C=K=a>/>F>t?%???R?Z?T?f@;@5@4@B8|949K9c:(:::O:_:n:u;#;(;,;3;=;E;U;g<%<8<K<W<e<r<~=+=7=L=]=~>.?H@)@^A*AKAcAuB,BDBZBZBZBZBZBZ"
CK_ES = "8@8M8Y8_8s8}9+999>9B9E9I9K9R9S9V9^9i9t9w:+:/:4:8:?:H:M:U:f:s:v;G;_;u<!<2<E<V<V<X<h<n<z=;=;=;8U8e8u9$9B9P9_9f9q9s9z9}9~:$:.:5:<:F:]:j:u:v;.;1;2;8;C;D;N;i;v<J=(=B=X=d=r=z>)>/>@>F>N>n"
     + ">z>|8v989J9d:$:5:E:U:h:l:p:r:w;!;);1;B;M;h<&<2<B<N<R<_<i<k<v=&=9=T>0>c?+?J?b@#@5@D@L@c@hA!A>ADAF9f9|:G:i;,;Q;b;y<)<3<@<F<X<g<i<l<y=)=R=s=x>$>5>A>_>a>v>}?4?R?_@RA^B2BRC5CRCfCzD6DMDZ"
     + "E.EHEaEt;+;Q;j<A<g<r=$=?=Q=W=m=w>$>)>3>=>h>{?B?x@>@L@w@w@wA'A<ALAmApB0CKD}E^FLF^GEH'HEIAISJ%JVK5K;KS6P6Q6;626+5v5q5W5S5C5:4y4w4{5!4k4l4n4,4P4.453~4(3u423u3G3(2x2j211+0'/u/h/W/6.o/P"
     + ".H-}-_.7.Y.U797+7*6~6n6o6o6f6k6d6_6d6Y6V6S6D6U6A6D6H6O606$5z6'5z6+5b5l5j5_5R4|4z4p5/4m4^4V4_4a4Q4,3w3x3W7c7b7b7k7s7k7q7u7t7m7v7s7r7r7|7x7q7x837z8.848-848-7u7y828#7}7~8!8(878-8B858R"
     + "868G8:89848S8c8N878A8H8T8c8i8t9,9!9$919+9-959/9:9<9U9j9u9k9z9o:.:3:):$:4:=:G:D:d;8;K;Y;w;t<8<7;v<8<C<a<z=6=,9(9,999K9d9~:.:M:L:a:n:n:t;!:o:|;.;G;^;[<(;y<.<;<S<C<C<N<S<v<z=C>7><?L?H"
     + "?i?t?j@.@;@6@Y@k@xA%939H9b9v:7:O:b:q:{;.;4;:;A;I;Q;T;j<#<:<P<_<t<}=$=7=B=N=V=p>#>2?5?q@=@kA%AJA[AiB&BABXBZBZBZBZ8G8Q8f8s9!9*969O9j9q9q9w9w9|9|9|9|:#:=:=:P:P:V:};D;H;M;S;o<-<B=!=h=h"
     + "=u>9>]>c>c?*?7?f?f?f?j?j8e8q8~909=9P9k:!:*:5:<:>:>:@:K:P:V:V;,;C;O;Q;n;w<-<4<7<^<z=B=M>7?.?h?h@!@H@^@_@j@n@z@{@{@{A)8~979C9U9{:6:O:r;$;(;+;I;I;I;N;N;b<+<d===Q=U=U=U=y=~>I>P>U>m?1@E"
     + "@oAmBZB[BiBiBiC(CoD=D=DWD_Dt9P:7:`;/;h<!<8<x=:=?=?=M=T=c=n=n=q>C>k?E?[?p@9@9@9@C@T@p@xA_AlC%CzDSE)EGEOEmF2GLGYH4HlIMIsJS;/;6<-<E=Q=R=l>->w?7?O?f?f?f?s?s?z@0@gA$A/ASB$BNBQBQB`B`BmC_"
     + "C{E(FLH8IVJXJXJaKrL3LWLWLqMaMaMa7(6t6_6>695l5r5=5E5T5N4h4W4r4A4r5%3E2C282o3)1Y221]1f0w1k1E0&00/d/U-s-^,V.',_.^-h-8,t*z**)c*?7W7J7G797:746p6]6b6b6^6i6w6j6|6e6l6B6,6+635x5p5L5f5Y515a"
     + "4y4{4m5+4D4+4%3=3[4)3i4#2~2S2v2j3?3+8+8<84828H8Z8Z8r8i8J8_8d8@8O8G868F8T8o8^8B8<8c8&8P8f828`8f9H9*9R9w8{959O9(9U9T96968^8S9:9H9l8g8x8y9:9^9z:N:9:D:<:V:E:7:9:.:I:`:`;1;8:t;-;B:z;>;3"
     + ";F;M;_;o;s</<v=)=/=A=z=R=s=p=3=8=1<w=8>'9=9S9}:M:y;);D;p<:<.<T<T<M<;;i;x;k<6<a=i=g=b>Z>`=r=t>%=}>U>;>&@^A_A_@3ATARAnAXB7BJDECkB{CMC79$9*999H9]9|:2:X:[:f:g:g:g:u:u;1;7;K;c;r;x<1<h<h"
     + "<y=(=2=@=]>'>2>z?j@T@oA)AXA_AiA{BABZBZBZBZBZ8>8G8S8`8q8}9(9196989<9>9B9D9H9L9T9[9j9v:#:):/:5:<:C:J:O:Z:i:m;7;T;m;y<(<-<4<<<J<X<h<p=&=-=38P8^8n8|959C9M9X9_9e9i9m9o9s9y:%:/:7:K:Z:f:p"
     + ":y:~;(;.;5;=;G;];h<2<S<q=/=?=Q=]=g=o=x>(>3>U>^>`8p9&999K9l9}:/:?:I:Q:X:Z:a:g:m:w;);1;K;_;n;v<#<,<6<?<K<U<b<}=1=p>B>e?#?/?I?_?n?y@.@>@V@p@~A&9H9d:':>:_:};6;P;^;l;q;x;}<*</<;<K<]<~=7"
     + "=P=m=}>/>:>F>M>b>p?$?2@(@oA?AgA~B:BWBvC@COCcC|DDDODT:P;#;<;a</<B<a=3=E=[=a=i=x=}>0>=>Y>k?5?P?a?n@%@2@M@_@vA>AKAhB)C.CyDZE#EUEsF4FeG,GdGrHII3I;IM6o6^6K6@6)5s5[5O5G5C575:5%5.4v4w5)4o"
     + "4Q4K464+4(4'3r3w3}3^3Q373>2Z271|1R1C0{0S0N0=0@/{/f/A/M/=7B7<757(6{6v6n6m6b6`6h6b6_6]6Y6Z6P6N6@656<6764626+616.6/6,6#5|5p5W5O5O575,5.5&4|4r4q4s4M4E4?7m7p7q7r7q7q7s7w7w7s7x7v7x7y7s7w"
     + "7{8!8$8*8+8+8*8.80878/818/828488818<888=84838=8C8F8U8N8F8N8H8:8B8L8Q8c8n8t8t8}9$9(9)9.9/929<9H9J9P9]9l9n9w9x9z9{:*:0:.:<:8:W:p:y;%;);G;J;R;m;z<&<3<D<N<Q8m8x909@9]9g9s:%:-:3:<:A:J:Q"
     + ":N:[:j:d:};4;I;V;V;_;b;p;n;l<!<7<>='=P=h>9>H>a?*?5?Y?a?s@#@D@E@J9%9=9V9o:4:H:Z:j:{;(;0;5;=;A;K;R;f;s<2<H<a<p<~=,===E=T=d=w>6>F?6?z@@@fA.AHAZAxB5BMBZBZBZBZBZ"

CK_RTY = "8<8L8R8Y8l8{9'9-92989<9>9@9A9C9L9R9X9i9u:(:.:1:5:>:B:F:G:N:X:j;q<B<p=3=9===Q=T=i=v>&>(>3>6>68Q8_8l8v949C9S9W9^9c9l9o9q9s9u:#:,:0:C:R:a:d:n:u:|;,;0;8;C;Z;h<~=h>/>M>h>s?'?.?0?1?8?H?]"
     + "?_?f8q9*9A9U9h9x:1:?:J:M:P:P:S:_:g:j:{;,;K;T;b;k;z<'<2<:<K<U<c<s=!>T?^@8@cA!A'A8A=AGAMATA]AuA}B!9_9w:6:H:g:~;3;M;P;[;n;r;z;{<#<(<6<G<c=#=:=>=O=`=l>$>->F>K>k>|@oA[B0BIC%C=CYChCyDBDY"
     + "DhE/E/E/:p;,;_;e;x<%<?<U<X<k=#=%=0=4=b=v>+>/>T>j?F?H?g@#@1@1@G@Z@{A!A2BxC~DUE8EMF-FJG%GCGZGmHsHyI/I/6^6U68636*6'5p5m5d5Z5W5A5G545B56535+4n4d4G4L3r424;4T4J3o4&3T3C2L1a0f04080!/e/h/d"
     + "/A/=/./8/Z/77<747$6~6}6u6r6j6g6c6f6^6^6]6Y6L6I6Q6P6B6N616=656?6>625{5~6,5}4~433|3p3J3K3G373.2r2q2w3(3/3*7i7_7l7i7j7n7r7q7v7r7w7t7r7q7y7q7{7v8)8+8#8%8$8(8*7|8+838@8<8=7O7r7q7z807u7V"
     + "7X7u7l7i7g7s7o7c888?8K8W8e8r8w9!9!9!8|8~9%9-9&9.929L9[9_9d9v9d9y:*:!9z:.9}:!:(:S;>;P;u<,<*<G<'<?<A<c<U<q='<s8|9+9=9=9N9o:(:*:7:;:N:O:T:o:Y:j:_:p;.;A;X;a;`;b;`;Z;p;t</<0<5=E>$>E>R>w"
     + "?H?f?o@.@I@+@I@p@e@n9!989P9a9z:1:?:R:V:b:g:l:q:v;!;*;3;<;`;n<%<5<=<A<W<d<s<x=.=D=^?<@P@}ATAiA}BCBNBZBZBZBZBZBZBZ8I8M8Y8c8t8}9*9;9<9L9L9Y9Y9]9]9d9f9s:*:B:P:P:_:g:{;9;>;G;[<*<N<y=[=q"
     + "=v>[>[>[>y?;?I?i?s@,@,@28a8e8t8x9+949Q9d9x9{:':.:.:.:2:?:C:C:u;#;+;V;[;a<%<N<N<Y<x=<=T>E?0?S?{@.@B@Q@Q@Q@k@mAPAQAaAj8w949J9^9d9z:B:P:h:l:~;-;4;<;?;?;G;g<%<]<n<|=#=:=S=a=e=q>/>J>y@%"
     + "@zA`ArB6BbBbC!C%CgC~DKDgDgDg9R9m:3:e;,;L;f;u<6<6<J<W<Y<Y<Y<[<s=#=E=e=}>B>c?'?'?4?C?N?[@D@vB>C#DiDlDyEWEWEgFwF|G1G1GMGMGP9r:G;:;k<d<d=+=F=k=y>%>W>t>t>t>u?^@#@RA#A#AIAWAWAWAWA_AuBVCc"
     + "DME3ETFhI6I6ITITITJCJCJZJZK9K9K96w6.6N6S695j5l5I5B5g5m5Y5>5K4}5_5N5-4*3m4(3i2x2l2z2s2?2F2q2X2J180E/7.y.`-2.U.(-B.+.@.Q,t,L+x7P7S7J7-72777'6W6w6f6p6u6q6y6p6X6U6U626%6L6%6%6/5n5L5G5)"
     + "4}4u4i5?413:3W383n364+3F1Q1{1Q2F2:1y8*867z7}8:8;8Y8M8A8=878?8)868<8?8=7p888F8N8L89818@8I8.8;8>8r8u8p8k8B8;7e8:8'7>7B7)7W6~7M7V7l8D8Y8j8~939T9g9v:6:$:V:Y:1:#9w:':'9t:J:q:g;#:|;,;A;X"
     + ";<;j;2;K;a<<</;Q<(<M<I<4=:<Y<U=O=<=n=^>J8y939b:=:8:F:w;!;C;,;W;R;G;<;':~;);g<R<^<?<2<O=3=0=+<r=`=o>>>W?,?z@K@a@o@hA!AZBDA4A7A'B?B4B]8l8~9-979T9p9z:D:K:X:`:k:k:k:p:x:{;/;G;i;x<'<;<N"
     + "<Z=#=&=6=J=q>,>{?w@]A-AOAaAdB#B4BUBZBZBZBZBZ8<8E8O8Y8h8t8|9#9+9-909396989<9@9J9P9c9l9x:$:):/:4:<:C:J:W:d:l;l<<<^<m<w='=/=>=F=L=S=]=q=u=v8M8W8e8s9(939?9J9P9U9Z9^9b9d9h9n9w:#:5:C:Q:["
     + ":c:g:o:u;%;-;9;O;a<m=@=d>'>9>G>T>_>e>j>s?$?3?7?88h8z9/9=9X9j9w:':0:6:?:B:G:M:Q:X:b:n;%;8;H;S;a;j;v<#<+<4<@<b<q>?>x?>?`?o@+@<@T@e@q@{A-A>ABAC9?9X9w:):J:a:s;&;7;A;G;P;V;Z;c;g;w<!<A<["
     + "<k=$=2=>=O=[=h=v>0>K>]@0A!ASAxB?BXBmB~C0CBCWCeCyC~D%:D:l:};?;g<#<3<W<j<s<y=$=&=-=:=F=Y=i>6>O>c>s?)?A?H?X?j@#@<@`@|BUCTD%DXE-EJEwF6F:FIFZFmG=GEGJ6p6d6T6E625y5l5g5Z5]5U5O5I5N5A5:575*"
     + "4x4j4W4F4C4>434<4;413|3Y3]2R1`1@1(0z1)0p0E0=0600/m/R/p/|7C7@757)7#6z6v6q6k6k6o6g6d6d6h6g6^6]6U6F6D6@686;62656.6'6#5u5n5=4m4Z4S4E464;4,4$4'3r3p3X3g3a7m7l7o7m7k7p7n7p7r7s7v7q7s7t7r7v"
     + "7v7t7w7z7{7y7y7}7|8%8(8(8&8/8%838)7s7~847~8#8*8*888@88828885888>8G8M8[8a8j8i8l8p8t8x9!8~9(9*9/93999?9O9T9^9a9a9n9s9w:$:.:3:v;5;9;?;M;Z;`;m;}<.</<<<5<<<>8f8w9/9=9J9X9`9p9u9{:&:':*:1"
     + ":3:=:E:J:g:y;.;<;D;A;I;S;N;_;e;v;}=7=i>1>U>R>y?&?:?M?R?e?t?~?~?z8x9.9D9V9r:*:9:F:Q:]:b:h:k:p:w;!;/;:;X;k;}<6<D<O<Y<i<s=#=2=P=b?C@9@lA:AWAtB.BKBZBZBZBZBZBZBZ"
int  AN    = anchorI == "Trading day (18:00)" ? 0 : anchorI == "NY midnight" ? 1 : 2
bool isES  = syminfo.root == "ES" or syminfo.root == "MES"
bool isNQ  = syminfo.root == "NQ" or syminfo.root == "MNQ"
bool isRTY = syminfo.root == "RTY" or syminfo.root == "M2K"
string symR   = isES ? "ES" : isRTY ? "RTY" : "NQ"           // whose clock and tally the chart shows
string symTag = isNQ or isES or isRTY ? syminfo.root : syminfo.root + " (" + symR + " DATA)"
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
var array<float> CK = unpackMilli(isES ? CK_ES : isRTY ? CK_RTY : CK_NQ)
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
lbSz  = lblI == "Small" ? size.small : lblI == "Normal" ? size.normal : size.tiny
lsOf(string s) => s == "Solid" ? line.style_solid : s == "Dotted" ? line.style_dotted : line.style_dashed
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
        0 => "M11 HOLLOW · NFP week Monday"
        1 => "M11 HOLLOW · NFP week Tuesday"
        2 => "M11 HOLLOW · NFP week Wednesday"
        3 => "M11 HOLLOW · NFP week Thursday"
        4 => "M12 FULL BRINGER · day after FOMC"
        => ""
ownTy(int k) =>
    switch k
        0 => 5
        1 => 5
        2 => 5
        3 => 5
        4 => 3
        => 6
TAL_NQ = "20180201,-1,-1,-37.0,-0.532;20180322,-1,-1,-104.0,-1.511;20180503,1,1,-17.75,-0.268;20180614,1,1,36.75,0.51;20180802,1,1,-48.5,-0.667;20180927,1,1,35.75,0.471;20181109,-1,-1,-69.0,-0.963;20181220,-1,-1,-19.25,-0.304;"
     + "20190131,1,1,12.0,0.176;20190321,1,1,-20.25,-0.273;20190502,1,-1,8.5,0.11;20190620,1,-1,99.0,1.29;20190801,-1,-1,17.0,0.216;20190919,-1,-1,7.25,0.092;20191031,-1,-1,1.75,0.022;20191212,1,1,-12.75,-0.152;"
     + "20200130,1,1,-44.0,-0.484;20200430,-1,-1,-22.5,-0.249;20200611,-1,-1,-156.5,-1.552;20200730,1,1,-108.5,-1.016;20200917,-1,1,-303.5,-2.694;20201106,1,1,-73.5,-0.607;20201217,1,1,63.5,0.501;20210128,1,1,185.75,1.432;"
     + "20210318,-1,-1,-206.5,-1.564;20210429,-1,-1,109.0,0.782;20210617,1,1,-32.0,-0.229;20210729,-1,-1,-12.25,-0.082;20210923,1,1,39.0,0.257;20211104,1,1,52.0,0.322;20211216,-1,-1,38.25,0.235;20220127,-1,-1,259.25,1.842;"
     + "20220317,1,1,-78.75,-0.564;20220505,-1,-1,-156.0,-1.156;20220616,-1,-1,-281.75,-2.434;20220728,1,1,40.0,0.318;20220922,-1,-1,-54.75,-0.468;20221103,-1,-1,-95.75,-0.876;20221215,-1,-1,-194.75,-1.655;20230202,1,1,182.5,1.46;"
     + "20230323,1,-1,155.5,1.224;20230504,-1,-1,-41.75,-0.318;20230615,1,1,-65.25,-0.434;20230727,-1,-1,183.5,1.172;20230921,-1,-1,-145.5,-0.961;20231102,1,1,179.25,1.216;20231214,-1,-1,45.0,0.272;20240201,1,1,38.25,0.222;"
     + "20240321,1,-1,155.25,0.838;20240502,1,1,123.25,0.706;20240613,1,-1,158.0,0.811;20240801,-1,-1,-13.5,-0.069;20240919,1,1,411.0,2.118;20241108,1,1,-52.0,-0.245;20241219,-1,-1,247.0,1.168;20250130,1,-1,147.5,0.686;"
     + "20250320,-1,1,-178.5,-0.903;20250508,1,-1,183.5,0.918;20250620,-1,0,,;20250731,-1,-1,80.0,0.338;20250918,1,1,171.0,0.705;20251030,-1,-1,-105.0,-0.4;20251211,1,1,-144.75,-0.561;20260129,-1,0,,;"
     + "20260319,-1,1,-195.75,-0.795;20260430,1,1,358.5,1.321;20260618,1,1,566.75,1.887;20260730,1,1,576.75,2.113;20260917,1,1,448.25,1.547"
TAL_END_NQ = 20261009
TAL_ES = "20180201,-1,1,-12.75,-0.451;20180322,-1,-1,-29.75,-1.094;20180503,1,1,-4.25,-0.162;20180614,1,-1,12.0,0.432;20180802,1,1,-13.5,-0.48;20180927,1,1,5.75,0.197;20181109,-1,-1,-16.25,-0.578;20181220,-1,-1,-10.5,-0.419;"
     + "20190131,1,1,-3.5,-0.13;20190321,1,1,-6.5,-0.23;20190502,1,-1,-0.25,-0.009;20190620,1,1,27.25,0.929;20190801,-1,-1,2.5,0.084;20190919,-1,-1,4.5,0.15;20191031,-1,-1,-4.25,-0.139;20191212,1,1,-1.75,-0.056;"
     + "20200130,1,1,-22.25,-0.68;20200430,-1,-1,-25.5,-0.867;20200611,-1,-1,-73.5,-2.308;20200730,1,1,-34.0,-1.045;20200917,-1,1,-55.5,-1.642;20201106,1,1,-12.75,-0.363;20201217,1,1,17.25,0.467;20210128,1,1,51.25,1.379;"
     + "20210318,-1,-1,-28.75,-0.725;20210429,1,-1,27.75,0.664;20210617,1,1,-4.5,-0.107;20210729,1,1,11.25,0.256;20210923,1,1,17.75,0.405;20211104,1,1,6.5,0.14;20211216,-1,-1,18.75,0.399;20220127,-1,-1,58.25,1.345;"
     + "20220317,1,1,-18.75,-0.431;20220505,-1,-1,-38.25,-0.892;20220616,-1,-1,-82.75,-2.183;20220728,1,1,15.75,0.392;20220922,-1,-1,-8.5,-0.223;20221103,-1,-1,-32.5,-0.863;20221215,-1,-1,-62.25,-1.542;20230202,1,-1,32.0,0.773;"
     + "20230323,1,-1,23.75,0.598;20230504,-1,-1,-19.75,-0.48;20230615,1,1,-12.5,-0.286;20230727,-1,-1,30.75,0.669;20230921,-1,-1,-28.5,-0.641;20231102,1,1,38.75,0.911;20231214,1,-1,16.25,0.345;20240201,1,1,11.25,0.231;"
     + "20240321,1,-1,20.25,0.382;20240502,1,1,32.75,0.648;20240613,0,-1,18.75,0.346;20240801,-1,-1,11.0,0.198;20240919,1,-1,86.25,1.531;20241108,1,1,-1.75,-0.029;20241219,-1,-1,59.0,1.006;20250130,1,1,24.5,0.404;"
     + "20250320,-1,1,-42.0,-0.739;20250508,1,-1,37.5,0.664;20250620,-1,0,,;20250731,-1,-1,15.0,0.233;20250918,1,1,22.25,0.337;20251030,-1,-1,-28.5,-0.412;20251211,1,1,-23.25,-0.337;20260129,-1,-1,4.75,0.068;"
     + "20260319,-1,1,-35.0,-0.529;20260430,1,1,62.25,0.872;20260618,1,0,,;20260730,1,1,78.0,1.063"
TAL_END_ES = 20260828
TAL_RTY = "20180201,1,1,-9.0,-0.570;20180322,-1,-1,-13.6,-0.858;20180503,-1,-1,-1.4,-0.090;20180614,1,1,6.3,0.375;20180802,1,1,-6.4,-0.384;20180927,1,-1,4.2,0.248;20181109,-1,-1,-11.9,-0.752;"
     + "20181220,-1,-1,-0.2,-0.015;20190131,1,1,-3.3,-0.222;20190321,1,1,-4.3,-0.278;20190502,1,1,-0.7,-0.044;20190620,1,-1,14.7,0.943;20190801,-1,-1,2.9,0.184;20190919,-1,-1,3.6,0.229;"
     + "20191031,-1,-1,-4.9,-0.311;20191212,1,1,-0.5,-0.031;20200130,1,1,-11.6,-0.703;20200430,-1,-1,-36.4,-2.678;20200611,-1,-1,-60.0,-4.094;20200730,-1,1,-20.4,-1.363;20200917,-1,1,-23.2,-1.496;"
     + "20201106,-1,-1,0.8,0.048;20201217,1,1,7.1,0.363;20210128,-1,-1,28.0,1.338;20210318,-1,-1,-15.4,-0.660;20210429,-1,-1,22.6,0.983;20210617,-1,-1,-7.3,-0.316;20210729,1,1,17.3,0.779;"
     + "20210923,1,1,10.6,0.478;20211104,-1,-1,7.8,0.325;20211216,-1,-1,13.7,0.623;20220127,-1,-1,22.7,1.154;20220317,1,1,-11.7,-0.577;20220505,-1,-1,-17.6,-0.905;20220616,-1,-1,-38.3,-2.213;"
     + "20220728,1,1,11.1,0.601;20220922,-1,-1,-3.1,-0.175;20221103,-1,1,-21.1,-1.178;20221215,-1,-1,-26.4,-1.436;20230202,1,1,17.0,0.864;20230323,-1,-1,9.3,0.533;20230504,-1,-1,-16.5,-0.943;"
     + "20230615,1,1,-11.3,-0.596;20230727,-1,-1,12.1,0.608;20230921,-1,-1,-12.7,-0.696;20231102,1,1,24.2,1.445;20231214,1,1,29.1,1.474;20240201,1,1,12.4,0.634;20240321,1,1,7.2,0.342;20240502,1,1,18.4,0.922;"
     + "20240613,-1,-1,-6.6,-0.320;20240801,-1,-1,-3.5,-0.154;20240919,1,-1,47.9,2.143;20241108,1,1,-9.2,-0.383;20241219,-1,-1,28.6,1.270;20250130,1,-1,16.2,0.704;20250320,-1,1,-23.1,-1.099;"
     + "20250508,1,1,23.0,1.152;20250620,1,-1,12.7,0.596;20250731,-1,-1,-2.1,-0.094;20250918,1,1,19.2,0.791;20251030,-1,-1,-17.6,-0.705;20251211,1,1,-7.2,-0.280;20260129,-1,-1,6.8,0.255;"
     + "20260319,1,1,-22.0,-0.885;20260430,1,1,18.2,0.664;20260618,1,1,43.5,1.477;20260730,1,1,31.3,1.076;20260917,1,-1,42.1,1.462"
TAL_END_RTY = 20261009
TAL_NAME = "day-after-FOMC"
talIs(int k, int pk) => FO.includes(pk)
ownCk(int k) =>
    switch k
        0 => 0
        1 => 0
        2 => 0
        3 => 0
        4 => 1
        => 0
ckName(int k) =>
    switch k
        0 => "NFP week"
        1 => "FOMC +1"
        2 => "Normal"
        => ""
ckN(int k) =>
    switch k
        0 => isES ? "324" : isRTY ? "333" : "323"
        1 => isRTY ? "68" : "67"
        2 => isES ? "1416" : isRTY ? "1441" : "1342"
        => ""
hollowDay(int k) =>
    int  dw = dowOf(k)
    bool h  = false
    if dw >= 2 and dw <= 5
        for j = 1 to 6 - dw
            if NP.includes(addDays(k, j))
                h := true
    h
hollowNext(int today) =>
    int n = nextOf(NP, addDays(today, 1))
    int m = na(n) ? na : math.max(addDays(n, 2 - dowOf(n)), today)
    int f = nextOf(FO, today)
    int p = na(f) ? na : addDays(f, dowOf(f) == 6 ? 3 : 1)
    [m, p]
ownProfile(int tk, int pk, int today) =>
    int  k   = 0
    bool now = false
    int  d   = na
    if FO.includes(pk)
        k := 4
        now := true
        d := tk
    else if hollowDay(tk)
        k := dowOf(tk) - 2
        now := true
        d := tk
    else
        [m, p] = hollowNext(na(tk) ? today : math.max(tk, today))
        k := nz(m, 99999999) <= nz(p, 99999999) ? 0 : 4
        d := k == 0 ? m : p
    [k, now, d]
ownNext(int today) =>
    [m, p] = hollowNext(today)
    ["NFP week", m, "day after FOMC", p]


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
// ADR20 of the trading day from daily bars (as Kyōka): a 1-minute chart or Bar Replay often loads fewer than the 15 days of
// 15-minute bars the line above needs; the daily bars (the CME 18:00–17:00 trading day) always have them.
// The 15-minute figure stays as the fallback.
float adrD = request.security(ticker.modify(syminfo.tickerid, backadjustment = backadjustment.off), "D", ta.sma((high - low) / open, 20)[1], lookahead = barmerge.lookahead_on)
ADRtd := na(adrD) ? ADRtd : adrD
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
int  talEnd = isES ? TAL_END_ES : isRTY ? TAL_END_RTY : isNQ ? TAL_END_NQ : 0
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

// ═══════════════════════════════════════════════════════════════ Hollow stages (NFP week · day after FOMC)
// Both days read at 09:29 (the RTH open): NY AM = 09:30 open → 10:59 close; RTH = 09:30 open → 16:14 close.
fdSg(float v, string f) => na(v) ? "—" : (v >= 0 ? "+" : "−") + str.tostring(math.abs(v), f)
vzSg(float v) => na(v) ? "—" : (v >= 0 ? "+" : "−") + str.tostring(math.abs(v), format.mintick)
vzAr(float v) => na(v) or v == 0 ? "·" : v > 0 ? "▲" : "▼"
// VIX: prior close and its 20-day average (completed days)
[vxC, vxA] = request.security(vixSym, "D", [close[1], ta.sma(close, 20)[1]], lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
// The stages card's and Shirosaki's statistics: NQ + ES + RTY pooled (329 NFP weeks, 67 days after FOMC), read at 09:29,
// in ADR20 of the trading day; −1 = too few days. Groups run up / middle / down in the order the code names them.
// NFP week 0–57: |NY AM|, RTH range, settlement range, next day's range by the month's position (median, 80th) · 24–41
//   new high / low after 09:30 by prior day, overnight, month · 42–47 RTH range by month's open, VIX · 48–53 gap 50% by
//   10:00, then filled by 16:14, by gap · 54–57 gap 50% by 10:00, Mon–Thu
// Day after FOMC 58–102: |NY AM|, RTH, next day by month · 76–87 new high / low by the FOMC day's range, overnight · 88–93
//   took the FOMC high / low by month · 94–96 RTH range by VIX · 97–102 gap filled, then its 50% in NY AM, by gap
// 103–123 NFP week: open-side ¼ held NY AM and gap 50% in NY AM by gap · new high / low by gap · RTH range by prior day,
//   overnight, gap · 124–154 day after: FOMC high / low by the FOMC afternoon, by gap, by the FOMC close · new high / low
//   by gap, by month · ¼ held by gap · 155–169 base rates of all such days
// VH: 1 where that figure held.
var string PW = "NQ + ES + RTY pooled, 329 NFP-week Mon–Thu 2018–26 (970 symbol-days), read at 09:29. "
var string PF = "NQ + ES + RTY pooled, 67 days after FOMC 2018–26 (196 symbol-days), read at 09:29. "
var string PD = "Index against DXY futures in the same window, Feb 2023 – Jul 2026, NQ + ES + RTY pooled. "
var array<float> VS = parseStats("0.30,0.59,0.22,0.42,0.20,0.37,0.94,1.29,0.77,1.10,0.66,0.94,0.08,0.14,0.07,0.11,0.07,0.11,1.07,1.62,0.96,1.46,0.85,1.26,76,43,65,61,40,76,89,23,66,62,27,78,45,76,70,55,69,53,0.67,0.76,0.90,0.97,0.74,0.59,32,82,40,37,83,48,61,67,54,59,0.33,0.48,0.28,0.63,0.29,0.52,0.99,1.23,1.07,1.48,0.80,1.21,1.19,1.54,1.21,1.70,0.86,1.17,64,36,69,54,17,80,81,26,61,60,21,73,9,86,39,47,76,22,1.26,0.97,0.74,40,81,36,51,80,47,32,6,24,46,89,57,81,35,67,64,38,75,0.66,0.76,0.93,0.81,0.73,1.06,0.76,0.71,0.91,73,28,24,61,68,22,57,41,15,78,81,17,48,50,19,64,76,35,68,62,24,71,36,77,69,53,62,44,22,16,42,0.76,64,59,60,64,17,49,44,59,55,0.91,54,60,26,0.95")
VH = "11001111001111001111001111001101011111100110110111111100000000000000000011110110111100101100111011100101111111101111010110111111110011100011110011000001010000000000000000"
var string VZT_WMON = PW + "By the month's position (bottom quarter = discount, top quarter = premium). Right: new day high (H) / new low (L) after 09:30. discount (n 218) H45% L76% · middle (n 395) H70% L55% · premium (n 357) H69% L53%. Held: ✓ discount: new day high after 09:30 45% vs 70% (2018–24 45% vs 68%, 2025–26 47% vs 76%; NQ 47% · ES 45% · RTY 44%; p < 0.001); ✓ discount: new day low after 09:30 76% vs 54% (2018–24 75% vs 55%, 2025–26 77% vs 51%; NQ 74% · ES 73% · RTY 80%; p < 0.001); ✓ middle: new day high after 09:30 70% vs 60% (2018–24 69% vs 59%, 2025–26 74% vs 64%; NQ 75% · ES 65% · RTY 71%; p 0.008); ✓ premium: new day low after 09:30 53% vs 63% (2018–24 53% vs 63%, 2025–26 54% vs 61%; NQ 53% · ES 49% · RTY 58%; p 0.027). The EXPECT rows use this group."
// long texts live in one runtime array, so each is embedded once (Pine folds a constant string into every use)
var array<string> TXA = array.new<string>()
txAdd(string s) =>
    TXA.push(s)
    TXA.size() - 1
var int VZT_WMO = txAdd(PW + "Over / under = more than 1 ADR from the month's open. Right: R = the RTH range, ADR. over (n 212) 0.67 · within (n 599) 0.76 · under (n 159) 0.90. Held: ✓ over: RTH range 0.67 vs 0.78 (2018–24 0.66 vs 0.76, 2025–26 0.72 vs 0.85; NQ 0.72 · ES 0.61 · RTY 0.72; p 0.008); ✓ under: RTH range 0.90 vs 0.74 (2018–24 0.81 vs 0.73, 2025–26 1.03 vs 0.77; NQ 0.91 · ES 0.90 · RTY 0.88; p 0.005).")
var int VZT_WPD = txAdd(PW + "Against the prior day's high and low. Right: H / L after 09:30. above PDH (n 211) H76% L43% · inside (n 627) H65% L61% · below PDL (n 132) H40% L76%. Held: ✓ above PDH: new day high after 09:30 76% vs 61% (2018–24 76% vs 59%, 2025–26 77% vs 65%; NQ 76% · ES 78% · RTY 75%; p < 0.001); ✓ above PDH: new day low after 09:30 43% vs 64% (2018–24 44% vs 64%, 2025–26 40% vs 62%; NQ 45% · ES 42% · RTY 42%; p < 0.001); ✓ below PDL: new day high after 09:30 40% vs 68% (2018–24 33% vs 68%, 2025–26 60% vs 69%; NQ 46% · ES 34% · RTY 40%; p < 0.001); ✓ below PDL: new day low after 09:30 76% vs 56% (2018–24 79% vs 56%, 2025–26 66% vs 57%; NQ 72% · ES 77% · RTY 79%; p < 0.001).")
var int VZT_W18 = txAdd(PW + "Overnight: the 18:00 open to 09:29, in ADR; strong = beyond ±0.4. Right: H / L after 09:30. up > 0.4 (n 122) H89% L23% · within (n 736) H66% L62% · down > 0.4 (n 112) H27% L78%. Held: ✓ up > 0.4 ADR: new day low after 09:30 23% vs 64% (2018–24 22% vs 65%, 2025–26 29% vs 61%; NQ 24% · ES 20% · RTY 24%; p < 0.001); ✓ within: new day low after 09:30 62% vs 49% (2018–24 63% vs 47%, 2025–26 59% vs 58%; NQ 61% · ES 58% · RTY 67%; p 0.010); ✓ down > 0.4 ADR: new day high after 09:30 27% vs 69% (2018–24 24% vs 68%, 2025–26 36% vs 73%; NQ 36% · ES 18% · RTY 26%; p < 0.001); ✓ down > 0.4 ADR: new day low after 09:30 78% vs 57% (2018–24 79% vs 57%, 2025–26 75% vs 56%; NQ 69% · ES 85% · RTY 79%; p < 0.001).")
var int VZT_WGP = txAdd(PW + "RTH gap = 09:30 open − prior 16:14 close, in ADR. Right: ½ = the gap's 50% traded by 10:00, F = the whole gap filled by 16:14. gap up > 0.25 ADR (n 242) ½32% F37% · smaller (n 517) ½82% F83% · gap down > 0.25 ADR (n 211) ½40% F48%. Held: ✓ gap up: gap 50% by 10:00 32% vs 70% (2018–24 30% vs 70%, 2025–26 40% vs 70%; NQ 38% · ES 22% · RTY 37%; p < 0.001); ✓ gap up: gap filled by 16:14 37% vs 72% (2018–24 36% vs 71%, 2025–26 43% vs 78%; NQ 40% · ES 32% · RTY 38%; p < 0.001); ✓ smaller: gap 50% by 10:00 82% vs 36% (2018–24 81% vs 35%, 2025–26 85% vs 40%; NQ 84% · ES 79% · RTY 83%; p < 0.001); ✓ smaller: gap filled by 16:14 83% vs 42% (2018–24 81% vs 40%, 2025–26 91% vs 49%; NQ 80% · ES 84% · RTY 84%; p < 0.001); ✓ gap down: gap 50% by 10:00 40% vs 66% (2018–24 40% vs 65%, 2025–26 40% vs 72%; NQ 43% · ES 39% · RTY 39%; p < 0.001); ✓ gap down: gap filled by 16:14 48% vs 68% (2018–24 46% vs 66%, 2025–26 54% vs 77%; NQ 49% · ES 49% · RTY 45%; p < 0.001).")
var int VZT_WVX = txAdd(PW + "VIX's prior close against its 20-day average (±10%). Right: R = the RTH range, ADR. over (n 215) 0.97 · near (n 596) 0.74 · under (n 159) 0.59. Held: ✓ VIX over: RTH range 0.97 vs 0.71 (2018–24 0.96 vs 0.68, 2025–26 1.02 vs 0.79; NQ 1.00 · ES 0.96 · RTY 0.93; p < 0.001); ✓ VIX under: RTH range 0.59 vs 0.79 (2018–24 0.59 vs 0.78, 2025–26 0.56 vs 0.85; NQ 0.61 · ES 0.56 · RTY 0.66; p < 0.001).")
var string VZT_WDY = PW + "The gap's 50% by 10:00 by weekday: Mon (n 261) 61% · Tue (n 244) 67% · Wed (n 237) 54% · Thu (n 228) 59%. Nothing here held."
var int VZT_WE = txAdd(PW + "Median and 80th percentile by the month's position (discount · middle · premium; n 218 · 395 · 357), at today's ADR20. |NY AM| 09:30–11:00: 0.30 · 0.22 · 0.20 ADR (80%: 0.59 · 0.42 · 0.37) — held for discount, premium; RTH range: 0.94 · 0.77 · 0.66 ADR (80%: 1.29 · 1.10 · 0.94) — held for discount, premium; settlement window 16:15–17:00 range: 0.08 · 0.07 · 0.07 ADR (80%: 0.14 · 0.11 · 0.11) — held for discount, premium; next day's range: 1.07 · 0.96 · 0.85 ADR (80%: 1.62 · 1.46 · 1.26) — held for discount, premium. Sizes for stops and targets: which way it goes did not hold.")
var int VZT_WDR = txAdd(PD + "RTH 09:30–16:14: with DXY ≥ 0.26 of its ADR20 (BIG) the index went the other way 70% (n 188 on 64 days; 2023–24 66%, 2025–26 74%; NQ 65% · ES 69% · RTY 75%; p < 0.001; held) vs 42% when smaller. NY AM: with DXY ≥ 0.19, 60% (2023–24 67%, 2025–26 53%; p 0.047; held, barely) vs 54%. It confirms the move, it does not call it.")
var int VZT_FMON = txAdd(PF + "By the month's position. Right: how often RTH took the FOMC day's high (FH) and low (FL). discount (n 44) FH9% FL86% · middle (n 62) FH39% FL47% · premium (n 90) FH76% FL22%. Held: ✓ discount: took the FOMC high 9% vs 61% (2018–24 8% vs 61%, 2025–26 20% vs 59%; NQ 19% · ES 8% · RTY 0%; p < 0.001); ✓ discount: took the FOMC low 86% vs 32% (2018–24 92% vs 32%, 2025–26 40% vs 34%; NQ 81% · ES 100% · RTY 81%; p < 0.001); ✓ premium: took the FOMC high 76% vs 26% (2018–24 75% vs 25%, 2025–26 78% vs 32%; NQ 87% · ES 71% · RTY 68%; p < 0.001); ✓ premium: took the FOMC low 22% vs 63% (2018–24 21% vs 68%, 2025–26 28% vs 42%; NQ 13% · ES 29% · RTY 25%; p < 0.001). The EXPECT rows use this group.")
var int VZT_FPD = txAdd(PF + "Against the FOMC day's high and low at 09:29. Right: H / L after 09:30. above the FOMC high (n 44) H64% L36% · inside (n 117) H69% L54% · below the FOMC low (n 35) H17% L80%. Held: ✓ above the FOMC high: new day low after 09:30 36% vs 60% (2018–24 39% vs 63%, 2025–26 27% vs 46%; NQ 37% · ES 38% · RTY 33%; p 0.047); ✓ inside: new day high after 09:30 69% vs 43% (2018–24 70% vs 38%, 2025–26 65% vs 64%; NQ 76% · ES 69% · RTY 64%; p 0.007); ✓ below the FOMC low: new day high after 09:30 17% vs 68% (2018–24 16% vs 68%, 2025–26 33% vs 68%; NQ 23% · ES 17% · RTY 10%; p < 0.001); ✓ below the FOMC low: new day low after 09:30 80% vs 49% (2018–24 81% vs 52%, 2025–26 67% vs 38%; NQ 77% · ES 75% · RTY 90%; p 0.004). (Above the FOMC high at 09:29, RTH takes it by construction.)")
var int VZT_F18 = txAdd(PF + "Overnight after the decision: the 18:00 open to 09:29, in ADR. Right: H / L after 09:30. up > 0.4 (n 42) H81% L26% · within (n 121) H61% L60% · down > 0.4 (n 33) H21% L73%. Held: ✓ up > 0.4 ADR: new day high after 09:30 81% vs 53% (2018–24 77% vs 53%, 2025–26 92% vs 52%; NQ 87% · ES 86% · RTY 69%; p 0.006); ✓ up > 0.4 ADR: new day low after 09:30 26% vs 62% (2018–24 33% vs 64%, 2025–26 8% vs 56%; NQ 20% · ES 36% · RTY 23%; p 0.002); ✓ down > 0.4 ADR: new day high after 09:30 21% vs 66% (2018–24 19% vs 66%, 2025–26 50% vs 66%; NQ 30% · ES 20% · RTY 15%; p < 0.001).")
var int VZT_FGP = txAdd(PF + "RTH gap = 09:30 open − FOMC day's 16:14 close, in ADR. Right: F = the whole gap filled by 16:14, ½ = its 50% traded in NY AM. gap up > 0.25 ADR (n 72) F40% ½51% · smaller (n 69) F81% ½80% · gap down > 0.25 ADR (n 55) F36% ½47%. Held: ✓ gap up: gap filled by 16:14 40% vs 61% (2018–24 43% vs 59%, 2025–26 33% vs 75%; NQ 32% · ES 39% · RTY 50%; p 0.040); ✓ smaller: gap filled by 16:14 81% vs 39% (2018–24 81% vs 36%, 2025–26 80% vs 47%; NQ 78% · ES 76% · RTY 88%; p < 0.001); ✓ smaller: gap 50% in NY AM 80% vs 50% (2018–24 78% vs 43%, 2025–26 100% vs 69%; NQ 83% · ES 81% · RTY 76%; p < 0.001).")
var int VZT_FVX = txAdd(PF + "VIX's prior close against its 20-day average. Right: R = the RTH range, ADR. over (n 39) 1.26 · near (n 106) 0.97 · under (n 51) 0.74. Held: ✓ VIX over: RTH range 1.26 vs 0.82 (2018–24 1.32 vs 0.84, 2025–26 0.83 vs 0.79; NQ 1.12 · ES 1.37 · RTY 1.20; p < 0.001); ✓ VIX under: RTH range 0.74 vs 1.06 (2018–24 0.73 vs 1.10, 2025–26 0.74 vs 0.81; NQ 0.61 · ES 0.69 · RTY 0.76; p < 0.001).")
var int VZT_FE = txAdd(PF + "Median and 80th percentile by the month's position (discount · middle · premium; n 44 · 62 · 90), at today's ADR20. |NY AM| 09:30–11:00: 0.33 · 0.28 · 0.29 ADR (80%: 0.48 · 0.63 · 0.52); RTH range: 0.99 · 1.07 · 0.80 ADR (80%: 1.23 · 1.48 · 1.21); next day's range: 1.19 · 1.21 · 0.86 ADR (80%: 1.54 · 1.70 · 1.17) — held for middle, premium. Sizes for stops and targets: which way it goes did not hold.")
var int VZT_FDR = txAdd(PD + "RTH 09:30–16:14: with DXY ≥ 0.52 of its ADR20 (BIG) the index went the other way 81% (n 42 on 14 days; 2023–24 78%, 2025–26 87%; NQ 93% · ES 79% · RTY 71%; p 0.003; held) vs 41% when smaller. NY AM: 63% with a big DXY move (p 0.228; not held). It confirms the move, it does not call it.")
var int VZT_FP = txAdd(PF + "The FOMC day's own afternoon, 14:00 → 16:14. Right: FH / FL = RTH took the FOMC high / low the next day. up (n 98) FH73% FL28% · down (n 98) FH24% FL61%. Held: ✓ afternoon up: took the FOMC high 73% vs 24% (2018–24 75% vs 17%, 2025–26 64% vs 48%; NQ 77% · ES 73% · RTY 70%; p < 0.001); ✓ afternoon up: took the FOMC low 28% vs 61% (2018–24 27% vs 68%, 2025–26 29% vs 39%; NQ 26% · ES 33% · RTY 23%; p < 0.001); ✓ afternoon down: took the FOMC high 24% vs 73% (2018–24 17% vs 75%, 2025–26 48% vs 64%; NQ 40% · ES 19% · RTY 16%; p < 0.001); ✓ afternoon down: took the FOMC low 61% vs 28% (2018–24 68% vs 27%, 2025–26 39% vs 29%; NQ 57% · ES 61% · RTY 65%; p < 0.001). By where the FOMC day closed in its range: top quarter FH81% FL17% · middle FH48% FL50% · bottom quarter FH19% FL64%.")
var int VZT_Q = txAdd(PF + "The open-side quarter: the quarter of the RTH gap next to the 09:30 open (the top quarter of a gap up, the bottom of a gap down). NY AM never traded back past it on gap up 22% · smaller gap 16% · gap down 42% of days (26% overall). Still a minority outcome: most days retrace past it.")
var string VZT_NW = "NFP week's opening gap: the prior week's last close to Sunday's 18:00 open, drawn to the release. NQ + ES + RTY pooled 2018–26 (299 NFP weeks): its midpoint traded by Monday's close 90% (other weeks 88%, no difference) and by the release 96%."
var string VZT_FH = "The FOMC day's high and low (its 18:00–17:00 session), carried into the next day. NQ + ES + RTY pooled: the next RTH took the high on 49% and the low on 44% of days after FOMC; Shirosaki shows the odds for today's setup."
vh(int i) => str.substring(VH, i, i + 1) == "1"
var int VZT_HD = txAdd("Hollow reads two days at the RTH open (09:29): Monday–Thursday of NFP week (Model 11) and the day after FOMC (Model 12, Full Bringer), led by where price sits in the month's range. SETUP: the month, its open, the prior day (the FOMC day's own range the day after), the overnight, the RTH gap and VIX (live, then fixed at 09:29). EXPECT: how far such days moved, at today's ADR20. LIVE (after 09:30): NY AM and RTH against DXY, the gap and the range since 09:30. Figures pooled from NQ, ES and RTY. Green key = held. No 09:29 feature called the day's direction.")
var int VZT_LV = txAdd("Today so far (points from the 09:30 open) and DXY's move in the same window, in DXY's ADR20. ×typ = against the EXPECT median. ⇄ = the other way to DXY, ⇉ = the same way. BIG = DXY's move reached the size where the other-way rate applies (NFP week: 0.19 in NY AM, 0.26 over RTH; day after FOMC: 0.52 over RTH).")
var int VZT_SHW = txAdd("Shirosaki · NFP week. HYDRA on NQ + ES + RTY pooled (773 training rows on 258 days 2018–24, errors clustered by date; 406 heads × 15 targets; 20 shifted-target nulls; locked 2025–26 test (197 rows on 71 days) plus the same sign on each symbol). Direction: NY AM up, RTH up and the settlement window had no more survivors than their nulls (10 / 4 / 0 vs null means 14 / 19 / 4), and the whole net scored AUC 0.52–0.56 on 2025–26. Group tests: 3 of 44 direction tests passed the ✓ rule, about what chance gives with this many tries. SIDE shows the one that leans 60 / 40 or more: after an overnight up more than 0.4 ADR, RTH closed up 69% vs 54% (2018–24 70% vs 52%, 2025–26 65% vs 61%; NQ 73 · ES 66 · RTY 68; p 0.014; n 122 on 60 days). The other two are near a coin flip: NY AM up 56% vs 48% from the month's middle; RTH up 53% vs 64% after a flat overnight. What held: the gap (filled 33 heads, 50% by 10:00 30, in NY AM 30, open-side quarter 29), the RTH range 37, the next day 33, new high 29 and low 31 after 09:30, |NY AM| 12, the settlement range 11.")
var int VZT_SHF = txAdd("Shirosaki · day after FOMC. HYDRA on NQ + ES + RTY pooled (159 training rows on 53 days 2018–24; 413 heads × 15 targets; locked 2025–26 test on 37 rows / 14 days plus each symbol). Direction: NY AM up had 0 survivors and RTH up 8 against a null maximum of 30; no direction head held in 2025–26. The whole net beat its null on NY AM up (AUC 0.71) and on NY AM going the stage-2 way (0.76), but on 14 days and with no single head behind it: unconfirmed. Group tests: 2 of 46 direction tests passed the ✓ rule, about what chance gives. SIDE shows the one that leans 60 / 40 or more: with VIX within 10% of its 20-day average, NY AM went down 64% vs 42% (2018–24 67% vs 40%, 2025–26 55% vs 53%, barely; NQ 63 · ES 63 · RTY 67; p 0.039; n 106 on 36 days). The other: inside the FOMC day's range at 09:29, NY AM up 54% vs 34%, near a coin flip. What held: RTH taking the FOMC high (31 heads) and low (15), new high after 09:30 (16), the gap fill (9) and its 50% in NY AM (4).")
bool hwF = hollowDay(calK) and not FO.includes(tdPK)
bool faF = FO.includes(tdPK) and tdK == calK                      // the day after an FOMC day
// the week's open
var int   wkX  = na
var float wkOp = na
if ta.change(time("W")) != 0
    wkX  := bar_index
    wkOp := open
// the setup at price c with the day's high h and low l so far: position in the month's range (0–1), distance from the
// month's open, beyond the prior day's range (ADR; 0 = inside), the overnight from 18:00 (ADR), ADR20 (pts)
ctxOf(float c, float h, float l) =>
    float a  = ADRtd * tdO
    float mh = math.max(nz(mtH, h), h)
    float ml = math.min(nz(mtL, l), l)
    float p  = mh > ml ? (c - ml) / (mh - ml) : na
    float m  = a > 0 ? (c - mtO) / a : na
    float d  = na(ptdH) or not (a > 0) ? na : c > ptdH ? (c - ptdH) / a : c < ptdL ? (c - ptdL) / a : 0.0
    float s  = a > 0 ? (c - tdO) / a : na
    [p, m, d, s, a]
// FOMC day: the 13:59 close and ADR, for the day after's FOMC row (its 16:14 close is the next day's gap reference)
var float fc59 = na
var float fA   = na
var int   fK   = na
if FO.includes(calK) and mod >= 840 and (mod[1] < 840 or calK[1] != calK)
    fc59 := close[1]
    fA   := ADRtd * tdO
    fK   := calK
// the setup fixed at 09:29, NY AM and RTH closes, DXY at the same moments, and the gap events
var int   hK   = na
var float amC  = na
var float x0   = na
var float xA   = na
var float xR   = na
var int   k59  = na
var float cxP  = na
var float cxM  = na
var float cxD  = na
var float cxS  = na
var float cxA  = na
var int   ceT  = na
var int   gfT  = na
var int   qbT  = na
bool at930 = (hwF or faF) and tfM <= 30 and rthSt and tgKey == calK and nz(hK) != calK
if at930
    hK   := calK
    x0   := dxL[1]
    amC  := na
    xA   := na
    xR   := na
    ceT  := na
    gfT  := na
    qbT  := na
    [p_, m_, d_, q_, a_] = ctxOf(close[1], tdH[1], tdL[1])
    k59 := calK
    cxP := p_
    cxM := m_
    cxD := d_
    cxS := q_
    cxA := a_
if hK == calK and na(amC) and mod >= 660 and mod < 975
    amC := close[1]
    xA  := dxL[1]
if hK == calK and na(xR) and mod >= 975
    xR := dxL[1]
if hK == calK and mod >= 570 and mod < 975 and not na(gapPC) and rthO != gapPC
    float g_ = rthO - gapPC
    if na(ceT) and (g_ > 0 ? low <= gapCE : high >= gapCE)
        ceT := time
    if na(gfT) and (g_ > 0 ? low <= gapPC : high >= gapPC)
        gfT := time
    if na(qbT) and mod < 660 and (g_ > 0 ? low <= gapPC + 0.75 * g_ : high >= gapPC + 0.75 * g_)
        qbT := time
// the stages card's table
var table TV  = na
var int   tvO = 0
SGR = layI == "Mobile" ? 5 : 12
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
// Shirosaki's table (indicator pane)
var table TH  = na
var int   thO = 0
HYR = layI == "Mobile" ? 6 : 11
if barstate.isfirst and showSh
    thO := str.startswith(shPos, "Top") ? 1 : 0
    TH  := table.new(posOf(shPos), 5, HYR + thO, bgcolor = #00000000, frame_width = 0, border_width = 0)
    if thO == 1
        TH.cell(0, 0, "", height = 7.0, bgcolor = #00000000)
        TH.merge_cells(0, 0, 4, 0)
    TH.merge_cells(1, thO, 3, thO)
    if layI != "Mobile"
        TH.merge_cells(2, thO + 2, 4, thO + 2)
// Level lines and their end labels that run to a time later today (16:14, the NFP release) are cut at the latest bar and
// grow with it.
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
bool hOn = showStr and recent
var int   tdTy = 6
var int   ptdK = na
var float nwC  = na
var float nwO  = na
if tdSt
    tdTy := dayType(tdK, ptdK)
    if na(ptdK) or dowOf(tdK) <= dowOf(nz(ptdK, tdK))
        nwC := close[1]
        nwO := open
        int nfpK = na
        for j = 0 to 4
            if NP.includes(addDays(tdK, j)) and na(nfpK)
                nfpK := addDays(tdK, j)
        if hOn and showNW and not na(nfpK) and not na(nwC)
            int te = keyAt(nfpK, 510)
            float ce = (nwC + nwO) / 2
            trimL(line.new(time, nwC, te, nwC, xloc = xloc.bar_time, color = color.new(cNW, 40), style = line.style_dotted, force_overlay = true), te)
            trimL(line.new(time, nwO, te, nwO, xloc = xloc.bar_time, color = color.new(cNW, 40), style = line.style_dotted, force_overlay = true), te)
            trimL(line.new(time, ce, te, ce, xloc = xloc.bar_time, color = cNW, style = lsOf(stNW), force_overlay = true), te)
            trimT(label.new(te, ce, "NWOG 50%", xloc = xloc.bar_time, color = #00000000, textcolor = cNW, style = label.style_label_left, size = lbSz, tooltip = VZT_NW, force_overlay = true), te)
    if hOn and showFH and FO.includes(ptdK) and not na(ptdH)
        trimL(line.new(time, ptdH, keyAt(tdK, 974), ptdH, xloc = xloc.bar_time, color = cFH, style = lsOf(stFH), force_overlay = true), keyAt(tdK, 974))
        trimL(line.new(time, ptdL, keyAt(tdK, 974), ptdL, xloc = xloc.bar_time, color = cFH, style = lsOf(stFH), force_overlay = true), keyAt(tdK, 974))
        trimT(label.new(keyAt(tdK, 974), ptdH, "FOMC high", xloc = xloc.bar_time, color = #00000000, textcolor = cFH, style = label.style_label_left, size = lbSz, tooltip = VZT_FH, force_overlay = true), keyAt(tdK, 974))
        trimT(label.new(keyAt(tdK, 974), ptdL, "FOMC low", xloc = xloc.bar_time, color = #00000000, textcolor = cFH, style = label.style_label_left, size = lbSz, tooltip = VZT_FH, force_overlay = true), keyAt(tdK, 974))
    ptdK := tdK
if hOn and showGap and (tdTy == 5 or tdTy == 3) and rthSt and not na(gapPC)
    trimL(line.new(time, gapPC, keyAt(calK, 974), gapPC, xloc = xloc.bar_time, color = color.new(cLvl, 40), style = line.style_dotted, force_overlay = true), keyAt(calK, 974))
    trimL(line.new(time, gapCE, keyAt(calK, 974), gapCE, xloc = xloc.bar_time, color = color.new(cLvl, 20), style = line.style_dotted, force_overlay = true), keyAt(calK, 974))
    trimT(label.new(keyAt(calK, 974), gapCE, "gap 50%", xloc = xloc.bar_time, color = #00000000, textcolor = cLvl, style = label.style_label_left, size = lbSz, tooltip = "RTH gap 50% = (prior 16:14 close + 09:30 open) ÷ 2. " + (tdTy == 3 ? TXA.get(VZT_FGP) : TXA.get(VZT_WGP)), force_overlay = true), keyAt(calK, 974))
// the event flags: above the bar's high, tied by a stem to its open; they rise with price for half an hour
var int   mkK = na
var int   mkE = 0
var label mkL = na
var line  mkV = na
bool mkN = NP.includes(calK) and mod <= 510 and mod + tfM > 510
bool mkF = FO.includes(calK) and mod <= 840 and mod + tfM > 840
if hOn and markEv and (mkN or mkF)
    float yT = high + 0.3 * nz(ADRtd * tdO, 4 * (high - low))
    mkK := calK
    mkE := mkN ? 540 : 870
    mkV := line.new(time, open, time, yT, xloc = xloc.bar_time, color = color.new(cGh, 25), style = line.style_dotted, force_overlay = true)
    mkL := label.new(time, yT, (mkN ? "NFP 08:30 · " : "FOMC 14:00 · ") + pf(open), xloc = xloc.bar_time, color = cGh, textcolor = #ffffff, style = label.style_label_down, size = lbSz == size.tiny ? size.small : lbSz, tooltip = mkN ? "NFP release, 08:30 ET: the end of the Hollow week. The stem runs to the 08:30 open." : "FOMC statement, 14:00 ET: tomorrow is a Full Bringer day (Model 12). The stem runs to the 14:00 open.", force_overlay = true)
else if mkK == calK and mod < mkE and high + 0.3 * nz(ADRtd * tdO) > mkL.get_y()
    mkL.set_y(high + 0.3 * nz(ADRtd * tdO))
    mkV.set_y2(high + 0.3 * nz(ADRtd * tdO))
bgcolor(hOn and showSet and tdTy == 5 and mod >= 975 and mod < 1020 ? cWin : na, title = "Settlement window 16:15–17:00", force_overlay = true)

// the day after FOMC: the RTH gap in eighths over NY AM, 50% bold, the quarter next to the open shaded
if hOn and showOct and faF and rthSt and not na(gapPC) and rthO != gapPC
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
    trimT(label.new(te, gapPC + gp * 0.875, "open-side ¼", xloc = xloc.bar_time, color = #00000000, textcolor = color.new(cOq, 0), style = label.style_label_left, size = lbSz, tooltip = TXA.get(VZT_Q), force_overlay = true), te)
bgcolor(hOn and showOct and faF and mod >= 570 and mod < 660 ? color.new(cOq, math.min(100, color.t(cOq) + 14)) : na, title = "NY AM, the day after FOMC", force_overlay = true)

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
REL = ""
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
bool  ckTop = (showCk and ckOn == "Indicator pane" and str.startswith(ckPos, "Top")) or (showSh and str.startswith(shPos, "Top"))
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
// Price chart: two cards, each its own table in its own corner: the event tally and the stages card. Each card is an
// accent stripe, a header bar with a status pill and a tinted body. The clock card (indicator pane by default) uses the
// same style. Five columns: stripe · key · wording · value · comparison.
SC = 5
cBody  = dark ? #161a23 : #f4f6f9
cBody2 = dark ? #1c2130 : #e9edf3
cNeu   = dark ? #3a3f4b : #d1d4dc
cDxc   = cAcD
cPrem  = dark ? #ef5350 : #d32f2f
cDisc  = dark ? #66bb6a : #2e7d32
bool mob = layI == "Mobile"
EV_N = mob ? 6 : 8                    // Full: header · sub · DAY · RTH · GAP · WEEK · MONTH · NEXT; Mobile: header · NOW · DAY · GAP · WK · MO
KR   = 5
var table TS  = na
var table TK  = na
var int   tsO = 0
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
    string src = isES ? TAL_ES : isRTY ? TAL_RTY : isNQ ? TAL_NQ : ""
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
        string srcT = TEd.size() > 0 ? " Built-in " + symR + " records run to " + str.format_time(keyTime(talEnd), "dd MMM yyyy", TZ) + "; later days, and any this chart loads itself, come from the chart's own bars." : " Records come from this chart's own bars (built-in history covers NQ / MNQ, ES / MES and RTY / M2K)."
        string tTip = "Trading day (18:00 → 17:00) close vs open on the last " + str.tostring(nT) + " " + TAL_NAME + " days" + since + ", oldest → newest: " + seq + ". RTH (09:30 → 16:14): ▲ " + str.tostring(uR) + " ▼ " + str.tostring(dR_) + ". A tally, not a forecast: across 2018–26 the up-close rate on these days was not different from normal days." + srcT
        string gTip = "RTH gap = 09:30 open − prior trading day's 16:14 close. Average over the last " + str.tostring(nG) + " " + TAL_NAME + " days: " + (na(gAvg) ? "—" : pf(gAvg)) + " pts; average size " + (na(gAbs) ? "—" : pf(gAbs) + " pts (" + str.tostring(acc.get(8) / nG, "0.00") + "%)") + "; gapped up on " + str.tostring(int(acc.get(9))) + " of " + str.tostring(nG) + "."
        bool   nxW  = not na(n1k) and (na(n2k) or n1k <= n2k)
        int    nxK  = nxW ? n1k : n2k
        string nxT  = na(nxK) ? "beyond loaded dates" : (nxW ? "NFP week " : "FOMC +1 ") + str.format_time(keyTime(nxK), "dd MMM", TZ) + (nxK == today ? " · today" : " · " + str.tostring(inDays(nxK, today)) + "d") + (warn ? " · UPDATE" : "")
        string nxTip = "Next NFP week (Mon–Thu): " + (na(n1k) ? "beyond the loaded dates" : fmtDay(n1k)) + " · next day after FOMC: " + (na(n2k) ? "beyond the loaded dates" : fmtDay(n2k)) + ". Release dates are built in up to " + str.format_time(keyTime(LAST_DATE), "dd MMM yyyy", TZ) + ": add next year's dates (bls.gov/schedule, federalreserve.gov) to S_FOMC, S_CPI and S_NFP, then raise LAST_DATE."
        string hdT  = pfName(pk) + ". Clock and tally: " + symR + " 1-minute data 2018–26; stages card and Shirosaki: NQ + ES + RTY pooled." + (isNQ or isES or isRTY ? "" : " This chart is " + syminfo.root + ": the clock and tally are " + symR + "'s.")
        string pill_ = pNow ? "TODAY" : na(dd) ? "—" : dd == 1 ? "TMRW" : "IN " + str.tostring(dd) + "D"
        if showEv and not na(TS)
            int r0 = tsO
            cardHead(TS, r0, cGh, dot + " HOLLOW · " + ev + " · " + symTag, hdT + " " + nxTip, mob and warn ? "UPDATE" : pill_, mob and warn or not pNow ? #ffffff : cGh, mob and warn ? cWarn : pNow ? #ffffff : color.new(#000000, 55))
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
            cardHead(TK, r0, cGh, dot + " " + "HOLLOW · CLOCK · " + nowT + " ET", "Today's running range (or net move) from the 18:00 open against the same time of day on " + bN + " days, 2018–26: paths from " + ckN(ckI) + " " + bN + " days" + (ckI != NCK - 1 ? " and " + ckN(NCK - 1) + " normal days" : "") + ", half-hour steps, scaled by today's ADR20" + (scP > 0 ? " (" + pf(scP) + " pts)." : "."), ckEv ? eN + " DAY" : "NORMAL", ckEv ? cGh : #ffffff, ckEv ? #ffffff : color.new(#000000, 55))
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
            int   bestJ = 1
            for j = 1 to 45
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
        // the week's open, extended to the right of price
        if showWO and not na(wkX) and not na(wkOp)
            RL.push(line.new(math.max(wkX, bar_index - 4900), wkOp, xd, wkOp, color = color.new(cLvl, 15), style = line.style_dashed, force_overlay = true))
            RT.push(label.new(bar_index + 2, wkOp, "week open " + pf(wkOp), color = #00000000, textcolor = cLvl, style = label.style_label_left, size = lbSz, force_overlay = true))
    true
drawLast1()

// ═══════════════════════════════════════════════════════════════ Hollow stages card and Shirosaki (last bar)
// part of the month's range: 0 discount (bottom quarter) · 1 middle · 2 premium (top quarter)
zIdx(float p) => na(p) ? 1 : p >= 0.75 ? 2 : p <= 0.25 ? 0 : 1
zWd(int z) => z == 2 ? "PREM" : z == 0 ? "DISC" : "MID"
sgP(float v) => na(v) ? "—" : str.tostring(v, "0")
sgS(float v) => na(v) ? "—" : (v >= 0 ? "+" : "−") + str.tostring(math.abs(v), "0")
pcV(int i) => VS.get(i) < 0 ? "—" : str.tostring(VS.get(i), "0")
hl(int i) => "H" + pcV(i) + " L" + pcV(i + 1)
fl(int i) => "FH" + pcV(i) + " FL" + pcV(i + 1)
hlH(int i) => vh(i) or vh(i + 1)
rg(int i) => "R" + str.tostring(VS.get(i), "0.00")
hhT(int t) => str.format_time(t, "HH:mm", TZ)
mOf(int t) => hour(t, TZ) * 60 + minute(t, TZ)
liveTx(float sv, float dv) => na(sv) ? "—" : sgS(sv) + " · DXY " + (na(dv) ? "—" : vzAr(dv) + str.tostring(math.abs(dv), "0.00"))
// same window against DXY: ⇄ other way · ⇉ same way · BIG once DXY's move reaches thr of its ADR20
dxPill(float dv, float sv, float thr) =>
    bool ok  = not (na(dv) or na(sv) or dv == 0 or sv == 0)
    bool big = ok and math.abs(dv) >= thr
    bool oth = ok and math.sign(dv) != math.sign(sv)
    [not ok ? "—" : (oth ? "⇄" : "⇉") + (big ? " BIG" : ""), big ? #ffffff : cTx, not ok ? cBody : big ? (oth ? cOk : cWarn) : cNeu]
// a held size group active today: its token, its figure, and whether it points bigger or smaller than all such days
szT(int i, string lab, float b) =>
    bool h = vh(i)
    [h ? lab + (VS.get(i) > b ? "↑ " : "↓ ") : "", h ? lab + " " + str.tostring(VS.get(i), "0.00") + " · " : "", h and VS.get(i) > b ? 1 : 0, h and VS.get(i) < b ? 1 : 0]
// today's (or the next Hollow day's) setup: live, then fixed at 09:29
var int  hKd = 0
var bool hNw = false
var int  hDy = na
if barstate.islast
    [k_, n_, d_] = ownProfile(tdK, tdPK, calK)
    hKd := k_
    hNw := n_
    hDy := d_
bool  isF  = hKd == 4                                               // the day after FOMC, else NFP week
bool  evD  = hNw and (isF ? faF : hwF)
bool  fzS  = not na(k59) and k59 == calK
[lp_, lm_, ld_, ls_, la_] = ctxOf(close, tdH, tdL)
float uP   = fzS ? cxP : lp_
float uM   = fzS ? cxM : lm_
float uD   = fzS ? cxD : ld_
float uS   = fzS ? cxS : ls_
float uA   = fzS ? cxA : la_
bool  gOpn = tgKey == calK and not na(gapPC) and mod >= 570
float uG   = not (uA > 0) ? na : gOpn ? (rthO - gapPC) / uA : not na(rthC) ? (close - rthC) / uA : na      // before 09:30: the gap if it opened now
float uV   = vxA > 0 ? vxC / vxA - 1 : na
int   uZ   = zIdx(uP)
int   uOc  = na(uP) ? na : math.min(8, int(math.floor(uP * 8)) + 1)
int   uMo  = na(uM) ? 1 : uM > 1 ? 0 : uM < -1 ? 2 : 1                  // over · near · under the month's open
int   uPg  = na(uD) ? 1 : uD > 0 ? 0 : uD < 0 ? 2 : 1                   // above the prior high · inside · below the prior low
int   uSg  = na(uS) ? 1 : uS > 0.4 ? 0 : uS < -0.4 ? 2 : 1               // overnight strong up · within · strong down
int   uGg  = na(uG) ? 1 : uG > 0.25 ? 0 : uG < -0.25 ? 2 : 1             // gap up · smaller · gap down
int   uVg  = na(uV) ? 1 : uV > 0.1 ? 0 : uV < -0.1 ? 2 : 1               // VIX over · near · under its average
int   uDd  = na(hDy) ? na : inDays(hDy, calK)
bool  stS  = hK == calK
float svA  = stS and not na(rthO) ? (na(amC) ? close : amC) - rthO : na
float svR  = stS and not na(rthO) ? (mod < 975 ? close : rthC) - rthO : na
float dvA  = stS and not na(x0) and dxA > 0 ? ((na(xA) ? dxL : xA) - x0) / dxA : na
float dvR  = stS and not na(x0) and dxA > 0 ? ((na(xR) ? dxL : xR) - x0) / dxA : na
float fCl  = tgKey == calK ? gapPC : rthC                            // the FOMC day's 16:14 close
float fPo  = isF and fK == tdPK and not na(fc59) and fA > 0 and not na(fCl) ? (fCl - fc59) / fA : na
int   fpI  = nz(fPo) >= 0 ? 124 : 126
float fRg  = isF and faF and fA > 0 ? (ptdH - ptdL) / fA : na
// the gap's events since 09:30: its 50% (by 10:00 in NFP week, in NY AM the day after FOMC), the fill, the open-side ¼
bool   gpOn  = stS and gOpn and rthO != gapPC
int    cDl   = isF ? 660 : 600
string sHalf = not stS ? "from 09:30" : not gpOn ? "no gap" : not na(ceT) ? (mOf(ceT) < cDl ? "hit " : "late ") + hhT(ceT) : mod < cDl ? "open" : "missed"
string sFill = not stS ? "from 09:30" : not gpOn ? "no gap" : not na(gfT) ? "filled " + hhT(gfT) : mod < 975 ? "open" : "missed"
string sQ    = not stS ? "from 09:30" : not gpOn ? "no gap" : not na(qbT) ? "broke " + hhT(qbT) : mod < 660 ? "holding" : "held"
color  zBg   = uZ == 2 ? cPrem : uZ == 0 ? cDisc : cNeu
color  zFg   = uZ == 1 ? cTx : #ffffff
string gLab  = uGg == 0 ? "gap up" : uGg == 2 ? "gap down" : "small gap"
color  cH    = not na(ceT) and mOf(ceT) < cDl ? cOk : sHalf == "missed" or str.startswith(sHalf, "late") ? cWarn : na
color  cF    = not na(gfT) ? cOk : sFill == "missed" ? cWarn : na
color  cQ    = not na(qbT) ? cWarn : sQ == "held" ? cOk : na
// a gap row's right cell: the base rate before 09:30, then today's outcome
gpB(int i, string s) => gpOn ? s : "all " + pcV(i) + "%"
// The cards are drawn in small blocks: Pine caps the size of one if block (CE10205), so each card part is its own
// function, and the values both layouts share come from a function rather than being repeated.
sgDot() => barstate.isrealtime ? (beat % 2 == 0 ? "●" : "○") : "◆"
sgVals() =>
    int    z   = uZ
    float  a   = uA
    int    o   = isF ? 58 : 0
    float  eA  = VS.get(o + 2 * z) * a
    float  eR  = VS.get(o + 6 + 2 * z) * a
    float  rQ  = stS and tgKey == calK and not na(rH) ? rH - rL : na
    string zW  = z == 2 ? "PREMIUM" : z == 0 ? "DISCOUNT" : "MIDDLE"
    string mTp = "Price at " + (na(uP) ? "—" : p0(uP)) + " of the month's range so far (" + (fzS ? "09:29" : "live") + "): " + zW + ". " + (isF ? TXA.get(VZT_FMON) : VZT_WMON)
    string gpR = isF ? "F" + pcV(97 + uGg) + " ½" + pcV(100 + uGg) : "½" + pcV(48 + uGg) + " F" + pcV(51 + uGg)
    bool   gpH = isF ? vh(97 + uGg) or vh(100 + uGg) : vh(48 + uGg) or vh(51 + uGg)
    [z, a, o, eA, eR, rQ, zW, mTp, gpR, gpH]
// stages card, Desktop: header and SETUP
drawSgA() =>
    if barstate.islast and showSg and not na(TV) and not mob
        [z, a, o, eA, eR, rQ, zW, mTp, gpR, gpH] = sgVals()
        string dayT = evD ? "TODAY" : na(uDd) ? "—" : "IN " + str.tostring(uDd) + "D"
        string ttl  = isF ? "FULL BRINGER · FOMC +1" : "HOLLOW · NFP WEEK"
        string oc   = octBar(uOc) + " O" + (na(uOc) ? "—" : str.tostring(uOc))
        int    r    = tvO
        cardHead(TV, r, cGh, sgDot() + " " + ttl + " · " + symTag + " · " + dayT + (fzS ? " · 09:29" : ""), TXA.get(VZT_HD), zW, zFg, zBg)
        if isF
            cardRow(TV, r + 1, cGh, "FOMC", hlH(fpI), "14:00→16:14 " + sgS(fPo * fA) + " · R" + (na(fRg) ? "—" : str.tostring(fRg, "0.0")), fdSg(fPo, "0.0"), fl(fpI), TXA.get(VZT_FP), na, cSub)
            cardRow(TV, r + 2, cGh, "MONTH", hlH(88 + 2 * z), oc, na(uP) ? "—" : p0(uP), fl(88 + 2 * z), mTp, z == 1 ? na : zBg, cSub)
        else
            cardRow(TV, r + 1, cGh, "MONTH", hlH(36 + 2 * z) or vh(6 + 2 * z), oc, na(uP) ? "—" : p0(uP), hl(36 + 2 * z), mTp, z == 1 ? na : zBg, cSub)
            cardRow(TV, r + 2, cGh, "MO", vh(42 + uMo), "vs month open " + sgS(uM * a), fdSg(uM, "0.0"), rg(42 + uMo), "Month's open " + pf(mtO) + ": " + fdSg(uM, "0.0") + " ADR (" + sgS(uM * a) + " pts). " + TXA.get(VZT_WMO), uMo == 0 ? cHot : uMo == 2 ? cCold : na, cSub)
    true
drawSgB() =>
    if barstate.islast and showSg and not na(TV) and not mob
        [z, a, o, eA, eR, rQ, zW, mTp, gpR, gpH] = sgVals()
        string lvH = isF and faF ? "FOMC high" : "PDH"
        string lvL = isF and faF ? "FOMC low" : "PDL"
        string pdT = na(uD) ? "prior day —" : uD > 0 ? "above " + lvH + " " + sgS(uD * a) : uD < 0 ? "below " + lvL + " " + sgS(uD * a) : isF and faF ? "inside FOMC day" : "inside prior day"
        string gpT = na(uG) ? "gap at 09:30" : (gOpn ? "" : "now ") + (uG >= 0 ? "gap up " : "gap down ") + sgP(math.abs(uG) * a)
        string vxT = na(uV) ? "VIX —" : "VIX " + str.tostring(vxC, "0.0") + " · " + fdSg(100 * uV, "0") + "% vs 20d"
        int    r   = tvO
        cardRow(TV, r + 3, cGh, "PD", hlH((isF ? 76 : 24) + 2 * uPg), pdT, uPg == 1 ? "" : fdSg(uD, "0.0"), hl((isF ? 76 : 24) + 2 * uPg), isF ? TXA.get(VZT_FPD) : TXA.get(VZT_WPD), na, cSub)
        cardRow(TV, r + 4, cGh, "O/N", hlH((isF ? 82 : 30) + 2 * uSg), "since 18:00 " + sgS(uS * a), fdSg(uS, "0.0"), hl((isF ? 82 : 30) + 2 * uSg), isF ? TXA.get(VZT_F18) : TXA.get(VZT_W18), uSg == 0 ? cDisc : uSg == 2 ? cPrem : na, cSub)
        cardRow(TV, r + 5, cGh, "GAP", gpH, gpT, fdSg(uG, "0.00"), gpR, isF ? TXA.get(VZT_FGP) : TXA.get(VZT_WGP), na, cSub)
        cardRow(TV, r + 6, cGh, "VIX", vh((isF ? 94 : 45) + uVg), vxT, "", rg((isF ? 94 : 45) + uVg), isF ? TXA.get(VZT_FVX) : TXA.get(VZT_WVX), na, cSub)
    true
// stages card, Desktop: LIVE (from 09:30) or EXPECT
drawSgC() =>
    if barstate.islast and showSg and not na(TV) and not mob and stS
        [z, a, o, eA, eR, rQ, zW, mTp, gpR, gpH] = sgVals()
        float rA = na(svA) or not (eA > 0) ? na : math.abs(svA) / eA
        float rR = na(rQ) or not (eR > 0) ? na : rQ / eR
        [tA, fA_, bA] = dxPill(dvA, svA, isF ? 99.0 : 0.19)
        [tR, fR, bR] = dxPill(dvR, svR, isF ? 0.52 : 0.26)
        int r = tvO
        cardSub(TV, r + 7, cDxc, "LIVE · vs DXY", "×typ", "DXY")
        cardRow(TV, r + 8, cGh, "NY AM", false, liveTx(svA, dvA), na(rA) ? "" : x2(rA), "", TXA.get(VZT_LV), nz(rA) >= 1 ? cHot : na)
        tcQ(TV, 4, r + 8, tA, fA_, bA, TXA.get(VZT_LV), text.align_center, true)
        cardRow(TV, r + 9, cGh, "RTH", false, liveTx(svR, dvR), "", "", TXA.get(VZT_LV) + " " + (isF ? TXA.get(VZT_FDR) : TXA.get(VZT_WDR)))
        tcQ(TV, 4, r + 9, tR, fR, bR, TXA.get(VZT_LV), text.align_center, true)
        cardRow(TV, r + 10, cGh, "RANGE", false, "since 09:30 " + sgP(rQ) + " pts", na(rR) ? "" : x2(rR), "med " + sgP(eR), "The RTH range so far against the EXPECT median for today's month position. " + (isF ? TXA.get(VZT_FE) : TXA.get(VZT_WE)), nz(rR) >= 1 ? cHot : na)
        cardRow(TV, r + 11, cGh, "GAP", gpH, "½ " + sHalf + " · F " + sFill, isF ? pcV(100 + uGg) + "%" : pcV(48 + uGg) + "%", "F" + pcV((isF ? 97 : 51) + uGg), isF ? TXA.get(VZT_FGP) : TXA.get(VZT_WGP))
    true
drawSgD() =>
    if barstate.islast and showSg and not na(TV) and not mob and not stS
        [z, a, o, eA, eR, rQ, zW, mTp, gpR, gpH] = sgVals()
        int r = tvO
        cardSub(TV, r + 7, cGh, "EXPECT · " + zWd(z) + " · ADR " + sgP(a), "med", "80%")
        cardRow(TV, r + 8, cGh, "NY AM", vh(o + 2 * z), "09:30–11:00", "±" + sgP(eA), "±" + sgP(VS.get(o + 1 + 2 * z) * a), isF ? TXA.get(VZT_FE) : TXA.get(VZT_WE))
        cardRow(TV, r + 9, cGh, "RTH", vh(o + 6 + 2 * z), "RTH range", sgP(eR), sgP(VS.get(o + 7 + 2 * z) * a), isF ? TXA.get(VZT_FE) : TXA.get(VZT_WE))
        if isF
            cardRow(TV, r + 10, cGh, "NEXT", vh(70 + 2 * z), "next day's range", sgP(VS.get(70 + 2 * z) * a), sgP(VS.get(71 + 2 * z) * a), TXA.get(VZT_FE))
            cardRow(TV, r + 11, cGh, "¼", vh(152 + uGg), "open-side ¼ held NY AM", pcV(152 + uGg) + "%", "all " + pcV(168) + "%", TXA.get(VZT_Q))
        else
            cardRow(TV, r + 10, cGh, "SETTLE", vh(12 + 2 * z), "16:15–17:00 range", sgP(VS.get(12 + 2 * z) * a), sgP(VS.get(13 + 2 * z) * a), TXA.get(VZT_WE))
            cardRow(TV, r + 11, cGh, "NEXT", vh(18 + 2 * z), "next day's range", sgP(VS.get(18 + 2 * z) * a), sgP(VS.get(19 + 2 * z) * a), TXA.get(VZT_WE))
    true
// stages card, Mobile
drawSgM() =>
    if barstate.islast and showSg and not na(TV) and mob
        [z, a, o, eA, eR, rQ, zW, mTp, gpR, gpH] = sgVals()
        [tR, fR, bR] = dxPill(dvR, svR, isF ? 0.52 : 0.26)
        int r = tvO
        cardHead(TV, r, cGh, sgDot() + " " + (isF ? "FOMC +1" : "NFP WEEK") + " · " + symTag + (evD or na(uDd) ? "" : " · " + str.tostring(uDd) + "D"), TXA.get(VZT_HD), zWd(z), zFg, zBg)
        cardRow(TV, r + 1, cGh, "MONTH", isF ? hlH(88 + 2 * z) : hlH(36 + 2 * z), octBar(uOc), na(uP) ? "—" : p0(uP), isF ? fl(88 + 2 * z) : hl(36 + 2 * z), mTp, z == 1 ? na : zBg)
        if stS
            cardRow(TV, r + 2, cGh, "RTH", false, liveTx(svR, dvR), "", "", TXA.get(VZT_LV))
            tcQ(TV, 4, r + 2, tR, fR, bR, TXA.get(VZT_LV), text.align_center, true)
            cardRow(TV, r + 3, cGh, "GAP", gpH, "½ " + sHalf + " · F " + sFill, "", "", isF ? TXA.get(VZT_FGP) : TXA.get(VZT_WGP))
        else
            cardRow(TV, r + 2, cGh, "EXP", vh(o + 6 + 2 * z), "RTH " + sgP(eR) + " · AM ±" + sgP(eA), sgP(VS.get(o + 7 + 2 * z) * a), "80%", isF ? TXA.get(VZT_FE) : TXA.get(VZT_WE))
            cardRow(TV, r + 3, cGh, "GAP", gpH, (na(uG) ? "gap —" : "gap " + fdSg(uG, "0.00")) + " " + gpR, "", "", isF ? TXA.get(VZT_FGP) : TXA.get(VZT_WGP))
        cardRow(TV, r + 4, cGh, "PD", hlH((isF ? 76 : 24) + 2 * uPg), (uPg == 0 ? "> " : uPg == 2 ? "< " : "in ") + (isF ? "FOMC " : "PD ") + hl((isF ? 76 : 24) + 2 * uPg), uPg == 1 ? "" : fdSg(uD, "0.0"), "", isF ? TXA.get(VZT_FPD) : TXA.get(VZT_WPD))
    true
drawSgA()
drawSgB()
drawSgC()
drawSgD()
drawSgM()

// Shirosaki (indicator pane): what held for today's setup, pooled NQ + ES + RTY, in points at today's ADR20, with the gap live.
// size: today's month position, then the other held size groups active today and whether they all agree
shSize() =>
    float  base = VS.get(isF ? 165 : 155)
    int    zi   = (isF ? 64 : 6) + 2 * uZ
    string tg   = ""
    string tgN  = ""
    int    bg_  = vh(zi) and VS.get(zi) > base ? 1 : 0
    int    sm_  = vh(zi) and VS.get(zi) < base ? 1 : 0
    for g = 0 to 4
        int lv = g == 0 ? uVg : g == 1 ? uMo : g == 2 ? uPg : g == 3 ? uSg : uGg
        if lv != 1 and (g == 0 or not isF)
            int    ix = g == 0 ? (isF ? 94 : 45) + uVg : g == 1 ? 42 + uMo : g == 2 ? 115 + uPg : g == 3 ? 118 + uSg : 121 + uGg
            string lb = g == 0 ? "VIX" : g == 1 ? "MO" : g == 2 ? "PD" : g == 3 ? "O/N" : "GAP"
            [t1, n1, b1, s1] = szT(ix, lb, base)
            tg  += t1
            tgN += n1
            bg_ += b1
            sm_ += s1
    string agr = bg_ > 0 and sm_ == 0 ? "BIGGER" : sm_ > 0 and bg_ == 0 ? "SMALLER" : bg_ > 0 ? "MIXED" : "TYPICAL"
    string agT = "RTH range in ADR for each held size group active today (all such days " + str.tostring(base, "0.00") + "): " + (tgN == "" ? "none" : tgN) + " BIGGER / SMALLER = every held group, the month's position included, points the same way; MIXED = they disagree. " + (isF ? TXA.get(VZT_FVX) : TXA.get(VZT_WVX) + " " + TXA.get(VZT_WMO))
    [base, zi, tg, agr, agT]
// new high / low after 09:30: the most specific group (the overnight, then the prior day, then the gap, then the month)
shHL() =>
    int    z  = uZ
    int    xi = isF ? (uSg != 1 ? 82 + 2 * uSg : uPg != 1 ? 76 + 2 * uPg : uGg != 1 ? 140 + 2 * uGg : 146 + 2 * z) : (uSg != 1 ? 30 + 2 * uSg : uPg != 1 ? 24 + 2 * uPg : uGg != 1 ? 109 + 2 * uGg : 36 + 2 * z)
    string xn = uSg == 0 ? "O/N↑" : uSg == 2 ? "O/N↓" : uPg == 0 ? (isF ? ">FOMC H" : ">PDH") : uPg == 2 ? (isF ? "<FOMC L" : "<PDL") : uGg != 1 ? gLab : zWd(z)
    [xi, xn, "H" + pcV(isF ? 163 : 156) + " L" + pcV(isF ? 164 : 157)]
agFg(string s) => s == "BIGGER" or s == "SMALLER" ? #ffffff : cTx
agBg(string s) => s == "BIGGER" ? cHot : s == "SMALLER" ? cCold : cNeu
// the day after FOMC: the FOMC high / low row by today's gap, or by the FOMC afternoon when the gap is small
shGi() => uGg != 1 ? 128 + 2 * uGg : fpI
shGn() => uGg == 0 ? "gap up" : uGg == 2 ? "gap down" : na(fPo) ? "14:00→16:14" : fPo >= 0 ? "14:00→16:14 ▲" : "14:00→16:14 ▼"
shRi() => uVg != 1 ? 94 + uVg : (64 + 2 * uZ)
shN() =>
    [base, zi, tg, agr, agT] = shSize()
    [xi, xn, xB] = shHL()
    int z = uZ
    isF ? (hlH(88 + 2 * z) ? 1 : 0) + (hlH(shGi()) ? 1 : 0) + (vh(shRi()) ? 1 : 0) + (hlH(xi) ? 1 : 0) + (vh(97 + uGg) ? 1 : 0) + (vh(100 + uGg) ? 1 : 0) + (vh(152 + uGg) ? 1 : 0) + 1 + (uVg == 1 ? 1 : 0) : (vh(zi) ? 1 : 0) + (tg != "" ? 1 : 0) + (hlH(xi) ? 1 : 0) + (vh(48 + uGg) ? 1 : 0) + (vh(51 + uGg) ? 1 : 0) + (vh(103 + uGg) ? 1 : 0) + 2 + (uSg == 0 ? 1 : 0)
// NFP week, Desktop
drawShW1() =>
    if barstate.islast and showSh and not na(TH) and not isF and not mob
        [base, zi, tg, agr, agT] = shSize()
        int   r = thO
        float a = uA
        cardHead(TH, r, cSh, sgDot() + " SHIROSAKI · NFP WEEK", TXA.get(VZT_SHW), str.tostring(shN()) + " ✓", cSh, #ffffff)
        cardSub(TH, r + 1, cSh, "NQ+ES+RTY · ADR " + sgP(a), "today", stS ? "base · live" : "base")
        cardWide(TH, r + 2, cSh, "SIDE", uSg == 0 ? "O/N up: RTH up 69% vs 54% ✓" : "none held: size the day", TXA.get(VZT_SHW), uSg == 0 ? cOk : cSub)
        cardRow(TH, r + 3, cSh, "RANGE", vh(zi), "RTH range · " + zWd(uZ), sgP(VS.get(zi) * a), "all " + sgP(base * a), "RTH range for today's month position (" + zWd(uZ) + "): median " + sgP(VS.get(zi) * a) + ", 80% " + sgP(VS.get(zi + 1) * a) + " pts. " + TXA.get(VZT_WE))
        cardRow(TH, r + 4, cSh, "SIZE+", tg != "", tg == "" ? "none active" : tg, "", "", agT)
        tcQ(TH, 3, r + 4, agr, agFg(agr), agBg(agr), agT, text.align_center, true)
    true
drawShW2() =>
    if barstate.islast and showSh and not na(TH) and not isF and not mob
        [xi, xn, xB] = shHL()
        int r = thO
        cardRow(TH, r + 5, cSh, "H/L", hlH(xi), "after 09:30 · " + xn, hl(xi), xB, "New day high (H) / low (L) after 09:30 for today's most specific group (" + xn + "). " + TXA.get(VZT_W18) + " " + TXA.get(VZT_WPD))
        cardRow(TH, r + 6, cSh, "½ 10:00", vh(48 + uGg), gLab + " · 50% by 10:00", pcV(48 + uGg) + "%", gpB(158, sHalf), "The gap's 50% traded by 10:00. " + TXA.get(VZT_WGP), na, cH)
        cardRow(TH, r + 7, cSh, "FILL", vh(51 + uGg), gLab + " · filled by 16:14", pcV(51 + uGg) + "%", gpB(159, sFill), "The whole gap filled by 16:14. " + TXA.get(VZT_WGP), na, cF)
        cardRow(TH, r + 8, cSh, "¼ OPEN", vh(103 + uGg), gLab + " · held NY AM", pcV(103 + uGg) + "%", gpB(160, sQ), "The open-side quarter: the quarter of the RTH gap next to the 09:30 open. " + PW + "NY AM never traded back past it on gap up " + pcV(103) + "% · smaller gap " + pcV(104) + "% · gap down " + pcV(105) + "% of days (" + pcV(160) + "% overall); each held. A minority outcome: most days retrace past it.", na, cQ)
    true
drawShW3() =>
    if barstate.islast and showSh and not na(TH) and not isF and not mob
        int r = thO
        cardRow(TH, r + 9, cSh, "DXY RTH", true, "BIG ≥ 0.26 → other way", "70%", "vs 42%", TXA.get(VZT_WDR))
        cardRow(TH, r + 10, cSh, "DXY AM", true, "BIG ≥ 0.19 → other way", "60%", "vs 54%", TXA.get(VZT_WDR))
        if stS
            [tR, fR, bR] = dxPill(dvR, svR, 0.26)
            [tA, fA_, bA] = dxPill(dvA, svA, 0.19)
            tcQ(TH, 4, r + 9, tR, fR, bR, TXA.get(VZT_LV), text.align_center, true)
            tcQ(TH, 4, r + 10, tA, fA_, bA, TXA.get(VZT_LV), text.align_center, true)
    true
// the day after FOMC, Desktop
drawShF1() =>
    if barstate.islast and showSh and not na(TH) and isF and not mob
        int   r = thO
        float a = uA
        int   z = uZ
        cardHead(TH, r, cSh, sgDot() + " SHIROSAKI · FOMC +1", TXA.get(VZT_SHF), str.tostring(shN()) + " ✓", cSh, #ffffff)
        cardSub(TH, r + 1, cSh, "NQ+ES+RTY · ADR " + sgP(a), "today", stS ? "base · live" : "base")
        cardWide(TH, r + 2, cSh, "SIDE", uVg == 1 ? "VIX near avg: NY AM down 64% vs 42% ✓" : "none held: size the day", TXA.get(VZT_SHF), uVg == 1 ? cOk : cSub)
        cardRow(TH, r + 3, cSh, "FH/FL", hlH(88 + 2 * z), "RTH takes · " + zWd(z), fl(88 + 2 * z), "FH" + pcV(161) + " FL" + pcV(162), TXA.get(VZT_FMON))
        cardRow(TH, r + 4, cSh, "FH/FL", hlH(shGi()), "RTH takes · " + shGn(), fl(shGi()), "", uGg != 1 ? TXA.get(VZT_FGP) + " " + TXA.get(VZT_FP) : TXA.get(VZT_FP))
        cardRow(TH, r + 5, cSh, "RANGE", vh(shRi()), "RTH range · " + (uVg == 0 ? "VIX high" : uVg == 2 ? "VIX low" : zWd(z)), sgP(VS.get(shRi()) * a), "all " + sgP(VS.get(165) * a), TXA.get(VZT_FVX) + " " + TXA.get(VZT_FE))
    true
drawShF2() =>
    if barstate.islast and showSh and not na(TH) and isF and not mob
        [xi, xn, xB] = shHL()
        int r = thO
        cardRow(TH, r + 6, cSh, "H/L", hlH(xi), "after 09:30 · " + xn, hl(xi), xB, "New day high (H) / low (L) after 09:30 for today's most specific group (" + xn + "). " + TXA.get(VZT_F18) + " " + TXA.get(VZT_FPD))
        cardRow(TH, r + 7, cSh, "FILL", vh(97 + uGg), gLab + " · filled by 16:14", pcV(97 + uGg) + "%", gpB(166, sFill), "The whole gap filled by 16:14. " + TXA.get(VZT_FGP), na, cF)
        cardRow(TH, r + 8, cSh, "½ NY AM", vh(100 + uGg), gLab + " · 50% by 11:00", pcV(100 + uGg) + "%", gpB(167, sHalf), "The gap's 50% traded in NY AM. " + TXA.get(VZT_FGP), na, cH)
        cardRow(TH, r + 9, cSh, "¼ OPEN", vh(152 + uGg), gLab + " · held NY AM", pcV(152 + uGg) + "%", gpB(168, sQ), TXA.get(VZT_Q), na, cQ)
        cardRow(TH, r + 10, cSh, "DXY RTH", true, "BIG ≥ 0.52 → other way", "81%", "vs 41%", TXA.get(VZT_FDR))
        if stS
            [tR, fR, bR] = dxPill(dvR, svR, 0.52)
            tcQ(TH, 4, r + 10, tR, fR, bR, TXA.get(VZT_LV), text.align_center, true)
    true
// Mobile, both days
drawShM1() =>
    if barstate.islast and showSh and not na(TH) and mob
        [base, zi, tg, agr, agT] = shSize()
        [xi, xn, xB] = shHL()
        int   r = thO
        float a = uA
        cardHead(TH, r, cSh, sgDot() + " SHIROSAKI", isF ? TXA.get(VZT_SHF) : TXA.get(VZT_SHW), str.tostring(shN()) + " ✓", cSh, #ffffff)
        if isF
            cardRow(TH, r + 1, cSh, "FH/FL", hlH(shGi()) or hlH(88 + 2 * uZ), shGn(), fl(shGi()), "", TXA.get(VZT_FP))
        else
            cardRow(TH, r + 1, cSh, "RANGE", vh(zi), zWd(uZ) + " " + sgP(VS.get(zi) * a) + " pts", "", "", TXA.get(VZT_WE))
            tcQ(TH, 3, r + 1, agr, agFg(agr), agBg(agr), agT, text.align_center, true)
        cardRow(TH, r + 2, cSh, "H/L", hlH(xi), "after 09:30 · " + xn, hl(xi), "", isF ? TXA.get(VZT_F18) : TXA.get(VZT_W18))
    true
drawShM2() =>
    if barstate.islast and showSh and not na(TH) and mob
        int r  = thO
        int iH = isF ? 100 + uGg : 48 + uGg
        int iF = isF ? 97 + uGg : 51 + uGg
        cardRow(TH, r + 3, cSh, "½", vh(iH), gLab + (isF ? " · by 11:00" : " · by 10:00"), pcV(iH) + "%", gpOn ? sHalf : "", isF ? TXA.get(VZT_FGP) : TXA.get(VZT_WGP), na, cH)
        cardRow(TH, r + 4, cSh, "FILL", vh(iF), gLab + " · by 16:14", pcV(iF) + "%", gpOn ? sFill : "", isF ? TXA.get(VZT_FGP) : TXA.get(VZT_WGP), na, cF)
        cardRow(TH, r + 5, cSh, "DXY", true, "RTH BIG → other", isF ? "81%" : "70%", "", isF ? TXA.get(VZT_FDR) : TXA.get(VZT_WDR))
        if stS
            [tR, fR, bR] = dxPill(dvR, svR, isF ? 0.52 : 0.26)
            tcQ(TH, 4, r + 5, tR, fR, bR, TXA.get(VZT_LV), text.align_center, true)
    true
drawShW1()
drawShW2()
drawShW3()
drawShF1()
drawShF2()
drawShM1()
drawShM2()
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
