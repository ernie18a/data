# Catalyst: Multi-Asset Economic Calendar

- url: https://www.tradingview.com/script/5bfCQ1GP-Catalyst-Multi-Asset-Economic-Calendar/
- type: indicator
- pine_id: PUB;f4c390cf6781498aaedbd08ea8c293db
- version: 1.0

## Description

============================================================
[b]⚠️ IMPORTANT — READ BEFORE USING ⚠️[/b]
============================================================

⚠️ Catalyst is an educational and analytical tool. It is not financial advice, a trading system or a signal service. It does not generate buy or sell signals, and nothing it displays is a recommendation to trade.

⚠️ The calendar shows scheduled events and released economic data — not predictions. Impact ratings, colours, figures and alerts do not tell you whether price will rise, fall or reverse. A Critical event does not guarantee a large move, and a favourable data change is not a buy signal.

⚠️ Use this tool to help plan your session, not as a replacement for official sources. Schedules can change, coverage can be incomplete, and figures may be delayed, missing or revised. Accuracy and completeness cannot be guaranteed. Always confirm important releases with their original publisher before relying on them.

⚠️ Past data and past market reactions do not guarantee future results. The same type of announcement can produce a different reaction from one release to the next.

⚠️ Your trading decisions and any resulting losses are your responsibility. Leveraged trading can cause substantial losses and, depending on the product and account protections, losses beyond your initial deposit. Seek advice from an appropriately licensed professional when needed.

------------------------------------------------------------

[b]📅 Catalyst — your economic calendar, right on your chart[/b]

What news is coming up, when is it due, and which events relate to the market you are watching? Catalyst brings that information into one simple table on your TradingView chart.

See scheduled interest-rate decisions, inflation reports, jobs data, oil inventories and more, with their release times and colour-coded impact levels. When a supported result reaches TradingView, the table shows the new figure beside the previous one.

In the default Auto mode, change your chart's symbol and the calendar changes with it. Everything stays in one corner of your chart — no extra lines or levels drawn over price.

Whether you are learning to use an economic calendar or already plan your sessions around news, the aim is the same: less switching between screens and a clearer view of what is scheduled.


[b]✨ Why traders add it[/b]

📆 See the week at a glance. Quickly spot scheduled releases, with red for Critical, orange for High and yellow for Medium impact.

🎯 Let Auto mode choose the relevant releases. EURUSD shows US and euro-area events, crude oil includes energy reports, and gold includes trader-positioning reports.

🔢 Compare the latest result with the previous one. Actual, Prev. and Change fill in automatically when supported figures become available through TradingView. The Change colour reflects the usual interpretation for the currency — not a trading signal.

⏰ Keep track of what is next. A countdown shows the time until the next release, and you can create an alert to notify you beforehand.

🗓️ Use publisher-based dates. Dates come from the original publisher's calendar or published scheduling rule. Missing dates are not guessed.

🔓 Free and open source. No separate data feed, no API key and no external service to connect.


[b]🚀 Quick start[/b]

1. Add Catalyst to your chart. The table appears in the bottom-right corner.
2. You are ready to go: Auto mode selects the releases for your symbol, showing This Week in New York time by default.
3. To change the timezone, date range, impact levels or appearance, double-click the table to open its settings.


[b]👀 Reading the table[/b]

[b]Impact dots[/b]
🔴 Critical  ·  🟠 High  ·  🟡 Medium  ·  ⚪ Low  ·  🔵 Holiday

Critical includes releases that can move a market on their own, such as interest-rate decisions, US payrolls and US CPI inflation. High is the next tier, including retail sales, business-activity surveys (PMIs) and economic-growth reports (GDP). These labels describe the event's impact category, not a guaranteed market reaction.

[b]Time, Currency and Type[/b]
Time follows your chosen timezone — New York by default. Currency identifies the economy behind the release; currencies other than USD appear in bold. Type identifies the event category, such as Economy, Energy or Bonds.

[b]Event[/b]
This is the release name. Where available, the reporting period appears in brackets. For example, “CPI (YoY) (Sep)” refers to September's consumer inflation compared with a year earlier, released in October. The month in brackets is the month being measured, not necessarily the release month.

[b]Actual, Prev. and Change[/b]
Actual is the released figure. Prev. is the previous figure. Change is the difference between them: Actual minus Previous. Its colour follows the usual interpretation for the currency; for example, rising unemployment is shown as weaker. It does not predict how price will react.

[b]Now and Next[/b]
The now line separates past releases from upcoming ones. The Next line counts down to the next release. The table focuses on the events nearest to now, with roughly one-third already released and the rest still to come.

[b]Bottom line[/b]
This shows the selected period and how many events it contains.

💡 Hover for help. Hover over an event name to learn what it measures, a Change cell to read its usual interpretation, or a dash to find out why a value is missing.


[b]🎯 Auto mode — a calendar that follows your chart[/b]

Auto is the default. It uses your chart's symbol to select the relevant economies and event categories:

[b]Currency pairs:[/b] releases for both currencies.

[b]Crude oil and natural gas:[/b] US releases, US Treasury auctions, energy reports and trader-positioning reports.

[b]US stock indices:[/b] US releases, US Treasury auctions, quarterly expiry and trader-positioning reports.

[b]Gold:[/b] US releases, US Treasury auctions and trader-positioning reports.

US dollar pairs and US stock indices also include the weekly crude oil inventories report.

Prefer a different selection? Show everything lists every event, while Custom lets you choose the currencies and categories yourself.

Auto mode on natural gas futures, daily chart:
https://www.tradingview.com/x/SoiuE6JU/


[b]⚙️ The settings[/b]

Double-click the table to open the settings. The small i icons beside them explain each option in more detail.

[b]Mode:[/b] Auto, Show everything or Custom.

[b]Timezone:[/b] Exchange, UTC, New York, Chicago, London, Frankfurt, Tokyo or Sydney. TradingView does not let an indicator read your chart's timezone, so choose the table's timezone here separately.

[b]Time Format:[/b] 24 hour or 12 hour (AM/PM).

[b]Show:[/b] Today, This Week (the default), Next Week, This Month, Next Month, This Quarter, This Year, or Custom with your own From and To dates.

[b]News impact:[/b] choose which impact levels to include. All five levels are on by default.

The settings, part 1 - mode, timezone, period and impact levels:
https://www.tradingview.com/x/977eH95o/

[b]Filters:[/b] available in Custom mode only. Choose from AUD, CAD, CHF, CNY, EUR, GBP, JPY, NZD and USD, and the categories Economy, Energy, Crops, Bonds, Market and Positioning.

[b]Table:[/b] show or hide the table, choose its corner and size, select the columns, and adjust the notices, alert lead time and colours. Sizes are Tiny, Small, Normal and Large, with Small selected by default. Rows controls how many events are displayed, from 10 to 50.

The settings, part 2 - the filters for Custom mode and the table:
https://www.tradingview.com/x/gpzJvUr4/


[b]🔔 Alerts — a reminder before the release[/b]

One alert covers every release that matches your settings.

To create it, click the alarm-clock icon in TradingView's top toolbar, select Catalyst (Gigi) as the condition, and create the alert.

Choose a reminder 5, 15, 30 or 60 minutes before the release under Alert in the settings. The default is 15 minutes. The notification includes the event name, currency, impact level and release time.

Set your currency and impact filters before creating the alert so you only receive reminders for the events you care about.

An alert tells you what is coming — never what to buy or sell.


[b]🌍 What it covers[/b]

Catalyst's catalogue includes 128 event types across nine economies: the United States, the euro area, the United Kingdom, Japan, Australia, New Zealand, Canada, Switzerland and China.

The calendar covers central-bank decisions, inflation, employment, economic growth, housing and sentiment. The US has the broadest coverage, with 71 event types. The other eight economies have between 3 and 13 each, focused on releases that matter most to their currencies.

It also includes the EIA's and API's weekly oil and gas inventory reports; the USDA's WASDE, crop progress and grain stocks reports; US Treasury note, bond and bill auctions; the Chicago PMI; the CFTC's trader-positioning report; quarterly index expiry; and US market holidays.

Not every event type has available dates or figures in this version. The coverage and limitations are explained below.


------------------------------------------------------------
[b]🔎 More detail — data sources, coverage and limitations[/b]
------------------------------------------------------------

The sections above explain everyday use. Below you will find where the dates and figures come from, why some cells show a dash, and what to expect on longer timeframes, in Bar Replay or on a chart that has stopped trading.


[b]📚 Where the dates and figures come from[/b]

[b]Release dates: included with each version[/b]

Every date comes from the original publisher's release calendar or, for certain events, its written scheduling rule. A date that the publisher has not supplied is not invented.

The schedule is compiled before each version and included in the open-source companion library CatalystCalendarData. Its format is documented line by line, so anyone can check and decode an individual record by hand.

[b]The sources are:[/b]

[b]United States:[/b] FRED, the St. Louis Fed's release calendar, which includes the BLS and BEA schedules; the Census Bureau; the Federal Reserve; the EIA; the US Treasury; the USDA; the CFTC; ISM; the University of Michigan; the Conference Board; MNI; NAHB; and the National Association of Realtors.

[b]Euro area:[/b] Eurostat, the ECB, ZEW and the European Commission.

[b]United Kingdom:[/b] the Office for National Statistics and the Bank of England.

[b]Japan:[/b] the Statistics Bureau, Japan Customs, the Cabinet Office and the Bank of Japan.

[b]Australia:[/b] the Australian Bureau of Statistics and the Reserve Bank of Australia.

[b]New Zealand:[/b] Stats NZ and the Reserve Bank of New Zealand.

[b]Canada:[/b] Statistics Canada and the Bank of Canada.

[b]Switzerland:[/b] the Swiss Federal Statistical Office, SECO and the Swiss National Bank.

[b]China:[/b] the National Bureau of Statistics.

The EIA's and API's weekly reports, bill auctions, FOMC minutes, quarterly expiry, US market holidays and the Conference Board's consumer confidence releases from January to November follow their publisher's written scheduling rule.

[b]Released figures: supplied through TradingView[/b]

The figures come from TradingView's own economic data, without a separate outside feed, requests to external services or an API key.

Each figure is matched to the period TradingView assigns it to and is displayed only from its scheduled release time. It is not shown on a past row before that scheduled time.

⏳ Figures can arrive a few minutes after the official release. While Catalyst waits, the Actual cell shows an hourglass, with the previous figure beside it. The row fills in automatically when the new figure becomes available.

The important distinction: release dates are included with the script's data version; supported figures update as they become available through TradingView.


[b]🗓️ How far ahead does the calendar go?[/b]

Each version contains the dates that publishers had made available when it was built. Different events therefore have different end dates.

The first public version was built in October 2026. This version covers October 2024 to October 2027, but that does not mean every event is scheduled through October 2027:

• Events based on published scheduling rules and the Federal Reserve's decisions run to the end of the covered period.
• US statistical releases, including jobs, inflation, GDP and retail sales, run to December 2026.
• US Treasury note and bond auctions run to January 2027.
• China's releases run to mid-December 2026.

These limits reflect how far the relevant agencies had published their schedules when this version was built.

The schedule is refreshed every three months. Each refresh extends coverage to the dates published since the previous version. Release notes explain how far each update reaches, and the table's bottom line shows the data version your chart is using.

[b]Seven event types have no dates in this version and are not listed:[/b]

• China's loan prime rate: normally set on the 20th of the month, or later when a public holiday intervenes. The full official holiday calendar has not yet been read, so dates are left out rather than guessed.
• China's trade balance: the customs administration publishes a timetable, but its website does not make that document available to automated readers.
• OPEC meetings: OPEC publishes no calendar; each meeting's date is announced at the previous meeting.
• Reuters Tankan: this poll has no published release calendar.
• Baker Hughes rig count: published at noon Central time on the last working day of the week, but the website blocked every automated read.
• Global Dairy Trade auctions: held about every two weeks. Published dates exist but have not yet been read.
• Challenger job cuts: the publisher's release dates have not yet been read.

When an update adds dates for one of these events, its release notes will say so.


[b]❓ Why does a cell show a dash?[/b]

A dash means a figure is unavailable for a specific reason. Hover over it to see the explanation.

Hovering a dash shows why it is there:
https://www.tradingview.com/x/d94eEJce/

[b]Date-only events[/b]

23 event types are date markers rather than rows with figures.

Six do not have a numerical result by nature: FOMC and ECB press conferences, FOMC minutes, US market holidays, quarterly expiry and OPEC meetings.

For the other 17, TradingView does not supply the figures: ISM Services PMI, ISM Manufacturing Prices, the Conference Board's consumer confidence, the Chicago PMI, the nine Treasury auctions, the CFTC report, WASDE, crop progress and Australia's quarterly CPI. Their published dates and times are still used.

[b]Reporting period not confirmed[/b]

Five event types show no figure because a published source could not confirm the period the figure belongs to: the three grain stocks reports, Japan's machinery orders and the Global Dairy Trade price index. Leaving the cell empty avoids displaying a number for the wrong reporting period.

[b]Core PCE month on month[/b]

This row shows its date only, by choice. TradingView supplies the index rather than its monthly change. After a revision, it updates only the latest months, so calculating the change between neighbouring months can mix different versions of the data. The yearly rate is shown on a separate row.

[b]Shutdown-delayed US releases[/b]

For US releases delayed by the 2025 government shutdown in the October 2025 to early May 2026 period, no figure is shown where the reporting month cannot be established from the release date.

[b]Data-request limits[/b]

Catalyst works within a 40-request TradingView budget. It loads at most 36 figures at a time: 36 requests on daily or shorter charts, and 37 on longer charts, where the figures are read through the chart's daily bars.

The highest-impact events get their figures first. When more event types are visible than the script can load figures for — for example, when every US event is shown — the remaining events show dates only. A notice explains how many are affected and which filters to untick.

[b]Not enough chart history[/b]

Figures can only reach back as far as your chart's available history. On 1-, 5- or 15-minute charts, or a 1-hour chart with a 5,000-bar history limit, some needed data can fall before the first available bar. This can affect older figures, the previous value of a monthly release, or year-on-year PCE, which needs a value from a year earlier.

Those cells show a dash with an explanation. A 4-hour or daily chart reaches back far enough for these cases.


[b]🔢 Understanding the figures[/b]

[b]No Forecast column[/b]

There is deliberately no Forecast column. TradingView's economic data does not include a consensus forecast — the figure analysts expect before a release. A forecast stored when the script was built would become outdated for later releases.

Change compares Actual with Previous, not Actual with Forecast. It is calculated from the values as printed in their cells. Its colour reflects the usual interpretation for the currency, not a prediction. Markets can react to the difference from expectations, revisions to older data or other news.

[b]Past figures can be revised[/b]

Historical rows show TradingView's revised figures, not necessarily the numbers first announced. TradingView replaces older values when its data is revised.

[b]Later estimates of the same period[/b]

A later estimate is identified in the event name, such as “(Q2 3rd est.)” for a third GDP estimate or “(Sep final)” for a final Michigan reading. These rows do not show Previous: TradingView keeps only one value per reporting period, so the earlier estimate it replaced is unavailable.

[b]Euro-area interest rates[/b]

The displayed figure is the ECB's main refinancing rate. The deposit facility rate, which is often quoted elsewhere, is set lower.

[b]Year-on-year PCE after revisions[/b]

After an annual revision, the displayed year-on-year PCE rate can temporarily differ from the published figure by 0.1, until TradingView also revises the year-earlier month.

[b]Daily currency and futures charts[/b]

A release appears on its own day's bar. For example, a Friday Bank of Japan decision appears on Friday, not after the weekend.

[b]Weekly, monthly and other longer charts[/b]

Charts with bars longer than one day — including two-day, weekly, monthly and quarterly charts — read each figure from the chart's daily bars inside the longer bar. This accounts for differences in how markets group their trading days.

The result is the same figure, at the same time, as on a daily chart. You do not have to wait for the next weekly or monthly bar to open, and a monthly chart can show every weekly report.

A weekly chart shows the same figures as a daily chart:
https://www.tradingview.com/x/6T2j61tq/


[b]🛠️ The table, custom dates and notices[/b]

[b]Custom dates include the time[/b]

From and To define exact dates and times, not whole calendar days. The defaults are 18:00 New York on 1 January 2026 to 17:00 on 1 January 2027, following the futures trading day.

The date boxes use your chart's timezone, while the table uses Catalyst's Timezone setting. Set both to the same zone to avoid confusion. The table's heading includes the hours whenever either end of the range is not midnight.

[b]The table cannot scroll[/b]

It shows the events nearest to now, and its heading tells you how many of the available events are displayed.

[b]When the table is too tall[/b]

A table taller than the chart is cut off at the edge furthest from its selected corner. With the default bottom-right position, that means the top is cut off.

In either bottom corner, a long table repeats the column headings beneath the last row so they remain visible. Reduce Rows or choose a smaller table size to fit more comfortably. The main heading and notices stay at the anchored corner edge, where they are not cut off.

[b]Notices explain what to change[/b]

The table displays a notice when there are more events than Rows allows, custom dates extend outside the available calendar, From is later than To, too many event types need figures, or the chart's price data has stopped updating.

[b]When a chart has stopped trading[/b]

A chart cannot show figures for releases after its last bar. Those rows show a dash. The notice suggests opening the same pair or symbol from another broker or data feed that is still trading.

[b]Bar Replay[/b]

Rows before the replay point show their figures; rows after it show a dash. However, the now line, countdown and Today, This Week and This Month ranges follow the real clock, not the replay clock.

💡 In Bar Replay, set Show to Custom and choose the dates you are replaying.


[b]🔓 Open source[/b]

Catalyst is published open source under the Mozilla Public License 2.0. The code is commented to make it easier to read, and no code was taken from another script.

Questions, feedback and corrections are welcome in the comments below. 💬

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gigi_Luigino
//
// ===========================================================================
// Catalyst: Multi-Asset Economic Calendar
// ===========================================================================
//
// WHAT THIS DOES
//
//   Shows a forward-looking economic and commodity release calendar, in a
//   table on any chart: FX and rates policy decisions, inflation and labour
//   prints, EIA petroleum and natural gas reports, agricultural reports,
//   Treasury auctions and market-structure dates such as quarterly expiry.
//
//   The release SCHEDULE ships inside the script: up to about 24 months of
//   history and up to about 12 months ahead, depending on the source - see
//   FORWARD COVERAGE below. The FIGURES - actual, previous and change - are
//   read live through request.economic(), and each print is compared against
//   the previous one with the correct polarity, so a falling unemployment
//   rate reads as positive and a falling GDP does not.
//
// WHERE THE DATA COMES FROM
//
//   The release SCHEDULE is compiled offline from each publisher's own
//   calendar - or, for a few weekly reports, auctions and market dates, from
//   the publisher's own written rule - and shipped in the companion data
//   library, CatalystCalendarData, which this script imports. The [Data]
//   region below is a pointer to it. A date that no publisher states is not
//   invented: the row is shown without one.
//
//     United States   FRED (the St. Louis Fed's release calendar, which
//                     carries the BLS, BEA and much of the Census schedule),
//                     the Federal Reserve, the Census Bureau, the EIA, the
//                     US Treasury, the USDA, the CFTC, ISM, the University of
//                     Michigan, the Conference Board, MNI (the Chicago PMI),
//                     NAHB and the National Association of Realtors
//     Euro area       Eurostat, the ECB, ZEW and the European Commission
//     UK              the Office for National Statistics, the Bank of England
//     Japan           the Statistics Bureau, Japan Customs, the Cabinet
//                     Office (ESRI), the Bank of Japan
//     Australia       the Australian Bureau of Statistics, the RBA
//     New Zealand     Stats NZ, the RBNZ
//     Canada          Statistics Canada, the Bank of Canada
//     Switzerland     the Federal Statistical Office, SECO, the SNB
//     China           the National Bureau of Statistics
//
//   The release VALUES come from TradingView's own economic data through
//   request.economic(). No third-party feed, no external requests, no keys.
//
//   THE FIGURES CAN LAG THE RELEASE. The schedule is embedded and waits on
//   nothing, so a release is listed at its time whatever any feed is doing.
//   The figures are TradingView's economic data, which can reach the chart
//   minutes after the official release. Until a released figure arrives its
//   Actual cell shows an hourglass, and the row fills in by itself when it
//   does.
//
// HOW THE EMBEDDED DATA IS PACKED
//
//   Event metadata is stored once in a key table; each dated occurrence is a
//   fixed-width 11-character record. The library's [Data] region documents the
//   format inline in enough detail to decode any record by hand.
//
// UPDATE CADENCE
//
//   The embedded schedule is regenerated and republished quarterly. Values
//   need no republish - they arrive live.
//
//   FORWARD COVERAGE VARIES BY SOURCE. An event that follows its publisher's
//   own written rule runs to the end of the build, about 12 months out. An
//   event dated from an agency's own published calendar stops where that
//   calendar stops: some
//   agencies publish only about six months ahead, others a calendar year at a
//   time, and until they publish more those events show no later dates. That
//   is deliberate - a real date with a gap after it beats an invented one.
//   Each quarterly refresh extends every event to whatever has been published
//   since.
//
// NOTES AND LIMITATIONS
//
//   * TIMEZONE. All timestamps are stored and compared in UTC and converted
//     only for display. TradingView does not expose the CHART's timezone to
//     an indicator, so the panel offers a list of named zones rather than a
//     "follow the chart" option it could not honour. The default is New York,
//     the clock almost every economic release is quoted in.
//
//   * NO FORECAST, AND `Change` IS NOT ONE. The Change column compares a
//     release against the PREVIOUS release, not against an analyst consensus:
//     Actual minus Previous, each as its cell prints it, so the three always
//     add up on screen.
//     request.economic() publishes no consensus figure, and a forecast baked
//     in at build time would be wrong for every release after the republish
//     date - a stale forecast is worse than none, because it looks
//     authoritative.
//
//   * NO LOOK-AHEAD. An actual is never shown before its scheduled release
//     time. Economic series are back-dated to the end of their reference
//     period, so July payrolls carry a 31 July stamp and appear on 7 August;
//     the value exists on bars before the release, and displaying it there
//     would be look-ahead bias with no error to warn you. On historical bars
//     the release is judged by the bar's timestamp; on the live bar by the
//     clock, capped at the bar's close, so a release shows as soon as it is
//     out rather than when the next bar opens.
//
//   * A FIGURE IS READ WHERE IT IS DATED, AND SHOWN WHEN IT IS RELEASED. Each
//     release's figure is taken from its series at the end of the period it
//     describes - July's trade balance at 31 July, although it is released on
//     3 September - and appears in the table only from the release. Reading
//     at the release instead shows the NEXT period's figure for a series
//     published long after its period, and the PREVIOUS period's for a survey
//     of the month in progress.
//
//   * SURVEYS OF THE CURRENT MONTH FILL IN AT MONTH END. The Philadelphia
//     Fed, Empire State, NAHB and Michigan surveys, among others, describe the
//     month they are released in, and TradingView dates each to that month's
//     last day. Until then the row shows an hourglass, because the series
//     still holds the previous month's figure.
//
//   * WEEKLY AND MONTHLY CHARTS SHOW A DAILY CHART'S FIGURES. What a bar
//     longer than a day holds differs between markets, and even with the
//     weekday a bar happens to open on, so such a bar is never read itself.
//     A 2-day, weekly, monthly or quarterly chart reads each figure from its
//     own daily bars inside the bar - the same daily bar a daily chart reads
//     it from - so it shows the same figure, at the same moment, and a
//     monthly chart shows every weekly report week by week. It costs one data
//     request more than a daily chart: 37 of the 40 allowed.
//
//   * SIX EVENTS SHOW NO FIGURE BY CHOICE. For five the period a figure
//     describes could not be established from a published source, so their
//     figures are not shown rather than risk the wrong month's. The sixth is
//     Core PCE month on month: TradingView publishes the index, not its
//     monthly change, and after a revision it updates only the latest months,
//     so a change worked out from two neighbouring months can mix two versions
//     of the data. The yearly rate is shown. US releases delayed by the 2025
//     government shutdown, from October 2025 to early May 2026, show none
//     either - unless their publisher stated the reference month, in which
//     case the record carries it and the row is read for that month. Hover the
//     cell for the reason.
//
//   * A FEW RELEASES CARRY THEIR OWN PERIOD. Which period a release describes
//     is normally a rule - "the month before", "the month it falls in" - and a
//     rule holds only while the publisher behaves. A postponed release
//     published beside the next month's, or a report left running a month
//     behind by a shutdown, breaks it, and the row then names the wrong month
//     while looking perfectly ordinary. Those releases carry their period in
//     the record instead, taken from the publisher's own statement of it.
//
//   * REVISIONS OVERWRITE RETROACTIVELY. A historical row shows the revised
//     figure, not the original print, because the series itself is revised in
//     place. Expect a past Change to differ from what was reported on the day.
//
//   * THE CAPTURE WINDOW IS WIDER THAN THE DISPLAY WINDOW. "Previous" is the
//     last value that key printed, so the previous occurrence has to be
//     decoded even when it falls outside what you asked to see. The script
//     therefore reads 13 months further back than the window and shows none
//     of it. A year-on-year rate computed here (PCE) reads its year-ago level
//     from the chart itself, so it needs a chart that reaches back that far.
//
//   * A SHORT CHART SHOWS WHAT ITS HISTORY REACHES. Each figure is read from
//     the chart's own bars, and a 1- or 5-minute chart holds weeks of history,
//     a 15-minute one months. A figure from before the chart's first bar - an
//     older row, or the Previous of a monthly release - cannot be read there:
//     its cells show a dash whose hover says so, and every row the history
//     does reach shows its figure. A 4-hour or daily chart reaches back far
//     enough on any plan.
//
//   * TWENTY-THREE EVENTS ARE DATE MARKERS. Of the 128 events in this
//     calendar, twenty-three carry no figure and show an em dash in the
//     Actual, Previous and Change columns. Six have no number by nature - the
//     FOMC and ECB press conferences, FOMC minutes, market holidays, quarterly
//     expiry, OPEC meetings. For the other seventeen there is a published
//     number and TradingView has no data for it: ISM Services PMI, ISM
//     Manufacturing Prices, CB Consumer Confidence, the Chicago PMI, the nine
//     Treasury auctions, the CFTC COT report, USDA Crop Progress, WASDE and
//     Australia's quarterly CPI. Their DATES are accurate and are the reason
//     the rows are there; hover any of a row's dashes for which kind it is.
//
//   * A LATER ESTIMATE HAS NO PREVIOUS. TradingView keeps one value per
//     period - the latest revision - so a GDP third estimate, or Michigan's
//     final reading, cannot be compared with the estimate it revises. Its
//     Previous and Change show a dash, and its label says which estimate it
//     is: "(Q2 3rd est.)", "(Sep final)".
//
//   * AT MOST 36 SERIES. TradingView allows 40 unique data requests per
//     script and this budgets 36. A chart scoped to more distinct event types
//     than that keeps the highest-impact ones and leaves the rest with a
//     blank Actual - the table states how many, rather than letting a column
//     of empty cells look like missing data.
//
//   * NOTHING IS DRAWN ON THE PRICE PANE. Everything is in one table,
//     including the notices that explain it.
//
// ===========================================================================

//@version=6

//#region [Meta]
// ---------------------------------------------------------------------------
// Declaration and the constants shared by every later region.
// ---------------------------------------------------------------------------

indicator(
     title             = "Catalyst: Multi-Asset Economic Calendar",
     shorttitle        = "Catalyst (Gigi)",
     overlay           = true,
     max_bars_back     = 5000)

// -- The data library -------------------------------------------------------
//
// The release schedule ships in a companion library rather than in this file,
// and that is a platform limit rather than a preference. A script's own
// compiled form is capped at roughly 100,000 tokens; this schedule alone
// exceeds it once every event carries a description. An imported library draws
// from a SEPARATE budget of up to 1,000,000 tokens, so the split does not make
// the data smaller - it puts it where there is room. ARCHITECTURE section 1.
//
// Everything else stays here. In particular every request is made in this
// file, never in the library: a request issued inside a library still counts
// against the 40-request budget, and every one must be introduced on a
// historical bar.
import Gigi_Luigino/CatalystCalendarData/6 as cal

// The library version imported on the line above, printed in the table's
// footer - "Data v4 - built 25 Sep 2026" - so the data a chart is reading is
// on screen rather than assumed. Added in C21, after a whole week of checking
// ran on version 2 in the belief it was version 3. `gigi lint-pine` fails if
// this number and the import line ever disagree.
DATA_VERSION = 6

// -- Wire format ------------------------------------------------------------
// These mirror the pipeline's encoder exactly. See the [Data] region header
// for the full record layout.

REC_LEN  = 11                                    // chars per occurrence record
BASE36   = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ" // key-index alphabet
ALL_DAY  = "9999"                                // HHMM sentinel: no clock time
KEY_SEP  = "|"                                   // key-table field delimiter
ROW_SEP  = "\n"                                  // key-table row delimiter
KEY_FIELDS = 12                                  // fields per key-table row

// PRD, the twelfth field, arrived in C9 with library version 2. decodeKeys
// ALSO accepts an eleven-field row - version 1's shape - and reads it as "no
// period label". The tolerance is deliberate and exactly one version deep: the
// library and this indicator are published separately, so there is always a
// moment when one is ahead of the other, and a strict count would turn that
// moment into a table where every event silently vanishes.

// Invariant 3. Premium allows 40 unique request.*() calls; four are headroom.
// The same number is REQUEST_BUDGET in the pipeline's taxonomy.py, and a test
// asserts the two agree - a Pine side that drifted low would silently drop
// fields, and one that drifted high would not compile.
REQUEST_BUDGET = 36

// -- Impact identity --------------------------------------------------------
//
// Each level has ONE colour, fixed, chosen to match the coloured circle that
// names it in the settings panel. It is not user-editable, and that is the
// point: the panel shows a circle emoji, and no colour input can change what
// an emoji looks like. Offering a swatch that cannot alter the thing beside it
// would be an incoherent control.
//
// One constant per level drives the dot in the table, and matches the circle
// that names the level in the settings panel.
//
// Red, orange, yellow, white is a four-step HEAT RAMP. The impact tiers are an
// intensity ladder, so the colours descend one: there is no circle emoji
// between orange and yellow, and any assignment that pins yellow to the bottom
// rung forces an odd hue into the middle.
//
// Holiday is blue because it is NOT a rung on that ladder. A market closure is
// a different kind of row, not a fainter release, so it should look different
// rather than dimmer - and blue reads as "not a data release" at a glance.
CLR_CRITICAL = #DD2E44                           // matches U+1F534 red
CLR_HIGH     = #F4900C                           // matches U+1F7E0 orange
CLR_MEDIUM   = #FDCB58                           // matches U+1F7E1 yellow
CLR_LOW      = #E6E7E8                           // matches U+26AA  white
CLR_HOLIDAY  = #55ACEE                           // matches U+1F535 blue

// The colour of a cell that is deliberately saying nothing: an unchanged
// Change, and every figure on an event that has no data feed. Dimmer than the
// row text, so "nothing here" reads differently from "here is a value".
CLR_MUTED = #787b86

// The glyph the chart and the table draw an impact dot with. NOT an emoji:
// this takes whichever colour it is given, it inherits the label's font
// metrics so table columns stay aligned, and it costs one character instead of
// a surrogate pair. `gigi verify-pads` asserts its codepoint.
IMPACT_DOT = "●"

// ELLIPSIS (U+2026) WAS HERE AND IS GONE. It was the truncation character for
// chart labels, which had a 22-character budget; the table has no such budget,
// because a table cell sizes itself to its content and event names are capped
// at 40 characters by the pipeline. Nothing truncates any more, so the constant
// and its codepoint guard were both removed rather than left as decoration.
//
// What a figure cell shows when the event has no data feed at all.
//
// Twenty-three of the events in this calendar carry no series code: some have no
// number by their nature - a press conference, a market holiday, quarterly
// expiry - and for the rest TradingView simply publishes nothing usable. The
// row still earns its place, because the DATE is the information.
//
// An empty cell reads as a bug. An em dash reads as "there is deliberately
// nothing here", which is the truth, and the cell's tooltip says why.
//
// U+2014, guarded by `gigi verify-pads` for exactly the reason IMPACT_DOT is:
// an editor or a clipboard round trip will happily flatten it to a hyphen or
// an en dash, and it would still compile and simply look wrong. Note this does
// NOT conflict with the 7-bit ASCII rule on the title - that rule covers the
// title string and nothing else.
NO_DATA = "—"

// What the Actual cell shows when the release time has passed and TradingView
// has not published the figure yet. Added in C12.
//
// The table had three states and drew two. A release twelve minutes old whose
// figure had not reached TradingView's series showed an empty cell - exactly
// what a release still to come shows - and it read as broken to the author who
// built it.
//
// An hourglass, because it says WAITING rather than NOTHING. It cannot be
// taken for NO_DATA: that is a flat stroke in the muted colour on every figure
// cell of a row that will never have a number; this is a pictograph, in the
// Actual cell only, on a row that will. Each carries its own tooltip.
//
// U+23F3, guarded by `gigi verify-pads` like NO_DATA.
AWAITING = "⏳"

// Meta.drv values. A non-zero drv means the field returns an index LEVEL and
// the percentage change has to be computed here, because the data provider
// publishes no rate variant of it. See the [Data] header for the arithmetic.
DRV_NONE = 0
DRV_MOM  = 1
DRV_YOY  = 2

// Meta.prd values: which period a release describes, relative to the date it
// is released. It decides two things from one rule: the label the table
// appends to the name - "Retail Sales (MoM) (Aug)" - and where the figure is
// READ, which is where TradingView dates that period (see [Actuals]). See
// [Data].
PRD_NONE             = 0    // no label; read at the release
PRD_PREV_MONTH       = 1    // the month before the release
PRD_PREV_QUARTER     = 2    // the quarter before the release
PRD_CURRENT_MONTH    = 3    // the release month - surveys
PRD_LAGGED_MONTH     = 4    // the latest month ended four weeks before
PRD_WEEK_BEFORE_LAST = 5    // no label; the week ending the Saturday before last
PRD_WITHHELD         = 6    // no label, and no figure shown
PRD_NEAREST_MONTH    = 7    // the month whose end is nearest the release
PRD_WEEK_TO_FRIDAY   = 8    // no label; the week ending the Friday before
PRD_WEEK_TO_SATURDAY = 9    // no label; the week ending the Saturday before
PRD_RELEASE_DAY      = 10   // no label; dated 00:00 UTC on the release's day

// Ev.prdOv, the occurrence record's eleventh character: THIS release's period,
// overriding the rule above for that release alone. Counted back from the
// release's own month - 1 is the month it falls in, 2 the month before - so it
// depends on nothing but the date beside it in the record.
//
// It exists because PRD is a rule, and a rule is right about a release only
// while its publisher behaves. Nine releases in this build do not: a postponed
// month published beside the next one's, an early-January release of November's
// index, and a report left a month behind by the 2025 US shutdown for half a
// year. On each of those rows the rule names the wrong month, which decides
// both the label and where the figure is read, and nothing about the row looks
// wrong. Every override is written from its publisher's own statement of the
// reference period and from nothing else.
PRD_OVERRIDE_NONE    = 0    // no override: the key's PRD rule decides

DAY_MS  = 86400000

// A survey of the current month released in the first COUPLE OF DAYS of a
// month describes the month just ended. Tokyo's September CPI comes out on
// 2 October and its April CPI on 1 May; a label worked out from the release
// month would call them October and May, and the figure would be read a
// month late.
//
// The value is measured, not chosen: C19 checked it against 87 releases whose
// publishers state the period they describe - Michigan's preliminary survey
// (24), DG ECFIN's flash consumer confidence (36), Tokyo CPI (15) and the NAHB
// index (12). Two is the only value that fits all of them. It was seven until
// then, set from Tokyo CPI alone, and it labelled Michigan a month early
// whenever that survey came out on the 3rd to the 6th of its own month.
CURRENT_MONTH_FIRST_WEEK = 2

// PRD_NEAREST_MONTH describes the month the day this many days before the
// release falls in: the month whose end is nearest. Half a month, so it holds
// for any release within two weeks of its month's end. Its two events sit one
// day before to eight days after: Eurostat's flash inflation estimate, whose
// calendar states the month (31 October 2025 is October, 7 January 2026 is
// December - 24 of 24), and ADP, whose month FRED's record shows (30 September
// 2026 is September, 4 November October). Both are checked on every build.
NEAREST_MONTH_DAYS = 15

// PRD_LAGGED_MONTH describes the latest month that ended at least this many
// days before the release. Fitted in C16 to every published date of the
// eleven events that carry it: JOLTS on 30 September is August, because
// August ended thirty days earlier; JOLTS on 1 September is July. Canadian
// retail on 24 September is July too - August ended only 24 days before -
// and JOLTS on 29 October is September, 29 days after. Any value from 25 to
// 29 fits all of them; four weeks sits inside that range with room either side.
LAGGED_MONTH_DAYS = 28

// A quarterly release in the first eleven days of a quarter describes the
// quarter BEFORE the one that has just ended. No economy here publishes a
// quarter that fast - the quickest, New Zealand's CPI and China's GDP, come 17
// days after - so a release that early is a late estimate. The US GDP third
// estimate for Q4 2025 came on 9 April 2026, after the shutdown, and was
// labelled Q1 until C15. Checked against all 138 quarterly releases in the
// build: this changes that one label and no other.
QUARTER_LATE_DAYS = 11

// US releases from October 2025 through 5 May 2026 whose period is counted
// back from the release - PRD 1, 2 and 4 - carry NO period label and show NO
// figure.
//
// The federal shutdown that began on 1 October 2025 delayed and merged US
// releases for months afterwards: the payrolls report published on 20 November
// covered September, and one December report covered October and November
// together. A label worked out from the release date would read "(Oct)" on
// September's data, which is wrong in the way that looks right - and since
// C16 the label also says where the figure is read, so the figure would be the
// wrong month's too. No label and no figure is the honest answer. The dates
// themselves are the published ones and are unchanged.
//
// The gap ended at March 2026 until C16. FRED's first-print records show the
// catch-up ran later than that: retail sales until 1 April, PCE until 9 April,
// and new home sales until 5 May, which published February and March
// together. Outside this gap, all 22 US series with such a rule read their
// rule's period on every release FRED records. Surveys of the current month were
// never delayed - the Philadelphia and New York Fed surveys match on all 24
// releases - so the gap does not touch them.
PRD_GAP_US_FROM = timestamp("America/New_York", 2025, 10, 1, 0, 0)
PRD_GAP_US_TO   = timestamp("America/New_York", 2026, 5, 6, 0, 0)

// Ev.flags bits. Only one bit is defined, so equality tests against it are
// correct today. Pine has no bitwise AND, so when a second flag is added the
// tests must switch to arithmetic extraction rather than equality.
FLAG_ALL_DAY = 1                                 // all-day or tentative

// -- Padding characters -----------------------------------------------------
// Fixed-width spaces used to align the settings panel. They are declared with
// bare assignment from a string literal on purpose: that is what makes them
// `const string`, and input() titles will not accept anything weaker.
//
// All three are INVISIBLE in an editor and every one of them looks exactly
// like a plain ASCII space. Editors, terminals, copy-paste and heredocs
// silently normalise them, which breaks panel alignment with no visible
// diff and no compile error.
//
//   PAD_W  U+2007  FIGURE SPACE        - width of a digit
//   PAD_M  U+2005  FOUR-PER-EM SPACE   - a quarter of an em
//   PAD_N  U+200A  HAIR SPACE          - the narrowest space there is
//
// `gigi verify-pads` asserts the codepoints, and `gigi assemble` refuses to
// run if they have drifted. Do not retype these lines by hand.
PAD_W = " "
PAD_M = " "
PAD_N = " "
//#endregion [Meta]

//#region [Data]
// ---------------------------------------------------------------------------
// THE DATA MOVED. It lives in the companion library, imported at the top of
// [Meta] and reached through the `cal.` prefix:
//
//     cal.monthChunk(y, m)   packed occurrence records for one UTC month
//     cal.keyTable()         event metadata, one row per event
//     cal.buildStamp()       when the data was generated, UTC milliseconds
//     cal.horizon()          [start, end] of the generated range
//
// It is not a tidiness split. An indicator's own compiled form is capped at
// roughly 100,000 tokens (CE10117) and the schedule alone exceeds it; an
// imported library draws from a separate budget of up to 1,000,000. See
// ARCHITECTURE section 1, and section 3 for why this region marker survives an
// empty region.
//
// The wire format is documented in full in the library, which is where a
// reader looking for it will be.
// ---------------------------------------------------------------------------
//#endregion [Data]

//#region [Types]
// ---------------------------------------------------------------------------
// The two records the whole script works in.
//
// `Ev` is one dated occurrence, decoded from a 10-char record. It is
// deliberately tiny: there are thousands of them and they are all built on
// bar 0.
//
// `Meta` is the metadata for an event type, decoded once from the key table
// and shared by every occurrence of that event.
// ---------------------------------------------------------------------------

type Ev
    int ts        // absolute release time, UTC milliseconds
    int key       // index into the Meta array
    int impact    // 0 holiday, 1 low, 2 medium, 3 high, 4 critical
    int flags     // bit 0: all-day or tentative (no published clock time)
    int prdOv     // per-release period override; 0 = use the key's PRD rule

type Meta
    string name   // display name, at most 40 chars
    string region // US EU GB JP AU NZ CA CH CN XX
    string cat    // POL INF LAB GRO HOU SEN ENE AGR POS AUC MKT
    string tvf    // request.economic() field code, empty if no series exists
    string unit   // display suffix: % K M B T Bcf kbbl idx or empty
    int    dec    // decimals to render, 0-3
    int    pol    // 1 higher is bullish, -1 inverted, 0 neutral
    float  scl    // divisor applied to the raw series value; 0 = not yet measured
    int    drv    // 0 none, 1 show MoM % change, 2 show YoY % change
    int    prd    // 0 none, 1 previous month, 2 previous quarter, 3 current month
    string desc   // plain-English explanation, shown on hover. May be empty.
//#endregion [Types]

//#region [Decode]
// ---------------------------------------------------------------------------
// Unpacking. Every function here runs exactly once, on bar 0.
// ---------------------------------------------------------------------------

// Decode a fixed-width base36 integer.
//
// The input is machine-generated and validated before it ships, so every
// character is guaranteed to be in BASE36; there is no error path to take.
//
// The parameter is `encoded` rather than the obvious `text` because `text` is
// a reserved Pine namespace. See the note above decodeKeys.
base36ToInt(string encoded) =>
    int total = 0
    int width = str.length(encoded)
    if width > 0
        for i = 0 to width - 1
            total := total * 36 + str.pos(BASE36, str.substring(encoded, i, i + 1))
    total

// Parse the key table into an array indexed by key.
//
// An array rather than a map: the key in every occurrence record IS the
// index, so lookup is a direct offset with no hashing. The generator emits
// rows in index order, which is what makes push-in-order correct.
//
// The key table is '|' delimited by design and split is the right tool for
// it. The 10-char occurrence records are the opposite case and are read with
// str.substring only - see decodeMonth.
//
// NAMING: the parameter is `keyRows`, not `table`. Pine reserves a large flat
// namespace - `table`, `text`, `hour`, `minute`, `position`, `size` and many
// more are all built-ins - and shadowing one is a compile error that only
// reports the first offender. `gigi lint-pine` checks the whole file at once.
decodeKeys(string keyRows) =>
    array<Meta> out = array.new<Meta>()
    if str.length(keyRows) > 0
        array<string> rows = str.split(keyRows, ROW_SEP)
        int rowCount = array.size(rows)
        if rowCount > 0
            for i = 0 to rowCount - 1
                string row = array.get(rows, i)
                if str.length(row) > 0
                    array<string> f = str.split(row, KEY_SEP)
                    // Twelve fields, or eleven from library version 1 - see
                    // KEY_FIELDS. DESC is last in both, so it is read from
                    // the end; PRD exists only in the longer shape.
                    int fieldCount = array.size(f)
                    if fieldCount == KEY_FIELDS or fieldCount == KEY_FIELDS - 1
                        array.push(out, Meta.new(
                             name   = array.get(f, 1),
                             region = array.get(f, 2),
                             cat    = array.get(f, 3),
                             tvf    = array.get(f, 4),
                             unit   = array.get(f, 5),
                             dec    = int(str.tonumber(array.get(f, 6))),
                             pol    = int(str.tonumber(array.get(f, 7))),
                             scl    = str.tonumber(array.get(f, 8)),
                             drv    = int(str.tonumber(array.get(f, 9))),
                             prd    = fieldCount == KEY_FIELDS
                                  ? int(str.tonumber(array.get(f, 10))) : PRD_NONE,
                             desc   = array.get(f, fieldCount - 1)))
    out

// Append one month's occurrences to `out`.
//
// Records are read by offset, never by splitting: a chunk is the bare
// concatenation of 10-char records with no delimiter to split on.
//
// ORDERING, precisely. The generator sorts records ascending by the DDHHMM
// characters as written, and this function must never re-sort - doing that
// here would mean sorting thousands of events on bar 0.
//
// One consequence is worth knowing before relying on the order: an all-day
// event is written with HHMM = 9999, which sorts it AFTER every timed event
// on the same day, while it decodes to 00:00 UTC. So appending months in
// order gives an array sorted by (day, time-as-written) - not one that is
// strictly monotonic in `ts`.
//
// For display that is the order you want, an all-day row belonging at the end
// of its day. For anything that walks the array expecting monotonic time,
// compare on `ts` rather than assuming position.
//
// The record's LAST character is the per-release period override, and it is
// last for exactly this reason: the generator sorts on the first nine
// characters, so the field can never affect the order.
decodeMonth(string chunk, int y, int m, array<Ev> out) =>
    int length = str.length(chunk)
    // Integer division of a char count can land off a record boundary on a
    // malformed chunk; flooring keeps the loop inside the string.
    int count = int(math.floor(length / REC_LEN))
    if count > 0
        for i = 0 to count - 1
            int at = i * REC_LEN
            int dayUtc = int(str.tonumber(str.substring(chunk, at,     at + 2)))
            string hhmm =         str.substring(chunk, at + 2, at + 6)
            int key = base36ToInt(str.substring(chunk, at + 6, at + 9))
            int impact = int(str.tonumber(str.substring(chunk, at + 9, at + 10)))
            // The eleventh character: this release's own period, overriding
            // the key's PRD rule. 0 on nearly every record. See referencePeriod.
            int prdOv = base36ToInt(str.substring(chunk, at + 10, at + 11))

            // `hourUtc` / `minuteUtc`, because bare `hour` and `minute` are
            // built-in Pine series variables and cannot be shadowed.
            bool allDay = hhmm == ALL_DAY
            int hourUtc   = allDay ? 0 : int(str.tonumber(str.substring(hhmm, 0, 2)))
            int minuteUtc = allDay ? 0 : int(str.tonumber(str.substring(hhmm, 2, 4)))

            array.push(out, Ev.new(
                 ts     = timestamp("UTC", y, m, dayUtc, hourUtc, minuteUtc, 0),
                 key    = key,
                 impact = impact,
                 flags  = allDay ? FLAG_ALL_DAY : 0,
                 prdOv  = prdOv))

// Group the integer part of a rendered number: 1801 -> 1,801.
//
// Continuing Jobless Claims prints 1801K, which is four digits a reader has to
// count. Grouping is applied to the INTEGER part only - the fractional part of
// 6.74T must not acquire separators.
groupDigits(string rendered) =>
    string out = rendered
    int dot = str.pos(rendered, ".")
    string whole = dot >= 0 ? str.substring(rendered, 0, dot) : rendered
    string rest  = dot >= 0 ? str.substring(rendered, dot) : ""
    bool negative = str.startswith(whole, "-")
    string digits = negative ? str.substring(whole, 1) : whole
    if str.length(digits) > 3
        string grouped = ""
        int length = str.length(digits)
        for i = 0 to length - 1
            grouped := grouped + str.substring(digits, i, i + 1)
            int remaining = length - 1 - i
            if remaining > 0 and remaining % 3 == 0
                grouped := grouped + ","
        out := (negative ? "-" : "") + grouped + rest
    out

// A number with exactly `dec` decimals, grouped: 4 -> "4.0", 6743.03 -> "6,743".
//
// FIXED decimals, not trimmed. Until C21 the pattern was "#.#", which drops a
// trailing zero: Catalyst printed 4% and 3% where the publisher prints 4.0%
// and 3.0%, and a reader takes a missing decimal for a rounded figure.
// "0.0" keeps it, and keeps the leading zero of 0.5 that "#.0" would drop.
fixedFormat(int dec) =>
    switch dec
        0 => "0"
        1 => "0.0"
        2 => "0.00"
        => "0.000"

fmtFixed(float value, int dec) =>
    groupDigits(str.tostring(value, fixedFormat(dec)))

// A figure exactly as its cell prints it, as a number: the divisor applied,
// then rounded by the same format the cell uses - "0.50B" is 0.5, "2.9%" is
// 2.9. Derived rates are already percentages and take no divisor. C23: the
// Change column is worked out from these, so it always adds up on screen.
shownNumber(float value, Meta m) =>
    float scaled = m.drv == DRV_NONE and m.scl > 0 ? value / m.scl : value
    na(value) ? na : str.tonumber(str.tostring(scaled, fixedFormat(m.dec)))

// Render a raw series value for display.
//
// The divisor is the whole point. request.economic() returns unscaled units:
// payrolls arrive as 57000, not 57, and EIA crude as -7170000 barrels. `scl`
// carries the per-event divisor, so 57000 with scl 1000 and unit K renders
// as "57K".
//
// Suffix convention: %, K, M, B and T attach directly to the number; Bcf and
// kbbl take a space; `idx` is a marker meaning "this is an index level, not
// a rate" and prints no suffix at all.
fmtValue(float raw, Meta m) =>
    string out = ""
    if not na(raw)
        float scaled = m.scl > 0 ? raw / m.scl : raw
        out := fmtFixed(scaled, m.dec)
        // Two independent ifs, not if/else-if. Both arms of an if/else must
        // type-agree in Pine even when the value is discarded, and an
        // else-if chain with no final else leaves a void arm against string
        // ones. The two conditions are mutually exclusive by construction.
        if m.unit == "%" or m.unit == "K" or m.unit == "M" or m.unit == "B" or m.unit == "T"
            out := out + m.unit
        if m.unit == "Bcf" or m.unit == "kbbl"
            out := out + " " + m.unit
    out
//#endregion [Decode]

//#region [Inputs]
// ---------------------------------------------------------------------------
// The settings panel. Five sections, ARCHITECTURE section 5.
//
// ALIGNMENT IS APPLIED, AND THE UNITS ARE MEASURED RATHER THAN ASSUMED.
//
//   W = 18 device px    U+2007 FIGURE SPACE
//   M =  7 device px    U+2005 FOUR-PER-EM SPACE
//   N =  1 device px    U+200A HAIR SPACE
//
// All alignment figures here are DEVICE px on a 2x display. The method doc
// quotes 18/8/3, which is numerically close but in the wrong unit - those are
// device px on this display, not CSS px, and mixing the two is what made the
// first padding round land short.
//
// The units were solved, not fitted: a second screenshot with known padding
// applied gives `landing = floor + padding` on five rows, and the three
// unknowns fall out of it consistently every time.
//
// PADDING CAN ONLY PUSH A WIDGET RIGHT, so a section's anchor is always its
// LARGEST floor. A row sitting left of another can never be the anchor - it is
// the one that gets padded out to meet it.
//
// Anchors: DISPLAY 224 (Time Format) - TABLE 205 (the Actual / Previous /
// Change / Type row). The three characters live in [Meta] and are invisible in
// an editor; `gigi verify-pads` asserts their codepoints on every assemble.
//
// FOUR RULES THIS REGION OBEYS:
//
//   1. Pad only the FIRST title of an inline row. Later titles are "" unless
//      the widget is a checkbox, where the title is the label.
//   2. No mid-row labels. Their meaning goes into the row tooltip.
//   3. One tooltip per row GROUP, on the last input of the group's last row.
//   4. Checkboxes keep their labels.
//
// RULE 1 HAS ONE EXCEPTION, IN FILTERS. A checkbox grid cannot be aligned by
// padding first titles alone: every later checkbox lands immediately after the
// preceding label, so column 2 is positioned by the WIDTH OF COLUMN 1'S TEXT,
// and "USD" and "JPY" are not the same width in a proportional font. There the
// labels are padded column by column to a common width, because the goal is a
// grid rather than a single anchor. The last column needs none.
//
// No input.session anywhere: about 161 CSS px, the largest width trap there
// is. `input.time` is close behind - it renders a date picker AND a time
// picker - which is why From and To are on separate rows rather than sharing
// one as first drawn. Two of them plus two titles plus a tooltip does not fit
// 764 device px, and a wrapped row is worse than an extra one.
//
// ONE NON-INLINE TITLE. Non-inline titles share a column sized to the widest
// of them, so each one added couples the whole panel's alignment to another
// string. "Mode" is the only one. Anything added later must be inline.
// ---------------------------------------------------------------------------

// Section headers, each with its own alignment anchor.
//
// FILTERS says CUSTOM MODE ONLY in the header because sixteen greyed
// checkboxes with no explanation read as a broken panel rather than as an
// inactive one.
GRP_DISPLAY = "DISPLAY"
GRP_IMPACT  = "NEWS IMPACT"
GRP_FILTERS = "FILTERS — CUSTOM MODE ONLY"
GRP_TABLE   = "TABLE"

// -- Tooltip copy -----------------------------------------------------------
//
// Held as constants rather than written inline: an input() tooltip needs a
// const string and concatenated literals are const, the declarations below
// stay readable, and the copy can be diffed against ARCHITECTURE 5.7 in one
// place. Written for a reader who does not know what a PMI is. "\n" is a line
// break, "\n\n" a blank line between ideas.

TT_MODE =
     "How the calendar decides which events to show.\n\n" +
     "1. Auto — matches the symbol on your chart. EURUSD brings up US and Euro Area releases, gold brings up US releases and trader positioning, crude oil adds energy reports. Dollar pairs and US stock indices also get the weekly crude oil inventories report, the one energy release that moves them.\n\n" +
     "2. Show everything — every event in the database, no filtering.\n\n" +
     "3. Custom — you choose the currencies and categories yourself in the rows below.\n\n" +
     "The Currencies and Categories rows only do anything in Custom mode."

TT_TIMEZONE =
     "The clock every time in this calendar is shown in.\n\n" +
     "This script cannot read your chart's timezone setting — TradingView does not expose it to indicators — so pick one here if your chart is not on exchange time.\n\n" +
     "New York is the default, because that is the clock almost every economic release is quoted in — an 08:30 US release reads as 08:30. Exchange follows the symbol instead, so the same release shows as 07:30 on a CME futures chart.\n\n" +
     "Times are stored in UTC and converted only when displayed, so daylight saving is handled for you."

TT_TIME_FORMAT =
     "Whether times read as 14:30 or 2:30 PM.\n\n" +
     "This changes the table and the countdown only. It does not change which events are shown."

TT_WINDOW =
     "How much of the calendar to load, as a calendar period around today.\n\n" +
     "Every choice spans past AND future. On a Friday morning, This Week means Monday through Sunday — the releases already out this week as well as the ones still to come. Next Week is the seven days after that, Monday through Sunday. Next Month is the whole of the following month, the 1st through its last day.\n\n" +
     "Shorter is faster. This Year loads about twelve months and takes noticeably longer to start up.\n\n" +
     "Custom lets you set an exact range in the two rows below.\n\n" +
     "In Bar Replay every preset, the now line and the countdown still follow today's date - TradingView gives a script no way to tell Replay from a market that is simply closed. Set Show to Custom to list the dates you are replaying.\n\n" +
     "WHY THE LONG PRESETS EXIST. A TradingView table cannot scroll, so the table always lists the events nearest to now and no preset changes that. What the longer ones give you is the COUNT — the header says how many events fall in the whole period — and a starting point: see that This Quarter holds 146, then set Show to Custom and pick the fortnight you actually care about."

TT_CUSTOM =
     "The exact range to list, used only when Show is set to Custom.\n\n" +
     "The range runs from the From date and time to the To date and time, hours included. The defaults, 1 January 2026 18:00 to 1 January 2027 17:00 New York time, cover a year of the futures trading day, which opens at 18:00 and closes at 17:00 New York time.\n\n" +
     "The date and time boxes use your chart's timezone. Set the chart and the Timezone above to the same zone, so the hours in the boxes and in the table's top line agree.\n\n" +
     "From must not be after To. TradingView's date picker can land a month out when you click a day, so if the table lists nothing, check the month in both boxes - the table names both. The table's top line always states the range it is showing.\n\n" +
     "The schedule built into this script covers roughly two years back and up to one year forward - less for events whose agency has not published that far yet. A date outside that range is clamped to it, and the table says so rather than quietly showing nothing.\n\n" +
     "These two rows do nothing unless Show is Custom."

TT_IMPACT =
     "Which releases are big enough to show.\n\n" +
     "1. Critical — moves the market on its own. Interest rate decisions, Non-Farm Payrolls, CPI.\n\n" +
     "2. High — reliably tradeable. Retail sales, PMIs, GDP.\n\n" +
     "3. Medium — worth knowing about, rarely moves price by itself.\n\n" +
     "4. Low — background detail.\n\n" +
     "5. Holiday — a market closure or bank holiday, not a data release. It is blue rather than a fainter shade because it is a different kind of row, not a quieter one.\n\n" +
     "Red through white is a heat scale: the hotter the colour, the bigger the release. Each level's colour is fixed, and the circle you see here is the same colour as that level's dot in the table."

TT_CURRENCIES =
     "Which country's releases to show, labelled by that country's currency.\n\n" +
     "USD covers United States releases, EUR the Euro Area, GBP the UK, and so on.\n\n" +
     "Two things worth knowing:\n\n" +
     "1. This also filters commodity reports, because they have a home country. US crude oil inventories sit under USD.\n\n" +
     "2. These boxes only do anything when Mode is set to Custom."

TT_CATEGORIES =
     "The kind of event.\n\n" +
     "1. Economy — interest rates, inflation, jobs, growth, housing and sentiment.\n\n" +
     "2. Energy — crude oil and natural gas inventories, and OPEC meetings.\n\n" +
     "3. Crops — US Department of Agriculture reports such as WASDE, crop progress and grain stocks.\n\n" +
     "4. Bonds — government bond auctions.\n\n" +
     "5. Market — quad witching and exchange holidays. Not data releases, but they change how the market behaves that day.\n\n" +
     "6. Positioning — the weekly US Commitment of Traders report, which shows how the largest traders are positioned.\n\n" +
     "These boxes only do anything when Mode is set to Custom."

TT_TABLE_SHOW =
     "The summary table.\n\n" +
     "1. First box — turns it on.\n\n" +
     "2. Which corner it sits in.\n\n" +
     "3. Text size.\n\n" +
     "The table lists the period you picked under Show, trimmed to a readable number of rows around the now divider, so a long period does not produce a table taller than the screen.\n\n" +
     "If it covers part of your chart, move it or shrink it here rather than switching it off."

TT_TABLE_COLUMNS =
     "Extra columns in the table.\n\n" +
     "1. Actual — the released figure. Stays blank until the release has actually happened.\n\n" +
     "2. Previous — the figure from the release before this one. A dash means there is nothing comparable to show: a later estimate of the same quarter or month, whose earlier estimate TradingView does not keep.\n\n" +
     "3. Change — the difference between the two, coloured green or red. Hover any value for what it means.\n\n" +
     "4. Type — which group the event belongs to, so an inventories report reads as Energy rather than just USD.\n\n" +
     "Change takes direction into account. A rise in unemployment shows red even though the number went up.\n\n" +
     "THERE IS NO FORECAST COLUMN, and Change is not a comparison against one. TradingView publishes no consensus figure to an indicator, and a forecast baked in when this script was last updated would be wrong for every release after that date. A stale forecast is worse than none, because it looks authoritative."

TT_TABLE_ROWS_COUNT =
     "How many events the table lists at once.\n\n" +
     "This counts event rows only. The line with the period and the event count, the column titles, the now divider, the Next line and any notice are not events and do not use up your setting.\n\n" +
     "A TradingView table cannot scroll, so if your window holds more events than this the extra ones are not reachable — the header says how many of them are shown so the gap is visible rather than silent.\n\n" +
     "Rows are centred on the now divider, weighted towards what is coming: roughly one third already released, two thirds still to come. If the window holds fewer events than this, the table simply shrinks.\n\n" +
     "A table taller than the chart is cut off by TradingView at the edge away from its corner, and the script cannot tell how tall your chart is. So in the two bottom corners, when the table is long - more lines than a laptop's chart holds at this text size - the column titles are shown again under the last event, where they stay in view. To see the whole table, lower Rows or the table size. The top line and any notice sit on the corner's edge, so they are never the part that is cut."

TT_WARNINGS =
     "Notices, when the table cannot show you everything. They sit inside the table, as full-width rows on the edge nearest its corner - the edge TradingView never cuts off - so they cannot cover the table or be cut off with it.\n\n" +
     "They appear only when there is something to say. Five things can trigger one: the table lists fewer events than the period holds; your custom From date is after To; your custom dates reach outside the schedule built into this script; more event types are in view than TradingView allows live figures for; or released rows have no bar after them on this chart.\n\n" +
     "Each says what happened and what to change. They show even with the table switched off. Turn this off if you would rather work it out from the table on your own."

TT_ALERT =
     "How far ahead of a release the alert fires.\n\n" +
     "To use it: click the alarm-clock icon in TradingView's top toolbar and choose this indicator as the Condition. There is no named condition to pick - the script sends its own message, and that message names the release, its currency, its impact level and the time it is due.\n\n" +
     "Only events that pass the filters above will fire, so narrow the currencies and impact levels first and you will only be told about releases you actually care about. The alert reports what is coming — it never suggests a direction or a trade."

TT_TABLE_HEADER =
     "1. Background colour of the table's top row.\n\n" +
     "2. Text colour of the table's top row."

TT_TABLE_ROWS =
     "1. Background colour of the event rows.\n\n" +
     "2. Text colour of the event rows.\n\n" +
     "3. The now divider. Everything above it has already been released; everything below is still to come."

// -- DISPLAY ----------------------------------------------------------------
// Anchor 224, set by "Time Format".

// The only non-inline input. Padding it widens the shared non-inline column,
// which is harmless precisely because it is the only one.
scopeMode = input.string("Auto", "Mode" + PAD_W + PAD_W + PAD_W + PAD_N + PAD_N + PAD_N + PAD_N + PAD_N,
     options = ["Auto", "Show everything", "Custom"],
     group   = GRP_DISPLAY,
     tooltip = TT_MODE)

// Row "tz". ONE dropdown of named zones, not two.
//
// The pair it replaces offered "Chart" and "Exchange" as if they differed.
// They cannot: Pine has no accessor for the chart's display timezone, so both
// resolved to the exchange's and the choice was fiction. Named zones are the
// honest version - the user picks explicitly, and Exchange stays the default
// because it matches the chart for anyone who has not changed theirs.
tzSource = input.string("New York", "Timezone" + PAD_W + PAD_M + PAD_N + PAD_N + PAD_N + PAD_N + PAD_N,
     options = ["Exchange", "UTC", "New York", "Chicago", "London",
                "Frankfurt", "Tokyo", "Sydney"],
     inline  = "tz",
     group   = GRP_DISPLAY,
     tooltip = TT_TIMEZONE)

// Row "tf". Sets this section's anchor, so it takes no padding.
timeFormat = input.string("24 hour", "Time Format",
     options = ["24 hour", "12 hour (AM/PM)"],
     inline  = "tf",
     group   = GRP_DISPLAY,
     tooltip = TT_TIME_FORMAT)

// Row "sw". ONE window control, replacing the three that overlapped -
// a past window, a forward window, and the table's own range.
//
// Every preset is a WHOLE CALENDAR PERIOD - the current one, or for Next Week
// and Next Month the one after it - which is how a trader actually thinks: on
// Friday morning "this week" means Monday through Sunday, including what has
// already printed. One semantic across all of them leaves nothing to explain.
timeWindow = input.string("This Week", "Show" + PAD_W + PAD_W + PAD_W + PAD_W + PAD_W + PAD_N + PAD_N,
     options = ["Today", "This Week", "Next Week", "This Month", "Next Month",
                "This Quarter", "This Year", "Custom"],
     inline  = "sw",
     group   = GRP_DISPLAY,
     tooltip = TT_WINDOW)

// Rows "cf" and "ct". Separate rows because input.time renders a date picker
// AND a time picker; two of them on one row does not fit the dialog.
//
// The defaults are BARE EPOCH MILLISECONDS, not timestamp() calls.
// input.time wants a `const int` and timestamp() returns a `simple int` -
// close enough to read as interchangeable and rejected with CE10123. A
// literal is the only form that is const by construction.
//
//   1767308400000 = 2026-01-01T23:00:00Z = 1 Jan 2026 18:00 New York
//   1798840800000 = 2027-01-01T22:00:00Z = 1 Jan 2027 17:00 New York
//
// THE HOURS COUNT, since C22 (the author's decision of 4 October): the range
// is exactly the two instants the boxes show. C21 used whole days and ignored
// the time boxes. The defaults follow the futures trading day - it opens at
// 18:00 New York and closes at 17:00 - over one year. The boxes show an
// instant in the CHART's timezone, so they read 18:00 and 17:00 only on a
// chart set to New York; on a Tokyo chart the same defaults read 08:00 on
// 2 January 2026 and 07:00 on 2 January 2027. The tooltip says to set the
// chart and the panel's Timezone to the same zone.
//
// ON THE 1ST OF A MONTH, NOT THE 31ST (C24). Until C24 the defaults were
// 31 December 2025 and 2026. TradingView's date picker appears to change the
// month first and the day second, so the first date picked from a box holding
// the 31st went through a day that does not exist: 31 September became
// 1 October, and the clicked 27th landed on 27 October. It happened once -
// after that the box no longer held a 31st. A default on the 1st exists in
// every month.
//
// They are only placeholders: the row does nothing unless Show is Custom, and
// the range is clamped to the shipped horizon either way.
customFrom = input.time(1767308400000, "From" + PAD_W + PAD_W + PAD_W + PAD_W + PAD_W + PAD_M,
     inline = "cf", group = GRP_DISPLAY,
     active = timeWindow == "Custom")
customTo = input.time(1798840800000, "To" + PAD_W + PAD_W + PAD_W + PAD_W + PAD_W + PAD_W + PAD_W + PAD_N + PAD_N + PAD_N + PAD_N + PAD_N,
     inline = "ct", group = GRP_DISPLAY,
     active = timeWindow == "Custom",
     tooltip = TT_CUSTOM)

// -- NEWS IMPACT ------------------------------------------------------------
// NO PADDING IN THIS SECTION. There is nothing after the label to align.
//
// No colour inputs either. Pine has no circular colour input, so the panel
// names each tier with a coloured-circle EMOJI - and no colour input can
// change what an emoji looks like. A swatch beside one would be a control that
// cannot alter the thing it appears to control. The colours are constants in
// [Meta], and one constant drives the chart marker, the line and the table dot.
//
// RED, ORANGE, YELLOW, WHITE IS A HEAT RAMP. The tiers are an intensity
// ladder, so the colours descend one: there is no circle emoji between orange
// and yellow, and pinning yellow to the bottom rung would force an odd hue
// into the middle.
//
// Holiday is BLUE because it is not a rung on that ladder at all - a market
// closure is a different kind of row, not a fainter release - and it defaults
// ON, because a closure changes how every other event that day behaves.
//
// All five codepoints are asserted by `gigi verify-pads` on every assemble:
// four are above U+FFFF and are exposed to exactly the silent substitution the
// padding characters are.
//
// Never greyed: "Show everything" bypasses currency and category, not impact.
impactCritical = input.bool(true,  "🔴 Critical", inline = "im1", group = GRP_IMPACT)
impactHigh     = input.bool(true,  "🟠 High",    inline = "im2", group = GRP_IMPACT)
impactMedium   = input.bool(true,  "🟡 Medium",  inline = "im3", group = GRP_IMPACT)
impactLow      = input.bool(true,  "⚪ Low",      inline = "im4", group = GRP_IMPACT)
impactHoliday  = input.bool(true,  "🔵 Holiday", inline = "im5", group = GRP_IMPACT,
     tooltip = TT_IMPACT)

// -- FILTERS ----------------------------------------------------------------
// Alphabetical, and padded as a GRID rather than to a single anchor.
//
// Only the first title of an inline row can be padded to an anchor; every
// later checkbox lands immediately after the preceding label. So column 2 is
// positioned by the width of column 1's TEXT, and "USD" and "JPY" are not the
// same width. Each column is padded to its own widest member; the last needs
// none.
//
// Greyed unless Mode is Custom. `active` needs an input-qualified bool, which
// a comparison of an input against a literal is. A greyed input STILL HOLDS
// ITS VALUE, so [Scope] tests the mode explicitly rather than reading these.

// Currencies. Column 1 widest is AUD/CNY, column 2 widest is CAD/EUR.
regionAU = input.bool(true, "AUD", inline = "cur1",
     group = GRP_FILTERS, active = scopeMode == "Custom")
regionCA = input.bool(true, "CAD", inline = "cur1",
     group = GRP_FILTERS, active = scopeMode == "Custom")
regionCH = input.bool(true, "CHF", inline = "cur1",
     group = GRP_FILTERS, active = scopeMode == "Custom")

regionCN = input.bool(true, "CNY", inline = "cur2",
     group = GRP_FILTERS, active = scopeMode == "Custom")
regionEU = input.bool(true, "EUR", inline = "cur2",
     group = GRP_FILTERS, active = scopeMode == "Custom")
regionGB = input.bool(true, "GBP", inline = "cur2",
     group = GRP_FILTERS, active = scopeMode == "Custom")

regionJP = input.bool(true, "JPY" + PAD_M + PAD_N, inline = "cur3",
     group = GRP_FILTERS, active = scopeMode == "Custom")
regionNZ = input.bool(true, "NZD" + PAD_N + PAD_N, inline = "cur3",
     group = GRP_FILTERS, active = scopeMode == "Custom")
regionUS = input.bool(true, "USD", inline = "cur3",
     group = GRP_FILTERS, active = scopeMode == "Custom",
     tooltip = TT_CURRENCIES)

// Categories. Column 1 widest is Positioning, column 2 widest is Market.
//
// Interest rate decisions live under Economy, not Bonds. Bonds means debt
// auctions. The previous panel called the pair "Rates" and a user hunting for
// an FOMC decision had to guess which group held it.
groupBonds   = input.bool(true, "Bonds" + PAD_W + PAD_W + PAD_W + PAD_M,
     inline = "cat1", group = GRP_FILTERS, active = scopeMode == "Custom")
groupCrops   = input.bool(true, "Crops" + PAD_M + PAD_N + PAD_N + PAD_N + PAD_N + PAD_N,
     inline = "cat1", group = GRP_FILTERS, active = scopeMode == "Custom")
groupEconomy = input.bool(true, "Economy", inline = "cat1",
     group = GRP_FILTERS, active = scopeMode == "Custom")

groupEnergy  = input.bool(true, "Energy" + PAD_W + PAD_W + PAD_M + PAD_M + PAD_N,
     inline = "cat2", group = GRP_FILTERS, active = scopeMode == "Custom")
groupMarket  = input.bool(true, "Market", inline = "cat2",
     group = GRP_FILTERS, active = scopeMode == "Custom")

groupPositioning = input.bool(true, "Positioning", inline = "cat3",
     group = GRP_FILTERS, active = scopeMode == "Custom",
     tooltip = TT_CATEGORIES)

// -- TABLE ------------------------------------------------------------------
// Anchor 205, set by the Actual / Previous / Change / Type row. That floor is
// PREDICTED rather than measured - a checkbox row's widgets are too narrow for
// the edge detector - so it is the least certain number in this region.
// Everything else here is measured.
//
// The table has no range of its own. It lists the Show window from DISPLAY,
// trimmed to a readable number of rows around the now divider.

showTable  = input.bool(true, "Show" + PAD_M + PAD_N, inline = "tb",
     group = GRP_TABLE)
tableCorner = input.string("Bottom right", "",
     options = ["Bottom right", "Bottom left", "Top right", "Top left",
                "Middle right", "Middle left"],
     inline  = "tb", group = GRP_TABLE, active = showTable)
tableScale = input.string("Small", "",
     options = ["Tiny", "Small", "Normal", "Large"],
     inline  = "tb", group = GRP_TABLE, active = showTable,
     tooltip = TT_TABLE_SHOW)

// Time, impact, currency and event are always shown; these four are optional.
// This row sets the section anchor, so it takes no padding.
colActual   = input.bool(true, "Actual",   inline = "tc", group = GRP_TABLE,
     active = showTable)
colPrevious = input.bool(true, "Previous", inline = "tc", group = GRP_TABLE,
     active = showTable)
colChange   = input.bool(true, "Change",   inline = "tc", group = GRP_TABLE,
     active = showTable)
colType     = input.bool(true, "Type",     inline = "tc", group = GRP_TABLE,
     active = showTable, tooltip = TT_TABLE_COLUMNS)

// Row "tn": how tall the table is.
//
// Pine tables have no scrollbar and no scroll API, so a window holding more
// events than fit has no way to reveal the rest. Letting the user set the
// height is the honest answer; the header then says how many of the window's
// events are actually shown.
//
// THIRTY, not fifteen. A single-currency This Week in Auto mode is typically
// ten to twenty-five events, so at thirty the common case fits entirely and
// the truncation never fires at all - which is the right default, because a
// truncated week silently hides Monday and Tuesday and the user has no way to
// tell that from a quiet week. The number counts EVENT rows only; the header,
// the divider, the Next line and the attribution are chrome and are not
// charged against it.
tableRows_ = input.string("30", "Rows" + PAD_W + PAD_W + PAD_W + PAD_W + PAD_M,
     options = ["10", "15", "20", "30", "40", "50"],
     inline  = "tn", group = GRP_TABLE, active = showTable,
     tooltip = TT_TABLE_ROWS_COUNT)

// Row "wn". A checkbox with nothing after it, so there is nothing to align and
// it takes no padding - the same shape the CHART section's Outline row had.
//
// NOT greyed by showTable. The warning panel is a separate table and stays
// useful with the main one switched off: "your custom dates are outside the
// data" is exactly the message somebody needs when their table is empty.
showWarnings = input.bool(true, "Show Warnings", inline = "wn",
     group = GRP_TABLE, tooltip = TT_WARNINGS)

// Row "al": how far ahead the alert fires.
//
// TITLED "Alert", NOT "Alert lead time", and the reason is alignment rather
// than brevity. Non-inline titles share one column and inline rows are padded
// to their section's widest floor; "Alert lead time" renders about 241 device
// px against this section's 205 anchor, so it would become the new anchor and
// every other TABLE row would need repadding. The tooltip carries the meaning
// instead, which costs nothing - the row reads "Alert [15]" and the minutes
// are self-evident from the options.
alertLead = input.string("15", "Alert" + PAD_W + PAD_W + PAD_W + PAD_W + PAD_W + PAD_N + PAD_N,
     options = ["5", "15", "30", "60"],
     inline  = "al", group = GRP_TABLE,
     tooltip = TT_ALERT)

// Header and Rows land on the same anchor, so the Rows swatches sit directly
// under the Header swatches and both under the dropdowns above.
headerBg   = input.color(color.new(#1e222d, 0), "Header" + PAD_W + PAD_W + PAD_M + PAD_M + PAD_N,
     inline = "th", group = GRP_TABLE, active = showTable)
headerText = input.color(color.new(#d1d4dc, 0), "",
     inline = "th", group = GRP_TABLE, active = showTable,
     tooltip = TT_TABLE_HEADER)

rowBg      = input.color(color.new(#131722, 15), "Rows" + PAD_W + PAD_W + PAD_W + PAD_W + PAD_M,
     inline = "tw", group = GRP_TABLE, active = showTable)
rowText    = input.color(color.new(#b2b5be, 0), "",
     inline = "tw", group = GRP_TABLE, active = showTable)
rowDivider = input.color(color.new(#5A6272, 0), "",
     inline = "tw", group = GRP_TABLE, active = showTable,
     tooltip = TT_TABLE_ROWS)
//#endregion [Inputs]

//#region [Scope]
// ---------------------------------------------------------------------------
// Which events belong on THIS chart.
//
// Two things live here. autoScope() answers "what moves this symbol?" from
// syminfo alone, and passes() is the predicate every decoded event is run
// through before it is drawn.
//
// HOW SETS ARE REPRESENTED
//
// A set is a comma-delimited string with a comma on BOTH ends: ",US,EU,".
// Membership is then a plain substring search for "," + item + ",", which
// cannot produce the false positive a naive search would - ",AUS," does not
// contain ",US," - and costs no allocation. Two sets are unioned with
// setUnion(), which drops the seam. Writing them side by side would leave ",,"
// in the middle, and ",," is an EMPTY MEMBER: inSet(bag, "") searches for
// exactly that string. No event has an empty category today, which is what
// made it look harmless for four batches.
//
// Pine has no set type and building arrays for this would mean allocating on
// bar 0 and searching linearly per event. A string is smaller and faster for
// sets this size.
//
// WHY autoScope TAKES ARGUMENTS INSTEAD OF READING syminfo
//
// Reading syminfo inside would make it untestable: there would be no way to
// ask what it does with ZC1! except by loading a corn chart. Passing the four
// values in keeps it a pure function of its inputs, which is what lets the
// Python mirror check it against a table of real tickers.
// ---------------------------------------------------------------------------

// Category groups, as the settings panel names them. These are the single
// definition of what each checkbox in the Groups rows actually covers - the
// panel shows six friendly names, the key table stores eleven codes, and
// this is the one place the two are reconciled.
// POL sits under Economy rather than beside AUC. The panel promises
// "Economy - interest rates, inflation, jobs, growth, housing and sentiment"
// and "Bonds - government bond auctions", and that is the honest split: a
// rate decision is an economic release, an auction is a bond event. The
// previous grouping called the pair "Rates" and left a user hunting for an
// FOMC decision to guess which group held it.
CATS_ECONOMY     = ",POL,INF,LAB,GRO,HOU,SEN,"  // rates, inflation, jobs, growth, housing, sentiment
CATS_ENERGY      = ",ENE,"
CATS_CROPS       = ",AGR,"
CATS_BONDS       = ",AUC,"                      // government debt auctions
CATS_MARKET      = ",MKT,"                      // quarterly expiry, exchange holidays
CATS_POSITIONING = ",POS,"                      // the COT report

// Every region and category the key table can hold. Used only by the
// "Show everything" mode, which is why they are stated once here rather than
// assembled from the group constants: this set must stay complete even if
// the six panel groups are ever regrouped.
ALL_REGIONS = ",US,EU,GB,JP,AU,NZ,CA,CH,CN,XX,"
ALL_CATS    = ",POL,INF,LAB,GRO,HOU,SEN,ENE,AGR,AUC,MKT,POS,"

// Instrument families, keyed by symbol root. Ordinary data, deliberately:
// adding an instrument is adding a word to a string, not writing a branch.
//
// Both the exchange root ("CL") and whole vendor tickers ("USOIL", "NAS100")
// appear, because a CFD feed names the same exposure differently from a
// futures exchange and both must land in the same family.
ROOTS_METALS = ",XAU,XAG,XPT,XPD,GC,SI,HG,PL,PA,MGC,SIL,GOLD,SILVER,XAUUSD,XAGUSD,"
ROOTS_ENERGY = ",CL,BZ,NG,RB,HO,QM,QG,MNG,HH,MCL,WTI,BRENT,USOIL,UKOIL,NATGAS,UKOUSD,USOUSD,"
ROOTS_AGRI   = ",ZC,ZS,ZW,ZL,ZM,ZO,ZR,KE,MW,CT,SB,KC,CC,LE,HE,OJ,GF,DC,LBR,CORN,WHEAT,SOYBEAN,"
ROOTS_CRYPTO = ",BTC,ETH,SOL,XRP,ADA,DOGE,LTC,BCH,BNB,AVAX,DOT,LINK,MBT,MET,"

// Bonds and index futures, US and otherwise. A root here says WHAT the
// instrument is; HOME_* below says WHOSE economy it belongs to, and anything
// absent from HOME_* is American.
ROOTS_BONDS  = ",ZB,ZN,ZF,ZT,UB,TN,ZQ,GE,SR3,SR1," +
     "FGBL,FGBM,FGBS,FGBX,FOAT,FBTP,R,JGB,CGB,"
ROOTS_INDEX  = ",ES,NQ,YM,RTY,MES,MNQ,MYM,M2K,SPX,NDX,DJI,RUT,SPX500,US500,US30,US100,NAS100,USTEC," +
     "FDAX,MDAX,FESX,FSMI,NKD,NIY,SPI,HSI," +
     "GER40,GER30,DAX,EU50,STOXX50,EUSTX50,FRA40,ESP35,UK100,FTSE," +
     "JPN225,NIKKEI,AUS200,SWI20,HK50,CHINA50,"

// The economy an instrument belongs to, when it is not the United States.
//
// This is what stops a DAX future being scoped to US macro. Index and bond
// futures both consult it, because the question is the same for both: whose
// central bank and whose statistics move this contract? A root absent from
// every row here is American, which is the common case and needs no entry.
HOME_EU = ",FESX,FDAX,MDAX,GER40,GER30,DAX,EU50,STOXX50,EUSTX50,FRA40,ESP35," +
     "FGBL,FGBM,FGBS,FGBX,FOAT,FBTP,"
HOME_GB = ",UK100,FTSE,R,"
HOME_JP = ",NKD,NIY,JPN225,NIKKEI,JGB,"
HOME_AU = ",SPI,AUS200,"
HOME_CH = ",FSMI,SWI20,"
HOME_CN = ",HSI,HK50,CHINA50,"
HOME_CA = ",CGB,"

// CME currency futures, root to the currency they are quoted against USD.
//
// These need an explicit table rather than the FX branch's currency lookup.
// syminfo.basecurrency is not reliably populated for a futures contract, so a
// 6E chart would fall through to the fallback and show US macro only - which
// is exactly the euro trader's problem, since the ECB would be missing.
FXFUT_EUR = ",6E,M6E,E7,"
FXFUT_GBP = ",6B,M6B,J7,"
FXFUT_JPY = ",6J,M6J,MJY,"
FXFUT_AUD = ",6A,M6A,"
FXFUT_CAD = ",6C,MCD,"
FXFUT_CHF = ",6S,MSF,"
FXFUT_NZD = ",6N,"
FXFUT_MXN = ",6M,"

// The dollar index is every major at once: it is a basket, so a move in any
// of them moves it. Scoped to all nine economies rather than to the US alone.
ROOTS_DOLLAR = ",DX,MDX,DXY,USDX,DXH,"

// Currency code to region code. Only the ten regions the key table knows.
CUR_US = ",USD,"
CUR_EU = ",EUR,"
CUR_GB = ",GBP,"
CUR_JP = ",JPY,"
CUR_AU = ",AUD,"
CUR_NZ = ",NZD,"
CUR_CA = ",CAD,"
CUR_CH = ",CHF,"
CUR_CN = ",CNY,CNH,"

// Is `item` in the delimited set `bag`?
//
// The parameter is `bag` rather than the obvious `set` to stay clear of
// Pine's reserved namespace; `gigi lint-pine` checks the whole file for that
// class of collision.
inSet(string bag, string item) =>
    str.contains(bag, "," + item + ",")

// The union of two sets, without the ",," a plain concatenation leaves at the
// seam. Both arguments are sets, so `right` always starts with its own comma
// and `left` always ends with one.
setUnion(string left, string right) =>
    left + str.substring(right, 1)

// The region a currency code belongs to, or "" if it is not one we track.
currencyRegion(string code) =>
    string out = ""
    if inSet(CUR_US, code)
        out := "US"
    if inSet(CUR_EU, code)
        out := "EU"
    if inSet(CUR_GB, code)
        out := "GB"
    if inSet(CUR_JP, code)
        out := "JP"
    if inSet(CUR_AU, code)
        out := "AU"
    if inSet(CUR_NZ, code)
        out := "NZ"
    if inSet(CUR_CA, code)
        out := "CA"
    if inSet(CUR_CH, code)
        out := "CH"
    if inSet(CUR_CN, code)
        out := "CN"
    out

// A continuous-contract ticker with its suffix removed: "CL1!" -> "CL".
//
// Bounded to three characters because that is the longest suffix this form
// takes, and because an unbounded loop on bar 0 is a way to spend the
// execution budget on nothing.
//
// This is only ever a FALLBACK candidate. It happily turns "US500" into "US",
// which is why matchesFamily below tries the untouched ticker first.
stripContinuation(string symbolId) =>
    int cut = str.length(symbolId)
    for i = 1 to 3
        if cut > 0 and str.contains("0123456789!", str.substring(symbolId, cut - 1, cut))
            cut -= 1
    str.substring(symbolId, 0, cut)

// Does any spelling of this symbol appear in `bag`?
//
// Three candidates, because the same instrument arrives under three shapes
// depending on the feed: syminfo.root is authoritative for futures and empty
// for everything else, the raw ticker is what CFD feeds give, and the
// stripped form catches continuous contracts whose root is unavailable.
matchesFamily(string bag, string rootId, string symbolId, string stripped) =>
    (rootId != "" and inSet(bag, rootId))
         or inSet(bag, symbolId)
         or (stripped != "" and inSet(bag, stripped))

// The economy a non-US index or bond future belongs to, or "" if American.
homeRegion(string rootId, string symbolId, string stripped) =>
    string out = ""
    if matchesFamily(HOME_EU, rootId, symbolId, stripped)
        out := "EU"
    if matchesFamily(HOME_GB, rootId, symbolId, stripped)
        out := "GB"
    if matchesFamily(HOME_JP, rootId, symbolId, stripped)
        out := "JP"
    if matchesFamily(HOME_AU, rootId, symbolId, stripped)
        out := "AU"
    if matchesFamily(HOME_CH, rootId, symbolId, stripped)
        out := "CH"
    if matchesFamily(HOME_CN, rootId, symbolId, stripped)
        out := "CN"
    if matchesFamily(HOME_CA, rootId, symbolId, stripped)
        out := "CA"
    out

// The economy on the far side of a CME currency future, or "" if untracked.
//
// 6M is the Mexican peso, which has no events in this taxonomy, so it returns
// "" and the contract scopes to US macro alone. That is the honest answer
// rather than a silent mis-mapping.
fxFuturesRegion(string rootId, string symbolId, string stripped) =>
    string out = ""
    if matchesFamily(FXFUT_EUR, rootId, symbolId, stripped)
        out := "EU"
    if matchesFamily(FXFUT_GBP, rootId, symbolId, stripped)
        out := "GB"
    if matchesFamily(FXFUT_JPY, rootId, symbolId, stripped)
        out := "JP"
    if matchesFamily(FXFUT_AUD, rootId, symbolId, stripped)
        out := "AU"
    if matchesFamily(FXFUT_CAD, rootId, symbolId, stripped)
        out := "CA"
    if matchesFamily(FXFUT_CHF, rootId, symbolId, stripped)
        out := "CH"
    if matchesFamily(FXFUT_NZD, rootId, symbolId, stripped)
        out := "NZ"
    out

// Is this a pair between two DIFFERENT currencies this calendar tracks?
//
// The instrument's own identity, and more reliable than syminfo.type, which
// describes the VENUE rather than the instrument. GEMINI:AUDUSD is typed
// "crypto" because Gemini is a crypto exchange, and it is still the Australian
// dollar against the US dollar. Found in C10: that one symbol scoped to US
// events only, because the crypto test ran first and won.
//
// Two tracked currencies, not one, so a crypto symbol cannot pass by quoting
// in dollars: BTCUSD has base BTC, which is in no CUR_* set.
isCurrencyPair(string base, string quote) =>
    string baseRegion  = currencyRegion(base)
    string quoteRegion = currencyRegion(quote)
    baseRegion != "" and quoteRegion != "" and baseRegion != quoteRegion

// Is this any CME currency future at all, peso included?
isFxFuture(string rootId, string symbolId, string stripped) =>
    matchesFamily(FXFUT_EUR, rootId, symbolId, stripped)
         or matchesFamily(FXFUT_GBP, rootId, symbolId, stripped)
         or matchesFamily(FXFUT_JPY, rootId, symbolId, stripped)
         or matchesFamily(FXFUT_AUD, rootId, symbolId, stripped)
         or matchesFamily(FXFUT_CAD, rootId, symbolId, stripped)
         or matchesFamily(FXFUT_CHF, rootId, symbolId, stripped)
         or matchesFamily(FXFUT_NZD, rootId, symbolId, stripped)
         or matchesFamily(FXFUT_MXN, rootId, symbolId, stripped)

// The instrument family this symbol belongs to.
//
// Order matters and is not alphabetical. Metals come first because a spot
// gold symbol is typed `forex` by most feeds and carries base currency XAU -
// testing forex first would classify XAUUSD as a currency pair and show it
// Swiss CPI instead of the COT report.
//
// A pair of two tracked currencies is FX BEFORE syminfo.type is consulted, for
// the reason given at isCurrencyPair(): the type names the venue. Metals still
// come first, so XAUUSD - base XAU, in no CUR_* set anyway - is never at risk.
scopeFamily(string symbolId, string rootId, string base, string quote, string symType) =>
    string stripped = stripContinuation(symbolId)
    string family = "OTHER"

    if matchesFamily(ROOTS_METALS, rootId, symbolId, stripped) or inSet(ROOTS_METALS, base)
        family := "METALS"
    else if matchesFamily(ROOTS_ENERGY, rootId, symbolId, stripped)
        family := "ENERGY"
    else if matchesFamily(ROOTS_AGRI, rootId, symbolId, stripped)
        family := "AGRI"
    else if matchesFamily(ROOTS_BONDS, rootId, symbolId, stripped)
        family := "BONDS"
    else if matchesFamily(ROOTS_INDEX, rootId, symbolId, stripped)
        family := "INDEX"
    else if isCurrencyPair(base, quote)
        family := "FX"
    else if symType == "crypto" or matchesFamily(ROOTS_CRYPTO, rootId, symbolId, stripped) or inSet(ROOTS_CRYPTO, base)
        family := "CRYPTO"
    else if matchesFamily(ROOTS_DOLLAR, rootId, symbolId, stripped)
        family := "DOLLAR"
    else if isFxFuture(rootId, symbolId, stripped)
        family := "FXFUT"
    else if symType == "forex" and currencyRegion(base) != ""
        family := "FX"
    family

// Regions a family cares about.
//
// US appears in every one of them, including the currency crosses. That is a
// judgement, and it is deliberate: the Fed sets the price of the numeraire,
// so a EURGBP trader who cannot see an FOMC decision is missing the largest
// scheduled risk on the chart. XX (global) appears everywhere too, and the
// two events it holds - quarterly expiry and OPEC - are then admitted or
// excluded by category rather than by region.
familyRegions(string family, string base, string quote,
     string rootId, string symbolId, string stripped) =>
    string out = ",US,XX,"
    if family == "AGRI"
        // Chinese purchase and demand data moves the grain complex.
        out := ",US,CN,XX,"
    if family == "BONDS" or family == "INDEX"
        // A Bund future is not a US instrument. US stays in the set because
        // the Fed moves every bond market, but the home economy is what the
        // contract actually tracks.
        string home = homeRegion(rootId, symbolId, stripped)
        if home != ""
            out := out + home + ","
    if family == "DOLLAR"
        // A basket of every major, so every major's calendar is relevant.
        out := ALL_REGIONS
    if family == "CRYPTO"
        // Stated, not inherited from the default above, even though the value
        // is the same. A crypto asset has no home economy; what moves it on
        // this calendar is US liquidity - the Fed and US data - plus the
        // global events. Arriving here by falling through is how a
        // mis-classified AUDUSD hid: nothing looked wrong.
        out := ",US,XX,"
    if family == "FXFUT"
        string counter = fxFuturesRegion(rootId, symbolId, stripped)
        if counter != ""
            out := out + counter + ","
    if family == "FX"
        string baseRegion  = currencyRegion(base)
        string quoteRegion = currencyRegion(quote)
        if baseRegion != "" and baseRegion != "US"
            out := out + baseRegion + ","
        if quoteRegion != "" and quoteRegion != "US" and quoteRegion != baseRegion
            out := out + quoteRegion + ","
    out

// Categories a family cares about.
//
// Every family gets CATS_ECONOMY and CATS_BONDS: policy is what reprices
// everything, and an auction calendar is useful on any dollar-denominated
// instrument. What
// separates the families is the commodity group and whether positioning and
// market structure are relevant.
familyCats(string family) =>
    string core = setUnion(CATS_ECONOMY, CATS_BONDS)
    string out = setUnion(core, CATS_MARKET)
    if family == "METALS"
        // No metals category: the one metals release the calendar carried,
        // US gold reserves, never moved and was removed in C19. What moves
        // gold is US macro, Fed policy, auctions and positioning.
        out := setUnion(core, CATS_POSITIONING)
    if family == "ENERGY"
        out := setUnion(setUnion(core, CATS_ENERGY), CATS_POSITIONING)
    if family == "AGRI"
        out := setUnion(setUnion(core, CATS_CROPS), CATS_POSITIONING)
    if family == "BONDS"
        out := setUnion(setUnion(core, CATS_POSITIONING), CATS_MARKET)
    if family == "INDEX"
        // Quarterly expiry is a market-structure event and index futures are
        // exactly what it expires, so INDEX keeps CATS_MARKET and adds the
        // COT report on top.
        out := setUnion(setUnion(core, CATS_MARKET), CATS_POSITIONING)
    if family == "FX" or family == "FXFUT" or family == "DOLLAR"
        out := setUnion(core, CATS_POSITIONING)
    out

// Region and category sets derived from the chart symbol.
//
// Pure and table-driven: it reads nothing but its four arguments, so the
// Python mirror can check it against a table of real tickers without a chart.
//
// THE FALLBACK IS NOT AN ERROR PATH. Most symbols on TradingView are single
// stocks, and none of the families above will claim them. "OTHER" returns US
// macro, rates and market structure plus the global events - which is a
// defensible calendar for an equity - rather than everything (unreadable) or
// nothing (looks broken).
autoScope(string symbolId, string rootId, string base, string quote, string symType) =>
    string sym      = str.upper(symbolId)
    string rootUp   = str.upper(rootId)
    string baseUp   = str.upper(base)
    string stripped = stripContinuation(sym)
    string family   = scopeFamily(sym, rootUp, baseUp, str.upper(quote), symType)
    [familyRegions(family, baseUp, str.upper(quote), rootUp, sym, stripped),
     familyCats(family)]

// -- Beyond the categories: one energy release on dollar charts (C21) --------
//
// Auto mode scopes by category, and a currency pair or a stock index has no
// Energy category - energy reports belong on oil and gas charts. One weekly
// energy release is the exception: the EIA's
// crude oil inventories, rated High, move the dollar and US equities often
// enough that traders of both expect to see them. So on a pair with the dollar
// on either side, on a CME currency future (all quoted against the dollar),
// and on a US stock index or index future, Auto admits that one release by its
// series, at its own impact. Gasoline, distillate, Cushing, production, the API
// report and natural gas stay on energy charts.
//
// Held as "REGION:FIELD" pairs rather than event names, because a field code
// is TradingView's and does not change when a display name does.
AUTO_CRUDE = ",US:COSC,"

// What Auto admits beyond its regions and categories, as a set of
// "REGION:FIELD" pairs - "," when nothing. Pure, like autoScope().
autoExtras(string symbolId, string rootId, string base, string quote, string symType) =>
    string sym      = str.upper(symbolId)
    string rootUp   = str.upper(rootId)
    string baseUp   = str.upper(base)
    string quoteUp  = str.upper(quote)
    string stripped = stripContinuation(sym)
    string family   = scopeFamily(sym, rootUp, baseUp, quoteUp, symType)
    bool dollarPair = family == "FX"
         and (currencyRegion(baseUp) == "US" or currencyRegion(quoteUp) == "US")
    bool usIndex = family == "INDEX" and homeRegion(rootUp, sym, stripped) == ""
    dollarPair or usIndex or family == "FXFUT" ? AUTO_CRUDE : ","

// The economies on the far side of the dollar on a currency-pair chart, as a
// set - ",AU," on AUDUSD, ",EU,GB," on EURGBP, "," on anything that is not a
// pair. C21: the table emphasises their Currency cells, because an event name
// alone does not say whose release a row is - "Retail Sales (MoM)" exists for
// the US and the UK, and the author read a US row as the British one twice in
// a week. Read from the symbol in every Mode, since it is about the chart.
pairRegions(string symbolId, string rootId, string base, string quote, string symType) =>
    string sym      = str.upper(symbolId)
    string rootUp   = str.upper(rootId)
    string baseUp   = str.upper(base)
    string quoteUp  = str.upper(quote)
    string stripped = stripContinuation(sym)
    string family   = scopeFamily(sym, rootUp, baseUp, quoteUp, symType)
    string out = ","
    if family == "FX"
        string baseRegion  = currencyRegion(baseUp)
        string quoteRegion = currencyRegion(quoteUp)
        if baseRegion != "" and baseRegion != "US"
            out := out + baseRegion + ","
        if quoteRegion != "" and quoteRegion != "US" and quoteRegion != baseRegion
            out := out + quoteRegion + ","
    if family == "FXFUT"
        string counter = fxFuturesRegion(rootUp, sym, stripped)
        if counter != ""
            out := out + counter + ","
    out

// -- The manual sets, built from the panel ----------------------------------
//
// XX is appended unconditionally. It has no checkbox because it is not an
// economy: the two global events are governed by the Structure and Energy
// group checkboxes instead, which is what the Regions tooltip promises.

manualRegions() =>
    string out = ",XX,"
    out := out + (regionUS ? "US," : "")
    out := out + (regionEU ? "EU," : "")
    out := out + (regionGB ? "GB," : "")
    out := out + (regionJP ? "JP," : "")
    out := out + (regionAU ? "AU," : "")
    out := out + (regionNZ ? "NZ," : "")
    out := out + (regionCA ? "CA," : "")
    out := out + (regionCH ? "CH," : "")
    out := out + (regionCN ? "CN," : "")
    out

manualCats() =>
    string out = ","
    out := out + (groupEconomy     ? "POL,INF,LAB,GRO,HOU,SEN," : "")
    out := out + (groupEnergy      ? "ENE," : "")
    out := out + (groupCrops       ? "AGR," : "")
    out := out + (groupBonds       ? "AUC," : "")
    out := out + (groupMarket      ? "MKT," : "")
    out := out + (groupPositioning ? "POS," : "")
    out

// Impact tiers, as the digits that appear in the occurrence record.
//
// Not affected by Mode. "Show everything" means every currency and every
// category; a user who unticks Low still means it, in every mode.
impactSet() =>
    string out = ","
    out := out + (impactHoliday  ? "0," : "")
    out := out + (impactLow      ? "1," : "")
    out := out + (impactMedium   ? "2," : "")
    out := out + (impactHigh     ? "3," : "")
    out := out + (impactCritical ? "4," : "")
    out

// The currency a region's releases are quoted in. The inverse of
// currencyRegion(), and what the table's Currency column shows: a trader
// thinks in USD and EUR, not in region codes.
//
// A global event has no home currency, so it shows a dash rather than an
// invented code.
currencyOf(string region) =>
    switch region
        "US" => "USD"
        "EU" => "EUR"
        "GB" => "GBP"
        "JP" => "JPY"
        "AU" => "AUD"
        "NZ" => "NZD"
        "CA" => "CAD"
        "CH" => "CHF"
        "CN" => "CNY"
        => "-"

// The friendly group name for a stored category code.
//
// Six names over eleven codes, the same mapping manualCats() applies in
// reverse. It is what the table's Type column shows, so an EIA natural-gas
// release on an NG chart reads as USD + Energy rather than as USD alone.
categoryName(string cat) =>
    switch cat
        "ENE" => "Energy"
        "AGR" => "Crops"
        "AUC" => "Bonds"
        "MKT" => "Market"
        "POS" => "Positioning"
        => "Economy"

// -- The effective filters, resolved once -----------------------------------
//
// The three modes are read here and nowhere else, so no later region has to
// remember which one is in force.
//
// THE GREYED INPUTS STILL HOLD THEIR VALUES. `active =` on the currency and
// category checkboxes greys them outside Custom mode, but greying is a
// display state: the inputs keep whatever was last ticked and reading them
// in Auto mode would silently apply a filter the user cannot see. The
// explicit mode test below is what prevents that, and it is why manualCats()
// and manualRegions() are called only on the Custom branch.
//
// RESOLVED ONCE, ON THE FIRST BAR (14 Oct 2026). Every value here depends only
// on the symbol and the inputs, and changing either runs the script again from
// the first bar - so `var` gives the same value on every bar. Before, each was
// worked out again on every bar: scopeFamily() ran four times a bar, about a
// tenth of the script's whole running time in TradingView's profiler.
autoScopeRegions(string symbolId, string rootId, string base, string quote, string symType) =>
    [regions, cats] = autoScope(symbolId, rootId, base, quote, symType)
    regions

autoScopeCats(string symbolId, string rootId, string base, string quote, string symType) =>
    [regions, cats] = autoScope(symbolId, rootId, base, quote, symType)
    cats

var string symbolRegions = autoScopeRegions(syminfo.ticker, syminfo.root,
     syminfo.basecurrency, syminfo.currency, syminfo.type)
var string symbolCats = autoScopeCats(syminfo.ticker, syminfo.root,
     syminfo.basecurrency, syminfo.currency, syminfo.type)

var string scopeRegions = scopeMode == "Auto" ? symbolRegions
     : scopeMode == "Show everything" ? ALL_REGIONS : manualRegions()

var string scopeCats = scopeMode == "Auto" ? symbolCats
     : scopeMode == "Show everything" ? ALL_CATS : manualCats()

var string scopeImpacts = impactSet()

// What Auto admits beyond its categories (C21), and the pair's own economies.
var string scopeExtras = scopeMode == "Auto"
     ? autoExtras(syminfo.ticker, syminfo.root, syminfo.basecurrency,
          syminfo.currency, syminfo.type)
     : ","
var string emphasisRegions = pairRegions(syminfo.ticker, syminfo.root,
     syminfo.basecurrency, syminfo.currency, syminfo.type)

// Whether the chart is a currency pair, by the same test Auto uses - so a pair
// listed on a venue that types it "crypto" is still a pair (isCurrencyPair()).
// The stopped-chart notice says "the same pair" on one and "the same symbol"
// on anything else (C24).
var bool chartIsPair = scopeFamily(str.upper(syminfo.ticker), str.upper(syminfo.root),
     str.upper(syminfo.basecurrency), str.upper(syminfo.currency), syminfo.type) == "FX"

// Should this event be shown?
//
// Impact is tested first because it is the cheapest test - one substring
// search on a short string - and rejects every level the reader has unticked
// (all five are ticked by default since 14 Oct 2026). Then region x category
// - or, since C21, one of the series Auto
// admits beyond its categories (autoExtras), still at its own impact.
//
// Note what is NOT here. Whether an event has already fired, and whether its
// actual value may be displayed yet, are time questions rather than filter
// questions, and they are decided against Ev.ts where the value is read. A
// value is never shown before its scheduled release time (invariant 11).
passes(Ev ev, Meta m, string regions, string cats, string impacts, string extras) =>
    inSet(impacts, str.tostring(ev.impact))
         and ((inSet(regions, m.region) and inSet(cats, m.cat))
              or inSet(extras, m.region + ":" + m.tvf))
//#endregion [Scope]

//#region [Actuals]
// ---------------------------------------------------------------------------
// The bar-0 pipeline, and the live values.
//
// ARCHITECTURE section 3.2, steps 1-7: decode the key table, decode the months
// inside the user's window, filter to the scoped set, collect the distinct
// request fields in priority order, truncate to the budget, and issue the
// requests.
//
// THREE CONSTRAINTS SHAPE EVERYTHING HERE.
//
// 1. A request context must be introduced on a HISTORICAL bar. Pine v6 refuses
//    to open one on a realtime bar, so every request below runs from the
//    first bar with arguments that are settled on bar 0 and never change
//    afterwards. Since C24 there are two sets in exclusive branches, chosen by
//    the chart's timeframe - which cannot change without the script starting
//    again from its first bar - so whichever set a chart runs, it runs on
//    every bar from the first.
//
// 2. AT MOST 36 SERIES. Premium allows 40 unique requests. A chart of a day or
//    less makes 36; a longer chart 37 - one call for its daily bars, with the
//    36 nested inside (Step 7). The requests are fixed call sites reading
//    their arguments from an array, rather than a loop, so the count is
//    visible in the source.
//
// 3. AN ACTUAL IS NEVER SHOWN BEFORE ITS RELEASE TIME. This is the one that
//    fails silently. Economic series are stamped to the END OF THEIR REFERENCE
//    PERIOD, not to their release: July payrolls carry a 31 July timestamp and
//    appear when they are published on 7 August. So on any bar between those
//    two dates the series already holds a value that nobody had yet, and
//    reading it there is look-ahead bias with no error and no warning - a
//    backtest that looks prescient and is simply cheating.
//
//    Every read below is gated on isReleased(Ev.ts), which compares OUR OWN
//    schedule - never the series - against the bar's timestamp on historical
//    bars and against the clock, capped at the bar's close, on the live bar.
//    An open-time gate on the live bar would hide a release until the next bar
//    opened. ARCHITECTURE section 7, consequence 2.
// ---------------------------------------------------------------------------

// -- Step 1: how much calendar to decode ------------------------------------
//
// ONE window, calendar-anchored, spanning past and future together.
//
// It replaces three controls that overlapped - a past window, a forward
// window, and the table's own range. Every preset is "the current calendar
// N": on a Friday morning This Week means Monday through Sunday, including
// what has already printed. One semantic across all of them leaves nothing to
// explain, and the past half is what lets a trader see how price reacted.
//
// Boundaries are resolved with timestamp() in the DISPLAY timezone rather than
// by millisecond arithmetic, so a week that contains a daylight-saving change
// still starts at local midnight instead of an hour either side of it.

// The zone every displayed time and every window boundary is resolved in.
//
// Pine exposes no accessor for the CHART's timezone, so the panel offers named
// zones instead of pretending it can follow the chart. New York is the default
// because that is the clock economic releases are quoted in.
displayZone() =>
    switch tzSource
        "UTC"       => "UTC"
        "New York"  => "America/New_York"
        "Chicago"   => "America/Chicago"
        "London"    => "Europe/London"
        "Frankfurt" => "Europe/Berlin"
        "Tokyo"     => "Asia/Tokyo"
        "Sydney"    => "Australia/Sydney"
        => syminfo.timezone

// Midnight at the start of the day `at` falls in.
startOfDay(int at, string zone) =>
    timestamp(zone, year(at, zone), month(at, zone), dayofmonth(at, zone), 0, 0)

// The window, as [start, end] in UTC milliseconds.
//
// `dayofweek` is 1 = Sunday, so Monday is 2 and the offset back to Monday is
// (dow + 5) % 7. Day arithmetic is done in milliseconds only to find WHICH
// day, never to build the boundary - the boundary always comes from
// timestamp(), which resolves the wall time correctly across a DST change.
windowBounds() =>
    string zone = displayZone()
    int y = year(timenow, zone)
    int m = month(timenow, zone)
    int startMs = na
    int endMs = na

    if timeWindow == "Today"
        startMs := startOfDay(timenow, zone)
        int tomorrow = timenow + 86400000
        endMs := startOfDay(tomorrow, zone) - 1
    if timeWindow == "This Week"
        int backDays = (dayofweek(timenow, zone) + 5) % 7
        int monday = timenow - backDays * 86400000
        int nextMonday = timenow + (7 - backDays) * 86400000
        startMs := startOfDay(monday, zone)
        endMs := startOfDay(nextMonday, zone) - 1
    if timeWindow == "Next Week"
        // The same anchor shifted seven days, so the two presets cannot drift
        // apart: This Week ends the instant Next Week begins.
        int backDays = (dayofweek(timenow, zone) + 5) % 7
        int nextMonday = timenow + (7 - backDays) * 86400000
        int weekAfter = timenow + (14 - backDays) * 86400000
        startMs := startOfDay(nextMonday, zone)
        endMs := startOfDay(weekAfter, zone) - 1
    if timeWindow == "This Month"
        startMs := timestamp(zone, y, m, 1, 0, 0)
        endMs := timestamp(zone, m == 12 ? y + 1 : y, m == 12 ? 1 : m + 1, 1, 0, 0) - 1
    if timeWindow == "Next Month"
        // This Month's end is the instant this one begins, for the same reason
        // Next Week shares This Week's anchor.
        int nextY = m == 12 ? y + 1 : y
        int nextM = m == 12 ? 1 : m + 1
        startMs := timestamp(zone, nextY, nextM, 1, 0, 0)
        endMs := timestamp(zone, nextM == 12 ? nextY + 1 : nextY, nextM == 12 ? 1 : nextM + 1, 1, 0, 0) - 1
    if timeWindow == "This Quarter"
        int firstMonth = int(math.floor((m - 1) / 3)) * 3 + 1
        startMs := timestamp(zone, y, firstMonth, 1, 0, 0)
        endMs := timestamp(zone, firstMonth >= 10 ? y + 1 : y,
             firstMonth >= 10 ? 1 : firstMonth + 3, 1, 0, 0) - 1
    if timeWindow == "This Year"
        startMs := timestamp(zone, y, 1, 1, 0, 0)
        endMs := timestamp(zone, y + 1, 1, 1, 0, 0) - 1
    if timeWindow == "Custom"
        // EXACTLY THE TWO INSTANTS IN THE BOXES, hours included (C22, the
        // author's decision). C21 made the range whole days and ignored the
        // time boxes, because they read 18:00 and dropped every event before
        // 18:00 on the From day without saying so. Now the headline states the
        // hours whenever either box is not at midnight, so a range that starts
        // at 18:00 says so - see rangeText().
        //
        // NEVER SWAPPED. Until C21 a From after To was quietly exchanged for
        // the other order: TradingView's date picker landed From a month late,
        // on 28 October, and the table showed 3 to 28 October with nothing to
        // say why. Now the window is empty and a notice names both.
        startMs := customFrom
        endMs := customTo
    [startMs, endMs]

// Clamp to the horizon the embedded data actually covers.
//
// A custom range outside it is not an error - the user asked a reasonable
// question and the answer is "not in this build". The table says so; it does
// not quietly show an empty list.
[horizonStart, horizonEnd] = cal.horizon()
[requestedStart, requestedEnd] = windowBounds()

var int windowStart = math.max(requestedStart, horizonStart)
var int windowEnd   = math.min(requestedEnd, horizonEnd)

// Whether the user asked for something the data cannot answer, for the table.
// A reversed range is its own notice, not this one.
var bool customReversed = timeWindow == "Custom" and requestedStart > requestedEnd
var bool windowClipped = not customReversed
     and (requestedStart < horizonStart or requestedEnd > horizonEnd)

// -- The CAPTURE window is wider than the DISPLAY window --------------------
//
// This is the fix for a bug that made Previous and Change blank on every short
// preset, and it is worth stating plainly because the symptom pointed at the
// renderer and the cause was here.
//
// "Previous" is the last captured actual FOR THAT KEY, which means the key's
// PRIOR OCCURRENCE has to have been decoded and walked. With Show = Today, the
// previous Non-Farm Payrolls sits a month outside the window: never decoded,
// never captured, so Previous is na - and Change, being the difference of two
// values one of which is na, is na too. Actual survived because it is read at
// the event's own release bar, which IS inside the window. Custom spanning a
// year worked for the same reason in reverse.
//
// So the two windows are separated:
//
//   CAPTURE  at least CAPTURE_MONTHS back from the display start. Decoded and
//            walked so values accumulate, but never shown.
//   DISPLAY  exactly what the user asked for. The table and the event count
//            use this and only this.
//
// Thirteen months was the depth of derive's ring of releases, until C16. The
// derived rates now read month-end levels from the chart's own bars (see
// derive, below), so only Previous depends on this window - and the previous
// release of an event is a few months back at most, four in the shutdown
// catch-up. It stays at thirteen rather than being tuned to that.
//
// Forward needs no lookahead: an unreleased event has nothing to capture.
CAPTURE_MONTHS = 13

captureStartFor(int displayStart) =>
    int y = year(displayStart, "UTC")
    int m = month(displayStart, "UTC") - CAPTURE_MONTHS
    while m < 1
        m += 12
        y -= 1
    timestamp("UTC", y, m, 1, 0, 0)

var int captureStart = math.max(captureStartFor(windowStart), horizonStart)

// -- Step 2-4: decode, once, into var state ---------------------------------

var array<Meta> keys   = array.new<Meta>()
var array<Ev>   events = array.new<Ev>()

// Occurrences that survived the filter, and the parallel arrays that track
// their values. Parallel arrays rather than a wider UDT because only these
// three change after bar 0, and copying a UDT to mutate one field is waste.
var array<Ev>    scoped   = array.new<Ev>()
var array<float> actuals  = array.new<float>()
var array<float> previous = array.new<float>()

// The scoped keys' occurrences AFTER the window, to the end of the month after
// it. Never shown and never read: only coarseRead() looks at them, to know
// when each period's NEXT period is dated. C22.
var array<Ev>    afterWindow = array.new<Ev>()

if barstate.isfirst
    keys := decodeKeys(cal.keyTable())

    // Decode from the CAPTURE start, not the display start, so each key's
    // prior occurrence is available to populate Previous - and one month past
    // the window's, for afterWindow.
    //
    // `year` and `month` are built-in series variables, so the cursor cannot
    // use those names.
    int cursorYear  = year(captureStart, "UTC")
    int cursorMonth = month(captureStart, "UTC")
    int lastYear    = year(windowEnd, "UTC") + (month(windowEnd, "UTC") == 12 ? 1 : 0)
    int lastMonth   = month(windowEnd, "UTC") % 12 + 1

    // Bounded: 37 chunks exist, and a malformed window must not spin on bar 0.
    int steps = 0
    while cursorYear * 12 + cursorMonth <= lastYear * 12 + lastMonth and steps < 40
        decodeMonth(cal.monthChunk(cursorYear, cursorMonth), cursorYear,
             cursorMonth, events)
        cursorMonth += 1
        if cursorMonth > 12
            cursorMonth := 1
            cursorYear  += 1
        steps += 1

    // Step 5: filter, in two passes.
    //
    // The first pass records which KEYS appear inside the display window. The
    // second keeps an event if it is displayed, or if it is an earlier
    // occurrence of a key that will be. That is what keeps the retained array
    // small while still decoding thirteen extra months: a year of lookback for
    // six displayed keys is a few dozen extra events, not a few thousand.
    var array<bool> keyWanted = array.new<bool>()
    if array.size(keys) > 0
        for i = 0 to array.size(keys) - 1
            array.push(keyWanted, false)

    if array.size(events) > 0
        for i = 0 to array.size(events) - 1
            Ev ev = array.get(events, i)
            if ev.key >= 0 and ev.key < array.size(keys)
                 and ev.ts >= windowStart and ev.ts <= windowEnd
                if passes(ev, array.get(keys, ev.key), scopeRegions, scopeCats,
                     scopeImpacts, scopeExtras)
                    array.set(keyWanted, ev.key, true)

    if array.size(events) > 0
        for i = 0 to array.size(events) - 1
            Ev ev = array.get(events, i)
            if ev.key >= 0 and ev.key < array.size(keys)
                Meta m = array.get(keys, ev.key)
                bool displayed = ev.ts >= windowStart and ev.ts <= windowEnd
                bool lookback = ev.ts < windowStart
                     and array.get(keyWanted, ev.key)
                bool after = ev.ts > windowEnd and array.get(keyWanted, ev.key)
                if (displayed or lookback or after)
                     and passes(ev, m, scopeRegions, scopeCats, scopeImpacts,
                          scopeExtras)
                    if after
                        array.push(afterWindow, ev)
                    if not after
                        array.push(scoped, ev)
                        array.push(actuals, na)
                        array.push(previous, na)

// Where the DISPLAY half of `scoped` begins.
//
// `scoped` is in time order and every lookback event is strictly before
// windowStart, so the split is a single index: everything below it is capture
// only and everything at or above it is shown. That is cheaper than a parallel
// bool array and impossible to get out of step with the data.
var int displayFrom = 0
if barstate.isfirst and array.size(scoped) > 0
    displayFrom := array.size(scoped)
    for i = 0 to array.size(scoped) - 1
        if displayFrom == array.size(scoped)
             and array.get(scoped, i).ts >= windowStart
            displayFrom := i

// How many events the user actually asked to see. The header counts these,
// not the lookback.
displayCount() =>
    array.size(scoped) - displayFrom

// Whether an event's series is worth a request slot. Not when its figure is
// never shown: a period no source establishes (PRD_WITHHELD), a divisor not
// yet measured (scl 0), or a month-on-month rate derived from an index level
// (DRV_MOM, C22 - see withheldFigure()). Until C21 the first two took a slot
// from the budget of 36 and filled it with a number nobody sees.
wantsSlot(Meta m) =>
    str.length(m.tvf) > 0 and m.scl > 0 and m.prd != PRD_WITHHELD and m.drv != DRV_MOM

// -- Step 6: which fields to request ----------------------------------------
//
// Distinct (region, field) pairs over the scoped set, highest impact first,
// truncated at the budget. Impact order matters: when more than 36 fields are
// wanted, the ones that survive should be the ones a user filtered FOR.

var array<string> reqRegion = array.new<string>()
var array<string> reqField  = array.new<string>()

// How many distinct (region, field) pairs were wanted before truncation.
// Surfaced in the table: a silently truncated budget is a column of blanks with
// no explanation (ARCHITECTURE section 4.1).
//
// DISTINCT PAIRS, counted in their own list. Until C21 a pair was looked up in
// the request list, which stops growing at 36, so once the budget was full
// every further OCCURRENCE of an unslotted field counted again - the notice
// told the author "176 event types are showing no figures" on a calendar of
// 118 event types.
var int fieldsWanted = 0
var array<string> wantedRegion = array.new<string>()
var array<string> wantedField  = array.new<string>()

if barstate.isfirst
    // Walk impact tiers from critical down, so the array comes out in
    // priority order without sorting anything.
    for tier = 4 to 0
        if array.size(scoped) > 0
            for i = 0 to array.size(scoped) - 1
                Ev ev = array.get(scoped, i)
                if ev.impact == tier
                    Meta m = array.get(keys, ev.key)
                    if wantsSlot(m)
                        bool seen = false
                        if array.size(wantedField) > 0
                            for j = 0 to array.size(wantedField) - 1
                                if array.get(wantedField, j) == m.tvf
                                     and array.get(wantedRegion, j) == m.region
                                    seen := true
                        if not seen
                            array.push(wantedRegion, m.region)
                            array.push(wantedField, m.tvf)
                            if array.size(reqField) < REQUEST_BUDGET
                                array.push(reqRegion, m.region)
                                array.push(reqField, m.tvf)
    fieldsWanted := array.size(wantedField)

// The arguments for one request slot.
//
// Slots beyond the ones we actually need still have to request SOMETHING -
// there are 36 fixed call sites in each set and a chart evaluates every one
// of its set. They are pointed at an empty field code, which
// `ignore_invalid_symbol = true` turns into a permanent `na` rather than an
// error. Identical calls share one request (Pine: "only the first call
// usually counts toward this limit").
slotRegion(int slot) =>
    slot < array.size(reqRegion) ? array.get(reqRegion, slot) : "US"
slotField(int slot) =>
    slot < array.size(reqField) ? array.get(reqField, slot) : ""

// -- Step 7: the requests ---------------------------------------------------
//
// TWO SETS OF CALLS, AND A CHART RUNS ONE OF THEM (C24).
//
//   * A chart whose bars are a day or shorter reads each series on its own
//     bars: thirty-six request.economic() calls, a00 to a35.
//   * A chart whose bars are longer than a day - 2D, 1W, 1M, 3M - reads them
//     through its own DAILY bars: one request.security_lower_tf() call for
//     the chart's daily bars, with the same thirty-six request.economic()
//     calls nested inside it (dailyReads()). Thirty-seven requests.
//
// WHY NOT READ A WEEKLY OR MONTHLY BAR ITSELF. What such a bar holds depends
// on the market and on where the bar happens to open. The C23 probe measured
// five charts: a crypto weekly or monthly bar holds its whole bar; a CME or
// FX weekly bar what is dated up to its first trading day; and an NG1!
// monthly bar that opened on a Sunday, because the 1st was a Saturday, held
// its whole month. The daily bars inside each of those bars held, on every
// chart, every bar and every series, exactly what a daily chart holds. So
// above a day every figure is read from the daily bar a daily chart reads it
// from (ARCHITECTURE section 7, consequences 9 and 10).
//
// ONLY THE SET A CHART RUNS COUNTS AGAINST THE LIMIT OF 40. Pine's
// documentation: with dynamic requests, the default in v6, "each request.*()
// instance in the code can activate zero, one, or several times on each
// script execution" (Other timeframes and data, "In local scopes"), and the
// limit is reached while executing - its own example "causes a runtime error
// when i == 41 because each iteration executes a unique request"
// (Limitations, "request.*() calls"). A call in a branch the chart never
// enters executes nothing.
//
// Thirty-six call sites per set, written out rather than looped: the nested
// set cannot be a loop - an expression evaluated in another context may not
// depend on a loop's variable - and an explicit list keeps the budget
// auditable by reading the file. `gigi lint-pine` and the tests count them.

// Whether this chart's bars are longer than a day: the branch every request,
// read and clock below goes by.
longBars = timeframe.in_seconds() > 86400

// -- Charts of a day or less: the chart's own bars --------------------------
float a00 = na
float a01 = na
float a02 = na
float a03 = na
float a04 = na
float a05 = na
float a06 = na
float a07 = na
float a08 = na
float a09 = na
float a10 = na
float a11 = na
float a12 = na
float a13 = na
float a14 = na
float a15 = na
float a16 = na
float a17 = na
float a18 = na
float a19 = na
float a20 = na
float a21 = na
float a22 = na
float a23 = na
float a24 = na
float a25 = na
float a26 = na
float a27 = na
float a28 = na
float a29 = na
float a30 = na
float a31 = na
float a32 = na
float a33 = na
float a34 = na
float a35 = na
if not longBars
    a00 := request.economic(slotRegion(0),  slotField(0),  ignore_invalid_symbol = true)
    a01 := request.economic(slotRegion(1),  slotField(1),  ignore_invalid_symbol = true)
    a02 := request.economic(slotRegion(2),  slotField(2),  ignore_invalid_symbol = true)
    a03 := request.economic(slotRegion(3),  slotField(3),  ignore_invalid_symbol = true)
    a04 := request.economic(slotRegion(4),  slotField(4),  ignore_invalid_symbol = true)
    a05 := request.economic(slotRegion(5),  slotField(5),  ignore_invalid_symbol = true)
    a06 := request.economic(slotRegion(6),  slotField(6),  ignore_invalid_symbol = true)
    a07 := request.economic(slotRegion(7),  slotField(7),  ignore_invalid_symbol = true)
    a08 := request.economic(slotRegion(8),  slotField(8),  ignore_invalid_symbol = true)
    a09 := request.economic(slotRegion(9),  slotField(9),  ignore_invalid_symbol = true)
    a10 := request.economic(slotRegion(10), slotField(10), ignore_invalid_symbol = true)
    a11 := request.economic(slotRegion(11), slotField(11), ignore_invalid_symbol = true)
    a12 := request.economic(slotRegion(12), slotField(12), ignore_invalid_symbol = true)
    a13 := request.economic(slotRegion(13), slotField(13), ignore_invalid_symbol = true)
    a14 := request.economic(slotRegion(14), slotField(14), ignore_invalid_symbol = true)
    a15 := request.economic(slotRegion(15), slotField(15), ignore_invalid_symbol = true)
    a16 := request.economic(slotRegion(16), slotField(16), ignore_invalid_symbol = true)
    a17 := request.economic(slotRegion(17), slotField(17), ignore_invalid_symbol = true)
    a18 := request.economic(slotRegion(18), slotField(18), ignore_invalid_symbol = true)
    a19 := request.economic(slotRegion(19), slotField(19), ignore_invalid_symbol = true)
    a20 := request.economic(slotRegion(20), slotField(20), ignore_invalid_symbol = true)
    a21 := request.economic(slotRegion(21), slotField(21), ignore_invalid_symbol = true)
    a22 := request.economic(slotRegion(22), slotField(22), ignore_invalid_symbol = true)
    a23 := request.economic(slotRegion(23), slotField(23), ignore_invalid_symbol = true)
    a24 := request.economic(slotRegion(24), slotField(24), ignore_invalid_symbol = true)
    a25 := request.economic(slotRegion(25), slotField(25), ignore_invalid_symbol = true)
    a26 := request.economic(slotRegion(26), slotField(26), ignore_invalid_symbol = true)
    a27 := request.economic(slotRegion(27), slotField(27), ignore_invalid_symbol = true)
    a28 := request.economic(slotRegion(28), slotField(28), ignore_invalid_symbol = true)
    a29 := request.economic(slotRegion(29), slotField(29), ignore_invalid_symbol = true)
    a30 := request.economic(slotRegion(30), slotField(30), ignore_invalid_symbol = true)
    a31 := request.economic(slotRegion(31), slotField(31), ignore_invalid_symbol = true)
    a32 := request.economic(slotRegion(32), slotField(32), ignore_invalid_symbol = true)
    a33 := request.economic(slotRegion(33), slotField(33), ignore_invalid_symbol = true)
    a34 := request.economic(slotRegion(34), slotField(34), ignore_invalid_symbol = true)
    a35 := request.economic(slotRegion(35), slotField(35), ignore_invalid_symbol = true)

// One slot's current value on the chart's own bar. A switch rather than an
// array because the request results are 36 separate series and Pine has no way
// to index them.
slotValue(int slot) =>
    switch slot
        0 => a00
        1 => a01
        2 => a02
        3 => a03
        4 => a04
        5 => a05
        6 => a06
        7 => a07
        8 => a08
        9 => a09
        10 => a10
        11 => a11
        12 => a12
        13 => a13
        14 => a14
        15 => a15
        16 => a16
        17 => a17
        18 => a18
        19 => a19
        20 => a20
        21 => a21
        22 => a22
        23 => a23
        24 => a24
        25 => a25
        26 => a26
        27 => a27
        28 => a28
        29 => a29
        30 => a30
        31 => a31
        32 => a32
        33 => a33
        34 => a34
        => a35

// -- Charts of bars longer than a day: the daily bars inside each bar -------

// One daily bar of this chart, as a daily chart reads it: its open, its
// trading day and its close, and the thirty-six series as that bar holds
// them. Evaluated inside the chart's daily bars by request.security_lower_tf(),
// so time, time_tradingday and time_close here are the DAILY bar's. So are
// slotRegion() and slotField(): Pine evaluates a requested expression, and the
// code it depends on, in the requested context ("the function call duplicates
// all preceding code that determines the assigned value"), so the bar-0
// decode that chooses the slots runs a second time there, on the first daily
// bar, from the same inputs, symbol and clock - and chooses the same slots.
dailyReads() =>
    [time, time_tradingday, time_close,
     request.economic(slotRegion(0),  slotField(0),  ignore_invalid_symbol = true),
     request.economic(slotRegion(1),  slotField(1),  ignore_invalid_symbol = true),
     request.economic(slotRegion(2),  slotField(2),  ignore_invalid_symbol = true),
     request.economic(slotRegion(3),  slotField(3),  ignore_invalid_symbol = true),
     request.economic(slotRegion(4),  slotField(4),  ignore_invalid_symbol = true),
     request.economic(slotRegion(5),  slotField(5),  ignore_invalid_symbol = true),
     request.economic(slotRegion(6),  slotField(6),  ignore_invalid_symbol = true),
     request.economic(slotRegion(7),  slotField(7),  ignore_invalid_symbol = true),
     request.economic(slotRegion(8),  slotField(8),  ignore_invalid_symbol = true),
     request.economic(slotRegion(9),  slotField(9),  ignore_invalid_symbol = true),
     request.economic(slotRegion(10), slotField(10), ignore_invalid_symbol = true),
     request.economic(slotRegion(11), slotField(11), ignore_invalid_symbol = true),
     request.economic(slotRegion(12), slotField(12), ignore_invalid_symbol = true),
     request.economic(slotRegion(13), slotField(13), ignore_invalid_symbol = true),
     request.economic(slotRegion(14), slotField(14), ignore_invalid_symbol = true),
     request.economic(slotRegion(15), slotField(15), ignore_invalid_symbol = true),
     request.economic(slotRegion(16), slotField(16), ignore_invalid_symbol = true),
     request.economic(slotRegion(17), slotField(17), ignore_invalid_symbol = true),
     request.economic(slotRegion(18), slotField(18), ignore_invalid_symbol = true),
     request.economic(slotRegion(19), slotField(19), ignore_invalid_symbol = true),
     request.economic(slotRegion(20), slotField(20), ignore_invalid_symbol = true),
     request.economic(slotRegion(21), slotField(21), ignore_invalid_symbol = true),
     request.economic(slotRegion(22), slotField(22), ignore_invalid_symbol = true),
     request.economic(slotRegion(23), slotField(23), ignore_invalid_symbol = true),
     request.economic(slotRegion(24), slotField(24), ignore_invalid_symbol = true),
     request.economic(slotRegion(25), slotField(25), ignore_invalid_symbol = true),
     request.economic(slotRegion(26), slotField(26), ignore_invalid_symbol = true),
     request.economic(slotRegion(27), slotField(27), ignore_invalid_symbol = true),
     request.economic(slotRegion(28), slotField(28), ignore_invalid_symbol = true),
     request.economic(slotRegion(29), slotField(29), ignore_invalid_symbol = true),
     request.economic(slotRegion(30), slotField(30), ignore_invalid_symbol = true),
     request.economic(slotRegion(31), slotField(31), ignore_invalid_symbol = true),
     request.economic(slotRegion(32), slotField(32), ignore_invalid_symbol = true),
     request.economic(slotRegion(33), slotField(33), ignore_invalid_symbol = true),
     request.economic(slotRegion(34), slotField(34), ignore_invalid_symbol = true),
     request.economic(slotRegion(35), slotField(35), ignore_invalid_symbol = true)]

// The chart's daily bars inside the current bar, oldest first, one array per
// element of dailyReads(). na on a chart of a day or less.
array<int> dayOpen    = na
array<int> dayTrading = na
array<int> dayClose   = na
array<float> d00 = na
array<float> d01 = na
array<float> d02 = na
array<float> d03 = na
array<float> d04 = na
array<float> d05 = na
array<float> d06 = na
array<float> d07 = na
array<float> d08 = na
array<float> d09 = na
array<float> d10 = na
array<float> d11 = na
array<float> d12 = na
array<float> d13 = na
array<float> d14 = na
array<float> d15 = na
array<float> d16 = na
array<float> d17 = na
array<float> d18 = na
array<float> d19 = na
array<float> d20 = na
array<float> d21 = na
array<float> d22 = na
array<float> d23 = na
array<float> d24 = na
array<float> d25 = na
array<float> d26 = na
array<float> d27 = na
array<float> d28 = na
array<float> d29 = na
array<float> d30 = na
array<float> d31 = na
array<float> d32 = na
array<float> d33 = na
array<float> d34 = na
array<float> d35 = na
// The tuple's names stay on one line. Pine documents wrapping a long
// expression; a wrapped tuple DECLARATION has never been compiled here, and
// one long line costs nothing.
if longBars
    [o, t, c, r00, r01, r02, r03, r04, r05, r06, r07, r08, r09, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23, r24, r25, r26, r27, r28, r29, r30, r31, r32, r33, r34, r35] = request.security_lower_tf(
         syminfo.tickerid, "1D", dailyReads(),
         ignore_invalid_symbol = true, ignore_invalid_timeframe = true)
    dayOpen    := o
    dayTrading := t
    dayClose   := c
    d00 := r00
    d01 := r01
    d02 := r02
    d03 := r03
    d04 := r04
    d05 := r05
    d06 := r06
    d07 := r07
    d08 := r08
    d09 := r09
    d10 := r10
    d11 := r11
    d12 := r12
    d13 := r13
    d14 := r14
    d15 := r15
    d16 := r16
    d17 := r17
    d18 := r18
    d19 := r19
    d20 := r20
    d21 := r21
    d22 := r22
    d23 := r23
    d24 := r24
    d25 := r25
    d26 := r26
    d27 := r27
    d28 := r28
    d29 := r29
    d30 := r30
    d31 := r31
    d32 := r32
    d33 := r33
    d34 := r34
    d35 := r35

// How many daily bars the current bar holds: 0 on a chart of a day or less.
daysInBar() =>
    na(dayTrading) ? 0 : array.size(dayTrading)

// One slot's values on the daily bars inside the current bar.
dailySeries(int slot) =>
    switch slot
        0 => d00
        1 => d01
        2 => d02
        3 => d03
        4 => d04
        5 => d05
        6 => d06
        7 => d07
        8 => d08
        9 => d09
        10 => d10
        11 => d11
        12 => d12
        13 => d13
        14 => d14
        15 => d15
        16 => d16
        17 => d17
        18 => d18
        19 => d19
        20 => d20
        21 => d21
        22 => d22
        23 => d23
        24 => d24
        25 => d25
        26 => d26
        27 => d27
        28 => d28
        29 => d29
        30 => d30
        31 => d31
        32 => d32
        33 => d33
        34 => d34
        => d35

// One slot's value on daily bar `day` inside the current bar, or na.
dailyValue(int slot, int day) =>
    day >= 0 and day < daysInBar() ? array.get(dailySeries(slot), day) : na

// Which slot serves a given event, or -1 if its field was truncated away.
slotFor(Meta m) =>
    int found = -1
    if str.length(m.tvf) > 0 and array.size(reqField) > 0
        for j = 0 to array.size(reqField) - 1
            if array.get(reqField, j) == m.tvf
                 and array.get(reqRegion, j) == m.region
                found := j
    found

// How many EVENT TYPES in the window have a series and no slot - what the
// notice reports. Counted by key, because that is what a reader counts: two
// event types can share one series (Core PCE month on month and year on year
// both read CPCEPI), and one series served is two rows served.
var int typesUnserved = 0
if barstate.isfirst and displayFrom < array.size(scoped)
    array<bool> counted = array.new<bool>(array.size(keys), false)
    for i = displayFrom to array.size(scoped) - 1
        int key = array.get(scoped, i).key
        Meta m = array.get(keys, key)
        if not array.get(counted, key) and wantsSlot(m) and slotFor(m) < 0
            array.set(counted, key, true)
            typesUnserved += 1

// -- The release clock ------------------------------------------------------
//
// Whether the release at `ts` has happened, as far as the current bar can know.
//
// On a historical bar it is `time >= ts`: the bar's OPEN. A bar that opened
// before the release may not see it, even if the release fell inside the bar.
// That is invariant 11, and it is what stops look-ahead.
//
// On the last bar it is the wall clock, capped at the bar's close. Until C12 the
// last bar used its open time as well, and on anything slower than a 1-minute
// chart that hid a release for the rest of its bar. An 08:30 figure stayed blank
// on a 1-hour chart until 09:00, and on a daily chart until the next session -
// however fast TradingView published it. Meanwhile the table put the row above
// the "now" divider, as released, with nothing in it. Reading a figure after
// its release time is being late, not looking ahead.
//
// The cap is for Bar Replay, where the wall clock is today and the last bar is
// in the past: there a release counts only if it fell before that bar closed.
// Some chart types have no close time until the bar ends; there the wall clock
// alone is used, which on a live chart is the same thing.
//
// ON A CHART OF BARS LONGER THAN A DAY (C24) "the bar" is the latest daily bar
// inside the chart's bar - clockOpen() and clockClose() - so a weekly or
// monthly chart decides "released" with the same open and close a daily chart
// does. Over an FX weekend, say, the cap is Friday's close on both, not the
// end of the month.
//
// THIS DECIDES WHEN A FIGURE IS SHOWN, AND NOTHING ELSE. Where it is read is
// the next section's question.
clockOpen() =>
    longBars and daysInBar() > 0 ? array.last(dayOpen) : time

clockClose() =>
    longBars and daysInBar() > 0 ? array.last(dayClose) : time_close

isReleased(int ts) =>
    int clock = clockOpen()
    if barstate.islast
        int barEnd = clockClose()
        int wall = na(barEnd) ? timenow : math.min(timenow, barEnd)
        clock := math.max(clockOpen(), wall)
    clock >= ts

// -- Where a figure is read: the end of its period --------------------------
//
// ARCHITECTURE section 7. TradingView dates every value to the END of the
// period it describes - July payrolls to 31 July, a claims week to its
// Saturday - and the value exists only once it has been published. So the
// figure for a release is the value dated to the end of ITS period, and that
// date can fall on either side of the release:
//
//   * July's trade balance is released on 3 September and dated 31 July. By
//     3 September on a reloaded chart the series already holds AUGUST's value,
//     dated 31 August and published on 6 October. Reading at the release showed
//     next month's figure a month early - look-ahead, found in C15.
//   * September's Philadelphia Fed survey is released on 17 September and
//     dated 30 September. Reading at the release showed AUGUST's figure. It is
//     readable from 30 September, not before.
//
// Until C16 every figure was read at its release, which is right only while
// the period ends before the release and the next one ends after it. Now each
// is read where it is dated, and SHOWN only once isReleased() says the
// release has happened. Where we read and when we show are separate
// questions; answering both with the release time is what produced both bugs.
//
// C16 KEPT ONE EXCEPTION, AND C21 REMOVED IT. Weekly reports and rate decisions
// were still read at the release, because their period ends before the release
// and the next one after it. That was checked against the release INSTANT, not
// against the bar the read lands on, and they differ:
//
//   * natural gas storage is released on Thursday at 14:30 UTC and dated to
//     the Friday its week ends. On a daily chart the first bar at or after
//     14:30 Thursday is FRIDAY's, which already holds the next week's value,
//     dated that Friday and published six days later. The 24 September row
//     showed 1 October's 64 Bcf, and 1 October's Previous repeated it. On an
//     hourly chart the same read was right, so it depended on the timeframe.
//   * the euro area flash inflation estimate came out at 09:00 UTC on a
//     Friday. On a daily FX chart the first bar after that is MONDAY's, so a
//     figure published on Friday morning showed an hourglass all weekend.
//
// So every figure with a series is now read where TradingView dates it: a
// month or quarter at its end, a week at the day it ends, a rate decision at
// midnight UTC on its day. A read there lands on a bar that holds this
// period's value and cannot yet hold the next one's, on every timeframe.
//
// Meta.prd says which period a release describes, and the same rule produces
// the table's label - "Retail Sales (MoM) (Aug)" - so the name and the figure
// cannot describe different months.

// The zone a region's releases are dated in.
//
// A period is worked out from the release's date THERE, not in UTC and not in
// the viewer's zone. New Zealand's 10:45 release on the 1st of a month is
// still the last day of the previous month in UTC, and would be read, and
// labelled, a month early.
homeZone(string region) =>
    switch region
        "US" => "America/New_York"
        "EU" => "Europe/Berlin"
        "GB" => "Europe/London"
        "JP" => "Asia/Tokyo"
        "AU" => "Australia/Sydney"
        "NZ" => "Pacific/Auckland"
        "CA" => "America/Toronto"
        "CH" => "Europe/Zurich"
        "CN" => "Asia/Shanghai"
        => "UTC"

// Months since year zero, so month arithmetic crosses a year boundary with
// plain subtraction.
monthIndexOf(int at, string zone) =>
    year(at, zone) * 12 + month(at, zone) - 1

// Whether a release sits in the US shutdown gap - see PRD_GAP_US_FROM. Only
// the modes that count back from the release are affected; a survey of the
// current month was never delayed.
//
// A release that carries its own period (ev.prdOv) is NOT in the gap, whatever
// its date. The gap exists because the period cannot be told from the release's
// date; where the publisher stated it and the record carries it, there is
// nothing to withhold. This is what lets the six durable-goods rows of the
// 2025 shutdown backlog show a figure again.
inShutdownGap(Ev ev, Meta m) =>
    ev.prdOv == PRD_OVERRIDE_NONE
         and m.region == "US" and ev.ts >= PRD_GAP_US_FROM and ev.ts < PRD_GAP_US_TO
         and (m.prd == PRD_PREV_MONTH or m.prd == PRD_PREV_QUARTER
         or m.prd == PRD_LAGGED_MONTH)

// The day, counted from 1 January 1970 UTC, of the latest `weekday` strictly
// before the release's own date in `zone` - the day a weekly report's week
// ends. `weekday` is Pine's numbering, 1 = Sunday to 7 = Saturday. A report
// out on a Thursday for the week ending the Friday before reaches back six
// days; one delayed to Friday by a holiday, seven.
//
// The step back is taken from the release instant, so it lands at the same
// clock time on the target day, give or take a daylight-saving hour - never on
// another date.
weekEndDay(int at, string zone, int weekday) =>
    int back = (dayofweek(at, zone) - weekday + 6) % 7 + 1
    int target = at - back * DAY_MS
    int(math.floor(timestamp("UTC", year(target, zone), month(target, zone),
         dayofmonth(target, zone), 0, 0) / DAY_MS))

// The period a release describes, as [kind, index]:
//
//   kind 0   none - PRD 0 and 6
//   kind 1   a month; index is its monthIndexOf
//   kind 2   a quarter; index is year * 4 + quarter - 1
//   kind 3   a day; index counts days from 1 January 1970 UTC. A weekly
//            report is named by the day its week ends, a rate decision by its
//            own day - each the day TradingView dates it to, at 00:00 UTC
//
// ev.prdOv, the record's last character, overrides the rule for one release.
// PRD is a rule and a rule is right about a release only while its publisher
// behaves: the ONS postponed one month's retail sales beside the next month's,
// the ABS publishes November's CPI in the first days of January, and the 2025
// shutdown left durable goods a month behind for half a year. On those rows
// the rule names the wrong month - which decides the label AND where the
// figure is read - and each looks perfect on the chart.
//
// The override counts months back from the release's OWN month, not from the
// rule's answer, so no change to CURRENT_MONTH_FIRST_WEEK or LAGGED_MONTH_DAYS
// can quietly invalidate one. 1 is the release's own month, 2 the month
// before it. Every one is written from its publisher's own statement of the
// reference period; the pipeline refuses to encode one that cites no source.
referencePeriod(Ev ev, Meta m) =>
    string zone = homeZone(m.region)
    int kind = 0
    int index = 0
    if ev.prdOv != PRD_OVERRIDE_NONE
        kind := 1
        index := monthIndexOf(ev.ts, zone) - (ev.prdOv - 1)
    if ev.prdOv == PRD_OVERRIDE_NONE and m.prd == PRD_PREV_MONTH
        kind := 1
        index := monthIndexOf(ev.ts, zone) - 1
    if ev.prdOv == PRD_OVERRIDE_NONE and m.prd == PRD_CURRENT_MONTH
        // The month a couple of days before the release: a release in a
        // month's first days describes the month just ended. See
        // CURRENT_MONTH_FIRST_WEEK.
        kind := 1
        index := monthIndexOf(ev.ts - CURRENT_MONTH_FIRST_WEEK * DAY_MS, zone)
    if ev.prdOv == PRD_OVERRIDE_NONE and m.prd == PRD_LAGGED_MONTH
        // The latest month whose last day is at least LAGGED_MONTH_DAYS before
        // the release. The month holding the day one fewer than that before the
        // release has not ended by then; the one before it has.
        kind := 1
        index := monthIndexOf(ev.ts - (LAGGED_MONTH_DAYS - 1) * DAY_MS, zone) - 1
    if ev.prdOv == PRD_OVERRIDE_NONE and m.prd == PRD_PREV_QUARTER
        // The quarter before the release's, and one further back for a late
        // estimate: see QUARTER_LATE_DAYS.
        kind := 2
        int released = monthIndexOf(ev.ts, zone)
        index := int(math.floor(released / 3)) - 1
        if released % 3 == 0 and dayofmonth(ev.ts, zone) <= QUARTER_LATE_DAYS
            index -= 1
    if ev.prdOv == PRD_OVERRIDE_NONE and m.prd == PRD_NEAREST_MONTH
        // The month whose end is nearest the release. See NEAREST_MONTH_DAYS.
        kind := 1
        index := monthIndexOf(ev.ts - NEAREST_MONTH_DAYS * DAY_MS, zone)
    if ev.prdOv == PRD_OVERRIDE_NONE and m.prd == PRD_WEEK_TO_FRIDAY
        // The EIA's weekly series: the week ending the Friday before the
        // release, dated to that Friday (ARCHITECTURE section 7).
        kind := 3
        index := weekEndDay(ev.ts, zone, dayofweek.friday)
    if ev.prdOv == PRD_OVERRIDE_NONE and m.prd == PRD_WEEK_TO_SATURDAY
        // Initial jobless claims: the week ending the Saturday before.
        kind := 3
        index := weekEndDay(ev.ts, zone, dayofweek.saturday)
    if ev.prdOv == PRD_OVERRIDE_NONE and m.prd == PRD_WEEK_BEFORE_LAST
        // Continuing claims: the week before the one initial claims report in
        // the same release.
        kind := 3
        index := weekEndDay(ev.ts, zone, dayofweek.saturday) - 7
    if ev.prdOv == PRD_OVERRIDE_NONE and m.prd == PRD_RELEASE_DAY
        // A policy rate is dated to 00:00 UTC on the decision day (C17
        // probe). Every bank here announces on the same date in UTC as at
        // home, so the release's UTC day is the decision day.
        kind := 3
        index := int(math.floor(ev.ts / DAY_MS))
    [kind, index]

// 00:00 UTC on the last day of month `index`: where a monthly value is dated.
monthEndStamp(int index) =>
    int next = index + 1
    timestamp("UTC", int(math.floor(next / 12)), next % 12 + 1, 1, 0, 0) - DAY_MS

// Where the figure for a release is read, in UTC milliseconds: where
// TradingView dates its period. A month at 00:00 UTC on its last day, a
// quarter at the end of its last month, a day-named period at 00:00 UTC on
// that day. PRD 0 and 6 are read at the release itself: 6 is never shown, and
// 0 is left only on series with no period to name.
readTimeFor(Ev ev, Meta m) =>
    [kind, index] = referencePeriod(ev, m)
    int out = ev.ts
    if kind == 1
        out := monthEndStamp(index)
    if kind == 2
        out := monthEndStamp(index * 3 + 2)
    if kind == 3
        out := index * DAY_MS
    out

// The latest instant whose value the current bar is sure to hold.
//
// A DAILY BAR HOLDS WHAT IS DATED UP TO 00:00 UTC OF ITS TRADING DAY -
// measured, ARCHITECTURE section 7 consequences 9 and 10.
//
//   * intraday     its open. Spike 1, on 15-minute bars.
//   * daily        its trading day (time_tradingday). FX and CME open the
//                  evening before, so Friday's bar opens on Thursday evening
//                  and already holds what is dated Friday 00:00. Measured by
//                  the C21 probe, by two NG1! 1D re-checks and by the C23
//                  probe's daily bars on five charts. Until C22 the bar was
//                  read at its open, and a Friday Bank of Japan decision
//                  waited all weekend for Monday's bar.
//   * longer       NOT READ AT ALL (C24). What a weekly or monthly bar holds
//                  differs between markets and with where the bar opens (the
//                  C23 probe), so such a chart reads the daily bars inside
//                  each bar instead, each at its own trading day - dayClock()
//                  - and this returns the latest of them. C22 read a weekly
//                  bar at its open and C16 to C21 at its close; each was
//                  right on one market and wrong on another.
//
// Never later than the wall clock: a live daily FX bar opened on Thursday
// evening has not reached Friday until midnight.

// The read clock of daily bar `day` inside the current bar: what readClock()
// returns on that bar of a daily chart.
dayClock(int day) =>
    int opened = array.get(dayOpen, day)
    int traded = array.get(dayTrading, day)
    math.min(na(traded) ? opened : math.max(opened, traded), timenow)

readClock() =>
    int held = timeframe.isdaily and timeframe.multiplier == 1
         and not na(time_tradingday) ? math.max(time, time_tradingday) : time
    longBars and daysInBar() > 0 ? dayClock(daysInBar() - 1) : math.min(held, timenow)

readable(int at) =>
    readClock() >= at

// Per scoped occurrence, fixed on bar 0: where its figure is read, and which
// period it describes (kind * 1000000 + index, or -1 for none). The period
// keeps Previous from being taken from another release of the same period.
var array<int> readAt    = array.new<int>()
var array<int> refPeriod = array.new<int>()

// The scoped occurrences in the order their figures become readable. Month
// chunks are never sorted - the pipeline orders them (invariant 9) - but read
// times are not release times, so they need an order of their own: a current-
// month survey is read after later releases, a lagged series long before. This
// sorts a few hundred integers once, on bar 0.
var array<int> readOrder = array.new<int>()

if barstate.isfirst and array.size(scoped) > 0
    for i = 0 to array.size(scoped) - 1
        Ev ev = array.get(scoped, i)
        Meta m = array.get(keys, ev.key)
        array.push(readAt, readTimeFor(ev, m))
        [kind, index] = referencePeriod(ev, m)
        array.push(refPeriod, kind == 0 ? -1 : kind * 1000000 + index)
    readOrder := array.sort_indices(readAt, order.ascending)

// -- A bar that also holds the next period (C22; one read at a time, C25) ----
//
// A bar holds ONE value of a series: the latest dated up to what it holds. If
// the bar a read lands on also holds the key's NEXT period, it shows that
// period's figure, and no later bar holds this one's. Reading anyway would
// show another release's figure in this release's row - the kind of error
// this table must never make - so such a read is refused: that row shows the
// em dash, with reachTooltip() saying why.
//
// C22 wrote this for monthly charts, where every weekly series had four or
// five weeks in each bar. SINCE C24 NO CHART READS A BAR LONGER THAN A DAY, so
// two read points of one key can share a bar only where a stretch with no bars
// holds both: before a chart's first bar, on a chart whose history is shorter
// than the capture window (CAPTURE_MONTHS), or across a market closure of more
// than a week. A chart of bars longer than a day applies it to each daily bar
// inside, exactly as a daily chart does, so the two never disagree.
//
// ONLY THE READ IS REFUSED, NEVER THE KEY (C25). Until C25 one refusal marked
// the whole key and every row of the event showed the dash. On a chart whose
// history starts after the capture window - every 1- and 5-minute chart,
// 15-minute crypto on Premium, 1-hour on a 5,000-bar plan - the first bar
// reaches every earlier read point at once and refuses all but the last of
// each key, so every row of every event with a series showed the dash, the
// ones the chart reads perfectly well included. Now the refused rows show the
// dash, a row whose Previous was refused shows it in Prev. and Change, and
// every other row shows its figure. On a chart with the full history nothing
// is refused, so nothing changes there.
//
// The test needs the NEXT period of the key: where it is read (nextReadAt)
// and when it is first published (nextTs). Worked out once here, walking the
// key's occurrences backwards - `scoped`, then `afterWindow` beyond it. A
// later estimate of the same period has the same read point and is skipped:
// the next period is the next DIFFERENT one.
var array<int>  nextReadAt = array.new<int>()
var array<int>  nextTs     = array.new<int>()

// Per scoped occurrence: was its read refused? Set by the read cursor.
var array<bool> refused    = array.new<bool>()

// Where this chart's history begins: the clock of its first read step - its
// first bar's, or above a day the first daily bar's - and the month whose
// level that step holds. Set once, on the first step. A read point before
// chartFrom was never reached one bar at a time (C25).
var int chartFrom      = na
var int chartFromMonth = na

if barstate.isfirst
    int inScope = array.size(scoped)
    int total = inScope + array.size(afterWindow)
    int keyCount = array.size(keys)
    // Per key, while walking back: the period being walked (its read point
    // and its earliest release so far) and the period after it.
    array<int> curAt = array.new<int>(keyCount, na)
    array<int> curTs = array.new<int>(keyCount, na)
    array<int> aftAt = array.new<int>(keyCount, na)
    array<int> aftTs = array.new<int>(keyCount, na)
    refused := array.new<bool>(inScope, false)
    nextReadAt := array.new<int>(inScope, na)
    nextTs := array.new<int>(inScope, na)
    if total > 0
        for j = 0 to total - 1
            int idx = total - 1 - j
            bool shown = idx < inScope
            Ev ev = na
            int r = na
            if shown
                ev := array.get(scoped, idx)
                r := array.get(readAt, idx)
            if not shown
                ev := array.get(afterWindow, idx - inScope)
                r := readTimeFor(ev, array.get(keys, ev.key))
            int c = array.get(curAt, ev.key)
            int outAt = na
            int outTs = na
            if not na(c) and r == c
                outAt := array.get(aftAt, ev.key)
                outTs := array.get(aftTs, ev.key)
                array.set(curTs, ev.key, ev.ts)
            if not na(c) and r < c
                outAt := c
                outTs := array.get(curTs, ev.key)
                array.set(aftAt, ev.key, c)
                array.set(aftTs, ev.key, outTs)
            if na(c) or r < c
                array.set(curAt, ev.key, r)
                array.set(curTs, ev.key, ev.ts)
            if shown
                array.set(nextReadAt, idx, outAt)
                array.set(nextTs, idx, outTs)

// Whether the read of occurrence `index`, taken at read clock `clock`, would
// find its key's next period on the same bar. The next period counts only
// once it has been published; until then the bar's latest value is this one.
//
// `clock` is exact on every chart since C24 - an intraday bar's open, a daily
// bar's trading day - so there is no slack. Until C24 a weekly or monthly bar
// was read at its open, a day before its first trading day, and a day of
// slack covered the difference.
coarseRead(int index, int clock) =>
    int nxt = array.get(nextReadAt, index)
    not na(nxt) and array.get(nextTs, index) <= timenow and nxt <= clock

// -- derive: rates computed from index levels -------------------------------
//
// ARCHITECTURE section 2.5. Some fields publish an index LEVEL and no rate
// variant - Core PCE is the case that forced this, being the Fed's preferred
// inflation gauge and useless as a level. The rate is computed here from the
// series' own history.
//
// Levels are kept BY MONTH, not by release. Each is the value dated to that
// month's last day, taken on the first bar that reaches it, so:
//
//     mom = (level[month] / level[month - 1]  - 1) * 100
//     yoy = (level[month] / level[month - 12] - 1) * 100
//
// Until C16 the samples were a ring of the last thirteen RELEASES. That holds
// only while every release publishes exactly one month. The 2025 shutdown broke
// it: PCE for October and November came out together on 22 January 2026, so
// thirteen releases back from the September 2026 release reaches July 2025,
// and the "year-on-year" rate would have been a thirteen-month change.
var array<float> drvLevel = array.new<float>()   // derived keys x drvSpan
var array<int>   drvRow   = array.new<int>()     // per key: row, or -1
var int drvBase = 0                              // month index of column 0
var int drvSpan = 0                              // columns per row
var int drvLastMonth = -1                        // latest month end sampled

if barstate.isfirst and array.size(keys) > 0
    // The earliest month any capture can need: two months before the capture
    // window (the longest lag of a derived key), and twelve before that.
    drvBase := monthIndexOf(captureStart, "UTC") - 14
    drvSpan := monthIndexOf(windowEnd, "UTC") - drvBase + 1
    int rows = 0
    for i = 0 to array.size(keys) - 1
        bool derived = array.get(keys, i).drv != DRV_NONE
        array.push(drvRow, derived ? rows : -1)
        if derived
            rows += 1
            for c = 1 to drvSpan
                array.push(drvLevel, na)

drvAt(int key, int monthIdx) =>
    int row = array.get(drvRow, key)
    int col = monthIdx - drvBase
    row >= 0 and col >= 0 and col < drvSpan ? row * drvSpan + col : -1

drvGet(int key, int monthIdx) =>
    int at = drvAt(key, monthIdx)
    at >= 0 ? array.get(drvLevel, at) : na

drvSet(int key, int monthIdx, float level) =>
    int at = drvAt(key, monthIdx)
    if at >= 0
        array.set(drvLevel, at, level)

// The displayed value for a derived key in month `monthIdx`, or na until both
// levels exist. Below that the cell renders EMPTY, never zero: a zero would
// read as "unchanged", which is a statement about the economy rather than
// about how far back the chart reaches.
drvValue(Meta m, int key, int monthIdx) =>
    float now = drvGet(key, monthIdx)
    float ago = drvGet(key, monthIdx - (m.drv == DRV_MOM ? 1 : 12))
    not na(now) and not na(ago) and ago != 0 ? (now / ago - 1) * 100 : na

// -- Capture ----------------------------------------------------------------
//
// A cursor over readOrder, not a rescan. Walking every scoped occurrence on
// every bar would be tens of millions of comparisons across a 20,000-bar
// chart; the cursor makes the whole capture O(n) for the chart rather than
// O(n) per bar.
//
// A read point can be reached before its release is PUBLISHED - a chart loaded
// on 14 September passes 5 September, the end of the claims week released on
// the 17th, with the week before's value still in the series. Such a read is
// held back in `pending` and taken once the release has happened, from the
// series as it then stands, which is this release's value: nothing later is
// published until a later release.
//
// CAPTURE IS IDEMPOTENT, and has to be. A realtime bar runs the script once per
// tick. Pine rolls `var` state back to the last bar close before each run, but
// a release that lands while the chart is open can still be read on one tick
// and read again on the next. Until C11 "previous" came from a running
// per-key variable that the first read had already advanced, so the second
// read could record the new value as its own previous - Previous equal to
// Actual, Change a flat zero, and nothing to say it was wrong. Now:
//
//   * an occurrence's actual is written ONCE; a later read leaves it alone,
//     except the live correction in the fallback below
//   * previous is LOOKED UP from the stored actuals of that key's earlier
//     occurrences, so it cannot see the value being captured
//   * a derived level is set once per occurrence
//
// So capturing the same occurrence twice gives exactly what capturing it once
// does, on a live chart or read back from history.
var int readCursor = 0
var array<int> pending = array.new<int>()

// One flag per scoped occurrence: has its level gone into drvLevel?
var array<bool> sampled = array.new<bool>()

if barstate.isfirst and array.size(scoped) > 0
    for i = 0 to array.size(scoped) - 1
        array.push(sampled, false)

// Whether this chart cannot give occurrence `index` its figure (C25): its read
// was refused - coarseRead() - or it is a rate derived from index levels whose
// comparison level is dated before the first month end the chart reached
// (chartFromMonth), so the rate would be built from a level outside the chart.
// Either way the chart's own bars cannot supply it; reachTooltip() says so.
//
// A derived rate whose comparison month IS inside the chart but has no level
// is not this: TradingView had no value, and the cell stays empty as before.
outOfReach(int index) =>
    bool out = array.get(refused, index)
    int key = array.get(scoped, index).key
    Meta m = array.get(keys, key)
    if not out and m.drv != DRV_NONE and array.get(sampled, index)
         and na(array.get(actuals, index)) and not na(chartFromMonth)
        int ago = array.get(refPeriod, index) - 1000000
             - (m.drv == DRV_MOM ? 1 : 12)
        out := ago < chartFromMonth and na(drvGet(key, ago))
    out

// The occurrence Previous comes from, or -1: this key's latest earlier PERIOD
// that has a figure, or that this chart cannot read. Earlier occurrences whose
// value never arrived are skipped, and so is an earlier release of the same
// period: in the shutdown catch-up two releases can describe one month, and
// the second must not take the first as its previous.
//
// A period this chart cannot read STOPS the walk (C25). Skipped like a value
// that never arrived, it would put the period before it under "Prev." - on a
// short chart, a figure from two months back that looks right and is not.
priorIndex(int index) =>
    int key = array.get(scoped, index).key
    int period = array.get(refPeriod, index)
    int found = -1
    int j = index - 1
    while j >= 0 and found < 0
        if array.get(scoped, j).key == key
             and (period < 0 or array.get(refPeriod, j) != period)
             and (not na(array.get(actuals, j)) or outOfReach(j))
            found := j
        j -= 1
    found

// What this key printed for the latest earlier PERIOD before occurrence
// `index`, or na - na too when that period is one this chart cannot read.
previousFor(int index) =>
    int j = priorIndex(index)
    j >= 0 and not outOfReach(j) ? array.get(actuals, j) : na

// Record the value read for occurrence `index`. Safe to call any number of
// times for the same occurrence - see the note above.
//
// For a derived key the raw index is that month's level; scl still applies
// to it, and is 1 for every index level, so it is a no-op there - but it
// stays in the arithmetic rather than being special-cased away.
captureOccurrence(int index, Meta m, float raw) =>
    if na(array.get(actuals, index)) and not na(raw)
        array.set(previous, index, previousFor(index))
        if m.drv == DRV_NONE
            array.set(actuals, index, raw)
        else
            // Derived keys describe a month (a test in the pipeline pins it),
            // so their period is kind 1.
            int key = array.get(scoped, index).key
            int monthIdx = array.get(refPeriod, index) - 1000000
            if not array.get(sampled, index)
                array.set(sampled, index, true)
                drvSet(key, monthIdx, m.scl > 0 ? raw / m.scl : raw)
            array.set(actuals, index, drvValue(m, key, monthIdx))

// -- The read steps of a bar (C24) ------------------------------------------
//
// A bar of a day or less is read once: at readClock(), from its own values. A
// longer bar is read once per daily bar inside it, oldest first, each exactly
// as a daily chart reads that daily bar - at its trading day, from the values
// it holds. So a weekly or monthly chart takes every figure from the same
// daily bar a daily chart takes it from, and a weekly report on a monthly
// chart is read week by week.

// How many read steps the current bar has.
readSteps() =>
    longBars ? daysInBar() : 1

// The last step: the one that holds the latest values.
lastStep() =>
    longBars ? daysInBar() - 1 : 0

// The read clock of step `step`.
stepClock(int step) =>
    longBars ? dayClock(step) : readClock()

// Slot `slot`'s value at step `step`.
stepValue(int slot, int step) =>
    longBars ? dailyValue(slot, step) : slotValue(slot)

// Slot `slot`'s value as the bar holds it now: the chart's own bar, or above a
// day the latest daily bar inside it.
latestValue(int slot) =>
    stepValue(slot, lastStep())

// Read occurrence `index` from its series as step `step` of this bar holds it.
captureAt(int index, int step) =>
    Meta m = array.get(keys, array.get(scoped, index).key)
    int slot = slotFor(m)
    if slot >= 0
        captureOccurrence(index, m, stepValue(slot, step))

// Each step: derive's month-end levels, then the read cursor.
//
// THE LEVELS. The level of every derived key at each month end the chart
// passes. A level read before its month was published is the previous
// month's, and is corrected when that month's release is captured - see
// captureOccurrence.
//
// THE CURSOR. A read that reaches its key's next period too cannot give this
// one's figure, on this bar or any later one - see coarseRead() - and is
// refused, alone. Otherwise: published before this script ran, the series
// holds this release's value at its read point; not yet, hold it until the
// release.
int steps = readSteps()
if steps > 0
    for step = 0 to steps - 1
        int clock = stepClock(step)
        int monthReached = monthIndexOf(clock, "UTC")
             - (dayofmonth(clock + DAY_MS, "UTC") == 1 ? 0 : 1)
        if na(chartFrom)
            chartFrom := clock
            chartFromMonth := monthReached
        if monthReached > drvLastMonth and array.size(keys) > 0
            drvLastMonth := monthReached
            for k = 0 to array.size(keys) - 1
                Meta m = array.get(keys, k)
                if m.drv != DRV_NONE
                    int slot = slotFor(m)
                    if slot >= 0
                        float raw = stepValue(slot, step)
                        if not na(raw)
                            drvSet(k, monthReached, m.scl > 0 ? raw / m.scl : raw)
        if array.size(readOrder) > 0
            while readCursor < array.size(readOrder)
                  and clock >= array.get(readAt, array.get(readOrder, readCursor))
                int i = array.get(readOrder, readCursor)
                bool coarse = coarseRead(i, clock)
                if coarse
                    array.set(refused, i, true)
                if not coarse
                    if timenow >= array.get(scoped, i).ts
                        captureAt(i, step)
                    else
                        array.push(pending, i)
                readCursor += 1

// Held reads, taken once their release has happened. On a historical bar
// isReleased() is false for every one of them - each was pending because its
// release was after the script started - so this only ever reads live.
if array.size(pending) > 0
    int j = 0
    while j < array.size(pending)
        int i = array.get(pending, j)
        if isReleased(array.get(scoped, i).ts)
            captureAt(i, lastStep())
            array.remove(pending, j)
        else
            j += 1

// -- The late-publication fallback ------------------------------------------
//
// THIS IS WHAT DECIDES WHETHER A RELEASE APPEARS IN SECONDS OR ONLY ON RELOAD.
//
// The capture above reads a series at the release's read point. That assumes
// the figure is already published when that bar is processed. It is not
// always: TradingView's economic series can publish minutes after the release.
// PINE NEVER RECALCULATES A CLOSED HISTORICAL BAR, so a missed read stays blank
// until the user reloads the script. No error, no warning, just an empty cell
// on the one release they were watching.
//
// So on the last bar the latest past release of each key is given a second
// chance, reading the series as it stands now.
//
// THE GATES ARE UNCHANGED. The release must have happened - isReleased() - and
// its read point must have been reached - readable(). The second matters for a
// survey of the current month: until its month ends, the series' latest value
// is the previous month's, and filling the row with it would be the C15 bug.
// And its own read must not have been refused (coarseRead()): the series has
// moved on to a later period, so its latest value is another release's.
// Until C25 this skipped every release of a key with ANY refused read.
//
// On a chart of bars longer than a day the series "as it stands now" is the
// latest daily bar inside the last bar - latestValue() - and "the live bar"
// is that daily bar (clockClose()), so the fallback and the live correction
// behave exactly as on a daily chart (C24).
//
// ONE KEY, ONE PATCH. Reading the series on the last bar yields that series'
// LATEST value, which belongs to the most recent release and to no other. So
// the walk runs backwards and stops at the first past release of each key:
// that occurrence is the only one the current value can honestly be assigned
// to. An older gap stays a gap, because the number that would fill it is not
// available any more and a newer figure in an older row is a fabrication.
//
// THE LIVE CORRECTION. A read taken the moment a release is due can find the
// previous period's value still in the series - TradingView had not published
// yet - and it is stored like any other. Its signature is an Actual exactly
// equal to Previous. On a live bar such a row is read again, and replaced if
// the series now says something else; a genuinely unchanged print reads the
// same and stays. Only on a live bar: in Bar Replay the series' latest value
// can belong to a release the replay has not reached.
var array<bool> patched = array.new<bool>()

// Per key, the index of its latest past occurrence, or -1: the one row whose
// missing figure can still arrive. Read by awaitingData().
var array<int> latestPast = array.new<int>()

if barstate.isfirst and array.size(keys) > 0
    for i = 0 to array.size(keys) - 1
        array.push(patched, false)
        array.push(latestPast, -1)

// Replace a stale live read of occurrence `index` - see THE LIVE CORRECTION.
refreshOccurrence(int index, Meta m, float raw) =>
    if not na(raw)
        if m.drv == DRV_NONE
            float actual = array.get(actuals, index)
            if actual == array.get(previous, index) and raw != actual
                array.set(actuals, index, raw)
        else
            int key = array.get(scoped, index).key
            int monthIdx = array.get(refPeriod, index) - 1000000
            float level = m.scl > 0 ? raw / m.scl : raw
            float stored = drvGet(key, monthIdx)
            if stored == drvGet(key, monthIdx - 1) and level != stored
                drvSet(key, monthIdx, level)
                array.set(actuals, index, drvValue(m, key, monthIdx))

bool liveBar = barstate.islast and not na(clockClose()) and clockClose() >= timenow

if barstate.islast and array.size(scoped) > 0
    if array.size(patched) > 0
        array.fill(patched, false)
        array.fill(latestPast, -1)
    for j = 0 to array.size(scoped) - 1
        int i = array.size(scoped) - 1 - j
        Ev ev = array.get(scoped, i)
        // Same gate as displayActual(). The release is in the past.
        if isReleased(ev.ts) and not array.get(patched, ev.key)
            // The latest past occurrence of this key, captured or not. Marking
            // it either way is what stops an earlier gap being filled with a
            // later release's number.
            array.set(patched, ev.key, true)
            array.set(latestPast, ev.key, i)
            Meta m = array.get(keys, ev.key)
            int slot = slotFor(m)
            if slot >= 0 and readable(array.get(readAt, i))
                 and not array.get(refused, i)
                if na(array.get(actuals, i))
                    captureOccurrence(i, m, latestValue(slot))
                else if liveBar
                    refreshOccurrence(i, m, latestValue(slot))

// Previous is what was stored when the figure was captured, or - while a
// released figure is still to come - looked up now, so a row waiting for its
// figure (an hourglass) still shows the figure before it. C22.
priorOf(int index) =>
    float stored = array.get(previous, index)
    na(stored) ? previousFor(index) : stored

// -- Change -----------------------------------------------------------------
//
// Actual minus previous, in display units, carrying ITS OWN SIGN.
//
// Polarity never touches this number. It decides the colour and the words in
// the tooltip - verdictOf(), below - and nothing else. Until C11 the difference
// was multiplied by Meta.pol here, so every inverted event printed its move
// backwards: jobless claims rising from 198K to 199K showed "-1K", and a crude
// draw showed "+0.25M". The colours were right, which is exactly why it
// survived several reviews - a red "-1K" on claims looks deliberate.
//
// Returns na when either side is missing, which renders as an empty cell.
changeOf(int index, Meta m) =>
    float actual = array.get(actuals, index)
    float prior  = priorOf(index)
    float out = na
    if not na(actual) and not na(prior)
        // FROM THE FIGURES AS SHOWN (C23): each side as its own cell prints
        // it - the divisor applied and rounded to the event's decimals - so
        // Actual minus Previous on screen is the Change on screen. Until C23
        // the unrounded difference was rounded instead, and a reader saw Core
        // PCE (YoY) 3.0% / 2.9% / 0.0%, and a trade balance of 0.50B / 1.35B
        // with a change of -0.86B.
        float a = shownNumber(actual, m)
        float p = shownNumber(prior, m)
        out := a - p
    out

// Whether a change is good or bad news for the currency: the difference signed
// by the event's polarity, so positive reads stronger and negative weaker: a
// rising unemployment rate is a larger number and worse news. A neutral event
// (pol 0) keeps its raw direction, which is what its colour has always
// followed.
verdictOf(float delta, Meta m) =>
    na(delta) ? na : delta * (m.pol == 0 ? 1 : m.pol)

// The value to display for a scoped occurrence, gated on its release time.
//
// THE GATE IS THE POINT. Without isReleased(ev.ts) a historical re-render shows
// July payrolls on a 1 August bar, because the series is stamped 31 July. It
// throws nothing and looks entirely plausible - and since C16 it matters more:
// a figure read at its period end is often read BEFORE its release, and this
// gate is all that keeps it off the table until then.
displayActual(int index) =>
    Ev ev = array.get(scoped, index)
    isReleased(ev.ts) ? array.get(actuals, index) : na

displayPrevious(int index) =>
    Ev ev = array.get(scoped, index)
    isReleased(ev.ts) ? priorOf(index) : na

// Whether occurrence `index` is released and still waiting on TradingView for
// its figure - the middle of the Actual cell's states. C12.
//
// Deliberately narrower than "released and empty", because the tooltip
// promises the value is on its way and that must be true:
//
//   * only the LATEST past release of its key. The fallback can fill that one
//     and no other, so an older gap is a gap, not a wait.
//   * only with a request slot. An event truncated out of the request budget
//     is never read, so nothing is coming.
//   * only once its read point has passed. Before that the figure is not late,
//     it is not yet dated - see periodOpen().
//   * for a derived rate, only until its level arrives. After that
//     TradingView has published; the rate is blank because the chart does not
//     reach back a year, which is a different thing.
//
// An event with no field code has no slot, so it is never waiting either.
awaitingData(int index, Meta m) =>
    Ev ev = array.get(scoped, index)
    bool arrived = m.drv == DRV_NONE ? not na(array.get(actuals, index))
         : array.get(sampled, index)
    array.get(latestPast, ev.key) == index and slotFor(m) >= 0 and not arrived
         and readable(array.get(readAt, index))

// Whether a released survey of the current month is waiting for its month to
// end. C16.
//
// The Philadelphia Fed survey released on 17 September describes September,
// and TradingView dates it 30 September. Until then the series' latest value
// is August's, which is what the table showed in C15. The figure is out; it
// is not readable until its date. The row shows the hourglass until then.
periodOpen(int index, Meta m) =>
    Ev ev = array.get(scoped, index)
    isReleased(ev.ts) and slotFor(m) >= 0
         and not readable(array.get(readAt, index))

// Whether an occurrence's figures are WITHHELD rather than shown.
//
// C15 withheld every survey of the current month, until the probe measured
// how they are dated. It did (C16): to the end of their month, so they are now
// read there and shown.
//
// What remains withheld is what no source dates:
//
//   * PRD_WITHHELD - an event whose period could not be established. Its
//     taxonomy note says why for each.
//   * a divisor of 0 - an event added before TradingView's scale for its
//     series was measured (C21). A number off by a thousand is the same
//     confident error as one off by a month.
//   * a US release in the shutdown gap whose period is counted back from its
//     release date - see PRD_GAP_US_FROM.
//   * a month-on-month rate derived from an index level (DRV_MOM, C22).
//     TradingView carries a revision of the index for recent months only, so
//     two neighbouring months can come from different vintages. The C21
//     sitting's Core PCE (MoM) read 0.3% / -0.2% against a published 0.2% /
//     0.3%: July 2026 revised over June unrevised flipped Previous's sign. The
//     derive path for month-on-month rates is kept - drvValue() - for the day
//     the index can be trusted; nothing reaches it now.
//
// A number that may belong to the wrong period is the most dangerous kind: the
// right event, the right units, the right size. A visible gap is recoverable;
// a confident error is not.
withheldFigure(Ev ev, Meta m) =>
    m.prd == PRD_WITHHELD or m.scl <= 0 or m.drv == DRV_MOM or inShutdownGap(ev, m)

// Whether occurrence `index` is a later estimate of a period its key's
// previous occurrence already described - GDP's second and third estimates of
// a quarter, Michigan's final reading of a month. C21.
//
// TradingView keeps ONE value per period, the latest revision, so the earlier
// estimate this one revises cannot be shown. previousFor() skips it and would
// show the period BEFORE - Q1's growth under "Prev." on a Q2 third estimate -
// which reads as wrong to anyone comparing with the publisher, and makes
// Change a quarter-on-quarter difference nobody asked for. So Previous and
// Change show the em dash on such a row, with a tooltip that says why.
samePeriodAsBefore(int index) =>
    int key = array.get(scoped, index).key
    int period = array.get(refPeriod, index)
    bool out = false
    if period >= 0
        bool found = false
        int j = index - 1
        while j >= 0 and not found
            if array.get(scoped, j).key == key
                found := true
                out := array.get(refPeriod, j) == period
            j -= 1
    out

// Whether a release the clock says has happened falls after the chart's LAST
// BAR. C21.
//
// A figure is read from the chart's own bars, so a release with no bar after it
// cannot be read at all. On a live chart that never happens - its last bar is
// still open. It does on a symbol whose data has stopped: GEMINI:AUDUSD's daily
// bars end in March 2026, and every row after that showed three empty cells and
// no reason. It also does in Bar Replay, for every release after the replay
// point. Either way the row shows the em dash, with the last bar's date on
// hover, rather than cells that look broken.
beyondLastBar(Ev ev) =>
    barstate.islast and timenow >= ev.ts and not isReleased(ev.ts)
//#endregion [Actuals]

//#region [Render]
// ---------------------------------------------------------------------------
// The table and the alert.
//
// THIS SCRIPT DRAWS NOTHING ON THE PRICE PANE. It used to: markers, vertical
// lines, timestamp clustering, collision staggering and a 450-object cull, all
// of which worked and none of which survived. The calendar's value is the
// schedule and the accuracy of the figures beside it, and every one of those
// drawing features was competing with the chart for the same pixels while
// adding a budget to police, a cull to explain and four settings to tune.
// Removing them is a deliberate narrowing rather than a simplification: the
// table IS the product.
//
// EVERYTHING VISIBLE IS BUILT UNDER barstate.islast. A table cell written on
// every bar is written twenty thousand times to show one value. So the table
// is allocated once, outside the guard, and only written on the last bar.
//
// ONE TABLE, AND ITS CORNER EDGE CARRIES EVERYTHING THAT EXPLAINS IT (C21).
// Silent degradation is the failure pattern this project keeps finding, and a
// count in a header is not an explanation, so when the table cannot show
// everything a notice says in plain words what is missing and which setting
// fixes it. Until C21 the notices were a second table at the top centre of
// the chart, and a tall event table grew up into it and covered it.
//
// They are now full-width rows inside this table, on the edge at its corner,
// together with the headline - the range shown and how many events it holds -
// the Next line and the footer. TradingView anchors a table at its corner and,
// when the table is taller than the pane, cuts off the OTHER edge: on a
// bottom-right table the column titles and the earliest rows, never the
// bottom. So nothing that explains the table is on the edge that can be lost.
// Pine cannot read the pane's height, so there is no auto-fit; the Rows
// tooltip says what to do instead.
// ---------------------------------------------------------------------------

// The most EVENT rows the table can ever hold, so table.new() can be sized
// once. The user picks the actual number; this is only the ceiling.
//
// Pine tables have NO scrollbar and no scroll API, so there is no way to show
// seventeen rows in the space of eight. Letting the user set the height is the
// honest answer to that, rather than a fixed number that is wrong for
// somebody on every chart.
TABLE_ROW_CEILING = 50

// Rows for the events and the now divider between them.
EVENT_SLOTS = TABLE_ROW_CEILING + 1

// One row per notice, each condition in its own slot. Five can be live at once.
WARN_ROWS = 5

// Rows table.new() allocates: the event slots, the notices, and five more
// that are NOT charged against the user's setting - the column titles, their
// repeat under the last event (C23, bottom corners only), the Next countdown,
// the footer and the headline.
//
// EVERY ROW HAS A FIXED POSITION, worked out from the corner alone (see
// edgeAtTop). Pine renders only the cells that were written, so a notice slot
// with nothing to say, or event slots beyond the user's count, take no space
// and the table still shrinks to fit six events. The fixed positions are what
// make merging safe: TradingView cannot separate cells once they are merged,
// so a merged row must never be asked to hold an event later. Only the
// full-width rows are merged, and no event row ever lands on one of them.
TABLE_ROWS_ALLOCATED = EVENT_SLOTS + WARN_ROWS + 5

// Characters per line in a notice. A table cell does not wrap, so the prose is
// broken into lines here - about as wide as the event rows, so a notice never
// makes the table wider than its events do.
NOTICE_WIDTH = 64

// -- Presentation helpers ---------------------------------------------------

// How many EVENT rows the user asked for. Chrome is not charged against it.
tableRowCount() =>
    switch tableRows_
        "10" => 10
        "15" => 15
        "20" => 20
        "40" => 40
        "50" => 50
        => 30

// The fixed colour for an impact tier, from [Meta]. One constant drives the
// dot in the table and the tier's circle in the settings panel alike.
tierColor(int impact) =>
    switch impact
        4 => CLR_CRITICAL
        3 => CLR_HIGH
        2 => CLR_MEDIUM
        1 => CLR_LOW
        => CLR_HOLIDAY

// The tier's name, for the alert message. The table shows a coloured dot,
// which a notification cannot.
impactName(int impact) =>
    switch impact
        4 => "Critical"
        3 => "High"
        2 => "Medium"
        1 => "Low"
        => "Holiday"

// Time of day, in the chosen zone and the chosen format.
fmtClock(int at) =>
    timeFormat == "24 hour"
         ? str.format_time(at, "HH:mm", displayZone())
         : str.format_time(at, "hh:mm a", displayZone())

// An all-day event is a DATE, not an instant, and is shown as written. It
// decodes to 00:00 UTC on its day; formatted in the viewer's zone, every zone
// west of UTC pushed it to the evening before, so in the default New York
// zone every US market holiday showed a day early. Found in C16.
fmtWhen(Ev ev) =>
    ev.flags == FLAG_ALL_DAY
         ? str.format_time(ev.ts, "dd MMM", "UTC") + " all day"
         : str.format_time(ev.ts, "dd MMM", displayZone()) + "  " + fmtClock(ev.ts)

// A date for prose, where "07 Aug" alone would be ambiguous across years.
fmtLongDate(int at) =>
    str.format_time(at, "d MMM yyyy", displayZone())

// A date for prose, with its time when it is not midnight: "3 Oct 2026" or
// "3 Oct 2026 18:00". For the Custom range, whose hours count since C22.
fmtInstant(int at) =>
    fmtLongDate(at) + (at == startOfDay(at, displayZone()) ? "" : " " + fmtClock(at))

// The period a release describes: "Aug", "Q2", or "" for none.
//
// Only the RULE ships in the key table (Meta.prd); referencePeriod() in
// [Actuals] applies it to the release's own date, and the same answer decides
// where the figure is read - so the label and the figure cannot describe
// different months. The month name is formatted from a mid-month UTC
// timestamp, in UTC, so no timezone can push it across a month boundary.
periodLabel(Ev ev, Meta m) =>
    string out = ""
    // The shutdown gap - see PRD_GAP_US_FROM in [Meta].
    if not inShutdownGap(ev, m)
        [kind, index] = referencePeriod(ev, m)
        if kind == 1
            out := str.format_time(timestamp("UTC", int(math.floor(index / 12)),
                 index % 12 + 1, 15, 12, 0), "MMM", "UTC")
        if kind == 2
            out := "Q" + str.tostring(index % 4 + 1)
    out

// Which estimate of its period occurrence `index` is, as [n, certain]: n is 1
// for the first release of a period, 2 for the next release of the same
// period, and so on. C21.
//
// The count is CERTAIN only when the walk back meets this key's release of an
// EARLIER period - then every release of this period in between is in hand.
// If it runs out of decoded occurrences first, n is only a lower bound: the
// period's first release may lie before what was decoded. That cannot happen
// inside an ordinary window - the decode reaches CAPTURE_MONTHS back, and a
// quarter's estimates span three months - but it does at the start of the
// shipped horizon, where nothing earlier exists to decode. There a third
// estimate would count itself the second, and nothing would look wrong.
estimateNumber(int index) =>
    int key = array.get(scoped, index).key
    int period = array.get(refPeriod, index)
    int n = 1
    bool certain = false
    if period >= 0
        int j = index - 1
        while j >= 0 and not certain
            // Two ifs rather than if/else: the arms would end in an int and a
            // bool, and Pine requires both arms of an if/else to agree.
            if array.get(scoped, j).key == key
                certain := array.get(refPeriod, j) != period
                if not certain
                    n += 1
            j -= 1
    [n, certain]

// An event's name as the table shows it, with its period when it has one, and
// saying when it is a later estimate of that period:
// "Michigan Consumer Sentiment (Sep final)", "GDP Growth Rate (QoQ) (Q2 3rd
// est.)". C21.
//
// A survey of the month in progress released twice in its month is a
// preliminary and a final reading; anything else re-released for a period
// already out is a numbered estimate. Nothing in the record says so, and
// nothing needs to: the release's own period and the release before it are
// enough, so the record keeps its eleven characters. Such a row has no
// Previous and no Change - see samePeriodAsBefore().
//
// THE NUMBER IS SHOWN ONLY WHEN IT IS CERTAIN (see estimateNumber). Otherwise
// the label says "later est.", which is true whatever was not decoded. "final"
// needs no count: the Michigan survey publishes exactly two readings of a
// month, so a second release of the same month is the final one.
eventTitleAt(int index) =>
    Ev ev = array.get(scoped, index)
    Meta m = array.get(keys, ev.key)
    string tag = periodLabel(ev, m)
    [n, certain] = estimateNumber(index)
    string which = str.length(tag) == 0 or n <= 1 ? ""
         : m.prd == PRD_CURRENT_MONTH ? " final"
         : not certain ? " later est."
         : n == 2 ? " 2nd est." : n == 3 ? " 3rd est." : " " + str.tostring(n) + "th est."
    str.length(tag) > 0 ? m.name + " (" + tag + which + ")" : m.name

// The now divider's text: the day as well as the time, so the row adds
// information rather than only marking a boundary - "now · Mon 14 Sep 06:45".
// The weekday is dropped at Tiny, the narrowest setting, where the divider is
// already the widest cell in the Time column.
nowLabel() =>
    string day = str.format_time(timenow,
         tableScale == "Tiny" ? "dd MMM" : "EEE dd MMM", displayZone())
    "now · " + day + " " + fmtClock(timenow)

// Time until an event, as the largest useful unit.
countdown(int target) =>
    int left = target - timenow
    string out = ""
    if left > 0
        int days = int(math.floor(left / 86400000))
        int hours = int(math.floor((left % 86400000) / 3600000))
        int mins = int(math.floor((left % 3600000) / 60000))
        out := days > 0 ? str.tostring(days) + "d " + str.tostring(hours) + "h"
             : hours > 0 ? str.tostring(hours) + "h " + str.tostring(mins) + "m"
             : str.tostring(mins) + "m"
    out

// A value for display.
//
// fmtValue applies the SCL divisor and the thousands separators, which is
// right for a raw series value and wrong for a derived one - drvValue already
// divided by scl before taking the ratio, and the result is a percentage.
// Dividing again would be a silent second application.
fmtDisplay(float value, Meta m) =>
    m.drv == DRV_NONE
         ? fmtValue(value, m)
         : na(value) ? "" : fmtFixed(value, m.dec) + "%"

// A thousands separator for a plain count.
withCommas(int value) =>
    groupDigits(str.tostring(value))

// A change rounded to the event's own decimals - what the Change cell prints,
// and what its colour and tooltip go by, so a cell never reads "0.0" in green.
roundedChange(float value, Meta m) =>
    float shown = na(value) ? na : math.round(value, m.dec)
    // math.round(-0.01, 1) is a negative zero, which would print as "-0.0".
    na(shown) ? na : shown == 0 ? 0.0 : shown

// The Change column: signed, grouped, with the event's own decimals and the
// same unit as the value it was computed from.
//
// Without the unit a change of -1 on jobless claims reads as one person rather
// than one thousand. The comparison has to be dimensionally honest or it is
// worse than absent. Without fixed decimals a change of 0.04 on a one-decimal
// rate printed "+0%" - C21 prints "0.0%".
fmtChange(float value, Meta m) =>
    string out = ""
    if not na(value)
        string body = fmtFixed(value, m.dec)
        string suffix = m.unit == "idx" ? "" : m.unit
        out := (value > 0 ? "+" : "") + body
             + (str.length(suffix) > 0 and suffix != "Bcf" and suffix != "kbbl"
                    ? suffix : str.length(suffix) > 0 ? " " + suffix : "")
    out

// Green when a change is good news for the currency, red when it is bad,
// neutral at zero.
//
// Takes the VERDICT - verdictOf(), which applies Meta.pol - never the displayed
// difference. A rise in jobless claims is a positive number and a red cell.
changeColor(float value) =>
    na(value) or value == 0 ? color.new(CLR_MUTED, 0)
         : value > 0 ? color.new(#26a69a, 0) : color.new(#ef5350, 0)

// -- Events with no data feed -----------------------------------------------
//
// Twenty-three of the 128 events in this calendar have no series code. Two reasons,
// and the row is worth keeping in both:
//
//   * there is no number by nature - an FOMC press conference, a market
//     holiday, quarterly expiry, an OPEC meeting
//   * there is a number, and TradingView publishes no series for it - ISM
//     Services PMI, the Treasury auctions, the COT report, WASDE
//
// Either way the DATE is the information, and it is accurate. What was wrong
// was the presentation: three empty cells in a row of otherwise-populated ones
// reads as a broken script rather than as a deliberate absence.
//
// So the cells carry an em dash in the muted colour, and every one of them -
// Actual, Previous and Change - carries a hover saying which of the two it is
// (C23; until then only the Change cell did, with one wording for both).
// Absence stated is information; absence implied is a bug report.
hasFeed(Meta m) =>
    str.length(m.tvf) > 0

// Whether an event with no series has no number BY NATURE: the press
// conferences, the FOMC minutes, the US market holiday, quadruple witching and
// the OPEC meeting. In the key table these are exactly the events with no
// field code in the policy (POL), market structure (MKT) and energy (ENE)
// categories; every other event without one has a number TradingView does not
// carry. tests/test_c23.py holds this rule to the taxonomy, event by event.
noNumberByNature(Meta m) =>
    not hasFeed(m) and (m.cat == "POL" or m.cat == "MKT" or m.cat == "ENE")

// What such an event is, in a few words, for its hover.
eventKind(Meta m) =>
    str.contains(m.name, "Press Conference") ? "a press conference"
         : str.contains(m.name, "Minutes") ? "the written record of a meeting"
         : str.contains(m.name, "Holiday") ? "a day the market is closed"
         : str.contains(m.name, "Witching") ? "the quarterly expiry of index futures and options"
         : "a meeting"

// The hover on each dash of a row with no series. C23: two cases, in plain
// words.
noFigureTooltip(Meta m) =>
    noNumberByNature(m)
         ? "This event has no figure: it is " + eventKind(m) + ". Its date and time are what matter, and they are accurate."
         : "TradingView has no data for this event, so only its date and time are shown. They are accurate."

// Why a row with a data feed shows no figure. Two causes, one tooltip each.
TT_WITHHELD =
     "Which period this figure describes could not be established from a published source, so it is not shown. A number that may belong to the wrong month is worse than none.\n\n" +
     "The release date and time are accurate."

TT_UNMEASURED =
     "This event's figure is not shown yet: the scale TradingView uses for it has not been measured, and a number a thousand times out is worse than none.\n\n" +
     "The release date and time are accurate. The figure appears once the scale is measured and the schedule is next republished."

TT_SHUTDOWN =
     "The 2025 US government shutdown delayed and merged this release: from October 2025 to early May 2026 some releases reported a month or two late, or two months at once.\n\n" +
     "Which month this one reported cannot be told from its date, so its figures are not shown.\n\n" +
     "The release date and time are accurate."

TT_DERIVED_MOM =
     "TradingView publishes this index, not its monthly change, and the change cannot be worked out reliably from it: after a revision TradingView updates only the latest months, so two neighbouring months can come from different versions of the data and give the wrong figure.\n\n" +
     "The release date and time are accurate. The yearly rate is shown on its own row."

// A figure this chart cannot read - outOfReach() in [Actuals]. C25. It
// replaces the C22 wording, which blamed one bar spanning two releases: since
// C24 no bar does, and what is left is where the chart's history begins.
//
// One hover for a row's own figure and for its Previous: "this figure" is the
// one in the cell under the pointer. What to do depends on the chart. An
// intraday chart's history is cut by the plan's bar count, so a longer
// timeframe reaches further back: 4 hours reaches about two years back even
// on a 5,000-bar plan, so it is the shortest worth naming - 1 hour does only
// on Premium. A daily or longer chart's history is the symbol's own, and no
// timeframe reaches further.
//
// A read refused INSIDE the chart's history was refused over a closure - a
// market shut for more than a week - and says that instead.
TT_HISTORY = "This chart's history does not reach back to this figure"

reachTooltip(int index) =>
    bool closed = array.get(refused, index) and array.get(readAt, index) >= chartFrom
    string out = closed
         ? "This chart has no prices for a stretch long enough to hold this figure and the next one, so the two cannot be told apart, and this one is not shown."
         : not timeframe.isintraday ? TT_HISTORY + ": the symbol has no prices that far back."
         : timeframe.in_seconds() < 4 * 3600 ? TT_HISTORY + ". A longer timeframe, such as 4 hours or 1 day, shows it."
         : TT_HISTORY + ". A daily chart shows it."
    out + "\n\nThe release date and time are accurate."

withheldTooltip(Ev ev, Meta m) =>
    m.scl <= 0 ? TT_UNMEASURED : m.drv == DRV_MOM ? TT_DERIVED_MOM
         : m.prd == PRD_WITHHELD ? TT_WITHHELD : TT_SHUTDOWN

// The hourglass on a survey of the current month, released and waiting for
// its month to end - periodOpen() in [Actuals].
//
// A row with no period label is the other case (C21): a figure dated to
// 00:00 UTC on its own day - a rate decision - on a chart whose daily bar
// opened the evening before. Until C21 it got the survey wording, with a blank
// where the month should be.
//
// C22 added a third, for charts of bars longer than a day: a figure dated
// later in a weekly or monthly bar waited for the next bar. C24 removed it
// with the reads that caused it - such a chart now reads its daily bars, so
// its hourglasses are a daily chart's, for the same reasons.
periodOpenTooltip(int index, Meta m) =>
    Ev ev = array.get(scoped, index)
    string tag = periodLabel(ev, m)
    str.length(tag) == 0
         ? "TradingView dates this figure to 00:00 UTC on " + str.format_time(array.get(readAt, index), "d MMM yyyy", "UTC") + ". " +
              "This chart's bar for the day opened before that - its trading day starts the evening before - so the figure is read on the next bar, and the table fills it in by itself then.\n\n" +
              "The release date and time are accurate."
         : "This survey describes " + tag + ", and TradingView dates its figure to the last day of that month. " +
              "Until then the series still holds the previous month's value, which is not shown in its place.\n\n" +
              "The figure can be read from " + fmtLongDate(array.get(readAt, index)) + ", and the table fills it in by itself then.\n\n" +
              "The release date and time are accurate."

TT_AWAITING =
     "The release time has passed, but TradingView has not published this figure yet.\n\n" +
     "The schedule in this indicator is fixed and accurate. The figures come live from " +
     "TradingView's economic data, which can lag the official release.\n\n" +
     "The table updates itself when the value arrives. No action is needed."

// Previous and Change on a later estimate of a period already out -
// samePeriodAsBefore() in [Actuals]. C21.
TT_SAME_PERIOD =
     "This release is a later estimate of the same period as the release before it - a second or third estimate of a quarter, or a final reading of a month.\n\n" +
     "TradingView keeps only the latest estimate of each period, so the earlier estimate this one revises cannot be shown. The release before it in the table describes the same period, so there is nothing to compare against.\n\n" +
     "Actual is the latest estimate TradingView holds."

// The date and time of the chart's last bar, for the rows and notice that
// depend on it - beyondLastBar() in [Actuals]. C21. Above a day it is the
// latest daily bar's (clockOpen(), C24), so a weekly chart names the same day
// as a daily one.
lastBarText() =>
    str.format_time(clockOpen(), "d MMM yyyy", displayZone())
         + (timeframe.isintraday ? " " + fmtClock(clockOpen()) : "")

// "pair" on a currency pair, "symbol" on anything else - for the two texts
// below, which tell the reader what to search for.
sameWhat() =>
    chartIsPair ? "pair" : "symbol"

// The hover on each dash of a row released after the chart's last bar. C24:
// in the author's words - he found the C22 wording robotic, and "search for
// the same symbol" the only part he understood. "Broker" and "data feed" are
// the two generic words allowed here; no broker or provider is ever named.
beyondTooltip() =>
    "No figure: this chart has no prices after " + lastBarText() + ". Open the same " + sameWhat() + " from another broker or data feed to see it. In Bar Replay it appears once you replay past this release."

// Word-wrap prose to `width` characters a line. A table cell does not wrap by
// itself, and a notice on one line would stretch the table across the chart.
// Paragraphs ("\n\n") and line breaks are kept; a word longer than the width
// gets a line of its own. Runs on the last bar only, over a few sentences.
wrapText(string body, int width) =>
    array<string> paras = str.split(body, "\n")
    string out = ""
    if array.size(paras) > 0
        for p = 0 to array.size(paras) - 1
            array<string> words = str.split(array.get(paras, p), " ")
            string wrapped = ""
            string current = ""
            if array.size(words) > 0
                for w = 0 to array.size(words) - 1
                    string word = array.get(words, w)
                    if str.length(current) == 0
                        current := word
                    else if str.length(current) + 1 + str.length(word) > width
                        wrapped := wrapped + current + "\n"
                        current := word
                    else
                        current := current + " " + word
            out := out + (p > 0 ? "\n" : "") + wrapped + current
    out

// Whether instant `at` is the start of its day in `zone`.
atMidnight(int at, string zone) =>
    at == startOfDay(at, zone)

// The range the table is showing, in words: "28 Sep – 3 Oct 2026", or one
// date for a single day. C21: the headline states it in every Show mode, so a
// date the picker landed a month out is seen at a glance. A reversed Custom
// range shows the two as they were entered.
//
// C22: a Custom range states its HOURS when either end is not at midnight -
// "27 Sep 18:00 – 2 Oct 17:00 2026" - because the hours now count. The presets
// are whole days and never show them.
rangeText() =>
    string zone = displayZone()
    int a = customReversed ? requestedStart : windowStart
    int b = customReversed ? requestedEnd : windowEnd
    bool sameDay = str.format_time(a, "yyyyMMdd", zone) == str.format_time(b, "yyyyMMdd", zone)
    bool sameYear = year(a, zone) == year(b, zone)
    bool hours = timeWindow == "Custom" and not (atMidnight(a, zone) and atMidnight(b, zone))
    string out = sameDay ? str.format_time(a, "d MMM yyyy", zone)
         : str.format_time(a, sameYear ? "d MMM" : "d MMM yyyy", zone) + " – "
              + str.format_time(b, "d MMM yyyy", zone)
    if hours
        out := sameYear
             ? str.format_time(a, "d MMM", zone) + " " + fmtClock(a) + " – "
                  + str.format_time(b, "d MMM", zone) + " " + fmtClock(b) + " "
                  + str.format_time(b, "yyyy", zone)
             : str.format_time(a, "d MMM yyyy", zone) + " " + fmtClock(a) + " – "
                  + str.format_time(b, "d MMM yyyy", zone) + " " + fmtClock(b)
    out

// What a Change value means, as a per-cell tooltip.
//
// Three paragraphs: what happened, how it is usually read, and the caveat that
// it is a rule of thumb. Direction comes from Meta.pol, so a rise in
// unemployment or in jobless claims reads as weaker rather than stronger.
//
// IT NEVER NAMES THE CHART'S SYMBOL AND NEVER PREDICTS ITS DIRECTION. What a
// print means for a currency is information; what it means for the instrument
// in front of you is a trade call, and that does not belong in a published
// indicator.
changeTooltip(Meta m, float rawDelta, float signed) =>
    string out = ""
    if not na(rawDelta) and not na(signed)
        string moved = rawDelta > 0 ? "higher" : rawDelta < 0 ? "lower" : "unchanged"
        string swing = rawDelta > 0 ? "A rise" : "A fall"
        string force = signed > 0 ? "stronger" : "weaker"
        string bias  = signed > 0 ? "bullish" : "bearish"
        string cur   = currencyOf(m.region)

        out := m.name + " came in " + fmtChange(rawDelta, m) + " " + moved
             + " than the previous release.\n\n"
        if m.pol == 0
            out := out + "This release has no consistent direction - it is "
                 + "context rather than a signal for " + cur + ".\n\n"
        else
            out := out + swing + " here is usually read as " + force + " for "
                 + cur + ", which generally reads as " + bias
                 + " for that currency.\n\n"
        out := out + "This is a rule of thumb, not a prediction. Markets often "
             + "react to the gap against analyst forecasts, to revisions of "
             + "earlier data, or to other news landing at the same time, so "
             + "the actual move can go the other way."
    out

// -- Which rows the table lists ---------------------------------------------

var array<int> tableRows = array.new<int>()

if barstate.islast
    array.clear(tableRows)

    int total = array.size(scoped)
    int shown = displayCount()

    // Centred on the divider and WEIGHTED FORWARD: about a third of the budget
    // behind, the rest ahead. Recent releases carry actuals and are worth
    // keeping in view; what has not happened yet is what the calendar is for.
    //
    // THE BUDGET IS SPENT IN FULL WHENEVER THE EVENTS EXIST. The version this
    // replaces took `min(budget / 2, available past)` and then read forward,
    // which silently wasted the rest of the budget whenever one side ran out.
    // On a Friday afternoon with nothing left in the week that meant a
    // fifteen-row table showing SEVEN events out of eleven and cutting Monday
    // and Tuesday off the top - and the header said "7 shown", which is
    // truthful and reads as a window problem rather than an arithmetic one.
    int budget = tableRowCount()
    int first = 0
    if shown > 0
        // The first event at or after now. `total` when the whole window has
        // already fired, which is the case the old arithmetic got wrong.
        first := total
        for i = displayFrom to total - 1
            if first == total and array.get(scoped, i).ts >= timenow
                first := i

        // Never more rows than events, so six events render six rows.
        int take = math.min(budget, total - displayFrom)
        int futureRoom = total - first
        int back = math.min(int(math.floor(budget / 3)), first - displayFrom)

        // Not enough ahead to fill the rest? Reach further back rather than
        // leaving rows unspent. `take - futureRoom` can never exceed the past
        // available, because take is itself capped at the total.
        if take - back > futureRoom
            back := take - futureRoom

        int from = first - back
        if take > 0
            for i = from to from + take - 1
                array.push(tableRows, i)

// -- The table --------------------------------------------------------------

cornerOf() =>
    switch tableCorner
        "Bottom right" => position.bottom_right
        "Bottom left"  => position.bottom_left
        "Top right"    => position.top_right
        "Top left"     => position.top_left
        "Middle right" => position.middle_right
        => position.middle_left

tableTextSize() =>
    switch tableScale
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

// Which edge carries the headline, the notices, the Next line and the footer:
// the edge at the table's corner, the one TradingView never cuts off. A middle
// table is centred and can lose either edge, so it takes the top, where a
// headline reads first.
edgeAtTop() =>
    tableCorner != "Bottom right" and tableCorner != "Bottom left"

// The fixed rows, from the corner alone. On the bottom edge, top to bottom:
// column titles, events, the titles again, Next, notices, footer, headline. On
// the top edge the same block mirrored: headline, footer, notices, Next,
// column titles, events - and the repeat's slot, last, is never written there.
rowHeadline() =>
    edgeAtTop() ? 0 : TABLE_ROWS_ALLOCATED - 1
rowFooter() =>
    edgeAtTop() ? 1 : TABLE_ROWS_ALLOCATED - 2
rowNotice(int slot) =>
    edgeAtTop() ? 2 + slot : EVENT_SLOTS + 3 + slot
rowNext() =>
    edgeAtTop() ? 2 + WARN_ROWS : EVENT_SLOTS + 2
rowHeadings() =>
    edgeAtTop() ? 3 + WARN_ROWS : 0
rowFirstEvent() =>
    edgeAtTop() ? 4 + WARN_ROWS : 1

// The column titles again, directly under the last event row, on a bottom
// corner whose table is long (C23). A fixed row just past the last event slot:
// event slots the table does not fill are not rendered, so it sits right under
// the last event, above Next, the notices, the footer and the headline - the
// edge TradingView never cuts. A plain row, never merged.
rowHeadingsAgain() =>
    edgeAtTop() ? TABLE_ROWS_ALLOCATED - 1 : EVENT_SLOTS + 1

// -- When the column titles are repeated (C23) -------------------------------
//
// TradingView anchors a table at its corner and cuts the far edge when the
// table is taller than the chart: on a bottom corner, the column titles and
// the earliest rows. Pine cannot read the chart's height, so the script cannot
// know when that happens. The author's rule is titles at the top, and at the
// bottom only when the top is cut; the nearest the script can get is to repeat
// them under the last event whenever the table is long enough to be cut on a
// small screen.
//
// LONG = MORE LINES THAN A 13-INCH LAPTOP'S CHART HOLDS: about 26 at the
// default size, Small - lines of about 26 CSS pixels (the author's
// screenshots) in a chart about 700 pixels tall - scaled by the text sizes
// Pine documents for tables: Tiny 8 points, Small 10, Normal 14, Large 20. So
// 32, 26, 18 and 13 lines.
LONG_TABLE_LINES = 26

// The table's text size in points, as Pine's reference gives them.
textPoints() =>
    switch tableScale
        "Tiny"   => 8
        "Normal" => 14
        "Large"  => 20
        => 10

longTableLines() =>
    int(math.floor(LONG_TABLE_LINES * 10.0 / textPoints()))

// Created once. table.new() inside a barstate.islast block reallocates the
// whole table on every incoming trade. Created at its corner, too: the corner
// is an input, and changing an input runs the script again from the first bar.
// Until C22 the position was set again on every last-bar execution.
var table board = table.new(
     position     = cornerOf(),
     columns      = 8,
     rows         = TABLE_ROWS_ALLOCATED,
     border_color = color.new(#2a2e39, 0),
     border_width = 1)

// The full-width rows merged so far, as a set of row numbers.
//
// VAR, AND IT MUST STAY VAR (C22). The table is a `var` object, and
// TradingView rolls back every change to such an object made on an open bar
// before the next tick: "for objects of built-in or user-defined types with
// references assigned to var variables, the rollback process reverts any
// changes to those objects that occur on the open bar" (Pine's execution
// model). A merge made on a live bar is undone by the next trade. Until C22
// this record was VARIP, which rollback leaves alone: after the first tick it
// said "merged" while the table was not, so on a live chart the notice,
// headline and footer sat in the Time column alone - widening it to the
// notice's width - with the other seven cells of each row empty below the
// table. On a closed market the last bar runs once, which is why EURUSD on a
// Sunday looked right. A `var` record rolls back with the table, so the two
// always agree: a tick that finds a row unmerged merges it, and a bar that
// closes commits both. `gigi lint-pine` fails on a varip merge record.
var string mergedRows = ","

// -- What the notices say ---------------------------------------------------
//
// ARCHITECTURE section 4.1: every truncation is information, not an error.
// None blocks rendering and none is styled as a failure. Each says what
// happened, why, and what to change - one paragraph each. They are built on
// the last bar only, in a fixed order that is also their slot.

// How many listed rows are released by the clock with no bar after them.
beyondCount() =>
    int out = 0
    if array.size(tableRows) > 0
        for k = 0 to array.size(tableRows) - 1
            Ev ev = array.get(scoped, array.get(tableRows, k))
            if hasFeed(array.get(keys, ev.key)) and beyondLastBar(ev)
                out += 1
    out

noticeText(int slot) =>
    string out = ""
    if slot == 0 and array.size(tableRows) < displayCount()
        out := "Showing " + withCommas(array.size(tableRows)) + " of "
             + withCommas(displayCount()) + " events, the ones nearest now. "
             + "A table on a chart cannot scroll.\n\n"
             + "To see the others, set Show to a shorter period, or to Custom "
             + "with your own dates, or raise Rows in the Table section."
    if slot == 1 and customReversed
        out := "Nothing is listed: From (" + fmtInstant(requestedStart)
             + ") is after To (" + fmtInstant(requestedEnd) + ").\n\n"
             + "TradingView's date picker can land a month out when you click a "
             + "day. Check the month in both boxes under Show = Custom."
    if slot == 2 and windowClipped
        out := "Part of your range is outside the dates in this version: it "
             + "covers " + fmtLongDate(horizonStart) + " to "
             + fmtLongDate(horizonEnd) + ", so only that part is listed.\n\n"
             + "Pick dates inside it, or update the indicator when a newer "
             + "version is published - the dates are refreshed every three "
             + "months."
    if slot == 3 and typesUnserved > 0
        out := withCommas(typesUnserved)
             + (typesUnserved == 1 ? " event type shows its date" : " event types show their dates")
             + " with no figures: too many event types are on screen "
             + "for TradingView to show every figure.\n\n"
             + "Untick some currencies or impact levels in the settings and "
             + "the rest fill in."
    if slot == 4 and barstate.islast and beyondCount() > 0
        out := "No figures after " + lastBarText() + ": this chart has no "
             + "prices after that date, so there is nothing to read the "
             + "figures from.\n\n"
             + "To see them, open the same " + sameWhat() + " from another "
             + "broker or data feed: click the symbol name, search "
             + syminfo.ticker + " and pick one that is still trading.\n\n"
             + "If you are using Bar Replay, this is normal: each figure "
             + "appears once you replay past its release."
    out

// The first scoped event still to come, or -1: the Next line's event.
nextEventIndex() =>
    int found = -1
    if array.size(scoped) > 0
        for i = 0 to array.size(scoped) - 1
            if found < 0 and array.get(scoped, i).ts > timenow
                found := i
    found

// How many lines the table renders: every row it writes - the column titles,
// the events and the now divider, the Next line, each line of each wrapped
// notice (a paragraph break is a blank line) and the headline (the footer row
// went on 14 Oct 2026).
// C23: what longTableLines() is compared with. The repeat itself is left out:
// it is the answer, not part of the question.
renderedLines() =>
    bool divider = false
    if array.size(tableRows) > 0
        for k = 0 to array.size(tableRows) - 1
            if array.get(scoped, array.get(tableRows, k)).ts > timenow
                divider := true
    int lines = 2 + array.size(tableRows) + (divider ? 1 : 0)
         + (nextEventIndex() >= 0 ? 1 : 0)
    if showWarnings
        for slot = 0 to WARN_ROWS - 1
            string body = noticeText(slot)
            if str.length(body) > 0
                string wrapped = wrapText(body, NOTICE_WIDTH)
                lines += 1 + str.length(wrapped) - str.length(str.replace_all(wrapped, "\n", ""))
    lines

if barstate.islast
    // The rows that are rewritten every time are cleared first, so a row that
    // has stopped applying - an event that crossed the now line, a Next with
    // nothing left, titles a shorter table no longer repeats - disappears
    // rather than lingering from an earlier tick. Merged rows are never
    // cleared; see mergedRows.
    table.clear(board, 0, rowFirstEvent(), 7, rowFirstEvent() + EVENT_SLOTS - 1)
    table.clear(board, 0, rowHeadingsAgain(), 7, rowHeadingsAgain())
    table.clear(board, 0, rowNext(), 7, rowNext())

    // ---- the notices ----------------------------------------------------
    //
    // NOT gated on showTable. "Your dates are outside the data" is exactly
    // what somebody staring at an empty chart needs to read, so with the
    // table switched off the notices still appear, alone, at its corner.
    for slot = 0 to WARN_ROWS - 1
        string body = showWarnings ? noticeText(slot) : ""
        int row = rowNotice(slot)
        string key = str.tostring(row)
        bool merged = inSet(mergedRows, key)
        if str.length(body) > 0 or merged
            table.cell(board, 0, row, wrapText(body, NOTICE_WIDTH),
                 bgcolor = headerBg, text_color = headerText,
                 text_halign = text.align_left, text_size = tableTextSize())
            if not merged
                table.merge_cells(board, 0, row, 7, row)
                mergedRows := mergedRows + key + ","

if barstate.islast and showTable
    int budget = tableRowCount()

    // ---- the headline ----------------------------------------------------
    //
    // The range first, then the count. C21: the range is stated in every
    // Show mode, so a date the picker landed a month out is seen at once -
    // the author's From read 28 October for a week, and the table quietly
    // showed 3 to 28 October. "nearest to now" stops the count reading as a
    // defect: a table that says "1,818 events · 30 shown" invites the
    // question of WHICH thirty, and the honest answer is three words long.
    string headline = rangeText() + " · " + withCommas(displayCount())
         + (displayCount() == 1 ? " event" : " events")
    if array.size(tableRows) < displayCount()
        headline := headline + " · " + withCommas(array.size(tableRows))
             + " shown, nearest to now"
    // Then which data the chart is reading, and whose script it is (14 Oct
    // 2026, the author: the footer row went, to save a line). The data
    // version is the import line's (DATA_VERSION, held to it by `gigi
    // lint-pine`): it is how an out-of-date copy is told from an updated one.
    //
    // The name is a plain name and nothing else. No link, no product name, no
    // tagline, no call to action: TradingView's Vendor Requirements treat a
    // publication used as advertising as a serious violation, and
    // ARCHITECTURE section 8 keeps that prohibition while permitting the
    // author's name. The underscore form is the author's TradingView username
    // and matches the copyright line at the top of this file.
    headline := headline + " · v" + str.tostring(DATA_VERSION) + " · Gigi_Luigino"

    // ---- the headline row ------------------------------------------------
    //
    // Until 14 Oct 2026 a footer row under it carried "Data vN · built <date>
    // · Gigi_Luigino"; the version and the name now end the headline, and
    // rowFooter()'s slot is never written, so it takes no space.
    string hkey = str.tostring(rowHeadline())
    table.cell(board, 0, rowHeadline(), headline, bgcolor = headerBg,
         text_color = headerText, text_size = tableTextSize())
    if not inSet(mergedRows, hkey)
        table.merge_cells(board, 0, rowHeadline(), 7, rowHeadline())
        mergedRows := mergedRows + hkey + ","

    // ---- column titles ---------------------------------------------------
    array<string> heads = array.from("Time", "", "Currency", "Type", "Event",
         "Actual", "Prev.", "Change")
    for c = 0 to 7
        table.cell(board, c, rowHeadings(), array.get(heads, c), bgcolor = headerBg,
             text_color = headerText, text_size = tableTextSize())

    // ---- one row per listed event ----------------------------------------
    //
    // `row` is where we are writing; `eventRows` is what the budget counts.
    // They are deliberately different numbers. The now divider is chrome - it
    // is a boundary marker, not a release - and charging it against the user's
    // setting made a 15-row table show fourteen events and no explanation.
    int row = rowFirstEvent()
    int eventRows = 0
    bool dividerDone = false
    if array.size(tableRows) > 0
        for k = 0 to array.size(tableRows) - 1
            if eventRows < budget
                int i = array.get(tableRows, k)
                Ev ev = array.get(scoped, i)
                Meta m = array.get(keys, ev.key)

                // The now divider, carrying the current time so the row says
                // what it is rather than just marking a boundary. Written
                // immediately before the first row that is still to come, so
                // it can never end up dangling under an empty half.
                if not dividerDone and ev.ts > timenow
                    // Body text size and the body text colour, on a clearly
                    // different background. It is a divider, not a heading:
                    // the eye should catch the BAND, so the type stays the
                    // same size as the rows either side of it.
                    for c = 0 to 7
                        table.cell(board, c, row,
                             c == 0 ? nowLabel() : "",
                             bgcolor = rowDivider, text_color = rowText,
                             text_size = tableTextSize())
                    dividerDone := true
                    row += 1

                float actual = displayActual(i)
                float prior  = displayPrevious(i)
                // The difference as printed - rounded to the event's decimals
                // - and what it means for the currency. Only the second knows
                // about polarity.
                float delta   = roundedChange(isReleased(ev.ts) ? changeOf(i, m) : na, m)
                float verdict = verdictOf(delta, m)

                // The figure cells' states, in the order they win:
                //
                //   no feed      an event with no series: an em dash in all
                //                three, muted, rather than blanks that read as
                //                a bug
                //   withheld     its period cannot be established: em dash,
                //                and the reason on hover
                //   beyond       released by the clock with no bar after it on
                //                this chart (C21): em dash, the last bar's date
                //                on hover
                //   unreached    this chart cannot read the figure - its
                //                history does not reach back to it (C25;
                //                outOfReach()): em dash. Only for an event
                //                with a slot: one without is never read
                //   same period  a later estimate of a period already out
                //                (C21): Previous and Change are an em dash -
                //                TradingView keeps one value per period
                //   prior        released, its figure read, the Previous one
                //   unreached    not (C25): Previous and Change are an em dash
                //   waiting      released, its figure not in yet: hourglass
                //   the figure, or blank for a release still to come
                bool feed = hasFeed(m)
                bool withheld = feed and withheldFigure(ev, m)
                bool beyond = feed and not withheld and beyondLastBar(ev)
                bool served = feed and slotFor(m) >= 0
                bool unreached = served and not withheld and not beyond and outOfReach(i)
                bool figures = feed and not withheld and not beyond and not unreached
                bool samePeriod = figures and samePeriodAsBefore(i)
                int before = served and figures and not samePeriod and isReleased(ev.ts)
                     ? priorIndex(i) : -1
                bool priorUnreached = before >= 0 and outOfReach(before)
                color figureColor = figures ? rowText : color.new(CLR_MUTED, 0)
                bool monthOpen = figures and periodOpen(i, m)
                bool waiting = figures and not monthOpen and awaitingData(i, m)
                // Why a cell shows the em dash. Every dash has one (C23): a
                // row with no series says which of its two kinds it is.
                string blankWhy = not feed ? noFigureTooltip(m)
                     : withheld ? withheldTooltip(ev, m)
                     : beyond ? beyondTooltip() : unreached ? reachTooltip(i) : ""
                string priorWhy = priorUnreached ? reachTooltip(before) : ""

                table.cell(board, 0, row, fmtWhen(ev), bgcolor = rowBg,
                     text_color = rowText, text_size = tableTextSize())
                // The impact dot: U+25CF coloured by tier. Not an emoji - it
                // takes a text_color, keeps the row's font metrics, and is one
                // character rather than a surrogate pair.
                table.cell(board, 1, row, IMPACT_DOT, bgcolor = rowBg,
                     text_color = tierColor(ev.impact),
                     text_size = tableTextSize())
                // C21: on a currency-pair chart the far side's currency is in
                // bold, so its rows stand apart from the dollar's - see
                // pairRegions() in [Scope].
                table.cell(board, 2, row, currencyOf(m.region), bgcolor = rowBg,
                     text_color = rowText, text_size = tableTextSize(),
                     text_formatting = inSet(emphasisRegions, m.region)
                          ? text.format_bold : text.format_none)
                table.cell(board, 3, row,
                     colType ? categoryName(m.cat) : "", bgcolor = rowBg,
                     text_color = rowText, text_size = tableTextSize())
                // The event name carries its own description as a tooltip.
                // Hovering is the only place a calendar can explain what a
                // release actually measures without turning the table into
                // prose.
                table.cell(board, 4, row, eventTitleAt(i), bgcolor = rowBg,
                     text_color = rowText, text_size = tableTextSize(),
                     tooltip = m.desc)
                table.cell(board, 5, row,
                     colActual ? (not figures ? NO_DATA : monthOpen or waiting ? AWAITING : fmtDisplay(actual, m)) : "",
                     bgcolor = rowBg, text_color = figureColor,
                     text_size = tableTextSize(),
                     tooltip = not colActual ? "" : str.length(blankWhy) > 0 ? blankWhy
                          : monthOpen ? periodOpenTooltip(i, m)
                          : waiting ? TT_AWAITING : "")
                table.cell(board, 6, row,
                     colPrevious ? (not figures or samePeriod or priorUnreached ? NO_DATA : fmtDisplay(prior, m)) : "",
                     bgcolor = rowBg,
                     text_color = samePeriod or priorUnreached ? color.new(CLR_MUTED, 0) : figureColor,
                     text_size = tableTextSize(),
                     tooltip = not colPrevious ? "" : samePeriod ? TT_SAME_PERIOD
                          : priorUnreached ? priorWhy : blankWhy)
                table.cell(board, 7, row,
                     colChange ? (not figures or samePeriod or priorUnreached ? NO_DATA : fmtChange(delta, m)) : "",
                     bgcolor = rowBg,
                     text_color = figures and not samePeriod and not priorUnreached ? changeColor(verdict)
                          : color.new(CLR_MUTED, 0),
                     text_size = tableTextSize(),
                     tooltip = not colChange ? ""
                          : str.length(blankWhy) > 0 ? blankWhy
                          : samePeriod ? TT_SAME_PERIOD
                          : priorUnreached ? priorWhy
                          : changeTooltip(m, delta, verdict))
                row += 1
                eventRows += 1

    // ---- the column titles again, on a long table (C23) -------------------
    //
    // Bottom corners only: there the titles are on the edge TradingView cuts
    // when the table is taller than the chart, and the repeat sits on the edge
    // it never cuts. See longTableLines() for what "long" means.
    if not edgeAtTop() and renderedLines() > longTableLines()
        for c = 0 to 7
            table.cell(board, c, rowHeadingsAgain(), array.get(heads, c), bgcolor = headerBg,
                 text_color = headerText, text_size = tableTextSize())

    // ---- the countdown row -----------------------------------------------
    int nextIndex = nextEventIndex()
    if nextIndex >= 0
        Ev nextEv = array.get(scoped, nextIndex)
        Meta nextMeta = array.get(keys, nextEv.key)
        // Prefixed with "Next:" so it reads as a statement rather than as
        // another event row that happens to have a countdown in it.
        //
        // Currency and Type are filled from the same helpers the body rows
        // use, and Type honours the same column switch. They were blank until
        // C5, which left the row looking like a body row with two cells
        // missing - the one thing this table must never look like.
        table.cell(board, 0, rowNext(), "Next:", bgcolor = headerBg,
             text_color = headerText, text_size = tableTextSize())
        table.cell(board, 1, rowNext(), IMPACT_DOT, bgcolor = headerBg,
             text_color = tierColor(nextEv.impact), text_size = tableTextSize())
        for c = 2 to 7
            table.cell(board, c, rowNext(),
                 c == 2 ? currencyOf(nextMeta.region)
                      : c == 3 ? (colType ? categoryName(nextMeta.cat) : "")
                      : c == 4 ? eventTitleAt(nextIndex)
                      : c == 5 ? "in " + countdown(nextEv.ts) : "",
                 bgcolor = headerBg, text_color = headerText,
                 text_size = tableTextSize(),
                 text_formatting = c == 2 and inSet(emphasisRegions, nextMeta.region)
                      ? text.format_bold : text.format_none)

// -- The alert --------------------------------------------------------------
//
// ONE alert, and it reports rather than advises.
//
// A calendar with no alert is a calendar you have to remember to look at, which
// is the opposite of what a calendar is for. But an indicator that tells you
// which way to trade a release is a signal service, and this is not one: the
// message carries what is coming, in which currency, how big it usually is, and
// when - and stops there.
//
// alert() rather than alertcondition() because the message has to name the
// event. alertcondition() takes a compile-time constant string, so it could
// only ever say "an event is approaching" - true, and no use at all when four
// releases land at 08:30.
//
// Only events that pass the user's filters can fire, because `scoped` IS the
// filtered set, and only the display half - a lookback occurrence exists so
// Previous has something to read and is not something to be notified about.

alertLeadMinutes() =>
    switch alertLead
        "5"  => 5
        "30" => 30
        "60" => 60
        => 15

// The release time most recently alerted for.
//
// VARIP, and that is the whole guarantee against duplicates. A realtime bar runs
// the script once per tick, and a `var` is rolled back to its value at the last
// bar close before each of those runs - so a `var` guard forgets, on the very
// next tick, that it has already fired. The version this replaces hid that
// behind alert.freq_once_per_bar, which also capped the script at ONE alert per
// bar: on an hourly chart, payrolls, the unemployment rate and hourly earnings
// all due at 08:30 produced one message naming one of them, and nothing about
// the other two. A varip survives every tick, so alert.freq_all is safe.
varip int alertedTs = 0

// Each release time is alerted exactly once, as it enters the lead window, and
// the message names every event due at that time.
//
// Times are taken earliest first. Every event becomes alertable exactly `lead`
// before it is due, so events become alertable in the order of their times -
// which is why "later than the last time alerted" can never skip one. Several
// times can come due on the same tick, so the pass repeats, bounded, until
// none is left.
if barstate.isrealtime and displayFrom < array.size(scoped)
    int lead = alertLeadMinutes() * 60000
    for burst = 1 to 12
        int dueTs = na
        for i = displayFrom to array.size(scoped) - 1
            Ev ev = array.get(scoped, i)
            if ev.ts > timenow and ev.ts > alertedTs and ev.ts - timenow <= lead
                 and (na(dueTs) or ev.ts < dueTs)
                dueTs := ev.ts
        if na(dueTs)
            break
        string message = ""
        for i = displayFrom to array.size(scoped) - 1
            Ev ev = array.get(scoped, i)
            if ev.ts == dueTs
                Meta m = array.get(keys, ev.key)
                message := message + (str.length(message) > 0 ? "\n" : "")
                     + eventTitleAt(i) + "  ·  " + currencyOf(m.region)
                     + "  ·  " + impactName(ev.impact) + " impact  ·  "
                     + fmtWhen(ev)
        alert(message, alert.freq_all)
        alertedTs := dueTs
//#endregion [Render]
````
