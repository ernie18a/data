//+------------------------------------------------------------------+
//|                                 SAR Color Filling Right zone.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   2
//--- plot SAR
#property indicator_label1  "SAR"
#property indicator_type1   DRAW_COLOR_ARROW
#property indicator_color1  clrDodgerBlue,clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot SAR Filling
#property indicator_label2  "SAR Filling"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  C'149,202,255',C'255,166,132'
#property indicator_width2  1
//--- input parameters
input double   Inp_SAR_step      = 0.02;  // SAR: price increment step - acceleration factor
input double   Inp_SAR_maximum   = 0.2;   // SAR: maximum value of step
//--- indicator buffers
double   SARBuffer[];
double   SARColors[];
double   SARFillingBuffer1[];
double   SARFillingBuffer2[];
//---
int      handle_iSAR;            // variable for storing the handle of the iSAR indicator
int      bars_calculated= 0;     // we will keep the number of values in the Parabolic SAR indicator
bool     m_init_error   = false; // error on InInit
//---
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   ObjectDelete(ChartID(),"SAR Rectangle");
//--- indicator buffers mapping
   SetIndexBuffer(0,SARBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,SARColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,SARFillingBuffer1,INDICATOR_DATA);
   SetIndexBuffer(3,SARFillingBuffer2,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
//--- set indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- set label name
   string short_name=StringFormat("SAR(%.2f,%.2f)",Inp_SAR_step,Inp_SAR_maximum);
   PlotIndexSetString(0,PLOT_LABEL,short_name);
//--- create handle of the indicator iSAR
   handle_iSAR=iSAR(Symbol(),Period(),Inp_SAR_step,Inp_SAR_maximum);
//--- if the handle is not created
   if(handle_iSAR==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iSAR indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
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
//---
   if(m_init_error)
      return(0);
//--- number of values copied from the iSAR indicator
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated=BarsCalculated(handle_iSAR);
   if(calculated<=0)
     {
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError());
      return(0);
     }
//--- if it is the first start of calculation of the indicator or if the number of values in the iSAR indicator changed
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the iSARBuffer array is greater than the number of values in the iSAR indicator for symbol/period, then we don't copy everything
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
//--- fill the arrays with values of the iSAR indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBuffer(SARBuffer,handle_iSAR,values_to_copy))
      return(0);
//--- memorize the number of values in the Parabolic SAR indicator
   bars_calculated=calculated;
//--- main loop
   int limit=prev_calculated-1;
   if(prev_calculated==0)
      limit=0;
//---
   double price1=0.0;   // first point price (up)
   double price2=0.0;   // second point price  (down)
   color clr=clrRed;    // rectangle color
//---
   for(int i=limit; i<rates_total; i++)
     {
      if(SARBuffer[i]<=low[i])
        {
         SARColors[i]=0.0;
         SARFillingBuffer1[i]=low[i];
         SARFillingBuffer2[i]=SARBuffer[i];
         price1=low[i];
         price2=SARBuffer[i];
         clr=C'149,202,255';
        }
      if(SARBuffer[i]>=high[i])
        {
         SARColors[i]=1.0;
         SARFillingBuffer1[i]=high[i];
         SARFillingBuffer2[i]=SARBuffer[i];
         price1=SARBuffer[i];
         price2=high[i];
         clr=C'255,166,132';
        }
     }
//--- rectangle
   long chart_id=ChartID();
   if(ObjectFind(chart_id,"SAR Rectangle")<0)
     {
      RectangleCreate(chart_id,"SAR Rectangle",0,time[rates_total-1],price1,D'2050.01.01 00:00',price2,clr);
     }
   else
     {
      RectanglePointChange(chart_id,"SAR Rectangle",0,time[rates_total-1],price1,clr);
      RectanglePointChange(chart_id,"SAR Rectangle",1,D'2050.01.01 00:00',price2,clr);
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the iSAR indicator                |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &sar_buffer[],  // indicator buffer of Parabolic SAR values
                         int ind_handle,        // handle of the iSAR indicator
                         int amount             // number of copied values
                        )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the iSARBuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,0,amount,sar_buffer)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iSAR indicator, error code %d",GetLastError());
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
   ObjectDelete(ChartID(),"SAR Rectangle");
   if(handle_iSAR!=INVALID_HANDLE)
      IndicatorRelease(handle_iSAR);
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
                     const bool            fill=true,         // filling rectangle with color
                     const bool            back=false,        // in the background
                     const bool            selection=true,    // highlight to move
                     const bool            hidden=true,       // hidden in the object list
                     const long            z_order=0)         // priority for mouse click
  {
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
//| Move the rectangle anchor point                                  |
//+------------------------------------------------------------------+
bool RectanglePointChange(const long   chart_ID=0,       // chart's ID
                          const string name="Rectangle", // rectangle name
                          const int    point_index=0,    // anchor point index
                          datetime     time=0,           // anchor point time coordinate
                          double       price=0,          // anchor point price coordinate
                          color        clr=clrRed)       // rectangle color
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
//--- set rectangle color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the style of rectangle lines
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
