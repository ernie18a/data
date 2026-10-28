//------------------------------------------------------------------+
#property copyright "© mladen, 2016, MetaQuotes Software Corp."
#property link      "www.forex-tsd.com, forge.mql5.io"
//------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 13
#property indicator_plots   5
#property indicator_label1  "upper filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'160,216,239'
#property indicator_label2  "middle filling"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  clrPowderBlue
#property indicator_label3  "lower filling"
#property indicator_type3   DRAW_FILLING
#property indicator_color3  C'160,216,239'
#property indicator_label4  "Average"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDarkGray
#property indicator_style4  STYLE_DOT
#property indicator_label5  "STARC candles"
#property indicator_type5   DRAW_COLOR_CANDLES
#property indicator_color5  clrDarkGray,clrDeepSkyBlue,clrSandyBrown

//
//
//
//
//

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
};
enum enMaTypes
{
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
};

input ENUM_TIMEFRAMES TimeFrame       = PERIOD_CURRENT; // Time frame
input int             StarcPeriod     = 56;             // STARC main period
input int             StarcFastPeriod = 3;              // Fast period (for candles color)
input enMaTypes       StarcMaType     = ma_sma;         // STARC average type
input enPrices        Price           = pr_close;       // Price
input int             AtrPeriod       = 100;            // ATR period
input double          AtrMultiplier1  = 2;              // ATR multiplier 1
input double          AtrMultiplier2  = 3;              // ATR multiplier 2
input enMaTypes       AtrMaType       = ma_sma;         // ATR averaging type
input bool            Interpolate     = true;           // Interpolate mtf data ?


//
//
//
//
//

double fill1u[],fill1d[],fill2u[],fill2d[],fillmu[],fillmd[],count[],ma[],cano[],canh[],canl[],canc[],cancl[];
ENUM_TIMEFRAMES timeFrame;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   SetIndexBuffer( 0,fill1u,INDICATOR_DATA); 
   SetIndexBuffer( 1,fill1d,INDICATOR_DATA);
   SetIndexBuffer( 2,fillmu,INDICATOR_DATA);
   SetIndexBuffer( 3,fillmd,INDICATOR_DATA);
   SetIndexBuffer( 4,fill2u,INDICATOR_DATA);
   SetIndexBuffer( 5,fill2d,INDICATOR_DATA);
   SetIndexBuffer( 6,ma    ,INDICATOR_DATA);
   SetIndexBuffer( 7,cano  ,INDICATOR_DATA);
   SetIndexBuffer( 8,canh  ,INDICATOR_DATA);
   SetIndexBuffer( 9,canl  ,INDICATOR_DATA);
   SetIndexBuffer(10,canc  ,INDICATOR_DATA);
   SetIndexBuffer(11,cancl,INDICATOR_DATA);
   SetIndexBuffer(12,count,INDICATOR_CALCULATIONS);
         timeFrame = MathMax(_Period,TimeFrame);
         PlotIndexSetString(0,PLOT_LABEL,timeFrameToString(timeFrame)+" STARC upper area");
         PlotIndexSetString(1,PLOT_LABEL,timeFrameToString(timeFrame)+" STARC middle area");
         PlotIndexSetString(2,PLOT_LABEL,timeFrameToString(timeFrame)+" STARC lower area");
   return(0);
}
void OnDeinit(const int reason) { return; }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[])
{
   if (Bars(_Symbol,_Period)<rates_total) return(-1);
   
      //
      //
      //
      //
      //
      
      if (timeFrame!=_Period)
      {
         double result[]; datetime currTime[],nextTime[]; 
         static int indHandle =-1;
                if (indHandle==-1) indHandle = iCustom(_Symbol,timeFrame,getIndicatorName(),PERIOD_CURRENT,StarcPeriod,StarcFastPeriod,StarcMaType,Price,AtrPeriod,AtrMultiplier1,AtrMultiplier2,AtrMaType);
                if (indHandle==-1)                          return(0);
                if (CopyBuffer(indHandle,12,0,1,result)==-1) return(0); 
             
                //
                //
                //
                //
                //
              
                #define _processed EMPTY_VALUE-1
                int i,limit = rates_total-(int)MathMin(result[0]*PeriodSeconds(timeFrame)/PeriodSeconds(_Period),rates_total); 
                for (limit=MathMax(limit,0); limit>0 && !IsStopped(); limit--) if (count[limit]==_processed) break;
                for (i=MathMin(limit,MathMax(prev_calculated-1,0)); i<rates_total && !IsStopped(); i++    )
                {
                   if (CopyBuffer(indHandle, 0,time[i],1,result)==-1) break; fill1u[i] = result[0];
                   if (CopyBuffer(indHandle, 1,time[i],1,result)==-1) break; fill1d[i] = result[0];
                   if (CopyBuffer(indHandle, 2,time[i],1,result)==-1) break; fillmu[i] = result[0];
                   if (CopyBuffer(indHandle, 3,time[i],1,result)==-1) break; fillmd[i] = result[0];
                   if (CopyBuffer(indHandle, 4,time[i],1,result)==-1) break; fill2u[i] = result[0];
                   if (CopyBuffer(indHandle, 5,time[i],1,result)==-1) break; fill2d[i] = result[0];
                   if (CopyBuffer(indHandle, 6,time[i],1,result)==-1) break; ma[i]     = result[0];
                   if (CopyBuffer(indHandle,11,time[i],1,result)==-1) break; cancl[i]  = result[0];
                                                                             cano[i]   = open[i];
                                                                             canh[i]   = high[i];
                                                                             canl[i]   = low[i];
                                                                             canc[i]   = close[i];
                                                                             count[i]  = _processed;
                   
                   //
                   //
                   //
                   //
                   //
                   
                   #define _interpolate(buff,i,k,n) buff[i-k] = buff[i]+(buff[i-n]-buff[i])*k/n
                   if (!Interpolate) continue; CopyTime(_Symbol,TimeFrame,time[i  ],1,currTime); 
                      if (i<(rates_total-1)) { CopyTime(_Symbol,TimeFrame,time[i+1],1,nextTime); if (currTime[0]==nextTime[0]) continue; }
                      int n,k;
                         for(n=1; (i-n)> 0 && time[i-n] >= currTime[0]; n++) continue;	
                         for(k=1; (i-k)>=0 && k<n; k++)
                         {
                            _interpolate(fill1u,i,k,n);
                            _interpolate(fill1d,i,k,n);
                            _interpolate(fillmu,i,k,n);
                            _interpolate(fillmd,i,k,n);
                            _interpolate(fill2u,i,k,n);
                            _interpolate(fill2d,i,k,n);
                            _interpolate(ma    ,i,k,n);
                         }                            
                }     
                if (i!=rates_total) return(0); return(rates_total);
      }

   //
   //
   //
   //
   //

   int    atrPeriod      = (AtrPeriod>0) ? AtrPeriod : StarcPeriod;
   double atrMultiplier1 = MathMin(AtrMultiplier1,AtrMultiplier2);
   double atrMultiplier2 = MathMax(AtrMultiplier1,AtrMultiplier2);
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
   {
      double price = getPrice(Price,open,close,high,low,i,rates_total,0);
      double tr    = (i>0) ? MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1]) : high[i]-low[i];
      double atr   = iCustomMa(AtrMaType,tr,atrPeriod,i,rates_total,1);
      double fma   = iCustomMa(StarcMaType,price,StarcFastPeriod,i,rates_total,2);
            ma[i]     = iCustomMa(StarcMaType,price,StarcPeriod,i,rates_total,0);
            fillmu[i] = ma[i]+atrMultiplier1*atr;
            fillmd[i] = ma[i]-atrMultiplier1*atr;
            fill1u[i] = ma[i]+atrMultiplier2*atr; fill1d[i] = fillmu[i];
            fill2d[i] = ma[i]-atrMultiplier2*atr; fill2u[i] = fillmd[i];
            canc[i]   = close[i];
            cano[i]   = open[i];
            canh[i]   = high[i];
            canl[i]   = low[i];
            cancl[i]  = (fma>ma[i]) ? 1 : (fma<ma[i]) ? 2 : 0;
      }                     
   count[rates_total-1] = MathMax(rates_total-prev_calculated+1,1);
   return(rates_total);         
}


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
//

#define priceInstances 1
double workHa[][priceInstances*4];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i,int _bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= _bars) ArrayResize(workHa,_bars); instanceNo*=4;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (i>0)
                haOpen  = (workHa[i-1][instanceNo+2] + workHa[i-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[i][instanceNo+0] = haLow;  workHa[i][instanceNo+1] = haHigh; } 
         else                 { workHa[i][instanceNo+0] = haHigh; workHa[i][instanceNo+1] = haLow;  } 
                                workHa[i][instanceNo+2] = haOpen;
                                workHa[i][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
         {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh+haLow)/2.0);
            case pr_hamedianb:   return((haOpen+haClose)/2.0);
            case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
            case pr_hatbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (tprice)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
      case pr_tbiased2:   
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
   }
   return(0);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

#define _maInstances 3
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx2 2*_maInstances

double iCustomMa(int mode, double price, double length, int r, int bars, int instanceNo=0)
{
   switch (mode)
   {
      case ma_sma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      default       : return(price);
   }
}

//
//
//
//
//

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars); instanceNo *= 2; int k;

   workSma[r][instanceNo+0] = price;
   workSma[r][instanceNo+1] = price; for(k=1; k<period && (r-k)>=0; k++) workSma[r][instanceNo+1] += workSma[r-k][instanceNo+0];  
   workSma[r][instanceNo+1] /= 1.0*k;
   return(workSma[r][instanceNo+1]);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= _bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo] = price;
   if (r>0 && period>1)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= _bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo] = price;
   if (r>1 && period>1)
          workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workLwma,0)!= _bars) ArrayResize(workLwma,_bars);
   
   workLwma[r][instanceNo] = price; if (period<=1) return(price);
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

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

string getIndicatorName()
{
   string progPath = MQL5InfoString(MQL5_PROGRAM_PATH); int start=-1;
   while (true)
   {
      int foundAt = StringFind(progPath,"\\",start+1);
      if (foundAt>=0) 
               start = foundAt;
      else  break;     
   }
   string indicatorName = StringSubstr(progPath,start+1);
          indicatorName = StringSubstr(indicatorName,0,StringLen(indicatorName)-4);
   return(indicatorName);
}

//
//
//
//
//

int    _tfsPer[]={PERIOD_M1,PERIOD_M2,PERIOD_M3,PERIOD_M4,PERIOD_M5,PERIOD_M6,PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,PERIOD_M30,PERIOD_H1,PERIOD_H2,PERIOD_H3,PERIOD_H4,PERIOD_H6,PERIOD_H8,PERIOD_H12,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
string _tfsStr[]={"1 minute","2 minutes","3 minutes","4 minutes","5 minutes","6 minutes","10 minutes","12 minutes","15 minutes","20 minutes","30 minutes","1 hour","2 hours","3 hours","4 hours","6 hours","8 hours","12 hours","daily","weekly","monthly"};
string timeFrameToString(int period)
{
   if (period==PERIOD_CURRENT) 
       period = _Period;   
         int i; for(i=ArraySize(_tfsPer)-1;i>=0;i--) if(period==_tfsPer[i]) break;
   return(_tfsStr[i]);   
}