//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Smoothed WPR with floating levels and on chart SR levels"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   4
#property indicator_label1  "Upper level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Middle level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Lower level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_DOT
#property indicator_label4  "WPR"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width4  2

//
//---
//
enum enColorChangeOn
{
   cchange_onSlope,  // Change color on slope change
   cchange_onLevels, // Change color on levels crossing
   cchange_onZero    // Change color on zero crossing
};
input int                inpPeriod       = 14;               // Period
input int                inpSmoothPeriod =  0;               // Smoothing period (< 1 for same as WPR period)
input int                inpFlPeriod     = 25;               // Floating levels period
input double             inpFlLevelUp    = 90;               // Floating levels up %
input double             inpFlLevelDn    = 10;               // Floating levels down %
input enColorChangeOn    inpColorChange  = cchange_onLevels; // Color change type
input string             inpUniqueID     = "WPRLevels1";     // Unique ID for on chart objects
input color              inpColorUp      = clrMediumSeaGreen;// Color for upper level broken line
input color              inpColorDown    = clrOrangeRed;     // Color for lower level broken line
input int                inpLinesWidth   = 2;                // Lines width
input ENUM_LINE_STYLE    inpLinesStyle   = STYLE_SOLID;      // Lines style

double val[],valc[],levu[],levd[],levm[],smth[],smtl[],smtc[],_alpha;

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
         SetIndexBuffer(0,levu,INDICATOR_DATA);
         SetIndexBuffer(1,levm,INDICATOR_DATA);
         SetIndexBuffer(2,levd,INDICATOR_DATA);
         SetIndexBuffer(3,val ,INDICATOR_DATA);
         SetIndexBuffer(4,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(5,smth,INDICATOR_CALCULATIONS);
         SetIndexBuffer(6,smtl,INDICATOR_CALCULATIONS);
         SetIndexBuffer(7,smtc,INDICATOR_CALCULATIONS);
            _alpha = 2.0 / (1.0 + (inpSmoothPeriod>0 ? inpSmoothPeriod : inpPeriod));
            _srHandler.setUniqueID(inpUniqueID);
            _srHandler.setLinesStyle(inpLinesStyle);
            _srHandler.setLinesWidth(inpLinesWidth);
            _srHandler.setSupportColor(inpColorDown);
            _srHandler.setResistanceColor(inpColorUp);
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"WPR ("+(string)inpPeriod+","+(string)inpSmoothPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
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
   static int    prev_i=-1;
   static double prev_max,prev_min;
   static double prev_maxv,prev_minv;

   //
   //---
   //
   
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      if (i>0)
      {
         smth[i] = smth[i-1]+_alpha*(high[i] -smth[i-1]);
         smtl[i] = smtl[i-1]+_alpha*(low[i]  -smtl[i-1]);
         smtc[i] = smtc[i-1]+_alpha*(close[i]-smtc[i-1]);
      }  
      else { smth[i] = high[i]; smtl[i] = low[i];  smtc[i] = close[i]; }
      if (prev_i!=i)
      {
         int start    = i-inpPeriod+1; if (start<0) start=0;
             prev_max = smth[ArrayMaximum(smth,start,inpPeriod-1)];
             prev_min = smtl[ArrayMinimum(smtl,start,inpPeriod-1)];
      }
      double max = (smth[i] > prev_max) ? smth[i] : prev_max;
      double min = (smtl[i] < prev_min) ? smtl[i] : prev_min;
         
      //
      //---
      //
         
      val[i] = (max!=min) ? -(max-smtc[i])*100.0/(max-min) : 0;
      if (prev_i!=i)
      {
         prev_i = i; 
         int start     = i-inpPeriod+1; if (start<0) start=0;
             prev_maxv = val[ArrayMaximum(val,start,inpPeriod-1)];
             prev_minv = val[ArrayMinimum(val,start,inpPeriod-1)];
      }
             max = (val[i] > prev_maxv) ? val[i] : prev_maxv;
             min = (val[i] < prev_minv) ? val[i] : prev_minv;
      double range = (max-min)/100.0;
      levu[i] = min+inpFlLevelUp*range;
      levd[i] = min+inpFlLevelDn*range;
      levm[i] = min+50.0        *range;
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0; 
      
      //
      //---
      //
      
         switch (inpColorChange)
         {
            case cchange_onLevels : valc[i] = (val[i]>levu[i]) ? 1 :(val[i]<levd[i]) ? 2 : 0; break;
            case cchange_onSlope  : valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0; break;
            case cchange_onZero   : valc[i] = (val[i]>levm[i]) ? 1 :(val[i]<levm[i]) ? 2 : 0; break;
         }         
         _srHandler.update(close[i],time[i],valc[i],i,rates_total);
   }
   return(i);
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
