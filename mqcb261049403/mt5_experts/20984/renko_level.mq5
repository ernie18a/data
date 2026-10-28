//+------------------------------------------------------------------+
//|                                                  Renko Level.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 1
//--- plot Histogram 
#property indicator_label1  "Histogram" 
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
#property indicator_color1  clrBlue,clrRed
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  3
//--- input parameters
input ushort      InpSize=30;
//--- indicator buffers
double    ExtRenkoBufferUP[];
double    ExtRenkoBufferDOWN[];
double    ExtRenkoColorBuffer[];
//---
double    ExtSize=0.0;
string    m_name_ceil="ceil";
string    m_name_round="round";
string    m_name_floor="floor";
color             InpColorCeil            = clrBlue;        // Line color 
ENUM_LINE_STYLE   InpStyleCeil            = STYLE_DASH;     // Line style 
int               InpWidthCeil            = 1;              // Line width 
color             InpColorRound           = clrGray;        // Line color 
ENUM_LINE_STYLE   InpStyleRound           = STYLE_DASH;     // Line style 
int               InpWidthRound           = 1;              // Line width 
color             InpColorFloor           = clrRed;         // Line color 
ENUM_LINE_STYLE   InpStyleFloor           = STYLE_DASH;     // Line style 
int               InpWidthFloor           = 1;              // Line width 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtRenkoBufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,ExtRenkoBufferDOWN,INDICATOR_DATA);
   SetIndexBuffer(2,ExtRenkoColorBuffer,INDICATOR_COLOR_INDEX);
//---
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,0);
//--- name for DataWindow and indicator subwindow label
   string short_name="Renko("+string(InpSize)+")";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   PlotIndexSetString(0,PLOT_LABEL,short_name);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(Digits()==3 || Digits()==5)
      digits_adjust=10;
   ExtSize=Point()*digits_adjust*InpSize;
//---
   if(ObjectFind(0,m_name_ceil)<0)
      HLineCreate(0,m_name_ceil,0,0.0,InpColorCeil,InpStyleCeil,InpWidthCeil);
   if(ObjectFind(0,m_name_round)<0)
      HLineCreate(0,m_name_round,0,0.0,InpColorRound,InpStyleRound,InpWidthRound);
   if(ObjectFind(0,m_name_floor)<0)
      HLineCreate(0,m_name_floor,0,0.0,InpColorFloor,InpStyleFloor,InpWidthFloor);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(reason==1) // REASON_REMOVE
     {
      HLineDelete(0,m_name_ceil);
      HLineDelete(0,m_name_round);
      HLineDelete(0,m_name_floor);
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
   static double price_UP=0;
   static double price_DOWN=0;
   static datetime prev_time=0;

   int limit=prev_calculated-1;

   if(prev_calculated==0)
     {
      Print("prev_calculated==0");
      price_UP=0;
      price_DOWN=0;
      prev_time=0;
      limit=1;
      double price_ceil=0.0,price_round=0.0,price_floor=0.0;

      Math(close[0],(double)ExtSize/Point(),price_ceil,price_round,price_floor);
      price_UP=price_round;
      price_DOWN=price_floor;

      /*Comment(DoubleToString(price_ceil,Digits()),"\n",
              DoubleToString(price_round,Digits()),"\n",
              DoubleToString(price_floor,Digits()),"\n");*/

      ArrayInitialize(ExtRenkoBufferUP,0.0);
      ArrayInitialize(ExtRenkoBufferDOWN,0.0);

     }

   if(time[rates_total-1]==prev_time)
     {
      return(rates_total);
     }

   for(int i=limit;i<rates_total;i++)
     {
      double price_ceil=0.0,price_round=0.0,price_floor=0.0;
      if(close[i]>=price_DOWN && close[i]<=price_UP)
        {
         Math(close[i],(double)ExtSize/Point(),price_ceil,price_round,price_floor);

         ExtRenkoBufferUP[i]=price_UP;
         ExtRenkoBufferDOWN[i]=price_DOWN;
         ExtRenkoColorBuffer[i]=ExtRenkoColorBuffer[i-1];

         HLineMove(0,m_name_ceil,price_ceil);
         HLineMove(0,m_name_round,price_round);
         HLineMove(0,m_name_floor,price_floor);
        }
      else if(close[i]<price_DOWN)
        {
         Math(close[i],(double)ExtSize/Point(),price_ceil,price_round,price_floor);
         if(CompareDoubles(price_round,price_DOWN))
           {
            ExtRenkoBufferUP[i]=price_UP;
            ExtRenkoBufferDOWN[i]=price_DOWN;
            ExtRenkoColorBuffer[i]=ExtRenkoColorBuffer[i-1];
           }
         else
           {
            price_UP=price_ceil;
            price_DOWN=price_round;
            ExtRenkoBufferUP[i]=price_UP;
            ExtRenkoBufferDOWN[i]=price_DOWN;
            ExtRenkoColorBuffer[i]=1;
           }
         HLineMove(0,m_name_ceil,price_ceil);
         HLineMove(0,m_name_round,price_round);
         HLineMove(0,m_name_floor,price_floor);
        }
      else if(close[i]>price_UP)
        {
         Math(close[i],(double)ExtSize/Point(),price_ceil,price_round,price_floor);
         if(CompareDoubles(price_round,price_UP))
           {
            ExtRenkoBufferUP[i]=price_UP;
            ExtRenkoBufferDOWN[i]=price_DOWN;
            ExtRenkoColorBuffer[i]=ExtRenkoColorBuffer[i-1];
           }
         else
           {
            price_DOWN=price_floor;
            price_UP=price_round;
            ExtRenkoBufferUP[i]=price_UP;
            ExtRenkoBufferDOWN[i]=price_DOWN;
            ExtRenkoColorBuffer[i]=0;
           }
         HLineMove(0,m_name_ceil,price_ceil);
         HLineMove(0,m_name_round,price_round);
         HLineMove(0,m_name_floor,price_floor);
        }
      else
        {
         int f=0;
        }
     }

   prev_time=time[rates_total-1];
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Input parameter: price                                           |
//|  price (for example 1.08003)                                     |
//|  step (for example 200, which means 20 points on a 5-digit)      |
//| output parameters:                                               |
//|  price_ceil - integer numeric value closest from above           |
//|  price_round - a value rounded off to the nearest integer        |
//|  price_floor - integer numeric value closest from below          |
//+------------------------------------------------------------------+
void Math(const double price,const double step,double &price_ceil,double &price_round,double &price_floor)
  {
   double point=Point();

   double step1=MathRound(price*1/point/step);          // returns a value rounded off to the nearest integer of the specified numeric value
   price_round=step*step1*point;

   double step1_ceil=MathCeil((price_round+step/2.0*point)*1/point/step);      // returns integer numeric value closest from above
   double step1_floor=MathFloor((price_round-step/2.0*point)*1/point/step);    // returns integer numeric value closest from below

   price_ceil=step*step1_ceil*point;
   price_floor=step*step1_floor*point;
//---
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CompareDoubles(double number1,double number2)
  {
   if(NormalizeDouble(number1-number2,Digits()-1)==0)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+ 
//| Create the horizontal line                                       | 
//+------------------------------------------------------------------+ 
bool HLineCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="HLine",      // line name 
                 const int             sub_window=0,      // subwindow index 
                 double                price=0,           // line price 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=true,    // highlight to move 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  {
//--- if the price is not set, set it at the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- create a horizontal line 
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
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
//| Move horizontal line                                             | 
//+------------------------------------------------------------------+ 
bool HLineMove(const long   chart_ID=0,   // chart's ID 
               const string name="HLine", // line name 
               double       price=0)      // line price 
  {
//--- if the line price is not set, move it to the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- move a horizontal line 
   if(!ObjectMove(chart_ID,name,0,0,price))
     {
      Print(__FUNCTION__,
            ": failed to move the horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Delete a horizontal line                                         | 
//+------------------------------------------------------------------+ 
bool HLineDelete(const long   chart_ID=0,   // chart's ID 
                 const string name="HLine") // line name 
  {
//--- reset the error value 
   ResetLastError();
//--- delete a horizontal line 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
