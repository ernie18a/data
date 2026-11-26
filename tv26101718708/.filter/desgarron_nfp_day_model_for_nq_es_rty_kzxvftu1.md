# Desgarron - NFP Day Model for NQ, ES + RTY

- url: https://www.tradingview.com/script/KZxVftU1-Desgarron-NFP-Day-Model-for-NQ-ES-RTY/
- type: indicator
- pine_id: PUB;8e0f1252706347799461be78c81e6715
- version: 2.0

## Description

[image]https://www.tradingview.com/x/LDHZCuvU/[/image][b]Desgarron[/b] maps NFP days: the Employment Situation report, released at 08:30 ET. It covers five things:
• the structure the release trades into;
• how far NFP days with today's setup usually move, at today's ADR20;
• each release stage live against the dollar;
• Grimmjow, a table of what held for today's setup;
• today's range against the typical NFP day.
The figures are pooled across NQ, ES and RTY: 99 releases and 293 symbol-days. A ✓ row held in 2018–24, again in 2025–26, and on each of the three markets. [i]It is a map of how NFP days usually behave, not a signal generator.[/i]

[image]https://www.tradingview.com/x/iZPDjOjm/[/image]
[b]WHAT IT DRAWS ON PRICE[/b]

• [b]Pre-release range (07:00–08:29):[/b] drawn live from 07:00. It stops at the bar where the release breaks one of its sides.
• [b]Dealing range (07:00–09:00):[/b] created when the release breaks the pre-release range, or at 09:00 if it never does. It is drawn from 07:00, follows the high and low until 09:00, then stays fixed, with an optional 50% line and fill.
• [b]Release window:[/b] 08:30 to 09:00 is shaded (the end is adjustable). A flag above the release push is tied by a stem to the 08:30 open.
• [b]Stage lines:[/b] the 08:50 line, plus the 08:30 and 08:50 opens carried right of price.
• [b]Week open and RTH gap:[/b] the week's open carried right, and from 09:30 the prior 16:14 close and the gap's 50%.
• [b]ATH:[/b] the all-time high, drawn from the day it was set and carried right of price.
• [b]ATH CE:[/b] at 08:30, the consequent encroachment (50%) between the ATH and the 08:29 close forms. It runs to 17:00 or into the next session to 11:00 (the Monday after a Friday release). Its label gives how often NFP days touched it from that distance.

How often NFP days touched the CE, by its distance from price at 08:29 (by 17:00 / by the next session's 11:00):
• within 0.5 ADR: [b]79%[/b] / [b]83%[/b];
• 0.5–1 ADR: 23% / 31%;
• 1–2 ADR: 1% / 6%;
• beyond 2 ADR: 0% / 0%.

[image]https://www.tradingview.com/x/xBFpM0e0/[/image]
[b]STAGES CARD[/b]

Stage 1 is 08:30 → 08:50 (the release push). Stage 2 is 08:50 → 09:30 (into the RTH open). The header pill shows where price sits in the month's range: [i]discount[/i] (bottom quarter), [i]middle[/i] or [i]premium[/i] (top quarter). It shows this first because it is the setup that sized NFP days most.

[b]SETUP[/b] runs live, then is fixed at 08:29 on NFP day. Each row shows the odds for its group:
• the month's octant;
• the distance from the month's open;
• the prior day's high and low;
• the move since 18:00;
• the week into the release;
• VIX against its 20-day average.

[b]EXPECT[/b] (before 08:30) gives the median and 80th percentile at today's ADR20 for:
• the range after 08:30;
• NY AM;
• stage 1 and stage 2.

[b]LIVE[/b] (after 08:30) shows:
• each stage in points, against its expected size and against DXY's move in the same window;
• the range since 08:30 against the expected median.


[b]GRIMMJOW (INDICATOR PANE)[/b]

Grimmjow lists what held on NFP days for today's setup, in points at today's ADR20.
• [b]Range after 08:30[/b] for today's month position: [b]1.21[/b] ADR from a discount vs [b]0.88[/b] from a premium ✓. A second row lists the other size groups active today and whether they point bigger or smaller:
  – VIX more than 10% over its average: 1.35 ✓; more than 10% under: 0.69 ✓;
  – week up more than 0.5 ADR into the release: 0.82 ✓; week down: 1.34 ✓;
  – more than 1 ADR over the month's open: 0.90 ✓; under: 1.37 ✓.
• [b]New high / low after 08:30[/b] for the most specific group active today:
  – from a monthly discount, a new low came on [b]91%[/b] of days ✓;
  – from below the prior day's low: new high 36% ✓, new low 92% ✓;
  – after a drop of more than 0.4 ADR since 18:00: new high 19% ✓, new low 85% ✓.
• [b]ATH CE:[/b] its distance, its odds and when it was hit. Within 0.5 ADR is held ✓.
• [b]First side of the pre-release range taken after 08:30:[/b] it went on to be the bigger side of the day 59% of the time. With VIX more than 10% under its average: [b]79%[/b] ✓. After an up week: 74% ✓. After a flat week: 46% ✓. The row also shows which side broke and when.
• [b]DXY:[/b] once DXY's move is big, the index went the other way:
  – stage 1 (DXY moved ≥ 0.42 of its ADR20): [b]82%[/b] vs 53% ✓;
  – stage 2 (≥ 0.22): [b]71%[/b] vs 59% ✓.
• [b]08:30–09:00:[/b] the day's range grows [b]+0.14[/b] ADR at the median, against nothing on ordinary days ✓.
• [b]Side:[/b] a HYDRA search over everything knowable at 08:29 found no feature that called the direction out of sample. That is why both the card and Grimmjow size the day rather than pick a side.

[image]https://www.tradingview.com/x/F1xksgji/[/image]
[b]EVENT CLOCK AND TALLY[/b]

• [b]Event clock (pane):[/b] today's running range from 18:00 (or its net move), against NFP days or normal days at the same time of day. It shows the median path with 25–75% and 10–90% bands, in half-hour steps at today's ADR20. A NOW status reads [i]Above[/i], [i]Inside[/i] or [i]Below[/i] the middle half.
• [b]Tally card:[/b]
  – the last N NFP days' up and down closes and their average RTH gap;
  – where price sits in this week's and this month's range, by octant;
  – the next release.
  [i]The octant is a locator, not a tested signal.[/i]

[image]https://www.tradingview.com/x/HAc1Ynm1/[/image]
[b]SETTINGS[/b]

[b]View[/b] sits at the top, the same as in my other indicators:
• [b]Pane:[/b] clock + Grimmjow, the clock, Grimmjow, or cards only;
• [b]Clock measure:[/b] range or net move;
• [b]Theme:[/b] Auto follows the chart;
• [b]Layout:[/b] Desktop or Mobile;
• [b]Card text:[/b] tiny, small or normal.

[b]Model structure[/b] has on/off, colour, style and width for each range, plus the 50% line and fill, how far the ranges run, the release window's end, label size, the ATH style and the CE's end.

[b]Mobile[/b] folds the cards for a phone: a five-row stages card and a six-row Grimmjow. The full wording stays in the tooltips.


[b]HOW TO USE[/b]

• Built for [b]NQ / MNQ[/b], [b]ES / MES[/b] and [b]RTY / M2K[/b], continuous or front month. On other symbols the clock and tally show NQ's figures.
• 1 to 15-minute charts suit the structure. The stages need 30 minutes or less, and the clock 60 minutes or less.
• Make the indicator pane tall enough for Grimmjow.
• For a phone, use a separate chart layout with [i]Layout = Mobile[/i], since chart layouts sync across devices.


[b]DATA AND METHOD[/b]

• NQ, ES and RTY front-month 1-minute data, Jan 2018 – Oct 2026: 99 NFP releases, 293 symbol-days.
• A row gets a ✓ only if all of these held:
  – p < 0.05 with errors clustered by release date;
  – the same side in 2018–24 and in 2025–26;
  – the same side on each of NQ, ES and RTY.
• Several thousand group tests were run across the calendar models, so treat the ✓ rows as the steadiest descriptions, not proven edges. The rows with the most days behind them (range by month position, VIX and the week into the release, the big-DXY rows) are the most dependable.
• DXY rows: DXY futures, Feb 2023 – Jul 2026 (60 big-move stage-1 readings on 20 releases). On the chart they read TVC:DXY, which can be changed in the inputs.
• [b]ADR20[/b] = mean (high − low) of the last 20 complete trading days.
• Release dates come from the BLS schedule and are loaded to Dec 2027. Add new years in S_NFP and raise LAST_DATE.
• No higher-timeframe value leaks future data.


[b][image]https://www.tradingview.com/x/LDHZCuvU/[/image]LIMITATIONS[/b]

[i]These are historical frequencies on 99 releases: useful context, not guarantees.[/i] Same-window DXY rows describe how a stage finishes and cannot be known in advance. In Bar Replay, TradingView may not feed TVC:DXY minute by minute, so the DXY pills can read near zero there. The 2025 lapse moved two releases (20 Nov and 16 Dec 2025); both are in the dates. Nothing here is financial advice.


[b]CREDITS[/b]

ICT concepts ([i]Michael J. Huddleston[/i]): the dealing range, consequent encroachment, premium and discount, the RTH gap and its 50%. Event clock after Kyōka Suigetsu. Part of the Hueco Mundo set; Grimmjow's claws are Model 6's disruption idea. Written from scratch; open source under MPL 2.0.

## Source Code

````pine
//@version=6
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Unclehk2000
//
// Desgarrón (豹王の爪) · Model 6: NFP days (Employment Situation, released 08:30 ET). Grimmjow's tearing claws: the
// release that tears into whoever is already positioned, Model 6's disruption idea.
// On the price chart: the pre-release range 07:00–08:29 (drawn live from 07:00); once the release breaks it, the 07:00–09:00
// dealing range (with its 50%); the release window from 08:30 and a flag tied to the 08:30 open; the 08:50 line, the RTH
// gap (prior 16:14 close and its 50%), the 08:30 and 08:50 opens, the all-time high carried right of price and, from
// 08:30, the consequent encroachment between the ATH and the 08:29 close, to 17:00 or the next session's 11:00. Two cards:
// the NFP tally and the NFP stages card, led by where price sits in the month's range (discount / middle / premium).
// Indicator pane: the event clock (today's running range against NFP days) and Grimmjow, the HYDRA findings table: what
// held for today's setup, in points at today's ADR20.
// Built for NQ / MNQ, ES / MES and RTY / M2K. The stages card and the findings are pooled across NQ, ES and RTY 1-minute
// data, Jan 2018 – Oct 2026 (293 symbol-days on 99 releases); the clock and tally use the chart's own symbol. A green key
// (✓) held: p < 0.05 with errors clustered by release date, the same side in 2018–24 and 2025–26 and on each symbol.
// Release dates were checked against the BLS and Federal Reserve schedules and are loaded to Dec 2027; update once a year.
// Clock after Kyōka Suigetsu. Written from scratch.
// Concepts: ICT (Michael J. Huddleston).

indicator("Desgarrón", "Desgarrón", overlay = false, max_boxes_count = 300, max_lines_count = 400, max_labels_count = 400, max_polylines_count = 60)

TZ = "America/New_York"

// ═══════════════════════════════════════════════════════════════ Inputs
grpW = "View"
paneI   = input.string("Clock + Grimmjow", "Pane", options = ["Clock + Grimmjow", "Event clock", "Grimmjow", "Cards only"], group = grpW, tooltip = "What the indicator pane shows. Event clock: today's running range (or net move) against NFP days at the same time of day. Grimmjow: the HYDRA findings table for today's setup. Cards only: neither (the clock card stays where you put it).", display = display.none)
clkMet  = input.string("Range", "Clock measure", options = ["Range", "Net move"], group = grpW, tooltip = "Range: the day's high − low so far. Net move: price − the 18:00 open. Both in points, against the same measure on NFP days (2018–26), scaled to today's ADR20 of the trading day. Needs an intraday chart of 60 minutes or lower.", display = display.none)
themeI  = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = grpW, tooltip = "Auto follows the chart background.", display = display.none)
layI    = input.string("Desktop", "Layout", options = ["Desktop", "Mobile"], group = grpW, tooltip = "Desktop: every row. Mobile: narrow cards for a phone screen (the clock folded into the tally's NOW row, a five-row stages card, a six-row Grimmjow); the full wording stays in the tooltips. For a phone, use a separate chart layout set to Mobile, since layouts sync across devices.", display = display.none)
crdSzI  = input.string("Small", "Card text", options = ["Tiny", "Small", "Normal"], group = grpW, display = display.none)

grpE = "Event day"
anchorI  = input.string("Trading day (18:00)", "Day", options = ["Trading day (18:00)", "NY midnight", "RTH (09:30–16:14)"], group = grpE, tooltip = "Which day counts as the event day for the tally.\nTrading day: the CME day, 18:00 → 17:00 ET.\nNY midnight: 00:00 → 17:00 ET.\nRTH: 09:30 → 16:14 ET (close of the 16:14 bar).\nThe clock always runs on the trading day.", display = display.none)
markEv   = input.bool(true, "Mark releases", group = grpE, inline = "g3", display = display.none)
markD    = input.int(90, "and model structure for the last (days)", minval = 5, maxval = 400, group = grpE, inline = "g3", display = display.none)

grpS = "Model structure"
showStr = input.bool(true, "Draw the model's levels and windows", group = grpS, display = display.none)
cLvl    = input.color(#ffb300, "Levels", group = grpS, inline = "s1", display = display.none)
cGh     = input.color(#ff7043, "Model", group = grpS, inline = "s1", display = display.none)
lblI    = input.string("Tiny", "Labels", options = ["Tiny", "Small", "Normal"], group = grpS, inline = "s1", display = display.none)
offI    = 12
showDR0 = input.bool(true, "Pre-release range 07:00–08:29", group = grpS, inline = "d0", display = display.none)
cDR0    = input.color(#90a4ae, "", group = grpS, inline = "d0", display = display.none)
stDR0   = input.string("Dashed", "", options = ["Solid", "Dashed", "Dotted"], group = grpS, inline = "d0", tooltip = "Drawn live from 07:00 and fixed at 08:29. When the release takes one of its sides it stops at that bar and the 07:00–09:00 dealing range takes over.", display = display.none)
showDR  = input.bool(true, "Dealing range 07:00–09:00", group = grpS, inline = "d1", display = display.none)
cDR     = input.color(#ffb300, "", group = grpS, inline = "d1", display = display.none)
stDR    = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted"], group = grpS, inline = "d1", display = display.none)
wDR     = input.int(1, "", minval = 1, maxval = 4, group = grpS, inline = "d1", tooltip = "Created when the release breaks the pre-release range (at 09:00 if it never does): drawn from 07:00, it follows the high and low until 09:00, then stays fixed.", display = display.none)
drEq    = input.bool(true, "50%", group = grpS, inline = "d2", display = display.none)
drFill  = input.bool(false, "Fill", group = grpS, inline = "d2", display = display.none)
drEnd   = input.string("16:14", "Ranges run to", options = ["11:00", "16:14", "17:00"], group = grpS, inline = "d2", display = display.none)
relEnd  = input.string("09:00", "Release window 08:30 →", options = ["08:45", "08:50", "09:00", "09:30"], group = grpS, inline = "w0", display = display.none)
cHands  = input.color(color.new(#f23645, 85), "", group = grpS, inline = "w0", tooltip = "Shades the release on NFP days. Model 6's hands-off window is 08:30–08:45; 09:00 covers the half hour that adds +0.14 ADR to the day's range.", display = display.none)
showWO  = input.bool(true, "Week open, 08:30 / 08:50 opens", group = grpS, inline = "o0", display = display.none)
showGap = input.bool(true, "RTH gap", group = grpS, inline = "o0", tooltip = "The week's open (Sunday 18:00) and, on NFP days, the open of the 08:30 and 08:50 candles, carried right of price. RTH gap: the prior 16:14 close and the gap's 50%, from 09:30.", display = display.none)
showATH = input.bool(true, "ATH", group = grpS, inline = "s2", display = display.none)
cAth    = input.color(#ab47bc, "", group = grpS, inline = "s2", display = display.none)
stAth   = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted"], group = grpS, inline = "s2", display = display.none)
showCE  = input.bool(true, "08:30 CE to", group = grpS, inline = "s3", display = display.none)
ceEnd   = input.string("Next session 11:00", "", options = ["17:00", "Next session 11:00"], group = grpS, inline = "s3", tooltip = "ATH: the all-time high, drawn from the day it was set and carried right of price. CE: on NFP days at 08:30, the consequent encroachment (50%) between the ATH and the 08:29 close, carried to 17:00 or into the next session (Monday after a Friday release) to 11:00. Its label gives how often pooled NFP days touched it by then at that distance.", display = display.none)

grpK = "Event clock (indicator pane)"
clkOn  = paneI == "Clock + Grimmjow" or paneI == "Event clock"
kBands = input.bool(true, "10–90 and 25–75 bands", group = grpK, display = display.none)
kRef   = input.bool(true, "Reference path", group = grpK, tooltip = "On NFP days: the normal-day median. On other days: the next NFP day's median, so you can see how its day usually unfolds.", display = display.none)
kPast  = input.bool(true, "Earlier days, faded", group = grpK, display = display.none)

grpR = "Cards (price chart)"
showEv  = input.bool(true, "Event tally", group = grpR, inline = "r1", display = display.none)
crdPos  = input.string("Top right", "", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = grpR, inline = "r1", display = display.none)
talN    = input.int(12, "last", minval = 3, maxval = 60, group = grpR, inline = "r1", tooltip = "The last N NFP days (up / down closes, average RTH gap), where price sits in this week's and this month's range in octants (top quarter = premium, bottom quarter = discount), and the next release.", display = display.none)
showCk  = input.bool(true, "Clock card", group = grpR, inline = "r3", display = display.none)
ckOn    = input.string("Indicator pane", "", options = ["Price chart", "Indicator pane"], group = grpR, inline = "r3", display = display.none)
ckPos   = input.string("Top right", "", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = grpR, inline = "r3", display = display.none)
cAcD    = input.color(#00897b, "Accent · DXY", group = grpR, inline = "r4", tooltip = "Stripe colour of the DXY rows. The tally, clock and stages cards use the Model colour.", display = display.none)

grpM = "DXY · VIX"
dxySym  = input.symbol("TVC:DXY", "DXY", group = grpM, inline = "m0", display = display.none)
vixSym  = input.symbol("CBOE:VIX", "VIX", group = grpM, inline = "m0", tooltip = "Read for the stages card: DXY's moves in stage 1 and 2 in its own ADR20, and VIX's prior close against its 20-day average.", display = display.none)
grpV    = "NFP stages card"
showSg  = input.bool(true, "Stages card", group = grpV, inline = "v0", tooltip = "SETUP: where price stands against the month's range, the month's open, the prior day and the 18:00 open, the week into the release and VIX (live, then fixed at 08:29 on NFP day). EXPECT: how far NFP days with that setup moved in stage 1 (08:30–08:50), stage 2 (08:50–09:30), NY AM and after 08:30, at today's ADR20. LIVE (NFP day): each stage against DXY and the 08:30–09:00 expansion. Needs a chart of 30 minutes or less for the stages.", display = display.none)
sgOn    = input.string("Price chart", "", options = ["Price chart", "Indicator pane"], group = grpV, inline = "v0", display = display.none)
sgPos   = input.string("Bottom left", "", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = grpV, inline = "v0", display = display.none)
grpH    = "Grimmjow: HYDRA findings (indicator pane)"
showHy  = paneI == "Clock + Grimmjow" or paneI == "Grimmjow"
hyPos   = input.string("Top left", "Position", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = grpH, inline = "h0", tooltip = "What held on NFP days (NQ + ES + RTY pooled, 2018–26) for today's setup, in points at today's ADR20: the range after 08:30, whether the other size groups agree, which extreme the day is likely to make, the ATH CE odds, the first side of the pre-release range, the DXY rules for stages 1 and 2 and the 08:30–09:00 expansion. A green key = held. Shares the pane with the event clock.", display = display.none)
cHy     = input.color(#5e35b1, "Accent", group = grpH, inline = "h0", display = display.none)
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
CK_NQ = "8:8@8N8S8f8r8z9(9+97999=9D9H9K9X9Y9`9m9p9p9s9~:):*:*:7:7:7;r;|<N<s=(=)=-=0=T=i=i=i=q=q=q=q=u8H8W8c8l9-999G9M9Y9e9j9m9v9z:$:&:/:;:O:W:_:f:j:m:q:r:{;-;@<t=!>,>W?2?:?V?V?X?j?o?w?w?w@B"
     + "@B@B8a8u9-9A9]9z:(:7:B:L:M:M:N:[:q:s;);4;J;K;`;e;n;q;y<&<2<;<?>C>j?R@VA$A]B-B2BGB`BjBqC1C8C8C8C89/9T:!:6:X:t;+;A;Q;R;W;i;m<+<Z<Z<^<q=C=Q=k=k=k=q=}>&>&>5>5@M@cB1BiCOC_DFDmD~E8ERF%Fb"
     + "FsFtFtFt:,:V:~;E<#<_='='=P=P=l=l=l>&>.>G>b>n>|?a?r?r?}?~@,@,@,@1@1B>C%CwF<FjGbHZHZI?JNJQJeJeJnK0KqKq6z6b605V5.4t4O5W524y4i4c5%4r4n4u4C3a4-3;3a3T3X3:3U3$3/2u3N0A1>/r/t/(,v-(,n,6,.+H"
     + ",I+L,!,k-,-#7I7@726q6s6Z6n7$6r6c6g6e6g6}6c6P6M6O6L686)5u6#5j5r5u5o5u5R3q4@3S433:2s3F2|3-2s2E1[2D1N2(1d1^7i7k7b7b7e7v7s7z7u7x7~7w8.8*8*8$7e7^7P7w7t8(8-888,7|828&8=8B888&8D8b8d8.8'7T"
     + "7Y7l7q7?7r7`7U7h8-87878=8O8`8g8r9&9,8}8|9$9.9>9?95949M98909,9=9M9H9Q9U9J9Y:{;(;u<9<k<x=f>A>#=h=L=b>2>s?I>o>I8E8Q8z9.969^9a9c9d9w9}:#:-:C;2:i:f:f:=:S:a:s:s;0;D;3;6;2;7=&=M>}@&@o@>A5"
     + "AbApAtB.BQBjBLB@B)B:8d8v9+9;9T9k:&:3:4:<:@:N:O:R:]:e:n:s;(;L;P;V;];g;u<$<.<8<;>(>O?S@6A+ALAnB%B2BJBZBZBZBZBZBZBZ8<8E8N8Z8l8v9$9,9295989:9?9@9B9J9R9Y9l9s9~:*:4:9:=:B:I:T:b:l:q;V;w<0"
     + "<A<L<Y<b<k<v=$=(=+=7=F=H8K8W8f8v9/9>9H9S9^9c9g9j9l9o9u9~:-:5:I:U:f:n:t:|;&;.;6;>;F;U;`<Q<~=<=T=h=z=~>3>;>I>S>Y>j>q>s8k8~949D9d9t:&:5:C:K:S:W:_:b:h:q:~;0;H;V;f;u;|<'<.<<<G<N<[<r=#>'"
     + ">Y?)?E?[?s@+@4@E@O@a@sA*A9A=9C9[9{:1:[:{;2;E;O;Y;e;k;s;v;~<,<@<R<n<}=9=G=Z=c=r>!>,>>>Q>q?#@0A&APAzB6BPBgBxC,CBCXCuDADLDV:K:u;1;V;x<@<R<n=3===@=T=]=d=n=x>;>K>g?(?I?R?v@.@8@G@U@g@uA9"
     + "AHBoCaDGE(ENEjF.FEFoG-GIGiH-HCHR6u6c6Q6C615p5X5V5K5D5A5>53545)5)5&4m4`4V4G4G4:4-4+444,3c3`3P3Q2Q1W1C1!0~0r0U0E0F/z/v/K/E/2/#7C7>777.6}6|6w6r6m6i6l6j6m6g6c6a6X6]6N6F6@6@686464616?60"
     + "6/6&5{5N555+5/4{4g4n4h4m4U4C4B4G4A4@7k7m7r7s7w7u7w7u7w7v7u7u7u7w7x7{8%8#8%8&81828,868/878;8@8484808*8*8:858=8C8>85858E8D8H8E8L8N888?8L8R8c8l8w8|9!9&9'9+9*91939?9H9M9V9`9e9o9s9x9r9}"
     + "9x9x:$:6:3:m;,;%;A;_;];k;l<&<0<9<;<O<Q<b8k8x909<9X9g9v:0:0:6:>:G:M:I:O:]:g:s:|;4;K;L;T;V;c;[;^;h<)<?<C=K=a>/>F>t?%???R?Z?T?f@;@5@4@B8|949K9c:(:::O:_:n:u;#;(;,;3;=;E;U;g<%<8<K<W<e<r"
     + "<~=+=7=L=]=~>.?H@)@^A*AKAcAuB,BDBZBZBZBZBZBZ"
CK_ES = "8@8Q8X8d8w8{9#9.9/999E9H9J9S9V9]9]9^9r:$:+:0:E:E:J:J:V:V:W<0<0<@<Z<c<j<u=,=:=H=K=K=K=K=m=t=y8M8_8j8u9-9?9O9_9`9q9s9s9t9x9x:#:0:2:Q:T:j:r:v:y:y;!;);/;C=7=S>!>L?<?M?U?V@I@O@P@P@P@P@m"
     + "@p@p8h8w9<9J9l9|:4:K:L:Z:^:t:y:|:~;!;*;-;>;N;W;Z</<2<?<M<T<`<c>e?C@5A!AMAYAoB1B=BhBrBrBrBrC*C*C*9@9d:.:F:k;-;8;G;G;G;P;m;q<H<R<^<o<{=G=M=d=d=d=h>#>3>7>7>C@OA7B9C0CpD7E;EcEqF2FbG>GM"
     + "GdG}G}G}:2:X;H;_;r<x=H=M=f=f=f=f=f=w>F>R?6?7?L?O?O?O?{?{@E@E@E@Y@aBrB~D$F%FaGEIMIXJCJLJLJqKpLFLoLoLo6z6M6<5Z5Q5!5i5R5(4T4l4k4}4O4U4y5%4K483^3l3O3U3J30392k3L310x1h/r/a.2-Z,?+v,V-1+-"
     + ",2,9+f,|,V,g7E7@7,6}6j6e6i6t6e6q6^6[6{6k6j6m6U6I6+5o6,5V5e5]6%5r5w5U5n4/454}3t3t2Q3%342}372K2X2U1y362o2x7p7r7p7f7c7u7w7s8+8(8183868:888$7t7t7e7u7w8%8*82877g8,87829!8e8z8}9=9<8*8f7f"
     + "7b8(867w867b7u8'8,848?8=8N8c8d8q9!919(8y9'9#9+9:999S959Q9D9H9U9[:%:$9v9o:-;W;W<2<C=8=.=`=_=b=n>,>f>X>w>8>J>j8T8]9'9?9G:%9n9t9~:19y:#:4:G:v:a:q;#:G:r;-;F;`;J;`;U;H;A;:=K><>~?PA>@dA%"
     + "A;AIB&AfAzB#BNBsC0C(8h8y959J9c9s9z:,:9:F:P:P:S:V:`:g:l:u;:;@;N;];f;g;|;~</<4<;>7>H?3@CA/A?AbAxB)BABZBZBZBZBZBZBZ8>8G8S8`8q8}9(9196989<9>9B9D9H9L9T9[9j9v:#:):/:5:<:C:J:O:Z:i:m;7;T;m"
     + ";y<(<-<4<<<J<X<h<p=&=-=38P8^8n8|959C9M9X9_9e9i9m9o9s9y:%:/:7:K:Z:f:p:y:~;(;.;5;=;G;];h<2<S<q=/=?=Q=]=g=o=x>(>3>U>^>`8p9&999K9l9}:/:?:I:Q:X:Z:a:g:m:w;);1;K;_;n;v<#<,<6<?<K<U<b<}=1=p"
     + ">B>e?#?/?I?_?n?y@.@>@V@p@~A&9H9d:':>:_:};6;P;^;l;q;x;}<*</<;<K<]<~=7=P=m=}>/>:>F>M>b>p?$?2@(@oA?AgA~B:BWBvC@COCcC|DDDODT:P;#;<;a</<B<a=3=E=[=a=i=x=}>0>=>Y>k?5?P?a?n@%@2@M@_@vA>AKAh"
     + "B)C.CyDZE#EUEsF4FeG,GdGrHII3I;IM6o6^6K6@6)5s5[5O5G5C575:5%5.4v4w5)4o4Q4K464+4(4'3r3w3}3^3Q373>2Z271|1R1C0{0S0N0=0@/{/f/A/M/=7B7<757(6{6v6n6m6b6`6h6b6_6]6Y6Z6P6N6@656<6764626+616.6/"
     + "6,6#5|5p5W5O5O575,5.5&4|4r4q4s4M4E4?7m7p7q7r7q7q7s7w7w7s7x7v7x7y7s7w7{8!8$8*8+8+8*8.80878/818/828488818<888=84838=8C8F8U8N8F8N8H8:8B8L8Q8c8n8t8t8}9$9(9)9.9/929<9H9J9P9]9l9n9w9x9z9{"
     + ":*:0:.:<:8:W:p:y;%;);G;J;R;m;z<&<3<D<N<Q8m8x909@9]9g9s:%:-:3:<:A:J:Q:N:[:j:d:};4;I;V;V;_;b;p;n;l<!<7<>='=P=h>9>H>a?*?5?Y?a?s@#@D@E@J9%9=9V9o:4:H:Z:j:{;(;0;5;=;A;K;R;f;s<2<H<a<p<~=,"
     + "===E=T=d=w>6>F?6?z@@@fA.AHAZAxB5BMBZBZBZBZBZ"

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

// ── pooled NQ + ES + RTY card data (generated by hydra_cal/pool_pine.py)
var array<float> VS = parseStats("0.16,0.33,0.15,0.31,0.18,0.36,0.08,0.19,0.08,0.18,0.06,0.15,0.36,0.72,0.28,0.61,0.21,0.44,1.21,1.49,1.06,1.55,0.88,1.13,1.27,2.16,0.96,1.43,0.78,1.03,80,40,81,64,36,92,88,25,80,65,19,85,61,91,80,59,79,54,0.90,0.91,1.37,1.35,0.94,0.69,0.82,0.90,1.34")
VH = "000000000000000000100010100010011011011011110001101101101"
var array<float> OC = parseStats("29,1.34,66,93;37,0.94,57,89;32,1.30,69,72;24,1.18,92,62;20,0.98,90,50;25,0.91,76,48;45,0.90,71,64;81,0.87,83,48")
// long texts live in one runtime array, so each is embedded once (Pine folds a constant string into every use)
var array<string> TXA = array.new<string>()
txAdd(string s) =>
    TXA.push(s)
    TXA.size() - 1
var int VZT_MON = txAdd("NFP days 2018–26, NQ + ES + RTY pooled (293 symbol-days on 99 releases), read at 08:29, in ADR20. By the month's position (bottom quarter = discount, top quarter = premium). R = range after 08:30, H / L = new day high / low after 08:30. discount (n 66) R1.21 H61% L91% · middle (n 101) R1.06 H80% L59% · premium (n 126) R0.88 H79% L54%. Held: ✓ discount: range after 08:30 1.21 vs 0.92 (2018–24 1.16 vs 0.92, 2025–26 1.32 vs 0.96); new high after 08:30 61% vs 79% (2018–24 65% vs 80%, 2025–26 42% vs 78%); new low after 08:30 91% vs 56% (2018–24 91% vs 55%, 2025–26 92% vs 61%); ✓ premium: range after 08:30 0.88 vs 1.14 (2018–24 0.87 vs 1.09, 2025–26 0.95 vs 1.21); new low after 08:30 54% vs 72% (2018–24 54% vs 71%, 2025–26 56% vs 74%). ✓ = p < 0.05 with errors clustered by release date, the same side in 2018–24 and 2025–26, and on NQ, ES and RTY separately.")
var string VZT_MO = "NFP days 2018–26, NQ + ES + RTY pooled (293 symbol-days on 99 releases), read at 08:29, in ADR20. Over / under = more than 1 ADR from the month's open. over (n 75) R0.90 H81% L53% · within (n 162) R0.91 H72% L64% · under (n 56) R1.37 H75% L80%. Held: ✓ over: range after 08:30 0.90 vs 1.02 (2018–24 0.90 vs 1.00, 2025–26 0.90 vs 1.23); ✓ under: range after 08:30 1.37 vs 0.91 (2018–24 1.34 vs 0.91, 2025–26 1.70 vs 0.89); new low after 08:30 80% vs 60% (2018–24 77% vs 60%, 2025–26 100% vs 61%). ✓ = p < 0.05 with errors clustered by release date, the same side in 2018–24 and 2025–26, and on NQ, ES and RTY separately."
var int VZT_PD = txAdd("NFP days 2018–26, NQ + ES + RTY pooled (293 symbol-days on 99 releases), read at 08:29, in ADR20. Against the prior day's high (PDH) and low (PDL). above PDH (n 40) R0.93 H80% L40% · inside (n 217) R0.91 H81% L64% · below PDL (n 36) R1.29 H36% L92%. Held: ✓ above PDH: new low after 08:30 40% vs 68% (2018–24 35% vs 68%, 2025–26 67% vs 68%); ✓ inside: new high after 08:30 81% vs 59% (2018–24 81% vs 63%, 2025–26 79% vs 43%); ✓ below PDL: range after 08:30 1.29 vs 0.92 (2018–24 1.20 vs 0.92, 2025–26 1.65 vs 0.96); new high after 08:30 36% vs 81% (2018–24 43% vs 81%, 2025–26 12% vs 80%); new low after 08:30 92% vs 60% (2018–24 89% vs 60%, 2025–26 100% vs 62%). ✓ = p < 0.05 with errors clustered by release date, the same side in 2018–24 and 2025–26, and on NQ, ES and RTY separately.")
var int VZT_18 = txAdd("NFP days 2018–26, NQ + ES + RTY pooled (293 symbol-days on 99 releases), read at 08:29, in ADR20. Move from the 18:00 open to 08:29; strong = beyond ±0.4 ADR. up (n 16) R1.03 H88% L25% · within (n 251) R0.94 H80% L65% · down (n 26) R1.20 H19% L85%. Held: ✓ up: new low after 08:30 25% vs 66% (2018–24 38% vs 64%, 2025–26 12% vs 78%); ✓ within: new high after 08:30 80% vs 45% (2018–24 80% vs 42%, 2025–26 78% vs 50%); ✓ down: range after 08:30 1.20 vs 0.94 (2018–24 0.99 vs 0.94, 2025–26 1.69 vs 0.90); new high after 08:30 19% vs 81% (2018–24 28% vs 80%, 2025–26 0% vs 82%); new low after 08:30 85% vs 62% (2018–24 78% vs 62%, 2025–26 100% vs 62%). ✓ = p < 0.05 with errors clustered by release date, the same side in 2018–24 and 2025–26, and on NQ, ES and RTY separately.")
var int VZT_WK = txAdd("NFP days 2018–26, NQ + ES + RTY pooled (293 symbol-days on 99 releases), read at 08:29, in ADR20. The week into the release (Sunday 18:00 open to 08:29 Friday); up / down = beyond ±0.5 ADR. week up (n 115) R0.82 H80% L53% · flat (n 85) R0.90 H73% L66% · week down (n 93) R1.34 H71% L76%. Held: ✓ week up: range after 08:30 0.82 vs 1.16 (2018–24 0.82 vs 1.14, 2025–26 0.90 vs 1.27); new low after 08:30 53% vs 71% (2018–24 56% vs 68%, 2025–26 37% vs 85%); ✓ week down: range after 08:30 1.34 vs 0.87 (2018–24 1.33 vs 0.87, 2025–26 1.45 vs 0.84); new low after 08:30 76% vs 58% (2018–24 72% vs 59%, 2025–26 100% vs 55%). A strong week into NFP came with a smaller reaction, a weak week with a bigger one. ✓ = p < 0.05 with errors clustered by release date, the same side in 2018–24 and 2025–26, and on NQ, ES and RTY separately.")
var int VZT_VX = txAdd("NFP days 2018–26, NQ + ES + RTY pooled (293 symbol-days on 99 releases), read at 08:29, in ADR20. VIX's prior close against its 20-day average (±10%). over (n 84) R1.35 H76% L73% · near (n 146) R0.94 H73% L62% · under (n 63) R0.69 H79% L57%. Held: ✓ over: range after 08:30 1.35 vs 0.90 (2018–24 1.34 vs 0.90, 2025–26 1.45 vs 0.96); ✓ under: range after 08:30 0.69 vs 1.04 (2018–24 0.77 vs 1.03, 2025–26 0.43 vs 1.18). ✓ = p < 0.05 with errors clustered by release date, the same side in 2018–24 and 2025–26, and on NQ, ES and RTY separately.")
var int VZT_E = txAdd("NFP days 2018–26, NQ + ES + RTY pooled (293 symbol-days on 99 releases), read at 08:29, in ADR20. Median and 80th percentile by the month's position (discount · middle · premium; n 66 · 101 · 126), at today's ADR20. |stage 1| 08:30–08:50: 0.16 · 0.15 · 0.18 ADR (80%: 0.33 · 0.31 · 0.36); |stage 2| 08:50–09:30: 0.08 · 0.08 · 0.06 ADR (80%: 0.19 · 0.18 · 0.15); |NY AM| 09:30–11:00: 0.36 · 0.28 · 0.21 ADR (80%: 0.72 · 0.61 · 0.44); range after 08:30: 1.21 · 1.06 · 0.88 ADR (80%: 1.49 · 1.55 · 1.13) — held for discount, premium; the next session's range (Monday): 1.27 · 0.96 · 0.78 ADR (80%: 2.16 · 1.43 · 1.03) — held for discount, premium. Sizes for stops and targets: no direction held.")
var int VZT_DR = txAdd("Index against DXY futures in the same window, Feb 2023 – Jul 2026, NQ + ES + RTY pooled. Stage 1 (08:30–08:50): with DXY ≥ 0.42 of its ADR20 (BIG) the index went the other way 82% (n 60 on 20 releases; 2023–24 86%, 2025–26 72%; NQ 80%, ES 80%, RTY 85%; p 0.001) vs 53% when smaller. Stage 2 (08:50–09:30): BIG ≥ 0.22: 71% (n 56; 2023–24 78%, 2025–26 66%; NQ 72%, ES 74%, RTY 68%; p 0.024) vs 59%. It confirms the stage, it does not call it.")
var string VZT_AD = "How much the day's range (from 18:00) grows from 08:30 to 09:00, in ADR20. NFP days: +0.14× at the median vs +0.00× on ordinary days (2018–24 +0.13×, 2025–26 +0.21×; NQ +0.12, ES +0.13, RTY +0.16; held). Value: today, live until 09:00 then fixed."
var int VZT_FS = txAdd("First side of the pre-release range (07:00–08:29) taken after 08:30, and whether the day then reached further that way than the other (high vs low after 08:30, from 08:29). All NFP days: 59%. Held: ✓ VIX > 10% under its average 79% vs 54% (p 0.006); ✓ week up > 0.5 ADR 74% vs 50% (p < 0.001); ✓ flat week 46% vs 65% (lower). Not held: a quiet night (range since 18:00 ≤ 0.36 ADR) 71% vs 53%, but 67% vs 68% in 2025–26. The first break is a lean, not a call: it was wrong on about 4 in 10 days.")
var int VZT_CE = txAdd("ATH CE = halfway between the all-time high and the 08:29 close, drawn from 08:30 to 17:00 or into the next session to 11:00 (the Monday after a Friday release). Touched on pooled NFP days, by its distance at 08:29, by 17:00 / by the next session's 11:00: ≤ 0.5 ADR 79% / 83% (n 63; next-session odds 2018–24 91%, 2025–26 61%; NQ 88, ES 79, RTY 82) · 0.5–1 ADR 23% / 31% (n 26) · 1–2 ADR 1% / 6% (n 71) · > 2 ADR 0% / 0% (n 133). Within 0.5 ADR the ATH itself was taken by 17:00 on 56%. HYDRA: distance is the whole story (the whole-net AUC 0.93 on 2025–26 is the distance effect).")
var int VZT_HY = txAdd("Grimmjow: the HYDRA findings for NFP day. HYDRA on NQ + ES + RTY pooled: 406 heads × 18 targets on 240 symbol-days (80 releases, 2018–24), errors clustered by date, Benjamini–Hochberg 10% against 20 shifted nulls; survivors tested on 2025–26 (53 symbol-days) and on each symbol. Direction: stage 1, stage 2, RTH, 08:30 → 16:14 and day-against-the-week found no more survivors than their nulls; NY AM up found 8 against a null mean of 2.6 (max 18) and none held; 1 direction head of 283 survivors held in the test (chance level); the whole net's direction AUCs sat at the null's 95th percentile (0.62–0.65). Sizes and extremes: 177 of 283 held — the range after 08:30, |NY AM|, Monday's range, new high / low after 08:30, the ATH CE and the first DR side. So the pane sizes the day and gives the odds that held; it does not call a side.")
CK_RTY = "8<8A8K8T8g8m8o8w8}9,9091949<9?9C9G9P9X9d9n9u9|9}:#:#:):1:9;|;|<x=.=o=~>)>I>J>z>z>z>z>z>|?3?58F8Y8c8n9'9.959C9I9Q9R9R9U9^9c9e9r9z:#:':7:J:L:M:P:R:b:i:y<v=*>L>}?M?e?r?{@*@L@Q@Q@X@jA."
     + "A.A98_8j9%939J9f9k9m9}:&:(:*:/:9:;:=:O:S:j:o:x;%;>;L;T;c;l;r<.>W>u?z@nAmB3B5BBBeBlC;C;C;C<CECMCM8{939N9p:3:Q:Y:_;!;';/;7;7;K;T;Z;c;z<)<+<8<Q<S<o=.=<=C=F=F@pAMBtCVDAE8EkEvF=FHF[F[Fo"
     + "FrFrFrF{9R:(:4:S;/;V;z<*<.<.<L<R<U<o<r=R=R=R>+>O>s?=?K?K?M?M?M?c?cD3DAE_FFFHG/H*HLHmH|H|I[JHJZJcJcJj7+6l6N5u5n5?5k5M5a5g5V54514~5Q5G5G53524[4[414(3m424*4+3o4K2+1[/l09/u.R.7-N-4.8,/"
     + ",X,n-$,{,U,k7H7E767.6w6|7'7+6s6n6w7!6p6x6x6x6q6q6>6K6E626%6>6@63625o6>4u4U4e4:2z2t2e2P222@182J2z2X232=1r7n7n7o7g7_7m7h7q7t7q8&7}8(8$8!7v7p7p7e7c7r7y7y8,8'8#8:888H8R8[8B858~8a8N8d7p"
     + "7b828K8|958Q8V8h8)8/8;8=8T8W8T8g8g8s8m8g8p8x9(9!92918~9/929*9/9F9c9P9d9j:*<$<#<8<y=#<x=X=i>.<u>)=q>$=u>#>B>Q8D8X8b9*9#9D999@9Q9M9S9V9h:):0:):E:G:9:@:P:e;!;0;7;>;D;+;U>7=p?XAMA#@gAR"
     + "@tA/A1AXAzAwA?A!AIAA8V8h8w9,9G9U9b9c9i9l9o9t9w:#:2:2:8:I:T:f:y;$;5;L;Y;];m;}<5>]>z@)@KAHA^AyB8BVBZBZBZBZBZBZBZBZ8<8E8N8X8g8t8{9#9*9-909296979<9@9J9P9c9l9y:$:*:/:4:<:C:K:W:e:m;m<><`"
     + "<n<z=,=3=?=H=N=U=b=v=w=z8L8W8d8r9(939>9J9P9U9Z9]9b9d9h9n9v:#:5:C:Q:[:c:g:p:v;%;.;:;P;a<n=C=f>)>;>K>U>a>f>m>t?(?5?8?:8g8x9-9:9V9i9w:&:/:6:?:A:G:L:Q:X:b:n;%;8;H;S;a;j;v<#<+<4<@<a<q>@"
     + ">y???a?p@.@>@T@g@s@}A.A@ACAF989Q9m:$:D:_:r;%;4;?;D;N;S;Y;b;g;v;}<><Z<k=$=2=>=O=[=h=v>1>M>^@1A$ATAzBABYBmB~C2CCCYCfC{D!D&:,:J:g;%;W;{<-<J<g<p<t<|=%=(=:=E=Y=i>6>O>c>s?)?A?H?X?j@#@<@`"
     + "@|BUCTD%DXE-EJEwF6F:FIFZFmG>GFGK6s6i6Y6K655z5m5h5[5^5W5P5M5O5F5<585,4x4k4X4F4C4>434=4:413|3Z3]2R1`1@1(0z1)0q0E0?0?01/t/T/s/~7D7A777*7#6{6v6q6k6k6o6g6f6d6i6g6_6^6V6F6D6@6;6;62656/6("
     + "6#5u5n5=4l4Y4S4@454;4,4%4'3s3p3X3g3b7m7l7o7m7j7o7n7p7s7t7v7r7s7t7s7v7v7t7w7z7{7z7z7}7|8%8(8'8'8/8(838)7s7~837}8#8*8)888@87828885888>8F8M8Z8`8j8i8l8o8t8w9!8~9(9*9/93999?9O9T9^9b9`9n"
     + "9t9z:%:0:4:x;6;=;B;Q;^;d;n<#<.<1<B<8<A<?8d8t9,9:9I9W9`9p9u9{:&:&:*:1:3:=:E:J:g:y;.;<;D;A;I;S;N;`;e;v;~=8=i>4>W>U>y?,???R?V?f?w@$@!?|8w9*9@9R9q:):8:F:P:Z:b:f:j:o:v:~;.;8;W;j;|<4<C<N"
     + "<Y<h<r=#=2=O=b?@@8@kA9AVAsB,BIBZBZBZBZBZBZBZ"
TAL_RTY = "20180105,1,1,4.6,0.295;20180202,-1,-1,-10.2,-0.644;20180309,1,1,11.1,0.705;20180406,-1,-1,-10.4,-0.673;20180504,1,1,-8.8,-0.567;20180601,1,1,10.0,0.611;20180706,1,1,1.8,0.107;20180803,-1,-1,-0.9,-0.053;"
     + "20180907,-1,1,-3.4,-0.198;20181005,-1,-1,1.7,0.103;20181102,1,-1,9.4,0.610;20181207,-1,-1,2.5,0.169;20190104,1,1,18.7,1.405;20190201,1,1,1.7,0.113;20190308,1,1,-3.5,-0.230;20190405,1,1,4.1,0.261;"
     + "20190503,1,1,7.2,0.454;20190607,1,1,6.5,0.433;20190705,1,1,-11.7,-0.741;20190802,-1,-1,-8.2,-0.529;20190906,-1,-1,5.5,0.365;20191004,1,1,3.1,0.209;20191101,1,1,9.2,0.588;20191206,1,1,15.2,0.940;"
     + "20200110,-1,-1,-0.3,-0.018;20200207,-1,-1,-8.3,-0.494;20200306,-1,1,-45.4,-3.074;20200403,-1,-1,-12.3,-1.136;20200508,1,1,21.0,1.634;20200605,1,-1,61.2,4.213;20200702,1,-1,26.9,1.889;20200807,1,1,-4.2,-0.272;"
     + "20200904,-1,-1,14.7,0.949;20201002,1,1,-26.3,-1.722;20201106,-1,-1,0.8,0.048;20201204,1,1,6.1,0.329;20210108,-1,-1,9.1,0.434;20210205,1,1,17.6,0.799;20210305,1,1,32.7,1.522;20210507,1,1,-0.2,-0.009;"
     + "20210604,1,-1,8.6,0.377;20210702,-1,-1,7.1,0.305;20210806,1,-1,16.8,0.753;20210903,-1,-1,-8.6,-0.373;20211008,-1,-1,-0.1,-0.004;20211105,1,1,24.7,1.028;20211203,-1,-1,15.0,0.681;20220107,-1,-1,-0.7,-0.032;"
     + "20220204,-1,1,-10.3,-0.517;20220304,-1,-1,-24.0,-1.180;20220401,1,1,3.9,0.188;20220506,-1,-1,-11.6,-0.620;20220603,-1,1,-12.5,-0.659;20220708,1,1,-2.8,-0.158;20220805,1,1,-20.8,-1.090;20220902,-1,-1,24.6,1.351;"
     + "20221007,-1,-1,-18.5,-1.052;20221104,1,-1,21.5,1.205;20221202,1,1,-25.3,-1.344;20230106,1,1,17.1,0.971;20230203,-1,1,-17.0,-0.849;20230310,-1,-1,9.2,0.504;20230407,1,0,,;20230505,1,1,30.9,1.794;"
     + "20230602,1,1,22.7,1.281;20230707,1,1,1.7,0.092;20230804,-1,-1,0.0,0.000;20230901,1,1,12.7,0.667;20231006,1,1,-9.8,-0.562;20231103,1,1,29.7,1.726;20231208,1,1,16.6,0.888;20240105,-1,1,-13.8,-0.699;"
     + "20240202,-1,1,-20.7,-1.046;20240308,-1,-1,45.0,2.160;20240405,1,1,-10.2,-0.491;20240503,1,-1,36.1,1.782;20240607,-1,-1,-21.1,-1.028;20240705,-1,-1,-7.6,-0.370;20240802,-1,1,-79.1,-3.601;20240906,-1,-1,-1.9,-0.089;"
     + "20241004,1,1,30.7,1.396;20241101,1,-1,21.0,0.953;20241206,1,-1,17.5,0.729;20250110,-1,-1,-28.6,-1.273;20250207,-1,-1,3.1,0.134;20250307,1,1,-8.4,-0.405;20250404,-1,-1,-72.1,-3.746;20250502,1,1,27.8,1.406;"
     + "20250606,1,1,27.5,1.308;20250703,1,1,8.5,0.379;20250801,-1,-1,-34.9,-1.571;20250905,1,1,9.6,0.403;20251120,-1,-1,38.5,1.635;20251216,-1,-1,-9.3,-0.364;20260109,1,1,10.2,0.389;20260211,-1,-1,17.6,0.653;"
     + "20260306,-1,-1,-49.2,-1.906;20260403,-1,0,,;20260508,1,1,13.8,0.484;20260605,-1,-1,-28.7,-0.977;20260702,-1,-1,13.7,0.452;20260807,1,1,21.0,0.698;20260904,1,1,-15.4,-0.519;20261002,1,-1,28.6,1.010"
TAL_END_RTY = 20261009

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
int relM = relEnd == "08:45" ? 525 : relEnd == "08:50" ? 530 : relEnd == "09:30" ? 570 : 540
int drEM = drEnd == "11:00" ? 660 : drEnd == "17:00" ? 1020 : 974
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
        0 => "M6 DESGARRÓN · NFP 08:30"
        => ""
ownTy(int k) =>
    switch k
        0 => 1
        => 6
TAL_NQ = "20180105,1,1,22.0,0.333;20180202,-1,-1,-15.0,-0.218;20180309,1,1,45.5,0.652;20180406,-1,-1,-67.75,-1.026;20180504,1,1,-48.25,-0.724;20180601,1,1,31.75,0.455;20180706,1,1,10.75,0.151;20180803,1,1,5.0,0.068;"
     + "20180907,-1,1,-50.0,-0.671;20181005,-1,-1,-3.0,-0.04;20181102,-1,-1,-26.5,-0.374;20181207,-1,-1,-15.25,-0.223;20190104,1,1,96.5,1.566;20190201,-1,1,-40.75,-0.589;20190308,1,1,-76.5,-1.089;20190405,1,1,26.5,0.35;"
     + "20190503,1,1,60.75,0.785;20190607,1,1,37.25,0.512;20190705,-1,1,,;20190802,-1,-1,-46.5,-0.596;20190906,1,-1,17.75,0.226;20191004,1,1,30.0,0.392;20191101,1,1,37.75,0.467;20191206,1,1,62.0,0.746;"
     + "20200110,-1,-1,29.25,0.325;20200207,-1,-1,-43.5,-0.46;20200306,-1,1,-264.25,-3.055;20200403,-1,-1,-36.75,-0.482;20200508,1,1,48.25,0.53;20200605,1,1,42.75,0.444;20200702,1,-1,101.75,0.991;20200807,-1,-1,-29.0,-0.258;"
     + "20200904,-1,-1,-83.5,-0.708;20201002,-1,-1,-257.25,-2.223;20201106,1,1,-73.5,-0.607;20201204,1,1,-13.5,-0.108;20210108,1,1,83.5,0.646;20210205,1,1,31.0,0.229;20210305,1,1,102.75,0.823;20210507,1,1,117.25,0.862;"
     + "20210604,1,1,92.0,0.681;20210702,1,1,93.0,0.64;20210806,-1,-1,-51.75,-0.341;20210903,1,1,-38.25,-0.245;20211008,-1,-1,40.5,0.272;20211105,1,-1,79.25,0.485;20211203,-1,-1,68.5,0.429;20220107,-1,-1,-25.5,-0.162;"
     + "20220204,-1,1,-175.5,-1.194;20220304,-1,-1,-115.75,-0.824;20220401,-1,-1,-19.25,-0.129;20220506,-1,-1,-148.0,-1.147;20220603,-1,-1,-202.5,-1.573;20220708,1,1,-106.0,-0.874;20220805,-1,1,-210.75,-1.581;20220902,-1,-1,144.0,1.174;"
     + "20221007,-1,-1,-195.75,-1.696;20221104,1,-1,193.75,1.804;20221202,-1,1,-202.25,-1.679;20230106,1,1,67.25,0.621;20230203,-1,1,-133.0,-1.047;20230310,-1,-1,25.0,0.208;20230407,1,0,,;20230505,1,1,100.5,0.771;"
     + "20230602,1,1,50.75,0.35;20230707,-1,-1,-20.75,-0.136;20230804,-1,-1,-4.5,-0.029;20230901,-1,-1,86.0,0.553;20231006,1,1,-121.0,-0.814;20231103,1,1,71.0,0.474;20231208,1,1,-69.0,-0.431;20240105,1,1,10.5,0.064;"
     + "20240202,1,1,-37.0,-0.211;20240308,-1,-1,53.5,0.293;20240405,1,1,50.75,0.281;20240503,1,1,301.75,1.709;20240607,-1,-1,-25.25,-0.132;20240705,1,1,,;20240802,-1,-1,-290.0,-1.531;20240906,-1,-1,-50.0,-0.263;"
     + "20241004,1,-1,231.0,1.155;20241101,1,1,14.25,0.071;20241206,1,1,34.5,0.161;20250110,-1,-1,,;20250207,-1,-1,68.5,0.314;20250307,-1,1,-90.25,-0.448;20250404,-1,-1,-536.0,-2.868;20250502,1,1,285.75,1.443;"
     + "20250606,1,1,214.0,0.991;20250703,1,0,96.5,0.423;20250801,-1,-1,-242.25,-1.038;20250905,-1,-1,182.5,0.77;20251120,-1,-1,487.75,1.973;20251216,-1,1,-108.5,-0.432;20260109,1,0,,;20260211,1,0,,;"
     + "20260306,-1,-1,-345.5,-1.38;20260403,-1,0,,;20260508,1,1,167.0,0.582;20260605,-1,-1,-416.0,-1.366;20260702,-1,-1,15.5,0.052;20260807,1,1,177.75,0.602;20260904,1,-1,67.0,0.227;20261002,1,-1,338.5,1.099"
TAL_END_NQ = 20261009
TAL_ES = "20180105,1,1,8.25,0.303;20180202,-1,-1,-16.0,-0.567;20180309,1,1,20.5,0.748;20180406,-1,-1,-23.5,-0.882;20180504,1,1,-15.75,-0.599;20180601,1,1,16.0,0.591;20180706,1,1,0.25,0.009;20180803,1,1,0.5,0.018;"
     + "20180907,-1,1,-11.25,-0.391;20181005,-1,-1,0.5,0.017;20181102,-1,-1,13.25,0.484;20181207,-1,-1,0.25,0.009;20190104,1,1,34.75,1.419;20190201,-1,-1,-1.75,-0.065;20190308,-1,1,-18.0,-0.655;20190405,1,1,7.0,0.243;"
     + "20190503,1,1,15.75,0.54;20190607,1,1,11.25,0.395;20190705,-1,1,,;20190802,-1,-1,-7.5,-0.254;20190906,1,1,8.0,0.269;20191004,1,1,6.75,0.232;20191101,1,1,16.0,0.527;20191206,1,1,21.5,0.69;"
     + "20200110,-1,-1,6.25,0.191;20200207,-1,-1,-12.25,-0.366;20200306,-1,1,-88.5,-2.934;20200403,-1,-1,-13.25,-0.526;20200508,1,1,27.75,0.963;20200605,1,1,59.0,1.897;20200702,1,-1,39.5,1.273;20200807,1,1,-12.5,-0.374;"
     + "20200904,-1,-1,0.75,0.022;20201002,-1,1,-50.75,-1.507;20201106,1,1,-12.75,-0.363;20201204,1,1,2.25,0.061;20210108,1,1,13.0,0.342;20210205,1,-1,17.75,0.459;20210305,1,1,34.25,0.908;20210507,1,1,8.5,0.203;"
     + "20210604,1,1,20.75,0.495;20210702,1,1,14.25,0.331;20210806,1,1,4.75,0.107;20210903,-1,1,-12.0,-0.265;20211008,-1,-1,7.75,0.176;20211105,1,-1,25.0,0.535;20211203,-1,-1,22.0,0.481;20220107,-1,-1,-4.25,-0.091;"
     + "20220204,-1,1,-32.5,-0.722;20220304,-1,1,-44.5,-1.02;20220401,-1,-1,1.0,0.022;20220506,-1,-1,-34.75,-0.837;20220603,-1,-1,-44.25,-1.061;20220708,1,1,-12.75,-0.327;20220805,-1,1,-44.75,-1.078;20220902,-1,-1,45.75,1.155;"
     + "20221007,-1,-1,-41.25,-1.099;20221104,1,-1,55.0,1.474;20221202,-1,1,-51.25,-1.256;20230106,1,1,31.25,0.816;20230203,-1,1,-28.0,-0.672;20230310,-1,-1,-1.25,-0.032;20230407,1,0,,;20230505,1,1,41.75,1.025;"
     + "20230602,1,1,23.25,0.549;20230707,-1,1,-13.75,-0.309;20230804,-1,-1,3.0,0.066;20230901,1,-1,24.75,0.548;20231006,1,1,-23.25,-0.542;20231103,1,1,26.0,0.6;20231208,1,1,-6.25,-0.136;20240105,1,1,1.5,0.032;"
     + "20240202,1,1,-11.25,-0.228;20240308,-1,-1,9.5,0.184;20240405,1,1,9.25,0.178;20240503,1,1,61.5,1.208;20240607,-1,-1,-10.0,-0.186;20240705,1,1,,;20240802,-1,-1,-60.5,-1.107;20240906,-1,-1,-1.5,-0.027;"
     + "20241004,1,1,42.5,0.739;20241101,1,1,17.25,0.3;20241206,1,1,10.5,0.173;20250110,-1,-1,,;20250207,-1,-1,16.5,0.271;20250307,1,1,-32.0,-0.556;20250404,-1,-1,-142.0,-2.613;20250502,1,1,77.25,1.377;"
     + "20250606,1,1,52.5,0.882;20250703,1,0,20.5,0.327;20250801,-1,-1,-55.75,-0.876;20250905,-1,-1,18.75,0.288;20251120,-1,-1,101.0,1.516;20251216,-1,-1,-18.25,-0.267;20260109,1,1,6.0,0.086;20260211,-1,-1,37.5,0.538;"
     + "20260306,-1,-1,-76.25,-1.117;20260403,-1,0,,;20260508,1,1,26.25,0.356;20260605,-1,-1,-46.25,-0.609;20260702,-1,-1,20.0,0.265;20260807,1,1,19.5,0.252"
TAL_END_ES = 20260828
TAL_NAME = "NFP"
talIs(int k, int pk) => NP.includes(k)
ownCk(int k) =>
    switch k
        0 => 0
        => 0
ckName(int k) =>
    switch k
        0 => "NFP"
        1 => "Normal"
        => ""
ckN(int k) =>
    switch k
        0 => isRTY ? "100" : "98"
        1 => isES ? "1416" : isRTY ? "1430" : "1342"
        => ""
ownProfile(int tk, int pk, int today) =>
    bool now = NP.includes(tk)
    int  rf  = na(tk) ? today : math.max(tk, today)
    [0, now, now ? tk : nextOf(NP, rf)]
ownNext(int today) =>
    int n1 = nextOf(NP, today)
    ["NFP 08:30", n1, "then", na(n1) ? na : nextOf(NP, addDays(n1, 1))]


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
// all-time high: the highest daily high of the completed days and the day it was set (today's high is added on the chart)
athD() =>
    float m = ta.max(high)
    var int t = na
    if high >= m
        t := time
    [m[1], t[1]]
[athP, athPT] = request.security(syminfo.tickerid, "D", athD(), lookahead = barmerge.lookahead_on)

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
var int   tdHT = na
if tdSt
    tdPK := tdK[1]
    ptdH := tdH
    ptdL := tdL
    tdO  := open
    tdH  := high
    tdL  := low
    tdX  := bar_index
    tdHT := time
else
    if na(tdH) or high > tdH
        tdHT := time
    tdH := math.max(nz(tdH, high), high)
    tdL := math.min(nz(tdL, low), low)
bool  athTd = na(athP) or tdH >= athP
float athN  = athTd ? tdH : athP
int   athNT = athTd ? tdHT : athPT
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

// ═══════════════════════════════════════════════════════════════ NFP stages (Desgarrón)
// Stage 1 = 08:30 open → 08:49 close (the release push to the 08:50 line); stage 2 = 08:50 open → 09:29 close (the second
// stage into the RTH open); NY AM = 09:30 open → 10:59 close.
fdSg(float v, string f) => na(v) ? "—" : (v >= 0 ? "+" : "−") + str.tostring(math.abs(v), f)
vzSg(float v) => na(v) ? "—" : (v >= 0 ? "+" : "−") + str.tostring(math.abs(v), format.mintick)
vzAr(float v) => na(v) or v == 0 ? "·" : v > 0 ? "▲" : "▼"
// VIX: prior close and its 20-day average (completed days)
[vxC, vxA] = request.security(vixSym, "D", [close[1], ta.sma(close, 20)[1]], lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
// The stages card's statistics (VS, VH, OC and the tooltips above): NQ + ES + RTY pooled, read at 08:29, in ADR20 of the
// trading day; −1 = too few days
//  0–29  |stage 1|, |stage 2|, |NY AM|, the range after 08:30, the next session's range: median and 80th percentile with
//        price in the month's discount (bottom quarter), middle, premium (top quarter)
//  30–35 new day high and low after 08:30 (%): above PDH, inside the prior day, below PDL
//  36–41 the same after a move since 18:00 above +0.4 ADR, within ±0.4, below −0.4
//  42–47 the same in the month's discount, middle, premium
//  48–56 the range after 08:30 (ADR): over / within / under 1 ADR from the month's open · VIX over / near / under its
//        20-day average (±10%) · the week into the release up / flat / down (±0.5 ADR)
// VH: 1 where that figure held. OC: per month octant 1–8, n · range after 08:30 · new high % · new low %
vh(int i) => str.substring(VH, i, i + 1) == "1"
var int VZT_HD = txAdd("The NFP release (08:30 ET), led by where price sits in the month's range: discount (bottom quarter), middle or premium (top quarter), the setup that sized NFP days most. SETUP: the month, its open, the prior day, the 18:00 open, the week into the release and VIX (live, then fixed at 08:29). EXPECT: how far NFP days with today's month position moved, at today's ADR20. LIVE (from 08:30): stages 1 and 2 against DXY and the range since 08:30. Figures: NQ + ES + RTY pooled, 2018–26 (293 symbol-days, 99 releases). Green key = held; every other figure describes. No 08:29 feature called the direction.")
var int VZT_LV = txAdd("Today's stage so far (points from its open) and DXY's move in the same window, in DXY's ADR20. ×typ = against the EXPECT median. ⇄ = the other way to DXY, ⇉ = the same way. BIG = DXY has moved at least 0.42 (stage 1) or 0.22 (stage 2) of its ADR20, about its median release move: then the index went the other way 82% and 71% of the time (pooled, held). RANGE: the range since 08:30 against the median for today's month position.")
VZT_MN = "ES, held: the next session's RTH (09:30 → 16:14, usually Monday) closed the same way as NFP day's RTH on 36% of 97 NFP days vs 48% after ordinary days (2018–24 35%, 2025–26 41%; p 0.025). Expect the Monday to undo, not extend."
bool vzF = NP.includes(calK)
// the week's open
var int   wkX  = na
var float wkOp = na
if ta.change(time("W")) != 0
    wkX  := bar_index
    wkOp := open
// the setup at price c with the day's high h and low l so far: position in the month's range (0–1), distance from the
// month's open, beyond the prior day's range (ADR; 0 = inside), move since 18:00 (ADR), ADR20 (pts), the week so far (ADR)
ctxOf(float c, float h, float l) =>
    float a  = ADRtd * tdO
    float mh = math.max(nz(mtH, h), h)
    float ml = math.min(nz(mtL, l), l)
    float p  = mh > ml ? (c - ml) / (mh - ml) : na
    float m  = a > 0 ? (c - mtO) / a : na
    float d  = na(ptdH) or not (a > 0) ? na : c > ptdH ? (c - ptdH) / a : c < ptdL ? (c - ptdL) / a : 0.0
    float s  = a > 0 ? (c - tdO) / a : na
    float w  = a > 0 and not na(wkOp) ? (c - wkOp) / a : na
    [p, m, d, s, a, w]
// stage prices on NFP day (and DXY at the same moments), the setup fixed at 08:29, the day's range at 08:29 and 09:00
var int   vzK  = na
var float s1O  = na
var int   s1X  = na
var float s2O  = na
var int   s2X  = na
var float s1C  = na
var float s2C  = na
var float amC  = na
var float x1O  = na
var float x2O  = na
var float x1C  = na
var float x2C  = na
var float r830 = na
var float r09  = na
var int   k59  = na
var float cxP  = na
var float cxM  = na
var float cxD  = na
var float cxS  = na
var float cxA  = na
var float cxW  = na
// pre-release range 07:00–08:29, the first side of it taken after 08:30, the range since 08:30, and the ATH CE fixed at 08:30
var int   p7K  = na
var float p7H  = na
var float p7L  = na
if vzF and mod >= 420 and mod < 510
    if nz(p7K) != calK
        p7K := calK
        p7H := high
        p7L := low
    else
        p7H := math.max(p7H, high)
        p7L := math.min(p7L, low)
var int   fsd  = 0                                                      // 1 high first · −1 low first · 2 both on one bar
var int   fsT  = na
var float qH   = na
var float qL   = na
var float ceV  = na
var float ceAt = na
var float ceDA = na
var int   ceHT = na
var int   ceXE = na                                                     // when the CE line ends
nxtTd(int k) => addDays(k, dowOf(k) == dayofweek.friday ? 3 : 1)
bool at830 = vzF and tfM <= 30 and mod >= 510 and mod < 540 and (mod[1] < 510 or calK[1] != calK) and nz(vzK) != calK
if at830
    vzK  := calK
    s1O  := open
    s1X  := bar_index
    x1O  := dxL[1]
    s2O  := na
    s2X  := na
    s1C  := na
    s2C  := na
    amC  := na
    x2O  := na
    x1C  := na
    x2C  := na
    r09  := na
    r830 := tdH[1] - tdL[1]
    [p_, m_, d_, q_, a_, w_] = ctxOf(close[1], tdH[1], tdL[1])
    k59 := calK
    fsd  := 0
    fsT  := na
    qH   := na
    qL   := na
    ceAt := math.max(nz(athP, tdH[1]), tdH[1])
    ceV  := ceAt > close[1] ? (ceAt + close[1]) / 2 : na
    ceDA := a_ > 0 and not na(ceV) ? (ceV - close[1]) / a_ : na
    ceHT := na
    ceXE := ceEnd == "17:00" ? keyAt(calK, 1020) : keyAt(nxtTd(calK), 660)
    cxP := p_
    cxM := m_
    cxD := d_
    cxS := q_
    cxA := a_
    cxW := w_
bool at850 = vzK == calK and na(s2O) and mod >= 530 and mod < 570
if at850
    s2O := open
    s2X := bar_index
    s1C := close[1]
    x2O := dxL[1]
    x1C := dxL[1]
if vzK == calK and not na(s2O) and na(s2C) and mod >= 570
    s2C := close[1]
    x2C := dxL[1]
if vzK == calK and na(r09) and mod >= 540
    r09 := tdH[1] - tdL[1]
if vzK == calK and na(amC) and mod >= 660 and tgKey == calK
    amC := close[1]
if vzK == calK and mod >= 510 and mod < 975
    qH := math.max(nz(qH, high), high)
    qL := math.min(nz(qL, low), low)
    if fsd == 0 and p7K == calK
        bool bu = high > p7H
        bool bd = low < p7L
        if bu or bd
            fsd := bu and bd ? 2 : bu ? 1 : -1
            fsT := time
if not na(ceV) and na(ceHT) and not na(ceXE) and time < ceXE and high >= ceV
    ceHT := time
// touched by 17:00 / by the next session's 11:00, pooled NFP days, by the CE's distance at 08:29 (ADR)
ceOdds(float x) => na(x) ? "—" : ceEnd == "17:00" ? (x <= 0.5 ? "79%" : x <= 1 ? "23%" : x <= 2 ? "1%" : "0%") : (x <= 0.5 ? "83%" : x <= 1 ? "31%" : x <= 2 ? "6%" : "0%")
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
// the findings table (indicator pane)
var table TH  = na
var int   thO = 0
HYR = layI == "Mobile" ? 6 : 11
if barstate.isfirst and showHy
    thO := hyPos == "Top left" or hyPos == "Top center" or hyPos == "Top right" ? 1 : 0
    TH  := table.new(posOf(hyPos), 5, HYR + thO, bgcolor = #00000000, frame_width = 0, border_width = 0)
    if thO == 1
        TH.cell(0, 0, "", height = 7.0, bgcolor = #00000000)
        TH.merge_cells(0, 0, 4, 0)
    TH.merge_cells(1, thO, 3, thO)
    if layI != "Mobile"
        TH.merge_cells(2, thO + 2, 4, thO + 2)
// Level lines and their end labels that run to a time later today (16:14, the RTH close) are cut at the latest bar and
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
bool cNFP = NP.includes(calK)
bool cOn  = showStr and recent and cNFP
int  drE  = keyAt(calK, drEM)
// the 07:00–08:59 high and low (the dealing range)
var float drH = na
var float drL = na
var int   drK = na
if cNFP and mod >= 420 and mod < 540
    if nz(drK) != calK
        drK := calK
        drH := high
        drL := low
    else
        drH := math.max(drH, high)
        drL := math.min(drL, low)
// pre-release range 07:00–08:29, drawn live; it stops where the release breaks it (or at 09:00)
var int   d0K = na
var bool  d0On = false
var line  d0H = na
var line  d0L = na
var label d0T = na
var label d0B = na
if cOn and showDR0 and p7K == calK and mod >= 420 and mod < 510
    if nz(d0K) != calK
        d0K  := calK
        d0On := true
        d0H  := line.new(keyAt(calK, 420), p7H, time, p7H, xloc = xloc.bar_time, color = cDR0, style = lsOf(stDR0), force_overlay = true)
        d0L  := line.new(keyAt(calK, 420), p7L, time, p7L, xloc = xloc.bar_time, color = cDR0, style = lsOf(stDR0), force_overlay = true)
        string t0 = "Pre-release range 07:00–08:29, drawn live. The first side the release takes after 08:30 became the bigger side of the day on 59% of pooled NFP days (79% with VIX > 10% under its average, 74% after an up week, 46% after a flat week). " + TXA.get(VZT_FS)
        d0T  := label.new(keyAt(calK, 420), p7H, "pre-NFP high", xloc = xloc.bar_time, color = #00000000, textcolor = cDR0, style = label.style_label_lower_left, size = lbSz, tooltip = t0, force_overlay = true)
        d0B  := label.new(keyAt(calK, 420), p7L, "pre-NFP low", xloc = xloc.bar_time, color = #00000000, textcolor = cDR0, style = label.style_label_upper_left, size = lbSz, tooltip = t0, force_overlay = true)
    else
        d0H.set_y1(p7H)
        d0H.set_y2(p7H)
        d0L.set_y1(p7L)
        d0L.set_y2(p7L)
        d0T.set_y(p7H)
        d0B.set_y(p7L)
// the dealing range 07:00–09:00: created when the release breaks the pre-release range (at 09:00 if it never does), drawn
// from 07:00, following the high and low until 09:00, then fixed
var int   dK2 = na
var line  dLH = na
var line  dLL = na
var line  dLE = na
var box   dBx = na
var label dTH = na
var label dTL = na
if cOn and showDR and drK == calK and nz(dK2) != calK and ((vzK == calK and fsd != 0) or mod >= 540)
    dK2 := calK
    int    x0 = keyAt(calK, 420)
    string tD = "NFP dealing range 07:00–09:00 ET: created when the release broke the 07:00–08:29 range" + (fsd == 0 ? " (it did not by 09:00)" : " at " + str.format_time(fsT, "HH:mm", TZ)) + ", following the high and low to 09:00, then fixed."
    dLH := line.new(x0, drH, time, drH, xloc = xloc.bar_time, color = cDR, style = lsOf(stDR), width = wDR, force_overlay = true)
    dLL := line.new(x0, drL, time, drL, xloc = xloc.bar_time, color = cDR, style = lsOf(stDR), width = wDR, force_overlay = true)
    dLE := drEq ? line.new(x0, (drH + drL) / 2, time, (drH + drL) / 2, xloc = xloc.bar_time, color = color.new(cDR, 35), style = line.style_dotted, force_overlay = true) : na
    dBx := drFill ? box.new(x0, drH, time, drL, xloc = xloc.bar_time, border_color = #00000000, bgcolor = color.new(cDR, 92), force_overlay = true) : na
    dTH := label.new(keyAt(calK, 540), drH, "DR high", xloc = xloc.bar_time, color = #00000000, textcolor = cDR, style = label.style_label_lower_left, size = lbSz, tooltip = tD, force_overlay = true)
    dTL := label.new(keyAt(calK, 540), drL, "DR low", xloc = xloc.bar_time, color = #00000000, textcolor = cDR, style = label.style_label_upper_left, size = lbSz, tooltip = tD, force_overlay = true)
if dK2 == calK
    if mod < 540
        dLH.set_y1(drH)
        dLH.set_y2(drH)
        dLL.set_y1(drL)
        dLL.set_y2(drL)
        dTH.set_y(drH)
        dTL.set_y(drL)
        if not na(dLE)
            dLE.set_y1((drH + drL) / 2)
            dLE.set_y2((drH + drL) / 2)
        if not na(dBx)
            dBx.set_top(drH)
            dBx.set_bottom(drL)
    if time <= drE
        dLH.set_x2(time)
        dLL.set_x2(time)
        if not na(dLE)
            dLE.set_x2(time)
        if not na(dBx)
            dBx.set_right(time)
if d0On and d0K == calK
    d0On := nz(dK2) != calK and time <= drE
    d0H.set_x2(time)
    d0L.set_x2(time)
if cOn
    if at830 and showATH and showCE and not na(ceV)
        string ceTp = "ATH CE " + pf(ceV) + " = (ATH " + pf(ceAt) + " + 08:29 close) ÷ 2, " + str.tostring(ceDA, "0.00") + " ADR above price at 08:29: touched by " + (ceEnd == "17:00" ? "17:00" : "the next session's 11:00") + " on " + ceOdds(ceDA) + " of pooled NFP days at that distance. " + TXA.get(VZT_CE)
        trimL(line.new(time, ceV, ceXE, ceV, xloc = xloc.bar_time, color = cAth, width = 1, style = line.style_dashed, force_overlay = true), ceXE)
        trimT(label.new(ceXE, ceV, "ATH CE " + ceOdds(ceDA), xloc = xloc.bar_time, color = #00000000, textcolor = cAth, style = label.style_label_left, size = lbSz, tooltip = ceTp, force_overlay = true), ceXE)
    if mod <= 530 and mod + tfM > 530
        line.new(keyAt(calK, 530), close, keyAt(calK, 530), close + syminfo.mintick, xloc = xloc.bar_time, extend = extend.both, color = color.new(cLvl, 60), style = line.style_dotted, force_overlay = true)
    if showGap and rthSt and not na(gapPC)
        trimL(line.new(time, gapPC, keyAt(calK, 974), gapPC, xloc = xloc.bar_time, color = color.new(cLvl, 40), style = line.style_dotted, force_overlay = true), keyAt(calK, 974))
        trimL(line.new(time, gapCE, keyAt(calK, 974), gapCE, xloc = xloc.bar_time, color = color.new(cLvl, 20), style = line.style_dotted, force_overlay = true), keyAt(calK, 974))
        trimT(label.new(keyAt(calK, 974), gapCE, "gap 50%", xloc = xloc.bar_time, color = #00000000, textcolor = cLvl, style = label.style_label_left, size = lbSz, tooltip = "RTH gap 50% = (prior 16:14 close + 09:30 open) ÷ 2. NFP days filled the full gap less often than normal days (NQ 54% vs 63%, ES 53% vs 62%).", force_overlay = true), keyAt(calK, 974))
// the release marker: a flag above the release push, tied by a stem to the 08:30 open; it rises with price until 09:00
var int   nfK = na
var label nfL = na
var line  nfV = na
if cOn and markEv and mod <= 510 and mod + tfM > 510
    float yT = high + 0.3 * ADRtd * tdO
    nfK := calK
    nfV := line.new(time, open, time, yT, xloc = xloc.bar_time, color = color.new(cGh, 25), style = line.style_dotted, width = 1, force_overlay = true)
    nfL := label.new(time, yT, "NFP 08:30 · " + pf(open), xloc = xloc.bar_time, color = cGh, textcolor = #ffffff, style = label.style_label_down, size = lbSz == size.tiny ? size.small : lbSz, tooltip = "Employment Situation release, 08:30 ET " + str.format_time(time, "dd MMM yyyy", TZ) + ". The stem runs down to the 08:30 open, " + pf(open) + ".", force_overlay = true)
else if nfK == calK and mod > 510 and mod < 540 and high + 0.3 * ADRtd * tdO > nfL.get_y()
    nfL.set_y(high + 0.3 * ADRtd * tdO)
    nfV.set_y2(high + 0.3 * ADRtd * tdO)
bgcolor(cOn and mod >= 510 and mod < relM ? cHands : na, title = "NFP release window", force_overlay = true)
// NFP day: the 08:30 and 08:50 opens to the RTH close
if cOn and showWO and at830
    trimL(line.new(time, open, keyAt(calK, 974), open, xloc = xloc.bar_time, color = color.new(cGh, 15), width = 1, force_overlay = true), keyAt(calK, 974))
if cOn and showWO and at850
    trimL(line.new(time, open, keyAt(calK, 974), open, xloc = xloc.bar_time, color = color.new(cGh, 35), width = 1, style = line.style_dashed, force_overlay = true), keyAt(calK, 974))

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
NCK = 2
REL = "510"
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
bool  ckTop = (showCk and ckOn == "Indicator pane" and str.startswith(ckPos, "Top")) or (showHy and str.startswith(hyPos, "Top"))
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
        string nxT  = na(n1k) ? "beyond loaded dates" : "NFP " + str.format_time(keyTime(n1k), "dd MMM", TZ) + (n1k == today ? " · today" : " · " + str.tostring(inDays(n1k, today)) + "d") + (warn ? " · UPDATE" : "")
        string nxTip = "Next release: " + (na(n1k) ? "beyond the loaded dates" : fmtDay(n1k) + " 08:30 ET" + (na(n2k) ? "" : ", then " + fmtDay(n2k))) + ". Release dates are built in up to " + str.format_time(keyTime(LAST_DATE), "dd MMM yyyy", TZ) + ": add next year's dates (bls.gov/schedule, federalreserve.gov) to S_FOMC, S_CPI and S_NFP, then raise LAST_DATE."
        string hdT  = pfName(pk) + ". Clock and tally: " + symR + " 1-minute data 2018–26; stages card and findings: NQ + ES + RTY pooled." + (isNQ or isES or isRTY ? "" : " This chart is " + syminfo.root + ": the clock and tally are " + symR + "'s.")
        string pill_ = pNow ? "TODAY" : na(dd) ? "—" : dd == 1 ? "TMRW" : "IN " + str.tostring(dd) + "D"
        if showEv and not na(TS)
            int r0 = tsO
            cardHead(TS, r0, cGh, dot + " DESGARRÓN · " + ev + " · " + symTag, hdT + " " + nxTip, mob and warn ? "UPDATE" : pill_, mob and warn or not pNow ? #ffffff : cGh, mob and warn ? cWarn : pNow ? #ffffff : color.new(#000000, 55))
            if not mob
                cardSub(TS, r0 + 1, cGh, "last " + str.tostring(nT) + " " + TAL_NAME + " days", "▲", "▼")
                cardRow(TS, r0 + 2, cGh, "DAY", false, gauge(uT + dT_ > 0 ? float(uT) / (uT + dT_) : na) + " " + (uT + dT_ > 0 ? p0(float(uT) / (uT + dT_)) : "—"), str.tostring(uT), str.tostring(dT_), tTip, cDisc, cPrem)
                cardRow(TS, r0 + 3, cGh, "RTH", false, gauge(uR + dR_ > 0 ? float(uR) / (uR + dR_) : na) + " " + (uR + dR_ > 0 ? p0(float(uR) / (uR + dR_)) : "—"), str.tostring(uR), str.tostring(dR_), "RTH 09:30 → 16:14 close vs open on the same days (days without RTH data are left out).", cDisc, cPrem)
                cardRow(TS, r0 + 4, cGh, "GAP", false, "avg gap · ▲" + str.tostring(int(acc.get(9))) + "/" + str.tostring(nG), na(gAvg) ? "—" : (gAvg >= 0 ? "+" : "") + str.tostring(gAvg, "0.0"), na(gAbs) ? "—" : "±" + str.tostring(gAbs, "0.0"), gTip)
                for zi = 0 to 1
                    zoneRow(TS, r0 + 5 + zi, cGh, zi == 0 ? "WEEK" : "MONTH", zi == 0 ? math.max(nz(wH, tdH), tdH) : mHi, zi == 0 ? math.min(nz(wL, tdL), tdL) : mLo, zi == 0 ? "week" : "month")
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
                    zoneRow(TS, r0 + 4 + zi, cGh, zi == 0 ? "WK" : "MO", zi == 0 ? math.max(nz(wH, tdH), tdH) : mHi, zi == 0 ? math.min(nz(wL, tdL), tdL) : mLo, zi == 0 ? "week" : "month")
        // ── clock card
        if showCk and not na(TK)
            string bN   = ckName(ckI)
            string eN   = ckName(ckEvI)
            string nowT = hhmm(int(math.min(1439.0, (elM + tfM + 1080) % 1440)))
            int    r0   = tkO
            cardHead(TK, r0, cGh, dot + " " + "DESGARRÓN · CLOCK · " + nowT + " ET", "Today's running range (or net move) from the 18:00 open against the same time of day on " + bN + " days, 2018–26: paths from " + ckN(ckI) + " " + bN + " days" + (ckI != NCK - 1 ? " and " + ckN(NCK - 1) + " normal days" : "") + ", half-hour steps, scaled by today's ADR20" + (scP > 0 ? " (" + pf(scP) + " pts)." : "."), ckEv ? eN + " DAY" : "NORMAL", ckEv ? cGh : #ffffff, ckEv ? #ffffff : color.new(#000000, 55))
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
        // week open, and NFP day's 08:30 and 08:50 opens, extended to the right of price
        if showWO and not na(wkX) and not na(wkOp)
            RL.push(line.new(math.max(wkX, bar_index - 4900), wkOp, xd, wkOp, color = color.new(cLvl, 15), style = line.style_dashed, force_overlay = true))
            RT.push(label.new(bar_index + 2, wkOp, "week open " + pf(wkOp), color = #00000000, textcolor = cLvl, style = label.style_label_left, size = lbSz, force_overlay = true))
        if showATH and not na(athN) and not na(athNT)
            float aA = ADRtd * tdO
            RL.push(line.new(athNT, athN, time + offI * timeframe.in_seconds() * 1000, athN, xloc = xloc.bar_time, color = cAth, width = 1, style = lsOf(stAth), force_overlay = true))
            RT.push(label.new(bar_index + 2, athN, "ATH " + pf(athN) + " · −" + str.tostring(athN - close, "0"), color = #00000000, textcolor = cAth, style = label.style_label_left, size = lbSz, tooltip = "All-time high " + pf(athN) + ", set " + (athTd ? "today" : str.format_time(athNT, "dd MMM yyyy", TZ)) + " (highest daily high of the chart's history). Price is " + pf(athN - close) + " pts below it" + (aA > 0 ? " (" + str.tostring((athN - close) / aA, "0.00") + " ADR)" : "") + ". On NFP days the CE between it and the 08:29 close is drawn at 08:30.", force_overlay = true))
        if showWO and vzF and vzK == calK and not na(s1X) and bar_index - s1X < 4900
            RL.push(line.new(s1X, s1O, xd, s1O, color = color.new(cGh, 15), force_overlay = true))
            RT.push(label.new(bar_index + 2, s1O, "08:30 open " + pf(s1O), color = #00000000, textcolor = cGh, style = label.style_label_left, size = lbSz, force_overlay = true))
            if not na(s2X)
                RL.push(line.new(s2X, s2O, xd, s2O, color = color.new(cGh, 35), style = line.style_dashed, force_overlay = true))
                RT.push(label.new(bar_index + 2, s2O, "08:50 open " + pf(s2O), color = #00000000, textcolor = color.new(cGh, 25), style = label.style_label_left, size = lbSz, force_overlay = true))
    true
drawLast1()

// ═══════════════════════════════════════════════════════════════ NFP stages card and HYDRA findings (last bar)
// part of the month's range: 0 discount (bottom quarter) · 1 middle · 2 premium (top quarter)
zIdx(float p) => na(p) ? 1 : p >= 0.75 ? 2 : p <= 0.25 ? 0 : 1
zWd(int z) => z == 2 ? "PREM" : z == 0 ? "DISC" : "MID"
sgP(float v) => na(v) ? "—" : str.tostring(v, "0")
sgS(float v) => na(v) ? "—" : (v >= 0 ? "+" : "−") + str.tostring(math.abs(v), "0")
pcV(int i) => VS.get(i) < 0 ? "—" : str.tostring(VS.get(i), "0")
hl(int i) => "H" + pcV(i) + " L" + pcV(i + 1)
hlH(int i) => vh(i) or vh(i + 1)
rg(int i) => "R" + str.tostring(VS.get(i), "0.00")
liveTx(float sv, float dv) => na(sv) ? "—" : sgS(sv) + " · DXY " + (na(dv) ? "—" : vzAr(dv) + str.tostring(math.abs(dv), "0.00"))
// same window against DXY: ⇄ other way · ⇉ same way · BIG once DXY's move reaches thr of its ADR20
dxPill(float dv, float sv, float thr) =>
    bool ok  = not (na(dv) or na(sv) or dv == 0 or sv == 0)
    bool big = ok and math.abs(dv) >= thr
    bool oth = ok and math.sign(dv) != math.sign(sv)
    [not ok ? "—" : (oth ? "⇄" : "⇉") + (big ? " BIG" : ""), big ? #ffffff : cTx, not ok ? cBody : big ? (oth ? cOk : cWarn) : cNeu]
// today's setup: live, then fixed at 08:29 on NFP day
[lp_, lm_, ld_, ls_, la_, lw_] = ctxOf(close, tdH, tdL)
bool  fzS  = not na(k59) and k59 == calK
float uP   = fzS ? cxP : lp_
float uM   = fzS ? cxM : lm_
float uD   = fzS ? cxD : ld_
float uS   = fzS ? cxS : ls_
float uA   = fzS ? cxA : la_
float uW   = fzS ? cxW : lw_
float uV   = vxA > 0 ? vxC / vxA - 1 : na
int   uZ   = zIdx(uP)
int   uOc  = na(uP) ? na : math.min(8, int(math.floor(uP * 8)) + 1)
int   uMo  = na(uM) ? 1 : uM > 1 ? 0 : uM < -1 ? 2 : 1                 // over · near · under the month's open
int   uPg  = na(uD) ? 1 : uD > 0 ? 0 : uD < 0 ? 2 : 1                  // above PDH · inside · below PDL
int   uSg  = na(uS) ? 1 : uS > 0.4 ? 0 : uS < -0.4 ? 2 : 1              // strong up · within · strong down
int   uWg  = na(uW) ? 1 : uW > 0.5 ? 0 : uW < -0.5 ? 2 : 1              // week up · flat · down
int   uVg  = na(uV) ? 1 : uV > 0.1 ? 0 : uV < -0.1 ? 2 : 1              // VIX over · near · under its average
int   uDd  = na(nextOf(NP, calK)) ? na : inDays(nextOf(NP, calK), calK)
bool  stS  = vzK == calK
float sv1  = stS and not na(s1O) ? (na(s1C) ? close : s1C) - s1O : na
float sv2  = stS and not na(s2O) ? (na(s2C) ? close : s2C) - s2O : na
float dv1  = stS and not na(x1O) and dxA > 0 ? ((na(x1C) ? dxL : x1C) - x1O) / dxA : na
float dv2  = stS and not na(x2O) and dxA > 0 ? ((na(x2C) ? dxL : x2C) - x2O) / dxA : na
float uAdd = stS and not na(r830) and uA > 0 ? ((na(r09) ? tdH - tdL : r09) - r830) / uA : na
color zBg  = uZ == 2 ? cPrem : uZ == 0 ? cDisc : cNeu
color zFg  = uZ == 1 ? cTx : #ffffff
drawSg() =>
    if barstate.islast and showSg and not na(TV)
        string dot  = barstate.isrealtime ? (beat % 2 == 0 ? "●" : "○") : "◆"
        int    z    = uZ
        float  a    = uA
        float  e1   = VS.get(2 * z) * a
        float  e2   = VS.get(6 + 2 * z) * a
        float  eA   = VS.get(12 + 2 * z) * a
        float  eR   = VS.get(18 + 2 * z) * a
        float  r1   = na(sv1) or not (e1 > 0) ? na : math.abs(sv1) / e1
        float  r2   = na(sv2) or not (e2 > 0) ? na : math.abs(sv2) / e2
        float  rq   = stS and not na(qH) ? qH - qL : na
        float  rR   = na(rq) or not (eR > 0) ? na : rq / eR
        [t1, f1, b1] = dxPill(dv1, sv1, 0.42)
        [t2, f2, b2] = dxPill(dv2, sv2, 0.22)
        string zW   = z == 2 ? "PREMIUM" : z == 0 ? "DISCOUNT" : "MIDDLE"
        string dayT = vzF ? "NFP TODAY" : na(uDd) ? "NFP —" : "NFP IN " + str.tostring(uDd) + "D"
        int    oi   = na(uOc) ? 0 : 4 * (uOc - 1)
        string ocT  = na(uOc) ? "" : "Octant " + str.tostring(uOc) + " of 8 (n " + str.tostring(OC.get(oi), "0") + "): range after 08:30 " + str.tostring(OC.get(oi + 1), "0.00") + " ADR, new high " + str.tostring(OC.get(oi + 2), "0") + "%, new low " + str.tostring(OC.get(oi + 3), "0") + "%. "
        string mTp  = "Price at " + (na(uP) ? "—" : p0(uP)) + " of the month's range so far (" + (fzS ? "08:29" : "live") + "): " + zW + ". " + ocT + TXA.get(VZT_MON)
        string oTp  = "Month's open " + pf(mtO) + ": " + fdSg(uM, "0.0") + " ADR (" + sgS(uM * a) + " pts). " + VZT_MO
        string pdT  = na(uD) ? "prior day —" : uD > 0 ? "above PDH " + sgS(uD * a) : uD < 0 ? "below PDL " + sgS(uD * a) : "inside prior day"
        string vxT  = na(uV) ? "VIX —" : "VIX " + str.tostring(vxC, "0.0") + " · " + fdSg(100 * uV, "0") + "% vs 20d"
        bool   zH   = hlH(42 + 2 * z) or vh(18 + 2 * z)
        int    r    = tvO
        if not mob
            cardHead(TV, r, cGh, dot + " NFP STAGES · " + symTag, TXA.get(VZT_HD), zW, zFg, zBg)
            cardSub(TV, r + 1, cGh, (fzS ? "SETUP AT 08:29 · " : "SETUP LIVE · ") + dayT, "ADR", "after")
            cardRow(TV, r + 2, cGh, "MONTH", zH, octBar(uOc) + " O" + (na(uOc) ? "—" : str.tostring(uOc)), na(uP) ? "—" : p0(uP), hl(42 + 2 * z), mTp, z == 1 ? na : zBg, cSub)
            cardRow(TV, r + 3, cGh, "MO", vh(48 + uMo), "vs month open " + sgS(uM * a), fdSg(uM, "0.0"), rg(48 + uMo), oTp, uMo == 0 ? cHot : uMo == 2 ? cCold : na, cSub)
            cardRow(TV, r + 4, cGh, "PD", hlH(30 + 2 * uPg), pdT, uPg == 1 ? "" : fdSg(uD, "0.0"), hl(30 + 2 * uPg), TXA.get(VZT_PD), na, cSub)
            cardRow(TV, r + 5, cGh, "18:00", hlH(36 + 2 * uSg), "since 18:00 " + sgS(uS * a), fdSg(uS, "0.0"), hl(36 + 2 * uSg), TXA.get(VZT_18), uSg == 0 ? cDisc : uSg == 2 ? cPrem : na, cSub)
            cardRow(TV, r + 6, cGh, "WEEK", vh(54 + uWg), "week in " + sgS(uW * a), fdSg(uW, "0.0"), rg(54 + uWg), TXA.get(VZT_WK), uWg == 0 ? cDisc : uWg == 2 ? cPrem : na, cSub)
            cardRow(TV, r + 7, cGh, "VIX", vh(51 + uVg), vxT, "", rg(51 + uVg), TXA.get(VZT_VX), na, cSub)
            if stS
                cardSub(TV, r + 8, cDxc, "LIVE · vs DXY", "×typ", "DXY")
                cardRow(TV, r + 9, cGh, "S1", false, liveTx(sv1, dv1), na(r1) ? "" : x2(r1), "", TXA.get(VZT_LV), nz(r1) >= 1 ? cHot : na)
                tcQ(TV, 4, r + 9, t1, f1, b1, TXA.get(VZT_LV), text.align_center, true)
                cardRow(TV, r + 10, cGh, "S2", false, na(s2O) ? "from 08:50" : liveTx(sv2, dv2), na(r2) ? "" : x2(r2), "", TXA.get(VZT_LV), nz(r2) >= 1 ? cHot : na)
                tcQ(TV, 4, r + 10, t2, f2, b2, TXA.get(VZT_LV), text.align_center, true)
                cardRow(TV, r + 11, cGh, "RANGE", vh(18 + 2 * z), "since 08:30 " + sgP(rq) + " pts", na(rR) ? "" : x2(rR), "med " + sgP(eR), TXA.get(VZT_LV) + " " + TXA.get(VZT_E), nz(rR) >= 1 ? cHot : na)
            else
                cardSub(TV, r + 8, cGh, "EXPECT · " + zWd(z) + " · ADR " + sgP(a), "med", "80%")
                cardRow(TV, r + 9, cGh, "RANGE", vh(18 + 2 * z), "after 08:30", sgP(eR), sgP(VS.get(19 + 2 * z) * a), TXA.get(VZT_E))
                cardRow(TV, r + 10, cGh, "NY AM", vh(12 + 2 * z), "09:30–11:00", "±" + sgP(eA), "±" + sgP(VS.get(13 + 2 * z) * a), TXA.get(VZT_E))
                cardRow(TV, r + 11, cGh, "S1/S2", false, "08:30–08:50 / –09:30", "±" + sgP(e1) + "/" + sgP(e2), "±" + sgP(VS.get(1 + 2 * z) * a) + "/" + sgP(VS.get(7 + 2 * z) * a), TXA.get(VZT_E) + (isES ? " " + VZT_MN : ""))
        else
            cardHead(TV, r, cGh, dot + " NFP · " + symTag + (vzF or na(uDd) ? "" : " · " + str.tostring(uDd) + "D"), TXA.get(VZT_HD), zWd(z), zFg, zBg)
            cardRow(TV, r + 1, cGh, "MO", zH, octBar(uOc) + " " + (na(uP) ? "—" : p0(uP)), fdSg(uM, "0.0"), hl(42 + 2 * z), mTp + " " + oTp, uMo == 0 ? cHot : uMo == 2 ? cCold : na)
            if stS
                bool in2 = not na(s2O)
                cardRow(TV, r + 2, cGh, in2 ? "S2" : "S1", false, in2 ? liveTx(sv2, dv2) : liveTx(sv1, dv1), na(in2 ? r2 : r1) ? "" : x2(in2 ? r2 : r1), "", TXA.get(VZT_LV))
                tcQ(TV, 4, r + 2, in2 ? t2 : t1, in2 ? f2 : f1, in2 ? b2 : b1, TXA.get(VZT_LV), text.align_center, true)
                cardRow(TV, r + 3, cGh, "RANGE", vh(18 + 2 * z), "since 08:30 " + sgP(rq), na(rR) ? "" : x2(rR), "med " + sgP(eR), TXA.get(VZT_LV))
            else
                cardRow(TV, r + 2, cGh, "EXP", vh(18 + 2 * z), "range " + sgP(eR) + " · AM ±" + sgP(eA), sgP(VS.get(19 + 2 * z) * a), "80%", TXA.get(VZT_E))
                cardRow(TV, r + 3, cGh, "PD", hlH(30 + 2 * uPg), (uPg == 0 ? "> PDH " : uPg == 2 ? "< PDL " : "in PD ") + hl(30 + 2 * uPg), uPg == 1 ? "" : fdSg(uD, "0.0"), "", TXA.get(VZT_PD))
            cardRow(TV, r + 4, cGh, "WK·VX", vh(54 + uWg) or vh(51 + uVg), "wk " + fdSg(uW, "0.0") + " · VIX " + fdSg(100 * uV, "0") + "%", rg(54 + uWg), rg(51 + uVg), TXA.get(VZT_WK) + " " + TXA.get(VZT_VX))
    true
drawSg()
// HYDRA findings (indicator pane): what held for today's setup, pooled NQ + ES + RTY, in points at today's ADR20
drawHy() =>
    if barstate.islast and showHy and not na(TH)
        string dot = barstate.isrealtime ? (beat % 2 == 0 ? "●" : "○") : "◆"
        int    z   = uZ
        float  a   = uA
        int    r   = thO
        float  eR  = VS.get(18 + 2 * z) * a
        // size: the month's group, then the other held size groups and whether they agree (bigger / smaller than all NFP days)
        string tg  = ""
        string tgN = ""
        int    bg_ = z == 0 ? 1 : 0
        int    sm_ = z == 2 ? 1 : 0
        if uMo != 1
            tg  += (uMo == 0 ? "MO↑ " : "MO↓ ")
            tgN += (uMo == 0 ? "MO↑ " : "MO↓ ") + str.tostring(VS.get(48 + uMo), "0.00") + " · "
            bg_ += uMo == 2 ? 1 : 0
            sm_ += uMo == 0 ? 1 : 0
        if uVg != 1
            tg  += (uVg == 0 ? "VIX↑ " : "VIX↓ ")
            tgN += (uVg == 0 ? "VIX↑ " : "VIX↓ ") + str.tostring(VS.get(51 + uVg), "0.00") + " · "
            bg_ += uVg == 0 ? 1 : 0
            sm_ += uVg == 2 ? 1 : 0
        if uWg != 1
            tg  += (uWg == 0 ? "WK↑ " : "WK↓ ")
            tgN += (uWg == 0 ? "WK↑ " : "WK↓ ") + str.tostring(VS.get(54 + uWg), "0.00") + " · "
            bg_ += uWg == 2 ? 1 : 0
            sm_ += uWg == 0 ? 1 : 0
        if uPg == 2
            tg  += "<PDL "
            tgN += "<PDL 1.29 · "
            bg_ += 1
        if uSg == 2
            tg  += "18↓ "
            tgN += "18↓ 1.20 · "
            bg_ += 1
        string agr = bg_ > 0 and sm_ == 0 ? "BIGGER" : sm_ > 0 and bg_ == 0 ? "SMALLER" : bg_ > 0 ? "MIXED" : "TYPICAL"
        string agT = "Active today: " + (tgN == "" ? "none" : tgN) + " Range after 08:30 in ADR for each held size group active today (all NFP days 0.95): MO = more than 1 ADR from the month's open, VIX = more than 10% from its 20-day average, WK = the week into the release beyond ±0.5 ADR, <PDL = below the prior day's low, 18↓ = down more than 0.4 ADR since 18:00. BIGGER / SMALLER = every active group, the month's position included, points the same way; MIXED = they disagree. " + TXA.get(VZT_VX) + " " + TXA.get(VZT_WK)
        // extremes after 08:30: the most specific held group (the move since 18:00, then the prior day, then the month)
        int    xi  = uSg != 1 ? 36 + 2 * uSg : uPg != 1 ? 30 + 2 * uPg : 42 + 2 * z
        string xn  = uSg == 0 ? "18:00↑" : uSg == 2 ? "18:00↓" : uPg == 0 ? ">PDH" : uPg == 2 ? "<PDL" : zWd(z)
        // ATH CE: fixed at 08:30 on NFP day, else where it would sit now
        bool   ceF = not na(ceV) and not na(ceXE) and time < ceXE
        float  ceX = ceF ? ceV : athN > close ? (athN + close) / 2 : na
        float  ceD = ceF ? ceDA : a > 0 and not na(ceX) ? (ceX - close) / a : na
        bool   ceH = not na(ceD) and (ceD <= 0.5 or ceD > 1)
        string ceS = ceF ? (na(ceHT) ? "open" : "hit " + str.format_time(ceHT, dateKey(ceHT) == calK ? "HH:mm" : "EEE HH:mm", TZ)) : "at 08:30"
        // first side of the pre-release range (07:00–08:29) taken after 08:30
        string fsR = uVg == 2 ? "79%" : uWg == 0 ? "74%" : uWg == 1 ? "46%" : "59%"
        bool   fsH = uVg == 2 or uWg == 0 or uWg == 1
        string fsW = uVg == 2 ? "VIX low" : uWg == 0 ? "week up" : uWg == 1 ? "flat wk" : "all"
        string fsX = fsd == 0 ? (stS ? "no break yet" : "break from 08:30") : fsd == 2 ? "both sides, one bar" : "break " + (fsd == 1 ? "▲ " : "▼ ") + str.format_time(fsT, "HH:mm", TZ)
        [t1, f1, b1] = dxPill(dv1, sv1, 0.42)
        [t2, f2, b2] = dxPill(dv2, sv2, 0.22)
        int    nH  = (vh(18 + 2 * z) ? 1 : 0) + (tg != "" ? 1 : 0) + (hlH(xi) ? 1 : 0) + (ceH ? 1 : 0) + (fsH ? 1 : 0) + 3
        bool   in2 = stS and not na(s2O)
        if not mob
            cardHead(TH, r, cHy, dot + " GRIMMJOW · NFP", TXA.get(VZT_HY), str.tostring(nH) + " ✓", cHy, #ffffff)
            cardSub(TH, r + 1, cHy, "NQ+ES+RTY · ADR " + sgP(a), "today", "base")
            cardWide(TH, r + 2, cHy, "SIDE", "none held: size the day", TXA.get(VZT_HY), cSub)
            cardRow(TH, r + 3, cHy, "RANGE", vh(18 + 2 * z), "after 08:30 · " + zWd(z), sgP(eR), "all " + sgP(0.95 * a), "Range after 08:30 for today's month position (" + zWd(z) + "): median " + sgP(eR) + ", 80% " + sgP(VS.get(19 + 2 * z) * a) + " pts. " + TXA.get(VZT_MON) + " " + TXA.get(VZT_E))
            cardRow(TH, r + 4, cHy, "SIZE+", tg != "", tg == "" ? "none active" : tg, "", "", agT)
            tcQ(TH, 3, r + 4, agr, agr == "BIGGER" or agr == "SMALLER" ? #ffffff : cTx, agr == "BIGGER" ? cHot : agr == "SMALLER" ? cCold : cNeu, agT, text.align_center, true)
            cardRow(TH, r + 5, cHy, "H/L", hlH(xi), "after 08:30 · " + xn, hl(xi), "H75 L64", "New day high (H) / low (L) after 08:30 for today's most specific group (" + xn + "); all NFP days H75 L64. " + TXA.get(VZT_18) + " " + TXA.get(VZT_PD) + " " + TXA.get(VZT_MON))
            cardRow(TH, r + 6, cHy, "CE", ceH, na(ceX) ? "at the ATH" : pf(ceX) + " · " + str.tostring(ceD, "0.0") + " ADR", ceOdds(ceD), ceS, TXA.get(VZT_CE), nz(ceD, 9) <= 0.5 ? cHot : na, ceF and not na(ceHT) ? cOk : na)
            cardRow(TH, r + 7, cHy, "1ST", fsH, fsX, fsR, fsW, TXA.get(VZT_FS))
            cardRow(TH, r + 8, cHy, "DXY1", true, "S1 BIG ≥ 0.42 → other", "82%", "vs 53%", TXA.get(VZT_DR))
            cardRow(TH, r + 9, cHy, "DXY2", true, "S2 BIG ≥ 0.22 → other", "71%", "vs 59%", TXA.get(VZT_DR))
            if stS
                tcQ(TH, 4, r + 8, t1, f1, b1, TXA.get(VZT_LV), text.align_center, true)
            if in2
                tcQ(TH, 4, r + 9, t2, f2, b2, TXA.get(VZT_LV), text.align_center, true)
            cardRow(TH, r + 10, cHy, "08:30", true, "→09:00 adds · typ " + sgP(0.14 * a), na(uAdd) ? "—" : "+" + sgP(uAdd * a), na(uAdd) ? "+0.14×" : "+" + x2(uAdd), VZT_AD, nz(uAdd) >= 0.14 ? cHot : na)
        else
            cardHead(TH, r, cHy, dot + " GRIMMJOW", TXA.get(VZT_HY), str.tostring(nH) + " ✓", cHy, #ffffff)
            cardRow(TH, r + 1, cHy, "RANGE", vh(18 + 2 * z), zWd(z) + " " + sgP(eR) + " pts", "", "", TXA.get(VZT_E))
            tcQ(TH, 3, r + 1, agr, agr == "BIGGER" or agr == "SMALLER" ? #ffffff : cTx, agr == "BIGGER" ? cHot : agr == "SMALLER" ? cCold : cNeu, agT, text.align_center, true)
            cardRow(TH, r + 2, cHy, "H/L", hlH(xi), "after 08:30 · " + xn, hl(xi), "", TXA.get(VZT_PD))
            cardRow(TH, r + 3, cHy, "CE", ceH, na(ceX) ? "at the ATH" : str.tostring(ceD, "0.0") + " ADR · " + ceS, ceOdds(ceD), "", TXA.get(VZT_CE))
            cardRow(TH, r + 4, cHy, "1ST", fsH, fsX, fsR, "", TXA.get(VZT_FS))
            cardRow(TH, r + 5, cHy, in2 ? "DXY2" : "DXY1", true, "BIG → other way", in2 ? "71%" : "82%", "", TXA.get(VZT_DR))
            if stS
                tcQ(TH, 4, r + 5, in2 ? t2 : t1, in2 ? f2 : f1, in2 ? b2 : b1, TXA.get(VZT_LV), text.align_center, true)
    true
drawHy()
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
