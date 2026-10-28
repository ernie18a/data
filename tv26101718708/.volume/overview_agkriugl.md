# Overview

- url: https://www.tradingview.com/script/aGKrIuGL-Overview/
- type: indicator
- pine_id: PUB;83bc13ca2ba24cc983982760608cd54a
- version: 1.0

## Description

sauce straight sauce do not try at home overnight data provides. the best sauce in sauce town

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
//@version=6

indicator("Overview", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_bars_back=5000, calc_bars_count=20000)

// ═════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ═════════════════════════════════════════════════════════════════════════════

lineStyleFromString(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

labelSizeFromString(s) =>
    s == "tiny" ? size.tiny : s == "large" ? size.large : s == "normal" ? size.normal : size.small

_tip(float p) => str.tostring(p, format.mintick)

// ═════════════════════════════════════════════════════════════════════════════
//  GLOBAL SETTINGS
// ═════════════════════════════════════════════════════════════════════════════

grpGlobal = "Global Settings"

gsKeyLevels  = input.bool(true,  "Key Levels",           group=grpGlobal)
gsOpens      = input.bool(true,  "Opens",                group=grpGlobal)
gsPreMkt     = input.bool(false, "Overnight High/Low",   group=grpGlobal)
gsVWAP       = input.bool(true,  "VWAP",                 group=grpGlobal)
gsIB         = input.bool(true,  "Initial Balance",      group=grpGlobal)
gsSessions   = input.bool(false, "Sessions",             group=grpGlobal)
gsONFib      = input.bool(false, "Overnight Fib",        group=grpGlobal)
gsHistorical = input.bool(false, "Historical Levels",    group=grpGlobal)
gsVP         = input.bool(false, "Volume Profile",       group=grpGlobal)
gsSMT        = input.bool(false, "SMT Divergences",      group=grpGlobal)
gsFVG        = input.bool(false, "Fair Value Gaps",      group=grpGlobal)

gLineWidth = input.int(1,          "Line Width", minval=1, maxval=5,                        group=grpGlobal, inline="gStyle")
gTextSize  = input.string("small", "Text",       options=["tiny","small","normal","large"],  group=grpGlobal, inline="gStyle")
gLineStyle = input.string("Solid", "Style",      options=["Solid","Dashed","Dotted"],        group=grpGlobal, inline="gStyle")

_gLblSz = labelSizeFromString(gTextSize)
_gLnSt  = lineStyleFromString(gLineStyle)

// ═════════════════════════════════════════════════════════════════════════════
//  KEY LEVELS
// ═════════════════════════════════════════════════════════════════════════════

grpKey = "Key Levels"

showPDH   = input.bool(true,  "PDH",     group=grpKey, inline="pdh")
pdhColor  = input.color(color.new(#000000,0), "", group=grpKey, inline="pdh")
showPDL   = input.bool(true,  "PDL",     group=grpKey, inline="pdl")
pdlColor  = input.color(color.new(#000000,0), "", group=grpKey, inline="pdl")
showPDEQ  = input.bool(true,  "PD EQ",   group=grpKey, inline="pdeq")
pdeqColor = input.color(color.new(#000000,0), "", group=grpKey, inline="pdeq")
showPWH   = input.bool(false, "PWH",     group=grpKey, inline="pwh")
pwhColor  = input.color(color.new(#000000,0), "", group=grpKey, inline="pwh")
showPWL   = input.bool(false, "PWL",     group=grpKey, inline="pwl")
pwlColor  = input.color(color.new(#000000,0), "", group=grpKey, inline="pwl")
showPMH   = input.bool(false, "PM High", group=grpKey, inline="pmh")
pmhColor  = input.color(color.new(#000000,0), "", group=grpKey, inline="pmh")
showPML   = input.bool(false, "PM Low",  group=grpKey, inline="pml")
pmlColor  = input.color(color.new(#000000,0), "", group=grpKey, inline="pml")

// ═════════════════════════════════════════════════════════════════════════════
//  OPENS
// ═════════════════════════════════════════════════════════════════════════════

grpOpens = "Opens"

showDO    = input.bool(true,  "Daily",    group=grpOpens, inline="do")
doColor   = input.color(color.new(#2962FF,0), "", group=grpOpens, inline="do")
showWO    = input.bool(true,  "Weekly",   group=grpOpens, inline="wo")
woColor   = input.color(color.new(#2962FF,0), "", group=grpOpens, inline="wo")
showMO    = input.bool(false, "Monthly",  group=grpOpens, inline="mo")
moColor   = input.color(color.new(#2962FF,0), "", group=grpOpens, inline="mo")
showYO    = input.bool(false, "Yearly",   group=grpOpens, inline="yo")
yoColor   = input.color(color.new(#2962FF,0), "", group=grpOpens, inline="yo")
showMidO  = input.bool(true,  "Midnight", group=grpOpens, inline="mido")
midoColor = input.color(color.new(#2962FF,0), "", group=grpOpens, inline="mido")
showNYO   = input.bool(true,  "NY Open",  group=grpOpens, inline="nyo")
nyoColor  = input.color(color.new(#2962FF,0), "", group=grpOpens, inline="nyo")

opensLineStyle = input.string("Dashed", "Style", options=["Solid","Dashed","Dotted"], group=grpOpens, inline="opensStyle")

// ═════════════════════════════════════════════════════════════════════════════
//  PRE MARKET LEVELS
// ═════════════════════════════════════════════════════════════════════════════

grpPreMkt = "Overnight High/Low"

showONH     = input.bool(false, "ONH",  group=grpPreMkt, inline="onh")
onhColor    = input.color(color.new(#FF6B35, 0), "", group=grpPreMkt, inline="onh")
showONL     = input.bool(false, "ONL",  group=grpPreMkt, inline="onl")
onlColor    = input.color(color.new(#FF6B35, 0), "", group=grpPreMkt, inline="onl")
preMktStyle = input.string("Solid", "Style", options=["Solid","Dashed","Dotted"], group=grpPreMkt, inline="pmStyle")

// ═════════════════════════════════════════════════════════════════════════════
//  INITIAL BALANCE
// ═════════════════════════════════════════════════════════════════════════════

grpIB = "Initial Balance"

showIB          = input.bool(true,  "H/L",        group=grpIB, inline="ibShow")
showIBFill      = input.bool(true,  "Fill",        group=grpIB, inline="ibShow")
showIBEQ        = input.bool(false, "EQ",          group=grpIB, inline="ibShow")
ibExtendBars    = input.int(150,    "Ext Bars",    minval=1, maxval=500, group=grpIB, inline="ibShow")
ibKeepToday     = input.bool(false, "Today Only",  group=grpIB, inline="ibShow")

ibColor      = input.color(color.new(#2E2E2E, 35), "Lines", group=grpIB, inline="ibc")
ibLineStyle  = input.string("Solid", "H/L Style",  options=["Solid","Dashed","Dotted"], group=grpIB, inline="ibc")
ibEQColor    = input.color(color.new(#FFFFFF, 50),  "EQ",    group=grpIB, inline="ibc")
ibFillColor  = input.color(color.new(#555555, 40),  "Fill",  group=grpIB, inline="ibc")
ibTextColor  = input.color(color.new(#000000, 0),   "Text",  group=grpIB, inline="ibc")

// ═════════════════════════════════════════════════════════════════════════════
//  SESSIONS
// ═════════════════════════════════════════════════════════════════════════════

grpSessions = "Sessions"

showAsia      = input.bool(true, "Asia",     group=grpSessions, inline="asT")
asiaHighColor = input.color(color.new(#B22833,0),  "H", group=grpSessions, inline="asT")
asiaLowColor  = input.color(color.new(#B22833,0),  "L", group=grpSessions, inline="asT")
asiaFillColor = input.color(color.new(#F23645,85), "F", group=grpSessions, inline="asT")

showLondon   = input.bool(true, "London",    group=grpSessions, inline="lonT")
lonHighColor = input.color(color.new(#1848CC,0),  "H", group=grpSessions, inline="lonT")
lonLowColor  = input.color(color.new(#1848CC,0),  "L", group=grpSessions, inline="lonT")
lonFillColor = input.color(color.new(#2962FF,85), "F", group=grpSessions, inline="lonT")

showNYSess  = input.bool(true, "New York",   group=grpSessions, inline="nyT")
nyHighColor = input.color(color.new(#FFE86C,0),  "H", group=grpSessions, inline="nyT")
nyLowColor  = input.color(color.new(#FFE86C,0),  "L", group=grpSessions, inline="nyT")
nyFillColor = input.color(color.new(#FFD700,88), "F", group=grpSessions, inline="nyT")

// ═════════════════════════════════════════════════════════════════════════════
//  HISTORICAL LEVELS
// ═════════════════════════════════════════════════════════════════════════════

grpHist = "Historical Levels"

showHistIB   = input.bool(true, "IB",     group=grpHist, inline="histRow")
showHistAsia = input.bool(true, "Asia",   group=grpHist, inline="histRow")
showHistLon  = input.bool(true, "London", group=grpHist, inline="histRow")
showHistNY   = input.bool(true, "NY",     group=grpHist, inline="histRow")
histLookback = input.int(5,  "Lookback Days", minval=1, maxval=20,  group=grpHist, inline="histOpts")
histTransp   = input.int(80, "Opacity %",     minval=0, maxval=100, group=grpHist, inline="histOpts")

// ═════════════════════════════════════════════════════════════════════════════
//  OVERNIGHT FIB
// ═════════════════════════════════════════════════════════════════════════════

grpONFib = "Overnight Fib"

showONFib    = input.bool(true,  "Show",      group=grpONFib, inline="onfs")
onFibColor   = input.color(color.new(#4A4A4A,0), "", group=grpONFib, inline="onfs")
onFibExtend  = input.bool(false, "Extend R",  group=grpONFib, inline="onfs")
onFibBarLen  = input.int(60, "Len", minval=1, maxval=500, group=grpONFib, inline="onfs")

showFib0236  = input.bool(true, "0.236",  group=grpONFib, inline="fLvls")
showFib066   = input.bool(true, "0.66",   group=grpONFib, inline="fLvls")
showFib0618  = input.bool(true, "0.618",  group=grpONFib, inline="fLvls")
showFib0786  = input.bool(true, "0.786",  group=grpONFib, inline="fLvls")
showFibN0236 = input.bool(true, "-0.236", group=grpONFib, inline="fLvls")
showFibN0786 = input.bool(true, "-0.786", group=grpONFib, inline="fLvls")

showHistONFib     = input.bool(true, "Historical",           group=grpONFib, inline="hfib")
histONFibColor    = input.color(color.new(#000000,75), "",   group=grpONFib, inline="hfib")
histONFibLookback = input.int(3,  "Days",    minval=1, maxval=10,  group=grpONFib, inline="hfib")
histONFibTransp   = input.int(75, "Opacity", minval=0, maxval=100, group=grpONFib, inline="hfib")

// ═════════════════════════════════════════════════════════════════════════════
//  VWAP
// ═════════════════════════════════════════════════════════════════════════════

grpVWAP = "VWAP"

showDailyVWAP        = input.bool(true,  "Daily",      group=grpVWAP, inline="vD")
vwapDailyColor       = input.color(color.new(#FFFFFF,0),  "Line",    group=grpVWAP, inline="vD")
vwapDailyLabelColor  = input.color(color.new(#FFFFFF,0),  "Label",   group=grpVWAP, inline="vD")
vwapDailyOutline     = input.color(color.new(#FFFFFF,70), "Outline", group=grpVWAP, inline="vD")

showWeeklyVWAP       = input.bool(true,  "Weekly",     group=grpVWAP, inline="vW")
vwapWeeklyColor      = input.color(color.new(#2962FF,0),  "Line",    group=grpVWAP, inline="vW")
vwapWeeklyLabelColor = input.color(color.new(#FFFFFF,0),  "Label",   group=grpVWAP, inline="vW")
vwapWeeklyOutline    = input.color(color.new(#FFFFFF,70), "Outline", group=grpVWAP, inline="vW")

showMonthlyVWAP       = input.bool(false, "Monthly",   group=grpVWAP, inline="vM")
vwapMonthlyColor      = input.color(color.new(#4CAF50,0),  "Line",   group=grpVWAP, inline="vM")
vwapMonthlyLabelColor = input.color(color.new(#FFFFFF,0),  "Label",  group=grpVWAP, inline="vM")
vwapMonthlyOutline    = input.color(color.new(#FFFFFF,70), "Outline",group=grpVWAP, inline="vM")

showYearlyVWAP       = input.bool(false, "Yearly",     group=grpVWAP, inline="vY")
vwapYearlyColor      = input.color(color.new(#FFD700,0),  "Line",    group=grpVWAP, inline="vY")
vwapYearlyLabelColor = input.color(color.new(#FFFFFF,0),  "Label",   group=grpVWAP, inline="vY")
vwapYearlyOutline    = input.color(color.new(#FFFFFF,70), "Outline", group=grpVWAP, inline="vY")

showNYSessVWAP       = input.bool(true,  "NY Session", group=grpVWAP, inline="vNY")
vwapNYSessColor      = input.color(color.new(#00BCD4,0),  "Line",    group=grpVWAP, inline="vNY")
vwapNYSessLabelColor = input.color(color.new(#FFFFFF,0),  "Label",   group=grpVWAP, inline="vNY")
vwapNYSessOutline    = input.color(color.new(#FFFFFF,70), "Outline", group=grpVWAP, inline="vNY")

// ═════════════════════════════════════════════════════════════════════════════
//  VOLUME PROFILE
// ═════════════════════════════════════════════════════════════════════════════

grpVP = "Volume Profile"

showDailyVP    = input.bool(true, "Daily VP",  group=grpVP, inline="vpD")
vpRows         = input.int(148,   "Rows",      minval=1, maxval=400, group=grpVP, inline="vpD")
vpWidthPct     = input.int(30,    "Width %",   minval=1, maxval=100, group=grpVP, inline="vpD")
vpOutsideColor = input.color(color.new(#FFFFFF,94), "Outside", group=grpVP, inline="vpColors")
vpInsideColor  = input.color(color.new(#FFFFFF,80), "Inside",  group=grpVP, inline="vpColors")
showVPPOC      = input.bool(true,  "POC",      group=grpVP, inline="vpColors")
vpPOCColor     = input.color(color.new(#FF0000,0),  "",       group=grpVP, inline="vpColors")
showVPVAHL     = input.bool(false, "VAH/VAL",  group=grpVP, inline="vpColors")
vpVAHLColor    = input.color(color.new(#FFFFFF,0),  "",       group=grpVP, inline="vpColors")

showNYVP      = input.bool(true, "NY VP",      group=grpVP, inline="nyvpD")
nyVPRows      = input.int(148,   "Rows",       minval=1, maxval=400, group=grpVP, inline="nyvpD")
nyVPWidthPct  = input.int(30,    "Width %",    minval=1, maxval=100, group=grpVP, inline="nyvpD")
nyVPOutsideC  = input.color(color.new(#FFFFFF,94), "Outside", group=grpVP, inline="nyvpColors")
nyVPInsideC   = input.color(color.new(#FFFFFF,80), "Inside",  group=grpVP, inline="nyvpColors")
showNYVPPOC   = input.bool(true,  "POC",       group=grpVP, inline="nyvpColors")
nyVPPOCColor  = input.color(color.new(#FF0000,0),  "",       group=grpVP, inline="nyvpColors")
showNYVPVAHL  = input.bool(false, "VAH/VAL",   group=grpVP, inline="nyvpColors")
nyVPVAHLColor = input.color(color.new(#FFFFFF,0),  "",       group=grpVP, inline="nyvpColors")

// ═════════════════════════════════════════════════════════════════════════════
//  SMT DIVERGENCES
// ═════════════════════════════════════════════════════════════════════════════

grpSMT = "SMT Divergences"

showSMT        = input.bool(true,     "Show",           group=grpSMT, inline="smtShow")
smtCompSym     = input.symbol("ES1!", "Symbol",         group=grpSMT, inline="smtShow")
smtEnableAdj   = input.bool(false, "Adj Wicks",         group=grpSMT, inline="smtOpts")
smtEnablePivot = input.bool(true,  "Pivots",            group=grpSMT, inline="smtOpts")
smtLength      = input.int(5, "Primary",   minval=2, maxval=50, group=grpSMT, inline="smtLen")
smtLengthLarge = input.int(8, "Secondary", minval=2, maxval=50, group=grpSMT, inline="smtLen")
smtLengthSmall = input.int(3, "Tertiary",  minval=2, maxval=50, group=grpSMT, inline="smtLen")
smtLineColor   = input.color(color.new(#9C27B0,0), "Line", group=grpSMT, inline="smtC")
smtTextColor   = input.color(color.new(#000000,0), "Text", group=grpSMT, inline="smtC")

// ═════════════════════════════════════════════════════════════════════════════
//  FAIR VALUE GAPS
// ═════════════════════════════════════════════════════════════════════════════

grpFVG = "Fair Value Gaps"

showFVG      = input.bool(true,  "Show",           group=grpFVG, inline="fvgMain")
fvgMitigate  = input.bool(true,  "Auto-Mitigate",  group=grpFVG, inline="fvgMain")
showFVGEQ    = input.bool(false, "Show EQ",        group=grpFVG, inline="fvgMain")
fvgMaxBoxes  = input.int(10,  "Max",      minval=1,  maxval=100,  group=grpFVG, inline="fvgMain")
fvgLookback  = input.int(500, "Lookback", minval=10, maxval=5000, group=grpFVG, inline="fvgMain")
fvgBoxLen    = input.int(20,  "Box Len",  minval=1,  maxval=500,  group=grpFVG, inline="fvgMain")
fvgBullColor = input.color(color.new(#00E676,90), "Bull", group=grpFVG, inline="fvgC")
fvgBearColor = input.color(color.new(#F23645,90), "Bear", group=grpFVG, inline="fvgC")
fvgEQColor   = input.color(color.new(#FFFFFF,50), "EQ",   group=grpFVG, inline="fvgC")

// ═════════════════════════════════════════════════════════════════════════════
//  EFFECTIVE BOOLEANS
// ═════════════════════════════════════════════════════════════════════════════

bool _tf1h  = timeframe.in_seconds() <= 3600

_ibLnSt     = lineStyleFromString(ibLineStyle)
_opensLnSt  = lineStyleFromString(opensLineStyle)
_preMktLnSt = lineStyleFromString(preMktStyle)

bool showPDH_  = showPDH  and gsKeyLevels
bool showPDL_  = showPDL  and gsKeyLevels
bool showPDEQ_ = showPDEQ and gsKeyLevels
bool showPMH_  = showPMH  and gsKeyLevels
bool showPML_  = showPML  and gsKeyLevels
bool showPWH_  = showPWH  and gsKeyLevels
bool showPWL_  = showPWL  and gsKeyLevels

bool showDO_   = showDO   and gsOpens
bool showWO_   = showWO   and gsOpens
bool showMO_   = showMO   and gsOpens
bool showYO_   = showYO   and gsOpens
bool showMidO_ = showMidO and gsOpens
bool showNYO_  = showNYO  and gsOpens

bool showONH_  = showONH  and gsPreMkt
bool showONL_  = showONL  and gsPreMkt

bool showDailyVWAP_   = showDailyVWAP   and gsVWAP
bool showWeeklyVWAP_  = showWeeklyVWAP  and gsVWAP
bool showMonthlyVWAP_ = showMonthlyVWAP and gsVWAP
bool showYearlyVWAP_  = showYearlyVWAP  and gsVWAP
bool showNYSessVWAP_  = showNYSessVWAP  and gsVWAP

bool showIB_     = showIB     and gsIB
bool showIBEQ_   = showIBEQ   and gsIB
bool showIBFill_ = showIBFill and gsIB

bool showAsia_   = showAsia   and gsSessions and _tf1h
bool showLondon_ = showLondon and gsSessions and _tf1h
bool showNYSess_ = showNYSess and gsSessions and _tf1h

bool showHistIB_   = showHistIB   and gsHistorical and gsIB
bool showHistAsia_ = showHistAsia and gsHistorical and gsSessions and _tf1h
bool showHistLon_  = showHistLon  and gsHistorical and gsSessions and _tf1h
bool showHistNY_   = showHistNY   and gsHistorical and gsSessions and _tf1h

bool showDailyVP_ = showDailyVP and gsVP
bool showNYVP_    = showNYVP    and gsVP
bool showSMT_     = showSMT     and gsSMT

bool showONFib_     = showONFib     and gsONFib
bool showHistONFib_ = showHistONFib and gsONFib

bool showFVG_   = showFVG   and gsFVG
bool showFVGEQ_ = showFVGEQ and gsFVG

// ═════════════════════════════════════════════════════════════════════════════
//  LABEL SIZE HELPERS
//  _gLblSz      = global size (used by stack labels, VWAP, SMT, FVG, ONFib)
//  _sessLblSz   = session / IB active labels (one step larger than global)
//  _opensLblSz  = opens / key-level stack labels (one step smaller than global)
// ═════════════════════════════════════════════════════════════════════════════

// Session & IB labels: bump up one step from the global setting
_sessLblSz = gTextSize == "tiny"   ? size.small  :
             gTextSize == "small"  ? size.normal :
             gTextSize == "normal" ? size.large  : size.large

// Opens & Key-level stack labels: drop down one step from the global setting
_opensLblSz = gTextSize == "large"  ? size.normal :
              gTextSize == "normal" ? size.small  :
              gTextSize == "small"  ? size.tiny   : size.tiny

// ═════════════════════════════════════════════════════════════════════════════
//  TIME HELPERS
// ═════════════════════════════════════════════════════════════════════════════

TZ          = "America/New_York"
nyHour      = hour(time,      TZ)
nyMinute    = minute(time,    TZ)
nyMonth     = month(time,     TZ)
nyDayOfWeek = dayofweek(time, TZ)

isNewWeek  = nyHour == 18 and nyMinute == 0 and nyDayOfWeek == dayofweek.sunday
isNewMonth = nyMonth != nyMonth[1]
isNewYear  = nyMonth == 1 and nyMonth[1] == 12

var bool _dailyOpenFired   = false
var bool _weeklyOpenFired  = false
var bool _monthlyOpenFired = false
var bool _yearlyOpenFired  = false
var bool _midnightFired    = false
var bool _nyOpenFired      = false
var bool _ibStartFired     = false
var bool _ibEndFired       = false
var bool _asiaStartFired   = false
var bool _lonStartFired    = false
var bool _nySessStartFired = false
var bool _nySessEndFired   = false

_atDailyOpen  = nyHour == 18 and nyMinute == 0
_atWeeklyOpen = _atDailyOpen and nyDayOfWeek == dayofweek.sunday
_atMidnight   = nyHour == 0  and nyMinute == 0
_atNYOpen     = nyHour == 9  and nyMinute == 30
_atIBEnd      = nyHour == 10 and nyMinute == 30
_atAsiaStart  = nyHour == 20 and nyMinute == 0
_atLonStart   = nyHour == 2  and nyMinute == 0
_atNYSessEnd  = nyHour == 16 and nyMinute == 0
isNYSessWin   = (nyHour == 9 and nyMinute >= 30) or (nyHour >= 10 and nyHour < 16)

if not _atDailyOpen
    _dailyOpenFired   := false
if not _atWeeklyOpen
    _weeklyOpenFired  := false
if not isNewMonth
    _monthlyOpenFired := false
if not isNewYear
    _yearlyOpenFired  := false
if not _atMidnight
    _midnightFired    := false
if not _atNYOpen
    _nyOpenFired      := false
    _ibStartFired     := false
    _nySessStartFired := false
if not _atIBEnd
    _ibEndFired       := false
if not _atAsiaStart
    _asiaStartFired   := false
if not _atLonStart
    _lonStartFired    := false
if not _atNYSessEnd
    _nySessEndFired   := false

isDailyOpen    = _atDailyOpen  and not _dailyOpenFired
isWeeklyOpen   = _atWeeklyOpen and not _weeklyOpenFired
isMonthlyOpen  = isNewMonth    and not _monthlyOpenFired
isYearlyOpen   = isNewYear     and not _yearlyOpenFired
isMidnightOpen = _atMidnight   and not _midnightFired
isNYOpen       = _atNYOpen     and not _nyOpenFired
isIBStart      = _atNYOpen     and not _ibStartFired
isIBEnd        = _atIBEnd      and not _ibEndFired
isAsiaStart    = _atAsiaStart  and not _asiaStartFired
isLonStart     = _atLonStart   and not _lonStartFired
isNYSessStart  = _atNYOpen     and not _nySessStartFired
isNYSessEnd    = (not isNYSessWin) and isNYSessWin[1]

if isDailyOpen
    _dailyOpenFired   := true
if isWeeklyOpen
    _weeklyOpenFired  := true
if isMonthlyOpen
    _monthlyOpenFired := true
if isYearlyOpen
    _yearlyOpenFired  := true
if isMidnightOpen
    _midnightFired    := true
if isNYOpen
    _nyOpenFired      := true
if isIBStart
    _ibStartFired     := true
if isIBEnd
    _ibEndFired       := true
if isAsiaStart
    _asiaStartFired   := true
if isLonStart
    _lonStartFired    := true
if isNYSessStart
    _nySessStartFired := true
if isNYSessEnd
    _nySessEndFired   := true

isIBWindow   = (nyHour == 9 and nyMinute >= 30) or (nyHour == 10 and nyMinute <= 29)
isAsiaWindow = nyHour >= 20
isAsiaEnd    = not isAsiaWindow and isAsiaWindow[1]
isLonWindow  = nyHour >= 2 and nyHour < 5
isLonEnd     = not isLonWindow and isLonWindow[1]

int _tfMs     = timeframe.in_seconds() * 1000
int _lblNudge = math.min(_tfMs * 2, _tfMs * 20)

// ═════════════════════════════════════════════════════════════════════════════
//  LABEL STACK
// ═════════════════════════════════════════════════════════════════════════════

var float[]  _stackPx  = array.new_float(0)
var string[] _stackTxt = array.new_string(0)
var color[]  _stackCol = array.new_color(0)
var label[]  _stackLbl = array.new_label(0)
var float[]  _lblPx    = array.new_float(0)

_lblSlot(float p) =>
    float thresh = syminfo.mintick * 4
    int cnt = 0
    int sz  = array.size(_lblPx)
    if sz > 0
        for k = 0 to sz - 1
            if math.abs(array.get(_lblPx, k) - p) < thresh
                cnt += 1
    array.push(_lblPx, p)
    cnt

_stackAdd(float p, string txt, color col) =>
    float thresh = syminfo.mintick * 4
    int found = -1
    int sz    = array.size(_stackPx)
    if sz > 0
        for k = 0 to sz - 1
            if math.abs(array.get(_stackPx, k) - p) < thresh
                found := k
                break
    if found == -1
        array.push(_stackPx, p)
        array.push(_stackTxt, txt)
        array.push(_stackCol, col)
    else
        string old = array.get(_stackTxt, found)
        if not str.contains(old, txt)
            array.set(_stackTxt, found, old + " / " + txt)

_stackClear() =>
    for lb in _stackLbl
        label.delete(lb)
    array.clear(_stackLbl)
    array.clear(_stackPx)
    array.clear(_stackTxt)
    array.clear(_stackCol)
    array.clear(_lblPx)

_stackRender() =>
    int sz = array.size(_stackPx)
    if sz > 0
        for k = 0 to sz - 1
            float  p    = array.get(_stackPx,  k)
            string txt  = array.get(_stackTxt, k)
            color  col  = array.get(_stackCol, k)
            int    slot = _lblSlot(p)
            label lb = label.new(time + _lblNudge + slot * _tfMs * 4, p, txt,
                 xloc=xloc.bar_time, color=color.new(color.black,100), textcolor=col,
                 style=label.style_label_left, size=_gLblSz, tooltip=_tip(p))
            array.push(_stackLbl, lb)

if barstate.islast
    _stackClear()

// ═════════════════════════════════════════════════════════════════════════════
//  PDH / PDL / PD-EQ
// ═════════════════════════════════════════════════════════════════════════════

[_pdSecHigh, _pdSecLow, _pdSecPrevDayOpenTime, _pdSecCurDayOpenTime, _pdSecCurDayHigh, _pdSecCurDayLow] =
     request.security(syminfo.tickerid, "D", [high[1], low[1], time[1], time, high, low], lookahead=barmerge.lookahead_on)

var float prevDayHigh     = na
var float prevDayLow      = na
var int   prevDayOpenTime = na
var int   prevDayHighTime = na
var int   prevDayLowTime  = na
var float curDayHigh      = na
var float curDayLow       = na
var int   curDayHighTime  = na
var int   curDayLowTime   = na
var int   curDayStartTime = na

if na(prevDayHigh) and not na(_pdSecHigh)
    prevDayHigh := _pdSecHigh
if na(prevDayLow) and not na(_pdSecLow)
    prevDayLow := _pdSecLow
if na(prevDayOpenTime) and not na(_pdSecPrevDayOpenTime)
    prevDayOpenTime := _pdSecPrevDayOpenTime
if na(curDayStartTime) and not na(_pdSecCurDayOpenTime)
    curDayStartTime := _pdSecCurDayOpenTime
if na(curDayHigh) and not na(_pdSecCurDayHigh)
    curDayHigh := _pdSecCurDayHigh
if na(curDayLow) and not na(_pdSecCurDayLow)
    curDayLow := _pdSecCurDayLow
if na(curDayHighTime)
    curDayHighTime := curDayStartTime
if na(curDayLowTime)
    curDayLowTime := curDayStartTime

if isDailyOpen
    if not na(curDayHigh)
        prevDayHigh := curDayHigh
    if not na(curDayLow)
        prevDayLow := curDayLow
    if not na(curDayStartTime)
        prevDayOpenTime := curDayStartTime
    prevDayHighTime := curDayHighTime
    prevDayLowTime  := curDayLowTime
    curDayHigh      := high
    curDayLow       := low
    curDayHighTime  := time
    curDayLowTime   := time
    curDayStartTime := time
else
    if na(curDayHigh) or high > curDayHigh
        curDayHigh     := high
        curDayHighTime := time
    if na(curDayLow) or low < curDayLow
        curDayLow     := low
        curDayLowTime := time
    if na(curDayStartTime)
        curDayStartTime := time

var float pwl = na

var line  pdhLine  = na
var line  pdlLine  = na
var line  pdeqLine = na

if barstate.islast and not na(prevDayHigh)
    int _pdS   = not na(prevDayHighTime) ? prevDayHighTime : not na(prevDayOpenTime) ? prevDayOpenTime : time - 86400000
    int _pdlS  = not na(prevDayLowTime)  ? prevDayLowTime  : not na(prevDayOpenTime) ? prevDayOpenTime : time - 86400000
    int _pdeqS = not na(prevDayHighTime) and not na(prevDayLowTime) ? math.min(prevDayHighTime, prevDayLowTime) :
                 not na(prevDayHighTime) ? prevDayHighTime :
                 not na(prevDayLowTime)  ? prevDayLowTime  :
                 not na(prevDayOpenTime) ? prevDayOpenTime : time - 86400000

    if showPDH_
        line.delete(pdhLine)
        pdhLine := line.new(_pdS, prevDayHigh, time, prevDayHigh,
             xloc=xloc.bar_time, color=pdhColor, width=gLineWidth, style=_gLnSt)
        _stackAdd(prevDayHigh, "PDH", pdhColor)
    if showPDL_ and not na(prevDayLow)
        line.delete(pdlLine)
        pdlLine := line.new(_pdlS, prevDayLow, time, prevDayLow,
             xloc=xloc.bar_time, color=pdlColor, width=gLineWidth, style=_gLnSt)
        _stackAdd(prevDayLow, "PDL", pdlColor)
    if showPDEQ_ and not na(prevDayLow)
        float _eq = (prevDayHigh + prevDayLow) / 2
        line.delete(pdeqLine)
        pdeqLine := line.new(_pdeqS, _eq, time, _eq,
             xloc=xloc.bar_time, color=pdeqColor, width=gLineWidth, style=_gLnSt)
        _stackAdd(_eq, "PD-EQ", pdeqColor)

// ═════════════════════════════════════════════════════════════════════════════
//  PRE MARKET HIGH / LOW  (18:00 → 09:30 ET = Overnight / Globex session)
// ═════════════════════════════════════════════════════════════════════════════

// Window: 18:00 ET up to (but not including) 09:30 ET
isPreMktWindow = nyHour >= 18 or nyHour < 9 or (nyHour == 9 and nyMinute < 30)

var float onHigh      = na
var float onLow       = na
var int   onHighTime  = na
var int   onLowTime   = na
var int   onStartTime = na
var bool  _onFrozen   = false   // true once 09:30 fires for the current session

// Reset at the daily open (18:00 ET)
if isDailyOpen
    onHigh      := high
    onLow       := low
    onHighTime  := time
    onLowTime   := time
    onStartTime := time
    _onFrozen   := false

// Track during the pre-market window
if isPreMktWindow and not _onFrozen and not na(onStartTime)
    if high > onHigh
        onHigh     := high
        onHighTime := time
    if low < onLow
        onLow     := low
        onLowTime := time

// Freeze at NY Open (09:30 ET) so the lines stay put for the rest of the day
if isNYOpen and not _onFrozen
    _onFrozen := true

var line onhLine = na
var line onlLine = na

if barstate.islast
    if showONH_ and not na(onHigh) and not na(onStartTime)
        line.delete(onhLine)
        onhLine := line.new(onHighTime, onHigh, time, onHigh,
             xloc=xloc.bar_time, color=onhColor, width=gLineWidth, style=_preMktLnSt)
        _stackAdd(onHigh, "ONH", onhColor)
    if showONL_ and not na(onLow) and not na(onStartTime)
        line.delete(onlLine)
        onlLine := line.new(onLowTime, onLow, time, onLow,
             xloc=xloc.bar_time, color=onlColor, width=gLineWidth, style=_preMktLnSt)
        _stackAdd(onLow, "ONL", onlColor)

// ═════════════════════════════════════════════════════════════════════════════
//  PREVIOUS MONTH HIGH / LOW
// ═════════════════════════════════════════════════════════════════════════════

[_pmSecHigh, _pmSecLow, _pmSecOpenTime] =
     request.security(syminfo.tickerid, "1M", [high[1], low[1], time[1]], lookahead=barmerge.lookahead_on)

var float pmh           = na
var float pml           = na
var int   pmhTime       = na
var int   pmlTime       = na
var int   prevMonthOpenTime = na
var float _curMHigh     = na
var float _curMLow      = na
var int   _curMHTime    = na
var int   _curMLTime    = na
var int   _curMStartTime = na
var bool  _pmResetFired = false

if not isNewMonth
    _pmResetFired := false
isNewMonthOpen = isNewMonth and not _pmResetFired
if isNewMonthOpen
    _pmResetFired  := true
    pmhTime        := _curMHTime
    pmlTime        := _curMLTime
    _curMHigh      := high
    _curMLow       := low
    _curMHTime     := time
    _curMLTime     := time
    _curMStartTime := time
else
    if na(_curMHigh) or high > _curMHigh
        _curMHigh  := high
        _curMHTime := time
    if na(_curMLow) or low < _curMLow
        _curMLow   := low
        _curMLTime := time
    if na(_curMStartTime)
        _curMStartTime := time

if not na(_pmSecHigh)
    pmh := _pmSecHigh
if not na(_pmSecLow)
    pml := _pmSecLow
if not na(_pmSecOpenTime)
    prevMonthOpenTime := _pmSecOpenTime

var line pmhLine = na
var line pmlLine = na

if barstate.islast
    if showPMH_ and not na(pmh)
        line.delete(pmhLine)
        pmhLine := line.new(not na(pmhTime) ? pmhTime : not na(prevMonthOpenTime) ? prevMonthOpenTime : time - 2592000000,
             pmh, time, pmh, xloc=xloc.bar_time, color=pmhColor, width=gLineWidth, style=_gLnSt)
        _stackAdd(pmh, "PM High", pmhColor)
    if showPML_ and not na(pml)
        line.delete(pmlLine)
        pmlLine := line.new(not na(pmlTime) ? pmlTime : not na(prevMonthOpenTime) ? prevMonthOpenTime : time - 2592000000,
             pml, time, pml, xloc=xloc.bar_time, color=pmlColor, width=gLineWidth, style=_gLnSt)
        _stackAdd(pml, "PM Low", pmlColor)

// ═════════════════════════════════════════════════════════════════════════════
//  PREVIOUS WEEK HIGH / LOW
// ═════════════════════════════════════════════════════════════════════════════

[_pwSecOpenTime] = request.security(syminfo.tickerid, "W", [time[1]], lookahead=barmerge.lookahead_on)

var float pwh           = na
var int   pwhTime       = na
var int   pwlTime       = na
var int   prevWeekOpenTime = na
var float _curWHigh     = na
var float _curWLow      = na
var int   _curWHTime    = na
var int   _curWLTime    = na
var int   _curWStartTime = na

if not na(_pwSecOpenTime)
    prevWeekOpenTime := _pwSecOpenTime

if isNewWeek
    pwh          := _curWHigh
    pwl          := _curWLow
    pwhTime      := _curWHTime
    pwlTime      := _curWLTime
    _curWHigh    := high
    _curWLow     := low
    _curWHTime   := time
    _curWLTime   := time
    _curWStartTime := time
else
    if na(_curWHigh) or high > _curWHigh
        _curWHigh  := high
        _curWHTime := time
    if na(_curWLow) or low < _curWLow
        _curWLow   := low
        _curWLTime := time
    if na(_curWStartTime)
        _curWStartTime := time

var line pwhLine = na
var line pwlLine = na

if barstate.islast
    if showPWH_ and not na(pwh)
        line.delete(pwhLine)
        pwhLine := line.new(not na(pwhTime) ? pwhTime : not na(prevWeekOpenTime) ? prevWeekOpenTime : time - 604800000,
             pwh, time, pwh, xloc=xloc.bar_time, color=pwhColor, width=gLineWidth, style=_gLnSt)
        _stackAdd(pwh, "PWH", pwhColor)
    if showPWL_ and not na(pwl)
        line.delete(pwlLine)
        pwlLine := line.new(not na(pwlTime) ? pwlTime : not na(prevWeekOpenTime) ? prevWeekOpenTime : time - 604800000,
             pwl, time, pwl, xloc=xloc.bar_time, color=pwlColor, width=gLineWidth, style=_gLnSt)
        _stackAdd(pwl, "PWL", pwlColor)

// ═════════════════════════════════════════════════════════════════════════════
//  OPENS
// ═════════════════════════════════════════════════════════════════════════════

[_doSec,  _doSecTime]     = request.security(syminfo.tickerid, "D",   [open, time], lookahead=barmerge.lookahead_on)
[_woSec,  _woSecTime]     = request.security(syminfo.tickerid, "W",   [open, time], lookahead=barmerge.lookahead_on)
[_moSec,  _moSecTime]     = request.security(syminfo.tickerid, "M",   [open, time], lookahead=barmerge.lookahead_on)
[_yoSecTime, _yoSecPrice] = request.security(syminfo.tickerid, "12M", [time, open], lookahead=barmerge.lookahead_on)

var float dailyOpenPrice   = na
var int   dailyOpenTime    = na
var float weeklyOpenPrice  = na
var int   weeklyOpenTime   = na
var float monthlyOpenPrice = na
var int   monthlyOpenTime  = na
var float yearlyOpenPrice  = na
var int   yearlyOpenTime   = na
var float midoPrice        = na
var int   midoTime         = na
var float nyOpenPrice      = na
var int   nyOpenTime       = na

if not na(_doSec)
    dailyOpenPrice  := _doSec
    dailyOpenTime   := _doSecTime
if not na(_woSec)
    weeklyOpenPrice := _woSec
    weeklyOpenTime  := _woSecTime
if not na(_moSec)
    monthlyOpenPrice := _moSec
    monthlyOpenTime  := _moSecTime
if not na(_yoSecPrice) and not na(_yoSecTime) and na(yearlyOpenPrice)
    yearlyOpenPrice := _yoSecPrice
    yearlyOpenTime  := _yoSecTime
if isYearlyOpen
    yearlyOpenPrice := open
    yearlyOpenTime  := time
if isMidnightOpen
    midoPrice := open
    midoTime  := time
if isNYOpen
    nyOpenPrice := open
    nyOpenTime  := time

var line doLine   = na
var line woLine   = na
var line moLine   = na
var line yoLine   = na
var line midoLine = na
var line nyoLine  = na

var label[] openLabels = array.new_label(0)

if barstate.islast
    for lb in openLabels
        label.delete(lb)
    array.clear(openLabels)

    if showDO_ and not na(dailyOpenPrice)
        line.delete(doLine)
        doLine := line.new(not na(dailyOpenTime) ? dailyOpenTime : time - 86400000,
             dailyOpenPrice, time, dailyOpenPrice, xloc=xloc.bar_time, color=doColor, width=gLineWidth, style=_opensLnSt)
    if showWO_ and not na(weeklyOpenPrice)
        line.delete(woLine)
        woLine := line.new(not na(weeklyOpenTime) ? weeklyOpenTime : time - 604800000,
             weeklyOpenPrice, time, weeklyOpenPrice, xloc=xloc.bar_time, color=woColor, width=gLineWidth, style=_opensLnSt)
    if showMO_ and not na(monthlyOpenPrice)
        line.delete(moLine)
        moLine := line.new(not na(monthlyOpenTime) ? monthlyOpenTime : time - 2592000000,
             monthlyOpenPrice, time, monthlyOpenPrice, xloc=xloc.bar_time, color=moColor, width=gLineWidth, style=_opensLnSt)
    if showYO_ and not na(yearlyOpenPrice)
        line.delete(yoLine)
        yoLine := line.new(not na(yearlyOpenTime) ? yearlyOpenTime : time - 31536000000,
             yearlyOpenPrice, time, yearlyOpenPrice, xloc=xloc.bar_time, color=yoColor, width=gLineWidth, style=_opensLnSt)

    float[]  oPrices = array.new_float()
    string[] oCodes  = array.new_string()
    color[]  oColors = array.new_color()
    if showDO_ and not na(dailyOpenPrice)
        array.push(oPrices, dailyOpenPrice), array.push(oCodes, "D"),  array.push(oColors, doColor)
    if showWO_ and not na(weeklyOpenPrice)
        array.push(oPrices, weeklyOpenPrice), array.push(oCodes, "W"), array.push(oColors, woColor)
    if showMO_ and not na(monthlyOpenPrice)
        array.push(oPrices, monthlyOpenPrice), array.push(oCodes, "M"), array.push(oColors, moColor)
    if showYO_ and not na(yearlyOpenPrice)
        array.push(oPrices, yearlyOpenPrice), array.push(oCodes, "Y"), array.push(oColors, yoColor)

    float[]  cPrices = array.new_float()
    string[] cTexts  = array.new_string()
    color[]  cColors = array.new_color()
    int _oPSz = array.size(oPrices)
    if _oPSz > 0
        for i = 0 to _oPSz - 1
            float  p   = array.get(oPrices, i)
            string c   = array.get(oCodes,  i)
            color  col = array.get(oColors, i)
            int idx = -1
            int _cPSz = array.size(cPrices)
            if _cPSz > 0
                for j = 0 to _cPSz - 1
                    if array.get(cPrices, j) == p
                        idx := j
                        break
            if idx == -1
                array.push(cPrices, p), array.push(cTexts, c), array.push(cColors, col)
            else
                array.set(cTexts, idx, array.get(cTexts, idx) + "/" + c)
    int _cPSz2 = array.size(cPrices)
    if _cPSz2 > 0
        for j = 0 to _cPSz2 - 1
            _stackAdd(array.get(cPrices, j), array.get(cTexts, j) + " Open", array.get(cColors, j))

    if showMidO_ and not na(midoPrice)
        line.delete(midoLine)
        midoLine := line.new(midoTime, midoPrice, time, midoPrice,
             xloc=xloc.bar_time, color=midoColor, width=gLineWidth, style=_opensLnSt)
        _stackAdd(midoPrice, "00:00", midoColor)
    if showNYO_ and not na(nyOpenPrice)
        line.delete(nyoLine)
        nyoLine := line.new(nyOpenTime, nyOpenPrice, time, nyOpenPrice,
             xloc=xloc.bar_time, color=nyoColor, width=gLineWidth, style=_opensLnSt)
        _stackAdd(nyOpenPrice, "NY Open", nyoColor)

// ═════════════════════════════════════════════════════════════════════════════
//  VWAP
// ═════════════════════════════════════════════════════════════════════════════

var float _dSrcVol = 0.0, var float _dVol = 0.0
if isDailyOpen or barstate.isfirst
    _dSrcVol := hlc3 * volume,  _dVol := volume
else
    _dSrcVol += hlc3 * volume,  _dVol += volume
dailyVWAP = _dVol > 0 ? _dSrcVol / _dVol : na

var float _wSrcVol = 0.0, var float _wVol = 0.0
if isNewWeek
    _wSrcVol := hlc3 * volume,  _wVol := volume
else
    _wSrcVol += hlc3 * volume,  _wVol += volume
weeklyVWAP = _wVol > 0 ? _wSrcVol / _wVol : na

var float _mSrcVol = 0.0, var float _mVol = 0.0
if isNewMonth
    _mSrcVol := hlc3 * volume,  _mVol := volume
else
    _mSrcVol += hlc3 * volume,  _mVol += volume
monthlyVWAP = _mVol > 0 ? _mSrcVol / _mVol : na

var float _ySrcVol = 0.0, var float _yVol = 0.0
if isNewYear
    _ySrcVol := hlc3 * volume,  _yVol := volume
else
    _ySrcVol += hlc3 * volume,  _yVol += volume
yearlyVWAP = _yVol > 0 ? _ySrcVol / _yVol : na

var float _nySrcVol = 0.0, var float _nyVol = 0.0
if isNYSessStart
    _nySrcVol := hlc3 * volume,  _nyVol := volume
else
    _nySrcVol += hlc3 * volume,  _nyVol += volume
nySessVWAP = _nyVol > 0 ? _nySrcVol / _nyVol : na

plot(showDailyVWAP_   ? dailyVWAP   : na, "vD bg",  color=vwapDailyOutline,   linewidth=gLineWidth+1, display=display.pane)
plot(showDailyVWAP_   ? dailyVWAP   : na, "vD",     color=vwapDailyColor,     linewidth=gLineWidth,   display=display.pane)
plot(showWeeklyVWAP_  ? weeklyVWAP  : na, "vW bg",  color=vwapWeeklyOutline,  linewidth=gLineWidth+1, display=display.pane)
plot(showWeeklyVWAP_  ? weeklyVWAP  : na, "vW",     color=vwapWeeklyColor,    linewidth=gLineWidth,   display=display.pane)
plot(showMonthlyVWAP_ ? monthlyVWAP : na, "vM bg",  color=vwapMonthlyOutline, linewidth=gLineWidth+1, display=display.pane)
plot(showMonthlyVWAP_ ? monthlyVWAP : na, "vM",     color=vwapMonthlyColor,   linewidth=gLineWidth,   display=display.pane)
plot(showYearlyVWAP_  ? yearlyVWAP  : na, "vY bg",  color=vwapYearlyOutline,  linewidth=gLineWidth+1, display=display.pane)
plot(showYearlyVWAP_  ? yearlyVWAP  : na, "vY",     color=vwapYearlyColor,    linewidth=gLineWidth,   display=display.pane)
plot(showNYSessVWAP_  ? nySessVWAP  : na, "vNY bg", color=vwapNYSessOutline,  linewidth=gLineWidth+1, display=display.pane)
plot(showNYSessVWAP_  ? nySessVWAP  : na, "vNY",    color=vwapNYSessColor,    linewidth=gLineWidth,   display=display.pane)

if barstate.islast
    if showDailyVWAP_   and not na(dailyVWAP)
        _stackAdd(dailyVWAP,   "vD",  vwapDailyLabelColor)
    if showWeeklyVWAP_  and not na(weeklyVWAP)
        _stackAdd(weeklyVWAP,  "vW",  vwapWeeklyLabelColor)
    if showMonthlyVWAP_ and not na(monthlyVWAP)
        _stackAdd(monthlyVWAP, "vM",  vwapMonthlyLabelColor)
    if showYearlyVWAP_  and not na(yearlyVWAP)
        _stackAdd(yearlyVWAP,  "vY",  vwapYearlyLabelColor)
    if showNYSessVWAP_  and not na(nySessVWAP)
        _stackAdd(nySessVWAP,  "vNY", vwapNYSessLabelColor)
    _stackRender()

// ═════════════════════════════════════════════════════════════════════════════
//  INITIAL BALANCE
// ═════════════════════════════════════════════════════════════════════════════

var float ibHigh      = na
var float ibLow       = na
var bool  ibDone      = false
var int   ibStartTime = na
var int   ibHighTime  = na
var int   ibLowTime   = na

var line  ibhLine   = na, var line  iblLine   = na, var line  ibEQLn    = na
var label ibhLabel  = na, var label iblLabel  = na, var label ibEQLabel = na
var box   ibFillBox = na

var float[] histIBHighs     = array.new_float(0)
var float[] histIBLows      = array.new_float(0)
var int[]   histIBStarts    = array.new_int(0)
var int[]   histIBEnds      = array.new_int(0)
var int[]   histIBBoxEnds   = array.new_int(0)
var int[]   histIBHighTimes = array.new_int(0)
var int[]   histIBLowTimes  = array.new_int(0)
var line[]  histIBhLines    = array.new_line(0)
var label[] histIBhHLbls    = array.new_label(0)
var label[] histIBhLLbls    = array.new_label(0)
var box[]   histIBBoxes     = array.new_box(0)

if isIBStart
    ibHigh := high, ibLow := low, ibDone := false, ibStartTime := time
    ibHighTime := time, ibLowTime := time

// Clean up IB drawings if toggled off while window is active
if isIBWindow and not ibDone and not showIB_
    line.delete(ibhLine),   ibhLine   := na
    line.delete(iblLine),   iblLine   := na
    line.delete(ibEQLn),    ibEQLn    := na
    label.delete(ibhLabel), ibhLabel  := na
    label.delete(iblLabel), iblLabel  := na
    label.delete(ibEQLabel),ibEQLabel := na
    box.delete(ibFillBox),  ibFillBox := na

// H/L tracking always runs regardless of display toggle
if isIBWindow and not ibDone and not na(ibStartTime)
    if high > ibHigh
        ibHigh := high, ibHighTime := time
    if low < ibLow
        ibLow  := low,  ibLowTime  := time

if isIBWindow and not ibDone and showIB_ and not na(ibStartTime)
    int _ibExt = ibStartTime + ibExtendBars * _tfMs
    line.delete(ibhLine),   line.delete(iblLine),   line.delete(ibEQLn)
    label.delete(ibhLabel), label.delete(iblLabel), label.delete(ibEQLabel)
    if showIBFill_
        box.delete(ibFillBox)
        ibFillBox := box.new(ibStartTime, ibHigh, time + _tfMs, ibLow,
             xloc=xloc.bar_time, bgcolor=ibFillColor,
             border_color=color.new(color.black,100), border_width=0)
    ibhLine  := line.new(ibHighTime, ibHigh, _ibExt, ibHigh,
         xloc=xloc.bar_time, color=ibColor, width=gLineWidth, style=_ibLnSt)
    iblLine  := line.new(ibLowTime,  ibLow,  _ibExt, ibLow,
         xloc=xloc.bar_time, color=ibColor, width=gLineWidth, style=_ibLnSt)
    ibhLabel := label.new(ibHighTime, ibHigh, "IB High  ",
         xloc=xloc.bar_time, color=color.new(color.black,100), textcolor=ibTextColor,
         style=label.style_label_right, size=_gLblSz, tooltip=_tip(ibHigh))
    iblLabel := label.new(ibLowTime,  ibLow,  "IB Low  ",
         xloc=xloc.bar_time, color=color.new(color.black,100), textcolor=ibTextColor,
         style=label.style_label_right, size=_gLblSz, tooltip=_tip(ibLow))
    if showIBEQ_
        float _ibEQ = (ibHigh + ibLow) / 2
        ibEQLn    := line.new(ibStartTime, _ibEQ, _ibExt, _ibEQ,
             xloc=xloc.bar_time, color=ibEQColor, width=gLineWidth, style=line.style_dashed)
        ibEQLabel := label.new(ibStartTime, _ibEQ, "IB EQ  ",
             xloc=xloc.bar_time, color=color.new(color.black,100), textcolor=ibTextColor,
             style=label.style_label_right, size=_gLblSz, tooltip=_tip(_ibEQ))

if isIBEnd and not ibDone and showIB_
    ibDone := true
    int _ibExt = ibStartTime + ibExtendBars * _tfMs
    if showHistIB_
        line.delete(ibhLine),   line.delete(iblLine),   line.delete(ibEQLn)
        label.delete(ibhLabel), label.delete(iblLabel), label.delete(ibEQLabel)
        box.delete(ibFillBox)
        array.unshift(histIBHighs,     ibHigh)
        array.unshift(histIBLows,      ibLow)
        array.unshift(histIBStarts,    ibStartTime)
        array.unshift(histIBEnds,      _ibExt)
        array.unshift(histIBBoxEnds,   time)
        array.unshift(histIBHighTimes, ibHighTime)
        array.unshift(histIBLowTimes,  ibLowTime)
        while array.size(histIBHighs) > histLookback
            array.pop(histIBHighs),     array.pop(histIBLows)
            array.pop(histIBStarts),    array.pop(histIBEnds),    array.pop(histIBBoxEnds)
            array.pop(histIBHighTimes), array.pop(histIBLowTimes)
        for ol in histIBhLines
            line.delete(ol)
        array.clear(histIBhLines)
        for ol in histIBhHLbls
            label.delete(ol)
        array.clear(histIBhHLbls)
        for ol in histIBhLLbls
            label.delete(ol)
        array.clear(histIBhLLbls)
        for ob in histIBBoxes
            box.delete(ob)
        array.clear(histIBBoxes)
        int _histIBSz = array.size(histIBHighs)
        if _histIBSz > 0
            for i = 0 to _histIBSz - 1
                float hH  = array.get(histIBHighs,     i)
                float hL  = array.get(histIBLows,      i)
                int   hS  = array.get(histIBStarts,    i)
                int   hE  = array.get(histIBEnds,      i)
                int   hBE = array.get(histIBBoxEnds,   i)
                int   hHT = array.get(histIBHighTimes, i)
                int   hLT = array.get(histIBLowTimes,  i)
                bool  _isToday = hS >= curDayStartTime
                color _hIBF = _isToday ? ibFillColor : color.new(ibFillColor, histTransp)
                color _hIBC = _isToday ? ibColor     : color.new(ibColor,     histTransp)
                color _hIBT = _isToday ? ibTextColor : color.new(ibTextColor, histTransp)
                if showIBFill_
                    array.push(histIBBoxes, box.new(hS, hH, hBE, hL, xloc=xloc.bar_time,
                         bgcolor=_hIBF, border_color=color.new(color.black,100), border_width=0))
                if not ibKeepToday
                    array.push(histIBhLines, line.new(hHT, hH, hE, hH, xloc=xloc.bar_time, color=_hIBC, width=gLineWidth, style=_ibLnSt))
                    array.push(histIBhLines, line.new(hLT, hL, hE, hL, xloc=xloc.bar_time, color=_hIBC, width=gLineWidth, style=_ibLnSt))
                    array.push(histIBhHLbls, label.new(hHT, hH, "IB High  ", xloc=xloc.bar_time,
                         color=color.new(color.black,100), textcolor=_hIBT, style=label.style_label_right, size=size.tiny, tooltip=_tip(hH)))
                    array.push(histIBhLLbls, label.new(hLT, hL, "IB Low  ",  xloc=xloc.bar_time,
                         color=color.new(color.black,100), textcolor=_hIBT, style=label.style_label_right, size=size.tiny, tooltip=_tip(hL)))

// ═════════════════════════════════════════════════════════════════════════════
//  SESSION DRAWING HELPERS
// ═════════════════════════════════════════════════════════════════════════════

_sessDrawActive(float sHigh, float sLow, int sStartTime, int sHighTime, int sLowTime,
                color hColor, color lColor, color fillColor, string lbl_h, string lbl_l,
                line hLine, line lLine, label hLabel, label lLabel, box fillBox) =>
    int sEnd = time + _tfMs
    line.delete(hLine),   line.delete(lLine)
    label.delete(hLabel), label.delete(lLabel)
    box.delete(fillBox)
    box   _fb  = box.new(sStartTime, sHigh, sEnd, sLow, xloc=xloc.bar_time,
         bgcolor=fillColor, border_color=color.new(color.black,100), border_width=0)
    line  _hl  = line.new(sHighTime, sHigh, sEnd, sHigh, xloc=xloc.bar_time, color=hColor, width=gLineWidth, style=line.style_dashed)
    line  _ll  = line.new(sLowTime,  sLow,  sEnd, sLow,  xloc=xloc.bar_time, color=lColor, width=gLineWidth, style=line.style_dashed)
    label _hlb = label.new(sHighTime, sHigh, lbl_h, xloc=xloc.bar_time, color=color.new(color.black,100),
         textcolor=hColor, style=label.style_label_right, size=_gLblSz, tooltip=_tip(sHigh))
    label _llb = label.new(sLowTime,  sLow,  lbl_l, xloc=xloc.bar_time, color=color.new(color.black,100),
         textcolor=lColor, style=label.style_label_right, size=_gLblSz, tooltip=_tip(sLow))
    [_hl, _ll, _hlb, _llb, _fb]

_sessDrawHist(float sHigh, float sLow, int sStartTime, int sHighTime, int sLowTime, int sEndOff,
              float[] hHighs, float[] hLows, int[] hStarts, int[] hEnds,
              int[] hHighTimes, int[] hLowTimes,
              line[] hLines, label[] hHLbls, label[] hLLbls, box[] hBoxes,
              color hColor, color lColor, color fillColor, string lbl_h, string lbl_l, int lookback) =>
    array.unshift(hHighs,     sHigh)
    array.unshift(hLows,      sLow)
    array.unshift(hStarts,    sStartTime)
    array.unshift(hEnds,      sEndOff)
    array.unshift(hHighTimes, sHighTime)
    array.unshift(hLowTimes,  sLowTime)
    while array.size(hHighs) > lookback
        array.pop(hHighs),     array.pop(hLows)
        array.pop(hStarts),    array.pop(hEnds)
        array.pop(hHighTimes), array.pop(hLowTimes)
    for ol in hLines
        line.delete(ol)
    array.clear(hLines)
    for ol in hHLbls
        label.delete(ol)
    array.clear(hHLbls)
    for ol in hLLbls
        label.delete(ol)
    array.clear(hLLbls)
    for ob in hBoxes
        box.delete(ob)
    array.clear(hBoxes)
    color _hHC   = color.new(hColor,    histTransp)
    color _hLC   = color.new(lColor,    histTransp)
    color _hFill = color.new(fillColor, math.min(histTransp + 10, 100))
    int _hSz = array.size(hHighs)
    if _hSz > 0
        for i = 0 to _hSz - 1
            float hH  = array.get(hHighs,     i)
            float hL  = array.get(hLows,      i)
            int   hS  = array.get(hStarts,    i)
            int   hE  = array.get(hEnds,      i)
            int   hHT = array.get(hHighTimes, i)
            int   hLT = array.get(hLowTimes,  i)
            bool  _isTodaySess = hS >= curDayStartTime
            color _loopHC   = _isTodaySess ? hColor    : _hHC
            color _loopLC   = _isTodaySess ? lColor    : _hLC
            color _loopFill = _isTodaySess ? fillColor : _hFill
            array.push(hBoxes, box.new(hS, hH, hE, hL, xloc=xloc.bar_time,
                 bgcolor=_loopFill, border_color=color.new(color.black,100), border_width=0))
            array.push(hLines, line.new(hHT, hH, hE, hH, xloc=xloc.bar_time, color=_loopHC, width=1, style=line.style_dashed))
            array.push(hLines, line.new(hLT, hL, hE, hL, xloc=xloc.bar_time, color=_loopLC, width=1, style=line.style_dashed))
            array.push(hHLbls, label.new(hHT, hH, lbl_h, xloc=xloc.bar_time, color=color.new(color.black,100),
                 textcolor=_loopHC, style=label.style_label_right, size=size.tiny, tooltip=_tip(hH)))
            array.push(hLLbls, label.new(hLT, hL, lbl_l, xloc=xloc.bar_time, color=color.new(color.black,100),
                 textcolor=_loopLC, style=label.style_label_right, size=size.tiny, tooltip=_tip(hL)))

// ═════════════════════════════════════════════════════════════════════════════
//  ASIA SESSION
// ═════════════════════════════════════════════════════════════════════════════

var float asiaHigh      = na, var float asiaLow       = na
var bool  asiaDone      = false, var int asiaStartTime = na
var int   asiaHighTime  = na,    var int asiaLowTime   = na
var line  asiaHLine     = na,    var line  asiaLLine   = na
var label asiaHLabel    = na,    var label asiaLLabel  = na
var box   asiaFillBox   = na

var float[] histAsiaHighs     = array.new_float(0)
var float[] histAsiaLows      = array.new_float(0)
var int[]   histAsiaStarts    = array.new_int(0)
var int[]   histAsiaEnds      = array.new_int(0)
var int[]   histAsiaHighTimes = array.new_int(0)
var int[]   histAsiaLowTimes  = array.new_int(0)
var line[]  histAsiaLines     = array.new_line(0)
var label[] histAsiaHLbls     = array.new_label(0)
var label[] histAsiaLLbls     = array.new_label(0)
var box[]   histAsiaBoxes     = array.new_box(0)

if isAsiaStart
    asiaHigh := high, asiaLow := low, asiaDone := false, asiaStartTime := time
    asiaHighTime := time, asiaLowTime := time

if isAsiaWindow and not asiaDone and not na(asiaStartTime)
    if high > asiaHigh
        asiaHigh := high, asiaHighTime := time
    if low < asiaLow
        asiaLow  := low,  asiaLowTime  := time

if isAsiaWindow and not asiaDone and showAsia_ and not na(asiaStartTime)
    [_aHL, _aLL, _aHLb, _aLLb, _aFB] = _sessDrawActive(
         asiaHigh, asiaLow, asiaStartTime, asiaHighTime, asiaLowTime,
         asiaHighColor, asiaLowColor, asiaFillColor,
         "Asia High  ", "Asia Low  ", asiaHLine, asiaLLine, asiaHLabel, asiaLLabel, asiaFillBox)
    asiaHLine := _aHL, asiaLLine := _aLL, asiaHLabel := _aHLb, asiaLLabel := _aLLb, asiaFillBox := _aFB

// Clean up Asia drawings if toggled off while session is active
if isAsiaWindow and not asiaDone and not showAsia_
    line.delete(asiaHLine),   asiaHLine  := na
    line.delete(asiaLLine),   asiaLLine  := na
    label.delete(asiaHLabel), asiaHLabel := na
    label.delete(asiaLLabel), asiaLLabel := na
    box.delete(asiaFillBox),  asiaFillBox := na

if isAsiaEnd and not asiaDone and not na(asiaHigh)
    asiaDone := true
    if showHistAsia_
        line.delete(asiaHLine),   line.delete(asiaLLine)
        label.delete(asiaHLabel), label.delete(asiaLLabel)
        box.delete(asiaFillBox)
        _sessDrawHist(asiaHigh, asiaLow, asiaStartTime, asiaHighTime, asiaLowTime, time - 60000,
             histAsiaHighs, histAsiaLows, histAsiaStarts, histAsiaEnds,
             histAsiaHighTimes, histAsiaLowTimes,
             histAsiaLines, histAsiaHLbls, histAsiaLLbls, histAsiaBoxes,
             asiaHighColor, asiaLowColor, asiaFillColor,
             "Asia High  ", "Asia Low  ", histLookback)

// ═════════════════════════════════════════════════════════════════════════════
//  LONDON SESSION
// ═════════════════════════════════════════════════════════════════════════════

var float lonHigh      = na, var float lonLow       = na
var bool  lonDone      = false, var int lonStartTime = na
var int   lonHighTime  = na,    var int lonLowTime   = na
var line  lonHLine     = na,    var line  lonLLine   = na
var label lonHLabel    = na,    var label lonLLabel  = na
var box   lonFillBox   = na

var float[] histLonHighs     = array.new_float(0)
var float[] histLonLows      = array.new_float(0)
var int[]   histLonStarts    = array.new_int(0)
var int[]   histLonEnds      = array.new_int(0)
var int[]   histLonHighTimes = array.new_int(0)
var int[]   histLonLowTimes  = array.new_int(0)
var line[]  histLonLines     = array.new_line(0)
var label[] histLonHLbls     = array.new_label(0)
var label[] histLonLLbls     = array.new_label(0)
var box[]   histLonBoxes     = array.new_box(0)

if isLonStart
    lonHigh := high, lonLow := low, lonDone := false, lonStartTime := time
    lonHighTime := time, lonLowTime := time

if isLonWindow and not lonDone and not na(lonStartTime)
    if high > lonHigh
        lonHigh := high, lonHighTime := time
    if low < lonLow
        lonLow  := low,  lonLowTime  := time

if isLonWindow and not lonDone and showLondon_ and not na(lonStartTime)
    [_lHL, _lLL, _lHLb, _lLLb, _lFB] = _sessDrawActive(
         lonHigh, lonLow, lonStartTime, lonHighTime, lonLowTime,
         lonHighColor, lonLowColor, lonFillColor,
         "London High  ", "London Low  ", lonHLine, lonLLine, lonHLabel, lonLLabel, lonFillBox)
    lonHLine := _lHL, lonLLine := _lLL, lonHLabel := _lHLb, lonLLabel := _lLLb, lonFillBox := _lFB

// Clean up London drawings if toggled off while session is active
if isLonWindow and not lonDone and not showLondon_
    line.delete(lonHLine),   lonHLine  := na
    line.delete(lonLLine),   lonLLine  := na
    label.delete(lonHLabel), lonHLabel := na
    label.delete(lonLLabel), lonLLabel := na
    box.delete(lonFillBox),  lonFillBox := na

if isLonEnd and not lonDone and not na(lonHigh)
    lonDone := true
    if showHistLon_
        line.delete(lonHLine),   line.delete(lonLLine)
        label.delete(lonHLabel), label.delete(lonLLabel)
        box.delete(lonFillBox)
        _sessDrawHist(lonHigh, lonLow, lonStartTime, lonHighTime, lonLowTime, time - 60000,
             histLonHighs, histLonLows, histLonStarts, histLonEnds,
             histLonHighTimes, histLonLowTimes,
             histLonLines, histLonHLbls, histLonLLbls, histLonBoxes,
             lonHighColor, lonLowColor, lonFillColor,
             "London High  ", "London Low  ", histLookback)

// ═════════════════════════════════════════════════════════════════════════════
//  NY SESSION
// ═════════════════════════════════════════════════════════════════════════════

var float nyHigh      = na, var float nyLow       = na
var bool  nyDone      = false, var int nyStartTime = na
var int   nyHighTime  = na,    var int nyLowTime   = na
var line  nyHLine     = na,    var line  nyLLine   = na
var label nyHLabel    = na,    var label nyLLabel  = na
var box   nyFillBox   = na

var float[] histNYHighs     = array.new_float(0)
var float[] histNYLows      = array.new_float(0)
var int[]   histNYStarts    = array.new_int(0)
var int[]   histNYEnds      = array.new_int(0)
var int[]   histNYHighTimes = array.new_int(0)
var int[]   histNYLowTimes  = array.new_int(0)
var line[]  histNYLines     = array.new_line(0)
var label[] histNYHLbls     = array.new_label(0)
var label[] histNYLLbls     = array.new_label(0)
var box[]   histNYBoxes     = array.new_box(0)

if isNYSessStart
    nyHigh := high, nyLow := low, nyDone := false, nyStartTime := time
    nyHighTime := time, nyLowTime := time

if isNYSessWin and not nyDone and not na(nyStartTime)
    if high > nyHigh
        nyHigh := high, nyHighTime := time
    if low < nyLow
        nyLow  := low,  nyLowTime  := time

if isNYSessWin and not nyDone and showNYSess_ and not na(nyStartTime)
    [_nHL, _nLL, _nHLb, _nLLb, _nFB] = _sessDrawActive(
         nyHigh, nyLow, nyStartTime, nyHighTime, nyLowTime,
         nyHighColor, nyLowColor, nyFillColor,
         "NY High  ", "NY Low  ", nyHLine, nyLLine, nyHLabel, nyLLabel, nyFillBox)
    nyHLine := _nHL, nyLLine := _nLL, nyHLabel := _nHLb, nyLLabel := _nLLb, nyFillBox := _nFB

// Clean up NY drawings if toggled off while session is active
if isNYSessWin and not nyDone and not showNYSess_
    line.delete(nyHLine),   nyHLine  := na
    line.delete(nyLLine),   nyLLine  := na
    label.delete(nyHLabel), nyHLabel := na
    label.delete(nyLLabel), nyLLabel := na
    box.delete(nyFillBox),  nyFillBox := na

if isNYSessEnd and not nyDone and not na(nyHigh)
    nyDone := true
    if showHistNY_
        line.delete(nyHLine),   line.delete(nyLLine)
        label.delete(nyHLabel), label.delete(nyLLabel)
        box.delete(nyFillBox)
        _sessDrawHist(nyHigh, nyLow, nyStartTime, nyHighTime, nyLowTime, time - 60000,
             histNYHighs, histNYLows, histNYStarts, histNYEnds,
             histNYHighTimes, histNYLowTimes,
             histNYLines, histNYHLbls, histNYLLbls, histNYBoxes,
             nyHighColor, nyLowColor, nyFillColor,
             "NY High  ", "NY Low  ", histLookback)

// ═════════════════════════════════════════════════════════════════════════════
//  VOLUME PROFILE
// ═════════════════════════════════════════════════════════════════════════════

vpLTF() =>
    int s = timeframe.in_seconds()
    s >= 900 ? "5" : s >= 300 ? "1" : "1"

string _vpLTF     = vpLTF()
bool   _vpEnabled = timeframe.in_seconds() <= 900 and timeframe.in_seconds() > 60
bool   _vpActive  = timeframe.in_seconds() <= 900

float[] ltfHighs = (_vpActive and gsVP) ? request.security_lower_tf(syminfo.tickerid, _vpLTF, high)   : array.new_float(0)
float[] ltfLows  = (_vpActive and gsVP) ? request.security_lower_tf(syminfo.tickerid, _vpLTF, low)    : array.new_float(0)
float[] ltfVols  = (_vpActive and gsVP) ? request.security_lower_tf(syminfo.tickerid, _vpLTF, volume) : array.new_float(0)

vpRecompute(float[] allHighs, float[] allLows, float[] allVols,
            float[] buckets, int rows, float rangeHigh, float rangeLow) =>
    array.clear(buckets)
    for _i = 0 to rows - 1
        array.push(buckets, 0.0)
    n = array.size(allHighs)
    if n > 0 and rangeHigh > rangeLow and rows > 0
        rowH = (rangeHigh - rangeLow) / rows
        for i = 0 to n - 1
            h = array.get(allHighs, i), l = array.get(allLows, i), v = array.get(allVols, i)
            barSpan = math.max(h - l, rowH * 0.01)
            for r = 0 to rows - 1
                rL = rangeLow + r * rowH, rH = rL + rowH
                ov = math.min(h, rH) - math.max(l, rL)
                if ov > 0
                    array.set(buckets, r, array.get(buckets, r) + v * ov / barSpan)

vpDraw(float[] buckets, float rangeHigh, float rangeLow,
       int startBar, int widthBars,
       color outsideC, color insideC,
       bool showPOC, color pocColor,
       bool showVAHL, color vahlColor,
       box[] boxArr, line[] lineArr, label[] lblArr) =>
    for b in boxArr
        box.delete(b)
    array.clear(boxArr)
    for l in lineArr
        line.delete(l)
    array.clear(lineArr)
    for lb in lblArr
        label.delete(lb)
    array.clear(lblArr)
    int n = array.size(buckets)
    if n >= 1 and rangeHigh > rangeLow
        int safeStart = math.max(startBar, bar_index - 990)
        float totalVol = 0.0, float maxVol = 0.0, int pocIdx = 0
        for i = 0 to n - 1
            v = array.get(buckets, i)
            totalVol += v
            if v > maxVol
                maxVol := v
                pocIdx := i
        float rowH = (rangeHigh - rangeLow) / n
        float vaT  = totalVol * 0.70
        float vaV  = array.get(buckets, pocIdx)
        int vaTop = pocIdx, int vaBot = pocIdx
        for _i = 0 to n - 1
            if vaV >= vaT or (vaTop >= n - 1 and vaBot <= 0)
                break
            upV = vaTop < n - 1 ? array.get(buckets, vaTop + 1) : 0.0
            dnV = vaBot > 0     ? array.get(buckets, vaBot - 1) : 0.0
            if upV >= dnV
                vaTop += 1, vaV += upV
            else
                vaBot -= 1, vaV += dnV
        for i = 0 to n - 1
            rL   = rangeLow + i * rowH
            rH   = rL + rowH
            rVol = array.get(buckets, i)
            bBars = maxVol > 0 ? math.max(1, math.round(rVol / maxVol * widthBars)) : 1
            bCol  = (i >= vaBot and i <= vaTop) ? insideC : outsideC
            array.push(boxArr, box.new(safeStart, rH, safeStart + bBars, rL, bgcolor=bCol, border_color=bCol, border_width=1))
        pocPrice = rangeLow + pocIdx * rowH + rowH / 2
        vahPrice = rangeLow + vaTop  * rowH + rowH
        valPrice = rangeLow + vaBot  * rowH
        if showPOC
            array.push(lineArr, line.new(safeStart, pocPrice, bar_index, pocPrice, color=pocColor, width=gLineWidth, style=line.style_solid))
            array.push(lblArr,  label.new(bar_index + 1, pocPrice, "POC", color=color.new(color.black,100), textcolor=pocColor, style=label.style_label_left, size=size.tiny, tooltip=_tip(pocPrice)))
        if showVAHL
            array.push(lineArr, line.new(safeStart, vahPrice, bar_index, vahPrice, color=vahlColor, width=gLineWidth, style=line.style_dotted))
            array.push(lineArr, line.new(safeStart, valPrice, bar_index, valPrice, color=vahlColor, width=gLineWidth, style=line.style_dotted))
            array.push(lblArr,  label.new(bar_index + 1, vahPrice, "VAH", color=color.new(color.black,100), textcolor=vahlColor, style=label.style_label_left, size=size.tiny, tooltip=_tip(vahPrice)))
            array.push(lblArr,  label.new(bar_index + 1, valPrice, "VAL", color=color.new(color.black,100), textcolor=vahlColor, style=label.style_label_left, size=size.tiny, tooltip=_tip(valPrice)))

var float[] vpDayAllHighs = array.new_float(0)
var float[] vpDayAllLows  = array.new_float(0)
var float[] vpDayAllVols  = array.new_float(0)
var float[] vpDayBuckets  = array.new_float(0)
var float   vpDayHigh     = na, var float vpDayLow = na
var int     vpDayStartBar = na
var box[]   vpBoxes       = array.new_box(0)
var line[]  vpLines       = array.new_line(0)
var label[] vpLabels      = array.new_label(0)

var float[] nyVPAllHighs = array.new_float(0)
var float[] nyVPAllLows  = array.new_float(0)
var float[] nyVPAllVols  = array.new_float(0)
var float[] nyVPBuckets  = array.new_float(0)
var float   nyVPHigh     = na, var float nyVPLow = na
var int     nyVPStartBar = na
var box[]   nyVPBoxes    = array.new_box(0)
var line[]  nyVPLines    = array.new_line(0)
var label[] nyVPLabels   = array.new_label(0)

if isDailyOpen
    vpDayHigh := high, vpDayLow := low, vpDayStartBar := bar_index
    array.clear(vpDayAllHighs), array.clear(vpDayAllLows), array.clear(vpDayAllVols)

if barstate.isconfirmed and _vpActive and showDailyVP_ and _vpEnabled and not isDailyOpen and not na(vpDayStartBar) and bar_index > vpDayStartBar
    vpDayHigh := math.max(vpDayHigh, high), vpDayLow := math.min(vpDayLow, low)
    for i = 0 to array.size(ltfHighs) - 1
        array.push(vpDayAllHighs, array.get(ltfHighs, i))
        array.push(vpDayAllLows,  array.get(ltfLows,  i))
        array.push(vpDayAllVols,  array.get(ltfVols,  i))
if barstate.isconfirmed and _vpActive and showDailyVP_ and not _vpEnabled and not isDailyOpen and not na(vpDayStartBar) and bar_index > vpDayStartBar
    vpDayHigh := math.max(vpDayHigh, high), vpDayLow := math.min(vpDayLow, low)
    array.push(vpDayAllHighs, high), array.push(vpDayAllLows, low), array.push(vpDayAllVols, volume)

if (barstate.islast or barstate.isconfirmed) and _vpActive and showDailyVP_ and not na(vpDayHigh) and not na(vpDayLow)
    int vpW = math.max(2, math.round(math.max(5, bar_index - vpDayStartBar) * vpWidthPct / 100))
    vpRecompute(vpDayAllHighs, vpDayAllLows, vpDayAllVols, vpDayBuckets, vpRows, vpDayHigh, vpDayLow)
    vpDraw(vpDayBuckets, vpDayHigh, vpDayLow, vpDayStartBar, vpW,
         vpOutsideColor, vpInsideColor, showVPPOC, vpPOCColor,
         showVPVAHL, vpVAHLColor, vpBoxes, vpLines, vpLabels)

if isNYSessStart
    nyVPHigh := high, nyVPLow := low, nyVPStartBar := bar_index
    array.clear(nyVPAllHighs), array.clear(nyVPAllLows), array.clear(nyVPAllVols)

if barstate.isconfirmed and _vpActive and showNYVP_ and _vpEnabled and isNYSessWin and not isNYSessStart and not na(nyVPStartBar) and bar_index > nyVPStartBar
    nyVPHigh := math.max(nyVPHigh, high), nyVPLow := math.min(nyVPLow, low)
    for i = 0 to array.size(ltfHighs) - 1
        array.push(nyVPAllHighs, array.get(ltfHighs, i))
        array.push(nyVPAllLows,  array.get(ltfLows,  i))
        array.push(nyVPAllVols,  array.get(ltfVols,  i))
if barstate.isconfirmed and _vpActive and showNYVP_ and not _vpEnabled and isNYSessWin and not isNYSessStart and not na(nyVPStartBar) and bar_index > nyVPStartBar
    nyVPHigh := math.max(nyVPHigh, high), nyVPLow := math.min(nyVPLow, low)
    array.push(nyVPAllHighs, high), array.push(nyVPAllLows, low), array.push(nyVPAllVols, volume)

if (barstate.islast or barstate.isconfirmed) and _vpActive and showNYVP_ and not na(nyVPHigh) and not na(nyVPLow)
    int nyW = math.max(2, math.round(math.max(5, bar_index - nyVPStartBar) * nyVPWidthPct / 100))
    vpRecompute(nyVPAllHighs, nyVPAllLows, nyVPAllVols, nyVPBuckets, nyVPRows, nyVPHigh, nyVPLow)
    vpDraw(nyVPBuckets, nyVPHigh, nyVPLow, nyVPStartBar, nyW,
         nyVPOutsideC, nyVPInsideC, showNYVPPOC, nyVPPOCColor,
         showNYVPVAHL, nyVPVAHLColor, nyVPBoxes, nyVPLines, nyVPLabels)

// ═════════════════════════════════════════════════════════════════════════════
//  SMT DIVERGENCES
// ═════════════════════════════════════════════════════════════════════════════

[smt_comp_high, smt_comp_low] = request.security(smtCompSym, timeframe.period, [high, low], lookahead=barmerge.lookahead_off)
smtCompShort = str.contains(smtCompSym, ":") ? str.substring(smtCompSym, str.pos(smtCompSym, ":") + 1, str.length(smtCompSym)) : smtCompSym

var line[]  adj_up_lines     = array.new_line()
var label[] adj_up_labels    = array.new_label()
var float[] adj_up_comp_refs = array.new_float()
var line[]  adj_dn_lines     = array.new_line()
var label[] adj_dn_labels    = array.new_label()
var float[] adj_dn_comp_refs = array.new_float()

adj_hh_main = high > high[1], adj_hh_comp = smt_comp_high > smt_comp_high[1]
adj_ll_main = low  < low[1],  adj_ll_comp = smt_comp_low  < smt_comp_low[1]
adj_up_div  = smtEnableAdj and adj_hh_main and not adj_hh_comp
adj_dn_div  = smtEnableAdj and adj_ll_main and not adj_ll_comp

if showSMT_ and smtEnableAdj
    i = array.size(adj_up_lines) - 1
    while i >= 0
        if smt_comp_high > array.get(adj_up_comp_refs, i)
            line.delete(array.get(adj_up_lines,  i)), label.delete(array.get(adj_up_labels, i))
            array.remove(adj_up_lines, i), array.remove(adj_up_labels, i), array.remove(adj_up_comp_refs, i)
        i -= 1
    j = array.size(adj_dn_lines) - 1
    while j >= 0
        if smt_comp_low < array.get(adj_dn_comp_refs, j)
            line.delete(array.get(adj_dn_lines,  j)), label.delete(array.get(adj_dn_labels, j))
            array.remove(adj_dn_lines, j), array.remove(adj_dn_labels, j), array.remove(adj_dn_comp_refs, j)
        j -= 1
    if adj_up_div and not adj_up_div[1]
        array.push(adj_up_lines,     line.new(bar_index, high, bar_index - 1, high[1], color=smtLineColor, width=gLineWidth, style=line.style_dotted))
        array.push(adj_up_labels,    label.new(bar_index, high, smtCompShort, style=label.style_none, textcolor=smtTextColor, size=_gLblSz))
        array.push(adj_up_comp_refs, smt_comp_high[1])
    if adj_dn_div and not adj_dn_div[1]
        array.push(adj_dn_lines,     line.new(bar_index, low, bar_index - 1, low[1], color=smtLineColor, width=gLineWidth, style=line.style_dotted))
        array.push(adj_dn_labels,    label.new(bar_index, low, smtCompShort, style=label.style_none, textcolor=smtTextColor, size=_gLblSz))
        array.push(adj_dn_comp_refs, smt_comp_low[1])

var float _sPPhY_r = na, var float _sPPhS_r = na, var int _sPPhX_r = na
var float _sPlY_r  = na, var float _sPlS_r  = na, var int _sPlX_r  = na
var float _sPPhY_l = na, var float _sPPhS_l = na, var int _sPPhX_l = na
var float _sPlY_l  = na, var float _sPlS_l  = na, var int _sPlX_l  = na
var float _sPPhY_s = na, var float _sPPhS_s = na, var int _sPPhX_s = na
var float _sPlY_s  = na, var float _sPlS_s  = na, var int _sPlX_s  = na

smtPivCheck(float y2, float sy2, simple int _len, float y1r, float sy1r, int x1r) =>
    float ny1 = y1r, float ns1 = sy1r, int nx1 = x1r
    if y2 != y2[1] and sy2 != sy2[1]
        if not na(y1r) and not na(sy1r) and (y2 - y1r) * (sy2 - sy1r) < 0
            line.new(bar_index - _len, y2, x1r, y1r, color=smtLineColor, width=gLineWidth, style=line.style_dotted)
            label.new(x1r - 3, y1r, smtCompShort, style=label.style_none, textcolor=smtTextColor, size=_gLblSz)
        ny1 := y2, ns1 := sy2, nx1 := bar_index - _len
    [ny1, ns1, nx1]

if showSMT_ and smtEnablePivot
    _rph  = fixnan(ta.pivothigh(smtLength,      smtLength))
    _rpl  = fixnan(ta.pivotlow( smtLength,      smtLength))
    _cph  = fixnan(ta.pivothigh(smt_comp_high,  smtLength,      smtLength))
    _cpl  = fixnan(ta.pivotlow( smt_comp_low,   smtLength,      smtLength))
    [ny,  ns,  nx]  = smtPivCheck(_rph, _cph, smtLength,      _sPPhY_r, _sPPhS_r, _sPPhX_r)
    _sPPhY_r := ny,  _sPPhS_r := ns,  _sPPhX_r := nx
    [ny2, ns2, nx2] = smtPivCheck(_rpl, _cpl, smtLength,      _sPlY_r,  _sPlS_r,  _sPlX_r)
    _sPlY_r  := ny2, _sPlS_r  := ns2, _sPlX_r  := nx2

    _rphl = fixnan(ta.pivothigh(smtLengthLarge, smtLengthLarge))
    _rpll = fixnan(ta.pivotlow( smtLengthLarge, smtLengthLarge))
    _cphl = fixnan(ta.pivothigh(smt_comp_high,  smtLengthLarge, smtLengthLarge))
    _cpll = fixnan(ta.pivotlow( smt_comp_low,   smtLengthLarge, smtLengthLarge))
    [nyL,  nsL,  nxL]  = smtPivCheck(_rphl, _cphl, smtLengthLarge, _sPPhY_l, _sPPhS_l, _sPPhX_l)
    _sPPhY_l := nyL,  _sPPhS_l := nsL,  _sPPhX_l := nxL
    [nyL2, nsL2, nxL2] = smtPivCheck(_rpll, _cpll, smtLengthLarge, _sPlY_l,  _sPlS_l,  _sPlX_l)
    _sPlY_l  := nyL2, _sPlS_l  := nsL2, _sPlX_l  := nxL2

    _rphs = fixnan(ta.pivothigh(smtLengthSmall, smtLengthSmall))
    _rpls = fixnan(ta.pivotlow( smtLengthSmall, smtLengthSmall))
    _cphs = fixnan(ta.pivothigh(smt_comp_high,  smtLengthSmall, smtLengthSmall))
    _cpls = fixnan(ta.pivotlow( smt_comp_low,   smtLengthSmall, smtLengthSmall))
    [nyS,  nsS,  nxS]  = smtPivCheck(_rphs, _cphs, smtLengthSmall, _sPPhY_s, _sPPhS_s, _sPPhX_s)
    _sPPhY_s := nyS,  _sPPhS_s := nsS,  _sPPhX_s := nxS
    [nyS2, nsS2, nxS2] = smtPivCheck(_rpls, _cpls, smtLengthSmall, _sPlY_s,  _sPlS_s,  _sPlX_s)
    _sPlY_s  := nyS2, _sPlS_s  := nsS2, _sPlX_s  := nxS2

// ═════════════════════════════════════════════════════════════════════════════
//  FAIR VALUE GAPS
// ═════════════════════════════════════════════════════════════════════════════

var box[]   fvgBoxes     = array.new_box(0)
var line[]  fvgEQLines   = array.new_line(0)
var label[] fvgLabels    = array.new_label(0)
var float[] fvgTops      = array.new_float(0)
var float[] fvgBots      = array.new_float(0)
var bool[]  fvgIsBull    = array.new_bool(0)
var int[]   fvgStartBars = array.new_int(0)

if showFVG_ and array.size(fvgBoxes) > 0 and barstate.isconfirmed
    i = array.size(fvgBoxes) - 1
    while i >= 0
        _top  = array.get(fvgTops,   i)
        _bot  = array.get(fvgBots,   i)
        _bull = array.get(fvgIsBull, i)
        if fvgMitigate and ((_bull and close < _bot) or (not _bull and close > _top))
            box.delete(array.get(fvgBoxes, i))
            _eqLm = array.get(fvgEQLines, i)
            if not na(_eqLm)
                line.delete(_eqLm)
            label.delete(array.get(fvgLabels, i))
            array.remove(fvgBoxes,     i), array.remove(fvgEQLines,   i), array.remove(fvgLabels,    i)
            array.remove(fvgTops,      i), array.remove(fvgBots,      i)
            array.remove(fvgIsBull,    i), array.remove(fvgStartBars, i)
        i -= 1

if showFVG_ and barstate.isconfirmed and bar_index >= 2
    _fBullBot = high[2], _fBullTop = low[0]
    _fBearTop = low[2],  _fBearBot = high[0]
    bool inLB = bar_index >= last_bar_index - fvgLookback
    if _fBullBot < _fBullTop and inLB
        _fMid = (_fBullTop + _fBullBot) / 2
        _fL = bar_index - 2, _fR = _fL + fvgBoxLen
        array.push(fvgBoxes,    box.new(_fL, _fBullTop, _fR, _fBullBot, bgcolor=fvgBullColor, border_color=color.new(color.black,100), border_width=0))
        array.push(fvgTops,     _fBullTop), array.push(fvgBots,     _fBullBot)
        array.push(fvgIsBull,   true),      array.push(fvgStartBars, _fL)
        array.push(fvgEQLines,  showFVGEQ_ ? line.new(_fL, _fMid, _fR, _fMid, color=fvgEQColor, width=1, style=line.style_dashed) : na)
        array.push(fvgLabels,   label.new(_fL + fvgBoxLen / 2, _fMid, "FVG", color=color.new(color.black,100),
             textcolor=color.new(#00E676,0), style=label.style_none, size=_gLblSz, tooltip=_tip(_fMid)))
    if _fBearTop > _fBearBot and inLB
        _fMid = (_fBearTop + _fBearBot) / 2
        _fL = bar_index - 2, _fR = _fL + fvgBoxLen
        array.push(fvgBoxes,    box.new(_fL, _fBearTop, _fR, _fBearBot, bgcolor=fvgBearColor, border_color=color.new(color.black,100), border_width=0))
        array.push(fvgTops,     _fBearTop), array.push(fvgBots,     _fBearBot)
        array.push(fvgIsBull,   false),     array.push(fvgStartBars, _fL)
        array.push(fvgEQLines,  showFVGEQ_ ? line.new(_fL, _fMid, _fR, _fMid, color=fvgEQColor, width=1, style=line.style_dashed) : na)
        array.push(fvgLabels,   label.new(_fL + fvgBoxLen / 2, _fMid, "FVG", color=color.new(color.black,100),
             textcolor=color.new(#F23645,0), style=label.style_none, size=_gLblSz, tooltip=_tip(_fMid)))
    while array.size(fvgBoxes) > fvgMaxBoxes
        box.delete(array.shift(fvgBoxes))
        _eqOld = array.shift(fvgEQLines)
        if not na(_eqOld)
            line.delete(_eqOld)
        label.delete(array.shift(fvgLabels))
        array.shift(fvgTops), array.shift(fvgBots), array.shift(fvgIsBull), array.shift(fvgStartBars)

if showFVG_ and array.size(fvgBoxes) > 0
    for i = 0 to array.size(fvgBoxes) - 1
        _sBar = array.get(fvgStartBars, i)
        box.set_right(array.get(fvgBoxes, i), bar_index)
        _eqL = array.get(fvgEQLines, i)
        if not na(_eqL)
            line.set_x2(_eqL, bar_index)
        label.set_x(array.get(fvgLabels, i), _sBar + fvgBoxLen / 2)

// ═════════════════════════════════════════════════════════════════════════════
//  OVERNIGHT SESSION FIB
// ═════════════════════════════════════════════════════════════════════════════

var line[]  onFibLines     = array.new_line(0)
var label[] onFibLabels    = array.new_label(0)
var float[] histONFibHighs = array.new_float(0)
var float[] histONFibLows  = array.new_float(0)
var int[]   histONFibTimes = array.new_int(0)
var line[]  histONFibLines = array.new_line(0)
var label[] histONFibLbls  = array.new_label(0)

onFibLS  = lineStyleFromString(gLineStyle)
onFibExt = onFibExtend ? extend.right : extend.none
int _onFibMs = onFibBarLen * _tfMs

_onFibDraw(float lvl, float price, int startT, color col, bool showIt, line[] lArr, label[] lbArr) =>
    if showIt and not na(price)
        ln = line.new(startT, price, startT + _onFibMs, price,
             xloc=xloc.bar_time, color=col, width=gLineWidth, style=onFibLS, extend=onFibExt)
        array.push(lArr, ln)
        txt = str.tostring(lvl, "#.###") + "  (" + str.tostring(math.round(price, 2), "#.##") + ")"
        lb = label.new(startT, price, txt, xloc=xloc.bar_time, color=color.new(color.black,100),
             textcolor=col, style=label.style_label_right, size=_gLblSz, tooltip=_tip(price))
        array.push(lbArr, lb)

_onFibDrawAll(float fHigh, float fLow, int startT, color col, line[] lArr, label[] lbArr) =>
    if not na(fHigh) and not na(fLow) and fHigh != fLow
        float rng = fHigh - fLow
        _onFibDraw(0.236,  fLow + 0.236 * rng, startT, col, showFib0236,  lArr, lbArr)
        _onFibDraw(0.660,  fLow + 0.660 * rng, startT, col, showFib066,   lArr, lbArr)
        _onFibDraw(0.618,  fLow + 0.618 * rng, startT, col, showFib0618,  lArr, lbArr)
        _onFibDraw(0.786,  fLow + 0.786 * rng, startT, col, showFib0786,  lArr, lbArr)
        _onFibDraw(-0.236, fLow - 0.236 * rng, startT, col, showFibN0236, lArr, lbArr)
        _onFibDraw(-0.786, fLow - 0.786 * rng, startT, col, showFibN0786, lArr, lbArr)

if (showONFib_ or showHistONFib_) and isLonEnd and _tf1h
    float fibHigh = na, float fibLow = na
    if not na(asiaHigh) and not na(lonHigh) and not na(asiaLow) and not na(lonLow)
        if lonHigh > asiaHigh
            fibHigh := asiaLow,  fibLow := lonHigh
        else if lonLow < asiaLow
            fibHigh := asiaHigh, fibLow := lonLow
        else
            fibHigh := asiaHigh, fibLow := asiaLow

    if not na(fibHigh) and not na(fibLow) and fibHigh != fibLow
        for ol in onFibLines
            line.delete(ol)
        array.clear(onFibLines)
        for ol in onFibLabels
            label.delete(ol)
        array.clear(onFibLabels)
        for ol in histONFibLines
            line.delete(ol)
        array.clear(histONFibLines)
        for ol in histONFibLbls
            label.delete(ol)
        array.clear(histONFibLbls)

        if showHistONFib_
            array.unshift(histONFibHighs, fibHigh)
            array.unshift(histONFibLows,  fibLow)
            array.unshift(histONFibTimes, time)
            while array.size(histONFibHighs) > histONFibLookback
                array.pop(histONFibHighs), array.pop(histONFibLows), array.pop(histONFibTimes)

        if showONFib_
            _onFibDrawAll(fibHigh, fibLow, time, onFibColor, onFibLines, onFibLabels)

        if showHistONFib_ and array.size(histONFibHighs) >= 2
            color _hCol = color.new(histONFibColor, histONFibTransp)
            int _hFibSz = array.size(histONFibHighs)
            for k = 1 to _hFibSz - 1
                float _hH = array.get(histONFibHighs, k)
                float _hL = array.get(histONFibLows,  k)
                int   _hT = array.get(histONFibTimes, k)
                if not na(_hH) and not na(_hL) and _hH != _hL
                    _onFibDrawAll(_hH, _hL, _hT, _hCol, histONFibLines, histONFibLbls)
````
