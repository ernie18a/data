# MMXM Model Checklist by [Pac]

- url: https://www.tradingview.com/script/BwvumkTH-MMXM-Model-Checklist-by-Pac/
- type: indicator
- pine_id: PUB;50fa9e8bf53d40988de97ede496c80e3
- version: 1.0

## Description

[b]MMXM Model Checklist by [Pac][/b]

A simple checklist tool to validate MMXM (Market Maker Model) setups before entering a trade.

The checklist covers 3 phases:

① Bias & Context

HTF Bias confirmed (Daily/Weekly direction)
DOL (Draw on Liquidity) identified
Price in Premium or Discount zone
② Market Structure

MSS (Market Structure Shift) confirmed
CIC (Change In Character) present
Valid Order Block or Fair Value Gap at entry
③ Timing & Entry

Kill Zone or ICT Time Macro active
SMT divergence or Liquidity Sweep occurred
Features:

Trade Score — shows % of criteria checked (green ≥75%, yellow ≥50%, red <50%)
Symbol pinning — checklist only shows on your chosen symbol
Fully customizable: position, colors, font size, visible rows
Clean table layout with section headers
How to use:

Add to chart
Check each criteria as you analyze
Enter only when score is high and setup aligns

## Source Code

````pine
//@version=6
indicator(title = "MMXM Model Checklist by [Pac]", shorttitle = "MMXM Checklist by [Pac]", overlay = true)

// ─── Group 0: Symbol Pinning ────────────────────────────────────────────────
var string GP0 = "Symbol Settings"
var bool firstLoad = true
pinnedSymbolInput = input.string(defval = "", title = "Pinned Symbol", group = GP0,
     tooltip = "Checklist sẽ chỉ hiển thị trên symbol này. Để trống = dùng symbol hiện tại khi load lần đầu.")
var string pinnedSymbol = firstLoad and pinnedSymbolInput == "" ? syminfo.ticker : pinnedSymbolInput
if firstLoad
    firstLoad := false

// ─── Group 1: Table Header Settings ─────────────────────────────────────────
var string GP1 = "Table Header Settings"
TablePosition = input.string(defval = "Bottom Right", title = "Position",
     options = ["Top Left", "Top Center", "Top Right",
                "Middle Left", "Middle Center", "Middle Right",
                "Bottom Left", "Bottom Center", "Bottom Right"],
     inline = "in1", group = GP1)
Table_Position = switch TablePosition
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right

label_size = input.string(defval = "Small", title = "Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     inline = "in1", group = GP1)
Tsize = switch label_size
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge

btextcolor      = input.color(defval = color.white,   title = "Header Text Color",  inline = "in111", group = GP1)
bbackgroundcolor = input.color(defval = #0D47A1,       title = "Header Background",  inline = "in111", group = GP1)
borderColor     = input.color(defval = #1565C0,        title = "Border Color",       inline = "in112", group = GP1)
ubs    = input.bool(true, "", inline = "in00", group = GP1,
     tooltip = "Hiện/ẩn banner tiêu đề. Max 50 ký tự.")
banner = input.string("MMXM Model Checklist", title = "Header", inline = "in00", group = GP1)

// ─── Group 2: Bias & Context ─────────────────────────────────────────────────
var string GP2 = "① Bias & Context"
check1 = input.bool(false, "HTF Bias",     inline = "r1", group = GP2,
     tooltip = "HTF (Daily/Weekly) bias xác nhận hướng trade. Bullish = tìm long, Bearish = tìm short.")
check2 = input.bool(false, "DOL Defined",  inline = "r2", group = GP2,
     tooltip = "Draw On Liquidity đã xác định rõ — biết giá đang kéo về đâu (BSL hoặc SSL).")
check3 = input.bool(false, "Premium/Discount", inline = "r3", group = GP2,
     tooltip = "Giá đang ở vùng Discount (long) hoặc Premium (short) so với range HTF. Tính theo Fibonacci 50%.")

text1 = input.string("HTF Bias",          title = "①", inline = "r1", group = GP2)
text2 = input.string("DOL Defined",       title = "②", inline = "r2", group = GP2)
text3 = input.string("Premium/Discount",  title = "③", inline = "r3", group = GP2)

// ─── Group 3: Market Structure ────────────────────────────────────────────────
var string GP3 = "② Market Structure"
check4 = input.bool(false, "MSS Confirmed", inline = "r4", group = GP3,
     tooltip = "Market Structure Shift — giá phá vỡ swing quan trọng theo hướng bias, xác nhận chuyển pha.")
check5 = input.bool(false, "CIC Present",   inline = "r5", group = GP3,
     tooltip = "Change In Character (ChoCh) — cây nến thay đổi tính cách, momentum dừng, sẵn sàng đảo chiều.")
check6 = input.bool(false, "OB/FVG Valid",  inline = "r6", group = GP3,
     tooltip = "Order Block hoặc Fair Value Gap hợp lệ ở vùng entry — chưa bị fill, nằm đúng cấu trúc.")

text4 = input.string("MSS Confirmed", title = "④", inline = "r4", group = GP3)
text5 = input.string("CIC Present",   title = "⑤", inline = "r5", group = GP3)
text6 = input.string("OB / FVG",      title = "⑥", inline = "r6", group = GP3)

// ─── Group 4: Timing & Entry ──────────────────────────────────────────────────
var string GP4 = "③ Timing & Entry"
check7 = input.bool(false, "Kill Zone / Macro", inline = "r7", group = GP4,
     tooltip = "Trade xảy ra trong Kill Zone (London/NY Open) hoặc Time Macro ICT được xác nhận.")
check8 = input.bool(false, "SMT / Sweep",       inline = "r8", group = GP4,
     tooltip = "Smart Money Technique hoặc Liquidity Sweep đã xảy ra — giá lấy thanh khoản trước khi vào hướng thật.")

text7 = input.string("Kill Zone / Macro", title = "⑦", inline = "r7", group = GP4)
text8 = input.string("SMT / Sweep",       title = "⑧", inline = "r8", group = GP4)

// ─── Group 5: Display Settings ────────────────────────────────────────────────
var string GP5 = "Display Settings"
visibleRows    = input.int(8,    title = "Visible Rows",     minval = 1, maxval = 8, group = GP5)
showTradeScore = input.bool(true, title = "Show Trade Score", group = GP5,
     tooltip = "Hiển thị % số tiêu chí đã đánh dấu / tổng visible rows.")
textcolor        = input.color(defval = #D3D3D3, title = "Text Color",       inline = "in2", group = GP5)
backgroundcolor  = input.color(defval = #151515, title = "Background Color", inline = "in2", group = GP5)

// ─── Logic ────────────────────────────────────────────────────────────────────
isPinnedSymbol = syminfo.ticker == pinnedSymbol

// Map row index to check/text values
f_checked(i) =>
    switch i
        1 => check1
        2 => check2
        3 => check3
        4 => check4
        5 => check5
        6 => check6
        7 => check7
        8 => check8
        => false

f_text(i) =>
    switch i
        1 => text1
        2 => text2
        3 => text3
        4 => text4
        5 => text5
        6 => text6
        7 => text7
        8 => text8
        => ""

checkedCount = (check1 ? 1 : 0) + (check2 ? 1 : 0) + (check3 ? 1 : 0) + (check4 ? 1 : 0) +
               (check5 ? 1 : 0) + (check6 ? 1 : 0) + (check7 ? 1 : 0) + (check8 ? 1 : 0)
tradeScore   = isPinnedSymbol ? math.round((checkedCount / visibleRows) * 100) : 0

tradeScoreColor = tradeScore >= 75 ? #32CD32 : tradeScore >= 50 ? #FFD700 : #FF4500

// Section header rows (row numbers within the table)
// Layout: header=0, section①=1, rows 1-3 = 2-4, section②=5, rows 4-6 = 6-8, section③=9, rows 7-8 = 10-11, score=12
// Total rows = 13
var int TOTAL_ROWS = 13
var table myTable = table.new(
     position     = Table_Position,
     columns      = 2,
     rows         = TOTAL_ROWS,
     border_width = 1,
     border_color = borderColor,
     frame_width  = 2,
     frame_color  = borderColor)

f_section(tableId, row, label) =>
    table.cell(tableId, 0, row, text_size = size.tiny,
         text = label, text_color = #90CAF9,
         bgcolor = #0D2B55)
    table.merge_cells(tableId, 0, row, 1, row)

if barstate.islast
    table.clear(myTable, 0, 0, 1, TOTAL_ROWS - 1)

    if isPinnedSymbol
        // ── Header ──
        if ubs
            table.cell(myTable, 0, 0,
                 text       = " " + banner + " ",
                 text_size  = Tsize,
                 text_color = btextcolor,
                 bgcolor    = bbackgroundcolor)
            table.merge_cells(myTable, 0, 0, 1, 0)

        // ── Section ① Bias & Context ──
        f_section(myTable, 1, "① Bias & Context")

        // Rows 1-3
        for i = 1 to math.min(visibleRows, 3)
            chk  = f_checked(i)
            txt  = f_text(i)
            tableRow = i + 1
            table.cell(myTable, 0, tableRow,
                 text       = chk ? "✔" : "✘",
                 text_size  = Tsize,
                 text_color = chk ? #32CD32 : #FF4500,
                 bgcolor    = backgroundcolor)
            table.cell(myTable, 1, tableRow,
                 text       = txt,
                 text_size  = Tsize,
                 text_color = textcolor,
                 bgcolor    = backgroundcolor)

        // ── Section ② Market Structure ──
        if visibleRows >= 4
            f_section(myTable, 5, "② Market Structure")
            for i = 4 to math.min(visibleRows, 6)
                chk      = f_checked(i)
                txt      = f_text(i)
                tableRow = i + 2
                table.cell(myTable, 0, tableRow,
                     text       = chk ? "✔" : "✘",
                     text_size  = Tsize,
                     text_color = chk ? #32CD32 : #FF4500,
                     bgcolor    = backgroundcolor)
                table.cell(myTable, 1, tableRow,
                     text       = txt,
                     text_size  = Tsize,
                     text_color = textcolor,
                     bgcolor    = backgroundcolor)

        // ── Section ③ Timing & Entry ──
        if visibleRows >= 7
            f_section(myTable, 9, "③ Timing & Entry")
            for i = 7 to math.min(visibleRows, 8)
                chk      = f_checked(i)
                txt      = f_text(i)
                tableRow = i + 3
                table.cell(myTable, 0, tableRow,
                     text       = chk ? "✔" : "✘",
                     text_size  = Tsize,
                     text_color = chk ? #32CD32 : #FF4500,
                     bgcolor    = backgroundcolor)
                table.cell(myTable, 1, tableRow,
                     text       = txt,
                     text_size  = Tsize,
                     text_color = textcolor,
                     bgcolor    = backgroundcolor)

        // ── Trade Score ──
        if showTradeScore
            table.cell(myTable, 0, 12,
                 text       = "Score",
                 text_size  = Tsize,
                 text_color = #FFD700,
                 bgcolor    = #1A1A2E)
            table.cell(myTable, 1, 12,
                 text       = str.tostring(tradeScore) + "%  (" + str.tostring(checkedCount) + "/" + str.tostring(visibleRows) + ")",
                 text_size  = Tsize,
                 text_color = tradeScoreColor,
                 bgcolor    = #1A1A2E)
````
