# Checklist Djones Group

- url: https://www.tradingview.com/script/yNclNyQT/
- type: indicator
- pine_id: PUB;a5f8132c0bc6472c8235dafa316f6764
- version: 1.0

## Description

check list djones group en 6 étapes pour confirmer le trade

## Source Code

````pine
//@version=5
indicator("Checklist Djones Group", overlay=true)

// ═══════════════════════════════════════════════
// ✅ CHECKLIST - Coche les confirmations
// ═══════════════════════════════════════════════
g1 = "Checklist de Confirmation"
check1 = input.bool(false, "1. Structure HTF (fond)", group=g1)
check2 = input.bool(false, "2. Jambe de prix HTF",    group=g1)
check3 = input.bool(false, "3. Structure & jambe LTF", group=g1)
check4 = input.bool(false, "4. Fibonacci / OTE",       group=g1)
check5 = input.bool(false, "5. Liquidite prise",       group=g1)
check6 = input.bool(false, "6. MSS + TS",              group=g1)

// ═══════════════════════════════════════════════
// 🎨 PERSONNALISATION
// ═══════════════════════════════════════════════
g2 = "Position & Taille"
posY     = input.string("bottom", "Position verticale",   options=["top","middle","bottom"], group=g2)
posX     = input.string("left",   "Position horizontale", options=["left","center","right"], group=g2)
textSize = input.string("normal", "Taille du texte",      options=["tiny","small","normal","large","huge"], group=g2)

g3 = "Couleurs"
bgColor       = input.color(color.new(#1e222d, 10), "Fond",              group=g3)
titleBgColor  = input.color(color.new(#2962ff, 0),  "Fond du titre",     group=g3)
titleTxtColor = input.color(color.white,            "Texte du titre",    group=g3)
checkedColor  = input.color(#26a69a,                "Coche",             group=g3)
uncheckedCol  = input.color(#787b86,                "Non coche",         group=g3)
borderColor   = input.color(color.new(#363a45, 0),  "Bordure",           group=g3)

// Conversion taille - via switch
sizeVal = switch textSize
    "tiny"   => size.tiny
    "small"  => size.small
    "large"  => size.large
    "huge"   => size.huge
    =>          size.normal

// Conversion position - via switch sur cle combinee
posKey = posY + "_" + posX
tablePos = switch posKey
    "bottom_left"   => position.bottom_left
    "bottom_center" => position.bottom_center
    "bottom_right"  => position.bottom_right
    "middle_left"   => position.middle_left
    "middle_center" => position.middle_center
    "middle_right"  => position.middle_right
    "top_left"      => position.top_left
    "top_center"    => position.top_center
    "top_right"     => position.top_right
    =>                 position.bottom_left

// ═══════════════════════════════════════════════
// AFFICHAGE
// ═══════════════════════════════════════════════
var table t = table.new(tablePos, 2, 9, bgcolor=bgColor, border_width=1, border_color=borderColor, frame_width=1, frame_color=borderColor)

if barstate.islast
    // Titre
    table.cell(t, 0, 0, "CHECKLIST DJONES GROUP", bgcolor=titleBgColor, text_color=titleTxtColor, text_size=sizeVal)
    table.cell(t, 1, 0, "", bgcolor=titleBgColor)
    table.merge_cells(t, 0, 0, 1, 0)

    // Les 6 points
    labels = array.from("Structure HTF (fond)", "Jambe de prix HTF", "Structure & jambe LTF", "Fibonacci / OTE", "Liquidite prise", "MSS + TS")
    checks = array.from(check1, check2, check3, check4, check5, check6)

    for i = 0 to 5
        isChecked = array.get(checks, i)
        lbl       = array.get(labels, i)
        symbol    = isChecked ? "[X]" : "[  ]"
        col       = isChecked ? checkedColor : uncheckedCol
        table.cell(t, 0, i+1, symbol, text_color=col, text_size=sizeVal)
        table.cell(t, 1, i+1, str.tostring(i+1) + ". " + lbl, text_color=col, text_size=sizeVal, text_halign=text.align_left)

    // Compteur
    count = (check1?1:0) + (check2?1:0) + (check3?1:0) + (check4?1:0) + (check5?1:0) + (check6?1:0)
    pct   = str.tostring(math.round(count * 100 / 6)) + "%"
    progTxt = "Progression : " + str.tostring(count) + "/6  (" + pct + ")"
    progCol = count == 6 ? checkedColor : count >= 4 ? color.new(color.orange, 0) : uncheckedCol
    table.cell(t, 0, 7, progTxt, text_color=progCol, text_size=sizeVal)
    table.cell(t, 1, 7, "")
    table.merge_cells(t, 0, 7, 1, 7)

    // Validation
    if count == 6
        table.cell(t, 0, 8, "SETUP VALIDE - ENTREE", bgcolor=checkedColor, text_color=color.white, text_size=sizeVal)
    else
        table.cell(t, 0, 8, "Encore " + str.tostring(6 - count) + " confirmation(s)", text_color=uncheckedCol, text_size=sizeVal)
    table.cell(t, 1, 8, "", bgcolor=count == 6 ? checkedColor : bgColor)
    table.merge_cells(t, 0, 8, 1, 8)
````
