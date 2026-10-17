# Narraytive market 

- url: https://www.tradingview.com/script/DC0Qxye0-Narraytive-market/
- type: indicator
- pine_id: PUB;2eb0635f71bf48228d21e8d01f5ea82f
- version: 1.0

## Description

Narraytive market checlist for confirm entry setup

## Source Code

````pine
//@version=6
indicator("Custom Checklist", overlay=true)

// ===== SIZE CONTROL =====
sizeOption = input.string("Small", "Checklist Size", options = ["Tiny", "Small", "Normal"])
textSize = sizeOption == "Tiny" ? size.tiny :
           sizeOption == "Small" ? size.small :
           size.normal

// ===== COLOR SETTINGS =====
bgColor        = input.color(color.black, "Background Color")
bgTransparency = input.int(85, "Background Transparency (0-100)", minval=0, maxval=100)
borderColor    = input.color(color.gray, "Border Color")
textColor      = input.color(color.white, "Text Color")
checkColor     = input.color(color.lime, "Checkmark Color")

// ===== NUMBER OF ITEMS =====
maxItems = input.int(6, "Number of Checklist Items", minval=1, maxval=15)

// ===== ITEM TEXT + CHECKS =====
item1  = input.string("Item 1",  "Item 1 Text")
item2  = input.string("",        "Item 2 Text")
item3  = input.string("",        "Item 3 Text")
item4  = input.string("",        "Item 4 Text")
item5  = input.string("",        "Item 5 Text")
item6  = input.string("",        "Item 6 Text")
item7  = input.string("",        "Item 7 Text")
item8  = input.string("",        "Item 8 Text")
item9  = input.string("",        "Item 9 Text")
item10 = input.string("",        "Item 10 Text")
item11 = input.string("",        "Item 11 Text")
item12 = input.string("",        "Item 12 Text")
item13 = input.string("",        "Item 13 Text")
item14 = input.string("",        "Item 14 Text")
item15 = input.string("",        "Item 15 Text")

check1  = input.bool(false, "Item 1 Checked")
check2  = input.bool(false, "Item 2 Checked")
check3  = input.bool(false, "Item 3 Checked")
check4  = input.bool(false, "Item 4 Checked")
check5  = input.bool(false, "Item 5 Checked")
check6  = input.bool(false, "Item 6 Checked")
check7  = input.bool(false, "Item 7 Checked")
check8  = input.bool(false, "Item 8 Checked")
check9  = input.bool(false, "Item 9 Checked")
check10 = input.bool(false, "Item 10 Checked")
check11 = input.bool(false, "Item 11 Checked")
check12 = input.bool(false, "Item 12 Checked")
check13 = input.bool(false, "Item 13 Checked")
check14 = input.bool(false, "Item 14 Checked")
check15 = input.bool(false, "Item 15 Checked")

// ===== STORE IN ARRAYS =====
texts  = array.from(item1,item2,item3,item4,item5,item6,item7,item8,item9,item10,item11,item12,item13,item14,item15)
checks = array.from(check1,check2,check3,check4,check5,check6,check7,check8,check9,check10,check11,check12,check13,check14,check15)

// ===== TABLE =====
var table checklist = table.new(position.top_right, 2, 16,
     bgcolor = color.new(bgColor, bgTransparency),
     frame_color = borderColor,
     frame_width = 1)

if barstate.islast
    table.cell(checklist, 0, 0, "Narraytive Market", text_color=textColor, text_size=textSize)
    table.cell(checklist, 1, 0, "")

    for i = 0 to maxItems - 1
        txt = array.get(texts, i)
        chk = array.get(checks, i)
        if txt != ""
            table.cell(checklist, 0, i + 1, txt, text_color=textColor, text_size=textSize)
            table.cell(checklist, 1, i + 1, chk ? "✓" : "", text_color=checkColor, text_size=textSize)
````
