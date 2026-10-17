# Yesterday's OCHL Session relative (JH)

- url: https://www.tradingview.com/script/zX8AIPME-Yesterday-s-OCHL-Session-relative-JH/
- type: indicator
- pine_id: PUB;aadf305d3c3e46f6b27a36212702c991
- version: 3.0

## Description

Shows the open close high and low values of the previous relative session. So if you are trading New york hours, it will display OCHL of the previous new york session. Choose if you want to see New York, London, Tokyo and New Zealand (Sunday night open) sessions

## Source Code

````pine
//@version=5
indicator("Yesterday OCHL Session Relative (JH)", overlay=true)

// --- Inputs ---
utc_offset = input.int(-4, "Your UTC Offset", minval=-12, maxval=14, tooltip="Chile is currently UTC-4")

// Session Visibility Toggles (RESTORED)
show_ny  = input.bool(true, "Show NY Session", group="Session Selection")
show_lon = input.bool(true, "Show London Session", group="Session Selection")
show_tok = input.bool(true, "Show Tokyo Session", group="Session Selection")
show_nz  = input.bool(true, "Show New Zealand Session", group="Session Selection")

// Level Visibility
show_o = input.bool(true, "Show Open", group="Levels")
show_h = input.bool(true, "Show High", group="Levels")
show_l = input.bool(true, "Show Low", group="Levels")
show_c = input.bool(true, "Show Close", group="Levels")

// Style
color_o = input.color(color.new(color.gray, 0), "Open Color", group="Style")
color_h = input.color(color.new(#00ff08, 0), "High Color", group="Style")
color_l = input.color(color.new(#ff0000, 0), "Low Color", group="Style")
color_c = input.color(color.new(color.white, 0), "Close Color", group="Style")
line_w  = input.int(1, "Line Width", minval=1, group="Style")

// --- Session Strings (Hardcoded UTC) ---
ny_sess  = "1330-2000"
lon_sess = "0700-1530"
tok_sess = "0000-0600"
nz_sess  = "2200-0445"

// --- Improved Capture Logic ---
// Isolated state handling to prevent London/NY data mixing
get_sess_data(sess_str, active) =>
    in_sess = not na(time(timeframe.period, sess_str, "UTC")) and active
    is_new  = in_sess and not in_sess[1]
    is_end  = not in_sess and in_sess[1]
    
    var float c_o = na, var float c_h = na, var float c_l = na, var float c_c = na
    var float y_o = na, var float y_h = na, var float y_l = na, var float y_c = na
    
    if in_sess
        if is_new
            // Project the data captured during the PREVIOUS instance of this window
            y_o := c_o, y_h := c_h, y_l := c_l, y_c := c_c
            // Start fresh capture for TODAY
            c_o := open
            c_h := high
            c_l := low
            c_c := close
        else
            c_h := math.max(high, nz(c_h, high))
            c_l := math.min(low, nz(c_l, low))
            c_c := close
            
    [in_sess, y_o, y_h, y_l, y_c]

// --- Execute ---
[in_ny,  ny_o,  ny_h,  ny_l,  ny_c]  = get_sess_data(ny_sess, show_ny)
[in_lon, lon_o, lon_h, lon_l, lon_c] = get_sess_data(lon_sess, show_lon)
[in_tok, tok_o, tok_h, tok_l, tok_c] = get_sess_data(tok_sess, show_tok)
[in_nz,  nz_o,  nz_h,  nz_l,  nz_c]  = get_sess_data(nz_sess, show_nz)

// --- Global Plotting ---

// New York
plot(in_ny and show_o ? ny_o : na, "NY Open",  color=color_o, style=plot.style_linebr, linewidth=line_w)
plot(in_ny and show_h ? ny_h : na, "NY High",  color=color_h, style=plot.style_linebr, linewidth=line_w)
plot(in_ny and show_l ? ny_l : na, "NY Low",   color=color_l, style=plot.style_linebr, linewidth=line_w)
plot(in_ny and show_c ? ny_c : na, "NY Close", color=color_c, style=plot.style_linebr, linewidth=line_w)

// London
plot(in_lon and show_o ? lon_o : na, "Lon Open",  color=color_o, style=plot.style_linebr, linewidth=line_w)
plot(in_lon and show_h ? lon_h : na, "Lon High",  color=color_h, style=plot.style_linebr, linewidth=line_w)
plot(in_lon and show_l ? lon_l : na, "Lon Low",   color=color_l, style=plot.style_linebr, linewidth=line_w)
plot(in_lon and show_c ? lon_c : na, "Lon Close", color=color_c, style=plot.style_linebr, linewidth=line_w)

// Tokyo
plot(in_tok and show_o ? tok_o : na, "Tok Open",  color=color_o, style=plot.style_linebr, linewidth=line_w)
plot(in_tok and show_h ? tok_h : na, "Tok High",  color=color_h, style=plot.style_linebr, linewidth=line_w)
plot(in_tok and show_l ? tok_l : na, "Tok Low",   color=color_l, style=plot.style_linebr, linewidth=line_w)
plot(in_tok and show_c ? tok_c : na, "Tok Close", color=color_c, style=plot.style_linebr, linewidth=line_w)

// New Zealand
plot(in_nz and show_o ? nz_o : na, "NZ Open",  color=color_o, style=plot.style_linebr, linewidth=line_w)
plot(in_nz and show_h ? nz_h : na, "NZ High",  color=color_h, style=plot.style_linebr, linewidth=line_w)
plot(in_nz and show_l ? nz_l : na, "NZ Low",   color=color_l, style=plot.style_linebr, linewidth=line_w)
plot(in_nz and show_c ? nz_c : na, "NZ Close", color=color_c, style=plot.style_linebr, linewidth=line_w)
````
