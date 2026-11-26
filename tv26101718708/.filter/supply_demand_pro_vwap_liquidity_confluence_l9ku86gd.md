# Supply Demand Pro - VWAP + Liquidity Confluence

- url: https://www.tradingview.com/script/L9Ku86GD-Supply-Demand-Pro-VWAP-Liquidity-Confluence/
- type: indicator
- pine_id: PUB;29a765e464244d5b8224ff3544545068
- version: 1.0

## Description

Supply Demand Pro — Liquidity + VWAP Confluence
by ApexFlow

━━━━━━━━━━━━━━━━━━━━
INSPIRATION & CREDIT
━━━━━━━━━━━━━━━━━━━━

Credit: Zone base detection concept inspired by "Market Structure Break & Orderblock" by EmreKb (TradingView open-source). All code has been rewritten with significant original additions: quantitative grading system (A+/A/B/C), VWAP confluence scoring, liquidity sweep detection, multi-timeframe overlay, and live backtest panel.

━━━━━━━━━━━━━━━━━━━━
WHAT THIS INDICATOR DOES
━━━━━━━━━━━━━━━━━━━━

Detects institutional supply and demand zones using a three-layer confluence model:
1. Zone formation: explosive impulsive move + consolidation base
2. Zone scoring: quantitative grade based on move strength, volume, VWAP proximity, HTF overlap
3. Signal generation: price returns to zone with rejection confirmation + sweep detection

The combination of these three layers separates this from standard S&D indicators that draw zones without qualification.

━━━━━━━━━━━━━━━━━━━━
ZONE DETECTION METHODOLOGY
━━━━━━━━━━━━━━━━━━━━

A zone forms when a confirmed bar (barstate.isconfirmed) meets all of:
- Bar range > ATR(14) × Move Multiplier — confirms volatility expansion
- Candle body > 55% of total range — filters wicky, indecisive bars
- Optional: Volume > SMA(20) × multiplier — confirms participation

ATR uses ta.atr(14). Body percentage = |close − open| / (high − low).

The base of the zone is built from preceding candle(s) where:
- |close − open| < ATR × 0.5 (small-bodied consolidation)
- Bar is not itself explosive

Base high and low define the zone boundaries:
- Supply zone: base candle(s) before bearish explosive move
  → Top = base high, Bottom = min(base low, explosive open)
- Demand zone: base candle(s) before bullish explosive move
  → Top = max(base high, explosive open), Bottom = base low

All detection references bar[1] and bar[2] on confirmed bars only. No repainting, no lookahead.

━━━━━━━━━━━━━━━━━━━━
ZONE GRADING SYSTEM (A+ / A / B / C)
━━━━━━━━━━━━━━━━━━━━

Each zone receives a score from 0–100 at creation using four measurable factors:

Move strength (max 30 pts):
- score += min((range[1] / ATR[1]) × 18, 30)

Volume strength (max 20 pts):
- score += min((volume[1] / volAvg[1]) × 13, 20)
- If volume confirmation disabled: default 10 pts

VWAP confluence (25 pts):
- +25 if session VWAP falls within zone ± (ATR × tolerance)
- Uses ta.vwap (session-anchored)

HTF zone overlap (20 pts):
- +20 if zone price range overlaps a detected higher-timeframe zone
- HTF data pulled via request.security() with lookahead=barmerge.lookahead_off

Freshness bonus (5 pts):
- +5 at creation

Grade thresholds:
- A+ ≥ 80 | A ≥ 65 | B ≥ 50 | C < 50

Grade displayed as badge inside each zone. Signals filterable by minimum grade.

━━━━━━━━━━━━━━━━━━━━
VWAP CONFLUENCE
━━━━━━━━━━━━━━━━━━━━

Session VWAP (ta.vwap) compared to each new zone at creation:

vwapInZone = VWAP ≥ (zoneBottom − ATR × tolerance)
           AND VWAP ≤ (zoneTop + ATR × tolerance)

When true, zone receives +25 score and ⊕V tag on label.

━━━━━━━━━━━━━━━━━━━━
MULTI-TIMEFRAME ZONE OVERLAY
━━━━━━━━━━━━━━━━━━━━

Same detection logic runs on a higher timeframe via:
request.security(syminfo.tickerid, htfRes, f_htfDetect(), lookahead=barmerge.lookahead_off)

HTF zones drawn with dashed blue borders. When LTF zone overlaps active HTF zone it receives +20 confluence bonus and ⊕H label tag. HTF zones auto-mitigated when price closes through them.

━━━━━━━━━━━━━━━━━━━━
LIQUIDITY SWEEP DETECTION
━━━━━━━━━━━━━━━━━━━━

A liquidity sweep is defined as:

For demand zones (⚡BUY):
- bar[1] low < zone bottom — wick pierced below
- bar[1] close > zone bottom — body reclaimed inside zone
- Sweep depth = (zoneBottom − low[1]) / close ≥ minimum threshold
- Current bar confirms bullish (close > open)

For supply zones (⚡SELL): inverse conditions apply.

This represents institutional stop hunting — retail stops below a structural low are triggered, price immediately reverses. These are marked as ⚡BUY / ⚡SELL, visually distinct from regular signals.

━━━━━━━━━━━━━━━━━━━━
SIGNAL LOGIC
━━━━━━━━━━━━━━━━━━━━

Regular BUY signal fires when all confirmed on closed bar:
- Price taps active demand zone (low ≤ zone top)
- Close back above zone top — bullish body
- Lower wick ≥ 50% of candle range — rejection confirmation
- Trend filter: close > EMA(50) — directional bias
- Zone grade meets minimum requirement
- Zone not yet used (one-signal-per-zone mode)
- Cooldown bars passed since last signal

Inverse for SELL at supply zones.

━━━━━━━━━━━━━━━━━━━━
ZONE MITIGATION
━━━━━━━━━━━━━━━━━━━━

Two modes:
- Body Close: zone removed when candle body closes through zone boundary
- Wick Touch: zone removed when any wick touches zone boundary

Mitigated zones are deleted from chart automatically. All related labels and badges deleted simultaneously via parallel array management.

━━━━━━━━━━━━━━━━━━━━
LIVE BACKTEST PANEL
━━━━━━━━━━━━━━━━━━━━

Every fired signal is logged with: entry price, ATR at entry, direction, bar index. On subsequent bars the script evaluates:

- Win: price reaches entry ± (ATR × targetMultiplier) in signal direction
- Loss: price reaches entry ∓ (ATR × stopMultiplier) against signal direction

First level hit determines outcome. Panel displays:
- Total signals tracked (configurable max, default 50)
- Wins / Losses / Open
- Win rate %
- Average R-multiple = (wins × targetMult − losses × stopMult) / closed signals

This is a logic-level simulation using OHLC data. Not slippage or fee adjusted.

━━━━━━━━━━━━━━━━━━━━
WHAT IS ORIGINAL
━━━━━━━━━━━━━━━━━━━━

- Quantitative zone grading (0–100 score → A+/A/B/C) based on four measurable confluences
- Liquidity sweep detection as a separate premium signal class
- VWAP proximity as a scored confluence factor (not just an overlay)
- HTF zone overlap as a scored confluence factor
- Live backtest panel tracking actual signal outcomes with R-multiple
- Adaptive zone extension — boxes track current bar instead of extending infinitely
- All filters stackable independently: grade, trend, wick size, cooldown, session, freshness

━━━━━━━━━━━━━━━━━━━━
HOW TO USE
━━━━━━━━━━━━━━━━━━━━

- Green boxes = demand zones | Red boxes = supply zones
- Dashed blue boxes = higher timeframe zones
- Grade badge inside each zone: A+ (yellow) / A (orange) / B (gray) / C (faded)
- ⊕V = VWAP confluence | ⊕H = HTF confluence
- Triangle up = BUY signal | Triangle down = SELL signal
- ⚡BUY / ⚡SELL = liquidity sweep signals (highest probability)

Recommended workflow:
1. Identify A or A+ graded zones with ⊕V or ⊕H tags
2. Wait for price to return to zone
3. Enter on BUY/SELL signal — wick rejection + bullish/bearish close
4. Prioritize ⚡ sweep signals when available
5. Monitor backtest panel to confirm positive expectancy on your asset

━━━━━━━━━━━━━━━━━━━━
RECOMMENDED SETTINGS
━━━━━━━━━━━━━━━━━━━━

- Forex / Gold (XAUUSD): Volume confirmation OFF
- Stocks / Crypto / Futures: Volume confirmation ON
- Scalping: 5m–15m chart, HTF = 1H
- Intraday: 15m–1H chart, HTF = 4H
- Conservative: Min Grade = A, Cooldown = 10
- Aggressive: Min Grade = B, Cooldown = 5

━━━━━━━━━━━━━━━━━━━━

No repainting. No lookahead bias. All signals fire on barstate.isconfirmed only.
Detection uses bar[1] and bar[2] historical references exclusively.

WHY THESE COMPONENTS WORK TOGETHER

Supply and demand zones identify WHERE price is likely to react. VWAP identifies WHERE fair value sits. Neither alone confirms institutional intent. When a zone aligns with VWAP and a higher-timeframe zone simultaneously, the probability of a genuine institutional reaction increases measurably. The liquidity sweep signal adds a third layer — detecting when stops are hunted before reversal. These three components cannot produce the same edge independently; the confluence scoring model is what ties them into one system.

## Source Code

````pine
//@version=6
indicator("Supply Demand Pro — VWAP + Liquidity Confluence [ApexFlow_]", "Supply Demand Pro — VWAP + Liquidity Confluence", overlay=true, max_boxes_count=200, max_labels_count=200, max_lines_count=50)

// ============================================================
// INPUTS
// ============================================================
grpZ = "▸ Zone Detection"
basePeriod = input.int(2, "Max Base Candles", 1, 5, group=grpZ)
moveMult   = input.float(1.2, "Move Strength (ATR x)", 0.5, step=0.1, group=grpZ)
atrLen     = input.int(14, "ATR Length", 1, group=grpZ)
volMult    = input.float(1.1, "Volume Multiplier", 1.0, step=0.1, group=grpZ)
volLen     = input.int(20, "Volume Avg Length", 1, group=grpZ)
bodyPct    = input.float(0.55, "Min Body % of Range", 0.3, 0.9, step=0.05, group=grpZ)
useVolume  = input.bool(false, "Require Volume Confirmation", group=grpZ)

grpF = "▸ Signal Filters"
freshOnly  = input.bool(true, "Fresh Zones Only", group=grpF)
oneShot    = input.bool(true, "One Signal Per Zone", group=grpF)
minWickPct = input.float(0.5, "Min Rejection Wick %", 0.2, 0.9, step=0.05, group=grpF)
cooldown   = input.int(5, "Cooldown Bars", 0, 50, group=grpF)
useTrend   = input.bool(true, "HTF Trend Filter (EMA)", group=grpF)
emaLen     = input.int(50, "Trend EMA Length", 5, group=grpF)
minGrade   = input.string("B", "Min Zone Grade for Signal", options=["A+", "A", "B", "C"], group=grpF)

grpSweep = "▸ Liquidity Sweep Mode"
sweepOn  = input.bool(true, "Enable Sweep Signals", group=grpSweep, tooltip="Premium: zone wicked + reclaimed = institutional stop hunt. Requires Body Close mitigation.")
sweepReq = input.float(0.0005, "Min Sweep Depth (% of price)", 0.0001, step=0.0001, group=grpSweep)

grpMTF = "▸ Multi-Timeframe Zones"
mtfOn  = input.bool(true, "Show HTF Zones", group=grpMTF)
htfRes = input.timeframe("60", "HTF Resolution", group=grpMTF)
htfBg  = input.color(color.new(color.blue, 88), "HTF Zone Fill", group=grpMTF)

grpVwap = "▸ VWAP Confluence"
vwapOn   = input.bool(true, "Show VWAP", group=grpVwap)
vwapConf = input.bool(true, "Use as Confluence (boost grade)", group=grpVwap)
vwapTol  = input.float(0.5, "Confluence Tolerance (ATR x)", 0.1, 2.0, step=0.1, group=grpVwap)

grpBT = "▸ Backtest Panel"
btOn      = input.bool(true, "Track Backtest Stats", group=grpBT)
targetATR = input.float(2.0, "Target (ATR x)", 0.5, step=0.1, group=grpBT)
stopATR   = input.float(1.0, "Stop (ATR x)", 0.3, step=0.1, group=grpBT)
maxTrack  = input.int(50, "Max Signals to Track", 10, 200, group=grpBT)

grpD = "▸ Display"
maxZones  = input.int(3, "Max Active Zones / Side", 1, 8, group=grpD)
mitMode   = input.string("Body Close", "Mitigation", options=["Wick Touch", "Body Close"], group=grpD)
extendRt  = input.bool(true, "Extend Right", group=grpD)
showLbl   = input.bool(true, "Show Zone Labels", group=grpD)
showGrade = input.bool(true, "Show Grade Badge", group=grpD)
showStats = input.bool(true, "Show Stats Panel", group=grpD)
showEma   = input.bool(false, "Plot Trend EMA", group=grpD)

grpS = "▸ Style"
supBg = input.color(color.new(#ef5350, 82), "Supply Fill", group=grpS)
demBg = input.color(color.new(#26a69a, 82), "Demand Fill", group=grpS)
supBd = input.color(#ef5350, "Supply Border", group=grpS)
demBd = input.color(#26a69a, "Demand Border", group=grpS)

grpSig = "▸ Session"
sigOn  = input.bool(true, "Buy/Sell Signals", group=grpSig)
sessOn = input.bool(false, "Session Filter", group=grpSig)
sess   = input.session("0930-1530", "Active Session", group=grpSig)
tz     = input.string("America/New_York", "Timezone", group=grpSig)

// ============================================================
// CORE
// ============================================================
atr    = ta.atr(atrLen)
volAvg = ta.sma(volume, volLen)
ema    = ta.ema(close, emaLen)
vwap   = ta.vwap
rng    = high - low
body   = math.abs(close - open)
upWick = high - math.max(close, open)
dnWick = math.min(close, open) - low
isBull = close > open
isBear = close < open

volOK     = useVolume ? volume > volAvg * volMult : true
explosive = rng > atr * moveMult and volOK and body > rng * bodyPct
inSess    = sessOn ? not na(time(timeframe.period, sess, tz)) : true
trendUp   = useTrend ? close > ema : true
trendDn   = useTrend ? close < ema : true

detectSupply = explosive[1] and isBear[1]
detectDemand = explosive[1] and isBull[1]

// ============================================================
// HTF DETECTION
// ============================================================
f_htfDetect() =>
    a = ta.atr(atrLen)
    r = high - low
    bd = math.abs(close - open)
    va = ta.sma(volume, volLen)
    vo = useVolume ? volume > va * volMult : true
    ex = r > a * moveMult and vo and bd > r * bodyPct
    bu = close > open
    be = close < open
    ds = ex[1] and be[1]
    dd = ex[1] and bu[1]
    sT = ds ? high[2] : na
    sB = ds ? math.min(low[2], open[1]) : na
    dT = dd ? math.max(high[2], open[1]) : na
    dB = dd ? low[2] : na
    [ds, dd, sT, sB, dT, dB]

[htfSupNew, htfDemNew, htfSupT, htfSupB, htfDemT, htfDemB] = request.security(syminfo.tickerid, htfRes, f_htfDetect(), lookahead=barmerge.lookahead_off)

var box   htfSupBox  = na
var box   htfDemBox  = na
var float htfSupTopV = na
var float htfSupBotV = na
var float htfDemTopV = na
var float htfDemBotV = na

if mtfOn and htfSupNew and not na(htfSupT)
    if not na(htfSupBox)
        box.delete(htfSupBox)
    htfSupBox  := box.new(bar_index - 20, htfSupT, bar_index, htfSupB, border_color=color.new(color.blue, 30), bgcolor=htfBg, extend=extendRt ? extend.right : extend.none, border_width=1, border_style=line.style_dashed)
    htfSupTopV := htfSupT
    htfSupBotV := htfSupB

if mtfOn and htfDemNew and not na(htfDemT)
    if not na(htfDemBox)
        box.delete(htfDemBox)
    htfDemBox  := box.new(bar_index - 20, htfDemT, bar_index, htfDemB, border_color=color.new(color.blue, 30), bgcolor=htfBg, extend=extendRt ? extend.right : extend.none, border_width=1, border_style=line.style_dashed)
    htfDemTopV := htfDemT
    htfDemBotV := htfDemB

if mtfOn and not na(htfSupTopV) and close > htfSupTopV
    if not na(htfSupBox)
        box.delete(htfSupBox)
        htfSupBox := na
    htfSupTopV := na
    htfSupBotV := na

if mtfOn and not na(htfDemBotV) and close < htfDemBotV
    if not na(htfDemBox)
        box.delete(htfDemBox)
        htfDemBox := na
    htfDemTopV := na
    htfDemBotV := na

// ============================================================
// GRADING
// ============================================================
f_grade(moveRatio, volRatio, vwapInZone, htfMatch) =>
    s = 0.0
    s := s + math.min(moveRatio * 18, 30)
    s := s + (useVolume ? math.min(volRatio * 13, 20) : 10)
    s := s + (vwapInZone ? 25 : 0)
    s := s + (htfMatch ? 20 : 0)
    s := s + 5
    g = s >= 80 ? "A+" : s >= 65 ? "A" : s >= 50 ? "B" : "C"
    [g, s]

f_gradeRank(g) =>
    g == "A+" ? 4 : g == "A" ? 3 : g == "B" ? 2 : 1

minRank = f_gradeRank(minGrade)

f_badgeColor(g) =>
    g == "A+" ? color.new(color.yellow, 0) : g == "A" ? color.new(color.orange, 0) : g == "B" ? color.new(color.gray, 30) : color.new(color.gray, 60)

// ============================================================
// STORAGE
// ============================================================
var array<box>    supBox    = array.new<box>()
var array<label>  supLbl    = array.new<label>()
var array<label>  supBadge  = array.new<label>()
var array<float>  supTop    = array.new<float>()
var array<float>  supBot    = array.new<float>()
var array<bool>   supTested = array.new<bool>()
var array<bool>   supUsed   = array.new<bool>()
var array<string> supGrade  = array.new<string>()
var array<bool>   supSwept  = array.new<bool>()

var array<box>    demBox    = array.new<box>()
var array<label>  demLbl    = array.new<label>()
var array<label>  demBadge  = array.new<label>()
var array<float>  demTop    = array.new<float>()
var array<float>  demBot    = array.new<float>()
var array<bool>   demTested = array.new<bool>()
var array<bool>   demUsed   = array.new<bool>()
var array<string> demGrade  = array.new<string>()
var array<bool>   demSwept  = array.new<bool>()

var int lastSigBar = -9999

f_base() =>
    bh = high[2]
    bl = low[2]
    off = 2
    for i = 2 to basePeriod + 1
        if math.abs(close[i] - open[i]) < atr[1] * 0.5 and not explosive[i]
            bh := math.max(bh, high[i])
            bl := math.min(bl, low[i])
            off := i
        else
            break
    [bh, bl, off]

// ============================================================
// CREATE SUPPLY
// ============================================================
if detectSupply and barstate.isconfirmed
    [bh, bl, off] = f_base()
    zTop = bh
    zBot = math.min(bl, open[1])
    moveRatio = rng[1] / atr[1]
    volRatio  = volAvg[1] > 0 ? volume[1] / volAvg[1] : 1.0
    vwapIn    = vwapConf and vwap >= zBot - atr * vwapTol and vwap <= zTop + atr * vwapTol
    htfMatch  = mtfOn and not na(htfSupTopV) and zTop >= htfSupBotV and zBot <= htfSupTopV
    [grade, gscore] = f_grade(moveRatio, volRatio, vwapIn, htfMatch)
    bx = box.new(bar_index - off, zTop, bar_index, zBot, border_color=supBd, bgcolor=supBg, extend=extendRt ? extend.right : extend.none, border_width=1)
    lblColor = showLbl ? color.new(#ef5350, 30) : color.new(color.white, 100)
    lblText  = showLbl ? "SUPPLY" + (vwapIn ? " ⊕V" : "") + (htfMatch ? " ⊕H" : "") : ""
    lb = label.new(bar_index, zTop, lblText, style=label.style_label_down, color=lblColor, textcolor=color.white, size=size.small)
    badgeText = showGrade ? grade : ""
    badge = label.new(bar_index - off, (zTop + zBot) / 2, badgeText, style=label.style_label_right, color=f_badgeColor(grade), textcolor=color.black, size=size.small)
    array.push(supBox, bx)
    array.push(supLbl, lb)
    array.push(supBadge, badge)
    array.push(supTop, zTop)
    array.push(supBot, zBot)
    array.push(supTested, false)
    array.push(supUsed, false)
    array.push(supGrade, grade)
    array.push(supSwept, false)
    while array.size(supBox) > maxZones
        box.delete(array.shift(supBox))
        label.delete(array.shift(supLbl))
        label.delete(array.shift(supBadge))
        array.shift(supTop)
        array.shift(supBot)
        array.shift(supTested)
        array.shift(supUsed)
        array.shift(supGrade)
        array.shift(supSwept)

// ============================================================
// CREATE DEMAND
// ============================================================
if detectDemand and barstate.isconfirmed
    [bh, bl, off] = f_base()
    zTop = math.max(bh, open[1])
    zBot = bl
    moveRatio = rng[1] / atr[1]
    volRatio  = volAvg[1] > 0 ? volume[1] / volAvg[1] : 1.0
    vwapIn    = vwapConf and vwap >= zBot - atr * vwapTol and vwap <= zTop + atr * vwapTol
    htfMatch  = mtfOn and not na(htfDemTopV) and zTop >= htfDemBotV and zBot <= htfDemTopV
    [grade, gscore] = f_grade(moveRatio, volRatio, vwapIn, htfMatch)
    bx = box.new(bar_index - off, zTop, bar_index, zBot, border_color=demBd, bgcolor=demBg, extend=extendRt ? extend.right : extend.none, border_width=1)
    lblColor = showLbl ? color.new(#26a69a, 30) : color.new(color.white, 100)
    lblText  = showLbl ? "DEMAND" + (vwapIn ? " ⊕V" : "") + (htfMatch ? " ⊕H" : "") : ""
    lb = label.new(bar_index, zBot, lblText, style=label.style_label_up, color=lblColor, textcolor=color.white, size=size.small)
    badgeText = showGrade ? grade : ""
    badge = label.new(bar_index - off, (zTop + zBot) / 2, badgeText, style=label.style_label_right, color=f_badgeColor(grade), textcolor=color.black, size=size.small)
    array.push(demBox, bx)
    array.push(demLbl, lb)
    array.push(demBadge, badge)
    array.push(demTop, zTop)
    array.push(demBot, zBot)
    array.push(demTested, false)
    array.push(demUsed, false)
    array.push(demGrade, grade)
    array.push(demSwept, false)
    while array.size(demBox) > maxZones
        box.delete(array.shift(demBox))
        label.delete(array.shift(demLbl))
        label.delete(array.shift(demBadge))
        array.shift(demTop)
        array.shift(demBot)
        array.shift(demTested)
        array.shift(demUsed)
        array.shift(demGrade)
        array.shift(demSwept)

// ============================================================
// MITIGATION
// ============================================================
i = array.size(supBox) - 1
while i >= 0
    t = array.get(supTop, i)
    broken = mitMode == "Body Close" ? close > t : high > t
    if broken
        box.delete(array.get(supBox, i))
        label.delete(array.get(supLbl, i))
        label.delete(array.get(supBadge, i))
        array.remove(supBox, i)
        array.remove(supLbl, i)
        array.remove(supBadge, i)
        array.remove(supTop, i)
        array.remove(supBot, i)
        array.remove(supTested, i)
        array.remove(supUsed, i)
        array.remove(supGrade, i)
        array.remove(supSwept, i)
    i -= 1

j = array.size(demBox) - 1
while j >= 0
    b = array.get(demBot, j)
    broken = mitMode == "Body Close" ? close < b : low < b
    if broken
        box.delete(array.get(demBox, j))
        label.delete(array.get(demLbl, j))
        label.delete(array.get(demBadge, j))
        array.remove(demBox, j)
        array.remove(demLbl, j)
        array.remove(demBadge, j)
        array.remove(demTop, j)
        array.remove(demBot, j)
        array.remove(demTested, j)
        array.remove(demUsed, j)
        array.remove(demGrade, j)
        array.remove(demSwept, j)
    j -= 1

// ============================================================
// BACKTEST ARRAYS
// ============================================================
var array<int>    sigBar    = array.new<int>()
var array<float>  sigPrice  = array.new<float>()
var array<float>  sigATR    = array.new<float>()
var array<int>    sigDir    = array.new<int>()
var array<int>    sigResult = array.new<int>()
var array<string> sigGradeA = array.new<string>()

f_logSignal(dir, grade) =>
    if btOn
        array.push(sigBar, bar_index)
        array.push(sigPrice, close)
        array.push(sigATR, atr)
        array.push(sigDir, dir)
        array.push(sigResult, 0)
        array.push(sigGradeA, grade)
        while array.size(sigBar) > maxTrack
            array.shift(sigBar)
            array.shift(sigPrice)
            array.shift(sigATR)
            array.shift(sigDir)
            array.shift(sigResult)
            array.shift(sigGradeA)

// ============================================================
// SIGNALS
// ============================================================
buySig    = false
sellSig   = false
sweepBuy  = false
sweepSell = false

cooldownOK = (bar_index - lastSigBar) >= cooldown

if sigOn and inSess and barstate.isconfirmed and cooldownOK
    if trendUp
        demSize = array.size(demBox)
````
