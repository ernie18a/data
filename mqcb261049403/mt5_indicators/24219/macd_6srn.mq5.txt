//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "MACD with support and resistance levels "
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_label1  "MACD"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width1  2
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT

//
//
//

enum enColorOn
{
   col_onSlope,   // Change color on macd slope change
   col_onZero,    // Change color on zero cross
   col_onSignal   // Change color on signal line cross
};

input int                inpPeriodFast    =  12;              // Fast MACD period
input int                inpPeriodSlow    =  26;              // Slow MACD period
input int                inpPeriodSign    =   9;              // Signal period
input ENUM_APPLIED_PRICE inpPrice         = PRICE_CLOSE;      // Price 
input enColorOn          inpColorOn       = col_onSignal;     // Color change mode
input string             inpUniqueID      = "MacdLevels1";    // Unique ID for on chart objects
input color              inpColorUp       = clrDeepSkyBlue;   // Color for upper level broken line
input color              inpColorDown     = clrLightSalmon;   // Color for lower level broken line
input int                inpLinesWidth    = 2;                // Lines width
input ENUM_LINE_STYLE    inpLinesStyle    = STYLE_SOLID;      // Lines style

//
//
//

double val[],valc[],vals[]; 
int ª_indHandle;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,val ,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,vals,INDICATOR_DATA);
            ª_indHandle = iMACD(_Symbol,0,inpPeriodFast,inpPeriodSlow,inpPeriodSign,inpPrice); if (!_checkHandle(ª_indHandle,"MACD")) { return(INIT_FAILED); }
            _srHandler.setUniqueID(inpUniqueID);
            _srHandler.setLinesStyle(inpLinesStyle);
            _srHandler.setLinesWidth(inpLinesWidth);
            _srHandler.setSupportColor(inpColorDown);
            _srHandler.setResistanceColor(inpColorUp);
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"MACD with SR levels ("+(string)inpPeriodFast+","+(string)inpPeriodSlow+","+(string)inpPeriodSign+")");
   return (INIT_SUCCEEDED);
}

//
//---
//

void OnDeinit(const int reason)
{
}

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------

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
         if (CopyBuffer(ª_indHandle,0,0,_copyCount,val )!=_copyCount) return(prev_calculated);
         if (CopyBuffer(ª_indHandle,1,0,_copyCount,vals)!=_copyCount) return(prev_calculated);
   
   //
   //---
   //
  
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      switch (inpColorOn)
      {
         case col_onZero   : valc[i] = (val[i]>0) ? 1 :(val[i]<0) ? 2 : 0; break;
         case col_onSlope  : valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0; break;
         case col_onSignal : valc[i] = (val[i]>vals[i]) ? 1 :(val[i]<vals[i]) ? 2 : 0; break;
      }         
      _srHandler.update(close[i],time[i],valc[i],i,rates_total);
   }         
   return (i);
}
  
//------------------------------------------------------------------
//    Custom function(s)
//------------------------------------------------------------------
//
//---
//

class COnChartSR
{
   private :
      string m_uniqueID;
      color  m_colorSup;
      color  m_colorRes;
      int    m_linesWidth;
      int    m_linesStyle;
      int    m_arraySize;
      struct sOnChartSRStruct
      {
         datetime time;
         double   state;
      };
      sOnChartSRStruct m_array[];
         
   public :
      COnChartSR() : m_colorSup(clrOrangeRed), m_colorRes(clrMediumSeaGreen), m_linesWidth(1), m_linesStyle(STYLE_SOLID), m_arraySize(-1) { return; }
     ~COnChartSR() { ObjectsDeleteAll(0,m_uniqueID+":"); ChartRedraw(0); return; }
     
      //
      //
      //
      
      void setUniqueID(string _id)          { m_uniqueID = _id; return; }
      void setSupportColor(color _color)    { m_colorSup = _color; return; }
      void setResistanceColor(color _color) { m_colorRes = _color; return; }
      void setLinesWidth(int _width)        { m_linesWidth = _width; return; }
      void setLinesStyle(int _style)        { m_linesStyle = _style; return; }
      void update(double price, datetime time, double state, int i, int bars)
      {
         if (m_arraySize<bars)
         {
            m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return;
         }
         
         //
         //
         //
         
         m_array[i].state = state;
         if (state==0)
         {
            m_array[i].time = time;
               string _name = m_uniqueID+":"+(string)m_array[i].time;
                  if (ObjectFind(0,_name)>=0) ObjectDelete(0,_name);               
         }
         else
            if (i>0)
            {
               if (m_array[i].state!=m_array[i-1].state)
               {
                  m_array[i].time = time;
                     string _name = m_uniqueID+":"+(string)time;
                     ObjectCreate(0,_name,OBJ_TREND,0,0,0);
                        ObjectSetInteger(0,_name,OBJPROP_WIDTH,m_linesWidth);
                        ObjectSetInteger(0,_name,OBJPROP_STYLE,m_linesStyle);
                        ObjectSetInteger(0,_name,OBJPROP_COLOR,(state==1 ? m_colorRes : m_colorSup));
                        ObjectSetInteger(0,_name,OBJPROP_HIDDEN,true);
                        ObjectSetInteger(0,_name,OBJPROP_BACK,true);
                        ObjectSetInteger(0,_name,OBJPROP_SELECTABLE,false);
                        ObjectSetInteger(0,_name,OBJPROP_RAY,false);
                        ObjectSetInteger(0,_name,OBJPROP_TIME,0,time);
                        ObjectSetInteger(0,_name,OBJPROP_TIME,1,time+PeriodSeconds(_Period));
                           ObjectSetDouble(0,_name,OBJPROP_PRICE,0,price);
                           ObjectSetDouble(0,_name,OBJPROP_PRICE,1,price);
               }                  
               else  
               {
                  m_array[i].time = m_array[i-1].time;
                     string _name = m_uniqueID+":"+(string)m_array[i].time;
                           ObjectSetInteger(0,_name,OBJPROP_TIME,1,time+PeriodSeconds(_Period));
               }
            }
            else m_array[i].time = time;
      }
};
COnChartSR _srHandler;

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
//------------------------------------------------------------------
