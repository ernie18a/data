//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Ssm RSI"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//---
//

input int                inpPeriod    = 10;           // Period
input ENUM_APPLIED_PRICE inpPrice     = PRICE_CLOSE;  // Price

double val[],valc[];

//------------------------------------------------------------------ 
//  Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //---- indicator buffers mapping
   //
         SetIndexBuffer(0,val ,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
            iSsmRsi.init(inpPeriod);
   //            
   //----
   //

   IndicatorSetString(INDICATOR_SHORTNAME,"Ssm RSI ("+(string)inpPeriod+")");
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
//  Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_priceType,_where,_index) { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _where = close[_index];                                              break; \
      case PRICE_OPEN:     _where = open[_index];                                               break; \
      case PRICE_HIGH:     _where = high[_index];                                               break; \
      case PRICE_LOW:      _where = low[_index];                                                break; \
      case PRICE_MEDIAN:   _where = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _where = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _where = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _where = 0; \
   }}

//
//---
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
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      val[i]  = iSsmRsi.caculate(_price,i);
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
   }
   return(i);
}

//------------------------------------------------------------------
//  Custom function(s)
//------------------------------------------------------------------
//
//---
//

class CSsmRsi
{
   private :
      int    m_period;
      double m_coeff1;
      double m_coeff2;
      double m_coeff3;
      int    m_arraySize;
         struct sSsmRsiArrayStruct
         {
            double value;
            double diffp;
            double diffn;
            double sump;
            double sumn;
            double sumps;
            double sumns;
         };
      sSsmRsiArrayStruct m_array[];         

   public :
      CSsmRsi() {};
     ~CSsmRsi() { ArrayFree(m_array); };
     
      ///
      ///
      ///
     
      bool init(int period)
      {
           m_period = (period>1) ? period : 1;
           double a = MathExp(-1.414*M_PI/m_period);
               m_coeff2 = 2*a*MathCos(1.414*M_PI/m_period);
               m_coeff3 = -a*a;
               m_coeff1 = 1-m_coeff2-m_coeff3;      

            //
            //
            //
                              
            m_arraySize = m_period+32;
            if (ArrayResize(m_array,m_arraySize)!=m_arraySize) return(false);
                                                               return(true); 
      }

      double caculate(double value, int i)
      {
         int _indC = (i)%m_arraySize; m_array[_indC].value=value;
         int _indP = _indC-1; if (_indP<0) _indP += m_arraySize;
                          
         //
         //
         //
         
         if (i>m_period)
            {
               int _indF = (i-m_period)%m_arraySize; 
                  if (m_array[_indC].value > m_array[_indP].value)
                                 { m_array[_indC].diffp = m_array[_indC].value - m_array[_indP].value; m_array[_indC].diffn = 0; }
                           else  { m_array[_indC].diffn = m_array[_indP].value - m_array[_indC].value; m_array[_indC].diffp = 0; }
                  m_array[_indC].sump = m_array[_indP].sump + m_array[_indC].diffp - m_array[_indF].diffp;
                  m_array[_indC].sumn = m_array[_indP].sumn + m_array[_indC].diffn - m_array[_indF].diffn;
            }
         else
            {
               m_array[_indC].diffp = (i>0) ? (m_array[_indC].value>m_array[_indP].value) ? m_array[_indC].value - m_array[_indP].value : 0 : 0;
               m_array[_indC].diffn = (i>0) ? (m_array[_indC].value<m_array[_indP].value) ? m_array[_indP].value - m_array[_indC].value : 0 : 0;
               m_array[_indC].sump  = m_array[_indC].diffp;
               m_array[_indC].sumn  = m_array[_indC].diffn;
                  for (int k=1, _indF=_indP; k<m_period && i>=k; k++, _indF--)
                  {
                     m_array[_indC].sump += m_array[_indF].diffp;
                     m_array[_indC].sumn += m_array[_indF].diffn;
                  }
            }

            //
            //
            //
         
            if (i>1) 
            {
               m_array[_indC].sumps = m_coeff1*(m_array[_indC].sump+m_array[_indP].sump)/2.0 + m_coeff2*m_array[_indP].sumps + m_coeff3*m_array[(i-2)%m_arraySize].sumps;
               m_array[_indC].sumns = m_coeff1*(m_array[_indC].sumn+m_array[_indP].sumn)/2.0 + m_coeff2*m_array[_indP].sumns + m_coeff3*m_array[(i-2)%m_arraySize].sumns;
            }               
            else
            {
               m_array[_indC].sumps = m_array[_indC].sump;
               m_array[_indC].sumns = m_array[_indC].sumn;
            }               
            return((m_array[_indC].sumns!=0) ? 100.0-(100.0/(1.0+m_array[_indC].sumps/m_array[_indC].sumns)) : 0);
      }
};
CSsmRsi iSsmRsi;
//------------------------------------------------------------------