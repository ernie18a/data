# CE ORG

- url: https://www.tradingview.com/script/cyInjx60-CE-ORG/
- type: indicator
- pine_id: PUB;833435ca9f3045d9b71732a7794104e7
- version: 1.0

## Description

This line represents the CE of the Opening Range Gap measured from Monday through Friday of the current week

## Source Code

````pine
//@version=5
indicator("CE ORG", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ── INPUTS ──
mid_color_up = input.color(color.new(color.blue, 0), "Màu Gap Up",   inline = "c")
mid_color_dn = input.color(color.new(color.red,  0), "Màu Gap Down", inline = "c")
show_label   = input.bool(true, "Hiện label thứ/ngày")
line_width   = input.int(1, "Độ dày đường", 1, 4)

// ── HÀM TÊN THỨ ──
day_name(d) =>
    switch d
        1 => "CN"
        2 => "T2"
        3 => "T3"
        4 => "T4"
        5 => "T5"
        6 => "T6"
        7 => "T7"
        => "??"

// ── MẢNG LƯU LINE & LABEL ĐỂ CẬP NHẬT VỊ TRÍ TEXT CUỐI LINE ──
var line[]  all_lines  = array.new_line()
var label[] all_labels = array.new_label()

// ── CHỈ CHẠY TRÊN KHUNG 1H hoặc nhỏ hơn ──
if timeframe.in_seconds() <= timeframe.in_seconds("60")

    is_close_16 = hour(time, "America/New_York") == 16 and minute(time, "America/New_York") == 0
    is_open_930 = hour(time, "America/New_York") == 9  and minute(time, "America/New_York") == 30

    var float close_1600 = na
    var int   time_1600  = na

    if is_close_16
        close_1600 := close
        time_1600  := time

    // Vẽ midline khi gặp nến 9h30
    if is_open_930 and not na(close_1600)

        float price_open_930 = open
        float price_close_16 = close_1600

        float top = math.max(price_open_930, price_close_16)
        float bot = math.min(price_open_930, price_close_16)
        float mid = (top + bot) / 2

        bool is_gap_up = price_open_930 > price_close_16
        color c = is_gap_up ? mid_color_up : mid_color_dn

        // Chỉ lấy cặp trong tuần T2-T6 hiện tại, cách nhau <= 4 ngày
        int diff_days = math.round((time - time_1600) / 86400000)

        int dow_930  = dayofweek(time,       "America/New_York")
        int dow_1600 = dayofweek(time_1600,  "America/New_York")

        // T2=2, T3=3, T4=4, T5=5, T6=6 — lọc đúng tuần T2-T6
        bool valid_days = dow_930  >= 2 and dow_930  <= 6 and
                          dow_1600 >= 2 and dow_1600 <= 6 and
                          diff_days <= 4

        // Chỉ vẽ nếu thuộc tuần hiện tại
        bool this_week = weekofyear(time) == weekofyear(timenow) and
                         year(time) == year(timenow)

        if valid_days and this_week
            int   d       = dayofmonth(time, "America/New_York")
            int   m       = month(time,      "America/New_York")
            string lbl_txt = "CE ORG " + day_name(dow_930) + " " + str.tostring(d) + "/" + str.tostring(m)

            // Vẽ line
            ln = line.new(
                 x1     = time,
                 y1     = mid,
                 x2     = time + 1,
                 y2     = mid,
                 xloc   = xloc.bar_time,
                 color  = c,
                 style  = line.style_solid,
                 width  = line_width,
                 extend = extend.right)
            all_lines.unshift(ln)

            // Label đặt tạm, sẽ cập nhật vị trí x cuối bar liên tục bên dưới
            if show_label
                lb = label.new(
                     x         = time,
                     y         = mid,
                     text      = lbl_txt,
                     xloc      = xloc.bar_time,
                     style     = label.style_label_left,
                     color     = color.new(color.white, 0),
                     textcolor = c,
                     size      = size.normal)
                all_labels.unshift(lb)

    // ── CẬP NHẬT VỊ TRÍ LABEL VỀ CUỐI BAR HIỆN TẠI (real-time) ──
    if show_label and all_labels.size() > 0
        for i = 0 to all_labels.size() - 1
            all_labels.get(i).set_x(time)
````
