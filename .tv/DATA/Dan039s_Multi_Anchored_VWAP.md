<!-- tradingview-pine-id: PUB;d6d10e0e9a5e417d9f3af0fe13043b59 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# Dan&#039;s Multi Anchored VWAP

Source: https://www.tradingview.com/script/ruOt6gtU-Multi-Anchored-VWAP-Automatic-Session-and-Custom-Anchors/

## Description

This indicator was built to remove the daily manual work involved in resetting multiple anchored VWAPs.

It automatically maintains a set of recurring VWAPs based on key market/session events, while also providing discretionary anchor slots for events or levels you want to track manually.

Default automatic VWAPs

Asia — 01:00 Europe/London
Frankfurt Open (FFO) — 07:00 Europe/London
London Open (LDO) — 08:00 Europe/London
New York Open — 09:30 America/New_York
Weekly — Friday 21:00 Europe/London
Gold Auction — 15:00 Europe/London, disabled by default

Each automatic VWAP continues running until its next scheduled anchor. For example, the New York VWAP remains active overnight and through the following European session, only resetting when the next New York cash open occurs.

Timezone-aware anchors

Each VWAP uses an explicit market/event timezone rather than the trader's local timezone. This means traders in different countries can use the same settings and see the same anchored VWAPs.

The timezone and anchor time for every automatic VWAP can also be changed from the settings menu.

IANA timezones such as Europe/London and America/New_York are used so daylight-saving changes are handled automatically.

Discretionary anchored VWAPs

Three additional custom VWAP slots are included and disabled by default.

Each custom VWAP allows you to specify:

Enable/disable
Custom name
Exact anchor date/time
Colour
Line thickness

These can be useful for anchoring from events such as CPI, FOMC, major highs/lows, news events, breakout points, or any other discretionary reference.

Unlike the automatic session VWAPs, custom VWAPs do not reset automatically and remain anchored until changed or disabled.

Visual settings

Each VWAP can be individually enabled or disabled and has configurable colour and line thickness.

Right-edge labels can also be customised for size, transparency and offset, making it easy to identify each VWAP directly on the chart.

Intended use

I mainly use this on NQ, ES and Gold for intraday context, mean-reversion/reference areas, confluence and tracking how price interacts with session and event-based value.

This indicator is intended as a charting/context tool rather than a standalone entry or trade signal.

---

## Source Code

````pine
//@version=6
indicator("Dan's Multi Anchored VWAP", shorttitle="AVWAP", overlay=true)

//=============================================================================
// GENERAL
//=============================================================================

groupGeneral = "General"

src = input.source(
     hlc3,
     "VWAP Source",
     group=groupGeneral)

showLabels = input.bool(
     true,
     "Show VWAP Labels",
     group=groupGeneral)

labelSizeInput = input.string(
     "Normal",
     "Label Size",
     options=["Small", "Normal", "Large"],
     group=groupGeneral)

labelOffset = input.int(
     3,
     "Label Offset (bars)",
     minval=1,
     maxval=20,
     group=groupGeneral)

labelTransparency = input.int(
     0,
     "Label Transparency",
     minval=0,
     maxval=90,
     group=groupGeneral)

labelSize = switch labelSizeInput
    "Small" => size.small
    "Large" => size.large
    => size.normal


//=============================================================================
// TIMEZONE OPTIONS
//=============================================================================
//
// These are market/event timezones, NOT the user's own timezone.
//
// Keeping the defaults means every user sees the same anchor event,
// regardless of where they live.
//
//=============================================================================


//=============================================================================
// AUTO VWAP — ASIA
//=============================================================================

groupAsia = "Auto VWAP — Asia"

showAsia = input.bool(
     true,
     "Show Asia VWAP",
     group=groupAsia)

asiaHour = input.int(
     1,
     "Anchor Hour",
     minval=0,
     maxval=23,
     group=groupAsia)

asiaMinute = input.int(
     0,
     "Anchor Minute",
     minval=0,
     maxval=59,
     group=groupAsia)

asiaTimezone = input.string(
     "Europe/London",
     "Anchor Timezone",
     options=[
         "Europe/London",
         "Europe/Berlin",
         "America/New_York",
         "America/Chicago",
         "America/Los_Angeles",
         "Asia/Tokyo",
         "Asia/Hong_Kong",
         "Asia/Singapore",
         "Australia/Sydney",
         "UTC"
     ],
     group=groupAsia)

asiaColor = input.color(
     color.aqua,
     "Colour",
     group=groupAsia)

asiaWidth = input.int(
     2,
     "Line Thickness",
     minval=1,
     maxval=5,
     group=groupAsia)


//=============================================================================
// AUTO VWAP — FRANKFURT
//=============================================================================

groupFFO = "Auto VWAP — Frankfurt"

showFFO = input.bool(
     true,
     "Show FFO VWAP",
     group=groupFFO)

ffoHour = input.int(
     7,
     "Anchor Hour",
     minval=0,
     maxval=23,
     group=groupFFO)

ffoMinute = input.int(
     0,
     "Anchor Minute",
     minval=0,
     maxval=59,
     group=groupFFO)

ffoTimezone = input.string(
     "Europe/London",
     "Anchor Timezone",
     options=[
         "Europe/London",
         "Europe/Berlin",
         "America/New_York",
         "America/Chicago",
         "America/Los_Angeles",
         "Asia/Tokyo",
         "Asia/Hong_Kong",
         "Asia/Singapore",
         "Australia/Sydney",
         "UTC"
     ],
     group=groupFFO)

ffoColor = input.color(
     color.orange,
     "Colour",
     group=groupFFO)

ffoWidth = input.int(
     2,
     "Line Thickness",
     minval=1,
     maxval=5,
     group=groupFFO)


//=============================================================================
// AUTO VWAP — LONDON
//=============================================================================

groupLDO = "Auto VWAP — London"

showLDO = input.bool(
     true,
     "Show LDO VWAP",
     group=groupLDO)

ldoHour = input.int(
     8,
     "Anchor Hour",
     minval=0,
     maxval=23,
     group=groupLDO)

ldoMinute = input.int(
     0,
     "Anchor Minute",
     minval=0,
     maxval=59,
     group=groupLDO)

ldoTimezone = input.string(
     "Europe/London",
     "Anchor Timezone",
     options=[
         "Europe/London",
         "Europe/Berlin",
         "America/New_York",
         "America/Chicago",
         "America/Los_Angeles",
         "Asia/Tokyo",
         "Asia/Hong_Kong",
         "Asia/Singapore",
         "Australia/Sydney",
         "UTC"
     ],
     group=groupLDO)

ldoColor = input.color(
     color.yellow,
     "Colour",
     group=groupLDO)

ldoWidth = input.int(
     2,
     "Line Thickness",
     minval=1,
     maxval=5,
     group=groupLDO)


//=============================================================================
// AUTO VWAP — NEW YORK
//=============================================================================

groupNY = "Auto VWAP — New York"

showNY = input.bool(
     true,
     "Show NY VWAP",
     group=groupNY)

nyHour = input.int(
     9,
     "Anchor Hour",
     minval=0,
     maxval=23,
     group=groupNY)

nyMinute = input.int(
     30,
     "Anchor Minute",
     minval=0,
     maxval=59,
     group=groupNY)

nyTimezone = input.string(
     "America/New_York",
     "Anchor Timezone",
     options=[
         "America/New_York",
         "America/Chicago",
         "America/Los_Angeles",
         "Europe/London",
         "Europe/Berlin",
         "Asia/Tokyo",
         "Asia/Hong_Kong",
         "Asia/Singapore",
         "Australia/Sydney",
         "UTC"
     ],
     group=groupNY)

nyColor = input.color(
     color.fuchsia,
     "Colour",
     group=groupNY)

nyWidth = input.int(
     2,
     "Line Thickness",
     minval=1,
     maxval=5,
     group=groupNY)


//=============================================================================
// AUTO VWAP — WEEKLY
//=============================================================================

groupWeekly = "Auto VWAP — Weekly"

showWeekly = input.bool(
     true,
     "Show Weekly VWAP",
     group=groupWeekly)

weeklyDayInput = input.string(
     "Friday",
     "Anchor Day",
     options=[
         "Monday",
         "Tuesday",
         "Wednesday",
         "Thursday",
         "Friday",
         "Saturday",
         "Sunday"
     ],
     group=groupWeekly)

weeklyHour = input.int(
     21,
     "Anchor Hour",
     minval=0,
     maxval=23,
     group=groupWeekly)

weeklyMinute = input.int(
     0,
     "Anchor Minute",
     minval=0,
     maxval=59,
     group=groupWeekly)

weeklyTimezone = input.string(
     "Europe/London",
     "Anchor Timezone",
     options=[
         "Europe/London",
         "Europe/Berlin",
         "America/New_York",
         "America/Chicago",
         "America/Los_Angeles",
         "Asia/Tokyo",
         "Asia/Hong_Kong",
         "Asia/Singapore",
         "Australia/Sydney",
         "UTC"
     ],
     group=groupWeekly)

weeklyColor = input.color(
     color.black,
     "Colour",
     group=groupWeekly)

weeklyWidth = input.int(
     2,
     "Line Thickness",
     minval=1,
     maxval=5,
     group=groupWeekly)


//=============================================================================
// AUTO VWAP — GOLD AUCTION
//=============================================================================

groupGold = "Auto VWAP — Gold Auction"

showGold = input.bool(
     false,
     "Show Gold Auction VWAP",
     group=groupGold)

goldHour = input.int(
     15,
     "Anchor Hour",
     minval=0,
     maxval=23,
     group=groupGold)

goldMinute = input.int(
     0,
     "Anchor Minute",
     minval=0,
     maxval=59,
     group=groupGold)

goldTimezone = input.string(
     "Europe/London",
     "Anchor Timezone",
     options=[
         "Europe/London",
         "Europe/Berlin",
         "America/New_York",
         "America/Chicago",
         "America/Los_Angeles",
         "Asia/Tokyo",
         "Asia/Hong_Kong",
         "Asia/Singapore",
         "Australia/Sydney",
         "UTC"
     ],
     group=groupGold)

goldColor = input.color(
     color.lime,
     "Colour",
     group=groupGold)

goldWidth = input.int(
     2,
     "Line Thickness",
     minval=1,
     maxval=5,
     group=groupGold)


//=============================================================================
// DISCRETIONARY VWAP 1
//=============================================================================

groupCustom1 = "Custom VWAP 1"

showCustom1 = input.bool(
     false,
     "Enable",
     group=groupCustom1)

custom1Name = input.string(
     "Custom 1",
     "Name",
     group=groupCustom1)

custom1Anchor = input.time(
     timestamp("01 Jan 2026 00:00 +0000"),
     "Anchor Date / Time",
     group=groupCustom1)

custom1Color = input.color(
     color.blue,
     "Colour",
     group=groupCustom1)

custom1Width = input.int(
     2,
     "Line Thickness",
     minval=1,
     maxval=5,
     group=groupCustom1)


//=============================================================================
// DISCRETIONARY VWAP 2
//=============================================================================

groupCustom2 = "Custom VWAP 2"

showCustom2 = input.bool(
     false,
     "Enable",
     group=groupCustom2)

custom2Name = input.string(
     "Custom 2",
     "Name",
     group=groupCustom2)

custom2Anchor = input.time(
     timestamp("01 Jan 2026 00:00 +0000"),
     "Anchor Date / Time",
     group=groupCustom2)

custom2Color = input.color(
     color.purple,
     "Colour",
     group=groupCustom2)

custom2Width = input.int(
     2,
     "Line Thickness",
     minval=1,
     maxval=5,
     group=groupCustom2)


//=============================================================================
// DISCRETIONARY VWAP 3
//=============================================================================

groupCustom3 = "Custom VWAP 3"

showCustom3 = input.bool(
     false,
     "Enable",
     group=groupCustom3)

custom3Name = input.string(
     "Custom 3",
     "Name",
     group=groupCustom3)

custom3Anchor = input.time(
     timestamp("01 Jan 2026 00:00 +0000"),
     "Anchor Date / Time",
     group=groupCustom3)

custom3Color = input.color(
     color.gray,
     "Colour",
     group=groupCustom3)

custom3Width = input.int(
     2,
     "Line Thickness",
     minval=1,
     maxval=5,
     group=groupCustom3)


//=============================================================================
// HELPER — RECURRING DAILY ANCHOR
//=============================================================================

f_dailyAnchor(
     string tz,
     int anchorHour,
     int anchorMinute) =>

    int anchorToday = timestamp(
         tz,
         year(time, tz),
         month(time, tz),
         dayofmonth(time, tz),
         anchorHour,
         anchorMinute)

    bool crossed =
         time >= anchorToday and
         (na(time[1]) or time[1] < anchorToday)

    crossed


//=============================================================================
// HELPER — WEEKDAY CONVERSION
//=============================================================================

f_weekday(string weekdayName) =>

    int selectedDay = switch weekdayName
        "Monday" => dayofweek.monday
        "Tuesday" => dayofweek.tuesday
        "Wednesday" => dayofweek.wednesday
        "Thursday" => dayofweek.thursday
        "Friday" => dayofweek.friday
        "Saturday" => dayofweek.saturday
        "Sunday" => dayofweek.sunday
        => dayofweek.friday

    selectedDay


//=============================================================================
// AUTOMATIC RESET EVENTS
//=============================================================================

asiaReset = f_dailyAnchor(
     asiaTimezone,
     asiaHour,
     asiaMinute)

ffoReset = f_dailyAnchor(
     ffoTimezone,
     ffoHour,
     ffoMinute)

ldoReset = f_dailyAnchor(
     ldoTimezone,
     ldoHour,
     ldoMinute)

nyReset = f_dailyAnchor(
     nyTimezone,
     nyHour,
     nyMinute)

goldReset = f_dailyAnchor(
     goldTimezone,
     goldHour,
     goldMinute)


//=============================================================================
// WEEKLY RESET
//=============================================================================

int selectedWeeklyDay = f_weekday(
     weeklyDayInput)

int weeklyAnchorToday = timestamp(
     weeklyTimezone,
     year(time, weeklyTimezone),
     month(time, weeklyTimezone),
     dayofmonth(time, weeklyTimezone),
     weeklyHour,
     weeklyMinute)

bool weeklyReset =
     dayofweek(time, weeklyTimezone) == selectedWeeklyDay and
     time >= weeklyAnchorToday and
     (na(time[1]) or time[1] < weeklyAnchorToday)


//=============================================================================
// CUSTOM RESET EVENTS
//=============================================================================

bool custom1Reset =
     time >= custom1Anchor and
     (na(time[1]) or time[1] < custom1Anchor)

bool custom2Reset =
     time >= custom2Anchor and
     (na(time[1]) or time[1] < custom2Anchor)

bool custom3Reset =
     time >= custom3Anchor and
     (na(time[1]) or time[1] < custom3Anchor)


//=============================================================================
// VWAP CALCULATIONS
//=============================================================================

asiaVWAP = ta.vwap(
     src,
     asiaReset)

ffoVWAP = ta.vwap(
     src,
     ffoReset)

ldoVWAP = ta.vwap(
     src,
     ldoReset)

nyVWAP = ta.vwap(
     src,
     nyReset)

weeklyVWAP = ta.vwap(
     src,
     weeklyReset)

goldVWAP = ta.vwap(
     src,
     goldReset)

custom1VWAP = ta.vwap(
     src,
     custom1Reset)

custom2VWAP = ta.vwap(
     src,
     custom2Reset)

custom3VWAP = ta.vwap(
     src,
     custom3Reset)


//=============================================================================
// PLOTS
//=============================================================================

plot(
     showAsia ? asiaVWAP : na,
     title="Asia VWAP",
     color=asiaColor,
     linewidth=asiaWidth)

plot(
     showFFO ? ffoVWAP : na,
     title="FFO VWAP",
     color=ffoColor,
     linewidth=ffoWidth)

plot(
     showLDO ? ldoVWAP : na,
     title="LDO VWAP",
     color=ldoColor,
     linewidth=ldoWidth)

plot(
     showNY ? nyVWAP : na,
     title="NY VWAP",
     color=nyColor,
     linewidth=nyWidth)

plot(
     showWeekly ? weeklyVWAP : na,
     title="Weekly VWAP",
     color=weeklyColor,
     linewidth=weeklyWidth)

plot(
     showGold ? goldVWAP : na,
     title="Gold Auction VWAP",
     color=goldColor,
     linewidth=goldWidth)

plot(
     showCustom1 ? custom1VWAP : na,
     title="Custom VWAP 1",
     color=custom1Color,
     linewidth=custom1Width)

plot(
     showCustom2 ? custom2VWAP : na,
     title="Custom VWAP 2",
     color=custom2Color,
     linewidth=custom2Width)

plot(
     showCustom3 ? custom3VWAP : na,
     title="Custom VWAP 3",
     color=custom3Color,
     linewidth=custom3Width)


//=============================================================================
// RIGHT-EDGE LABEL HELPER
//=============================================================================

f_updateLabel(
     label existingLabel,
     bool enabled,
     float value,
     string labelText,
     color labelColor) =>

    if not na(existingLabel)
        label.delete(existingLabel)

    label newLabel = na

    if barstate.islast and
       showLabels and
       enabled and
       not na(value)

        newLabel := label.new(
             bar_index + labelOffset,
             value,
             labelText,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_left,
             color=color.new(
                  labelColor,
                  labelTransparency),
             textcolor=color.white,
             size=labelSize)

    newLabel


//=============================================================================
// LABEL VARIABLES
//=============================================================================

var label asiaLabel = na
var label ffoLabel = na
var label ldoLabel = na
var label nyLabel = na
var label weeklyLabel = na
var label goldLabel = na

var label custom1Label = na
var label custom2Label = na
var label custom3Label = na


//=============================================================================
// UPDATE LABELS
//=============================================================================

asiaLabel := f_updateLabel(
     asiaLabel,
     showAsia,
     asiaVWAP,
     "Asia",
     asiaColor)

ffoLabel := f_updateLabel(
     ffoLabel,
     showFFO,
     ffoVWAP,
     "FFO",
     ffoColor)

ldoLabel := f_updateLabel(
     ldoLabel,
     showLDO,
     ldoVWAP,
     "LDO",
     ldoColor)

nyLabel := f_updateLabel(
     nyLabel,
     showNY,
     nyVWAP,
     "NY",
     nyColor)

weeklyLabel := f_updateLabel(
     weeklyLabel,
     showWeekly,
     weeklyVWAP,
     "Weekly",
     weeklyColor)

goldLabel := f_updateLabel(
     goldLabel,
     showGold,
     goldVWAP,
     "Gold Auction",
     goldColor)

custom1Label := f_updateLabel(
     custom1Label,
     showCustom1,
     custom1VWAP,
     custom1Name,
     custom1Color)

custom2Label := f_updateLabel(
     custom2Label,
     showCustom2,
     custom2VWAP,
     custom2Name,
     custom2Color)

custom3Label := f_updateLabel(
     custom3Label,
     showCustom3,
     custom3VWAP,
     custom3Name,
     custom3Color)
````
