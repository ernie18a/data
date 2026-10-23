//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "RSI of Super trend - simple"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   1
#property indicator_label1  "RSI of Super trend"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//--- input parameters
//

enum enUseWhat
{
   use_atr, // Use ATR for calculation
   use_dev  // Use standard deviation for calculation 
};
input int                inpPeriodRsi    = 14;            // RSI period
input int                inpPeriod       = 14;            // Super trend period
input ENUM_APPLIED_PRICE inpPrice        = PRICE_TYPICAL; // Price
input int                inpAtrDevPeriod = 5;             // Atr / standard deviation period
input enUseWhat          inpUseWhat      = use_atr;       // Calculation method 

//
//--- indicator buffers
//

double val[],valc[],trend[],ade[],ma[],prices[],st[];
int  ª_adHandle,ª_maHandle,ª_prHandle;

//------------------------------------------------------------------ 
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
   
         SetIndexBuffer(0,val   ,INDICATOR_DATA);
         SetIndexBuffer(1,valc  ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,trend ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(3,ade   ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(4,ma    ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(5,prices,INDICATOR_CALCULATIONS);
         SetIndexBuffer(6,st    ,INDICATOR_CALCULATIONS);
   //            
   //--- external indicator(s) loading
   //
   
         if (inpUseWhat==use_atr)
               { ª_adHandle=iATR(_Symbol,0,inpAtrDevPeriod);                        if (!_checkHandle(ª_adHandle,"ATR"))                return(INIT_FAILED); }
         else  { ª_adHandle=iStdDev(_Symbol,0,inpAtrDevPeriod,0,MODE_SMA,inpPrice); if (!_checkHandle(ª_adHandle,"Standard deviation")) return(INIT_FAILED); }
                 ª_maHandle =iMA(_Symbol,0,inpPeriod,0,MODE_SMA,inpPrice);  if (!_checkHandle(ª_maHandle ,"Average")) return(INIT_FAILED);
                 ª_prHandle =iMA(_Symbol,0,1        ,0,MODE_SMA,inpPrice);  if (!_checkHandle(ª_prHandle ,"Prices"))  return(INIT_FAILED);

         iRsi.init(inpPeriodRsi);
   //
   //--- indicator short name assignment
   //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"RSI ("+(string)inpPeriodRsi+") of super trend ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
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
         if (CopyBuffer(ª_adHandle,0,0,_copyCount,ade   )!=_copyCount) return(prev_calculated);
         if (CopyBuffer(ª_maHandle,0,0,_copyCount,ma    )!=_copyCount) return(prev_calculated);
         if (CopyBuffer(ª_prHandle,0,0,_copyCount,prices)!=_copyCount) return(prev_calculated);

   //
   //---
   //
   
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      trend[i] = (prices[i]>ma[i]) ? 1 : (prices[i]<ma[i]) ? -1 : (i>0) ? trend[i-1] : 0;
      st[i]    = (i>0) ? (trend[i]==1) ? MathMax(low[i]-ade[i],st[i-1]) : MathMin(high[i]+ade[i],st[i-1]) : close[i];
         val[i]  = iRsi.calculate(st[i],i);
         valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
class cRsi
{
   private :
      int    m_period;
      int    m_arraySize;
      double m_alpha;
      struct sRsiArray
      {
         double price;
         double change1;
         double changa1;
         double change;
         double changa;
      };
      sRsiArray m_work[];
   public :
      cRsi() : m_period(1), m_alpha(1), m_arraySize(33) { ArrayResize(m_work,33); return; }
     ~cRsi()                                            { ArrayFree(m_work);      return; }
     
      //
      //---
      //
      
      void init(int period)
      {
         m_period    = (period>1) ? period : 1;
         m_arraySize = m_period+32;
         m_alpha     = 1.0/MathSqrt(m_period);
            ArrayResize(m_work,m_arraySize);
      }
      
      double calculate(double price, int i)
      {
         int _indC = (i)%m_arraySize; m_work[_indC].price=price;
         
         //
         //---
         //
         
         if(i>m_period)
         {
            int _indP = (_indC-1); if (_indP<0) _indP += m_arraySize;
               double change = m_work[_indC].price-m_work[_indP].price;
               double changa = change; if (change<0) changa = -change;
                      m_work[_indC].change1 =  m_work[_indP].change1 + m_alpha*(change                - m_work[_indP].change1);
                      m_work[_indC].change  =  m_work[_indP].change  + m_alpha*(m_work[_indC].change1 - m_work[_indP].change );
                      m_work[_indC].changa1 =  m_work[_indP].changa1 + m_alpha*(changa                - m_work[_indP].changa1);
                      m_work[_indC].changa  =  m_work[_indP].changa  + m_alpha*(m_work[_indC].changa1 - m_work[_indP].changa );
         }
         else
         {
            m_work[_indC].changa = 0;
               for(int k=0; i>k; k++) 
               m_work[_indC].changa += m_work[_indC-k].price>m_work[_indC-k-1].price ? m_work[_indC-k].price-m_work[_indC-k-1].price : m_work[_indC-k-1].price-m_work[_indC-k].price; 
               m_work[_indC].changa /=                                       (i+1.0); m_work[_indC].changa1 = m_work[_indC].changa;
               m_work[_indC].change  = (m_work[_indC].price-m_work[0].price)/(i+1.0); m_work[_indC].change1 = m_work[_indC].change;
         }
         if (m_work[_indC].changa!=0)
               return(50.0*(m_work[_indC].change/m_work[_indC].changa+1.0));
         else  return(0);   
      }
};
cRsi iRsi;

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
//+------------------------------------------------------------------+
