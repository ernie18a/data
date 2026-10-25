//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "EMA - Jurik volty adaptive"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width1  2
//--- input parameters
input double             inpPeriod = 27;          // Period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price
//--- indicator buffers
double val[],valc[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"EMA Jurik volty adative("+(string)inpPeriod+")");
//---
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
      double _price=getPrice(inpPrice,open,close,high,low,i,rates_total);
      val[i]=iEma(_price,inpPeriod*iVoltyCoeff(_price,inpPeriod,i,rates_total),i,rates_total);
      valc[i]=(i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double wrk[][5];
#define bsmax  0
#define bsmin  1
#define voltya 2
#define vsum   3
#define avolty 4
#define avgLen 65
//
//---
//
double iVoltyCoeff(double price,double length,int r,int bars)
  {
   if(ArrayRange(wrk,0)!=bars) ArrayResize(wrk,bars);
   if(r==0) { for(int k=0; k<5; k++) wrk[0][k]=0; return(1); }

//
//---
//
   double len1 = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
   double pow1 = MathMax(len1-2.0,0.5);
   double del1 = (r>0) ? price - wrk[r-1][bsmax] : 0;
   double del2 = (r>0) ? price - wrk[r-1][bsmin] : 0;

   wrk[r][voltya]=0;
   if(MathAbs(del1) > MathAbs(del2)) wrk[r][voltya] = MathAbs(del1);
   if(MathAbs(del1) < MathAbs(del2)) wrk[r][voltya] = MathAbs(del2);
   wrk[r][vsum]=(r>9) ? wrk[r-1][vsum]+0.1*(wrk[r][voltya]-wrk[r-10][voltya]) : wrk[r][voltya];

   double avg=wrk[r][vsum];  int k=1; for(; k<avgLen && (r-k)>=0; k++) avg+=wrk[r-k][vsum];
   avg/=k;
   wrk[r][avolty]=avg;
   double dVolty=(wrk[r][avolty]>0) ? wrk[r][voltya]/wrk[r][avolty]: 0;
   if(dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
   if(dVolty < 1)                      dVolty = 1.0;

//
//---
//

   double pow2 = MathPow(dVolty, pow1);
   double len2 = MathSqrt(0.5*(length-1))*len1;
   double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

   if(del1 > 0) wrk[r][bsmax] = price; else wrk[r][bsmax] = price - Kv*del1;
   if(del2 < 0) wrk[r][bsmin] = price; else wrk[r][bsmin] = price - Kv*del2;

//
//---
//
   double _temp=(wrk[r][vsum]!=0) ? wrk[r][avolty]/wrk[r][vsum]: 1;
   return(_temp);
  }
//
//---
//
double workEma[][1];
//
//---
//
double iEma(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workEma,0)!=bars) ArrayResize(workEma,bars);
   //
   //---
   //
   workEma[r][instanceNo]=price;
   if(r>0 && period>=1)
      workEma[r][instanceNo]=workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
  }
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   if(i>=0)
      switch(tprice)
        {
         case PRICE_CLOSE:     return(close[i]);
         case PRICE_OPEN:      return(open[i]);
         case PRICE_HIGH:      return(high[i]);
         case PRICE_LOW:       return(low[i]);
         case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
         case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
         case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
        }
   return(0);
  }
//+------------------------------------------------------------------+
