//+------------------------------------------------------------------+
//|                                                       Rabbit.mq5 |
//|     Modification "Martingeil" dated March 14, 2011 fx.09@mail.ru |       
//|                                http://codebase.mql4.com/ru/6231/ |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2005, JonKatana."
//---- link to the website of the author
#property link      "http://codebase.mql4.com/ru/6231/"
//---- indicator version
#property version   "28.01"
//---- drawing the indicator in the main window
#property indicator_chart_window 
#property indicator_buffers  1
#property indicator_plots    1
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define DAY_SECONDS 86400 // The constant for the number of seconds in a day
#define RESET       0     // The constant for getting the command for the indicator recalculation back to the terminal
//---- number of indicator buffers
//+-----------------------------------+
//|  Declaration of enumeration       |
//+-----------------------------------+
enum Number
  {
   Number_0,
   Number_1,
   Number_2,
   Number_3
  };
//+-----------------------------------+
//|  Declaration of enumeration       |
//+-----------------------------------+  
enum Width
  {
   Width_1=1, // 1
   Width_2,   // 2
   Width_3,   // 3
   Width_4,   // 4
   Width_5    // 5
  };
//+-----------------------------------+
//|  Declaration of enumeration       |
//+-----------------------------------+
enum STYLE
  {
   SOLID_,     // Solid line
   DASH_,      // Dashed line
   DOT_,       // Dotted line
   DASHDOT_,   // Dot-dash line
   DASHDOTDOT_ // Dot-dash line with double dots
  };
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int   Yesterday    = 0;     // Days shift 0 - current,1 - previous, 1 - future
input int   Levels       = 7;     // Number of levels
input bool  Comm         = true;  // Display of comments on a chart
input bool  Sublevel     = true;  // Display of sublevels in the middle between basic levels
//----
input color FontColor=Black;            // Price level color
//----
input color LineColor    = DeepSkyBlue; // Basic line color
input STYLE LineStyle    = SOLID_;      // Basic line style
input Width LineWidth    = Width_1;     // Basic line width
//----
input color MLineColor   = Lime;        // Sublevels line color
input STYLE MLineStyle   = DASHDOTDOT_; // Sublevels line style
input Width MLineWidth   = Width_1;     // Sublevels line width
//----
input color VlineColor   = Black;       // Vertical line color
input STYLE VLineStyle   = SOLID_;      // Vertical line style
input Width VLineWidth   = Width_1;     // Vertical line width
//----
input color HL_lineColor = Lime;        // Previous day range line color
input STYLE HL_lineStyle = SOLID_;      // Previous day range line style
input Width HL_lineWidth = Width_5;     // Previous day range line width
//----
input bool  Background=true;            // Draw vertical lines as background
//+----------------------------------------------+

int PeriodSec,PeriodSec2,Levels2,Levels2_;
//+------------------------------------------------------------------+
//|  Trend line creation                                             |
//+------------------------------------------------------------------+
void CreateTline(long     chart_id,    // chart ID
                 string   name,        // object name
                 int      nwin,        // window index
                 datetime time1,       // price level time 1
                 double   price1,      // price level 1
                 datetime time2,       // price level time 2
                 double   price2,      // price level 2
                 color    Color,       // line color
                 int      style,       // line style
                 int      width,       // line width
                 bool     background,  // line background display
                 string   text)        // text
  {
//----
   ObjectCreate(chart_id,name,OBJ_TREND,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,false);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
//----
  }
//+------------------------------------------------------------------+
//|  Trend line reinstallation                                       |
//+------------------------------------------------------------------+
void SetTline(long     chart_id,    // chart ID
              string   name,        // object name
              int      nwin,        // window index
              datetime time1,       // price level time 1
              double   price1,      // price level 1
              datetime time2,       // price level time 2
              double   price2,      // price level 2
              color    Color,       // line color
              int      style,       // line style
              int      width,       // line width
              bool     background,  // line background display
              string   text)        // text
  {
//----
   if(ObjectFind(chart_id,name)==-1)
     {
      CreateTline(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,background,text);
     }
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }
//----
  }
//+------------------------------------------------------------------+
//|  Creating a price label                                          |
//+------------------------------------------------------------------+
void CreateArrowRightPrice(long     chart_id,    // chart ID
                           string   name,        // object name
                           int      nwin,        // window index
                           datetime time,        // vertical level time
                           double   price,       // price level
                           color    Color,       // line color
                           int      width,       // line width
                           bool     background,  // line background display
                           string   text)        // text
  {
//----
   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,time,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,background);
//----
  }
//+------------------------------------------------------------------+
//|  Price label reinstallation                                      |
//+------------------------------------------------------------------+
void SetArrowRightPrice(long     chart_id,    // chart ID
                        string   name,        // object name
                        int      nwin,        // window index
                        datetime time,        // vertical level time
                        double   price,       // price level
                        color    Color,       // line color
                        int      width,       // line width
                        bool     background,  // line background display
                        string   text)        // text
  {
//----
   if(ObjectFind(chart_id,name)==-1)
     {
      CreateArrowRightPrice(chart_id,name,nwin,time,price,Color,width,background,text);
     }
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time,price);
     }
//----
  }
//+------------------------------------------------------------------+
//|  Rectangle creation                                              |
//+------------------------------------------------------------------+
void CreateRectangle(long     chart_id,    // chart ID
                     string   name,        // object name
                     int      nwin,        // window index
                     datetime time1,       // vertical level 1 time
                     double   price1,      // price level 1
                     datetime time2,       // vertical level 2 time
                     double   price2,      // price level 2
                     color    Color,       // line color
                     int      style,       // line style
                     int      width,       // line width
                     bool     background,  // line background display
                     string   text)        // text
  {
//----
   ObjectCreate(chart_id,name,OBJ_RECTANGLE,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,background);
//----
  }
//+------------------------------------------------------------------+
//|  Rectangle reinstallation                                        |
//+------------------------------------------------------------------+
void SetRectangle(long     chart_id,   // chart ID
                  string   name,       // object name
                  int      nwin,       // window index
                  datetime time1,      // vertical level 1 time
                  double   price1,     // price level 1
                  datetime time2,      // vertical level 2 time
                  double   price2,     // price level 2
                  color    Color,      // line color
                  int      style,      // line style
                  int      width,      // line width
                  bool     background, // line background display
                  string   text)       // text
  {
//----
   if(ObjectFind(chart_id,name)==-1)
     {
      CreateRectangle(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,background,text);
     }
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
     }
//----
  }
//+------------------------------------------------------------------+
//|  Vertical line creation                                          |
//+------------------------------------------------------------------+
void CreateVline(long     chart_id,    // chart ID
                 string   name,        // object name
                 int      nwin,        // window index
                 datetime time,        // vertical level time
                 color    Color,       // line color
                 int      style,       // line style
                 int      width,       // line width
                 bool     background,  // line background display
                 string   text)        // text
  {
//----
   ObjectCreate(chart_id,name,OBJ_VLINE,nwin,time,999999999);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,background);
//----
  }
//+------------------------------------------------------------------+
//|  Vertical line reinstallation                                    |
//+------------------------------------------------------------------+
void SetVline(long     chart_id,    // chart ID
              string   name,        // object name
              int      nwin,        // window index
              datetime time,        // vertical level time
              color    Color,       // line color
              int      style,       // line style
              int      width,       // line width
              bool     background,  // line background display
              string   text)        // text
  {
//----
   if(ObjectFind(chart_id,name)==-1)
     {
      CreateVline(chart_id,name,nwin,time,Color,style,width,background,text);
     }
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time,999999999);
     }
//----
  }
//+------------------------------------------------------------------+
//|  Creating horizontal price level                                 |
//+------------------------------------------------------------------+
void CreateHline(long   chart_id,    // chart ID
                 string name,        // object name
                 int    nwin,        // window index
                 double price,       // price level
                 color  Color,       // line color
                 int    style,       // line style
                 int    width,       // line width
                 bool   background,  // line background display
                 string text)        // text
  {
//----
   ObjectCreate(chart_id,name,OBJ_HLINE,nwin,0,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,background);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
//----
  }
//+------------------------------------------------------------------+
//|  Reinstallation of the horizontal price level                    |
//+------------------------------------------------------------------+
void SetHline(long   chart_id,    // chart ID
              string name,        // object name
              int    nwin,        // window index
              double price,       // price level
              color  Color,       // line color
              int    style,       // line style
              int    width,       // line width
              bool   background,  // line background display
              string text)        // text
  {
//----
   if(ObjectFind(chart_id,name)==-1)
     {
      CreateHline(chart_id,name,nwin,price,Color,style,width,background,text);
     }
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,0,price);
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//----
   PeriodSec=PeriodSeconds();
   PeriodSec2=PeriodSec/2;
   Levels2=Levels*2;
   Levels2_=Levels2-1;
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   for(int z=0; z<Levels*2; z++)
     {
      ObjectDelete(0,"HiLo");
      ObjectDelete(0,"VL");
      ObjectDelete(0,"VL2");
      ObjectDelete(0,"R"+string(z));
      ObjectDelete(0,"Rp"+string(z));
      ObjectDelete(0,"M Line"+string(z));
      ObjectDelete(0,"Rm"+string(z));
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- 
   if(_Period>PERIOD_H12) return(0);

//---- declarations of static variables       
   datetime iTime[1];
   datetime time0_,time1_,time2_,ny_time;
   double H,L,nH,nL,S,R,M,range,Ser;
   double iHigh[1],iLow[1],value;
   string name;
//----   
   if(CopyTime(NULL,PERIOD_D1,0,1,iTime)<1) return(RESET);
   if(CopyHigh(NULL,PERIOD_D1,Yesterday+1,1,iHigh)<1) return(RESET);
   if(CopyLow(NULL,PERIOD_D1,Yesterday+1,1,iLow)<1) return(RESET);
//----   
   ny_time=iTime[0]-PeriodSec;
   time1_=ny_time+PeriodSec;
   time2_=ny_time+DAY_SECONDS+PeriodSec;
   time0_=ny_time+PeriodSec2;
//----    
   H=iHigh[0];
   L=iLow[0];
   nH=NormalizeDouble(H,_Digits);
   nL=NormalizeDouble(L,_Digits);

   range=H-L;
   S=range*0.236;
   Ser=H-range/2.0-S/2.0;

   SetVline(0,"VL",0,time1_,VlineColor,VLineStyle,VLineWidth,Background,"VL");
   SetVline(0,"VL2",0,time2_,VlineColor,VLineStyle,VLineWidth,Background,"VL2");
   SetRectangle(0,"HiLo",0,time0_,nH,time1_,nL,HL_lineColor,HL_lineStyle,HL_lineWidth,Background,"HiLo");

   value=L+range*(0.618-Levels*0.236);

   for(int z=0; z<Levels2; z++)
     {
      R=NormalizeDouble(value+S*z,_Digits);
      name="R"+string(z);
      SetTline(0,name,0,time1_,R,time2_,R,LineColor,LineStyle,LineWidth,Background,name);

      name="Rp"+string(z);
      SetArrowRightPrice(0,name,0,time2_,R,FontColor,1,Background,name);
     }

   if(Sublevel)
      for(int z=0; z<Levels2_; z++)
        {
         M=NormalizeDouble(value+S*z+S*0.5,_Digits);
         name="M Line"+string(z);
         SetTline(0,name,0,time1_,M,time2_,M,MLineColor,MLineStyle,MLineWidth,Background,name);

         name="Rm"+string(z);
         SetArrowRightPrice(0,name,0,time2_,M,FontColor,1,Background,name);
        }

   if(Comm) Comment("\n"," Today  =  "+TimeToString(TimeCurrent()),"?.","\n"," Step = ",DoubleToString(S,_Digits));
//----
   ChartRedraw(0);
//----   
   return(rates_total);
  }
//+------------------------------------------------------------------+
