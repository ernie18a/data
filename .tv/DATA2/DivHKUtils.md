<!-- tradingview-pine-id: PUB;dc684ad0af8942cb888958db43e50e3e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# DivHK_Utils

Source: https://www.tradingview.com/script/a8kLjihB/

## Description

Library  "DivHK_Utils"

tbl_pos_fn(p)
  Parameters:
    p (string)

tbl_pos_score_fn(p)
  Parameters:
    p (string)

stars(k)
  Parameters:
    k (int)

f_pct(v)
  Parameters:
    v (float)

f_st(v)
  Parameters:
    v (float)

f_sf(v)
  Parameters:
    v (float)

bname_fn(branch_id)
  Parameters:
    branch_id (int)

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © S-Schmidt
//@version=6

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  DivHK_Utils  —  Hilfsfunktionen für das Dividenden Handelssystem HK       ║
// ║  Library v1 · Gemeinsam genutzte Utilities für alle 9 Indikatoren           ║
// ║                                                                              ║
// ║  Enthält:                                                                    ║
// ║    tbl_pos_fn()       — Tabellen-Position aus String                         ║
// ║    tbl_pos_score_fn() — Tabellen-Position (Score-Variante, mehr Optionen)    ║
// ║    stars()            — Stern-Symbole für Signalstärke                       ║
// ║    f_pct()            — Perzentil-Wert formatieren                           ║
// ║    f_st()             — State (0/1/2) als Text                               ║
// ║    f_sf()             — Stufe (1/2/3) als Text                               ║
// ║    bname_fn()         — Branch-ID → lesbarer Name                            ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

library("DivHK_Utils", overlay=false)

// ──────────────────────────────────────────────────────────────────────────────
// tbl_pos_fn
// Verwendung: Reversal-Systeme + Master_RS  (4 Optionen: TR/TL/BR/BL)
// ──────────────────────────────────────────────────────────────────────────────
export tbl_pos_fn(string p) =>
    // @param p  — Position-String: "Top Right" | "Top Left" | "Bottom Right" | "Bottom Left"
    // @returns  — Pine-Script position.*-Konstante
    string result = position.top_right
    if p == "Top Left"
        result := position.top_left
    else if p == "Bottom Right"
        result := position.bottom_right
    else if p == "Bottom Left"
        result := position.bottom_left
    result

// ──────────────────────────────────────────────────────────────────────────────
// tbl_pos_score_fn
// Verwendung: Score-Indikatoren (mehr Optionen inkl. center + middle)
// ──────────────────────────────────────────────────────────────────────────────
export tbl_pos_score_fn(string p) =>
    // @param p  — Position-String: "top_left" | "top_center" | "top_right" |
    //             "middle_left" | "middle_right" | "bottom_left" | "bottom_right"
    // @returns  — Pine-Script position.*-Konstante
    string result = position.top_right
    if p == "top_left"
        result := position.top_left
    else if p == "top_center"
        result := position.top_center
    else if p == "middle_left"
        result := position.middle_left
    else if p == "middle_right"
        result := position.middle_right
    else if p == "bottom_left"
        result := position.bottom_left
    else if p == "bottom_right"
        result := position.bottom_right
    result

// ──────────────────────────────────────────────────────────────────────────────
// stars
// Stern-Label für Signalstärke (Konsens-Zähler 1–4)
// ──────────────────────────────────────────────────────────────────────────────
export stars(int k) =>
    // @param k  — Anzahl bestätigender Zyklen (1–4)
    // @returns  — String mit entsprechend vielen Sternen
    string result = "****"
    if k == 1
        result := "*"
    else if k == 2
        result := "**"
    else if k == 3
        result := "***"
    result

// ──────────────────────────────────────────────────────────────────────────────
// f_pct
// Perzentil-Rang als lesbarer String  (z.B. "P47.3")
// ──────────────────────────────────────────────────────────────────────────────
export f_pct(float v) =>
    // @param v  — Perzentil-Rang 0.0–100.0 (na erlaubt)
    // @returns  — "P##.#" oder "-"
    na(v) ? "-" : "P" + str.tostring(math.round(v, 1))

// ──────────────────────────────────────────────────────────────────────────────
// f_st
// State-Integer (0/1/2) als lesbarer String
// ──────────────────────────────────────────────────────────────────────────────
export f_st(float v) =>
    // @param v  — State als float (0=NEUTRAL · 1=LONG · 2=SHORT · na=unbekannt)
    // @returns  — "NEUTRAL" | "< LONG" | "> SHORT" | "-"
    string result = "NEUTRAL"
    if na(v)
        result := "-"
    else if v == 1.0
        result := "< LONG"
    else if v == 2.0
        result := "> SHORT"
    result

// ──────────────────────────────────────────────────────────────────────────────
// f_sf
// Stufe-Integer (1/2/3) als lesbarer String
// ──────────────────────────────────────────────────────────────────────────────
export f_sf(float v) =>
    // @param v  — Stufe als float (1=P10/P90 · 2=P1/P99 · 3=P0.01/P99.99)
    // @returns  — "St.1 (P10)" | "St.2 (P1)" | "St.3 (P0.01)" | "-"
    string result = "-"
    if v == 1.0
        result := "St.1 (P10)"
    else if v == 2.0
        result := "St.2 (P1)"
    else if v == 3.0
        result := "St.3 (P0.01)"
    result

// ──────────────────────────────────────────────────────────────────────────────
// bname_fn
// Branch-ID (0–7) → lesbarer Branchen-Name
// ──────────────────────────────────────────────────────────────────────────────
export bname_fn(int branch_id) =>
    // @param branch_id  — Branchen-ID aus dem is_member()-Dispatch (0–7 oder -1)
    // @returns          — Lesbarer Branchen-Name
    string result = "- Unbekannt -"
    if branch_id == 0
        result := "B0 · Transport"
    else if branch_id == 1
        result := "B1 · Konsum"
    else if branch_id == 2
        result := "B2 · Versorger"
    else if branch_id == 3
        result := "B3 · Telekom"
    else if branch_id == 4
        result := "B4 · Finanz"
    else if branch_id == 5
        result := "B5 · REIT"
    else if branch_id == 6
        result := "B6 · Energie"
    else if branch_id == 7
        result := "B7 · Auto"
    result
````
