# Time Channel [Aurabot]

- url: https://www.tradingview.com/script/gCU1k2H6-Time-Channel-Aurabot/
- type: indicator
- pine_id: PUB;ad46009c256a4754b5a7ba9cc8c37138
- version: 2.0

## Description

Time Channel fits a trend channel to any time window you choose, locks it, and projects it forward into your session. Then it watches the first break and tells you whether it held or was a fake-out.

WHAT IT SHOWS
- Resistance line fitted to the highs of your window, support line fitted to the lows
- Touch dots where wicks tagged the lines
- Both lines projected forward to a time you pick (default 12:00 New York)
- HOLDS label when a break stays beyond the line, FAKE BREAK label when it comes back inside
- Optional shading of common New York times (8:30, 9:00, 9:15, 9:30, 10:00, 10:30)
- Optional break zone: the first price gap after a break that held

HOW IT WORKS
- Analysis window: default 3:00 to 8:15 AM New York. Set any start and end, in any of the listed timezones.
- The lines are a least-squares fit through the highs and the lows, then refined toward the outer wicks so they sit on the edges of price the way you would draw them by hand, not through the middle.
- When the window closes, the channel freezes and is drawn all the way to the projection time at once. No bar-by-bar creep and no repainting after it is drawn.
- Break read: after the first close beyond a line, the script averages the closes of the next few minutes (default 10). Average still beyond the line = HOLDS, and the line takes the break colour. Average back inside = FAKE BREAK, and the line turns dashed.

HOW TO USE IT
- Inside the channel, the lines are areas where price has been turning.
- A break that HOLDS shows acceptance beyond the line. Many traders then wait for price to come back and retest the line before acting.
- A FAKE BREAK shows the move outside was rejected.
The script reads the break. It does not place trades or tell you to buy or sell.

SETTINGS
Analysis hours and timezone, edge refinement, touch tolerance, channel width and per-line nudges (in ATR), projection time or extend as a ray, optional breakout size filter (points or ATR), break read window, fake-out labels, pivotal times, break zone, line width and style.

ALERTS
Break Up, Break Down, Break HOLDS, FAKE break.

THEMES
Aurabot (default), Neon Cyber, Midnight Aura, Sunset Blaze, Ocean Depth, Ghost Protocol, Classic, Neon Violet, Plasma, Blade Runner, Toxic, Ghost Wire, Midnight Blue, Ember Gold, Stealth Dark, Clean Light (for white charts), or Custom.

NOTES
Built for intraday charts. A held or failed break describes what price did, not what it will do next. Past behavior does not guarantee future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AuraSznfx
// Aurabot Time Channel
// Fits a resistance line (highs) and a support line (lows) across a time window you choose, locks both and
// projects them forward. Marks the first real close beyond a line, then reads the next few candles to show
// whether the break held or was a fake-out.

//@version=6
indicator("Aurabot Time Channel", "Time Channel", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500, max_bars_back = 5000)

NONE_COLOR = #00000000

//─────────────────────────────────────────────────────────────────────────────
// ◈ Theme
//─────────────────────────────────────────────────────────────────────────────
_themeGrp = "◈ Theme"

theme_choice = input.string("Aurabot", "◈ Color Theme", group = _themeGrp, options = ["Aurabot", "Neon Cyber", "Midnight Aura", "Sunset Blaze", "Ocean Depth", "Ghost Protocol", "Classic", "Neon Violet", "Plasma", "Blade Runner", "Toxic", "Ghost Wire", "Midnight Blue", "Ember Gold", "Stealth Dark", "Clean Light", "Custom"], tooltip = "Resistance line uses Bearish, support line uses Bullish, projections use Accent.")
customBullColor = input.color(#00FFB2, '↳ Custom Bullish', group = _themeGrp)
customBearColor = input.color(#FF3366, '↳ Custom Bearish', group = _themeGrp)
customAccColor  = input.color(#00F5FF, '↳ Custom Accent', group = _themeGrp)

_nc_b = #00FFB2, _nc_r = #FF2D6A, _nc_a = #00F5FF
_ma_b = #6366F1, _ma_r = #F472B6, _ma_a = #EA80FC
_sb_b = #FBBF24, _sb_r = #EF4444, _sb_a = #FFD740
_od_b = #22D3EE, _od_r = #F97316, _od_a = #67E8F9
_gp_b = #A1A1AA, _gp_r = #52525B, _gp_a = #D4D4D8
_cl_b = #089981, _cl_r = #F23645, _cl_a = #FFFFFF
_nv_b = #B388FF, _nv_r = #FF4081, _nv_a = #EA80FC
_pl_b = #00FFF5, _pl_r = #FF006E, _pl_a = #76FF03
_br_b = #FFAB40, _br_r = #448AFF, _br_a = #FFD740
_tx_b = #76FF03, _tx_r = #D500F9, _tx_a = #C6FF00
_gw_b = #84FFFF, _gw_r = #FF8A80, _gw_a = #A7FFEB
_mb_b = #00B0FF, _mb_r = #FF6B6B, _mb_a = #448AFF
_eg_b = #FFD740, _eg_r = #FF6E40, _eg_a = #FFB300
_sd_b = #A5D6A7, _sd_r = #EF9A9A, _sd_a = #9E9E9E
_clt_b = #2E7D32, _clt_r = #C62828, _clt_a = #1565C0

bullColor = switch theme_choice
    'Aurabot'        => #00D9FF
    'Neon Cyber'     => _nc_b
    'Midnight Aura'  => _ma_b
    'Sunset Blaze'   => _sb_b
    'Ocean Depth'    => _od_b
    'Ghost Protocol' => _gp_b
    'Classic'        => _cl_b
    'Neon Violet'    => _nv_b
    'Plasma'         => _pl_b
    'Blade Runner'   => _br_b
    'Toxic'          => _tx_b
    'Ghost Wire'     => _gw_b
    'Midnight Blue'  => _mb_b
    'Ember Gold'     => _eg_b
    'Stealth Dark'   => _sd_b
    'Clean Light'    => _clt_b
    'Custom'         => customBullColor

bearColor = switch theme_choice
    'Aurabot'        => #FF427E
    'Neon Cyber'     => _nc_r
    'Midnight Aura'  => _ma_r
    'Sunset Blaze'   => _sb_r
    'Ocean Depth'    => _od_r
    'Ghost Protocol' => _gp_r
    'Classic'        => _cl_r
    'Neon Violet'    => _nv_r
    'Plasma'         => _pl_r
    'Blade Runner'   => _br_r
    'Toxic'          => _tx_r
    'Ghost Wire'     => _gw_r
    'Midnight Blue'  => _mb_r
    'Ember Gold'     => _eg_r
    'Stealth Dark'   => _sd_r
    'Clean Light'    => _clt_r
    'Custom'         => customBearColor

accColor = switch theme_choice
    'Aurabot'        => #FACC15
    'Neon Cyber'     => _nc_a
    'Midnight Aura'  => _ma_a
    'Sunset Blaze'   => _sb_a
    'Ocean Depth'    => _od_a
    'Ghost Protocol' => _gp_a
    'Classic'        => _cl_a
    'Neon Violet'    => _nv_a
    'Plasma'         => _pl_a
    'Blade Runner'   => _br_a
    'Toxic'          => _tx_a
    'Ghost Wire'     => _gw_a
    'Midnight Blue'  => _mb_a
    'Ember Gold'     => _eg_a
    'Stealth Dark'   => _sd_a
    'Clean Light'    => _clt_a
    'Custom'         => customAccColor

//─────────────────────────────────────────────────────────────────────────────
// ◈ Analysis Window
//─────────────────────────────────────────────────────────────────────────────
_awGrp = "◈ Analysis Window"
anlzSess = input.session("0300-0815", "◈ Analysis Hours", group = _awGrp, tooltip = "The bars used to fit the trendlines. Default 3:00 to 8:15 AM New York. The cutoff (right edge) is where the fit freezes — set it to 0900 for a 9 AM cutoff. Start anywhere (0100, 0300, 0500).")
winTZ    = input.string("America/New_York", "◈ Timezone", options = ["America/New_York", "America/Chicago", "America/Los_Angeles", "Europe/London", "Asia/Tokyo", "UTC"], group = _awGrp, tooltip = "Timezone for the analysis window AND the projection end.")
shadeAnlz = input.bool(true, "◈ Shade Analysis Window", group = _awGrp)
anlzTransp = input.int(94, "↳ Shade Transparency", minval = 80, maxval = 99, group = _awGrp)

//─────────────────────────────────────────────────────────────────────────────
// ◈ Trendline Fit
//─────────────────────────────────────────────────────────────────────────────
_fitGrp = "◈ Trendline Fit"
showRes    = input.bool(true, "◈ Resistance Line (highs)", group = _fitGrp)
showSup    = input.bool(true, "◈ Support Line (lows)", group = _fitGrp)
refinePass = input.int(2, "◈ Edge Refinement Passes", minval = 0, maxval = 5, group = _fitGrp, tooltip = "0 = raw least-squares through all wicks (sits in the middle). 1-5 = re-fit only on the bars nearest the outer edge each pass, pulling the line onto the outside wicks. 2 is a good clean default.")
touchTol   = input.float(0.25, "◈ Touch Tolerance (ATR)", minval = 0.02, maxval = 2.0, step = 0.02, group = _fitGrp, tooltip = "How close a wick must come to the line to count as a 'touch'. In ATR units.")
lineWidth  = input.int(2, "◈ Line Width", minval = 1, maxval = 5, group = _fitGrp)
lineStyle  = input.string("Solid", "◈ Line Style", options = ["Solid", "Dashed", "Dotted"], group = _fitGrp)
showTouches = input.bool(true, "◈ Mark Clean Touches", group = _fitGrp, tooltip = "Dots where wicks touched the fitted line.")
chanWidth   = input.float(0.0, "◈ Channel Width (ATR)", minval = -3.0, maxval = 5.0, step = 0.1, group = _fitGrp, tooltip = "Pushes BOTH lines out symmetrically without changing the fitted angle or anchor. Positive = wider (lines further from price), negative = tighter (closer to price). 0 = raw fit.")
resOffset   = input.float(0.0, "↳ Resistance Nudge (ATR)", minval = -3.0, maxval = 3.0, step = 0.1, group = _fitGrp, tooltip = "Fine independent shift of the resistance line only. Positive = up/further, negative = down/closer. Stacks on top of Channel Width.")
supOffset   = input.float(0.0, "↳ Support Nudge (ATR)", minval = -3.0, maxval = 3.0, step = 0.1, group = _fitGrp, tooltip = "Fine independent shift of the support line only. Positive = down/further, negative = up/closer.")

//─────────────────────────────────────────────────────────────────────────────
// ◈ Projection
//─────────────────────────────────────────────────────────────────────────────
_prjGrp = "◈ Projection"
projHr     = input.int(12, "◈ Project Until — Hour", minval = 0, maxval = 23, group = _prjGrp, tooltip = "The instant the fit completes at the analysis cutoff, both lines are drawn as a FULL channel all the way out to this time — no bar-by-bar creep. 12 = noon.")
projMin    = input.int(0, "↳ Project Until — Minute", minval = 0, maxval = 59, step = 5, group = _prjGrp)
extendRay  = input.bool(false, "◈ Extend As Ray", group = _prjGrp, tooltip = "ON = lines shoot to the right edge of the chart instead of stopping at the projection time.")
showBreak  = input.bool(true, "◈ Mark Breakout", group = _prjGrp, tooltip = "Flags the first close beyond a projected line after the analysis window closes — this is your directional bias.")
minBreakMode = input.string("Off", "◈ Breakout Size Filter", options = ["Points", "ATR", "Off"], group = _prjGrp, tooltip = "Requires the candle to CLOSE a real distance PAST the line — measured from the line to the close, not the candle's own size. An 80pt candle that barely closes through fails; a smaller candle that closes far past qualifies. Points = fixed distance. ATR = multiple of ATR. Off = any close beyond the line counts.")
minBreakPts  = input.float(60.0, "↳ Min Close Past Line (points)", minval = 0.0, step = 5.0, group = _prjGrp, tooltip = "How far past the line the candle must close. NQ example: 60–70. Only used in Points mode.")
minBreakATR  = input.float(1.5, "↳ Min Close Past Line (ATR)", minval = 0.1, maxval = 10.0, step = 0.1, group = _prjGrp, tooltip = "Close must be this × ATR beyond the line. Only used in ATR mode.")

f_lineStyle(_s) => _s == "Dashed" ? line.style_dashed : _s == "Dotted" ? line.style_dotted : line.style_solid

//─────────────────────────────────────────────────────────────────────────────
// State
//─────────────────────────────────────────────────────────────────────────────
float _atr = ta.atr(14)

bool _inAnlz  = not na(time(timeframe.period, anlzSess, winTZ))
bool _newDay  = ta.change(time("D")) != 0

// Minutes per bar, for projecting a fixed number of bars into the future
int _tfMins = math.max(1, timeframe.in_seconds() / 60)

// How many bars forward from the fit bar to reach the projection target time?
f_barsToTarget() =>
    int _nowMins = hour(time, winTZ) * 60 + minute(time, winTZ)
    int _tgtMins = projHr * 60 + projMin
    int _diff = _tgtMins - _nowMins
    // if target already passed today, project a small default forward span
    _diff <= 0 ? 20 : int(math.ceil(_diff / float(_tfMins)))

// Rolling storage of the current day's analysis-window bars
var array<float> _hi  = array.new_float()
var array<float> _lo  = array.new_float()
var array<int>   _bi  = array.new_int()
var int _anlzStartBar = na

// Fitted-line parameters (slope in price/bar, intercept at fit anchor bar)
var float _resSlope = na
var float _resB     = na
var float _supSlope = na
var float _supB     = na
var int   _fitAnchor = na
var bool  _fitted    = false

// Drawn objects
var line _resLine = na
var line _supLine = na
var label _resLbl = na
var label _supLbl = na

// Breakout state
var int _bias = 0   // 1 = broke up (through resistance), -1 = broke down, 0 = none
var label _brkLbl = na

// Shade the analysis window
bgcolor(shadeAnlz and _inAnlz ? color.new(accColor, anlzTransp) : na, title = "◈ Analysis Window")

//─────────────────────────────────────────────────────────────────────────────
// Collect analysis-window bars
//─────────────────────────────────────────────────────────────────────────────
// Reset the buffer when a fresh analysis window opens each day
if _inAnlz and not _inAnlz[1]
    array.clear(_hi)
    array.clear(_lo)
    array.clear(_bi)
    _anlzStartBar := bar_index
    _fitted := false
    _bias   := 0

if _inAnlz
    array.push(_hi, high)
    array.push(_lo, low)
    array.push(_bi, bar_index)

//─────────────────────────────────────────────────────────────────────────────
// Least-squares helpers
//─────────────────────────────────────────────────────────────────────────────
// Fit y = slope*x + b over selected indices (x measured as bar offset from anchor).
// mask[] tells which points to include. Returns [slope, b].
f_lsq(array<int> xs, array<float> ys, array<bool> mask, int anchor) =>
    float _n = 0.0
    float _sx = 0.0, float _sy = 0.0, float _sxx = 0.0, float _sxy = 0.0
    int _sz = array.size(xs)
    if _sz > 0
        for i = 0 to _sz - 1
            if array.get(mask, i)
                float x = array.get(xs, i) - anchor
                float y = array.get(ys, i)
                _n  += 1
                _sx += x
                _sy += y
                _sxx += x * x
                _sxy += x * y
    float _slope = na
    float _b = na
    float _denom = _n * _sxx - _sx * _sx
    if _n >= 2 and _denom != 0
        _slope := (_n * _sxy - _sx * _sy) / _denom
        _b     := (_sy - _slope * _sx) / _n
    else if _n >= 1
        _slope := 0.0
        _b     := _sy / _n
    [_slope, _b]

//─────────────────────────────────────────────────────────────────────────────
// Fit both lines when the analysis window closes
//─────────────────────────────────────────────────────────────────────────────
if _inAnlz[1] and not _inAnlz and array.size(_hi) >= 3 and not _fitted
    int _sz = array.size(_hi)
    _fitAnchor := array.get(_bi, 0)

    // ── Resistance (highs): start with all points, then keep only the ones at/above
    //    the current line (the outer upper wicks), re-fitting each pass.
    array<bool> _maskR = array.new<bool>(_sz, true)
    [_rs0, _rb0] = f_lsq(_bi, _hi, _maskR, _fitAnchor)
    float _rs = _rs0, float _rb = _rb0
    if refinePass > 0
        for _p = 1 to refinePass
            for i = 0 to _sz - 1
                float x = array.get(_bi, i) - _fitAnchor
                float yfit = _rs * x + _rb
                float y = array.get(_hi, i)
                // keep points near or above the line (upper edge)
                array.set(_maskR, i, y >= yfit - _atr * touchTol)
            [_rsN, _rbN] = f_lsq(_bi, _hi, _maskR, _fitAnchor)
            if not na(_rsN)
                _rs := _rsN
                _rb := _rbN
    _resSlope := _rs
    _resB     := _rb

    // ── Support (lows): keep points at/below the line (outer lower wicks)
    array<bool> _maskS = array.new<bool>(_sz, true)
    [_ss0, _sb0] = f_lsq(_bi, _lo, _maskS, _fitAnchor)
    float _ss = _ss0, float _sb = _sb0
    if refinePass > 0
        for _p = 1 to refinePass
            for i = 0 to _sz - 1
                float x = array.get(_bi, i) - _fitAnchor
                float yfit = _ss * x + _sb
                float y = array.get(_lo, i)
                array.set(_maskS, i, y <= yfit + _atr * touchTol)
            [_ssN, _sbN] = f_lsq(_bi, _lo, _maskS, _fitAnchor)
            if not na(_ssN)
                _ss := _ssN
                _sb := _sbN
    _supSlope := _ss
    _supB     := _sb

    _fitted := true

    // ── Draw the FULL channel immediately: from anchor out to the projection time ──
    int _x1 = _fitAnchor
    int _projBars = f_barsToTarget()
    int _x2 = extendRay ? bar_index : bar_index + _projBars
    float _ry1 = _resSlope * (_x1 - _fitAnchor) + _resB + _atr * (chanWidth + resOffset)
    float _ry2 = _resSlope * (_x2 - _fitAnchor) + _resB + _atr * (chanWidth + resOffset)
    float _sy1 = _supSlope * (_x1 - _fitAnchor) + _supB - _atr * (chanWidth + supOffset)
    float _sy2 = _supSlope * (_x2 - _fitAnchor) + _supB - _atr * (chanWidth + supOffset)

    if showRes
        _resLine := line.new(_x1, _ry1, _x2, _ry2, color = color.new(bearColor, 0), width = lineWidth, style = f_lineStyle(lineStyle), extend = extendRay ? extend.right : extend.none)
        _resLbl  := label.new(_x2, _ry2, "◈ RES", color = NONE_COLOR, textcolor = bearColor, style = label.style_label_left, size = size.small)
    if showSup
        _supLine := line.new(_x1, _sy1, _x2, _sy2, color = color.new(bullColor, 0), width = lineWidth, style = f_lineStyle(lineStyle), extend = extendRay ? extend.right : extend.none)
        _supLbl  := label.new(_x2, _sy2, "◈ SUP", color = NONE_COLOR, textcolor = bullColor, style = label.style_label_left, size = size.small)

    // ── Mark clean touches ──
    if showTouches
        for i = 0 to _sz - 1
            float x = array.get(_bi, i) - _fitAnchor
            if showRes
                float yfit = _resSlope * x + _resB
                if math.abs(array.get(_hi, i) - yfit) <= _atr * touchTol
                    label.new(array.get(_bi, i), array.get(_hi, i), "•", color = NONE_COLOR, textcolor = color.new(bearColor, 20), style = label.style_label_down, size = size.tiny)
            if showSup
                float yfit2 = _supSlope * x + _supB
                if math.abs(array.get(_lo, i) - yfit2) <= _atr * touchTol
                    label.new(array.get(_bi, i), array.get(_lo, i), "•", color = NONE_COLOR, textcolor = color.new(bullColor, 20), style = label.style_label_up, size = size.tiny)

//─────────────────────────────────────────────────────────────────────────────
// Line readers — apply width + per-line offset live, on top of the frozen fit.
// Resistance pushes UP (further) with positive width/nudge; support pushes DOWN.
//─────────────────────────────────────────────────────────────────────────────
f_resY(int _bx) => _resSlope * (_bx - _fitAnchor) + _resB + _atr * (chanWidth + resOffset)
f_supY(int _bx) => _supSlope * (_bx - _fitAnchor) + _supB - _atr * (chanWidth + supOffset)


//─────────────────────────────────────────────────────────────────────────────
// Keep the full channel live: re-apply width/offset to the FIXED endpoints so
// slider tweaks move instantly, but the right edge stays parked at the projection
// time — the channel is drawn out and waiting, not creeping bar-by-bar.
//─────────────────────────────────────────────────────────────────────────────
if _fitted and not na(_fitAnchor)
    if extendRay
        // ray mode: keep the right endpoint at the current bar so the ray anchors correctly
        int _x2 = bar_index
        if not na(_resLine)
            line.set_xy2(_resLine, _x2, f_resY(_x2))
        if not na(_supLine)
            line.set_xy2(_supLine, _x2, f_supY(_x2))
    else
        // fixed projection: leave x2 where it was drawn, just refresh y for live offset edits
        if not na(_resLine)
            int _rx2 = line.get_x2(_resLine)
            line.set_y1(_resLine, f_resY(line.get_x1(_resLine)))
            line.set_y2(_resLine, f_resY(_rx2))
            if not na(_resLbl)
                label.set_xy(_resLbl, _rx2, f_resY(_rx2))
        if not na(_supLine)
            int _sx2 = line.get_x2(_supLine)
            line.set_y1(_supLine, f_supY(line.get_x1(_supLine)))
            line.set_y2(_supLine, f_supY(_sx2))
            if not na(_supLbl)
                label.set_xy(_supLbl, _sx2, f_supY(_sx2))

//─────────────────────────────────────────────────────────────────────────────
// Breakout detection (after the analysis window, first close beyond a line)
//─────────────────────────────────────────────────────────────────────────────
if _fitted and _bias == 0 and not _inAnlz and barstate.isconfirmed
    float _resNow = f_resY(bar_index)
    float _supNow = f_supY(bar_index)

    // Breakout qualifier — how far PAST the line the candle closed (penetration)
    float _minSize = minBreakMode == "Points" ? minBreakPts : minBreakMode == "ATR" ? _atr * minBreakATR : 0.0
    float _resPen  = close - _resNow   // + when closed above resistance
    float _supPen  = _supNow - close   // + when closed below support
    bool  _resSizeOK = minBreakMode == "Off" or _resPen >= _minSize
    bool  _supSizeOK = minBreakMode == "Off" or _supPen >= _minSize

    if showRes and close > _resNow and _resSizeOK
        _bias := 1
        if showBreak
            _brkLbl := label.new(bar_index, high, "◈ BREAK ↑  +" + str.tostring(_resPen, format.mintick), color = NONE_COLOR, textcolor = bullColor, style = label.style_label_down, size = size.small)
    else if showSup and close < _supNow and _supSizeOK
        _bias := -1
        if showBreak
            _brkLbl := label.new(bar_index, low, "◈ BREAK ↓  +" + str.tostring(_supPen, format.mintick), color = NONE_COLOR, textcolor = bearColor, style = label.style_label_up, size = size.small)

//─────────────────────────────────────────────────────────────────────────────
// ◈ Alerts
//─────────────────────────────────────────────────────────────────────────────
float _resAlertY = _fitted ? f_resY(bar_index) : na
float _supAlertY = _fitted ? f_supY(bar_index) : na
float _alertMin  = minBreakMode == "Points" ? minBreakPts : minBreakMode == "ATR" ? _atr * minBreakATR : 0.0
bool  _resAlertOK = minBreakMode == "Off" or (close - _resAlertY) >= _alertMin
bool  _supAlertOK = minBreakMode == "Off" or (_supAlertY - close) >= _alertMin
alertcondition(_fitted and _bias == 0 and not _inAnlz and barstate.isconfirmed and _resAlertOK and _resAlertY < close, title = "◈ Break Up", message = "Time Channel: qualified break ABOVE resistance — long bias.")
alertcondition(_fitted and _bias == 0 and not _inAnlz and barstate.isconfirmed and _supAlertOK and _supAlertY > close, title = "◈ Break Down", message = "Time Channel: qualified break BELOW support — short bias.")
//─────────────────────────────────────────────────────────────────────────────

//─────────────────────────────────────────────────────────────────────────────
// ◈ Break Read: the line flips colour on the AVERAGE of the candles after the break
//   HOLDS = average close of the next few minutes stayed beyond the line → line turns the break colour.
//   FAKE  = average came back inside → line turns the accent colour, dashed, and a FAKE label prints.
//─────────────────────────────────────────────────────────────────────────────
_rdGrp = "◈ Break Read (flip + fake-out)"
flipOn   = input.bool(true, "◈ Flip line colour on the break read", group = _rdGrp, tooltip = "After the first close beyond a line, the script averages the closes of the next few minutes. Average still beyond the line → HOLDS (line turns the break colour). Average back inside → FAKE (line turns the accent colour and dashed, FAKE label).")
readMins = input.int(10, "↳ Read window (minutes after the break candle)", minval = 1, maxval = 60, group = _rdGrp, tooltip = "How many minutes after the break candle are averaged. Short reads (5 to 10 minutes) react fastest.")
showFake = input.bool(true, "◈ Mark fake-outs", group = _rdGrp, tooltip = "Prints a FAKE label when the average of the candles after the break comes back inside the line.")
showPiv  = input.bool(false, "◈ Pivotal times (8:30 · 9:00 · 9:15 · 9:30 · 10:00 · 10:30)", group = _rdGrp)
showBz   = input.bool(false, "◈ Break zone (first imbalance after a HOLDS break)", group = _rdGrp, tooltip = "Visual only. Boxes the first price gap in the break direction within 30 minutes of a break that held, and greys it out on the first touch.")
N_UP = bullColor
N_DN = bearColor
N_FAKE = accColor
N_PIV = accColor

int  _tm = hour(time, winTZ) * 60 + minute(time, winTZ)
bool _pivBar = _tm == 510 or _tm == 540 or _tm == 555 or _tm == 570 or _tm == 600 or _tm == 630
bgcolor(showPiv and _pivBar and timeframe.isintraday and timeframe.multiplier <= 15 ? color.new(N_PIV, 90) : na, title = "◈ Pivotal time")

var int   _rbDir = 0
var int   _rbBar = na
var float _rbSum = 0.0
var int   _rbN = 0
var int   _rbState = 0     // 0 waiting · 1 reading · 2 holds · 3 fake
var box   _bz = na
var bool  _bzLive = false
var bool  _bzDone = false
if _inAnlz and not _inAnlz[1]
    _rbDir := 0
    _rbState := 0
    _rbSum := 0.0
    _rbN := 0
    _bzLive := false
    _bzDone := false
int  _readBars = math.max(1, int(math.round(readMins / float(_tfMins))))
int  _projEnd = projHr * 60 + projMin
bool _heldNow = false
bool _fakeNow = false
if flipOn and _fitted and not _inAnlz and barstate.isconfirmed
    if _rbState == 0 and _tm < _projEnd
        float _r = f_resY(bar_index)
        float _s = f_supY(bar_index)
        if close > _r
            _rbDir := 1
            _rbBar := bar_index
            _rbState := 1
        else if close < _s
            _rbDir := -1
            _rbBar := bar_index
            _rbState := 1
    else if _rbState == 1 and bar_index > _rbBar
        _rbSum += close
        _rbN += 1
        if _rbN >= _readBars
            float _avg = _rbSum / _rbN
            float _lvl = _rbDir == 1 ? f_resY(bar_index) : f_supY(bar_index)
            bool  _held = _rbDir == 1 ? _avg > _lvl : _avg < _lvl
            line  _bl = _rbDir == 1 ? _resLine : _supLine
            line  _ol = _rbDir == 1 ? _supLine : _resLine
            color _dc = _rbDir == 1 ? N_UP : N_DN
            if _held
                _rbState := 2
                _heldNow := true
                if not na(_bl)
                    line.set_color(_bl, _dc)
                    line.set_width(_bl, lineWidth + 1)
                if not na(_ol)
                    line.set_color(_ol, color.new(_dc, 60))
                label.new(bar_index, _rbDir == 1 ? low : high, (_rbDir == 1 ? "◈ BREAK HOLDS ↑ " : "◈ BREAK HOLDS ↓ ") + str.tostring(math.abs(_avg - _lvl), format.mintick), color = NONE_COLOR, textcolor = _dc, style = _rbDir == 1 ? label.style_label_up : label.style_label_down, size = size.small, tooltip = "Average of the " + str.tostring(_rbN) + " candle(s) after the break stayed beyond the line: " + str.tostring(_avg, format.mintick) + " vs line " + str.tostring(_lvl, format.mintick))
            else
                _rbState := 3
                _fakeNow := true
                if not na(_bl)
                    line.set_color(_bl, N_FAKE)
                    line.set_style(_bl, line.style_dashed)
                if showFake
                    label.new(bar_index, _rbDir == 1 ? high : low, _rbDir == 1 ? "◈ FAKE BREAK ↑" : "◈ FAKE BREAK ↓", color = N_FAKE, textcolor = #05010A, style = _rbDir == 1 ? label.style_label_down : label.style_label_up, size = size.small, tooltip = "The break did not hold: the average close of the next " + str.tostring(_rbN) + " candle(s) came back inside the line (" + str.tostring(_avg, format.mintick) + " vs " + str.tostring(_lvl, format.mintick) + ").")

// Break zone: first imbalance in the break direction within 30 min of a HOLDS break; retired on first touch
int _bzWin = math.max(1, int(30 / _tfMins))
if barstate.isconfirmed
    if showBz and _rbState == 2 and not _bzDone and bar_index - _rbBar <= _bzWin
        if _rbDir == 1 and low > high[2]
            _bz := box.new(bar_index - 2, low, bar_index, high[2], border_color = color.new(N_UP, 40), bgcolor = color.new(N_UP, 86), text = "BREAK ZONE", text_color = color.new(N_UP, 30), text_size = size.tiny, text_halign = text.align_right)
            _bzLive := true
            _bzDone := true
        else if _rbDir == -1 and high < low[2]
            _bz := box.new(bar_index - 2, low[2], bar_index, high, border_color = color.new(N_DN, 40), bgcolor = color.new(N_DN, 86), text = "BREAK ZONE", text_color = color.new(N_DN, 30), text_size = size.tiny, text_halign = text.align_right)
            _bzLive := true
            _bzDone := true
    else if _bzLive and not na(_bz)
        float _zt = box.get_top(_bz)
        float _zb = box.get_bottom(_bz)
        box.set_right(_bz, bar_index)
        if (_rbDir == 1 and low <= _zt) or (_rbDir == -1 and high >= _zb)
            _bzLive := false
            box.set_bgcolor(_bz, color.new(color.gray, 92))
            box.set_border_color(_bz, color.new(color.gray, 70))
            box.set_text(_bz, "1st touch")
        else if _tm >= 960
            _bzLive := false

alertcondition(_heldNow, title = "◈ Break HOLDS", message = "Time Channel: break held on the average-of-candles read.")
alertcondition(_fakeNow, title = "◈ FAKE break", message = "Time Channel: break failed on the average-of-candles read — fake-out.")

// Data Window outputs: direction of the break (+1 up / -1 down) on the bar the break is read, 0 otherwise. Data Window only - nothing drawn.
plot(_heldNow ? _rbDir : 0, "Break held (direction)", display = display.data_window)
plot(_fakeNow ? _rbDir : 0, "Fake break (direction)", display = display.data_window)
````
