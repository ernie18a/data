//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   3
#property indicator_label1  "Adx trend filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'160,231,160',C'231,160,160'
#property indicator_label2  "Adx trend histogram"
#property indicator_type2   DRAW_COLOR_HISTOGRAM
#property indicator_color2  clrGray,clrLimeGreen,clrGreen,clrRed,clrMaroon
#property indicator_width2  2
#property indicator_label3  "Adx trend"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrGray,clrLimeGreen,clrRed
#property indicator_width3  2
//
//---
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
//
//---
//
enum enTimeFrames
  {
   tf_cu  = PERIOD_CURRENT, // Current time frame
   tf_m1  = PERIOD_M1,      // 1 minute
   tf_m2  = PERIOD_M2,      // 2 minutes
   tf_m3  = PERIOD_M3,      // 3 minutes
   tf_m4  = PERIOD_M4,      // 4 minutes
   tf_m5  = PERIOD_M5,      // 5 minutes
   tf_m6  = PERIOD_M6,      // 6 minutes
   tf_m10 = PERIOD_M10,     // 10 minutes
   tf_m12 = PERIOD_M12,     // 12 minutes
   tf_m15 = PERIOD_M15,     // 15 minutes
   tf_m20 = PERIOD_M20,     // 20 minutes
   tf_m30 = PERIOD_M30,     // 30 minutes
   tf_h1  = PERIOD_H1,      // 1 hour
   tf_h2  = PERIOD_H2,      // 2 hours
   tf_h3  = PERIOD_H3,      // 3 hours
   tf_h4  = PERIOD_H4,      // 4 hours
   tf_h6  = PERIOD_H6,      // 6 hours
   tf_h8  = PERIOD_H8,      // 8 hours
   tf_h12 = PERIOD_H12,     // 12 hours
   tf_d1  = PERIOD_D1,      // daily
   tf_w1  = PERIOD_W1,      // weekly
   tf_mn  = PERIOD_MN1,     // monthly
   tf_cp1 = -1,             // Next higher time frame
   tf_cp2 = -2,             // Second higher time frame
   tf_cp3 = -3              // Third higher time frame
  };
//
//---
//
input enTimeFrames    inpTimeFrame      = tf_cu;          // Time frame
input double          AdxVmaPeriod      = 10;             // AdxVma period
input enPrices        AdxVmaPrice       = pr_close;       // Price
input int             SmoothPeriod      = 5;              // Smoothing period (<=1 for no smoothing)
input bool            inpInterpolate    = true;           // Interpolate in multi time frame mode?
//
//---
//
double  val[],valc[],valfu[],valfd[],histo[],histoc[],count[];
int     _mtfHandle=INVALID_HANDLE; ENUM_TIMEFRAMES _indicatorTimeFrame; string _indicatorName;
#define _mtfCall iCustom(_Symbol,_indicatorTimeFrame,_indicatorName,0,AdxVmaPeriod,AdxVmaPrice,SmoothPeriod)

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
   SetIndexBuffer(0,valfu ,INDICATOR_DATA);
   SetIndexBuffer(1,valfd ,INDICATOR_DATA);
   SetIndexBuffer(2,histo ,INDICATOR_DATA);
   SetIndexBuffer(3,histoc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,val   ,INDICATOR_DATA);
   SetIndexBuffer(5,valc  ,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,count ,INDICATOR_CALCULATIONS);
      for (int k=0; k<2; k++) PlotIndexSetInteger(k,PLOT_SHOW_DATA,false);
//
//---
//
   _indicatorTimeFrame = MathMax(timeFrameGet((int)inpTimeFrame),_Period);
   _indicatorName      = getIndicatorName();
   if(_indicatorTimeFrame!=_Period)
     {
      _mtfHandle = _mtfCall; if(_mtfHandle==INVALID_HANDLE) return(INIT_FAILED);
     }
     IndicatorSetString(INDICATOR_SHORTNAME,timeFrameToString(_indicatorTimeFrame)+" Adx trend ("+string(AdxVmaPeriod)+","+string(SmoothPeriod)+")");
     return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnCalculate(const int rates_total,
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
   if(_indicatorTimeFrame!=_Period)
     {
      double result[];
      if(BarsCalculated(_mtfHandle)<0)              return(prev_calculated);
      if(!timeFrameCheck(_indicatorTimeFrame,time)) return(prev_calculated);
      if(CopyBuffer(_mtfHandle,6,0,1,result)==-1)   return(prev_calculated);

      //
      //---
      //
      
      #define _mtfRatio (double)PeriodSeconds((ENUM_TIMEFRAMES)_indicatorTimeFrame)/PeriodSeconds(_Period)
      int k,n,i=MathMin(MathMax(prev_calculated-1,0),MathMax(rates_total-int(result[0]*_mtfRatio)-1,0)),_prevMark=0,_seconds=PeriodSeconds(_indicatorTimeFrame);
      for(; i<rates_total && !_StopFlag; i++)
        {
         int _currMark= int(time[i]/_seconds);
         if (_currMark!=_prevMark)
            {
               _prevMark=_currMark;
               #define _mtfCopy(_buff,_buffNo) if(CopyBuffer(_mtfHandle,_buffNo,time[i],1,result)<=0) break; _buff[i]=result[0]
                       _mtfCopy(valfu ,0);
                       _mtfCopy(valfd ,1);
                       _mtfCopy(histo ,2);
                       _mtfCopy(histoc,3); 
                       _mtfCopy(val   ,4);
                       _mtfCopy(valc  ,5);
            }
            else
            {
               val[i]    = val[i-1];
               valc[i]   = valc[i-1];
               histo[i]  = histo[i-1];  
               histoc[i] = histoc[i-1];
               valfu[i]  = valfu[i-1];
               valfd[i]  = valfd[i-1];
            }

            //
            //---
            //

            if(!inpInterpolate) continue;
            int _nextMark=(i<rates_total-1) ? int(time[i+1]/_seconds) : _prevMark+1; if(_nextMark==_prevMark) continue;
            for(n=1; (i-n)> 0 && time[i-n] >= (_prevMark)*_seconds; n++) continue;
            for(k=1; (i-k)>=0 && k<n; k++)
            {
               #define _mtfInterpolate(_buff) _buff[i-k]=_buff[i]+(_buff[i-n]-_buff[i])*k/n
                       _mtfInterpolate(val);
                       histo[i-k] = val[i-k];
                        if (valfu[i]!=0) valfu[i-k] =  val[i-k];
                        if (valfd[i]!=0) valfd[i-k] =  val[i-k];
            }
         }
         return(i);
     }

   //
   //---
   //
   
   int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total  && !_StopFlag; i++)
   {
      double trendup,trenddn;
         iAdxvma(getPrice(AdxVmaPrice,open,close,high,low,i,rates_total),AdxVmaPeriod,i,rates_total,trendup,trenddn,1);
         val[i]    = (trendup>0) ? iSmooth(trendup,SmoothPeriod,0,i,rates_total,0) : iSmooth(trenddn,SmoothPeriod,0,i,rates_total,0);
         valc[i]   = (trendup>0) ? 1 : (trenddn>0) ? 2 : (i>0) ? valc[i-1] : 0; 
         valfu[i]  = (trendup>0) ? val[i] : 0;
         valfd[i]  = (trendup>0) ? 0 : val[i];
         histo[i]  = val[i];
         histoc[i] = (i>0) ? (valc[i]==1) ? (val[i]>val[i-1]) ? 1 : 2 : (val[i]<val[i-1]) ? 4 : 3 : 0;
   }      
   count[rates_total-1]=MathMax(rates_total-prev_calculated+1,1);
   return(i);
}


//------------------------------------------------------------------
// custom functions
//------------------------------------------------------------------
#define _adxvmaInstances     2
#define _adxvmaInstancesSize 7
double  _adxvmaWork[][_adxvmaInstances*_adxvmaInstancesSize];
#define _adxvmaWprc 0
#define _adxvmaWpdm 1
#define _adxvmaWmdm 2
#define _adxvmaWpdi 3
#define _adxvmaWmdi 4
#define _adxvmaWout 5
#define _adxvmaWval 6

double iAdxvma(double price, double period, int i, int bars, double& trendp, double& trendm, int instanceNo=0)
{
   if (ArrayRange(_adxvmaWork,0)!=bars) ArrayResize(_adxvmaWork,bars); instanceNo*=_adxvmaInstancesSize;
   
   //
   //
   //
   //
   //
   
   for (int k=0; k<7; k++) _adxvmaWork[i][instanceNo+k] = price;
   if (period>1)
   {
      double diff = (i>0) ? _adxvmaWork[i][instanceNo+_adxvmaWprc]-_adxvmaWork[i-1][instanceNo+_adxvmaWprc] : 0;
      double tpdm = (diff>0) ?  diff : 0;
      double tmdm = (diff<0) ? -diff : 0;
         _adxvmaWork[i][instanceNo+_adxvmaWpdm] = (i>0) ? ((period-1.0)*_adxvmaWork[i-1][instanceNo+_adxvmaWpdm]+tpdm)/period : tpdm;
         _adxvmaWork[i][instanceNo+_adxvmaWmdm] = (i>0) ? ((period-1.0)*_adxvmaWork[i-1][instanceNo+_adxvmaWmdm]+tmdm)/period : tmdm;

      double trueRange = _adxvmaWork[i][instanceNo+_adxvmaWpdm]+_adxvmaWork[i][instanceNo+_adxvmaWmdm];
      double tpdi      = (trueRange>0) ? _adxvmaWork[i][instanceNo+_adxvmaWpdm]/trueRange : 0;
      double tmdi      = (trueRange>0) ? _adxvmaWork[i][instanceNo+_adxvmaWmdm]/trueRange : 0;
         _adxvmaWork[i][instanceNo+_adxvmaWpdi] = (i>0) ? ((period-1.0)*_adxvmaWork[i-1][instanceNo+_adxvmaWpdi]+tpdi)/period : tpdi;
         _adxvmaWork[i][instanceNo+_adxvmaWmdi] = (i>0) ? ((period-1.0)*_adxvmaWork[i-1][instanceNo+_adxvmaWmdi]+tmdi)/period : tmdi;
                                         trendp = _adxvmaWork[i][instanceNo+_adxvmaWpdi]-0.5;
                                         trendm = _adxvmaWork[i][instanceNo+_adxvmaWmdi]-0.5;
   
      //
      //
      //
      //
      //
      
      double tout  = 0; 
         if ((_adxvmaWork[i][instanceNo+_adxvmaWpdi]+_adxvmaWork[i][instanceNo+_adxvmaWmdi])>0) 
               tout = MathAbs(_adxvmaWork[i][instanceNo+_adxvmaWpdi]-_adxvmaWork[i][instanceNo+_adxvmaWmdi])/(_adxvmaWork[i][instanceNo+_adxvmaWpdi]+_adxvmaWork[i][instanceNo+_adxvmaWmdi]);
                              _adxvmaWork[i][instanceNo+_adxvmaWout] = (i>0) ? ((period-1.0)*_adxvmaWork[i-1][instanceNo+_adxvmaWout]+tout)/period : tout;

      double thi = (i>0) ? MathMax(_adxvmaWork[i][instanceNo+_adxvmaWout],_adxvmaWork[i-1][instanceNo+_adxvmaWout]) : _adxvmaWork[i][instanceNo+_adxvmaWout];
      double tlo = (i>0) ? MathMin(_adxvmaWork[i][instanceNo+_adxvmaWout],_adxvmaWork[i-1][instanceNo+_adxvmaWout]) : _adxvmaWork[i][instanceNo+_adxvmaWout];
         for (int k = 2; k<period && i-k>=0; k++)
         {
            thi = MathMax(_adxvmaWork[i-k][instanceNo+_adxvmaWout],thi);
            tlo = MathMin(_adxvmaWork[i-k][instanceNo+_adxvmaWout],tlo);
         }            
      double vi = ((thi-tlo)>0) ? (_adxvmaWork[i][instanceNo+_adxvmaWout]-tlo)/(thi-tlo) : 0;
                                   _adxvmaWork[i][instanceNo+_adxvmaWval] = (i>0) ? ((period-vi)*_adxvmaWork[i-1][instanceNo+_adxvmaWval]+vi*_adxvmaWork[i][instanceNo+_adxvmaWprc])/period : price;

   }          
   
   //
   //
   //
   //
   //
   
   return(_adxvmaWork[i][instanceNo+_adxvmaWval]);
}
//
//---
//
#define _smoothInstances     1
#define _smoothInstancesSize 10
double m_wrk[][_smoothInstances*_smoothInstancesSize];
int    m_size=0;
//
//---
//
double iSmooth(double price,double length,double phase,int r,int bars,int instanceNo=0)
  {
   #define bsmax  5
   #define bsmin  6
   #define volty  7
   #define vsum   8
   #define avolty 9

   if(ArrayRange(m_wrk,0)!=bars) ArrayResize(m_wrk,bars); if(ArrayRange(m_wrk,0)!=bars) return(price); instanceNo*=_smoothInstancesSize;
   if(r==0 || length<=1) { int k=0; for(; k<7; k++) m_wrk[r][instanceNo+k]=price; for(; k<10; k++) m_wrk[r][instanceNo+k]=0; return(price); }

//
//---
//

   double len1   = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
   double pow1   = MathMax(len1-2.0,0.5);
   double del1   = price - m_wrk[r-1][instanceNo+bsmax];
   double del2   = price - m_wrk[r-1][instanceNo+bsmin];
   int    forBar = MathMin(r,10);

   m_wrk[r][instanceNo+volty]=0;
   if(MathAbs(del1) > MathAbs(del2)) m_wrk[r][instanceNo+volty] = MathAbs(del1);
   if(MathAbs(del1) < MathAbs(del2)) m_wrk[r][instanceNo+volty] = MathAbs(del2);
   m_wrk[r][instanceNo+vsum]=m_wrk[r-1][instanceNo+vsum]+(m_wrk[r][instanceNo+volty]-m_wrk[r-forBar][instanceNo+volty])*0.1;

//
//---
//

   m_wrk[r][instanceNo+avolty]=m_wrk[r-1][instanceNo+avolty]+(2.0/(MathMax(4.0*length,30)+1.0))*(m_wrk[r][instanceNo+vsum]-m_wrk[r-1][instanceNo+avolty]);
   double dVolty=(m_wrk[r][instanceNo+avolty]>0) ? m_wrk[r][instanceNo+volty]/m_wrk[r][instanceNo+avolty]: 0;
   if(dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
   if(dVolty < 1)                      dVolty = 1.0;

//
//---
//

   double pow2 = MathPow(dVolty, pow1);
   double len2 = MathSqrt(0.5*(length-1))*len1;
   double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

   if(del1 > 0) m_wrk[r][instanceNo+bsmax] = price; else m_wrk[r][instanceNo+bsmax] = price - Kv*del1;
   if(del2 < 0) m_wrk[r][instanceNo+bsmin] = price; else m_wrk[r][instanceNo+bsmin] = price - Kv*del2;

//
//---
//

   double corr  = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
   double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
   double alpha = MathPow(beta,pow2);

   m_wrk[r][instanceNo+0] = price + alpha*(m_wrk[r-1][instanceNo+0]-price);
   m_wrk[r][instanceNo+1] = (price - m_wrk[r][instanceNo+0])*(1-beta) + beta*m_wrk[r-1][instanceNo+1];
   m_wrk[r][instanceNo+2] = (m_wrk[r][instanceNo+0] + corr*m_wrk[r][instanceNo+1]);
   m_wrk[r][instanceNo+3] = (m_wrk[r][instanceNo+2] - m_wrk[r-1][instanceNo+4])*MathPow((1-alpha),2) + MathPow(alpha,2)*m_wrk[r-1][instanceNo+3];
   m_wrk[r][instanceNo+4] = (m_wrk[r-1][instanceNo+4] + m_wrk[r][instanceNo+3]);

//
//---
//

   return(m_wrk[r][instanceNo+4]);

   #undef bsmax
   #undef bsmin
   #undef volty
   #undef vsum
   #undef avolty
  }
//
//---
//
#define _pricesInstances 1
#define _pricesSize      4
double workHa[][_pricesInstances*_pricesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i,int _bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= _bars) ArrayResize(workHa,_bars); instanceNo*=_pricesSize;
         
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
//
//---
//  
ENUM_TIMEFRAMES _tfsPer[]={PERIOD_M1,PERIOD_M2,PERIOD_M3,PERIOD_M4,PERIOD_M5,PERIOD_M6,PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,PERIOD_M30,PERIOD_H1,PERIOD_H2,PERIOD_H3,PERIOD_H4,PERIOD_H6,PERIOD_H8,PERIOD_H12,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
string          _tfsStr[]={"1 minute","2 minutes","3 minutes","4 minutes","5 minutes","6 minutes","10 minutes","12 minutes","15 minutes","20 minutes","30 minutes","1 hour","2 hours","3 hours","4 hours","6 hours","8 hours","12 hours","daily","weekly","monthly"};
//
//---
//
string timeFrameToString(int period)
  {
   if(period==PERIOD_CURRENT)
      period=_Period;
   int i; for(i=0;i<ArraySize(_tfsPer);i++) if(period==_tfsPer[i]) break;
   return(_tfsStr[i]);
  }
//
//---
//
ENUM_TIMEFRAMES timeFrameGet(int period)
  {
   int _shift=(period<0?MathAbs(period):0);
   if(_shift>0 || period==tf_cu) period=_Period;
   int i; for(i=0;i<ArraySize(_tfsPer);i++) if(period==_tfsPer[i]) break;

   return(_tfsPer[(int)MathMin(i+_shift,ArraySize(_tfsPer)-1)]);
  }
//
//---
//
string getIndicatorName()
  {
   string _path=MQL5InfoString(MQL5_PROGRAM_PATH); StringToLower(_path);
   string _partsA[];
   ushort _partsS=StringGetCharacter("\\",0);
   int    _partsN= StringSplit(_path,_partsS,_partsA);
   string name=_partsA[_partsN-1]; for(int n=_partsN-2; n>=0 && _partsA[n]!="indicators"; n--) name=_partsA[n]+"\\"+name;
   return(name);
  }
//
//---
//  
bool timeFrameCheck(ENUM_TIMEFRAMES _timeFrame,const datetime &time[])
  {
   static bool warned=false;
   if(time[0]<SeriesInfoInteger(_Symbol,_timeFrame,SERIES_FIRSTDATE))
     {
      datetime startTime,testTime[];
      if(SeriesInfoInteger(_Symbol,PERIOD_M1,SERIES_TERMINAL_FIRSTDATE,startTime))
      if(startTime>0)                       { CopyTime(_Symbol,_timeFrame,time[0],1,testTime); SeriesInfoInteger(_Symbol,_timeFrame,SERIES_FIRSTDATE,startTime); }
      if(startTime<=0 || startTime>time[0]) { Comment(MQL5InfoString(MQL5_PROGRAM_NAME)+"\nMissing data for "+timeFrameToString(_timeFrame)+" time frame\nRe-trying on next tick"); warned=true; return(false); }
     }
   if(warned) { Comment(""); warned=false; }
   return(true);
  } 
//+------------------------------------------------------------------+
