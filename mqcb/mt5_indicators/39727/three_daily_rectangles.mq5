//+------------------------------------------------------------------+
//|                                       Three daily rectangles.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
//--- input parameters
input group                "Rectangle 0, 1, 2,"
input color                   Inp_0_Color       = clrMediumPurple;   // Rectangle 0: Color
input color                   Inp_1_Color       = clrLawnGreen;      // Rectangle 1: Color
input color                   Inp_2_Color       = clrCoral;          // Rectangle 2: Color
input group                "Rectangles"
input ENUM_LINE_STYLE         InpStyle          = STYLE_DASH;        // Rectangles: Style
input int                     InpWidth          = 2;                 // Rectangles: Width
//---
datetime m_prev_bars    = 0;        // "0" -> D'1970.01.01 00:00';
string   m_prefix       =  "TDR ";  // prefix
bool     m_init_error   = false;    // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(Period()>=PERIOD_D1)
     {
      string err_text="Chart period cannot be >= 'D1'!";
      if(MQLInfoInteger(MQL_TESTER)) // when testing, we will only output to the log about incorrect input parameters
         Print(__FILE__," ",__FUNCTION__,", ERROR: ",err_text);
      else // if the Expert Advisor is run on the chart, tell the user about the error
         Alert(__FILE__," ",__FUNCTION__,", ERROR: ",err_text);
      //---
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
   MqlRates rates_d1[];
   ArraySetAsSeries(rates_d1,true);
   int start_pos=0,count=3;
   CopyRates(Symbol(),PERIOD_D1,start_pos,count,rates_d1);
   long chart_id=ChartID();
   RectangleCreate(chart_id,m_prefix+"#0","#0",0,0,0.0,0,0.0,Inp_0_Color,InpStyle,InpWidth);
   RectangleCreate(chart_id,m_prefix+"#1","#1",0,0,0.0,0,0.0,Inp_1_Color,InpStyle,InpWidth);
   RectangleCreate(chart_id,m_prefix+"#2","#2",0,0,0.0,0,0.0,Inp_2_Color,InpStyle,InpWidth);
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
//---
   MqlRates rates_d1[];
   ArraySetAsSeries(rates_d1,true);
   int start_pos=0,count=3;
   if(CopyRates(Symbol(),PERIOD_D1,start_pos,count,rates_d1)!=count)
     {
      return(0);
     }
   datetime time_0=rates_d1[0].time;
   long chart_id=ChartID();
   if(time_0==m_prev_bars)
     {
      //--- #0
      RectanglePointChange(chart_id,m_prefix+"#0",0,rates_d1[0].time,rates_d1[0].high);
      RectanglePointChange(chart_id,m_prefix+"#0",1,time[rates_total-1],rates_d1[0].low);
      return(rates_total);
     }
   m_prev_bars=time_0;
//--- #2
   RectanglePointChange(chart_id,m_prefix+"#2",0,rates_d1[2].time,rates_d1[2].high);
   RectanglePointChange(chart_id,m_prefix+"#2",1,rates_d1[1].time-60,rates_d1[2].low);
//--- #1
   RectanglePointChange(chart_id,m_prefix+"#1",0,rates_d1[1].time,rates_d1[1].high);
   RectanglePointChange(chart_id,m_prefix+"#1",1,rates_d1[0].time-60,rates_d1[1].low);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,m_prefix,0,OBJ_RECTANGLE);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Create rectangle by the given coordinates                        |
//+------------------------------------------------------------------+
bool RectangleCreate(const long              chart_ID=0,          // chart's ID
                     const string            name="Rectangle",    // rectangle name
                     const string            text="Rectangle",    // rectangle text
                     const int               sub_window=0,        // subwindow index
                     datetime                time1=0,             // first point time
                     double                  price1=0,            // first point price
                     datetime                time2=0,             // second point time
                     double                  price2=0,            // second point price
                     const color             clr=clrRed,          // rectangle color
                     const ENUM_LINE_STYLE   style=STYLE_SOLID,   // style of rectangle lines
                     const int               width=1,             // width of rectangle lines
                     const bool              fill=false,          // filling rectangle with color
                     const bool              back=false,          // in the background
                     const bool              selection=false,     // highlight to move
                     const bool              hidden=true,         // hidden in the object list
                     const long              z_order=0)           // priority for mouse click

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
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
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
  }//+------------------------------------------------------------------+
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
