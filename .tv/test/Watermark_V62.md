<!-- tradingview-pine-id: PUB;1c8712d5e6864576b8e7f5759d73d274 -->
<!-- tradingviewscripts-format: 1 -->
# Watermark V6.2

Source: https://www.tradingview.com/script/9XtDVH57-Watermark-Personalise-Quote/

## Description

Day trading is a mountain. 
On top of remembering your strategy, you can forget your standards. 
Write your standard on chart so you never trade out of character.
Use the pine script and change quote on line 23, leave everything else.

---

## Source Code

````pine
//@version=6
indicator("Watermark V6.2", overlay = true)

// ── Positions & visibility ──
show_sym = input.bool(true, "Show Watermark")

sym_pos = input.string("top_center", "Watermark Position",
     options = ["top_left","top_center","top_right",
                "middle_left","middle_center","middle_right",
                "bottom_left","bottom_center","bottom_right"])

// ── Styling ──
bg    = input.color(color.new(color.white, 100), "Background")
c_sub = input.color(color.new(color.white, 30), "Text Color")

s_sub = input.string("normal", "Text Size",
     options = ["tiny","small","normal","large","huge"])

a_sub = input.string("center", "Text Align",
     options = ["left","center","right"])

// ── Watermark text ──
watermark_text = "No matter how hungry, the Lion never eats grass"

// ── Create table once ──
var table symTable = table.new(position = sym_pos, columns = 1, rows = 1, bgcolor = bg, border_width = 0)

// ── Update on last bar ──
if show_sym and barstate.islast
    table.cell(symTable, 0, 0, watermark_text,
         text_color = c_sub,
         text_size = s_sub,
         text_halign = a_sub)
````
