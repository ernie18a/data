//+------------------------------------------------------------------+
//|             BhanuCodeLab SMMA Levels MTF.mq5                     |
//|                                     Copyright 2026, BhanuCodeLab |
//+------------------------------------------------------------------+
#property copyright "BhanuCodeLab"
#property version   "1.0"
#property description "Plots three configurable multi-timeframe SMMA levels and displays a live price-position dashboard."
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3

#property indicator_label1  "SMMA MTF Level 1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDeepSkyBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "SMMA MTF Level 2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#property indicator_label3  "SMMA MTF Level 3"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrMediumPurple
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2

input group "1. General Settings"
input ENUM_APPLIED_PRICE InpAppliedPrice       = PRICE_CLOSE;  // SMMA applied price
input bool               InpUseClosedMTFBar    = false;        // Use completed MTF candle only
input int                InpMaximumHistoryBars = 2500;         // Maximum chart bars to calculate

input group "2. SMMA Level 1"
input bool               InpEnableLevel1       = true;         // Enable level 1
input ENUM_TIMEFRAMES    InpTimeframe1         = PERIOD_M15;   // Level 1 timeframe
input int                InpPeriod1            = 50;           // Level 1 SMMA period
input color              InpLineColor1         = clrDeepSkyBlue; // Level 1 line color
input ENUM_LINE_STYLE    InpLineStyle1         = STYLE_SOLID;    // Level 1 line style
input int                InpLineWidth1         = 2;              // Level 1 line width

input group "3. SMMA Level 2"
input bool               InpEnableLevel2       = true;         // Enable level 2
input ENUM_TIMEFRAMES    InpTimeframe2         = PERIOD_H1;    // Level 2 timeframe
input int                InpPeriod2            = 50;           // Level 2 SMMA period
input color              InpLineColor2         = clrOrange;     // Level 2 line color
input ENUM_LINE_STYLE    InpLineStyle2         = STYLE_SOLID;    // Level 2 line style
input int                InpLineWidth2         = 2;              // Level 2 line width

input group "4. SMMA Level 3"
input bool               InpEnableLevel3       = true;         // Enable level 3
input ENUM_TIMEFRAMES    InpTimeframe3         = PERIOD_H4;    // Level 3 timeframe
input int                InpPeriod3            = 50;           // Level 3 SMMA period
input color              InpLineColor3         = clrMediumPurple; // Level 3 line color
input ENUM_LINE_STYLE    InpLineStyle3         = STYLE_SOLID;      // Level 3 line style
input int                InpLineWidth3         = 2;                // Level 3 line width

input group "5. Status Table"
input bool               InpShowTable          = true;                 // Show status table
input ENUM_BASE_CORNER   InpTableCorner        = CORNER_RIGHT_UPPER;   // Table corner
input int                InpTableX             = 12;                   // Horizontal offset
input int                InpTableY             = 24;                   // Vertical offset
input color              InpTableBackground    = C'20,24,32';          // Background color
input color              InpTableBorder        = C'82,91,108';         // Border color
input color              InpTableText          = clrWhiteSmoke;        // Main text color
input color              InpAboveColor         = clrLimeGreen;         // Above SMMA color
input color              InpBelowColor         = clrTomato;            // Below SMMA color
input color              InpAtLevelColor       = clrGold;              // At-level color

//+------------------------------------------------------------------+
//| Indicator buffers                                                |
//+------------------------------------------------------------------+
double LevelBuffer1[];
double LevelBuffer2[];
double LevelBuffer3[];

//+------------------------------------------------------------------+
//| Indicator handles                                                |
//+------------------------------------------------------------------+
int HandleSMMA1 = INVALID_HANDLE;
int HandleSMMA2 = INVALID_HANDLE;
int HandleSMMA3 = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| Runtime and table state                                          |
//+------------------------------------------------------------------+
string ObjectPrefix = "";
int RuntimePeriod1 = 50;
int RuntimePeriod2 = 50;
int RuntimePeriod3 = 50;
int RuntimeHistoryBars = 2500;
ENUM_APPLIED_PRICE RuntimeAppliedPrice = PRICE_CLOSE;
ENUM_TIMEFRAMES RuntimeTimeframe1 = PERIOD_M15;
ENUM_TIMEFRAMES RuntimeTimeframe2 = PERIOD_H1;
ENUM_TIMEFRAMES RuntimeTimeframe3 = PERIOD_H4;
bool RuntimeEnableLevel1 = true;
bool RuntimeEnableLevel2 = true;
bool RuntimeEnableLevel3 = true;

const int PANEL_MIN_WIDTH      = 400;
const int PANEL_ROW_COUNT      = 3;
const int PANEL_ROW_START      = 51;
const int PANEL_ROW_GAP        = 23;
const int PANEL_BOTTOM_PADDING = 16;

int PanelLeft   = 0;
int PanelTop    = 0;
int PanelWidth  = PANEL_MIN_WIDTH;
int PanelHeight = 124;

//+------------------------------------------------------------------+
//| Convert timeframe to a compact readable string                   |
//+------------------------------------------------------------------+
string TimeframeText(const ENUM_TIMEFRAMES timeframe)
  {
   string text = EnumToString(timeframe);
   StringReplace(text,"PERIOD_","");
   return text;
  }

//+------------------------------------------------------------------+
//| Returns a safe SMMA period                                       |
//+------------------------------------------------------------------+
int SafePeriod(const int requested_period)
  {
   return MathMax(1,MathMin(1000,requested_period));
  }

//+------------------------------------------------------------------+
//| Returns a safe chart-history limit                               |
//+------------------------------------------------------------------+
int SafeHistoryBars(const int requested_bars)
  {
   return MathMax(10,MathMin(10000,requested_bars));
  }

//+------------------------------------------------------------------+
//| Returns a supported applied-price value                          |
//+------------------------------------------------------------------+
ENUM_APPLIED_PRICE SafeAppliedPrice(const ENUM_APPLIED_PRICE requested_price)
  {
   switch(requested_price)
     {
      case PRICE_CLOSE:
      case PRICE_OPEN:
      case PRICE_HIGH:
      case PRICE_LOW:
      case PRICE_MEDIAN:
      case PRICE_TYPICAL:
      case PRICE_WEIGHTED:
         return requested_price;
     }

   return PRICE_CLOSE;
  }

//+------------------------------------------------------------------+
//| Returns a supported chart timeframe                              |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES SafeTimeframe(const ENUM_TIMEFRAMES requested_timeframe,
                              const ENUM_TIMEFRAMES fallback_timeframe)
  {
   switch(requested_timeframe)
     {
      case PERIOD_CURRENT:
      case PERIOD_M1:
      case PERIOD_M2:
      case PERIOD_M3:
      case PERIOD_M4:
      case PERIOD_M5:
      case PERIOD_M6:
      case PERIOD_M10:
      case PERIOD_M12:
      case PERIOD_M15:
      case PERIOD_M20:
      case PERIOD_M30:
      case PERIOD_H1:
      case PERIOD_H2:
      case PERIOD_H3:
      case PERIOD_H4:
      case PERIOD_H6:
      case PERIOD_H8:
      case PERIOD_H12:
      case PERIOD_D1:
      case PERIOD_W1:
      case PERIOD_MN1:
         return requested_timeframe;
     }

   return fallback_timeframe;
  }

//+------------------------------------------------------------------+
//| Estimates the width required to display a text string            |
//+------------------------------------------------------------------+
int EstimatedTextWidth(const string text,const int font_size)
  {
   const double average_character_width = (double)font_size * 0.62;
   return (int)MathCeil(StringLen(text) * average_character_width);
  }

//+------------------------------------------------------------------+
//| Calculates panel size and keeps it inside the visible chart      |
//+------------------------------------------------------------------+
void CalculatePanelGeometry(const string title)
  {
   const int chart_width =
      (int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);

   const int chart_height =
      (int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);

   const int horizontal_margin = MathMax(0,InpTableX);
   const int vertical_margin = MathMax(0,InpTableY);

   const int title_width = EstimatedTextWidth(title,10) + 30;
   const int required_width = MathMax(PANEL_MIN_WIDTH,title_width);
   const int available_width =
      MathMax(120,chart_width - (2 * horizontal_margin));

   PanelWidth = MathMin(required_width,available_width);

   const int required_height =
      PANEL_ROW_START +
      ((PANEL_ROW_COUNT - 1) * PANEL_ROW_GAP) +
      12 +
      PANEL_BOTTOM_PADDING;

   PanelHeight = MathMin(required_height,MathMax(80,chart_height));

   const bool right_side =
      (InpTableCorner == CORNER_RIGHT_UPPER ||
       InpTableCorner == CORNER_RIGHT_LOWER);

   const bool lower_side =
      (InpTableCorner == CORNER_LEFT_LOWER ||
       InpTableCorner == CORNER_RIGHT_LOWER);

   PanelLeft = right_side
               ? chart_width - PanelWidth - horizontal_margin
               : horizontal_margin;

   PanelTop = lower_side
              ? chart_height - PanelHeight - vertical_margin
              : vertical_margin;

   const int maximum_left = MathMax(0,chart_width - PanelWidth);
   const int maximum_top  = MathMax(0,chart_height - PanelHeight);

   PanelLeft = MathMax(0,MathMin(maximum_left,PanelLeft));
   PanelTop  = MathMax(0,MathMin(maximum_top,PanelTop));
  }

//+------------------------------------------------------------------+
//| Creates or updates the dashboard background                      |
//+------------------------------------------------------------------+
void CreateTableBackground()
  {
   const string name = ObjectPrefix + "BACKGROUND";

   if(ObjectFind(0,name) < 0)
      ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,PanelLeft);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,PanelTop);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,PanelWidth);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,PanelHeight);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,InpTableBackground);
   ObjectSetInteger(0,name,OBJPROP_COLOR,InpTableBorder);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

//+------------------------------------------------------------------+
//| Creates or updates one dashboard label                           |
//+------------------------------------------------------------------+
void SetTableLabel(const string suffix,
                   const string text,
                   const int local_x,
                   const int local_y,
                   const color text_color,
                   const int font_size = 9,
                   const ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_UPPER)
  {
   const string name = ObjectPrefix + suffix;

   if(ObjectFind(0,name) < 0)
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,PanelLeft + local_x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,PanelTop + local_y);
   ObjectSetInteger(0,name,OBJPROP_COLOR,text_color);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetString(0,name,OBJPROP_FONT,"Segoe UI");
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

//+------------------------------------------------------------------+
//| Delete only this indicator instance's table objects              |
//+------------------------------------------------------------------+
void DeleteTableObjects()
  {
   if(ObjectPrefix != "")
      ObjectsDeleteAll(0,ObjectPrefix,0,-1);
  }

//+------------------------------------------------------------------+
//| Obtain an SMMA value corresponding to a chart bar time           |
//+------------------------------------------------------------------+
bool ReadMappedSMMA(const int handle,
                    const ENUM_TIMEFRAMES timeframe,
                    const datetime chart_bar_time,
                    double &smma_value)
  {
   if(handle == INVALID_HANDLE)
      return false;

   int source_shift = iBarShift(_Symbol,timeframe,chart_bar_time,false);
   if(source_shift < 0)
      return false;

   if(InpUseClosedMTFBar)
      source_shift++;

   double copied_value[1];
   if(CopyBuffer(handle,0,source_shift,1,copied_value) != 1)
      return false;

   if(copied_value[0] == EMPTY_VALUE || !MathIsValidNumber(copied_value[0]))
      return false;

   smma_value = copied_value[0];
   return true;
  }

//+------------------------------------------------------------------+
//| Obtain the latest display value for one SMMA                     |
//+------------------------------------------------------------------+
bool ReadCurrentSMMA(const int handle,double &smma_value)
  {
   if(handle == INVALID_HANDLE)
      return false;

   const int source_shift = InpUseClosedMTFBar ? 1 : 0;
   double copied_value[1];

   if(CopyBuffer(handle,0,source_shift,1,copied_value) != 1)
      return false;

   if(copied_value[0] == EMPTY_VALUE || !MathIsValidNumber(copied_value[0]))
      return false;

   smma_value = copied_value[0];
   return true;
  }

//+------------------------------------------------------------------+
//| Format a signed point distance                                   |
//+------------------------------------------------------------------+
string DistanceText(const double distance_points)
  {
   string sign = "";
   if(distance_points > 0.0)
      sign = "+";

   return StringFormat("%s%.1f pts",sign,distance_points);
  }

//+------------------------------------------------------------------+
//| Update one table data row                                        |
//+------------------------------------------------------------------+
void UpdateTableRow(const int row_number,
                    const bool enabled,
                    const ENUM_TIMEFRAMES timeframe,
                    const int handle,
                    const color level_color,
                    const double current_price)
  {
   const int row_y =
      PANEL_ROW_START + ((row_number - 1) * PANEL_ROW_GAP);

   const int timeframe_x = 12;
   const int value_x = (int)MathRound(PanelWidth * 0.18);
   const int state_x = (int)MathRound(PanelWidth * 0.53);
   const int distance_x = PanelWidth - 12;

   const string row_key =
      "ROW" + IntegerToString(row_number) + "_";

//--- Display the timeframe for this SMMA level.
   SetTableLabel(row_key + "TF",
                 TimeframeText(timeframe),
                 timeframe_x,
                 row_y,
                 level_color,
                 9,
                 ANCHOR_LEFT_UPPER);

//--- Display the disabled state without reading the indicator handle.
   if(!enabled)
     {
      SetTableLabel(row_key + "VALUE",
                    "Disabled",
                    value_x,
                    row_y,
                    clrSilver,
                    9,
                    ANCHOR_LEFT_UPPER);

      SetTableLabel(row_key + "STATE",
                    "OFF",
                    state_x,
                    row_y,
                    clrSilver,
                    9,
                    ANCHOR_LEFT_UPPER);

      SetTableLabel(row_key + "DISTANCE",
                    "--",
                    distance_x,
                    row_y,
                    clrSilver,
                    9,
                    ANCHOR_RIGHT_UPPER);
      return;
     }

//--- Read the current SMMA value and handle unavailable data.
   double smma_value = 0.0;
   if(!ReadCurrentSMMA(handle,smma_value))
     {
      SetTableLabel(row_key + "VALUE",
                    "Loading...",
                    value_x,
                    row_y,
                    clrSilver,
                    9,
                    ANCHOR_LEFT_UPPER);

      SetTableLabel(row_key + "STATE",
                    "WAIT",
                    state_x,
                    row_y,
                    clrSilver,
                    9,
                    ANCHOR_LEFT_UPPER);

      SetTableLabel(row_key + "DISTANCE",
                    "--",
                    distance_x,
                    row_y,
                    clrSilver,
                    9,
                    ANCHOR_RIGHT_UPPER);
      return;
     }

//--- Compare the current price with the SMMA level.
   const double difference = current_price - smma_value;
   const double distance_points =
      (_Point > 0.0) ? difference / _Point : 0.0;
   const double tolerance = _Point * 0.10;

   string state_text = "ON LEVEL";
   color state_color = InpAtLevelColor;

   if(difference > tolerance)
     {
      state_text = "ABOVE";
      state_color = InpAboveColor;
     }
   else
      if(difference < -tolerance)
        {
         state_text = "BELOW";
         state_color = InpBelowColor;
        }

//--- Update the value, position, and distance columns.
   SetTableLabel(row_key + "VALUE",
                 DoubleToString(smma_value,_Digits),
                 value_x,
                 row_y,
                 InpTableText,
                 9,
                 ANCHOR_LEFT_UPPER);

   SetTableLabel(row_key + "STATE",
                 state_text,
                 state_x,
                 row_y,
                 state_color,
                 9,
                 ANCHOR_LEFT_UPPER);

   SetTableLabel(row_key + "DISTANCE",
                 DistanceText(distance_points),
                 distance_x,
                 row_y,
                 state_color,
                 9,
                 ANCHOR_RIGHT_UPPER);
  }

//+------------------------------------------------------------------+
//| Create and refresh the complete status table                     |
//+------------------------------------------------------------------+
void UpdateStatusTable(const double fallback_price)
  {
   if(!InpShowTable)
     {
      DeleteTableObjects();
      return;
     }

//--- Obtain the latest available market price.
   double current_price = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   if(current_price <= 0.0)
      current_price = fallback_price;

   const string title =
      "SMMA LEVELS MTF  |  " + _Symbol +
      "  |  Price: " + DoubleToString(current_price,_Digits);

//--- Calculate one shared panel rectangle for all dashboard objects.
   CalculatePanelGeometry(title);
   CreateTableBackground();

   const int timeframe_x = 12;
   const int value_x = (int)MathRound(PanelWidth * 0.18);
   const int state_x = (int)MathRound(PanelWidth * 0.53);
   const int distance_x = PanelWidth - 12;

//--- Draw the centered title.
   SetTableLabel("TITLE",
                 title,
                 PanelWidth / 2,
                 7,
                 InpTableText,
                 10,
                 ANCHOR_UPPER);

//--- Draw table headers without a period column.
   SetTableLabel("HEADER_TF",
                 "TF",
                 timeframe_x,
                 30,
                 clrSilver,
                 8,
                 ANCHOR_LEFT_UPPER);

   SetTableLabel("HEADER_VALUE",
                 "SMMA Value",
                 value_x,
                 30,
                 clrSilver,
                 8,
                 ANCHOR_LEFT_UPPER);

   SetTableLabel("HEADER_STATE",
                 "Position",
                 state_x,
                 30,
                 clrSilver,
                 8,
                 ANCHOR_LEFT_UPPER);

   SetTableLabel("HEADER_DISTANCE",
                 "Distance",
                 distance_x,
                 30,
                 clrSilver,
                 8,
                 ANCHOR_RIGHT_UPPER);

//--- Refresh all configured SMMA rows.
   UpdateTableRow(1,
                  RuntimeEnableLevel1,
                  RuntimeTimeframe1,
                  HandleSMMA1,
                  InpLineColor1,
                  current_price);

   UpdateTableRow(2,
                  RuntimeEnableLevel2,
                  RuntimeTimeframe2,
                  HandleSMMA2,
                  InpLineColor2,
                  current_price);

   UpdateTableRow(3,
                  RuntimeEnableLevel3,
                  RuntimeTimeframe3,
                  HandleSMMA3,
                  InpLineColor3,
                  current_price);

  }

//+------------------------------------------------------------------+
//| Fill one plotted MTF SMMA buffer                                 |
//+------------------------------------------------------------------+
void CalculateLevelBuffer(double &target_buffer[],
                          const bool enabled,
                          const int handle,
                          const ENUM_TIMEFRAMES timeframe,
                          const datetime &time[],
                          const int bars_to_process)
  {
//--- Calculate only the chart bars selected for this update.
   for(int bar = bars_to_process - 1; bar >= 0; bar--)
     {
      if(!enabled)
        {
         target_buffer[bar] = EMPTY_VALUE;
         continue;
        }

      double smma_value = 0.0;
      if(ReadMappedSMMA(handle,timeframe,time[bar],smma_value))
         target_buffer[bar] = smma_value;
      else
         target_buffer[bar] = EMPTY_VALUE;
     }
  }

//+------------------------------------------------------------------+
//| Indicator initialization                                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Prepare safe runtime values for automatic validation tests.
   RuntimePeriod1 = SafePeriod(InpPeriod1);
   RuntimePeriod2 = SafePeriod(InpPeriod2);
   RuntimePeriod3 = SafePeriod(InpPeriod3);
   RuntimeHistoryBars = SafeHistoryBars(InpMaximumHistoryBars);
   RuntimeAppliedPrice = SafeAppliedPrice(InpAppliedPrice);
   RuntimeTimeframe1 = SafeTimeframe(InpTimeframe1,PERIOD_M15);
   RuntimeTimeframe2 = SafeTimeframe(InpTimeframe2,PERIOD_H1);
   RuntimeTimeframe3 = SafeTimeframe(InpTimeframe3,PERIOD_H4);
   RuntimeEnableLevel1 = InpEnableLevel1;
   RuntimeEnableLevel2 = InpEnableLevel2;
   RuntimeEnableLevel3 = InpEnableLevel3;

//--- Bind indicator buffers and configure their indexing direction.
   SetIndexBuffer(0,LevelBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,LevelBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,LevelBuffer3,INDICATOR_DATA);

   ArraySetAsSeries(LevelBuffer1,true);
   ArraySetAsSeries(LevelBuffer2,true);
   ArraySetAsSeries(LevelBuffer3,true);

   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//--- Apply the configured appearance and Data Window labels.
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,InpLineColor1);
   PlotIndexSetInteger(0,PLOT_LINE_STYLE,InpLineStyle1);
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,MathMax(1,MathMin(5,InpLineWidth1)));
   PlotIndexSetString(0,PLOT_LABEL,"SMMA " + TimeframeText(RuntimeTimeframe1) +
                      " (" + IntegerToString(RuntimePeriod1) + ")");

   PlotIndexSetInteger(1,PLOT_LINE_COLOR,InpLineColor2);
   PlotIndexSetInteger(1,PLOT_LINE_STYLE,InpLineStyle2);
   PlotIndexSetInteger(1,PLOT_LINE_WIDTH,MathMax(1,MathMin(5,InpLineWidth2)));
   PlotIndexSetString(1,PLOT_LABEL,"SMMA " + TimeframeText(RuntimeTimeframe2) +
                      " (" + IntegerToString(RuntimePeriod2) + ")");

   PlotIndexSetInteger(2,PLOT_LINE_COLOR,InpLineColor3);
   PlotIndexSetInteger(2,PLOT_LINE_STYLE,InpLineStyle3);
   PlotIndexSetInteger(2,PLOT_LINE_WIDTH,MathMax(1,MathMin(5,InpLineWidth3)));
   PlotIndexSetString(2,PLOT_LABEL,"SMMA " + TimeframeText(RuntimeTimeframe3) +
                      " (" + IntegerToString(RuntimePeriod3) + ")");

//--- Create the three multi-timeframe SMMA handles.
   HandleSMMA1 = RuntimeEnableLevel1
                 ? iMA(_Symbol,RuntimeTimeframe1,RuntimePeriod1,0,MODE_SMMA,RuntimeAppliedPrice)
                 : INVALID_HANDLE;
   HandleSMMA2 = RuntimeEnableLevel2
                 ? iMA(_Symbol,RuntimeTimeframe2,RuntimePeriod2,0,MODE_SMMA,RuntimeAppliedPrice)
                 : INVALID_HANDLE;
   HandleSMMA3 = RuntimeEnableLevel3
                 ? iMA(_Symbol,RuntimeTimeframe3,RuntimePeriod3,0,MODE_SMMA,RuntimeAppliedPrice)
                 : INVALID_HANDLE;

//--- Disable only the level whose handle could not be created.
   if(RuntimeEnableLevel1 && HandleSMMA1 == INVALID_HANDLE)
     {
      RuntimeEnableLevel1 = false;
      Print("SMMA level 1 was disabled because its handle could not be created.");
     }

   if(RuntimeEnableLevel2 && HandleSMMA2 == INVALID_HANDLE)
     {
      RuntimeEnableLevel2 = false;
      Print("SMMA level 2 was disabled because its handle could not be created.");
     }

   if(RuntimeEnableLevel3 && HandleSMMA3 == INVALID_HANDLE)
     {
      RuntimeEnableLevel3 = false;
      Print("SMMA level 3 was disabled because its handle could not be created.");
     }

//--- Create an object prefix unique to this indicator instance.
   ObjectPrefix = "BCL_SMMA_MTF_" + IntegerToString((int)ChartID()) + "_" +
                  IntegerToString((int)GetTickCount()) + "_";

   IndicatorSetString(INDICATOR_SHORTNAME,"BhanuCodeLab SMMA Levels MTF v1.02");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Indicator deinitialization                                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Release all indicator handles created during initialization.
   if(HandleSMMA1 != INVALID_HANDLE)
      IndicatorRelease(HandleSMMA1);

   if(HandleSMMA2 != INVALID_HANDLE)
      IndicatorRelease(HandleSMMA2);

   if(HandleSMMA3 != INVALID_HANDLE)
      IndicatorRelease(HandleSMMA3);

//--- Remove table objects created by this indicator instance.
   DeleteTableObjects();
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Main calculation                                                 |
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
   if(rates_total < 2)
      return 0;

   ArraySetAsSeries(time,true);
   ArraySetAsSeries(close,true);

   int bars_to_process = 0;

//--- Determine whether the full visible history or recent bars are required.
   if(prev_calculated == 0)
     {
      ArrayInitialize(LevelBuffer1,EMPTY_VALUE);
      ArrayInitialize(LevelBuffer2,EMPTY_VALUE);
      ArrayInitialize(LevelBuffer3,EMPTY_VALUE);

      bars_to_process = MathMin(rates_total,RuntimeHistoryBars);
     }
   else
     {
      //--- Refresh recent bars when a new source-timeframe bar develops.
      bars_to_process = MathMin(rates_total,10);
     }

//--- Map each source-timeframe SMMA onto the current chart bars.
   CalculateLevelBuffer(LevelBuffer1,RuntimeEnableLevel1,HandleSMMA1,RuntimeTimeframe1,time,bars_to_process);
   CalculateLevelBuffer(LevelBuffer2,RuntimeEnableLevel2,HandleSMMA2,RuntimeTimeframe2,time,bars_to_process);
   CalculateLevelBuffer(LevelBuffer3,RuntimeEnableLevel3,HandleSMMA3,RuntimeTimeframe3,time,bars_to_process);

//--- Refresh the live price-position table.
   UpdateStatusTable(close[0]);

   return rates_total;
  }

//+------------------------------------------------------------------+
//| Repositions the table after chart size or layout changes         |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id != CHARTEVENT_CHART_CHANGE || !InpShowTable)
      return;

   double fallback_price = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   UpdateStatusTable(fallback_price);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
