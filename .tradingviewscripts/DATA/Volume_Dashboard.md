<!-- tradingview-pine-id: PUB;6afd881eb2a2465388162aad90289712 -->
<!-- tradingviewscripts-format: 1 -->
# Volume Dashboard

Source: https://www.tradingview.com/script/Or8IKHAk-Volume-Dashboard/

## Description

Volume Dashboard — 1mL | Turnover | Volume

Overview
A lightweight, non-intrusive table indicator designed for Indian equity traders who want instant volume intelligence on any stock — without cluttering the chart. Three carefully chosen metrics give you a complete picture of a stock's liquidity profile at a glance.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WHAT IT SHOWS

🔹 1mL — Intraday Liquidity Score (in Lakhs)
Calculated as the 1-minute closing price × average volume over the last 50 candles on the 1-minute timeframe. This tells you how much value is being exchanged per minute in the current session. Displayed in Lakhs (₹).
Formula: 1m Close × SMA(Volume, 50) on 1m TF

🔹 Turnover — Structural Liquidity (in Crores)
Calculated as the current market price × average daily volume over the last 50 trading sessions. This is the true measure of how much institutional money flows through this stock on a typical day — essential for position sizing and liquidity filtering.
Formula: CMP × SMA(Volume, 50) on Daily TF

🔹 Volume — Today's Traded Volume (in Millions)
The cumulative volume traded today pulled directly from the daily feed. Shown in Millions (M) for easy reading.
Reference: 10L = 1M | 1Cr = 10M

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

KEY FEATURES

✅ Works on any timeframe — 1m and Daily data are always fetched from their correct feeds regardless of chart timeframe
✅ Indian number formatting — Lakhs, Crores and Millions as used natively by Indian traders
✅ Fully customizable table — choose size (Tiny to Huge) and position (9 positions)
✅ Custom colors — background, labels, values and border all adjustable
✅ Minimal footprint — pure table, no plots, no drawings, no chart clutter

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HOW TO USE

- 1mL — Filter stocks for intraday momentum. Higher 1mL = more active intraday participation
- Turnover — Use as a liquidity gate. Stocks with Turnover > 50Cr are generally safe for swing and positional trades
- Volume — Compare today's volume vs typical session to spot unusual activity early

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SETTINGS

- Table Size → Tiny / Small / Normal / Large / Huge
- Table Position → 9 positions across the chart
- Background Color → Table background
- Label Color → Row label text color
- Value Color → Metric value text color
- Border Color → Table border color

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NOTES

- Designed specifically for NSE/BSE listed stocks
- Best used alongside a momentum scanner or watchlist workflow
- Data pulls use request.security() with lookahead=off to prevent repainting

---

## Source Code

````pine
//@version=6
indicator("Volume Dashboard", overlay=true)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
tbl_size_inp = input.string("Normal", "Table Size",
     options=["Tiny","Small","Normal","Large","Huge"], group="Table")
tbl_pos_inp  = input.string("Bottom Right", "Table Position",
     options=["Top Left","Top Center","Top Right",
              "Middle Left","Middle Right",
              "Bottom Left","Bottom Center","Bottom Right"], group="Table")

col_bg  = input.color(color.new(color.black, 20), "Background",   group="Colors")
col_lbl = input.color(color.new(color.white, 0),  "Label Color",  group="Colors")
col_val = input.color(color.yellow,               "Value Color",  group="Colors")
col_bdr = input.color(color.new(color.gray, 50),  "Border Color", group="Colors")

// ─── HELPERS ──────────────────────────────────────────────────────────────────
f_size(s) =>
    s == "Tiny"   ? size.tiny   :
     s == "Small"  ? size.small  :
     s == "Normal" ? size.normal :
     s == "Large"  ? size.large  : size.huge

f_pos(s) =>
    s == "Top Left"      ? position.top_left      :
     s == "Top Center"    ? position.top_center    :
     s == "Top Right"     ? position.top_right     :
     s == "Middle Left"   ? position.middle_left   :
     s == "Middle Right"  ? position.middle_right  :
     s == "Bottom Left"   ? position.bottom_left   :
     s == "Bottom Center" ? position.bottom_center :
     position.bottom_right

// 1mL → Lakhs
to_lakhs(v) =>
    val = v / 100000.0
    str.tostring(math.round(val, 2)) + "L"

// Turnover → Crores
to_crores(v) =>
    val = v / 10000000.0
    str.tostring(math.round(val, 2)) + "Cr"

// Volume → Millions (10L = 1M, 1Cr = 10M)
to_millions(v) =>
    val = v / 1000000.0
    str.tostring(math.round(val, 2)) + "M"

tbl_size = f_size(tbl_size_inp)
tbl_pos  = f_pos(tbl_pos_inp)

// ─── DATA FETCH ───────────────────────────────────────────────────────────────
// 1m close and avg volume — both from 1m feed
[close_1m, avg_vol_1m] = request.security(syminfo.tickerid, "1",
     [close, ta.sma(volume, 50)],
     lookahead=barmerge.lookahead_off)

// Avg volume of last 50 × Daily candles
avg_vol_1d = request.security(syminfo.tickerid, "D",
     ta.sma(volume, 50),
     lookahead=barmerge.lookahead_off)

// Today's cumulative volume from Daily feed
today_vol = request.security(syminfo.tickerid, "D",
     volume,
     lookahead=barmerge.lookahead_off)

// ─── CALCULATIONS ─────────────────────────────────────────────────────────────
val_1ml  = close_1m * avg_vol_1m   // 1m close × 50-bar 1m avg vol → Lakhs
turnover = close    * avg_vol_1d   // CMP × 50D avg vol → Crores

// ─── TABLE ────────────────────────────────────────────────────────────────────
var table tbl = na

if barstate.islast
    tbl := table.new(tbl_pos, 2, 3,
         bgcolor=col_bg,
         border_color=col_bdr,
         border_width=1,
         frame_color=col_bdr,
         frame_width=1)

    // Row 0 — 1mL
    table.cell(tbl, 0, 0, "1mL",
         text_color=col_lbl, text_size=tbl_size,
         bgcolor=col_bg, text_halign=text.align_left)
    table.cell(tbl, 1, 0,
         na(val_1ml) ? "..." : to_lakhs(val_1ml),
         text_color=col_val, text_size=tbl_size,
         bgcolor=col_bg, text_halign=text.align_right)

    // Row 1 — Turnover
    table.cell(tbl, 0, 1, "Turnover",
         text_color=col_lbl, text_size=tbl_size,
         bgcolor=col_bg, text_halign=text.align_left)
    table.cell(tbl, 1, 1,
         na(turnover) ? "..." : to_crores(turnover),
         text_color=col_val, text_size=tbl_size,
         bgcolor=col_bg, text_halign=text.align_right)

    // Row 2 — Volume in Millions
    table.cell(tbl, 0, 2, "Volume",
         text_color=col_lbl, text_size=tbl_size,
         bgcolor=col_bg, text_halign=text.align_left)
    table.cell(tbl, 1, 2,
         na(today_vol) ? "..." : to_millions(today_vol),
         text_color=col_val, text_size=tbl_size,
         bgcolor=col_bg, text_halign=text.align_right)
````
