//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   6

#property indicator_label1  "High fill"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'220,235,220'
#property indicator_label2  "Low fill"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  C'235,220,220'
#property indicator_label3  "Highest high"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrMediumSeaGreen
#property indicator_label4  "Lowest high"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrMediumSeaGreen
#property indicator_style4  STYLE_DOT
#property indicator_label5  "Lowest low"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrOrangeRed
#property indicator_label6  "Highest low"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrOrangeRed
#property indicator_style6  STYLE_DOT
//
//--- input parameters
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
input enTimeFrames inpTimeFrame     = tf_cu; // Time frame
input int          inpChannelPeriod = 20;     // Period
enum enIterpolate
{
   interolate_yes=(int)true, // Interpolate data when in multi time frame
   interolate_no =(int)false // Do not interpolate data when in multi time frame
};
input enIterpolate inpInterpolate = interolate_yes; // Interpolation

//
//
//--- indicator buffers
//
//

double valuu[],valud[],valdd[],valdu[],filluu[],fillud[],filldd[],filldu[],count[];
int  ª_mtfHandle; 

ENUM_TIMEFRAMES _indicatorTimeFrame; string _indicatorName,_indicatorShortName;
#define _mtfCall iCustom(_Symbol,_indicatorTimeFrame,_indicatorName,0,inpChannelPeriod)

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,filluu,INDICATOR_DATA);
         SetIndexBuffer(1,fillud,INDICATOR_DATA);
         SetIndexBuffer(2,filldu,INDICATOR_DATA);
         SetIndexBuffer(3,filldd,INDICATOR_DATA);
         SetIndexBuffer(4,valuu ,INDICATOR_DATA);
         SetIndexBuffer(5,valud ,INDICATOR_DATA);
         SetIndexBuffer(6,valdd ,INDICATOR_DATA);
         SetIndexBuffer(7,valdu ,INDICATOR_DATA);
         SetIndexBuffer(8,count ,INDICATOR_CALCULATIONS);

         //
         //---
         //
         
         _indicatorTimeFrame  = MathMax(_Period,timeFrameGet(inpTimeFrame)); 
         if (_indicatorTimeFrame != _Period) 
            { 
               _indicatorName = getIndicatorName(); 
               ª_mtfHandle    = _mtfCall; 
                     if (!_checkHandle(ª_mtfHandle,"Target "+timeFrameToString(_indicatorTimeFrame)+" time frame instance")) return(INIT_FAILED); 
            }
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
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
   //
   //---
   //
         if(_indicatorTimeFrame!=_Period)
         {
            double result[1]; if (CopyBuffer(ª_mtfHandle,2,0,1,result)<0) result[0] = rates_total;

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
                  #define _mtfCopy(_buff,_buffNo) { if(CopyBuffer(ª_mtfHandle,_buffNo,_currMark,1,result)<1) break; _buff[i]=result[0]; }
                          _mtfCopy(filluu,0); valuu[i] = filluu[i];
                          _mtfCopy(fillud,1); valud[i] = fillud[i];
                          _mtfCopy(filldu,2); valdu[i] = filldu[i];
                          _mtfCopy(filldd,3); valdd[i] = filldd[i];
               }
               else 
               {
                  #define _mtfCopyValue(_buff) _buff[i] = _buff[i-1]; 
                          _mtfCopyValue(filluu); valuu[i] = filluu[i];
                          _mtfCopyValue(fillud); valud[i] = fillud[i];
                          _mtfCopyValue(filldu); valdu[i] = filldu[i];
                          _mtfCopyValue(filldd); valdd[i] = filldd[i];
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
                             _mtfInterpolate(filluu); valuu[i-k] = filluu[i-k];
                             _mtfInterpolate(fillud); valud[i-k] = fillud[i-k];
                             _mtfInterpolate(filldu); valdu[i-k] = filldu[i-k];
                             _mtfInterpolate(filldd); valdd[i-k] = filldd[i-k];
               }               
            }
            return(i);
         }

   //
   //
   //---
   //
   //
   
   static int    prev_i = -1;
   static double prev_hh,prev_hl,prev_ll,prev_lh;
   
   //
   //
   //
   
   int i = prev_calculated; for (; i<rates_total && !_StopFlag; i++)
   {
      if (prev_i != i)
      {
         int start = i-inpChannelPeriod; if (start<0) start=0;
            prev_hh = high[ArrayMaximum(high,start,inpChannelPeriod)];
            prev_hl = low [ArrayMaximum(low ,start,inpChannelPeriod)];
            prev_ll = low [ArrayMinimum(low ,start,inpChannelPeriod)];
            prev_lh = high[ArrayMinimum(high,start,inpChannelPeriod)];
      }         
      valuu[i]=filluu[i]=prev_hh;
      valud[i]=fillud[i]=prev_hl;
      valdd[i]=filldd[i]=prev_ll;
      valdu[i]=filldu[i]=prev_lh;
   }
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
//------------------------------------------------------------------
