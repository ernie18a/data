# Macroeconomic Tracker

- url: https://www.tradingview.com/script/mVHLLZmZ-Macroeconomic-Tracker/
- type: indicator
- pine_id: PUB;b7c3f470dea44db4abc600bba0002697
- version: 1.0

## Description

Macroeconomic Tracker highlights the exact release dates and times of 19 key U.S. macroeconomic reports directly on your chart, giving you a clear visual calendar of upcoming and historical data events.
Each indicator gets a distinct background color for the full release day, a vivid overlay during the active release window, and a labeled marker at the precise release time. A day-start label lists every report scheduled for that session so you can plan your trades before the open.
Reports covered:
ISM Manufacturing PMI® · ISM Services PMI® · ISM Supply Chain Planning Forecast · CPI · PPI · NFP Employment Situation · Import/Export Price Index · Productivity & Costs · ADP National Employment · JOLTS Job Openings · FT900 International Trade · EIA Short-Term Energy Outlook · EIA State Energy Portal · EIA Electric Power Monthly · EIA Electricity Monthly Update · EIA Monthly Energy Review · EIA Company Level Imports · EIA Natural Gas Monthly · EIA Petroleum Supply Monthly
Release times tracked: 8:15 AM · 8:30 AM · 10:00 AM · 12:00 PM · 3:00 PM · 4:00 PM ET
Features:

Individual toggle for every indicator — show only what matters to your strategy
Separate color customization per report
Release-time alerts for all major events
Schedule coverage through December 2026 based on official ISM, BLS, EIA, and FRED calendars

Works on any symbol and any intraday timeframe. Daily charts show forward-looking release dates across the full schedule year.
ISM PMI® is a registered trademark of Institute for Supply Management®.

## Source Code

````pine
//@version=6
indicator("Macroeconomic Tracker", shorttitle="MACRO◆TRACKER",
          overlay=true, max_labels_count=500)

// ══════════════════════════════════════════════════════════════════════════════
//  MACROECONOMIC TRACKER  |  Pine Script v6
//
//  Highlights release dates and times for eight key macroeconomic indicators.
//  Sources: ISM World (ismworld.org) and U.S. Bureau of Labor Statistics (bls.gov)
//  Schedule coverage: Q4 2025 through December 2026
//
//  RELEASE TIMES (Eastern Time)
//  ─────────────────────────────
//  10:00 AM : ISM Manufacturing PMI®
//             ISM Services PMI®
//             ISM Supply Chain Planning Forecast
//   8:30 AM : CPI · PPI · NFP · Import/Export Price · Productivity & Costs
//
//  VISUAL LANGUAGE
//  ───────────────
//  Full-day background : faint tint — report releases today
//  Release-hour band   : vivid overlay — active volatility window
//  Day-start label     : lists all indicators releasing today
//  Release-time label  : fires at exact release hour with indicator name
// ══════════════════════════════════════════════════════════════════════════════

// ─── INPUTS: INDICATOR FILTERS ───────────────────────────────────────────────
g0 = "Indicators — Toggle On/Off"
show_ism_mfg  = input.bool(true,  "ISM Manufacturing PMI®",         group=g0)
show_ism_svc  = input.bool(true,  "ISM Services PMI®",              group=g0)
show_ism_scpf = input.bool(true,  "ISM Supply Chain Forecast",      group=g0)
show_cpi      = input.bool(true,  "CPI  (Consumer Price Index)",    group=g0)
show_ppi      = input.bool(true,  "PPI  (Producer Price Index)",    group=g0)
show_nfp      = input.bool(true,  "NFP  (Employment Situation)",    group=g0)
show_impexp   = input.bool(true,  "Import / Export Price Index",    group=g0)
show_prod     = input.bool(true,  "Productivity & Costs",           group=g0)
show_adp      = input.bool(true,  "ADP National Employment",        group=g0)
show_jolts    = input.bool(true,  "JOLTS (Job Openings)",            group=g0)
show_trade    = input.bool(true,  "FT900 International Trade",       group=g0)
g0b = "EIA Energy Reports"
show_steo     = input.bool(true,  "EIA Short-Term Energy Outlook",   group=g0b)
show_sep      = input.bool(true,  "EIA State Energy Portal",         group=g0b)
show_epm      = input.bool(true,  "EIA Electric Power Monthly",      group=g0b)
show_emu      = input.bool(true,  "EIA Electricity Monthly Update",  group=g0b)
show_mer      = input.bool(true,  "EIA Monthly Energy Review",       group=g0b)
show_cli      = input.bool(true,  "EIA Company Level Imports",       group=g0b)
show_ngm      = input.bool(true,  "EIA Natural Gas Monthly",         group=g0b)
show_psm      = input.bool(true,  "EIA Petroleum Supply Monthly",    group=g0b)

// ─── INPUTS: COLORS ──────────────────────────────────────────────────────────
g1 = "Colors"
c_ism_mfg  = input.color(color.new(#2196F3, 82), "ISM Manufacturing PMI®",  group=g1)
c_ism_svc  = input.color(color.new(#673AB7, 82), "ISM Services PMI®",       group=g1)
c_ism_scpf = input.color(color.new(#00BCD4, 82), "ISM Supply Chain Forecast",group=g1)
c_cpi      = input.color(color.new(#FF4757, 82), "CPI",                     group=g1)
c_ppi      = input.color(color.new(#FFA502, 82), "PPI",                     group=g1)
c_nfp      = input.color(color.new(#00d4aa, 82), "NFP Employment",          group=g1)
c_impexp   = input.color(color.new(#FFD700, 85), "Import / Export Price",   group=g1)
c_prod     = input.color(color.new(#E91E63, 82), "Productivity & Costs",    group=g1)
c_adp      = input.color(color.new(#8BC34A, 82), "ADP Employment",           group=g1)
c_jolts    = input.color(color.new(#FF7043, 82), "JOLTS Job Openings",        group=g1)
c_trade    = input.color(color.new(#26C6DA, 82), "FT900 International Trade", group=g1)
g1b = "EIA Colors"
c_steo     = input.color(color.new(#FF6D00, 82), "STEO",                       group=g1b)
c_sep      = input.color(color.new(#8D6E63, 82), "State Energy Portal",        group=g1b)
c_epm      = input.color(color.new(#FDD835, 85), "Electric Power Monthly",     group=g1b)
c_emu      = input.color(color.new(#FB8C00, 85), "Electricity Monthly Update", group=g1b)
c_mer      = input.color(color.new(#F9A825, 85), "Monthly Energy Review",      group=g1b)
c_cli      = input.color(color.new(#C62828, 82), "Company Level Imports",      group=g1b)
c_ngm      = input.color(color.new(#039BE5, 82), "Natural Gas Monthly",        group=g1b)
c_psm      = input.color(color.new(#546E7A, 82), "Petroleum Supply Monthly",   group=g1b)

// ─── TIME ────────────────────────────────────────────────────────────────────
TZ     = "America/New_York"
et_h   = hour(time,      TZ)
et_m   = minute(time,    TZ)
et_dom = dayofmonth(time,TZ)
int cur_ymd = year(time,TZ) * 10000 + month(time,TZ) * 100 + et_dom
bool new_day    = cur_ymd != cur_ymd[1]
bool at_830     = et_h == 8  and et_m == 30
bool at_1000    = et_h == 10 and et_m == 0
bool window_830 = et_h == 8  and et_m >= 30
bool window_1000 = et_h == 10
bool at_815      = et_h == 8  and et_m == 15
bool window_815  = et_h == 8  and et_m == 15
bool at_1200     = et_h == 12 and et_m == 0
bool window_1200 = et_h == 12
bool at_1500     = et_h == 15 and et_m == 0
bool window_1500 = et_h == 15
bool at_1600     = et_h == 16 and et_m == 0
bool window_1600 = et_h == 16

// ─── DATE LOOKUP ─────────────────────────────────────────────────────────────
in_dates(array<int> arr, int d) =>
    bool found = false
    int  n     = array.size(arr)
    if n > 0
        for i = 0 to n - 1
            if array.get(arr, i) == d
                found := true
                break
    found

// ══════════════════════════════════════════════════════════════════════════════
//  RELEASE DATE ARRAYS  (YYYYMMDD)
//  Source: ISM World release calendar + BLS.gov release schedules
// ══════════════════════════════════════════════════════════════════════════════

// ─── ISM Manufacturing PMI®  — 1st business day, 10:00 AM ET ─────────────────
var array<int> ISM_MFG = array.from(
    20260105, 20260202, 20260302, 20260401, 20260501,
    20260601, 20260701, 20260803, 20260901, 20261001,
    20261102, 20261201)

// ─── ISM Services PMI®  — 3rd business day, 10:00 AM ET ──────────────────────
var array<int> ISM_SVC = array.from(
    20260107, 20260204, 20260304, 20260406, 20260505,
    20260603, 20260706, 20260805, 20260903, 20261005,
    20261104, 20261203)

// ─── ISM Supply Chain Planning Forecast  — 10:00 AM ET ───────────────────────
var array<int> ISM_SCPF = array.from(
    20260617, 20261216)

// ─── Consumer Price Index (CPI)  — 8:30 AM ET ────────────────────────────────
// Includes Dec 2025 release date (ref month Nov 2025) and full 2026 schedule
var array<int> CPI_D = array.from(
    20260113,  // Dec 2025 ref
    20260213, 20260311, 20260410, 20260512, 20260610,
    20260714, 20260812, 20260911, 20261014, 20261110, 20261210)

// ─── Producer Price Index (PPI)  — 8:30 AM ET ────────────────────────────────
var array<int> PPI_D = array.from(
    20260114,  // Nov 2025 ref
    20260130,  // Dec 2025 ref
    20260227, 20260318, 20260414, 20260513, 20260611,
    20260715, 20260813, 20260910, 20261015, 20261113, 20261215)

// ─── Employment Situation (NFP)  — 8:30 AM ET ────────────────────────────────
var array<int> NFP_D = array.from(
    20260109,  // Dec 2025 ref
    20260211, 20260306, 20260403, 20260508, 20260605,
    20260702, 20260807, 20260904, 20261002, 20261106, 20261204)

// ─── Import / Export Price Index  — 8:30 AM ET ───────────────────────────────
var array<int> IMPEXP_D = array.from(
    20260115,  // Nov 2025 ref
    20260210,  // Dec 2025 ref
    20260305, 20260325, 20260415, 20260514, 20260616,
    20260717, 20260818, 20260916, 20261016, 20261117, 20261217)

// ─── Productivity & Costs  — 8:30 AM ET ──────────────────────────────────────
var array<int> PROD_D = array.from(
    20260108,  // Q3 2025 Preliminary
    20260129,  // Q3 2025 Revised
    20260305,  // Q4 2025 Preliminary
    20260324,  // Q4 2025 Revised
    20260507,  // Q1 2026 Preliminary
    20260604,  // Q1 2026 Revised
    20260806,  // Q2 2026 Preliminary
    20260903,  // Q2 2026 Revised
    20261105,  // Q3 2026 Preliminary
    20261208)  // Q3 2026 Revised

// ─── ADP National Employment Report  — 8:15 AM ET ────────────────────────────
// Source: FRED release calendar (fred.stlouisfed.org). All times converted from
// US Central to Eastern. March 4 listed at 6:15 AM CT (anomaly) — treated as 8:15 AM ET.
var array<int> ADP_D = array.from(
    20260107, 20260204, 20260304, 20260401, 20260506,
    20260603, 20260701, 20260805, 20260902, 20260930,
    20261104, 20261202)

// ─── JOLTS (Job Openings and Labor Turnover Survey)  — 10:00 AM ET ───────────
// Source: FRED release calendar. 9:00 AM CT = 10:00 AM ET.
// Note: Some months have two releases when prior-month data catches up.
var array<int> JOLTS_D = array.from(
    20260107, 20260205, 20260313, 20260331, 20260505,
    20260602, 20260630, 20260804, 20260901, 20260929,
    20261103, 20261201)

// ─── FT900 U.S. International Trade in Goods & Services  — 8:30 AM ET ────────
// Source: U.S. Census Bureau / BEA FT900 press release schedule.
var array<int> TRADE_D = array.from(
    20260108,  // Oct 2025 ref
    20260129,  // Nov 2025 ref
    20260219,  // Dec 2025 ref
    20260312, 20260402, 20260505, 20260609,
    20260707, 20260804, 20260903, 20261006,
    20261104, 20261208)

// ─── EIA Short-Term Energy Outlook (STEO) — 12:00 PM ET ─────────────────────
// Rule: First Tuesday after the first Thursday of the month
var array<int> EIA_STEO_D = array.from(
    20260106, 20260210, 20260310, 20260407, 20260512, 20260609,
    20260707, 20260811, 20260908, 20261006, 20261110, 20261208)

// ─── EIA State Energy Portal — 3:00 PM ET (3rd Thursday) ─────────────────────
var array<int> EIA_SEP_D = array.from(
    20260115, 20260219, 20260319, 20260416, 20260521, 20260618,
    20260716, 20260820, 20260917, 20261015, 20261119, 20261217)

// ─── EIA 4:00 PM cluster: Electric Power Monthly / Electricity Monthly Update
//                          / Monthly Energy Review — 4:00 PM ET (last Thursday)
// Nov holiday adj: Thanksgiving Nov 26 → Nov 25. Dec adj: Christmas Eve → Dec 17.
// Dec 17 also coincides with State Energy Portal on same day.
var array<int> EIA_4PM_D = array.from(
    20260129, 20260226, 20260326, 20260430, 20260528, 20260625,
    20260730, 20260827, 20260924, 20261029, 20261125, 20261217)

// ─── EIA 3:00 PM cluster: Company Level Imports / Natural Gas Monthly
//                          / Petroleum Supply Monthly — 3:00 PM ET (last biz day)
// Apr 30 coincides with the 4 PM cluster (last Thu = last biz day in April).
var array<int> EIA_3PM_D = array.from(
    20260130, 20260227, 20260331, 20260430, 20260529, 20260630,
    20260731, 20260831, 20260930, 20261030, 20261130, 20261231)

// ══════════════════════════════════════════════════════════════════════════════
//  DETECTION
// ══════════════════════════════════════════════════════════════════════════════
bool is_ism_mfg  = show_ism_mfg  and in_dates(ISM_MFG,   cur_ymd)
bool is_ism_svc  = show_ism_svc  and in_dates(ISM_SVC,   cur_ymd)
bool is_ism_scpf = show_ism_scpf and in_dates(ISM_SCPF,  cur_ymd)
bool is_cpi      = show_cpi      and in_dates(CPI_D,     cur_ymd)
bool is_ppi      = show_ppi      and in_dates(PPI_D,     cur_ymd)
bool is_nfp      = show_nfp      and in_dates(NFP_D,     cur_ymd)
bool is_impexp   = show_impexp   and in_dates(IMPEXP_D,  cur_ymd)
bool is_prod     = show_prod     and in_dates(PROD_D,    cur_ymd)

bool is_adp      = show_adp   and in_dates(ADP_D,   cur_ymd)
bool is_jolts    = show_jolts and in_dates(JOLTS_D, cur_ymd)
bool is_trade    = show_trade and in_dates(TRADE_D, cur_ymd)

bool is_steo     = show_steo and in_dates(EIA_STEO_D, cur_ymd)
bool is_sep      = show_sep  and in_dates(EIA_SEP_D,  cur_ymd)
bool is_epm      = show_epm  and in_dates(EIA_4PM_D,  cur_ymd)
bool is_emu      = show_emu  and in_dates(EIA_4PM_D,  cur_ymd)
bool is_mer      = show_mer  and in_dates(EIA_4PM_D,  cur_ymd)
bool is_cli      = show_cli  and in_dates(EIA_3PM_D,  cur_ymd)
bool is_ngm      = show_ngm  and in_dates(EIA_3PM_D,  cur_ymd)
bool is_psm      = show_psm  and in_dates(EIA_3PM_D,  cur_ymd)
bool is_eia_any  = is_steo or is_sep or is_epm or is_emu or is_mer or is_cli or is_ngm or is_psm

bool is_ism_any  = is_ism_mfg or is_ism_svc or is_ism_scpf
bool is_bls_any  = is_cpi or is_ppi or is_nfp or is_impexp or is_prod or is_adp or is_jolts or is_trade
bool is_any      = is_ism_any or is_bls_any or is_eia_any

// ─── BACKGROUNDS ─────────────────────────────────────────────────────────────
// Full day — faint
bgcolor(is_ism_mfg  ? c_ism_mfg  : na, title="ISM Mfg PMI Day")
bgcolor(is_ism_svc  ? c_ism_svc  : na, title="ISM Svc PMI Day")
bgcolor(is_ism_scpf ? c_ism_scpf : na, title="ISM SCPF Day")
bgcolor(is_cpi      ? c_cpi      : na, title="CPI Day")
bgcolor(is_ppi      ? c_ppi      : na, title="PPI Day")
bgcolor(is_nfp      ? c_nfp      : na, title="NFP Day")
bgcolor(is_impexp   ? c_impexp   : na, title="Import/Export Day")
bgcolor(is_prod     ? c_prod     : na, title="Productivity Day")
bgcolor(is_adp      ? c_adp      : na, title="ADP Day")
bgcolor(is_jolts    ? c_jolts    : na, title="JOLTS Day")
bgcolor(is_trade    ? c_trade    : na, title="Trade Day")
bgcolor(is_steo     ? c_steo     : na, title="EIA STEO Day")
bgcolor(is_sep      ? c_sep      : na, title="EIA State Energy Portal Day")
bgcolor(is_epm      ? c_epm      : na, title="Electric Power Monthly Day")
bgcolor(is_emu      ? c_emu      : na, title="Electricity Monthly Update Day")
bgcolor(is_mer      ? c_mer      : na, title="Monthly Energy Review Day")
bgcolor(is_cli      ? c_cli      : na, title="Company Level Imports Day")
bgcolor(is_ngm      ? c_ngm      : na, title="Natural Gas Monthly Day")
bgcolor(is_psm      ? c_psm      : na, title="Petroleum Supply Monthly Day")

// Release-hour overlay — vivid
bgcolor((is_ism_any or is_jolts) and window_1000 ? color.new(color.white, 65) : na, title="ISM/JOLTS 10AM Window")
bgcolor(is_steo      and window_1200 ? color.new(color.white, 65) : na, title="EIA STEO 12PM Window")
bgcolor(is_sep       and window_1500 ? color.new(color.white, 65) : na, title="EIA SEP 3PM Window")
bgcolor((is_cli or is_ngm or is_psm) and window_1500 ? color.new(color.white, 65) : na, title="EIA 3PM Window")
bgcolor((is_epm or is_emu or is_mer) and window_1600 ? color.new(color.white, 65) : na, title="EIA 4PM Window")
bgcolor(is_adp      and window_815  ? color.new(color.white, 65) : na, title="ADP 8:15AM Window")
bgcolor(is_bls_any  and window_830  ? color.new(color.white, 65) : na, title="BLS 8:30AM Window")

// ─── DAY-START LABEL — lists all indicators releasing today ──────────────────
if new_day and is_any
    string txt = ""
    if is_ism_mfg
        txt := txt + "● ISM Mfg PMI®  10:00 AM\n"
    if is_ism_svc
        txt := txt + "● ISM Svc PMI®  10:00 AM\n"
    if is_ism_scpf
        txt := txt + "● ISM Supply Chain Forecast  10:00 AM\n"
    if is_cpi
        txt := txt + "● CPI  8:30 AM\n"
    if is_ppi
        txt := txt + "● PPI  8:30 AM\n"
    if is_nfp
        txt := txt + "● NFP Employment  8:30 AM\n"
    if is_impexp
        txt := txt + "● Import/Export Price  8:30 AM\n"
    if is_prod
        txt := txt + "● Productivity & Costs  8:30 AM\n"
    if is_adp
        txt := txt + "● ADP Employment  8:15 AM\n"
    if is_jolts
        txt := txt + "● JOLTS Job Openings  10:00 AM\n"
    if is_trade
        txt := txt + "● FT900 Intl Trade  8:30 AM\n"
    if is_steo
        txt := txt + "● EIA STEO  12:00 PM\n"
    if is_sep
        txt := txt + "● EIA State Energy Portal  3:00 PM\n"
    if is_epm
        txt := txt + "● EIA Electric Power Monthly  4:00 PM\n"
    if is_emu
        txt := txt + "● EIA Electricity Monthly Update  4:00 PM\n"
    if is_mer
        txt := txt + "● EIA Monthly Energy Review  4:00 PM\n"
    if is_cli
        txt := txt + "● EIA Company Level Imports  3:00 PM\n"
    if is_ngm
        txt := txt + "● EIA Natural Gas Monthly  3:00 PM\n"
    if is_psm
        txt := txt + "● EIA Petroleum Supply Monthly  3:00 PM\n"
    color lbl_c = is_ism_mfg ? c_ism_mfg : is_ism_svc ? c_ism_svc :
                  is_ism_scpf ? c_ism_scpf : is_cpi ? c_cpi : is_ppi ? c_ppi :
                  is_nfp ? c_nfp : is_impexp ? c_impexp : is_prod ? c_prod :
                  is_adp ? c_adp : is_jolts ? c_jolts : is_trade ? c_trade :
                  is_steo ? c_steo : is_sep ? c_sep : is_epm ? c_epm : c_ngm
    label.new(bar_index, high, str.trim(txt),
              style    = label.style_label_down,
              color    = color.new(lbl_c, 10),
              textcolor= color.white,
              size     = size.small)

// ─── RELEASE-TIME LABELS — var, one per indicator ────────────────────────────
var label lbl_rt_ism_mfg  = na
var label lbl_rt_ism_svc  = na
var label lbl_rt_ism_scpf = na
var label lbl_rt_cpi      = na
var label lbl_rt_ppi      = na
var label lbl_rt_nfp      = na
var label lbl_rt_impexp   = na
var label lbl_rt_prod     = na
var label lbl_rt_adp      = na
var label lbl_rt_jolts    = na
var label lbl_rt_trade    = na
var label lbl_rt_steo     = na
var label lbl_rt_eia_3pm  = na
var label lbl_rt_eia_4pm  = na

if at_1000 and is_ism_mfg
    if not na(lbl_rt_ism_mfg)
        label.delete(lbl_rt_ism_mfg)
    lbl_rt_ism_mfg := label.new(bar_index, high, "ISM MFG PMI®\n10:00 AM ET",
                                  style=label.style_label_down,
                                  color=color.new(c_ism_mfg, 10),
                                  textcolor=color.white, size=size.small)

if at_1000 and is_ism_svc
    if not na(lbl_rt_ism_svc)
        label.delete(lbl_rt_ism_svc)
    lbl_rt_ism_svc := label.new(bar_index, high, "ISM SVC PMI®\n10:00 AM ET",
                                  style=label.style_label_down,
                                  color=color.new(c_ism_svc, 10),
                                  textcolor=color.white, size=size.small)

if at_1000 and is_ism_scpf
    if not na(lbl_rt_ism_scpf)
        label.delete(lbl_rt_ism_scpf)
    lbl_rt_ism_scpf := label.new(bar_index, high, "ISM Supply Chain\nForecast  10:00 AM ET",
                                   style=label.style_label_down,
                                   color=color.new(c_ism_scpf, 10),
                                   textcolor=color.white, size=size.small)

if at_830 and is_cpi
    if not na(lbl_rt_cpi)
        label.delete(lbl_rt_cpi)
    lbl_rt_cpi := label.new(bar_index, high, "CPI\n8:30 AM ET",
                              style=label.style_label_down,
                              color=color.new(c_cpi, 10),
                              textcolor=color.white, size=size.small)

if at_830 and is_ppi
    if not na(lbl_rt_ppi)
        label.delete(lbl_rt_ppi)
    lbl_rt_ppi := label.new(bar_index, high, "PPI\n8:30 AM ET",
                              style=label.style_label_down,
                              color=color.new(c_ppi, 10),
                              textcolor=color.white, size=size.small)

if at_830 and is_nfp
    if not na(lbl_rt_nfp)
        label.delete(lbl_rt_nfp)
    lbl_rt_nfp := label.new(bar_index, high, "NFP Employment\n8:30 AM ET",
                              style=label.style_label_down,
                              color=color.new(c_nfp, 10),
                              textcolor=color.white, size=size.small)

if at_830 and is_impexp
    if not na(lbl_rt_impexp)
        label.delete(lbl_rt_impexp)
    lbl_rt_impexp := label.new(bar_index, high, "Import/Export Price\n8:30 AM ET",
                                 style=label.style_label_down,
                                 color=color.new(c_impexp, 10),
                                 textcolor=color.white, size=size.small)

if at_830 and is_prod
    if not na(lbl_rt_prod)
        label.delete(lbl_rt_prod)
    lbl_rt_prod := label.new(bar_index, high, "Productivity & Costs\n8:30 AM ET",
                               style=label.style_label_down,
                               color=color.new(c_prod, 10),
                               textcolor=color.white, size=size.small)

if at_815 and is_adp
    if not na(lbl_rt_adp)
        label.delete(lbl_rt_adp)
    lbl_rt_adp := label.new(bar_index, high, "ADP Employment\n8:15 AM ET",
                              style=label.style_label_down,
                              color=color.new(c_adp, 10),
                              textcolor=color.white, size=size.small)

if at_1000 and is_jolts
    if not na(lbl_rt_jolts)
        label.delete(lbl_rt_jolts)
    lbl_rt_jolts := label.new(bar_index, high, "JOLTS Job Openings\n10:00 AM ET",
                                style=label.style_label_down,
                                color=color.new(c_jolts, 10),
                                textcolor=color.white, size=size.small)

if at_830 and is_trade
    if not na(lbl_rt_trade)
        label.delete(lbl_rt_trade)
    lbl_rt_trade := label.new(bar_index, high, "FT900 Intl Trade\n8:30 AM ET",
                                style=label.style_label_down,
                                color=color.new(c_trade, 10),
                                textcolor=color.white, size=size.small)

if at_1200 and is_steo
    if not na(lbl_rt_steo)
        label.delete(lbl_rt_steo)
    lbl_rt_steo := label.new(bar_index, high, "EIA STEO\n12:00 PM ET",
                               style=label.style_label_down,
                               color=color.new(c_steo, 10),
                               textcolor=color.white, size=size.small)

if at_1500 and (is_sep or is_cli or is_ngm or is_psm)
    if not na(lbl_rt_eia_3pm)
        label.delete(lbl_rt_eia_3pm)
    string etxt = ""
    if is_sep
        etxt := etxt + "State Energy Portal\n"
    if is_cli
        etxt := etxt + "Company Level Imports\n"
    if is_ngm
        etxt := etxt + "Natural Gas Monthly\n"
    if is_psm
        etxt := etxt + "Petroleum Supply Monthly\n"
    lbl_rt_eia_3pm := label.new(bar_index, high,
                                  str.trim(etxt) + "\n3:00 PM ET",
                                  style=label.style_label_down,
                                  color=color.new(c_ngm, 10),
                                  textcolor=color.white, size=size.small)

if at_1600 and (is_epm or is_emu or is_mer)
    if not na(lbl_rt_eia_4pm)
        label.delete(lbl_rt_eia_4pm)
    string ftxt = ""
    if is_epm
        ftxt := ftxt + "Electric Power Monthly\n"
    if is_emu
        ftxt := ftxt + "Electricity Monthly Update\n"
    if is_mer
        ftxt := ftxt + "Monthly Energy Review\n"
    lbl_rt_eia_4pm := label.new(bar_index, high,
                                  str.trim(ftxt) + "\n4:00 PM ET",
                                  style=label.style_label_down,
                                  color=color.new(c_epm, 10),
                                  textcolor=color.white, size=size.small)

// ─── ALERTS ──────────────────────────────────────────────────────────────────
alertcondition(is_ism_mfg  and at_1000, title="ISM Manufacturing PMI® — 10 AM",
               message="ISM Manufacturing PMI® releasing now at 10:00 AM ET on {{ticker}}.")
alertcondition(is_ism_svc  and at_1000, title="ISM Services PMI® — 10 AM",
               message="ISM Services PMI® releasing now at 10:00 AM ET on {{ticker}}.")
alertcondition(is_cpi      and at_830,  title="CPI — 8:30 AM",
               message="Consumer Price Index releasing now at 8:30 AM ET on {{ticker}}.")
alertcondition(is_ppi      and at_830,  title="PPI — 8:30 AM",
               message="Producer Price Index releasing now at 8:30 AM ET on {{ticker}}.")
alertcondition(is_nfp      and at_830,  title="NFP Employment — 8:30 AM",
               message="Employment Situation (NFP) releasing now at 8:30 AM ET on {{ticker}}.")
alertcondition(is_bls_any  and at_830,  title="BLS Report — 8:30 AM",
               message="BLS macroeconomic report releasing now at 8:30 AM ET on {{ticker}}.")
alertcondition(is_adp   and at_815,  title="ADP Employment — 8:15 AM",
               message="ADP National Employment Report releasing now at 8:15 AM ET on {{ticker}}.")
alertcondition(is_jolts and at_1000, title="JOLTS Job Openings — 10:00 AM",
               message="JOLTS Job Openings releasing now at 10:00 AM ET on {{ticker}}.")
alertcondition(is_trade and at_830,  title="FT900 International Trade — 8:30 AM",
               message="FT900 U.S. International Trade releasing now at 8:30 AM ET on {{ticker}}.")
alertcondition(is_steo and at_1200, title="EIA STEO — 12:00 PM",
               message="EIA Short-Term Energy Outlook releasing now at 12:00 PM ET on {{ticker}}.")
alertcondition((is_sep or is_cli or is_ngm or is_psm) and at_1500,
               title="EIA 3PM Report",
               message="EIA 3:00 PM report releasing now on {{ticker}}.")
alertcondition((is_epm or is_emu or is_mer) and at_1600,
               title="EIA 4PM Report",
               message="EIA 4:00 PM report releasing now on {{ticker}}.")
alertcondition(is_any      and new_day, title="Macro Report Day Open",
               message="Macroeconomic report scheduled today on {{ticker}}. Check label for details.")
````
