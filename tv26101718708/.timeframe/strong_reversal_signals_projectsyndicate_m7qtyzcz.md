# Strong Reversal Signals | ProjectSyndicate

- url: https://www.tradingview.com/script/M7QtYZcz-Strong-Reversal-Signals-ProjectSyndicate/
- type: indicator
- pine_id: PUB;1ee1818bb65f46618e28a851b6843d04
- version: 1.0

## Description

[b]Strong Reversal Signals automatically identifies high-probability, non-repainting reversal setups formed after liquidity grabs, then ranks every signal 0–10 with a star strength score so you can instantly see the strongest trades. It calculates adaptive take-profit and stop-loss zones based on Average Daily Range (ADR), after each sweep, and presents a complete statistical breakdown — including win rate by strength tier — on a non-intrusive dashboard to provide a quantifiable, rankable edge.[/b]

⭐ Star Strength Ranking (0–10) — every signal is scored across five independently-tested factors (trend context, rejection-wick depth, volatility regime, mean proximity, and sweep depth) and labeled with 1–4 stars. The ranking was validated symbol-out across multiple GBP datasets, so the stars genuinely separate win rate rather than just decorating the chart.

🧠 NRP Liquidity-Grab Reversal Engine — uses a non-repainting pivot/HTF/session engine to detect liquidity sweeps, ensuring signals are stable and never repaint.

🎯 ADR-Adaptive TP/SL Zones — automatically calculates and plots uniform-width TP1, TP2, and SL zones as a percentage of the 10-day ADR, so the strategy dynamically adapts to any asset's volatility. Every historic signal keeps its full zone set on the chart.
🎨 Clean Green/Maroon Theme — BUY Reversal labels are green and SELL Reversal labels are maroon, each carrying its star rank, with fully opaque labels anchored clear of the candles for instant, unobstructed visual confirmation.
📊 Win-Rate-by-Strength Dashboard — a complete statistical overview: real-time ADR10, total trades, wins/losses, total R, expectancy, TP2 hits, the last 10 outcomes, and a dedicated Win Rate By Strength table showing the live win rate and sample size for each star tier (★ through ★★★★).

✅ Strength-Gated Display & Trading — a single "Minimum Stars To Plot" input lets you hide weaker setups and focus only on the strongest, while the dashboard keeps tracking every tier in the background.
🔔 Star-Ranked Alerts — get a single, detailed alert per signal including direction, star rank and strength tier (ELITE/STRONG/MODERATE/WEAK), symbol, timeframe, entry, SL, TP1, and TP2 — formatted for automated trading. A dedicated "Alert Minimum Stars" setting lets you fire alerts on strong setups only.
🔧 Fully Customizable — control everything from liquidity source , pivot length, and the five strength weights to TP/SL percentages, zone width and height, label and dashboard sizes, colors, and the star thresholds for plotting and alerts.

🎯 Why this algo is unique: Standard reversal and ZigZag indicators repaint and offer subjective signals with no statistical backing — and crucially, they treat every signal as equal. This algorithm provides an objective, non-repainting signal engine and ranks each setup by measured strength, with the ranking validated out-of-sample so the strongest signals demonstrably win more often. It builds a complete, quantifiable framework around each reversal with adaptive ADR risk management and a dashboard that proves performance per strength tier on the chart you are trading.

🚀 Apply to Gold (XAUUSD), Forex, Crypto, and Indices on any M5/M10/M15/M30/H1. The ADR-based zones and strength engine adapt from M5 scalping to H4 swing trading.

🎯 How to use this? Watch the Win-Rate-by-Strength table to see which tiers perform best on your asset/timeframe, then prioritize ★★★★ setups (or set "Minimum Stars To Plot" to 4). Adjust the TP/SL percentages to your risk tolerance, and favor signals that align with the higher-timeframe trend.

⚠️ IMPORTANT NOTICE: This indicator identifies statistically-backed, strength-ranked reversal signals. The published win rates are historical, measured on specific GBP M10 data and a fixed target geometry — past performance does not guarantee future results, and figures will vary by symbol, timeframe, and settings. The system also wins small per trade relative to its stop (high win rate, modest reward-to-risk), so position sizing matters. It should NOT be used as a standalone entry signal. Always combine it with your own strategy, price action analysis, and risk management.

## Source Code

````pine
//@version=6
indicator("Strong Reversal Signals", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

gSrc = "Liquidity Source"
src_mode = input.string("Macro Pivots", "Source", options=["Macro Pivots", "HTF Previous Bar", "Session High/Low"], group=gSrc)
pivLen   = input.int(20, "Pivot Length", minval=3, maxval=100, group=gSrc)
htfRes   = input.timeframe("240", "HTF Resolution", group=gSrc)
sessTz   = input.string("America/New_York", "Session Timezone", group=gSrc)
sAsia    = input.session("2000-0000", "Asian Session", group=gSrc)
sLon     = input.session("0300-0800", "London Session", group=gSrc)
sNy      = input.session("0900-1600", "New York Session", group=gSrc)
grabWick = input.float(20.0, "Min Reversal Wick (%)", minval=1, maxval=100, tooltip="Minimum rejection-wick size on the candle that sweeps liquidity.", group=gSrc)

gT = "Targets"
tp1Pct = input.float(10.0, "TP1 % of ADR10", minval=0.5, step=0.5, group=gT)
tp2Pct = input.float(25.0, "TP2 % of ADR10", minval=0.5, step=0.5, group=gT)
slPct  = input.float(35.0, "SL % of ADR10",  minval=0.5, step=0.5, group=gT)
expBars= input.int(120, "Trade Expiry (bars)", minval=10, group=gT)
zoneW  = input.int(30, "Zone Width (bars)", minval=10, maxval=500, group=gT)
zoneH  = input.float(2.0, "Zone Height % of ADR10", minval=0.1, step=0.1, group=gT)
keptN  = input.int(100, "Max Signals Kept", minval=1, maxval=120, group=gT)

gR = "Strength Ranking"
minStars = input.int(0, "Minimum Stars To Plot", minval=0, maxval=4, tooltip="0 = show every signal. Raise to show only stronger setups; the dashboard still tracks every tier.", group=gR)
wTrend = input.float(0.30, "Weight · Trend Context",   minval=0, maxval=1, step=0.05, group=gR)
wWick  = input.float(0.25, "Weight · Rejection Wick",  minval=0, maxval=1, step=0.05, group=gR)
wCalm  = input.float(0.20, "Weight · Volatility Regime",minval=0, maxval=1, step=0.05, group=gR)
wNear  = input.float(0.15, "Weight · Mean Proximity",  minval=0, maxval=1, step=0.05, group=gR)
wSweep = input.float(0.10, "Weight · Sweep Depth",     minval=0, maxval=1, step=0.05, group=gR)

gC = "Colors"
colBuy  = input.color(#1f9e6f, "Buy / Long",  inline="c", group=gC)
colSell = input.color(#7e2330, "Sell / Short", inline="c", group=gC)
colTP   = input.color(#1f9e6f, "Target Zones", group=gC)
colSL   = input.color(#7e2330, "Stop Zone", group=gC)
zoneAlpha   = input.int(82, "Zone Transparency", minval=0, maxval=100, group=gC)
borderAlpha = input.int(45, "Border Transparency", minval=0, maxval=100, group=gC)
showTags = input.bool(true, "Show SL/TP Tags", group=gC)
lblSize  = input.string("Normal", "Signal Label Size", options=["Tiny","Small","Normal","Large","Huge"], group=gC)
tagSize  = input.string("Normal", "SL/TP Tag Size", options=["Tiny","Small","Normal","Large","Huge"], group=gC)
lblOff   = input.float(6.0, "Signal Label Offset (% of ADR10)", minval=0, step=0.5, tooltip="Pushes the BUY/SELL label clear of the candles (below the bar for buys, above for sells).", group=gC)

gP = "Dashboard"
showPanel = input.bool(true, "Show Dashboard", group=gP)
panelPos  = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group=gP)
panelSize = input.string("Normal", "Text Size", options=["Tiny","Small","Normal","Large","Huge"], group=gP)

gA = "Alerts"
alertsOn      = input.bool(true, "Enable Alerts", group=gA)
alertMinStars = input.int(0, "Alert Minimum Stars", minval=0, maxval=4, tooltip="Only fire alerts for setups at or above this rank. 4 = strongest only.", group=gA)

f_clamp(float v) => math.min(math.max(v, 0.0), 1.0)
f_stars(float s) => s >= 7.5 ? "★★★★" : s >= 6.5 ? "★★★" : s >= 5.5 ? "★★" : s >= 4.5 ? "★" : "·"
f_tier(float s)  => s >= 7.5 ? 4 : s >= 6.5 ? 3 : s >= 5.5 ? 2 : s >= 4.5 ? 1 : 0
f_pos() =>
    switch panelPos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right
f_sz(string s, bool head) => head ? (s=="Tiny"?size.tiny:s=="Small"?size.small:s=="Normal"?size.normal:s=="Large"?size.large:size.huge) : (s=="Tiny"?size.tiny:s=="Small"?size.small:s=="Normal"?size.small:s=="Large"?size.normal:size.large)
f_lblsz(string s) => s=="Tiny"?size.tiny:s=="Small"?size.small:s=="Normal"?size.normal:s=="Large"?size.large:size.huge
f_tname(float s) => s>=7.5?"ELITE":s>=6.5?"STRONG":s>=5.5?"MODERATE":s>=4.5?"WEAK":"MINIMAL"
f_amsg(int dir, float sc, float e, float sl, float tp1, float tp2) =>
    (dir==1?"BUY Reversal":"SELL Reversal") + "  " + f_stars(sc) + " (" + f_tname(sc) + ")\n" + syminfo.ticker + " " + timeframe.period + "\nStrength: " + str.tostring(sc,"#.0") + "/10\nEntry: " + str.tostring(e,format.mintick) + "\nSL: " + str.tostring(sl,format.mintick) + "\nTP1: " + str.tostring(tp1,format.mintick) + "\nTP2: " + str.tostring(tp2,format.mintick)

float atr14  = nz(ta.atr(14), ta.cum(high - low) / (bar_index + 1))
float ema50  = ta.ema(close, 50)
float ema200 = ta.ema(close, 200)
float atrPct = ta.percentrank(atr14, 100)
int   L = (pivLen % 2 == 0) ? (pivLen + 1) : pivLen
int   pv = int(L / 2)

bool useHtf  = src_mode == "HTF Previous Bar"
bool useSess = src_mode == "Session High/Low"

[hHtf, lHtf] = request.security(syminfo.tickerid, htfRes, [high[1], low[1]], lookahead=barmerge.lookahead_on)
bool newHtf = ta.change(time(htfRes)) != 0

bool inAsia = not na(time(timeframe.period, sAsia, sessTz))
bool inLon  = not na(time(timeframe.period, sLon,  sessTz))
bool inNy   = not na(time(timeframe.period, sNy,   sessTz))
var float aH = na
var float aL = na
var float lH = na
var float lL = na
var float nH = na
var float nL = na
if inAsia
    aH := na(aH) ? high : math.max(aH, high)
    aL := na(aL) ? low  : math.min(aL, low)
if inLon
    lH := na(lH) ? high : math.max(lH, high)
    lL := na(lL) ? low  : math.min(lL, low)
if inNy
    nH := na(nH) ? high : math.max(nH, high)
    nL := na(nL) ? low  : math.min(nL, low)
bool aEnd = not inAsia and inAsia[1]
bool lEnd = not inLon  and inLon[1]
bool nEnd = not inNy   and inNy[1]

float rngBar = (high - low) == 0 ? syminfo.mintick : (high - low)
float upWick = (high - math.max(open, close)) / rngBar
float dnWick = (math.min(open, close) - low) / rngBar

float adr10 = request.security(syminfo.tickerid, "D", (math.sum(high[1] - low[1], 10)) / 10, lookahead=barmerge.lookahead_off)
float adrA  = nz(adr10) > 0.0 ? adr10 : close * 0.04
float tp1D  = adrA * (tp1Pct / 100)
float tp2D  = adrA * (tp2Pct / 100)
float slD   = adrA * (slPct  / 100)
float zh    = adrA * (zoneH / 100) / 2
bool  adrOk = nz(adr10) > 0.0
float rTP1  = slPct > 0 ? tp1Pct / slPct : 0.0
float rTP2  = slPct > 0 ? tp2Pct / slPct : 0.0

f_score(int dir, float entry, float gExt, float gLvl, float gWick) =>
    float fTrend = (dir == -1 ? (ema50 - ema200) : (ema200 - ema50)) / atr14
    float fAlign = (dir == -1 ? (ema200 - entry) : (entry - ema200)) / atr14
    float trendN = f_clamp((fTrend + 2.0) / 4.0)
    float wickN  = f_clamp(gWick / 0.6)
    float calmN  = f_clamp(1.0 - atrPct / 100.0)
    float nearN  = f_clamp(1.0 - math.max(fAlign, 0.0) / 3.0)
    float sweepN = f_clamp(math.abs(gExt - gLvl) / (atr14 * 1.5))
    float wsum = wTrend + wWick + wCalm + wNear + wSweep
    float raw = wsum > 0 ? (trendN*wTrend + wickN*wWick + calmN*wCalm + nearN*wNear + sweepN*wSweep) / wsum : 0.0
    math.min(math.max(raw * 10.0, 0.0), 10.0)

type Trade
    int   dir        = 0
    float entry      = na
    float sl         = na
    float tp1        = na
    float tp2        = na
    float score      = 0.0
    int   tier       = 0
    int   entryBar   = na
    bool  reachedTP1 = false
    bool  resolved   = false
    box   bSL        = na
    box   bTP1       = na
    box   bTP2       = na
    label lEntry     = na
    label lSL        = na
    label lTP1       = na
    label lTP2       = na

var array<Trade> trades = array.new<Trade>()

var int totalSignals = 0
var int wins = 0
var int losses = 0
var int tp2Hit = 0
var int expired = 0
var float totalR = 0.0
var array<int> tierWin  = array.new_int(5, 0)
var array<int> tierLoss = array.new_int(5, 0)
var array<string> recent = array.new<string>()

f_logRecent(string s) =>
    array.unshift(recent, s)
    if array.size(recent) > 10
        array.pop(recent)

f_zone(float lvl, int x1, int x2, color c) =>
    box.new(x1, lvl + zh, x2, lvl - zh, bgcolor=color.new(c, zoneAlpha), border_color=color.new(c, borderAlpha), border_width=1)

f_tag(float lvl, int x1, string t, color c) =>
    showTags ? label.new(x1, lvl, t, style=label.style_label_lower_left, color=color.new(c, 25), textcolor=color.white, size=f_lblsz(tagSize)) : na

var float topVal = na
var bool  topBrk = true
var float btmVal = na
var bool  btmBrk = true
var int   gState = 0
var float gExt   = na
var float gLvl   = na
var float gWick  = na

if useSess
    if aEnd or lEnd or nEnd
        float fh = na
        float fl = na
        if aEnd
            fh := aH
            fl := aL
            aH := na
            aL := na
        else if lEnd
            fh := lH
            fl := lL
            lH := na
            lL := na
        else if nEnd
            fh := nH
            fl := nL
            nH := na
            nL := na
        topVal := fh
        btmVal := fl
        topBrk := false
        btmBrk := false
        gState := 0
else if useHtf
    if newHtf
        topVal := hHtf
        btmVal := lHtf
        topBrk := false
        btmBrk := false
        gState := 0
else
    float ph = ta.pivothigh(high, pv, pv)
    float pl = ta.pivotlow(low, pv, pv)
    if not na(ph)
        topVal := ph
        topBrk := false
    if not na(pl)
        btmVal := pl
        btmBrk := false

if (not topBrk) and close > topVal and upWick * 100 >= grabWick
    topBrk := true
    gState := 1
    gExt := high
    gLvl := topVal
    gWick := upWick
if (not btmBrk) and close < btmVal and dnWick * 100 >= grabWick
    btmBrk := true
    gState := -1
    gExt := low
    gLvl := btmVal
    gWick := dnWick

var bool firedLong  = false
var bool firedShort = false
firedLong := false
firedShort := false

f_open(int dir, float sc) =>
    float e = close
    Trade t = Trade.new(dir, e, dir == -1 ? e + slD : e - slD, dir == -1 ? e - tp1D : e + tp1D, dir == -1 ? e - tp2D : e + tp2D, sc, f_tier(sc), bar_index, false, false, na, na, na, na, na, na, na)
    int x1 = bar_index
    int x2 = bar_index + zoneW
    t.bSL  := f_zone(t.sl,  x1, x2, colSL)
    t.bTP1 := f_zone(t.tp1, x1, x2, colTP)
    t.bTP2 := f_zone(t.tp2, x1, x2, colTP)
    t.lSL  := f_tag(t.sl,  x1, "SL",  colSL)
    t.lTP1 := f_tag(t.tp1, x1, "TP1", colTP)
    t.lTP2 := f_tag(t.tp2, x1, "TP2", colTP)
    color ec = dir == 1 ? colBuy : colSell
    string txt = (dir == 1 ? "BUY Reversal " : "SELL Reversal ") + f_stars(sc)
    float off = adrA * (lblOff / 100.0)
    float ly  = dir == 1 ? low - off : high + off
    t.lEntry := label.new(x1, ly, txt, style=dir == 1 ? label.style_label_up : label.style_label_down, color=color.new(ec, 0), textcolor=color.white, size=f_lblsz(lblSize))
    array.push(trades, t)

if gState == 1
    if high >= gExt
        gExt := high
    else if barstate.isconfirmed
        gState := 2
        if adrOk
            float sc = f_score(-1, close, gExt, gLvl, gWick)
            if f_tier(sc) >= minStars
                f_open(-1, sc)
                totalSignals += 1
                firedShort := true
                if alertsOn and f_tier(sc) >= alertMinStars
                    alert(f_amsg(-1, sc, close, close + slD, close - tp1D, close - tp2D), alert.freq_once_per_bar_close)

if gState == -1
    if low <= gExt
        gExt := low
    else if barstate.isconfirmed
        gState := -2
        if adrOk
            float sc = f_score(1, close, gExt, gLvl, gWick)
            if f_tier(sc) >= minStars
                f_open(1, sc)
                totalSignals += 1
                firedLong := true
                if alertsOn and f_tier(sc) >= alertMinStars
                    alert(f_amsg(1, sc, close, close - slD, close + tp1D, close + tp2D), alert.freq_once_per_bar_close)

if barstate.isconfirmed and array.size(trades) > 0
    for i = 0 to array.size(trades) - 1
        if i < array.size(trades)
            Trade t = array.get(trades, i)
            if not t.resolved and bar_index > t.entryBar
                bool done = false
                string res = ""
                float r = 0.0
                bool hSL = t.dir == 1 ? low <= t.sl : high >= t.sl
                bool hT1 = t.dir == 1 ? high >= t.tp1 : low <= t.tp1
                bool hT2 = t.dir == 1 ? high >= t.tp2 : low <= t.tp2
                if hSL and not t.reachedTP1
                    done := true
                    res := "SL"
                    r := -1.0
                else
                    if hT1
                        t.reachedTP1 := true
                    if t.reachedTP1 and hT2
                        done := true
                        res := "TP2"
                        r := rTP2
                    else if t.reachedTP1 and hSL
                        done := true
                        res := "TP1"
                        r := rTP1
                if not done and (bar_index - t.entryBar) >= expBars
                    done := true
                    if t.reachedTP1
                        res := "TP1"
                        r := rTP1
                    else
                        res := "EXP"
                if done
                    t.resolved := true
                    if res == "SL"
                        losses += 1
                        totalR += r
                        array.set(tierLoss, t.tier, array.get(tierLoss, t.tier) + 1)
                        f_logRecent("SL")
                    else if res == "TP1"
                        wins += 1
                        totalR += r
                        array.set(tierWin, t.tier, array.get(tierWin, t.tier) + 1)
                        f_logRecent("TP1")
                    else if res == "TP2"
                        wins += 1
                        tp2Hit += 1
                        totalR += r
                        array.set(tierWin, t.tier, array.get(tierWin, t.tier) + 1)
                        f_logRecent("TP2")
                    else
                        expired += 1

int openCount = 0
if array.size(trades) > 0
    for i = 0 to array.size(trades) - 1
        if not array.get(trades, i).resolved
            openCount += 1

while array.size(trades) > keptN
    Trade old = array.shift(trades)
    box.delete(old.bSL)
    box.delete(old.bTP1)
    box.delete(old.bTP2)
    label.delete(old.lEntry)
    label.delete(old.lSL)
    label.delete(old.lTP1)
    label.delete(old.lTP2)

f_tierWR(int k) =>
    int w = array.get(tierWin, k)
    int l = array.get(tierLoss, k)
    int n = w + l
    [n > 0 ? w / n * 100 : 0.0, n]

if showPanel and barstate.islast
    string th = f_sz(panelSize, true)
    string tb = f_sz(panelSize, false)
    int resolved = wins + losses
    float wr  = resolved > 0 ? wins / resolved * 100 : 0.0
    float exp = resolved > 0 ? totalR / resolved : 0.0

    var table d = table.new(f_pos(), 3, 24, bgcolor=color.new(#101418, 8), frame_color=color.new(#39414b, 40), frame_width=2, border_color=color.new(#39414b, 60), border_width=1)
    table.cell(d, 0, 0, "STRONG REVERSAL SIGNALS", text_color=color.white, text_size=th, bgcolor=color.new(#1f9e6f, 25))
    table.merge_cells(d, 0, 0, 2, 0)

    table.cell(d, 0, 1, "Trades", text_color=color.silver, text_size=tb, text_halign=text.align_left)
    table.cell(d, 1, 1, str.tostring(totalSignals), text_color=color.white, text_size=tb)
    table.cell(d, 2, 1, "open " + str.tostring(openCount), text_color=color.new(color.orange, 0), text_size=tb, text_halign=text.align_right)

    table.cell(d, 0, 2, "Wins / Losses", text_color=color.silver, text_size=tb, text_halign=text.align_left)
    table.cell(d, 1, 2, str.tostring(wins), text_color=color.new(colBuy, 0), text_size=tb)
    table.cell(d, 2, 2, str.tostring(losses), text_color=color.new(colSell, 0), text_size=tb, text_halign=text.align_right)

    color wrc = wr >= 50 ? color.new(colBuy, 0) : color.new(colSell, 0)
    table.cell(d, 0, 3, "Win Rate", text_color=color.white, text_size=tb, text_halign=text.align_left)
    table.cell(d, 1, 3, resolved > 0 ? str.tostring(wr, "#.#") + "%" : "—", text_color=wrc, text_size=tb)
    table.cell(d, 2, 3, (totalR >= 0 ? "+" : "") + str.tostring(totalR, "#.#") + "R", text_color=wrc, text_size=tb, text_halign=text.align_right)

    table.cell(d, 0, 4, "Expectancy", text_color=color.silver, text_size=tb, text_halign=text.align_left)
    table.cell(d, 1, 4, resolved > 0 ? (exp >= 0 ? "+" : "") + str.tostring(exp, "#.##") + "R" : "—", text_color=wrc, text_size=tb)
    table.cell(d, 2, 4, "TP2 " + str.tostring(tp2Hit), text_color=color.new(colTP, 0), text_size=tb, text_halign=text.align_right)

    table.cell(d, 0, 5, "WIN RATE BY STRENGTH", text_color=color.new(color.white, 20), text_size=tb, bgcolor=color.new(#39414b, 70), text_halign=text.align_center)
    table.merge_cells(d, 0, 5, 2, 5)
    table.cell(d, 0, 6, "Tier", text_color=color.new(color.white,40), text_size=tb, text_halign=text.align_left)
    table.cell(d, 1, 6, "WR", text_color=color.new(color.white,40), text_size=tb)
    table.cell(d, 2, 6, "n", text_color=color.new(color.white,40), text_size=tb, text_halign=text.align_right)
    string[] lab = array.from("★★★★", "★★★", "★★", "★")
    int rowi = 7
    for k = 4 to 1
        [twr, tn] = f_tierWR(k)
        color tc = twr >= 80 ? color.new(colBuy, 0) : twr >= 70 ? color.new(#b6c47a, 0) : color.new(colSell, 0)
        table.cell(d, 0, rowi, array.get(lab, 4 - k), text_color=color.yellow, text_size=tb, text_halign=text.align_left)
        table.cell(d, 1, rowi, tn > 0 ? str.tostring(twr, "#.#") + "%" : "—", text_color=tc, text_size=tb)
        table.cell(d, 2, rowi, str.tostring(tn), text_color=color.white, text_size=tb, text_halign=text.align_right)
        rowi += 1

    table.cell(d, 0, 11, "LAST TRADES", text_color=color.new(color.white, 20), text_size=tb, bgcolor=color.new(#39414b, 70), text_halign=text.align_center)
    table.merge_cells(d, 0, 11, 2, 11)
    int hn = array.size(recent)
    if hn > 0
        for i = 0 to math.min(hn - 1, 9)
            string o = array.get(recent, i)
            color oc = o == "SL" ? color.new(colSell, 0) : color.new(colTP, 0)
            table.cell(d, 0, 12 + i, "#" + str.tostring(i + 1), text_color=color.new(color.white, 35), text_size=tb, text_halign=text.align_left)
            table.cell(d, 1, 12 + i, o, text_color=oc, text_size=tb)
            table.cell(d, 2, 12 + i, "", text_color=color.white, text_size=tb)

alertcondition(firedLong,  "Buy Reversal",  "Bullish reversal signal formed.")
alertcondition(firedShort, "Sell Reversal", "Bearish reversal signal formed.")
````
