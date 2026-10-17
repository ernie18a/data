# macro moneyreaper

- url: https://www.tradingview.com/script/az8Gikhs/
- type: indicator
- pine_id: PUB;57c4b3f4aac044a48802916009034369
- version: 1.0

## Description

Macro ICT pour avoir les box avec horaires et indications si ce sera une expansion - retracement - reversal etc 

Indicateur fait par un amateur

## Source Code

````pine
//@version=6
indicator("📦 Macros ICT Classiques", overlay = true, max_boxes_count = 500, max_labels_count = 500)

// ═══════════════════════════════════════════════════════════════
// FUSEAU HORAIRE
// ═══════════════════════════════════════════════════════════════
tz_labels = input.string("New York (ET)", "🌍 Affichage des heures",
     options = ["New York (ET)", "Paris (+6h)"],
     tooltip = "La détection est toujours en heure New York.")

// ═══════════════════════════════════════════════════════════════
// RÉGLAGES VISUELS
// ═══════════════════════════════════════════════════════════════
grp_ui = "⚙️ Réglages visuels"
show_label    = input.bool(true, "Afficher les labels", group = grp_ui)
label_pos     = input.string("Intérieur — milieu", "📍 Position du label",
     options = ["Intérieur — haut", "Intérieur — milieu", "Intérieur — bas",
                "Extérieur — au-dessus", "Extérieur — en-dessous"],
     group = grp_ui)
label_size    = input.string("small", "Taille du texte",
     options = ["tiny", "small", "normal", "large", "huge"], group = grp_ui)
label_txt_col = input.color(color.new(color.black, 0),  "Couleur du texte", group = grp_ui)
label_bg_col  = input.color(color.new(color.white, 10), "Fond des labels",  group = grp_ui)
box_border_w  = input.int(1, "Épaisseur bordure", minval = 1, maxval = 4, group = grp_ui)
box_style_inp = input.string("solid", "Style de bordure",
     options = ["solid", "dashed", "dotted"], group = grp_ui)

border_style = box_style_inp == "dashed" ? line.style_dashed : box_style_inp == "dotted" ? line.style_dotted : line.style_solid
ls = label_size == "tiny" ? size.tiny : label_size == "small" ? size.small : label_size == "large" ? size.large : label_size == "huge" ? size.huge : size.normal

// ═══════════════════════════════════════════════════════════════
// 8 MACROS ICT CLASSIQUES
// ═══════════════════════════════════════════════════════════════
grp_1 = "① 02:33 – 03:00 · Londres — Accum / Sweep"
show_1 = input.bool(true, "Afficher", group = grp_1)
col_1  = input.color(color.new(color.red, 75), "Couleur box", group = grp_1)

grp_2 = "② 04:03 – 04:30 · Londres — Exp"
show_2 = input.bool(true, "Afficher", group = grp_2)
col_2  = input.color(color.new(color.teal, 75), "Couleur box", group = grp_2)

grp_3 = "③ 08:50 – 09:10 · Pré-ouverture NY — Accum"
show_3 = input.bool(true, "Afficher", group = grp_3)
col_3  = input.color(color.new(color.gray, 75), "Couleur box", group = grp_3)

grp_4 = "④ 09:50 – 10:10 · NY AM — Exp ⭐"
show_4 = input.bool(true, "Afficher", group = grp_4)
col_4  = input.color(color.new(color.teal, 68), "Couleur box", group = grp_4)

grp_5 = "⑤ 10:50 – 11:10 · NY AM — Accum / Retr"
show_5 = input.bool(true, "Afficher", group = grp_5)
col_5  = input.color(color.new(color.blue, 75), "Couleur box", group = grp_5)

grp_6 = "⑥ 11:50 – 12:10 · Lunch — Range ⚠"
show_6 = input.bool(true, "Afficher", group = grp_6)
col_6  = input.color(color.new(color.yellow, 75), "Couleur box", group = grp_6)

grp_7 = "⑦ 13:10 – 13:40 · NY PM — Exp"
show_7 = input.bool(true, "Afficher", group = grp_7)
col_7  = input.color(color.new(color.teal, 68), "Couleur box", group = grp_7)

grp_8 = "⑧ 15:15 – 15:45 · Dernière heure — Exp finale ⚠"
show_8 = input.bool(true, "Afficher", group = grp_8)
col_8  = input.color(color.new(color.red, 65), "Couleur box", group = grp_8)

// ═══════════════════════════════════════════════════════════════
// DÉTECTION HORAIRE
// ═══════════════════════════════════════════════════════════════
f_in_range(int sh, int sm, int eh, int em) =>
    int h   = hour(time, "America/New_York")
    int m   = minute(time, "America/New_York")
    int now = h * 60 + m
    now >= (sh * 60 + sm) and now < (eh * 60 + em)

// ═══════════════════════════════════════════════════════════════
// TEXTE DU LABEL
// ═══════════════════════════════════════════════════════════════
f_hm(int h, int m) =>
    string mm = m < 10 ? "0" + str.tostring(m) : str.tostring(m)
    str.tostring(h) + ":" + mm

f_label(string title, string role, int sh, int sm, int eh, int em) =>
    if tz_labels == "Paris (+6h)"
        title + " · " + role + "\n" + f_hm((sh + 6) % 24, sm) + "–" + f_hm((eh + 6) % 24, em)
    else
        title + " · " + role + "\n" + f_hm(sh, sm) + "–" + f_hm(eh, em)

// ═══════════════════════════════════════════════════════════════
// DESSIN
// Chaque bloc if est indépendant — aucun if/else ne mélange box et label
// ═══════════════════════════════════════════════════════════════
drawMacro(bool show, bool in_range, color col, string lbl) =>
    var box   b        = na
    var label lb       = na
    var bool  created  = false

    if show and in_range
        bool is_first = na(b) or not in_range[1]
        bool is_ext   = label_pos == "Extérieur — au-dessus" or label_pos == "Extérieur — en-dessous"

        // ── Première bougie ─────────────────────────────────────
        if is_first
            created := true

            // Alignement vertical du texte interne
            string v_align = text.align_center
            if label_pos == "Intérieur — haut"
                v_align := text.align_top
            if label_pos == "Intérieur — bas"
                v_align := text.align_bottom

            // Créer la box — avec texte intégré si mode intérieur
            string box_text = ""
            if show_label and not is_ext
                box_text := lbl

            b := box.new(
                 bar_index, high, bar_index, low,
                 border_color = col, border_width = box_border_w,
                 border_style = border_style, bgcolor = col,
                 text = box_text, text_size = ls, text_color = label_txt_col,
                 text_halign = text.align_center, text_valign = v_align)

            // Créer le label extérieur indépendamment
            if show_label and is_ext
                float  lbl_y   = label_pos == "Extérieur — au-dessus" ? high : low
                string lbl_sty = label_pos == "Extérieur — au-dessus" ? label.style_label_up : label.style_label_down
                lb := label.new(bar_index, lbl_y, lbl,
                      style = lbl_sty, size = ls,
                      color = label_bg_col, textcolor = label_txt_col)

        // ── Bougies suivantes : étendre la box ──────────────────
        if not is_first
            box.set_right(b,  bar_index)
            box.set_top(b,    math.max(box.get_top(b),    high))
            box.set_bottom(b, math.min(box.get_bottom(b), low))

            // Recentrer le label extérieur au milieu de la box
            if show_label and not na(lb)
                int mid_x = math.round((box.get_left(b) + box.get_right(b)) / 2)
                label.set_x(lb, mid_x)
                if label_pos == "Extérieur — au-dessus"
                    label.set_y(lb, box.get_top(b))
                if label_pos == "Extérieur — en-dessous"
                    label.set_y(lb, box.get_bottom(b))

// ═══════════════════════════════════════════════════════════════
// APPELS
// ═══════════════════════════════════════════════════════════════
drawMacro(show_1, f_in_range( 2, 33,  3,  0), col_1, f_label("① LDN",    "Accum · Sweep",  2, 33,  3,  0))
drawMacro(show_2, f_in_range( 4,  3,  4, 30), col_2, f_label("② LDN",    "Exp",            4,  3,  4, 30))
drawMacro(show_3, f_in_range( 8, 50,  9, 10), col_3, f_label("③ Pré-NY", "Accum",          8, 50,  9, 10))
drawMacro(show_4, f_in_range( 9, 50, 10, 10), col_4, f_label("④ NY AM",  "Exp ⭐",         9, 50, 10, 10))
drawMacro(show_5, f_in_range(10, 50, 11, 10), col_5, f_label("⑤ NY AM",  "Accum · Retr",  10, 50, 11, 10))
drawMacro(show_6, f_in_range(11, 50, 12, 10), col_6, f_label("⑥ Lunch",  "Range ⚠",       11, 50, 12, 10))
drawMacro(show_7, f_in_range(13, 10, 13, 40), col_7, f_label("⑦ NY PM",  "Exp",           13, 10, 13, 40))
drawMacro(show_8, f_in_range(15, 15, 15, 45), col_8, f_label("⑧ Close",  "Exp finale ⚠",  15, 15, 15, 45))

// ═══════════════════════════════════════════════════════════════
// AVERTISSEMENT TF TROP ÉLEVÉ
// ═══════════════════════════════════════════════════════════════
if not timeframe.isintraday and barstate.islast
    label.new(bar_index, high, "⚠️ Passez sur un TF intraday (M1–M30)",
         style = label.style_label_left, color = color.red,
         textcolor = color.white, size = size.normal)
````
