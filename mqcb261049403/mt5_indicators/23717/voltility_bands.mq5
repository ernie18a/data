//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Volatility bands"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_color1  clrDeepSkyBlue
#property indicator_color2  clrSilver
#property indicator_color3  clrOrange
#property indicator_style2  STYLE_DOT

//
//
//

input int                inpPeriod     = 20;          // Period
input int                inpMidPeriod  = 20;          // Midline period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // CCI price
input double             inpDeviations = 2.4;         // bands deviation
input double             inpLowAdjust  = 0.9;         // Low band adjust

//
//
//

double mid[],bandu[],bandd[],tr[],atr[],avg[];
int ª_atrPeriod,ª_avgHandle;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,bandu);
         SetIndexBuffer(1,mid);
         SetIndexBuffer(2,bandd);
         SetIndexBuffer(3,tr    ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(4,atr   ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(5,avg   ,INDICATOR_CALCULATIONS);
            ª_atrPeriod = inpPeriod*2-1;
            ª_avgHandle  = iMA(_Symbol,0,inpMidPeriod,0,MODE_LWMA,inpPrice);     if (!_checkHandle(ª_avgHandle,"Average")) { return(INIT_FAILED); }
            iLwma.init(inpMidPeriod);
   //         
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Volatility bands ("+(string)inpPeriod+","+(string)inpMidPeriod+","+(string)inpDeviations+","+(string)inpLowAdjust+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_priceType,_target,_index) \
   { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _target = close[_index];                                              break; \
      case PRICE_OPEN:     _target = open[_index];                                               break; \
      case PRICE_HIGH:     _target = high[_index];                                               break; \
      case PRICE_LOW:      _target = low[_index];                                                break; \
      case PRICE_MEDIAN:   _target = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _target = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _target = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _target = 0; \
   }}
   
//
//---
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
   int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
         if (CopyBuffer(ª_avgHandle,0,0,_copyCount,avg)!=_copyCount) return(prev_calculated);
   
   //
   //---
   //
  
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      if (i>0)
      {
         tr[i]  = (high[i]>close[i-1] ? high[i] : close[i-1]) - (low[i]<close[i-1] ? low[i] : close[i-1]);
         if (i>ª_atrPeriod)
                atr[i] = atr[i-1]+tr[i]-tr[i-ª_atrPeriod];
         else { atr[i] = tr[i]; for (int k=1; k<ª_atrPeriod && i>=k; k++) atr[i] += tr[i-k]; }
      }
      else tr[i] = atr[i] = high[i]-low[i];
      
      //
      //
      //

      double _price; _setPrice(inpPrice,_price,i);  
         if (avg[i]==EMPTY_VALUE) mid[i] = _price;
         double _atr = inpDeviations*atr[i]/(double)ª_atrPeriod; 

                bandu[i] = avg[i] + avg[i]*(_atr/_price);
                bandd[i] = avg[i] - avg[i]*(_atr*inpLowAdjust/_price);
                mid[i]  = iLwma.calculate((high[i]+low[i])/2.0,i) ;
   }
   return (i);
}
  
//------------------------------------------------------------------
//    custom functions
//------------------------------------------------------------------
//
//---
//

class CLwma
{
   #define _ringSize 32 
   private :
      struct sLwmaArrayStruct
         {
            double value;
            double wsumm;
            double vsumm;
         };
      sLwmaArrayStruct m_array[];
      int              m_arraySize;
      int              m_period;
      double           m_weight;
   public :
      CLwma() { init(1);            return; }
     ~CLwma() { ArrayFree(m_array); return; }
     
     //
     //---
     //

     void init(int period)
         { 
            m_period    = (period>1) ? period : 1; 
            m_arraySize = m_period+_ringSize;
            m_weight    = 1;
               ArrayResize(m_array,m_arraySize);
               for (int k=0; k<m_arraySize; k++)
               {
                  m_array[k].value  = 
                  m_array[k].wsumm  = 
                  m_array[k].vsumm  = 0;
               }
         }
         
     double calculate(double value, int i)
         {
            int _indC = (i)%m_arraySize; m_array[_indC].value=value;
               if (i>m_period)
               {
                  int _indP = _indC-1; if (_indP<0) _indP += m_arraySize;
                  int _indB = (i-m_period)%m_arraySize;
                     m_array[_indC].wsumm  = m_array[_indP].wsumm+value*m_period-m_array[_indP].vsumm;
                     m_array[_indC].vsumm  = m_array[_indP].vsumm+value         -m_array[_indB].value;
               }
               else
               {
                     m_weight              = 0;
                     m_array[_indC].wsumm  = 0;
                     m_array[_indC].vsumm  = 0;
                     for(int k=0, w=m_period, _indR=_indC; k<m_period && i>=k; k++,w--,_indR--)
                     {
                        if (_indR<0) _indR += m_arraySize;
                           m_weight             += w;
                           m_array[_indC].wsumm += m_array[_indR].value*(double)w;
                           m_array[_indC].vsumm += m_array[_indR].value;
                     }
               }
               return(m_array[_indC].wsumm/m_weight);
      }   
   #undef _ringSize
};
CLwma iLwma;

//
//---
//

bool _checkHandle(int _handle, string _description)
{
   static int  _handles[];
          int  _size   = ArraySize(_handles);
          bool _answer = (_handle!=INVALID_HANDLE);
          if  (_answer)
               { ArrayResize(_handles,_size+1); _handles[_size]=_handle; }
          else { for (int i=_size-1; i>=0; i--) IndicatorRelease(_handles[i]); ArrayResize(_handles,0); Alert(_description+" initialization failed"); }
   return(_answer);
}    
  
//+------------------------------------------------------------------+
