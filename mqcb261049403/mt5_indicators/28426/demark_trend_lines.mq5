 
#property copyright "GreenDog"
#property link      "krot@inbox.ru" // v2.3 simplified trendline only no comments

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
 
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrBlue
 


input int    LevDP=2;         // Fractal Period or Levels Demar Pint
input int    qSteps=1;       // Number  Trendlines per UpTrend or DownTrend
input int    BackStep=0;    // Number of Steps Back
input int    showBars=500; // Bars Back To Draw
input int    ArrowCode=159;
input color  UpTrendColor=clrDarkBlue;
input color  DownTrendColor=clrFireBrick;
input int    TrendlineWidth=1;
input ENUM_LINE_STYLE TrendlineStyle=STYLE_SOLID;
input string  UniqueID  = "TrendLINE"; // Indicator unique ID


double Buf1[],Fractal1[];
double Buf2[],Fractal2[];
int _showBars=showBars;
 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,Fractal1,INDICATOR_DATA);       ArraySetAsSeries(Fractal1,true);
   SetIndexBuffer(1,Fractal2,INDICATOR_DATA);       ArraySetAsSeries(Fractal2,true);
   SetIndexBuffer(2,Buf1,INDICATOR_CALCULATIONS);   ArraySetAsSeries(Buf1,true);
   SetIndexBuffer(3,Buf2,INDICATOR_CALCULATIONS);   ArraySetAsSeries(Buf2,true);
   PlotIndexSetInteger(0,PLOT_ARROW,ArrowCode);
   PlotIndexSetInteger(1,PLOT_ARROW,ArrowCode);
 
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int  reason)
  {
   ObjectsDeleteAll(0,UniqueID);
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
 
    ArrayInitialize(Buf1,0.0);
    ArrayInitialize(Buf2,0.0);
 
 
   static datetime prevTime=0;
   if(prevTime!=iTime(_Symbol,PERIOD_CURRENT,0))// New Bar
     {
      int cnt=0;
      if(_showBars==0||_showBars>rates_total-1)
        _showBars=MathMin(MathMax(rates_total-prev_calculated,LevDP),rates_total-1);
         
      for(cnt=_showBars; cnt>LevDP; cnt--)
        {
         Buf1[cnt]=DemHigh(cnt,LevDP);
         Buf2[cnt]=DemLow(cnt,LevDP);
         Fractal1[cnt] =  Buf1[cnt];
         Fractal2[cnt] =  Buf2[cnt];
        }
      for(cnt=1; cnt<=qSteps; cnt++)
         (TDMain(cnt));
 
     prevTime=iTime(_Symbol,PERIOD_CURRENT,0);
     }
     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TDMain(int Step)
  {
   int H1,H2,L1,L2;
   string Rem;

//   DownTrendLines
   H1=GetTD(Step+BackStep,Buf1);
   H2=GetNextHighTD(H1);

   if(H1<0 || H2<0)
      Print("Demark: Not enough bars on the chart for construction");
   else
     {
      Rem=UniqueID+" Down "+IntegerToString(Step);
      ObjectDelete(0,Rem);
      ObjectCreate(0,Rem,OBJ_TREND,0,iTime(Symbol(),Period(),H2),iHigh(Symbol(),Period(),H2),iTime(Symbol(),Period(),H1),iHigh(Symbol(),Period(),H1));
      ObjectSetInteger(0,Rem,OBJPROP_RAY_RIGHT,true);
      ObjectSetInteger(0,Rem,OBJPROP_COLOR,DownTrendColor);
      ObjectSetInteger(0,Rem,OBJPROP_WIDTH,TrendlineWidth);
      ObjectSetInteger(0,Rem,OBJPROP_STYLE,TrendlineStyle);
     }
//    UpTrendLines
   L1=GetTD(Step+BackStep,Buf2);
   L2=GetNextLowTD(L1);

   if(L1<0 || L2<0)
      Print("Demark: Not enough bars on the chart for construction");
   else
     {
      Rem=UniqueID+" Up "+IntegerToString(Step);
      ObjectDelete(0,Rem);
      ObjectCreate(0,Rem,OBJ_TREND,0,iTime(Symbol(),Period(),L2),iLow(Symbol(),Period(),L2),iTime(Symbol(),Period(),L1),iLow(Symbol(),Period(),L1));
      ObjectSetInteger(0,Rem,OBJPROP_RAY_RIGHT,true);
      ObjectSetInteger(0,Rem,OBJPROP_COLOR,UpTrendColor);
      ObjectSetInteger(0,Rem,OBJPROP_WIDTH,TrendlineWidth);
      ObjectSetInteger(0,Rem,OBJPROP_STYLE,TrendlineStyle);
     }
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetTD(int P, const double& Arr[])
  {
   int i=0,j=0;
   while(j<P)
     {
      i++;
      while(Arr[i]==0)
        {
         i++;
         if(i>_showBars-2)
            return(-1);
        }
      j++;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetNextHighTD(int P)
  {
   int i=P+1;
   while(Buf1[i]<=iHigh(Symbol(),Period(),P))
     {
      i++;
      if(i>_showBars-2)
         return(-1);
     }
   return (i);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetNextLowTD(int P)
  {
   int i=P+1;
   while(Buf2[i]>=iLow(Symbol(),Period(),P) || Buf2[i]==0)
     {
      i++;
      if(i>_showBars-2)
         return(-1);
     }
   return (i);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DemHigh(int cnt, int sh)
  {
   if(iHigh(Symbol(),Period(),cnt)>=iHigh(Symbol(),Period(),cnt+sh) && iHigh(Symbol(),Period(),cnt)>iHigh(Symbol(),Period(),cnt-sh))
     {
      if(sh>1)
         return(DemHigh(cnt,sh-1));
      else
         return(iHigh(Symbol(),Period(),cnt));
     }
   else
      return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DemLow(int cnt, int sh)
  {
   if(iLow(Symbol(),Period(),cnt)<=iLow(Symbol(),Period(),cnt+sh) && iLow(Symbol(),Period(),cnt)<iLow(Symbol(),Period(),cnt-sh))
     {
      if(sh>1)
         return(DemLow(cnt,sh-1));
      else
         return(iLow(Symbol(),Period(),cnt));
     }
   else
      return(0);
  }
//+------------------------------------------------------------------+
