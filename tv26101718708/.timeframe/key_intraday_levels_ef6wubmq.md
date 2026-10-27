# Key Intraday Levels

- url: https://www.tradingview.com/script/EF6wUbmQ-Key-Intraday-Levels/
- type: indicator
- pine_id: PUB;904ea6be5b6547729f1cd930255a57f7
- version: 3.0

## Description

[b]Key Intraday Levels
[/b]
A clean, all-in-one overlay for ICT and SMC traders. Plots every key intraday reference prices — session boxes, opening prices, and previous day/week highs and lows — without cluttering your chart with multiple separate indicators.

[b]What it does
[/b]

[b]🟧 Session Boxes[/b]
Highlights the price range of up to 5 trading sessions directly on your chart:

- Asian Range (default 18:00 – 03:00 ET)
- London (default 02:00 – 05:00 ET)
- NY AM (default 09:30 – 12:00 ET)
- Lunch Hour (optional, default off)
- NY PM (optional, default off)

Each box has its own color, and the start/end times are fully configurable in 15-minute increments. Boxes automatically hide on timeframes above 1H to keep higher timeframe charts clean. At 6pm ET (CME daily rollover), the previous day's boxes fade out — you control how many prior days stay visible.

[b] 📐 Key Liquidity Lines[/b]
Once a session closes, the indicator draws a horizontal line extending from the **exact candle** where that session's High or Low was formed. These are the liquidity levels price tends to return to.

- Lines extend forward until price **takes the level**, then freeze in place
- A configurable grace period lets the line extend a few candles past the take before stopping
- Each session (Asian, London, NY AM, Lunch, NY PM) has its own visibility toggle
- Labels sit **above** High lines and **below** Low lines, showing the session name (e.g. *AS High*, *LO Low*, *AM High*) and optionally the exact price
- Label position (Left / Center / Right) controls where along the line the text is anchored

[b]📌 Opens[/b]
Marks three key opening prices with a vertical line and an optional horizontal level extending forward:

- Midnight Open — start of the new CME trading day
- 8:30 Open — pre-market economic release time (optional, default off)
- 9:30am Open — NYSE/equities open

Each open has independent color, style, and width. Labels (*Midnight*, *8:30am*, *9:30am*) appear to the right of the horizontal level. Like session boxes, opens from prior days fade out at 6pm ET — previous days show only the vertical line, keeping your chart focused on the most recent levels.

[b]📊 Daily & Weekly Levels[/b]
Plots the four most-watched higher timeframe reference levels:

- PDH — Previous Day High (blue solid)
- PDL — Previous Day Low (red solid)
- PWH — Previous Week High (blue dashed)
- PWL — Previous Week Low (red dashed)

Lines start from the bar where the extreme was actually formed, not from the session open. They freeze when price takes the level, with an optional candle grace period. Labels show the level name and price.


[b]Timezone:[/b] The indicator defaults to New York (ET). If your chart is set to a different timezone, adjust the Timezone setting to match so session detection stays accurate.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// © traderdiegox

//@version=6
indicator("Key Intraday Levels", shorttitle="Key levels", overlay=true,
          max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ════════════════════════════════════════════════════════════════════════════
// INPUTS — GENERAL
// ════════════════════════════════════════════════════════════════════════════
string GEN = "⚙  General"
string tz      = input.string("America/New_York", "Timezone",
    options=["America/New_York","America/Chicago","America/Los_Angeles",
             "Europe/London","Europe/Berlin","Asia/Tokyo","Asia/Singapore"],
    group=GEN)
int  prev_days   = input.int(1,  "Show Previous Sessions",  minval=0, maxval=10, group=GEN)
int  prev_opens  = input.int(1,  "Show Previous Opens",     minval=0, maxval=10, group=GEN)
string bsty_in = input.string("Dotted", "Box Border Style",
    options=["Solid","Dashed","Dotted"], group=GEN)
int  bw_in      = input.int(1, "Box Border Width", minval=1, maxval=4, group=GEN)
int  extend_bars = input.int(5, "H-Line Extension (bars)", minval=0, maxval=500, group=GEN)
float atr_mult   = input.float(1.5, "Max Detection Range (Daily ATR)", minval=0.0, maxval=20.0, step=0.5, group=GEN,
     tooltip="Only draw EQH/EQL (and future 5m–1D swing levels) within this many Daily ATRs of current price; farther ones are hidden. 0 = no limit.")

// ════════════════════════════════════════════════════════════════════════════
// INPUTS — DAILY & WEEKLY LEVELS
// ════════════════════════════════════════════════════════════════════════════
string GDW = "📊  Daily & Weekly Levels"
bool   show_dw_labels = input.bool(true, "Show Labels", group=GDW)

bool   show_pdh   = input.bool(true,  "PDH",  group=GDW, inline="pdh")
color  pdh_col    = input.color(color.new(#2196F3,  0),  "", group=GDW, inline="pdh")
string pdh_sty_in = input.string("Solid",  "", options=["Solid","Dashed","Dotted"], group=GDW, inline="pdh")
int    pdh_w      = input.int(2, "", minval=1, maxval=4,  group=GDW, inline="pdh")
string pdh_lbl    = input.string("PDH", "",               group=GDW, inline="pdh")

bool   show_pdl   = input.bool(true,  "PDL",  group=GDW, inline="pdl")
color  pdl_col    = input.color(color.new(#F44336,  0),  "", group=GDW, inline="pdl")
string pdl_sty_in = input.string("Solid",  "", options=["Solid","Dashed","Dotted"], group=GDW, inline="pdl")
int    pdl_w      = input.int(2, "", minval=1, maxval=4,  group=GDW, inline="pdl")
string pdl_lbl    = input.string("PDL", "",               group=GDW, inline="pdl")

bool   show_pwh   = input.bool(true,  "PWH",  group=GDW, inline="pwh")
color  pwh_col    = input.color(color.new(#2196F3,  0),  "", group=GDW, inline="pwh")
string pwh_sty_in = input.string("Dashed", "", options=["Solid","Dashed","Dotted"], group=GDW, inline="pwh")
int    pwh_w      = input.int(2, "", minval=1, maxval=4,  group=GDW, inline="pwh")
string pwh_lbl    = input.string("PWH", "",               group=GDW, inline="pwh")

bool   show_pwl   = input.bool(true,  "PWL",  group=GDW, inline="pwl")
color  pwl_col    = input.color(color.new(#F44336,  0),  "", group=GDW, inline="pwl")
string pwl_sty_in = input.string("Dashed", "", options=["Solid","Dashed","Dotted"], group=GDW, inline="pwl")
int    pwl_w      = input.int(2, "", minval=1, maxval=4,  group=GDW, inline="pwl")
string pwl_lbl    = input.string("PWL", "",               group=GDW, inline="pwl")

int    dw_grace      = input.int(0,       "Extend after taken (Candles)", group=GDW, minval=0, maxval=500)
bool   dw_show_price = input.bool(false, "Show Price in Label",          group=GDW)
string d_lbl_pos     = input.string("Center", "Daily levels position",  options=["Left","Center","Right","Front"], group=GDW)
string w_lbl_pos     = input.string("Center", "Weekly levels position", options=["Left","Center","Right","Front"], group=GDW)

// ════════════════════════════════════════════════════════════════════════════
// INPUTS — OPENS
// ════════════════════════════════════════════════════════════════════════════
string GOP = "📌  Opens"

bool   show_mid    = input.bool(true,  "Midnight Open",   group=GOP, inline="mid")
color  mid_col     = input.color(color.new(#424242,  0),  "", group=GOP, inline="mid")
string mid_sty_in  = input.string("Dotted", "",  options=["Solid","Dashed","Dotted"], group=GOP, inline="mid")
int    mid_w       = input.int(1, "", minval=1, maxval=4,  group=GOP, inline="mid")
bool   show_mid_h  = input.bool(true,  "H-Line",           group=GOP, inline="mid")

bool   show_830    = input.bool(false, "8:30 Open",        group=GOP, inline="830")
color  col_830     = input.color(color.new(#616161, 0),    "", group=GOP, inline="830")
string sty_830_in  = input.string("Dotted", "",  options=["Solid","Dashed","Dotted"], group=GOP, inline="830")
int    w_830       = input.int(1, "", minval=1, maxval=4,  group=GOP, inline="830")
bool   show_830_h  = input.bool(false, "H-Line",           group=GOP, inline="830")

bool   show_930    = input.bool(true,  "9:30am Open",      group=GOP, inline="930")
color  col_930     = input.color(color.new(#616161, 0),    "", group=GOP, inline="930")
string sty_930_in  = input.string("Dotted", "",  options=["Solid","Dashed","Dotted"], group=GOP, inline="930")
int    w_930       = input.int(1, "", minval=1, maxval=4,  group=GOP, inline="930")
bool   show_930_h  = input.bool(false, "H-Line",           group=GOP, inline="930")

bool   show_open_lbl  = input.bool(true,    "Open Labels",  group=GOP, inline="open_lbl")
bool   open_lbl_price = input.bool(false,   "Show Price",   group=GOP, inline="open_lbl")
string open_lbl_sz    = input.string("small", "Label Size", options=["tiny","small","normal","large"], group=GOP)

// ════════════════════════════════════════════════════════════════════════════
// INPUTS — KEY LIQUIDITY
// ════════════════════════════════════════════════════════════════════════════
string GKL = "🔑  Key Liquidity Boxes"

// Time options must be inlined as a const literal per input (Pine limitation)
// 00:00 → 23:45, 15-min steps

bool   show_asia  = input.bool(true,  "Asian Range",    group=GKL, inline="asia")
color  asia_col   = input.color(color.new(#FF9800, 95), "", group=GKL, inline="asia")
string asia_s_in  = input.string("18:00", "",  group=GKL, inline="asia",
    options=["00:00","00:15","00:30","00:45","01:00","01:15","01:30","01:45",
             "02:00","02:15","02:30","02:45","03:00","03:15","03:30","03:45",
             "04:00","04:15","04:30","04:45","05:00","05:15","05:30","05:45",
             "06:00","06:15","06:30","06:45","07:00","07:15","07:30","07:45",
             "08:00","08:15","08:30","08:45","09:00","09:15","09:30","09:45",
             "10:00","10:15","10:30","10:45","11:00","11:15","11:30","11:45",
             "12:00","12:15","12:30","12:45","13:00","13:15","13:30","13:45",
             "14:00","14:15","14:30","14:45","15:00","15:15","15:30","15:45",
             "16:00","16:15","16:30","16:45","17:00","17:15","17:30","17:45",
             "18:00","18:15","18:30","18:45","19:00","19:15","19:30","19:45",
             "20:00","20:15","20:30","20:45","21:00","21:15","21:30","21:45",
             "22:00","22:15","22:30","22:45","23:00","23:15","23:30","23:45"])
string asia_e_in  = input.string("03:00", "—", group=GKL, inline="asia",
    options=["00:00","00:15","00:30","00:45","01:00","01:15","01:30","01:45",
             "02:00","02:15","02:30","02:45","03:00","03:15","03:30","03:45",
             "04:00","04:15","04:30","04:45","05:00","05:15","05:30","05:45",
             "06:00","06:15","06:30","06:45","07:00","07:15","07:30","07:45",
             "08:00","08:15","08:30","08:45","09:00","09:15","09:30","09:45",
             "10:00","10:15","10:30","10:45","11:00","11:15","11:30","11:45",
             "12:00","12:15","12:30","12:45","13:00","13:15","13:30","13:45",
             "14:00","14:15","14:30","14:45","15:00","15:15","15:30","15:45",
             "16:00","16:15","16:30","16:45","17:00","17:15","17:30","17:45",
             "18:00","18:15","18:30","18:45","19:00","19:15","19:30","19:45",
             "20:00","20:15","20:30","20:45","21:00","21:15","21:30","21:45",
             "22:00","22:15","22:30","22:45","23:00","23:15","23:30","23:45"])

bool   show_lon   = input.bool(true,  "London Session", group=GKL, inline="lon")
color  lon_col    = input.color(color.new(#2196F3, 95), "", group=GKL, inline="lon")
string lon_s_in   = input.string("03:00", "",  group=GKL, inline="lon",
    options=["00:00","00:15","00:30","00:45","01:00","01:15","01:30","01:45",
             "02:00","02:15","02:30","02:45","03:00","03:15","03:30","03:45",
             "04:00","04:15","04:30","04:45","05:00","05:15","05:30","05:45",
             "06:00","06:15","06:30","06:45","07:00","07:15","07:30","07:45",
             "08:00","08:15","08:30","08:45","09:00","09:15","09:30","09:45",
             "10:00","10:15","10:30","10:45","11:00","11:15","11:30","11:45",
             "12:00","12:15","12:30","12:45","13:00","13:15","13:30","13:45",
             "14:00","14:15","14:30","14:45","15:00","15:15","15:30","15:45",
             "16:00","16:15","16:30","16:45","17:00","17:15","17:30","17:45",
             "18:00","18:15","18:30","18:45","19:00","19:15","19:30","19:45",
             "20:00","20:15","20:30","20:45","21:00","21:15","21:30","21:45",
             "22:00","22:15","22:30","22:45","23:00","23:15","23:30","23:45"])
string lon_e_in   = input.string("09:30", "—", group=GKL, inline="lon",
    options=["00:00","00:15","00:30","00:45","01:00","01:15","01:30","01:45",
             "02:00","02:15","02:30","02:45","03:00","03:15","03:30","03:45",
             "04:00","04:15","04:30","04:45","05:00","05:15","05:30","05:45",
             "06:00","06:15","06:30","06:45","07:00","07:15","07:30","07:45",
             "08:00","08:15","08:30","08:45","09:00","09:15","09:30","09:45",
             "10:00","10:15","10:30","10:45","11:00","11:15","11:30","11:45",
             "12:00","12:15","12:30","12:45","13:00","13:15","13:30","13:45",
             "14:00","14:15","14:30","14:45","15:00","15:15","15:30","15:45",
             "16:00","16:15","16:30","16:45","17:00","17:15","17:30","17:45",
             "18:00","18:15","18:30","18:45","19:00","19:15","19:30","19:45",
             "20:00","20:15","20:30","20:45","21:00","21:15","21:30","21:45",
             "22:00","22:15","22:30","22:45","23:00","23:15","23:30","23:45"])

bool   show_nyam  = input.bool(true,  "NY AM Session",  group=GKL, inline="nyam")
color  nyam_col   = input.color(color.new(#4CAF50, 95), "", group=GKL, inline="nyam")
string nyam_s_in  = input.string("09:30", "",  group=GKL, inline="nyam",
    options=["00:00","00:15","00:30","00:45","01:00","01:15","01:30","01:45",
             "02:00","02:15","02:30","02:45","03:00","03:15","03:30","03:45",
             "04:00","04:15","04:30","04:45","05:00","05:15","05:30","05:45",
             "06:00","06:15","06:30","06:45","07:00","07:15","07:30","07:45",
             "08:00","08:15","08:30","08:45","09:00","09:15","09:30","09:45",
             "10:00","10:15","10:30","10:45","11:00","11:15","11:30","11:45",
             "12:00","12:15","12:30","12:45","13:00","13:15","13:30","13:45",
             "14:00","14:15","14:30","14:45","15:00","15:15","15:30","15:45",
             "16:00","16:15","16:30","16:45","17:00","17:15","17:30","17:45",
             "18:00","18:15","18:30","18:45","19:00","19:15","19:30","19:45",
             "20:00","20:15","20:30","20:45","21:00","21:15","21:30","21:45",
             "22:00","22:15","22:30","22:45","23:00","23:15","23:30","23:45"])
string nyam_e_in  = input.string("12:00", "—", group=GKL, inline="nyam",
    options=["00:00","00:15","00:30","00:45","01:00","01:15","01:30","01:45",
             "02:00","02:15","02:30","02:45","03:00","03:15","03:30","03:45",
             "04:00","04:15","04:30","04:45","05:00","05:15","05:30","05:45",
             "06:00","06:15","06:30","06:45","07:00","07:15","07:30","07:45",
             "08:00","08:15","08:30","08:45","09:00","09:15","09:30","09:45",
             "10:00","10:15","10:30","10:45","11:00","11:15","11:30","11:45",
             "12:00","12:15","12:30","12:45","13:00","13:15","13:30","13:45",
             "14:00","14:15","14:30","14:45","15:00","15:15","15:30","15:45",
             "16:00","16:15","16:30","16:45","17:00","17:15","17:30","17:45",
             "18:00","18:15","18:30","18:45","19:00","19:15","19:30","19:45",
             "20:00","20:15","20:30","20:45","21:00","21:15","21:30","21:45",
             "22:00","22:15","22:30","22:45","23:00","23:15","23:30","23:45"])

bool   show_lunch = input.bool(false, "Lunch Hour",     group=GKL, inline="lunch")
color  lunch_col  = input.color(color.new(#B2B2B2, 95), "", group=GKL, inline="lunch")
string lunch_s_in = input.string("12:00", "",  group=GKL, inline="lunch",
    options=["00:00","00:15","00:30","00:45","01:00","01:15","01:30","01:45",
             "02:00","02:15","02:30","02:45","03:00","03:15","03:30","03:45",
             "04:00","04:15","04:30","04:45","05:00","05:15","05:30","05:45",
             "06:00","06:15","06:30","06:45","07:00","07:15","07:30","07:45",
             "08:00","08:15","08:30","08:45","09:00","09:15","09:30","09:45",
             "10:00","10:15","10:30","10:45","11:00","11:15","11:30","11:45",
             "12:00","12:15","12:30","12:45","13:00","13:15","13:30","13:45",
             "14:00","14:15","14:30","14:45","15:00","15:15","15:30","15:45",
             "16:00","16:15","16:30","16:45","17:00","17:15","17:30","17:45",
             "18:00","18:15","18:30","18:45","19:00","19:15","19:30","19:45",
             "20:00","20:15","20:30","20:45","21:00","21:15","21:30","21:45",
             "22:00","22:15","22:30","22:45","23:00","23:15","23:30","23:45"])
string lunch_e_in = input.string("13:00", "—", group=GKL, inline="lunch",
    options=["00:00","00:15","00:30","00:45","01:00","01:15","01:30","01:45",
             "02:00","02:15","02:30","02:45","03:00","03:15","03:30","03:45",
             "04:00","04:15","04:30","04:45","05:00","05:15","05:30","05:45",
             "06:00","06:15","06:30","06:45","07:00","07:15","07:30","07:45",
             "08:00","08:15","08:30","08:45","09:00","09:15","09:30","09:45",
             "10:00","10:15","10:30","10:45","11:00","11:15","11:30","11:45",
             "12:00","12:15","12:30","12:45","13:00","13:15","13:30","13:45",
             "14:00","14:15","14:30","14:45","15:00","15:15","15:30","15:45",
             "16:00","16:15","16:30","16:45","17:00","17:15","17:30","17:45",
             "18:00","18:15","18:30","18:45","19:00","19:15","19:30","19:45",
             "20:00","20:15","20:30","20:45","21:00","21:15","21:30","21:45",
             "22:00","22:15","22:30","22:45","23:00","23:15","23:30","23:45"])

bool   show_nypm  = input.bool(false, "NY PM Session",  group=GKL, inline="nypm")
color  nypm_col   = input.color(color.new(#9C27B0, 95), "", group=GKL, inline="nypm")
string nypm_s_in  = input.string("13:30", "",  group=GKL, inline="nypm",
    options=["00:00","00:15","00:30","00:45","01:00","01:15","01:30","01:45",
             "02:00","02:15","02:30","02:45","03:00","03:15","03:30","03:45",
             "04:00","04:15","04:30","04:45","05:00","05:15","05:30","05:45",
             "06:00","06:15","06:30","06:45","07:00","07:15","07:30","07:45",
             "08:00","08:15","08:30","08:45","09:00","09:15","09:30","09:45",
             "10:00","10:15","10:30","10:45","11:00","11:15","11:30","11:45",
             "12:00","12:15","12:30","12:45","13:00","13:15","13:30","13:45",
             "14:00","14:15","14:30","14:45","15:00","15:15","15:30","15:45",
             "16:00","16:15","16:30","16:45","17:00","17:15","17:30","17:45",
             "18:00","18:15","18:30","18:45","19:00","19:15","19:30","19:45",
             "20:00","20:15","20:30","20:45","21:00","21:15","21:30","21:45",
             "22:00","22:15","22:30","22:45","23:00","23:15","23:30","23:45"])
string nypm_e_in  = input.string("16:00", "—", group=GKL, inline="nypm",
    options=["00:00","00:15","00:30","00:45","01:00","01:15","01:30","01:45",
             "02:00","02:15","02:30","02:45","03:00","03:15","03:30","03:45",
             "04:00","04:15","04:30","04:45","05:00","05:15","05:30","05:45",
             "06:00","06:15","06:30","06:45","07:00","07:15","07:30","07:45",
             "08:00","08:15","08:30","08:45","09:00","09:15","09:30","09:45",
             "10:00","10:15","10:30","10:45","11:00","11:15","11:30","11:45",
             "12:00","12:15","12:30","12:45","13:00","13:15","13:30","13:45",
             "14:00","14:15","14:30","14:45","15:00","15:15","15:30","15:45",
             "16:00","16:15","16:30","16:45","17:00","17:15","17:30","17:45",
             "18:00","18:15","18:30","18:45","19:00","19:15","19:30","19:45",
             "20:00","20:15","20:30","20:45","21:00","21:15","21:30","21:45",
             "22:00","22:15","22:30","22:45","23:00","23:15","23:30","23:45"])

bool   show_box_lbl = input.bool(false,   "Box Labels",  group=GKL, inline="bl")
string box_lbl_pos  = input.string("Top Left", "",       group=GKL, inline="bl",
    options=["Top Left","Top Center","Top Right","Center","Bottom Left","Bottom Center","Bottom Right"])
color  box_lbl_col  = input.color(#616161, "",             group=GKL, inline="bl")
string box_lbl_size = input.string("small", "",           group=GKL, inline="bl",
    options=["tiny","small","normal","large"])

bool   show_mid_line = input.bool(false, "Session Midline (50%)", group=GKL, inline="mid",
     tooltip="Draws the 50% equilibrium line of each session range, spanning the session box. Color / style / width apply to all session midlines.")
color  mid_line_col  = input.color(color.new(#787b86, 0), "", group=GKL, inline="mid")
string mid_line_sty  = input.string("Dashed", "", options=["Solid","Dashed","Dotted"], group=GKL, inline="mid")
int    mid_line_w    = input.int(1, "", minval=1, maxval=4, group=GKL, inline="mid")

// ════════════════════════════════════════════════════════════════════════════
// INPUTS — KEY LIQUIDITY LINES
// ════════════════════════════════════════════════════════════════════════════
string GLL = "📐  Key Liquidity Lines"
bool   show_sl_lines = input.bool(true,  "Session Level Lines",         group=GLL)
bool   sl_show_asia  = input.bool(true,  "Asian",  group=GLL, inline="sl_sess")
bool   sl_show_lon   = input.bool(true,  "London", group=GLL, inline="sl_sess")
bool   sl_show_nyam  = input.bool(true,  "NY AM",  group=GLL, inline="sl_sess")
bool   sl_show_lunch = input.bool(false, "Lunch",  group=GLL, inline="sl_sess")
bool   sl_show_nypm  = input.bool(false, "NY PM",  group=GLL, inline="sl_sess")
int    sl_grace      = input.int(0,  "Extend after taken (Candles)",    group=GLL, minval=0, maxval=500)
bool   sl_show_price = input.bool(false, "Show Price in Label", group=GLL)
string sl_lbl_pos    = input.string("Center", "Label Position", options=["Left","Center","Right","Front"], group=GLL)
string sl_sty_in     = input.string("Solid",  "Line Style",  options=["Solid","Dashed","Dotted"], group=GLL)
int    sl_w          = input.int(1, "Thickness", minval=1, maxval=4, group=GLL)
string sl_lbl_sz     = input.string("small", "Label Size",   options=["tiny","small","normal","large"], group=GLL)

// ════════════════════════════════════════════════════════════════════════════
// INPUTS — EQUAL HIGHS & LOWS
// ════════════════════════════════════════════════════════════════════════════
string GEQ = "📏  Equal Highs & Lows"
bool   show_eqh    = input.bool(true,  "Equal Highs", group=GEQ, inline="eqh",
     tooltip="ⓘ Equal Highs/Lows are detected from the 5-minute timeframe at minimum. On a sub-5min chart (1m/2m/3m) you'll see the 5-minute swings drawn — not noisy 1-minute ones. At 5min and above, detection uses the chart's own timeframe.")
color  eqh_col     = input.color(color.new(#2196F3, 0), "", group=GEQ, inline="eqh")
string eqh_lbl     = input.string("EQH", "",            group=GEQ, inline="eqh")
bool   show_eql    = input.bool(true,  "Equal Lows",  group=GEQ, inline="eql")
color  eql_col     = input.color(color.new(#F44336, 0), "", group=GEQ, inline="eql")
string eql_lbl     = input.string("EQL", "",            group=GEQ, inline="eql")
int    eq_pivot    = input.int(2,   "Swing Length (bars)",   minval=1, maxval=50, group=GEQ,
     tooltip="Bars on each side of a pivot required to confirm a swing high/low. Larger = fewer, more significant swings.")
int    eq_depth    = input.int(10,  "Equal Search Depth (swings)", minval=1, maxval=50, group=GEQ,
     tooltip="How many prior swings back to compare a new swing against. Higher catches equal levels separated by other swings (more intervening candles); 1 = only the immediately previous swing.")
float  eq_tol      = input.float(10.0, "Equality Tolerance (%)", minval=0.0, maxval=10.0, step=0.5, group=GEQ,
     tooltip="Two swings are 'equal' if their price difference is within this % of the pullback (vertical move) between them. 0% = perfectly equal, 10% = loose.")
bool   eq_no_sweep = input.bool(true, "Second swing must not take the first", group=GEQ,
     tooltip="When on, the second swing high must stay at or below the first (and the second low at or above the first). Rejects pools where price already swept the prior swing.")
bool   eq_hide_inv = input.bool(true, "Hide invalidated (previous days)", group=GEQ,
     tooltip="Once price trades through an equal level, hide it — but only after its trading day has closed (6pm ET). Today's swept levels stay visible.")
string eq_sty_in   = input.string("Dotted", "Line", options=["Solid","Dashed","Dotted"], group=GEQ, inline="eqline")
int    eq_w        = input.int(1, "", minval=1, maxval=4, group=GEQ, inline="eqline")
bool   eq_show_lbl   = input.bool(true,  "Show Labels", group=GEQ, inline="eqlbl")
bool   eq_show_price = input.bool(false, "Show Price",  group=GEQ, inline="eqlbl")
string eq_lbl_pos  = input.string("Right", "Label Position", options=["Left","Center","Right","Front"], group=GEQ, inline="eqlbl2")
string eq_lbl_sz   = input.string("small", "", options=["tiny","small","normal","large"], group=GEQ, inline="eqlbl2")
int    eq_max      = input.int(5, "Max Untaken Shown (nearest)", minval=1, maxval=50, group=GEQ,
     tooltip="Only the N untaken equal levels closest to current price are drawn (highs + lows combined); farther untaken ones are hidden. Taken levels keep showing until they're invalidated on a later day.")
bool   eq_merge_sess = input.bool(true, "Merge into coinciding session level", group=GEQ,
     tooltip="When an EQH/EQL lands on a session High/Low (within Swing-TF Tags → Match Tolerance), don't draw a separate line — append \"/ EQH\" or \"/ EQL\" to that session label instead.")

// ════════════════════════════════════════════════════════════════════════════
// INPUTS — SWING-TF TAGS
// ════════════════════════════════════════════════════════════════════════════
string GTF = "🔭  Swing-TF Tags"
bool   tf_tag_on  = input.bool(true, "Show Level Timeframe", group=GTF,
     tooltip="Master toggle. Appends e.g. \" / 4H\" to a session High/Low, PDH/PDL, or EQH/EQL label — the highest of 5m·15m·1h·4h·1D on which that price is a 3-candle pivot (the bar is higher/lower than the one bar on each side). Only timeframes at or above the chart's are checked.")
int    tf_tag_tol = input.int(3, "Match Tolerance (ticks)", minval=0, maxval=50, group=GTF,
     tooltip="How close (in ticks) the level's price must be to the higher-timeframe pivot to count as the same swing.")

// ════════════════════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════════════════════
int bar_ms    = int(timeframe.in_seconds() * 1000)
int extend_ms = extend_bars * bar_ms
int cur_h     = hour(time,   tz)
int cur_m     = minute(time, tz)

ls(s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_solid

lbl_sz(s) =>
    switch s
        "tiny"   => size.tiny
        "large"  => size.large
        "normal" => size.normal
        =>          size.small

// x position along the extension line: Left=near session box, Center=midpoint, Right/Front=line tip
sl_lbl_x(pos, x1, x2) =>
    switch pos
        "Left"   => x1
        "Center" => int((x1 + x2) / 2)
        =>          x2   // "Right" and "Front" both anchor at the tip

sl_lbl_txt(nm, prc) =>
    sl_show_price ? nm + " (" + str.tostring(prc, format.mintick) + ")" : nm

dw_lbl_txt(nm, prc) =>
    dw_show_price ? nm + " (" + str.tostring(prc, format.mintick) + ")" : nm

eq_lbl_txt(nm, prc) =>
    eq_show_price ? nm + " (" + str.tostring(prc, format.mintick) + ")" : nm

// ── Equal-highs/lows shared state ────────────────────────────────────────────
var line[]  eq_lines  = array.new_line()
var label[] eq_labels = array.new_label()
var bool[]  eq_ishigh = array.new_bool()   // true = equal-high pool, false = equal-low
var float[] eq_lvl    = array.new_float()  // the level price
var int[]   eq_tkn    = array.new_int()    // freeze timestamp once taken (na = still live)
var int[]   eq_tknday = array.new_int()    // tday_num at the moment it was taken (na = not taken)
var int[]   eq_lvltime = array.new_int()   // bar time of the swing that defines the level

// ── Swing-TF tags: highest ladder TF on which a swing is a 3-candle pivot ─────
// Per TF we keep recent confirmed pivots as (value, pivot-candle start time). A
// level is "visible on TF X" when its bar falls inside one of those pivot candles
// AND its price matches the pivot extreme. A na swing time falls back to
// price-only matching (used by PDH/PDL, which are daily extremes by definition).
float tf_tol_px = tf_tag_tol * syminfo.mintick
int   chart_sec = timeframe.in_seconds()

// suffix for a session label when an active EQ of the same side sits on its price
eq_at(bool isHigh, float prc) =>
    string s = ""
    bool on = isHigh ? show_eqh : show_eql
    int n = array.size(eq_lvl)
    if eq_merge_sess and on and not na(prc) and n > 0
        for i = 0 to n - 1
            if array.get(eq_ishigh, i) == isHigh and na(array.get(eq_tkn, i)) and math.abs(array.get(eq_lvl, i) - prc) <= tf_tol_px
                s := " / " + (isHigh ? eqh_lbl : eql_lbl)
    s

f_buf_push(vb, tb, v, t) =>
    // request.security forward-fills the pivot across the whole HTF period,
    // so store each pivot once — when it first appears (changes from prior bar)
    if not na(v) and (na(v[1]) or v != v[1])
        array.push(vb, v)
        array.push(tb, t)
        if array.size(vb) > 40
            array.shift(vb)
            array.shift(tb)

f_tf_has(vb, tb, price, swingT, tfms) =>
    bool f = false
    int n = array.size(vb)
    if n > 0
        for i = 0 to n - 1
            bool pxok = math.abs(array.get(vb, i) - price) <= tf_tol_px
            bool tok  = na(swingT) or (swingT >= array.get(tb, i) and swingT < array.get(tb, i) + tfms)
            if pxok and tok
                f := true
    f

// confirmed 3-candle pivots (left=1, right=1) + pivot-candle start time, per TF
// Request each rung at max(rung, chart) so a rung below the chart collapses to a
// cheap same-resolution request instead of an expensive lower-timeframe fetch.
// Sub-chart rungs are gated out of htf_tag anyway, so behaviour is unchanged.
string tf5   = timeframe.from_seconds(math.max(300,   chart_sec))
string tf15  = timeframe.from_seconds(math.max(900,   chart_sec))
string tf60  = timeframe.from_seconds(math.max(3600,  chart_sec))
string tf240 = timeframe.from_seconds(math.max(14400, chart_sec))
[tfph5,   tfpl5,   tft5]   = request.security(syminfo.tickerid, tf5,   [ta.pivothigh(1, 1), ta.pivotlow(1, 1), time[1]], lookahead=barmerge.lookahead_off)
[tfph15,  tfpl15,  tft15]  = request.security(syminfo.tickerid, tf15,  [ta.pivothigh(1, 1), ta.pivotlow(1, 1), time[1]], lookahead=barmerge.lookahead_off)
[tfph60,  tfpl60,  tft60]  = request.security(syminfo.tickerid, tf60,  [ta.pivothigh(1, 1), ta.pivotlow(1, 1), time[1]], lookahead=barmerge.lookahead_off)
[tfph240, tfpl240, tft240] = request.security(syminfo.tickerid, tf240, [ta.pivothigh(1, 1), ta.pivotlow(1, 1), time[1]], lookahead=barmerge.lookahead_off)
// daily call also carries the ATR(14) for the detection-range filter (one request, not two)
[tfphD,   tfplD,   tftD,   daily_atr] = request.security(syminfo.tickerid, "D", [ta.pivothigh(1, 1), ta.pivotlow(1, 1), time[1], ta.atr(14)], lookahead=barmerge.lookahead_off)

// max detection range in price (na = unlimited)
float atr_range = atr_mult > 0 and not na(daily_atr) ? atr_mult * daily_atr : na

var float[] bph5   = array.new_float()
var int[]   bph5t  = array.new_int()
var float[] bpl5   = array.new_float()
var int[]   bpl5t  = array.new_int()
var float[] bph15  = array.new_float()
var int[]   bph15t = array.new_int()
var float[] bpl15  = array.new_float()
var int[]   bpl15t = array.new_int()
var float[] bph60  = array.new_float()
var int[]   bph60t = array.new_int()
var float[] bpl60  = array.new_float()
var int[]   bpl60t = array.new_int()
var float[] bph240 = array.new_float()
var int[]   bph240t = array.new_int()
var float[] bpl240 = array.new_float()
var int[]   bpl240t = array.new_int()
var float[] bphD   = array.new_float()
var int[]   bphDt  = array.new_int()
var float[] bplD   = array.new_float()
var int[]   bplDt  = array.new_int()

f_buf_push(bph5,   bph5t,   tfph5,   tft5)
f_buf_push(bpl5,   bpl5t,   tfpl5,   tft5)
f_buf_push(bph15,  bph15t,  tfph15,  tft15)
f_buf_push(bpl15,  bpl15t,  tfpl15,  tft15)
f_buf_push(bph60,  bph60t,  tfph60,  tft60)
f_buf_push(bpl60,  bpl60t,  tfpl60,  tft60)
f_buf_push(bph240, bph240t, tfph240, tft240)
f_buf_push(bpl240, bpl240t, tfpl240, tft240)
f_buf_push(bphD,   bphDt,   tfphD,   tftD)
f_buf_push(bplD,   bplDt,   tfplD,   tftD)

// highest ladder TF (>= chart TF) on which a swing at (price, swingT) is a pivot
htf_tag(float price, int swingT, bool isHigh) =>
    string t = ""
    if tf_tag_on and not na(price)
        if chart_sec <= 86400 and (isHigh ? f_tf_has(bphD, bphDt, price, swingT, 86400000) : f_tf_has(bplD, bplDt, price, swingT, 86400000))
            t := " / 1D"
        else if chart_sec <= 14400 and (isHigh ? f_tf_has(bph240, bph240t, price, swingT, 14400000) : f_tf_has(bpl240, bpl240t, price, swingT, 14400000))
            t := " / 4H"
        else if chart_sec <= 3600 and (isHigh ? f_tf_has(bph60, bph60t, price, swingT, 3600000) : f_tf_has(bpl60, bpl60t, price, swingT, 3600000))
            t := " / 1H"
        else if chart_sec <= 900 and (isHigh ? f_tf_has(bph15, bph15t, price, swingT, 900000) : f_tf_has(bpl15, bpl15t, price, swingT, 900000))
            t := " / 15m"
        else if chart_sec <= 300 and (isHigh ? f_tf_has(bph5, bph5t, price, swingT, 300000) : f_tf_has(bpl5, bpl5t, price, swingT, 300000))
            t := " / 5m"
    t

// Label style for HIGH lines. Left/Center/Right all anchor the text's RIGHT edge at
// their x (text extends LEFT), so it never spills past the tip into the candles when
// the line is short. Only "Front" places text after the line tip.
sl_lbl_sty_hi(pos) =>
    pos == "Front" ? label.style_label_left : label.style_label_lower_right

// Label style for LOW lines (same rule, text below the line).
sl_lbl_sty_lo(pos) =>
    pos == "Front" ? label.style_label_left : label.style_label_upper_right

bx_halign(pos) =>
    switch pos
        "Top Right"    => text.align_right
        "Top Center"   => text.align_center
        "Bottom Right" => text.align_right
        "Bottom Center"=> text.align_center
        "Center"       => text.align_center
        =>               text.align_left

bx_valign(pos) =>
    switch pos
        "Bottom Left"   => text.align_bottom
        "Bottom Center" => text.align_bottom
        "Bottom Right"  => text.align_bottom
        "Center"        => text.align_center
        =>                text.align_top

// Parse "HH:MM" string → [hours, minutes]
t_hm(s) =>
    p = str.split(s, ":")
    [int(str.tonumber(array.get(p, 0))), int(str.tonumber(array.get(p, 1)))]

[asia_sh,  asia_sm]  = t_hm(asia_s_in)
[asia_eh,  asia_em]  = t_hm(asia_e_in)
[lon_sh,   lon_sm]   = t_hm(lon_s_in)
[lon_eh,   lon_em]   = t_hm(lon_e_in)
[nyam_sh,  nyam_sm]  = t_hm(nyam_s_in)
[nyam_eh,  nyam_em]  = t_hm(nyam_e_in)
[lunch_sh, lunch_sm] = t_hm(lunch_s_in)
[lunch_eh, lunch_em] = t_hm(lunch_e_in)
[nypm_sh,  nypm_sm]  = t_hm(nypm_s_in)
[nypm_eh,  nypm_em]  = t_hm(nypm_e_in)

// Returns true if current bar's time (h:m in tz) is within session sh:sm – eh:em
// Handles cross-midnight sessions automatically (e.g. 18:00 – 03:00)
f_in_sess(sh, sm, eh, em) =>
    int ts = sh * 60 + sm
    int te = eh * 60 + em
    int tc = cur_h * 60 + cur_m
    te > ts ? (tc >= ts and tc < te) : (tc >= ts or tc < te)

// Trim a line array to max_n, deleting the oldest
f_trim_l(arr, max_n) =>
    while array.size(arr) > max_n
        line.delete(array.shift(arr))

// Trim a set of parallel session arrays (box + 5 data arrays) to max_n
f_trim_sess(bxs, his, los, lts, rts, dyn, mids, max_n) =>
    while array.size(bxs) > max_n
        box.delete(array.shift(bxs))
        array.shift(his)
        array.shift(los)
        array.shift(lts)
        array.shift(rts)
        array.shift(dyn)
        line.delete(array.shift(mids))

// Trim session H/L extension line + label arrays (parallel to session box arrays)
// htt/ltt = arrays storing the bar-time when session high/low was formed
f_trim_hl(hll, lll, hlt, llt, hla, lla, htt, ltt, max_n) =>
    while array.size(hll) > max_n
        line.delete(array.shift(hll))
        line.delete(array.shift(lll))
        array.shift(hlt)
        array.shift(llt)
        label.delete(array.shift(hla))
        label.delete(array.shift(lla))
        array.shift(htt)
        array.shift(ltt)

// Trim open-line arrays (vertical + h-line + label + day_n) together
f_trim_open(vls, hls, lbls, dns, max_n) =>
    while array.size(vls) > max_n
        line.delete(array.shift(vls))
        line.delete(array.shift(hls))
        label.delete(array.shift(lbls))
        array.shift(dns)


// ════════════════════════════════════════════════════════════════════════════
// OPEN LINE TRIGGERS
// ════════════════════════════════════════════════════════════════════════════
bool is_new_day = ta.change(dayofmonth(time, tz)) != 0
bool new_day_d  = ta.change(time("D")) != 0   // fires at 6pm ET when CME session rolls
bool new_week_w = ta.change(time("W")) != 0

// Trading-day counter — increments every time the daily session rolls at 6pm.
// Used to hide session boxes from previous days respecting the "Previous Sessions" input.
var int tday_num = 0
if new_day_d
    tday_num += 1

var bool mid_done  = false
var bool a830_done = false
var bool a930_done = false

if is_new_day
    mid_done  := false
    a830_done := false
    a930_done := false

bool trig_mid = cur_h == 0 and cur_m == 0 and not mid_done
bool trig_830 = cur_h == 8 and cur_m == 30 and not a830_done
bool trig_930 = cur_h == 9 and cur_m == 30 and not a930_done

if trig_mid
    mid_done  := true
if trig_830
    a830_done := true
if trig_930
    a930_done := true

int max_ol     = prev_days  + 1   // session boxes
int max_opens  = prev_opens + 1   // open lines
bool tf_ok     = timeframe.in_seconds() <= 3600  // hide session boxes above 1h

// ════════════════════════════════════════════════════════════════════════════
// OPEN LINES — ARRAYS
// ════════════════════════════════════════════════════════════════════════════
var line[]  mid_vl     = array.new_line()
var line[]  mid_hl     = array.new_line()
var label[] lbl_mid    = array.new_label()
var int[]   mid_day_n  = array.new_int()
var line[]  vl_830     = array.new_line()
var line[]  hl_830     = array.new_line()
var label[] lbl_830    = array.new_label()
var int[]   a830_day_n = array.new_int()
var line[]  vl_930     = array.new_line()
var line[]  hl_930     = array.new_line()
var label[] lbl_930    = array.new_label()
var int[]   a930_day_n = array.new_int()

// Draw on trigger — always create so toggling later reveals history
if trig_mid
    l = line.new(time, high, time, low, xloc=xloc.bar_time,
                 extend=extend.both, color=mid_col, style=ls(mid_sty_in), width=mid_w)
    array.push(mid_vl, l)
    hl = line.new(time, open, time + extend_ms, open, xloc=xloc.bar_time,
                  color=mid_col, style=ls(mid_sty_in), width=mid_w)
    array.push(mid_hl, hl)
    lb = label.new(time, open, "Midnight", xloc=xloc.bar_time,
                   color=na, textcolor=na, size=size.small)
    array.push(lbl_mid, lb)
    array.push(mid_day_n, tday_num)
    f_trim_open(mid_vl, mid_hl, lbl_mid, mid_day_n, max_opens)

if trig_830
    l = line.new(time, high, time, low, xloc=xloc.bar_time,
                 extend=extend.both, color=col_830, style=ls(sty_830_in), width=w_830)
    array.push(vl_830, l)
    hl = line.new(time, open, time + extend_ms, open, xloc=xloc.bar_time,
                  color=col_830, style=ls(sty_830_in), width=w_830)
    array.push(hl_830, hl)
    lb = label.new(time, open, "8:30am", xloc=xloc.bar_time,
                   color=na, textcolor=na, size=size.small)
    array.push(lbl_830, lb)
    array.push(a830_day_n, tday_num)
    f_trim_open(vl_830, hl_830, lbl_830, a830_day_n, max_opens)

if trig_930
    l = line.new(time, high, time, low, xloc=xloc.bar_time,
                 extend=extend.both, color=col_930, style=ls(sty_930_in), width=w_930)
    array.push(vl_930, l)
    hl = line.new(time, open, time + extend_ms, open, xloc=xloc.bar_time,
                  color=col_930, style=ls(sty_930_in), width=w_930)
    array.push(hl_930, hl)
    lb = label.new(time, open, "9:30am", xloc=xloc.bar_time,
                   color=na, textcolor=na, size=size.small)
    array.push(lbl_930, lb)
    array.push(a930_day_n, tday_num)
    f_trim_open(vl_930, hl_930, lbl_930, a930_day_n, max_opens)

// Update every bar — required for toggle/color/style/day-visibility changes to take effect
int n_mid = array.size(mid_vl)
if n_mid > 0 and barstate.islast
    for i = 0 to n_mid - 1
        bool day_ok_mid  = tday_num - array.get(mid_day_n, i) <= prev_opens
        bool latest_mid  = i == n_mid - 1   // only the most-recent open shows h-line
        line  lv_m  = array.get(mid_vl,  i)
        line  lh_m  = array.get(mid_hl,  i)
        label lb_m  = array.get(lbl_mid, i)
        int   op_x2 = time + extend_ms
        float op_prc = line.get_y1(lh_m)
        line.set_color(lv_m, show_mid and day_ok_mid ? mid_col : na)
        line.set_width(lv_m, show_mid and day_ok_mid ? mid_w : 0)
        line.set_style(lv_m, ls(mid_sty_in))
        line.set_x2(lh_m, op_x2)
        line.set_color(lh_m, show_mid and show_mid_h and day_ok_mid and latest_mid ? mid_col : na)
        line.set_width(lh_m, show_mid and show_mid_h and day_ok_mid and latest_mid ? mid_w : 0)
        line.set_style(lh_m, ls(mid_sty_in))
        label.set_x(lb_m, op_x2)
        label.set_y(lb_m, op_prc)
        label.set_style(lb_m, label.style_label_left)
        label.set_text(lb_m, open_lbl_price ? "Midnight (" + str.tostring(op_prc, format.mintick) + ")" : "Midnight")
        label.set_size(lb_m, lbl_sz(open_lbl_sz))
        label.set_textcolor(lb_m, show_mid and show_mid_h and show_open_lbl and day_ok_mid and latest_mid ? mid_col : na)

int n_830 = array.size(vl_830)
if n_830 > 0 and barstate.islast
    for i = 0 to n_830 - 1
        bool day_ok_830  = tday_num - array.get(a830_day_n, i) <= prev_opens
        bool latest_830  = i == n_830 - 1
        line  lv_8  = array.get(vl_830,  i)
        line  lh_8  = array.get(hl_830,  i)
        label lb_8  = array.get(lbl_830, i)
        int   op_x2 = time + extend_ms
        float op_prc = line.get_y1(lh_8)
        line.set_color(lv_8, show_830 and day_ok_830 ? col_830 : na)
        line.set_width(lv_8, show_830 and day_ok_830 ? w_830 : 0)
        line.set_style(lv_8, ls(sty_830_in))
        line.set_x2(lh_8, op_x2)
        line.set_color(lh_8, show_830 and show_830_h and day_ok_830 and latest_830 ? col_830 : na)
        line.set_width(lh_8, show_830 and show_830_h and day_ok_830 and latest_830 ? w_830 : 0)
        line.set_style(lh_8, ls(sty_830_in))
        label.set_x(lb_8, op_x2)
        label.set_y(lb_8, op_prc)
        label.set_style(lb_8, label.style_label_left)
        label.set_text(lb_8, open_lbl_price ? "8:30am (" + str.tostring(op_prc, format.mintick) + ")" : "8:30am")
        label.set_size(lb_8, lbl_sz(open_lbl_sz))
        label.set_textcolor(lb_8, show_830 and show_830_h and show_open_lbl and day_ok_830 and latest_830 ? col_830 : na)

int n_930 = array.size(vl_930)
if n_930 > 0 and barstate.islast
    for i = 0 to n_930 - 1
        bool day_ok_930  = tday_num - array.get(a930_day_n, i) <= prev_opens
        bool latest_930  = i == n_930 - 1
        line  lv_9  = array.get(vl_930,  i)
        line  lh_9  = array.get(hl_930,  i)
        label lb_9  = array.get(lbl_930, i)
        int   op_x2 = time + extend_ms
        float op_prc = line.get_y1(lh_9)
        line.set_color(lv_9, show_930 and day_ok_930 ? col_930 : na)
        line.set_width(lv_9, show_930 and day_ok_930 ? w_930 : 0)
        line.set_style(lv_9, ls(sty_930_in))
        line.set_x2(lh_9, op_x2)
        line.set_color(lh_9, show_930 and show_930_h and day_ok_930 and latest_930 ? col_930 : na)
        line.set_width(lh_9, show_930 and show_930_h and day_ok_930 and latest_930 ? w_930 : 0)
        line.set_style(lh_9, ls(sty_930_in))
        label.set_x(lb_9, op_x2)
        label.set_y(lb_9, op_prc)
        label.set_style(lb_9, label.style_label_left)
        label.set_text(lb_9, open_lbl_price ? "9:30am (" + str.tostring(op_prc, format.mintick) + ")" : "9:30am")
        label.set_size(lb_9, lbl_sz(open_lbl_sz))
        label.set_textcolor(lb_9, show_930 and show_930_h and show_open_lbl and day_ok_930 and latest_930 ? col_930 : na)

// ════════════════════════════════════════════════════════════════════════════
// SESSION BOX MACRO (comment-based — repeated per session below)
// Pattern:
//   1. Detect session start → push new box + parallel data arrays
//   2. While in session → track running high/low
//   3. Detect session end → mark as closed (no more right-edge extension)
//   4. Every bar → re-apply all properties for toggle responsiveness
// ════════════════════════════════════════════════════════════════════════════

// ── ASIAN RANGE ──────────────────────────────────────────────────────────────
var bool    asia_in   = false
var float   asia_hi   = na
var float   asia_lo   = na
var int     asia_hi_t = na   // time of bar where session high was formed
var int     asia_lo_t = na   // time of bar where session low was formed
var box[]   asia_bxs  = array.new_box()
var float[] asia_his  = array.new_float()
var float[] asia_los  = array.new_float()
var int[]   asia_lt   = array.new_int()
var int[]   asia_rt   = array.new_int()
var line[]  asia_mid_lns = array.new_line()   // 50% session equilibrium line per box
var line[]  asia_hl_lns  = array.new_line()
var line[]  asia_ll_lns  = array.new_line()
var int[]   asia_hl_tkn  = array.new_int()
var int[]   asia_ll_tkn  = array.new_int()
var label[] asia_hl_lbls = array.new_label()
var label[] asia_ll_lbls = array.new_label()
var int[]   asia_hl_t    = array.new_int()   // stored high-bar times per session
var int[]   asia_ll_t    = array.new_int()   // stored low-bar times per session
var int[]   asia_day_n   = array.new_int()   // trading-day number when box was created

bool asia_now   = f_in_sess(asia_sh, asia_sm, asia_eh, asia_em)
bool asia_start = asia_now  and not asia_in
bool asia_end   = not asia_now and asia_in

if asia_start and tf_ok
    asia_in   := true
    asia_hi   := high
    asia_lo   := low
    asia_hi_t := time
    asia_lo_t := time
    b = box.new(time, high, time + bar_ms, low, xloc=xloc.bar_time,
                bgcolor=na, border_color=na, border_width=0)
    array.push(asia_bxs, b)
    array.push(asia_his, high)
    array.push(asia_los, low)
    array.push(asia_lt,  time)
    array.push(asia_rt,  time + bar_ms)
    ml = line.new(time, (high + low) / 2, time + bar_ms, (high + low) / 2, xloc=xloc.bar_time, color=na, width=0)
    array.push(asia_mid_lns, ml)
    hl = line.new(time, high, time + bar_ms, high, xloc=xloc.bar_time, color=na, width=0)
    ll = line.new(time, low,  time + bar_ms, low,  xloc=xloc.bar_time, color=na, width=0)
    hl_lbl = label.new(time + bar_ms, high, "AS High", xloc=xloc.bar_time,
                       color=na, textcolor=na, size=size.small)
    ll_lbl = label.new(time + bar_ms, low,  "AS Low",  xloc=xloc.bar_time,
                       color=na, textcolor=na, size=size.small)
    array.push(asia_hl_lns, hl)
    array.push(asia_ll_lns, ll)
    array.push(asia_hl_tkn, na)
    array.push(asia_ll_tkn, na)
    array.push(asia_hl_lbls, hl_lbl)
    array.push(asia_ll_lbls, ll_lbl)
    array.push(asia_hl_t, time)
    array.push(asia_ll_t, time)
    array.push(asia_day_n, tday_num)
    f_trim_sess(asia_bxs, asia_his, asia_los, asia_lt, asia_rt, asia_day_n, asia_mid_lns, max_ol)
    f_trim_hl(asia_hl_lns, asia_ll_lns, asia_hl_tkn, asia_ll_tkn, asia_hl_lbls, asia_ll_lbls, asia_hl_t, asia_ll_t, max_ol)

if asia_in and not asia_start
    if high >= asia_hi
        asia_hi   := high
        asia_hi_t := time
    if low <= asia_lo
        asia_lo   := low
        asia_lo_t := time

if asia_end
    asia_in := false

int n_asia = array.size(asia_bxs)
if n_asia > 0
    for i = 0 to n_asia - 1
        bool live = i == n_asia - 1 and asia_in
        if live
            array.set(asia_his,  i, asia_hi)
            array.set(asia_los,  i, asia_lo)
            array.set(asia_rt,   i, time + bar_ms)
            array.set(asia_hl_t, i, asia_hi_t)
            array.set(asia_ll_t, i, asia_lo_t)
        float h_prc_a = array.get(asia_his,  i)
        float l_prc_a = array.get(asia_los,  i)
        // take-detection must run every bar (path-dependent)
        if not live
            if na(array.get(asia_hl_tkn, i)) and high >= h_prc_a
                array.set(asia_hl_tkn, i, time + sl_grace * bar_ms)
            if na(array.get(asia_ll_tkn, i)) and low <= l_prc_a
                array.set(asia_ll_tkn, i, time + sl_grace * bar_ms)
        // historical objects: paint final state once on the last bar.
        // live in-progress box: paint every bar so it tracks new highs/lows in realtime.
        if barstate.islast or live
            b = array.get(asia_bxs, i)
            box.set_top(b,           h_prc_a)
            box.set_bottom(b,        l_prc_a)
            box.set_left(b,          array.get(asia_lt,  i))
            box.set_right(b,         array.get(asia_rt,  i))
            bool day_ok_a = tday_num - array.get(asia_day_n, i) <= prev_days
            box.set_bgcolor(b,       show_asia and tf_ok and day_ok_a ? asia_col : na)
            box.set_border_color(b,  show_asia and tf_ok and day_ok_a ? color.new(asia_col, 0) : na)
            box.set_border_width(b,  show_asia and tf_ok and day_ok_a ? bw_in : 0)
            box.set_border_style(b,  ls(bsty_in))
            box.set_text(b,          show_asia and show_box_lbl and day_ok_a ? "Asia" : "")
            box.set_text_color(b,    box_lbl_col)
            box.set_text_size(b,     lbl_sz(box_lbl_size))
            box.set_text_halign(b,   bx_halign(box_lbl_pos))
            box.set_text_valign(b,   bx_valign(box_lbl_pos))
            line  mid_a   = array.get(asia_mid_lns, i)
            bool  midvis_a = show_mid_line and show_asia and tf_ok and day_ok_a
            float mid_p_a = (h_prc_a + l_prc_a) / 2
            line.set_x1(mid_a, array.get(asia_lt, i))
            line.set_x2(mid_a, array.get(asia_rt, i))
            line.set_y1(mid_a, mid_p_a)
            line.set_y2(mid_a, mid_p_a)
            line.set_color(mid_a, midvis_a ? mid_line_col : na)
            line.set_width(mid_a, midvis_a ? mid_line_w : 0)
            line.set_style(mid_a, ls(mid_line_sty))
            int   h_t1_a  = array.get(asia_hl_t, i)
            int   l_t1_a  = array.get(asia_ll_t, i)
            line  h_ln_a  = array.get(asia_hl_lns, i)
            line  l_ln_a  = array.get(asia_ll_lns, i)
            int   h_tkn_a = array.get(asia_hl_tkn, i)
            int   l_tkn_a = array.get(asia_ll_tkn, i)
            int  h_x2_a = not na(h_tkn_a) ? h_tkn_a : time + extend_ms
            int  l_x2_a = not na(l_tkn_a) ? l_tkn_a : time + extend_ms
            bool vis_a   = show_sl_lines and sl_show_asia and tf_ok and not live and day_ok_a
            line.set_x1(h_ln_a, h_t1_a)
            line.set_x2(h_ln_a, h_x2_a)
            line.set_y1(h_ln_a, h_prc_a)
            line.set_y2(h_ln_a, h_prc_a)
            line.set_color(h_ln_a, vis_a ? color.new(asia_col, 0) : na)
            line.set_width(h_ln_a, vis_a ? sl_w : 0)
            line.set_style(h_ln_a, ls(sl_sty_in))
            line.set_x1(l_ln_a, l_t1_a)
            line.set_x2(l_ln_a, l_x2_a)
            line.set_y1(l_ln_a, l_prc_a)
            line.set_y2(l_ln_a, l_prc_a)
            line.set_color(l_ln_a, vis_a ? color.new(asia_col, 0) : na)
            line.set_width(l_ln_a, vis_a ? sl_w : 0)
            line.set_style(l_ln_a, ls(sl_sty_in))
            label hl_lbl_a = array.get(asia_hl_lbls, i)
            label ll_lbl_a = array.get(asia_ll_lbls, i)
            label.set_x(hl_lbl_a, sl_lbl_x(sl_lbl_pos, h_t1_a, h_x2_a))
            label.set_y(hl_lbl_a, h_prc_a)
            label.set_style(hl_lbl_a, sl_lbl_sty_hi(sl_lbl_pos))
            label.set_text(hl_lbl_a, sl_lbl_txt("AS High", h_prc_a) + htf_tag(h_prc_a, array.get(asia_hl_t, i), true) + eq_at(true, h_prc_a))
            label.set_size(hl_lbl_a, lbl_sz(sl_lbl_sz))
            label.set_textcolor(hl_lbl_a, vis_a ? color.new(asia_col, 0) : na)
            label.set_x(ll_lbl_a, sl_lbl_x(sl_lbl_pos, l_t1_a, l_x2_a))
            label.set_y(ll_lbl_a, l_prc_a)
            label.set_style(ll_lbl_a, sl_lbl_sty_lo(sl_lbl_pos))
            label.set_text(ll_lbl_a, sl_lbl_txt("AS Low", l_prc_a) + htf_tag(l_prc_a, array.get(asia_ll_t, i), false) + eq_at(false, l_prc_a))
            label.set_size(ll_lbl_a, lbl_sz(sl_lbl_sz))
            label.set_textcolor(ll_lbl_a, vis_a ? color.new(asia_col, 0) : na)

// ── LONDON SESSION ────────────────────────────────────────────────────────────
var bool    lon_in  = false
var float   lon_hi  = na
var float   lon_lo  = na
var box[]   lon_bxs = array.new_box()
var float[] lon_his = array.new_float()
var float[] lon_los = array.new_float()
var int[]   lon_lt  = array.new_int()
var int[]   lon_rt  = array.new_int()
var line[]  lon_mid_lns = array.new_line()
var line[]  lon_hl_lns  = array.new_line()
var line[]  lon_ll_lns  = array.new_line()
var int[]   lon_hl_tkn  = array.new_int()
var int[]   lon_ll_tkn  = array.new_int()
var label[] lon_hl_lbls = array.new_label()
var label[] lon_ll_lbls = array.new_label()
var int     lon_hi_t    = na
var int     lon_lo_t    = na
var int[]   lon_hl_t    = array.new_int()
var int[]   lon_ll_t    = array.new_int()
var int[]   lon_day_n   = array.new_int()

bool lon_now   = f_in_sess(lon_sh, lon_sm, lon_eh, lon_em)
bool lon_start = lon_now  and not lon_in
bool lon_end   = not lon_now and lon_in

if lon_start and tf_ok
    lon_in   := true
    lon_hi   := high
    lon_lo   := low
    lon_hi_t := time
    lon_lo_t := time
    b = box.new(time, high, time + bar_ms, low, xloc=xloc.bar_time,
                bgcolor=na, border_color=na, border_width=0)
    array.push(lon_bxs, b)
    array.push(lon_his, high)
    array.push(lon_los, low)
    array.push(lon_lt,  time)
    array.push(lon_rt,  time + bar_ms)
    ml = line.new(time, (high + low) / 2, time + bar_ms, (high + low) / 2, xloc=xloc.bar_time, color=na, width=0)
    array.push(lon_mid_lns, ml)
    hl = line.new(time, high, time + bar_ms, high, xloc=xloc.bar_time, color=na, width=0)
    ll = line.new(time, low,  time + bar_ms, low,  xloc=xloc.bar_time, color=na, width=0)
    hl_lbl = label.new(time + bar_ms, high, "LO High", xloc=xloc.bar_time,
                       color=na, textcolor=na, size=size.small)
    ll_lbl = label.new(time + bar_ms, low,  "LO Low",  xloc=xloc.bar_time,
                       color=na, textcolor=na, size=size.small)
    array.push(lon_hl_lns, hl)
    array.push(lon_ll_lns, ll)
    array.push(lon_hl_tkn, na)
    array.push(lon_ll_tkn, na)
    array.push(lon_hl_lbls, hl_lbl)
    array.push(lon_ll_lbls, ll_lbl)
    array.push(lon_hl_t, time)
    array.push(lon_ll_t, time)
    array.push(lon_day_n, tday_num)
    f_trim_sess(lon_bxs, lon_his, lon_los, lon_lt, lon_rt, lon_day_n, lon_mid_lns, max_ol)
    f_trim_hl(lon_hl_lns, lon_ll_lns, lon_hl_tkn, lon_ll_tkn, lon_hl_lbls, lon_ll_lbls, lon_hl_t, lon_ll_t, max_ol)

if lon_in and not lon_start
    if high >= lon_hi
        lon_hi   := high
        lon_hi_t := time
    if low <= lon_lo
        lon_lo   := low
        lon_lo_t := time

if lon_end
    lon_in := false

int n_lon = array.size(lon_bxs)
if n_lon > 0
    for i = 0 to n_lon - 1
        bool live = i == n_lon - 1 and lon_in
        if live
            array.set(lon_his,  i, lon_hi)
            array.set(lon_los,  i, lon_lo)
            array.set(lon_rt,   i, time + bar_ms)
            array.set(lon_hl_t, i, lon_hi_t)
            array.set(lon_ll_t, i, lon_lo_t)
        float h_prc_l = array.get(lon_his,  i)
        float l_prc_l = array.get(lon_los,  i)
        if not live
            if na(array.get(lon_hl_tkn, i)) and high >= h_prc_l
                array.set(lon_hl_tkn, i, time + sl_grace * bar_ms)
            if na(array.get(lon_ll_tkn, i)) and low <= l_prc_l
                array.set(lon_ll_tkn, i, time + sl_grace * bar_ms)
        if barstate.islast or live
            b = array.get(lon_bxs, i)
            box.set_top(b,           h_prc_l)
            box.set_bottom(b,        l_prc_l)
            box.set_left(b,          array.get(lon_lt,  i))
            box.set_right(b,         array.get(lon_rt,  i))
            bool day_ok_l = tday_num - array.get(lon_day_n, i) <= prev_days
            box.set_bgcolor(b,       show_lon and tf_ok and day_ok_l ? lon_col : na)
            box.set_border_color(b,  show_lon and tf_ok and day_ok_l ? color.new(lon_col, 0) : na)
            box.set_border_width(b,  show_lon and tf_ok and day_ok_l ? bw_in : 0)
            box.set_border_style(b,  ls(bsty_in))
            box.set_text(b,          show_lon and show_box_lbl and day_ok_l ? "London" : "")
            box.set_text_color(b,    box_lbl_col)
            box.set_text_size(b,     lbl_sz(box_lbl_size))
            box.set_text_halign(b,   bx_halign(box_lbl_pos))
            box.set_text_valign(b,   bx_valign(box_lbl_pos))
            line  mid_l   = array.get(lon_mid_lns, i)
            bool  midvis_l = show_mid_line and show_lon and tf_ok and day_ok_l
            float mid_p_l = (h_prc_l + l_prc_l) / 2
            line.set_x1(mid_l, array.get(lon_lt, i))
            line.set_x2(mid_l, array.get(lon_rt, i))
            line.set_y1(mid_l, mid_p_l)
            line.set_y2(mid_l, mid_p_l)
            line.set_color(mid_l, midvis_l ? mid_line_col : na)
            line.set_width(mid_l, midvis_l ? mid_line_w : 0)
            line.set_style(mid_l, ls(mid_line_sty))
            int   h_t1_l  = array.get(lon_hl_t, i)
            int   l_t1_l  = array.get(lon_ll_t, i)
            line  h_ln_l  = array.get(lon_hl_lns, i)
            line  l_ln_l  = array.get(lon_ll_lns, i)
            int   h_tkn_l = array.get(lon_hl_tkn, i)
            int   l_tkn_l = array.get(lon_ll_tkn, i)
            int  h_x2_l = not na(h_tkn_l) ? h_tkn_l : time + extend_ms
            int  l_x2_l = not na(l_tkn_l) ? l_tkn_l : time + extend_ms
            bool vis_l   = show_sl_lines and sl_show_lon and tf_ok and not live and day_ok_l
            line.set_x1(h_ln_l, h_t1_l)
            line.set_x2(h_ln_l, h_x2_l)
            line.set_y1(h_ln_l, h_prc_l)
            line.set_y2(h_ln_l, h_prc_l)
            line.set_color(h_ln_l, vis_l ? color.new(lon_col, 0) : na)
            line.set_width(h_ln_l, vis_l ? sl_w : 0)
            line.set_style(h_ln_l, ls(sl_sty_in))
            line.set_x1(l_ln_l, l_t1_l)
            line.set_x2(l_ln_l, l_x2_l)
            line.set_y1(l_ln_l, l_prc_l)
            line.set_y2(l_ln_l, l_prc_l)
            line.set_color(l_ln_l, vis_l ? color.new(lon_col, 0) : na)
            line.set_width(l_ln_l, vis_l ? sl_w : 0)
            line.set_style(l_ln_l, ls(sl_sty_in))
            label hl_lbl_l = array.get(lon_hl_lbls, i)
            label ll_lbl_l = array.get(lon_ll_lbls, i)
            label.set_x(hl_lbl_l, sl_lbl_x(sl_lbl_pos, h_t1_l, h_x2_l))
            label.set_y(hl_lbl_l, h_prc_l)
            label.set_style(hl_lbl_l, sl_lbl_sty_hi(sl_lbl_pos))
            label.set_text(hl_lbl_l, sl_lbl_txt("LO High", h_prc_l) + htf_tag(h_prc_l, array.get(lon_hl_t, i), true) + eq_at(true, h_prc_l))
            label.set_size(hl_lbl_l, lbl_sz(sl_lbl_sz))
            label.set_textcolor(hl_lbl_l, vis_l ? color.new(lon_col, 0) : na)
            label.set_x(ll_lbl_l, sl_lbl_x(sl_lbl_pos, l_t1_l, l_x2_l))
            label.set_y(ll_lbl_l, l_prc_l)
            label.set_style(ll_lbl_l, sl_lbl_sty_lo(sl_lbl_pos))
            label.set_text(ll_lbl_l, sl_lbl_txt("LO Low", l_prc_l) + htf_tag(l_prc_l, array.get(lon_ll_t, i), false) + eq_at(false, l_prc_l))
            label.set_size(ll_lbl_l, lbl_sz(sl_lbl_sz))
            label.set_textcolor(ll_lbl_l, vis_l ? color.new(lon_col, 0) : na)

// ── NY AM SESSION ─────────────────────────────────────────────────────────────
var bool    nyam_in  = false
var float   nyam_hi  = na
var float   nyam_lo  = na
var box[]   nyam_bxs = array.new_box()
var float[] nyam_his = array.new_float()
var float[] nyam_los = array.new_float()
var int[]   nyam_lt  = array.new_int()
var int[]   nyam_rt  = array.new_int()
var line[]  nyam_mid_lns = array.new_line()
var line[]  nyam_hl_lns  = array.new_line()
var line[]  nyam_ll_lns  = array.new_line()
var int[]   nyam_hl_tkn  = array.new_int()
var int[]   nyam_ll_tkn  = array.new_int()
var label[] nyam_hl_lbls = array.new_label()
var label[] nyam_ll_lbls = array.new_label()
var int     nyam_hi_t    = na
var int     nyam_lo_t    = na
var int[]   nyam_hl_t    = array.new_int()
var int[]   nyam_ll_t    = array.new_int()
var int[]   nyam_day_n   = array.new_int()

bool nyam_now   = f_in_sess(nyam_sh, nyam_sm, nyam_eh, nyam_em)
bool nyam_start = nyam_now  and not nyam_in
bool nyam_end   = not nyam_now and nyam_in

if nyam_start and tf_ok
    nyam_in   := true
    nyam_hi   := high
    nyam_lo   := low
    nyam_hi_t := time
    nyam_lo_t := time
    b = box.new(time, high, time + bar_ms, low, xloc=xloc.bar_time,
                bgcolor=na, border_color=na, border_width=0)
    array.push(nyam_bxs, b)
    array.push(nyam_his, high)
    array.push(nyam_los, low)
    array.push(nyam_lt,  time)
    array.push(nyam_rt,  time + bar_ms)
    ml = line.new(time, (high + low) / 2, time + bar_ms, (high + low) / 2, xloc=xloc.bar_time, color=na, width=0)
    array.push(nyam_mid_lns, ml)
    hl = line.new(time, high, time + bar_ms, high, xloc=xloc.bar_time, color=na, width=0)
    ll = line.new(time, low,  time + bar_ms, low,  xloc=xloc.bar_time, color=na, width=0)
    hl_lbl = label.new(time + bar_ms, high, "AM High", xloc=xloc.bar_time,
                       color=na, textcolor=na, size=size.small)
    ll_lbl = label.new(time + bar_ms, low,  "AM Low",  xloc=xloc.bar_time,
                       color=na, textcolor=na, size=size.small)
    array.push(nyam_hl_lns, hl)
    array.push(nyam_ll_lns, ll)
    array.push(nyam_hl_tkn, na)
    array.push(nyam_ll_tkn, na)
    array.push(nyam_hl_lbls, hl_lbl)
    array.push(nyam_ll_lbls, ll_lbl)
    array.push(nyam_hl_t, time)
    array.push(nyam_ll_t, time)
    array.push(nyam_day_n, tday_num)
    f_trim_sess(nyam_bxs, nyam_his, nyam_los, nyam_lt, nyam_rt, nyam_day_n, nyam_mid_lns, max_ol)
    f_trim_hl(nyam_hl_lns, nyam_ll_lns, nyam_hl_tkn, nyam_ll_tkn, nyam_hl_lbls, nyam_ll_lbls, nyam_hl_t, nyam_ll_t, max_ol)

if nyam_in and not nyam_start
    if high >= nyam_hi
        nyam_hi   := high
        nyam_hi_t := time
    if low <= nyam_lo
        nyam_lo   := low
        nyam_lo_t := time

if nyam_end
    nyam_in := false

int n_nyam = array.size(nyam_bxs)
if n_nyam > 0
    for i = 0 to n_nyam - 1
        bool live = i == n_nyam - 1 and nyam_in
        if live
            array.set(nyam_his,  i, nyam_hi)
            array.set(nyam_los,  i, nyam_lo)
            array.set(nyam_rt,   i, time + bar_ms)
            array.set(nyam_hl_t, i, nyam_hi_t)
            array.set(nyam_ll_t, i, nyam_lo_t)
        float h_prc_n = array.get(nyam_his,  i)
        float l_prc_n = array.get(nyam_los,  i)
        if not live
            if na(array.get(nyam_hl_tkn, i)) and high >= h_prc_n
                array.set(nyam_hl_tkn, i, time + sl_grace * bar_ms)
            if na(array.get(nyam_ll_tkn, i)) and low <= l_prc_n
                array.set(nyam_ll_tkn, i, time + sl_grace * bar_ms)
        if barstate.islast or live
            b = array.get(nyam_bxs, i)
            box.set_top(b,           h_prc_n)
            box.set_bottom(b,        l_prc_n)
            box.set_left(b,          array.get(nyam_lt,  i))
            box.set_right(b,         array.get(nyam_rt,  i))
            bool day_ok_n = tday_num - array.get(nyam_day_n, i) <= prev_days
            box.set_bgcolor(b,       show_nyam and tf_ok and day_ok_n ? nyam_col : na)
            box.set_border_color(b,  show_nyam and tf_ok and day_ok_n ? color.new(nyam_col, 0) : na)
            box.set_border_width(b,  show_nyam and tf_ok and day_ok_n ? bw_in : 0)
            box.set_border_style(b,  ls(bsty_in))
            box.set_text(b,          show_nyam and show_box_lbl and day_ok_n ? "NY AM" : "")
            box.set_text_color(b,    box_lbl_col)
            box.set_text_size(b,     lbl_sz(box_lbl_size))
            box.set_text_halign(b,   bx_halign(box_lbl_pos))
            box.set_text_valign(b,   bx_valign(box_lbl_pos))
            line  mid_n   = array.get(nyam_mid_lns, i)
            bool  midvis_n = show_mid_line and show_nyam and tf_ok and day_ok_n
            float mid_p_n = (h_prc_n + l_prc_n) / 2
            line.set_x1(mid_n, array.get(nyam_lt, i))
            line.set_x2(mid_n, array.get(nyam_rt, i))
            line.set_y1(mid_n, mid_p_n)
            line.set_y2(mid_n, mid_p_n)
            line.set_color(mid_n, midvis_n ? mid_line_col : na)
            line.set_width(mid_n, midvis_n ? mid_line_w : 0)
            line.set_style(mid_n, ls(mid_line_sty))
            int   h_t1_n  = array.get(nyam_hl_t, i)
            int   l_t1_n  = array.get(nyam_ll_t, i)
            line  h_ln_n  = array.get(nyam_hl_lns, i)
            line  l_ln_n  = array.get(nyam_ll_lns, i)
            int   h_tkn_n = array.get(nyam_hl_tkn, i)
            int   l_tkn_n = array.get(nyam_ll_tkn, i)
            int  h_x2_n = not na(h_tkn_n) ? h_tkn_n : time + extend_ms
            int  l_x2_n = not na(l_tkn_n) ? l_tkn_n : time + extend_ms
            bool vis_n   = show_sl_lines and sl_show_nyam and tf_ok and not live and day_ok_n
            line.set_x1(h_ln_n, h_t1_n)
            line.set_x2(h_ln_n, h_x2_n)
            line.set_y1(h_ln_n, h_prc_n)
            line.set_y2(h_ln_n, h_prc_n)
            line.set_color(h_ln_n, vis_n ? color.new(nyam_col, 0) : na)
            line.set_width(h_ln_n, vis_n ? sl_w : 0)
            line.set_style(h_ln_n, ls(sl_sty_in))
            line.set_x1(l_ln_n, l_t1_n)
            line.set_x2(l_ln_n, l_x2_n)
            line.set_y1(l_ln_n, l_prc_n)
            line.set_y2(l_ln_n, l_prc_n)
            line.set_color(l_ln_n, vis_n ? color.new(nyam_col, 0) : na)
            line.set_width(l_ln_n, vis_n ? sl_w : 0)
            line.set_style(l_ln_n, ls(sl_sty_in))
            label hl_lbl_n = array.get(nyam_hl_lbls, i)
            label ll_lbl_n = array.get(nyam_ll_lbls, i)
            label.set_x(hl_lbl_n, sl_lbl_x(sl_lbl_pos, h_t1_n, h_x2_n))
            label.set_y(hl_lbl_n, h_prc_n)
            label.set_style(hl_lbl_n, sl_lbl_sty_hi(sl_lbl_pos))
            label.set_text(hl_lbl_n, sl_lbl_txt("AM High", h_prc_n) + htf_tag(h_prc_n, array.get(nyam_hl_t, i), true) + eq_at(true, h_prc_n))
            label.set_size(hl_lbl_n, lbl_sz(sl_lbl_sz))
            label.set_textcolor(hl_lbl_n, vis_n ? color.new(nyam_col, 0) : na)
            label.set_x(ll_lbl_n, sl_lbl_x(sl_lbl_pos, l_t1_n, l_x2_n))
            label.set_y(ll_lbl_n, l_prc_n)
            label.set_style(ll_lbl_n, sl_lbl_sty_lo(sl_lbl_pos))
            label.set_text(ll_lbl_n, sl_lbl_txt("AM Low", l_prc_n) + htf_tag(l_prc_n, array.get(nyam_ll_t, i), false) + eq_at(false, l_prc_n))
            label.set_size(ll_lbl_n, lbl_sz(sl_lbl_sz))
            label.set_textcolor(ll_lbl_n, vis_n ? color.new(nyam_col, 0) : na)

// ── LUNCH HOUR ────────────────────────────────────────────────────────────────
var bool    lunch_in  = false
var float   lunch_hi  = na
var float   lunch_lo  = na
var box[]   lunch_bxs = array.new_box()
var float[] lunch_his = array.new_float()
var float[] lunch_los = array.new_float()
var int[]   lunch_lt  = array.new_int()
var int[]   lunch_rt  = array.new_int()
var line[]  lunch_mid_lns = array.new_line()
var line[]  lunch_hl_lns  = array.new_line()
var line[]  lunch_ll_lns  = array.new_line()
var int[]   lunch_hl_tkn  = array.new_int()
var int[]   lunch_ll_tkn  = array.new_int()
var label[] lunch_hl_lbls = array.new_label()
var label[] lunch_ll_lbls = array.new_label()
var int     lunch_hi_t    = na
var int     lunch_lo_t    = na
var int[]   lunch_hl_t    = array.new_int()
var int[]   lunch_ll_t    = array.new_int()
var int[]   lunch_day_n   = array.new_int()

bool lunch_now   = f_in_sess(lunch_sh, lunch_sm, lunch_eh, lunch_em)
bool lunch_start = lunch_now  and not lunch_in
bool lunch_end   = not lunch_now and lunch_in

if lunch_start and tf_ok
    lunch_in   := true
    lunch_hi   := high
    lunch_lo   := low
    lunch_hi_t := time
    lunch_lo_t := time
    b = box.new(time, high, time + bar_ms, low, xloc=xloc.bar_time,
                bgcolor=na, border_color=na, border_width=0)
    array.push(lunch_bxs, b)
    array.push(lunch_his, high)
    array.push(lunch_los, low)
    array.push(lunch_lt,  time)
    array.push(lunch_rt,  time + bar_ms)
    ml = line.new(time, (high + low) / 2, time + bar_ms, (high + low) / 2, xloc=xloc.bar_time, color=na, width=0)
    array.push(lunch_mid_lns, ml)
    hl = line.new(time, high, time + bar_ms, high, xloc=xloc.bar_time, color=na, width=0)
    ll = line.new(time, low,  time + bar_ms, low,  xloc=xloc.bar_time, color=na, width=0)
    hl_lbl = label.new(time + bar_ms, high, "Lunch High", xloc=xloc.bar_time,
                       color=na, textcolor=na, size=size.small)
    ll_lbl = label.new(time + bar_ms, low,  "Lunch Low",  xloc=xloc.bar_time,
                       color=na, textcolor=na, size=size.small)
    array.push(lunch_hl_lns, hl)
    array.push(lunch_ll_lns, ll)
    array.push(lunch_hl_tkn, na)
    array.push(lunch_ll_tkn, na)
    array.push(lunch_hl_lbls, hl_lbl)
    array.push(lunch_ll_lbls, ll_lbl)
    array.push(lunch_hl_t, time)
    array.push(lunch_ll_t, time)
    array.push(lunch_day_n, tday_num)
    f_trim_sess(lunch_bxs, lunch_his, lunch_los, lunch_lt, lunch_rt, lunch_day_n, lunch_mid_lns, max_ol)
    f_trim_hl(lunch_hl_lns, lunch_ll_lns, lunch_hl_tkn, lunch_ll_tkn, lunch_hl_lbls, lunch_ll_lbls, lunch_hl_t, lunch_ll_t, max_ol)

if lunch_in and not lunch_start
    if high >= lunch_hi
        lunch_hi   := high
        lunch_hi_t := time
    if low <= lunch_lo
        lunch_lo   := low
        lunch_lo_t := time

if lunch_end
    lunch_in := false

int n_lunch = array.size(lunch_bxs)
if n_lunch > 0
    for i = 0 to n_lunch - 1
        bool live = i == n_lunch - 1 and lunch_in
        if live
            array.set(lunch_his,  i, lunch_hi)
            array.set(lunch_los,  i, lunch_lo)
            array.set(lunch_rt,   i, time + bar_ms)
            array.set(lunch_hl_t, i, lunch_hi_t)
            array.set(lunch_ll_t, i, lunch_lo_t)
        float h_prc_u = array.get(lunch_his,  i)
        float l_prc_u = array.get(lunch_los,  i)
        if not live
            if na(array.get(lunch_hl_tkn, i)) and high >= h_prc_u
                array.set(lunch_hl_tkn, i, time + sl_grace * bar_ms)
            if na(array.get(lunch_ll_tkn, i)) and low <= l_prc_u
                array.set(lunch_ll_tkn, i, time + sl_grace * bar_ms)
        if barstate.islast or live
            b = array.get(lunch_bxs, i)
            box.set_top(b,           h_prc_u)
            box.set_bottom(b,        l_prc_u)
            box.set_left(b,          array.get(lunch_lt,  i))
            box.set_right(b,         array.get(lunch_rt,  i))
            bool day_ok_u = tday_num - array.get(lunch_day_n, i) <= prev_days
            box.set_bgcolor(b,       show_lunch and tf_ok and day_ok_u ? lunch_col : na)
            box.set_border_color(b,  show_lunch and tf_ok and day_ok_u ? color.new(lunch_col, 0) : na)
            box.set_border_width(b,  show_lunch and tf_ok and day_ok_u ? bw_in : 0)
            box.set_border_style(b,  ls(bsty_in))
            box.set_text(b,          show_lunch and show_box_lbl and day_ok_u ? "Lunch" : "")
            box.set_text_color(b,    box_lbl_col)
            box.set_text_size(b,     lbl_sz(box_lbl_size))
            box.set_text_halign(b,   bx_halign(box_lbl_pos))
            box.set_text_valign(b,   bx_valign(box_lbl_pos))
            line  mid_u   = array.get(lunch_mid_lns, i)
            bool  midvis_u = show_mid_line and show_lunch and tf_ok and day_ok_u
            float mid_p_u = (h_prc_u + l_prc_u) / 2
            line.set_x1(mid_u, array.get(lunch_lt, i))
            line.set_x2(mid_u, array.get(lunch_rt, i))
            line.set_y1(mid_u, mid_p_u)
            line.set_y2(mid_u, mid_p_u)
            line.set_color(mid_u, midvis_u ? mid_line_col : na)
            line.set_width(mid_u, midvis_u ? mid_line_w : 0)
            line.set_style(mid_u, ls(mid_line_sty))
            int   h_t1_u  = array.get(lunch_hl_t, i)
            int   l_t1_u  = array.get(lunch_ll_t, i)
            line  h_ln_u  = array.get(lunch_hl_lns, i)
            line  l_ln_u  = array.get(lunch_ll_lns, i)
            int   h_tkn_u = array.get(lunch_hl_tkn, i)
            int   l_tkn_u = array.get(lunch_ll_tkn, i)
            int  h_x2_u = not na(h_tkn_u) ? h_tkn_u : time + extend_ms
            int  l_x2_u = not na(l_tkn_u) ? l_tkn_u : time + extend_ms
            bool vis_u   = show_sl_lines and sl_show_lunch and tf_ok and not live and day_ok_u
            line.set_x1(h_ln_u, h_t1_u)
            line.set_x2(h_ln_u, h_x2_u)
            line.set_y1(h_ln_u, h_prc_u)
            line.set_y2(h_ln_u, h_prc_u)
            line.set_color(h_ln_u, vis_u ? color.new(lunch_col, 0) : na)
            line.set_width(h_ln_u, vis_u ? sl_w : 0)
            line.set_style(h_ln_u, ls(sl_sty_in))
            line.set_x1(l_ln_u, l_t1_u)
            line.set_x2(l_ln_u, l_x2_u)
            line.set_y1(l_ln_u, l_prc_u)
            line.set_y2(l_ln_u, l_prc_u)
            line.set_color(l_ln_u, vis_u ? color.new(lunch_col, 0) : na)
            line.set_width(l_ln_u, vis_u ? sl_w : 0)
            line.set_style(l_ln_u, ls(sl_sty_in))
            label hl_lbl_u = array.get(lunch_hl_lbls, i)
            label ll_lbl_u = array.get(lunch_ll_lbls, i)
            label.set_x(hl_lbl_u, sl_lbl_x(sl_lbl_pos, h_t1_u, h_x2_u))
            label.set_y(hl_lbl_u, h_prc_u)
            label.set_style(hl_lbl_u, sl_lbl_sty_hi(sl_lbl_pos))
            label.set_text(hl_lbl_u, sl_lbl_txt("Lunch High", h_prc_u) + htf_tag(h_prc_u, array.get(lunch_hl_t, i), true) + eq_at(true, h_prc_u))
            label.set_size(hl_lbl_u, lbl_sz(sl_lbl_sz))
            label.set_textcolor(hl_lbl_u, vis_u ? color.new(lunch_col, 0) : na)
            label.set_x(ll_lbl_u, sl_lbl_x(sl_lbl_pos, l_t1_u, l_x2_u))
            label.set_y(ll_lbl_u, l_prc_u)
            label.set_style(ll_lbl_u, sl_lbl_sty_lo(sl_lbl_pos))
            label.set_text(ll_lbl_u, sl_lbl_txt("Lunch Low", l_prc_u) + htf_tag(l_prc_u, array.get(lunch_ll_t, i), false) + eq_at(false, l_prc_u))
            label.set_size(ll_lbl_u, lbl_sz(sl_lbl_sz))
            label.set_textcolor(ll_lbl_u, vis_u ? color.new(lunch_col, 0) : na)

// ── NY PM SESSION ─────────────────────────────────────────────────────────────
var bool    nypm_in   = false
var float   nypm_hi   = na
var float   nypm_lo   = na
var int     nypm_hi_t = na
var int     nypm_lo_t = na
var box[]   nypm_bxs  = array.new_box()
var float[] nypm_his  = array.new_float()
var float[] nypm_los  = array.new_float()
var int[]   nypm_lt   = array.new_int()
var int[]   nypm_rt   = array.new_int()
var line[]  nypm_mid_lns = array.new_line()
var line[]  nypm_hl_lns  = array.new_line()
var line[]  nypm_ll_lns  = array.new_line()
var int[]   nypm_hl_tkn  = array.new_int()
var int[]   nypm_ll_tkn  = array.new_int()
var label[] nypm_hl_lbls = array.new_label()
var label[] nypm_ll_lbls = array.new_label()
var int[]   nypm_hl_t    = array.new_int()
var int[]   nypm_ll_t    = array.new_int()
var int[]   nypm_day_n   = array.new_int()

bool nypm_now   = f_in_sess(nypm_sh, nypm_sm, nypm_eh, nypm_em)
bool nypm_start = nypm_now  and not nypm_in
bool nypm_end   = not nypm_now and nypm_in

if nypm_start and tf_ok
    nypm_in   := true
    nypm_hi   := high
    nypm_lo   := low
    nypm_hi_t := time
    nypm_lo_t := time
    b = box.new(time, high, time + bar_ms, low, xloc=xloc.bar_time,
                bgcolor=na, border_color=na, border_width=0)
    array.push(nypm_bxs, b)
    array.push(nypm_his, high)
    array.push(nypm_los, low)
    array.push(nypm_lt,  time)
    array.push(nypm_rt,  time + bar_ms)
    ml = line.new(time, (high + low) / 2, time + bar_ms, (high + low) / 2, xloc=xloc.bar_time, color=na, width=0)
    array.push(nypm_mid_lns, ml)
    hl = line.new(time, high, time + bar_ms, high, xloc=xloc.bar_time, color=na, width=0)
    ll = line.new(time, low,  time + bar_ms, low,  xloc=xloc.bar_time, color=na, width=0)
    hl_lbl = label.new(time + bar_ms, high, "PM High", xloc=xloc.bar_time,
                       color=na, textcolor=na, size=size.small)
    ll_lbl = label.new(time + bar_ms, low,  "PM Low",  xloc=xloc.bar_time,
                       color=na, textcolor=na, size=size.small)
    array.push(nypm_hl_lns, hl)
    array.push(nypm_ll_lns, ll)
    array.push(nypm_hl_tkn, na)
    array.push(nypm_ll_tkn, na)
    array.push(nypm_hl_lbls, hl_lbl)
    array.push(nypm_ll_lbls, ll_lbl)
    array.push(nypm_hl_t, time)
    array.push(nypm_ll_t, time)
    array.push(nypm_day_n, tday_num)
    f_trim_sess(nypm_bxs, nypm_his, nypm_los, nypm_lt, nypm_rt, nypm_day_n, nypm_mid_lns, max_ol)
    f_trim_hl(nypm_hl_lns, nypm_ll_lns, nypm_hl_tkn, nypm_ll_tkn, nypm_hl_lbls, nypm_ll_lbls, nypm_hl_t, nypm_ll_t, max_ol)

if nypm_in and not nypm_start
    if high >= nypm_hi
        nypm_hi   := high
        nypm_hi_t := time
    if low <= nypm_lo
        nypm_lo   := low
        nypm_lo_t := time

if nypm_end
    nypm_in := false

int n_nypm = array.size(nypm_bxs)
if n_nypm > 0
    for i = 0 to n_nypm - 1
        bool live = i == n_nypm - 1 and nypm_in
        if live
            array.set(nypm_his,  i, nypm_hi)
            array.set(nypm_los,  i, nypm_lo)
            array.set(nypm_rt,   i, time + bar_ms)
            array.set(nypm_hl_t, i, nypm_hi_t)
            array.set(nypm_ll_t, i, nypm_lo_t)
        float h_prc_p = array.get(nypm_his,  i)
        float l_prc_p = array.get(nypm_los,  i)
        if not live
            if na(array.get(nypm_hl_tkn, i)) and high >= h_prc_p
                array.set(nypm_hl_tkn, i, time + sl_grace * bar_ms)
            if na(array.get(nypm_ll_tkn, i)) and low <= l_prc_p
                array.set(nypm_ll_tkn, i, time + sl_grace * bar_ms)
        if barstate.islast or live
            b = array.get(nypm_bxs, i)
            box.set_top(b,           h_prc_p)
            box.set_bottom(b,        l_prc_p)
            box.set_left(b,          array.get(nypm_lt,  i))
            box.set_right(b,         array.get(nypm_rt,  i))
            bool day_ok_p = tday_num - array.get(nypm_day_n, i) <= prev_days
            box.set_bgcolor(b,       show_nypm and tf_ok and day_ok_p ? nypm_col : na)
            box.set_border_color(b,  show_nypm and tf_ok and day_ok_p ? color.new(nypm_col, 0) : na)
            box.set_border_width(b,  show_nypm and tf_ok and day_ok_p ? bw_in : 0)
            box.set_border_style(b,  ls(bsty_in))
            box.set_text(b,          show_nypm and show_box_lbl and day_ok_p ? "NY PM" : "")
            box.set_text_color(b,    box_lbl_col)
            box.set_text_size(b,     lbl_sz(box_lbl_size))
            box.set_text_halign(b,   bx_halign(box_lbl_pos))
            box.set_text_valign(b,   bx_valign(box_lbl_pos))
            line  mid_p   = array.get(nypm_mid_lns, i)
            bool  midvis_p = show_mid_line and show_nypm and tf_ok and day_ok_p
            float mid_p_p = (h_prc_p + l_prc_p) / 2
            line.set_x1(mid_p, array.get(nypm_lt, i))
            line.set_x2(mid_p, array.get(nypm_rt, i))
            line.set_y1(mid_p, mid_p_p)
            line.set_y2(mid_p, mid_p_p)
            line.set_color(mid_p, midvis_p ? mid_line_col : na)
            line.set_width(mid_p, midvis_p ? mid_line_w : 0)
            line.set_style(mid_p, ls(mid_line_sty))
            int   h_t1_p  = array.get(nypm_hl_t, i)
            int   l_t1_p  = array.get(nypm_ll_t, i)
            line  h_ln_p  = array.get(nypm_hl_lns, i)
            line  l_ln_p  = array.get(nypm_ll_lns, i)
            int   h_tkn_p = array.get(nypm_hl_tkn, i)
            int   l_tkn_p = array.get(nypm_ll_tkn, i)
            int  h_x2_p = not na(h_tkn_p) ? h_tkn_p : time + extend_ms
            int  l_x2_p = not na(l_tkn_p) ? l_tkn_p : time + extend_ms
            bool vis_p   = show_sl_lines and sl_show_nypm and tf_ok and not live and day_ok_p
            line.set_x1(h_ln_p, h_t1_p)
            line.set_x2(h_ln_p, h_x2_p)
            line.set_y1(h_ln_p, h_prc_p)
            line.set_y2(h_ln_p, h_prc_p)
            line.set_color(h_ln_p, vis_p ? color.new(nypm_col, 0) : na)
            line.set_width(h_ln_p, vis_p ? sl_w : 0)
            line.set_style(h_ln_p, ls(sl_sty_in))
            line.set_x1(l_ln_p, l_t1_p)
            line.set_x2(l_ln_p, l_x2_p)
            line.set_y1(l_ln_p, l_prc_p)
            line.set_y2(l_ln_p, l_prc_p)
            line.set_color(l_ln_p, vis_p ? color.new(nypm_col, 0) : na)
            line.set_width(l_ln_p, vis_p ? sl_w : 0)
            line.set_style(l_ln_p, ls(sl_sty_in))
            label hl_lbl_p = array.get(nypm_hl_lbls, i)
            label ll_lbl_p = array.get(nypm_ll_lbls, i)
            label.set_x(hl_lbl_p, sl_lbl_x(sl_lbl_pos, h_t1_p, h_x2_p))
            label.set_y(hl_lbl_p, h_prc_p)
            label.set_style(hl_lbl_p, sl_lbl_sty_hi(sl_lbl_pos))
            label.set_text(hl_lbl_p, sl_lbl_txt("PM High", h_prc_p) + htf_tag(h_prc_p, array.get(nypm_hl_t, i), true) + eq_at(true, h_prc_p))
            label.set_size(hl_lbl_p, lbl_sz(sl_lbl_sz))
            label.set_textcolor(hl_lbl_p, vis_p ? color.new(nypm_col, 0) : na)
            label.set_x(ll_lbl_p, sl_lbl_x(sl_lbl_pos, l_t1_p, l_x2_p))
            label.set_y(ll_lbl_p, l_prc_p)
            label.set_style(ll_lbl_p, sl_lbl_sty_lo(sl_lbl_pos))
            label.set_text(ll_lbl_p, sl_lbl_txt("PM Low", l_prc_p) + htf_tag(l_prc_p, array.get(nypm_ll_t, i), false) + eq_at(false, l_prc_p))
            label.set_size(ll_lbl_p, lbl_sz(sl_lbl_sz))
            label.set_textcolor(ll_lbl_p, vis_p ? color.new(nypm_col, 0) : na)

// ════════════════════════════════════════════════════════════════════════════
// DAILY & WEEKLY LEVELS
// ════════════════════════════════════════════════════════════════════════════

// Previous day & week H/L via higher-timeframe security
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead=barmerge.lookahead_on)

// Track running H/L within the current day/week to record the bar where each extreme was formed.
// On the boundary bar we save the previous period's extreme time as x1 for the new D&W line.
var float cur_day_hi   = na
var int   cur_day_hi_t = na
var float cur_day_lo   = na
var int   cur_day_lo_t = na
var float cur_wk_hi    = na
var int   cur_wk_hi_t  = na
var float cur_wk_lo    = na
var int   cur_wk_lo_t  = na
var int   pdh_ln_x1    = na   // x1 timestamp for current PDH line
var int   pdl_ln_x1    = na
var int   pwh_ln_x1    = na
var int   pwl_ln_x1    = na

if new_day_d
    pdh_ln_x1    := na(cur_day_hi_t) ? time : cur_day_hi_t
    pdl_ln_x1    := na(cur_day_lo_t) ? time : cur_day_lo_t
    cur_day_hi   := high
    cur_day_hi_t := time
    cur_day_lo   := low
    cur_day_lo_t := time
else
    if na(cur_day_hi) or high >= cur_day_hi
        cur_day_hi   := high
        cur_day_hi_t := time
    if na(cur_day_lo) or low <= cur_day_lo
        cur_day_lo   := low
        cur_day_lo_t := time

if new_week_w
    pwh_ln_x1   := na(cur_wk_hi_t) ? time : cur_wk_hi_t
    pwl_ln_x1   := na(cur_wk_lo_t) ? time : cur_wk_lo_t
    cur_wk_hi   := high
    cur_wk_hi_t := time
    cur_wk_lo   := low
    cur_wk_lo_t := time
else
    if na(cur_wk_hi) or high >= cur_wk_hi
        cur_wk_hi   := high
        cur_wk_hi_t := time
    if na(cur_wk_lo) or low <= cur_wk_lo
        cur_wk_lo   := low
        cur_wk_lo_t := time

var line  pdh_ln  = na
var line  pdl_ln  = na
var line  pwh_ln  = na
var line  pwl_ln  = na
var label pdh_lbl_obj = na
var label pdl_lbl_obj = na
var label pwh_lbl_obj = na
var label pwl_lbl_obj = na
var int   pdh_tkn = na
var int   pdl_tkn = na
var int   pwh_tkn = na
var int   pwl_tkn = na

// Recreate daily lines at the start of each new day
if (new_day_d or na(pdh_ln)) and not na(pdh)
    line.delete(pdh_ln)
    line.delete(pdl_ln)
    label.delete(pdh_lbl_obj)
    label.delete(pdl_lbl_obj)
    pdh_tkn := na
    pdl_tkn := na
    pdh_ln      := line.new(na(pdh_ln_x1) ? time : pdh_ln_x1, pdh, time + extend_ms, pdh, xloc=xloc.bar_time, color=na, width=1)
    pdl_ln      := line.new(na(pdl_ln_x1) ? time : pdl_ln_x1, pdl, time + extend_ms, pdl, xloc=xloc.bar_time, color=na, width=1)
    pdh_lbl_obj := label.new(time + extend_ms, pdh, pdh_lbl, xloc=xloc.bar_time,
                              color=na, textcolor=na, size=size.small)
    pdl_lbl_obj := label.new(time + extend_ms, pdl, pdl_lbl, xloc=xloc.bar_time,
                              color=na, textcolor=na, size=size.small)

// Recreate weekly lines at the start of each new week
if (new_week_w or na(pwh_ln)) and not na(pwh)
    line.delete(pwh_ln)
    line.delete(pwl_ln)
    label.delete(pwh_lbl_obj)
    label.delete(pwl_lbl_obj)
    pwh_tkn := na
    pwl_tkn := na
    pwh_ln      := line.new(na(pwh_ln_x1) ? time : pwh_ln_x1, pwh, time + extend_ms, pwh, xloc=xloc.bar_time, color=na, width=1)
    pwl_ln      := line.new(na(pwl_ln_x1) ? time : pwl_ln_x1, pwl, time + extend_ms, pwl, xloc=xloc.bar_time, color=na, width=1)
    pwh_lbl_obj := label.new(time + extend_ms, pwh, pwh_lbl, xloc=xloc.bar_time,
                              color=na, textcolor=na, size=size.small)
    pwl_lbl_obj := label.new(time + extend_ms, pwl, pwl_lbl, xloc=xloc.bar_time,
                              color=na, textcolor=na, size=size.small)

// Update all properties every bar for toggle/color/style/extension responsiveness
if not na(pdh_ln)
    if na(pdh_tkn) and high >= pdh
        pdh_tkn := time + dw_grace * bar_ms
    if barstate.islast
        int pdh_x1 = na(pdh_ln_x1) ? time : pdh_ln_x1
        int pdh_x2 = not na(pdh_tkn) ? pdh_tkn : time + extend_ms
        line.set_y1(pdh_ln, pdh)
        line.set_y2(pdh_ln, pdh)
        line.set_x2(pdh_ln, pdh_x2)
        line.set_color(pdh_ln, show_pdh ? pdh_col : na)
        line.set_style(pdh_ln, ls(pdh_sty_in))
        line.set_width(pdh_ln, show_pdh ? pdh_w : 0)
        label.set_x(pdh_lbl_obj, sl_lbl_x(d_lbl_pos, pdh_x1, pdh_x2))
        label.set_y(pdh_lbl_obj, pdh)
        label.set_style(pdh_lbl_obj, sl_lbl_sty_hi(d_lbl_pos))
        label.set_text(pdh_lbl_obj, dw_lbl_txt(pdh_lbl, pdh) + eq_at(true, pdh))
        label.set_textcolor(pdh_lbl_obj, show_pdh and show_dw_labels ? pdh_col : na)

if not na(pdl_ln)
    if na(pdl_tkn) and low <= pdl
        pdl_tkn := time + dw_grace * bar_ms
    if barstate.islast
        int pdl_x1 = na(pdl_ln_x1) ? time : pdl_ln_x1
        int pdl_x2 = not na(pdl_tkn) ? pdl_tkn : time + extend_ms
        line.set_y1(pdl_ln, pdl)
        line.set_y2(pdl_ln, pdl)
        line.set_x2(pdl_ln, pdl_x2)
        line.set_color(pdl_ln, show_pdl ? pdl_col : na)
        line.set_style(pdl_ln, ls(pdl_sty_in))
        line.set_width(pdl_ln, show_pdl ? pdl_w : 0)
        label.set_x(pdl_lbl_obj, sl_lbl_x(d_lbl_pos, pdl_x1, pdl_x2))
        label.set_y(pdl_lbl_obj, pdl)
        label.set_style(pdl_lbl_obj, sl_lbl_sty_lo(d_lbl_pos))
        label.set_text(pdl_lbl_obj, dw_lbl_txt(pdl_lbl, pdl) + eq_at(false, pdl))
        label.set_textcolor(pdl_lbl_obj, show_pdl and show_dw_labels ? pdl_col : na)

if not na(pwh_ln)
    if na(pwh_tkn) and high >= pwh
        pwh_tkn := time + dw_grace * bar_ms
    if barstate.islast
        int pwh_x1 = na(pwh_ln_x1) ? time : pwh_ln_x1
        int pwh_x2 = not na(pwh_tkn) ? pwh_tkn : time + extend_ms
        line.set_y1(pwh_ln, pwh)
        line.set_y2(pwh_ln, pwh)
        line.set_x2(pwh_ln, pwh_x2)
        line.set_color(pwh_ln, show_pwh ? pwh_col : na)
        line.set_style(pwh_ln, ls(pwh_sty_in))
        line.set_width(pwh_ln, show_pwh ? pwh_w : 0)
        label.set_x(pwh_lbl_obj, sl_lbl_x(w_lbl_pos, pwh_x1, pwh_x2))
        label.set_y(pwh_lbl_obj, pwh)
        label.set_style(pwh_lbl_obj, sl_lbl_sty_hi(w_lbl_pos))
        label.set_text(pwh_lbl_obj, dw_lbl_txt(pwh_lbl, pwh) + eq_at(true, pwh))
        label.set_textcolor(pwh_lbl_obj, show_pwh and show_dw_labels ? pwh_col : na)

if not na(pwl_ln)
    if na(pwl_tkn) and low <= pwl
        pwl_tkn := time + dw_grace * bar_ms
    if barstate.islast
        int pwl_x1 = na(pwl_ln_x1) ? time : pwl_ln_x1
        int pwl_x2 = not na(pwl_tkn) ? pwl_tkn : time + extend_ms
        line.set_y1(pwl_ln, pwl)
        line.set_y2(pwl_ln, pwl)
        line.set_x2(pwl_ln, pwl_x2)
        line.set_color(pwl_ln, show_pwl ? pwl_col : na)
        line.set_style(pwl_ln, ls(pwl_sty_in))
        line.set_width(pwl_ln, show_pwl ? pwl_w : 0)
        label.set_x(pwl_lbl_obj, sl_lbl_x(w_lbl_pos, pwl_x1, pwl_x2))
        label.set_y(pwl_lbl_obj, pwl)
        label.set_style(pwl_lbl_obj, sl_lbl_sty_lo(w_lbl_pos))
        label.set_text(pwl_lbl_obj, dw_lbl_txt(pwl_lbl, pwl) + eq_at(false, pwl))
        label.set_textcolor(pwl_lbl_obj, show_pwl and show_dw_labels ? pwl_col : na)

// ════════════════════════════════════════════════════════════════════════════
// EQUAL HIGHS & LOWS
// ════════════════════════════════════════════════════════════════════════════
// Two consecutive same-type swings are "equal" when their price difference is
// within eq_tol% of the pullback (vertical move) that separates them.
//   highs:  vert = firstHigh - lowestLowBetween ;  diff = |secondHigh - firstHigh|
//   lows:   vert = highestHighBetween - firstLow ; diff = |secondLow  - firstLow|
//   equal  <=>  diff <= vert * eq_tol/100
// Lines extend right until price takes the level, then freeze in place.
// State arrays are declared up in HELPERS.

// Each new pivot is compared against the last eq_depth pivots of the same type
// (not just the immediately previous one), so equal levels separated by other
// swings — i.e. many candles apart — are still caught.

// rolling pivot history: price, bar time, and running high/low since each pivot
var float[] ph_prc = array.new_float()
var int[]   ph_t   = array.new_int()
var float[] ph_max = array.new_float()
var float[] ph_min = array.new_float()
var bool[]  ph_used = array.new_bool()    // already part of an EQH → can't pair again
var float[] pl_prc = array.new_float()
var int[]   pl_t   = array.new_int()
var float[] pl_max = array.new_float()
var float[] pl_min = array.new_float()
var bool[]  pl_used = array.new_bool()     // already part of an EQL → can't pair again

// keep the running extremes of every remembered pivot current
int nph = array.size(ph_prc)
if nph > 0
    for k = 0 to nph - 1
        array.set(ph_max, k, math.max(array.get(ph_max, k), high))
        array.set(ph_min, k, math.min(array.get(ph_min, k), low))
int npl = array.size(pl_prc)
if npl > 0
    for k = 0 to npl - 1
        array.set(pl_max, k, math.max(array.get(pl_max, k), high))
        array.set(pl_min, k, math.min(array.get(pl_min, k), low))

// create an equal-level drawing (left edge at the matched prior pivot)
f_eq_push(isHigh, t1, lvl, lvlt) =>
    line  el = line.new(t1, lvl, time + extend_ms, lvl, xloc=xloc.bar_time,
         color=na, style=ls(eq_sty_in), width=eq_w)
    label eb = label.new(time + extend_ms, lvl, "", xloc=xloc.bar_time,
         style=isHigh ? label.style_label_lower_right : label.style_label_upper_right,
         color=na, textcolor=na, size=lbl_sz(eq_lbl_sz))
    array.push(eq_lines, el)
    array.push(eq_labels, eb)
    array.push(eq_ishigh, isHigh)
    array.push(eq_lvl, lvl)
    array.push(eq_tkn, na)
    array.push(eq_tknday, na)
    array.push(eq_lvltime, lvlt)

// EQ pivots are sourced from max(chart, 5min): on a sub-5min chart this finds the
// 5-minute swings (not 1-minute noise); at 5min+ it's the chart's own pivots.
string eq_tf = timeframe.from_seconds(math.max(300, chart_sec))
[eq_ph, eq_pl, eq_pt] = request.security(syminfo.tickerid, eq_tf, [ta.pivothigh(eq_pivot, eq_pivot), ta.pivotlow(eq_pivot, eq_pivot), time[eq_pivot]], lookahead=barmerge.lookahead_off)
// a new pivot has confirmed when the (forward-filled) value changes from the prior bar
bool eq_new_ph = not na(eq_ph) and (na(eq_ph[1]) or eq_ph != eq_ph[1])
bool eq_new_pl = not na(eq_pl) and (na(eq_pl[1]) or eq_pl != eq_pl[1])

// ── swing highs ──────────────────────────────────────────────────────────────
float ph = eq_ph
if eq_new_ph
    int   phT      = eq_pt
    int   match_t  = na
    float match_pr = na
    int   match_k  = na
    bool  used_match = false
    int   m = array.size(ph_prc)
    if m > 0
        for k = m - 1 to 0                            // newest prior pivot first
            float prior = array.get(ph_prc, k)
            float vmove = prior - array.get(ph_min, k)   // drop between the two highs
            bool  swept = array.get(ph_max, k) > prior   // price already broke above prior
            float diff  = math.abs(ph - prior)
            bool  oksw  = not eq_no_sweep or (ph <= prior and not swept)
            if vmove > 0 and diff <= vmove * eq_tol / 100.0 and oksw
                if array.get(ph_used, k)
                    used_match := true               // matches a high already in an EQH cluster
                else
                    match_t  := array.get(ph_t, k)
                    match_pr := prior
                    match_k  := k
                    break                            // prefer an unused match → draw a fresh EQH
    bool ph_draw     = not na(match_t)
    bool ph_consumed = ph_draw or used_match         // spent if it draws OR is absorbed into a cluster
    if ph_draw
        array.set(ph_used, match_k, true)            // the matched prior high is now spent
        f_eq_push(true, match_t, math.max(match_pr, ph), ph >= match_pr ? phT : match_t)
    array.push(ph_prc, ph)
    array.push(ph_t, phT)
    array.push(ph_max, high)
    array.push(ph_min, low)
    array.push(ph_used, ph_consumed)                 // mark spent so it can't seed a duplicate later
    while array.size(ph_prc) > eq_depth
        array.shift(ph_prc)
        array.shift(ph_t)
        array.shift(ph_max)
        array.shift(ph_min)
        array.shift(ph_used)

// ── swing lows ───────────────────────────────────────────────────────────────
float pl = eq_pl
if eq_new_pl
    int   plT      = eq_pt
    int   match_t  = na
    float match_pr = na
    int   match_k  = na
    bool  used_match = false
    int   m = array.size(pl_prc)
    if m > 0
        for k = m - 1 to 0                            // newest prior pivot first
            float prior = array.get(pl_prc, k)
            float vmove = array.get(pl_max, k) - prior   // rally between the two lows
            bool  swept = array.get(pl_min, k) < prior   // price already broke below prior
            float diff  = math.abs(pl - prior)
            bool  oksw  = not eq_no_sweep or (pl >= prior and not swept)
            if vmove > 0 and diff <= vmove * eq_tol / 100.0 and oksw
                if array.get(pl_used, k)
                    used_match := true               // matches a low already in an EQL cluster
                else
                    match_t  := array.get(pl_t, k)
                    match_pr := prior
                    match_k  := k
                    break                            // prefer an unused match → draw a fresh EQL
    bool pl_draw     = not na(match_t)
    bool pl_consumed = pl_draw or used_match         // spent if it draws OR is absorbed into a cluster
    if pl_draw
        array.set(pl_used, match_k, true)            // the matched prior low is now spent
        f_eq_push(false, match_t, math.min(match_pr, pl), pl <= match_pr ? plT : match_t)
    array.push(pl_prc, pl)
    array.push(pl_t, plT)
    array.push(pl_max, high)
    array.push(pl_min, low)
    array.push(pl_used, pl_consumed)                 // mark spent so it can't seed a duplicate later
    while array.size(pl_prc) > eq_depth
        array.shift(pl_prc)
        array.shift(pl_t)
        array.shift(pl_max)
        array.shift(pl_min)
        array.shift(pl_used)

// ── storage cap: bound the object count (display is limited separately, below) ──
while array.size(eq_lines) > 50
    line.delete(array.shift(eq_lines))
    label.delete(array.shift(eq_labels))
    array.shift(eq_ishigh)
    array.shift(eq_lvl)
    array.shift(eq_tkn)
    array.shift(eq_tknday)
    array.shift(eq_lvltime)

int eq_n = array.size(eq_lines)

// true if prc sits within match tolerance of any value in arr
f_near_arr(float prc, float[] arr) =>
    bool f = false
    int n = array.size(arr)
    if n > 0
        for i = 0 to n - 1
            if math.abs(array.get(arr, i) - prc) <= tf_tol_px
                f := true
    f

// true if prc coincides with a session High/Low or a Daily/Weekly High/Low of the same side
f_near_lvl(float prc, float lvl) =>
    not na(lvl) and math.abs(lvl - prc) <= tf_tol_px
near_session(bool isHigh, float prc) =>
    isHigh ? (f_near_arr(prc, asia_his) or f_near_arr(prc, lon_his) or f_near_arr(prc, nyam_his) or f_near_arr(prc, lunch_his) or f_near_arr(prc, nypm_his) or f_near_lvl(prc, pdh) or f_near_lvl(prc, pwh)) : (f_near_arr(prc, asia_los) or f_near_arr(prc, lon_los) or f_near_arr(prc, nyam_los) or f_near_arr(prc, lunch_los) or f_near_arr(prc, nypm_los) or f_near_lvl(prc, pdl) or f_near_lvl(prc, pwl))

// ── nearest-untaken selection: distance of the eq_max-th closest untaken level ──
// Only untaken, type-enabled levels compete for the limited on-chart slots.
float eq_thr = na
if eq_n > 0 and barstate.islast
    float[] eq_dists = array.new_float()
    for i = 0 to eq_n - 1
        bool  ih_s = array.get(eq_ishigh, i)
        bool  on_s = ih_s ? show_eqh : show_eql
        float d_s  = math.abs(array.get(eq_lvl, i) - close)
        if on_s and na(array.get(eq_tkn, i)) and (na(atr_range) or d_s <= atr_range)
            array.push(eq_dists, d_s)
    int dn = array.size(eq_dists)
    if dn > eq_max
        array.sort(eq_dists, order.ascending)
        eq_thr := array.get(eq_dists, eq_max - 1)   // farthest level still allowed on chart

// ── extend, freeze on take, and restyle every bar (keeps toggles live) ───────
if eq_n > 0
    for i = 0 to eq_n - 1
        bool   ih  = array.get(eq_ishigh, i)
        float  lv  = array.get(eq_lvl,    i)
        // take/invalidation → freeze the right edge and record the trading day of the take (per-bar)
        if na(array.get(eq_tkn, i)) and (ih ? high > lv : low < lv)
            array.set(eq_tkn,    i, time)
            array.set(eq_tknday, i, tday_num)
        if barstate.islast
            line   el2 = array.get(eq_lines,  i)
            label  eb2 = array.get(eq_labels, i)
            int  tkn   = array.get(eq_tkn, i)
            bool taken = not na(tkn)
            // hidden only if the take happened on a PREVIOUS day (today's sweeps stay visible)
            bool taken_prev_day = taken and (tday_num - array.get(eq_tknday, i) >= 1)
            bool hidden = eq_hide_inv and taken_prev_day
            bool on     = ih ? show_eqh : show_eql
            float dist  = math.abs(lv - close)
            bool in_rng = na(atr_range) or dist <= atr_range   // within Daily-ATR detection range
            // untaken levels must be among the nearest eq_max; taken levels just respect the hide rule
            bool merged = eq_merge_sess and near_session(ih, lv)   // absorbed into a session label (stays merged even once taken)
            bool vis = in_rng and not merged and (taken ? (on and not hidden) : (on and (na(eq_thr) or dist <= eq_thr)))
            color  c   = ih ? eqh_col : eql_col
            string nm  = ih ? eqh_lbl : eql_lbl
            int    x1  = line.get_x1(el2)
            int    x2  = taken ? tkn : time + extend_ms   // extend right until taken, then freeze
            line.set_x2(el2, x2)
            line.set_color(el2, vis ? c : na)
            line.set_style(el2, ls(eq_sty_in))
            line.set_width(el2, vis ? eq_w : 0)
            label.set_x(eb2, sl_lbl_x(eq_lbl_pos, x1, x2))
            label.set_y(eb2, lv)
            label.set_style(eb2, ih ? sl_lbl_sty_hi(eq_lbl_pos) : sl_lbl_sty_lo(eq_lbl_pos))
            label.set_size(eb2, lbl_sz(eq_lbl_sz))
            label.set_text(eb2, eq_lbl_txt(nm, lv) + htf_tag(lv, array.get(eq_lvltime, i), ih))
            label.set_textcolor(eb2, vis and eq_show_lbl ? c : na)
````
