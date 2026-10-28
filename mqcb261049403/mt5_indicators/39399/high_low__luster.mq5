//+------------------------------------------------------------------+
//|                                             High Low Сluster.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.005"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
#property tester_everytick_calculate
//--- plot MA
#property indicator_label1  "MA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrYellowGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input group             "MA"
input int                  Inp_MA_ma_period     = 9;              // MA: averaging period
input int                  Inp_MA_ma_shift      = 0;              // MA: horizontal shift
input ENUM_MA_METHOD       Inp_MA_ma_method     = MODE_SMA;       // MA: smoothing type
input ENUM_APPLIED_PRICE   Inp_MA_applied_price = PRICE_CLOSE;    // MA: type of price
//--- indicator buffer and handle
double   iMABuffer[];
int      handle_iMA;                   // variable for storing the handle of the iMA indicator
//---
int      bars_calculated   = 0;        // we will keep the number of values in the Moving Average indicator
bool     m_init_error      = false;    // error on InInit
//--- current rectangle
string   m_name       = "";
datetime m_time_left  = 0;           // first point time, "0" -> D'1970.01.01 00:00'
double   m_price_min  = DBL_MAX;     // first point price
datetime m_time_right = 0;           // second point time, "0" -> D'1970.01.01 00:00'
double   m_price_max  = DBL_MIN;     // second point price
//---
datetime m_prev_bars       = 0;           // "0" -> D'1970.01.01 00:00';
string   m_prefix          = "HLC_";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,iMABuffer,INDICATOR_DATA);
//--- create handle of the indicator iMA
   handle_iMA=iMA(Symbol(),Period(),Inp_MA_ma_period,Inp_MA_ma_shift,
                  Inp_MA_ma_method,Inp_MA_applied_price);
//--- if the handle is not created
   if(handle_iMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//--- MA
   string mode;
   switch(Inp_MA_ma_method)
     {
      case MODE_EMA :
         mode="EMA";
         break;
      case MODE_LWMA :
         mode="LWMA";
         break;
      case MODE_SMA :
         mode="SMA";
         break;
      case MODE_SMMA :
         mode="SMMA";
         break;
      default :
         mode="unknown mode";
     }
   string price=StringSubstr(EnumToString(Inp_MA_applied_price),6,-1);
//--- name for indicator subwindow label
   string short_name=StringFormat("High LowCluster(%d,%d,%s,%s)",
                                  Inp_MA_ma_period,Inp_MA_ma_shift,mode,price);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
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
   if(rates_total<10)
      return(0);
   if(m_init_error)
      return(0);
//--- number of values copied from the iMA indicator
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated=BarsCalculated(handle_iMA);
   if(calculated<=0)
     {
      PrintFormat("BarsCalculated(handle_iMA) returned %d, error code %d",calculated,GetLastError());
      return(0);
     }
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
   if(!FillArrayFromBuffer(iMABuffer,Inp_MA_ma_shift,handle_iMA,values_to_copy))
      return(0);
//--- memorize the number of values in the Moving Average indicator
   bars_calculated=calculated;
//--- main loop
   int limit=prev_calculated-1;
   if(limit<4)
      limit=4;
   for(int i=limit; i<rates_total; i++)
     {
      //--- we work only at the time of the birth of new bar
      if(time[i]==m_prev_bars)
         continue;
      m_prev_bars=time[i];
      //--- the MA indicator crossed from bottom to top on the previous candle
      if(open[i-1]<iMABuffer[i-1] && close[i-1]>iMABuffer[i-1])
        {
         VariableInitialization();
         if((open[i-2]>iMABuffer[i-2] && close[i-2]<iMABuffer[i-2]) || (open[i-3]>iMABuffer[i-3] && close[i-3]<iMABuffer[i-3]))
           {
            VariableInitialization();
            continue;
           }
         m_time_right=time[i-2];           // second point time, "0" -> D'1970.01.01 00:00'
         for(int j=i-2; j>=1; j--)
           {
            if(high[j]>m_price_max)
               m_price_max=high[j];
            if(low[j]<m_price_min)
               m_price_min=low[j];
            if(open[j-1]>iMABuffer[j-1] && close[j-1]<iMABuffer[j-1])
              {
               m_name=TimeToString(time[j],TIME_DATE|TIME_MINUTES)+"-"+TimeToString(m_time_right,TIME_DATE|TIME_MINUTES);
               m_time_left=time[j];       // first point time, "0" -> D'1970.01.01 00:00'
               if(m_time_right!=m_time_left)
                 {
                  RectangleCreate(ChartID(),m_prefix+m_name,0,m_time_left,m_price_min,m_time_right,m_price_max,clrRed,STYLE_DASH,2);
                  VariableInitialization();
                  break;
                 }
               break;
              }
           }
         VariableInitialization();
         continue;
        }
      else
        {
         if(open[i-1]>iMABuffer[i-1] && close[i-1]<iMABuffer[i-1]) // the MA indicator crossed down on the previous candle
           {
            VariableInitialization();
            if((open[i-2]<iMABuffer[i-2] && close[i-2]>iMABuffer[i-2]) || (open[i-3]<iMABuffer[i-3] && close[i-3]>iMABuffer[i-3]))
              {
               VariableInitialization();
               continue;
              }
            m_time_right=time[i-2];           // second point time, "0" -> D'1970.01.01 00:00'
            for(int j=i-2; j>=1; j--)
              {
               if(high[j]>m_price_max)
                  m_price_max=high[j];
               if(low[j]<m_price_min)
                  m_price_min=low[j];
               if(open[j-1]<iMABuffer[j-1] && close[j-1]>iMABuffer[j-1])
                 {
                  m_name=TimeToString(time[j],TIME_DATE|TIME_MINUTES)+"-"+TimeToString(m_time_right,TIME_DATE|TIME_MINUTES);
                  m_time_left=time[j];       // first point time, "0" -> D'1970.01.01 00:00'
                  if(m_time_right!=m_time_left)
                    {
                     RectangleCreate(ChartID(),m_prefix+m_name,0,m_time_left,m_price_min,m_time_right,m_price_max,clrBlue,STYLE_DASH,2);
                     VariableInitialization();
                     break;
                    }
                  break;
                 }
              }
            VariableInitialization();
            continue;
           }
        }
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
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectsDeleteAll(ChartID(),m_prefix,0,OBJ_RECTANGLE);
   if(handle_iMA!=INVALID_HANDLE)
      IndicatorRelease(handle_iMA);
  }
//+------------------------------------------------------------------+
//| Create rectangle by the given coordinates                        |
//+------------------------------------------------------------------+
bool RectangleCreate(const long            chart_ID=0,        // chart's ID
                     const string          name="Rectangle",  // rectangle name
                     const int             sub_window=0,      // subwindow index
                     datetime              time1=0,           // first point time
                     double                price1=0,          // first point price
                     datetime              time2=0,           // second point time
                     double                price2=0,          // second point price
                     const color           clr=clrRed,        // rectangle color
                     const ENUM_LINE_STYLE style=STYLE_SOLID, // style of rectangle lines
                     const int             width=1,           // width of rectangle lines
                     const bool            fill=false,        // filling rectangle with color
                     const bool            back=false,        // in the background
                     const bool            selection=false,   // highlight to move
                     const bool            hidden=true,       // hidden in the object list
                     const long            z_order=0)         // priority for mouse click
  {
//--- set anchor points' coordinates if they are not set
   ChangeRectangleEmptyPoints(time1,price1,time2,price2);
//--- reset the error value
   ResetLastError();
//--- create a rectangle by the given coordinates
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a rectangle! Error code = ",GetLastError());
      return(false);
     }
//--- set rectangle color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the style of rectangle lines
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set width of the rectangle lines
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- enable (true) or disable (false) the mode of filling the rectangle
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of highlighting the rectangle for moving
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Move the rectangle anchor point                                  |
//+------------------------------------------------------------------+
bool RectanglePointChange(const long   chart_ID=0,       // chart's ID
                          const string name="Rectangle", // rectangle name
                          const int    point_index=0,    // anchor point index
                          datetime     time=0,           // anchor point time coordinate
                          double       price=0)          // anchor point price coordinate
  {
//--- if point position is not set, move it to the current bar having Bid price
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- move the anchor point
   if(!ObjectMove(chart_ID,name,point_index,time,price))
     {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Delete the rectangle                                             |
//+------------------------------------------------------------------+
bool RectangleDelete(const long   chart_ID=0,       // chart's ID
                     const string name="Rectangle") // rectangle name
  {
//--- reset the error value
   ResetLastError();
//--- delete rectangle
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete rectangle! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the values of rectangle's anchor points and set default    |
//| values for empty ones                                            |
//+------------------------------------------------------------------+
void ChangeRectangleEmptyPoints(datetime &time1,double &price1,
                                datetime &time2,double &price2)
  {
//--- if the first point's time is not set, it will be on the current bar
   if(!time1)
      time1=TimeCurrent();
//--- if the first point's price is not set, it will have Bid value
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the second point's time is not set, it is located 9 bars left from the second one
   if(!time2)
     {
      //--- array for receiving the open time of the last 10 bars
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- set the second point 9 bars left from the first one
      time2=temp[0];
     }
//--- if the second point's price is not set, move it 300 points lower than the first one
   if(!price2)
      price2=price1-300*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
  }
//+------------------------------------------------------------------+
//| Variable Initialization                                          |
//+------------------------------------------------------------------+
void VariableInitialization(void)
  {
   m_name       = "";
   m_time_left  = 0;           // first point time, "0" -> D'1970.01.01 00:00'
   m_price_min  = DBL_MAX;     // first point price
   m_time_right = 0;           // second point time, "0" -> D'1970.01.01 00:00'
   m_price_max  = DBL_MIN;     // second point price
  }
//+------------------------------------------------------------------+
