# RTH Session VWAP

- url: https://www.tradingview.com/script/baqDrdPW-RTH-Session-VWAP/
- type: indicator
- pine_id: PUB;085aa3b4809b4aac90be4846da7b3e32
- version: 3.0

## Description

[b]RTH Session VWAP[/b]

[i]Timezone-correct session VWAPs (NY RTH, London, Asia) + a 24h VWAP with StdDev bands. Sessions anchor to their own market timezone, so they plot right from anywhere.[/i]

Session VWAPs for New York, London, and Asia, plus a continuous 24-hour/daily VWAP, with optional standard-deviation bands — built for intraday futures trading from any timezone.
The core problem this solves: most session-VWAP scripts read their session times in the chart's exchange timezone, so the boundaries drift or break when you view the chart from a different timezone. Here each session is computed in its own explicit market timezone (America/New_York, Europe/London, Asia/Tokyo), so the sessions anchor correctly no matter where you are or how your chart timezone is set. Daylight saving is handled automatically.
Features

New York VWAP defaults to the regular cash session (09:30–16:00 ET), anchored to the RTH open.
London and Asia session VWAPs, each in its own timezone, off by default.
An always-on 24h VWAP anchored to the trading day, drawn independently of the sessions.
Optional ±1 / ±2 standard-deviation bands for every VWAP.
Independent show toggles per session, plus a master switch.
Configurable session hours, timezones, StdDev multipliers, and VWAP source.
Clean chart legend — input arguments and helper plots are kept out of the status line.

How to use

Add to chart. By default you'll see the New York RTH VWAP (green) and the 24h VWAP (amber). Enable the London/Asia sessions or the StdDev bands under Inputs. Session hours are entered in each session's own market timezone (e.g. NY 0930-1600). VWAP and its deviation bands act as intraday mean/value references — price returning to VWAP, or rejecting a ±1/±2 band, are common contexts traders watch.


Credit

This is an open-source modification of "Koalafied VWAP Session/Day" (Session VWAP) by TJ_667, published under the Mozilla Public License 2.0. All original credit goes to TJ_667. This version adds explicit per-session timezones, an RTH default, a 24h VWAP, per-session toggles, and a Pine v6 migration.

Source and notes: https://github.com/raoulsson/trading-view-script-rth-session-wvap

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TJ_667  |  Modifications © 2026 raoulsson
//
// ============================================================================
//  RTH Session VWAP - changes vs the original "Koalafied VWAP Session/Day"
// ============================================================================
//  Timezones
//    - Each session (Asia, Europe, NY) computes in an explicit market timezone
//      via time(period, session, tz), so it plots correctly no matter what
//      timezone the chart is set to. Daylight saving is handled automatically.
//    - NY defaults to the RTH cash session 0930-1600 New York time.
//  Session inputs (one block per session)
//    - A "Zone & preset hours" dropdown sets BOTH the timezone and the default
//      hours, e.g. "America/New York (0930-1600, default)". Displayed with
//      spaces; f_tz restores the IANA underscores time() requires. Only real
//      IANA zone names work (Germany is Europe/Berlin, not Europe/Frankfurt).
//    - A per-session "Use custom hours" checkbox + Custom hours field override
//      the dropdown hours when enabled (read in the same dropdown timezone).
//  Plots / display
//    - Always-on Daily (24h) VWAP anchored to the trading-day (Globex) boundary.
//    - Per-session VWAP toggles, per-session labels, per-session + Daily std-dev
//      band toggles. VWAP source applies to all VWAPs (sessions + Daily).
//    - Colored last-value price-axis tags removed; status line kept clean.
//    - Color presets: Asia yellow, Europe cyan, NY green, Daily amber.
//  Pine v6
//    - time() int-or-na results wrapped to real booleans (v6 dropped implicit
//      int/float -> bool casting); the daily reset uses an explicit bool.
// ============================================================================

//@version=6
indicator('RTH Session VWAP', 'RTH Session VWAP', true)

// ---------- Functions ---------- //

computeVWAP(src, isNewPeriod) =>
	var float sumSrcVol = na
	var float sumVol = na
	var float sumSrcSrcVol = na

	sumSrcVol := isNewPeriod ? src * volume : src * volume + sumSrcVol[1]
	sumVol := isNewPeriod ? volume : volume + sumVol[1]
	sumSrcSrcVol := isNewPeriod ? volume * math.pow(src, 2) : volume * math.pow(src, 2) + sumSrcSrcVol[1]

	_vwap = sumSrcVol / sumVol
	variance = sumSrcSrcVol / sumVol - math.pow(_vwap, 2)
	variance := variance < 0 ? 0 : variance
	stDev = math.sqrt(variance)

	[_vwap, stDev]

compute_stDEV(_vwap, stDev, stDevMultiplier_1, stDevMultiplier_2) =>
    upperBand_2 = _vwap + stDev * stDevMultiplier_2
    upperBand_1 = _vwap + stDev * stDevMultiplier_1
    lowerBand_1 = _vwap - stDev * stDevMultiplier_1
    lowerBand_2 = _vwap - stDev * stDevMultiplier_2
    [upperBand_2, upperBand_1, lowerBand_1, lowerBand_2]

f_drawLabel(_x, _y, _text, _textcolor, _style, _size) =>
    var _label = label.new(x=_x, y=_y, text=_text, textcolor=_textcolor, style=_style, size=_size, xloc=xloc.bar_time)
    label.set_xy(_label, _x, _y)

// Parse a session dropdown value of the form 'IANA/Zone (HHMM-HHMM[, default])'. Display uses spaces
// for readability (e.g. 'America/New York'); f_tz restores the IANA underscores that time() requires.
f_tz(_sel)    => str.replace_all(str.substring(_sel, 0, str.pos(_sel, ' (')), ' ', '_') // zone before ' (', spaces->underscores
f_hours(_sel) => str.substring(_sel, str.pos(_sel, '(') + 1, str.pos(_sel, '(') + 10)   // the HHMM-HHMM after '('

//-------------------- Inputs --------------------//

showDaily = input(true, 'Show Daily VWAP', group = 'Display', display = display.none)
showAsia = input(false, 'Show Asia VWAP', group = 'Display', display = display.none)
showLondon = input(false, 'Show Europe VWAP', group = 'Display', display = display.none)
showNY = input(true, 'Show NY VWAP', group = 'Display', display = display.none)
showD_label      = input(false, 'Show Daily Label',  group = 'Display', display = display.none)
showAsia_label   = input(false, 'Show Asia Label',   group = 'Display', display = display.none)
showLondon_label = input(false, 'Show Europe Label', group = 'Display', display = display.none)
showNY_label     = input(false, 'Show NY Label',     group = 'Display', display = display.none)

showStd_A  = input(false, 'Show Asia Std Dev Bands',   group = 'Display', display = display.none)
showStd_L  = input(false, 'Show Europe Std Dev Bands', group = 'Display', display = display.none)
showStd_NY = input(false, 'Show NY Std Dev Bands',     group = 'Display', display = display.none)
showStd_D  = input(false, 'Show Daily Std Dev Bands',  group = 'Display', display = display.none)

// Sessions declared before Calculation so they sort above it. Each session is ONE block: a zone+hours
// dropdown, a "Use custom hours" checkbox, and a Custom hours field applied only when that checkbox is
// on (read in the dropdown timezone). Pine cannot grey out the field, so it always shows. The dropdown
// value is 'IANA/Zone (HHMM-HHMM[, default])': f_tz takes the zone, f_hours the hours.

selAsia       = input.string('Asia/Tokyo (0900-1500, default)', 'Zone & preset hours', options = ['Asia/Tokyo (0900-1500, default)', 'Asia/Hong Kong (0930-1600)', 'Asia/Shanghai (0930-1500)', 'Asia/Singapore (0900-1700)', 'Asia/Seoul (0900-1530)', 'Asia/Kolkata (0915-1530)', 'Asia/Dubai (1000-1500)', 'Australia/Sydney (1000-1600)'], group = 'Asia Session', tooltip = 'Sets the Asia session timezone and default hours. DST handled automatically.', display = display.none)
useCustomAsia = input.bool(false, 'Use custom hours (overrides selection above)', group = 'Asia Session', display = display.none)
customAsia    = input.session('0900-1500', 'Custom hours', group = 'Asia Session', tooltip = 'Applied only when "Use custom hours" is on. Read in the Asia dropdown timezone.', display = display.none)

selLondon       = input.string('Europe/London (0800-1630, default)', 'Zone & preset hours', options = ['Europe/London (0800-1630, default)', 'Europe/Berlin (0900-1730)', 'Europe/Zurich (0900-1730)', 'Europe/Paris (0900-1730)', 'Europe/Moscow (1000-1840)'], group = 'Europe Session', tooltip = 'Sets the Europe session timezone and default hours. DST handled automatically.', display = display.none)
useCustomLondon = input.bool(false, 'Use custom hours (overrides selection above)', group = 'Europe Session', display = display.none)
customLondon    = input.session('0800-1630', 'Custom hours', group = 'Europe Session', tooltip = 'Applied only when "Use custom hours" is on. Read in the Europe dropdown timezone.', display = display.none)

selNY        = input.string('America/New York (0930-1600, default)', 'Zone & preset hours', options = ['America/New York (0930-1600, default)', 'America/Chicago (0830-1500)', 'America/Denver (0730-1400)', 'America/Los Angeles (0630-1300)', 'America/Toronto (0930-1600)', 'America/Sao Paulo (1000-1700)'], group = 'NY Session', tooltip = 'Sets the NY session timezone and default hours. DST handled automatically.', display = display.none)
useCustomNY  = input.bool(false, 'Use custom hours (overrides selection above)', group = 'NY Session', display = display.none)
customNY     = input.session('0930-1600', 'Custom hours', group = 'NY Session', tooltip = 'Applied only when "Use custom hours" is on. Read in the NY dropdown timezone.', display = display.none)

tzAsia   = f_tz(selAsia)
tzLondon = f_tz(selLondon)
tzNY     = f_tz(selNY)

Asia_session_full   = useCustomAsia   ? customAsia   : f_hours(selAsia)
London_session_full = useCustomLondon ? customLondon : f_hours(selLondon)
NY_session_full     = useCustomNY     ? customNY     : f_hours(selNY)

stDevMultiplier_1 = input(1.0, "StDev mult 1", group = 'Calculation', display = display.none)
stDevMultiplier_2 = input(2.0, "StDev mult 2", group = 'Calculation', display = display.none)
src = input(hlc3, "VWAP Source", group = 'Calculation', display = display.none)
off_mult = input(10, 'Label offset', group = 'Calculation', display = display.none)

var DEFAULT_LABEL_SIZE = size.small
var DEFAULT_LABEL_STYLE = label.style_none
ll_offset = timenow + math.round(ta.change(time) * off_mult)

// Raw session times (int or na)
tAsia   = time(timeframe.period, Asia_session_full   + ':1234567', tzAsia)
tLondon = time(timeframe.period, London_session_full + ':1234567', tzLondon)
tNY     = time(timeframe.period, NY_session_full     + ':1234567', tzNY)

// v6: derive real booleans. inX = currently in session. newX = first bar of the session (reset point).
inAsia   = not na(tAsia)
inLondon = not na(tLondon)
inNY     = not na(tNY)

newAsia   = inAsia   and na(tAsia[1])
newLondon = inLondon and na(tLondon[1])
newNY     = inNY     and na(tNY[1])

//-------------------- VWAP Calculations --------------------//

// Asia
p_Asia = src * volume
p_Asia := newAsia ? src * volume : p_Asia[1] + src * volume

vol_Asia = 0.0
vol_Asia := newAsia ? volume : vol_Asia[1] + volume

v_Asia = p_Asia / vol_Asia
mv_Asia = v_Asia
A_vwap = mv_Asia

Sn_Asia = 0.0
Sn_Asia := newAsia ? 0 : Sn_Asia[1] + volume * (src - v_Asia[1]) * (src - mv_Asia)
std_Asia = math.sqrt(Sn_Asia / vol_Asia)

// London
p_London = src * volume
p_London := newLondon ? src * volume : p_London[1] + src * volume

vol_London = 0.0
vol_London := newLondon ? volume : vol_London[1] + volume

v_London = p_London / vol_London
mv_London = v_London
L_vwap = mv_London

Sn_London = 0.0
Sn_London := newLondon ? 0 : Sn_London[1] + volume * (src - v_London[1]) * (src - mv_London)
std_London = math.sqrt(Sn_London / vol_London)

// NY
p_NY = src * volume
p_NY := newNY ? src * volume : p_NY[1] + src * volume

vol_NY = 0.0
vol_NY := newNY ? volume : vol_NY[1] + volume

v_NY = p_NY / vol_NY
mv_NY = v_NY
NY_vwap = mv_NY

Sn_NY = 0.0
Sn_NY := newNY ? 0 : Sn_NY[1] + volume * (src - v_NY[1]) * (src - mv_NY)
std_NY = math.sqrt(Sn_NY / vol_NY)

// Plot VWAP
A = plot(showAsia and inAsia ? A_vwap : na, title='Asia VWAP', color=color.new(color.yellow, 0), linewidth=2, style=plot.style_linebr, display = display.all - display.status_line - display.price_scale)
f_drawLabel(ll_offset, showAsia_label and showAsia and inAsia ? A_vwap : na, '     --- vAsia   ', color.yellow, DEFAULT_LABEL_STYLE, DEFAULT_LABEL_SIZE)

L = plot(showLondon and inLondon ? L_vwap : na, title='Europe VWAP', color=color.new(color.aqua, 0), linewidth=2, style=plot.style_linebr, display = display.all - display.status_line - display.price_scale)
f_drawLabel(ll_offset, showLondon_label and showLondon and inLondon ? L_vwap : na, '     --- vEurope   ', color.aqua, DEFAULT_LABEL_STYLE, DEFAULT_LABEL_SIZE)

N = plot(showNY and inNY ? NY_vwap : na, title='New York VWAP', color=color.new(#5eff3b, 0), linewidth=2, style=plot.style_linebr, display = display.all - display.status_line - display.price_scale)
f_drawLabel(ll_offset, showNY_label and showNY and inNY ? NY_vwap : na, '     --- vNY   ', #5eff3b, DEFAULT_LABEL_STYLE, DEFAULT_LABEL_SIZE)

//-------------------- Plot Standard Deviation Bands --------------------//

[s2up_A, s1up_A, s1dn_A, s2dn_A] = compute_stDEV(A_vwap, std_Asia, stDevMultiplier_1, stDevMultiplier_2)
[s2up_L, s1up_L, s1dn_L, s2dn_L] = compute_stDEV(L_vwap, std_London, stDevMultiplier_1, stDevMultiplier_2)
[s2up_NY, s1up_NY, s1dn_NY, s2dn_NY] = compute_stDEV(NY_vwap, std_NY, stDevMultiplier_1, stDevMultiplier_2)

// Asia Standard Deviation Bands
sd2up_A = plot(showStd_A and showAsia and inAsia ? s2up_A : na, title='VWAP_Asia - STDEV +2', color=color.new(color.red, 80), style=plot.style_linebr, linewidth=3, display = display.all - display.status_line - display.price_scale)
f_drawLabel(ll_offset, showAsia_label and showStd_A and showAsia and inAsia ? s2up_A : na, '     --- vAsia SD+2   ', color.red, DEFAULT_LABEL_STYLE, DEFAULT_LABEL_SIZE)

sd1up_A = plot(showStd_A and showAsia and inAsia ? s1up_A : na, title='VWAP_Asia - STDEV +1', color=color.new(color.gray, 70), style=plot.style_linebr, linewidth=3, display = display.all - display.status_line - display.price_scale)
f_drawLabel(ll_offset, showAsia_label and showStd_A and showAsia and inAsia ? s1up_A : na, '     --- vAsia SD+1   ', color.gray, DEFAULT_LABEL_STYLE, DEFAULT_LABEL_SIZE)

sd1dn_A = plot(showStd_A and showAsia and inAsia ? s1dn_A : na, title='VWAP_Asia - STDEV -1', color=color.new(color.gray, 70), style=plot.style_linebr, linewidth=3, display = display.all - display.status_line - display.price_scale)
f_drawLabel(ll_offset, showAsia_label and showStd_A and showAsia and inAsia ? s1dn_A : na, '     --- vAsia SD-1   ', color.gray, DEFAULT_LABEL_STYLE, DEFAULT_LABEL_SIZE)

sd2dn_A = plot(showStd_A and showAsia and inAsia ? s2dn_A : na, title='VWAP_Asia - STDEV -2', color=color.new(color.blue, 80), style=plot.style_linebr, linewidth=3, display = display.all - display.status_line - display.price_scale)
f_drawLabel(ll_offset, showAsia_label and showStd_A and showAsia and inAsia ? s2dn_A : na, '     --- vAsia SD-2   ', color.blue, DEFAULT_LABEL_STYLE, DEFAULT_LABEL_SIZE)

// London Standard Deviation Bands
sd2up_L = plot(showStd_L and showLondon and inLondon ? s2up_L : na, title='VWAP_Europe - STDEV +2', color=color.new(color.red, 80), style=plot.style_linebr, linewidth=3, display = display.all - display.status_line - display.price_scale)
f_drawLabel(ll_offset, showLondon_label and showStd_L and showLondon and inLondon ? s2up_L : na, '     --- vEurope SD+2   ', color.red, DEFAULT_LABEL_STYLE, DEFAULT_LABEL_SIZE)

sd1up_L = plot(showStd_L and showLondon and inLondon ? s1up_L : na, title='VWAP_Europe - STDEV +1', color=color.new(color.gray, 70), style=plot.style_linebr, linewidth=3, display = display.all - display.status_line - display.price_scale)
f_drawLabel(ll_offset, showLondon_label and showStd_L and showLondon and inLondon ? s1up_L : na, '     --- vEurope SD+1   ', color.gray, DEFAULT_LABEL_STYLE, DEFAULT_LABEL_SIZE)

sd1dn_L = plot(showStd_L and showLondon and inLondon ? s1dn_L : na, title='VWAP_Europe - STDEV -1', color=color.new(color.gray, 70), style=plot.style_linebr, linewidth=3, display = display.all - display.status_line - display.price_scale)
f_drawLabel(ll_offset, showLondon_label and showStd_L and showLondon and inLondon ? s1dn_L : na, '     --- vEurope SD-1   ', color.gray, DEFAULT_LABEL_STYLE, DEFAULT_LABEL_SIZE)

sd2dn_L = plot(showStd_L and showLondon and inLondon ? s2dn_L : na, title='VWAP_Europe - STDEV -2', color=color.new(color.blue, 80), style=plot.style_linebr, linewidth=3, display = display.all - display.status_line - display.price_scale)
f_drawLabel(ll_offset, showLondon_label and showStd_L and showLondon and inLondon ? s2dn_L : na, '     --- vEurope SD-2   ', color.blue, DEFAULT_LABEL_STYLE, DEFAULT_LABEL_SIZE)

// NY Standard Deviation Bands
sd2up_NY = plot(showStd_NY and showNY and inNY ? s2up_NY : na, title='VWAP_NY - STDEV +2', color=color.new(color.red, 80), style=plot.style_linebr, linewidth=3, display = display.all - display.status_line - display.price_scale)
f_drawLabel(ll_offset, showNY_label and showStd_NY and showNY and inNY ? s2up_NY : na, '     --- vNY SD+2   ', color.red, DEFAULT_LABEL_STYLE, DEFAULT_LABEL_SIZE)

sd1up_NY = plot(showStd_NY and showNY and inNY ? s1up_NY : na, title='VWAP_NY - STDEV +1', color=color.new(color.gray, 70), style=plot.style_linebr, linewidth=3, display = display.all - display.status_line - display.price_scale)
f_drawLabel(ll_offset, showNY_label and showStd_NY and showNY and inNY ? s1up_NY : na, '     --- vNY SD+1   ', color.gray, DEFAULT_LABEL_STYLE, DEFAULT_LABEL_SIZE)

sd1dn_NY = plot(showStd_NY and showNY and inNY ? s1dn_NY : na, title='VWAP_NY - STDEV -1', color=color.new(color.gray, 70), style=plot.style_linebr, linewidth=3, display = display.all - display.status_line - display.price_scale)
f_drawLabel(ll_offset, showNY_label and showStd_NY and showNY and inNY ? s1dn_NY : na, '     --- vNY SD-1   ', color.gray, DEFAULT_LABEL_STYLE, DEFAULT_LABEL_SIZE)

sd2dn_NY = plot(showStd_NY and showNY and inNY ? s2dn_NY : na, title='VWAP_NY - STDEV -2', color=color.new(color.blue, 80), style=plot.style_linebr, linewidth=3, display = display.all - display.status_line - display.price_scale)
f_drawLabel(ll_offset, showNY_label and showStd_NY and showNY and inNY ? s2dn_NY : na, '     --- vNY SD-2   ', color.blue, DEFAULT_LABEL_STYLE, DEFAULT_LABEL_SIZE)

//-------------------- Daily VWAP --------------------//

dChange = ta.change(time("1D"))
newSessionD = na(dChange) ? false : dChange != 0
[vD, stdevD] = computeVWAP(src, newSessionD)

[s2up_D, s1up_D, s1dn_D, s2dn_D] = compute_stDEV(vD, stdevD, stDevMultiplier_1, stDevMultiplier_2)

// Daily VWAP — anchored to the trading day, one continuous line (independent of session VWAPs)
plot(showDaily ? vD : na, title='Daily VWAP', color=color.new(#f57c00, 0), linewidth=2, style=plot.style_linebr, display = display.all - display.status_line - display.price_scale)
f_drawLabel(ll_offset, showD_label and showDaily ? vD : na, '     --- vDaily   ', #f57c00, DEFAULT_LABEL_STYLE, DEFAULT_LABEL_SIZE)

// Daily Std Dev Bands — gated on the Daily line being visible
plot(showStd_D and showDaily ? s1up_D : na, title='Daily VWAP - STDEV +1', color=color.new(color.gray, 30), style=plot.style_circles, linewidth=1, display = display.all - display.status_line - display.price_scale)
f_drawLabel(ll_offset, showD_label and showStd_D and showDaily ? s1up_D : na, '     --- vDaily SD+1   ', color.gray, DEFAULT_LABEL_STYLE, DEFAULT_LABEL_SIZE)

plot(showStd_D and showDaily ? s1dn_D : na, title='Daily VWAP - STDEV -1', color=color.new(color.gray, 30), style=plot.style_circles, linewidth=1, display = display.all - display.status_line - display.price_scale)
f_drawLabel(ll_offset, showD_label and showStd_D and showDaily ? s1dn_D : na, '     --- vDaily SD-1   ', color.gray, DEFAULT_LABEL_STYLE, DEFAULT_LABEL_SIZE)

plot(showStd_D and showDaily ? s2up_D : na, title='Daily VWAP - STDEV +2', color=color.new(color.red, 50), style=plot.style_circles, linewidth=1, display = display.all - display.status_line - display.price_scale)
f_drawLabel(ll_offset, showD_label and showStd_D and showDaily ? s2up_D : na, '     --- vDaily SD+2   ', color.red, DEFAULT_LABEL_STYLE, DEFAULT_LABEL_SIZE)

plot(showStd_D and showDaily ? s2dn_D : na, title='Daily VWAP - STDEV -2', color=color.new(color.blue, 50), style=plot.style_circles, linewidth=1, display = display.all - display.status_line - display.price_scale)
f_drawLabel(ll_offset, showD_label and showStd_D and showDaily ? s2dn_D : na, '     --- vDaily SD-2   ', color.blue, DEFAULT_LABEL_STYLE, DEFAULT_LABEL_SIZE)
````
