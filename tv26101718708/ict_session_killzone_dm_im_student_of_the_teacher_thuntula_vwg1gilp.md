# ICT Session & Killzone[ DM ] I'm Student of the teacher ThunTula

- url: https://www.tradingview.com/script/VWG1gILp-ICT-Session-Killzone-DM-I-m-Student-of-the-teacher-ThunTula/
- type: indicator
- pine_id: PUB;cd7f0350f6a940398cc0ab7e96563714
- version: 1.0

## Description

I'm Student of the teacher ThunTula 
Indicator by DMKING that Student of the Teacher ThunTula

## Source Code

````pine
//@version=5
indicator("ICT Session & Killzone [ DM ]", overlay=true, max_boxes_count=500, max_lines_count=500)

// --- Timezone ---
tz = "Asia/Bangkok" // ម៉ោងនៅខ្មែរ (GMT+7)

// --- 1. ប៊ូតុងបិទ/បើក (Toggles) ---
grp1 = "បិទ/បើក ប្រអប់ (SHOW / HIDE)"
showAsiaS = input.bool(true, "Asia Session", inline="A", group=grp1)
showAsiaK = input.bool(true, "Asia Killzone", inline="A", group=grp1)
showLonS  = input.bool(true, "London Session", inline="B", group=grp1)
showLonK  = input.bool(true, "London Killzone", inline="B", group=grp1)
showNYS   = input.bool(true, "NY Session", inline="C", group=grp1)
showNYK   = input.bool(true, "NY Killzone", inline="C", group=grp1)

showHL    = input.bool(true, "បង្ហាញបន្ទាត់ High/Low (Liquidity)", group=grp1)

// --- 2. កំណត់ម៉ោង (Times) ---
grp2 = "កំណត់ម៉ោង (TIME SETTINGS - ម៉ោងខ្មែរ)"
t_AsiaS = input.session("0700-1300", "Asia Session", group=grp2)
t_AsiaK = input.session("0800-1000", "Asia Killzone", group=grp2)
t_LonS  = input.session("1400-1800", "London Session", group=grp2)
t_LonK  = input.session("1400-1700", "London Killzone", group=grp2)
t_NYS   = input.session("1900-2300", "NY Session", group=grp2)
t_NYK   = input.session("2000-2300", "NY Killzone", group=grp2)

// --- 3. កំណត់ពណ៌ (Colors) ---
grp3 = "កំណត់ពណ៌ (COLORS & STYLE)"
c_AsiaS = input.color(color.new(color.blue, 90), "Asia Session", inline="C1", group=grp3)
c_AsiaK = input.color(color.new(color.teal, 70), "Asia Killzone", inline="C1", group=grp3)
c_LonS  = input.color(color.new(color.orange, 90), "London Session", inline="C2", group=grp3)
c_LonK  = input.color(color.new(color.red, 70), "London Killzone", inline="C2", group=grp3)
c_NYS   = input.color(color.new(color.purple, 90), "NY Session", inline="C3", group=grp3)
c_NYK   = input.color(color.new(color.fuchsia, 70), "NY Killzone", inline="C3", group=grp3)

c_Line  = input.color(color.new(color.gray, 30), "ពណ៌បន្ទាត់ High/Low", group=grp3)

// --- 4. មុខងារគូសប្រអប់ និងបន្ទាត់ (Core Function) ---
f_draw(_sess, _showBox, _cBox, _showHL, _title) =>
    inSess = time(timeframe.period, _sess, tz)
    isStart = inSess and not inSess[1]
    
    var box b = na
    var line l_H = na
    var line l_L = na
    var label lbl_H = na
    var label lbl_L = na
    
    var float h = na
    var float l = na
    var int sIdx = na
    
    if isStart
        h := high
        l := low
        sIdx := bar_index
        if _showBox
            b := box.new(sIdx, h, bar_index, l, bgcolor=_cBox, border_color=_cBox, border_width=1)
        if _showHL
            // បង្កើតបន្ទាត់ និងឈ្មោះ
            l_H := line.new(sIdx, h, bar_index, h, color=c_Line, style=line.style_dashed)
            l_L := line.new(sIdx, l, bar_index, l, color=c_Line, style=line.style_dashed)
            lbl_H := label.new(bar_index, h, _title + " H", style=label.style_label_down, color=color.new(color.white, 100), textcolor=c_Line, size=size.small)
            lbl_L := label.new(bar_index, l, _title + " L", style=label.style_label_up, color=color.new(color.white, 100), textcolor=c_Line, size=size.small)
            
    if inSess
        h := math.max(h, high)
        l := math.min(l, low)
        if _showBox
            box.set_top(b, h)
            box.set_bottom(b, l)
            box.set_right(b, bar_index)
        if _showHL
            // អាប់ដេតបន្ទាត់ឱ្យរត់តាមតម្លៃ High/Low ថ្មី ហើយអូសទៅមុខបន្តិច
            line.set_y1(l_H, h)
            line.set_y2(l_H, h)
            line.set_x2(l_H, bar_index + 10) 
            label.set_x(lbl_H, bar_index + 10)
            label.set_y(lbl_H, h)
            
            line.set_y1(l_L, l)
            line.set_y2(l_L, l)
            line.set_x2(l_L, bar_index + 10)
            label.set_x(lbl_L, bar_index + 10)
            label.set_y(lbl_L, l)

// --- 5. ហៅមុខងារមកប្រើ (Execution) ---
// យើងគូស High/Low តែសម្រាប់ Session បានហើយ ដើម្បីកុំឱ្យ Chart ញ៉េញ៉ៃពេក
f_draw(t_AsiaS, showAsiaS, c_AsiaS, showHL, "Asia")
f_draw(t_AsiaK, showAsiaK, c_AsiaK, false, "") 
f_draw(t_LonS,  showLonS,  c_LonS,  showHL, "Lon")
f_draw(t_LonK,  showLonK,  c_LonK,  false, "")
f_draw(t_NYS,   showNYS,   c_NYS,   showHL, "NY")
f_draw(t_NYK,   showNYK,   c_NYK,   false, "")
````
