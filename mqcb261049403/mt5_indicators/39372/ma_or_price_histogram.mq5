//+------------------------------------------------------------------+
//|                                        MA or Price Histogram.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.003"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   3
//+------------------------------------------------------------------+
//| Enum MA Price                                                    |
//+------------------------------------------------------------------+
enum ENUM_MA_PRICE
  {
   price_fast=0,  // Price <-> Fast
   price_slow=1,  // Price <-> Slow
   fast_slow=2,   // Fast <-> Slow
  };
//--- plot MA_Fast_
#property indicator_label1  "MA_Fast_"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGoldenrod
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot MA_Slow_
#property indicator_label2  "MA_Slow_"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGold
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot Trend
#property indicator_label3  "Trend"
#property indicator_type3   DRAW_COLOR_HISTOGRAM2
#property indicator_color3  clrBlue,clrRed
#property indicator_style3  STYLE_DOT
#property indicator_width3  1
//--- input parameters
input group             "Main settings"
input ENUM_MA_PRICE        InpMAPrice                    = fast_slow;            // Histogram:
input ENUM_APPLIED_PRICE   InpPrice                      = PRICE_CLOSE;          // Price:
input group             "MA Fast"
input int                  Inp_MA_Fast_ma_period         = 12;                   // MA: averaging period
input int                  Inp_MA_Fast_ma_shift          = 0;                    // MA: horizontal shift
input ENUM_MA_METHOD       Inp_MA_Fast_ma_method         = MODE_SMA;             // MA: smoothing type
input ENUM_APPLIED_PRICE   Inp_MA_Fast_applied_price     = PRICE_CLOSE;          // MA: type of price
input group             "MA Slow"
input int                  Inp_MA_Slow_ma_period         = 48;                   // MA: averaging period
input int                  Inp_MA_Slow_ma_shift          = 3;                    // MA: horizontal shift
input ENUM_MA_METHOD       Inp_MA_Slow_ma_method         = MODE_SMA;             // MA: smoothing type
input ENUM_APPLIED_PRICE   Inp_MA_Slow_applied_price     = PRICE_CLOSE;          // MA: type of price
input group             "Labels"
input bool                 InpUse                        = true;                 // Use Info
input int                  InpX                          = 50;                   // X coordinate
input int                  InpY                          = 50;                   // Y coordinate
input int                  InpYStep                      = 12;                   // Y step
input ENUM_BASE_CORNER     InpCorner                     = CORNER_RIGHT_LOWER;   // Chart corner for anchoring
input string               InpFont                       = "Consolas";           // Font Name
input int                  InpFontSize                   = 10;                   // Font size
input color                InpColor                      = clrRed;               // Color
input double               InpAngle                      = 0.0;                  // Text slope
input ENUM_ANCHOR_POINT    InpAnchor                     = ANCHOR_RIGHT_LOWER;   // Anchor type
//--- indicator buffers
double   MA_Fast_Buffer[];
double   MA_Slow_Buffer[];
double   TrendBuffer1[];
double   TrendBuffer2[];
double   TrendColors[];
//---
int      handle_iMA_Fast;              // variable for storing the handle of the iMA indicator
int      handle_iMA_Slow;              // variable for storing the handle of the iMA indicator
//---
int      m_min_bars        = 0;
string   m_prefix          = "MA_or_Price_";
color    m_color_0         = clrLightGray;
color    m_color_1         = clrLightGray;
int      bars_calculated   = 0;        // we will keep the number of values in the Moving Average indicators
bool     m_init_error      = false;    // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MA_Fast_Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,MA_Slow_Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,TrendBuffer1,INDICATOR_DATA);
   SetIndexBuffer(3,TrendBuffer2,INDICATOR_DATA);
   SetIndexBuffer(4,TrendColors,INDICATOR_COLOR_INDEX);
//--- set shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Inp_MA_Fast_ma_shift);
   PlotIndexSetInteger(1,PLOT_SHIFT,Inp_MA_Slow_ma_shift);
//--- MA Fast
   string mode_fast;
   switch(Inp_MA_Fast_ma_method)
     {
      case MODE_EMA :
         mode_fast="EMA";
         break;
      case MODE_LWMA :
         mode_fast="LWMA";
         break;
      case MODE_SMA :
         mode_fast="SMA";
         break;
      case MODE_SMMA :
         mode_fast="SMMA";
         break;
      default :
         mode_fast="unknown mode";
     }
   string price_fast=StringSubstr(EnumToString(Inp_MA_Fast_applied_price),6,-1);
//--- name for indicator subwindow label
   string name_fast=StringFormat("MA Fast(%d,%s,%s,%d)",Inp_MA_Fast_ma_period,mode_fast,price_fast,Inp_MA_Fast_ma_shift);
   PlotIndexSetString(0,PLOT_LABEL,name_fast);
//--- MA Slow
   string mode_slow;
   switch(Inp_MA_Slow_ma_method)
     {
      case MODE_EMA :
         mode_slow="EMA";
         break;
      case MODE_LWMA :
         mode_slow="LWMA";
         break;
      case MODE_SMA :
         mode_slow="SMA";
         break;
      case MODE_SMMA :
         mode_slow="SMMA";
         break;
      default :
         mode_slow="unknown mode";
     }
   string price_slow=StringSubstr(EnumToString(Inp_MA_Slow_applied_price),6,-1);
//--- name for indicator subwindow label
   string name_slow=StringFormat("MA Slow(%d,%s,%s,%d)",Inp_MA_Slow_ma_period,mode_slow,price_slow,Inp_MA_Slow_ma_shift);
   PlotIndexSetString(1,PLOT_LABEL,name_slow);
//--- create handle of the indicator iMA
   handle_iMA_Fast=iMA(Symbol(),Period(),Inp_MA_Fast_ma_period,Inp_MA_Fast_ma_shift,
                       Inp_MA_Fast_ma_method,Inp_MA_Fast_applied_price);
//--- if the handle is not created
   if(handle_iMA_Fast==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA indicator ('Fast') for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//--- create handle of the indicator iMA
   handle_iMA_Slow=iMA(Symbol(),Period(),Inp_MA_Slow_ma_period,Inp_MA_Slow_ma_shift,
                       Inp_MA_Slow_ma_method,Inp_MA_Slow_applied_price);
//--- if the handle is not created
   if(handle_iMA_Slow==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA indicator ('Slow') for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//---
   int min_bars_fast=Inp_MA_Fast_ma_period+Inp_MA_Fast_ma_shift;
   int min_bars_slow=Inp_MA_Slow_ma_period+Inp_MA_Slow_ma_shift;
   m_min_bars=(min_bars_fast<min_bars_slow)?min_bars_slow:min_bars_fast;
   m_color_0=(color)PlotIndexGetInteger(0,PLOT_LINE_COLOR,0);
   m_color_1=(color)PlotIndexGetInteger(1,PLOT_LINE_COLOR,0);
//---
   if(InpUse)
     {
      uint width;    // buffer width in pixels
      uint height;   // buffer height in pixels
      int step_y=(int)(TextGetSize("80",width,height)?height:3);
      LabelCreate(ChartID(),m_prefix+"Fast",0,InpX,InpY+0,InpCorner,"Fast: - - -",InpFont,InpFontSize,InpColor,InpAngle,InpAnchor);
      LabelCreate(ChartID(),m_prefix+"Slow",0,InpX,InpY+step_y,InpCorner,"Slow: - - -",InpFont,InpFontSize,InpColor,InpAngle,InpAnchor);
     }
//---
   return(INIT_SUCCEEDED);
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
   if(m_init_error)
      return(0);
   if(rates_total<m_min_bars)
      return(0);
//--- number of values copied from the iMA indicator
   int values_to_copy;
//--- determine the number of values calculated in the indicators
   int calculated_fast=BarsCalculated(handle_iMA_Fast);
   if(calculated_fast<=0)
     {
      PrintFormat("BarsCalculated(handle_iMA_Fast) returned %d, error code %d",calculated_fast,GetLastError());
      return(0);
     }
   int calculated_slow=BarsCalculated(handle_iMA_Slow);
   if(calculated_slow<=0)
     {
      PrintFormat("BarsCalculated(handle_iMA_Slow) returned %d, error code %d",calculated_slow,GetLastError());
      return(0);
     }
   if(calculated_fast!=calculated_slow)
     {
      PrintFormat("BarsCalculated(handle_iMA_Fast) returned %d, BarsCalculated(handle_iMA_Slow) returned %d",calculated_fast,calculated_slow);
      return(0);
     }
   int calculated=calculated_fast;
//--- if it is the first start of calculation of the indicator or if the number of values in the iMA indicator changed
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the iMABuffer array is greater than the number of values in the iMA indicator for symbol/period, then we don't copy everything
      //--- otherwise, we copy less than the size of indicator buffers
      if(calculated>rates_total)
         values_to_copy=rates_total;
      else
         values_to_copy=calculated;
     }
   else
     {
      //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate()
      //--- for calculation not more than one bar is added
      values_to_copy=(rates_total-prev_calculated)+1;
     }
//--- fill the iMABuffer array with values of the Moving Average indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBuffer(MA_Fast_Buffer,Inp_MA_Fast_ma_shift,handle_iMA_Fast,values_to_copy))
      return(0);
   if(!FillArrayFromBuffer(MA_Slow_Buffer,Inp_MA_Slow_ma_shift,handle_iMA_Slow,values_to_copy))
      return(0);
//--- memorize the number of values in the Moving Average indicator
   bars_calculated=calculated;
//--- main loop
   int limit=rates_total-values_to_copy;
   if(limit<Inp_MA_Fast_ma_shift)
      limit=Inp_MA_Fast_ma_shift;
   if(limit<Inp_MA_Slow_ma_shift)
      limit=Inp_MA_Slow_ma_shift;
   for(int i=limit; i<rates_total; i++)
     {
      double price_1=MA_Fast_Buffer[i-Inp_MA_Fast_ma_shift];
      double price_2=MA_Slow_Buffer[i-Inp_MA_Slow_ma_shift];
      /*
      //+------------------------------------------------------------------+
      //| Enum MA Price                                                    |
      //+------------------------------------------------------------------+
      enum ENUM_MA_PRICE
      {
      price_fast=0,  // Price <-> Fast
      price_slow=1,  // Price <-> Slow
      fast_slow=2,   // Fast <-> Slow
      };
      */
      switch(InpMAPrice)
        {
         case  price_fast:
            price_2=MA_Fast_Buffer[i-Inp_MA_Fast_ma_shift];
            break;
         case  price_slow:
            price_2=MA_Slow_Buffer[i-Inp_MA_Slow_ma_shift];
            break;
         default:
            price_2=MA_Slow_Buffer[i-Inp_MA_Slow_ma_shift];
            break;
        }
      if(InpMAPrice!=fast_slow)
        {
         switch(InpPrice)
           {
            case PRICE_CLOSE:
               price_1=close[i];
               break;
            case PRICE_OPEN:
               price_1=open[i];
               break;
            case PRICE_HIGH:
               price_1=high[i];
               break;
            case PRICE_LOW:
               price_1=low[i];
               break;
            case PRICE_MEDIAN:
               price_1=(high[i] + low[i])/2.0;
               break;
            case PRICE_TYPICAL:
               price_1=(high[i] + low[i] + close[i])/3.0;
               break;
            case PRICE_WEIGHTED:
               price_1=(high[i] + low[i] + close[i] + close[i])/4.0;
               break;
           }
        }
      TrendBuffer1[i]=price_1;
      TrendBuffer2[i]=price_2;
      if(MA_Fast_Buffer[i]>MA_Slow_Buffer[i])
         TrendColors[i]=0.0;
      else
         TrendColors[i]=1.0;
     }
   if(InpUse)
     {
      long chart_id=ChartID();
      LabelTextChange(chart_id,m_prefix+"Fast","Fast: "+DoubleToString(TrendBuffer1[rates_total-1],Digits()+1),m_color_0);
      LabelTextChange(chart_id,m_prefix+"Slow","Slow: "+DoubleToString(TrendBuffer2[rates_total-1],Digits()+1),m_color_1);
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the MA indicator                  |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &values[],   // indicator buffer of Moving Average values
                         int shift,          // shift
                         int ind_handle,     // handle of the iMA indicator
                         int amount          // number of copied values
                        )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,-shift,amount,values)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
     }
//--- everything is fine
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a text label                                              |
//+------------------------------------------------------------------+
bool LabelCreate(const long               chart_ID=0,                // chart's ID
                 const string             name="Label",              // label name
                 const int                sub_window=0,              // subwindow index
                 const int                x=0,                       // X coordinate
                 const int                y=0,                       // Y coordinate
                 const ENUM_BASE_CORNER   corner=CORNER_LEFT_UPPER,  // chart corner for anchoring
                 const string             text="Label",              // text
                 const string             font="Arial",              // font
                 const int                font_size=10,              // font size
                 const color              clr=clrRed,                // color
                 const double             angle=0.0,                 // text slope
                 const ENUM_ANCHOR_POINT  anchor=ANCHOR_CENTER,      // anchor type
                 const bool               back=false,                // in the background
                 const bool               selection=false,           // highlight to move
                 const bool               hidden=true,               // hidden in the object list
                 const long               z_order=0)                 // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create a text label
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Change the label text                                            |
//+------------------------------------------------------------------+
bool LabelTextChange(const long   chart_ID=0,      // chart's ID
                     const string name="Label",    // object name
                     const string text="text",     // text
                     const color  clr=clrRed)      // color
  {
//--- reset the error value
   ResetLastError();
//--- change the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(handle_iMA_Fast!=INVALID_HANDLE)
      IndicatorRelease(handle_iMA_Fast);
   if(handle_iMA_Slow!=INVALID_HANDLE)
      IndicatorRelease(handle_iMA_Slow);
//--- delete the labels
   ObjectsDeleteAll(ChartID(),m_prefix,0,OBJ_LABEL);
   ChartRedraw(ChartID());
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
