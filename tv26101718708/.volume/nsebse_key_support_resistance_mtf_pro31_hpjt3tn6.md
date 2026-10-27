# NSE/BSE Key Support & Resistance | MTF Pro-3.1

- url: https://www.tradingview.com/script/HPJT3TN6-NSE-BSE-Key-Support-Resistance-MTF-Pro-3-1/
- type: indicator
- pine_id: PUB;fc477a7662f24718a5439689f253562e
- version: 10.0

## Description

Advanced pivot-based Support & Resistance with multi-timeframe confluence, strength scoring, volume-confirmed breaks, and adaptive zone visuals — built specifically for Indian stock market (NSE/BSE).

Overview
Most S&R indicators draw every pivot as an equal horizontal line and extend it infinitely to the right — creating cluttered, unreadable charts. This indicator solves that by scoring every level based on [b]how strongly price rejected it[/b], merging overlapping levels from different timeframes into a single confluence zone, and only showing the levels that actually matter.
Built and tuned specifically for [b]NSE and BSE [/b]stocks, indices (Nifty 50, Bank Nifty, Sensex), and F&O instruments.

Key Features
🔷 [b]Multi-Timeframe Support (4 TFs)[/b]
Enable up to 4 independent timeframes simultaneously. Each timeframe's pivots are detected separately and tagged in the label — [15m], [1H], [D], [W]. You choose which timeframes to activate.
🔷 [b]Cross-TF Confluence Merge[/b]
When two different timeframes produce a pivot at nearly the same price (within ATR proximity), they automatically merge into a single stronger zone instead of drawing two overlapping boxes. The label shows both sources — [1H] [D] — and the level receives a confluence strength bonus. These merged zones are your highest-priority trade levels.
🔷 [b]Advanced Strength Scoring[/b]
Every level carries a live strength score (★) that accumulates over time. Each touch is scored individually based on:

Wick size relative to candle range (how strongly price rejected)
Distance of close from the level (how convincingly price pulled back)
Whether volume was above average on that candle
Whether a strong body / engulfing candle formed

A barely touching wick scores ~0.5. A high-volume hammer rejection scores ~5–6. The score drives both zone opacity and zone width — strong levels appear bold and wide, weak levels fade visually.
🔷 [b]Volume-Based Break Filter[/b]
A level is only invalidated when price closes beyond it and volume meets a configurable threshold (default: 1× average volume). Low-volume spikes through a level are ignored as false breakouts — the zone remains valid. Break alerts include the volume ratio so you know the conviction behind the move.
🔷 [b]Adaptive Zone Visuals[/b]

[b]No right extension[/b] — zones terminate at the current bar (valid) or the break bar (broken). No infinite lines cluttering the right side of your chart.
[b]Opacity scales with strength[/b] — strongest levels are most visible, weakest levels are nearly transparent.
[b]Zone width scales with strength[/b] — high-confidence zones are wider, giving a visual sense of the price area's importance.

🔷[b] Clean Labels[/b]
Each label shows the full picture at a glance:
[1H] [D]
21450.00  ★6.5  ×3
Timeframe source | Price | Strength score | Touch count

[b]Settings Guide[/b]
SettingWhat it doesPivot LengthBars each side to confirm a pivot. Higher = fewer, stronger levelsMin StrengthHide levels below this score. Raise to show only confirmed levelsATR Merge DistanceHow close two levels must be to merge into oneInvalidationClose-based (reliable) or Wick-based (faster) break detectionVolume Break FilterRequire above-average volume to confirm a breakoutMin Volume MultiplierHow many times average volume needed to confirm a breakMax Active LevelsCap total zones shown on chartStrength → Zone OpacityToggle adaptive opacity based on strength score

How to Use
Bounce trades — price enters a green (support) zone → wait for a rejection candle with volume → enter above the rejection candle high, SL below zone bottom.
Rejection trades — price enters a red (resistance) zone → wait for a bearish candle with volume → enter below candle low, SL above zone top.
Breakout trades — price closes beyond a zone with high volume (break alert fires) → wait for pullback to the broken level → trade in the direction of the break.
Highest priority setups — zones tagged [1H] [D] or [D] [W] with ★ score above 5 and multiple touches. These are the levels institutional money respects.

[b]Alerts[/b]
The indicator fires alert() calls for:

Break confirmed — includes ticker, price, and volume ratio
Retest — includes ticker, price, and touch quality score

Set alert condition to "Any alert() function call" in TradingView's alert dialog.

[b]Notes[/b]

Designed and tested on NSE/BSE equities and F&O stocks
Works on any timeframe from 1 minute to Weekly
All calculations are original — pivot detection, strength engine, confluence merge, and volume filter are built from scratch in Pine Script v6

## Source Code

````pine
// ============================================================
// KEY SUPPORT & RESISTANCE | MTF Pro Edition v3.24
// Author  : Jithin Chellappan
// New     : Advanced touch scoring, volume-based break filter,
//           strength scoring (opacity + zone width),
//           cross-TF confluence merge with combined label.
// v3.4    : + NSE Session Filter (pre-open + closing auction)
// v3.5    : + Strength label cap (★8+ display)
//           + Volatility-aware ATR merge (normal vs high-vol days)
// v3.6    : + Dashed border zone style toggle
// v3.7    : + Dashed style: blue/grey colors, 9% transparency, center line
// v3.8    : + Line only style option
// v3.9    : + Performance: reduced max counts, max_bars_back limits
// v3.10   : + Market Preset dropdown (NSE/Forex/Gold/Crypto/Custom)
// v3.11   : + User-selectable dashed zone colors
// v3.16   : + Zone width per preset, bumped max_lines_count
// v3.19   : Removed trend lines — clean S&R only
// v3.20   : Tightened defaults for key zones only
// v3.21   : Default zone style changed to Dashed
// v3.22   : Gold futures tuning (GC1!/MGC1!) — real volume,
//           wider zones, COMEX session filter
// v3.23   : Auto market detection — removed preset dropdown
// v3.24   : + Silver, Copper, Crude Oil, Natural Gas (spot + futures) presets
// ============================================================

//@version=6
indicator("Key S&R MTF Pro v3.24", overlay = true,
     max_labels_count = 200, max_lines_count = 200, max_boxes_count = 200,
     dynamic_requests = true)

// ─────────────────────────────────────────────
// PERFORMANCE
// ─────────────────────────────────────────────
max_bars_back(high,   300)
max_bars_back(low,    300)
max_bars_back(close,  300)
max_bars_back(volume, 300)

// ─────────────────────────────────────────────
// GROUPS
// ─────────────────────────────────────────────
grpTF     = "⏱  Timeframes"
grpCore   = "⚙️  Core Settings"
grpBreak  = "💥  Break Filter"
grpStyle  = "🎨  Visual Style"
grpAlrt   = "🔔  Alerts"
grpSess   = "🕐  NSE Session Filter"

// ─────────────────────────────────────────────
// AUTO MARKET DETECTION
// Detects instrument automatically from syminfo.
// No manual selection needed.
// ─────────────────────────────────────────────
_ticker = syminfo.ticker

// ── Commodity Futures ──
_isGoldFut    = _ticker == "GC1!"  or _ticker == "MGC1!"
_isSilverFut  = _ticker == "SI1!"  or _ticker == "MSI1!" or _ticker == "SIL1!"
_isCopperFut  = _ticker == "HG1!"  or _ticker == "MHG1!"
_isCrudeFut   = _ticker == "CL1!"  or _ticker == "MCL1!" or _ticker == "QM1!"
_isNGasFut    = _ticker == "NG1!"  or _ticker == "MNG1!"

// ── Commodity Spots ──
_isGoldSpot   = syminfo.basecurrency == "XAU"
_isSilverSpot = syminfo.basecurrency == "XAG"
_isCopperSpot = str.contains(_ticker, "COPPER") or str.contains(_ticker, "XCUUSD")
_isCrudeSpot  = str.contains(_ticker, "USOIL")  or str.contains(_ticker, "WTICOUSD") or str.contains(_ticker, "BCOUSD")
_isNGasSpot   = str.contains(_ticker, "NATGAS") or str.contains(_ticker, "UKOIL")

// ── Other markets ──
_isNSEBSE     = syminfo.prefix == "NSE" or syminfo.prefix == "BSE"
_isCrypto     = syminfo.type == "crypto"
_isForex      = syminfo.type == "forex"
_isFutures    = syminfo.type == "futures" and not (_isGoldFut or _isSilverFut or _isCopperFut or _isCrudeFut or _isNGasFut)

var string marketPreset = "Custom"
if _isNSEBSE
    marketPreset := "NSE/BSE"
else if _isGoldFut
    marketPreset := "Gold Fut"
else if _isGoldSpot
    marketPreset := "Gold Spot"
else if _isSilverFut
    marketPreset := "Silver Fut"
else if _isSilverSpot
    marketPreset := "Silver Spot"
else if _isCopperFut
    marketPreset := "Copper Fut"
else if _isCopperSpot
    marketPreset := "Copper Spot"
else if _isCrudeFut
    marketPreset := "Crude Fut"
else if _isCrudeSpot
    marketPreset := "Crude Spot"
else if _isNGasFut
    marketPreset := "NatGas Fut"
else if _isNGasSpot
    marketPreset := "NatGas Spot"
else if _isCrypto
    marketPreset := "Crypto"
else if _isForex
    marketPreset := "Forex"
else if _isFutures
    marketPreset := "Futures"
else
    marketPreset := "Custom"

// ─────────────────────────────────────────────
// TIMEFRAME INPUTS
// ─────────────────────────────────────────────
tf1On = input.bool     (true,  "", inline = "tf1", group = grpTF)
tf1   = input.timeframe("",    "TF 1 (Current)", inline = "tf1", group = grpTF)

tf2On = input.bool     (false, "", inline = "tf2", group = grpTF)
tf2   = input.timeframe("60",  "TF 2",            inline = "tf2", group = grpTF)

tf3On = input.bool     (false, "", inline = "tf3", group = grpTF)
tf3   = input.timeframe("D",   "TF 3",            inline = "tf3", group = grpTF)

tf4On = input.bool     (false, "", inline = "tf4", group = grpTF)
tf4   = input.timeframe("W",   "TF 4",            inline = "tf4", group = grpTF)

// ─────────────────────────────────────────────
// CORE INPUTS
// ─────────────────────────────────────────────
pivLen      = input.int   (15,   "Pivot Length",        minval=3,    maxval=50,  group = grpCore)
minStrength = input.int   (2,    "Min Strength to Show",minval=1,    maxval=10,  group = grpCore,
                tooltip = "Strength = touch score. Strong rejections score more than weak wicks.")
atrProx     = input.float (0.4,  "ATR Merge Distance",  minval=0.05, maxval=2.0, step=0.05, group = grpCore,
                tooltip = "Levels within this × ATR are merged into one (cross-TF confluence).")
atrVolAware = input.bool  (true, "Volatility-Aware Merge", group = grpCore,
                tooltip = "Tightens merge threshold on high-volatility days (budget, RBI, results).")
invMethod   = input.string("Close","Invalidation",       options=["Close","Wick"], group = grpCore)
showBroken  = input.bool  (false,"Show Broken Levels",  group = grpCore)
maxLvls     = input.int   (4,    "Max Active Levels",   minval=2,    maxval=20,  group = grpCore)

// ─────────────────────────────────────────────
// BREAK FILTER INPUTS
// ─────────────────────────────────────────────
volBreakFilter = input.bool  (true,  "Volume Break Filter",   group = grpBreak,
                    tooltip = "Requires above-average volume to confirm a break.\nGold Futures uses real COMEX volume — reliable at 1.0× threshold.")
volBreakMult   = input.float (1.0,   "Min Volume Multiplier", minval=0.5, maxval=3.0, step=0.1, group = grpBreak,
                    tooltip = "Break only confirmed if volume > this × average volume.")
volAvgLen      = input.int   (20,    "Volume Avg Length",     minval=5,   maxval=50,  group = grpBreak)

// ─────────────────────────────────────────────
// STYLE INPUTS
// ─────────────────────────────────────────────
supCol      = input.color (color.new(#089981, 55), "Support",    group = grpStyle, inline = "colors")
resCol      = input.color (color.new(#F23645, 55), "Resistance", group = grpStyle, inline = "colors")
baseZoneW   = input.float (0.12, "Base Zone Width (×ATR)", minval=0.02, maxval=0.5, step=0.02, group = grpStyle)
strengthVis = input.bool  (true, "Strength → Zone Opacity", group = grpStyle,
                tooltip = "Stronger levels appear more opaque. Weaker levels are more transparent.")
lbSize      = input.string(size.tiny, "Label Size", options=[size.tiny, size.small, size.normal], group = grpStyle)
showLbl     = input.bool  (true, "Show Labels", group = grpStyle)
showZone    = input.bool  (true, "Show Zones",  group = grpStyle)
dashSupCol  = input.color (color.new(#2962FF, 91), "Dashed Support Color",    group = grpStyle, inline = "dashcol")
dashResCol  = input.color (color.new(#9598A1, 91), "Dashed Resistance Color", group = grpStyle, inline = "dashcol")
zoneStyle   = input.string("Dashed", "Zone Style", options=["Filled","Dashed","Line"], group = grpStyle,
                tooltip = "Filled = solid zone.\nDashed = dotted border, 9% fill, blue/grey.\nLine = single horizontal line only.")
lineWidth   = input.int   (1, "Line Width", minval=1, maxval=4, group = grpStyle)

// ─────────────────────────────────────────────
// ALERT INPUTS
// ─────────────────────────────────────────────
alrtRetest = input.bool(true, "Alert: Retest", group = grpAlrt)
alrtBreak  = input.bool(true, "Alert: Break",  group = grpAlrt)

// ─────────────────────────────────────────────
// NSE SESSION FILTER INPUTS
// ─────────────────────────────────────────────
sessionFilter = input.bool(true,  "NSE Session Filter",              group = grpSess,
                    tooltip = "Ignores pivots from pre-open and closing auction sessions.\nAuto-disabled for non-NSE presets.")
filterPreOpen = input.bool(true,  "Block Pre-Open (9:00 – 9:15 AM)", group = grpSess)
filterClosing = input.bool(true,  "Block Closing Auction (3:25 – 3:30 PM)", group = grpSess)

// ─────────────────────────────────────────────
// PRESET OVERRIDES — per instrument type
// Pivot | ATR Merge | Vol Mult | Zone Width
// ─────────────────────────────────────────────
_pivLen     = marketPreset == "NSE/BSE"     ? 15   :
              marketPreset == "Gold Fut"    ? 15   :
              marketPreset == "Gold Spot"   ? 12   :
              marketPreset == "Silver Fut"  ? 15   :
              marketPreset == "Silver Spot" ? 12   :
              marketPreset == "Copper Fut"  ? 12   :
              marketPreset == "Copper Spot" ? 12   :
              marketPreset == "Crude Fut"   ? 12   :
              marketPreset == "Crude Spot"  ? 12   :
              marketPreset == "NatGas Fut"  ? 10   :
              marketPreset == "NatGas Spot" ? 10   :
              marketPreset == "Crypto"      ? 10   :
              marketPreset == "Forex"       ? 12   :
              marketPreset == "Futures"     ? 10   : pivLen

_atrProx    = marketPreset == "NSE/BSE"     ? 0.40 :
              marketPreset == "Gold Fut"    ? 0.50 :
              marketPreset == "Gold Spot"   ? 0.40 :
              marketPreset == "Silver Fut"  ? 0.50 :
              marketPreset == "Silver Spot" ? 0.40 :
              marketPreset == "Copper Fut"  ? 0.40 :
              marketPreset == "Copper Spot" ? 0.40 :
              marketPreset == "Crude Fut"   ? 0.45 :
              marketPreset == "Crude Spot"  ? 0.45 :
              marketPreset == "NatGas Fut"  ? 0.50 :
              marketPreset == "NatGas Spot" ? 0.50 :
              marketPreset == "Crypto"      ? 0.50 :
              marketPreset == "Forex"       ? 0.40 :
              marketPreset == "Futures"     ? 0.35 : atrProx

_volMult    = marketPreset == "NSE/BSE"     ? 1.0 :
              marketPreset == "Gold Fut"    ? 1.0 :
              marketPreset == "Gold Spot"   ? 0.6 :
              marketPreset == "Silver Fut"  ? 1.0 :
              marketPreset == "Silver Spot" ? 0.6 :
              marketPreset == "Copper Fut"  ? 1.0 :
              marketPreset == "Copper Spot" ? 0.6 :
              marketPreset == "Crude Fut"   ? 1.0 :
              marketPreset == "Crude Spot"  ? 0.6 :
              marketPreset == "NatGas Fut"  ? 1.0 :
              marketPreset == "NatGas Spot" ? 0.6 :
              marketPreset == "Crypto"      ? 0.8 :
              marketPreset == "Forex"       ? 0.6 :
              marketPreset == "Futures"     ? 0.8 : volBreakMult

_useSession = marketPreset == "NSE/BSE" ? sessionFilter : false  // Only NSE/BSE uses session filter

_zoneW      = marketPreset == "NSE/BSE"     ? baseZoneW :
              marketPreset == "Gold Fut"    ? 0.20      :
              marketPreset == "Gold Spot"   ? 0.15      :
              marketPreset == "Silver Fut"  ? 0.22      :
              marketPreset == "Silver Spot" ? 0.18      :
              marketPreset == "Copper Fut"  ? 0.18      :
              marketPreset == "Copper Spot" ? 0.15      :
              marketPreset == "Crude Fut"   ? 0.20      :
              marketPreset == "Crude Spot"  ? 0.18      :
              marketPreset == "NatGas Fut"  ? 0.25      :
              marketPreset == "NatGas Spot" ? 0.22      :
              marketPreset == "Crypto"      ? 0.18      :
              marketPreset == "Forex"       ? 0.10      :
              marketPreset == "Futures"     ? 0.12      : baseZoneW

// ─────────────────────────────────────────────
// BASE CALCS
// ─────────────────────────────────────────────
atr      = ta.atr(14)
atrSlow  = ta.atr(50)
avgVol   = ta.sma(volume, volAvgLen)

effectiveAtrProx = atrVolAware and (atr > atrSlow * 1.5) ? _atrProx * 0.5 : _atrProx

// ─────────────────────────────────────────────
// PIVOT + VOLUME CALLS — HOISTED TO GLOBAL SCOPE
// ─────────────────────────────────────────────
[ph1, pl1, vol1] = request.security(syminfo.tickerid, tf1,
     [ta.pivothigh(high, _pivLen, _pivLen), ta.pivotlow(low, _pivLen, _pivLen), volume],
     lookahead = barmerge.lookahead_off)

[ph2, pl2, vol2] = request.security(syminfo.tickerid, tf2,
     [ta.pivothigh(high, _pivLen, _pivLen), ta.pivotlow(low, _pivLen, _pivLen), volume],
     lookahead = barmerge.lookahead_off)

[ph3, pl3, vol3] = request.security(syminfo.tickerid, tf3,
     [ta.pivothigh(high, _pivLen, _pivLen), ta.pivotlow(low, _pivLen, _pivLen), volume],
     lookahead = barmerge.lookahead_off)

[ph4, pl4, vol4] = request.security(syminfo.tickerid, tf4,
     [ta.pivothigh(high, _pivLen, _pivLen), ta.pivotlow(low, _pivLen, _pivLen), volume],
     lookahead = barmerge.lookahead_off)

// ─────────────────────────────────────────────
// DATA TYPE
// ─────────────────────────────────────────────
type SR
    float  price
    string kind
    int    startTime
    int    endTime
    int    touches
    float  strength
    bool   valid
    string tfLabels
    line   ln
    box    bx
    label  lb

var SR[] allLevels = array.new<SR>()

// ─────────────────────────────────────────────
// DELETE DRAWINGS
// ─────────────────────────────────────────────
deleteSR(SR s) =>
    line.delete (s.ln)
    box.delete  (s.bx)
    label.delete(s.lb)
    s.ln := na
    s.bx := na
    s.lb := na

// ─────────────────────────────────────────────
// STRENGTH → OPACITY  (75% weak → 20% strong)
// ─────────────────────────────────────────────
strengthToAlpha(float str) =>
    capped = math.min(str, 8.0)
    int(math.round(75 - (capped / 8.0) * 55))

// ─────────────────────────────────────────────
// STRENGTH → ZONE WIDTH
// ─────────────────────────────────────────────
strengthToWidth(float str) =>
    capped = math.min(str, 8.0)
    _zoneW * (1.0 + (capped / 8.0) * 0.5)

// ─────────────────────────────────────────────
// ADVANCED TOUCH SCORE  (0–6 pts per touch)
// ─────────────────────────────────────────────
touchScore(string kind, float lvl) =>
    score       = 0.0
    candleRange = high - low
    bodySize    = math.abs(close - open)
    if kind == "Res"
        wickAbove = high - math.max(open, close)
        wickRatio = candleRange > 0 ? wickAbove / candleRange : 0.0
        score    += math.min(wickRatio * 4, 2.0)
        closeGap  = (lvl - close) / math.max(atr, 0.0001)
        score    += math.min(closeGap * 1.5, 2.0)
    else
        wickBelow = math.min(open, close) - low
        wickRatio = candleRange > 0 ? wickBelow / candleRange : 0.0
        score    += math.min(wickRatio * 4, 2.0)
        closeGap  = (close - lvl) / math.max(atr, 0.0001)
        score    += math.min(closeGap * 1.5, 2.0)
    if volume > avgVol
        score += 1.0
    if bodySize > candleRange * 0.5
        score += 1.0
    score

// ─────────────────────────────────────────────
// NSE SESSION FILTER
// ─────────────────────────────────────────────
isBlockedSession() =>
    blocked = false
    if _useSession
        h        = hour  (time, "Asia/Kolkata")
        m        = minute(time, "Asia/Kolkata")
        totalMin = h * 60 + m
        if filterPreOpen and totalMin >= 540 and totalMin < 555
            blocked := true
        if filterClosing and totalMin >= 925 and totalMin <= 930
            blocked := true
    blocked

// ─────────────────────────────────────────────
// PROXIMITY CHECK
// ─────────────────────────────────────────────
findClose(float p, string kind) =>
    SR found = na
    n = allLevels.size()
    if n > 0
        for i = 0 to n - 1
            s = allLevels.get(i)
            if s.valid and s.kind == kind and math.abs(s.price - p) < atr * effectiveAtrProx
                found := s
                break
    found

// ─────────────────────────────────────────────
// ADD OR MERGE LEVEL
// ─────────────────────────────────────────────
addOrMerge(float p, string kind, string tfl) =>
    existing   = findClose(p, kind)
    int _dummy = 0
    if not na(existing)
        existing.price    := (existing.price + p) / 2
        if not str.contains(existing.tfLabels, tfl)
            existing.tfLabels := existing.tfLabels + " [" + tfl + "]"
        else
            existing.tfLabels := existing.tfLabels
        existing.strength += 1.5
        existing.touches  += 1
        _dummy := existing.touches
    else
        s            = SR.new()
        s.price      := p
        s.kind       := kind
        s.startTime  := time[_pivLen]
        s.endTime    := na
        s.touches    := 1
        s.strength   := 1.0
        s.valid      := true
        s.tfLabels   := "[" + tfl + "]"
        allLevels.unshift(s)
        while allLevels.size() > maxLvls * 6
            old = allLevels.pop()
            deleteSR(old)
        _dummy := allLevels.size()

// ─────────────────────────────────────────────
// UPDATE ALL LEVELS (breaks + retests)
// ─────────────────────────────────────────────
updateAll() =>
    n = allLevels.size()
    if n > 0
        for i = 0 to n - 1
            s = allLevels.get(i)
            if not s.valid
                continue
            invHi = invMethod == "Wick" ? high  : close
            invLo = invMethod == "Wick" ? low   : close

            if s.kind == "Res" and invHi > s.price
                volOk = (not volBreakFilter) or (volume >= avgVol * _volMult)
                if volOk
                    s.endTime := time
                    s.valid   := false
                    if alrtBreak
                        alert("BREAK ↑ " + syminfo.ticker + " R " +
                             str.tostring(s.price, format.mintick) +
                             " | Vol: " + str.tostring(math.round(volume / avgVol, 1)) + "×Avg",
                             alert.freq_once_per_bar_close)
            else if s.kind == "Sup" and invLo < s.price
                volOk = (not volBreakFilter) or (volume >= avgVol * _volMult)
                if volOk
                    s.endTime := time
                    s.valid   := false
                    if alrtBreak
                        alert("BREAK ↓ " + syminfo.ticker + " S " +
                             str.tostring(s.price, format.mintick) +
                             " | Vol: " + str.tostring(math.round(volume / avgVol, 1)) + "×Avg",
                             alert.freq_once_per_bar_close)
            else if na(s.endTime)
                if s.kind == "Res" and high >= s.price and close < s.price
                    sc         = touchScore("Res", s.price)
                    s.strength += sc
                    s.touches  += 1
                    if alrtRetest
                        alert("RETEST " + syminfo.ticker + " R " +
                             str.tostring(s.price, format.mintick) +
                             " | Score +" + str.tostring(math.round(sc, 1)),
                             alert.freq_once_per_bar_close)
                else if s.kind == "Sup" and low <= s.price and close > s.price
                    sc         = touchScore("Sup", s.price)
                    s.strength += sc
                    s.touches  += 1
                    if alrtRetest
                        alert("RETEST " + syminfo.ticker + " S " +
                             str.tostring(s.price, format.mintick) +
                             " | Score +" + str.tostring(math.round(sc, 1)),
                             alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────
// STRENGTH LABEL — capped at ★8+
// ─────────────────────────────────────────────
strengthLabel(float sval) =>
    if sval >= 8.0
        "★8+"
    else
        _cap  = math.min(sval, 7.99)
        _wi   = int(math.floor(_cap))
        _wd   = int(math.round((_cap - _wi) * 10))
        _wd == 0 ? "★" + str.tostring(_wi) : "★" + str.tostring(_wi) + "." + str.tostring(_wd)

// ─────────────────────────────────────────────
// RENDER ONE LEVEL
// ─────────────────────────────────────────────
renderSR(SR s) =>
    deleteSR(s)
    baseC  = s.kind == "Sup" ? supCol : resCol
    alpha  = strengthVis ? strengthToAlpha(s.strength) : 55
    c      = color.new(baseC, alpha)
    solidC = color.new(baseC, 0)
    zW     = strengthToWidth(s.strength)
    _bc    = s.kind == "Sup" ? color.new(dashSupCol, 0) : color.new(dashResCol, 0)
    eTime  = na(s.endTime) ? time : s.endTime

    if showZone
        if zoneStyle == "Dashed"
            _dc   = s.kind == "Sup" ? dashSupCol : dashResCol
            s.bx := box.new(s.startTime, s.price + atr * zW, eTime, s.price - atr * zW,
                 xloc=xloc.bar_time, bgcolor=_dc, border_color=_bc, border_width=1,
                 border_style=line.style_dotted, extend=extend.none)
            s.ln := line.new(s.startTime, s.price, eTime, s.price,
                 xloc=xloc.bar_time, color=_bc, style=line.style_dashed, width=1)
        else if zoneStyle == "Line"
            s.bx := na
            s.ln := line.new(s.startTime, s.price, eTime, s.price,
                 xloc=xloc.bar_time, color=solidC, style=line.style_solid, width=lineWidth)
        else
            s.bx := box.new(s.startTime, s.price + atr * zW, eTime, s.price - atr * zW,
                 xloc=xloc.bar_time, bgcolor=c, border_color=na, border_width=0, extend=extend.none)
            s.ln := na
    else
        s.bx := na
        s.ln := na

    if showLbl and na(s.endTime)
        strTxt = strengthLabel(s.strength)
        tchTxt = str.tostring(s.touches)
        txt    = s.tfLabels + "\n" +
                 str.tostring(s.price, format.mintick) +
                 "  " + strTxt + "  ×" + tchTxt
        s.lb  := label.new(eTime, s.price, text=txt,
             xloc=xloc.bar_time, style=label.style_label_left,
             color=color.new(color.black, 100),
             textcolor=zoneStyle == "Dashed" ? _bc : solidC,
             size=lbSize)
    else
        s.lb := na

// ─────────────────────────────────────────────
// RENDER ALL — strength sorted, top N only
// ─────────────────────────────────────────────
renderAll() =>
    n = allLevels.size()
    if n > 0
        for i = 0 to n - 1
            s = allLevels.get(i)
            deleteSR(s)

        strengthArr = array.new<float>()
        for i = 0 to n - 1
            s = allLevels.get(i)
            if s.valid and s.strength >= minStrength
                strengthArr.push(s.strength)

        float threshold = 0.0
        if strengthArr.size() > 0
            strengthArr.sort(order.descending)
            cutIdx    = math.min(maxLvls - 1, strengthArr.size() - 1)
            threshold := strengthArr.get(cutIdx)

        rendered = 0
        for i = 0 to n - 1
            s = allLevels.get(i)
            bool doRender = false
            if s.valid and s.strength >= minStrength and s.strength >= threshold and rendered < maxLvls
                doRender := true
                rendered += 1
            else if not s.valid and showBroken
                doRender := true
            else
                doRender := false
            if doRender
                renderSR(s)

// ─────────────────────────────────────────────
// TF LABEL HELPER
// ─────────────────────────────────────────────
tfLabel(string tf) =>
    t    = tf == "" ? timeframe.period : tf
    secs = timeframe.in_seconds(t)
    result = ""
    if str.contains(t, "D") or str.contains(t, "W") or str.contains(t, "M")
        result := timeframe.from_seconds(secs)
    else if secs >= 3600
        result := str.tostring(int(secs / 3600)) + "H"
    else
        result := t + "m"
    result

// ─────────────────────────────────────────────
// PROCESS ONE TIMEFRAME
// ─────────────────────────────────────────────
processTF(string tf, bool enabled, float ph, float pl) =>
    if enabled and barstate.isconfirmed and not isBlockedSession()
        lbl = tfLabel(tf)
        if not na(ph)
            addOrMerge(ph, "Res", lbl)
        if not na(pl)
            addOrMerge(pl, "Sup", lbl)

// ─────────────────────────────────────────────
// MAIN EXECUTION
// ─────────────────────────────────────────────
processTF(tf1, tf1On, ph1, pl1)
processTF(tf2, tf2On, ph2, pl2)
processTF(tf3, tf3On, ph3, pl3)
processTF(tf4, tf4On, ph4, pl4)

if barstate.isconfirmed
    updateAll()

if barstate.islast
    renderAll()

// ─────────────────────────────────────────────
// ALERT CONDITIONS
// ─────────────────────────────────────────────
alertcondition(condition = true, title = "S&R Break or Retest",
     message = "NSE S&R event on {{ticker}}")
````
