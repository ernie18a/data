//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   3
#property indicator_label1  "Zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'230,230,230'
#property indicator_label2  "Middle"
#property indicator_type2   DRAW_LINE
#property indicator_style2  STYLE_DOT
#property indicator_color2  clrGray
#property indicator_label3  "Double smoothed EMA"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrLimeGreen,clrDeepPink
#property indicator_width3  2
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
input enTimeFrames       inpTimeFrame  = tf_cu;        // Time frame
input double             inpPeriod     = 14;           // Period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_MEDIAN; // Price
enum chgColor
{
   chg_onSlope,  // change color on slope change
   chg_onLevel,  // Change color on outer levels cross
   chg_onMiddle, // Change color on middle level cross
};
input int                inpFlPeriod         = 25;             // Period for finding floating levels
input double             inpFlUp             = 90;             // Upper level %
input double             inpFlDown           = 10;             // Lower level %
input chgColor           inpColorOn          = chg_onLevel;    // Color change on :
enum enIterpolate
{
   interolate_yes=(int)true, // Interpolate data when in multi time frame
   interolate_no =(int)false // Do not interpolate data when in multi time frame
};
input enIterpolate inpInterpolate = interolate_yes; // Interpolation

//
//---
//

double val[],valc[],work[],count[],mid[],fup[],fdn[],_alpha;
ENUM_TIMEFRAMES _indicatorTimeFrame; string _indicatorName; int  _indicatorMtfHandle; 
#define _mtfCall iCustom(_Symbol,_indicatorTimeFrame,_indicatorName,0,inpPeriod,inpPrice,inpFlPeriod,inpFlUp,inpFlDown,inpColorOn)

//------------------------------------------------------------------ 
// Custom indicator initialization function                          
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,fup  ,INDICATOR_DATA);
         SetIndexBuffer(1,fdn  ,INDICATOR_DATA);
         SetIndexBuffer(2,mid  ,INDICATOR_DATA);
         SetIndexBuffer(3,val  ,INDICATOR_DATA);
         SetIndexBuffer(4,valc ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(5,work ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(6,count,INDICATOR_CALCULATIONS);
            _alpha               = 2.0/(1.0+MathSqrt(MathMax(inpPeriod,1)));
            _indicatorTimeFrame  = MathMax(_Period,timeFrameGet(inpTimeFrame)); 
            if (_indicatorTimeFrame != _Period) 
               {
                  _indicatorName = getIndicatorName(); 
                  _indicatorMtfHandle = _mtfCall; if (!_checkHandle(_indicatorMtfHandle,"Target time frame instance")) return(INIT_FAILED); 
               }
   //         
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Double smoothed EMA ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
}

//------------------------------------------------------------------
// Custom indicator iteration function                              
//------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   //
   //---
   //
         if(_indicatorTimeFrame!=_Period)
         {
            double result[1]; if (CopyBuffer(_indicatorMtfHandle,6,0,1,result)<0) result[0] = rates_total;

            //
            //---
            //
      
            #define _mtfRatio (double)PeriodSeconds((ENUM_TIMEFRAMES)_indicatorTimeFrame)/PeriodSeconds(_Period)
            int  n,k,i=MathMin(MathMax(prev_calculated-1,0),MathMax(rates_total-int(result[0]*_mtfRatio)-1,0)),_prevMark=-99; datetime _prevTime;
            for(; i<rates_total && !_StopFlag; i++)
            {
               int _currMark = iBarShift(_Symbol,_indicatorTimeFrame,time[i]); if (_currMark<0) continue;
               if (_currMark!=_prevMark)
               {
                  _prevMark =_currMark;
                  _prevTime = time[i];
                  #define _mtfCopy(_buff,_buffNo) { if(CopyBuffer(_indicatorMtfHandle,_buffNo,_currMark,1,result)<1) break; _buff[i]=result[0]; }
                          _mtfCopy(fup ,0);
                          _mtfCopy(fdn ,1);
                          _mtfCopy(mid ,2);
                          _mtfCopy(val ,3);
                          _mtfCopy(valc,4);
               }
               else 
               {
                  #define _mtfCopyValue(_buff) _buff[i] = _buff[i-1]; 
                          _mtfCopyValue(fup);
                          _mtfCopyValue(fdn);
                          _mtfCopyValue(mid);
                          _mtfCopyValue(val);
                          _mtfCopyValue(valc);
               }                  
               
               //
               //---
               //

               if(!inpInterpolate) continue;
                  int _nextMark = (i<rates_total-1) ? iBarShift(_Symbol,_indicatorTimeFrame,time[i+1]) : _prevMark+1; if(_nextMark==_prevMark) continue;               
                  for (n=1; (i-n)> 0 && time[i-n] >= _prevTime; n++) continue;
                  for (k=1; (i-k)>=0 && k<n; k++)
                  {
                     #define _mtfInterpolate(_buff) _buff[i-k]=_buff[i]+(_buff[i-n]-_buff[i])*k/n
                             _mtfInterpolate(fup);
                             _mtfInterpolate(fdn);
                             _mtfInterpolate(mid);
                             _mtfInterpolate(val);
                  }               
            }
            return(i);
         }
   
   //
   //
   //----------------------------------------
   //
   //
   
   static int    prev_i=-1;
   static double prev_max,prev_min;

   //
   //---
   //
   
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double price=getPrice(inpPrice,open,close,high,low,i);
      work[i] = (i>0) ? work[i-1] + _alpha*(price-work[i-1]) : price;
      val[i]  = (i>0) ? val[i-1] + _alpha*(work[i]-val[i-1]) : work[i];
      
      //
      //---
      //
            if (prev_i!=i)
            {
               prev_i = i; 
               int start    = i-inpFlPeriod+1; if (start<0) start=0;
                   prev_max = val[ArrayMaximum(val,start,inpFlPeriod-1)];
                   prev_min = val[ArrayMinimum(val,start,inpFlPeriod-1)];
            }
            double max   = (val[i] > prev_max) ? val[i] : prev_max;
            double min   = (val[i] < prev_min) ? val[i] : prev_min;
            double range = (max-min)/100.0;

                  fup[i] = min+inpFlUp  *range;
                  fdn[i] = min+inpFlDown*range;
                  mid[i] = min+     50.0*range;

            //
            //---
            //
                              
            switch (inpColorOn)
            {
               case chg_onLevel  : valc[i] = (val[i]>fup[i]) ? 1 : (val[i]<fdn[i])  ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1] : 0 : 0; break;
               case chg_onMiddle : valc[i] = (val[i]>mid[i]) ? 1 : (val[i]<mid[i])  ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1] : 0 : 0; break;
               default :           valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
            }                  
   }
   count[rates_total-1]=MathMax(i-prev_calculated+1,1);
   return(i);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
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
   int _shift = (period<0 ? MathAbs(period) : 0); if (period<=0) period=_Period;
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
   int    _partsN = StringSplit(_path,StringGetCharacter("\\",0),_partsA);
   string name=_partsA[_partsN-1]; for(int n=_partsN-2; n>=0 && _partsA[n]!="indicators"; n--) name=_partsA[n]+"\\"+name;
   return(name);
}

//
//---
//  

bool _checkHandle(int _handle, string _description)
{
   static int  _chandles[];
          int  _size   = ArraySize(_chandles);
          bool _answer = (_handle!=INVALID_HANDLE);
          if  (_answer)
               { ArrayResize(_chandles,_size+1); _chandles[_size]=_handle; }
          else { for (int i=_size-1; i>=0; i--) IndicatorRelease(_chandles[i]); ArrayResize(_chandles,0); Alert(_description+" initialization failed"); }
   return(_answer);
} 
 
//
//---
//

double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i)
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
//------------------------------------------------------------------

