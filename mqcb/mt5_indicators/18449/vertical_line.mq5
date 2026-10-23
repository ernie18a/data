//+------------------------------------------------------------------+
//|                                                Vertical line.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0
//--- input parameters
sinput string           _0_      = "time setting";          // *-*-*-*
input datetime          InpTime  = D'2017.05.22 18:40:00';  // Use only Hours and minutes
sinput string           _1_      = "vertical line setting"; // *-*-*-*
input string            InpName  = "Vertical line";         // Line name 
input color             InpColor = clrRed;                  // Line color 
input ENUM_LINE_STYLE   InpStyle = STYLE_DASH;              // Line style 
input int               InpWidth = 3;                       // Line width 
//--- static variable for storing the vertical line drawing time
static datetime prev_date=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!EventSetTimer(5))
     {
      Print("Error create a Timer!");
      return(INIT_FAILED);
     }
//---
   if(ObjectFind(0,InpName)<0)
      VLineCreate(0,InpName,0,0.0,InpColor,InpStyle,InpWidth);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   //Print(__FUNCTION__,", ",reason);
   if(reason==1) // REASON_REMOVE
     {
      VLineDelete(0,InpName);
     }
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
   MqlDateTime str_to_draw;
   TimeToStruct(TimeCurrent(),str_to_draw);

   if(prev_date==0) // first start
     {
      MqlDateTime str_input;
      TimeToStruct(InpTime,str_input);
      str_to_draw.hour=str_input.hour;
      str_to_draw.min=str_input.min;
      str_to_draw.sec=0;

      prev_date=StructToTime(str_to_draw);
      VLineMove(0,InpName,prev_date);

      return(rates_total);
     }

   MqlDateTime str_prev_date;
   TimeToStruct(prev_date,str_prev_date);

   if(str_to_draw.day==str_prev_date.day) // today the vertical line has already been drawn
      return(rates_total);
   else
     {
      MqlDateTime str_input;
      TimeToStruct(InpTime,str_input);
      str_to_draw.hour=str_input.hour;
      str_to_draw.min=str_input.min;
      str_to_draw.sec=0;

      prev_date=StructToTime(str_to_draw);
      VLineMove(0,InpName,prev_date);
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- protection against unauthorized deletion
   if(ObjectFind(0,InpName)<0)
     {
      prev_date=0;
      VLineCreate(0,InpName,0,0.0,InpColor,InpStyle,InpWidth);
     }
  }
//+------------------------------------------------------------------+ 
//| Create the vertical line                                         | 
//+------------------------------------------------------------------+ 
bool VLineCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="VLine",      // line name 
                 const int             sub_window=0,      // subwindow index 
                 datetime              time=0,            // line time 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1/*,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=true,    // highlight to move 
                 const bool            ray=true,          // line's continuation down 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0*/) // priority for mouse click 
  {
//--- if the line time is not set, draw it via the last bar 
   if(!time)
      time=TimeCurrent();
//--- reset the error value 
   ResetLastError();
//--- create a vertical line 
   if(!ObjectCreate(chart_ID,name,OBJ_VLINE,sub_window,time,0))
     {
      Print(__FUNCTION__,
            ": failed to create a vertical line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move the vertical line                                           | 
//+------------------------------------------------------------------+ 
bool VLineMove(const long   chart_ID=0,   // chart's ID 
               const string name="VLine", // line name 
               datetime     time=0)       // line time 
  {
//--- if line time is not set, move the line to the last bar 
   if(!time)
      time=TimeCurrent();
//--- reset the error value 
   ResetLastError();
//--- move the vertical line 
   if(!ObjectMove(chart_ID,name,0,time,0))
     {
      Print(__FUNCTION__,
            ": failed to move the vertical line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Delete the vertical line                                         | 
//+------------------------------------------------------------------+ 
bool VLineDelete(const long   chart_ID=0,   // chart's ID 
                 const string name="VLine") // line name 
  {
//--- reset the error value 
   ResetLastError();
//--- delete the vertical line 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete the vertical line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
