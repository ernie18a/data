//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 16
#property indicator_plots   3
#property indicator_label1  "Vq bars bars"
#property indicator_type1   DRAW_COLOR_BARS
#property indicator_color1  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_label2  "Vq candles candles"
#property indicator_type2   DRAW_COLOR_CANDLES
#property indicator_color2  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_label3  "Vq line"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width3  2
//
//---
//
enum enDisplayStyle
  {
   dis_automatic, // Automatic display style
   dis_line,      // Display line
   dis_bars,      // Display bars
   dis_candles    // Display candles
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum enMaTypes
  {
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
  };
input int            PriceSmoothing         = 5;        // Price smoothing period
input enMaTypes      PriceSmoothingMethod   = ma_lwma;  // Price smoothing method
input double         FilterInPips           = 2.0;      // Filter (in pips)
input enDisplayStyle inpDisplayStyle=dis_automatic; // Display style

                                                    //
//---
//
double canh[],canl[],cano[],canc[],cancl[],baro[],barh[],barl[],barc[],barcl[],line[],linecl[],prices[],trend[],val[],valc[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,baro,INDICATOR_DATA);
   SetIndexBuffer(1,barh,INDICATOR_DATA);
   SetIndexBuffer(2,barl,INDICATOR_DATA);
   SetIndexBuffer(3,barc,INDICATOR_DATA);
   SetIndexBuffer(4,barcl,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,cano,INDICATOR_DATA);
   SetIndexBuffer(6,canh,INDICATOR_DATA);
   SetIndexBuffer(7,canl,INDICATOR_DATA);
   SetIndexBuffer(8,canc,INDICATOR_DATA);
   SetIndexBuffer(9,cancl,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(10,line,INDICATOR_DATA);
   SetIndexBuffer(11,linecl,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(12,prices,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,trend,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,val,INDICATOR_CALCULATIONS);
   SetIndexBuffer(15,valc,INDICATOR_CALCULATIONS);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Volatility quality Stridsman ("+(string)PriceSmoothing+")");
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
   double pipMultiplier=MathPow(10,_Digits%2);
   int limit=prev_calculated-1;
   static int prevDisplayType=-1;
   int currDisplayType=-1;
   switch(inpDisplayStyle)
     {
      case dis_line :      currDisplayType = CHART_LINE;    break;
      case dis_bars :      currDisplayType = CHART_BARS;    break;
      case dis_candles :   currDisplayType = CHART_CANDLES; break;
      case dis_automatic : currDisplayType = (int)ChartGetInteger(0,CHART_MODE);
     }
   if(currDisplayType!=prevDisplayType) { limit=0; prevDisplayType=currDisplayType; }
   int i=(int)MathMax(limit,0); for(; i<rates_total && !_StopFlag; i++)
     {
      double cHigh  =         iCustomMa(PriceSmoothingMethod,high[i]   ,PriceSmoothing,i  ,rates_total,0);
      double cLow   =         iCustomMa(PriceSmoothingMethod,low[i]    ,PriceSmoothing,i  ,rates_total,1);
      double cOpen  =         iCustomMa(PriceSmoothingMethod,open[i]   ,PriceSmoothing,i  ,rates_total,2);
      double cClose =         iCustomMa(PriceSmoothingMethod,close[i]  ,PriceSmoothing,i  ,rates_total,3);
      double pClose = (i>0) ? iCustomMa(PriceSmoothingMethod,close[i-1],PriceSmoothing,i-1,rates_total,4) : cClose;

      double trueRange = MathMax(cHigh,pClose)-MathMin(cLow,pClose);
      double range     = cHigh-cLow;
      double vqi       = (range != 0 && trueRange!=0) ? ((cClose-pClose)/trueRange + (cClose-cOpen)/range)*0.5 : (i>0) ? val[i-1] : 0;

      //
      //---
      //

      val[i]=(i>0) ? val[i-1]+MathAbs(vqi)*(cClose-pClose+cClose-cOpen)*0.5 : 0;
      if(FilterInPips>0 && i>0) if(MathAbs(val[i]-val[i-1])<FilterInPips*pipMultiplier*_Point) val[i]=val[i-1];
      valc[i]=(i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
      baro[i] = barh[i] = barl[i] = barc[i] = EMPTY_VALUE;
      cano[i] = canh[i] = canl[i] = canc[i] = EMPTY_VALUE;
      line[i] = EMPTY_VALUE;
      switch(currDisplayType)
        {
         case CHART_BARS :
            barh[i]  = high[i];
            barl[i]  = low[i];
            barc[i]  = close[i];
            baro[i]  = open[i];
            barcl[i] = valc[i];
            break;
         case CHART_CANDLES :
            canh[i]  = high[i];
            canl[i]  = low[i];
            canc[i]  = close[i];
            cano[i]  = open[i];
            cancl[i] = valc[i];
            break;
         case CHART_LINE :
            line[i]=cClose;
            linecl[i]=valc[i];
        }
     }
   return(rates_total);
  }
//------------------------------------------------------------------
// custom functions
//------------------------------------------------------------------
#define _maInstances 5
#define _maWorkBufferx1 1*_maInstances
//
//---
//
double iCustomMa(int mode,double price,double length,int r,int bars,int instanceNo=0)
  {
   switch(mode)
     {
      case ma_sma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      default       : return(price);
     }
  }
//
//---
//
double workSma[][_maWorkBufferx1];
//
//---
//
double iSma(double price,int period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSma,0)!=_bars) ArrayResize(workSma,_bars); int k;

   workSma[r][instanceNo+0]=price;
   double avg=price; for(k=1; k<period && (r-k)>=0; k++) avg+=workSma[r-k][instanceNo+0];
   return(avg/k);
  }
//
//---
//
double workEma[][_maWorkBufferx1];
//
//---
//
double iEma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workEma,0)!=_bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo]=price;
   if(r>0 && period>1)
      workEma[r][instanceNo]=workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
  }
//
//---
//
double workSmma[][_maWorkBufferx1];
//
//---
//
double iSmma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSmma,0)!=_bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo]=price;
   if(r>1 && period>1)
      workSmma[r][instanceNo]=workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
  }
//
//---
//
double workLwma[][_maWorkBufferx1];
//
//---
//
double iLwma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workLwma,0)!=_bars) ArrayResize(workLwma,_bars);

   workLwma[r][instanceNo] = price; if(period<=1) return(price);
   double sumw = period;
   double sum  = period*price;

   for(int k=1; k<period && (r-k)>=0; k++)
     {
      double weight = period-k;
      sumw  += weight;
      sum   += weight*workLwma[r-k][instanceNo];
     }
   return(sum/sumw);
  }
//+------------------------------------------------------------------+
