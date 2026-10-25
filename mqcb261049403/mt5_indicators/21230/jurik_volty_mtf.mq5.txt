//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Jurik volty"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2
#property indicator_label1  "Jurik volty"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrLimeGreen,clrOrange
#property indicator_width1  2
#property indicator_label2  "Jurik volty signal"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrSilver,clrLimeGreen,clrOrange
//
// input parameters
//
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
input enTimeFrames       inpTimeFrame   = tf_cu;       // Time frame
input int                inpPeriod      = 14;          // Volty period
input ENUM_APPLIED_PRICE inpPrice       = PRICE_CLOSE; // Price
input bool               inpInterpolate = true;        // Interpolate in multi time frame mode?

double  val[],valc[],sig[],sigc[],count[];
int     _mtfHandle=INVALID_HANDLE; ENUM_TIMEFRAMES _indicatorTimeFrame; string _indicatorName;
#define _mtfCall iCustom(_Symbol,_indicatorTimeFrame,_indicatorName,tf_cu,inpPeriod,inpPrice)
//
//---
//
struct sVoltyAnswer
  {
   double            volty;
   double            voltySignal;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,sig,INDICATOR_DATA);
   SetIndexBuffer(3,sigc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,count,INDICATOR_CALCULATIONS);
//
//---
//
   _indicatorTimeFrame = MathMax(timeFrameGet((int)inpTimeFrame),_Period);
   _indicatorName      = getIndicatorName();
   if(_indicatorTimeFrame!=_Period)
     {
      _mtfHandle = _mtfCall; if(_mtfHandle==INVALID_HANDLE) return(INIT_FAILED);
     }
//
//---
//
   IndicatorSetString(INDICATOR_SHORTNAME,timeFrameToString(_indicatorTimeFrame)+" Jurik volty ("+(string)inpPeriod+")");
   return(INIT_SUCCEEDED);
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
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
   if(_indicatorTimeFrame!=_Period)
     {
      double result[1];
      if(BarsCalculated(_mtfHandle)<0)            return(prev_calculated);
      if(CopyBuffer(_mtfHandle,4,0,1,result)!= 1) return(prev_calculated);

      //
      //---
      //

      #define _mtfRatio (double)PeriodSeconds((ENUM_TIMEFRAMES)_indicatorTimeFrame)/PeriodSeconds(_Period)
      int k,n,i=MathMin(MathMax(prev_calculated-1,0),MathMax(rates_total-int(result[0]*_mtfRatio)-1,0)),_prevMark=0,_seconds=PeriodSeconds(_indicatorTimeFrame);

      for(; i<rates_total && !_StopFlag; i++)
        {
         int _currMark= int(time[i]/_seconds);
         if(_currMark!=_prevMark)
           {
            _prevMark=_currMark;
            #define _mtfCopy(_buff,_buffNo) if(CopyBuffer(_mtfHandle,_buffNo,time[i],1,result)<=0) break; _buff[i]=result[0]
                    _mtfCopy(val,0);
                    _mtfCopy(valc,1);
                    _mtfCopy(sig,2);
                    _mtfCopy(sigc,3);
           }
         else
           {
            val[i]  = val[i-1];
            valc[i] = valc[i-1];
            sig[i]  = sig[i-1];
            sigc[i] = sigc[i-1];
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
                    _mtfInterpolate(sig);
           }
        }
      return(i);
     }

//
//---
//

   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      double price=getPrice(inpPrice,open,close,high,low,i,rates_total);
      sVoltyAnswer _answer=iVolty(price,inpPeriod,i,rates_total);
      val[i]  = _answer.volty;
      sig[i]  = _answer.voltySignal;
      valc[i] = (val[i]>sig[i]) ? 1 : (val[i]<sig[i]) ? 2 : 0;
      sigc[i] = valc[i];
     }
   count[rates_total-1]=MathMax(rates_total-prev_calculated+1,1);
   return(i);
  }
//------------------------------------------------------------------
// custom functions
//------------------------------------------------------------------
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
sVoltyAnswer iVolty(double price,double length,int r,int bars)
  {
   if(ArrayRange(wrk,0)!=bars) ArrayResize(wrk,bars);
   sVoltyAnswer _answer;
   _answer.volty=0;
   _answer.voltySignal=0;

   if(r==0) { for(int k=0; k<5; k++) wrk[0][k]=0; return(_answer); }

//
//
//
//
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

   _answer.voltySignal = wrk[r][avolty];
   _answer.volty       = wrk[r][vsum];
   return(_answer);
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
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
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
