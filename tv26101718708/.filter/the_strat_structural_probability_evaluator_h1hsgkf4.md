# The Strat Structural Probability Evaluator

- url: https://www.tradingview.com/script/H1HSgkF4-The-Strat-Structural-Probability-Evaluator/
- type: indicator
- pine_id: PUB;807b09aa642442b287c759d101e63ba0
- version: 14.0

## Description

The Strat Structural Probability Evaluator

Overview
The Strat Structural Probability Evaluator is a quantitative research tool designed to provide an objective, data-driven audit of price action within the framework of The Strat Combos and Broadening Formations. Rather than providing subjective signals, this script functions as a localized Statistical Engine that evaluates the historical success rate of specific Strat setups relative to the current market structure.

By projecting Higher Timeframe (HTF) boundaries onto the chart, the Evaluator calculates a "Structural Roadmap" and tracks how price interacts with these levels in real-time.

How the Engine Works

The script utilizes a Resolution Window logic to grade every historical setup. This Resolution Window is a user-defined number of bars in the future. When a valid Strat trigger occurs (e.g., 2-1-2 Reversals, Failed 2s, or Continuations), the engine initiates a "Shot Clock" (user-defined bar count--the Resolution Window). During this period, it monitors a race between four primary structural boundaries:

The Structural High (Red Line): The ceiling of the current Broadening Formation.

The Structural Low (Green Line): The floor of the current Broadening Formation.

The Reaction Zone (Blue Cloud): The 50%–70% retracement area of the anchor range.

The Hard Stop: The extreme of the signal bar that triggered the trade.

The Audit System

To maintain full transparency and enable manual user verification, every graded setup is stamped with an Audit Label. This allows the user to see exactly why a trade was categorized a certain way on the dashboard:

[H] High 1st: Price reached the structural ceiling before any other level.

[L] Low 1st: Price reached the structural floor before any other level.

[Z] Zone 1st: Price retraced into the "Reclaim" zone before expanding to an extreme.

[S] Stop 1st: Price violated the signal bar high/low before reaching a target.

[A] Ambiguous: High-volatility candle (Outside Bar) hit both a target and a stop in the same bar.

[T] Timeout: The resolution window expired while price was still in "No Man's Land."

Market Filtering

The real power of the Evaluator lies in identifying the Market Regime. By looking at the aggregated percentages in the dashboard, a trader can determine if the current environment favors:

Expansion (Trend): High "High 1st/Low 1st" percentages suggest momentum is front-running pullbacks.

Reversion (Range): High "Zone 1st" percentages suggest price is respecting the mean and requiring a deeper discount before moving.

Inversion (Choppy): High "Ambig" or "Stop" percentages suggest a lack of timeframe continuity and broadening volatility.

Automation & Data Export

Designed for the modern quantitative workflow, the Evaluator includes a JSON Webhook Integration. This allows users to exfiltrate real-time dashboard updates and historical audit data to external databases or spreadsheets for deeper cross-asset analysis.

Disclaimer: This script is an analytical tool for educational and research purposes only. It does not provide financial advice or automated buy/sell signals. Trading futures and equities involves significant risk; past performance as calculated by the engine does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("The Strat Structural Probability Evaluator v6.1", overlay=true, max_bars_back=5000, max_labels_count=500, max_lines_count=500)

// =====================================================
// 1) USER INPUTS
// =====================================================
grp_m = "Markov / Structure Settings"
tf = input.timeframe("240", "Structural Timeframe", group=grp_m)
bflb = input.int(70, "Structure Lookback", minval=1, group=grp_m)
zS = input.float(50.0, "Zone Floor %", group=grp_m) / 100.0
zE = input.float(70.0, "Zone Ceiling %", group=grp_m) / 100.0
win_in = input.int(20, "Resolution Window (Bars)", minval=1, maxval=200, group=grp_m)
slb_in = input.int(400, "Stat Lookback", minval=1, maxval=5000, group=grp_m)
skipOverlap = input.bool(true, "Skip Overlapping Signals", group=grp_m)
minSample = input.int(20, "Minimum Sample Warning Threshold", minval=1, group=grp_m)

grp_s = "Setup Toggles"
showF2 = input.bool(true, "Show Failed 2s", group=grp_s)
show22 = input.bool(true, "Show 2-2 Reversals", group=grp_s)
show212 = input.bool(true, "Show 2-1-2 Reversals", group=grp_s)
show312 = input.bool(true, "Show 3-1-2 Reversals", group=grp_s)
showCont = input.bool(true, "Show Continuations", group=grp_s)

grp_r = "Resolution / Stop Logic"
stopMode = input.string("Wick", "Stop Trigger", options=["Wick", "Close"], group=grp_r)
stopBufType = input.string("None", "Stop Buffer Type", options=["None", "Ticks", "Points", "ATR"], group=grp_r)
stopBufValue = input.float(0.0, "Stop Buffer Value", minval=0.0, step=0.25, group=grp_r)
atrLen = input.int(14, "ATR Length", minval=1, group=grp_r)
resolutionCountMode = input.string("Fully Aged Only", "Resolution Counting Mode", options=["Fully Aged Only", "Early Resolve / Pending Excluded"], group=grp_r)
earlyResolveMode = resolutionCountMode == "Early Resolve / Pending Excluded"

grp_v = "Visuals & Audit"
showStratTbl = input.bool(true, "Show Strat Probability Table", group=grp_v)
showAudit = input.bool(true, "Show Audit Marks", group=grp_v)
auditBars = input.int(150, "Audit Lookback Bars", minval=10, group=grp_v)
auditLabelSizeInput = input.string("Small", "Audit Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=grp_v)
extendR = input.bool(true, "Extend Structure Right", group=grp_v)
extBars = input.int(20, "Extension Bar Count", minval=1, group=grp_v)
highCol = input.color(color.new(color.red, 30), "BF High Color", group=grp_v)
lowCol = input.color(color.new(color.green, 30), "BF Low Color", group=grp_v)
zoneCol = input.color(color.new(color.blue, 90), "Zone Fill", group=grp_v)
tTxtCol = input.color(color.white, "Table Text Color", group=grp_v)
tHiCol = input.color(color.lime, "High Probability Highlight", group=grp_v)
tWarnCol = input.color(color.orange, "Low Sample Warning Color", group=grp_v)
tPosInput = input.string("Middle Right", "Table Position", options=["Top Right", "Middle Right", "Bottom Right", "Top Left", "Middle Left", "Bottom Left"], group=grp_v)
tSizeInput = input.string("Small", "Table Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=grp_v)
tBg = input.color(color.new(color.black, 10), "Table Background", group=grp_v)
tableLayoutMode = input.string("Full Desktop", "Table Layout Mode", options=["Full Desktop", "Compact Mobile"], group=grp_v)
showLowerBfDetailRows = input.bool(true, "Show Lower BF Detail Rows", group=grp_v)
hideRowsBelowMinSample = input.bool(false, "Hide Rows Below Min Sample", group=grp_v)

grp_cols = "Table Column Visibility"
showColZone = input.bool(true, "Show Zone 1st", group=grp_cols)
showColBzZ = input.bool(true, "Show BZ-Z", group=grp_cols)
showColAzZ = input.bool(true, "Show AZ-Z", group=grp_cols)
showColHigh = input.bool(true, "Show High 1st", group=grp_cols)
showColLow = input.bool(true, "Show Low 1st", group=grp_cols)
showColBzZh = input.bool(true, "Show BZ-Z-H", group=grp_cols)
showColAzZl = input.bool(true, "Show AZ-Z-L", group=grp_cols)
showColStop = input.bool(true, "Show Stop 1st", group=grp_cols)
showColAmbig = input.bool(true, "Show 1-Bar 2+ Hits", group=grp_cols)
showColCR = input.bool(true, "Show F2/2x/x C/R%", group=grp_cols)
showColRJ = input.bool(true, "Show F2 R F/X %", group=grp_cols)
showF2SequenceRows = input.bool(true, "Show F2 Sequence Rows", group=grp_cols)
show22SequenceRows = input.bool(true, "Show 2-2 Sequence Rows", group=grp_cols)
showCol22CR = input.bool(true, "Show 2-2-x C/R%", group=grp_cols)
showCol22FT = input.bool(true, "Show 2-2-x FThru/X%", group=grp_cols)
showBfBreakRows = input.bool(true, "Show RevStrat 3 Break C/R Rows", group=grp_cols)

showAmbigDetail = input.bool(true, "Show 1-Bar 2+ Hits Detail Row", group=grp_v)
showBzAzPathAudit = input.bool(false, "Show BZ/AZ Path Audit Marks", group=grp_v)
showBzAzDenomAudit = input.bool(true, "Show BZ/AZ Denominator Marks", group=grp_v)
showBzAzStageAudit = input.bool(true, "Show BZ-Z / AZ-Z Stage-One Marks", group=grp_v)
showBzAzHitAudit = input.bool(true, "Show BZ/AZ Completion Marks", group=grp_v)
showBzAzSourceAudit = input.bool(true, "Show BZ/AZ Source Marks For Hits", group=grp_v)
bzAzAuditLabelSizeInput = input.string("Normal", "BZ/AZ Audit Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=grp_v)
bzAzAuditLabelOffsetAtr = input.float(0.03, "BZ/AZ Audit Label Offset (ATR Mult)", minval=0.0, step=0.01, group=grp_v)
showSeqAudit = input.bool(false, "Show Specialty Sequence Audit Marks", group=grp_v)
showSeqAuditF2 = input.bool(true, "Audit F2 -> 2x -> x Sequences", group=grp_v)
showSeqAudit22 = input.bool(true, "Audit 2-2 -> x Sequences", group=grp_v)
seqAuditBars = input.int(150, "Specialty Sequence Audit Lookback Bars", minval=10, maxval=5000, group=grp_v)
seqAuditLabelSizeInput = input.string("Small", "Specialty Sequence Audit Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=grp_v)
seqAuditLabelOffsetAtr = input.float(0.06, "Specialty Sequence Audit Label Offset (ATR Mult)", minval=0.0, step=0.01, group=grp_v)

grp_w = "Webhook & Spreadsheet Export"
sendWebhook = input.bool(false, "Enable JSON Webhook Export", group=grp_w)
customTicker = input.string("MES", "Custom Sheet Ticker (e.g. MES, BTC)", group=grp_w)
includeMeta = input.bool(true, "Include Meta Fields In JSON", group=grp_w)

grp_bf = "Separate True BF Engine"
showTrueBFLabels = input.bool(true, "Show Separate True BF Labels", group=grp_bf)
bfEvalTf = input.timeframe("240", "True BF Evaluation Timeframe", group=grp_bf)
bfLookbackBars = input.int(400, "True BF Lookback Bars", minval=10, maxval=5000, group=grp_bf)

grp_perf = "Performance / Memory Safety"
maxStoredBars = input.int(6000, "Max Stored Chart Bars", minval=1000, maxval=6000, group=grp_perf)


grp_mk = "Markov Regime Permission Panel - Ultra Lite"
mkEn = input.bool(true, "Enable Markov Permission Panel", group=grp_mk)
mkSrc = input.source(close, "Markov Source", group=grp_mk)
mkLen = input.int(20, "Regime Lookback", minval=1, maxval=500, group=grp_mk)
mkLb = input.int(500, "Markov Transition Lookback (independent; max 5000)", minval=25, maxval=5000, group=grp_mk, tooltip="Independent from the main Strat Stat Lookback. TradingView historical references are limited to 5000 bars. Actual Markov loop is capped at 5000 minus Regime Lookback.")
mkMode = input.string("Auto Adaptive", "Threshold Mode", options=["Auto Adaptive", "Custom Fixed"], group=grp_mk)
mkVolLen = input.int(100, "Auto Volatility Lookback", minval=10, maxval=1000, group=grp_mk)
mkMult = input.float(1.0, "Auto Threshold Multiplier", step=0.05, group=grp_mk)
mkMinT = input.float(0.02, "Minimum Auto Threshold %", step=0.01, group=grp_mk)
mkMaxT = input.float(10.0, "Maximum Auto Threshold %", step=0.25, group=grp_mk)
mkBullFix = input.float(0.25, "Custom Bull Threshold %", step=0.05, group=grp_mk)
mkBearFix = input.float(-0.25, "Custom Bear Threshold %", step=0.05, group=grp_mk)
mkStrong = input.float(25.0, "Strong Signal Threshold %", step=1.0, group=grp_mk)
mkWeak = input.float(10.0, "Weak Edge Band %", step=1.0, group=grp_mk)
mkMinN = input.int(30, "Low Sample Warning Below", minval=1, group=grp_mk)
mkShow = input.bool(true, "Show Markov Panel Table", group=grp_mk)
mkShowFlip = input.bool(true, "Show Flip Level Row", group=grp_mk)
mkShowFc = input.bool(true, "Show 3/5 Bar Signal Row", group=grp_mk)
mkShowMx = input.bool(false, "Show Compact Markov Matrix % Row", group=grp_mk, tooltip="Adds one compact row showing the full transition matrix percentages. Each cell shows To Bull / To Side / To Bear for that starting state.")
mkShowAlign = input.bool(true, "Show Active Setup / Markov Behavior Row", group=grp_mk, tooltip="Shows a compact behavior read from active Strat setup, HTF bias, and Markov permission. No math changes.")
mkFL = input.bool(false, "Show Markov Flip Lines", group=grp_mk)
mkFLMode = input.string("Bull & Bear", "Flip Lines Shown", options=["Bull & Bear", "Bull Only", "Bear Only"], group=grp_mk)
mkFLStyle = input.string("Dashed", "Flip Line Style", options=["Solid", "Dashed", "Dotted"], group=grp_mk)
mkFLW = input.int(2, "Flip Line Width", minval=1, maxval=5, group=grp_mk)
mkFLBack = input.int(100, "Flip Line Bars Back", minval=1, maxval=5000, group=grp_mk)
mkPosInput = input.string("Top Right", "Markov Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp_mk)
mkSizeInput = input.string("Small", "Markov Table Text Size", options=["Tiny", "Small", "Normal"], group=grp_mk)
mkHeaderBg = input.color(color.rgb(35, 39, 52), "Header Background", group=grp_mk)
mkLabelBg = input.color(color.rgb(52, 57, 72), "Label Background", group=grp_mk)
mkDataBg = input.color(color.rgb(67, 72, 88), "Data Background", group=grp_mk)
mkTextCol = input.color(color.white, "Text Color", group=grp_mk)
mkBullCol = input.color(color.green, "Bull Color", group=grp_mk)
mkSideCol = input.color(color.orange, "Sideways Color", group=grp_mk)
mkBearCol = input.color(color.red, "Bear Color", group=grp_mk)

// =====================================================
// 2) TABLE POSITION / SIZE MAP
// =====================================================
tPos = switch tPosInput
    "Top Right" => position.top_right
    "Bottom Right" => position.bottom_right
    "Top Left" => position.top_left
    "Middle Left" => position.middle_left
    "Bottom Left" => position.bottom_left
    => position.middle_right

tSize = switch tSizeInput
    "Tiny" => size.tiny
    "Normal" => size.normal
    "Large" => size.large
    "Huge" => size.huge
    => size.small

auditLabelSize = switch auditLabelSizeInput
    "Tiny" => size.tiny
    "Normal" => size.normal
    "Large" => size.large
    "Huge" => size.huge
    => size.small

bzAzAuditLabelSize = switch bzAzAuditLabelSizeInput
    "Tiny" => size.tiny
    "Small" => size.small
    "Large" => size.large
    "Huge" => size.huge
    => size.normal

seqAuditLabelSize = switch seqAuditLabelSizeInput
    "Tiny" => size.tiny
    "Normal" => size.normal
    "Large" => size.large
    "Huge" => size.huge
    => size.small

bzAzAuditLabelOffset = ta.atr(atrLen) * bzAzAuditLabelOffsetAtr
seqAuditLabelOffset = ta.atr(atrLen) * seqAuditLabelOffsetAtr

// =====================================================
// 3) HELPERS / CONSTANTS / UDT
// =====================================================
int OUT_NONE = 0
int OUT_ZONE = 1
int OUT_HIGH = 2
int OUT_LOW = 3
int OUT_STOP = 4
int OUT_AMBIG = 5
int OUT_TIMEOUT = 6

type SignalData
    int f2U
    int f2D
    int s22U
    int s22D
    int s212U
    int s212D
    int s312U
    int s312D
    int contU
    int contD
    int dir
    int idx
    int t
    float h
    float l
    float c
    float curHtfH
    float curHtfL
    float mtfH
    float mtfL
    float zTop
    float zBot
    float stopBuf

type StatRes
    int count = 0
    int zoneFirst = 0
    int highFirst = 0
    int lowFirst = 0
    int stopFirst = 0
    int ambiguousFirst = 0
    int timeoutFirst = 0
    int bfFollow = 0
    int bfStop = 0
    int bfAmbig = 0
    int bfTimeout = 0
    int bzTotal = 0
    int bzZ = 0
    int bzZh = 0
    int azTotal = 0
    int azZ = 0
    int azZl = 0
    int tcTotal = 0
    int tcCont = 0
    int tcReclaim = 0
    int rjTotal = 0
    int rjFollow = 0
    int rjFail = 0
    int s22TcTotal = 0
    int s22TcCont = 0
    int s22TcReclaim = 0
    int s22FtTotal = 0
    int s22FtFollow = 0
    int s22FtFail = 0

f_pct(int hits, int total) =>
    float out = 0.0
    if total > 0
        out := (hits / float(total)) * 100.0
    out

f_pctStr(int hits, int total) =>
    str.tostring(f_pct(hits, total), "#.##") + "%"

f_pctStrCnt(int hits, int total) =>
    str.tostring(f_pct(hits, total), "#.##") + "% (" + str.tostring(hits) + ")"

f_pctStrFrac(int hits, int total) =>
    str.tostring(f_pct(hits, total), "#.##") + "% (" + str.tostring(hits) + "/" + str.tostring(total) + ")"

f_pctStrCntDisp(int hits, int total, bool compact) =>
    compact ? f_pctStr(hits, total) : f_pctStrCnt(hits, total)

f_pctStrFracDisp(int hits, int total, bool compact) =>
    compact ? f_pctStr(hits, total) : f_pctStrFrac(hits, total)

f_avgNumStr(float v) =>
    str.tostring(v, "#.##")

f_avgPctStr(float v) =>
    str.tostring(v, "#.##") + "%"

f_truthOddsStr(int cont, int reclaim) =>
    string out = "NA"
    int total = cont + reclaim
    if total > 0
        if cont > reclaim
            out := "C " + str.tostring(f_pct(cont, total), "#.##") + "%"
        else if reclaim > cont
            out := "R " + str.tostring(f_pct(reclaim, total), "#.##") + "%"
        else
            out := "Flat " + str.tostring(f_pct(cont, total), "#.##") + "%"
    out

f_truthWinnerStr(int cont, int reclaim) =>
    string out = "NA"
    int total = cont + reclaim
    if total > 0
        if cont > reclaim
            out := "C"
        else if reclaim > cont
            out := "R"
        else
            out := "Flat"
    out

f_truthOddsStrCnt(int cont, int reclaim) =>
    string out = f_truthOddsStr(cont, reclaim)
    int total = cont + reclaim
    if total > 0
        if cont > reclaim
            out := out + " (" + str.tostring(cont) + "/" + str.tostring(total) + ")"
        else if reclaim > cont
            out := out + " (" + str.tostring(reclaim) + "/" + str.tostring(total) + ")"
        else
            out := out + " (" + str.tostring(cont) + "/" + str.tostring(total) + ")"
    out

f_truthOddsStrDisp(int cont, int reclaim, bool compact) =>
    string out = ""
    if compact
        out := f_truthOddsStr(cont, reclaim)
    else
        out := f_truthOddsStrCnt(cont, reclaim)
    out

f_rjFollowStr(int follow, int fail) =>
    string out = "NA"
    int total = follow + fail
    if total > 0
        out := "F " + str.tostring(f_pct(follow, total), "#.##") + "% / X " + str.tostring(f_pct(fail, total), "#.##") + "%"
    out

f_rjFollowStrCnt(int follow, int fail) =>
    string out = f_rjFollowStr(follow, fail)
    int total = follow + fail
    if total > 0
        out := out + " (F " + str.tostring(follow) + " / X " + str.tostring(fail) + ", n=" + str.tostring(total) + ")"
    out

f_rjFollowStrDisp(int follow, int fail, bool compact) =>
    string out = ""
    if compact
        out := f_rjFollowStr(follow, fail)
    else
        out := f_rjFollowStrCnt(follow, fail)
    out

f_rjFollowColor(int follow, int fail, int minCnt, color hiColor, color normalColor) =>
    color out = normalColor
    int total = follow + fail
    if total > 0
        if follow > fail
            out := hiColor
        else if fail > follow
            out := color.red
        else
            out := color.yellow
    out

f_truthOddsColor(int cont, int reclaim, int minCnt, color hiColor, color normalColor) =>
    color out = normalColor
    int total = cont + reclaim
    if total > 0
        if cont > reclaim
            out := hiColor
        else if reclaim > cont
            out := color.red
        else
            out := color.yellow
    out

f_pctColor(int hits, int total, int minCnt, color hiColor, color normalColor) =>
    color out = normalColor
    float p = f_pct(hits, total)
    if total >= minCnt and p >= 55.0
        out := hiColor
    out

f_countBg(int total, int minCnt, color warnColor, color baseColor) =>
    color out = baseColor
    if total > 0 and total < minCnt
        out := color.new(warnColor, 75)
    out

f_outcomeText(int outcome) =>
    string txt = "T"
    if outcome == OUT_ZONE
        txt := "Z"
    else if outcome == OUT_HIGH
        txt := "H"
    else if outcome == OUT_LOW
        txt := "L"
    else if outcome == OUT_STOP
        txt := "S"
    else if outcome == OUT_AMBIG
        txt := "2+"
    else if outcome == OUT_TIMEOUT
        txt := "T"
    txt

f_outcomeColor(int outcome) =>
    color c = color.gray
    if outcome == OUT_ZONE
        c := color.aqua
    else if outcome == OUT_HIGH
        c := color.lime
    else if outcome == OUT_LOW
        c := color.fuchsia
    else if outcome == OUT_STOP
        c := color.red
    else if outcome == OUT_AMBIG
        c := color.yellow
    else if outcome == OUT_TIMEOUT
        c := color.gray
    c

f_setupText(bool isF2U, bool isF2D, bool is22U, bool is22D, bool is212U, bool is212D, bool is312U, bool is312D, bool isContU, bool isContD) =>
    string txt = ""
    if isF2U
        txt := "F2U"
    else if isF2D
        txt := "F2D"
    else if is22U
        txt := "22U"
    else if is22D
        txt := "22D"
    else if is212U
        txt := "212U"
    else if is212D
        txt := "212D"
    else if is312U
        txt := "312U"
    else if is312D
        txt := "312D"
    else if isContU
        txt := "CONTU"
    else if isContD
        txt := "CONTD"
    txt

f_addSetupToList(string current, string item) =>
    string out = current
    if out == ""
        out := item
    else
        out := out + "/" + item
    out

f_setupAuditText(bool isF2U, bool isF2D, bool is22U, bool is22D, bool is212U, bool is212D, bool is312U, bool is312D, bool isContU, bool isContD) =>
    string txt = ""
    if showF2 and isF2U
        txt := f_addSetupToList(txt, "F2U")
    if showF2 and isF2D
        txt := f_addSetupToList(txt, "F2D")
    if show22 and is22U
        txt := f_addSetupToList(txt, "22U")
    if show22 and is22D
        txt := f_addSetupToList(txt, "22D")
    if show212 and is212U
        txt := f_addSetupToList(txt, "212U")
    if show212 and is212D
        txt := f_addSetupToList(txt, "212D")
    if show312 and is312U
        txt := f_addSetupToList(txt, "312U")
    if show312 and is312D
        txt := f_addSetupToList(txt, "312D")
    if showCont and isContU
        txt := f_addSetupToList(txt, "CONTU")
    if showCont and isContD
        txt := f_addSetupToList(txt, "CONTD")
    txt

f_setupRowLabel(string setupName) =>
    string txt = setupName
    if setupName == "Failed 2 Up"
        txt := "▼ Failed 2 Up"
    else if setupName == "Failed 2 Down"
        txt := "▲ Failed 2 Down"
    else if setupName == "2-2 Rev Up"
        txt := "● 2-2 Rev Up"
    else if setupName == "2-2 Rev Down"
        txt := "● 2-2 Rev Down"
    else if setupName == "2-1-2 Rev Up"
        txt := "◆ 2-1-2 Rev Up"
    else if setupName == "2-1-2 Rev Down"
        txt := "◆ 2-1-2 Rev Down"
    else if setupName == "3-1-2 Rev Up"
        txt := "■ 3-1-2 Rev Up"
    else if setupName == "3-1-2 Rev Down"
        txt := "■ 3-1-2 Rev Down"
    txt

f_setupRowLabelShort(string setupName) =>
    string txt = setupName
    if setupName == "Failed 2 Up"
        txt := "F2U"
    else if setupName == "Failed 2 Down"
        txt := "F2D"
    else if setupName == "2-2 Rev Up"
        txt := "22U"
    else if setupName == "2-2 Rev Down"
        txt := "22D"
    else if setupName == "2-1-2 Rev Up"
        txt := "212U"
    else if setupName == "2-1-2 Rev Down"
        txt := "212D"
    else if setupName == "3-1-2 Rev Up"
        txt := "312U"
    else if setupName == "3-1-2 Rev Down"
        txt := "312D"
    else if setupName == "Cont Up"
        txt := "CU"
    else if setupName == "Cont Down"
        txt := "CD"
    txt

f_setupRowLabelDisp(string setupName, bool compact) =>
    compact ? f_setupRowLabelShort(setupName) : f_setupRowLabel(setupName)


mkS(float r, float bt, float rt) =>
    int s = 0
    if r >= bt
        s := 1
    else if r <= rt
        s := -1
    s

mkTxt(int s) =>
    string x = "Sideways"
    if s == 1
        x := "Bull"
    else if s == -1
        x := "Bear"
    x

mkPct(int a, int b) =>
    b > 0 ? a * 100.0 / b : na

mkFmt(float x) =>
    na(x) ? "n/a" : str.tostring(x, "#.##") + "%"

mkPx(float x) =>
    na(x) ? "n/a" : str.tostring(x, format.mintick)

mkBgState(int s) =>
    s == 1 ? color.new(mkBullCol, 25) : s == -1 ? color.new(mkBearCol, 25) : color.new(mkSideCol, 25)

mkBgPath(string p) =>
    p == "Bull" ? color.new(mkBullCol, 60) : p == "Bear" ? color.new(mkBearCol, 60) : p == "Sideways" ? color.new(mkSideCol, 60) : mkDataBg

mkPos(string x) =>
    x == "Top Left" ? position.top_left : x == "Bottom Right" ? position.bottom_right : x == "Bottom Left" ? position.bottom_left : position.top_right

mkSz(string x) =>
    x == "Tiny" ? size.tiny : x == "Normal" ? size.normal : size.small

mkThresh(float src, simple int len) =>
    float one = na(src[1]) or src[1] == 0.0 ? na : ((src / src[1]) - 1.0) * 100.0
    float vol = ta.stdev(one, mkVolLen) * math.sqrt(len * 1.0) * mkMult
    float autoT = na(vol) ? na : math.min(math.max(vol, math.max(mkMinT, 0.0)), math.max(mkMaxT, mkMinT))
    float bt = mkMode == "Auto Adaptive" ? autoT : mkBullFix
    float rt = mkMode == "Auto Adaptive" ? -autoT : mkBearFix
    [bt, rt, autoT]

mkVb(float b, float s, float r, float bb, float sb, float rb) =>
    (b * bb + s * sb + r * rb) / 100.0

mkVs(float b, float s, float r, float bs, float ss, float rs) =>
    (b * bs + s * ss + r * rs) / 100.0

mkVr(float b, float s, float r, float br, float sr, float rr) =>
    (b * br + s * sr + r * rr) / 100.0

mkPath(float b, float s, float r) =>
    string p = "n/a"
    if not na(b) and not na(s) and not na(r)
        p := b >= s and b >= r ? "Bull" : r >= b and r >= s ? "Bear" : "Sideways"
    p

mkMatrix(float src, simple int len, simple int req, float bt, float rt, bool on) =>
    int cs = 0
    float rn = na
    if on and bar_index >= len and not na(src[len]) and src[len] != 0.0
        rn := ((src / src[len]) - 1.0) * 100.0
        cs := mkS(rn, bt, rt)
    int used = 0
    int bb = 0
    int bs = 0
    int br = 0
    int sb = 0
    int ss = 0
    int sr = 0
    int rb = 0
    int rs = 0
    int rr = 0
    int maxUse = math.min(req, math.max(1, 5000 - len))
    int avail = math.max(0, bar_index - len)
    used := math.min(maxUse, avail)
    if on and used >= 1
        for i = 1 to used
            float fr = na
            float tr = na
            if not na(src[i + len]) and src[i + len] != 0.0 and not na(src[i - 1 + len]) and src[i - 1 + len] != 0.0
                fr := ((src[i] / src[i + len]) - 1.0) * 100.0
                tr := ((src[i - 1] / src[i - 1 + len]) - 1.0) * 100.0
            int f = na(fr) ? 0 : mkS(fr, bt, rt)
            int t = na(tr) ? 0 : mkS(tr, bt, rt)
            if f == 1 and t == 1
                bb += 1
            else if f == 1 and t == 0
                bs += 1
            else if f == 1 and t == -1
                br += 1
            else if f == 0 and t == 1
                sb += 1
            else if f == 0 and t == 0
                ss += 1
            else if f == 0 and t == -1
                sr += 1
            else if f == -1 and t == 1
                rb += 1
            else if f == -1 and t == 0
                rs += 1
            else if f == -1 and t == -1
                rr += 1
    int bd = bb + bs + br
    int sd = sb + ss + sr
    int rd = rb + rs + rr
    float bbp = mkPct(bb, bd)
    float bsp = mkPct(bs, bd)
    float brp = mkPct(br, bd)
    float sbp = mkPct(sb, sd)
    float ssp = mkPct(ss, sd)
    float srp = mkPct(sr, sd)
    float rbp = mkPct(rb, rd)
    float rsp = mkPct(rs, rd)
    float rrp = mkPct(rr, rd)
    float p1b = cs == 1 ? bbp : cs == -1 ? rbp : sbp
    float p1s = cs == 1 ? bsp : cs == -1 ? rsp : ssp
    float p1r = cs == 1 ? brp : cs == -1 ? rrp : srp
    float p2b = mkVb(p1b, p1s, p1r, bbp, sbp, rbp)
    float p2s = mkVs(p1b, p1s, p1r, bsp, ssp, rsp)
    float p2r = mkVr(p1b, p1s, p1r, brp, srp, rrp)
    float p3b = mkVb(p2b, p2s, p2r, bbp, sbp, rbp)
    float p3r = mkVr(p2b, p2s, p2r, brp, srp, rrp)
    float p4b = mkVb(p3b, mkVs(p2b, p2s, p2r, bsp, ssp, rsp), p3r, bbp, sbp, rbp)
    float p4s = mkVs(p3b, mkVs(p2b, p2s, p2r, bsp, ssp, rsp), p3r, bsp, ssp, rsp)
    float p4r = mkVr(p3b, mkVs(p2b, p2s, p2r, bsp, ssp, rsp), p3r, brp, srp, rrp)
    float p5b = mkVb(p4b, p4s, p4r, bbp, sbp, rbp)
    float p5r = mkVr(p4b, p4s, p4r, brp, srp, rrp)
    [cs, rn, used, bd, sd, rd, p1b, p1s, p1r, p3b, p3r, p5b, p5r, bbp, bsp, brp, sbp, ssp, srp, rbp, rsp, rrp]

mkPerm(float sig, int n) =>
    string p = "Wait / Chop"
    if n > 0 and n < mkMinN
        p := "Low sample"
    else if sig >= mkStrong
        p := "Aggressive Long"
    else if sig > mkWeak
        p := "Cautious Long"
    else if sig <= -mkStrong
        p := "Aggressive Short"
    else if sig < -mkWeak
        p := "Cautious Short"
    p

mkPermDir(string p) =>
    int d = 0
    if str.contains(p, "Long")
        d := 1
    else if str.contains(p, "Short")
        d := -1
    d

mkDirTxt(int d) =>
    string x = "None"
    if d == 1
        x := "Long"
    else if d == -1
        x := "Short"
    x

mkHtfTxt(int d) =>
    string x = "HTF Bear"
    if d == 1
        x := "HTF Bull"
    x

mkAlignTxt(int stratD, int markovD, int htfD) =>
    string x = "No live setup"
    if stratD == 0
        x := "No live setup"
    else if markovD == 0
        if stratD == htfD
            if stratD == 1
                x := "Long setup in chop / faster targets"
            else
                x := "Short setup in chop / faster targets"
        else
            if stratD == 1
                x := "Long not clean: chop + Bear HTF"
            else
                x := "Short not clean: chop + Bull HTF"
    else if stratD == markovD and stratD == htfD
        if stratD == 1
            x := "Long setup confirmed"
        else
            x := "Short setup confirmed"
    else if stratD == markovD
        if stratD == 1
            x := "Favor long continuation"
        else
            x := "Favor short continuation"
    else if markovD == htfD
        if markovD == 1
            x := "Favor longs / short counter-regime"
        else
            x := "Favor shorts / long counter-regime"
    else
        x := "Mixed: wait for confirmation"
    x

mkAlignBg(int stratD, int markovD, int htfD) =>
    color c = mkDataBg
    if stratD == 0
        c := mkDataBg
    else if markovD == 0
        c := color.new(mkSideCol, 60)
    else if stratD == markovD and stratD == htfD
        c := stratD == 1 ? color.new(mkBullCol, 45) : color.new(mkBearCol, 45)
    else if stratD == markovD
        c := stratD == 1 ? color.new(mkBullCol, 60) : color.new(mkBearCol, 60)
    else
        c := color.new(mkSideCol, 70)
    c

mkCell(table tb, int c, int r, string txt, color bg, sz) =>
    table.cell(tb, c, r, txt, text_color=mkTextCol, bgcolor=bg, text_size=sz)

[bfEvalTime, bfEvalLabelTime, bfEvalAnchorHigh, bfEvalAnchorLow, bfEvalPairHigh, bfEvalPairLow] = request.security(
     syminfo.tickerid, 
     bfEvalTf, 
     [time, time[1], high[3], low[3], math.max(high[1], high[2]), math.min(low[1], low[2])], 
     gaps=barmerge.gaps_off
 )

bfEvalUpBreak = bfEvalPairHigh > bfEvalAnchorHigh
bfEvalDownBreak = bfEvalPairLow < bfEvalAnchorLow
bfEvalUpOnly = bfEvalUpBreak and not bfEvalDownBreak
bfEvalDownOnly = bfEvalDownBreak and not bfEvalUpBreak
bfEvalBoth = bfEvalUpBreak and bfEvalDownBreak
bfEvalNewBar = ta.change(bfEvalTime) != 0

// =====================================================
// 4) ANCHORED MTF STRUCTURE (LOCKED TO CLOSED HTF)
// =====================================================
[mtfH, mtfL, mtfO, mtfC] = request.security(
     syminfo.tickerid,
     tf,
     [ta.highest(high, bflb)[1], ta.lowest(low, bflb)[1], open[1], close[1]],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on
)

rangeMTF = mtfH - mtfL
isBullHTF = mtfC >= mtfO

float z1 = na
float z2 = na
if isBullHTF
    z1 := mtfH - (rangeMTF * zS)
    z2 := mtfH - (rangeMTF * zE)
else
    z1 := mtfL + (rangeMTF * zS)
    z2 := mtfL + (rangeMTF * zE)

zTop = math.max(z1, z2)
zBot = math.min(z1, z2)

// Developing HTF candle high/low for location-aware outside-structure resolution.
// These are built on the chart timeframe so the value is snapshotted as it existed when each setup fired.
htfNowTime = time(tf)
htfNowNewBar = ta.change(htfNowTime) != 0
var float curHtfH = na
var float curHtfL = na
if htfNowNewBar or na(curHtfH) or na(curHtfL)
    curHtfH := high
    curHtfL := low
else
    curHtfH := math.max(curHtfH, high)
    curHtfL := math.min(curHtfL, low)

plot(mtfH, "BF High", color=highCol, linewidth=2, style=plot.style_linebr)
plot(mtfL, "BF Low", color=lowCol, linewidth=2, style=plot.style_linebr)
pZT = plot(zTop, "Zone Top", color=color.new(color.gray, 50), style=plot.style_linebr)
pZB = plot(zBot, "Zone Bottom", color=color.new(color.gray, 50), style=plot.style_linebr)
fill(pZT, pZB, color=zoneCol, title="Reaction Zone")

// =====================================================
// 5) RIGHT-SIDE EXTENSIONS (REUSED OBJECTS)
// =====================================================
var line exH = na
var line exL = na
var line exZT = na
var line exZB = na
var linefill exFill = na

if barstate.islast
    if extendR
        int targetBar = bar_index + extBars

        if na(exH)
            exH := line.new(bar_index, mtfH, targetBar, mtfH, color=highCol, width=2)
        else
            line.set_xy1(exH, bar_index, mtfH)
            line.set_xy2(exH, targetBar, mtfH)
            line.set_color(exH, highCol)
            line.set_width(exH, 2)

        if na(exL)
            exL := line.new(bar_index, mtfL, targetBar, mtfL, color=lowCol, width=2)
        else
            line.set_xy1(exL, bar_index, mtfL)
            line.set_xy2(exL, targetBar, mtfL)
            line.set_color(exL, lowCol)
            line.set_width(exL, 2)

        if na(exZT)
            exZT := line.new(bar_index, zTop, targetBar, zTop, color=color.new(color.gray, 50), width=1, style=line.style_dashed)
        else
            line.set_xy1(exZT, bar_index, zTop)
            line.set_xy2(exZT, targetBar, zTop)
            line.set_color(exZT, color.new(color.gray, 50))
            line.set_style(exZT, line.style_dashed)

        if na(exZB)
            exZB := line.new(bar_index, zBot, targetBar, zBot, color=color.new(color.gray, 50), width=1, style=line.style_dashed)
        else
            line.set_xy1(exZB, bar_index, zBot)
            line.set_xy2(exZB, targetBar, zBot)
            line.set_color(exZB, color.new(color.gray, 50))
            line.set_style(exZB, line.style_dashed)

        if na(exFill)
            exFill := linefill.new(exZT, exZB, zoneCol)
    else
        if not na(exH)
            line.delete(exH)
            exH := na
        if not na(exL)
            line.delete(exL)
            exL := na
        if not na(exZT)
            line.delete(exZT)
            exZT := na
        if not na(exZB)
            line.delete(exZB)
            exZB := na
        if not na(exFill)
            linefill.delete(exFill)
            exFill := na

// =====================================================
// 6) THESTRAT SETUP LOGIC
// =====================================================
is2U = high > high[1] and low >= low[1]
is2D = low < low[1] and high <= high[1]
is1 = high <= high[1] and low >= low[1]
is3 = high > high[1] and low < low[1]

f2D_R = low < low[1] and high <= high[1] and close > open
f2U_R = high > high[1] and low >= low[1] and close < open

s22_U = is2D[1] and is2U and high > high[1]
s22_D = is2U[1] and is2D and low < low[1]

s212_U = is2D[2] and is1[1] and is2U and high > high[1]
s212_D = is2U[2] and is1[1] and is2D and low < low[1]

s312_U = is3[2] and is1[1] and is2U and high > high[1]
s312_D = is3[2] and is1[1] and is2D and low < low[1]

contU = (is2U[1] and is2U) or (is2U[2] and is1[1] and is2U)
contD = (is2D[1] and is2D) or (is2D[2] and is1[1] and is2D)

plotshape(showF2 and f2D_R, title="F2D", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.tiny)
plotshape(showF2 and f2U_R, title="F2U", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny)
plotshape(show22 and s22_U, title="2-2 U", style=shape.circle, location=location.belowbar, color=color.lime, size=size.tiny)
plotshape(show22 and s22_D, title="2-2 D", style=shape.circle, location=location.abovebar, color=color.red, size=size.tiny)
plotshape(show212 and s212_U, title="2-1-2 U", style=shape.diamond, location=location.belowbar, color=color.lime, size=size.tiny)
plotshape(show212 and s212_D, title="2-1-2 D", style=shape.diamond, location=location.abovebar, color=color.red, size=size.tiny)
plotshape(show312 and s312_U, title="3-1-2 U", style=shape.square, location=location.belowbar, color=color.lime, size=size.tiny)
plotshape(show312 and s312_D, title="3-1-2 D", style=shape.square, location=location.abovebar, color=color.red, size=size.tiny)

// =====================================================
// 7) STOP BUFFER CALC
// =====================================================
float stopBufferNow = 0.0
if stopBufType == "None"
    stopBufferNow := 0.0
else if stopBufType == "Ticks"
    stopBufferNow := syminfo.mintick * stopBufValue
else if stopBufType == "Points"
    stopBufferNow := stopBufValue
else if stopBufType == "ATR"
    stopBufferNow := ta.atr(atrLen) * stopBufValue

// =====================================================
// 8) UDT ARRAY STORAGE 
// =====================================================
var array<SignalData> sigs = array.new<SignalData>()

bool bullSetupNow = false
bool bearSetupNow = false

if f2D_R or s22_U or s212_U or s312_U or contU
    bullSetupNow := true
if f2U_R or s22_D or s212_D or s312_D or contD
    bearSetupNow := true

int dirNow = 0
if bullSetupNow and not bearSetupNow
    dirNow := 1
else if bearSetupNow and not bullSetupNow
    dirNow := -1

array.push(sigs, SignalData.new(
     f2U_R ? 1 : 0, f2D_R ? 1 : 0, s22_U ? 1 : 0, s22_D ? 1 : 0,
     s212_U ? 1 : 0, s212_D ? 1 : 0, s312_U ? 1 : 0, s312_D ? 1 : 0,
     contU ? 1 : 0, contD ? 1 : 0,
     dirNow, bar_index, time, high, low, close,
     curHtfH, curHtfL, mtfH, mtfL, zTop, zBot, stopBufferNow
 ))

int chartTfSec = timeframe.in_seconds(timeframe.period)
int bfTfSec = timeframe.in_seconds(bfEvalTf)
float bfBarsNeededFloat = bfLookbackBars
if chartTfSec > 0 and bfTfSec > 0
    bfBarsNeededFloat := math.ceil((bfLookbackBars * bfTfSec) / chartTfSec)
int statKeepBars = slb_in + win_in + 100
int bfKeepBars = int(bfBarsNeededFloat) + win_in + 100
int rawKeepBars = math.max(statKeepBars, bfKeepBars)
int keepBars = math.min(rawKeepBars, maxStoredBars)
bool memoryCapActive = rawKeepBars > keepBars

while array.size(sigs) > keepBars
    array.shift(sigs)

// =====================================================
// 9) STATS ENGINE
// =====================================================
var StatRes rF2U = StatRes.new()
var StatRes rF2D = StatRes.new()
var StatRes r22U = StatRes.new()
var StatRes r22D = StatRes.new()
var StatRes r212U = StatRes.new()
var StatRes r212D = StatRes.new()
var StatRes r312U = StatRes.new()
var StatRes r312D = StatRes.new()
var StatRes rContU = StatRes.new()
var StatRes rContD = StatRes.new()

var array<label> auditLabels = array.new<label>()
var array<int> auditLabelBars = array.new_int()
var array<label> trueBFLabels = array.new<label>()

var string lastLoggedTxt = "None"
var int lastLoggedBar = na
var int trueBFUpCount = 0
var int trueBFDownCount = 0
var int trueBFBothCount = 0
var int trueBFTotalCount = 0
var int trueBFSetupTotal = 0
var float trueBFPctOfSetups = 0.0
var int ambigZoneHighCount = 0
var int ambigZoneLowCount = 0
var int ambigZoneStopCount = 0
var int ambigHighLowCount = 0
var int ambigHighStopCount = 0
var int ambigLowStopCount = 0
var int ambigThreePlusCount = 0
var int bfBreakUpTotal = 0
var int bfBreakUpCont = 0
var int bfBreakUpReclaim = 0
var int bfBreakUpFollow = 0
var int bfBreakUpFail = 0
var int bfBreakDownTotal = 0
var int bfBreakDownCont = 0
var int bfBreakDownReclaim = 0
var int bfBreakDownFollow = 0
var int bfBreakDownFail = 0

if barstate.islast
    rF2U := StatRes.new()    
    rF2D := StatRes.new()
    r22U := StatRes.new()
    r22D := StatRes.new()
    r212U := StatRes.new()
    r212D := StatRes.new()
    r312U := StatRes.new()
    r312D := StatRes.new()
    rContU := StatRes.new()
    rContD := StatRes.new()

    lastLoggedTxt := "None"
    lastLoggedBar := na

    int oldLabelCount = array.size(auditLabels)
    if oldLabelCount > 0
        for d = 0 to oldLabelCount - 1
            label.delete(array.get(auditLabels, d))
    array.clear(auditLabels)
    array.clear(auditLabelBars)

    int oldTrueBFLabelCount = array.size(trueBFLabels)
    if oldTrueBFLabelCount > 0
        for d = 0 to oldTrueBFLabelCount - 1
            label.delete(array.get(trueBFLabels, d))
    array.clear(trueBFLabels)

    trueBFUpCount := 0
    trueBFDownCount := 0
    trueBFBothCount := 0
    trueBFTotalCount := 0
    trueBFSetupTotal := 0
    trueBFPctOfSetups := 0.0
    ambigZoneHighCount := 0
    ambigZoneLowCount := 0
    ambigZoneStopCount := 0
    ambigHighLowCount := 0
    ambigHighStopCount := 0
    ambigLowStopCount := 0
    ambigThreePlusCount := 0
    bfBreakUpTotal := 0
    bfBreakUpCont := 0
    bfBreakUpReclaim := 0
    bfBreakUpFollow := 0
    bfBreakUpFail := 0
    bfBreakDownTotal := 0
    bfBreakDownCont := 0
    bfBreakDownReclaim := 0
    bfBreakDownFollow := 0
    bfBreakDownFail := 0

    int aSz = array.size(sigs)
    int lastClosedSigIndex = barstate.isconfirmed ? aSz - 1 : aSz - 2
    int st = 0
    int en = 0
    if earlyResolveMode
        st := math.max(0, aSz - slb_in)
        en := aSz - 2
    else
        st := math.max(0, aSz - slb_in - win_in)
        en := aSz - win_in - 1
    int statsStartBar = na
    int statsEndBar = na
    if en >= st
        statsStartBar := array.get(sigs, st).idx
        statsEndBar := array.get(sigs, en).idx
    int lockUntil = -1

    if en >= st
        for i = st to en
            SignalData sObj = array.get(sigs, i)
            bool hasSignal = false
            if showF2 and sObj.f2U == 1
                hasSignal := true
            if showF2 and sObj.f2D == 1
                hasSignal := true
            if show22 and sObj.s22U == 1
                hasSignal := true
            if show22 and sObj.s22D == 1
                hasSignal := true
            if show212 and sObj.s212U == 1
                hasSignal := true
            if show212 and sObj.s212D == 1
                hasSignal := true
            if show312 and sObj.s312U == 1
                hasSignal := true
            if show312 and sObj.s312D == 1
                hasSignal := true
            if showCont and sObj.contU == 1
                hasSignal := true
            if showCont and sObj.contD == 1
                hasSignal := true

            bool canCount = hasSignal
            if skipOverlap and i <= lockUntil
                canCount := false

            if canCount
                int outcome = OUT_TIMEOUT
                int firstBarUsed = win_in
                int maxForwardBars = win_in
                if earlyResolveMode
                    maxForwardBars := math.min(win_in, aSz - i - 1)
                bool pendingSignal = false
                bool bfFollowPending = false
                int bfOutcome = OUT_TIMEOUT
                string ambigDetailTxt = ""

                bool sigBull = sObj.dir == 1
                bool sigBear = sObj.dir == -1

                float sigHigh = sObj.h
                float sigLow = sObj.l
                float sigStructHigh = sObj.mtfH
                float sigStructLow = sObj.mtfL
                float sigZoneTop = sObj.zTop
                float sigZoneBot = sObj.zBot
                float sigStopBuf = sObj.stopBuf
                float sigClose = sObj.c
                bool sigBelowZone = sigClose < sigZoneBot
                bool sigAboveZone = sigClose > sigZoneTop
                float sigCurrentHtfHigh = sObj.curHtfH
                float sigCurrentHtfLow = sObj.curHtfL
                bool sigBelowStructLow = sigClose < sigStructLow
                bool sigAboveStructHigh = sigClose > sigStructHigh
                bool sigStartedBelowZone = sigHigh < sigZoneBot
                bool sigStartedAboveZone = sigLow > sigZoneTop
                bool sigStartedInZone = not sigStartedBelowZone and not sigStartedAboveZone
                bool zoneLeftAfterSetup = false
                int zonePathOutcome = OUT_TIMEOUT
                bool firstZoneNow = false
                bool firstEventIncludedStop = false

                for j = 1 to maxForwardBars
                    SignalData sObj_j = array.get(sigs, i + j)
                    float barH = sObj_j.h
                    float barL = sObj_j.l
                    float barC = sObj_j.c

                    bool zoneNow = false
                    bool highNow = false
                    bool lowNow = false
                    bool stopNow = false

                    bool barZoneOverlap = barH >= sigZoneBot and barL <= sigZoneTop
                    if sigStartedInZone
                        if zoneLeftAfterSetup and barZoneOverlap
                            zoneNow := true
                        if not barZoneOverlap
                            if barH < sigZoneBot or barL > sigZoneTop
                                zoneLeftAfterSetup := true
                    else
                        if barZoneOverlap
                            zoneNow := true

                    bool oldHighRetestNow = barH >= sigStructHigh and barL <= sigStructHigh
                    bool oldLowRetestNow = barH >= sigStructLow and barL <= sigStructLow
                    bool currentHtfHighBreakNow = barH >= sigCurrentHtfHigh
                    bool currentHtfLowBreakNow = barL <= sigCurrentHtfLow

                    if sigAboveStructHigh
                        if oldHighRetestNow or currentHtfHighBreakNow
                            highNow := true
                    else
                        if barH >= sigStructHigh
                            highNow := true

                    if sigBelowStructLow
                        if oldLowRetestNow or currentHtfLowBreakNow
                            lowNow := true
                    else
                        if barL <= sigStructLow
                            lowNow := true

                    if sigBull
                        float stopLvlBull = sigLow - sigStopBuf
                        if stopMode == "Wick"
                            if barL < stopLvlBull
                                stopNow := true
                        else
                            if barC < stopLvlBull
                                stopNow := true

                    if sigBear
                        float stopLvlBear = sigHigh + sigStopBuf
                        if stopMode == "Wick"
                            if barH > stopLvlBear
                                stopNow := true
                        else
                            if barC > stopLvlBear
                                stopNow := true

                    int eventCount = 0
                    if zoneNow
                        eventCount += 1
                    if highNow
                        eventCount += 1
                    if lowNow
                        eventCount += 1
                    if stopNow
                        eventCount += 1

                    if eventCount > 0
                        firstZoneNow := zoneNow
                        firstEventIncludedStop := stopNow
                        firstBarUsed := j
                        if eventCount > 1
                            outcome := OUT_AMBIG
                            if eventCount >= 3
                                ambigDetailTxt := "3+ Hits"
                            else
                                if zoneNow and highNow
                                    ambigDetailTxt := "Z+H"
                                else if zoneNow and lowNow
                                    ambigDetailTxt := "Z+L"
                                else if zoneNow and stopNow
                                    ambigDetailTxt := "Z+S"
                                else if highNow and lowNow
                                    ambigDetailTxt := "H+L"
                                else if highNow and stopNow
                                    ambigDetailTxt := "H+S"
                                else if lowNow and stopNow
                                    ambigDetailTxt := "L+S"
                                else
                                    ambigDetailTxt := "Other"
                        else
                            if stopNow
                                outcome := OUT_STOP
                            else if zoneNow
                                outcome := OUT_ZONE
                            else if highNow
                                outcome := OUT_HIGH
                            else if lowNow
                                outcome := OUT_LOW
                        break

                bool tcBullSeq = false
                bool tcBearSeq = false
                bool tcCont = false
                bool tcReclaim = false
                bool rjCanClassify = false
                bool rjFollow = false
                bool rjFail = false
                int tcNextIdx = na
                float tcNextH = na
                float tcNextL = na

                if i > 0 and i + 1 <= lastClosedSigIndex
                    SignalData sObj_prev_tc = array.get(sigs, i - 1)
                    SignalData sObj_next_tc = array.get(sigs, i + 1)
                    tcNextIdx := sObj_next_tc.idx
                    tcNextH := sObj_next_tc.h
                    tcNextL := sObj_next_tc.l

                    // Bearish combo: the prior candle must be the Failed 2U, and that same candle is the first 2 of the 2-2D.
                    // Current setup candle is the 2D that completes the 2-2 Rev Down.
                    // Next candle is the truth candle: close below 2-2D low = continuation; close above 2-2D low = reclaim.
                    if sObj.s22D == 1 and sObj_prev_tc.f2U == 1
                        tcBearSeq := true
                        if sObj_next_tc.c < sObj.l
                            tcCont := true
                        else if sObj_next_tc.c > sObj.l
                            tcReclaim := true

                    // Bullish reverse: the prior candle must be the Failed 2D, and that same candle is the first 2 of the 2-2U.
                    // Current setup candle is the 2U that completes the 2-2 Rev Up.
                    // Next candle is the truth candle: close above 2-2U high = continuation; close below 2-2U high = reclaim.
                    if sObj.s22U == 1 and sObj_prev_tc.f2D == 1
                        tcBullSeq := true
                        if sObj_next_tc.c > sObj.h
                            tcCont := true
                        else if sObj_next_tc.c < sObj.h
                            tcReclaim := true

                    // Reclaim-follow layer: only evaluate after the third candle has reclaimed.
                    // Bearish combo reclaim follow-through = fourth candle closes above the reclaim candle's high.
                    // Bullish combo reclaim follow-through = fourth candle closes below the reclaim candle's low.
                    if i + 2 <= lastClosedSigIndex
                        SignalData sObj_follow_tc = array.get(sigs, i + 2)
                        if tcBearSeq and tcReclaim
                            rjCanClassify := true
                            if sObj_follow_tc.c > sObj_next_tc.h
                                rjFollow := true
                            else
                                rjFail := true
                        if tcBullSeq and tcReclaim
                            rjCanClassify := true
                            if sObj_follow_tc.c < sObj_next_tc.l
                                rjFollow := true
                            else
                                rjFail := true

                bool tcClassified = tcCont or tcReclaim

                // F2 sequence audit labels are drawn in the independent closed-candle pass below.

                if earlyResolveMode and outcome == OUT_TIMEOUT and maxForwardBars < win_in
                    pendingSignal := true

                if skipOverlap and pendingSignal
                    lockUntil := i + maxForwardBars

                if pendingSignal
                    if tcBullSeq and tcClassified
                        r22U.tcTotal += 1
                        if tcCont
                            r22U.tcCont += 1
                        if tcReclaim
                            r22U.tcReclaim += 1
                    if tcBearSeq and tcClassified
                        r22D.tcTotal += 1
                        if tcCont
                            r22D.tcCont += 1
                        if tcReclaim
                            r22D.tcReclaim += 1
                    continue

                bool bzZPathHit = false
                bool azZPathHit = false
                bool bzZhPathHit = false
                bool azZlPathHit = false
                int bzZHitBar = na
                int azZHitBar = na
                int bzZhHitBar = na
                int azZlHitBar = na
                int bzZhBarsFromSetup = na
                int azZlBarsFromSetup = na
                float bzZHitPrice = na
                float azZHitPrice = na
                float bzZhHitPrice = na
                float azZlHitPrice = na

                bool firstZoneHit = outcome == OUT_ZONE and firstZoneNow

                if sigBelowZone and firstZoneHit
                    bzZPathHit := true
                    SignalData sObj_bz_first = array.get(sigs, i + firstBarUsed)
                    bzZHitBar := sObj_bz_first.idx
                    bzZHitPrice := sigZoneBot
                if sigAboveZone and firstZoneHit
                    azZPathHit := true
                    SignalData sObj_az_first = array.get(sigs, i + firstBarUsed)
                    azZHitBar := sObj_az_first.idx
                    azZHitPrice := sigZoneTop

                if firstZoneHit and firstBarUsed < maxForwardBars
                    for pth = firstBarUsed + 1 to maxForwardBars
                        SignalData sObj_pth = array.get(sigs, i + pth)
                        float pthH = sObj_pth.h
                        float pthL = sObj_pth.l

                        bool oldHighRetestPth = pthH >= sigStructHigh and pthL <= sigStructHigh
                        bool oldLowRetestPth = pthH >= sigStructLow and pthL <= sigStructLow
                        bool currentHtfHighBreakPth = pthH >= sigCurrentHtfHigh
                        bool currentHtfLowBreakPth = pthL <= sigCurrentHtfLow

                        bool pthHighNow = false
                        bool pthLowNow = false

                        if sigAboveStructHigh
                            if oldHighRetestPth or currentHtfHighBreakPth
                                pthHighNow := true
                        else
                            if pthH >= sigStructHigh
                                pthHighNow := true

                        if sigBelowStructLow
                            if oldLowRetestPth or currentHtfLowBreakPth
                                pthLowNow := true
                        else
                            if pthL <= sigStructLow
                                pthLowNow := true

                        if bzZPathHit and not bzZhPathHit and pthHighNow
                            bzZhPathHit := true
                            bzZhHitBar := sObj_pth.idx
                            bzZhBarsFromSetup := pth
                            bzZhHitPrice := pthH

                        if azZPathHit and not azZlPathHit and pthLowNow
                            azZlPathHit := true
                            azZlHitBar := sObj_pth.idx
                            azZlBarsFromSetup := pth
                            azZlHitPrice := pthL

                if outcome == OUT_ZONE
                    if firstBarUsed < maxForwardBars
                        for k = firstBarUsed + 1 to maxForwardBars
                            SignalData sObj_k = array.get(sigs, i + k)
                            float barH2 = sObj_k.h
                            float barL2 = sObj_k.l
                            float barC2 = sObj_k.c

                            bool targetNow2 = false
                            bool stopNow2 = false

                            bool oldHighRetestNow2 = barH2 >= sigStructHigh and barL2 <= sigStructHigh
                            bool oldLowRetestNow2 = barH2 >= sigStructLow and barL2 <= sigStructLow
                            bool currentHtfHighBreakNow2 = barH2 >= sigCurrentHtfHigh
                            bool currentHtfLowBreakNow2 = barL2 <= sigCurrentHtfLow

                            bool highNow2 = false
                            bool lowNow2 = false

                            if sigAboveStructHigh
                                if oldHighRetestNow2 or currentHtfHighBreakNow2
                                    highNow2 := true
                            else
                                if barH2 >= sigStructHigh
                                    highNow2 := true

                            if sigBelowStructLow
                                if oldLowRetestNow2 or currentHtfLowBreakNow2
                                    lowNow2 := true
                            else
                                if barL2 <= sigStructLow
                                    lowNow2 := true

                            if sigBull
                                if highNow2
                                    targetNow2 := true

                                float stopLvlBull2 = sigLow - sigStopBuf
                                if stopMode == "Wick"
                                    if barL2 < stopLvlBull2
                                        stopNow2 := true
                                else
                                    if barC2 < stopLvlBull2
                                        stopNow2 := true

                            if sigBear
                                if lowNow2
                                    targetNow2 := true

                                float stopLvlBear2 = sigHigh + sigStopBuf
                                if stopMode == "Wick"
                                    if barH2 > stopLvlBear2
                                        stopNow2 := true
                                else
                                    if barC2 > stopLvlBear2
                                        stopNow2 := true

                            if zonePathOutcome == OUT_TIMEOUT
                                int pathCount = 0
                                if highNow2
                                    pathCount += 1
                                if lowNow2
                                    pathCount += 1
                                if stopNow2
                                    pathCount += 1
                                if pathCount > 0
                                    if pathCount > 1
                                        zonePathOutcome := OUT_AMBIG
                                    else
                                        if highNow2
                                            zonePathOutcome := OUT_HIGH
                                        else if lowNow2
                                            zonePathOutcome := OUT_LOW
                                        else
                                            zonePathOutcome := OUT_STOP

                            int followCount = 0
                            if targetNow2
                                followCount += 1
                            if stopNow2
                                followCount += 1

                            if followCount > 0
                                if followCount > 1
                                    bfOutcome := OUT_AMBIG
                                else
                                    if stopNow2
                                        bfOutcome := OUT_STOP
                                    else
                                        if sigBull
                                            bfOutcome := OUT_HIGH
                                        else
                                            bfOutcome := OUT_LOW
                                break

                if outcome == OUT_ZONE and bfOutcome == OUT_TIMEOUT and earlyResolveMode and maxForwardBars < win_in
                    bfFollowPending := true

                if skipOverlap
                    lockUntil := i + firstBarUsed

                if sObj.f2U == 1
                    rF2U.count += 1
                    if sigBelowZone
                        rF2U.bzTotal += 1
                    if sigAboveZone
                        rF2U.azTotal += 1
                    if bzZPathHit
                        rF2U.bzZ += 1
                    if azZPathHit
                        rF2U.azZ += 1
                    if sigBelowZone and bzZhPathHit
                        rF2U.bzZh += 1
                    if sigAboveZone and azZlPathHit
                        rF2U.azZl += 1
                    if outcome == OUT_ZONE
                        rF2U.zoneFirst += 1
                        if bfOutcome == OUT_HIGH or bfOutcome == OUT_LOW
                            rF2U.bfFollow += 1
                        else if bfOutcome == OUT_STOP
                            rF2U.bfStop += 1
                        else if bfOutcome == OUT_AMBIG
                            rF2U.bfAmbig += 1
                        else if bfOutcome == OUT_TIMEOUT and not bfFollowPending
                            rF2U.bfTimeout += 1
                    else if outcome == OUT_HIGH
                        rF2U.highFirst += 1
                    else if outcome == OUT_LOW
                        rF2U.lowFirst += 1
                    else if outcome == OUT_STOP
                        rF2U.stopFirst += 1
                    else if outcome == OUT_AMBIG
                        if firstEventIncludedStop
                            rF2U.stopFirst += 1
                        rF2U.ambiguousFirst += 1
                    else if outcome == OUT_TIMEOUT
                        rF2U.timeoutFirst += 1

                if sObj.f2D == 1
                    rF2D.count += 1
                    if sigBelowZone
                        rF2D.bzTotal += 1
                    if sigAboveZone
                        rF2D.azTotal += 1
                    if bzZPathHit
                        rF2D.bzZ += 1
                    if azZPathHit
                        rF2D.azZ += 1
                    if sigBelowZone and bzZhPathHit
                        rF2D.bzZh += 1
                    if sigAboveZone and azZlPathHit
                        rF2D.azZl += 1
                    if outcome == OUT_ZONE
                        rF2D.zoneFirst += 1
                        if bfOutcome == OUT_HIGH or bfOutcome == OUT_LOW
                            rF2D.bfFollow += 1
                        else if bfOutcome == OUT_STOP
                            rF2D.bfStop += 1
                        else if bfOutcome == OUT_AMBIG
                            rF2D.bfAmbig += 1
                        else if bfOutcome == OUT_TIMEOUT and not bfFollowPending
                            rF2D.bfTimeout += 1
                    else if outcome == OUT_HIGH
                        rF2D.highFirst += 1
                    else if outcome == OUT_LOW
                        rF2D.lowFirst += 1
                    else if outcome == OUT_STOP
                        rF2D.stopFirst += 1
                    else if outcome == OUT_AMBIG
                        if firstEventIncludedStop
                            rF2D.stopFirst += 1
                        rF2D.ambiguousFirst += 1
                    else if outcome == OUT_TIMEOUT
                        rF2D.timeoutFirst += 1

                if sObj.s22U == 1
                    r22U.count += 1
                    if tcBullSeq and tcClassified
                        r22U.tcTotal += 1
                        if tcCont
                            r22U.tcCont += 1
                        if tcReclaim
                            r22U.tcReclaim += 1
                    if sigBelowZone
                        r22U.bzTotal += 1
                    if sigAboveZone
                        r22U.azTotal += 1
                    if bzZPathHit
                        r22U.bzZ += 1
                    if azZPathHit
                        r22U.azZ += 1
                    if sigBelowZone and bzZhPathHit
                        r22U.bzZh += 1
                    if sigAboveZone and azZlPathHit
                        r22U.azZl += 1
                    if outcome == OUT_ZONE
                        r22U.zoneFirst += 1
                        if bfOutcome == OUT_HIGH or bfOutcome == OUT_LOW
                            r22U.bfFollow += 1
                        else if bfOutcome == OUT_STOP
                            r22U.bfStop += 1
                        else if bfOutcome == OUT_AMBIG
                            r22U.bfAmbig += 1
                        else if bfOutcome == OUT_TIMEOUT and not bfFollowPending
                            r22U.bfTimeout += 1
                    else if outcome == OUT_HIGH
                        r22U.highFirst += 1
                    else if outcome == OUT_LOW
                        r22U.lowFirst += 1
                    else if outcome == OUT_STOP
                        r22U.stopFirst += 1
                    else if outcome == OUT_AMBIG
                        if firstEventIncludedStop
                            r22U.stopFirst += 1
                        r22U.ambiguousFirst += 1
                    else if outcome == OUT_TIMEOUT
                        r22U.timeoutFirst += 1

                if sObj.s22D == 1
                    r22D.count += 1
                    if tcBearSeq and tcClassified
                        r22D.tcTotal += 1
                        if tcCont
                            r22D.tcCont += 1
                        if tcReclaim
                            r22D.tcReclaim += 1
                    if sigBelowZone
                        r22D.bzTotal += 1
                    if sigAboveZone
                        r22D.azTotal += 1
                    if bzZPathHit
                        r22D.bzZ += 1
                    if azZPathHit
                        r22D.azZ += 1
                    if sigBelowZone and bzZhPathHit
                        r22D.bzZh += 1
                    if sigAboveZone and azZlPathHit
                        r22D.azZl += 1
                    if outcome == OUT_ZONE
                        r22D.zoneFirst += 1
                        if bfOutcome == OUT_HIGH or bfOutcome == OUT_LOW
                            r22D.bfFollow += 1
                        else if bfOutcome == OUT_STOP
                            r22D.bfStop += 1
                        else if bfOutcome == OUT_AMBIG
                            r22D.bfAmbig += 1
                        else if bfOutcome == OUT_TIMEOUT and not bfFollowPending
                            r22D.bfTimeout += 1
                    else if outcome == OUT_HIGH
                        r22D.highFirst += 1
                    else if outcome == OUT_LOW
                        r22D.lowFirst += 1
                    else if outcome == OUT_STOP
                        r22D.stopFirst += 1
                    else if outcome == OUT_AMBIG
                        if firstEventIncludedStop
                            r22D.stopFirst += 1
                        r22D.ambiguousFirst += 1
                    else if outcome == OUT_TIMEOUT
                        r22D.timeoutFirst += 1

                if sObj.s212U == 1
                    r212U.count += 1
                    if sigBelowZone
                        r212U.bzTotal += 1
                    if sigAboveZone
                        r212U.azTotal += 1
                    if bzZPathHit
                        r212U.bzZ += 1
                    if azZPathHit
                        r212U.azZ += 1
                    if sigBelowZone and bzZhPathHit
                        r212U.bzZh += 1
                    if sigAboveZone and azZlPathHit
                        r212U.azZl += 1
                    if outcome == OUT_ZONE
                        r212U.zoneFirst += 1
                        if bfOutcome == OUT_HIGH or bfOutcome == OUT_LOW
                            r212U.bfFollow += 1
                        else if bfOutcome == OUT_STOP
                            r212U.bfStop += 1
                        else if bfOutcome == OUT_AMBIG
                            r212U.bfAmbig += 1
                        else if bfOutcome == OUT_TIMEOUT and not bfFollowPending
                            r212U.bfTimeout += 1
                    else if outcome == OUT_HIGH
                        r212U.highFirst += 1
                    else if outcome == OUT_LOW
                        r212U.lowFirst += 1
                    else if outcome == OUT_STOP
                        r212U.stopFirst += 1
                    else if outcome == OUT_AMBIG
                        if firstEventIncludedStop
                            r212U.stopFirst += 1
                        r212U.ambiguousFirst += 1
                    else if outcome == OUT_TIMEOUT
                        r212U.timeoutFirst += 1

                if sObj.s212D == 1
                    r212D.count += 1
                    if sigBelowZone
                        r212D.bzTotal += 1
                    if sigAboveZone
                        r212D.azTotal += 1
                    if bzZPathHit
                        r212D.bzZ += 1
                    if azZPathHit
                        r212D.azZ += 1
                    if sigBelowZone and bzZhPathHit
                        r212D.bzZh += 1
                    if sigAboveZone and azZlPathHit
                        r212D.azZl += 1
                    if outcome == OUT_ZONE
                        r212D.zoneFirst += 1
                        if bfOutcome == OUT_HIGH or bfOutcome == OUT_LOW
                            r212D.bfFollow += 1
                        else if bfOutcome == OUT_STOP
                            r212D.bfStop += 1
                        else if bfOutcome == OUT_AMBIG
                            r212D.bfAmbig += 1
                        else if bfOutcome == OUT_TIMEOUT and not bfFollowPending
                            r212D.bfTimeout += 1
                    else if outcome == OUT_HIGH
                        r212D.highFirst += 1
                    else if outcome == OUT_LOW
                        r212D.lowFirst += 1
                    else if outcome == OUT_STOP
                        r212D.stopFirst += 1
                    else if outcome == OUT_AMBIG
                        if firstEventIncludedStop
                            r212D.stopFirst += 1
                        r212D.ambiguousFirst += 1
                    else if outcome == OUT_TIMEOUT
                        r212D.timeoutFirst += 1

                if sObj.s312U == 1
                    r312U.count += 1
                    if sigBelowZone
                        r312U.bzTotal += 1
                    if sigAboveZone
                        r312U.azTotal += 1
                    if bzZPathHit
                        r312U.bzZ += 1
                    if azZPathHit
                        r312U.azZ += 1
                    if sigBelowZone and bzZhPathHit
                        r312U.bzZh += 1
                    if sigAboveZone and azZlPathHit
                        r312U.azZl += 1
                    if outcome == OUT_ZONE
                        r312U.zoneFirst += 1
                        if bfOutcome == OUT_HIGH or bfOutcome == OUT_LOW
                            r312U.bfFollow += 1
                        else if bfOutcome == OUT_STOP
                            r312U.bfStop += 1
                        else if bfOutcome == OUT_AMBIG
                            r312U.bfAmbig += 1
                        else if bfOutcome == OUT_TIMEOUT and not bfFollowPending
                            r312U.bfTimeout += 1
                    else if outcome == OUT_HIGH
                        r312U.highFirst += 1
                    else if outcome == OUT_LOW
                        r312U.lowFirst += 1
                    else if outcome == OUT_STOP
                        r312U.stopFirst += 1
                    else if outcome == OUT_AMBIG
                        if firstEventIncludedStop
                            r312U.stopFirst += 1
                        r312U.ambiguousFirst += 1
                    else if outcome == OUT_TIMEOUT
                        r312U.timeoutFirst += 1

                if sObj.s312D == 1
                    r312D.count += 1
                    if sigBelowZone
                        r312D.bzTotal += 1
                    if sigAboveZone
                        r312D.azTotal += 1
                    if bzZPathHit
                        r312D.bzZ += 1
                    if azZPathHit
                        r312D.azZ += 1
                    if sigBelowZone and bzZhPathHit
                        r312D.bzZh += 1
                    if sigAboveZone and azZlPathHit
                        r312D.azZl += 1
                    if outcome == OUT_ZONE
                        r312D.zoneFirst += 1
                        if bfOutcome == OUT_HIGH or bfOutcome == OUT_LOW
                            r312D.bfFollow += 1
                        else if bfOutcome == OUT_STOP
                            r312D.bfStop += 1
                        else if bfOutcome == OUT_AMBIG
                            r312D.bfAmbig += 1
                        else if bfOutcome == OUT_TIMEOUT and not bfFollowPending
                            r312D.bfTimeout += 1
                    else if outcome == OUT_HIGH
                        r312D.highFirst += 1
                    else if outcome == OUT_LOW
                        r312D.lowFirst += 1
                    else if outcome == OUT_STOP
                        r312D.stopFirst += 1
                    else if outcome == OUT_AMBIG
                        if firstEventIncludedStop
                            r312D.stopFirst += 1
                        r312D.ambiguousFirst += 1
                    else if outcome == OUT_TIMEOUT
                        r312D.timeoutFirst += 1

                if sObj.contU == 1
                    rContU.count += 1
                    if sigBelowZone
                        rContU.bzTotal += 1
                    if sigAboveZone
                        rContU.azTotal += 1
                    if bzZPathHit
                        rContU.bzZ += 1
                    if azZPathHit
                        rContU.azZ += 1
                    if sigBelowZone and bzZhPathHit
                        rContU.bzZh += 1
                    if sigAboveZone and azZlPathHit
                        rContU.azZl += 1
                    if outcome == OUT_ZONE
                        rContU.zoneFirst += 1
                        if bfOutcome == OUT_HIGH or bfOutcome == OUT_LOW
                            rContU.bfFollow += 1
                        else if bfOutcome == OUT_STOP
                            rContU.bfStop += 1
                        else if bfOutcome == OUT_AMBIG
                            rContU.bfAmbig += 1
                        else if bfOutcome == OUT_TIMEOUT and not bfFollowPending
                            rContU.bfTimeout += 1
                    else if outcome == OUT_HIGH
                        rContU.highFirst += 1
                    else if outcome == OUT_LOW
                        rContU.lowFirst += 1
                    else if outcome == OUT_STOP
                        rContU.stopFirst += 1
                    else if outcome == OUT_AMBIG
                        if firstEventIncludedStop
                            rContU.stopFirst += 1
                        rContU.ambiguousFirst += 1
                    else if outcome == OUT_TIMEOUT
                        rContU.timeoutFirst += 1

                if sObj.contD == 1
                    rContD.count += 1
                    if sigBelowZone
                        rContD.bzTotal += 1
                    if sigAboveZone
                        rContD.azTotal += 1
                    if bzZPathHit
                        rContD.bzZ += 1
                    if azZPathHit
                        rContD.azZ += 1
                    if sigBelowZone and bzZhPathHit
                        rContD.bzZh += 1
                    if sigAboveZone and azZlPathHit
                        rContD.azZl += 1
                    if outcome == OUT_ZONE
                        rContD.zoneFirst += 1
                        if bfOutcome == OUT_HIGH or bfOutcome == OUT_LOW
                            rContD.bfFollow += 1
                        else if bfOutcome == OUT_STOP
                            rContD.bfStop += 1
                        else if bfOutcome == OUT_AMBIG
                            rContD.bfAmbig += 1
                        else if bfOutcome == OUT_TIMEOUT and not bfFollowPending
                            rContD.bfTimeout += 1
                    else if outcome == OUT_HIGH
                        rContD.highFirst += 1
                    else if outcome == OUT_LOW
                        rContD.lowFirst += 1
                    else if outcome == OUT_STOP
                        rContD.stopFirst += 1
                    else if outcome == OUT_AMBIG
                        if firstEventIncludedStop
                            rContD.stopFirst += 1
                        rContD.ambiguousFirst += 1
                    else if outcome == OUT_TIMEOUT
                        rContD.timeoutFirst += 1

                bool isF2U_i = sObj.f2U == 1
                bool isF2D_i = sObj.f2D == 1
                bool is22U_i = sObj.s22U == 1
                bool is22D_i = sObj.s22D == 1
                bool is212U_i = sObj.s212U == 1
                bool is212D_i = sObj.s212D == 1
                bool is312U_i = sObj.s312U == 1
                bool is312D_i = sObj.s312D == 1
                bool isContU_i = sObj.contU == 1
                bool isContD_i = sObj.contD == 1

                int ambigDetailWeight = 0
                if showF2 and isF2U_i
                    ambigDetailWeight += 1
                if showF2 and isF2D_i
                    ambigDetailWeight += 1
                if show22 and is22U_i
                    ambigDetailWeight += 1
                if show22 and is22D_i
                    ambigDetailWeight += 1
                if show212 and is212U_i
                    ambigDetailWeight += 1
                if show212 and is212D_i
                    ambigDetailWeight += 1
                if show312 and is312U_i
                    ambigDetailWeight += 1
                if show312 and is312D_i
                    ambigDetailWeight += 1
                if showCont and isContU_i
                    ambigDetailWeight += 1
                if showCont and isContD_i
                    ambigDetailWeight += 1

                if outcome == OUT_AMBIG and ambigDetailWeight > 0
                    if ambigDetailTxt == "Z+H"
                        ambigZoneHighCount += ambigDetailWeight
                    else if ambigDetailTxt == "Z+L"
                        ambigZoneLowCount += ambigDetailWeight
                    else if ambigDetailTxt == "Z+S"
                        ambigZoneStopCount += ambigDetailWeight
                    else if ambigDetailTxt == "H+L"
                        ambigHighLowCount += ambigDetailWeight
                    else if ambigDetailTxt == "H+S"
                        ambigHighStopCount += ambigDetailWeight
                    else if ambigDetailTxt == "L+S"
                        ambigLowStopCount += ambigDetailWeight
                    else
                        ambigThreePlusCount += ambigDetailWeight

                string setupTxtResolved = f_setupText(isF2U_i, isF2D_i, is22U_i, is22D_i, is212U_i, is212D_i, is312U_i, is312D_i, isContU_i, isContD_i)
                string setupTxtAudit = f_setupAuditText(isF2U_i, isF2D_i, is22U_i, is22D_i, is212U_i, is212D_i, is312U_i, is312D_i, isContU_i, isContD_i)
                string outTxtResolved = f_outcomeText(outcome)

                if outcome == OUT_ZONE
                    if bfOutcome == OUT_HIGH
                        outTxtResolved := "Z→H"
                    else if bfOutcome == OUT_LOW
                        outTxtResolved := "Z→L"
                    else if bfOutcome == OUT_STOP
                        outTxtResolved := "Z→S"
                    else if bfOutcome == OUT_AMBIG
                        outTxtResolved := "Z→2+"
                    else if bfOutcome == OUT_TIMEOUT and not bfFollowPending
                        outTxtResolved := "Z→T"
                    else
                        outTxtResolved := "Z"

                if outcome == OUT_AMBIG
                    outTxtResolved := "2+(" + ambigDetailTxt + ")"

                string finalTxtResolved = setupTxtResolved + "-" + outTxtResolved
                lastLoggedTxt := finalTxtResolved
                lastLoggedBar := sObj.idx

                bool auditRecent = false
                if showAudit
                    if sObj.idx >= bar_index - auditBars
                        auditRecent := true

                if auditRecent
                    float yPrice = sigHigh
                    labStyle = label.style_label_down
                    if sigBull
                        yPrice := sigLow
                        labStyle := label.style_label_up

                    label lab = label.new(
                         sObj.idx,
                         yPrice,
                         finalTxtResolved,
                         yloc=yloc.price,
                         style=labStyle,
                         color=color.new(color.black, 0),
                         textcolor=f_outcomeColor(outcome),
                         size=auditLabelSize
                    )
                    array.push(auditLabels, lab)
                    array.push(auditLabelBars, sObj.idx)

                bool bzAzAuditRecent = false
                if showBzAzPathAudit
                    if sObj.idx >= bar_index - auditBars
                        bzAzAuditRecent := true

                if bzAzAuditRecent and setupTxtAudit != "" and showBzAzDenomAudit and sigBelowZone
                    float bzDenomY = sigLow - bzAzAuditLabelOffset
                    label bzDenomLab = label.new(sObj.idx, bzDenomY, "BZ? " + setupTxtAudit, yloc=yloc.price, style=label.style_label_up, color=color.new(color.blue, 0), textcolor=color.white, size=bzAzAuditLabelSize)
                    array.push(auditLabels, bzDenomLab)

                if bzAzAuditRecent and setupTxtAudit != "" and showBzAzDenomAudit and sigAboveZone
                    float azDenomY = sigHigh + bzAzAuditLabelOffset
                    label azDenomLab = label.new(sObj.idx, azDenomY, "AZ? " + setupTxtAudit, yloc=yloc.price, style=label.style_label_down, color=color.new(color.purple, 0), textcolor=color.white, size=bzAzAuditLabelSize)
                    array.push(auditLabels, azDenomLab)

                if bzAzAuditRecent and setupTxtAudit != "" and showBzAzSourceAudit and bzZPathHit
                    float bzSourceY = sigLow - (bzAzAuditLabelOffset * 2.0)
                    string bzSourceTxt = bzZhPathHit ? "SRC BZ-Z-H " + setupTxtAudit : "SRC BZ-Z " + setupTxtAudit
                    label bzSourceLab = label.new(sObj.idx, bzSourceY, bzSourceTxt, yloc=yloc.price, style=label.style_label_up, color=color.new(color.aqua, 15), textcolor=color.black, size=bzAzAuditLabelSize)
                    array.push(auditLabels, bzSourceLab)

                if bzAzAuditRecent and setupTxtAudit != "" and showBzAzSourceAudit and azZPathHit
                    float azSourceY = sigHigh + (bzAzAuditLabelOffset * 2.0)
                    string azSourceTxt = azZlPathHit ? "SRC AZ-Z-L " + setupTxtAudit : "SRC AZ-Z " + setupTxtAudit
                    label azSourceLab = label.new(sObj.idx, azSourceY, azSourceTxt, yloc=yloc.price, style=label.style_label_down, color=color.new(color.orange, 15), textcolor=color.black, size=bzAzAuditLabelSize)
                    array.push(auditLabels, azSourceLab)

                if bzAzAuditRecent and setupTxtAudit != "" and showBzAzStageAudit and bzZPathHit and not na(bzZHitBar)
                    float bzStageY = bzZHitPrice + bzAzAuditLabelOffset
                    string bzStageTxt = "BZ-Z " + setupTxtAudit + "\nfrom setup " + str.tostring(firstBarUsed) + "b"
                    label bzStageLab = label.new(bzZHitBar, bzStageY, bzStageTxt, yloc=yloc.price, style=label.style_label_down, color=color.new(color.aqua, 0), textcolor=color.black, size=bzAzAuditLabelSize)
                    array.push(auditLabels, bzStageLab)

                if bzAzAuditRecent and setupTxtAudit != "" and showBzAzStageAudit and azZPathHit and not na(azZHitBar)
                    float azStageY = azZHitPrice - bzAzAuditLabelOffset
                    string azStageTxt = "AZ-Z " + setupTxtAudit + "\nfrom setup " + str.tostring(firstBarUsed) + "b"
                    label azStageLab = label.new(azZHitBar, azStageY, azStageTxt, yloc=yloc.price, style=label.style_label_up, color=color.new(color.orange, 0), textcolor=color.black, size=bzAzAuditLabelSize)
                    array.push(auditLabels, azStageLab)

                if bzAzAuditRecent and setupTxtAudit != "" and showBzAzHitAudit and bzZhPathHit and not na(bzZhHitBar)
                    float bzHitY = bzZhHitPrice + bzAzAuditLabelOffset
                    string bzHitTxt = "BZ-Z-H " + setupTxtAudit + "\nfrom setup " + str.tostring(bzZhBarsFromSetup) + "b"
                    label bzHitLab = label.new(bzZhHitBar, bzHitY, bzHitTxt, yloc=yloc.price, style=label.style_label_down, color=color.new(color.green, 0), textcolor=color.white, size=bzAzAuditLabelSize)
                    array.push(auditLabels, bzHitLab)

                if bzAzAuditRecent and setupTxtAudit != "" and showBzAzHitAudit and azZlPathHit and not na(azZlHitBar)
                    float azHitY = azZlHitPrice - bzAzAuditLabelOffset
                    string azHitTxt = "AZ-Z-L " + setupTxtAudit + "\nfrom setup " + str.tostring(azZlBarsFromSetup) + "b"
                    label azHitLab = label.new(azZlHitBar, azHitY, azHitTxt, yloc=yloc.price, style=label.style_label_up, color=color.new(color.red, 0), textcolor=color.white, size=bzAzAuditLabelSize)
                    array.push(auditLabels, azHitLab)


    // =====================================================
    // 9B) F2 -> 2x -> x C/R + RECLAIM F/X ENGINE — CLOSED-CANDLE STAT
    // =====================================================
    // This pass is intentionally decoupled from the Zone/High/Low resolution window.
    // It uses Stat Lookback only and is not affected by Fully Aged Only, Early Resolve, or Skip Overlapping Signals.
    // F2U -> 2D -> x:
    //     C = next closed candle closes below the 2D low.
    //     R = next closed candle closes back above the 2D low.
    // F2D -> 2U -> x:
    //     C = next closed candle closes above the 2U high.
    //     R = next closed candle closes back below the 2U high.
    // F/X is evaluated only after a reclaim decision and uses the next fully closed candle.
    r22U.tcTotal := 0
    r22U.tcCont := 0
    r22U.tcReclaim := 0
    r22U.rjTotal := 0
    r22U.rjFollow := 0
    r22U.rjFail := 0
    r22D.tcTotal := 0
    r22D.tcCont := 0
    r22D.tcReclaim := 0
    r22D.rjTotal := 0
    r22D.rjFollow := 0
    r22D.rjFail := 0

    if (showF2SequenceRows or showColCR or showColRJ) and aSz >= 3
        int f2SeqSt = math.max(1, aSz - slb_in)
        int f2SeqEn = aSz - 1
        if f2SeqEn >= f2SeqSt
            for f2SeqI = f2SeqSt to f2SeqEn
                bool f2SeqDecisionClosed = f2SeqI + 1 < aSz - 1 or (f2SeqI + 1 == aSz - 1 and barstate.isconfirmed)
                bool f2SeqFourthClosed = f2SeqI + 2 < aSz - 1 or (f2SeqI + 2 == aSz - 1 and barstate.isconfirmed)
                if f2SeqI > 0 and f2SeqI + 1 < aSz and f2SeqDecisionClosed
                    SignalData f2SeqPrev = array.get(sigs, f2SeqI - 1)
                    SignalData f2SeqSetup = array.get(sigs, f2SeqI)
                    SignalData f2SeqDecision = array.get(sigs, f2SeqI + 1)

                    bool f2SeqBear = f2SeqSetup.s22D == 1 and f2SeqPrev.f2U == 1
                    bool f2SeqBull = f2SeqSetup.s22U == 1 and f2SeqPrev.f2D == 1
                    bool f2SeqCont = false
                    bool f2SeqReclaim = false

                    if f2SeqBear
                        if f2SeqDecision.c < f2SeqSetup.l
                            f2SeqCont := true
                        else if f2SeqDecision.c > f2SeqSetup.l
                            f2SeqReclaim := true

                    if f2SeqBull
                        if f2SeqDecision.c > f2SeqSetup.h
                            f2SeqCont := true
                        else if f2SeqDecision.c < f2SeqSetup.h
                            f2SeqReclaim := true

                    bool f2SeqClassified = f2SeqCont or f2SeqReclaim

                    if f2SeqBear and f2SeqClassified
                        r22D.tcTotal += 1
                        if f2SeqCont
                            r22D.tcCont += 1
                        if f2SeqReclaim
                            r22D.tcReclaim += 1

                    if f2SeqBull and f2SeqClassified
                        r22U.tcTotal += 1
                        if f2SeqCont
                            r22U.tcCont += 1
                        if f2SeqReclaim
                            r22U.tcReclaim += 1

                    if showSeqAudit and showSeqAuditF2 and f2SeqClassified and bar_index - f2SeqSetup.idx <= seqAuditBars
                        string seqSetupTxtF2Pass = ""
                        string seqDecisionTxtF2Pass = f2SeqCont ? "C" : "R"
                        color seqColorF2Pass = color.gray
                        float seqSetupYF2Pass = f2SeqSetup.h + seqAuditLabelOffset
                        float seqDecisionYF2Pass = f2SeqDecision.h + seqAuditLabelOffset
                        seqStyleF2Pass = label.style_label_down
                        if f2SeqBear
                            seqSetupTxtF2Pass := "F2U→2D"
                            seqColorF2Pass := color.red
                            seqSetupYF2Pass := f2SeqSetup.h + seqAuditLabelOffset
                            seqDecisionYF2Pass := f2SeqDecision.h + seqAuditLabelOffset
                            seqStyleF2Pass := label.style_label_down
                        if f2SeqBull
                            seqSetupTxtF2Pass := "F2D→2U"
                            seqColorF2Pass := color.green
                            seqSetupYF2Pass := f2SeqSetup.l - seqAuditLabelOffset
                            seqDecisionYF2Pass := f2SeqDecision.l - seqAuditLabelOffset
                            seqStyleF2Pass := label.style_label_up
                        if seqSetupTxtF2Pass != ""
                            label seqSetupLabF2Pass = label.new(f2SeqSetup.idx, seqSetupYF2Pass, seqSetupTxtF2Pass, yloc=yloc.price, style=seqStyleF2Pass, color=color.new(seqColorF2Pass, 0), textcolor=color.white, size=seqAuditLabelSize)
                            label seqDecisionLabF2Pass = label.new(f2SeqDecision.idx, seqDecisionYF2Pass, seqDecisionTxtF2Pass, yloc=yloc.price, style=seqStyleF2Pass, color=color.new(seqColorF2Pass, 0), textcolor=color.white, size=seqAuditLabelSize)
                            array.push(auditLabels, seqSetupLabF2Pass)
                            array.push(auditLabels, seqDecisionLabF2Pass)

                    if f2SeqClassified and f2SeqReclaim and f2SeqI + 2 < aSz and f2SeqFourthClosed
                        SignalData f2SeqFourth = array.get(sigs, f2SeqI + 2)
                        bool f2SeqFollow = false
                        bool f2SeqFail = false

                        if f2SeqBear
                            if f2SeqFourth.c > f2SeqDecision.h
                                f2SeqFollow := true
                            else
                                f2SeqFail := true

                        if f2SeqBull
                            if f2SeqFourth.c < f2SeqDecision.l
                                f2SeqFollow := true
                            else
                                f2SeqFail := true

                        if f2SeqBear
                            r22D.rjTotal += 1
                            if f2SeqFollow
                                r22D.rjFollow += 1
                            if f2SeqFail
                                r22D.rjFail += 1

                        if f2SeqBull
                            r22U.rjTotal += 1
                            if f2SeqFollow
                                r22U.rjFollow += 1
                            if f2SeqFail
                                r22U.rjFail += 1

                        if showSeqAudit and showSeqAuditF2 and bar_index - f2SeqSetup.idx <= seqAuditBars
                            string f2SeqFxTxt = f2SeqFollow ? "F" : "X"
                            if f2SeqBear
                                label f2SeqFxLabBear = label.new(f2SeqFourth.idx, f2SeqFourth.h + seqAuditLabelOffset, f2SeqFxTxt, yloc=yloc.price, style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=seqAuditLabelSize)
                                array.push(auditLabels, f2SeqFxLabBear)
                            if f2SeqBull
                                label f2SeqFxLabBull = label.new(f2SeqFourth.idx, f2SeqFourth.l - seqAuditLabelOffset, f2SeqFxTxt, yloc=yloc.price, style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.white, size=seqAuditLabelSize)
                                array.push(auditLabels, f2SeqFxLabBull)

    // =====================================================
    // 9C) GENERAL 2-2 C/R + F/THRU ENGINE — CLOSED-CANDLE STAT
    // =====================================================
    // This pass measures all 2-2 reversals, without requiring a Failed 2 before the 2-2.
    // C/R is known after the third candle closes; F/Thru is known after the fourth candle closes.
    if show22 and aSz >= 3
        int s22St = math.max(0, aSz - slb_in)
        int s22En = aSz - 1
        if s22En >= s22St
            for s22I = s22St to s22En
                bool s22DecisionClosed = s22I + 1 < aSz - 1 or (s22I + 1 == aSz - 1 and barstate.isconfirmed)
                bool s22FourthClosed = s22I + 2 < aSz - 1 or (s22I + 2 == aSz - 1 and barstate.isconfirmed)
                if s22I + 1 < aSz and s22DecisionClosed
                    SignalData s22Setup = array.get(sigs, s22I)
                    SignalData s22Decision = array.get(sigs, s22I + 1)

                    bool s22UpSeq = s22Setup.s22U == 1
                    bool s22DownSeq = s22Setup.s22D == 1
                    bool s22Cont = false
                    bool s22Reclaim = false

                    if s22UpSeq
                        if s22Decision.c > s22Setup.h
                            s22Cont := true
                        else if s22Decision.c < s22Setup.h
                            s22Reclaim := true

                    if s22DownSeq
                        if s22Decision.c < s22Setup.l
                            s22Cont := true
                        else if s22Decision.c > s22Setup.l
                            s22Reclaim := true

                    bool s22Classified = s22Cont or s22Reclaim

                    if showSeqAudit and showSeqAudit22 and s22Classified
                        bool seqRecent22 = bar_index - s22Setup.idx <= seqAuditBars
                        if seqRecent22
                            string seqSetupTxt22 = ""
                            string seqDecisionTxt22 = s22Cont ? "C" : "R"
                            color seqColor22 = color.gray
                            float seqSetupY22 = s22Setup.h + seqAuditLabelOffset
                            float seqDecisionY22 = s22Decision.h + seqAuditLabelOffset
                            seqStyle22 = label.style_label_down
                            if s22UpSeq
                                seqSetupTxt22 := "22U"
                                seqColor22 := color.green
                                seqSetupY22 := s22Setup.l - seqAuditLabelOffset
                                seqDecisionY22 := s22Decision.l - seqAuditLabelOffset
                                seqStyle22 := label.style_label_up
                            if s22DownSeq
                                seqSetupTxt22 := "22D"
                                seqColor22 := color.red
                                seqSetupY22 := s22Setup.h + seqAuditLabelOffset
                                seqDecisionY22 := s22Decision.h + seqAuditLabelOffset
                                seqStyle22 := label.style_label_down
                            if seqSetupTxt22 != ""
                                label seqSetupLab22 = label.new(s22Setup.idx, seqSetupY22, seqSetupTxt22, yloc=yloc.price, style=seqStyle22, color=color.new(seqColor22, 0), textcolor=color.white, size=seqAuditLabelSize)
                                label seqDecisionLab22 = label.new(s22Decision.idx, seqDecisionY22, seqDecisionTxt22, yloc=yloc.price, style=seqStyle22, color=color.new(seqColor22, 0), textcolor=color.white, size=seqAuditLabelSize)
                                array.push(auditLabels, seqSetupLab22)
                                array.push(auditLabels, seqDecisionLab22)

                    if s22UpSeq and s22Classified
                        r22U.s22TcTotal += 1
                        if s22Cont
                            r22U.s22TcCont += 1
                        if s22Reclaim
                            r22U.s22TcReclaim += 1

                    if s22DownSeq and s22Classified
                        r22D.s22TcTotal += 1
                        if s22Cont
                            r22D.s22TcCont += 1
                        if s22Reclaim
                            r22D.s22TcReclaim += 1

                    if s22Classified and s22I + 2 < aSz and s22FourthClosed
                        SignalData s22Fourth = array.get(sigs, s22I + 2)
                        bool s22Follow = false
                        bool s22Fail = false

                        if s22UpSeq
                            if s22Cont
                                if s22Fourth.c > s22Decision.h
                                    s22Follow := true
                                else
                                    s22Fail := true
                            else if s22Reclaim
                                if s22Fourth.c < s22Decision.l
                                    s22Follow := true
                                else
                                    s22Fail := true

                        if s22DownSeq
                            if s22Cont
                                if s22Fourth.c < s22Decision.l
                                    s22Follow := true
                                else
                                    s22Fail := true
                            else if s22Reclaim
                                if s22Fourth.c > s22Decision.h
                                    s22Follow := true
                                else
                                    s22Fail := true

                        if showSeqAudit and showSeqAudit22 and bar_index - s22Setup.idx <= seqAuditBars
                            string s22FxTxt = s22Follow ? "F" : "X"
                            if s22UpSeq
                                label s22FxLabUp = label.new(s22Fourth.idx, s22Fourth.l - seqAuditLabelOffset, s22FxTxt, yloc=yloc.price, style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.white, size=seqAuditLabelSize)
                                array.push(auditLabels, s22FxLabUp)
                            if s22DownSeq
                                label s22FxLabDown = label.new(s22Fourth.idx, s22Fourth.h + seqAuditLabelOffset, s22FxTxt, yloc=yloc.price, style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=seqAuditLabelSize)
                                array.push(auditLabels, s22FxLabDown)

                        if s22UpSeq
                            r22U.s22FtTotal += 1
                            if s22Follow
                                r22U.s22FtFollow += 1
                            if s22Fail
                                r22U.s22FtFail += 1

                        if s22DownSeq
                            r22D.s22FtTotal += 1
                            if s22Follow
                                r22D.s22FtFollow += 1
                            if s22Fail
                                r22D.s22FtFail += 1


    // =====================================================
    // 9D) REVSTRAT 3 HIGH/LOW BREAK C/R + F/X ENGINE — CLOSED-BAR STAT
    // =====================================================
    // This pass measures the candle immediately AFTER a Strat 3 / outside bar.
    // The prior candle must be a true 3: prior high > candle-before high AND prior low < candle-before low.
    // High-side event: the next candle wicks/trades above the 3 candle high.
    //     C = that closed candle closes above the 3 high.
    //     R = that closed candle closes back below the 3 high.
    // Low-side event: the next candle wicks/trades below the 3 candle low.
    //     C = that closed candle closes below the 3 low.
    //     R = that closed candle closes back above the 3 low.
    // F/X then checks the next CLOSED candle against the break/reclaim candle itself.
    if showBfBreakRows and aSz >= 4
        int bfBreakSt = math.max(2, aSz - slb_in)
        int bfBreakEn = aSz - 1
        if bfBreakEn >= bfBreakSt
            for bfBreakI = bfBreakSt to bfBreakEn
                bool bfBreakDecisionClosed = bfBreakI < aSz - 1 or (bfBreakI == aSz - 1 and barstate.isconfirmed)
                bool bfBreakNextClosed = bfBreakI + 1 < aSz - 1 or (bfBreakI + 1 == aSz - 1 and barstate.isconfirmed)
                if bfBreakDecisionClosed
                    SignalData threePrev = array.get(sigs, bfBreakI - 1)
                    SignalData threeBefore = array.get(sigs, bfBreakI - 2)
                    SignalData bfBreakSetup = array.get(sigs, bfBreakI)

                    bool priorIsThree = threePrev.h > threeBefore.h and threePrev.l < threeBefore.l
                    bool threeHighBreak = priorIsThree and bfBreakSetup.h > threePrev.h
                    bool threeLowBreak = priorIsThree and bfBreakSetup.l < threePrev.l

                    bool bfHighCont = false
                    bool bfHighReclaim = false
                    bool bfLowCont = false
                    bool bfLowReclaim = false

                    if threeHighBreak
                        if bfBreakSetup.c > threePrev.h
                            bfHighCont := true
                        else if bfBreakSetup.c < threePrev.h
                            bfHighReclaim := true

                    if threeLowBreak
                        if bfBreakSetup.c < threePrev.l
                            bfLowCont := true
                        else if bfBreakSetup.c > threePrev.l
                            bfLowReclaim := true

                    bool bfHighClassified = bfHighCont or bfHighReclaim
                    bool bfLowClassified = bfLowCont or bfLowReclaim

                    if bfHighClassified
                        bfBreakUpTotal += 1
                        if bfHighCont
                            bfBreakUpCont += 1
                        if bfHighReclaim
                            bfBreakUpReclaim += 1

                    if bfLowClassified
                        bfBreakDownTotal += 1
                        if bfLowCont
                            bfBreakDownCont += 1
                        if bfLowReclaim
                            bfBreakDownReclaim += 1

                    if bfBreakI + 1 < aSz and bfBreakNextClosed
                        SignalData bfBreakNext = array.get(sigs, bfBreakI + 1)
                        bool bfHighFollow = false
                        bool bfHighFail = false
                        bool bfLowFollow = false
                        bool bfLowFail = false

                        if bfHighClassified
                            if bfHighCont
                                if bfBreakNext.c > bfBreakSetup.h
                                    bfHighFollow := true
                                else
                                    bfHighFail := true
                            else if bfHighReclaim
                                if bfBreakNext.c < bfBreakSetup.l
                                    bfHighFollow := true
                                else
                                    bfHighFail := true

                        if bfLowClassified
                            if bfLowCont
                                if bfBreakNext.c < bfBreakSetup.l
                                    bfLowFollow := true
                                else
                                    bfLowFail := true
                            else if bfLowReclaim
                                if bfBreakNext.c > bfBreakSetup.h
                                    bfLowFollow := true
                                else
                                    bfLowFail := true

                        if bfHighClassified
                            if bfHighFollow
                                bfBreakUpFollow += 1
                            if bfHighFail
                                bfBreakUpFail += 1

                        if bfLowClassified
                            if bfLowFollow
                                bfBreakDownFollow += 1
                            if bfLowFail
                                bfBreakDownFail += 1

    int auditMatch = -1
    int auditSz = array.size(auditLabelBars)
    if auditSz > 0 and not na(lastLoggedBar)        
        for q = 0 to auditSz - 1
            if array.get(auditLabelBars, q) == lastLoggedBar
                auditMatch := q

    if auditMatch >= 0
        label.set_text(array.get(auditLabels, auditMatch), "*" + lastLoggedTxt)

    int maxBFSearchBars = bar_index
    if maxBFSearchBars > 5000
        maxBFSearchBars := 5000

    int htfEventsSeen = 0
    int bfWindowStartTime = na

    for barsBack = 0 to maxBFSearchBars
        if bfEvalNewBar[barsBack]
            htfEventsSeen += 1

            if htfEventsSeen <= bfLookbackBars
                bfWindowStartTime := bfEvalLabelTime[barsBack]

                if bfEvalUpOnly[barsBack]
                    trueBFUpCount += 1
                    trueBFTotalCount += 1
                else if bfEvalDownOnly[barsBack]
                    trueBFDownCount += 1
                    trueBFTotalCount += 1
                else if bfEvalBoth[barsBack]
                    trueBFBothCount += 1
                    trueBFTotalCount += 1

                    if showTrueBFLabels
                        if bfEvalLabelTime[barsBack] >= time[auditBars]
                            label bfLab = label.new(
                                 bfEvalLabelTime[barsBack],
                                 bfEvalPairHigh[barsBack],
                                 "BF",
                                 xloc=xloc.bar_time,
                                 yloc=yloc.price,
                                 style=label.style_label_down,
                                 color=color.new(color.black, 0),
                                 textcolor=color.yellow,
                                 size=auditLabelSize
                            )
                            array.push(trueBFLabels, bfLab)

            if htfEventsSeen >= bfLookbackBars
                break

    if not na(bfWindowStartTime) and array.size(sigs) > 0
        int aSz2 = array.size(sigs)
        for s = 0 to aSz2 - 1
            SignalData sObj2 = array.get(sigs, s)
            if sObj2.t >= bfWindowStartTime
                if showF2
                    trueBFSetupTotal += sObj2.f2U + sObj2.f2D
                if show22
                    trueBFSetupTotal += sObj2.s22U + sObj2.s22D
                if show212
                    trueBFSetupTotal += sObj2.s212U + sObj2.s212D
                if show312
                    trueBFSetupTotal += sObj2.s312U + sObj2.s312D
                if showCont
                    trueBFSetupTotal += sObj2.contU + sObj2.contD


// =====================================================
// 9B) TABLE DRAW HELPERS
// =====================================================
f_drawBfBreakRow(table tbl, int rnum, string labelTxt, int seqCount, int contCount, int reclaimCount, int followCount, int failCount, color labelColor, bool compact, string sz, color rowBg, int cZone, int cBzZ, int cAzZ, int cHigh, int cLow, int cBzZh, int cAzZl, int cStop, int cAmbig, int cCR, int cRJ, int c22CR, int c22FT) =>
    table.cell(tbl, 0, rnum, labelTxt, text_color=labelColor, text_size=sz, bgcolor=rowBg)
    table.cell(tbl, 1, rnum, str.tostring(seqCount), text_color=tTxtCol, text_size=sz, bgcolor=f_countBg(seqCount, minSample, tWarnCol, rowBg))
    if showColZone
        table.cell(tbl, cZone, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColBzZ
        table.cell(tbl, cBzZ, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColAzZ
        table.cell(tbl, cAzZ, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColHigh
        table.cell(tbl, cHigh, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColLow
        table.cell(tbl, cLow, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColBzZh
        table.cell(tbl, cBzZh, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColAzZl
        table.cell(tbl, cAzZl, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColStop
        table.cell(tbl, cStop, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColAmbig
        table.cell(tbl, cAmbig, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColCR
        table.cell(tbl, cCR, rnum, f_truthOddsStrDisp(contCount, reclaimCount, compact), text_color=f_truthOddsColor(contCount, reclaimCount, minSample, tHiCol, tTxtCol), text_size=sz, bgcolor=rowBg)
    if showColRJ
        table.cell(tbl, cRJ, rnum, f_rjFollowStrDisp(followCount, failCount, compact), text_color=f_rjFollowColor(followCount, failCount, minSample, tHiCol, tTxtCol), text_size=sz, bgcolor=rowBg)
    if showCol22CR
        table.cell(tbl, c22CR, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showCol22FT
        table.cell(tbl, c22FT, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)

f_drawStandardRow(table tbl, int rnum, string labelTxt, StatRes res, color labelColor, bool compact, string sz, color rowBg, int cZone, int cBzZ, int cAzZ, int cHigh, int cLow, int cBzZh, int cAzZl, int cStop, int cAmbig, int cCR, int cRJ, int c22CR, int c22FT, bool useF2Cols, bool use22Cols) =>
    table.cell(tbl, 0, rnum, labelTxt, text_color=labelColor, text_size=sz, bgcolor=rowBg)
    table.cell(tbl, 1, rnum, str.tostring(res.count), text_color=tTxtCol, text_size=sz, bgcolor=f_countBg(res.count, minSample, tWarnCol, rowBg))
    if showColZone
        table.cell(tbl, cZone, rnum, f_pctStrCntDisp(res.zoneFirst, res.count, compact), text_color=f_pctColor(res.zoneFirst, res.count, minSample, tHiCol, tTxtCol), text_size=sz, bgcolor=rowBg)
    if showColBzZ
        table.cell(tbl, cBzZ, rnum, f_pctStrFracDisp(res.bzZ, res.bzTotal, compact), text_color=f_pctColor(res.bzZ, res.bzTotal, minSample, tHiCol, tTxtCol), text_size=sz, bgcolor=rowBg)
    if showColAzZ
        table.cell(tbl, cAzZ, rnum, f_pctStrFracDisp(res.azZ, res.azTotal, compact), text_color=f_pctColor(res.azZ, res.azTotal, minSample, tHiCol, tTxtCol), text_size=sz, bgcolor=rowBg)
    if showColBzZh
        table.cell(tbl, cBzZh, rnum, f_pctStrFracDisp(res.bzZh, res.bzTotal, compact), text_color=f_pctColor(res.bzZh, res.bzTotal, minSample, tHiCol, tTxtCol), text_size=sz, bgcolor=rowBg)
    if showColHigh
        table.cell(tbl, cHigh, rnum, f_pctStrCntDisp(res.highFirst, res.count, compact), text_color=f_pctColor(res.highFirst, res.count, minSample, tHiCol, tTxtCol), text_size=sz, bgcolor=rowBg)
    if showColLow
        table.cell(tbl, cLow, rnum, f_pctStrCntDisp(res.lowFirst, res.count, compact), text_color=f_pctColor(res.lowFirst, res.count, minSample, tHiCol, tTxtCol), text_size=sz, bgcolor=rowBg)
    if showColAzZl
        table.cell(tbl, cAzZl, rnum, f_pctStrFracDisp(res.azZl, res.azTotal, compact), text_color=f_pctColor(res.azZl, res.azTotal, minSample, tHiCol, tTxtCol), text_size=sz, bgcolor=rowBg)
    if showColStop
        table.cell(tbl, cStop, rnum, f_pctStrCntDisp(res.stopFirst, res.count, compact), text_color=f_pctColor(res.stopFirst, res.count, minSample, tWarnCol, tTxtCol), text_size=sz, bgcolor=rowBg)
    if showColAmbig
        table.cell(tbl, cAmbig, rnum, f_pctStrCntDisp(res.ambiguousFirst, res.count, compact), text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColCR
        string crTxt = useF2Cols ? f_truthOddsStrDisp(res.tcCont, res.tcReclaim, compact) : "NA"
        color crColor = useF2Cols ? f_truthOddsColor(res.tcCont, res.tcReclaim, minSample, tHiCol, tTxtCol) : tTxtCol
        table.cell(tbl, cCR, rnum, crTxt, text_color=crColor, text_size=sz, bgcolor=rowBg)
    if showColRJ
        string rjTxt = useF2Cols ? f_rjFollowStrDisp(res.rjFollow, res.rjFail, compact) : "NA"
        color rjColor = useF2Cols ? f_rjFollowColor(res.rjFollow, res.rjFail, minSample, tHiCol, tTxtCol) : tTxtCol
        table.cell(tbl, cRJ, rnum, rjTxt, text_color=rjColor, text_size=sz, bgcolor=rowBg)
    if showCol22CR
        table.cell(tbl, c22CR, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showCol22FT
        table.cell(tbl, c22FT, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)

f_drawF2SeqRow(table tbl, int rnum, string labelTxt, StatRes res, color labelColor, bool compact, string sz, color rowBg, int cZone, int cBzZ, int cAzZ, int cHigh, int cLow, int cBzZh, int cAzZl, int cStop, int cAmbig, int cCR, int cRJ, int c22CR, int c22FT) =>
    int seqCount = res.tcTotal
    table.cell(tbl, 0, rnum, labelTxt, text_color=labelColor, text_size=sz, bgcolor=rowBg)
    table.cell(tbl, 1, rnum, str.tostring(seqCount), text_color=tTxtCol, text_size=sz, bgcolor=f_countBg(seqCount, minSample, tWarnCol, rowBg))
    if showColZone
        table.cell(tbl, cZone, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColBzZ
        table.cell(tbl, cBzZ, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColAzZ
        table.cell(tbl, cAzZ, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColBzZh
        table.cell(tbl, cBzZh, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColHigh
        table.cell(tbl, cHigh, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColLow
        table.cell(tbl, cLow, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColAzZl
        table.cell(tbl, cAzZl, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColStop
        table.cell(tbl, cStop, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColAmbig
        table.cell(tbl, cAmbig, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColCR
        table.cell(tbl, cCR, rnum, f_truthOddsStrDisp(res.tcCont, res.tcReclaim, compact), text_color=f_truthOddsColor(res.tcCont, res.tcReclaim, minSample, tHiCol, tTxtCol), text_size=sz, bgcolor=rowBg)
    if showColRJ
        table.cell(tbl, cRJ, rnum, f_rjFollowStrDisp(res.rjFollow, res.rjFail, compact), text_color=f_rjFollowColor(res.rjFollow, res.rjFail, minSample, tHiCol, tTxtCol), text_size=sz, bgcolor=rowBg)
    if showCol22CR
        table.cell(tbl, c22CR, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showCol22FT
        table.cell(tbl, c22FT, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)


f_draw22SeqRow(table tbl, int rnum, string labelTxt, StatRes res, color labelColor, bool compact, string sz, color rowBg, int cZone, int cBzZ, int cAzZ, int cHigh, int cLow, int cBzZh, int cAzZl, int cStop, int cAmbig, int cCR, int cRJ, int c22CR, int c22FT) =>
    int seqCount = res.s22TcTotal
    table.cell(tbl, 0, rnum, labelTxt, text_color=labelColor, text_size=sz, bgcolor=rowBg)
    table.cell(tbl, 1, rnum, str.tostring(seqCount), text_color=tTxtCol, text_size=sz, bgcolor=f_countBg(seqCount, minSample, tWarnCol, rowBg))
    if showColZone
        table.cell(tbl, cZone, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColBzZ
        table.cell(tbl, cBzZ, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColAzZ
        table.cell(tbl, cAzZ, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColBzZh
        table.cell(tbl, cBzZh, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColHigh
        table.cell(tbl, cHigh, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColLow
        table.cell(tbl, cLow, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColAzZl
        table.cell(tbl, cAzZl, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColStop
        table.cell(tbl, cStop, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColAmbig
        table.cell(tbl, cAmbig, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColCR
        table.cell(tbl, cCR, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showColRJ
        table.cell(tbl, cRJ, rnum, "NA", text_color=tTxtCol, text_size=sz, bgcolor=rowBg)
    if showCol22CR
        table.cell(tbl, c22CR, rnum, f_truthOddsStrDisp(res.s22TcCont, res.s22TcReclaim, compact), text_color=f_truthOddsColor(res.s22TcCont, res.s22TcReclaim, minSample, tHiCol, tTxtCol), text_size=sz, bgcolor=rowBg)
    if showCol22FT
        table.cell(tbl, c22FT, rnum, f_rjFollowStrDisp(res.s22FtFollow, res.s22FtFail, compact), text_color=f_rjFollowColor(res.s22FtFollow, res.s22FtFail, minSample, tHiCol, tTxtCol), text_size=sz, bgcolor=rowBg)

// =====================================================
// 10) DASHBOARD
// =====================================================
var table t = table.new(tPos, 15, 36, tBg, color.gray, 1, color.gray, 1)

if barstate.islast
    table.clear(t, 0, 0, 14, 35)

if barstate.islast and showStratTbl
    bool compactTable = tableLayoutMode == "Compact Mobile"
    displaySize = compactTable ? size.tiny : tSize

    int colCursor = 2
    int colZone = na
    int colBzZ = na
    int colAzZ = na
    int colHigh = na
    int colLow = na
    int colBzZh = na
    int colAzZl = na
    int colStop = na
    int colAmbig = na
    int colCR = na
    int colRJ = na
    int col22CR = na
    int col22FT = na

    if showColZone
        colZone := colCursor
        colCursor += 1
    if showColBzZ
        colBzZ := colCursor
        colCursor += 1
    if showColAzZ
        colAzZ := colCursor
        colCursor += 1
    if showColHigh
        colHigh := colCursor
        colCursor += 1
    if showColLow
        colLow := colCursor
        colCursor += 1
    if showColBzZh
        colBzZh := colCursor
        colCursor += 1
    if showColAzZl
        colAzZl := colCursor
        colCursor += 1
    if showColStop
        colStop := colCursor
        colCursor += 1
    if showColAmbig
        colAmbig := colCursor
        colCursor += 1
    if showColCR
        colCR := colCursor
        colCursor += 1
    if showColRJ
        colRJ := colCursor
        colCursor += 1
    if showCol22CR
        col22CR := colCursor
        colCursor += 1
    if showCol22FT
        col22FT := colCursor
        colCursor += 1

    int lastTableCol = math.max(colCursor - 1, 1)

    string headerT = compactTable ? "Strat Prob  | " + tf + " | " + str.tostring(bflb) + " | W:" + str.tostring(win_in) : "The Strat Structural Probability Evaluator  | " + tf + " | " + str.tostring(bflb) + " Bars | Win: " + str.tostring(win_in)
    table.cell(t, 0, 0, headerT, bgcolor=color.new(color.blue, 70), text_color=tTxtCol, text_size=displaySize)
    table.merge_cells(t, 0, 0, lastTableCol, 0)

    table.cell(t, 0, 1, compactTable ? "Set" : "Setup", bgcolor=color.new(color.black, 40), text_color=tTxtCol, text_size=displaySize)
    table.cell(t, 1, 1, compactTable ? "#" : "Count", bgcolor=color.new(color.black, 40), text_color=tTxtCol, text_size=displaySize)
    if showColZone
        table.cell(t, colZone, 1, compactTable ? "Z" : "Zone 1st", bgcolor=color.new(color.black, 40), text_color=tTxtCol, text_size=displaySize)
    if showColBzZ
        table.cell(t, colBzZ, 1, "BZ-Z", bgcolor=color.new(color.black, 40), text_color=tTxtCol, text_size=displaySize)
    if showColAzZ
        table.cell(t, colAzZ, 1, "AZ-Z", bgcolor=color.new(color.black, 40), text_color=tTxtCol, text_size=displaySize)
    if showColHigh
        table.cell(t, colHigh, 1, compactTable ? "H" : "High 1st", bgcolor=color.new(color.black, 40), text_color=tTxtCol, text_size=displaySize)
    if showColLow
        table.cell(t, colLow, 1, compactTable ? "L" : "Low 1st", bgcolor=color.new(color.black, 40), text_color=tTxtCol, text_size=displaySize)
    if showColBzZh
        table.cell(t, colBzZh, 1, "BZ-Z-H", bgcolor=color.new(color.black, 40), text_color=tTxtCol, text_size=displaySize)
    if showColAzZl
        table.cell(t, colAzZl, 1, "AZ-Z-L", bgcolor=color.new(color.black, 40), text_color=tTxtCol, text_size=displaySize)
    if showColStop
        table.cell(t, colStop, 1, compactTable ? "S" : "Stop 1st", bgcolor=color.new(color.black, 40), text_color=tTxtCol, text_size=displaySize)
    if showColAmbig
        table.cell(t, colAmbig, 1, compactTable ? "2+" : "1-Bar\n2+ Hits", bgcolor=color.new(color.black, 40), text_color=tTxtCol, text_size=displaySize)
    if showColCR
        table.cell(t, colCR, 1, compactTable ? "F2/2x/x C/R%" : "F2/2x/x\nC/R%", bgcolor=color.new(color.black, 40), text_color=tTxtCol, text_size=displaySize)
    if showColRJ
        table.cell(t, colRJ, 1, compactTable ? "F2 R F/X%" : "F2\nR F/X %", bgcolor=color.new(color.black, 40), text_color=tTxtCol, text_size=displaySize)
    if showCol22CR
        table.cell(t, col22CR, 1, compactTable ? "22x C/R%" : "2-2-x\nC/R%", bgcolor=color.new(color.black, 40), text_color=tTxtCol, text_size=displaySize)
    if showCol22FT
        table.cell(t, col22FT, 1, compactTable ? "22x F/X%" : "2-2-x\nFThru/X %", bgcolor=color.new(color.black, 40), text_color=tTxtCol, text_size=displaySize)
    int row = 2
    color baseRowBg = color.new(color.black, 80)
    color avgRowBg = color.new(color.blue, 82)

    int avgRows = 0
    float avgCountSum = 0.0
    float avgZoneSum = 0.0
    float avgBzZSum = 0.0
    float avgAzZSum = 0.0
    float avgBzZhSum = 0.0
    float avgHighSum = 0.0
    float avgLowSum = 0.0
    float avgAzZlSum = 0.0
    float avgStopSum = 0.0
    float avgAmbigSum = 0.0
    float avgTimeoutSum = 0.0
    int avgTcContSum = 0
    int avgTcReclaimSum = 0
    int avgRjFollowSum = 0
    int avgRjFailSum = 0
    int avg22TcContSum = 0
    int avg22TcReclaimSum = 0
    int avg22FtFollowSum = 0
    int avg22FtFailSum = 0

    if showF2
        bool showRowF2U = not hideRowsBelowMinSample or rF2U.count >= minSample
        if showRowF2U
            f_drawStandardRow(t, row, f_setupRowLabelDisp("Failed 2 Up", compactTable), rF2U, color.red, compactTable, displaySize, baseRowBg, colZone, colBzZ, colAzZ, colHigh, colLow, colBzZh, colAzZl, colStop, colAmbig, colCR, colRJ, col22CR, col22FT, false, false)
        avgRows += 1
        avgCountSum += rF2U.count
        avgZoneSum += f_pct(rF2U.zoneFirst, rF2U.count)
        avgBzZSum += f_pct(rF2U.bzZ, rF2U.bzTotal)
        avgAzZSum += f_pct(rF2U.azZ, rF2U.azTotal)
        avgBzZhSum += f_pct(rF2U.bzZh, rF2U.bzTotal)
        avgHighSum += f_pct(rF2U.highFirst, rF2U.count)
        avgLowSum += f_pct(rF2U.lowFirst, rF2U.count)
        avgAzZlSum += f_pct(rF2U.azZl, rF2U.azTotal)
        avgStopSum += f_pct(rF2U.stopFirst, rF2U.count)
        avgAmbigSum += f_pct(rF2U.ambiguousFirst, rF2U.count)
        avgTimeoutSum += f_pct(rF2U.timeoutFirst, rF2U.count)
        avgTcContSum += rF2U.tcCont
        avgTcReclaimSum += rF2U.tcReclaim
        avgRjFollowSum += rF2U.rjFollow
        avgRjFailSum += rF2U.rjFail
        avg22TcContSum += rF2U.s22TcCont
        avg22TcReclaimSum += rF2U.s22TcReclaim
        avg22FtFollowSum += rF2U.s22FtFollow
        avg22FtFailSum += rF2U.s22FtFail
        if showRowF2U
            row += 1

        bool showRowF2D = not hideRowsBelowMinSample or rF2D.count >= minSample
        if showRowF2D
            f_drawStandardRow(t, row, f_setupRowLabelDisp("Failed 2 Down", compactTable), rF2D, color.green, compactTable, displaySize, baseRowBg, colZone, colBzZ, colAzZ, colHigh, colLow, colBzZh, colAzZl, colStop, colAmbig, colCR, colRJ, col22CR, col22FT, false, false)
        avgRows += 1
        avgCountSum += rF2D.count
        avgZoneSum += f_pct(rF2D.zoneFirst, rF2D.count)
        avgBzZSum += f_pct(rF2D.bzZ, rF2D.bzTotal)
        avgAzZSum += f_pct(rF2D.azZ, rF2D.azTotal)
        avgBzZhSum += f_pct(rF2D.bzZh, rF2D.bzTotal)
        avgHighSum += f_pct(rF2D.highFirst, rF2D.count)
        avgLowSum += f_pct(rF2D.lowFirst, rF2D.count)
        avgAzZlSum += f_pct(rF2D.azZl, rF2D.azTotal)
        avgStopSum += f_pct(rF2D.stopFirst, rF2D.count)
        avgAmbigSum += f_pct(rF2D.ambiguousFirst, rF2D.count)
        avgTimeoutSum += f_pct(rF2D.timeoutFirst, rF2D.count)
        avgTcContSum += rF2D.tcCont
        avgTcReclaimSum += rF2D.tcReclaim
        avgRjFollowSum += rF2D.rjFollow
        avgRjFailSum += rF2D.rjFail
        avg22TcContSum += rF2D.s22TcCont
        avg22TcReclaimSum += rF2D.s22TcReclaim
        avg22FtFollowSum += rF2D.s22FtFollow
        avg22FtFailSum += rF2D.s22FtFail
        if showRowF2D
            row += 1

    if show22
        bool showRow22U = not hideRowsBelowMinSample or r22U.count >= minSample
        if showRow22U
            f_drawStandardRow(t, row, f_setupRowLabelDisp("2-2 Rev Up", compactTable), r22U, color.green, compactTable, displaySize, baseRowBg, colZone, colBzZ, colAzZ, colHigh, colLow, colBzZh, colAzZl, colStop, colAmbig, colCR, colRJ, col22CR, col22FT, false, false)
        avgRows += 1
        avgCountSum += r22U.count
        avgZoneSum += f_pct(r22U.zoneFirst, r22U.count)
        avgBzZSum += f_pct(r22U.bzZ, r22U.bzTotal)
        avgAzZSum += f_pct(r22U.azZ, r22U.azTotal)
        avgBzZhSum += f_pct(r22U.bzZh, r22U.bzTotal)
        avgHighSum += f_pct(r22U.highFirst, r22U.count)
        avgLowSum += f_pct(r22U.lowFirst, r22U.count)
        avgAzZlSum += f_pct(r22U.azZl, r22U.azTotal)
        avgStopSum += f_pct(r22U.stopFirst, r22U.count)
        avgAmbigSum += f_pct(r22U.ambiguousFirst, r22U.count)
        avgTimeoutSum += f_pct(r22U.timeoutFirst, r22U.count)
        avgTcContSum += r22U.tcCont
        avgTcReclaimSum += r22U.tcReclaim
        avgRjFollowSum += r22U.rjFollow
        avgRjFailSum += r22U.rjFail
        avg22TcContSum += r22U.s22TcCont
        avg22TcReclaimSum += r22U.s22TcReclaim
        avg22FtFollowSum += r22U.s22FtFollow
        avg22FtFailSum += r22U.s22FtFail
        if showRow22U
            row += 1

        bool showRow22D = not hideRowsBelowMinSample or r22D.count >= minSample
        if showRow22D
            f_drawStandardRow(t, row, f_setupRowLabelDisp("2-2 Rev Down", compactTable), r22D, color.red, compactTable, displaySize, baseRowBg, colZone, colBzZ, colAzZ, colHigh, colLow, colBzZh, colAzZl, colStop, colAmbig, colCR, colRJ, col22CR, col22FT, false, false)
        avgRows += 1
        avgCountSum += r22D.count
        avgZoneSum += f_pct(r22D.zoneFirst, r22D.count)
        avgBzZSum += f_pct(r22D.bzZ, r22D.bzTotal)
        avgAzZSum += f_pct(r22D.azZ, r22D.azTotal)
        avgBzZhSum += f_pct(r22D.bzZh, r22D.bzTotal)
        avgHighSum += f_pct(r22D.highFirst, r22D.count)
        avgLowSum += f_pct(r22D.lowFirst, r22D.count)
        avgAzZlSum += f_pct(r22D.azZl, r22D.azTotal)
        avgStopSum += f_pct(r22D.stopFirst, r22D.count)
        avgAmbigSum += f_pct(r22D.ambiguousFirst, r22D.count)
        avgTimeoutSum += f_pct(r22D.timeoutFirst, r22D.count)
        avgTcContSum += r22D.tcCont
        avgTcReclaimSum += r22D.tcReclaim
        avgRjFollowSum += r22D.rjFollow
        avgRjFailSum += r22D.rjFail
        avg22TcContSum += r22D.s22TcCont
        avg22TcReclaimSum += r22D.s22TcReclaim
        avg22FtFollowSum += r22D.s22FtFollow
        avg22FtFailSum += r22D.s22FtFail
        if showRow22D
            row += 1

    if show212
        bool showRow212U = not hideRowsBelowMinSample or r212U.count >= minSample
        if showRow212U
            f_drawStandardRow(t, row, f_setupRowLabelDisp("2-1-2 Rev Up", compactTable), r212U, color.green, compactTable, displaySize, baseRowBg, colZone, colBzZ, colAzZ, colHigh, colLow, colBzZh, colAzZl, colStop, colAmbig, colCR, colRJ, col22CR, col22FT, false, false)
        avgRows += 1
        avgCountSum += r212U.count
        avgZoneSum += f_pct(r212U.zoneFirst, r212U.count)
        avgBzZSum += f_pct(r212U.bzZ, r212U.bzTotal)
        avgAzZSum += f_pct(r212U.azZ, r212U.azTotal)
        avgBzZhSum += f_pct(r212U.bzZh, r212U.bzTotal)
        avgHighSum += f_pct(r212U.highFirst, r212U.count)
        avgLowSum += f_pct(r212U.lowFirst, r212U.count)
        avgAzZlSum += f_pct(r212U.azZl, r212U.azTotal)
        avgStopSum += f_pct(r212U.stopFirst, r212U.count)
        avgAmbigSum += f_pct(r212U.ambiguousFirst, r212U.count)
        avgTimeoutSum += f_pct(r212U.timeoutFirst, r212U.count)
        avgTcContSum += r212U.tcCont
        avgTcReclaimSum += r212U.tcReclaim
        avgRjFollowSum += r212U.rjFollow
        avgRjFailSum += r212U.rjFail
        avg22TcContSum += r212U.s22TcCont
        avg22TcReclaimSum += r212U.s22TcReclaim
        avg22FtFollowSum += r212U.s22FtFollow
        avg22FtFailSum += r212U.s22FtFail
        if showRow212U
            row += 1

        bool showRow212D = not hideRowsBelowMinSample or r212D.count >= minSample
        if showRow212D
            f_drawStandardRow(t, row, f_setupRowLabelDisp("2-1-2 Rev Down", compactTable), r212D, color.red, compactTable, displaySize, baseRowBg, colZone, colBzZ, colAzZ, colHigh, colLow, colBzZh, colAzZl, colStop, colAmbig, colCR, colRJ, col22CR, col22FT, false, false)
        avgRows += 1
        avgCountSum += r212D.count
        avgZoneSum += f_pct(r212D.zoneFirst, r212D.count)
        avgBzZSum += f_pct(r212D.bzZ, r212D.bzTotal)
        avgAzZSum += f_pct(r212D.azZ, r212D.azTotal)
        avgBzZhSum += f_pct(r212D.bzZh, r212D.bzTotal)
        avgHighSum += f_pct(r212D.highFirst, r212D.count)
        avgLowSum += f_pct(r212D.lowFirst, r212D.count)
        avgAzZlSum += f_pct(r212D.azZl, r212D.azTotal)
        avgStopSum += f_pct(r212D.stopFirst, r212D.count)
        avgAmbigSum += f_pct(r212D.ambiguousFirst, r212D.count)
        avgTimeoutSum += f_pct(r212D.timeoutFirst, r212D.count)
        avgTcContSum += r212D.tcCont
        avgTcReclaimSum += r212D.tcReclaim
        avgRjFollowSum += r212D.rjFollow
        avgRjFailSum += r212D.rjFail
        avg22TcContSum += r212D.s22TcCont
        avg22TcReclaimSum += r212D.s22TcReclaim
        avg22FtFollowSum += r212D.s22FtFollow
        avg22FtFailSum += r212D.s22FtFail
        if showRow212D
            row += 1

    if show312
        bool showRow312U = not hideRowsBelowMinSample or r312U.count >= minSample
        if showRow312U
            f_drawStandardRow(t, row, f_setupRowLabelDisp("3-1-2 Rev Up", compactTable), r312U, color.green, compactTable, displaySize, baseRowBg, colZone, colBzZ, colAzZ, colHigh, colLow, colBzZh, colAzZl, colStop, colAmbig, colCR, colRJ, col22CR, col22FT, false, false)
        avgRows += 1
        avgCountSum += r312U.count
        avgZoneSum += f_pct(r312U.zoneFirst, r312U.count)
        avgBzZSum += f_pct(r312U.bzZ, r312U.bzTotal)
        avgAzZSum += f_pct(r312U.azZ, r312U.azTotal)
        avgBzZhSum += f_pct(r312U.bzZh, r312U.bzTotal)
        avgHighSum += f_pct(r312U.highFirst, r312U.count)
        avgLowSum += f_pct(r312U.lowFirst, r312U.count)
        avgAzZlSum += f_pct(r312U.azZl, r312U.azTotal)
        avgStopSum += f_pct(r312U.stopFirst, r312U.count)
        avgAmbigSum += f_pct(r312U.ambiguousFirst, r312U.count)
        avgTimeoutSum += f_pct(r312U.timeoutFirst, r312U.count)
        avgTcContSum += r312U.tcCont
        avgTcReclaimSum += r312U.tcReclaim
        avgRjFollowSum += r312U.rjFollow
        avgRjFailSum += r312U.rjFail
        avg22TcContSum += r312U.s22TcCont
        avg22TcReclaimSum += r312U.s22TcReclaim
        avg22FtFollowSum += r312U.s22FtFollow
        avg22FtFailSum += r312U.s22FtFail
        if showRow312U
            row += 1

        bool showRow312D = not hideRowsBelowMinSample or r312D.count >= minSample
        if showRow312D
            f_drawStandardRow(t, row, f_setupRowLabelDisp("3-1-2 Rev Down", compactTable), r312D, color.red, compactTable, displaySize, baseRowBg, colZone, colBzZ, colAzZ, colHigh, colLow, colBzZh, colAzZl, colStop, colAmbig, colCR, colRJ, col22CR, col22FT, false, false)
        avgRows += 1
        avgCountSum += r312D.count
        avgZoneSum += f_pct(r312D.zoneFirst, r312D.count)
        avgBzZSum += f_pct(r312D.bzZ, r312D.bzTotal)
        avgAzZSum += f_pct(r312D.azZ, r312D.azTotal)
        avgBzZhSum += f_pct(r312D.bzZh, r312D.bzTotal)
        avgHighSum += f_pct(r312D.highFirst, r312D.count)
        avgLowSum += f_pct(r312D.lowFirst, r312D.count)
        avgAzZlSum += f_pct(r312D.azZl, r312D.azTotal)
        avgStopSum += f_pct(r312D.stopFirst, r312D.count)
        avgAmbigSum += f_pct(r312D.ambiguousFirst, r312D.count)
        avgTimeoutSum += f_pct(r312D.timeoutFirst, r312D.count)
        avgTcContSum += r312D.tcCont
        avgTcReclaimSum += r312D.tcReclaim
        avgRjFollowSum += r312D.rjFollow
        avgRjFailSum += r312D.rjFail
        avg22TcContSum += r312D.s22TcCont
        avg22TcReclaimSum += r312D.s22TcReclaim
        avg22FtFollowSum += r312D.s22FtFollow
        avg22FtFailSum += r312D.s22FtFail
        if showRow312D
            row += 1

    if showCont
        bool showRowContU = not hideRowsBelowMinSample or rContU.count >= minSample
        if showRowContU
            f_drawStandardRow(t, row, "Cont Up", rContU, color.green, compactTable, displaySize, baseRowBg, colZone, colBzZ, colAzZ, colHigh, colLow, colBzZh, colAzZl, colStop, colAmbig, colCR, colRJ, col22CR, col22FT, false, false)
        avgRows += 1
        avgCountSum += rContU.count
        avgZoneSum += f_pct(rContU.zoneFirst, rContU.count)
        avgBzZSum += f_pct(rContU.bzZ, rContU.bzTotal)
        avgAzZSum += f_pct(rContU.azZ, rContU.azTotal)
        avgBzZhSum += f_pct(rContU.bzZh, rContU.bzTotal)
        avgHighSum += f_pct(rContU.highFirst, rContU.count)
        avgLowSum += f_pct(rContU.lowFirst, rContU.count)
        avgAzZlSum += f_pct(rContU.azZl, rContU.azTotal)
        avgStopSum += f_pct(rContU.stopFirst, rContU.count)
        avgAmbigSum += f_pct(rContU.ambiguousFirst, rContU.count)
        avgTimeoutSum += f_pct(rContU.timeoutFirst, rContU.count)
        avgTcContSum += rContU.tcCont
        avgTcReclaimSum += rContU.tcReclaim
        avgRjFollowSum += rContU.rjFollow
        avgRjFailSum += rContU.rjFail
        avg22TcContSum += rContU.s22TcCont
        avg22TcReclaimSum += rContU.s22TcReclaim
        avg22FtFollowSum += rContU.s22FtFollow
        avg22FtFailSum += rContU.s22FtFail
        if showRowContU
            row += 1

        bool showRowContD = not hideRowsBelowMinSample or rContD.count >= minSample
        if showRowContD
            f_drawStandardRow(t, row, "Cont Down", rContD, color.red, compactTable, displaySize, baseRowBg, colZone, colBzZ, colAzZ, colHigh, colLow, colBzZh, colAzZl, colStop, colAmbig, colCR, colRJ, col22CR, col22FT, false, false)
        avgRows += 1
        avgCountSum += rContD.count
        avgZoneSum += f_pct(rContD.zoneFirst, rContD.count)
        avgBzZSum += f_pct(rContD.bzZ, rContD.bzTotal)
        avgAzZSum += f_pct(rContD.azZ, rContD.azTotal)
        avgBzZhSum += f_pct(rContD.bzZh, rContD.bzTotal)
        avgHighSum += f_pct(rContD.highFirst, rContD.count)
        avgLowSum += f_pct(rContD.lowFirst, rContD.count)
        avgAzZlSum += f_pct(rContD.azZl, rContD.azTotal)
        avgStopSum += f_pct(rContD.stopFirst, rContD.count)
        avgAmbigSum += f_pct(rContD.ambiguousFirst, rContD.count)
        avgTimeoutSum += f_pct(rContD.timeoutFirst, rContD.count)
        avgTcContSum += rContD.tcCont
        avgTcReclaimSum += rContD.tcReclaim
        avgRjFollowSum += rContD.rjFollow
        avgRjFailSum += rContD.rjFail
        avg22TcContSum += rContD.s22TcCont
        avg22TcReclaimSum += rContD.s22TcReclaim
        avg22FtFollowSum += rContD.s22FtFollow
        avg22FtFailSum += rContD.s22FtFail
        if showRowContD
            row += 1

    if avgRows > 0
        float avgCount = avgCountSum / avgRows
        float avgZone = avgZoneSum / avgRows
        float avgBzZ = avgBzZSum / avgRows
        float avgAzZ = avgAzZSum / avgRows
        float avgBzZh = avgBzZhSum / avgRows
        float avgHigh = avgHighSum / avgRows
        float avgLow = avgLowSum / avgRows
        float avgAzZl = avgAzZlSum / avgRows
        float avgStop = avgStopSum / avgRows
        float avgAmbig = avgAmbigSum / avgRows
        float avgTimeout = avgTimeoutSum / avgRows

        table.cell(t, 0, row, "Average", text_color=tTxtCol, text_size=displaySize, bgcolor=avgRowBg)
        table.cell(t, 1, row, f_avgNumStr(avgCount), text_color=tTxtCol, text_size=displaySize, bgcolor=avgRowBg)
        if showColZone
            table.cell(t, colZone, row, f_avgPctStr(avgZone), text_color=tTxtCol, text_size=displaySize, bgcolor=avgRowBg)
        if showColBzZ
            table.cell(t, colBzZ, row, f_avgPctStr(avgBzZ), text_color=tTxtCol, text_size=displaySize, bgcolor=avgRowBg)
        if showColAzZ
            table.cell(t, colAzZ, row, f_avgPctStr(avgAzZ), text_color=tTxtCol, text_size=displaySize, bgcolor=avgRowBg)
        if showColHigh
            table.cell(t, colHigh, row, f_avgPctStr(avgHigh), text_color=tTxtCol, text_size=displaySize, bgcolor=avgRowBg)
        if showColLow
            table.cell(t, colLow, row, f_avgPctStr(avgLow), text_color=tTxtCol, text_size=displaySize, bgcolor=avgRowBg)
        if showColBzZh
            table.cell(t, colBzZh, row, f_avgPctStr(avgBzZh), text_color=tTxtCol, text_size=displaySize, bgcolor=avgRowBg)
        if showColAzZl
            table.cell(t, colAzZl, row, f_avgPctStr(avgAzZl), text_color=tTxtCol, text_size=displaySize, bgcolor=avgRowBg)
        if showColStop
            table.cell(t, colStop, row, f_avgPctStr(avgStop), text_color=tTxtCol, text_size=displaySize, bgcolor=avgRowBg)
        if showColAmbig
            table.cell(t, colAmbig, row, f_avgPctStr(avgAmbig), text_color=tTxtCol, text_size=displaySize, bgcolor=avgRowBg)
        if showColCR
            table.cell(t, colCR, row, f_truthOddsStrDisp(avgTcContSum, avgTcReclaimSum, compactTable), text_color=f_truthOddsColor(avgTcContSum, avgTcReclaimSum, minSample, tHiCol, tTxtCol), text_size=displaySize, bgcolor=avgRowBg)
        if showColRJ
            table.cell(t, colRJ, row, f_rjFollowStrDisp(avgRjFollowSum, avgRjFailSum, compactTable), text_color=f_rjFollowColor(avgRjFollowSum, avgRjFailSum, minSample, tHiCol, tTxtCol), text_size=displaySize, bgcolor=avgRowBg)
        if showCol22CR
            table.cell(t, col22CR, row, f_truthOddsStrDisp(avg22TcContSum, avg22TcReclaimSum, compactTable), text_color=f_truthOddsColor(avg22TcContSum, avg22TcReclaimSum, minSample, tHiCol, tTxtCol), text_size=displaySize, bgcolor=avgRowBg)
        if showCol22FT
            table.cell(t, col22FT, row, f_rjFollowStrDisp(avg22FtFollowSum, avg22FtFailSum, compactTable), text_color=f_rjFollowColor(avg22FtFollowSum, avg22FtFailSum, minSample, tHiCol, tTxtCol), text_size=displaySize, bgcolor=avgRowBg)
        row += 1

    if showF2SequenceRows
        f_drawF2SeqRow(t, row, compactTable ? "▼ F2U→2D→x" : "▼ F2U → 2D → x", r22D, color.red, compactTable, displaySize, baseRowBg, colZone, colBzZ, colAzZ, colHigh, colLow, colBzZh, colAzZl, colStop, colAmbig, colCR, colRJ, col22CR, col22FT)
        row += 1
        f_drawF2SeqRow(t, row, compactTable ? "▲ F2D→2U→x" : "▲ F2D → 2U → x", r22U, color.green, compactTable, displaySize, baseRowBg, colZone, colBzZ, colAzZ, colHigh, colLow, colBzZh, colAzZl, colStop, colAmbig, colCR, colRJ, col22CR, col22FT)
        row += 1

    if show22SequenceRows
        f_draw22SeqRow(t, row, compactTable ? "● 22U→x" : "● 2-2U → x", r22U, color.green, compactTable, displaySize, baseRowBg, colZone, colBzZ, colAzZ, colHigh, colLow, colBzZh, colAzZl, colStop, colAmbig, colCR, colRJ, col22CR, col22FT)
        row += 1
        f_draw22SeqRow(t, row, compactTable ? "● 22D→x" : "● 2-2D → x", r22D, color.red, compactTable, displaySize, baseRowBg, colZone, colBzZ, colAzZ, colHigh, colLow, colBzZh, colAzZl, colStop, colAmbig, colCR, colRJ, col22CR, col22FT)
        row += 1

    if showBfBreakRows
        string revStrat3HeaderTxt = compactTable ? "Strat 3/2 Metrics" : "Strat 3/2 Metrics: 3 candle → next candle breaks 3H/3L; close decides C/R | next closed candle decides F/X"
        table.cell(t, 0, row, revStrat3HeaderTxt, text_color=tTxtCol, text_size=displaySize, bgcolor=color.new(color.purple, 78))
        table.merge_cells(t, 0, row, lastTableCol, row)
        row += 1
        f_drawBfBreakRow(t, row, compactTable ? "▲ 3H→x" : "▲ 3 High Break → x", bfBreakUpTotal, bfBreakUpCont, bfBreakUpReclaim, bfBreakUpFollow, bfBreakUpFail, color.green, compactTable, displaySize, baseRowBg, colZone, colBzZ, colAzZ, colHigh, colLow, colBzZh, colAzZl, colStop, colAmbig, colCR, colRJ, col22CR, col22FT)
        row += 1
        f_drawBfBreakRow(t, row, compactTable ? "▼ 3L→x" : "▼ 3 Low Break → x", bfBreakDownTotal, bfBreakDownCont, bfBreakDownReclaim, bfBreakDownFollow, bfBreakDownFail, color.red, compactTable, displaySize, baseRowBg, colZone, colBzZ, colAzZ, colHigh, colLow, colBzZh, colAzZl, colStop, colAmbig, colCR, colRJ, col22CR, col22FT)
        row += 1

    if showAmbigDetail
        string ambigDetailRowTxt = "1-Bar 2+ Hits: Zone+High " + str.tostring(ambigZoneHighCount) + " | Zone+Low " + str.tostring(ambigZoneLowCount) + " | Zone+Stop " + str.tostring(ambigZoneStopCount) + " | High+Low " + str.tostring(ambigHighLowCount) + " | High+Stop " + str.tostring(ambigHighStopCount) + " | Low+Stop " + str.tostring(ambigLowStopCount) + " | 3+ Hits " + str.tostring(ambigThreePlusCount)
        table.cell(t, 0, row, ambigDetailRowTxt, text_color=tTxtCol, text_size=displaySize, bgcolor=color.new(color.yellow, 86))
        table.merge_cells(t, 0, row, lastTableCol, row)
        row += 1

    trueBFPctOfSetups := 0.0
    if trueBFSetupTotal > 0
        trueBFPctOfSetups := (trueBFTotalCount / float(trueBFSetupTotal)) * 100.0

    int bfSummaryTitleRow = row
    table.cell(t, 0, bfSummaryTitleRow, "True BF Summary (" + bfEvalTf + ")", bgcolor=color.new(color.blue, 82), text_color=tTxtCol, text_size=displaySize)
    table.merge_cells(t, 0, bfSummaryTitleRow, lastTableCol, bfSummaryTitleRow)
    row += 1

    if lastTableCol >= 11
        table.cell(t, 0, row, "BF-U", text_color=color.lime, text_size=displaySize, bgcolor=baseRowBg)
        table.cell(t, 1, row, str.tostring(trueBFUpCount), text_color=tTxtCol, text_size=displaySize, bgcolor=baseRowBg)
        table.cell(t, 2, row, "BF-D", text_color=color.red, text_size=displaySize, bgcolor=baseRowBg)
        table.cell(t, 4, row, str.tostring(trueBFDownCount), text_color=tTxtCol, text_size=displaySize, bgcolor=baseRowBg)
        table.cell(t, 5, row, "Both", text_color=color.yellow, text_size=displaySize, bgcolor=baseRowBg)
        table.cell(t, 7, row, str.tostring(trueBFBothCount), text_color=tTxtCol, text_size=displaySize, bgcolor=baseRowBg)
        table.cell(t, 10, row, "Total BF", text_color=tTxtCol, text_size=displaySize, bgcolor=baseRowBg)
        table.cell(t, 11, row, str.tostring(trueBFTotalCount), text_color=tTxtCol, text_size=displaySize, bgcolor=baseRowBg)
    else
        string bfSummaryCountsTxt = "BF-U " + str.tostring(trueBFUpCount) + " | BF-D " + str.tostring(trueBFDownCount) + " | Both " + str.tostring(trueBFBothCount) + " | Total BF " + str.tostring(trueBFTotalCount)
        table.cell(t, 0, row, bfSummaryCountsTxt, text_color=tTxtCol, text_size=displaySize, bgcolor=baseRowBg)
        table.merge_cells(t, 0, row, lastTableCol, row)
    row += 1

    if showLowerBfDetailRows
        int bfClassTotal = trueBFUpCount + trueBFDownCount + trueBFBothCount
        float trueBFBothPctOfBFEvents = 0.0
        if bfClassTotal > 0
            trueBFBothPctOfBFEvents := (trueBFBothCount / float(bfClassTotal)) * 100.0

        table.cell(t, 0, row, "BF Both % of BF Events: " + str.tostring(trueBFBothPctOfBFEvents, "#.##") + "%", text_color=tTxtCol, text_size=displaySize, bgcolor=avgRowBg)
        table.merge_cells(t, 0, row, lastTableCol, row)
        row += 1

        table.cell(t, 0, row, "Setup Total: " + str.tostring(trueBFSetupTotal) + " | True BF % of All Setups: " + str.tostring(trueBFPctOfSetups, "#.##") + "%", text_color=tTxtCol, text_size=displaySize, bgcolor=avgRowBg)
        table.merge_cells(t, 0, row, lastTableCol, row)
        row += 1

        int lastLoggedRow = row
        table.cell(t, 0, lastLoggedRow, "Last Logged: " + lastLoggedTxt, bgcolor=color.new(color.blue, 82), text_color=tTxtCol, text_size=displaySize)
        table.merge_cells(t, 0, lastLoggedRow, lastTableCol, lastLoggedRow)

        int footerRow1 = lastLoggedRow + 1
        string footer1 = "HTF Bias: " + (isBullHTF ? "Bullish HTF" : "Bearish HTF") + " | Stop: " + stopMode + " | Buffer: " + stopBufType + " " + str.tostring(stopBufValue) + " | BF Eval TF: " + bfEvalTf
        table.cell(t, 0, footerRow1, footer1, bgcolor=color.new(color.blue, 85), text_color=tTxtCol, text_size=displaySize)
        table.merge_cells(t, 0, footerRow1, lastTableCol, footerRow1)

        int footerRow2 = footerRow1 + 1
        string capTxt = ""
        if memoryCapActive
            capTxt := " | MEM CAP ON: Stored " + str.tostring(array.size(sigs)) + "/" + str.tostring(rawKeepBars) + " chart bars"
        else
            capTxt := " | Stored " + str.tostring(array.size(sigs)) + "/" + str.tostring(rawKeepBars) + " chart bars"
        string footer2 = "BF Lookback: " + str.tostring(bfLookbackBars) + " | Resolution: " + resolutionCountMode + " | Overlap Filter: " + (skipOverlap ? "ON" : "OFF") + " | Low Sample Warn < " + str.tostring(minSample) + capTxt
        color footer2Bg = color.new(color.blue, 85)
        if memoryCapActive
            footer2Bg := color.new(color.orange, 65)
        table.cell(t, 0, footerRow2, footer2, bgcolor=footer2Bg, text_color=tTxtCol, text_size=displaySize)
        table.merge_cells(t, 0, footerRow2, lastTableCol, footerRow2)

// =====================================================
// 11) LOOKBACK DIVIDER REMOVED
// =====================================================
// Removed in v6.2.2 to recover Pine compiled-token budget for the Strat table visibility toggle.

// =====================================================
// 12) JSON WEBHOOK EXPORT
// =====================================================
f_jsonPairStr(string k, string v) =>
    "\"" + k + "\":\"" + v + "\""

f_jsonPairNum(string k, int v) =>
    "\"" + k + "\":" + str.tostring(v)

f_jsonPairFloat(string k, float v) =>
    "\"" + k + "\":" + str.tostring(v, "#.##")

f_buildJsonPayload() =>
    int contLegacyCount = rContU.count + rContD.count
    int contLegacyZone = rContU.zoneFirst + rContD.zoneFirst
    int contLegacyHigh = rContU.highFirst + rContD.highFirst
    int contLegacyLow = rContU.lowFirst + rContD.lowFirst
    int contLegacyStop = rContU.stopFirst + rContD.stopFirst
    int contLegacyAmbig = rContU.ambiguousFirst + rContD.ambiguousFirst
    int contLegacyTimeout = rContU.timeoutFirst + rContD.timeoutFirst
    int contLegacyBfFollow = rContU.bfFollow + rContD.bfFollow
    int contLegacyBzTotal = rContU.bzTotal + rContD.bzTotal
    int contLegacyBzZ = rContU.bzZ + rContD.bzZ
    int contLegacyBzZh = rContU.bzZh + rContD.bzZh
    int contLegacyAzTotal = rContU.azTotal + rContD.azTotal
    int contLegacyAzZ = rContU.azZ + rContD.azZ
    int contLegacyAzZl = rContU.azZl + rContD.azZl

    int crAvgCont = r22U.tcCont + r22D.tcCont
    int crAvgReclaim = r22U.tcReclaim + r22D.tcReclaim
    int crAvgTotal = crAvgCont + crAvgReclaim
    int rjAvgFollow = r22U.rjFollow + r22D.rjFollow
    int rjAvgFail = r22U.rjFail + r22D.rjFail
    int rjAvgTotal = rjAvgFollow + rjAvgFail
    int s22CrAvgCont = r22U.s22TcCont + r22D.s22TcCont
    int s22CrAvgReclaim = r22U.s22TcReclaim + r22D.s22TcReclaim
    int s22CrAvgTotal = s22CrAvgCont + s22CrAvgReclaim
    int s22FtAvgFollow = r22U.s22FtFollow + r22D.s22FtFollow
    int s22FtAvgFail = r22U.s22FtFail + r22D.s22FtFail
    int s22FtAvgTotal = s22FtAvgFollow + s22FtAvgFail
    int bfBreakAvgCont = bfBreakUpCont + bfBreakDownCont
    int bfBreakAvgReclaim = bfBreakUpReclaim + bfBreakDownReclaim
    int bfBreakAvgTotal = bfBreakAvgCont + bfBreakAvgReclaim
    int bfBreakAvgFollow = bfBreakUpFollow + bfBreakDownFollow
    int bfBreakAvgFail = bfBreakUpFail + bfBreakDownFail
    int bfBreakAvgFxTotal = bfBreakAvgFollow + bfBreakAvgFail

    int bfClassTotalJson = trueBFUpCount + trueBFDownCount + trueBFBothCount
    float trueBFBothPctOfBFEventsJson = 0.0
    if bfClassTotalJson > 0
        trueBFBothPctOfBFEventsJson := (trueBFBothCount / float(bfClassTotalJson)) * 100.0

    string payload = "{"

    payload += f_jsonPairStr("ticker", customTicker) + ","
    payload += f_jsonPairStr("chart_ticker", syminfo.ticker) + ","
    payload += f_jsonPairStr("tf", tf) + ","

    if includeMeta
        payload += f_jsonPairStr("htf_bias", isBullHTF ? "bullish" : "bearish") + ","
        payload += f_jsonPairStr("stop_mode", stopMode) + ","
        payload += f_jsonPairStr("stop_buffer_type", stopBufType) + ","
        payload += f_jsonPairFloat("stop_buffer_value", stopBufValue) + ","
        payload += f_jsonPairNum("structure_lookback", bflb) + ","
        payload += f_jsonPairNum("resolution_window", win_in) + ","
        payload += f_jsonPairStr("resolution_count_mode", resolutionCountMode) + ","
        payload += f_jsonPairNum("stat_lookback", slb_in) + ","
        payload += f_jsonPairStr("overlap_filter", skipOverlap ? "on" : "off") + ","
        payload += f_jsonPairNum("min_sample", minSample) + ","
        payload += f_jsonPairFloat("bf_high", mtfH) + ","
        payload += f_jsonPairFloat("bf_low", mtfL) + ","
        payload += f_jsonPairFloat("zone_top", zTop) + ","
        payload += f_jsonPairFloat("zone_bottom", zBot) + ","

    payload += f_jsonPairNum("f2u_cnt", rF2U.count) + ","
    payload += f_jsonPairStr("f2u_z", f_pctStr(rF2U.zoneFirst, rF2U.count)) + ","
    payload += f_jsonPairStr("f2u_h", f_pctStr(rF2U.highFirst, rF2U.count)) + ","
    payload += f_jsonPairStr("f2u_l", f_pctStr(rF2U.lowFirst, rF2U.count)) + ","
    payload += f_jsonPairStr("f2u_s", f_pctStr(rF2U.stopFirst, rF2U.count)) + ","
    payload += f_jsonPairStr("f2u_a", f_pctStr(rF2U.ambiguousFirst, rF2U.count)) + ","
    payload += f_jsonPairStr("f2u_t", f_pctStr(rF2U.timeoutFirst, rF2U.count)) + ","
    payload += f_jsonPairStr("f2u_bf", f_pctStr(rF2U.bfFollow, rF2U.zoneFirst)) + ","
    payload += f_jsonPairStr("f2u_bz_z", f_pctStr(rF2U.bzZ, rF2U.bzTotal)) + ","
    payload += f_jsonPairNum("f2u_bz_z_hits", rF2U.bzZ) + ","
    payload += f_jsonPairNum("f2u_bz_z_total", rF2U.bzTotal) + ","
    payload += f_jsonPairStr("f2u_az_z", f_pctStr(rF2U.azZ, rF2U.azTotal)) + ","
    payload += f_jsonPairNum("f2u_az_z_hits", rF2U.azZ) + ","
    payload += f_jsonPairNum("f2u_az_z_total", rF2U.azTotal) + ","
    payload += f_jsonPairNum("f2u_bz_zh_hits", rF2U.bzZh) + ","
    payload += f_jsonPairNum("f2u_bz_zh_total", rF2U.bzTotal) + ","
    payload += f_jsonPairNum("f2u_az_zl_hits", rF2U.azZl) + ","
    payload += f_jsonPairNum("f2u_az_zl_total", rF2U.azTotal) + ","
    payload += f_jsonPairStr("f2u_bz_zh", f_pctStr(rF2U.bzZh, rF2U.bzTotal)) + ","
    payload += f_jsonPairStr("f2u_az_zl", f_pctStr(rF2U.azZl, rF2U.azTotal)) + ","

    payload += f_jsonPairNum("f2d_cnt", rF2D.count) + ","
    payload += f_jsonPairStr("f2d_z", f_pctStr(rF2D.zoneFirst, rF2D.count)) + ","
    payload += f_jsonPairStr("f2d_h", f_pctStr(rF2D.highFirst, rF2D.count)) + ","
    payload += f_jsonPairStr("f2d_l", f_pctStr(rF2D.lowFirst, rF2D.count)) + ","
    payload += f_jsonPairStr("f2d_s", f_pctStr(rF2D.stopFirst, rF2D.count)) + ","
    payload += f_jsonPairStr("f2d_a", f_pctStr(rF2D.ambiguousFirst, rF2D.count)) + ","
    payload += f_jsonPairStr("f2d_t", f_pctStr(rF2D.timeoutFirst, rF2D.count)) + ","
    payload += f_jsonPairStr("f2d_bf", f_pctStr(rF2D.bfFollow, rF2D.zoneFirst)) + ","
    payload += f_jsonPairStr("f2d_bz_z", f_pctStr(rF2D.bzZ, rF2D.bzTotal)) + ","
    payload += f_jsonPairNum("f2d_bz_z_hits", rF2D.bzZ) + ","
    payload += f_jsonPairNum("f2d_bz_z_total", rF2D.bzTotal) + ","
    payload += f_jsonPairStr("f2d_az_z", f_pctStr(rF2D.azZ, rF2D.azTotal)) + ","
    payload += f_jsonPairNum("f2d_az_z_hits", rF2D.azZ) + ","
    payload += f_jsonPairNum("f2d_az_z_total", rF2D.azTotal) + ","
    payload += f_jsonPairNum("f2d_bz_zh_hits", rF2D.bzZh) + ","
    payload += f_jsonPairNum("f2d_bz_zh_total", rF2D.bzTotal) + ","
    payload += f_jsonPairNum("f2d_az_zl_hits", rF2D.azZl) + ","
    payload += f_jsonPairNum("f2d_az_zl_total", rF2D.azTotal) + ","
    payload += f_jsonPairStr("f2d_bz_zh", f_pctStr(rF2D.bzZh, rF2D.bzTotal)) + ","
    payload += f_jsonPairStr("f2d_az_zl", f_pctStr(rF2D.azZl, rF2D.azTotal)) + ","

    payload += f_jsonPairNum("2d2u_cnt", r22U.count) + ","
    payload += f_jsonPairStr("2d2u_z", f_pctStr(r22U.zoneFirst, r22U.count)) + ","
    payload += f_jsonPairStr("2d2u_h", f_pctStr(r22U.highFirst, r22U.count)) + ","
    payload += f_jsonPairStr("2d2u_l", f_pctStr(r22U.lowFirst, r22U.count)) + ","
    payload += f_jsonPairStr("2d2u_s", f_pctStr(r22U.stopFirst, r22U.count)) + ","
    payload += f_jsonPairStr("2d2u_a", f_pctStr(r22U.ambiguousFirst, r22U.count)) + ","
    payload += f_jsonPairStr("2d2u_t", f_pctStr(r22U.timeoutFirst, r22U.count)) + ","
    payload += f_jsonPairStr("2d2u_bf", f_pctStr(r22U.bfFollow, r22U.zoneFirst)) + ","
    payload += f_jsonPairStr("2d2u_bz_z", f_pctStr(r22U.bzZ, r22U.bzTotal)) + ","
    payload += f_jsonPairNum("2d2u_bz_z_hits", r22U.bzZ) + ","
    payload += f_jsonPairNum("2d2u_bz_z_total", r22U.bzTotal) + ","
    payload += f_jsonPairStr("2d2u_az_z", f_pctStr(r22U.azZ, r22U.azTotal)) + ","
    payload += f_jsonPairNum("2d2u_az_z_hits", r22U.azZ) + ","
    payload += f_jsonPairNum("2d2u_az_z_total", r22U.azTotal) + ","
    payload += f_jsonPairNum("2d2u_bz_zh_hits", r22U.bzZh) + ","
    payload += f_jsonPairNum("2d2u_bz_zh_total", r22U.bzTotal) + ","
    payload += f_jsonPairNum("2d2u_az_zl_hits", r22U.azZl) + ","
    payload += f_jsonPairNum("2d2u_az_zl_total", r22U.azTotal) + ","
    payload += f_jsonPairStr("2d2u_bz_zh", f_pctStr(r22U.bzZh, r22U.bzTotal)) + ","
    payload += f_jsonPairStr("2d2u_az_zl", f_pctStr(r22U.azZl, r22U.azTotal)) + ","
    payload += f_jsonPairStr("2d2u_cr_edge", f_truthOddsStrCnt(r22U.tcCont, r22U.tcReclaim)) + ","
    payload += f_jsonPairStr("2d2u_cr_bias", f_truthWinnerStr(r22U.tcCont, r22U.tcReclaim)) + ","
    payload += f_jsonPairNum("2d2u_cr_cont_hits", r22U.tcCont) + ","
    payload += f_jsonPairNum("2d2u_cr_reclaim_hits", r22U.tcReclaim) + ","
    payload += f_jsonPairNum("2d2u_cr_total", r22U.tcCont + r22U.tcReclaim) + ","
    payload += f_jsonPairStr("2d2u_cr_cont_pct", f_pctStr(r22U.tcCont, r22U.tcCont + r22U.tcReclaim)) + ","
    payload += f_jsonPairStr("2d2u_cr_reclaim_pct", f_pctStr(r22U.tcReclaim, r22U.tcCont + r22U.tcReclaim)) + ","
    payload += f_jsonPairStr("2d2u_rj_follow_edge", f_rjFollowStrCnt(r22U.rjFollow, r22U.rjFail)) + ","
    payload += f_jsonPairNum("2d2u_rj_follow_hits", r22U.rjFollow) + ","
    payload += f_jsonPairNum("2d2u_rj_fail_hits", r22U.rjFail) + ","
    payload += f_jsonPairNum("2d2u_rj_total", r22U.rjFollow + r22U.rjFail) + ","
    payload += f_jsonPairStr("2d2u_rj_follow_pct", f_pctStr(r22U.rjFollow, r22U.rjFollow + r22U.rjFail)) + ","
    payload += f_jsonPairStr("2d2u_rj_fail_pct", f_pctStr(r22U.rjFail, r22U.rjFollow + r22U.rjFail)) + ","
    payload += f_jsonPairStr("any22u_cr_edge", f_truthOddsStrCnt(r22U.s22TcCont, r22U.s22TcReclaim)) + ","
    payload += f_jsonPairStr("any22u_cr_bias", f_truthWinnerStr(r22U.s22TcCont, r22U.s22TcReclaim)) + ","
    payload += f_jsonPairNum("any22u_cr_cont_hits", r22U.s22TcCont) + ","
    payload += f_jsonPairNum("any22u_cr_reclaim_hits", r22U.s22TcReclaim) + ","
    payload += f_jsonPairNum("any22u_cr_total", r22U.s22TcCont + r22U.s22TcReclaim) + ","
    payload += f_jsonPairStr("any22u_cr_cont_pct", f_pctStr(r22U.s22TcCont, r22U.s22TcCont + r22U.s22TcReclaim)) + ","
    payload += f_jsonPairStr("any22u_cr_reclaim_pct", f_pctStr(r22U.s22TcReclaim, r22U.s22TcCont + r22U.s22TcReclaim)) + ","
    payload += f_jsonPairStr("any22u_ft_edge", f_rjFollowStrCnt(r22U.s22FtFollow, r22U.s22FtFail)) + ","
    payload += f_jsonPairNum("any22u_ft_follow_hits", r22U.s22FtFollow) + ","
    payload += f_jsonPairNum("any22u_ft_fail_hits", r22U.s22FtFail) + ","
    payload += f_jsonPairNum("any22u_ft_total", r22U.s22FtFollow + r22U.s22FtFail) + ","
    payload += f_jsonPairStr("any22u_ft_follow_pct", f_pctStr(r22U.s22FtFollow, r22U.s22FtFollow + r22U.s22FtFail)) + ","
    payload += f_jsonPairStr("any22u_ft_fail_pct", f_pctStr(r22U.s22FtFail, r22U.s22FtFollow + r22U.s22FtFail)) + ","

    payload += f_jsonPairNum("2u2d_cnt", r22D.count) + ","
    payload += f_jsonPairStr("2u2d_z", f_pctStr(r22D.zoneFirst, r22D.count)) + ","
    payload += f_jsonPairStr("2u2d_h", f_pctStr(r22D.highFirst, r22D.count)) + ","
    payload += f_jsonPairStr("2u2d_l", f_pctStr(r22D.lowFirst, r22D.count)) + ","
    payload += f_jsonPairStr("2u2d_s", f_pctStr(r22D.stopFirst, r22D.count)) + ","
    payload += f_jsonPairStr("2u2d_a", f_pctStr(r22D.ambiguousFirst, r22D.count)) + ","
    payload += f_jsonPairStr("2u2d_t", f_pctStr(r22D.timeoutFirst, r22D.count)) + ","
    payload += f_jsonPairStr("2u2d_bf", f_pctStr(r22D.bfFollow, r22D.zoneFirst)) + ","
    payload += f_jsonPairStr("2u2d_bz_z", f_pctStr(r22D.bzZ, r22D.bzTotal)) + ","
    payload += f_jsonPairNum("2u2d_bz_z_hits", r22D.bzZ) + ","
    payload += f_jsonPairNum("2u2d_bz_z_total", r22D.bzTotal) + ","
    payload += f_jsonPairStr("2u2d_az_z", f_pctStr(r22D.azZ, r22D.azTotal)) + ","
    payload += f_jsonPairNum("2u2d_az_z_hits", r22D.azZ) + ","
    payload += f_jsonPairNum("2u2d_az_z_total", r22D.azTotal) + ","
    payload += f_jsonPairNum("2u2d_bz_zh_hits", r22D.bzZh) + ","
    payload += f_jsonPairNum("2u2d_bz_zh_total", r22D.bzTotal) + ","
    payload += f_jsonPairNum("2u2d_az_zl_hits", r22D.azZl) + ","
    payload += f_jsonPairNum("2u2d_az_zl_total", r22D.azTotal) + ","
    payload += f_jsonPairStr("2u2d_bz_zh", f_pctStr(r22D.bzZh, r22D.bzTotal)) + ","
    payload += f_jsonPairStr("2u2d_az_zl", f_pctStr(r22D.azZl, r22D.azTotal)) + ","
    payload += f_jsonPairStr("2u2d_cr_edge", f_truthOddsStrCnt(r22D.tcCont, r22D.tcReclaim)) + ","
    payload += f_jsonPairStr("2u2d_cr_bias", f_truthWinnerStr(r22D.tcCont, r22D.tcReclaim)) + ","
    payload += f_jsonPairNum("2u2d_cr_cont_hits", r22D.tcCont) + ","
    payload += f_jsonPairNum("2u2d_cr_reclaim_hits", r22D.tcReclaim) + ","
    payload += f_jsonPairNum("2u2d_cr_total", r22D.tcCont + r22D.tcReclaim) + ","
    payload += f_jsonPairStr("2u2d_cr_cont_pct", f_pctStr(r22D.tcCont, r22D.tcCont + r22D.tcReclaim)) + ","
    payload += f_jsonPairStr("2u2d_cr_reclaim_pct", f_pctStr(r22D.tcReclaim, r22D.tcCont + r22D.tcReclaim)) + ","
    payload += f_jsonPairStr("2u2d_rj_follow_edge", f_rjFollowStrCnt(r22D.rjFollow, r22D.rjFail)) + ","
    payload += f_jsonPairNum("2u2d_rj_follow_hits", r22D.rjFollow) + ","
    payload += f_jsonPairNum("2u2d_rj_fail_hits", r22D.rjFail) + ","
    payload += f_jsonPairNum("2u2d_rj_total", r22D.rjFollow + r22D.rjFail) + ","
    payload += f_jsonPairStr("2u2d_rj_follow_pct", f_pctStr(r22D.rjFollow, r22D.rjFollow + r22D.rjFail)) + ","
    payload += f_jsonPairStr("2u2d_rj_fail_pct", f_pctStr(r22D.rjFail, r22D.rjFollow + r22D.rjFail)) + ","
    payload += f_jsonPairStr("any22d_cr_edge", f_truthOddsStrCnt(r22D.s22TcCont, r22D.s22TcReclaim)) + ","
    payload += f_jsonPairStr("any22d_cr_bias", f_truthWinnerStr(r22D.s22TcCont, r22D.s22TcReclaim)) + ","
    payload += f_jsonPairNum("any22d_cr_cont_hits", r22D.s22TcCont) + ","
    payload += f_jsonPairNum("any22d_cr_reclaim_hits", r22D.s22TcReclaim) + ","
    payload += f_jsonPairNum("any22d_cr_total", r22D.s22TcCont + r22D.s22TcReclaim) + ","
    payload += f_jsonPairStr("any22d_cr_cont_pct", f_pctStr(r22D.s22TcCont, r22D.s22TcCont + r22D.s22TcReclaim)) + ","
    payload += f_jsonPairStr("any22d_cr_reclaim_pct", f_pctStr(r22D.s22TcReclaim, r22D.s22TcCont + r22D.s22TcReclaim)) + ","
    payload += f_jsonPairStr("any22d_ft_edge", f_rjFollowStrCnt(r22D.s22FtFollow, r22D.s22FtFail)) + ","
    payload += f_jsonPairNum("any22d_ft_follow_hits", r22D.s22FtFollow) + ","
    payload += f_jsonPairNum("any22d_ft_fail_hits", r22D.s22FtFail) + ","
    payload += f_jsonPairNum("any22d_ft_total", r22D.s22FtFollow + r22D.s22FtFail) + ","
    payload += f_jsonPairStr("any22d_ft_follow_pct", f_pctStr(r22D.s22FtFollow, r22D.s22FtFollow + r22D.s22FtFail)) + ","
    payload += f_jsonPairStr("any22d_ft_fail_pct", f_pctStr(r22D.s22FtFail, r22D.s22FtFollow + r22D.s22FtFail)) + ","

    payload += f_jsonPairNum("212u_cnt", r212U.count) + ","
    payload += f_jsonPairStr("212u_z", f_pctStr(r212U.zoneFirst, r212U.count)) + ","
    payload += f_jsonPairStr("212u_h", f_pctStr(r212U.highFirst, r212U.count)) + ","
    payload += f_jsonPairStr("212u_l", f_pctStr(r212U.lowFirst, r212U.count)) + ","
    payload += f_jsonPairStr("212u_s", f_pctStr(r212U.stopFirst, r212U.count)) + ","
    payload += f_jsonPairStr("212u_a", f_pctStr(r212U.ambiguousFirst, r212U.count)) + ","
    payload += f_jsonPairStr("212u_t", f_pctStr(r212U.timeoutFirst, r212U.count)) + ","
    payload += f_jsonPairStr("212u_bf", f_pctStr(r212U.bfFollow, r212U.zoneFirst)) + ","
    payload += f_jsonPairStr("212u_bz_z", f_pctStr(r212U.bzZ, r212U.bzTotal)) + ","
    payload += f_jsonPairNum("212u_bz_z_hits", r212U.bzZ) + ","
    payload += f_jsonPairNum("212u_bz_z_total", r212U.bzTotal) + ","
    payload += f_jsonPairStr("212u_az_z", f_pctStr(r212U.azZ, r212U.azTotal)) + ","
    payload += f_jsonPairNum("212u_az_z_hits", r212U.azZ) + ","
    payload += f_jsonPairNum("212u_az_z_total", r212U.azTotal) + ","
    payload += f_jsonPairNum("212u_bz_zh_hits", r212U.bzZh) + ","
    payload += f_jsonPairNum("212u_bz_zh_total", r212U.bzTotal) + ","
    payload += f_jsonPairNum("212u_az_zl_hits", r212U.azZl) + ","
    payload += f_jsonPairNum("212u_az_zl_total", r212U.azTotal) + ","
    payload += f_jsonPairStr("212u_bz_zh", f_pctStr(r212U.bzZh, r212U.bzTotal)) + ","
    payload += f_jsonPairStr("212u_az_zl", f_pctStr(r212U.azZl, r212U.azTotal)) + ","

    payload += f_jsonPairNum("212d_cnt", r212D.count) + ","
    payload += f_jsonPairStr("212d_z", f_pctStr(r212D.zoneFirst, r212D.count)) + ","
    payload += f_jsonPairStr("212d_h", f_pctStr(r212D.highFirst, r212D.count)) + ","
    payload += f_jsonPairStr("212d_l", f_pctStr(r212D.lowFirst, r212D.count)) + ","
    payload += f_jsonPairStr("212d_s", f_pctStr(r212D.stopFirst, r212D.count)) + ","
    payload += f_jsonPairStr("212d_a", f_pctStr(r212D.ambiguousFirst, r212D.count)) + ","
    payload += f_jsonPairStr("212d_t", f_pctStr(r212D.timeoutFirst, r212D.count)) + ","
    payload += f_jsonPairStr("212d_bf", f_pctStr(r212D.bfFollow, r212D.zoneFirst)) + ","
    payload += f_jsonPairStr("212d_bz_z", f_pctStr(r212D.bzZ, r212D.bzTotal)) + ","
    payload += f_jsonPairNum("212d_bz_z_hits", r212D.bzZ) + ","
    payload += f_jsonPairNum("212d_bz_z_total", r212D.bzTotal) + ","
    payload += f_jsonPairStr("212d_az_z", f_pctStr(r212D.azZ, r212D.azTotal)) + ","
    payload += f_jsonPairNum("212d_az_z_hits", r212D.azZ) + ","
    payload += f_jsonPairNum("212d_az_z_total", r212D.azTotal) + ","
    payload += f_jsonPairNum("212d_bz_zh_hits", r212D.bzZh) + ","
    payload += f_jsonPairNum("212d_bz_zh_total", r212D.bzTotal) + ","
    payload += f_jsonPairNum("212d_az_zl_hits", r212D.azZl) + ","
    payload += f_jsonPairNum("212d_az_zl_total", r212D.azTotal) + ","
    payload += f_jsonPairStr("212d_bz_zh", f_pctStr(r212D.bzZh, r212D.bzTotal)) + ","
    payload += f_jsonPairStr("212d_az_zl", f_pctStr(r212D.azZl, r212D.azTotal)) + ","

    payload += f_jsonPairNum("312u_cnt", r312U.count) + ","
    payload += f_jsonPairStr("312u_z", f_pctStr(r312U.zoneFirst, r312U.count)) + ","
    payload += f_jsonPairStr("312u_h", f_pctStr(r312U.highFirst, r312U.count)) + ","
    payload += f_jsonPairStr("312u_l", f_pctStr(r312U.lowFirst, r312U.count)) + ","
    payload += f_jsonPairStr("312u_s", f_pctStr(r312U.stopFirst, r312U.count)) + ","
    payload += f_jsonPairStr("312u_a", f_pctStr(r312U.ambiguousFirst, r312U.count)) + ","
    payload += f_jsonPairStr("312u_t", f_pctStr(r312U.timeoutFirst, r312U.count)) + ","
    payload += f_jsonPairStr("312u_bf", f_pctStr(r312U.bfFollow, r312U.zoneFirst)) + ","
    payload += f_jsonPairStr("312u_bz_z", f_pctStr(r312U.bzZ, r312U.bzTotal)) + ","
    payload += f_jsonPairNum("312u_bz_z_hits", r312U.bzZ) + ","
    payload += f_jsonPairNum("312u_bz_z_total", r312U.bzTotal) + ","
    payload += f_jsonPairStr("312u_az_z", f_pctStr(r312U.azZ, r312U.azTotal)) + ","
    payload += f_jsonPairNum("312u_az_z_hits", r312U.azZ) + ","
    payload += f_jsonPairNum("312u_az_z_total", r312U.azTotal) + ","
    payload += f_jsonPairNum("312u_bz_zh_hits", r312U.bzZh) + ","
    payload += f_jsonPairNum("312u_bz_zh_total", r312U.bzTotal) + ","
    payload += f_jsonPairNum("312u_az_zl_hits", r312U.azZl) + ","
    payload += f_jsonPairNum("312u_az_zl_total", r312U.azTotal) + ","
    payload += f_jsonPairStr("312u_bz_zh", f_pctStr(r312U.bzZh, r312U.bzTotal)) + ","
    payload += f_jsonPairStr("312u_az_zl", f_pctStr(r312U.azZl, r312U.azTotal)) + ","

    payload += f_jsonPairNum("312d_cnt", r312D.count) + ","
    payload += f_jsonPairStr("312d_z", f_pctStr(r312D.zoneFirst, r312D.count)) + ","
    payload += f_jsonPairStr("312d_h", f_pctStr(r312D.highFirst, r312D.count)) + ","
    payload += f_jsonPairStr("312d_l", f_pctStr(r312D.lowFirst, r312D.count)) + ","
    payload += f_jsonPairStr("312d_s", f_pctStr(r312D.stopFirst, r312D.count)) + ","
    payload += f_jsonPairStr("312d_a", f_pctStr(r312D.ambiguousFirst, r312D.count)) + ","
    payload += f_jsonPairStr("312d_t", f_pctStr(r312D.timeoutFirst, r312D.count)) + ","
    payload += f_jsonPairStr("312d_bf", f_pctStr(r312D.bfFollow, r312D.zoneFirst)) + ","
    payload += f_jsonPairStr("312d_bz_z", f_pctStr(r312D.bzZ, r312D.bzTotal)) + ","
    payload += f_jsonPairNum("312d_bz_z_hits", r312D.bzZ) + ","
    payload += f_jsonPairNum("312d_bz_z_total", r312D.bzTotal) + ","
    payload += f_jsonPairStr("312d_az_z", f_pctStr(r312D.azZ, r312D.azTotal)) + ","
    payload += f_jsonPairNum("312d_az_z_hits", r312D.azZ) + ","
    payload += f_jsonPairNum("312d_az_z_total", r312D.azTotal) + ","
    payload += f_jsonPairNum("312d_bz_zh_hits", r312D.bzZh) + ","
    payload += f_jsonPairNum("312d_bz_zh_total", r312D.bzTotal) + ","
    payload += f_jsonPairNum("312d_az_zl_hits", r312D.azZl) + ","
    payload += f_jsonPairNum("312d_az_zl_total", r312D.azTotal) + ","
    payload += f_jsonPairStr("312d_bz_zh", f_pctStr(r312D.bzZh, r312D.bzTotal)) + ","
    payload += f_jsonPairStr("312d_az_zl", f_pctStr(r312D.azZl, r312D.azTotal)) + ","

    payload += f_jsonPairNum("cont_cnt", contLegacyCount) + ","
    payload += f_jsonPairStr("cont_z", f_pctStr(contLegacyZone, contLegacyCount)) + ","
    payload += f_jsonPairStr("cont_h", f_pctStr(contLegacyHigh, contLegacyCount)) + ","
    payload += f_jsonPairStr("cont_l", f_pctStr(contLegacyLow, contLegacyCount)) + ","
    payload += f_jsonPairStr("cont_s", f_pctStr(contLegacyStop, contLegacyCount)) + ","
    payload += f_jsonPairStr("cont_a", f_pctStr(contLegacyAmbig, contLegacyCount)) + ","
    payload += f_jsonPairStr("cont_t", f_pctStr(contLegacyTimeout, contLegacyCount)) + ","
    payload += f_jsonPairStr("cont_bf", f_pctStr(contLegacyBfFollow, contLegacyZone)) + ","
    payload += f_jsonPairStr("cont_bz_z", f_pctStr(contLegacyBzZ, contLegacyBzTotal)) + ","
    payload += f_jsonPairNum("cont_bz_z_hits", contLegacyBzZ) + ","
    payload += f_jsonPairNum("cont_bz_z_total", contLegacyBzTotal) + ","
    payload += f_jsonPairStr("cont_az_z", f_pctStr(contLegacyAzZ, contLegacyAzTotal)) + ","
    payload += f_jsonPairNum("cont_az_z_hits", contLegacyAzZ) + ","
    payload += f_jsonPairNum("cont_az_z_total", contLegacyAzTotal) + ","
    payload += f_jsonPairNum("cont_bz_zh_hits", contLegacyBzZh) + ","
    payload += f_jsonPairNum("cont_bz_zh_total", contLegacyBzTotal) + ","
    payload += f_jsonPairNum("cont_az_zl_hits", contLegacyAzZl) + ","
    payload += f_jsonPairNum("cont_az_zl_total", contLegacyAzTotal) + ","
    payload += f_jsonPairStr("cont_bz_zh", f_pctStr(contLegacyBzZh, contLegacyBzTotal)) + ","
    payload += f_jsonPairStr("cont_az_zl", f_pctStr(contLegacyAzZl, contLegacyAzTotal)) + ","

    payload += f_jsonPairNum("contu_cnt", rContU.count) + ","
    payload += f_jsonPairStr("contu_z", f_pctStr(rContU.zoneFirst, rContU.count)) + ","
    payload += f_jsonPairStr("contu_h", f_pctStr(rContU.highFirst, rContU.count)) + ","
    payload += f_jsonPairStr("contu_l", f_pctStr(rContU.lowFirst, rContU.count)) + ","
    payload += f_jsonPairStr("contu_s", f_pctStr(rContU.stopFirst, rContU.count)) + ","
    payload += f_jsonPairStr("contu_a", f_pctStr(rContU.ambiguousFirst, rContU.count)) + ","
    payload += f_jsonPairStr("contu_t", f_pctStr(rContU.timeoutFirst, rContU.count)) + ","
    payload += f_jsonPairStr("contu_bf", f_pctStr(rContU.bfFollow, rContU.zoneFirst)) + ","
    payload += f_jsonPairStr("contu_bz_z", f_pctStr(rContU.bzZ, rContU.bzTotal)) + ","
    payload += f_jsonPairNum("contu_bz_z_hits", rContU.bzZ) + ","
    payload += f_jsonPairNum("contu_bz_z_total", rContU.bzTotal) + ","
    payload += f_jsonPairStr("contu_az_z", f_pctStr(rContU.azZ, rContU.azTotal)) + ","
    payload += f_jsonPairNum("contu_az_z_hits", rContU.azZ) + ","
    payload += f_jsonPairNum("contu_az_z_total", rContU.azTotal) + ","
    payload += f_jsonPairNum("contu_bz_zh_hits", rContU.bzZh) + ","
    payload += f_jsonPairNum("contu_bz_zh_total", rContU.bzTotal) + ","
    payload += f_jsonPairNum("contu_az_zl_hits", rContU.azZl) + ","
    payload += f_jsonPairNum("contu_az_zl_total", rContU.azTotal) + ","
    payload += f_jsonPairStr("contu_bz_zh", f_pctStr(rContU.bzZh, rContU.bzTotal)) + ","
    payload += f_jsonPairStr("contu_az_zl", f_pctStr(rContU.azZl, rContU.azTotal)) + ","

    payload += f_jsonPairNum("contd_cnt", rContD.count) + ","
    payload += f_jsonPairStr("contd_z", f_pctStr(rContD.zoneFirst, rContD.count)) + ","
    payload += f_jsonPairStr("contd_h", f_pctStr(rContD.highFirst, rContD.count)) + ","
    payload += f_jsonPairStr("contd_l", f_pctStr(rContD.lowFirst, rContD.count)) + ","
    payload += f_jsonPairStr("contd_s", f_pctStr(rContD.stopFirst, rContD.count)) + ","
    payload += f_jsonPairStr("contd_a", f_pctStr(rContD.ambiguousFirst, rContD.count)) + ","
    payload += f_jsonPairStr("contd_t", f_pctStr(rContD.timeoutFirst, rContD.count)) + ","
    payload += f_jsonPairStr("contd_bf", f_pctStr(rContD.bfFollow, rContD.zoneFirst)) + ","
    payload += f_jsonPairStr("contd_bz_z", f_pctStr(rContD.bzZ, rContD.bzTotal)) + ","
    payload += f_jsonPairNum("contd_bz_z_hits", rContD.bzZ) + ","
    payload += f_jsonPairNum("contd_bz_z_total", rContD.bzTotal) + ","
    payload += f_jsonPairStr("contd_az_z", f_pctStr(rContD.azZ, rContD.azTotal)) + ","
    payload += f_jsonPairNum("contd_az_z_hits", rContD.azZ) + ","
    payload += f_jsonPairNum("contd_az_z_total", rContD.azTotal) + ","
    payload += f_jsonPairNum("contd_bz_zh_hits", rContD.bzZh) + ","
    payload += f_jsonPairNum("contd_bz_zh_total", rContD.bzTotal) + ","
    payload += f_jsonPairNum("contd_az_zl_hits", rContD.azZl) + ","
    payload += f_jsonPairNum("contd_az_zl_total", rContD.azTotal) + ","
    payload += f_jsonPairStr("contd_bz_zh", f_pctStr(rContD.bzZh, rContD.bzTotal)) + ","
    payload += f_jsonPairStr("contd_az_zl", f_pctStr(rContD.azZl, rContD.azTotal)) + ","

    payload += f_jsonPairStr("avg_cr_edge", f_truthOddsStrCnt(crAvgCont, crAvgReclaim)) + ","
    payload += f_jsonPairStr("avg_cr_bias", f_truthWinnerStr(crAvgCont, crAvgReclaim)) + ","
    payload += f_jsonPairNum("avg_cr_cont_hits", crAvgCont) + ","
    payload += f_jsonPairNum("avg_cr_reclaim_hits", crAvgReclaim) + ","
    payload += f_jsonPairNum("avg_cr_total", crAvgTotal) + ","
    payload += f_jsonPairStr("avg_cr_cont_pct", f_pctStr(crAvgCont, crAvgTotal)) + ","
    payload += f_jsonPairStr("avg_cr_reclaim_pct", f_pctStr(crAvgReclaim, crAvgTotal)) + ","
    payload += f_jsonPairStr("avg_rj_follow_edge", f_rjFollowStrCnt(rjAvgFollow, rjAvgFail)) + ","
    payload += f_jsonPairNum("avg_rj_follow_hits", rjAvgFollow) + ","
    payload += f_jsonPairNum("avg_rj_fail_hits", rjAvgFail) + ","
    payload += f_jsonPairNum("avg_rj_total", rjAvgTotal) + ","
    payload += f_jsonPairStr("avg_rj_follow_pct", f_pctStr(rjAvgFollow, rjAvgTotal)) + ","
    payload += f_jsonPairStr("avg_rj_fail_pct", f_pctStr(rjAvgFail, rjAvgTotal)) + ","
    payload += f_jsonPairStr("avg_any22_cr_edge", f_truthOddsStrCnt(s22CrAvgCont, s22CrAvgReclaim)) + ","
    payload += f_jsonPairStr("avg_any22_cr_bias", f_truthWinnerStr(s22CrAvgCont, s22CrAvgReclaim)) + ","
    payload += f_jsonPairNum("avg_any22_cr_cont_hits", s22CrAvgCont) + ","
    payload += f_jsonPairNum("avg_any22_cr_reclaim_hits", s22CrAvgReclaim) + ","
    payload += f_jsonPairNum("avg_any22_cr_total", s22CrAvgTotal) + ","
    payload += f_jsonPairStr("avg_any22_cr_cont_pct", f_pctStr(s22CrAvgCont, s22CrAvgTotal)) + ","
    payload += f_jsonPairStr("avg_any22_cr_reclaim_pct", f_pctStr(s22CrAvgReclaim, s22CrAvgTotal)) + ","
    payload += f_jsonPairStr("three_high_break_cr_edge", f_truthOddsStrCnt(bfBreakUpCont, bfBreakUpReclaim)) + ","
    payload += f_jsonPairNum("three_high_break_cr_cont_hits", bfBreakUpCont) + ","
    payload += f_jsonPairNum("three_high_break_cr_reclaim_hits", bfBreakUpReclaim) + ","
    payload += f_jsonPairNum("three_high_break_cr_total", bfBreakUpTotal) + ","
    payload += f_jsonPairStr("three_high_break_fx_edge", f_rjFollowStrCnt(bfBreakUpFollow, bfBreakUpFail)) + ","
    payload += f_jsonPairNum("three_high_break_fx_follow_hits", bfBreakUpFollow) + ","
    payload += f_jsonPairNum("three_high_break_fx_fail_hits", bfBreakUpFail) + ","
    payload += f_jsonPairNum("three_high_break_fx_total", bfBreakUpFollow + bfBreakUpFail) + ","
    payload += f_jsonPairStr("three_low_break_cr_edge", f_truthOddsStrCnt(bfBreakDownCont, bfBreakDownReclaim)) + ","
    payload += f_jsonPairNum("three_low_break_cr_cont_hits", bfBreakDownCont) + ","
    payload += f_jsonPairNum("three_low_break_cr_reclaim_hits", bfBreakDownReclaim) + ","
    payload += f_jsonPairNum("three_low_break_cr_total", bfBreakDownTotal) + ","
    payload += f_jsonPairStr("three_low_break_fx_edge", f_rjFollowStrCnt(bfBreakDownFollow, bfBreakDownFail)) + ","
    payload += f_jsonPairNum("three_low_break_fx_follow_hits", bfBreakDownFollow) + ","
    payload += f_jsonPairNum("three_low_break_fx_fail_hits", bfBreakDownFail) + ","
    payload += f_jsonPairNum("three_low_break_fx_total", bfBreakDownFollow + bfBreakDownFail) + ","
    payload += f_jsonPairStr("avg_bf_break_cr_edge", f_truthOddsStrCnt(bfBreakAvgCont, bfBreakAvgReclaim)) + ","
    payload += f_jsonPairNum("avg_bf_break_cr_cont_hits", bfBreakAvgCont) + ","
    payload += f_jsonPairNum("avg_bf_break_cr_reclaim_hits", bfBreakAvgReclaim) + ","
    payload += f_jsonPairNum("avg_bf_break_cr_total", bfBreakAvgTotal) + ","
    payload += f_jsonPairStr("avg_bf_break_fx_edge", f_rjFollowStrCnt(bfBreakAvgFollow, bfBreakAvgFail)) + ","
    payload += f_jsonPairNum("avg_bf_break_fx_follow_hits", bfBreakAvgFollow) + ","
    payload += f_jsonPairNum("avg_bf_break_fx_fail_hits", bfBreakAvgFail) + ","
    payload += f_jsonPairNum("avg_bf_break_fx_total", bfBreakAvgFxTotal) + ","

    payload += f_jsonPairStr("avg_any22_ft_edge", f_rjFollowStrCnt(s22FtAvgFollow, s22FtAvgFail)) + ","
    payload += f_jsonPairNum("avg_any22_ft_follow_hits", s22FtAvgFollow) + ","
    payload += f_jsonPairNum("avg_any22_ft_fail_hits", s22FtAvgFail) + ","
    payload += f_jsonPairNum("avg_any22_ft_total", s22FtAvgTotal) + ","
    payload += f_jsonPairStr("avg_any22_ft_follow_pct", f_pctStr(s22FtAvgFollow, s22FtAvgTotal)) + ","
    payload += f_jsonPairStr("avg_any22_ft_fail_pct", f_pctStr(s22FtAvgFail, s22FtAvgTotal)) + ","

    payload += f_jsonPairNum("ambig_zone_high", ambigZoneHighCount) + ","
    payload += f_jsonPairNum("ambig_zone_low", ambigZoneLowCount) + ","
    payload += f_jsonPairNum("ambig_zone_stop", ambigZoneStopCount) + ","
    payload += f_jsonPairNum("ambig_high_low", ambigHighLowCount) + ","
    payload += f_jsonPairNum("ambig_high_stop", ambigHighStopCount) + ","
    payload += f_jsonPairNum("ambig_low_stop", ambigLowStopCount) + ","
    payload += f_jsonPairNum("ambig_three_plus", ambigThreePlusCount) + ","

    payload += f_jsonPairStr("last_logged", lastLoggedTxt) + ","
    payload += f_jsonPairNum("last_logged_bar", na(lastLoggedBar) ? 0 : lastLoggedBar) + ","
    payload += f_jsonPairStr("bf_eval_tf", bfEvalTf) + ","
    payload += f_jsonPairNum("bf_lookback_bars", bfLookbackBars) + ","
    payload += f_jsonPairNum("true_bf_up", trueBFUpCount) + ","
    payload += f_jsonPairNum("true_bf_down", trueBFDownCount) + ","
    payload += f_jsonPairNum("true_bf_both", trueBFBothCount) + ","
    payload += f_jsonPairNum("true_bf_total", trueBFTotalCount) + ","
    payload += f_jsonPairFloat("true_bf_both_pct_of_bf_events", trueBFBothPctOfBFEventsJson) + ","
    payload += f_jsonPairNum("setup_total", trueBFSetupTotal) + ","
    payload += f_jsonPairFloat("true_bf_pct_of_all_setups", trueBFPctOfSetups)

    payload += "}"


    payload



// =====================================================
// 14) MARKOV REGIME PERMISSION PANEL - ULTRA LITE
// =====================================================
[mkBt, mkRt, mkAutoT] = mkThresh(mkSrc, mkLen)
[mkState, mkRet, mkUsed, mkBd, mkSd, mkRd, mkP1b, mkP1s, mkP1r, mkP3b, mkP3r, mkP5b, mkP5r, mkBBp, mkBSp, mkBRp, mkSBp, mkSSp, mkSRp, mkRBp, mkRSp, mkRRp] = mkMatrix(mkSrc, mkLen, mkLb, mkBt, mkRt, mkEn)
float mkSig1 = mkP1b - mkP1r
float mkSig3 = mkP3b - mkP3r
float mkSig5 = mkP5b - mkP5r
float mkSigH = (mkSig1 + mkSig3 + mkSig5) / 3.0
int mkN = mkState == 1 ? mkBd : mkState == -1 ? mkRd : mkSd
string mkPermission = mkPerm(mkSigH, mkN)
string mkBestPath = mkPath(mkP1b, mkP1s, mkP1r)
int mkDir = mkPermDir(mkPermission)
int mkStratDir = 0
string mkStratLabel = "No live setup"
int mkStratAge = na
int mkASz = array.size(sigs)
if mkASz > 0
    int mkBackLim = math.min(win_in, mkASz - 1)
    for mkBack = 0 to mkBackLim
        int mkIdx = mkASz - 1 - mkBack
        SignalData mkSigObj = array.get(sigs, mkIdx)
        bool mkBullObj = (showF2 and mkSigObj.f2D == 1) or (show22 and mkSigObj.s22U == 1) or (show212 and mkSigObj.s212U == 1) or (show312 and mkSigObj.s312U == 1) or (showCont and mkSigObj.contU == 1)
        bool mkBearObj = (showF2 and mkSigObj.f2U == 1) or (show22 and mkSigObj.s22D == 1) or (show212 and mkSigObj.s212D == 1) or (show312 and mkSigObj.s312D == 1) or (showCont and mkSigObj.contD == 1)
        int mkObjDir = mkBullObj and not mkBearObj ? 1 : mkBearObj and not mkBullObj ? -1 : 0
        string mkObjTxt = f_setupAuditText(mkSigObj.f2U == 1, mkSigObj.f2D == 1, mkSigObj.s22U == 1, mkSigObj.s22D == 1, mkSigObj.s212U == 1, mkSigObj.s212D == 1, mkSigObj.s312U == 1, mkSigObj.s312D == 1, mkSigObj.contU == 1, mkSigObj.contD == 1)
        if mkObjDir != 0 and mkObjTxt != ""
            bool mkStopped = false
            if mkBack > 0
                float mkStopLvl = mkObjDir == 1 ? mkSigObj.l - mkSigObj.stopBuf : mkSigObj.h + mkSigObj.stopBuf
                for mkF = 1 to mkBack
                    SignalData mkFObj = array.get(sigs, mkIdx + mkF)
                    if mkObjDir == 1
                        if stopMode == "Wick"
                            if mkFObj.l < mkStopLvl
                                mkStopped := true
                        else
                            if mkFObj.c < mkStopLvl
                                mkStopped := true
                    else
                        if stopMode == "Wick"
                            if mkFObj.h > mkStopLvl
                                mkStopped := true
                        else
                            if mkFObj.c > mkStopLvl
                                mkStopped := true
            mkStratAge := mkBack
            if mkStopped
                mkStratLabel := "Prior " + mkObjTxt + " stopped"
                mkStratDir := 0
            else
                mkStratDir := mkObjDir
                mkStratLabel := mkBack == 0 ? "Live " + mkObjTxt : "Active " + mkObjTxt + " " + str.tostring(mkBack) + "b"
            break
int mkHtfDir = isBullHTF ? 1 : -1
string mkAlign = mkAlignTxt(mkStratDir, mkDir, mkHtfDir)
color mkAlignColor = mkAlignBg(mkStratDir, mkDir, mkHtfDir)
string mkMomentum = "Mixed"
if not na(mkSig1) and not na(mkSig5)
    if mkSig5 - mkSig1 >= 5
        mkMomentum := "Bull building"
    else if mkSig1 - mkSig5 >= 5 and mkSig1 > 0
        mkMomentum := "Bull fading"
    else if mkSig1 - mkSig5 >= 5
        mkMomentum := "Bear building"
    else if mkSig5 - mkSig1 >= 5 and mkSig1 < 0
        mkMomentum := "Bear fading"
float mkBullFlip = na
float mkBearFlip = na
if not na(mkSrc[mkLen]) and not na(mkBt) and not na(mkRt)
    mkBullFlip := mkSrc[mkLen] * (1.0 + mkBt / 100.0)
    mkBearFlip := mkSrc[mkLen] * (1.0 + mkRt / 100.0)

var line mkBullLine = na
var line mkBearLine = na
mkLS = mkFLStyle == "Solid" ? line.style_solid : mkFLStyle == "Dotted" ? line.style_dotted : line.style_dashed
if barstate.islast
    int mkX1 = bar_index - mkFLBack
    if mkX1 < 0
        mkX1 := 0
    bool mkDoBull = mkEn and mkFL and mkFLMode != "Bear Only" and not na(mkBullFlip)
    bool mkDoBear = mkEn and mkFL and mkFLMode != "Bull Only" and not na(mkBearFlip)
    if mkDoBull
        if na(mkBullLine)
            mkBullLine := line.new(mkX1, mkBullFlip, bar_index, mkBullFlip, extend=extend.right, color=mkBullCol, width=mkFLW, style=mkLS)
        else
            line.set_xy1(mkBullLine, mkX1, mkBullFlip)
            line.set_xy2(mkBullLine, bar_index, mkBullFlip)
            line.set_extend(mkBullLine, extend.right)
            line.set_color(mkBullLine, mkBullCol)
            line.set_width(mkBullLine, mkFLW)
            line.set_style(mkBullLine, mkLS)
    else if not na(mkBullLine)
        line.delete(mkBullLine)
        mkBullLine := na
    if mkDoBear
        if na(mkBearLine)
            mkBearLine := line.new(mkX1, mkBearFlip, bar_index, mkBearFlip, extend=extend.right, color=mkBearCol, width=mkFLW, style=mkLS)
        else
            line.set_xy1(mkBearLine, mkX1, mkBearFlip)
            line.set_xy2(mkBearLine, bar_index, mkBearFlip)
            line.set_extend(mkBearLine, extend.right)
            line.set_color(mkBearLine, mkBearCol)
            line.set_width(mkBearLine, mkFLW)
            line.set_style(mkBearLine, mkLS)
    else if not na(mkBearLine)
        line.delete(mkBearLine)
        mkBearLine := na

var table mkT = table.new(mkPos(mkPosInput), 4, 10, border_width=1)
mkTS = mkSz(mkSizeInput)
if mkEn and mkShow and barstate.islast
    table.clear(mkT, 0, 0, 3, 9)
    int mr = 0
    mkCell(mkT, 0, mr, "MARKOV PERMISSION", mkHeaderBg, mkTS)
    mkCell(mkT, 1, mr, "Bull", color.new(mkBullCol, 30), mkTS)
    mkCell(mkT, 2, mr, "Side", color.new(mkSideCol, 30), mkTS)
    mkCell(mkT, 3, mr, "Bear", color.new(mkBearCol, 30), mkTS)
    mr += 1
    mkCell(mkT, 0, mr, "State / Return", mkLabelBg, mkTS)
    mkCell(mkT, 1, mr, mkTxt(mkState), mkBgState(mkState), mkTS)
    mkCell(mkT, 2, mr, mkFmt(mkRet), mkDataBg, mkTS)
    mkCell(mkT, 3, mr, "Sample Size " + str.tostring(mkN), mkDataBg, mkTS)
    mr += 1
    if mkShowFlip
        mkCell(mkT, 0, mr, "Flip Levels", mkLabelBg, mkTS)
        mkCell(mkT, 1, mr, mkPx(mkBullFlip), color.new(mkBullCol, 70), mkTS)
        mkCell(mkT, 2, mr, "Src " + mkPx(mkSrc), mkDataBg, mkTS)
        mkCell(mkT, 3, mr, mkPx(mkBearFlip), color.new(mkBearCol, 70), mkTS)
        mr += 1
    mkCell(mkT, 0, mr, "1-Bar Prob", mkLabelBg, mkTS)
    mkCell(mkT, 1, mr, mkFmt(mkP1b), color.new(mkBullCol, 75), mkTS)
    mkCell(mkT, 2, mr, mkFmt(mkP1s), color.new(mkSideCol, 75), mkTS)
    mkCell(mkT, 3, mr, mkFmt(mkP1r), color.new(mkBearCol, 75), mkTS)
    mr += 1
    mkCell(mkT, 0, mr, "Signal / Path", mkLabelBg, mkTS)
    mkCell(mkT, 1, mr, mkFmt(mkSig1), mkSig1 > 0 ? color.new(mkBullCol, 65) : mkSig1 < 0 ? color.new(mkBearCol, 65) : mkDataBg, mkTS)
    mkCell(mkT, 2, mr, mkBestPath, mkBgPath(mkBestPath), mkTS)
    mkCell(mkT, 3, mr, "H " + mkFmt(mkSigH), mkDataBg, mkTS)
    mr += 1
    if mkShowFc
        mkCell(mkT, 0, mr, "3B / 5B Signal", mkLabelBg, mkTS)
        mkCell(mkT, 1, mr, "3B " + mkFmt(mkSig3), mkDataBg, mkTS)
        mkCell(mkT, 2, mr, "5B " + mkFmt(mkSig5), mkDataBg, mkTS)
        mkCell(mkT, 3, mr, mkMomentum, mkDataBg, mkTS)
        mr += 1
    if mkShowMx
        mkCell(mkT, 0, mr, "Matrix %", mkLabelBg, mkTS)
        mkCell(mkT, 1, mr, "Bull→ " + mkFmt(mkBBp) + "/" + mkFmt(mkBSp) + "/" + mkFmt(mkBRp), color.new(mkBullCol, 80), mkTS)
        mkCell(mkT, 2, mr, "Side→ " + mkFmt(mkSBp) + "/" + mkFmt(mkSSp) + "/" + mkFmt(mkSRp), color.new(mkSideCol, 80), mkTS)
        mkCell(mkT, 3, mr, "Bear→ " + mkFmt(mkRBp) + "/" + mkFmt(mkRSp) + "/" + mkFmt(mkRRp), color.new(mkBearCol, 80), mkTS)
        mr += 1
    mkCell(mkT, 0, mr, "Permission", mkLabelBg, mkTS)
    mkCell(mkT, 1, mr, mkPermission, str.contains(mkPermission, "Long") ? color.new(mkBullCol, 55) : str.contains(mkPermission, "Short") ? color.new(mkBearCol, 55) : color.new(mkSideCol, 60), mkTS)
    mkCell(mkT, 2, mr, "Used " + str.tostring(mkUsed), mkDataBg, mkTS)
    mkCell(mkT, 3, mr, "T " + mkFmt(mkBt), mkDataBg, mkTS)
    mr += 1
    if mkShowAlign
        mkCell(mkT, 0, mr, "Trade Behavior", mkLabelBg, mkTS)
        mkCell(mkT, 1, mr, mkStratLabel, mkStratDir == 1 ? color.new(mkBullCol, 65) : mkStratDir == -1 ? color.new(mkBearCol, 65) : mkDataBg, mkTS)
        mkCell(mkT, 2, mr, mkHtfTxt(mkHtfDir), mkDataBg, mkTS)
        mkCell(mkT, 3, mr, mkAlign, mkAlignColor, mkTS)
else if barstate.islast
    table.clear(mkT, 0, 0, 3, 9)

if sendWebhook and barstate.islast
    alert(f_buildJsonPayload(), alert.freq_once_per_bar_close)
````
