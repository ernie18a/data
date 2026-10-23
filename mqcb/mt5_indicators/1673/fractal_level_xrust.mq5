//+------------------------------------------------------------------+
//|                                          Fractal_Level_Xrust.mq5 |
//|                                  Copyright © 2008, XrustSolution |
//|                                            http://xrust.ucoz.net |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2008, XrustSolution"
//---- link to the website of the author
#property link      "xrust.ucoz.net"
//---- indicator version number
#property version   "1.00"
#property description "The indicator draws horizontal lines on the level of last fractals,up, and down"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- 0 graphical plots are used in total
#property indicator_plots   0
//+------------------------------------------------+ 
//|  declaration of constants                      |
//+------------------------------------------------+ 
#define RESET  0 // The constant for returning the indicator recalculation command to the terminal
//+------------------------------------------------+ 
//| Enumeration for the level width                |
//+------------------------------------------------+ 
enum ENUM_WIDTH //Type of constant
  {
   w_1 = 1,   //1
   w_2,       //2
   w_3,       //3
   w_4,       //4
   w_5        //5
  };
//+------------------------------------------------+
//| Indicator input parameters                     |
//+------------------------------------------------+
input ENUM_TIMEFRAMES  TimeFrame=PERIOD_CURRENT; //Fractals timeframe
input int              Distanse=0;               //Line distance from the fractal in points
input string           UpName="Up";              //Name of the line corresponding to Fractal up
input string           DnName="Dn";              //Name of the line corresponding to Fractal down
input color            ClUp=clrBlue;             //Color of the line corresponding to Fractal up
input color            ClDn=clrRed;              //Color of the line corresponding to Fractal down
input bool             comment=true;             //Permission for the comment
input ENUM_LINE_STYLE  levels_style=STYLE_SOLID; //actuation level style
input ENUM_WIDTH       levels_width=w_3;         //actuation level width
//+----------------------------------------------+
double FrPrice;
double FrUpPrice,FrDnPrice;
string FrUpName,FrDnName,TF;
//---- Declaration of variables for storing the indicators handles
int Fr_Handle;
//---- Declaration of integer variables of data starting point
int  min_rates_total;
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double UpBuffer[],DnBuffer[];
//+------------------------------------------------------------------+
//|  Getting string timeframe                                        |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
//----
  }
//+------------------------------------------------------------------+
//|  Creating the horizontal line                                    |
//+------------------------------------------------------------------+
void CreateHline
(
 long     chart_id,      // chart ID.
 string   name,          // object name
 int      nwin,          // window index
 double   price,         // horizontal level price
 color    Color,         // color of the line
 int      style,         // style of a line
 int      width,         // width of a line
 bool     background,// line background display
 string   text           // text
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_HLINE,nwin,0,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,background);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
//----
  }
//+------------------------------------------------------------------+
//|  Horizontal line relocation                                      |
//+------------------------------------------------------------------+
void SetHline
(
 long     chart_id,      // chart ID.
 string   name,          // object name
 int      nwin,          // window index
 double   price,         // horizontal level price
 color    Color,         // color of the line
 int      style,         // style of a line
 int      width,         // width of a line
 bool     background,// line background display
 string   text           // text
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateHline(chart_id,name,nwin,price,Color,style,width,background,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,0,price);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- getting handle of the iFractals indicator
   Fr_Handle=iFractals(Symbol(),TimeFrame);
   if(Fr_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iFractals indicator");

//---- Initialization of variables    
   min_rates_total=6;
   FrUpName=UpName;
   FrDnName=DnName;
   if(TimeFrame==PERIOD_CURRENT) TF=GetStringTimeframe(Period());
   else TF=GetStringTimeframe(TimeFrame);
   StringConcatenate(FrUpName,FrUpName,TF);
   StringConcatenate(FrDnName,FrDnName,TF);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpBuffer,INDICATOR_CALCULATIONS);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(UpBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,DnBuffer,INDICATOR_CALCULATIONS);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(DnBuffer,true);

//---- creating name for displaying if separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"Fractal_Level_Xrust"+TF);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//---- delete the level, if necessary
   ObjectDelete(0,FrDnName);
   ObjectDelete(0,FrUpName);
   Comment("");
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of minimums of price for the calculation of indicator
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking for the sufficiency of the number of bars for the calculation
   if(BarsCalculated(Fr_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int to_copy;

//---- calculation of the necessary amount of data to be copied
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      to_copy=rates_total; // starting number for calculation of all bars
     }
   else to_copy=rates_total-prev_calculated+3; // starting number for the calculation of new bars

//---- copy newly appeared data into the arrays
   if(CopyBuffer(Fr_Handle,UPPER_LINE,0,to_copy,UpBuffer)<=0) return(RESET);
   if(CopyBuffer(Fr_Handle,LOWER_LINE,0,to_copy,DnBuffer)<=0) return(RESET);

//----
   LineUp();
   LineDn();
   string FAP=DoubleToString((FrUpPrice-Distanse*_Point),_Digits);
   string FDP=DoubleToString((FrDnPrice+Distanse*_Point),_Digits);
   int diap=int(MathRound((FrUpPrice-FrDnPrice)/_Point));
   if(comment)
     {
      Comment("TimeFrame="+TF+
              "\nPrice of the upper fractal ="+FAP+
              "\nPrice of the lower fractal ="+FDP+
              "\nFractal channel ="+string(diap)+"points");
     }
//----
   ChartRedraw(0);
   return(rates_total);
  }
//-----------------------------------------------------------------------------+
// Searches the horizontal line by the name redraws if the price has changed   | 
//-----------------------------------------------------------------------------+
void LineUp()
  {
//----
   FrPrice=NormalizeDouble(FindUpFractal(),_Digits);
   FrPrice=NormalizeDouble(FrPrice+Distanse*_Point,_Digits);
   FrUpPrice=FrPrice;
   SetHline(0,FrUpName,0,FrPrice,ClUp,levels_style,levels_width,false,FrUpName);
//----
   return;
  }
//-----------------------------------------------------------------------------+
// Searches the horizontal line by the name redraws if the price has changed   | 
//-----------------------------------------------------------------------------+
void LineDn()
  {
//----
   FrPrice=NormalizeDouble(FindDnFractal(),_Digits);
   FrPrice=NormalizeDouble(FrPrice+Distanse*_Point,_Digits);
   FrDnPrice=FrPrice;
   SetHline(0,FrDnName,0,FrPrice,ClDn,levels_style,levels_width,false,FrDnName);
//----
   return;
  }
//+----------------------------------------------------------------------------+
//|  The author    : Kim Igor V. aka KimIV,  http://www.kimiv.ru               |
//+----------------------------------------------------------------------------+
//|  Version   : 07.10.2006                                                    |
//| Description: Search of the nearest upper fractal. Returns the price level. |
//+----------------------------------------------------------------------------+
double FindUpFractal()
  {
//----
   for(int s=2; s<100; s++) if(UpBuffer[s] && UpBuffer[s]!=EMPTY_VALUE) return(NormalizeDouble(UpBuffer[s],_Digits));
   Print(__FUNCTION__+"(): Fractal is not found");
//----
   return(0);
  }
//+----------------------------------------------------------------------------+
//|  The author    : Kim Igor V. aka KimIV,  http://www.kimiv.ru               |
//+----------------------------------------------------------------------------+
//|  Version   : 07.10.2006                                                    |
//| Description: Search of the nearest lower fractal. Returns the price level. |
//+----------------------------------------------------------------------------+
double FindDnFractal()
  {
//----
   for(int s=2; s<100; s++) if(DnBuffer[s] && DnBuffer[s]!=EMPTY_VALUE) return(NormalizeDouble(DnBuffer[s],_Digits));
   Print(__FUNCTION__+"(): Fractal is not found");
//----
   return(0);
  }
//+------------------------------------------------------------------+
