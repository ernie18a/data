# Auction Scalper | GainzAlgo

- url: https://www.tradingview.com/script/DYdYi1hl-Auction-Scalper-GainzAlgo/
- type: indicator
- pine_id: PUB;9fe6be44a9204207b64fa0a5a0839166
- version: 1.0

## Description

Auction Scalper is built specifically for intraday scalpers. It uses Auction Market Theory to identify two high-quality setups: failed auctions that reverse back toward value and accepted breaks that continue after a retest.

https://www.tradingview.com/x/p61GtSJK/

[b]THE TWO SETUPS[/b]

[b]Reversal — Failed Auction[/b]

Price pushes outside yesterday's value area, fails to hold there, and closes back inside. The setup targets a return toward value, with the POC as TP1 and the stop placed beyond the full sweep with an ATR buffer.

[b]Squeeze — Break & Retest[/b]

Price accepts outside value with a strong body close. The broken level is retested and must hold with sufficient participation before a continuation signal fires. Targets use meaningful prior-day levels, with a runner for extended moves.

[b]EVERY SETUP GETS A 0–100 SCORE[/b]

Every setup is scored using:

[list]
[*]Volume percentile
[*]Buy/sell pressure
[*]Rejection quality
[*]Trade location
[*]Higher-timeframe alignment
[*]Volatility
[*]Reward-to-risk
[*]Time of day
[/list]

Display the result as stars, a numerical score, or a letter grade.

Two additional rules come from testing: reversals against the higher-timeframe direction require a higher score, and setups requiring a stop wider than 4 ATR are skipped.

[b]KNOW WHY YOU'RE FLAT[/b]

The dashboard shows your current trading window and system status.

It tells you whether the market is OPEN, LATE, CLOSED or in lockout, and whether the system is SCANNING, waiting for a higher score because of CHOP, MANAGING A TRADE, or DONE FOR TODAY.

No guessing why the indicator isn't giving you a signal.

[b]BUILT FOR DISCIPLINED SCALPING[/b]

Includes:

[list]
[*]Session filter & opening lockout
[*]Late-entry cutoff
[*]Chop detection
[*]Signal cooldown
[*]One active trade at a time
[*]One long and one short setup per day
[*]TP1 → break-even management
[*]TP2 runner
[*]Maximum stop-distance filter
[*]Optional slippage-aware stops
[/list]

Every trade is tracked directly on the chart with Entry, SL, TP1, TP2 and R multiples, including stop-outs.

[b]VALIDATION[/b]

A companion strategy uses the same core logic so you can test it on your own market, timeframe, commission and slippage settings.

An earlier engine build tested on AAPL 5-minute data over one year produced a profit factor around 1.3 with drawdown near 2% using realistic costs. The engine has since been updated, so run the current strategy yourself for current results.

Settings were tuned on US stocks. Crypto and FX are supported but were not specifically calibrated.

[b]HOW TO USE[/b]

Designed for liquid markets on 1–5 minute charts during active sessions.

Choose a preset, set your session, and wait for qualified setups. Alerts fire once per confirmed bar close with direction, setup type, score, entry, stop and both targets.

[b]HONEST NOTES[/b]

Signals confirm on bar close and do not repaint. Higher-timeframe analysis uses only the last confirmed HTF bar.

Buy/sell pressure is estimated from candle structure, not exchange bid/ask data, and no lower-timeframe requests are required. The indicator therefore works across TradingView plans and in Bar Replay.

Some FX feeds have no usable volume, so the volume gate automatically steps aside when volume is unavailable.

This is an analytical tool, not financial advice. Past performance does not guarantee future results.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © GainzAlgo
//
//  ██████╗  █████╗ ██╗███╗   ██╗███████╗ █████╗ ██╗      ██████╗  ██████╗
// ██╔════╝ ██╔══██╗██║████╗  ██║╚══███╔╝██╔══██╗██║     ██╔════╝ ██╔═══██╗
// ██║  ███╗███████║██║██╔██╗ ██║  ███╔╝ ███████║██║     ██║  ███╗██║   ██║
// ██║   ██║██╔══██║██║██║╚██╗██║ ███╔╝  ██╔══██║██║     ██║   ██║██║   ██║
// ╚██████╔╝██║  ██║██║██║ ╚████║███████╗██║  ██║███████╗╚██████╔╝╚██████╔╝
//  ╚═════╝  ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝
//
//@version=6
indicator("Auction Scalper | GainzAlgo", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// ────────────────────────────── Constants ───────────────────────────────
PRESET_CON = "Conservative"
PRESET_BAL = "Balanced"
PRESET_AGG = "Aggressive"
PRESET_CUS = "Custom"
MODE_SIMPLE = "Simple"
MODE_ADV = "Advanced"
STOP_CLASSIC = "Classic (beyond swing)"
STOP_SAVER = "Slippage-saver (ticks inside swing)"
TH_CLASSIC = "Classic"
TH_NEON = "Neon"
TH_OCEAN = "Ocean"
TH_ROYAL = "Royal"
TH_CUSTOM = "Custom"
MK_DET = "Detailed labels"
MK_MIN = "Minimal arrows"
QD_STARS = "Stars ★ (simple)"
QD_SCORE = "Score /100"
QD_GRADE = "Grade (A+ … D)"
QD_OFF = "Off"

// ──────────────────────────────── Inputs ────────────────────────────────
grpMain = "⚙ Main"
preset = input.string(PRESET_BAL, "Preset", options = [PRESET_CON, PRESET_BAL, PRESET_AGG, PRESET_CUS], group = grpMain, tooltip = "Conservative = fewer, higher-grade signals. Aggressive = more signals, lower bar. Custom unlocks the two inputs below.", display = display.none)
minScoreIn = input.int(65, "Custom: min signal score (0–100)", minval = 40, maxval = 95, group = grpMain, display = display.none)
aggrPctIn = input.int(80, "Custom: min participation percentile", minval = 50, maxval = 99, group = grpMain, display = display.none)
dispMode = input.string(MODE_SIMPLE, "Dashboard depth", options = [MODE_SIMPLE, MODE_ADV], group = grpMain, tooltip = "Simple = clean signal card. Advanced = full data stack (delta, percentiles, HTF, session).", display = display.none)

grpLook = "✨ Look & feel"
theme = input.string(TH_CLASSIC, "Theme", options = [TH_CLASSIC, TH_NEON, TH_OCEAN, TH_ROYAL, TH_CUSTOM], group = grpLook, display = display.none)
markerStyle = input.string(MK_DET, "Signal markers", options = [MK_DET, MK_MIN], group = grpLook, tooltip = "Detailed labels print direction, grade and setup type at every signal. Minimal arrows keep the chart ultra-clean.", display = display.none)
qualDisp = input.string(QD_STARS, "Signal quality display", options = [QD_STARS, QD_SCORE, QD_GRADE, QD_OFF], group = grpLook, tooltip = "How setup quality is written on labels, dashboard and alerts. Stars: ★★★ strong · ★★ good · ★ fair. Behind the stars every setup is scored 0–100 across participation, rejection strength, location, HTF context, volatility, R:R and session quality.", display = display.none)
sigSizeIn = input.string("Normal", "Signal label size", options = ["Tiny", "Small", "Normal", "Large"], group = grpLook, display = display.none)
showDash = input.bool(true, "Show dashboard", group = grpLook, display = display.none)
dashPosIn = input.string("Top right", "Dashboard position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = grpLook, display = display.none)
dashSizeIn = input.string("Normal", "Dashboard text size", options = ["Tiny", "Small", "Normal", "Large"], group = grpLook, display = display.none)
showBg = input.bool(true, "Tint background by regime", group = grpLook, display = display.none)
showSessBg = input.bool(true, "Shade active session", group = grpLook, display = display.none)

grpVA = "◫ Value framework (previous-day profile)"
binsN = input.int(40, "Profile resolution (price bins)", minval = 20, maxval = 100, group = grpVA, display = display.none)
vaPct = input.float(70, "Value area %", minval = 50, maxval = 95, group = grpVA) / 100.0
showVA = input.bool(true, "Show VAH / POC / VAL + premium/discount shading", group = grpVA, display = display.none)
showPD = input.bool(true, "Show previous day high / low", group = grpVA, display = display.none)

grpSig = "◎ Signal engine"
reqAggr = input.bool(true, "Require participation gate", group = grpSig, tooltip = "ON: signals need volume in the top percentile band for this symbol (adaptive) with delta on your side. OFF: structure alone, quality expressed only through the score.", display = display.none)
bodyPct = input.float(0.6, "Acceptance: min body/range of breakout candle", minval = 0.3, maxval = 0.9, step = 0.05, group = grpSig, display = display.none)
maxFail = input.int(15, "Failed auction: max closes outside value", minval = 1, maxval = 50, group = grpSig, display = display.none)
retestWin = input.int(40, "Squeeze: retest window after breakout (bars)", minval = 5, maxval = 200, group = grpSig, display = display.none)
retestTol = input.float(0.25, "Squeeze: retest zone width (× ATR)", minval = 0.05, maxval = 2.0, step = 0.05, group = grpSig, display = display.none)
coolBars = input.int(10, "Cooldown between signals (bars)", minval = 0, maxval = 100, group = grpSig, display = display.none)
chopWin = input.int(30, "Chop detection window (bars)", minval = 10, maxval = 100, group = grpSig, display = display.none)
chopMin = input.int(5, "Chop: min value-edge whipsaws in window", minval = 3, maxval = 20, group = grpSig, tooltip = "This many crossings of VAH/VAL inside the window while in balance = CHOP regime: squeeze signals disabled, reversal score requirement +15.", display = display.none)
onePerDir       = input.bool(true, "Max one signal per direction per day", group = grpSig, tooltip = "Hard cap: one long and one short per session. Stops repeat entries in the same trend leg.", display = display.none)

grpHtf = "◔ Higher-timeframe context"
htfTf = input.timeframe("15", "HTF context timeframe", group = grpHtf, tooltip = "Score modifier only, never a hard filter. Uses the last CLOSED HTF bar vs its 20 EMA — non-repainting.", display = display.none)
ctrHtfPen = input.int(12, "Reversal penalty vs HTF bias (score pts)", minval = 0, maxval = 30, group = grpHtf, tooltip = "Backtest-validated: fading the higher-timeframe trend was the single biggest loss source. Counter-trend reversals must clear a higher score bar. 0 = off.", display = display.none)

grpSess = "◷ Session timing"
useSess = input.bool(true, "Only signal inside the session", group = grpSess, tooltip = "Turn OFF for 24/7 markets like crypto.", display = display.none)
sessStr = input.session("0930-1600", "Session (exchange hours)", group = grpSess, display = display.none)
sessTz = input.string("America/New_York", "Session timezone", group = grpSess, display = display.none)
skipMin = input.int(5, "Opening lockout: skip first minutes", minval = 0, maxval = 60, group = grpSess, display = display.none)
lastEntryMin = input.int(360, "No new signals after (minutes from open)", minval = 30, maxval = 1440, group = grpSess, tooltip = "Late-session setups have nowhere to travel before the close. 360 = 15:30 ET for a 09:30 open. The WINDOW row on the dashboard counts it down. Raise to 1440 to disable.", display = display.none)

grpRisk = "▤ Risk visualization"
showTrade = input.bool(true, "Draw position boxes for latest signal", group = grpRisk, display = display.none)
stopMode = input.string(STOP_CLASSIC, "Stop placement", options = [STOP_CLASSIC, STOP_SAVER], group = grpRisk, tooltip = "Slippage-saver parks the stop 1–2 ticks INSIDE the swing so you exit before the stop cascade accelerates through the level.", display = display.none)
stopTicks = input.int(2, "Slippage-saver: ticks inside swing", minval = 1, maxval = 20, group = grpRisk, display = display.none)
stopBuf = input.float(1.0, "Classic: ATR buffer beyond swing", minval = 0.0, maxval = 2.0, step = 0.05, group = grpRisk, display = display.none)
minStopAtr = input.float(1.5, "Classic: min stop distance (× ATR)", minval = 0.0, maxval = 5.0, step = 0.1, group = grpRisk, tooltip = "The stop is never placed closer than this to entry, so ordinary noise can't tag you out. Bigger = fewer stop-outs, but each stop that hits costs more and the same targets pay fewer R — keep risk equal by sizing positions to a fixed % per trade.", display = display.none)
maxStopAtr = input.float(4.0, "Max stop distance (× ATR), skip if wider", minval = 1.0, maxval = 10.0, step = 0.5, group = grpRisk, tooltip = "A stop wider than this is not a scalp — the trade is skipped. Backtest-validated: dropping wide-stop setups raised profit factor and cut drawdown.", display = display.none)
rrTarget = input.float(2.5, "Squeeze TP2 runner (R multiple)", minval = 1.0, maxval = 10.0, step = 0.5, group = grpRisk, display = display.none)
tp1R = input.float(1.2, "TP1 fallback distance (R multiple)", minval = 0.8, maxval = 3.0, step = 0.1, group = grpRisk, tooltip = "When POC / prior-day extreme is too close, TP1 falls back to this many R. Smaller = higher win rate, smaller first target.", display = display.none)

grpCol = "🎨 Custom theme colors"
colBull = input.color(#089981, "Bullish", group = grpCol, display = display.none)
colBear = input.color(#f23645, "Bearish", group = grpCol, display = display.none)
colAccC = input.color(#2962ff, "Accent / value area", group = grpCol, display = display.none)
colPocC = input.color(#ff9800, "POC", group = grpCol, display = display.none)

// ──────────────────────────────── Theme ─────────────────────────────────
effBull = theme == TH_CUSTOM ? colBull : theme == TH_NEON ? #00e676 : theme == TH_OCEAN ? #26a69a : theme == TH_ROYAL ? #7c4dff : #089981
effBear = theme == TH_CUSTOM ? colBear : theme == TH_NEON ? #ff1744 : theme == TH_OCEAN ? #ef5350 : theme == TH_ROYAL ? #ff6e40 : #f23645
effAcc  = theme == TH_CUSTOM ? colAccC : theme == TH_NEON ? #00e5ff : theme == TH_OCEAN ? #2962ff : theme == TH_ROYAL ? #b388ff : #2962ff
effPoc  = theme == TH_CUSTOM ? colPocC : theme == TH_NEON ? #ffea00 : theme == TH_OCEAN ? #ff9800 : theme == TH_ROYAL ? #ffd740 : #ff9800

// Preset thresholds
effMinScore = preset == PRESET_CON ? 75 : preset == PRESET_AGG ? 55 : preset == PRESET_CUS ? minScoreIn : 65
effAggrPct = preset == PRESET_CON ? 85 : preset == PRESET_AGG ? 70 : preset == PRESET_CUS ? aggrPctIn : 80

// Score weights
W_PART = 0.15
W_DOM  = 0.15
W_REJ  = 0.20
W_LOC  = 0.10
W_HTF  = 0.10
W_VOL  = 0.10
W_RR   = 0.10
W_SESS = 0.10

// ─────────────────────────────── Helpers ────────────────────────────────
f_size(_s) =>
    _s == "Tiny" ? size.tiny : _s == "Small" ? size.small : _s == "Large" ? size.large : size.normal

f_pos(_s) =>
    _s == "Top left" ? position.top_left : _s == "Bottom right" ? position.bottom_right : _s == "Bottom left" ? position.bottom_left : position.top_right

f_meter(_v, _n) =>
    string _s = ""
    int _fill = int(math.round(math.max(0.0, math.min(1.0, _v)) * _n))
    for _i = 1 to _n
        _s := _s + (_i <= _fill ? "▰" : "▱")
    _s

f_clamp(_x) =>
    math.max(0.0, math.min(100.0, _x))

f_grade(_s) =>
    _s >= 85 ? "A+" : _s >= 75 ? "A" : _s >= 65 ? "B" : _s >= 55 ? "C" : "D"

f_quality(_s) =>
    qualDisp == QD_STARS ? (_s >= 80 ? "★★★" : _s >= 65 ? "★★" : "★") : qualDisp == QD_SCORE ? str.tostring(_s, "#") + "/100" : qualDisp == QD_GRADE ? f_grade(_s) + " " + str.tostring(_s, "#") : ""

f_volScore(_rank) =>
    _rank < 25 ? f_clamp(_rank * 4) : _rank <= 90 ? 100.0 : f_clamp(100 - (_rank - 90) * 6)

// ───────────────────────────────── Core ─────────────────────────────────
atrV = ta.atr(14)
rng = math.max(high - low, syminfo.mintick)

buyV = rng > 0 ? volume * (close - low) / rng : volume * 0.5
sellV = rng > 0 ? volume * (high - close) / rng : volume * 0.5
barDelta = buyV - sellV
deltaRatio = volume > 0 ? barDelta / volume : 0.0
hasVol = not na(volume) and ta.highest(nz(volume, 0), 50) > 0

volRank = nz(ta.percentrank(volume, 200), 50)
atrRank = nz(ta.percentrank(atrV, 200), 50)

[htfCls, htfEma] = request.security(syminfo.tickerid, htfTf, [close[1], ta.ema(close, 20)[1]], lookahead = barmerge.lookahead_on)
htfBias = na(htfCls) or na(htfEma) ? 0 : htfCls > htfEma ? 1 : htfCls < htfEma ? -1 : 0

// ──────────────────────────── Value profile ─────────────────────────────
var hiA = array.new<float>()
var loA = array.new<float>()
var voA = array.new<float>()

var float prevVah = na
var float prevVal = na
var float prevPoc = na
var float prevDayHi = na
var float prevDayLo = na

var line vahL = na
var line valL = na
var line pocL = na
var line pocGlow = na
var line pdhL = na
var line pdlL = na
var box vaBoxUp = na
var box vaBoxDn = na
var label vahLab = na
var label valLab = na
var label pocLab = na

newDay = timeframe.change("D")

f_profile(_hi, _lo, _vo, _bins, _vaP) =>
    float _poc = na
    float _vah = na
    float _val = na
    int _n = array.size(_vo)
    if _n > 0
        _dHi = array.max(_hi)
        _dLo = array.min(_lo)
        if _dHi > _dLo
            _bs = (_dHi - _dLo) / _bins
            _volB = array.new<float>(_bins, 0.0)
            for _i = 0 to _n - 1
                _bh = array.get(_hi, _i)
                _bl = array.get(_lo, _i)
                _bv = array.get(_vo, _i)
                _i1 = math.max(0, math.min(_bins - 1, int(math.floor((_bl - _dLo) / _bs))))
                _i2 = math.max(0, math.min(_bins - 1, int(math.floor((_bh - _dLo) / _bs))))
                _per = _bv / (_i2 - _i1 + 1)
                for _b = _i1 to _i2
                    array.set(_volB, _b, array.get(_volB, _b) + _per)
            int _pIdx = 0
            for _b = 1 to _bins - 1
                if array.get(_volB, _b) > array.get(_volB, _pIdx)
                    _pIdx := _b
            _total = array.sum(_volB)
            _acc = array.get(_volB, _pIdx)
            int _up = _pIdx + 1
            int _dn = _pIdx - 1
            while _acc < _total * _vaP and (_up < _bins or _dn >= 0)
                _uV = _up < _bins ? array.get(_volB, _up) : -1.0
                _dV = _dn >= 0 ? array.get(_volB, _dn) : -1.0
                if _uV >= _dV
                    _acc := _acc + _uV
                    _up := _up + 1
                else
                    _acc := _acc + _dV
                    _dn := _dn - 1
            _vah := _dLo + _up * _bs
            _val := _dLo + (_dn + 1) * _bs
            _poc := _dLo + (_pIdx + 0.5) * _bs
    [_poc, _vah, _val]

if timeframe.isintraday
    if newDay and array.size(voA) > 0
        [p_, vh_, vl_] = f_profile(hiA, loA, voA, binsN, vaPct)
        prevPoc := p_
        prevVah := vh_
        prevVal := vl_
        prevDayHi := array.max(hiA)
        prevDayLo := array.min(loA)
        array.clear(hiA)
        array.clear(loA)
        array.clear(voA)
        if not na(vahLab)
            label.delete(vahLab)
        if not na(valLab)
            label.delete(valLab)
        if not na(pocLab)
            label.delete(pocLab)
        if showVA and not na(vh_)
            vahL := line.new(bar_index, vh_, bar_index, vh_, color = color.new(effAcc, 25), width = 1)
            valL := line.new(bar_index, vl_, bar_index, vl_, color = color.new(effAcc, 25), width = 1)
            pocGlow := line.new(bar_index, p_, bar_index, p_, color = color.new(effPoc, 85), width = 5)
            pocL := line.new(bar_index, p_, bar_index, p_, color = effPoc, width = 2)
            vaBoxUp := box.new(bar_index, vh_, bar_index, p_, bgcolor = color.new(effBear, 96), border_color = na)
            vaBoxDn := box.new(bar_index, p_, bar_index, vl_, bgcolor = color.new(effBull, 96), border_color = na)
            vahLab := label.new(bar_index + 3, vh_, "VAH " + str.tostring(vh_, format.mintick), style = label.style_none, textcolor = color.new(effAcc, 15), size = size.small)
            valLab := label.new(bar_index + 3, vl_, "VAL " + str.tostring(vl_, format.mintick), style = label.style_none, textcolor = color.new(effAcc, 15), size = size.small)
            pocLab := label.new(bar_index + 3, p_, "POC " + str.tostring(p_, format.mintick), style = label.style_none, textcolor = effPoc, size = size.small)
        if showPD and not na(prevDayHi)
            pdhL := line.new(bar_index, prevDayHi, bar_index, prevDayHi, color = color.new(color.gray, 30), style = line.style_dashed)
            pdlL := line.new(bar_index, prevDayLo, bar_index, prevDayLo, color = color.new(color.gray, 30), style = line.style_dashed)
    array.push(hiA, high)
    array.push(loA, low)
    array.push(voA, volume)
    if not na(vahL)
        line.set_x2(vahL, bar_index)
    if not na(valL)
        line.set_x2(valL, bar_index)
    if not na(pocL)
        line.set_x2(pocL, bar_index)
    if not na(pocGlow)
        line.set_x2(pocGlow, bar_index)
    if not na(vaBoxUp)
        box.set_right(vaBoxUp, bar_index)
    if not na(vaBoxDn)
        box.set_right(vaBoxDn, bar_index)
    if not na(pdhL)
        line.set_x2(pdhL, bar_index)
    if not na(pdlL)
        line.set_x2(pdlL, bar_index)
    if not na(vahLab)
        label.set_x(vahLab, bar_index + 3)
    if not na(valLab)
        label.set_x(valLab, bar_index + 3)
    if not na(pocLab)
        label.set_x(pocLab, bar_index + 3)

haveVA = not na(prevVah) and not na(prevVal) and not na(prevPoc)

// ─────────────────────────────── Session ────────────────────────────────
sessRaw = not na(time(timeframe.period, sessStr, sessTz))
inSess = not useSess or sessRaw
var int sessOpenT = na
if useSess and sessRaw and (bar_index == 0 or not sessRaw[1] or newDay)
    sessOpenT := time
minsOpen = not useSess ? -1.0 : na(sessOpenT) ? -1.0 : (time - sessOpenT) / 60000.0
lockout = useSess and (na(sessOpenT) ? true : minsOpen < skipMin)
entryWindowOK = not useSess or (minsOpen >= 0 and minsOpen <= lastEntryMin)

f_sessScore() =>
    not useSess ? 60.0 : minsOpen < 0 ? 40.0 : minsOpen <= 120 ? 100.0 : minsOpen <= 240 ? 70.0 : 45.0

// ──────────────────────────── Market regime ─────────────────────────────
fullBody = math.abs(close - open) >= bodyPct * rng

var int state = 0
var float breakLvl = na
var int breakBar = -1
var int retestUntil = -1
var bool armUp = false
var bool armDn = false
var int outLo = 0
var int outHi = 0
var float pokeLo = na
var float pokeHi = na

var int trdDir = 0
var float trdEntry = na
var float trdSL = na
var float trdTP1 = na
var float trdTP2 = na
var int trdStage = 0
var int trdStartBar = -1
var bool longUsed = false
var bool shortUsed = false

if newDay
    state := 0
    armUp := false
    armDn := false
    outLo := 0
    outHi := 0
    longUsed := false
    shortUsed := false

breakUpEvt = false
breakDnEvt = false
if haveVA
    if state != 1 and close > prevVah and close > open and fullBody
        breakUpEvt := true
        state := 1
        breakLvl := prevVah
        breakBar := bar_index
        armUp := true
        armDn := false
        retestUntil := bar_index + retestWin
    else if state != -1 and close < prevVal and close < open and fullBody
        breakDnEvt := true
        state := -1
        breakLvl := prevVal
        breakBar := bar_index
        armDn := true
        armUp := false
        retestUntil := bar_index + retestWin
    else if state == 1 and close < prevVah - retestTol * atrV
        state := 0
        armUp := false
    else if state == -1 and close > prevVal + retestTol * atrV
        state := 0
        armDn := false
    if bar_index > retestUntil
        armUp := false
        armDn := false

// Failed-auction counters — snapshot before update
prevOutLo = outLo
prevOutHi = outHi
if haveVA
    if close < prevVal
        outLo := outLo + 1
        pokeLo := outLo == 1 ? low : math.min(pokeLo, low)
    else
        outLo := 0
    if close > prevVah
        outHi := outHi + 1
        pokeHi := outHi == 1 ? high : math.max(pokeHi, high)
    else
        outHi := 0

// ──────────────────────────────── Regime ────────────────────────────────
edgeCross = haveVA and bar_index > 0 and (math.sign(close - prevVah) != math.sign(close[1] - prevVah) or math.sign(close - prevVal) != math.sign(close[1] - prevVal))
chopCount = math.sum(edgeCross ? 1 : 0, chopWin)
isChop = state == 0 and chopCount >= chopMin
noTradeCond = not timeframe.isintraday or not haveVA or not inSess or lockout
regime = noTradeCond ? 3 : isChop ? 2 : state

// ──────────────────────────────── Setups ────────────────────────────────
xUpVal = haveVA and not newDay and close > prevVal and nz(close[1], close) <= nz(prevVal[1], prevVal)
xDnVah = haveVA and not newDay and close < prevVah and nz(close[1], close) >= nz(prevVah[1], prevVah)
springLo = haveVA and not newDay and low < prevVal and close > prevVal and prevOutLo == 0
springHi = haveVA and not newDay and high > prevVah and close < prevVah and prevOutHi == 0

structRevL = springLo or (xUpVal and prevOutLo >= 1 and prevOutLo <= maxFail)
structRevS = springHi or (xDnVah and prevOutHi >= 1 and prevOutHi <= maxFail)
structSqzL = state == 1 and armUp and bar_index > breakBar and low <= breakLvl + retestTol * atrV and close > breakLvl
structSqzS = state == -1 and armDn and bar_index > breakBar and high >= breakLvl - retestTol * atrV and close < breakLvl

// Adaptive participation gate
gateL = close > open and (not reqAggr or not hasVol or (volRank >= effAggrPct and deltaRatio > 0.02))
gateS = close < open and (not reqAggr or not hasVol or (volRank >= effAggrPct and deltaRatio < -0.02))

var int lastSig = -100000
trdOpen = trdDir != 0 and trdStage >= 0 and trdStage < 2
canSignal = timeframe.isintraday and barstate.isconfirmed and haveVA and inSess and not lockout and entryWindowOK and not trdOpen and bar_index - lastSig > coolBars

// ────────────────────────── Signal evaluation ───────────────────────────
buySig = false
sellSig = false
firedRevL = false
firedSqzL = false
firedRevS = false
firedSqzS = false

var line entL = na
var line slLn = na
var line tp1Ln = na
var line tp2Ln = na
var box riskB = na
var box rew1B = na
var box rew2B = na
var label entLab = na
var label slLab = na
var label tp1Lab = na
var label tp2Lab = na
var string lsHead = "—"
var string lsEntry = "—"
var string lsSL = "—"
var string lsTP = "—"

// LONG candidate
if canSignal and gateL and not (onePerDir and longUsed) and (structRevL or (structSqzL and not isChop))
    bool isRev = structRevL
    float entry = close
    float swing = isRev ? math.min(nz(pokeLo, low), low) : math.min(low, nz(low[1], low))
    float sl = stopMode == STOP_SAVER ? swing + stopTicks * syminfo.mintick : swing - stopBuf * atrV
    if sl >= entry
        sl := swing - stopBuf * atrV
    if sl >= entry
        sl := entry - atrV
    if stopMode == STOP_CLASSIC and entry - sl < minStopAtr * atrV
        sl := entry - minStopAtr * atrV
    float risk = entry - sl
    float tp1 = na
    float tp2 = na
    if isRev
        tp1 := prevPoc > entry + 0.2 * risk ? prevPoc : entry + tp1R * risk
        tp2 := prevVah > tp1 + 0.2 * risk ? prevVah : tp1 + risk
    else
        tp1 := not na(prevDayHi) and prevDayHi > entry + 0.5 * risk ? prevDayHi : entry + tp1R * risk
        tp2 := entry + rrTarget * risk
        if tp2 <= tp1
            tp2 := tp1 + risk * 0.5
    float cPart = volRank
    float cDom = f_clamp(50 + deltaRatio * 250)
    float closePos = (close - low) / rng * 100
    float cRej = na
    float cLoc = na
    if isRev
        float sweep = (prevVal - swing) / atrV
        cRej := f_clamp(0.65 * closePos + 0.35 * f_clamp(20 + sweep * 60))
        cLoc := f_clamp(100 - (close - prevVal) / atrV * 35)
    else
        float prec = 1.0 - math.min(1.0, math.abs(low - breakLvl) / math.max(retestTol * atrV, syminfo.mintick))
        cRej := f_clamp(0.5 * closePos + 0.5 * prec * 100)
        cLoc := f_clamp(100 - math.abs(close - breakLvl) / atrV * 35)
    float cHtf = htfBias > 0 ? 100 : htfBias == 0 ? 55 : 15
    float cVol = f_volScore(atrRank)
    float rr1 = risk > 0 ? (tp1 - entry) / risk : 0.0
    float cRR = f_clamp(rr1 * 40)
    float cSess = f_sessScore()
    float total = W_PART * cPart + W_DOM * cDom + W_REJ * cRej + W_LOC * cLoc + W_HTF * cHtf + W_VOL * cVol + W_RR * cRR + W_SESS * cSess
    float needed = effMinScore + (isChop ? 15 : 0) + ((isRev and htfBias < 0) ? ctrHtfPen : 0)
    if total >= needed and risk <= maxStopAtr * atrV
        buySig := true
        longUsed := true
        firedRevL := isRev
        firedSqzL := not isRev
        lastSig := bar_index
        if not isRev
            armUp := false
        string qTxt = f_quality(total)
        string typeTxt = isRev ? "Reversal" : "Squeeze"
        lsHead := "BUY · " + typeTxt + (qTxt == "" ? "" : " · " + qTxt)
        lsEntry := str.tostring(entry, format.mintick)
        lsSL := str.tostring(sl, format.mintick)
        lsTP := str.tostring(tp1, format.mintick) + " · " + str.tostring(tp2, format.mintick)
        alert("Auction Scalper BUY · " + typeTxt + " · quality " + str.tostring(total, "#") + "/100 · Entry " + lsEntry + " · SL " + lsSL + " · TP1/TP2 " + lsTP, alert.freq_once_per_bar_close)
        if markerStyle == MK_DET
            label.new(bar_index, sl - 0.35 * atrV, "▲ LONG" + (qTxt == "" ? "" : " · " + qTxt) + "\n" + typeTxt, style = label.style_label_up, color = color.new(effBull, 12), textcolor = color.white, size = f_size(sigSizeIn), text_formatting = text.format_bold)
        trdDir := 1
        trdEntry := entry
        trdSL := sl
        trdTP1 := tp1
        trdTP2 := tp2
        trdStage := 0
        trdStartBar := bar_index
        if showTrade
            if not na(entL)
                line.delete(entL)
            if not na(slLn)
                line.delete(slLn)
            if not na(tp1Ln)
                line.delete(tp1Ln)
            if not na(tp2Ln)
                line.delete(tp2Ln)
            if not na(riskB)
                box.delete(riskB)
            if not na(rew1B)
                box.delete(rew1B)
            if not na(rew2B)
                box.delete(rew2B)
            if not na(entLab)
                label.delete(entLab)
            if not na(slLab)
                label.delete(slLab)
            if not na(tp1Lab)
                label.delete(tp1Lab)
            if not na(tp2Lab)
                label.delete(tp2Lab)
            entL := line.new(bar_index, entry, bar_index + 1, entry, color = color.new(color.gray, 15), style = line.style_dotted, width = 1)
            slLn := line.new(bar_index, sl, bar_index + 1, sl, color = effBear, width = 2)
            tp1Ln := line.new(bar_index, tp1, bar_index + 1, tp1, color = effBull, width = 2)
            tp2Ln := line.new(bar_index, tp2, bar_index + 1, tp2, color = color.new(effBull, 40), width = 2)
            riskB := box.new(bar_index, entry, bar_index + 1, sl, bgcolor = color.new(effBear, 88), border_color = color.new(effBear, 65))
            rew1B := box.new(bar_index, tp1, bar_index + 1, entry, bgcolor = color.new(effBull, 89), border_color = color.new(effBull, 65))
            rew2B := box.new(bar_index, tp2, bar_index + 1, tp1, bgcolor = color.new(effBull, 94), border_color = color.new(effBull, 78))
            entLab := label.new(bar_index + 2, entry, "E  " + lsEntry, style = label.style_label_left, color = color.new(color.gray, 55), textcolor = color.white, size = size.tiny)
            slLab := label.new(bar_index + 2, sl, "SL  " + lsSL + " · −1R", style = label.style_label_left, color = color.new(effBear, 35), textcolor = color.white, size = size.tiny)
            tp1Lab := label.new(bar_index + 2, tp1, "TP1  " + str.tostring(tp1, format.mintick) + " · +" + str.tostring(rr1, "#.#") + "R", style = label.style_label_left, color = color.new(effBull, 35), textcolor = color.white, size = size.tiny)
            tp2Lab := label.new(bar_index + 2, tp2, "TP2  " + str.tostring(tp2, format.mintick) + " · +" + str.tostring((tp2 - entry) / risk, "#.#") + "R", style = label.style_label_left, color = color.new(effBull, 55), textcolor = color.white, size = size.tiny)

// SHORT candidate
if canSignal and gateS and not (onePerDir and shortUsed) and (structRevS or (structSqzS and not isChop))
    bool isRev = structRevS
    float entry = close
    float swing = isRev ? math.max(nz(pokeHi, high), high) : math.max(high, nz(high[1], high))
    float sl = stopMode == STOP_SAVER ? swing - stopTicks * syminfo.mintick : swing + stopBuf * atrV
    if sl <= entry
        sl := swing + stopBuf * atrV
    if sl <= entry
        sl := entry + atrV
    if stopMode == STOP_CLASSIC and sl - entry < minStopAtr * atrV
        sl := entry + minStopAtr * atrV
    float risk = sl - entry
    float tp1 = na
    float tp2 = na
    if isRev
        tp1 := prevPoc < entry - 0.2 * risk ? prevPoc : entry - tp1R * risk
        tp2 := prevVal < tp1 - 0.2 * risk ? prevVal : tp1 - risk
    else
        tp1 := not na(prevDayLo) and prevDayLo < entry - 0.5 * risk ? prevDayLo : entry - tp1R * risk
        tp2 := entry - rrTarget * risk
        if tp2 >= tp1
            tp2 := tp1 - risk * 0.5
    float cPart = volRank
    float cDom = f_clamp(50 - deltaRatio * 250)
    float closePos = (high - close) / rng * 100
    float cRej = na
    float cLoc = na
    if isRev
        float sweep = (swing - prevVah) / atrV
        cRej := f_clamp(0.65 * closePos + 0.35 * f_clamp(20 + sweep * 60))
        cLoc := f_clamp(100 - (prevVah - close) / atrV * 35)
    else
        float prec = 1.0 - math.min(1.0, math.abs(high - breakLvl) / math.max(retestTol * atrV, syminfo.mintick))
        cRej := f_clamp(0.5 * closePos + 0.5 * prec * 100)
        cLoc := f_clamp(100 - math.abs(close - breakLvl) / atrV * 35)
    float cHtf = htfBias < 0 ? 100 : htfBias == 0 ? 55 : 15
    float cVol = f_volScore(atrRank)
    float rr1 = risk > 0 ? (entry - tp1) / risk : 0.0
    float cRR = f_clamp(rr1 * 40)
    float cSess = f_sessScore()
    float total = W_PART * cPart + W_DOM * cDom + W_REJ * cRej + W_LOC * cLoc + W_HTF * cHtf + W_VOL * cVol + W_RR * cRR + W_SESS * cSess
    float needed = effMinScore + (isChop ? 15 : 0) + ((isRev and htfBias > 0) ? ctrHtfPen : 0)
    if total >= needed and risk <= maxStopAtr * atrV
        sellSig := true
        shortUsed := true
        firedRevS := isRev
        firedSqzS := not isRev
        lastSig := bar_index
        if not isRev
            armDn := false
        string qTxt = f_quality(total)
        string typeTxt = isRev ? "Reversal" : "Squeeze"
        lsHead := "SELL · " + typeTxt + (qTxt == "" ? "" : " · " + qTxt)
        lsEntry := str.tostring(entry, format.mintick)
        lsSL := str.tostring(sl, format.mintick)
        lsTP := str.tostring(tp1, format.mintick) + " · " + str.tostring(tp2, format.mintick)
        alert("Auction Scalper SELL · " + typeTxt + " · quality " + str.tostring(total, "#") + "/100 · Entry " + lsEntry + " · SL " + lsSL + " · TP1/TP2 " + lsTP, alert.freq_once_per_bar_close)
        if markerStyle == MK_DET
            label.new(bar_index, sl + 0.35 * atrV, "▼ SHORT" + (qTxt == "" ? "" : " · " + qTxt) + "\n" + typeTxt, style = label.style_label_down, color = color.new(effBear, 12), textcolor = color.white, size = f_size(sigSizeIn), text_formatting = text.format_bold)
        trdDir := -1
        trdEntry := entry
        trdSL := sl
        trdTP1 := tp1
        trdTP2 := tp2
        trdStage := 0
        trdStartBar := bar_index
        if showTrade
            if not na(entL)
                line.delete(entL)
            if not na(slLn)
                line.delete(slLn)
            if not na(tp1Ln)
                line.delete(tp1Ln)
            if not na(tp2Ln)
                line.delete(tp2Ln)
            if not na(riskB)
                box.delete(riskB)
            if not na(rew1B)
                box.delete(rew1B)
            if not na(rew2B)
                box.delete(rew2B)
            if not na(entLab)
                label.delete(entLab)
            if not na(slLab)
                label.delete(slLab)
            if not na(tp1Lab)
                label.delete(tp1Lab)
            if not na(tp2Lab)
                label.delete(tp2Lab)
            entL := line.new(bar_index, entry, bar_index + 1, entry, color = color.new(color.gray, 15), style = line.style_dotted, width = 1)
            slLn := line.new(bar_index, sl, bar_index + 1, sl, color = effBear, width = 2)
            tp1Ln := line.new(bar_index, tp1, bar_index + 1, tp1, color = effBull, width = 2)
            tp2Ln := line.new(bar_index, tp2, bar_index + 1, tp2, color = color.new(effBull, 40), width = 2)
            riskB := box.new(bar_index, sl, bar_index + 1, entry, bgcolor = color.new(effBear, 88), border_color = color.new(effBear, 65))
            rew1B := box.new(bar_index, entry, bar_index + 1, tp1, bgcolor = color.new(effBull, 89), border_color = color.new(effBull, 65))
            rew2B := box.new(bar_index, tp1, bar_index + 1, tp2, bgcolor = color.new(effBull, 94), border_color = color.new(effBull, 78))
            entLab := label.new(bar_index + 2, entry, "E  " + lsEntry, style = label.style_label_left, color = color.new(color.gray, 55), textcolor = color.white, size = size.tiny)
            slLab := label.new(bar_index + 2, sl, "SL  " + lsSL + " · −1R", style = label.style_label_left, color = color.new(effBear, 35), textcolor = color.white, size = size.tiny)
            tp1Lab := label.new(bar_index + 2, tp1, "TP1  " + str.tostring(tp1, format.mintick) + " · +" + str.tostring(rr1, "#.#") + "R", style = label.style_label_left, color = color.new(effBull, 35), textcolor = color.white, size = size.tiny)
            tp2Lab := label.new(bar_index + 2, tp2, "TP2  " + str.tostring(tp2, format.mintick) + " · +" + str.tostring((entry - tp2) / risk, "#.#") + "R", style = label.style_label_left, color = color.new(effBull, 55), textcolor = color.white, size = size.tiny)

// ──────────────────────────── Trade tracking ────────────────────────────
if trdDir != 0 and trdStage >= 0 and trdStage < 2
    if not na(riskB)
        box.set_right(riskB, bar_index + 1)
        box.set_right(rew1B, bar_index + 1)
        box.set_right(rew2B, bar_index + 1)
        line.set_x2(entL, bar_index + 1)
        line.set_x2(slLn, bar_index + 1)
        line.set_x2(tp1Ln, bar_index + 1)
        line.set_x2(tp2Ln, bar_index + 1)
        label.set_x(entLab, bar_index + 2)
        label.set_x(slLab, bar_index + 2)
        label.set_x(tp1Lab, bar_index + 2)
        label.set_x(tp2Lab, bar_index + 2)
    if barstate.isconfirmed and bar_index > trdStartBar
        if trdDir == 1
            if low <= trdSL
                trdStage := -1
                lastSig := bar_index
                label.new(bar_index, trdSL, "✕", style = label.style_none, textcolor = effBear, size = size.normal, text_formatting = text.format_bold)
                if not na(slLab)
                    label.set_text(slLab, "✕ SL  " + str.tostring(trdSL, format.mintick))
                    label.set_textcolor(slLab, color.white)
                    label.set_color(slLab, color.new(effBear, 0))
            else
                if trdStage == 0 and high >= trdTP1
                    trdStage := 1
                    label.new(bar_index, trdTP1, "✓", style = label.style_none, textcolor = effBull, size = size.normal, text_formatting = text.format_bold)
                    if not na(tp1Lab)
                        label.set_text(tp1Lab, "✓ TP1  " + str.tostring(trdTP1, format.mintick) + " · +" + str.tostring((trdTP1 - trdEntry) / (trdEntry - trdSL), "#.#") + "R")
                        label.set_textcolor(tp1Lab, color.white)
                        label.set_color(tp1Lab, color.new(effBull, 0))
                if trdStage == 1 and high >= trdTP2
                    trdStage := 2
                    lastSig := bar_index
                    label.new(bar_index, trdTP2, "✓", style = label.style_none, textcolor = effBull, size = size.normal, text_formatting = text.format_bold)
                    if not na(tp2Lab)
                        label.set_text(tp2Lab, "✓ TP2  " + str.tostring(trdTP2, format.mintick) + " · +" + str.tostring((trdTP2 - trdEntry) / (trdEntry - trdSL), "#.#") + "R")
                        label.set_textcolor(tp2Lab, color.white)
                        label.set_color(tp2Lab, color.new(effBull, 0))
        else
            if high >= trdSL
                trdStage := -1
                lastSig := bar_index
                label.new(bar_index, trdSL, "✕", style = label.style_none, textcolor = effBear, size = size.normal, text_formatting = text.format_bold)
                if not na(slLab)
                    label.set_text(slLab, "✕ SL  " + str.tostring(trdSL, format.mintick))
                    label.set_textcolor(slLab, color.white)
                    label.set_color(slLab, color.new(effBear, 0))
            else
                if trdStage == 0 and low <= trdTP1
                    trdStage := 1
                    label.new(bar_index, trdTP1, "✓", style = label.style_none, textcolor = effBull, size = size.normal, text_formatting = text.format_bold)
                    if not na(tp1Lab)
                        label.set_text(tp1Lab, "✓ TP1  " + str.tostring(trdTP1, format.mintick) + " · +" + str.tostring((trdEntry - trdTP1) / (trdSL - trdEntry), "#.#") + "R")
                        label.set_textcolor(tp1Lab, color.white)
                        label.set_color(tp1Lab, color.new(effBull, 0))
                if trdStage == 1 and low <= trdTP2
                    trdStage := 2
                    lastSig := bar_index
                    label.new(bar_index, trdTP2, "✓", style = label.style_none, textcolor = effBull, size = size.normal, text_formatting = text.format_bold)
                    if not na(tp2Lab)
                        label.set_text(tp2Lab, "✓ TP2  " + str.tostring(trdTP2, format.mintick) + " · +" + str.tostring((trdEntry - trdTP2) / (trdSL - trdEntry), "#.#") + "R")
                        label.set_textcolor(tp2Lab, color.white)
                        label.set_color(tp2Lab, color.new(effBull, 0))

// ─────────────────────────────── Visuals ────────────────────────────────
plotshape(buySig and markerStyle == MK_MIN, "BUY", shape.triangleup, location.belowbar, effBull, size = size.small, text = "BUY", textcolor = effBull)
plotshape(sellSig and markerStyle == MK_MIN, "SELL", shape.triangledown, location.abovebar, effBear, size = size.small, text = "SELL", textcolor = effBear)
bgcolor(showBg ? (regime == 1 ? color.new(effBull, 95) : regime == -1 ? color.new(effBear, 95) : regime == 2 ? color.new(color.orange, 94) : na) : na, title = "Regime tint")
bgcolor(showSessBg and useSess and sessRaw ? (lockout ? color.new(color.orange, 95) : color.new(effAcc, 97)) : na, title = "Session shading")

// ────────────────────────────── Dashboard ───────────────────────────────
advMode = dispMode == MODE_ADV
dashTxt = f_size(dashSizeIn)
pressFill = (deltaRatio + 0.3) / 0.6
pressCol = deltaRatio >= 0.05 ? effBull : deltaRatio <= -0.05 ? effBear : color.new(color.gray, 0)
pressTxt = deltaRatio >= 0.15 and volRank >= 70 ? "STRONG BUY" : deltaRatio >= 0.05 ? "BUYERS" : deltaRatio <= -0.15 and volRank >= 70 ? "STRONG SELL" : deltaRatio <= -0.05 ? "SELLERS" : "NEUTRAL"

if showDash and barstate.islast
    var table dash = table.new(f_pos(dashPosIn), 2, 16, bgcolor = color.new(color.gray, 89), frame_color = color.new(color.gray, 55), frame_width = 1, border_color = color.new(color.gray, 82), border_width = 1)
    regTxt = regime == 3 ? "● NO TRADE" : regime == 2 ? "● CHOP" : regime == 1 ? "● BULL EXPANSION" : regime == -1 ? "● BEAR EXPANSION" : "● BALANCE"
    regCol = regime == 3 ? color.new(color.gray, 20) : regime == 2 ? color.orange : regime == 1 ? effBull : regime == -1 ? effBear : color.new(color.gray, 0)
    trdTxt = trdDir == 0 ? "—" : (trdDir == 1 ? "LONG · " : "SHORT · ") + (trdStage == -1 ? "stopped ✕" : trdStage == 0 ? "running…" : trdStage == 1 ? "TP1 hit ✓" : "TP2 done ✓")
    trdCol = trdDir == 0 ? color.new(color.gray, 20) : trdStage == -1 ? effBear : effBull
    table.cell(dash, 0, 0, "◆ AUCTION SCALPER", text_color = color.white, text_size = dashTxt, bgcolor = color.new(effAcc, 25), text_formatting = text.format_bold)
    table.cell(dash, 1, 0, "GainzAlgo", text_color = color.white, text_size = dashTxt, bgcolor = color.new(effAcc, 25), text_font_family = font.family_monospace, text_formatting = text.format_bold)
    table.cell(dash, 0, 1, "Regime", text_color = color.new(color.gray, 15), text_size = dashTxt)
    table.cell(dash, 1, 1, regTxt, text_color = regCol, text_size = dashTxt, text_font_family = font.family_monospace, text_formatting = text.format_bold)
    string winTxt = not useSess ? "24/7 · ALWAYS ON" : not sessRaw ? "CLOSED" : lockout ? "OPENING LOCKOUT" : minsOpen > lastEntryMin ? "LATE · NO NEW ENTRIES" : "OPEN ▸ " + str.tostring(math.max(0, lastEntryMin - minsOpen), "#") + "m LEFT"
    color winCol = not useSess ? color.new(color.gray, 0) : not sessRaw ? color.new(color.gray, 35) : lockout or minsOpen > lastEntryMin ? color.orange : effBull
    string stTxt = trdDir != 0 and trdStage == 0 ? "● MANAGING TRADE" : trdDir != 0 and trdStage == 1 ? "● RUNNER TO TP2" : not inSess ? "○ WAITING FOR SESSION" : lockout ? "○ WAITING · LOCKOUT" : useSess and minsOpen > lastEntryMin ? "○ DONE FOR TODAY" : isChop ? "◐ CHOP · BAR RAISED" : "◎ SCANNING · NEED " + str.tostring(effMinScore + (isChop ? 15 : 0), "#") + "+"
    color stCol = trdDir != 0 and trdStage >= 0 ? effBull : isChop ? color.orange : color.new(color.gray, 5)
    table.cell(dash, 0, 2, "Window", text_color = color.new(color.gray, 15), text_size = dashTxt)
    table.cell(dash, 1, 2, winTxt, text_color = winCol, text_size = dashTxt, text_font_family = font.family_monospace, text_formatting = text.format_bold)
    table.cell(dash, 0, 3, "Status", text_color = color.new(color.gray, 15), text_size = dashTxt)
    table.cell(dash, 1, 3, stTxt, text_color = stCol, text_size = dashTxt, text_font_family = font.family_monospace, text_formatting = text.format_bold)
    table.cell(dash, 0, 4, "Pressure", text_color = color.new(color.gray, 15), text_size = dashTxt)
    table.cell(dash, 1, 4, f_meter(pressFill, 8) + "  " + pressTxt, text_color = pressCol, text_size = dashTxt, text_font_family = font.family_monospace)
    table.cell(dash, 0, 5, "Participation", text_color = color.new(color.gray, 15), text_size = dashTxt)
    table.cell(dash, 1, 5, f_meter(volRank / 100, 8) + "  " + str.tostring(volRank, "#") + "%", text_color = volRank >= effAggrPct ? effPoc : color.new(color.gray, 0), text_size = dashTxt, text_font_family = font.family_monospace)
    table.cell(dash, 0, 6, "Last signal", text_color = color.new(color.gray, 15), text_size = dashTxt)
    table.cell(dash, 1, 6, lsHead, text_color = color.new(color.gray, 0), text_size = dashTxt, text_font_family = font.family_monospace)
    table.cell(dash, 0, 7, "Entry", text_color = color.new(color.gray, 15), text_size = dashTxt)
    table.cell(dash, 1, 7, lsEntry, text_color = color.new(color.gray, 0), text_size = dashTxt, text_font_family = font.family_monospace)
    table.cell(dash, 0, 8, "Stop", text_color = color.new(color.gray, 15), text_size = dashTxt)
    table.cell(dash, 1, 8, lsSL, text_color = effBear, text_size = dashTxt, text_font_family = font.family_monospace)
    table.cell(dash, 0, 9, "TP1 · TP2", text_color = color.new(color.gray, 15), text_size = dashTxt)
    table.cell(dash, 1, 9, lsTP, text_color = effBull, text_size = dashTxt, text_font_family = font.family_monospace)
    table.cell(dash, 0, 10, "Trade", text_color = color.new(color.gray, 15), text_size = dashTxt)
    table.cell(dash, 1, 10, trdTxt, text_color = trdCol, text_size = dashTxt, text_font_family = font.family_monospace, text_formatting = text.format_bold)
    if advMode
        table.cell(dash, 0, 11, "Bar delta", text_color = color.new(color.gray, 15), text_size = dashTxt)
        table.cell(dash, 1, 11, str.tostring(barDelta, format.volume), text_color = pressCol, text_size = dashTxt, text_font_family = font.family_monospace)
        table.cell(dash, 0, 12, "Dominance", text_color = color.new(color.gray, 15), text_size = dashTxt)
        table.cell(dash, 1, 12, (deltaRatio >= 0 ? "Buyers " : "Sellers ") + str.tostring(math.abs(deltaRatio) * 100, "#") + "%", text_color = pressCol, text_size = dashTxt, text_font_family = font.family_monospace)
        table.cell(dash, 0, 13, "ATR %ile", text_color = color.new(color.gray, 15), text_size = dashTxt)
        table.cell(dash, 1, 13, str.tostring(atrRank, "#"), text_color = color.new(color.gray, 0), text_size = dashTxt, text_font_family = font.family_monospace)
        table.cell(dash, 0, 14, "HTF (" + htfTf + ")", text_color = color.new(color.gray, 15), text_size = dashTxt)
        table.cell(dash, 1, 14, htfBias > 0 ? "Bullish ▲" : htfBias < 0 ? "Bearish ▼" : "Flat —", text_color = htfBias > 0 ? effBull : htfBias < 0 ? effBear : color.new(color.gray, 0), text_size = dashTxt, text_font_family = font.family_monospace)
        table.cell(dash, 0, 15, "Session", text_color = color.new(color.gray, 15), text_size = dashTxt)
        table.cell(dash, 1, 15, not useSess ? "OFF (24/7)" : sessRaw ? (lockout ? "OPEN LOCKOUT" : "ACTIVE") : "CLOSED", text_color = color.new(color.gray, 0), text_size = dashTxt, text_font_family = font.family_monospace)

if barstate.islast and not timeframe.isintraday
    var label warnLab = label.new(bar_index, close, "Auction Scalper needs an intraday chart — 1 to 5 minutes is ideal.", style = label.style_label_left, color = color.new(effBear, 15), textcolor = color.white, size = size.normal)
    label.set_xy(warnLab, bar_index, close)

// ──────────────────────────────── Alerts ────────────────────────────────
alertcondition(firedRevL, "Reversal BUY", "Sweep below value reclaimed — reversal long toward POC")
alertcondition(firedRevS, "Reversal SELL", "Sweep above value rejected — reversal short toward POC")
alertcondition(firedSqzL, "Squeeze BUY", "Breakout retest held with participation — continuation long")
alertcondition(firedSqzS, "Squeeze SELL", "Breakdown retest held with participation — continuation short")
alertcondition(breakUpEvt, "Balance → Imbalance UP", "Full-body acceptance above the value area")
alertcondition(breakDnEvt, "Balance → Imbalance DOWN", "Full-body acceptance below the value area")
````
