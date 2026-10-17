# Smart Killzones  Gold & BTC Edition

- url: https://www.tradingview.com/script/XNPriaYA/
- type: indicator
- pine_id: PUB;b58a2a87da82489086f0340c9ea75551
- version: 1.0

## Description

Smart Killzones — Gold & BTC Edition

OVERVIEW
A clean, open-source session-mapping tool that highlights the four major institutional trading sessions (Asia, London, New York AM, New York PM) and captures each session's High and Low as forward liquidity levels. It is built and calibrated for Gold (XAUUSD) and Bitcoin (BTCUSD), and works on any FX or index pair on intraday timeframes (M1 to H1).

WHY SESSIONS MATTER
The largest moves in Gold and BTC tend to occur during the London/New York overlap (around 13:00-17:00 UTC) and at the Asia -> London handover. Marking each session's High and Low gives you the liquidity pools that price often sweeps before reversing. This tool simply makes those zones visible and objective.

WHAT IT DRAWS
- A colored box for each active session (range from session open to now).
- Auto-extending High/Low liquidity lines for each completed session.
- Optional session-name labels with the range size in points.
- A compact status table showing which session is active and the current symbol.

KEY SETTINGS
- Timezone selector: UTC, Exchange, Broker GMT+2, Broker GMT+3, or Custom.
- Each session: independent on/off, custom time window, and color.
- Visuals: toggle labels, range text, liquidity lines (length and width), table position.
- Weekend Gap Awareness (Gold): optionally hides sessions during the Gold weekend close (Fri 22:00 -> Sun 22:00 UTC). Disable it for crypto, which trades 24/7.

NOT INCLUDED (by design)
- No buy/sell signals.
- No stop-loss / take-profit logic.
- This tool maps context only; it does not tell you when to trade.

HOW TO USE
1. Add to a Gold or BTC chart on an intraday timeframe (M5-M15 recommended).
2. Set the Timezone option to match your broker so the sessions align.
3. Watch how price reacts to prior session High/Low liquidity lines.
4. Use the active-session table to know which session you are trading.

NOTES
- This script is open-source under MPL 2.0; you are free to study and reuse it under the license terms.
- It is a session/liquidity visualization tool, not a strategy.

DISCLAIMER
Educational tool only. Not financial advice. Trading involves risk of capital loss. Past performance does not guarantee future results. Use at your own discretion.

## Source Code

````pine
// © 2026 ALAA NASER — All Rights Reserved
// =====================================================================
// Smart Killzones — Gold & BTC Edition  •  v1.0.1
// ---------------------------------------------------------------------
// Author : ALAA NASER  (TradingView: @AurumX_Official)
// License: Mozilla Public License 2.0
// =====================================================================
// PURPOSE
//   Highlights the four institutional trading sessions (Asia, London,
//   New York AM, New York PM) with clean colored boxes, captures the
//   High & Low of each session as future liquidity targets, and shows
//   the active session in a compact status table.
//
//   Designed and optimized for:
//     •  XAUUSD  (Gold)   — primary use case
//     •  BTCUSD  (Bitcoin) — 24/7 adapted
//     •  Any FX / Index pair on intraday timeframes (M1 → H1)
//
// WHY THIS MATTERS
//   The biggest moves in Gold and BTC occur during the overlap of
//   London + NY (13:00–17:00 UTC) and at the Asia → London handover.
//   Marking session highs/lows gives you precise liquidity pools that
//   institutions sweep before reversing.
//
// FEATURES
//   ✓ 4 fully customizable sessions (time + color + on/off)
//   ✓ Auto-extending High/Low liquidity lines (sweep targets)
//   ✓ Session labels with name + range size in pips/points
//   ✓ Active-session status table (top-right, compact)
//   ✓ Weekend gap awareness for Gold
//   ✓ Timezone selector (broker GMT+2/+3, exchange UTC, custom)
//   ✓ Works on every intraday TF (M1 to H1 recommended)
//
// NOT INCLUDED (by design — to keep the tool focused)
//   ✗ Entry/exit signals
//   ✗ Stop-loss / take-profit logic
//   ✗ Alerts on session open/close (planned for v1.1 if requested)
//
// DISCLAIMER
//   Educational tool only. Not financial advice. Trading involves
//   risk of capital loss. Past performance does not guarantee future
//   results. Use at your own discretion.
//
// CHANGELOG
//   v1.0.0 — Initial public release.
//   v1.0.1 — FIX: liquidity-line projection now uses a fixed per-bar
//            duration (timeframe.in_seconds) instead of the last bar's
//            time delta, so lines extend a consistent length and are not
//            distorted by weekend/session gaps.
// =====================================================================

//@version=6
indicator("Smart Killzones — Gold & BTC Edition", shorttitle="SmartKZ", overlay=true, max_boxes_count=200, max_lines_count=500, max_labels_count=200)

// =====================================================================
// 1. INPUTS — Timezone
// =====================================================================
grpTZ = "🌐 Timezone"
tzMode = input.string("UTC", "Time Reference", options=["UTC", "Exchange", "Broker GMT+2", "Broker GMT+3", "Custom"], group=grpTZ, tooltip="UTC = TradingView default. Broker GMT+2/+3 = typical MT5 broker time. Choose what matches the sessions you trade.")
tzCustom = input.string("UTC+0", "Custom Timezone (if selected above)", group=grpTZ, tooltip="Examples: UTC+3, GMT-5, America/New_York, Asia/Tokyo")

tz = switch tzMode
    "Exchange"     => syminfo.timezone
    "UTC"          => "UTC"
    "Broker GMT+2" => "UTC+2"
    "Broker GMT+3" => "UTC+3"
    =>                tzCustom

// =====================================================================
// 2. INPUTS — Sessions
// =====================================================================
grpAsia = "🌏 Asia Session (Tokyo)"
asiaEnable = input.bool(true,  "Show",    group=grpAsia, inline="asia1")
asiaTime   = input.session("0000-0800", "Time", group=grpAsia, inline="asia1")
asiaColor  = input.color(color.new(#2962ff, 88), "Color", group=grpAsia)

grpLondon = "🇬🇧 London Session"
londonEnable = input.bool(true,  "Show",    group=grpLondon, inline="lon1")
londonTime   = input.session("0700-1100", "Time", group=grpLondon, inline="lon1")
londonColor  = input.color(color.new(#26a69a, 88), "Color", group=grpLondon)

grpNYAM = "🇺🇸 New York AM (Power Hour)"
nyamEnable = input.bool(true,  "Show",    group=grpNYAM, inline="nyam1")
nyamTime   = input.session("1300-1700", "Time", group=grpNYAM, inline="nyam1")
nyamColor  = input.color(color.new(#ef5350, 85), "Color", group=grpNYAM)

grpNYPM = "🇺🇸 New York PM"
nypmEnable = input.bool(true,  "Show",    group=grpNYPM, inline="nypm1")
nypmTime   = input.session("1700-2100", "Time", group=grpNYPM, inline="nypm1")
nypmColor  = input.color(color.new(#ab47bc, 88), "Color", group=grpNYPM)

// =====================================================================
// 3. INPUTS — Visuals & Liquidity
// =====================================================================
grpViz = "🎨 Visuals"
showLabels    = input.bool(true,  "Show session name labels",     group=grpViz)
showRange     = input.bool(true,  "Show range size in label (pts)", group=grpViz)
showLiquidity = input.bool(true,  "Show H/L liquidity lines",     group=grpViz, tooltip="Marks each session's High & Low as horizontal lines extending right — these are the liquidity pools institutions sweep.")
liqExtendBars = input.int(50, "Liquidity lines length (bars)", minval=10, maxval=500, group=grpViz)
liqWidth      = input.int(1, "Liquidity line width", minval=1, maxval=3, group=grpViz)
showTable     = input.bool(true, "Show active-session table",    group=grpViz)
tablePos      = input.string("top_right", "Table position", options=["top_right","top_left","bottom_right","bottom_left","middle_right","middle_left"], group=grpViz)

grpWk = "🛡️ Weekend Gap Awareness (Gold)"
weekendAware  = input.bool(true, "Hide sessions during XAU weekend (Fri 22:00 → Sun 22:00 UTC)", group=grpWk, tooltip="MT5 Gold market closes weekends. Disable for crypto.")

// =====================================================================
// 4. SESSION DETECTION
// =====================================================================
inSession(sess) => not na(time(timeframe.period, sess, tz))

asiaActive   = asiaEnable   and inSession(asiaTime)
londonActive = londonEnable and inSession(londonTime)
nyamActive   = nyamEnable   and inSession(nyamTime)
nypmActive   = nypmEnable   and inSession(nypmTime)

// Weekend gate (UTC reference: Fri 22:00 → Sun 22:00)
dowUTC   = dayofweek(time, "UTC")
hourUTC  = hour(time, "UTC")
inWeekend = (dowUTC == dayofweek.friday and hourUTC >= 22) or (dowUTC == dayofweek.saturday) or (dowUTC == dayofweek.sunday and hourUTC < 22)
sessionsBlocked = weekendAware and inWeekend

// =====================================================================
// 5. SESSION TRACKING — High/Low capture
// =====================================================================
type SessionState
    bool   active     = false
    float  sHigh      = na
    float  sLow       = na
    int    startBar   = na
    int    startTime  = na
    box    activeBox  = na
    line   highLine   = na
    line   lowLine    = na
    label  nameLabel  = na

var SessionState asia   = SessionState.new()
var SessionState london = SessionState.new()
var SessionState nyam   = SessionState.new()
var SessionState nypm   = SessionState.new()

// =====================================================================
// 6. SESSION HANDLER
// =====================================================================
handleSession(SessionState st, bool isActive, string name, color col) =>
    bool justStarted = isActive and not st.active
    bool justEnded   = not isActive and st.active

    if justStarted and not sessionsBlocked
        st.active    := true
        st.sHigh     := high
        st.sLow      := low
        st.startBar  := bar_index
        st.startTime := time
        st.activeBox := box.new(left=time, top=high, right=time, bottom=low, bgcolor=col, border_color=color.new(color.white, 70), border_width=1, extend=extend.none, xloc=xloc.bar_time)

    if st.active and isActive
        st.sHigh := math.max(st.sHigh, high)
        st.sLow  := math.min(st.sLow,  low)
        if not na(st.activeBox)
            box.set_top(st.activeBox,    st.sHigh)
            box.set_bottom(st.activeBox, st.sLow)
            box.set_right(st.activeBox,  time)

    if justEnded and not na(st.sHigh)
        if showLabels
            float midPrice = (st.sHigh + st.sLow) / 2.0
            float rangePts = (st.sHigh - st.sLow) / syminfo.mintick
            string lblTxt  = showRange ? name + "  (" + str.tostring(rangePts, "#") + " pts)" : name
            st.nameLabel := label.new(x=math.round((st.startTime + time) / 2), y=st.sHigh, text=lblTxt, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_down, color=color.new(col, 50), textcolor=color.white, size=size.small)

        if showLiquidity
            int barMs  = timeframe.in_seconds(timeframe.period) * 1000
            int rightT = time + (liqExtendBars * barMs)
            st.highLine := line.new(x1=time, y1=st.sHigh, x2=rightT, y2=st.sHigh, xloc=xloc.bar_time, color=color.new(color.lime, 30), width=liqWidth, style=line.style_dashed)
            st.lowLine  := line.new(x1=time, y1=st.sLow,  x2=rightT, y2=st.sLow,  xloc=xloc.bar_time, color=color.new(color.red,  30), width=liqWidth, style=line.style_dashed)

        st.active    := false
        st.activeBox := na

if barstate.isconfirmed
    handleSession(asia,   asiaActive,   "Asia",     asiaColor)
    handleSession(london, londonActive, "London",   londonColor)
    handleSession(nyam,   nyamActive,   "NY AM",    nyamColor)
    handleSession(nypm,   nypmActive,   "NY PM",    nypmColor)

// =====================================================================
// 7. STATUS TABLE
// =====================================================================
var table statusTbl = na

if showTable and barstate.islast
    table.delete(statusTbl)
    tblPos = switch tablePos
        "top_right"     => position.top_right
        "top_left"      => position.top_left
        "bottom_right"  => position.bottom_right
        "bottom_left"   => position.bottom_left
        "middle_right"  => position.middle_right
        =>                 position.middle_left
    statusTbl := table.new(position=tblPos, columns=2, rows=6, bgcolor=color.new(#0a0a0a, 10), border_color=color.new(color.gray, 50), border_width=1)

    table.cell(statusTbl, 0, 0, "📍 Smart Killzones", text_color=color.new(#ffd700, 0), bgcolor=color.new(#1a1a1a, 0), text_size=size.small)
    table.cell(statusTbl, 1, 0, syminfo.ticker,        text_color=color.new(#ffd700, 0), bgcolor=color.new(#1a1a1a, 0), text_size=size.small)

    if sessionsBlocked
        table.cell(statusTbl, 0, 1, "🚫 Weekend",      text_color=color.white,  text_size=size.tiny)
        table.cell(statusTbl, 1, 1, "Gold market closed", text_color=color.orange, text_size=size.tiny)
    else
        table.cell(statusTbl, 0, 1, "🌏 Asia",     text_color=color.white, text_size=size.tiny)
        table.cell(statusTbl, 1, 1, asiaActive   ? "🟢 ACTIVE" : "⚪ closed", text_color = asiaActive   ? color.lime : color.gray, text_size=size.tiny)

        table.cell(statusTbl, 0, 2, "🇬🇧 London",  text_color=color.white, text_size=size.tiny)
        table.cell(statusTbl, 1, 2, londonActive ? "🟢 ACTIVE" : "⚪ closed", text_color = londonActive ? color.lime : color.gray, text_size=size.tiny)

        table.cell(statusTbl, 0, 3, "🇺🇸 NY AM",   text_color=color.white, text_size=size.tiny)
        table.cell(statusTbl, 1, 3, nyamActive   ? "🟢 ACTIVE" : "⚪ closed", text_color = nyamActive   ? color.lime : color.gray, text_size=size.tiny)

        table.cell(statusTbl, 0, 4, "🇺🇸 NY PM",   text_color=color.white, text_size=size.tiny)
        table.cell(statusTbl, 1, 4, nypmActive   ? "🟢 ACTIVE" : "⚪ closed", text_color = nypmActive   ? color.lime : color.gray, text_size=size.tiny)

    table.cell(statusTbl, 0, 5, "© ALAA NASER", text_color=color.new(color.yellow, 50), bgcolor=color.new(#0a0a0a, 0), text_size=size.tiny, text_halign=text.align_center)
    table.cell(statusTbl, 1, 5, "v1.0.1",        text_color=color.new(color.yellow, 50), bgcolor=color.new(#0a0a0a, 0), text_size=size.tiny, text_halign=text.align_center)
````
