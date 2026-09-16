<!-- tradingview-pine-id: PUB;0738d458c62b41079a07131847cb318c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ICT Everything v2

Source: https://www.tradingview.com/script/Isn8Ma7q-ICT-Everything-v2/

## Description

ICT Everything v2 is an open-source intraday charting toolkit for ICT-style time, liquidity, and displacement analysis.

The script combines related tools in one chart workflow. Sessions identify relevant trading windows, opening prices and prior-period levels provide liquidity context, gaps mark displacement areas, and SMT compares confirmed swings with a correlated market.

What it shows

[*]London, New York, London Close, afternoon, Asia, and custom sessions
[*]Midnight, New York, equities, afternoon, weekly, and monthly opening prices
[*]CBDR, FLOUT, and Asia ranges with configurable standard-deviation extensions
[*]Fair Value Gaps with consequent encroachment and fill handling
[*]New Week and New Day Opening Gaps with optional midpoint lines
[*]Previous week and previous month highs and lows
[*]Confirmed-pivot SMT divergence against a comparison symbol
[*]Day separators, day labels, session boxes, and selected confirmed-bar alerts

Why these tools are combined

The components share the same session and timezone context. This avoids building a chart from several unrelated scripts that may use different boundary definitions.

Sessions establish when activity occurs. Opening prices and prior-period levels mark reference liquidity. FVG, NWOG, and NDOG objects show displacement and reopening gaps. SMT adds relative-strength context by comparing the chart symbol with a correlated instrument over the same swing window.

This is a charting toolkit, not an entry system or strategy.

How to use it

The default configuration is intended for intraday charts. The script hides its drawings above a configurable ceiling, which defaults to 31 minutes.

The default timezone is New York and follows daylight-saving time automatically. Fixed UTC offsets are also available.

Most added modules are disabled by default. Enable only the features needed for the current analysis. Weekly and monthly opens, prior-period levels, FVGs, opening gaps, SMT, and session boxes can be enabled independently.

For SMT, select a positively correlated comparison symbol with similar trading hours. For example, NQ and ES generally provide cleaner comparisons than instruments with unrelated sessions.

Alerts use confirmed bars. TradingView alerts store the script version and settings that existed when the alert was created, so alerts should be recreated after a script update.

Boundary behavior

Continuous futures use locally captured evening-session boundaries for weekly and monthly opens. Crypto uses the standard UTC calendar boundaries: Monday 00:00 UTC for the week and the first day at 00:00 UTC for the month.

Broker sessions can differ, so users should verify opening levels against the instrument and feed they trade.

Meaningful changes in v2

The retained session and range foundation from the original script is credited below. V2 materially changes and extends that foundation with:

[*]Pine Script v6 support
[*]DST-aware New York session handling and additional timezone options
[*]Reworked weekly and monthly boundaries for futures and crypto
[*]Mechanical FVG, NWOG, and NDOG modules with bounded object retention
[*]Previous week and month high/low tracking
[*]Confirmed-pivot SMT using a same-window comparison method
[*]Session-box and high-low rendering modes
[*]Independent deviation counts for CBDR, FLOUT, and Asia
[*]Confirmed-bar alerts for range breaks, gaps, and prior-period sweeps
[*]Drawing cleanup and redraw changes that prevent stale objects and reduce unnecessary recalculation work

Open-source origin and credit

Based on ICT Everything by coldbrewrosh, formerly itsroshlol:
https://www.tradingview.com/script/T6KkMfK6-ICT-Everything/

Contains code from ArdOfCrypto's ICT Index Futures Vertical Lines:
https://www.tradingview.com/script/pTcmD9mD-ICT-Index-Futures-Vertical-Lines/

The original publication credited Shanxia as inspiration and thanked I_Am_ICT. Those acknowledgements are preserved.

This is an independently maintained derivative work. The credited authors do not endorse this publication. The source is published openly under the Mozilla Public License 2.0.

Limitations

This script does not predict market direction or promise trading performance. SMT depends on the selected comparison instrument and its available trading hours. Fixed-offset session choices do not adjust for daylight-saving time. Users remain responsible for confirming that the configured sessions match their market and data feed.

This publication is not affiliated with or endorsed by Inner Circle Trader, TradingView, or the credited authors.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Contains code from “ICT Index Futures Vertical Lines” © ArdOfCrypto:
// https://www.tradingview.com/script/pTcmD9mD-ICT-Index-Futures-Vertical-Lines/
// Based on “ICT Everything” © coldbrewrosh (formerly @itsroshlol):
// https://www.tradingview.com/script/T6KkMfK6-ICT-Everything/
// Modified, ported to Pine Script v6, and maintained as ICT Everything v2 by Stratinator, 2026.
// The original publication credited Shanxia as inspiration and thanked I_Am_ICT.
// Independent fork/derivative work; not endorsed by the credited authors.

//@version=6
indicator("ICT Everything v2", overlay=true, max_lines_count=500, max_labels_count=20, max_boxes_count=500)

// General Settings Inputs
TZI                     = input.string          (defval="New York", title="Timezone Selection", options=["New York", "UTC -10", "UTC -8", "UTC -7", "UTC -6", "UTC -5", "UTC -4", "UTC -3", "UTC +0", "UTC +1", "UTC +2", "UTC +3", "UTC +3:30", "UTC +4", "UTC +5", "UTC +5:30", "UTC +6", "UTC +7", "UTC +8", "UTC +9", "UTC +9:30", "UTC +10", "UTC +10:30", "UTC +11", "UTC +13", "UTC +13:45"], tooltip="Select the Timezone. ( Shifts Chart Elements ). New York follows DST automatically; the fixed UTC offsets do not.", group="Global Settings")
// "New York" maps to the IANA zone so NY-anchored elements follow DST; a fixed
// "UTC -5" default put midnight/killzones one hour late during US summer time
Timezone                = TZI                   == "New York" ? "America/New_York" : TZI == "UTC -10" ? "GMT-10:00" : TZI == "UTC -8" ? "GMT-08:00" : TZI == "UTC -7" ? "GMT-07:00" : TZI == "UTC -6" ? "GMT-06:00" : TZI == "UTC -5" ? "GMT-05:00" : TZI == "UTC -4" ? "GMT-04:00" : TZI == "UTC -3" ? "GMT-03:00" : TZI == "UTC +0" ? "GMT+00:00" : TZI == "UTC +1" ? "GMT+01:00" : TZI == "UTC +2" ? "GMT+02:00" : TZI == "UTC +3" ? "GMT+03:00" : TZI == "UTC +3:30" ? "GMT+03:30" : TZI == "UTC +4" ? "GMT+04:00" : TZI == "UTC +5" ? "GMT+05:00" : TZI == "UTC +5:30" ? "GMT+05:30" : TZI == "UTC +6" ? "GMT+06:00" : TZI == "UTC +7" ? "GMT+07:00" : TZI == "UTC +8" ? "GMT+08:00" : TZI == "UTC +9" ? "GMT+09:00" : TZI == "UTC +9:30" ? "GMT+09:30" : TZI == "UTC +10" ? "GMT+10:00" : TZI == "UTC +10:30" ? "GMT+10:30" : TZI == "UTC +11" ? "GMT+11:00" : TZI == "UTC +13" ? "GMT+13:00" : "GMT+13:45"
inputMaxInterval        = input.int             (31, title="Hide Indicator Above Specified Minutes", tooltip="Above 30Min, Chart Will Become Messy & Unreadable", group="Global Settings")
AlertFirstBreakOnly     = input.bool            (true, "Alert Once Per Session", tooltip="Session/level break alerts fire only on the first break per session (CBDR/Asia) or per week/month (previous week/month sweeps). Disable to alert on every re-cross.", group="Global Settings")
// Session options
ShowTSO                 = input.bool            (true, title="Show Today's Session Only", group="Session Options", tooltip="Hide Historical Sessions")
ShowTWO                 = input.bool            (true, title="Show Current Week's Sessions Only", group="Session Options", tooltip="Show All Sessions from the current week")
SL4W                    = input.bool            (true, title="Show Last 4 Week Sessions", group="Session Options", tooltip="Show All Sessions from Last Four Weeks \nShould Disable Current Week Session to Work")
ShowSFill               = input.bool            (false, title="Show Session Highlighting", group="Session Options", tooltip="Master switch for the Sessions group below - no session Highlight or Box renders while this is off")
//----------------------------------------------
// Historical Lines
ShowMOPL                = input.bool            (title="Midnight Historical Price Lines", defval=false, group="Historical Lines", tooltip="Shows Historical Midnight Price Lines")
MOLHist                 = input.bool            (title="Midnight Historical Vertical Lines", defval=true, group="Historical Lines", tooltip="Shows Historical Midnight Vertical Lines")
ShowPrev                = input.bool            (false, title="Misc. Historical Price Lines", group="Historical Lines", tooltip="Makes Chart Cluttered, Use For Backtesting Only")
//----------------------------------------------

// Session Bool
ShowLondon              = input.bool            (true, "", inline="LONDON", group="Sessions", tooltip="02:00 to 05:00")
ShowNY                  = input.bool            (true, "", inline="NY", group="Sessions", tooltip="07:00 to 10:00")
ShowLC                  = input.bool            (true, "", inline="LC", group="Sessions", tooltip="10:00 to 12:00")
ShowPM                  = input.bool            (true, "",inline="PM", group="Sessions", tooltip="13:00 to 16:00")
ShowAsian               = input.bool            (false, "",inline="ASIA2", group="Sessions", tooltip="20:00 to 00:00")
ShowFreeSesh            = input.bool            (false, "",inline="FREE", group="Sessions", tooltip="Custom Session")

// Session Strings
txt2                    = input.string          ("LONDON", title="", inline="LONDON", group="Sessions")
txt3                    = input.string          ("NEW YORK", title="", inline="NY", group="Sessions")
txt4                    = input.string          ("LDN CLOSE", title="", inline="LC", group="Sessions")
txt5                    = input.string          ("AFTERNOON", title="", inline="PM", group="Sessions")
txt6                    = input.string          ("ASIA", title="", inline="ASIA2", group="Sessions")
txt9                    = input.string          ("FREE SESH", title="", inline="FREE", group="Sessions")

// CBDR                = input.session         ('1600-2000:1234567', "", inline="CBDR", group="Sessions")
// ASIA                = input.session         ('2000-0000:1234567', "", inline="ASIA", group="Sessions")

// Session Times
LDNsesh                 = input.session         ('0200-0500:1234567', "", inline="LONDON", group="Sessions")
NYsesh                  = input.session         ('0700-1000:1234567', "", inline="NY", group="Sessions")
LCsesh                  = input.session         ('1000-1200:1234567', "", inline="LC", group="Sessions")
PMsesh                  = input.session         ('1300-1600:1234567', "", inline="PM", group="Sessions")
ASIA2sesh               = input.session         ('2000-2359:1234567', "", inline="ASIA2", group="Sessions")
FreeSesh                = input.session         ('0000-0000:1234567', "", inline="FREE", group="Sessions")
// Session Color
LSFC                    = input.color           (color.new(#787b86, 90), "", inline="LONDON", group="Sessions")
NYSFC                   = input.color           (color.new(#787b86, 90), "",inline="NY", group="Sessions")
LCSFC                   = input.color           (color.new(#787b86, 90), "",inline="LC", group="Sessions")
PMSFC                   = input.color           (color.new(#787b86, 90), "",inline="PM", group="Sessions")
ASFC                    = input.color           (color.new(#787b86, 90), "",inline="ASIA2", group="Sessions")
FSFC                    = input.color           (color.new(#787b86, 90), "",inline="FREE", group="Sessions")
LondonSeshRender        = input.string          ("Highlight", "", options=["Highlight", "Box"], inline="LONDON", group="Sessions")
NYSeshRender            = input.string          ("Highlight", "", options=["Highlight", "Box"], inline="NY", group="Sessions")
LCSeshRender            = input.string          ("Highlight", "", options=["Highlight", "Box"], inline="LC", group="Sessions")
PMSeshRender            = input.string          ("Highlight", "", options=["Highlight", "Box"], inline="PM", group="Sessions")
AsianSeshRender         = input.string          ("Highlight", "", options=["Highlight", "Box"], inline="ASIA2", group="Sessions")
FreeSeshRender          = input.string          ("Highlight", "", options=["Highlight", "Box"], inline="FREE", group="Sessions")
//----------------------------------------------

// Vertical Line Bool
ShowMOP                 = input.bool            (title="", defval=true, inline="MOP", group="Vertical Lines", tooltip="00:00 AM")
txt12                   = input.string          ("MIDNIGHT", title="", inline="MOP", group="Vertical Lines")
ShowLOP                 = input.bool            (title="", defval=false, inline="LOP", group="Vertical Lines", tooltip="03:00 AM")
txt14                   = input.string          ("LONDON", title="", inline="LOP", group="Vertical Lines")
ShowNYOP                = input.bool            (title="", defval=true, inline="NYOP", group="Vertical Lines", tooltip="08:30 AM")
txt15                   = input.string          ("NEW YORK", title="", inline="NYOP", group="Vertical Lines")
ShowEOP                 = input.bool            (title="", defval=false, inline="EOP", group="Vertical Lines", tooltip="09:30 AM")
txt16                   = input.string          ("EQUITIES", title="", inline="EOP", group="Vertical Lines")

// Vertical Line Color
MOPColor                = input.color           (color.new(#787b86, 0), "", inline="MOP", group="Vertical Lines")
LOPColor                = input.color           (color.rgb(0,128,128,60), "", inline="LOP", group="Vertical Lines")
NYOPColor               = input.color           (color.rgb(0,128,128,60), "", inline="NYOP", group="Vertical Lines")
EOPColor                = input.color           (color.rgb(0,128,128,60), "", inline="EOP", group="Vertical Lines")

// Vertical LineStyle
Midnight_Open_LS        = input.string          ("Dotted", "", options=["Solid", "Dashed", "Dotted"], inline="MOP", group="Vertical Lines")
london_Open_LS          = input.string          ("Solid", "", options=["Solid", "Dashed", "Dotted"], inline="LOP", group="Vertical Lines")
NY_Open_LS              = input.string          ("Solid", "", options=["Solid", "Dashed", "Dotted"], inline="NYOP", group="Vertical Lines")
Equities_Open_LS        = input.string          ("Solid", "", options=["Solid", "Dashed", "Dotted"], inline="EOP", group="Vertical Lines")

// Vertical LineWidth
Midnight_Open_LW        = input.string          ("1px", "", options=["1px","2px", "3px", "4px", "5px"], inline="MOP", group="Vertical Lines")
London_Open_LW          = input.string          ("1px", "", options=["1px","2px", "3px", "4px", "5px"], inline="LOP", group="Vertical Lines")
NY_Open_LW              = input.string          ("1px", "", options=["1px","2px", "3px", "4px", "5px"], inline="NYOP", group="Vertical Lines")
Equities_Open_LW        = input.string          ("1px", "", options=["1px","2px", "3px", "4px", "5px"], inline="EOP", group="Vertical Lines")
//----------------------------------------------

// Opening Price Bool
ShowMOPP                = input.bool            (title="", defval=true, inline="MOPP", group="Opening Price Lines", tooltip="00:00 AM")
txt13                   = input.string          ("MIDNIGHT", title="", inline="MOPP", group="Opening Price Lines")
ShowNYOPP               = input.bool            (title="", defval=false, inline="NYOPP", group="Opening Price Lines", tooltip="08:30 AM")
txt17                   = input.string          ("NEW YORK", title="", inline="NYOPP", group="Opening Price Lines")
ShowEOPP                = input.bool            (title="", defval=false, inline="EOPP", group="Opening Price Lines", tooltip="09:30 AM")
txt18                   = input.string          ("EQUITIES", title="", inline="EOPP", group="Opening Price Lines")
ShowAFTPP               = input.bool            (title="", defval=false, inline="AFTOPP", group="Opening Price Lines", tooltip="13:30 (01:30 PM)")
txt1330                 = input.string          ("AFTERNOON", title="", inline="AFTOPP", group="Opening Price Lines")

// Opening Price Color
MOPColP                 = input.color           (color.new(#787b86, 0), "", inline="MOPP", group="Opening Price Lines")
NYOPColP                = input.color           (color.new(#787b86, 0), "", inline="NYOPP", group="Opening Price Lines")
EOPColP                 = input.color           (color.new(#787b86, 0), "", inline="EOPP", group="Opening Price Lines")
AFTOPColP               = input.color           (color.new(#787b86, 0), "", inline="AFTOPP", group="Opening Price Lines")

// Opening Price LineStyle
MOPLS                   = input.string          ("Dotted", "", options=["Solid", "Dashed", "Dotted"], inline="MOPP", group="Opening Price Lines")
NYOPLS                  = input.string          ("Dotted", "", options=["Solid", "Dashed", "Dotted"], inline="NYOPP", group="Opening Price Lines")
EOPLS                   = input.string          ("Dotted", "", options=["Solid", "Dashed", "Dotted"], inline="EOPP", group="Opening Price Lines")
AFTOPLS                 = input.string          ("Dotted", "", options=["Solid", "Dashed", "Dotted"], inline="AFTOPP", group="Opening Price Lines")

// Opening Price LineWidth
i_MOPLW                 = input.string          ("1px", "", options=["1px","2px", "3px", "4px", "5px"], inline="MOPP", group="Opening Price Lines")
i_NYOPLW                = input.string          ("1px", "", options=["1px","2px", "3px", "4px", "5px"], inline="NYOPP", group="Opening Price Lines")
i_EOPLW                 = input.string          ("1px", "", options=["1px","2px", "3px", "4px", "5px"], inline="EOPP", group="Opening Price Lines")
i_AFTOPLW               = input.string          ("1px", "", options=["1px","2px", "3px", "4px", "5px"], inline="AFTOPP", group="Opening Price Lines")

//----------------------------------------------

// W&M Bool
ShowWeekOpen            = input.bool            (defval=false, title="", tooltip="Draw Weekly Open Price Line", group="HTF Opening Price Lines", inline="WO")
showMonthOpen           = input.bool            (defval=false, title="", tooltip="Draw Monthly Open Price Line", group="HTF Opening Price Lines", inline="MO")
ShowPrevWeekHL          = input.bool            (defval=false, title="", tooltip="Draw Previous Week High/Low lines", group="HTF Opening Price Lines", inline="PWHL")
ShowPrevMonthHL         = input.bool            (defval=false, title="", tooltip="Draw Previous Month High/Low lines", group="HTF Opening Price Lines", inline="PMHL")
ShowNWOG                = input.bool            (defval=false, title="", tooltip="Draw New Week Opening Gaps from prior Friday close to Sunday/Monday reopen", group="HTF Opening Price Lines", inline="NWOG")
ShowNWOGMid             = input.bool            (defval=true, title="CE", tooltip="Draw NWOG midpoint", group="HTF Opening Price Lines", inline="NWOG")
NWOGMaxCount            = input.int             (4, title="Max NWOGs", minval=1, maxval=20, group="HTF Opening Price Lines")
ShowNDOG                = input.bool            (defval=false, title="", tooltip="Draw New Day Opening Gaps from prior session close to next session reopen", group="HTF Opening Price Lines", inline="NDOG")
ShowNDOGMid             = input.bool            (defval=true, title="CE", tooltip="Draw NDOG midpoint", group="HTF Opening Price Lines", inline="NDOG")
NDOGMaxCount            = input.int             (5, title="Max NDOGs", minval=1, maxval=30, group="HTF Opening Price Lines")

// W&M String
txt19                   = input.string          ("WEEKLY", title="", inline="WO", group="HTF Opening Price Lines")
txt20                   = input.string          ("MONTHLY", title="", inline="MO", group="HTF Opening Price Lines")
txtPrevWeekHL           = input.string          ("PWH/PWL", title="", inline="PWHL", group="HTF Opening Price Lines")
txtPrevMonthHL          = input.string          ("PMH/PML", title="", inline="PMHL", group="HTF Opening Price Lines")
txtNWOG                 = input.string          ("NWOG", title="", inline="NWOG", group="HTF Opening Price Lines")
txtNDOG                 = input.string          ("NDOG", title="", inline="NDOG", group="HTF Opening Price Lines")

// W&M Color
i_WeekOpenCol           = input.color           (title="", defval=color.new(#787b86, 0), group="HTF Opening Price Lines", inline="WO")
i_MonthOpenCol          = input.color           (title="", tooltip="", defval=color.new(#787b86, 0), group="HTF Opening Price Lines", inline="MO")
i_PrevWeekHighCol       = input.color           (title="", defval=color.new(#26a69a, 0), group="HTF Opening Price Lines", inline="PWHL")
i_PrevWeekLowCol        = input.color           (title="", defval=color.new(#ef5350, 0), group="HTF Opening Price Lines", inline="PWHL")
i_PrevMonthHighCol      = input.color           (title="", defval=color.new(#26a69a, 0), group="HTF Opening Price Lines", inline="PMHL")
i_PrevMonthLowCol       = input.color           (title="", defval=color.new(#ef5350, 0), group="HTF Opening Price Lines", inline="PMHL")
i_NWOGCol               = input.color           (title="", defval=color.new(#787b86, 85), group="HTF Opening Price Lines", inline="NWOG")
i_NDOGCol               = input.color           (title="", defval=color.new(#787b86, 85), group="HTF Opening Price Lines", inline="NDOG")

// W&M LineStyle
WOLS                    = input.string          ("Dotted", "", options=["Solid", "Dashed", "Dotted"], inline="WO", group="HTF Opening Price Lines")
MOLS                    = input.string          ("Dotted", "", options=["Solid", "Dashed", "Dotted"], inline="MO", group="HTF Opening Price Lines")
NWOGMidLS               = input.string          ("Dotted", "", options=["Solid", "Dashed", "Dotted"], inline="NWOG", group="HTF Opening Price Lines")
NDOGMidLS               = input.string          ("Dotted", "", options=["Solid", "Dashed", "Dotted"], inline="NDOG", group="HTF Opening Price Lines")

// W&M LineWidth
i_WOPLW                 = input.string          ("1px", "", options=["1px","2px", "3px", "4px", "5px"], inline="WO", group="HTF Opening Price Lines")
i_MONPLW                = input.string          ("1px", "", options=["1px","2px", "3px", "4px", "5px"], inline="MO", group="HTF Opening Price Lines")
//----------------------------------------------

// Fair Value Gaps
ShowFVG                 = input.bool            (false, "Show FVG", group="Fair Value Gaps", tooltip="Mechanical chart-timeframe FVGs: bullish low > high[2], bearish high < low[2]")
FVGMaxCount             = input.int             (30, "Max FVGs", minval=1, maxval=100, group="Fair Value Gaps")
ShowFVGCE               = input.bool            (true, "Show CE", group="Fair Value Gaps", tooltip="Show FVG midpoint")
HideFilledFVG           = input.bool            (false, "Hide Filled", group="Fair Value Gaps")
FVGBullCol              = input.color           (color.new(color.green, 85), "Bullish", inline="FVGCOL", group="Fair Value Gaps")
FVGBearCol              = input.color           (color.new(color.red, 85), "Bearish", inline="FVGCOL", group="Fair Value Gaps")
//----------------------------------------------

// SMT Divergence
ShowSMT                 = input.bool            (false, "Show SMT", group="SMT Divergence", tooltip="Positive-corr pivots. Delayed by Pivot Length bars.")
SMTSymbol               = input.symbol          ("CME_MINI:ES1!", "Comparison", group="SMT Divergence", tooltip="Use a positively correlated symbol with the same trading hours as the chart. Mismatched sessions produce misleading divergences.")
SMTPivotLen             = input.int             (3, "Pivot Length", minval=1, maxval=20, group="SMT Divergence")
SMTMaxCount             = input.int             (10, "Max SMT Lines", minval=1, maxval=50, group="SMT Divergence")
SMTBullCol              = input.color           (color.new(#26a69a, 0), "Bullish", inline="SMTCOL", group="SMT Divergence")
SMTBearCol              = input.color           (color.new(#ef5350, 0), "Bearish", inline="SMTCOL", group="SMT Divergence")
//----------------------------------------------

// CBDR, ASIA & FLOUT
ShowCBDR                = input.bool            (true, "", inline='CBDR', group="CBDR, ASIA & FLOUT")
ShowASIA                = input.bool            (true, "", inline='ASIA', group="CBDR, ASIA & FLOUT")
ShowFLOUT               = input.bool            (false, "", inline='FLOUT', group="CBDR, ASIA & FLOUT")

// Strings
txt0                    = input.string          ("CBDR", title="", inline="CBDR", group="CBDR, ASIA & FLOUT", tooltip="16:00 to 20:00 \nSD Increments of 1")
txt1                    = input.string          ("ASIA", title="", inline="ASIA", group="CBDR, ASIA & FLOUT", tooltip="20:00 to 00:00 \nSD Increments of 1")
txt7                    = input.string          ("FLOUT", title="", inline="FLOUT", group="CBDR, ASIA & FLOUT", tooltip="16:00 to 00:00 \nSD Increments of 0.5")

// Color
CBDRBoxCol              = input.color           (color.new(#787b86, 0),"", inline='CBDR', group="CBDR, ASIA & FLOUT")
ASIABoxCol              = input.color           (color.new(#787b86, 0), "", inline='ASIA', group="CBDR, ASIA & FLOUT")
FLOUTBoxCol             = input.color           (color.new(#787b86, 0),"", inline='FLOUT', group="CBDR, ASIA & FLOUT")

// Extras
box_text_cbdr           = input.bool            (true, "Show Text", inline="CBDR", group="CBDR, ASIA & FLOUT")
box_text_cbdr_col       = input.color           (color.new(color.gray, 80), "", inline="CBDR", group="CBDR, ASIA & FLOUT")
bool_cbdr_dev           = input.bool            (true, "SD", inline="CBDR", group="CBDR, ASIA & FLOUT")

box_text_asia           = input.bool            (true, "Show Text", inline="ASIA", group="CBDR, ASIA & FLOUT")
box_text_asia_col       = input.color           (color.new(color.gray, 80), "", inline="ASIA", group="CBDR, ASIA & FLOUT")
bool_asia_dev           = input.bool            (true, "SD", inline="ASIA", group="CBDR, ASIA & FLOUT")

box_text_flout          = input.bool            (true, "Show Text", inline="FLOUT", group="CBDR, ASIA & FLOUT")
box_text_flout_col      = input.color           (color.new(color.gray, 80), "", inline="FLOUT", group="CBDR, ASIA & FLOUT")
bool_flout_dev          = input.bool            (true, "SD", inline="FLOUT", group="CBDR, ASIA & FLOUT")

// Table

// SD Lines
ShowDevLN               = input.bool            (title="", defval=true, inline="DEVLN", group="Standard Deviation", tooltip="Deviation Lines")
DEVLNTXT                = input.string          ("SD LINES", title="", inline="DEVLN", group="Standard Deviation")
DevLNCol                = input.color           (color.new(#787b86, 0), "", inline="DEVLN", group="Standard Deviation")
DEVLS                   = input.string          ("Solid", "", options=["Solid", "Dashed", "Dotted"], inline="DEVLN", group="Standard Deviation")
i_DEVLW                 = input.string          ("1px", "", options=["1px","2px", "3px", "4px", "5px"], inline="DEVLN", group="Standard Deviation")
DEVLSS                  = DEVLS=="Solid" ? line.style_solid : DEVLS == "Dotted" ? line.style_dotted : line.style_dashed
DEVLW                   = i_DEVLW=="1px" ? 1 : i_DEVLW == "2px" ? 2 : i_DEVLW == "3px" ? 3 : i_DEVLW == "4px" ? 4 : 5

ShowDev                 = input.bool            (false, '', inline="DEV", group="Standard Deviation")
txt8                    = input.string          ("SD COUNT", title="", inline="DEV", group="Standard Deviation")
SDCountCol              = input.color           (color.new(#787b86, 0), "", inline="DEV", group="Standard Deviation")
DevInput                = input.string          ("2 SD", "", options=["1 SD","2 SD", "3 SD", "4 SD"], inline="DEV", group="Standard Deviation")
DevDirection            = input.string          ("Both", "", options=["Upside Only","Both", "Downside Only"], inline="DEV", group="Standard Deviation", tooltip="SD Count, NULL, SD Count, SD Direction")
DevCount                = DevInput          ==  "1 SD" ? 1 : DevInput == "2 SD" ? 2 : DevInput == "3 SD" ? 3 : 4
CBDRDevOverride         = input.int             (0, "CBDR", minval=0, maxval=4, inline="D", group="Standard Deviation")
ASIADevOverride         = input.int             (0, "ASIA", minval=0, maxval=4, inline="D", group="Standard Deviation")
FLOUTDevOverride        = input.int             (0, "FLOUT", minval=0, maxval=4, inline="D", group="Standard Deviation")
CBDRDevCount            = CBDRDevOverride   == 0 ? DevCount : CBDRDevOverride
ASIADevCount            = ASIADevOverride   == 0 ? DevCount : ASIADevOverride
FLOUTDevCount           = FLOUTDevOverride  == 0 ? DevCount : FLOUTDevOverride

Auto_Select             = input.bool            (false, "", group="Standard Deviation", inline="AUTOSD", tooltip="Auto SD Selection | Charter Content, Range Table \nMight Bug Out On Mondays" )
txtSD                   = input.string          ("AUTO SD", "", group="Standard Deviation", inline="AUTOSD")
Tab1txtCol              = input.color           (color.new(#808080, 0), "", inline='AUTOSD', group="Standard Deviation")
TabOptionShow           = input.string          ("Show Table", "", options=["Show Table", "Hide Table"], inline="AUTOSD", group="Standard Deviation")
Stats                   = TabOptionShow     == "Show Table" ? true : false
TabOption1              = input.string          ("Top Right", "", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], inline="AUTOSD", group="Standard Deviation")
tabinp1                 = TabOption1        == "Top Left" ? position.top_left : TabOption1 == "Top Center" ? position.top_center : TabOption1 == "Top Right" ? position.top_right : TabOption1 == "Middle Left" ? position.middle_left : TabOption1 == "Middle Right" ? position.middle_right : TabOption1 == "Bottom Left" ? position.bottom_left : TabOption1 == "Bottom Center" ? position.bottom_center : position.bottom_right
L_Prof                  = true
CellBG                  = color.new(#131722, 100)

//----------------------------------------------
// Day Of Week & Labels
// Label Settings Inputs
ShowLabel               = input.bool            (true, title="", inline="Glabel", group="Day Of Week & Labels")
txt21                   = input.string          ("LABEL", title="", inline="Glabel", group="Day Of Week & Labels")
LabelColor              = input.color           (color.rgb(0,0,0,100), "", inline="Glabel", group="Day Of Week & Labels")
LabelSizeInput          = input.string          ("Normal", "", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], inline="Glabel", group="Day Of Week & Labels")
Terminusinp             = input.string          ("Terminus @ Current Time +1hr", "", options = ["Terminus @ Next Midnight","Terminus @ Current Time", "Terminus @ Current Time +15min", "Terminus @ Current Time +30min", "Terminus @ Current Time +45min", "Terminus @ Current Time +1hr", "Terminus @ Current Time +2hr", "Terminus @ Current Time +3hr"], inline="Glabel", group="Day Of Week & Labels", tooltip="Select Label Size & Color & Terminus \nHistorical Price Lines needs to be toggled off for using Terminus")

ShowLabelText           = input.bool            (true, title="", inline="label", group="Day Of Week & Labels")
txt22                   = input.string          ("LABEL TEXT", title="", inline="label", group="Day Of Week & Labels")
LabelTextColor          = input.color           (color.new(#787b86, 0), title="", inline="label", group="Day Of Week & Labels")
LabelTextOptioninput    = input.string          ("Time", "", options=["Time", "Text"], inline="label", group="Day Of Week & Labels", tooltip="Choose Between Descriptive Text as Label or Time \nShow/Hide Prices on Labels")
ShowPricesBool          = input.string          ("Hide Prices", title="", options=["Show Prices", "Hide Prices"], group="Day Of Week & Labels", inline="label")
ShowPrices              = ShowPricesBool    == "Show Prices" ? true : false

showDOW                 = input.bool            (true, title="", inline="DOW", group="Day Of Week & Labels")
txt24                   = input.string          ("DAY OF WEEK", title="", inline="DOW", group="Day Of Week & Labels")
i_DOWCol                = input.color           (color.new(#787b86, 0), title="", inline="DOW", group="Day Of Week & Labels")
DOWTime                 = input.int             (defval = 12, title="", inline="DOW", group="Day Of Week & Labels")
DOWLoc_inpt             = input.string          ("Bottom", "", options = ["Top", "Bottom"], inline="DOW", group="Day Of Week & Labels", tooltip="DOW Color, Time Alignment, Vertical Location")
DOWLoc                  = DOWLoc_inpt       == "Bottom" ? location.bottom : location.top
//----------------------------------------------

BIAS_M_Bool             = input.bool            (false, "", group="BIAS & NOTES PRECONFIG", inline="stats")
txt100                  = input.string          ("BIAS", title="", inline="stats", group="BIAS & NOTES PRECONFIG")
TableBG2                = color.new(#131722, 100)
Tab2txtCol              = input.color           (color.new(#787b86, 0), "", inline='stats', group="BIAS & NOTES PRECONFIG")
TabOption2              = input.string          ("Bottom Right", "", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], inline="stats", group="BIAS & NOTES PRECONFIG")
tabinp2                 = TabOption2        == "Top Left" ? position.top_left : TabOption2 == "Top Center" ? position.top_center : TabOption2 == "Top Right" ? position.top_right : TabOption2 == "Middle Left" ? position.middle_left : TabOption2 == "Middle Right" ? position.middle_right : TabOption2 == "Bottom Left" ? position.bottom_left : TabOption2 == "Bottom Center" ? position.bottom_center : position.bottom_right
NOTES_M_Bool            = input.bool            (true, "", group="BIAS & NOTES PRECONFIG", inline="stats2")
txt101                  = input.string          ("NOTES", title="", inline="stats2", group="BIAS & NOTES PRECONFIG")
Tab3txtCol              = input.color           (color.new(#787b86, 0), "", inline='stats2', group="BIAS & NOTES PRECONFIG")
TabOption3              = input.string          ("Top Center", "", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], inline="stats2", group="BIAS & NOTES PRECONFIG")
tabinp3                 = TabOption3        == "Top Left" ? position.top_left : TabOption3 == "Top Center" ? position.top_center : TabOption3 == "Top Right" ? position.top_right : TabOption3 == "Middle Left" ? position.middle_left : TabOption3 == "Middle Right" ? position.middle_right : TabOption3 == "Bottom Left" ? position.bottom_left : TabOption3 == "Bottom Center" ? position.bottom_center : position.bottom_right

BIASbool1               = input.bool            (true, '', inline="BIAS1", group="BIAS & NOTES")
txt52                   = input.string          ("DXY ", title="", inline="BIAS1", group="BIAS & NOTES")
BIASOption1             = input.string          ("Bullish", options=["Bullish", "Bearish", "Consolidating", "Unclear"], title="", inline="BIAS1", group="BIAS & NOTES")

BIASbool2               = input.bool            (true, '', inline="BIAS2", group="BIAS & NOTES")
txt53                   = input.string          ("EURGBP ", title="", inline="BIAS2", group="BIAS & NOTES")
BIASOption2             = input.string          ("Bearish", options=["Bullish", "Bearish", "Consolidating", "Unclear"], title="", inline="BIAS2", group="BIAS & NOTES")

BIASbool3               = input.bool            (true, '', inline="BIAS3", group="BIAS & NOTES")
txt54                   = input.string          ("AUDNZD ", title="", inline="BIAS3", group="BIAS & NOTES")
BIASOption3             = input.string          ("Bullish", options=["Bullish", "Bearish", "Consolidating", "Unclear"], title="", inline="BIAS3", group="BIAS & NOTES")

BIASbool4               = input.bool            (true, '', inline="BIAS4", group="BIAS & NOTES")
txt55                   = input.string          ("NASDAQ ", title="", inline="BIAS4", group="BIAS & NOTES")
BIASOption4             = input.string          ("Bearish", options=["Bullish", "Bearish", "Consolidating", "Unclear"], title="", inline="BIAS4", group="BIAS & NOTES")
notes                   = input.text_area       ("ICT Everything v2 by Stratinator", "Notes", group = "BIAS & NOTES")



//--------------------END OF INPUTS--------------------//

// Pre-Def
DOM                     = (timeframe.multiplier <= inputMaxInterval) and (timeframe.isintraday)
newDay                  = ta.change(dayofweek) != 0
newMonth                = ta.change(time("M")) != 0
calendarWeekChange      = ta.change(time("W")) != 0

transparentcol          = color.rgb(255,255,255,100)

LSVLC                   = color.rgb(255,255,255,100)
NYSVLC                  = color.rgb(255,255,255,100)
PMSVLC                  = color.rgb(255,255,255,100)
ASVLC                   = color.rgb(255,255,255,100)

LSVLS                   = "dotted"
NYSVLS                  = "dotted"
PMSVLS                  = "dotted"
ASVLS                   = "dotted"

// Functions
// Anchored to last_bar_time, not timenow: timenow is wall-clock even in Bar Replay,
// which hid every "today"/"last 4 weeks" element at historical replay points
// Current Week
thisweek = year(last_bar_time) == year(time) and weekofyear(last_bar_time) == weekofyear(time)
LastOneWeek = year(last_bar_time) == year(time) and weekofyear(last_bar_time-604800000) == weekofyear(time)
LastTwoWeek = year(last_bar_time) == year(time) and weekofyear(last_bar_time-1209600000) == weekofyear(time)
LastThreeWeek = year(last_bar_time) == year(time) and weekofyear(last_bar_time-1814400000) == weekofyear(time)
LastFourWeek = year(last_bar_time) == year(time) and weekofyear(last_bar_time-2419200000) == weekofyear(time)
Last4Weeks = false
if thisweek == true or LastOneWeek == true or LastTwoWeek == true or LastThreeWeek == true or LastFourWeek == true
    Last4Weeks := true

// Function to draw Vertical Lines
vline(Start, Color, linestyle, LineWidth) =>
    line.new(x1=Start, y1=low - ta.tr, x2=Start, y2=high + ta.tr, xloc=xloc.bar_time, extend=extend.both, color=Color, style=linestyle, width=LineWidth)

// Function to convert forex pips into whole numbers
atr = ta.atr(14)
toWhole(number) =>
    if syminfo.type == "forex" // This method only works on forex pairs
        _return = atr < 1.0 ? (number / syminfo.mintick) / 10 : number
        _return := atr >= 1.0 and atr < 100.0 and syminfo.currency == "JPY" ? _return * 100 : _return
    else
        number

// Function for determining the Start of a Session (taken from the Pinescript manual: https://www.tradingview.com/pine-script-docs/en/v5/concepts/Sessions.html )
SessionBegins(sess) =>
    t = time("", sess , Timezone)
    DOM and (not barstate.isfirst) and na(t[1]) and not na(t)

// BarIn Session
BarInSession(sess) =>
    time(timeframe.period, sess, Timezone) != 0

SessionBox(show, mode, sess, startTime, endTime, fillColor, seshBox, seshHi, seshLo) =>
    box nextBox = seshBox
    float nextHi = seshHi
    float nextLo = seshLo
    bool boxMode = ShowSFill and show and mode == "Box" and DOM
    if boxMode and SessionBegins(sess)
        nextHi := high
        nextLo := low
        if ShowTSO
            box.delete(nextBox[1])
        nextBox := box.new(left=startTime, top=nextHi, right=endTime, bottom=nextLo, xloc=xloc.bar_time, border_color=fillColor, bgcolor=fillColor)
    else if boxMode and BarInSession(sess) and not na(nextBox)
        nextHi := math.max(high, nextHi)
        nextLo := math.min(low, nextLo)
        box.set_top(nextBox, nextHi)
        box.set_bottom(nextBox, nextLo)
    else if not boxMode and not na(nextBox)
        box.delete(nextBox)
        nextBox := na
        nextHi := na
        nextLo := na
    [nextBox, nextHi, nextLo]

// Label Type Logic
var SFistrue = true
if LabelTextOptioninput == "Time"
    SFistrue := true
else
    SFistrue := false


// Session String to int
SeshStartHour(Session) =>
    math.round(str.tonumber(str.substring(Session,0,2)))
SeshStartMins(Session) =>
    math.round(str.tonumber(str.substring(Session,2,4)))
SeshEndHour(Session) =>
    math.round(str.tonumber(str.substring(Session,5,7)))
SeshEndMins(Session) =>
    math.round(str.tonumber(str.substring(Session,7,9)))

// Time periods
CBDR                    = "1600-2000:1234567"
ASIA                    = input.session         ('2000-0000:1234567', "Asia Range", group="Session Options", tooltip="Asia range session in the selected Timezone. ICT forex convention is 20:00-00:00; some use 19:00-00:00 for index futures")
FLOUT                   = "1600-0000:1234567"
midsesh                 = "0000-1600:1234567"

cbdrOpenTime            = timestamp             (Timezone, year, month, dayofmonth, SeshStartHour(CBDR), SeshStartMins(CBDR), 00)
cbdrEndTime             = timestamp             (Timezone, year, month, dayofmonth, SeshEndHour(CBDR), SeshEndMins(CBDR), 00)
asiaOpenTime            = timestamp             (Timezone, year, month, dayofmonth, SeshStartHour(ASIA), SeshStartMins(ASIA), 00)
asiaEndTime             = timestamp             (Timezone, year, month, dayofmonth, SeshEndHour(ASIA), SeshEndMins(ASIA), 00) + (SeshEndHour(ASIA) * 100 + SeshEndMins(ASIA) <= SeshStartHour(ASIA) * 100 + SeshStartMins(ASIA) ? 86400000 : 0)
floutOpenTime           = timestamp             (Timezone, year, month, dayofmonth, SeshStartHour(FLOUT), SeshStartMins(FLOUT), 00)
floutEndTime            = timestamp             (Timezone, year, month, dayofmonth, SeshEndHour(FLOUT), SeshEndMins(FLOUT), 00)+86400000
CBDRTime                = not na(time(timeframe.period, CBDR, Timezone))
ASIATime                = not na(time(timeframe.period, ASIA, Timezone))
FLOUTTime               = not na(time(timeframe.period, FLOUT, Timezone))

// Time Periods
LondonStartTime         = timestamp(Timezone, year, month, dayofmonth, SeshStartHour(LDNsesh), SeshStartMins(LDNsesh), 00)
LondonEndTime           = timestamp(Timezone, year, month, dayofmonth, SeshEndHour(LDNsesh), SeshEndMins(LDNsesh), 00)
NYStartTime             = timestamp(Timezone, year, month, dayofmonth, SeshStartHour(NYsesh), SeshStartMins(NYsesh), 00)
NYEndTime               = timestamp(Timezone, year, month, dayofmonth, SeshEndHour(NYsesh), SeshEndMins(NYsesh), 00)
LCStartTime             = timestamp(Timezone, year, month, dayofmonth, SeshStartHour(LCsesh), SeshStartMins(LCsesh), 00)
LCEndTime               = timestamp(Timezone, year, month, dayofmonth, SeshEndHour(LCsesh), SeshEndMins(LCsesh), 00)

PMStartTime             = timestamp(Timezone, year, month, dayofmonth, SeshStartHour(PMsesh), SeshStartMins(PMsesh), 00)
PMEndTime               = timestamp(Timezone, year, month, dayofmonth, SeshEndHour(PMsesh), SeshEndMins(PMsesh), 00)
AsianStartTime          = timestamp(Timezone, year, month, dayofmonth, SeshStartHour(ASIA2sesh), SeshStartMins(ASIA2sesh), 00)
AsianEndTime            = timestamp(Timezone, year, month, dayofmonth, SeshEndHour(ASIA2sesh), SeshEndMins(ASIA2sesh), 00)

FreeStartTime           = timestamp(Timezone, year, month, dayofmonth, SeshStartHour(FreeSesh), SeshStartMins(FreeSesh), 00)
FreeEndTime             = timestamp(Timezone, year, month, dayofmonth, SeshEndHour(FreeSesh), SeshEndMins(FreeSesh), 00)

MidnightOpenTime        = timestamp(Timezone, year, month, dayofmonth, 0, 0, 00)
CLEANUPTIME             = timestamp(Timezone, year, month, dayofmonth, 0, 0, 00) - 16200000
LondonOpenTime          = timestamp(Timezone, year, month, dayofmonth, 3, 0, 00)
NYOpenTime              = timestamp(Timezone, year, month, dayofmonth, 8, 30, 00)
EquitiesOpenTime        = timestamp(Timezone, year, month, dayofmonth, 9, 30, 00)
AfternoonOpenTime       = timestamp(Timezone, year, month, dayofmonth, 13, 30, 00)
tMidnight               = time("1", "0000-0001:1234567", Timezone)


// Cleanup - Remove old drawing objects
Cleanup(days) =>
    // Delete old drawing objects
    // One day is 86400000 milliseconds
    removal_timestamp = (CLEANUPTIME) - (days * 86400000)    // Remove every drawing object older than the start of the Today's Midnight
    a_allLines = line.all
    a_allLabels = label.all
    a_allboxes = box.all
    // Remove old lines
    if array.size(a_allLines) > 0
	    for i = 0 to array.size(a_allLines) - 1
		    line_x2 = line.get_x2(array.get(a_allLines, i))
		    if line_x2 < (removal_timestamp)
		        line.delete(array.get(a_allLines, i))
    // Remove old labels
    if array.size(a_allLabels) > 0
	    for i = 0 to array.size(a_allLabels) - 1
		    label_x = label.get_x(array.get(a_allLabels, i))
		    if label_x < removal_timestamp
		        label.delete(array.get(a_allLabels, i))
    // Remove old boxes
    if array.size(a_allboxes) > 0
	    for i = 0 to array.size(a_allboxes) - 1
		    box_x = box.get_right(array.get(a_allboxes, i))
		    if box_x < (removal_timestamp - 86400000)
		        box.delete(array.get(a_allboxes, i))
// End of Cleanup function

// Terminus Function
Terminus(Terminus_Inp)=>
    if Terminus_Inp == "Terminus @ Current Time"
        _return = last_bar_time
    else if Terminus_Inp == "Terminus @ Current Time +15min"
        _return = last_bar_time + 900000
    else if Terminus_Inp == "Terminus @ Current Time +30min"
        _return = last_bar_time + 1800000
    else if Terminus_Inp == "Terminus @ Current Time +45min"
        _return = last_bar_time + 2700000
    else if Terminus_Inp == "Terminus @ Current Time +1hr"
        _return = last_bar_time + 3600000
    else if Terminus_Inp == "Terminus @ Current Time +2hr"
        _return = last_bar_time + 7200000
    else
        _return = last_bar_time + 10800000

// Linestyle Function
MNOPLS                  = Midnight_Open_LS=="Solid" ? line.style_solid : Midnight_Open_LS == "Dotted" ? line.style_dotted : line.style_dashed
LNOPLS                  = london_Open_LS=="Solid" ? line.style_solid : london_Open_LS == "Dotted" ? line.style_dotted : line.style_dashed
NWYOPLS                 = NY_Open_LS=="Solid" ? line.style_solid : NY_Open_LS == "Dotted" ? line.style_dotted : line.style_dashed
EQOPLS                  = Equities_Open_LS=="Solid" ? line.style_solid : Equities_Open_LS == "Dotted" ? line.style_dotted : line.style_dashed

MOPLSS                  = MOPLS=="Solid" ? line.style_solid : MOPLS == "Dotted" ? line.style_dotted : line.style_dashed
NYOPLSS                 = NYOPLS=="Solid" ? line.style_solid : NYOPLS == "Dotted" ? line.style_dotted : line.style_dashed
EOPLSS                  = EOPLS=="Solid" ? line.style_solid : EOPLS == "Dotted" ? line.style_dotted : line.style_dashed
AFTOPLSS                = AFTOPLS=="Solid" ? line.style_solid : AFTOPLS == "Dotted" ? line.style_dotted : line.style_dashed

WeekOpenLS              = WOLS=="Solid" ? line.style_solid : WOLS == "Dotted" ? line.style_dotted : line.style_dashed
MonthOpenLS             = MOLS=="Solid" ? line.style_solid : MOLS == "Dotted" ? line.style_dotted : line.style_dashed
NWOGMidLineStyle        = NWOGMidLS=="Solid" ? line.style_solid : NWOGMidLS == "Dotted" ? line.style_dotted : line.style_dashed
NDOGMidLineStyle        = NDOGMidLS=="Solid" ? line.style_solid : NDOGMidLS == "Dotted" ? line.style_dotted : line.style_dashed

// Linewidth Function
MOPLW                   = Midnight_Open_LW=="1px" ? 1 : Midnight_Open_LW == "2px" ? 2 : Midnight_Open_LW == "3px" ? 3 : Midnight_Open_LW == "4px" ? 4 : 5
LOPLW                   = London_Open_LW=="1px" ? 1 : London_Open_LW == "2px" ? 2 : London_Open_LW == "3px" ? 3 : London_Open_LW == "4px" ? 4 : 5
NYOPLW                  = NY_Open_LW=="1px" ? 1 : NY_Open_LW == "2px" ? 2 : NY_Open_LW == "3px" ? 3 : NY_Open_LW == "4px" ? 4 : 5
EOPLW                   = Equities_Open_LW=="1px" ? 1 : Equities_Open_LW == "2px" ? 2 : Equities_Open_LW == "3px" ? 3 : Equities_Open_LW == "4px" ? 4 : 5

MOPPLW                  = i_MOPLW=="1px" ? 1 : i_MOPLW == "2px" ? 2 : i_MOPLW == "3px" ? 3 : i_MOPLW == "4px" ? 4 : 5
NYOPPLW                 = i_NYOPLW=="1px" ? 1 : i_NYOPLW == "2px" ? 2 : i_NYOPLW == "3px" ? 3 : i_NYOPLW == "4px" ? 4 : 5
EOPPLW                  = i_EOPLW=="1px" ? 1 : i_EOPLW == "2px" ? 2 : i_EOPLW == "3px" ? 3 : i_EOPLW == "4px" ? 4 : 5
AFTOPLW                 = i_AFTOPLW=="1px" ? 1 : i_AFTOPLW == "2px" ? 2 : i_AFTOPLW == "3px" ? 3 : i_AFTOPLW == "4px" ? 4 : 5

WEEKOPPLW               = i_WOPLW=="1px" ? 1 : i_WOPLW == "2px" ? 2 : i_WOPLW == "3px" ? 3 : i_WOPLW == "4px" ? 4 : 5
MONTHOPPLW              = i_MONPLW=="1px" ? 1 : i_MONPLW == "2px" ? 2 : i_MONPLW == "3px" ? 3 : i_MONPLW == "4px" ? 4 : 5

// Label Size Function
LabelSize               =LabelSizeInput=="Auto" ? size.auto : LabelSizeInput=="Tiny" ? size.tiny : LabelSizeInput=="Small" ? size.small : LabelSizeInput=="Normal" ? size.normal : LabelSizeInput=="Large" ? size.large : size.huge


// Fair Value Gaps
var box[] p_fvgBoxes = array.new<box>()
var line[] p_fvgMidLines = array.new<line>()
var float[] p_fvgTops = array.new<float>()
var float[] p_fvgBottoms = array.new<float>()
var int[] p_fvgStartTimes = array.new<int>()
var bool[] p_fvgBullish = array.new<bool>()
var bool[] p_fvgTouched = array.new<bool>()
var bool[] p_fvgFilled = array.new<bool>()
bool fvgTouchAlert = false
bool fvgFillAlert = false

bool t_fvgEnabled = ShowFVG and DOM
if t_fvgEnabled
    bool t_bullFVG = barstate.isconfirmed and bar_index >= 2 and low > high[2]
    bool t_bearFVG = barstate.isconfirmed and bar_index >= 2 and high < low[2]
    if t_bullFVG or t_bearFVG
        float t_fvgTop = t_bullFVG ? low : low[2]
        float t_fvgBottom = t_bullFVG ? high[2] : high
        color t_fvgColor = t_bullFVG ? FVGBullCol : FVGBearCol
        box t_fvgBox = box.new(left=time[2], top=t_fvgTop, right=time, bottom=t_fvgBottom, xloc=xloc.bar_time, border_color=t_fvgColor, bgcolor=t_fvgColor)
        line t_fvgMidLine = na
        if ShowFVGCE
            float t_fvgMid = (t_fvgTop + t_fvgBottom) / 2
            t_fvgMidLine := line.new(time[2], t_fvgMid, time, t_fvgMid, xloc.bar_time, extend.none, color.new(t_fvgColor, 25), line.style_dotted, 1)
        array.push(p_fvgBoxes, t_fvgBox)
        array.push(p_fvgMidLines, t_fvgMidLine)
        array.push(p_fvgTops, t_fvgTop)
        array.push(p_fvgBottoms, t_fvgBottom)
        array.push(p_fvgStartTimes, time)
        array.push(p_fvgBullish, t_bullFVG)
        array.push(p_fvgTouched, false)
        array.push(p_fvgFilled, false)
    while array.size(p_fvgBoxes) > FVGMaxCount
        box.delete(array.shift(p_fvgBoxes))
        line t_oldMidLine = array.shift(p_fvgMidLines)
        if not na(t_oldMidLine)
            line.delete(t_oldMidLine)
        array.shift(p_fvgTops)
        array.shift(p_fvgBottoms)
        array.shift(p_fvgStartTimes)
        array.shift(p_fvgBullish)
        array.shift(p_fvgTouched)
        array.shift(p_fvgFilled)
    int t_fvgSize = array.size(p_fvgBoxes)
    if t_fvgSize > 0
        // Pine requires a positive 'by' step; direction is inferred, so reverse iteration needs no 'by -1'
        for i = (t_fvgSize - 1) to 0
            if i < t_fvgSize
                box t_box = array.get(p_fvgBoxes, i)
                line t_midLine = array.get(p_fvgMidLines, i)
                float t_top = array.get(p_fvgTops, i)
                float t_bottom = array.get(p_fvgBottoms, i)
                int t_startTime = array.get(p_fvgStartTimes, i)
                bool t_isBullish = array.get(p_fvgBullish, i)
                bool t_isFilled = array.get(p_fvgFilled, i)
                if not t_isFilled
                    box.set_right(t_box, time)
                    if not na(t_midLine)
                        line.set_x2(t_midLine, time)
                    bool t_isTouched = time > t_startTime and (t_isBullish ? low <= t_top : high >= t_bottom)
                    bool t_nowFilled = time > t_startTime and (t_isBullish ? close <= t_bottom : close >= t_top)
                    fvgTouchAlert := fvgTouchAlert or (barstate.isconfirmed and t_isTouched and not array.get(p_fvgTouched, i))
                    fvgFillAlert := fvgFillAlert or (barstate.isconfirmed and t_nowFilled)
                    if t_isTouched and not array.get(p_fvgTouched, i)
                        array.set(p_fvgTouched, i, true)
                        box.set_bgcolor(t_box, color.new(t_isBullish ? FVGBullCol : FVGBearCol, 90))
                    if t_nowFilled
                        if HideFilledFVG
                            box.delete(t_box)
                            if not na(t_midLine)
                                line.delete(t_midLine)
                            array.remove(p_fvgBoxes, i)
                            array.remove(p_fvgMidLines, i)
                            array.remove(p_fvgTops, i)
                            array.remove(p_fvgBottoms, i)
                            array.remove(p_fvgStartTimes, i)
                            array.remove(p_fvgBullish, i)
                            array.remove(p_fvgTouched, i)
                            array.remove(p_fvgFilled, i)
                            t_fvgSize := array.size(p_fvgBoxes)
                        else
                            array.set(p_fvgFilled, i, true)
                            box.set_bgcolor(t_box, color.new(color.gray, 90))
                            box.set_border_color(t_box, color.new(color.gray, 60))
                            if not na(t_midLine)
                                line.set_color(t_midLine, color.new(color.gray, 60))
else if array.size(p_fvgBoxes) > 0
    while array.size(p_fvgBoxes) > 0
        box.delete(array.shift(p_fvgBoxes))
        line t_disabledMidLine = array.shift(p_fvgMidLines)
        if not na(t_disabledMidLine)
            line.delete(t_disabledMidLine)
    array.clear(p_fvgTops)
    array.clear(p_fvgBottoms)
    array.clear(p_fvgStartTimes)
    array.clear(p_fvgBullish)
    array.clear(p_fvgTouched)
    array.clear(p_fvgFilled)

// SMT Divergence
// Gate the cross-symbol request.security + pivots behind ShowSMT to avoid the
// always-on request cost when SMT is disabled (default). ShowSMT is an input
// bool = run-constant, so this if runs on every bar or none, keeping ta.pivot*
// internal state consistent. Comp high/low are locals (nothing external reads them).
// Chart is the only pivot anchor; the comparison instrument's swing is taken as its
// extreme over the SAME 2*Len+1 bar window (ta.highest/lowest), which auto-aligns
// timing without requiring the comp series to print its own pivot on the same bar.
float t_smtChartPivotHigh = na
float t_smtChartPivotLow = na
float t_smtCompWindowHigh = na
float t_smtCompWindowLow = na
if ShowSMT
    [t_smtCompHigh, t_smtCompLow] = request.security(SMTSymbol, timeframe.period, [high, low], lookahead=barmerge.lookahead_off)
    t_smtChartPivotHigh := ta.pivothigh(high, SMTPivotLen, SMTPivotLen)
    t_smtChartPivotLow := ta.pivotlow(low, SMTPivotLen, SMTPivotLen)
    t_smtCompWindowHigh := ta.highest(t_smtCompHigh, 2 * SMTPivotLen + 1)
    t_smtCompWindowLow := ta.lowest(t_smtCompLow, 2 * SMTPivotLen + 1)

var line[] p_smtLines = array.new<line>()
var float p_smtPrevChartHigh = na
var float p_smtPrevCompHigh = na
var int p_smtPrevHighTime = na
var float p_smtPrevChartLow = na
var float p_smtPrevCompLow = na
var int p_smtPrevLowTime = na

bool t_smtEnabled = ShowSMT and DOM
if t_smtEnabled and barstate.isconfirmed
    if not na(t_smtChartPivotLow) and not na(t_smtCompWindowLow)
        int t_smtLowTime = time[SMTPivotLen]
        bool t_smtHasLowPair = not na(p_smtPrevChartLow) and not na(p_smtPrevCompLow)
        bool t_smtChartLowerLow = t_smtChartPivotLow < p_smtPrevChartLow
        bool t_smtCompLowerLow = t_smtCompWindowLow < p_smtPrevCompLow
        bool t_smtBull = t_smtHasLowPair and t_smtChartLowerLow != t_smtCompLowerLow
        if t_smtBull
            line t_smtLine = line.new(p_smtPrevLowTime, p_smtPrevChartLow, t_smtLowTime, t_smtChartPivotLow, xloc.bar_time, extend.none, SMTBullCol, line.style_solid, 2)
            array.push(p_smtLines, t_smtLine)
        p_smtPrevChartLow := t_smtChartPivotLow
        p_smtPrevCompLow := t_smtCompWindowLow
        p_smtPrevLowTime := t_smtLowTime
    if not na(t_smtChartPivotHigh) and not na(t_smtCompWindowHigh)
        int t_smtHighTime = time[SMTPivotLen]
        bool t_smtHasHighPair = not na(p_smtPrevChartHigh) and not na(p_smtPrevCompHigh)
        bool t_smtChartHigherHigh = t_smtChartPivotHigh > p_smtPrevChartHigh
        bool t_smtCompHigherHigh = t_smtCompWindowHigh > p_smtPrevCompHigh
        bool t_smtBear = t_smtHasHighPair and t_smtChartHigherHigh != t_smtCompHigherHigh
        if t_smtBear
            line t_smtLine = line.new(p_smtPrevHighTime, p_smtPrevChartHigh, t_smtHighTime, t_smtChartPivotHigh, xloc.bar_time, extend.none, SMTBearCol, line.style_solid, 2)
            array.push(p_smtLines, t_smtLine)
        p_smtPrevChartHigh := t_smtChartPivotHigh
        p_smtPrevCompHigh := t_smtCompWindowHigh
        p_smtPrevHighTime := t_smtHighTime
    while array.size(p_smtLines) > SMTMaxCount
        line.delete(array.shift(p_smtLines))
if not t_smtEnabled
    while array.size(p_smtLines) > 0
        line.delete(array.shift(p_smtLines))
    p_smtPrevChartHigh := na
    p_smtPrevCompHigh := na
    p_smtPrevHighTime := na
    p_smtPrevChartLow := na
    p_smtPrevCompLow := na
    p_smtPrevLowTime := na


// Creating Variables
var London_Start_Vline  = line.new(x1=na, y1=na, x2=na, xloc=xloc.bar_time, y2=close, color=LSVLC, width=1)
var London_End_Vline    = line.new(x1=na, y1=na, x2=na, xloc=xloc.bar_time, y2=close, color=LSVLC, width=1)
var LondonFill          = linefill.new(London_Start_Vline, London_End_Vline, LSFC)

var NY_Start_Vline      = line.new(x1=na, y1=na, x2=na, xloc=xloc.bar_time, y2=close, color=NYSVLC, width=1)
var NY_End_Vline        = line.new(x1=na, y1=na, x2=na, xloc=xloc.bar_time, y2=close, color=NYSVLC, width=1)
var NYFill              = linefill.new(NY_Start_Vline, NY_End_Vline, NYSFC)

var LC_Start_Vline      = line.new(x1=na, y1=na, x2=na, xloc=xloc.bar_time, y2=close, color=NYSVLC, width=1)
var LC_End_Vline        = line.new(x1=na, y1=na, x2=na, xloc=xloc.bar_time, y2=close, color=NYSVLC, width=1)
var LCFill              = linefill.new(LC_Start_Vline, LC_End_Vline, LCSFC)

var PM_Start_Vline      = line.new(x1=na, y1=na, x2=na, xloc=xloc.bar_time, y2=close, color=PMSVLC, width=1)
var PM_End_Vline        = line.new(x1=na, y1=na, x2=na, xloc=xloc.bar_time, y2=close, color=PMSVLC, width=1)
var PMFill              = linefill.new(PM_Start_Vline, PM_End_Vline, PMSFC)

var Asian_Start_Vline   = line.new(x1=na, y1=na, x2=na, xloc=xloc.bar_time, y2=close, color=ASVLC, width=1)
var Asian_End_Vline     = line.new(x1=na, y1=na, x2=na, xloc=xloc.bar_time, y2=close, color=ASVLC, width=1)
var AsianFill           = linefill.new(Asian_Start_Vline, Asian_End_Vline, ASFC)

var Free_Start_Vline    = line.new(x1=na, y1=na, x2=na, xloc=xloc.bar_time, y2=close, color=ASVLC, width=1)
var Free_End_Vline      = line.new(x1=na, y1=na, x2=na, xloc=xloc.bar_time, y2=close, color=ASVLC, width=1)
var FreeFill            = linefill.new(Free_Start_Vline, Free_End_Vline, FSFC)

var box LondonBox       = na
var box NYBox           = na
var box LCBox           = na
var box PMBox           = na
var box AsianBox        = na
var box FreeBox         = na
var float LondonBoxHi   = na
var float LondonBoxLo   = na
var float NYBoxHi       = na
var float NYBoxLo       = na
var float LCBoxHi       = na
var float LCBoxLo       = na
var float PMBoxHi       = na
var float PMBoxLo       = na
var float AsianBoxHi    = na
var float AsianBoxLo    = na
var float FreeBoxHi     = na
var float FreeBoxLo     = na


var Midnight_Open       = line.new(x1=na, y1=na, x2=na, xloc=xloc.bar_time, y2=close, color=MOPColor, width=1)
var London_Open         = line.new(x1=na, y1=na, x2=na, xloc=xloc.bar_time, y2=close, color=LOPColor, width=1)
var NY_Open             = line.new(x1=na, y1=na, x2=na, xloc=xloc.bar_time, y2=close, color=NYOPColor, width=1)
var Equities_Open       = line.new(x1=na, y1=na, x2=na, xloc=xloc.bar_time, y2=close, color=EOPColor, width=1)

// When a New Day Starts, Start Drawing all lines
if newDay and dayofweek != dayofweek.sunday
    // London Session
    if (ShowLondon and DOM)
        if ShowTSO
            line.delete(London_Start_Vline[1])
            line.delete(London_End_Vline[1])
            linefill.delete(LondonFill[1])
        London_Start_Vline := vline(LondonStartTime,transparentcol, line.style_solid, 1)
        London_End_Vline   := vline(LondonEndTime, transparentcol, line.style_solid, 1)
        if ShowSFill and LondonSeshRender == "Highlight"
            LondonFill := linefill.new(London_Start_Vline, London_End_Vline, LSFC)

    // New York Session
    if (ShowNY and DOM)
        if ShowTSO
            line.delete(NY_Start_Vline[1])
            line.delete(NY_End_Vline[1])
            linefill.delete(NYFill[1])
        NY_Start_Vline := vline(NYStartTime, transparentcol, line.style_solid, 1)
        NY_End_Vline   := vline(NYEndTime, transparentcol, line.style_solid, 1)
        if ShowSFill and NYSeshRender == "Highlight"
            NYFill := linefill.new(NY_Start_Vline, NY_End_Vline, NYSFC)

    // London Close
    if (ShowLC and DOM)
        if ShowTSO
            line.delete(LC_End_Vline[1])
            linefill.delete(LCFill[1])
        LC_Start_Vline := vline(LCStartTime, transparentcol, line.style_solid, 1)
        LC_End_Vline   := vline(LCEndTime, transparentcol, line.style_solid, 1)
        if ShowSFill and LCSeshRender == "Highlight"
            LCFill := linefill.new(LC_Start_Vline, LC_End_Vline, LCSFC)

    // PM Session
    if (ShowPM and DOM)
        if ShowTSO
            line.delete(PM_Start_Vline[1])
            line.delete(PM_End_Vline[1])
            linefill.delete(PMFill[1])
        PM_Start_Vline := vline(PMStartTime, transparentcol, line.style_solid, 1)
        PM_End_Vline   := vline(PMEndTime, transparentcol, line.style_solid, 1)
        if ShowSFill and PMSeshRender == "Highlight"
            PMFill := linefill.new(PM_Start_Vline, PM_End_Vline, PMSFC)

    // Asian Session
    if (ShowAsian and DOM)
        if ShowTSO
            line.delete(Asian_Start_Vline[1])
            line.delete(Asian_End_Vline[1])
            linefill.delete(AsianFill[1])
        Asian_Start_Vline := vline(AsianStartTime, transparentcol, line.style_solid, 1)
        Asian_End_Vline   := vline(AsianEndTime, transparentcol, line.style_solid, 1)
        // if dayofweek == dayofweek.friday
        //     // line.delete(Asian_Start_Vline)
        //     // line.delete(Asian_End_Vline)
        //     Asian_Start_Vline := vline(MidnightOpenTime+244800000, transparentcol, line.style_solid, 1)
        //     Asian_End_Vline   := vline(MidnightOpenTime+259200000, transparentcol, line.style_solid, 1)
        if ShowSFill and AsianSeshRender == "Highlight"
            AsianFill := linefill.new(Asian_Start_Vline, Asian_End_Vline, ASFC)

    // Free Session
    if (ShowFreeSesh and DOM)
        if ShowTSO
            line.delete(Free_Start_Vline[1])
            line.delete(Free_End_Vline[1])
            linefill.delete(FreeFill[1])
        Free_Start_Vline := vline(FreeStartTime, transparentcol, line.style_solid, 1)
        Free_End_Vline   := vline(FreeEndTime, transparentcol, line.style_solid, 1)
        if ShowSFill and FreeSeshRender == "Highlight"
            FreeFill := linefill.new(Free_Start_Vline, Free_End_Vline, FSFC)

    // Midnight Opening Price
    if (ShowMOP and DOM)
        if MOLHist == false
            line.delete(Midnight_Open[1])
        Midnight_Open := vline(MidnightOpenTime, MOPColor, MNOPLS, MOPLW)

    // London Opening Price
    if (ShowLOP and DOM)
        if ShowTSO
            line.delete(London_Open[1])
        London_Open := vline(LondonOpenTime, LOPColor, LNOPLS, LOPLW)

    // New York Opening Price
    if (ShowNYOP and DOM)
        if ShowTSO
            line.delete(NY_Open[1])
        NY_Open := vline(NYOpenTime, NYOPColor, NWYOPLS, NYOPLW)

    // Equities Opening Price
    if (ShowEOP and DOM)
        if ShowTSO
            line.delete(Equities_Open[1])
        Equities_Open := vline(EquitiesOpenTime, EOPColor, EQOPLS, EOPLW)

[LondonBoxNext, LondonBoxHiNext, LondonBoxLoNext] = SessionBox(ShowLondon, LondonSeshRender, LDNsesh, LondonStartTime, LondonEndTime, LSFC, LondonBox, LondonBoxHi, LondonBoxLo)
LondonBox := LondonBoxNext
LondonBoxHi := LondonBoxHiNext
LondonBoxLo := LondonBoxLoNext
[NYBoxNext, NYBoxHiNext, NYBoxLoNext] = SessionBox(ShowNY, NYSeshRender, NYsesh, NYStartTime, NYEndTime, NYSFC, NYBox, NYBoxHi, NYBoxLo)
NYBox := NYBoxNext
NYBoxHi := NYBoxHiNext
NYBoxLo := NYBoxLoNext
[LCBoxNext, LCBoxHiNext, LCBoxLoNext] = SessionBox(ShowLC, LCSeshRender, LCsesh, LCStartTime, LCEndTime, LCSFC, LCBox, LCBoxHi, LCBoxLo)
LCBox := LCBoxNext
LCBoxHi := LCBoxHiNext
LCBoxLo := LCBoxLoNext
[PMBoxNext, PMBoxHiNext, PMBoxLoNext] = SessionBox(ShowPM, PMSeshRender, PMsesh, PMStartTime, PMEndTime, PMSFC, PMBox, PMBoxHi, PMBoxLo)
PMBox := PMBoxNext
PMBoxHi := PMBoxHiNext
PMBoxLo := PMBoxLoNext
[AsianBoxNext, AsianBoxHiNext, AsianBoxLoNext] = SessionBox(ShowAsian, AsianSeshRender, ASIA2sesh, AsianStartTime, AsianEndTime, ASFC, AsianBox, AsianBoxHi, AsianBoxLo)
AsianBox := AsianBoxNext
AsianBoxHi := AsianBoxHiNext
AsianBoxLo := AsianBoxLoNext
[FreeBoxNext, FreeBoxHiNext, FreeBoxLoNext] = SessionBox(ShowFreeSesh, FreeSeshRender, FreeSesh, FreeStartTime, FreeEndTime, FSFC, FreeBox, FreeBoxHi, FreeBoxLo)
FreeBox := FreeBoxNext
FreeBoxHi := FreeBoxHiNext
FreeBoxLo := FreeBoxLoNext

// Variables
var label MOPLB = na
var line MOPLN = na
var label NYOPLB = na
var line NYOPLN = na
var label EOPLB = na
var line EOPLN = na
var line AFTLN = na
var label AFTLB = na

// New York Midnight Open Price line
var openMidnight  = 0.0
if not na(tMidnight)
    if na(tMidnight[1])
        openMidnight  := open
    else
        openMidnight := math.max(open, openMidnight)

if (ShowMOPP and (openMidnight != openMidnight[1]) and DOM and barstate.isconfirmed)
    label.delete(MOPLB[1])
    if ShowMOPL == false
        line.delete(MOPLN[1])
    MOPLN := line.new(x1=tMidnight, y1=openMidnight, x2=tMidnight+86400000, xloc=xloc.bar_time, y2=openMidnight, color=MOPColP, style=MOPLSS, width=MOPPLW)
    if dayofweek == dayofweek.friday and syminfo.type != "crypto"
        line.set_x2(MOPLN, tMidnight+259200000)
    if ShowLabel
        MOPLB := label.new(x=tMidnight+86400000, y=openMidnight, xloc=xloc.bar_time, color=LabelColor, textcolor=MOPColP, style=label.style_label_left, size=LabelSize, tooltip="Midnight Opening Price")
        if dayofweek == dayofweek.friday and syminfo.type != "crypto"
            label.set_x(MOPLB, tMidnight+259200000)
        if ShowLabelText
            if SFistrue
                if ShowPrices == true
                    label.set_text(MOPLB, " 00:00  |  " + str.tostring(open))
                else
                    label.set_text(MOPLB, " 00:00 ")
                label.set_tooltip(MOPLB, "Midnight Opening Price")
            else
                if ShowPrices == true
                    label.set_text(MOPLB, " Midnight Opening Price  |  " + str.tostring(open))
                else
                    label.set_text(MOPLB, " Midnight Opening Price ")
                label.set_tooltip(MOPLB, "")
            label.set_textcolor(MOPLB, LabelTextColor)
            label.set_size(MOPLB,LabelSize)
    if time > PMEndTime and time < (MidnightOpenTime + 86400000)
        line.delete(MOPLN[0])

if Terminusinp != "Terminus @ Next Midnight" and ShowMOPL == false and barstate.islast
    line.set_x2(MOPLN, Terminus(Terminusinp))
    label.set_x(MOPLB, Terminus(Terminusinp))

// New York Opening Price Line
if (ShowNYOPP and (time == NYOpenTime) and DOM)
    label.delete(NYOPLB[1])
    if ShowPrev == false
        line.delete(NYOPLN[1])
    NYOPLN := line.new(x1=NYOpenTime, y1=open, x2=NYOpenTime+55800000, xloc=xloc.bar_time, y2=open, color=NYOPColP, style=NYOPLSS, width=NYOPPLW)
    if dayofweek == dayofweek.friday and syminfo.type != "crypto"
        line.set_x2(NYOPLN, NYOpenTime+228600000)
    if ShowLabel
        NYOPLB := label.new(x=NYOpenTime+55800000, y=open, xloc=xloc.bar_time, color=LabelColor, textcolor=NYOPColP, style=label.style_label_left, size=LabelSize, tooltip="New York Opening Price")
        if dayofweek == dayofweek.friday and syminfo.type != "crypto"
            label.set_x(NYOPLB, NYOpenTime+228600000)
        if ShowLabelText
            if SFistrue
                if ShowPrices == true
                    label.set_text(NYOPLB, " 08:30  |  " + str.tostring(open))
                else
                    label.set_text(NYOPLB, " 08:30 ")
                label.set_tooltip(NYOPLB, "New York Opening Price")
            else
                if ShowPrices == true
                    label.set_text(NYOPLB, " New York Opening Price  |  " + str.tostring(open))
                else
                    label.set_text(NYOPLB, " New York Opening Price ")
                label.set_tooltip(NYOPLB, "")
            label.set_textcolor(NYOPLB, LabelTextColor)
            label.set_size(NYOPLB,LabelSize)
if Terminusinp != "Terminus @ Next Midnight" and ShowPrev == false and barstate.islast
    line.set_x2(NYOPLN, Terminus(Terminusinp))
    label.set_x(NYOPLB, Terminus(Terminusinp))

// Equities Opening Price Line
if (ShowEOPP and (time == EquitiesOpenTime) and DOM)
    label.delete(EOPLB[1])
    if ShowPrev == false
        line.delete(EOPLN[1])
    EOPLN := line.new(x1=EquitiesOpenTime, y1=open, x2=EquitiesOpenTime+23400000, xloc=xloc.bar_time, y2=open, color=EOPColP, style=EOPLSS, width=EOPPLW)
    if ShowLabel
        EOPLB := label.new(x=EquitiesOpenTime+23400000, y=open, xloc=xloc.bar_time, color=LabelColor, textcolor=EOPColP, style=label.style_label_left, size=LabelSize, tooltip="Equities Opening Price")
        if ShowLabelText
            if SFistrue
                if ShowPrices == true
                    label.set_text(EOPLB, " 09:30  |  " + str.tostring(open))
                else
                    label.set_text(EOPLB, " 09:30 ")
                label.set_tooltip(EOPLB, "Equities Opening Price")
            else
                if ShowPrices == true
                    label.set_text(EOPLB, " Equities Opening Price  |  " + str.tostring(open))
                else
                    label.set_text(EOPLB, " Equities Opening Price ")
                label.set_tooltip(EOPLB, "")
            label.set_textcolor(EOPLB, LabelTextColor)
            label.set_size(EOPLB,LabelSize)
if Terminusinp != "Terminus @ Next Midnight" and ShowPrev == false and barstate.islast
    line.set_x2(EOPLN, Terminus(Terminusinp))
    label.set_x(EOPLB, Terminus(Terminusinp))

// Afternoon Opening Price Line
if (ShowAFTPP and (time == AfternoonOpenTime) and DOM)
    label.delete(AFTLB[1])
    if ShowPrev == false
        line.delete(AFTLN[1])
    AFTLN := line.new(x1=AfternoonOpenTime, y1=open, x2=EquitiesOpenTime+52200000, xloc=xloc.bar_time, y2=open, color=AFTOPColP, style=AFTOPLSS, width=AFTOPLW)
    if dayofweek == dayofweek.friday and syminfo.type != "crypto"
        line.set_x2(AFTLN, EquitiesOpenTime+225000000)
    if ShowLabel
        AFTLB := label.new(x=EquitiesOpenTime+52200000, y=open, xloc=xloc.bar_time, color=LabelColor, textcolor=AFTOPColP, style=label.style_label_left, size=LabelSize, tooltip="Equities Opening Price")
        if dayofweek == dayofweek.friday and syminfo.type != "crypto"
            label.set_x(AFTLB, EquitiesOpenTime+225000000)
        if ShowLabelText
            if SFistrue
                if ShowPrices == true
                    label.set_text(AFTLB, " 13:30  |  " + str.tostring(open))
                else
                    label.set_text(AFTLB, " 13:30 ")
                label.set_tooltip(AFTLB, " Afternoon Opening Price")
            else
                if ShowPrices == true
                    label.set_text(AFTLB, " Afternoon Opening Price  |  " + str.tostring(open))
                else
                    label.set_text(AFTLB, " Afternoon Opening Price ")
                label.set_tooltip(AFTLB, "")
            label.set_textcolor(AFTLB, LabelTextColor)
            label.set_size(AFTLB,LabelSize)
if Terminusinp != "Terminus @ Next Midnight" and ShowPrev == false and barstate.islast
    line.set_x2(AFTLN, Terminus(Terminusinp))
    label.set_x(AFTLB, Terminus(Terminusinp))

// HTF Variables
var Weekly_open     = line.new(x1=na, y1=na, x2=na, xloc=xloc.bar_time, y2=close, color=i_WeekOpenCol, style=WeekOpenLS, width=1)
var Weekly_openlbl  = label.new(x=na, y=na, xloc=xloc.bar_time, color=LabelColor, textcolor=LabelTextColor, style=label.style_label_left, size=LabelSize)
var WeeklyOpenTime  = time

var Monthly_open    = line.new(x1=na, y1=na, x2=na, xloc=xloc.bar_time, y2=close, color=i_MonthOpenCol, style=MonthOpenLS, width=1)
var Monthly_openlbl  = label.new(x=na, y=na, xloc=xloc.bar_time, color=LabelColor, textcolor=LabelTextColor, style=label.style_label_left, size=LabelSize)
var MonthlyOpenTime = time

var line PrevWeekHighLine = na
var line PrevWeekLowLine = na
var line PrevMonthHighLine = na
var line PrevMonthLowLine = na
var label PrevWeekHighLbl = na
var label PrevWeekLowLbl = na
var label PrevMonthHighLbl = na
var label PrevMonthLowLbl = na
var int PrevWeekHLStartTime = na
var int PrevMonthHLStartTime = na
var int CurrentWeekStartTime = na
var int CurrentMonthStartTime = na
var box[] p_nwogBoxes = array.new<box>()
var line[] p_nwogMidLines = array.new<line>()
var box[] p_ndogBoxes = array.new<box>()
var line[] p_ndogMidLines = array.new<line>()
var float[] p_nwogMidLevels = array.new<float>()
var int[] p_nwogStartTimes = array.new<int>()
var bool[] p_nwogMidTouched = array.new<bool>()
var float p_lastWeekClose = na
var int p_lastWeekCloseTime = na
bool nwogMidTouchAlert = false

// Get HTF Price levels
// Captured locally from chart bars at the trading week/month boundary instead of
// request.security("W"/"M", open): the weekly feed of some continuous futures
// (e.g. CBOT_MINI:YM1!) steps at daily session opens, while chart bars are correct.
// Shifting bar time +7h maps evening sessions (Sun 17:00 open) onto their trading
// day before extracting week/month. Crypto instead uses its UTC calendar W/M bars.
// Non-intraday non-crypto drawings apply the same 7h shift to their x-anchor.
tradingBoundaryTime = time + 25200000
newTradingWeek      = ta.change(weekofyear(tradingBoundaryTime)) != 0
newTradingMonth     = ta.change(month(tradingBoundaryTime)) != 0
newOpenWeek            = syminfo.type == "crypto" ? calendarWeekChange : newTradingWeek
newOpenMonth           = syminfo.type == "crypto" ? newMonth : newTradingMonth
// New trading day from the symbol's own daily session (first bar after the daily
// boundary, e.g. 18:00 ET futures reopen, 00:00 UTC crypto) - no session input needed
// ta.change kept unconditional: 'and' short-circuits in v6 and would skip it on bar 0
dailySessionChange  = ta.change(time("D")) != 0
newTradingDay       = not barstate.isfirst and dailySessionChange
var float WeeklyOpen    = na
var float MonthlyOpen   = na
var float CurrentWeekHigh = na
var float CurrentWeekLow = na
var float CurrentMonthHigh = na
var float CurrentMonthLow = na
var float PrevWeekHigh = na
var float PrevWeekLow = na
var float PrevMonthHigh = na
var float PrevMonthLow = na
if newOpenWeek
    float t_nwogPrevClose = p_lastWeekClose
    int t_nwogPrevCloseTime = p_lastWeekCloseTime
    WeeklyOpenTime := time
    WeeklyOpen := open
    PrevWeekHigh := CurrentWeekHigh
    PrevWeekLow := CurrentWeekLow
    // Anchor prev-week levels at the PREVIOUS week's start so the line spans the week it belongs to
    PrevWeekHLStartTime := CurrentWeekStartTime
    CurrentWeekStartTime := time
    CurrentWeekHigh := high
    CurrentWeekLow := low
    p_lastWeekClose := close
    p_lastWeekCloseTime := time
    if ShowNWOG and DOM and not na(t_nwogPrevClose) and not na(t_nwogPrevCloseTime) and open != t_nwogPrevClose
        float t_nwogTop = math.max(open, t_nwogPrevClose)
        float t_nwogBottom = math.min(open, t_nwogPrevClose)
        float t_nwogMid = na
        box t_nwogBox = box.new(left=t_nwogPrevCloseTime, top=t_nwogTop, right=time, bottom=t_nwogBottom, xloc=xloc.bar_time, border_color=color.new(i_NWOGCol, 35), bgcolor=i_NWOGCol, text=txtNWOG, text_color=color.new(i_NWOGCol, 0), text_size=size.tiny)
        line t_nwogMidLine = na
        if ShowNWOGMid
            t_nwogMid := (t_nwogTop + t_nwogBottom) / 2
            t_nwogMidLine := line.new(t_nwogPrevCloseTime, t_nwogMid, time, t_nwogMid, xloc.bar_time, extend.none, color.new(i_NWOGCol, 0), NWOGMidLineStyle, 1)
        array.push(p_nwogBoxes, t_nwogBox)
        array.push(p_nwogMidLines, t_nwogMidLine)
        array.push(p_nwogMidLevels, t_nwogMid)
        array.push(p_nwogStartTimes, time)
        array.push(p_nwogMidTouched, false)
else
    CurrentWeekHigh := na(CurrentWeekHigh) ? high : math.max(CurrentWeekHigh, high)
    CurrentWeekLow := na(CurrentWeekLow) ? low : math.min(CurrentWeekLow, low)
    p_lastWeekClose := close
    p_lastWeekCloseTime := time
while array.size(p_nwogBoxes) > (ShowNWOG ? NWOGMaxCount : 0)
    box.delete(array.shift(p_nwogBoxes))
    line t_oldNWOGMidLine = array.shift(p_nwogMidLines)
    if not na(t_oldNWOGMidLine)
        line.delete(t_oldNWOGMidLine)
    array.shift(p_nwogMidLevels)
    array.shift(p_nwogStartTimes)
    array.shift(p_nwogMidTouched)
if ShowNWOG and DOM and array.size(p_nwogBoxes) > 0
    int t_nwogSize = array.size(p_nwogBoxes)
    for i = 0 to t_nwogSize - 1
        box t_nwogBox = array.get(p_nwogBoxes, i)
        line t_nwogMidLine = array.get(p_nwogMidLines, i)
        box.set_right(t_nwogBox, time)
        if not na(t_nwogMidLine)
            line.set_x2(t_nwogMidLine, time)
        float t_nwogMidLevel = array.get(p_nwogMidLevels, i)
        int t_nwogStartTime = array.get(p_nwogStartTimes, i)
        if ShowNWOGMid and barstate.isconfirmed and not na(t_nwogMidLevel) and time > t_nwogStartTime and high >= t_nwogMidLevel and low <= t_nwogMidLevel and not array.get(p_nwogMidTouched, i)
            nwogMidTouchAlert := true
            array.set(p_nwogMidTouched, i, true)
// Weekly reopen is the NWOG's job, so week-boundary bars are excluded here
if ShowNDOG and DOM and newTradingDay and not newOpenWeek and not na(close[1]) and open != close[1]
    float t_ndogTop = math.max(open, close[1])
    float t_ndogBottom = math.min(open, close[1])
    box t_ndogBox = box.new(left=time[1], top=t_ndogTop, right=time, bottom=t_ndogBottom, xloc=xloc.bar_time, border_color=color.new(i_NDOGCol, 35), bgcolor=i_NDOGCol, text=txtNDOG, text_color=color.new(i_NDOGCol, 0), text_size=size.tiny)
    line t_ndogMidLine = na
    if ShowNDOGMid
        float t_ndogMid = (t_ndogTop + t_ndogBottom) / 2
        t_ndogMidLine := line.new(time[1], t_ndogMid, time, t_ndogMid, xloc.bar_time, extend.none, color.new(i_NDOGCol, 0), NDOGMidLineStyle, 1)
    array.push(p_ndogBoxes, t_ndogBox)
    array.push(p_ndogMidLines, t_ndogMidLine)
while array.size(p_ndogBoxes) > (ShowNDOG ? NDOGMaxCount : 0)
    box.delete(array.shift(p_ndogBoxes))
    line t_oldNDOGMidLine = array.shift(p_ndogMidLines)
    if not na(t_oldNDOGMidLine)
        line.delete(t_oldNDOGMidLine)
if ShowNDOG and DOM and array.size(p_ndogBoxes) > 0
    for i = 0 to array.size(p_ndogBoxes) - 1
        box.set_right(array.get(p_ndogBoxes, i), time)
        line t_extNDOGMidLine = array.get(p_ndogMidLines, i)
        if not na(t_extNDOGMidLine)
            line.set_x2(t_extNDOGMidLine, time)
if newOpenMonth
    MonthlyOpenTime := time
    MonthlyOpen := open
    PrevMonthHigh := CurrentMonthHigh
    PrevMonthLow := CurrentMonthLow
    PrevMonthHLStartTime := CurrentMonthStartTime
    CurrentMonthStartTime := time
    CurrentMonthHigh := high
    CurrentMonthLow := low
else
    CurrentMonthHigh := na(CurrentMonthHigh) ? high : math.max(CurrentMonthHigh, high)
    CurrentMonthLow := na(CurrentMonthLow) ? low : math.min(CurrentMonthLow, low)

UpdatePriorLevelLine(LevelLine, LevelLabel, ShowLevel, LevelStartTime, LevelPrice, LevelColor, LevelStyle, LevelWidth, LabelText) =>
    line UpdatedLine = LevelLine
    label UpdatedLabel = LevelLabel
    int LevelEndTime = Terminusinp == "Terminus @ Next Midnight" ? AsianEndTime : Terminus(Terminusinp)
    // Draw on the last bar only: a var line created early in history is silently
    // garbage-collected once newer drawings exceed max_lines_count, so it never renders
    if ShowLevel and DOM and barstate.islast and not na(LevelStartTime) and not na(LevelPrice)
        if na(UpdatedLine)
            UpdatedLine := line.new(LevelStartTime, LevelPrice, LevelEndTime, LevelPrice, xloc.bar_time, extend.none, LevelColor, LevelStyle, LevelWidth)
        else
            line.set_x1(UpdatedLine, LevelStartTime)
            line.set_y1(UpdatedLine, LevelPrice)
            line.set_x2(UpdatedLine, LevelEndTime)
            line.set_y2(UpdatedLine, LevelPrice)
            line.set_color(UpdatedLine, LevelColor)
            line.set_style(UpdatedLine, LevelStyle)
            line.set_width(UpdatedLine, LevelWidth)
        // End label so the level is identifiable when far from price (PWH/PWL can sit
        // hundreds of points outside the auto-scaled viewport on LTF charts)
        if ShowLabel
            if na(UpdatedLabel)
                UpdatedLabel := label.new(LevelEndTime, LevelPrice, LabelText, xloc.bar_time, yloc.price, LabelColor, label.style_label_left, LevelColor, LabelSize, tooltip=LabelText + ": " + str.tostring(LevelPrice))
            else
                label.set_x(UpdatedLabel, LevelEndTime)
                label.set_y(UpdatedLabel, LevelPrice)
                label.set_text(UpdatedLabel, LabelText)
                label.set_textcolor(UpdatedLabel, LevelColor)
                label.set_tooltip(UpdatedLabel, LabelText + ": " + str.tostring(LevelPrice))
        else if not na(UpdatedLabel)
            label.delete(UpdatedLabel)
            UpdatedLabel := na
    else
        if not na(UpdatedLine)
            line.delete(UpdatedLine)
            UpdatedLine := na
        if not na(UpdatedLabel)
            label.delete(UpdatedLabel)
            UpdatedLabel := na
    [UpdatedLine, UpdatedLabel]

[t_pwhLine, t_pwhLbl] = UpdatePriorLevelLine(PrevWeekHighLine, PrevWeekHighLbl, ShowPrevWeekHL, PrevWeekHLStartTime, PrevWeekHigh, i_PrevWeekHighCol, WeekOpenLS, WEEKOPPLW, " PWH ")
[t_pwlLine, t_pwlLbl] = UpdatePriorLevelLine(PrevWeekLowLine, PrevWeekLowLbl, ShowPrevWeekHL, PrevWeekHLStartTime, PrevWeekLow, i_PrevWeekLowCol, WeekOpenLS, WEEKOPPLW, " PWL ")
[t_pmhLine, t_pmhLbl] = UpdatePriorLevelLine(PrevMonthHighLine, PrevMonthHighLbl, ShowPrevMonthHL, PrevMonthHLStartTime, PrevMonthHigh, i_PrevMonthHighCol, MonthOpenLS, MONTHOPPLW, " PMH ")
[t_pmlLine, t_pmlLbl] = UpdatePriorLevelLine(PrevMonthLowLine, PrevMonthLowLbl, ShowPrevMonthHL, PrevMonthHLStartTime, PrevMonthLow, i_PrevMonthLowCol, MonthOpenLS, MONTHOPPLW, " PML ")
PrevWeekHighLine := t_pwhLine
PrevWeekHighLbl := t_pwhLbl
PrevWeekLowLine := t_pwlLine
PrevWeekLowLbl := t_pwlLbl
PrevMonthHighLine := t_pmhLine
PrevMonthHighLbl := t_pmhLbl
PrevMonthLowLine := t_pmlLine
PrevMonthLowLbl := t_pmlLbl

var bool pwHiSweepAlerted = false
var bool pwLoSweepAlerted = false
var bool pmHiSweepAlerted = false
var bool pmLoSweepAlerted = false
if newOpenWeek
    pwHiSweepAlerted := false
    pwLoSweepAlerted := false
if newOpenMonth
    pmHiSweepAlerted := false
    pmLoSweepAlerted := false

bool prevWeekHighSweepAlert = ShowPrevWeekHL and DOM and barstate.isconfirmed and not na(PrevWeekHigh) and time > PrevWeekHLStartTime and high > PrevWeekHigh and close < PrevWeekHigh and high[1] <= PrevWeekHigh and (not AlertFirstBreakOnly or not pwHiSweepAlerted)
bool prevWeekLowSweepAlert = ShowPrevWeekHL and DOM and barstate.isconfirmed and not na(PrevWeekLow) and time > PrevWeekHLStartTime and low < PrevWeekLow and close > PrevWeekLow and low[1] >= PrevWeekLow and (not AlertFirstBreakOnly or not pwLoSweepAlerted)
bool prevMonthHighSweepAlert = ShowPrevMonthHL and DOM and barstate.isconfirmed and not na(PrevMonthHigh) and time > PrevMonthHLStartTime and high > PrevMonthHigh and close < PrevMonthHigh and high[1] <= PrevMonthHigh and (not AlertFirstBreakOnly or not pmHiSweepAlerted)
bool prevMonthLowSweepAlert = ShowPrevMonthHL and DOM and barstate.isconfirmed and not na(PrevMonthLow) and time > PrevMonthHLStartTime and low < PrevMonthLow and close > PrevMonthLow and low[1] >= PrevMonthLow and (not AlertFirstBreakOnly or not pmLoSweepAlerted)

if prevWeekHighSweepAlert
    pwHiSweepAlerted := true
if prevWeekLowSweepAlert
    pwLoSweepAlerted := true
if prevMonthHighSweepAlert
    pmHiSweepAlerted := true
if prevMonthLowSweepAlert
    pmLoSweepAlerted := true


// Weekly Open
// Redraw on the last bar too: a line drawn only at newDay is garbage-collected
// within hours once other features (e.g. FVG midlines) push past max_lines_count
if ShowWeekOpen and Last4Weeks and (newDay or barstate.islast)
    label.delete(Weekly_openlbl[1])
    line.delete(Weekly_open[1])
    // if ShowPrev == false
    //     line.delete(Weekly_open[1])
    Weekly_open:= line.new(x1=WeeklyOpenTime-((timeframe.isintraday or syminfo.type == "crypto") ? 0 : 25200000), y1=WeeklyOpen, x2=EquitiesOpenTime+52200000, xloc=xloc.bar_time, y2=WeeklyOpen, color=i_WeekOpenCol, style=WeekOpenLS, width=WEEKOPPLW)
    if dayofweek == dayofweek.friday and syminfo.type != "crypto"
        line.set_x2(Weekly_open, EquitiesOpenTime+225000000)
    if ShowLabel
        Weekly_openlbl := label.new(x=EquitiesOpenTime+52200000, y=WeeklyOpen, xloc=xloc.bar_time, color=LabelColor, textcolor=LabelTextColor, style=label.style_label_left, size=LabelSize, tooltip="Weekly Open: " + str.tostring(WeeklyOpen))
        if dayofweek == dayofweek.friday and syminfo.type != "crypto"
            label.set_x(Weekly_openlbl, EquitiesOpenTime+225000000)
        if ShowLabelText
            if SFistrue
                if ShowPrices == true
                    label.set_text(Weekly_openlbl," W.O.   |  " + str.tostring(WeeklyOpen))
                else
                    label.set_text(Weekly_openlbl," W.O. ")
                label.set_tooltip(Weekly_openlbl, " Weekly Opening Price ")
            else
                if ShowPrices == true
                    label.set_text(Weekly_openlbl," Weekly Open  |  " + str.tostring(WeeklyOpen))
                else
                    label.set_text(Weekly_openlbl," Weekly Open ")
                label.set_tooltip(Weekly_openlbl, "")
            label.set_textcolor(Weekly_openlbl, LabelTextColor)
            label.set_size(Weekly_openlbl, LabelSize)
if timeframe.multiplier > 60 and barstate.islast
    line.set_x2(Weekly_open, AsianEndTime + 232000000)
    label.set_x(Weekly_openlbl, AsianEndTime + 232000000)
if timeframe.period == "1D" and barstate.islast
    line.set_x2(Weekly_open, AsianEndTime + 832000000)
    label.set_x(Weekly_openlbl, AsianEndTime + 832000000)
if timeframe.period == "1M"
    line.delete(Weekly_open)
    label.delete(Weekly_openlbl)
if Terminusinp != "Terminus @ Next Midnight" and DOM and barstate.islast
    line.set_x2(Weekly_open, Terminus(Terminusinp))
    label.set_x(Weekly_openlbl, Terminus(Terminusinp))

// Monthly Open
if showMonthOpen and (newDay or barstate.islast)
    line.delete(Monthly_open[1])
    label.delete(Monthly_openlbl[1])
    Monthly_open:= line.new(x1=MonthlyOpenTime, y1=MonthlyOpen, x2=AsianEndTime, xloc=xloc.bar_time, y2=MonthlyOpen, color=i_MonthOpenCol, style=MonthOpenLS, width=MONTHOPPLW)
    if dayofweek == dayofweek.friday and syminfo.type != "crypto"
        line.set_x2(Monthly_open, EquitiesOpenTime+225000000)
    if ShowLabel
        Monthly_openlbl := label.new(x=AsianEndTime, y=MonthlyOpen, xloc=xloc.bar_time, color=LabelColor, textcolor=LabelTextColor, style=label.style_label_left, size=LabelSize, tooltip="Monthly Open: " + str.tostring(MonthlyOpen))
        if dayofweek == dayofweek.friday and syminfo.type != "crypto"
            label.set_x(Monthly_openlbl, EquitiesOpenTime+225000000)
        if ShowLabelText
            if SFistrue
                if ShowPrices == true
                    label.set_text(Monthly_openlbl," M.O.   |  " + str.tostring(MonthlyOpen))
                else
                    label.set_text(Monthly_openlbl," M.O. ")
                label.set_tooltip(Monthly_openlbl, " Monthly Opening Price ")
            else
                if ShowPrices == true
                    label.set_text(Monthly_openlbl, " Monthly Open  |  " + str.tostring(MonthlyOpen))
                else
                    label.set_text(Monthly_openlbl, " Monthly Open ")
                label.set_tooltip(Monthly_openlbl, "")
            label.set_textcolor(Monthly_openlbl, LabelTextColor)
            label.set_size(Monthly_openlbl, LabelSize)
if timeframe.multiplier > 60 and barstate.islast
    line.set_x2(Monthly_open, AsianEndTime + 232000000)
    label.set_x(Monthly_openlbl, AsianEndTime + 232000000)
if timeframe.period == "1D" and barstate.islast
    line.set_x2(Monthly_open, AsianEndTime + 832000000)
    label.set_x(Monthly_openlbl, AsianEndTime + 832000000)
if timeframe.period == "1W" and barstate.islast
    line.set_x2(Monthly_open, AsianEndTime + 2592000000)
    label.set_x(Monthly_openlbl, AsianEndTime + 2592000000)
if timeframe.period == "1M"
    line.delete(Monthly_open)
    label.delete(Monthly_openlbl)
if Terminusinp != "Terminus @ Next Midnight" and DOM and barstate.islast
    line.set_x2(Monthly_open, Terminus(Terminusinp))
    label.set_x(Monthly_openlbl, Terminus(Terminusinp))

 // CBDR Stuff
var float cbdr_hi                = na
var float cbdr_lo                = na
var float cbdr_diff              = na
var box   cbdrbox                = na
var line  cbdr_hi_line           = na
var line  cbdr_lo_line           = na
var line  dev01negline           = na
var line  dev02negline           = na
var line  dev03negline           = na
var line  dev04negline           = na
var line  dev01posline           = na
var line  dev02posline           = na
var line  dev03posline           = na
var line  dev04posline           = na

if SessionBegins(CBDR) and DOM
    cbdr_hi                 := high
    cbdr_lo                 := low
    cbdr_diff           := cbdr_hi - cbdr_lo
    if ShowTSO
        box.delete(cbdrbox[1])
        line.delete(dev01posline[1])
        line.delete(dev01negline[1])
        line.delete(dev02posline[1])
        line.delete(dev02negline[1])
        line.delete(dev03posline[1])
        line.delete(dev03negline[1])
        line.delete(dev04posline[1])
        line.delete(dev04negline[1])
    if ShowCBDR
        cbdrbox := box.new(cbdrOpenTime, cbdr_hi, cbdrEndTime, cbdr_lo, color.new(CBDRBoxCol,90), 1, line.style_solid, extend.none, xloc.bar_time, color.new(CBDRBoxCol,90), txt0, size.auto, color.new(box_text_cbdr_col,80), text_wrap=text.wrap_auto)
        if dayofweek == dayofweek.friday
            box.set_right(cbdrbox, cbdrOpenTime+187200000)
            if not na(cbdr_hi_line)
                line.set_x2(cbdr_hi_line, cbdrOpenTime+187200000)
            if not na(cbdr_lo_line)
                line.set_x2(cbdr_lo_line, cbdrOpenTime+187200000)
    if ShowCBDR and box_text_cbdr == false
        box.set_text(cbdrbox, "")
    if ShowDev and ShowCBDR and bool_cbdr_dev
        for i = 1 to CBDRDevCount by 1
            if i == 1
                dev01posline := line.new(cbdrOpenTime, cbdr_hi + cbdr_diff * i, cbdrEndTime, cbdr_hi + cbdr_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev01negline := line.new(cbdrOpenTime, cbdr_hi - cbdr_diff * i, cbdrEndTime, cbdr_lo - cbdr_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                if dayofweek == dayofweek.friday
                    line.set_x2(dev01posline, cbdrOpenTime+187200000)
                    line.set_x2(dev01negline, cbdrOpenTime+187200000)
            if i == 2
                dev02posline := line.new(cbdrOpenTime, cbdr_hi + cbdr_diff * i, cbdrEndTime, cbdr_lo + cbdr_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev02negline := line.new(cbdrOpenTime, cbdr_hi - cbdr_diff * i, cbdrEndTime, cbdr_lo - cbdr_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                if dayofweek == dayofweek.friday
                    line.set_x2(dev02posline, cbdrOpenTime+187200000)
                    line.set_x2(dev02negline, cbdrOpenTime+187200000)
            if i == 3
                dev03posline := line.new(cbdrOpenTime, cbdr_hi + cbdr_diff * i, cbdrEndTime, cbdr_lo + cbdr_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev03negline := line.new(cbdrOpenTime, cbdr_hi - cbdr_diff * i, cbdrEndTime, cbdr_lo - cbdr_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                if dayofweek == dayofweek.friday
                    line.set_x2(dev03posline, cbdrOpenTime+187200000)
                    line.set_x2(dev03negline, cbdrOpenTime+187200000)
            if i == 4
                dev04posline := line.new(cbdrOpenTime, cbdr_hi + cbdr_diff * i, cbdrEndTime, cbdr_lo + cbdr_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev04negline := line.new(cbdrOpenTime, cbdr_hi - cbdr_diff * i, cbdrEndTime, cbdr_lo - cbdr_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                if dayofweek == dayofweek.friday
                    line.set_x2(dev04posline, cbdrOpenTime+187200000)
                    line.set_x2(dev04negline, cbdrOpenTime+187200000)
else if CBDRTime and DOM
    cbdr_hi             := math.max(high, cbdr_hi)
    cbdr_lo             := math.min(low, cbdr_lo)
    cbdr_diff           := cbdr_hi - cbdr_lo
    for i = 1 to CBDRDevCount by 1
        if i == 1 and ShowDev and ShowCBDR
            line.set_y1(dev01posline, cbdr_hi + cbdr_diff * i)
            line.set_y2(dev01posline, cbdr_hi + cbdr_diff * i)

            line.set_y1(dev01negline, cbdr_lo - cbdr_diff * i)
            line.set_y2(dev01negline, cbdr_lo - cbdr_diff * i)
        if i == 2 and ShowDev and ShowCBDR
            line.set_y1(dev02posline, cbdr_hi + cbdr_diff * i)
            line.set_y2(dev02posline, cbdr_hi + cbdr_diff * i)

            line.set_y1(dev02negline, cbdr_lo - cbdr_diff * i)
            line.set_y2(dev02negline, cbdr_lo - cbdr_diff * i)
        if i == 3 and ShowDev and ShowCBDR
            line.set_y1(dev03posline, cbdr_hi + cbdr_diff * i)
            line.set_y2(dev03posline, cbdr_hi + cbdr_diff * i)

            line.set_y1(dev03negline, cbdr_lo - cbdr_diff * i)
            line.set_y2(dev03negline, cbdr_lo - cbdr_diff * i)
        if i == 4 and ShowDev and ShowCBDR
            line.set_y1(dev04posline, cbdr_hi + cbdr_diff * i)
            line.set_y2(dev04posline, cbdr_hi + cbdr_diff * i)

            line.set_y1(dev04negline, cbdr_lo - cbdr_diff * i)
            line.set_y2(dev04negline, cbdr_lo - cbdr_diff * i)
    if (cbdr_hi > cbdr_hi[1])
        if ShowCBDR
            box.set_top(cbdrbox, cbdr_hi)
    if (cbdr_lo < cbdr_lo[1])
        if ShowCBDR
            box.set_bottom(cbdrbox, cbdr_lo)

if DevDirection == "Upside Only"
    line.delete(dev01negline)
    line.delete(dev02negline)
    line.delete(dev03negline)
    line.delete(dev04negline)
else if DevDirection == "Downside Only"
    line.delete(dev01posline)
    line.delete(dev02posline)
    line.delete(dev03posline)
    line.delete(dev04posline)

// ASIA Stuff
var float asia_hi                   = na
var float asia_lo                   = na
var float asia_diff                 = na
var box   asia_box                  = na
var line  dev01negline_asia         = na
var line  dev02negline_asia         = na
var line  dev03negline_asia         = na
var line  dev04negline_asia         = na
var line  dev01posline_asia         = na
var line  dev02posline_asia         = na
var line  dev03posline_asia         = na
var line  dev04posline_asia         = na
if SessionBegins(ASIA) and DOM
    asia_hi                 := high
    asia_lo                 := low
    asia_diff               := asia_hi - asia_lo
    if ShowTSO
        box.delete(asia_box[1])
        line.delete(dev01posline_asia[1])
        line.delete(dev01negline_asia[1])
        line.delete(dev02posline_asia[1])
        line.delete(dev02negline_asia[1])
        line.delete(dev03posline_asia[1])
        line.delete(dev03negline_asia[1])
        line.delete(dev04posline_asia[1])
        line.delete(dev04negline_asia[1])
    if ShowASIA
        asia_box := box.new(asiaOpenTime, asia_hi, asiaEndTime, asia_lo, color.new(ASIABoxCol,90), 1, line.style_solid, extend.none, xloc.bar_time, color.new(ASIABoxCol,90), txt1, size.auto, color.new(box_text_asia_col,80), text_wrap=text.wrap_auto)
    if ShowASIA and box_text_asia == false
        box.set_text(asia_box, "")
    if ShowDev and ShowASIA and bool_asia_dev
        for i = 1 to ASIADevCount by 1
            if i == 1
                dev01posline_asia := line.new(asiaOpenTime, asia_hi + asia_diff * i, asiaEndTime, asia_hi + asia_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev01negline_asia := line.new(asiaOpenTime, asia_hi - asia_diff * i, asiaEndTime, asia_lo - asia_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
            if i == 2
                dev02posline_asia := line.new(asiaOpenTime, asia_hi + asia_diff * i, asiaEndTime, asia_lo + asia_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev02negline_asia := line.new(asiaOpenTime, asia_hi - asia_diff * i, asiaEndTime, asia_lo - asia_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
            if i == 3
                dev03posline_asia := line.new(asiaOpenTime, asia_hi + asia_diff * i, asiaEndTime, asia_lo + asia_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev03negline_asia := line.new(asiaOpenTime, asia_hi - asia_diff * i, asiaEndTime, asia_lo - asia_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
            if i == 4
                dev04posline_asia := line.new(asiaOpenTime, asia_hi + asia_diff * i, asiaEndTime, asia_lo + asia_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev04negline_asia := line.new(asiaOpenTime, asia_hi - asia_diff * i, asiaEndTime, asia_lo - asia_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
else if ASIATime and DOM
    asia_hi             := math.max(high, asia_hi)
    asia_lo             := math.min(low, asia_lo)
    asia_diff           := asia_hi - asia_lo
    for i = 1 to ASIADevCount by 1
        if i == 1 and ShowDev and ShowASIA
            line.set_y1(dev01posline_asia, asia_hi + asia_diff * i)
            line.set_y2(dev01posline_asia, asia_hi + asia_diff * i)

            line.set_y1(dev01negline_asia, asia_lo - asia_diff * i)
            line.set_y2(dev01negline_asia, asia_lo - asia_diff * i)
        if i == 2 and ShowDev and ShowASIA
            line.set_y1(dev02posline_asia, asia_hi + asia_diff * i)
            line.set_y2(dev02posline_asia, asia_hi + asia_diff * i)

            line.set_y1(dev02negline_asia, asia_lo - asia_diff * i)
            line.set_y2(dev02negline_asia, asia_lo - asia_diff * i)
        if i == 3 and ShowDev and ShowASIA
            line.set_y1(dev03posline_asia, asia_hi + asia_diff * i)
            line.set_y2(dev03posline_asia, asia_hi + asia_diff * i)

            line.set_y1(dev03negline_asia, asia_lo - asia_diff * i)
            line.set_y2(dev03negline_asia, asia_lo - asia_diff * i)
        if i == 4 and ShowDev and ShowASIA
            line.set_y1(dev04posline_asia, asia_hi + asia_diff * i)
            line.set_y2(dev04posline_asia, asia_hi + asia_diff * i)

            line.set_y1(dev04negline_asia, asia_lo - asia_diff * i)
            line.set_y2(dev04negline_asia, asia_lo - asia_diff * i)
    if ShowASIA and (asia_hi > asia_hi[1])
        box.set_top(asia_box, asia_hi)
    if ShowASIA and (asia_lo < asia_lo[1])
        box.set_bottom(asia_box, asia_lo)

if DevDirection == "Upside Only"
    line.delete(dev01negline_asia)
    line.delete(dev02negline_asia)
    line.delete(dev03negline_asia)
    line.delete(dev04negline_asia)
else if DevDirection == "Downside Only"
    line.delete(dev01posline_asia)
    line.delete(dev02posline_asia)
    line.delete(dev03posline_asia)
    line.delete(dev04posline_asia)

var bool cbdrHiAlerted = false
var bool cbdrLoAlerted = false
var bool asiaHiAlerted = false
var bool asiaLoAlerted = false
if SessionBegins(CBDR)
    cbdrHiAlerted := false
    cbdrLoAlerted := false
if SessionBegins(ASIA)
    asiaHiAlerted := false
    asiaLoAlerted := false

cbdrHighCross = ta.crossover(high, cbdr_hi)
cbdrLowCross = ta.crossunder(low, cbdr_lo)
asiaHighCross = ta.crossover(high, asia_hi)
asiaLowCross = ta.crossunder(low, asia_lo)

cbdrHighBreak = barstate.isconfirmed and not CBDRTime and not na(cbdr_hi) and cbdrHighCross and (not AlertFirstBreakOnly or not cbdrHiAlerted)
if cbdrHighBreak
    cbdrHiAlerted := true
cbdrLowBreak = barstate.isconfirmed and not CBDRTime and not na(cbdr_lo) and cbdrLowCross and (not AlertFirstBreakOnly or not cbdrLoAlerted)
if cbdrLowBreak
    cbdrLoAlerted := true
asiaHighBreak = barstate.isconfirmed and not ASIATime and not na(asia_hi) and asiaHighCross and (not AlertFirstBreakOnly or not asiaHiAlerted)
if asiaHighBreak
    asiaHiAlerted := true
asiaLowBreak = barstate.isconfirmed and not ASIATime and not na(asia_lo) and asiaLowCross and (not AlertFirstBreakOnly or not asiaLoAlerted)
if asiaLowBreak
    asiaLoAlerted := true

alertcondition(cbdrHighBreak, title="CBDR High Break", message="CBDR high broken")
alertcondition(cbdrLowBreak, title="CBDR Low Break", message="CBDR low broken")
alertcondition(asiaHighBreak, title="Asia High Break", message="Asia high broken")
alertcondition(asiaLowBreak, title="Asia Low Break", message="Asia low broken")
alertcondition(fvgTouchAlert, title="FVG Touch", message="FVG touched")
alertcondition(fvgFillAlert, title="FVG Fill", message="FVG filled")
alertcondition(nwogMidTouchAlert, title="NWOG Midpoint Touch", message="NWOG midpoint touched")
alertcondition(prevWeekHighSweepAlert, title="Previous Week High Sweep", message="Previous week high swept")
alertcondition(prevWeekLowSweepAlert, title="Previous Week Low Sweep", message="Previous week low swept")
alertcondition(prevMonthHighSweepAlert, title="Previous Month High Sweep", message="Previous month high swept")
alertcondition(prevMonthLowSweepAlert, title="Previous Month Low Sweep", message="Previous month low swept")

// FLOUT Stuff
var float flout_hi                  = na
var float flout_lo                  = na
var float flout_diff                = na
var box   floutbox                  = na
var line  flout_hi_line             = na
var line  flout_lo_line             = na
var line  dev01negline_flout        = na
var line  dev02negline_flout        = na
var line  dev03negline_flout        = na
var line  dev04negline_flout        = na
var line  dev01posline_flout        = na
var line  dev02posline_flout        = na
var line  dev03posline_flout        = na
var line  dev04posline_flout        = na
if SessionBegins(FLOUT) and DOM
    flout_hi            := high
    flout_lo            := low
    flout_diff          := flout_hi - flout_lo
    if ShowTSO
        box.delete(floutbox[1])
        line.delete(dev01posline_flout[1])
        line.delete(dev01negline_flout[1])
        line.delete(dev02posline_flout[1])
        line.delete(dev02negline_flout[1])
        line.delete(dev03posline_flout[1])
        line.delete(dev03negline_flout[1])
        line.delete(dev04posline_flout[1])
        line.delete(dev04negline_flout[1])
    if ShowFLOUT
        floutbox := box.new(floutOpenTime, flout_hi, floutEndTime, flout_lo, color.new(FLOUTBoxCol,90), 1, line.style_solid, extend.none, xloc.bar_time, color.new(FLOUTBoxCol,90), txt7, size.auto, color.new(box_text_flout_col,80), text_wrap=text.wrap_auto)
        if dayofweek == dayofweek.friday
            box.set_right(floutbox, floutOpenTime+201600000)
            if not na(flout_hi_line)
                line.set_x2(flout_hi_line, floutOpenTime+201600000)
            if not na(flout_lo_line)
                line.set_x2(flout_lo_line, floutOpenTime+201600000)
    if ShowFLOUT and box_text_flout == false
        box.set_text(floutbox, "")
    if ShowDev and ShowFLOUT and bool_flout_dev
        for i = 0.5 to FLOUTDevCount by 0.5
            if i == 0.5
                dev01posline_flout := line.new(floutOpenTime, flout_hi + flout_diff * i, floutEndTime, flout_hi + flout_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev01negline_flout := line.new(floutOpenTime, flout_hi - flout_diff * i, floutEndTime, flout_lo - flout_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                if dayofweek == dayofweek.friday
                    line.set_x2(dev01posline_flout, floutOpenTime+201600000)
                    line.set_x2(dev01negline_flout, floutOpenTime+201600000)
            if i == 1
                dev02posline_flout := line.new(floutOpenTime, flout_hi + flout_diff * i, floutEndTime, flout_lo + flout_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev02negline_flout := line.new(floutOpenTime, flout_hi - flout_diff * i, floutEndTime, flout_lo - flout_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                if dayofweek == dayofweek.friday
                    line.set_x2(dev02posline_flout, floutOpenTime+201600000)
                    line.set_x2(dev02negline_flout, floutOpenTime+201600000)
            if i == 1.5
                dev03posline_flout := line.new(floutOpenTime, flout_hi + flout_diff * i, floutEndTime, flout_lo + flout_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev03negline_flout := line.new(floutOpenTime, flout_hi - flout_diff * i, floutEndTime, flout_lo - flout_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                if dayofweek == dayofweek.friday
                    line.set_x2(dev03posline_flout, floutOpenTime+201600000)
                    line.set_x2(dev03negline_flout, floutOpenTime+201600000)
            if i == 2
                dev04posline_flout := line.new(floutOpenTime, flout_hi + flout_diff * i, floutEndTime, flout_lo + flout_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev04negline_flout := line.new(floutOpenTime, flout_hi - flout_diff * i, floutEndTime, flout_lo - flout_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                if dayofweek == dayofweek.friday
                    line.set_x2(dev04posline_flout, floutOpenTime+201600000)
                    line.set_x2(dev04negline_flout, floutOpenTime+201600000)
else if FLOUTTime and DOM
    flout_hi             := math.max(high, flout_hi)
    flout_lo             := math.min(low, flout_lo)
    flout_diff           := flout_hi - flout_lo
    for i = 0.5 to FLOUTDevCount by 0.5
        if i == 0.5 and ShowDev and ShowFLOUT
            line.set_y1(dev01posline_flout, flout_hi + flout_diff * i)
            line.set_y2(dev01posline_flout, flout_hi + flout_diff * i)

            line.set_y1(dev01negline_flout, flout_lo - flout_diff * i)
            line.set_y2(dev01negline_flout, flout_lo - flout_diff * i)
        if i == 1 and ShowDev and ShowFLOUT
            line.set_y1(dev02posline_flout, flout_hi + flout_diff * i)
            line.set_y2(dev02posline_flout, flout_hi + flout_diff * i)

            line.set_y1(dev02negline_flout, flout_lo - flout_diff * i)
            line.set_y2(dev02negline_flout, flout_lo - flout_diff * i)
        if i == 1.5 and ShowDev and ShowFLOUT
            line.set_y1(dev03posline_flout, flout_hi + flout_diff * i)
            line.set_y2(dev03posline_flout, flout_hi + flout_diff * i)

            line.set_y1(dev03negline_flout, flout_lo - flout_diff * i)
            line.set_y2(dev03negline_flout, flout_lo - flout_diff * i)
        if i == 2 and ShowDev and ShowFLOUT
            line.set_y1(dev04posline_flout, flout_hi + flout_diff * i)
            line.set_y2(dev04posline_flout, flout_hi + flout_diff * i)

            line.set_y1(dev04negline_flout, flout_lo - flout_diff * i)
            line.set_y2(dev04negline_flout, flout_lo - flout_diff * i)
    if ShowFLOUT and (flout_hi > flout_hi[1])
        box.set_top(floutbox, flout_hi)
    if ShowFLOUT and (flout_lo < flout_lo[1])
        box.set_bottom(floutbox, flout_lo)

if DevDirection == "Upside Only"
    line.delete(dev01negline_flout)
    line.delete(dev02negline_flout)
    line.delete(dev03negline_flout)
    line.delete(dev04negline_flout)
else if DevDirection == "Downside Only"
    line.delete(dev01posline_flout)
    line.delete(dev02posline_flout)
    line.delete(dev03posline_flout)
    line.delete(dev04posline_flout)


// Start of Table
cbdrpipc                        = toWhole(cbdr_diff)
asiapipc                        = toWhole(asia_diff)
var color cbdr_cellt_col        = na
var color asia_cellt_col        = na
var color L_profile_col         = na

var color comp_green            = color.new(#1cac78,0)
var color comp_red              = color.new(#ff4040,0)
var color comp_gray             = color.new(#808080,0)
var L_Profile                   = ""

if cbdrpipc > 15 and cbdrpipc < 40
    cbdr_cellt_col  := color.new(#1cac78,0)     // Green
else
    cbdr_cellt_col  := color.new(#ff4040,0)     // Red

if asiapipc >= 20 and asiapipc <= 40
    asia_cellt_col  := color.new(#1cac78,0)     // Green
else
    asia_cellt_col  := color.new(#ff4040,0)     // Red

if cbdrpipc > 15 and cbdrpipc < 40
    L_Profile := "CBDR"
    L_profile_col := Tab1txtCol
else if asiapipc >= 20 and asiapipc <= 40
    L_Profile := "ASIA"
    L_profile_col := Tab1txtCol
else
    L_Profile := "FLOUT"
    L_profile_col := Tab1txtCol

if BarInSession(midsesh) and Auto_Select == true and syminfo.type == "forex"
    if cbdrpipc > 15 and cbdrpipc < 40
        // ASIA
        box.delete(asia_box)
        line.delete(dev01posline_asia)
        line.delete(dev01negline_asia)
        line.delete(dev02posline_asia)
        line.delete(dev02negline_asia)
        line.delete(dev03posline_asia)
        line.delete(dev03negline_asia)
        line.delete(dev04posline_asia)
        line.delete(dev04negline_asia)
        // FLOUT
        box.delete(floutbox)
        line.delete(dev01posline_flout)
        line.delete(dev01negline_flout)
        line.delete(dev02posline_flout)
        line.delete(dev02negline_flout)
        line.delete(dev03posline_flout)
        line.delete(dev03negline_flout)
        line.delete(dev04posline_flout)
        line.delete(dev04negline_flout)
    else if asiapipc >= 20 and asiapipc <= 40
        // CBDR
        box.delete(cbdrbox)
        line.delete(dev01posline)
        line.delete(dev01negline)
        line.delete(dev02posline)
        line.delete(dev02negline)
        line.delete(dev03posline)
        line.delete(dev03negline)
        line.delete(dev04posline)
        line.delete(dev04negline)
        // FLOUT
        box.delete(floutbox)
        line.delete(dev01posline_flout)
        line.delete(dev01negline_flout)
        line.delete(dev02posline_flout)
        line.delete(dev02negline_flout)
        line.delete(dev03posline_flout)
        line.delete(dev03negline_flout)
        line.delete(dev04posline_flout)
        line.delete(dev04negline_flout)
    else
        // CBDR
        box.delete(cbdrbox)
        line.delete(dev01posline)
        line.delete(dev01negline)
        line.delete(dev02posline)
        line.delete(dev02negline)
        line.delete(dev03posline)
        line.delete(dev03negline)
        line.delete(dev04posline)
        line.delete(dev04negline)
        // ASIA
        box.delete(asia_box)
        line.delete(dev01posline_asia)
        line.delete(dev01negline_asia)
        line.delete(dev02posline_asia)
        line.delete(dev02negline_asia)
        line.delete(dev03posline_asia)
        line.delete(dev03negline_asia)
        line.delete(dev04posline_asia)
        line.delete(dev04negline_asia)



// Table
var table ICTInfo = table.new(tabinp1, 2, 3, border_width=1)

if barstate.islast and syminfo.type == "forex" and Stats and DOM and (dayofweek != dayofweek.sunday)
    CBDR_cell           = "CBDR "
    Asia_cell           = "Asian Range "
    CBDR_cell_pipc      = "     " + str.tostring(cbdrpipc) + " pips"
    ASIA_cell_pipc      = "     " + str.tostring(asiapipc) + " pips"

    if L_Prof == true
        table.cell(ICTInfo, 0, 0, text=" Suggested SD ", bgcolor=CellBG, text_color=Tab1txtCol, text_halign=text.align_left, text_size=size.auto)
    table.cell(ICTInfo, 0, 1, text=" Asian Range ", bgcolor=CellBG, text_color=Tab1txtCol, text_halign=text.align_left, text_size=size.auto)
    table.cell(ICTInfo, 0, 2, text=" CBDR ", bgcolor=CellBG, text_color=Tab1txtCol, text_halign=text.align_left, text_size=size.auto)

    if L_Prof == true
        table.cell(ICTInfo, 1, 0, text=" "+ L_Profile + " ", bgcolor=CellBG, text_color=L_profile_col, text_halign=text.align_right, text_size=size.auto)
    table.cell(ICTInfo, 1, 1, text=ASIA_cell_pipc, bgcolor=CellBG, text_color=asia_cellt_col, text_size=size.auto, text_halign=text.align_right)
    table.cell(ICTInfo, 1, 2, text=CBDR_cell_pipc, bgcolor=CellBG, text_color=cbdr_cellt_col, text_size=size.auto, text_halign=text.align_right)

// Color Coding
var color Option1CC             = na
var color Option2CC             = na
var color Option3CC             = na
var color Option4CC             = na

if BIASOption1 == "Bullish"
    Option1CC := comp_green
else if BIASOption1 == "Bearish"
    Option1CC := comp_red
else
    Option1CC := Tab2txtCol

if BIASOption2 == "Bullish"
    Option2CC := comp_green
else if BIASOption2 == "Bearish"
    Option2CC := comp_red
else
    Option2CC := Tab2txtCol

if BIASOption3 == "Bullish"
    Option3CC := comp_green
else if BIASOption3 == "Bearish"
    Option3CC := comp_red
else
    Option3CC := Tab2txtCol

if BIASOption4 == "Bullish"
    Option4CC := comp_green
else if BIASOption4 == "Bearish"
    Option4CC := comp_red
else
    Option4CC := Tab2txtCol

var table BIAS_Table = table.new(tabinp2, 2, 20, bgcolor=TableBG2, border_width=1)
if barstate.islast and BIAS_M_Bool
	if BIASbool1
    	table.cell(BIAS_Table, 0, 1, text = txt52, text_color = Tab2txtCol, text_halign=text.align_left)
    	table.cell(BIAS_Table, 1, 1, text = BIASOption1, text_size = size.normal, text_color = Option1CC, text_halign=text.align_right)
    if BIASbool2
    	table.cell(BIAS_Table, 0, 2, text = txt53, text_color = Tab2txtCol, text_halign=text.align_left)
    	table.cell(BIAS_Table, 1, 2, text = BIASOption2, text_size = size.normal, text_color = Option2CC, text_halign=text.align_right)
	if BIASbool3
    	table.cell(BIAS_Table, 0, 3, text = txt54, text_color = Tab2txtCol, text_halign=text.align_left)
    	table.cell(BIAS_Table, 1, 3, text = BIASOption3, text_size = size.normal, text_color = Option3CC, text_halign=text.align_right)
	if BIASbool4
    	table.cell(BIAS_Table, 0, 4, text = txt55, text_color = Tab2txtCol, text_halign=text.align_left)
    	table.cell(BIAS_Table, 1, 4, text = BIASOption4, text_size = size.normal, text_color = Option4CC, text_halign=text.align_right)

var table NOTES_Table = table.new(tabinp3, 1, 20, bgcolor = TableBG2, border_width = 1)
if barstate.islast and NOTES_M_Bool
    table.cell(NOTES_Table, 0,0, text = notes, text_size = size.normal, text_color = Tab3txtCol, text_halign=text.align_center)

// Day of the Week
txtMon    = "M O N"
txtTue    = "T U E"
txtWed    = "W E D"
txtThu    = "T H U"
txtFri    = "F R I"
txtSat    = "S A T"
txtSun    = "S U N"
dowHour   = hour(time, Timezone)
dowMinute = minute(time, Timezone)
dowDay    = dayofweek(time, Timezone)
// Label anchor: first bar at/after DOWTime each calendar day. Requiring the exact
// DOWTime:00 bar drops the label on half-days where that bar never prints
// (e.g. Jul 3 2026, 13:00 ET close). Day-start bars already past DOWTime also
// fire, so post-holiday evening reopens still get their label.
dowMinOfDay = dowHour * 60 + dowMinute
dowPastLabelTime = dowMinOfDay >= DOWTime * 60
dowDayChanged = ta.change(dowDay) != 0
dowLabelBar = dowPastLabelTime and (not dowPastLabelTime[1] or dowDayChanged)

plotchar(showDOW and DOM and SL4W and Last4Weeks and (not ShowTWO)? dowLabelBar and dowDay == dayofweek.monday    : false, offset=0, char=" ", text=txtMon   , color=color.new(i_DOWCol,100), location = DOWLoc, textcolor=i_DOWCol, editable=false)
plotchar(showDOW and DOM and SL4W and Last4Weeks and (not ShowTWO)? dowLabelBar and dowDay == dayofweek.tuesday   : false, offset=0, char=" ", text=txtTue   , color=color.new(i_DOWCol,100), location = DOWLoc, textcolor=i_DOWCol, editable=false)
plotchar(showDOW and DOM and SL4W and Last4Weeks and (not ShowTWO)? dowLabelBar and dowDay == dayofweek.wednesday : false, offset=0, char=" ", text=txtWed   , color=color.new(i_DOWCol,100), location = DOWLoc, textcolor=i_DOWCol, editable=false)
plotchar(showDOW and DOM and SL4W and Last4Weeks and (not ShowTWO)? dowLabelBar and dowDay == dayofweek.thursday  : false, offset=0, char=" ", text=txtThu   , color=color.new(i_DOWCol,100), location = DOWLoc, textcolor=i_DOWCol, editable=false)
plotchar(showDOW and DOM and SL4W and Last4Weeks and (not ShowTWO)? dowLabelBar and dowDay == dayofweek.friday    : false, offset=0, char=" ", text=txtFri   , color=color.new(i_DOWCol,100), location = DOWLoc, textcolor=i_DOWCol, editable=false)

plotchar(showDOW and DOM and ShowTWO and thisweek? dowLabelBar and dowDay == dayofweek.monday    : false, offset=0, char=" ", text=txtMon   , color=color.new(i_DOWCol,100), location = DOWLoc, textcolor=i_DOWCol, editable=false)
plotchar(showDOW and DOM and ShowTWO and thisweek? dowLabelBar and dowDay == dayofweek.tuesday   : false, offset=0, char=" ", text=txtTue   , color=color.new(i_DOWCol,100), location = DOWLoc, textcolor=i_DOWCol, editable=false)
plotchar(showDOW and DOM and ShowTWO and thisweek? dowLabelBar and dowDay == dayofweek.wednesday : false, offset=0, char=" ", text=txtWed   , color=color.new(i_DOWCol,100), location = DOWLoc, textcolor=i_DOWCol, editable=false)
plotchar(showDOW and DOM and ShowTWO and thisweek? dowLabelBar and dowDay == dayofweek.thursday  : false, offset=0, char=" ", text=txtThu   , color=color.new(i_DOWCol,100), location = DOWLoc, textcolor=i_DOWCol, editable=false)
plotchar(showDOW and DOM and ShowTWO and thisweek? dowLabelBar and dowDay == dayofweek.friday    : false, offset=0, char=" ", text=txtFri   , color=color.new(i_DOWCol,100), location = DOWLoc, textcolor=i_DOWCol, editable=false)

plotchar(showDOW and DOM and (not ShowTWO) and (not SL4W)? dowLabelBar and dowDay == dayofweek.monday    : false, offset=0, char=" ", text=txtMon   , color=color.new(i_DOWCol,100), location = DOWLoc, textcolor=i_DOWCol, editable=false)
plotchar(showDOW and DOM and (not ShowTWO) and (not SL4W)? dowLabelBar and dowDay == dayofweek.tuesday   : false, offset=0, char=" ", text=txtTue   , color=color.new(i_DOWCol,100), location = DOWLoc, textcolor=i_DOWCol, editable=false)
plotchar(showDOW and DOM and (not ShowTWO) and (not SL4W)? dowLabelBar and dowDay == dayofweek.wednesday : false, offset=0, char=" ", text=txtWed   , color=color.new(i_DOWCol,100), location = DOWLoc, textcolor=i_DOWCol, editable=false)
plotchar(showDOW and DOM and (not ShowTWO) and (not SL4W)? dowLabelBar and dowDay == dayofweek.thursday  : false, offset=0, char=" ", text=txtThu   , color=color.new(i_DOWCol,100), location = DOWLoc, textcolor=i_DOWCol, editable=false)
plotchar(showDOW and DOM and (not ShowTWO) and (not SL4W)? dowLabelBar and dowDay == dayofweek.friday    : false, offset=0, char=" ", text=txtFri   , color=color.new(i_DOWCol,100), location = DOWLoc, textcolor=i_DOWCol, editable=false)


// plotshape(ShowLondon? BarInSession(LDNsesh) : false, style = shape.square, size=size.auto, location =location.bottom, color = LSFC)

var int daycount    =   0
var int SL4WC       =   0
if SL4W == true
    if dayofweek == dayofweek.monday
        SL4WC := 0 + 28
    if dayofweek == dayofweek.tuesday
        SL4WC := 1 + 28
    if dayofweek == dayofweek.wednesday
        SL4WC := 2 + 28
    if dayofweek == dayofweek.thursday
        SL4WC := 3 + 28
    if dayofweek == dayofweek.friday
        SL4WC := 4 + 28
    if dayofweek == dayofweek.saturday
        SL4WC := 5 + 28
    if dayofweek == dayofweek.sunday
        SL4WC := 6 + 28

if SL4W and (newDay or barstate.islast)
    Cleanup(SL4WC)



if ShowTWO
    if dayofweek == dayofweek.monday
        daycount := 0
    if dayofweek == dayofweek.tuesday
        daycount := 1
    if dayofweek == dayofweek.wednesday
        daycount := 2
    if dayofweek == dayofweek.thursday
        daycount := 3
    if dayofweek == dayofweek.friday
        daycount := 4
    if dayofweek == dayofweek.saturday
        daycount := 5
    if dayofweek == dayofweek.sunday
        daycount := 6

if ShowTWO and (newDay or barstate.islast)
    Cleanup(daycount)
````
