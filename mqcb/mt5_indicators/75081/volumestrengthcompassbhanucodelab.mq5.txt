//+------------------------------------------------------------------+
//|                            VolumeStrengthCompassBhanuCodeLab.mq5 |
//|                                        Volume-analysis indicator |
//|                                                     BhanuCodeLab |
//+------------------------------------------------------------------+
#property copyright "BhanuCodeLab"
#property version   "1.0"
#property description "Volume Strength Compass evaluates relative volume, candle body strength, close position, volume intensity, climax activity, and absorption."

#property indicator_separate_window
#property indicator_buffers 11
#property indicator_plots   3

#property indicator_label1  "Background Highlight"
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
#property indicator_color1  C'18,30,18',C'35,15,15',C'35,25,10'
#property indicator_width1  5

#property indicator_label2  "Volume"
#property indicator_type2   DRAW_COLOR_HISTOGRAM
#property indicator_color2  clrGray,C'120,120,120',C'106,168,79',C'255,0,0',C'255,153,0',C'217,210,233'
#property indicator_width2  3

#property indicator_label3  "Average Volume"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrYellow
#property indicator_width3  2

//+------------------------------------------------------------------+
//| Volume source selection                                          |
//+------------------------------------------------------------------+
enum ENUM_VSC_VOLUME_SOURCE
  {
   Volume_Auto = 0,       // Auto
   Volume_Tick = 1,       // Tick volume
   Volume_Real = 2        // Real volume
  };

//+------------------------------------------------------------------+
//| Signal label size                                                |
//+------------------------------------------------------------------+
enum ENUM_VSC_LABEL_SIZE
  {
   Label_Tiny   = 0,      // Tiny
   Label_Small  = 1,      // Small
   Label_Normal = 2,      // Normal
   Label_Large  = 3       // Large
  };

//+------------------------------------------------------------------+
//| Alert evaluation timing                                          |
//+------------------------------------------------------------------+
enum ENUM_VSC_ALERT_TIMING
  {
   Alert_On_Closed_Bar = 0, // Closed bar
   Alert_On_Live_Bar   = 1  // Live bar
  };

//+------------------------------------------------------------------+
//| Internal volume state                                            |
//+------------------------------------------------------------------+
enum ENUM_VSC_STATE
  {
   STATE_NORMAL = 0,
   STATE_LOW    = 1,
   STATE_HIGH   = 2,
   STATE_CLIMAX = 3,
   STATE_ABSORB = 4,
   STATE_BEAR   = 5,
   STATE_BULL   = 6
  };

//+------------------------------------------------------------------+
//| Internal signal flags                                            |
//+------------------------------------------------------------------+
enum ENUM_VSC_FLAG
  {
   FLAG_HIGH   = 1,
   FLAG_CLIMAX = 2,
   FLAG_LOW    = 4,
   FLAG_BULL   = 8,
   FLAG_BEAR   = 16,
   FLAG_ABSORB = 32
  };

#define MAX_SIGNAL_LABELS 500
#define BG_LOOKBACK_BARS  100
#define MAX_AVG_LENGTH    1000

input group "1. Volume Settings"
input int                    InpAvgVolLen       = 20;          // Average volume length
input double                 InpHighRvolLevel   = 1.50;        // High RVOL level
input double                 InpClimaxRvolLevel = 2.50;        // Climax RVOL level
input double                 InpLowRvolLevel    = 0.70;        // Low RVOL level
input ENUM_VSC_VOLUME_SOURCE InpVolumeSource    = Volume_Auto; // Volume data source

input group "2. Candle Analysis Settings"
input double InpMinBodyPct       = 55.0; // Minimum body percent
input double InpCloseStrengthPct = 70.0; // Close strength percent
input double InpAbsorbBodyPct    = 35.0; // Maximum absorption body percent

input group "3. Visual Settings"
input bool                InpShowAvgVolLine  = true;           // Show average volume line
input bool                InpShowLabels      = true;           // Show signal labels
input bool                InpShowDashboard   = true;           // Show dashboard
input bool                InpShowBgHighlight = true;           // Show background highlight
input ENUM_VSC_LABEL_SIZE InpLabelSize       = Label_Small;    // Label size
input color               InpNormalVolColor  = clrGray;        // Normal volume color
input color               InpLowVolColor     = C'120,120,120'; // Low volume color
input color               InpBullVolColor    = C'106,168,79';  // Bull volume color
input color               InpBearVolColor    = C'255,0,0';     // Bear volume color
input color               InpAbsorbColor     = C'255,153,0';   // Absorption color
input color               InpClimaxColor     = C'217,210,233'; // Climax volume color
input color               InpAvgLineColor    = clrYellow;      // Average line color

input group "4. Alert Settings"
input bool                  InpEnableAlerts = true;                // Enable signal alerts
input ENUM_VSC_ALERT_TIMING InpAlertTiming  = Alert_On_Closed_Bar; // Alert timing
input bool                  InpPopupAlert   = true;                // Popup and sound alert
input bool                  InpPushAlert    = false;               // Push notification
input bool                  InpEmailAlert   = false;               // Email alert

double BgLowBuffer[];
double BgHighBuffer[];
double BgColorBuffer[];
double VolumeBuffer[];
double VolumeColorBuffer[];
double AvgPlotBuffer[];
double AvgCalcBuffer[];
double RvolBuffer[];
double BodyPctBuffer[];
double StateBuffer[];
double FlagsBuffer[];

string   g_short_name             = "Volume Strength Compass";
string   g_prefix                 = "";
datetime g_last_bar_time          = 0;
datetime g_last_closed_alert_time = 0;
datetime g_live_alert_bar_time    = 0;
int      g_live_sent_flags        = 0;
bool     g_alert_initialized      = false;

//+------------------------------------------------------------------+
//| Cached signal information                                        |
//+------------------------------------------------------------------+
struct SignalInfo
  {
   datetime          bar_time;
   double            volume;
   double            rvol;
   int               state;
  };

SignalInfo g_signals[];

double g_dash_volume  = EMPTY_VALUE;
double g_dash_avg     = EMPTY_VALUE;
double g_dash_rvol    = EMPTY_VALUE;
double g_dash_bodypct = EMPTY_VALUE;
int    g_dash_state   = STATE_NORMAL;

//+------------------------------------------------------------------+
//| Blends two colors using the specified foreground weight          |
//+------------------------------------------------------------------+
color BlendColors(const color foreground,
                  const color background,
                  const double foreground_weight)
  {
   double weight=MathMax(0.0,MathMin(1.0,foreground_weight));

   int foreground_red=((int)foreground)&0xFF;
   int foreground_green=(((int)foreground)>>8)&0xFF;
   int foreground_blue=(((int)foreground)>>16)&0xFF;

   int background_red=((int)background)&0xFF;
   int background_green=(((int)background)>>8)&0xFF;
   int background_blue=(((int)background)>>16)&0xFF;

   int result_red=(int)MathRound(foreground_red*weight+
                                 background_red*(1.0-weight));

   int result_green=(int)MathRound(foreground_green*weight+
                                   background_green*(1.0-weight));

   int result_blue=(int)MathRound(foreground_blue*weight+
                                  background_blue*(1.0-weight));

   return (color)(result_red|
                  (result_green<<8)|
                  (result_blue<<16));
  }

//+------------------------------------------------------------------+
//| Applies the configured colors to all indicator plots             |
//+------------------------------------------------------------------+
void ConfigurePlotColors()
  {
   color chart_background=
      (color)ChartGetInteger(0,CHART_COLOR_BACKGROUND,0);

   PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,3);

   PlotIndexSetInteger(
      0,
      PLOT_LINE_COLOR,
      0,
      BlendColors(InpBullVolColor,chart_background,0.12)
   );

   PlotIndexSetInteger(
      0,
      PLOT_LINE_COLOR,
      1,
      BlendColors(InpBearVolColor,chart_background,0.12)
   );

   PlotIndexSetInteger(
      0,
      PLOT_LINE_COLOR,
      2,
      BlendColors(InpAbsorbColor,chart_background,0.12)
   );

   PlotIndexSetInteger(1,PLOT_COLOR_INDEXES,6);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,0,InpNormalVolColor);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,1,InpLowVolColor);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,2,InpBullVolColor);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,3,InpBearVolColor);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,4,InpAbsorbColor);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,5,InpClimaxColor);

   PlotIndexSetInteger(2,PLOT_LINE_COLOR,0,InpAvgLineColor);
  }

//+------------------------------------------------------------------+
//| Returns the indicator subwindow index                            |
//+------------------------------------------------------------------+
int CurrentSubwindow()
  {
   int subwindow=ChartWindowFind();

   if(subwindow<0)
      subwindow=ChartWindowFind(0,g_short_name);

   return subwindow;
  }

//+------------------------------------------------------------------+
//| Returns a safe average-volume period                             |
//+------------------------------------------------------------------+
int SafeAverageLength()
  {
   int average_length=InpAvgVolLen;

   if(average_length<1)
      average_length=1;

   if(average_length>MAX_AVG_LENGTH)
      average_length=MAX_AVG_LENGTH;

   return average_length;
  }

//+------------------------------------------------------------------+
//| Returns a valid high-RVOL threshold                              |
//+------------------------------------------------------------------+
double SafeHighRvolLevel()
  {
   double value=InpHighRvolLevel;

   if(!MathIsValidNumber(value) || value<0.10)
      value=0.10;

   if(value>1000.0)
      value=1000.0;

   return value;
  }

//+------------------------------------------------------------------+
//| Returns a valid climax-RVOL threshold                            |
//+------------------------------------------------------------------+
double SafeClimaxRvolLevel(const double high_rvol_level)
  {
   double value=InpClimaxRvolLevel;

   if(!MathIsValidNumber(value) || value<0.10)
      value=0.10;

   if(value>1000.0)
      value=1000.0;

   if(value<high_rvol_level)
      value=high_rvol_level;

   return value;
  }

//+------------------------------------------------------------------+
//| Returns a valid low-RVOL threshold                               |
//+------------------------------------------------------------------+
double SafeLowRvolLevel(const double high_rvol_level)
  {
   double value=InpLowRvolLevel;

   if(!MathIsValidNumber(value) || value<0.0)
      value=0.0;

   if(value>high_rvol_level)
      value=high_rvol_level;

   return value;
  }

//+------------------------------------------------------------------+
//| Returns a percentage constrained to the supplied range           |
//+------------------------------------------------------------------+
double SafePercent(const double value,
                   const double default_value,
                   const double minimum_value,
                   const double maximum_value)
  {
   double result=value;

   if(!MathIsValidNumber(result))
      result=default_value;

   return MathMax(minimum_value,
                  MathMin(maximum_value,result));
  }

//+------------------------------------------------------------------+
//| Returns the selected volume value for one bar                    |
//+------------------------------------------------------------------+
double SelectedVolume(const int index,
                      const long &tick_volume[],
                      const long &real_volume[])
  {
   if(InpVolumeSource==Volume_Tick)
      return (double)tick_volume[index];

   if(InpVolumeSource==Volume_Real)
      return (double)real_volume[index];

   if(real_volume[index]>0)
      return (double)real_volume[index];

   return (double)tick_volume[index];
  }

//+------------------------------------------------------------------+
//| Formats a value without unnecessary trailing zeros               |
//+------------------------------------------------------------------+
string FormatNumber2(const double value)
  {
   if(value==EMPTY_VALUE || !MathIsValidNumber(value))
      return "na";

   string text=DoubleToString(value,2);

   while(StringLen(text)>0 &&
         StringGetCharacter(text,StringLen(text)-1)=='0')
     {
      text=StringSubstr(text,0,StringLen(text)-1);
     }

   if(StringLen(text)>0 &&
      StringGetCharacter(text,StringLen(text)-1)=='.')
     {
      text=StringSubstr(text,0,StringLen(text)-1);
     }

   return text;
  }

//+------------------------------------------------------------------+
//| Formats large volume values using abbreviated suffixes           |
//+------------------------------------------------------------------+
string FormatVolume(const double value)
  {
   if(value==EMPTY_VALUE || !MathIsValidNumber(value))
      return "na";

   double absolute_value=MathAbs(value);

   if(absolute_value>=1000000000000.0)
      return FormatNumber2(value/1000000000000.0)+"T";

   if(absolute_value>=1000000000.0)
      return FormatNumber2(value/1000000000.0)+"B";

   if(absolute_value>=1000000.0)
      return FormatNumber2(value/1000000.0)+"M";

   if(absolute_value>=1000.0)
      return FormatNumber2(value/1000.0)+"K";

   return DoubleToString(value,0);
  }

//+------------------------------------------------------------------+
//| Returns the dashboard description for a volume state             |
//+------------------------------------------------------------------+
string StateText(const int state)
  {
   switch(state)
     {
      case STATE_BULL:
         return "Bull Good Volume";

      case STATE_BEAR:
         return "Bear Good Volume";

      case STATE_ABSORB:
         return "Absorption / No Result";

      case STATE_CLIMAX:
         return "Climax Volume";

      case STATE_HIGH:
         return "High Volume";

      case STATE_LOW:
         return "Low Volume";

      default:
         return "Normal Volume";
     }
  }

//+------------------------------------------------------------------+
//| Returns the practical interpretation of a volume state           |
//+------------------------------------------------------------------+
string VolumeUseText(const int state)
  {
   switch(state)
     {
      case STATE_BULL:
         return "Useful Bull Force";

      case STATE_BEAR:
         return "Useful Bear Force";

      case STATE_ABSORB:
         return "Wait, Absorption";

      case STATE_CLIMAX:
         return "Careful, Climax";

      case STATE_HIGH:
         return "High Vol, Check Candle";

      case STATE_LOW:
         return "Weak Volume";

      default:
         return "Normal";
     }
  }

//+------------------------------------------------------------------+
//| Returns the dashboard background color for a volume state        |
//+------------------------------------------------------------------+
color StateBackgroundColor(const int state)
  {
   switch(state)
     {
      case STATE_BULL:
         return BlendColors(InpBullVolColor,clrBlack,0.90);

      case STATE_BEAR:
         return BlendColors(InpBearVolColor,clrBlack,0.90);

      case STATE_ABSORB:
         return BlendColors(InpAbsorbColor,clrBlack,0.90);

      case STATE_CLIMAX:
         return BlendColors(InpClimaxColor,clrBlack,0.90);

      case STATE_HIGH:
         return BlendColors(clrBlue,clrBlack,0.80);

      case STATE_LOW:
         return BlendColors(clrGray,clrBlack,0.80);

      default:
         return clrBlack;
     }
  }

//+------------------------------------------------------------------+
//| Returns the background color used by a signal label              |
//+------------------------------------------------------------------+
color SignalBackgroundColor(const int state)
  {
   switch(state)
     {
      case STATE_BULL:
         return InpBullVolColor;

      case STATE_BEAR:
         return InpBearVolColor;

      case STATE_ABSORB:
         return InpAbsorbColor;

      case STATE_CLIMAX:
         return InpClimaxColor;
     }

   return InpNormalVolColor;
  }

//+------------------------------------------------------------------+
//| Returns the heading displayed inside a signal label              |
//+------------------------------------------------------------------+
string SignalHeadingText(const int state)
  {
   switch(state)
     {
      case STATE_BULL:
         return "BULL VOL";

      case STATE_BEAR:
         return "BEAR VOL";

      case STATE_ABSORB:
         return "ABSORB";

      case STATE_CLIMAX:
         return "CLIMAX";

      default:
         return "";
     }
  }

//+------------------------------------------------------------------+
//| Deletes all signal-label objects                                 |
//+------------------------------------------------------------------+
void DeleteSignalObjects()
  {
   ObjectsDeleteAll(0,g_prefix+"SIG_");
  }

//+------------------------------------------------------------------+
//| Deletes all dashboard objects                                    |
//+------------------------------------------------------------------+
void DeleteDashboardObjects()
  {
   ObjectsDeleteAll(0,g_prefix+"DASH_");
  }

//+------------------------------------------------------------------+
//| Applies shared properties to an indicator chart object           |
//+------------------------------------------------------------------+
void SetCommonObjectProperties(const string name)
  {
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,10);
  }

//+------------------------------------------------------------------+
//| Creates a rectangle label when required                          |
//+------------------------------------------------------------------+
bool EnsureRectangleLabel(const string name,
                          const int subwindow)
  {
   if(ObjectFind(0,name)>=0)
      return true;

   if(!ObjectCreate(0,
                    name,
                    OBJ_RECTANGLE_LABEL,
                    subwindow,
                    0,
                    0))
      return false;

   SetCommonObjectProperties(name);

   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);

   return true;
  }

//+------------------------------------------------------------------+
//| Creates a text label when required                               |
//+------------------------------------------------------------------+
bool EnsureTextLabel(const string name,
                     const int subwindow)
  {
   if(ObjectFind(0,name)>=0)
      return true;

   if(!ObjectCreate(0,name,OBJ_LABEL,subwindow,0,0))
      return false;

   SetCommonObjectProperties(name);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");

   return true;
  }

//+------------------------------------------------------------------+
//| Moves an unavailable signal object outside the visible chart     |
//+------------------------------------------------------------------+
void HideSignalObject(const string name)
  {
   if(ObjectFind(0,name)>=0)
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,-2000);
  }

//+------------------------------------------------------------------+
//| Returns dimensions for the selected signal-label size            |
//+------------------------------------------------------------------+
void LabelMetrics(int &title_size,
                  int &text_size,
                  int &box_width,
                  int &box_height,
                  int &arrow_size)
  {
   switch(InpLabelSize)
     {
      case Label_Small:
         title_size=8;
         text_size=7;
         box_width=104;
         box_height=54;
         arrow_size=10;
         break;

      case Label_Normal:
         title_size=10;
         text_size=8;
         box_width=122;
         box_height=62;
         arrow_size=12;
         break;

      case Label_Large:
         title_size=11;
         text_size=9;
         box_width=140;
         box_height=70;
         arrow_size=13;
         break;

      default:
         title_size=7;
         text_size=6;
         box_width=94;
         box_height=48;
         arrow_size=9;
         break;
     }

   int symbol_length=StringLen(_Symbol);

   if(symbol_length>8)
     {
      int extra_width=(symbol_length-8)*6;

      if(extra_width>60)
         extra_width=60;

      box_width+=extra_width;
     }
  }

//+------------------------------------------------------------------+
//| Draws cached signal labels inside colored boxes                  |
//+------------------------------------------------------------------+
void RenderSignalLabels()
  {
   if(!InpShowLabels)
     {
      DeleteSignalObjects();
      return;
     }

   int subwindow=CurrentSubwindow();

   if(subwindow<1)
      return;

   int title_size=0;
   int text_size=0;
   int box_width=0;
   int box_height=0;
   int arrow_size=0;

   LabelMetrics(title_size,
                text_size,
                box_width,
                box_height,
                arrow_size);

   int chart_width=
      (int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);

   int window_height=
      (int)ChartGetInteger(0,
                           CHART_HEIGHT_IN_PIXELS,
                           subwindow);

   int window_top=
      (int)ChartGetInteger(0,
                           CHART_WINDOW_YDISTANCE,
                           subwindow);

//--- Position each cached signal label.
   for(int index=0;index<ArraySize(g_signals);index++)
     {
      string suffix=IntegerToString(index);

      string rect_name=
         g_prefix+"SIG_RECT_"+suffix;

      string title_name=
         g_prefix+"SIG_TITLE_"+suffix;

      string symbol_name=
         g_prefix+"SIG_SYMBOL_"+suffix;

      string rvol_name=
         g_prefix+"SIG_RVOL_"+suffix;

      string arrow_name=
         g_prefix+"SIG_ARROW_"+suffix;

      if(!EnsureRectangleLabel(rect_name,subwindow) ||
         !EnsureTextLabel(title_name,subwindow) ||
         !EnsureTextLabel(symbol_name,subwindow) ||
         !EnsureTextLabel(rvol_name,subwindow) ||
         !EnsureTextLabel(arrow_name,subwindow))
         continue;

      int x=0;
      int y=0;

      bool mapped=
         ChartTimePriceToXY(
            0,
            subwindow,
            g_signals[index].bar_time,
            g_signals[index].volume,
            x,
            y
         );

      int local_y=y-window_top;

      if(!mapped ||
         x<-box_width ||
         x>chart_width+box_width ||
         local_y<0 ||
         local_y>window_height+box_height)
        {
         HideSignalObject(rect_name);
         HideSignalObject(title_name);
         HideSignalObject(symbol_name);
         HideSignalObject(rvol_name);
         HideSignalObject(arrow_name);
         continue;
        }

      int box_left=x-box_width/2;
      int box_top=local_y-box_height-10;

      if(box_top<2)
         box_top=2;

      color background=
         SignalBackgroundColor(g_signals[index].state);

      color foreground=
         (g_signals[index].state==STATE_CLIMAX
          ? clrBlack
          : clrWhite);

      int center_x=x;
      int title_y=box_top+11;
      int symbol_y=box_top+box_height/2;
      int rvol_y=box_top+box_height-12;

      //--- Draw the colored box.
      ObjectSetInteger(
         0,
         rect_name,
         OBJPROP_XDISTANCE,
         box_left
      );

      ObjectSetInteger(
         0,
         rect_name,
         OBJPROP_YDISTANCE,
         box_top
      );

      ObjectSetInteger(
         0,
         rect_name,
         OBJPROP_XSIZE,
         box_width
      );

      ObjectSetInteger(
         0,
         rect_name,
         OBJPROP_YSIZE,
         box_height
      );

      ObjectSetInteger(
         0,
         rect_name,
         OBJPROP_BGCOLOR,
         background
      );

      ObjectSetInteger(
         0,
         rect_name,
         OBJPROP_COLOR,
         background
      );

      //--- Draw the signal heading.
      ObjectSetInteger(
         0,
         title_name,
         OBJPROP_XDISTANCE,
         center_x
      );

      ObjectSetInteger(
         0,
         title_name,
         OBJPROP_YDISTANCE,
         title_y
      );

      ObjectSetInteger(
         0,
         title_name,
         OBJPROP_ANCHOR,
         ANCHOR_CENTER
      );

      ObjectSetInteger(
         0,
         title_name,
         OBJPROP_COLOR,
         foreground
      );

      ObjectSetInteger(
         0,
         title_name,
         OBJPROP_FONTSIZE,
         title_size
      );

      ObjectSetString(
         0,
         title_name,
         OBJPROP_TEXT,
         SignalHeadingText(g_signals[index].state)
      );

      //--- Draw the symbol text.
      ObjectSetInteger(
         0,
         symbol_name,
         OBJPROP_XDISTANCE,
         center_x
      );

      ObjectSetInteger(
         0,
         symbol_name,
         OBJPROP_YDISTANCE,
         symbol_y
      );

      ObjectSetInteger(
         0,
         symbol_name,
         OBJPROP_ANCHOR,
         ANCHOR_CENTER
      );

      ObjectSetInteger(
         0,
         symbol_name,
         OBJPROP_COLOR,
         foreground
      );

      ObjectSetInteger(
         0,
         symbol_name,
         OBJPROP_FONTSIZE,
         text_size
      );

      ObjectSetString(
         0,
         symbol_name,
         OBJPROP_TEXT,
         _Symbol
      );

      //--- Draw the relative-volume text.
      ObjectSetInteger(
         0,
         rvol_name,
         OBJPROP_XDISTANCE,
         center_x
      );

      ObjectSetInteger(
         0,
         rvol_name,
         OBJPROP_YDISTANCE,
         rvol_y
      );

      ObjectSetInteger(
         0,
         rvol_name,
         OBJPROP_ANCHOR,
         ANCHOR_CENTER
      );

      ObjectSetInteger(
         0,
         rvol_name,
         OBJPROP_COLOR,
         foreground
      );

      ObjectSetInteger(
         0,
         rvol_name,
         OBJPROP_FONTSIZE,
         text_size
      );

      ObjectSetString(
         0,
         rvol_name,
         OBJPROP_TEXT,
         "RVOL "+FormatNumber2(g_signals[index].rvol)
      );

      //--- Draw the pointer below the box.
      ObjectSetInteger(
         0,
         arrow_name,
         OBJPROP_XDISTANCE,
         center_x
      );

      ObjectSetInteger(
         0,
         arrow_name,
         OBJPROP_YDISTANCE,
         box_top+box_height-1
      );

      ObjectSetInteger(
         0,
         arrow_name,
         OBJPROP_ANCHOR,
         ANCHOR_CENTER
      );

      ObjectSetInteger(
         0,
         arrow_name,
         OBJPROP_COLOR,
         background
      );

      ObjectSetInteger(
         0,
         arrow_name,
         OBJPROP_FONTSIZE,
         arrow_size
      );

      ObjectSetString(
         0,
         arrow_name,
         OBJPROP_TEXT,
         "▼"
      );
     }
  }

//+------------------------------------------------------------------+
//| Rebuilds the confirmed-bar signal cache                          |
//+------------------------------------------------------------------+
void BuildSignalCache(const int rates_total,
                      const datetime &time[])
  {
   ArrayResize(g_signals,0);

   if(!InpShowLabels)
     {
      DeleteSignalObjects();
      return;
     }

   int signal_count=0;

//--- Collect confirmed bars that contain significant signals.
   for(int index=1;
       index<rates_total &&
       signal_count<MAX_SIGNAL_LABELS;
       index++)
     {
      int state=(int)StateBuffer[index];

      if(state!=STATE_BULL &&
         state!=STATE_BEAR &&
         state!=STATE_ABSORB &&
         state!=STATE_CLIMAX)
         continue;

      ArrayResize(g_signals,signal_count+1);

      g_signals[signal_count].bar_time=time[index];
      g_signals[signal_count].volume=VolumeBuffer[index];
      g_signals[signal_count].rvol=RvolBuffer[index];
      g_signals[signal_count].state=state;

      signal_count++;
     }

   DeleteSignalObjects();
   RenderSignalLabels();
  }

//+------------------------------------------------------------------+
//| Creates or updates one dashboard cell                            |
//+------------------------------------------------------------------+
void CreateOrUpdateDashboardCell(const int row,
                                 const int column,
                                 const string text,
                                 const color text_color,
                                 const color background_color,
                                 const int subwindow)
  {
   const int margin=4;
   const int row_height=22;
   const int left_width=100;
   const int right_width=245;

   int width=
      (column==0 ? left_width : right_width);

   int x_from_right=
      (column==0
       ? margin+right_width+left_width
       : margin+right_width);

   int center_x=
      (column==0
       ? margin+right_width+left_width/2
       : margin+right_width/2);

   int top=margin+row*row_height;
   int center_y=top+row_height/2;

   string base_name=
      g_prefix+
      "DASH_"+
      IntegerToString(row)+
      "_"+
      IntegerToString(column);

   string rect_name=base_name+"_RECT";
   string text_name=base_name+"_TEXT";

//--- Create the cell background.
   if(ObjectFind(0,rect_name)<0)
     {
      if(!ObjectCreate(
            0,
            rect_name,
            OBJ_RECTANGLE_LABEL,
            subwindow,
            0,
            0))
         return;

      SetCommonObjectProperties(rect_name);

      ObjectSetInteger(
         0,
         rect_name,
         OBJPROP_CORNER,
         CORNER_RIGHT_UPPER
      );

      ObjectSetInteger(
         0,
         rect_name,
         OBJPROP_BORDER_TYPE,
         BORDER_FLAT
      );
     }

//--- Create the cell text.
   if(ObjectFind(0,text_name)<0)
     {
      if(!ObjectCreate(
            0,
            text_name,
            OBJ_LABEL,
            subwindow,
            0,
            0))
         return;

      SetCommonObjectProperties(text_name);

      ObjectSetInteger(
         0,
         text_name,
         OBJPROP_CORNER,
         CORNER_RIGHT_UPPER
      );

      ObjectSetInteger(
         0,
         text_name,
         OBJPROP_ANCHOR,
         ANCHOR_CENTER
      );

      ObjectSetString(
         0,
         text_name,
         OBJPROP_FONT,
         "Arial"
      );

      ObjectSetInteger(
         0,
         text_name,
         OBJPROP_FONTSIZE,
         9
      );
     }

//--- Update the cell position and appearance.
   ObjectSetInteger(
      0,
      rect_name,
      OBJPROP_XDISTANCE,
      x_from_right
   );

   ObjectSetInteger(
      0,
      rect_name,
      OBJPROP_YDISTANCE,
      top
   );

   ObjectSetInteger(
      0,
      rect_name,
      OBJPROP_XSIZE,
      width
   );

   ObjectSetInteger(
      0,
      rect_name,
      OBJPROP_YSIZE,
      row_height
   );

   ObjectSetInteger(
      0,
      rect_name,
      OBJPROP_BGCOLOR,
      background_color
   );

   ObjectSetInteger(
      0,
      rect_name,
      OBJPROP_COLOR,
      C'64,64,64'
   );

   ObjectSetInteger(
      0,
      text_name,
      OBJPROP_XDISTANCE,
      center_x
   );

   ObjectSetInteger(
      0,
      text_name,
      OBJPROP_YDISTANCE,
      center_y
   );

   ObjectSetInteger(
      0,
      text_name,
      OBJPROP_COLOR,
      text_color
   );

   ObjectSetString(
      0,
      text_name,
      OBJPROP_TEXT,
      text
   );
  }

//+------------------------------------------------------------------+
//| Draws the current volume dashboard                               |
//+------------------------------------------------------------------+
void RenderDashboard()
  {
   if(!InpShowDashboard)
     {
      DeleteDashboardObjects();
      return;
     }

   int subwindow=CurrentSubwindow();

   if(subwindow<1)
      return;

   color dashboard_background=
      BlendColors(clrBlack,clrBlack,0.90);

   color header_background=C'74,134,232';

   color state_background=
      StateBackgroundColor(g_dash_state);

   CreateOrUpdateDashboardCell(
      0,
      0,
      "Volume Strength",
      clrWhite,
      header_background,
      subwindow
   );

   CreateOrUpdateDashboardCell(
      0,
      1,
      _Symbol,
      clrWhite,
      header_background,
      subwindow
   );

   CreateOrUpdateDashboardCell(
      1,
      0,
      "Volume",
      clrWhite,
      dashboard_background,
      subwindow
   );

   CreateOrUpdateDashboardCell(
      1,
      1,
      FormatVolume(g_dash_volume),
      clrWhite,
      dashboard_background,
      subwindow
   );

   CreateOrUpdateDashboardCell(
      2,
      0,
      "Avg Volume",
      clrWhite,
      dashboard_background,
      subwindow
   );

   CreateOrUpdateDashboardCell(
      2,
      1,
      FormatVolume(g_dash_avg),
      clrWhite,
      dashboard_background,
      subwindow
   );

   CreateOrUpdateDashboardCell(
      3,
      0,
      "RVOL",
      clrWhite,
      dashboard_background,
      subwindow
   );

   CreateOrUpdateDashboardCell(
      3,
      1,
      FormatNumber2(g_dash_rvol),
      clrWhite,
      dashboard_background,
      subwindow
   );

   CreateOrUpdateDashboardCell(
      4,
      0,
      "Body %",
      clrWhite,
      dashboard_background,
      subwindow
   );

   CreateOrUpdateDashboardCell(
      4,
      1,
      FormatNumber2(g_dash_bodypct),
      clrWhite,
      dashboard_background,
      subwindow
   );

   CreateOrUpdateDashboardCell(
      5,
      0,
      "State",
      clrWhite,
      dashboard_background,
      subwindow
   );

   CreateOrUpdateDashboardCell(
      5,
      1,
      StateText(g_dash_state),
      clrWhite,
      state_background,
      subwindow
   );

   CreateOrUpdateDashboardCell(
      6,
      0,
      "Volume Use",
      clrWhite,
      dashboard_background,
      subwindow
   );

   CreateOrUpdateDashboardCell(
      6,
      1,
      VolumeUseText(g_dash_state),
      clrWhite,
      dashboard_background,
      subwindow
   );
  }

//+------------------------------------------------------------------+
//| Sends one alert through all enabled notification channels        |
//+------------------------------------------------------------------+
void DispatchOneAlert(const string message)
  {
   if(InpPopupAlert)
      Alert(message);

   if(InpPushAlert)
      SendNotification(message);

   if(InpEmailAlert)
      SendMail("Volume Strength Compass",message);
  }

//+------------------------------------------------------------------+
//| Sends alerts represented by the supplied signal flags            |
//+------------------------------------------------------------------+
void DispatchFlagAlerts(const int flags)
  {
   if((flags&FLAG_BULL)!=0)
      DispatchOneAlert(
         "Bull good volume detected on "+_Symbol
      );

   if((flags&FLAG_BEAR)!=0)
      DispatchOneAlert(
         "Bear good volume detected on "+_Symbol
      );

   if((flags&FLAG_ABSORB)!=0)
      DispatchOneAlert(
         "Absorption volume detected on "+_Symbol
      );

   if((flags&FLAG_CLIMAX)!=0)
      DispatchOneAlert(
         "Climax volume detected on "+_Symbol
      );
  }

//+------------------------------------------------------------------+
//| Processes closed-bar or live-bar alerts                          |
//+------------------------------------------------------------------+
void ProcessAlerts(const datetime &time[],
                   const int rates_total)
  {
   if(!InpEnableAlerts || rates_total<2)
      return;

   if(InpAlertTiming==Alert_On_Closed_Bar)
     {
      if(!g_alert_initialized)
        {
         g_last_closed_alert_time=time[1];
         g_alert_initialized=true;
         return;
        }

      if(time[1]!=g_last_closed_alert_time)
        {
         DispatchFlagAlerts((int)FlagsBuffer[1]);
         g_last_closed_alert_time=time[1];
        }

      return;
     }

   if(!g_alert_initialized)
     {
      g_live_alert_bar_time=time[0];
      g_live_sent_flags=(int)FlagsBuffer[0];
      g_alert_initialized=true;
      return;
     }

   if(time[0]!=g_live_alert_bar_time)
     {
      g_live_alert_bar_time=time[0];
      g_live_sent_flags=0;
     }

   int signal_mask=
      FLAG_BULL|
      FLAG_BEAR|
      FLAG_ABSORB|
      FLAG_CLIMAX;

   int current_flags=
      ((int)FlagsBuffer[0])&signal_mask;

   int new_flags=
      current_flags&(~g_live_sent_flags);

   if(new_flags!=0)
     {
      DispatchFlagAlerts(new_flags);
      g_live_sent_flags|=new_flags;
     }
  }

//+------------------------------------------------------------------+
//| Binds and configures all indicator buffers                       |
//+------------------------------------------------------------------+
void ConfigureBuffers()
  {
   SetIndexBuffer(0,BgLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,BgHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,BgColorBuffer,INDICATOR_COLOR_INDEX);

   SetIndexBuffer(3,VolumeBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,VolumeColorBuffer,INDICATOR_COLOR_INDEX);

   SetIndexBuffer(5,AvgPlotBuffer,INDICATOR_DATA);

   SetIndexBuffer(6,AvgCalcBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,RvolBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BodyPctBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,StateBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,FlagsBuffer,INDICATOR_CALCULATIONS);

   ArraySetAsSeries(BgLowBuffer,true);
   ArraySetAsSeries(BgHighBuffer,true);
   ArraySetAsSeries(BgColorBuffer,true);

   ArraySetAsSeries(VolumeBuffer,true);
   ArraySetAsSeries(VolumeColorBuffer,true);

   ArraySetAsSeries(AvgPlotBuffer,true);
   ArraySetAsSeries(AvgCalcBuffer,true);

   ArraySetAsSeries(RvolBuffer,true);
   ArraySetAsSeries(BodyPctBuffer,true);
   ArraySetAsSeries(StateBuffer,true);
   ArraySetAsSeries(FlagsBuffer,true);
  }

//+------------------------------------------------------------------+
//| Initializes the indicator                                        |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_prefix=
      "VSC_"+
      IntegerToString((int)GetTickCount())+
      "_";

   ConfigureBuffers();

   int average_length=SafeAverageLength();

   PlotIndexSetDouble(
      0,
      PLOT_EMPTY_VALUE,
      EMPTY_VALUE
   );

   PlotIndexSetDouble(
      1,
      PLOT_EMPTY_VALUE,
      EMPTY_VALUE
   );

   PlotIndexSetDouble(
      2,
      PLOT_EMPTY_VALUE,
      EMPTY_VALUE
   );

   PlotIndexSetInteger(
      2,
      PLOT_DRAW_BEGIN,
      average_length-1
   );

   IndicatorSetString(
      INDICATOR_SHORTNAME,
      g_short_name
   );

   IndicatorSetInteger(
      INDICATOR_DIGITS,
      2
   );

   ConfigurePlotColors();

   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Removes indicator-created chart objects                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,g_prefix);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Calculates volume states, plots, labels, dashboard, and alerts   |
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
   if(rates_total<=0)
      return 0;

   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
   ArraySetAsSeries(volume,true);

   int average_length=SafeAverageLength();

   double high_rvol_level=
      SafeHighRvolLevel();

   double climax_rvol_level=
      SafeClimaxRvolLevel(high_rvol_level);

   double low_rvol_level=
      SafeLowRvolLevel(high_rvol_level);

   double minimum_body_percent=
      SafePercent(
         InpMinBodyPct,
         55.0,
         1.0,
         100.0
      );

   double close_strength_percent=
      SafePercent(
         InpCloseStrengthPct,
         70.0,
         50.0,
         100.0
      );

   double absorption_body_percent=
      SafePercent(
         InpAbsorbBodyPct,
         35.0,
         1.0,
         100.0
      );

   bool full_recalculation=
      (prev_calculated==0 ||
       rates_total-prev_calculated>1);

   int recalculate_to=0;

   if(full_recalculation)
     {
      recalculate_to=rates_total-1;
     }
   else
      if(rates_total>prev_calculated)
        {
         recalculate_to=
            (int)MathMin(
               rates_total-1,
               BG_LOOKBACK_BARS+
               average_length+
               5
            );
        }

   for(int index=recalculate_to;index>=0;index--)
     {
      VolumeBuffer[index]=
         SelectedVolume(
            index,
            tick_volume,
            volume
         );
     }

   for(int index=recalculate_to;index>=0;index--)
     {
      double average_volume=EMPTY_VALUE;

      if(index+average_length<=rates_total)
        {
         double volume_sum=0.0;

         for(int sample=index;
             sample<index+average_length;
             sample++)
           {
            volume_sum+=VolumeBuffer[sample];
           }

         average_volume=
            volume_sum/(double)average_length;
        }

      AvgCalcBuffer[index]=average_volume;

      AvgPlotBuffer[index]=
         (InpShowAvgVolLine
          ? average_volume
          : EMPTY_VALUE);

      double candle_range=
         high[index]-low[index];

      double candle_body=
         MathAbs(close[index]-open[index]);

      double body_percent=
         (candle_range>0.0
          ? candle_body/candle_range*100.0
          : 0.0);

      double close_position_percent=
         (candle_range>0.0
          ? (close[index]-low[index])/
          candle_range*100.0
          : 50.0);

      double relative_volume=
         (average_volume!=EMPTY_VALUE &&
          average_volume>0.0
          ? VolumeBuffer[index]/average_volume
          : EMPTY_VALUE);

      BodyPctBuffer[index]=body_percent;
      RvolBuffer[index]=relative_volume;

      bool has_volume_data=
         (VolumeBuffer[index]>0.0 &&
          average_volume!=EMPTY_VALUE &&
          average_volume>0.0 &&
          relative_volume!=EMPTY_VALUE);

      bool high_volume=
         (has_volume_data &&
          relative_volume>=high_rvol_level);

      bool climax_volume=
         (has_volume_data &&
          relative_volume>=climax_rvol_level);

      bool low_volume=
         (has_volume_data &&
          relative_volume<=low_rvol_level);

      bool strong_body=
         (body_percent>=minimum_body_percent);

      bool small_body=
         (body_percent<=absorption_body_percent);

      bool close_near_high=
         (close_position_percent>=
          close_strength_percent);

      bool close_near_low=
         (close_position_percent<=
          100.0-close_strength_percent);

      bool bullish_candle=
         (close[index]>open[index]);

      bool bearish_candle=
         (close[index]<open[index]);

      bool bull_good_volume=
         (high_volume &&
          bullish_candle &&
          strong_body &&
          close_near_high);

      bool bear_good_volume=
         (high_volume &&
          bearish_candle &&
          strong_body &&
          close_near_low);

      bool absorption_volume=
         (high_volume && small_body);

      //--- Build the signal-flag mask.
      int flags=0;

      if(high_volume)
         flags|=FLAG_HIGH;

      if(climax_volume)
         flags|=FLAG_CLIMAX;

      if(low_volume)
         flags|=FLAG_LOW;

      if(bull_good_volume)
         flags|=FLAG_BULL;

      if(bear_good_volume)
         flags|=FLAG_BEAR;

      if(absorption_volume)
         flags|=FLAG_ABSORB;

      FlagsBuffer[index]=(double)flags;


      int state=STATE_NORMAL;
      int volume_color_index=0;

      if(bull_good_volume)
        {
         state=STATE_BULL;
         volume_color_index=2;
        }
      else
         if(bear_good_volume)
           {
            state=STATE_BEAR;
            volume_color_index=3;
           }
         else
            if(absorption_volume)
              {
               state=STATE_ABSORB;
               volume_color_index=4;
              }
            else
               if(climax_volume)
                 {
                  state=STATE_CLIMAX;
                  volume_color_index=5;
                 }
               else
                  if(high_volume)
                    {
                     state=STATE_HIGH;
                     volume_color_index=0;
                    }
                  else
                     if(low_volume)
                       {
                        state=STATE_LOW;
                        volume_color_index=1;
                       }

      StateBuffer[index]=(double)state;

      VolumeColorBuffer[index]=
         (double)volume_color_index;

      //--- Calculate the pane background highlight.
      if(InpShowBgHighlight &&
         (state==STATE_BULL ||
          state==STATE_BEAR ||
          state==STATE_ABSORB))
        {
         double local_maximum=0.0;

         int final_bar=
            (int)MathMin(
               rates_total-1,
               index+BG_LOOKBACK_BARS-1
            );

         for(int sample=index;
             sample<=final_bar;
             sample++)
           {
            local_maximum=
               MathMax(
                  local_maximum,
                  VolumeBuffer[sample]
               );

            if(AvgCalcBuffer[sample]!=EMPTY_VALUE)
              {
               local_maximum=
                  MathMax(
                     local_maximum,
                     AvgCalcBuffer[sample]
                  );
              }
           }

         BgLowBuffer[index]=0.0;

         BgHighBuffer[index]=
            (local_maximum>0.0
             ? local_maximum*1.10
             : EMPTY_VALUE);

         if(state==STATE_BULL)
            BgColorBuffer[index]=0.0;
         else
            if(state==STATE_BEAR)
               BgColorBuffer[index]=1.0;
            else
               BgColorBuffer[index]=2.0;
        }
      else
        {
         BgLowBuffer[index]=EMPTY_VALUE;
         BgHighBuffer[index]=EMPTY_VALUE;
         BgColorBuffer[index]=0.0;
        }
     }


   g_dash_volume=VolumeBuffer[0];
   g_dash_avg=AvgCalcBuffer[0];
   g_dash_rvol=RvolBuffer[0];
   g_dash_bodypct=BodyPctBuffer[0];
   g_dash_state=(int)StateBuffer[0];

   RenderDashboard();


   if(full_recalculation ||
      time[0]!=g_last_bar_time)
     {
      g_last_bar_time=time[0];

      BuildSignalCache(
         rates_total,
         time
      );
     }


   ProcessAlerts(
      time,
      rates_total
   );

   return rates_total;
  }

//+------------------------------------------------------------------+
//| Repositions pixel-based objects after chart layout changes       |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id!=CHARTEVENT_CHART_CHANGE)
      return;

   ConfigurePlotColors();
   RenderSignalLabels();
   RenderDashboard();
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
