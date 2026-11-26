// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.
// Created by Vian — Systematic Trading Builder

#property copyright "Created by Vian — Systematic Trading Builder"
#property version   "1.00"
#property description "See multi-timeframe trend alignment at a glance."
#property description "Market-context indicator; not a standalone trading signal."
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_NONE
#property indicator_label1  "MTF Trend Context"

enum ENUM_MTF_PRESET
  {
   MTF_PRESET_SCALPING=0,   // Scalping
   MTF_PRESET_INTRADAY=1,   // Intraday
   MTF_PRESET_SWING=2,      // Swing
   MTF_PRESET_CUSTOM=3      // Custom
  };

enum ENUM_PANEL_CORNER
  {
   PANEL_TOP_RIGHT=0,       // Top Right
   PANEL_TOP_LEFT=1,        // Top Left
   PANEL_BOTTOM_RIGHT=2,    // Bottom Right
   PANEL_BOTTOM_LEFT=3      // Bottom Left
  };

enum ENUM_PANEL_TEXT_SIZE
  {
   PANEL_TEXT_SMALL=8,      // Small
   PANEL_TEXT_MEDIUM=9,     // Medium
   PANEL_TEXT_LARGE=10      // Large
  };

enum ENUM_TREND_STATE
  {
   STATE_BEARISH=-1,
   STATE_NEUTRAL=0,
   STATE_BULLISH=1,
   STATE_NA=99
  };

input group "Trend"
input int                  InpFastEMALength=20;                    // Fast EMA Length
input int                  InpSlowEMALength=50;                    // Slow EMA Length

input group "Timeframes"
input ENUM_MTF_PRESET      InpPreset=MTF_PRESET_INTRADAY;          // Preset
input ENUM_TIMEFRAMES      InpCustomTF1=PERIOD_M5;                 // Custom TF1
input ENUM_TIMEFRAMES      InpCustomTF2=PERIOD_M15;                // Custom TF2
input ENUM_TIMEFRAMES      InpCustomTF3=PERIOD_H1;                 // Custom TF3
input ENUM_TIMEFRAMES      InpCustomTF4=PERIOD_H4;                 // Custom TF4
input ENUM_TIMEFRAMES      InpCustomTF5=PERIOD_D1;                 // Custom TF5

input group "Display"
input ENUM_PANEL_CORNER    InpPanelCorner=PANEL_TOP_RIGHT;         // Panel Corner
input ENUM_PANEL_TEXT_SIZE InpTextSize=PANEL_TEXT_MEDIUM;          // Text Size
input bool                 InpShowAlignment=true;                   // Show Alignment

#define TF_COUNT 5
#define PANEL_WIDTH 240
#define TF_COLUMN_WIDTH 60
#define HEADER_HEIGHT 26
#define COLUMN_HEADER_HEIGHT 20
#define ROW_HEIGHT 22
#define FOOTER_HEIGHT 24
#define PANEL_MARGIN_X 12
#define PANEL_MARGIN_Y 12

ENUM_TIMEFRAMES g_timeframes[TF_COUNT];
int             g_fast_handles[TF_COUNT];
int             g_slow_handles[TF_COUNT];
ENUM_TREND_STATE g_states[TF_COUNT];
datetime        g_closed_bar_times[TF_COUNT];
double          g_dummy_buffer[];
string          g_prefix="";
int             g_panel_height=0;
bool            g_panel_ready=false;

//+------------------------------------------------------------------+
//| Resolve a custom PERIOD_CURRENT input to the current chart period.|
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES NormalizeTimeframe(const ENUM_TIMEFRAMES timeframe)
  {
   if(timeframe==PERIOD_CURRENT)
      return((ENUM_TIMEFRAMES)_Period);
   return(timeframe);
  }

//+------------------------------------------------------------------+
//| Convert selected preset into five concrete timeframes.            |
//+------------------------------------------------------------------+
void ResolveTimeframes()
  {
   switch(InpPreset)
     {
      case MTF_PRESET_SCALPING:
         g_timeframes[0]=PERIOD_M1;
         g_timeframes[1]=PERIOD_M5;
         g_timeframes[2]=PERIOD_M15;
         g_timeframes[3]=PERIOD_H1;
         g_timeframes[4]=PERIOD_H4;
         break;

      case MTF_PRESET_SWING:
         g_timeframes[0]=PERIOD_H1;
         g_timeframes[1]=PERIOD_H4;
         g_timeframes[2]=PERIOD_D1;
         g_timeframes[3]=PERIOD_W1;
         g_timeframes[4]=PERIOD_MN1;
         break;

      case MTF_PRESET_CUSTOM:
         g_timeframes[0]=NormalizeTimeframe(InpCustomTF1);
         g_timeframes[1]=NormalizeTimeframe(InpCustomTF2);
         g_timeframes[2]=NormalizeTimeframe(InpCustomTF3);
         g_timeframes[3]=NormalizeTimeframe(InpCustomTF4);
         g_timeframes[4]=NormalizeTimeframe(InpCustomTF5);
         break;

      case MTF_PRESET_INTRADAY:
      default:
         g_timeframes[0]=PERIOD_M5;
         g_timeframes[1]=PERIOD_M15;
         g_timeframes[2]=PERIOD_H1;
         g_timeframes[3]=PERIOD_H4;
         g_timeframes[4]=PERIOD_D1;
         break;
     }
  }

//+------------------------------------------------------------------+
//| Human-readable timeframe label.                                  |
//+------------------------------------------------------------------+
string TimeframeLabel(const ENUM_TIMEFRAMES timeframe)
  {
   switch(timeframe)
     {
      case PERIOD_M1:  return("M1");
      case PERIOD_M2:  return("M2");
      case PERIOD_M3:  return("M3");
      case PERIOD_M4:  return("M4");
      case PERIOD_M5:  return("M5");
      case PERIOD_M6:  return("M6");
      case PERIOD_M10: return("M10");
      case PERIOD_M12: return("M12");
      case PERIOD_M15: return("M15");
      case PERIOD_M20: return("M20");
      case PERIOD_M30: return("M30");
      case PERIOD_H1:  return("H1");
      case PERIOD_H2:  return("H2");
      case PERIOD_H3:  return("H3");
      case PERIOD_H4:  return("H4");
      case PERIOD_H6:  return("H6");
      case PERIOD_H8:  return("H8");
      case PERIOD_H12: return("H12");
      case PERIOD_D1:  return("D1");
      case PERIOD_W1:  return("W1");
      case PERIOD_MN1: return("MN1");
      default:         return(EnumToString(timeframe));
     }
  }

//+------------------------------------------------------------------+
//| State text.                                                       |
//+------------------------------------------------------------------+
string StateText(const ENUM_TREND_STATE state)
  {
   switch(state)
     {
      case STATE_BULLISH: return("BULLISH");
      case STATE_BEARISH: return("BEARISH");
      case STATE_NEUTRAL: return("NEUTRAL");
      default:            return("N/A");
     }
  }

//+------------------------------------------------------------------+
//| State cell color.                                                 |
//+------------------------------------------------------------------+
color StateBackground(const ENUM_TREND_STATE state)
  {
   switch(state)
     {
      case STATE_BULLISH: return(C'62,116,91');
      case STATE_BEARISH: return(C'148,76,76');
      case STATE_NEUTRAL: return(C'78,85,94');
      default:            return(C'55,61,69');
     }
  }

//+------------------------------------------------------------------+
//| Resolve the panel's top-left pixel origin inside the chart.      |
//| All cells use CORNER_LEFT_UPPER; requested corners only affect   |
//| this origin calculation. This keeps multi-column geometry intact.|
//+------------------------------------------------------------------+
bool GetPanelOrigin(int &origin_x,int &origin_y)
  {
   long chart_width=0;
   long chart_height=0;

   if(!ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,chart_width) ||
      !ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0,chart_height))
     {
      origin_x=PANEL_MARGIN_X;
      origin_y=PANEL_MARGIN_Y;
      return(false);
     }

   const bool align_right=(InpPanelCorner==PANEL_TOP_RIGHT ||
                           InpPanelCorner==PANEL_BOTTOM_RIGHT);
   const bool align_bottom=(InpPanelCorner==PANEL_BOTTOM_RIGHT ||
                            InpPanelCorner==PANEL_BOTTOM_LEFT);

   int right_x=(int)chart_width-PANEL_MARGIN_X-PANEL_WIDTH;
   int bottom_y=(int)chart_height-PANEL_MARGIN_Y-g_panel_height;

   if(right_x<PANEL_MARGIN_X)
      right_x=PANEL_MARGIN_X;
   if(bottom_y<PANEL_MARGIN_Y)
      bottom_y=PANEL_MARGIN_Y;

   origin_x=align_right ? right_x : PANEL_MARGIN_X;
   origin_y=align_bottom ? bottom_y : PANEL_MARGIN_Y;
   return(true);
  }

//+------------------------------------------------------------------+
//| Move an existing cell using panel-local coordinates.             |
//+------------------------------------------------------------------+
void PositionCell(const string suffix,
                  const int local_x,
                  const int local_y,
                  const int origin_x,
                  const int origin_y)
  {
   string name=g_prefix+suffix;
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,origin_x+local_x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,origin_y+local_y);
  }

//+------------------------------------------------------------------+
//| Reposition the existing panel after creation or chart resize.    |
//+------------------------------------------------------------------+
void RepositionPanel()
  {
   int origin_x=PANEL_MARGIN_X;
   int origin_y=PANEL_MARGIN_Y;
   GetPanelOrigin(origin_x,origin_y);

   int y=0;
   PositionCell("HEADER",0,y,origin_x,origin_y);
   y+=HEADER_HEIGHT;

   PositionCell("COL_TF",0,y,origin_x,origin_y);
   PositionCell("COL_STATE",TF_COLUMN_WIDTH,y,origin_x,origin_y);
   y+=COLUMN_HEADER_HEIGHT;

   for(int i=0;i<TF_COUNT;i++)
     {
      string index=IntegerToString(i);
      PositionCell("TF_"+index,0,y,origin_x,origin_y);
      PositionCell("STATE_"+index,TF_COLUMN_WIDTH,y,origin_x,origin_y);
      y+=ROW_HEIGHT;
     }

   if(InpShowAlignment)
     {
      PositionCell("ALIGN_LABEL",0,y,origin_x,origin_y);
      PositionCell("ALIGN_VALUE",TF_COLUMN_WIDTH,y,origin_x,origin_y);
     }

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Create one read-only UI cell.                                    |
//+------------------------------------------------------------------+
bool CreateCell(const string suffix,
                const int local_x,
                const int local_y,
                const int width,
                const int height,
                const string text,
                const color background,
                const color foreground,
                const ENUM_ALIGN_MODE alignment,
                const int font_size)
  {
   string name=g_prefix+suffix;

   if(!ObjectCreate(0,name,OBJ_EDIT,0,0,0))
     {
      PrintFormat("MTF Trend Context: failed to create chart object '%s'. Error %d",name,GetLastError());
      return(false);
     }

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,PANEL_MARGIN_X+local_x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,PANEL_MARGIN_Y+local_y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_ALIGN,alignment);
   ObjectSetInteger(0,name,OBJPROP_READONLY,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_COLOR,foreground);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,background);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,C'70,78,88');
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   return(true);
  }

//+------------------------------------------------------------------+
//| Build the panel once.                                            |
//+------------------------------------------------------------------+
bool BuildPanel()
  {
   const int text_size=(int)InpTextSize;
   const int state_width=PANEL_WIDTH-TF_COLUMN_WIDTH;
   int y=0;

   if(!CreateCell("HEADER",0,y,PANEL_WIDTH,HEADER_HEIGHT,"MTF TREND CONTEXT",C'55,79,102',clrWhite,ALIGN_CENTER,text_size+1))
      return(false);
   y+=HEADER_HEIGHT;

   if(!CreateCell("COL_TF",0,y,TF_COLUMN_WIDTH,COLUMN_HEADER_HEIGHT,"TF",C'45,52,61',C'205,210,216',ALIGN_CENTER,text_size))
      return(false);
   if(!CreateCell("COL_STATE",TF_COLUMN_WIDTH,y,state_width,COLUMN_HEADER_HEIGHT,"STATE",C'45,52,61',C'205,210,216',ALIGN_CENTER,text_size))
      return(false);
   y+=COLUMN_HEADER_HEIGHT;

   for(int i=0;i<TF_COUNT;i++)
     {
      string index=IntegerToString(i);
      if(!CreateCell("TF_"+index,0,y,TF_COLUMN_WIDTH,ROW_HEIGHT,TimeframeLabel(g_timeframes[i]),C'24,28,33',clrWhite,ALIGN_CENTER,text_size))
         return(false);
      if(!CreateCell("STATE_"+index,TF_COLUMN_WIDTH,y,state_width,ROW_HEIGHT,"N/A",StateBackground(STATE_NA),clrWhite,ALIGN_CENTER,text_size))
         return(false);
      y+=ROW_HEIGHT;
     }

   if(InpShowAlignment)
     {
      if(!CreateCell("ALIGN_LABEL",0,y,TF_COLUMN_WIDTH,FOOTER_HEIGHT,"Alignment",C'45,52,61',C'205,210,216',ALIGN_CENTER,text_size))
         return(false);
      if(!CreateCell("ALIGN_VALUE",TF_COLUMN_WIDTH,y,state_width,FOOTER_HEIGHT,"MIXED (0/5 data)",C'78,85,94',clrWhite,ALIGN_CENTER,text_size))
         return(false);
     }

   RepositionPanel();
   return(true);
  }

//+------------------------------------------------------------------+
//| Release iMA handles without double-releasing duplicate handles.  |
//+------------------------------------------------------------------+
void ReleaseHandles()
  {
   int released[TF_COUNT*2];
   int released_count=0;

   for(int i=0;i<TF_COUNT;i++)
     {
      int handles[2];
      handles[0]=g_fast_handles[i];
      handles[1]=g_slow_handles[i];

      for(int j=0;j<2;j++)
        {
         int handle=handles[j];
         if(handle==INVALID_HANDLE)
            continue;

         bool already_released=false;
         for(int k=0;k<released_count;k++)
           {
            if(released[k]==handle)
              {
               already_released=true;
               break;
              }
           }

         if(!already_released)
           {
            IndicatorRelease(handle);
            released[released_count]=handle;
            released_count++;
           }
        }

      g_fast_handles[i]=INVALID_HANDLE;
      g_slow_handles[i]=INVALID_HANDLE;
     }
  }

//+------------------------------------------------------------------+
//| Create the two EMA handles for each selected timeframe.          |
//+------------------------------------------------------------------+
bool CreateHandles()
  {
   for(int i=0;i<TF_COUNT;i++)
     {
      g_fast_handles[i]=INVALID_HANDLE;
      g_slow_handles[i]=INVALID_HANDLE;

      g_fast_handles[i]=iMA(_Symbol,g_timeframes[i],InpFastEMALength,0,MODE_EMA,PRICE_CLOSE);
      if(g_fast_handles[i]==INVALID_HANDLE)
        {
         PrintFormat("MTF Trend Context: failed to create Fast EMA handle for %s. Error %d",TimeframeLabel(g_timeframes[i]),GetLastError());
         return(false);
        }

      g_slow_handles[i]=iMA(_Symbol,g_timeframes[i],InpSlowEMALength,0,MODE_EMA,PRICE_CLOSE);
      if(g_slow_handles[i]==INVALID_HANDLE)
        {
         PrintFormat("MTF Trend Context: failed to create Slow EMA handle for %s. Error %d",TimeframeLabel(g_timeframes[i]),GetLastError());
         return(false);
        }
     }

   return(true);
  }

//+------------------------------------------------------------------+
//| Return state from the most recently CLOSED bar of one timeframe. |
//+------------------------------------------------------------------+
ENUM_TREND_STATE ReadClosedBarState(const int index)
  {
   ENUM_TIMEFRAMES timeframe=g_timeframes[index];
   int fast_handle=g_fast_handles[index];
   int slow_handle=g_slow_handles[index];

   if(fast_handle==INVALID_HANDLE || slow_handle==INVALID_HANDLE)
      return(STATE_NA);

   long synchronized=0;
   if(!SeriesInfoInteger(_Symbol,timeframe,SERIES_SYNCHRONIZED,synchronized) || synchronized==0)
     {
      double sync_probe[1];
      CopyClose(_Symbol,timeframe,1,1,sync_probe);
      return(STATE_NA);
     }

   int bars=Bars(_Symbol,timeframe);
   if(bars<InpSlowEMALength+1)
      return(STATE_NA);

   int fast_calculated=BarsCalculated(fast_handle);
   int slow_calculated=BarsCalculated(slow_handle);
   if(fast_calculated<InpFastEMALength+1 || slow_calculated<InpSlowEMALength+1)
      return(STATE_NA);

   double closed_price[1];
   double fast_ema[1];
   double slow_ema[1];

   ResetLastError();
   if(CopyClose(_Symbol,timeframe,1,1,closed_price)!=1)
      return(STATE_NA);
   if(CopyBuffer(fast_handle,0,1,1,fast_ema)!=1)
      return(STATE_NA);
   if(CopyBuffer(slow_handle,0,1,1,slow_ema)!=1)
      return(STATE_NA);

   if(fast_ema[0]==EMPTY_VALUE || slow_ema[0]==EMPTY_VALUE)
      return(STATE_NA);

   if(closed_price[0]>fast_ema[0] && fast_ema[0]>slow_ema[0])
      return(STATE_BULLISH);
   if(closed_price[0]<fast_ema[0] && fast_ema[0]<slow_ema[0])
      return(STATE_BEARISH);
   return(STATE_NEUTRAL);
  }

//+------------------------------------------------------------------+
//| Latest closed bar's open time for refresh detection.             |
//+------------------------------------------------------------------+
datetime ClosedBarTime(const ENUM_TIMEFRAMES timeframe)
  {
   datetime values[1];
   if(CopyTime(_Symbol,timeframe,1,1,values)!=1)
      return(0);
   return(values[0]);
  }

//+------------------------------------------------------------------+
//| Determine whether states should be refreshed.                    |
//+------------------------------------------------------------------+
bool NeedsRefresh()
  {
   if(!g_panel_ready)
      return(true);

   for(int i=0;i<TF_COUNT;i++)
     {
      if(g_states[i]==STATE_NA)
         return(true);

      datetime closed_time=ClosedBarTime(g_timeframes[i]);
      if(closed_time==0 || closed_time!=g_closed_bar_times[i])
         return(true);
     }

   return(false);
  }

//+------------------------------------------------------------------+
//| Update one panel cell without rebuilding chart objects.          |
//+------------------------------------------------------------------+
void UpdateCell(const string suffix,const string text,const color background)
  {
   string name=g_prefix+suffix;
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,background);
  }

//+------------------------------------------------------------------+
//| Recalculate states and update panel text/colors.                 |
//+------------------------------------------------------------------+
void RefreshPanel()
  {
   int bullish_count=0;
   int bearish_count=0;
   int valid_count=0;

   for(int i=0;i<TF_COUNT;i++)
     {
      g_states[i]=ReadClosedBarState(i);
      g_closed_bar_times[i]=ClosedBarTime(g_timeframes[i]);

      if(g_states[i]==STATE_BULLISH)
         bullish_count++;
      else if(g_states[i]==STATE_BEARISH)
         bearish_count++;

      if(g_states[i]!=STATE_NA)
         valid_count++;

      UpdateCell("STATE_"+IntegerToString(i),StateText(g_states[i]),StateBackground(g_states[i]));
     }

   if(InpShowAlignment)
     {
      string alignment="MIXED";
      color alignment_background=C'78,85,94';

      if(valid_count<5)
         alignment=StringFormat("MIXED (%d/5 data)",valid_count);
      else if(bullish_count==5)
        {
         alignment="ALL BULLISH (5/5)";
         alignment_background=StateBackground(STATE_BULLISH);
        }
      else if(bullish_count==4)
        {
         alignment="MOSTLY BULLISH (4/5)";
         alignment_background=StateBackground(STATE_BULLISH);
        }
      else if(bearish_count==5)
        {
         alignment="ALL BEARISH (5/5)";
         alignment_background=StateBackground(STATE_BEARISH);
        }
      else if(bearish_count==4)
        {
         alignment="MOSTLY BEARISH (4/5)";
         alignment_background=StateBackground(STATE_BEARISH);
        }

      UpdateCell("ALIGN_VALUE",alignment,alignment_background);
     }

   g_panel_ready=true;
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Indicator initialization.                                       |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpFastEMALength<1)
     {
      Print("MTF Trend Context: Fast EMA Length must be at least 1.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpSlowEMALength<2 || InpSlowEMALength<=InpFastEMALength)
     {
      Print("MTF Trend Context: Slow EMA Length must be greater than Fast EMA Length.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(!SetIndexBuffer(0,g_dummy_buffer,INDICATOR_DATA))
     {
      PrintFormat("MTF Trend Context: SetIndexBuffer() failed. Error %d",GetLastError());
      return(INIT_FAILED);
     }
   ArraySetAsSeries(g_dummy_buffer,true);
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   IndicatorSetString(INDICATOR_SHORTNAME,"MTF Trend Context [Vian]");

   ResolveTimeframes();
   g_panel_height=HEADER_HEIGHT+COLUMN_HEADER_HEIGHT+(ROW_HEIGHT*TF_COUNT)+(InpShowAlignment ? FOOTER_HEIGHT : 0);
   g_prefix="Vian_MTFTrendContext_"+IntegerToString(ChartID())+"_"+IntegerToString((long)GetTickCount())+"_";

   for(int i=0;i<TF_COUNT;i++)
     {
      g_fast_handles[i]=INVALID_HANDLE;
      g_slow_handles[i]=INVALID_HANDLE;
      g_states[i]=STATE_NA;
      g_closed_bar_times[i]=0;
     }

   if(!CreateHandles())
     {
      ReleaseHandles();
      return(INIT_FAILED);
     }

   if(!BuildPanel())
     {
      ObjectsDeleteAll(0,g_prefix);
      ReleaseHandles();
      return(INIT_FAILED);
     }

   g_panel_ready=false;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Indicator calculation.                                          |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   if(rates_total>0)
      g_dummy_buffer[0]=EMPTY_VALUE;

   if(prev_calculated==0 || NeedsRefresh())
      RefreshPanel();

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Keep corner-anchored panel visually current after chart changes. |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE)
      RepositionPanel();
  }

//+------------------------------------------------------------------+
//| Indicator deinitialization.                                     |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,g_prefix);
   ReleaseHandles();
   ChartRedraw(0);
  }
