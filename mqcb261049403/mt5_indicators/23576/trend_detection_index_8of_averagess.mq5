//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Trend detection index of average"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_label1  "Filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrDeepSkyBlue,clrSandyBrown
#property indicator_label2  "Trend detection index level up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDeepSkyBlue
#property indicator_width2  0
#property indicator_label3  "Trend detection index level down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSandyBrown
#property indicator_width3  0

//
//---
//

input int                inpPeriod     = 15;            // Period
input int                inpAvgPeriod  = 5;             // Pre-smoothing period
input ENUM_MA_METHOD     inpAvgMethod  = MODE_LWMA;     // Pre-smoothing method
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE;   // Price

double valu[],vald[],fup[],fdn[],avg[]; 
string ª_maNames[] = {"SMA","EMA","SMMA","LWMA"};
int    ª_avgHandle,ª_maPeriod,ª_periodx2;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //---
   //
         SetIndexBuffer(0,fup ,INDICATOR_DATA);     
         SetIndexBuffer(1,fdn ,INDICATOR_DATA);
         SetIndexBuffer(2,valu,INDICATOR_DATA); 
         SetIndexBuffer(3,vald,INDICATOR_DATA); 
         SetIndexBuffer(4,avg ,INDICATOR_CALCULATIONS);
         
         ª_maPeriod  = (inpAvgPeriod>1) ? inpAvgPeriod : 1;
         ª_avgHandle = iMA(_Symbol,0,ª_maPeriod ,0,inpAvgMethod,inpPrice); if (!_checkHandle(ª_avgHandle,ª_maNames[inpAvgMethod])) return(INIT_FAILED);
         ª_periodx2  = inpPeriod*2;
         
   //
   //---
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend detection index "+ª_maNames[inpAvgMethod]+" ("+(string)inpPeriod+","+(string)ª_maPeriod+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------ 
//
//
//

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
   int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
         if (CopyBuffer(ª_avgHandle,0,0,_copyCount,avg)!=_copyCount) return(prev_calculated);
         
         //
         //---
         //
         
         struct sTdiStruct
         {
            double mom;
            double abs;
            double sum_mom;
            double sum_abs;
            double sum_abs2;
         };
         static sTdiStruct m_array[];
         static int        m_arraySize=-1;
                       if (m_arraySize<rates_total) {  m_arraySize = ArrayResize(m_array,rates_total+500); if (m_arraySize<rates_total) return(0); }
         
   ///
   ///
   ///
   
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      if (avg[i]==EMPTY_VALUE) avg[i]=close[i];

      //
      //
      //
            
      int prev_i = i-inpPeriod; if (prev_i<0) prev_i = 0;
      
         //
         //
         //
         
         m_array[i].mom = avg[i]-avg[prev_i];
         m_array[i].abs = (m_array[i].mom>0) ? m_array[i].mom : -m_array[i].mom;
            
            if (i>ª_periodx2)
            {
                  m_array[i].sum_mom  = m_array[i-1].sum_mom +m_array[i].mom-m_array[i- inpPeriod].mom;
                  m_array[i].sum_abs  = m_array[i-1].sum_abs +m_array[i].abs-m_array[i- inpPeriod].abs;
                  m_array[i].sum_abs2 = m_array[i-1].sum_abs2+m_array[i].abs-m_array[i-ª_periodx2].abs;
            }
            else
            {
                  m_array[i].sum_mom = m_array[i].mom;
                  m_array[i].sum_abs = m_array[i].sum_abs2 = m_array[i].abs;
                  for (int k=1; k<ª_periodx2 && i>=k; k++) 
                  {
                     m_array[i].sum_abs2 += m_array[i-k].abs;
                     if (k<inpPeriod)
                     {
                        m_array[i].sum_mom += m_array[i-k].mom;
                        m_array[i].sum_abs += m_array[i-k].abs;
                     }              
                  }                         
            }

         //
         //
         //
      
         valu[i] = fup[i] =         m_array[i].sum_mom;
         vald[i] = fdn[i] = MathAbs(m_array[i].sum_mom)+m_array[i].sum_abs-m_array[i].sum_abs2;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
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

