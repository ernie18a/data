// PanelView.mqh
// Lightweight chart-object panel used by Daily Risk Monitor Lite.
// This module owns:
// - object creation,
// - layout coordinates,
// - text and color refresh,
// - custom drag behavior for the whole panel.

#ifndef __DAILY_RISK_MONITOR_LITE_PANELVIEW_MQH__
#define __DAILY_RISK_MONITOR_LITE_PANELVIEW_MQH__

#include "RiskCalc.mqh"

// Stable object names used by the panel so refreshes can update in place.
#define DRML_OBJECT_PREFIX   "DRML_"
#define DRML_PANEL_BG        "DRML_PANEL_BG"
#define DRML_TITLE           "DRML_TITLE"
#define DRML_STATUS_LABEL    "DRML_STATUS_LABEL"
#define DRML_STATUS_VALUE    "DRML_STATUS_VALUE"
#define DRML_TOTAL_LABEL     "DRML_TOTAL_LABEL"
#define DRML_TOTAL_VALUE     "DRML_TOTAL_VALUE"
#define DRML_REALIZED_LABEL  "DRML_REALIZED_LABEL"
#define DRML_REALIZED_VALUE  "DRML_REALIZED_VALUE"
#define DRML_FLOATING_LABEL  "DRML_FLOATING_LABEL"
#define DRML_FLOATING_VALUE  "DRML_FLOATING_VALUE"
#define DRML_DD_LABEL        "DRML_DD_LABEL"
#define DRML_DD_VALUE        "DRML_DD_VALUE"

// Input-driven panel appearance settings.
struct DRMLPanelConfig
  {
   ENUM_BASE_CORNER corner;         // Anchor corner used by MT5 chart objects.
   int              x_offset;       // Horizontal distance from the anchor corner.
   int              y_offset;       // Vertical distance from the anchor corner.
   int              font_size;      // Base text size used across the panel.
   color            panel_bg_color; // Background fill color.
   color            safe_color;     // Color for SAFE status and positive values.
   color            warn_color;     // Color for WARNING status.
   color            danger_color;   // Color for DANGER status and negative values.
  };

// Chart-object based panel wrapper.
class CDRMLPanelView
  {
private:
   long            m_chart_id;
   DRMLPanelConfig m_config;
   string          m_font_name;
   color           m_label_color;
   color           m_text_color;
   int             m_panel_width;
   int             m_panel_height;
   int             m_padding_x;
   int             m_padding_y;
   int             m_row_step;
   bool            m_is_dragging;
   bool            m_left_button_down;
   int             m_drag_offset_x;
   int             m_drag_offset_y;
   bool            m_mouse_scroll_saved;
   bool            m_saved_mouse_scroll;

public:
   // Constructor sets conservative default values so the object is always in a
   // valid state before Setup() receives indicator inputs.
                     CDRMLPanelView(void)
                       {
                        m_chart_id = 0;
                        m_font_name = "Consolas";
                        m_label_color = clrSilver;
                        m_text_color = clrWhiteSmoke;
                        m_panel_width = 280;
                        m_panel_height = 170;
                        m_padding_x = 12;
                        m_padding_y = 10;
                        m_row_step = 24;
                        m_is_dragging = false;
                        m_left_button_down = false;
                        m_drag_offset_x = 0;
                        m_drag_offset_y = 0;
                        m_mouse_scroll_saved = false;
                        m_saved_mouse_scroll = true;
                        m_config.corner = CORNER_LEFT_UPPER;
                        m_config.x_offset = 16;
                        m_config.y_offset = 24;
                        m_config.font_size = 10;
                        m_config.panel_bg_color = clrBlack;
                        m_config.safe_color = clrLimeGreen;
                        m_config.warn_color = clrGold;
                        m_config.danger_color = clrTomato;
                       }

   // Stores the target chart id and the panel appearance settings.
   void              Setup(const long chart_id,const DRMLPanelConfig &config)
                       {
                        m_chart_id = chart_id;
                        m_config.corner = config.corner;
                        m_config.x_offset = config.x_offset;
                        m_config.y_offset = config.y_offset;
                        m_config.font_size = config.font_size;
                        m_config.panel_bg_color = config.panel_bg_color;
                        m_config.safe_color = config.safe_color;
                        m_config.warn_color = config.warn_color;
                        m_config.danger_color = config.danger_color;
                        m_is_dragging = false;
                        m_left_button_down = false;
                        m_mouse_scroll_saved = false;
                        RecalculateMetrics();
                       }

   // Ensures that all panel objects exist and have their expected geometry.
   // This function is intentionally idempotent so refresh code can call it
   // safely after reloads or partial object removal.
   bool              Create(void)
                       {
                        RecalculateMetrics();

                        if(!EnsureBackground())
                           return false;

                        if(!EnsureTextObject(DRML_TITLE,LeftTextX(),RowY(0),ANCHOR_LEFT_UPPER,m_config.font_size + 1))
                           return false;
                        if(!EnsureTextObject(DRML_STATUS_LABEL,LeftTextX(),RowY(1),ANCHOR_LEFT_UPPER,m_config.font_size))
                           return false;
                        if(!EnsureTextObject(DRML_STATUS_VALUE,RightTextX(),RowY(1),ANCHOR_RIGHT_UPPER,m_config.font_size))
                           return false;
                        if(!EnsureTextObject(DRML_TOTAL_LABEL,LeftTextX(),RowY(2),ANCHOR_LEFT_UPPER,m_config.font_size))
                           return false;
                        if(!EnsureTextObject(DRML_TOTAL_VALUE,RightTextX(),RowY(2),ANCHOR_RIGHT_UPPER,m_config.font_size))
                           return false;
                        if(!EnsureTextObject(DRML_REALIZED_LABEL,LeftTextX(),RowY(3),ANCHOR_LEFT_UPPER,m_config.font_size))
                           return false;
                        if(!EnsureTextObject(DRML_REALIZED_VALUE,RightTextX(),RowY(3),ANCHOR_RIGHT_UPPER,m_config.font_size))
                           return false;
                        if(!EnsureTextObject(DRML_FLOATING_LABEL,LeftTextX(),RowY(4),ANCHOR_LEFT_UPPER,m_config.font_size))
                           return false;
                        if(!EnsureTextObject(DRML_FLOATING_VALUE,RightTextX(),RowY(4),ANCHOR_RIGHT_UPPER,m_config.font_size))
                           return false;
                        if(!EnsureTextObject(DRML_DD_LABEL,LeftTextX(),RowY(5),ANCHOR_LEFT_UPPER,m_config.font_size))
                           return false;
                        if(!EnsureTextObject(DRML_DD_VALUE,RightTextX(),RowY(5),ANCHOR_RIGHT_UPPER,m_config.font_size))
                           return false;

                        return true;
                       }

   // Handles custom drag logic for the full panel. Dragging starts when the
   // left mouse button is pressed inside the panel rectangle and continues
   // until the button is released.
   bool              HandleChartEvent(const int id,
                                      const long &lparam,
                                      const double &dparam,
                                      const string &sparam)
                       {
                        if(id != CHARTEVENT_MOUSE_MOVE)
                           return false;

                        const int mouse_x = (int)lparam;
                        const int mouse_y = (int)dparam;
                        const int mouse_state = (int)StringToInteger(sparam);
                        const bool left_button_down = ((mouse_state & 1) == 1);

                        int panel_left = 0;
                        int panel_top = 0;
                        GetPanelScreenPosition(panel_left,panel_top);

                        if(left_button_down && !m_left_button_down && PointInsidePanel(mouse_x,mouse_y,panel_left,panel_top))
                          {
                           m_is_dragging = true;
                           m_drag_offset_x = mouse_x - panel_left;
                           m_drag_offset_y = mouse_y - panel_top;
                           SaveMouseScrollState();
                           ChartSetInteger(m_chart_id,CHART_MOUSE_SCROLL,false);
                          }
                        else if(!left_button_down && m_left_button_down)
                          {
                           m_is_dragging = false;
                           RestoreMouseScrollState();
                          }

                        m_left_button_down = left_button_down;
                        if(!m_is_dragging || !left_button_down)
                           return false;

                        panel_left = mouse_x - m_drag_offset_x;
                        panel_top = mouse_y - m_drag_offset_y;
                        ClampPanelScreenPosition(panel_left,panel_top);
                        SetPanelScreenPosition(panel_left,panel_top);

                        if(!Create())
                           return false;

                        ChartRedraw(m_chart_id);
                        return true;
                       }

   // Updates panel text and colors using the latest calculated snapshot.
   void              Update(const DRMLRiskSnapshot &snapshot)
                       {
                        // Refreshes only mutate existing objects, but Create() is
                        // idempotent and restores any missing DRML_ object.
                        if(!Create())
                           return;

                        const color status_color = StatusColor(snapshot.status);

                        ObjectSetInteger(m_chart_id,DRML_PANEL_BG,OBJPROP_COLOR,status_color);

                        SetText(DRML_TITLE,"Daily Risk Monitor Lite",m_text_color,m_config.font_size + 1);
                        SetText(DRML_STATUS_LABEL,"Status",m_label_color,m_config.font_size);
                        SetText(DRML_STATUS_VALUE,snapshot.status_text,status_color,m_config.font_size);
                        SetText(DRML_TOTAL_LABEL,"Daily Total",m_label_color,m_config.font_size);
                        SetText(DRML_TOTAL_VALUE,FormatMoney(snapshot.daily_total),status_color,m_config.font_size);
                        SetText(DRML_REALIZED_LABEL,"Daily Realized",m_label_color,m_config.font_size);
                        SetText(DRML_REALIZED_VALUE,FormatMoney(snapshot.daily_realized),SignedMoneyColor(snapshot.daily_realized),m_config.font_size);
                        SetText(DRML_FLOATING_LABEL,"Floating",m_label_color,m_config.font_size);
                        SetText(DRML_FLOATING_VALUE,FormatMoney(snapshot.floating_pl),SignedMoneyColor(snapshot.floating_pl),m_config.font_size);
                        SetText(DRML_DD_LABEL,"Drawdown %",m_label_color,m_config.font_size);
                        SetText(DRML_DD_VALUE,FormatDrawdown(snapshot),DrawdownColor(snapshot),m_config.font_size);

                        ChartRedraw(m_chart_id);
                       }

   // Removes every DRML_ object from the chart and restores mouse scroll
   // state if a drag operation was in progress.
   void              Destroy(void)
                       {
                        m_is_dragging = false;
                        m_left_button_down = false;
                        RestoreMouseScrollState();

                        const int total = ObjectsTotal(m_chart_id,-1,-1);
                        for(int i = total - 1; i >= 0; --i)
                          {
                           const string name = ObjectName(m_chart_id,i,-1,-1);
                           if(StringFind(name,DRML_OBJECT_PREFIX) == 0)
                              ObjectDelete(m_chart_id,name);
                          }

                        ChartRedraw(m_chart_id);
                       }

private:
   // Recomputes basic layout metrics after font size changes.
   void              RecalculateMetrics(void)
                       {
                        m_row_step = MathMax(m_config.font_size + 10,20);
                        m_panel_width = 280;
                        m_panel_height = (m_padding_y * 2) + (m_row_step * 6);
                       }

   // X coordinate for left-aligned labels.
   int               LeftTextX(void) const
                       {
                        return m_config.x_offset + m_padding_x;
                       }

   // X coordinate for right-aligned values.
   int               RightTextX(void) const
                       {
                        return m_config.x_offset + m_panel_width - m_padding_x;
                       }

   // Y coordinate of a row based on the current panel geometry.
   int               RowY(const int row_index) const
                       {
                        return m_config.y_offset + m_padding_y + (row_index * m_row_step);
                       }

   // Creates or updates the background rectangle.
   bool              EnsureBackground(void)
                       {
                        if(ObjectFind(m_chart_id,DRML_PANEL_BG) < 0)
                          {
                           if(!ObjectCreate(m_chart_id,DRML_PANEL_BG,OBJ_RECTANGLE_LABEL,0,0,0))
                              return false;
                          }

                        ObjectSetInteger(m_chart_id,DRML_PANEL_BG,OBJPROP_CORNER,m_config.corner);
                        ObjectSetInteger(m_chart_id,DRML_PANEL_BG,OBJPROP_XDISTANCE,m_config.x_offset);
                        ObjectSetInteger(m_chart_id,DRML_PANEL_BG,OBJPROP_YDISTANCE,m_config.y_offset);
                        ObjectSetInteger(m_chart_id,DRML_PANEL_BG,OBJPROP_XSIZE,m_panel_width);
                        ObjectSetInteger(m_chart_id,DRML_PANEL_BG,OBJPROP_YSIZE,m_panel_height);
                        ObjectSetInteger(m_chart_id,DRML_PANEL_BG,OBJPROP_BGCOLOR,m_config.panel_bg_color);
                        ObjectSetInteger(m_chart_id,DRML_PANEL_BG,OBJPROP_BORDER_TYPE,BORDER_FLAT);
                        ObjectSetInteger(m_chart_id,DRML_PANEL_BG,OBJPROP_COLOR,m_label_color);
                        ObjectSetInteger(m_chart_id,DRML_PANEL_BG,OBJPROP_STYLE,STYLE_SOLID);
                        ObjectSetInteger(m_chart_id,DRML_PANEL_BG,OBJPROP_WIDTH,1);
                        ObjectSetInteger(m_chart_id,DRML_PANEL_BG,OBJPROP_BACK,false);
                        ObjectSetInteger(m_chart_id,DRML_PANEL_BG,OBJPROP_SELECTABLE,false);
                        ObjectSetInteger(m_chart_id,DRML_PANEL_BG,OBJPROP_SELECTED,false);
                        ObjectSetInteger(m_chart_id,DRML_PANEL_BG,OBJPROP_HIDDEN,true);
                        return true;
                       }

   // Creates or updates a text label/value object.
   bool              EnsureTextObject(const string name,
                                      const int x,
                                      const int y,
                                      const ENUM_ANCHOR_POINT anchor,
                                      const int font_size)
                       {
                        if(ObjectFind(m_chart_id,name) < 0)
                          {
                           if(!ObjectCreate(m_chart_id,name,OBJ_LABEL,0,0,0))
                              return false;
                          }

                        ObjectSetInteger(m_chart_id,name,OBJPROP_CORNER,m_config.corner);
                        ObjectSetInteger(m_chart_id,name,OBJPROP_XDISTANCE,x);
                        ObjectSetInteger(m_chart_id,name,OBJPROP_YDISTANCE,y);
                        ObjectSetInteger(m_chart_id,name,OBJPROP_ANCHOR,anchor);
                        ObjectSetInteger(m_chart_id,name,OBJPROP_FONTSIZE,font_size);
                        ObjectSetInteger(m_chart_id,name,OBJPROP_BACK,false);
                        ObjectSetInteger(m_chart_id,name,OBJPROP_SELECTABLE,false);
                        ObjectSetInteger(m_chart_id,name,OBJPROP_SELECTED,false);
                        ObjectSetInteger(m_chart_id,name,OBJPROP_HIDDEN,true);
                        ObjectSetString(m_chart_id,name,OBJPROP_FONT,m_font_name);
                        return true;
                       }

   // Applies the latest text content, color and font size to an object.
   void              SetText(const string name,
                             const string text,
                             const color text_color,
                             const int font_size)
                       {
                        ObjectSetString(m_chart_id,name,OBJPROP_TEXT,text);
                        ObjectSetInteger(m_chart_id,name,OBJPROP_COLOR,text_color);
                        ObjectSetInteger(m_chart_id,name,OBJPROP_FONTSIZE,font_size);
                       }

   // Resolves panel accent color from SAFE / WARNING / DANGER.
   color             StatusColor(const DRMLRiskStatus status) const
                       {
                        switch(status)
                          {
                           case DRML_STATUS_WARNING:
                              return m_config.warn_color;
                           case DRML_STATUS_DANGER:
                              return m_config.danger_color;
                           default:
                              return m_config.safe_color;
                          }
                       }

   // Uses green for positive amounts, red for negative amounts, and neutral
   // text color for zero.
   color             SignedMoneyColor(const double value) const
                       {
                        if(value > 0.0)
                           return m_config.safe_color;
                        if(value < 0.0)
                           return m_config.danger_color;

                        return m_text_color;
                       }

   // Drawdown is shown as safe when it is zero, warning when positive,
   // and neutral when drawdown is not available.
   color             DrawdownColor(const DRMLRiskSnapshot &snapshot) const
                       {
                        if(!snapshot.has_drawdown)
                           return m_text_color;
                        if(snapshot.drawdown_pct <= 0.0)
                           return m_config.safe_color;

                        return m_config.warn_color;
                       }

   // Formats money values with an explicit plus sign for positive numbers.
   string            FormatMoney(const double value) const
                       {
                        if(value > 0.0)
                           return "+" + DoubleToString(value,2);

                        return DoubleToString(value,2);
                       }

   // Formats drawdown as percentage or N/A.
   string            FormatDrawdown(const DRMLRiskSnapshot &snapshot) const
                       {
                        if(!snapshot.has_drawdown)
                           return "N/A";

                        return DoubleToString(snapshot.drawdown_pct,2) + "%";
                       }

   // Reads current chart size in pixels so the custom drag logic can keep the
   // panel inside visible chart bounds.
   bool              GetChartPixelSize(int &width,int &height) const
                       {
                        long chart_width = 0;
                        long chart_height = 0;
                        if(!ChartGetInteger(m_chart_id,CHART_WIDTH_IN_PIXELS,0,chart_width))
                           return false;
                        if(!ChartGetInteger(m_chart_id,CHART_HEIGHT_IN_PIXELS,0,chart_height))
                           return false;

                        width = (int)chart_width;
                        height = (int)chart_height;
                        return true;
                       }

   // Converts the configured anchor corner and offsets into an absolute
   // screen-space top-left panel position.
   void              GetPanelScreenPosition(int &left,int &top) const
                       {
                        int chart_width = 0;
                        int chart_height = 0;
                        if(!GetChartPixelSize(chart_width,chart_height))
                          {
                           left = m_config.x_offset;
                           top = m_config.y_offset;
                           return;
                          }

                        switch(m_config.corner)
                          {
                           case CORNER_RIGHT_UPPER:
                              left = chart_width - m_config.x_offset - m_panel_width;
                              top = m_config.y_offset;
                              break;
                           case CORNER_LEFT_LOWER:
                              left = m_config.x_offset;
                              top = chart_height - m_config.y_offset - m_panel_height;
                              break;
                           case CORNER_RIGHT_LOWER:
                              left = chart_width - m_config.x_offset - m_panel_width;
                              top = chart_height - m_config.y_offset - m_panel_height;
                              break;
                           default:
                              left = m_config.x_offset;
                              top = m_config.y_offset;
                              break;
                          }
                       }

   // Hit test used to start panel dragging.
   bool              PointInsidePanel(const int x,
                                      const int y,
                                      const int panel_left,
                                      const int panel_top) const
                       {
                        return (x >= panel_left &&
                                x <= panel_left + m_panel_width &&
                                y >= panel_top &&
                                y <= panel_top + m_panel_height);
                       }

   // Prevents the panel from being dragged outside the visible chart area.
   void              ClampPanelScreenPosition(int &left,int &top) const
                       {
                        int chart_width = 0;
                        int chart_height = 0;
                        if(!GetChartPixelSize(chart_width,chart_height))
                          {
                           left = MathMax(left,0);
                           top = MathMax(top,0);
                           return;
                          }

                        const int max_left = MathMax(chart_width - m_panel_width,0);
                        const int max_top = MathMax(chart_height - m_panel_height,0);
                        left = MathMin(MathMax(left,0),max_left);
                        top = MathMin(MathMax(top,0),max_top);
                       }

   // Converts an absolute top-left screen position back into the offset values
   // expected by MT5 objects for the current anchor corner.
   void              SetPanelScreenPosition(const int left,const int top)
                       {
                        int chart_width = 0;
                        int chart_height = 0;
                        if(!GetChartPixelSize(chart_width,chart_height))
                          {
                           m_config.x_offset = left;
                           m_config.y_offset = top;
                           return;
                          }

                        switch(m_config.corner)
                          {
                           case CORNER_RIGHT_UPPER:
                              m_config.x_offset = chart_width - left - m_panel_width;
                              m_config.y_offset = top;
                              break;
                           case CORNER_LEFT_LOWER:
                              m_config.x_offset = left;
                              m_config.y_offset = chart_height - top - m_panel_height;
                              break;
                           case CORNER_RIGHT_LOWER:
                              m_config.x_offset = chart_width - left - m_panel_width;
                              m_config.y_offset = chart_height - top - m_panel_height;
                              break;
                           default:
                              m_config.x_offset = left;
                              m_config.y_offset = top;
                              break;
                          }

                        m_config.x_offset = MathMax(m_config.x_offset,0);
                        m_config.y_offset = MathMax(m_config.y_offset,0);
                       }

   // Saves the current chart mouse-scroll state so drag mode can restore it.
   void              SaveMouseScrollState(void)
                       {
                        long mouse_scroll = 1;
                        if(ChartGetInteger(m_chart_id,CHART_MOUSE_SCROLL,0,mouse_scroll))
                          {
                           m_saved_mouse_scroll = (mouse_scroll != 0);
                           m_mouse_scroll_saved = true;
                          }
                       }

   // Restores chart mouse-scroll state after drag completes.
   void              RestoreMouseScrollState(void)
                       {
                        if(!m_mouse_scroll_saved)
                           return;

                        ChartSetInteger(m_chart_id,CHART_MOUSE_SCROLL,m_saved_mouse_scroll);
                        m_mouse_scroll_saved = false;
                       }
  };

#endif
