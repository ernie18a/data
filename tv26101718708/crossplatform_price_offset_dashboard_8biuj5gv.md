# Cross-Platform Price Offset Dashboard

- url: https://www.tradingview.com/script/8BiUj5gv/
- type: indicator
- pine_id: PUB;1715d243a2854155adb4cf15db5ea42b
- version: 1.0

## Description

## What it does

A utility dashboard for traders who hold accounts across multiple brokers
or trading platforms where the same underlying instrument quotes at slightly
different prices. The indicator displays, in real time, the equivalent
price of the chart's symbol on up to two external platforms — based on a
fixed offset that you calibrate once, manually.

## Why this exists

Traders who route the same idea to several brokers often see small but
persistent price gaps between platforms: different contract specifications,
broker-specific spreads, rollover timing differences between data feeds,
or CFD-versus-futures pricing on the same underlying. When you mark a
level on TradingView (entry, stop, target), you still need to translate
that level into the price scale of the platform where the trade is
actually executed. This indicator removes that mental arithmetic.

## How it works

At a single moment of your choosing, you take a simultaneous snapshot of
three values:

1. The current price of the symbol on the TradingView chart.
2. The price of the same instrument on Platform 1 (for example, your
   live MT4 or MT5 account).
3. The price of the same instrument on Platform 2 (another broker or
   account).

You enter all three values into the indicator's inputs. From that
moment on, the indicator computes a constant offset for each platform:

    offset_1 = platform_1_price − reference_price
    offset_2 = platform_2_price − reference_price

It then displays the live equivalent on each platform as:

    platform_1_live = close + offset_1
    platform_2_live = close + offset_2

If the TradingView chart moves +20 points, the displayed prices for both
platforms also move +20 points relative to their calibrated baseline.

## How to use

1. Add the indicator to any chart. It is symbol-agnostic and works on
   futures, indices, metals, stocks, and crypto.
2. Open the indicator settings, "Calibration" tab.
3. Fill in the three calibration prices, all taken at the same moment
   from your platforms.
4. Optionally, rename "Platform 1" and "Platform 2" to your broker names.
5. The dashboard now updates on every tick.

## Inputs

- Reference price at calibration — the chart's price at the moment you
  took the snapshot.
- Platform 1 name / Platform 2 name — labels shown in the table.
- Platform 1 price / Platform 2 price at calibration — the corresponding
  prices on your external platforms at that same moment.
- Display options — table position, text size (tiny, small, normal,
  large, huge), text and background colors, and an optional row that
  shows the raw offsets for sanity-checking.

## Assumptions and limitations

- The offset is treated as constant until you recalibrate. If the broker
  changes the spread, rolls a contract, or shifts a data-feed timing,
  the displayed values will drift away from reality and you should
  recalibrate.
- This is a display utility. It does not place orders, generate signals,
  or connect to any external broker. All three calibration prices are
  entered manually by the user.
- Recalibration is manual. Whenever you observe a meaningful drift on
  your real platform, take a fresh snapshot and update the three input
  values.

## Notes

- The indicator does not connect to brokers, does not fetch external
  data, and does not access any network resource. It operates purely on
  the chart's close series and on the three calibration inputs you
  provide.
- Displayed prices use the chart symbol's mintick precision, so values
  appear at the same precision as your chart.
- The source is fully open. Read the code for the exact formula and the
  table-rendering logic.

This script is provided for informational and convenience purposes only
and does not constitute trading advice.

## Source Code

````pine
//@version=6
indicator("RAZ.G PRICE OFFSET DASH 1.0", overlay=true)

// ══════════════════════════════════════════════
//  דאשבורד התאמת מחיר בין פלטפורמות
//  ─────────────────────────────────────────────
//  מטרה: לחשב ולהציג מחיר משוער של עד 2 פלטפורמות
//  חיצוניות (MT4/MT5/ברוקר אחר) לפי היסט קבוע
//  מהסימול שעל הגרף.
//
//  שימוש:
//    1. בעת הכיול לוקחים snapshot בו-זמני:
//       א. מחיר הסימול בגרף ב-TradingView
//       ב. מחיר אותו נכס בפלטפורמה 1
//       ג. מחיר אותו נכס בפלטפורמה 2
//    2. מזינים את 3 הערכים בקלטים.
//    3. האינדיקטור מחשב היסט קבוע לכל פלטפורמה
//       ומציג מחיר חי = close + offset.
//
//  הנחה: ההיסט נשאר קבוע עד הכיול הבא. אם הספרד
//  או גלגול חוזה משנה את הפער — לכייל מחדש.
//
//  עובד על כל נכס (NQ, ES, זהב, מניות וכו') —
//  אין תלות בסימול ספציפי.
// ══════════════════════════════════════════════

// ─── קלט: כיול ─────────────────────────────────
g_cal = "כיול"
ref_price = input.float(0.0, "מחיר סימול ראשי בכיול",
     group=g_cal,
     tooltip="מחיר ה-close של הגרף ברגע שלקחת snapshot מהפלטפורמות האחרות")
p1_name  = input.string("Platform 1", "שם פלטפורמה 1", group=g_cal)
p1_price = input.float(0.0, "מחיר פלטפורמה 1 בכיול", group=g_cal)
p2_name  = input.string("Platform 2", "שם פלטפורמה 2", group=g_cal)
p2_price = input.float(0.0, "מחיר פלטפורמה 2 בכיול", group=g_cal)

// ─── קלט: תצוגה ────────────────────────────────
g_view = "תצוגה"
table_pos_str = input.string("top_right", "מיקום טבלה",
     options=["top_left","top_right","bottom_left","bottom_right","middle_left","middle_right"],
     group=g_view)
text_size_str = input.string("large", "גודל טקסט",
     options=["tiny","small","normal","large","huge"],
     group=g_view)
text_color = input.color(color.white,                 "צבע טקסט",      group=g_view)
bg_color   = input.color(color.new(color.black, 20),  "צבע רקע שורות", group=g_view)
header_bg  = input.color(color.new(color.blue,  30),  "צבע רקע כותרת", group=g_view)
show_offsets = input.bool(true, "הצג שורת היסטים", group=g_view)

// ─── חישוב ─────────────────────────────────────
calibrated = ref_price > 0 and p1_price > 0 and p2_price > 0
offset_1   = p1_price - ref_price
offset_2   = p2_price - ref_price
p1_live    = close + offset_1
p2_live    = close + offset_2

// ─── עזר: מיקום וגודל טקסט ─────────────────────
get_pos(s) =>
    switch s
        "top_left"     => position.top_left
        "top_right"    => position.top_right
        "bottom_left"  => position.bottom_left
        "bottom_right" => position.bottom_right
        "middle_left"  => position.middle_left
        "middle_right" => position.middle_right
        =>                 position.top_right

get_size(s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        "huge"   => size.huge
        =>          size.normal

// שורת ההיסטים מוצגת בגודל אחד פחות מהטקסט הראשי
get_size_smaller(s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.tiny
        "normal" => size.small
        "large"  => size.normal
        "huge"   => size.large
        =>          size.small

// ─── טבלה ──────────────────────────────────────
var table dash = table.new(get_pos(table_pos_str), 2, 5, border_width=1)

if barstate.islast
    sym  = syminfo.ticker
    fmt  = format.mintick
    tsz  = get_size(text_size_str)
    tsz_sm = get_size_smaller(text_size_str)

    // כותרת
    table.cell(dash, 0, 0, "מחיר יחסי בין פלטפורמות",
         text_color=text_color, bgcolor=header_bg, text_halign=text.align_center, text_size=tsz)
    table.cell(dash, 1, 0, "", bgcolor=header_bg, text_size=tsz)
    table.merge_cells(dash, 0, 0, 1, 0)

    // סימול הגרף (חי)
    table.cell(dash, 0, 1, sym + " (חי)",
         text_color=text_color, bgcolor=bg_color, text_size=tsz)
    table.cell(dash, 1, 1, str.tostring(close, fmt),
         text_color=text_color, bgcolor=bg_color, text_halign=text.align_right, text_size=tsz)

    if calibrated
        table.cell(dash, 0, 2, p1_name,
             text_color=text_color, bgcolor=bg_color, text_size=tsz)
        table.cell(dash, 1, 2, str.tostring(p1_live, fmt),
             text_color=text_color, bgcolor=bg_color, text_halign=text.align_right, text_size=tsz)

        table.cell(dash, 0, 3, p2_name,
             text_color=text_color, bgcolor=bg_color, text_size=tsz)
        table.cell(dash, 1, 3, str.tostring(p2_live, fmt),
             text_color=text_color, bgcolor=bg_color, text_halign=text.align_right, text_size=tsz)

        if show_offsets
            offset_txt = p1_name + ": " + str.tostring(offset_1, fmt) +
                 "  |  " + p2_name + ": " + str.tostring(offset_2, fmt)
            table.cell(dash, 0, 4, "היסטים",
                 text_color=text_color, bgcolor=bg_color, text_size=tsz_sm)
            table.cell(dash, 1, 4, offset_txt,
                 text_color=text_color, bgcolor=bg_color,
                 text_size=tsz_sm, text_halign=text.align_right)
        else
            table.cell(dash, 0, 4, "", bgcolor=bg_color)
            table.cell(dash, 1, 4, "", bgcolor=bg_color)
    else
        table.cell(dash, 0, 2, "לא מכויל — מלא את 3 שדות המחיר בקלט",
             text_color=color.yellow, bgcolor=bg_color, text_halign=text.align_center, text_size=tsz)
        table.cell(dash, 1, 2, "", bgcolor=bg_color, text_size=tsz)
        table.merge_cells(dash, 0, 2, 1, 2)
        table.cell(dash, 0, 3, "", bgcolor=bg_color)
        table.cell(dash, 1, 3, "", bgcolor=bg_color)
        table.cell(dash, 0, 4, "", bgcolor=bg_color)
        table.cell(dash, 1, 4, "", bgcolor=bg_color)
````
