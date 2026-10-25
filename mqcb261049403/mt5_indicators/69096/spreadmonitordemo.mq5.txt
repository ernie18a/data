//+------------------------------------------------------------------+
//|                                            SpreadMonitorDemo.mq5 |
//|                                       Copyright 2026, Algosphere |
//|                                     https://algosphere-quant.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Algosphere"
#property link      "https://algosphere-quant.com"
#property version   "1.00"
#property description "Demo indicator for SpreadMonitor Library"
#property description "Displays real-time spread statistics and alerts"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   0

//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include "SpreadMonitor.mqh"

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input group              "=== Display Settings ==="
input int                InpPanelX=10;              // Panel X Position
input int                InpPanelY=30;              // Panel Y Position
input color              InpBackgroundColor=C'32,32,32';  // Background Color
input color              InpTextColor=clrWhite;    // Text Color

input group              "=== Spread Thresholds (Pips) ==="
input double             InpLowThreshold=1.0;      // Low Spread Threshold
input double             InpNormalThreshold=2.0;   // Normal Spread Threshold  
input double             InpHighThreshold=5.0;     // High Spread Threshold

input group              "=== Filter Settings ==="
input double             InpMaxSpread=3.0;         // Maximum Acceptable Spread
input int                InpHistorySize=500;       // History Size (samples)

input group              "=== Alert Settings ==="
input bool               InpAlertOnHigh=true;      // Alert on High Spread
input bool               InpAlertOnExtreme=true;   // Alert on Extreme Spread

//+------------------------------------------------------------------+
//| Defines                                                          |
//+------------------------------------------------------------------+
#define PREFIX           "SPM_"
#define PANEL_WIDTH      200
#define PANEL_HEIGHT     230
#define ROW_SPACING      18

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
CSpreadMonitor           g_spread_monitor;
double                   g_spread_buffer[];
ENUM_SPREAD_CONDITION    g_last_condition=SPREAD_LOW;
datetime                 g_last_alert_time=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initialize spread monitor
   if(!g_spread_monitor.Init(_Symbol,InpHistorySize,
                              InpLowThreshold,InpNormalThreshold,InpHighThreshold))
     {
      Print("Error: Failed to initialize SpreadMonitor");
      return(INIT_FAILED);
     }

//--- Set indicator buffer (not plotted, just for data storage)
   SetIndexBuffer(0,g_spread_buffer,INDICATOR_CALCULATIONS);

//--- Create panel
   CreatePanel();
   
//--- Initial update
   g_spread_monitor.Update();
   UpdatePanel();

//--- Set timer for frequent updates
   EventSetMillisecondTimer(250);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0,PREFIX);
  }

//+------------------------------------------------------------------+
//| Timer function - updates spread display                          |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- Record spread sample
   g_spread_monitor.Update();
   
//--- Update display
   UpdatePanel();
   
//--- Check for alerts
   CheckAlerts();
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- Store current spread
   if(rates_total>0)
      g_spread_buffer[rates_total-1]=g_spread_monitor.GetCurrentSpread();
      
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Check and trigger alerts                                         |
//+------------------------------------------------------------------+
void CheckAlerts()
  {
   ENUM_SPREAD_CONDITION current_condition=g_spread_monitor.GetSpreadCondition();
   
//--- Only alert on condition change to avoid spam
   if(current_condition==g_last_condition)
      return;
      
//--- Check if enough time passed since last alert (30 seconds)
   if(TimeCurrent()-g_last_alert_time<30)
      return;

//--- Alert on high spread
   if(InpAlertOnHigh && current_condition==SPREAD_HIGH && g_last_condition<SPREAD_HIGH)
     {
      Alert(_Symbol," - HIGH SPREAD: ",DoubleToString(g_spread_monitor.GetCurrentSpread(),1)," pips");
      g_last_alert_time=TimeCurrent();
     }

//--- Alert on extreme spread
   if(InpAlertOnExtreme && current_condition==SPREAD_EXTREME && g_last_condition<SPREAD_EXTREME)
     {
      Alert(_Symbol," - EXTREME SPREAD: ",DoubleToString(g_spread_monitor.GetCurrentSpread(),1)," pips!");
      g_last_alert_time=TimeCurrent();
     }

   g_last_condition=current_condition;
  }

//+------------------------------------------------------------------+
//| Create information panel                                         |
//+------------------------------------------------------------------+
void CreatePanel()
  {
   int x=InpPanelX;
   int y=InpPanelY;

//--- Background
   CreateRectangleLabel(PREFIX+"Background",x,y,PANEL_WIDTH,PANEL_HEIGHT,
                        InpBackgroundColor,C'60,60,60');

//--- Title
   CreateTextLabel(PREFIX+"Title",x+10,y+8,"SPREAD MONITOR",
                   InpTextColor,11,"Arial Bold");

//--- Symbol
   CreateTextLabel(PREFIX+"Symbol",x+PANEL_WIDTH-60,y+10,_Symbol,
                   clrDodgerBlue,9,"Arial");

//--- Separator
   CreateRectangleLabel(PREFIX+"Sep1",x+10,y+30,PANEL_WIDTH-20,1,
                        clrDimGray,clrDimGray);

   int row_y=y+40;

//--- Current spread (large display)
   CreateTextLabel(PREFIX+"LblCurrent",x+15,row_y,"Current:",clrGray,9,"Arial");
   CreateTextLabel(PREFIX+"ValCurrent",x+80,row_y,"0.0",clrLime,14,"Arial Bold");
   CreateTextLabel(PREFIX+"UnitCurrent",x+130,row_y,"pips",clrGray,9,"Arial");
   row_y+=24;

//--- Condition
   CreateTextLabel(PREFIX+"LblCondition",x+15,row_y,"Status:",clrGray,9,"Arial");
   CreateTextLabel(PREFIX+"ValCondition",x+80,row_y,"LOW",clrLime,10,"Arial Bold");
   row_y+=ROW_SPACING+5;

//--- Separator
   CreateRectangleLabel(PREFIX+"Sep2",x+10,row_y,PANEL_WIDTH-20,1,
                        clrDimGray,clrDimGray);
   row_y+=10;

//--- Statistics section
   CreateTextLabel(PREFIX+"LblStats",x+15,row_y,"Statistics",clrWhite,9,"Arial Bold");
   row_y+=ROW_SPACING;

   CreateTextLabel(PREFIX+"LblAvg",x+15,row_y,"Average:",clrGray,9,"Arial");
   CreateTextLabel(PREFIX+"ValAvg",x+100,row_y,"0.0 pips",InpTextColor,9,"Arial");
   row_y+=ROW_SPACING;

   CreateTextLabel(PREFIX+"LblMin",x+15,row_y,"Minimum:",clrGray,9,"Arial");
   CreateTextLabel(PREFIX+"ValMin",x+100,row_y,"0.0 pips",clrLime,9,"Arial");
   row_y+=ROW_SPACING;

   CreateTextLabel(PREFIX+"LblMax",x+15,row_y,"Maximum:",clrGray,9,"Arial");
   CreateTextLabel(PREFIX+"ValMax",x+100,row_y,"0.0 pips",clrOrange,9,"Arial");
   row_y+=ROW_SPACING;

//--- Separator
   CreateRectangleLabel(PREFIX+"Sep3",x+10,row_y+5,PANEL_WIDTH-20,1,
                        clrDimGray,clrDimGray);
   row_y+=15;

//--- Filter status
   CreateTextLabel(PREFIX+"LblFilter",x+15,row_y,"Trade Filter:",clrGray,9,"Arial");
   CreateTextLabel(PREFIX+"ValFilter",x+100,row_y,"ALLOW",clrLime,9,"Arial Bold");
   row_y+=ROW_SPACING;

//--- Samples
   CreateTextLabel(PREFIX+"LblSamples",x+15,row_y,"Samples:",clrGray,9,"Arial");
   CreateTextLabel(PREFIX+"ValSamples",x+100,row_y,"0",clrGray,9,"Arial");

   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Update panel values                                              |
//+------------------------------------------------------------------+
void UpdatePanel()
  {
//--- Get statistics
   SSpreadStats stats=g_spread_monitor.GetStatistics();

//--- Update current spread
   ObjectSetString(0,PREFIX+"ValCurrent",OBJPROP_TEXT,
                   DoubleToString(stats.current,1));
   ObjectSetInteger(0,PREFIX+"ValCurrent",OBJPROP_COLOR,
                    g_spread_monitor.GetConditionColor(stats.condition));

//--- Update condition
   ObjectSetString(0,PREFIX+"ValCondition",OBJPROP_TEXT,
                   g_spread_monitor.GetConditionName(stats.condition));
   ObjectSetInteger(0,PREFIX+"ValCondition",OBJPROP_COLOR,
                    g_spread_monitor.GetConditionColor(stats.condition));

//--- Update statistics
   ObjectSetString(0,PREFIX+"ValAvg",OBJPROP_TEXT,
                   DoubleToString(stats.average,1)+" pips");
   ObjectSetString(0,PREFIX+"ValMin",OBJPROP_TEXT,
                   DoubleToString(stats.minimum,1)+" pips");
   ObjectSetString(0,PREFIX+"ValMax",OBJPROP_TEXT,
                   DoubleToString(stats.maximum,1)+" pips");

//--- Update filter status
   bool acceptable=g_spread_monitor.IsSpreadAcceptable(InpMaxSpread);
   ObjectSetString(0,PREFIX+"ValFilter",OBJPROP_TEXT,
                   acceptable ? "ALLOW" : "BLOCK");
   ObjectSetInteger(0,PREFIX+"ValFilter",OBJPROP_COLOR,
                    acceptable ? clrLime : clrRed);

//--- Update samples count
   ObjectSetString(0,PREFIX+"ValSamples",OBJPROP_TEXT,
                   IntegerToString(stats.sample_count));

   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Create text label                                                |
//+------------------------------------------------------------------+
void CreateTextLabel(const string name,
                     const int x,
                     const int y,
                     const string text,
                     const color clr,
                     const int font_size,
                     const string font_name)
  {
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);

   if(!ObjectCreate(0,name,OBJ_LABEL,0,0,0))
      return;

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetString(0,name,OBJPROP_FONT,font_name);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

//+------------------------------------------------------------------+
//| Create rectangle label                                           |
//+------------------------------------------------------------------+
void CreateRectangleLabel(const string name,
                          const int x,
                          const int y,
                          const int width,
                          const int height,
                          const color bg_color,
                          const color border_color)
  {
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);

   if(!ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0))
      return;

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg_color);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,border_color);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }
//+------------------------------------------------------------------+
