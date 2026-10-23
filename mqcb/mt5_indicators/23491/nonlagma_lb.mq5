//+------------------------------------------------------------------+
//| Derived from                                   NonLagMA_v7.1.mq4 |
//|                                Copyright © 2007, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright   "Copyright © 2018-2019, MetaQuotes Software Corp."
#property link        "https://www.mql5.com/en/users/lukeb"
#property description  "Author: https://www.mql5.com/en/users/lukeb"
#property description "A Re-Coded NonLagMA including ATR Bands and Information Panel"
string indicator_name = "lukeB_NonLagMA";
#property version     "1.01";  // 1.01 adds ChartRedraw to make the events handle properly
#property strict
// #include <errordescription.mqh>  // errordescription.mqh is found at: https://www.mql5.com/en/code/79 
//
enum EnumOnOffSwitch {OFF, ON};
//---- input parameters
input ENUM_APPLIED_PRICE MAPrice        = PRICE_CLOSE;
input int                MAPeriod       = 30;           //Period of NonLagMA
input int                Displace       = 0;            //shift of display 
input double             PctFilter      = 0.0;          //Dynamic filter in decimal
input double             Deviation      = 0.0;          //Up/down deviation        
input EnumOnOffSwitch    AlertMode      = OFF;          //Sound Alert switch (0-off,1-on) 
input double             AtrMultiplier  = 2.0;          // Must be > 0 to enable ATR Bands, try 2.0
input int                AtrPeriod      = 14;
input long               Uniquifier     = 972;         // Number to make objects unique
//====== Global Variables to hold programatically altered input values ========
ENUM_APPLIED_PRICE g_MA_price; EnumOnOffSwitch g_alert_mode; 
int g_MA_period, g_displace, g_atr_period;
double g_pct_filter, g_deviation, g_atr_multiplier;
//--- handles for obtaining terminal data (moving average, atr) ------
int    MA_handle  = NULL;
int    ATR_handle = NULL;
// --- Other indicator global worker variables
enum      TrendDirEnum { k_no_trend, k_up_trend, k_dn_trend };
int       g_min_bars;
string    comment_string = "";
const int k_no_shift=0, k_chart_window=0, k_no_property_modifier = 0;
datetime  g_stats_time = NULL;
EnumOnOffSwitch g_run_onoff = ON;
//+------------------------------------------------------------------+
//| Define Indicator Data and Buffers                                |
//+------------------------------------------------------------------+
//=== Define the Indicator buffers; The index enum will allow human readable access throughout the program to the arrays ====
enum IndicatorBufferIdx                   { k_ATR_up_idx,   k_ATR_dn_idx,   k_MA_indi_idx,   k_MA_clr_idx,          k_ATR_vals_idx,         k_IMA_val_idx,          k_del_indi_idx,         k_avg_del_buffer,       k_end_indi_idx};
ENUM_INDEXBUFFER_TYPE indi_bufferType[] = { INDICATOR_DATA, INDICATOR_DATA, INDICATOR_DATA,  INDICATOR_COLOR_INDEX, INDICATOR_CALCULATIONS, INDICATOR_CALCULATIONS, INDICATOR_CALCULATIONS, INDICATOR_CALCULATIONS   };
string                 indi_text_name[] = { "ATR_UP",       "ATR_DN",       "NonLagMA",      "MA_Clrs",             "ATR_Values",           "IMA_BUFFER",           "DELETE_BUFFER",        "AVG_DEL_BUFFER"         };
ENUM_DRAW_TYPE         indi_draw_type[] = { DRAW_LINE,      DRAW_LINE,      DRAW_COLOR_LINE, DRAW_NONE,             DRAW_NONE,              DRAW_NONE,              DRAW_NONE,              DRAW_NONE                };
int                   indi_line_width[] = {  1,              1,              3,               1,                     1,                      1,                      1,                      1                       };
ENUM_LINE_STYLE       indi_draw_style[] = { STYLE_DOT,      STYLE_DOT,      STYLE_SOLID,     STYLE_SOLID,           STYLE_SOLID,            STYLE_SOLID,            STYLE_SOLID,            STYLE_SOLID              };
//
#property indicator_chart_window
#property indicator_buffers k_end_indi_idx
#property indicator_plots   3
//====== Set Colors ===========
enum EnumPlotClrs         { k_long_clr, k_short_clr };  // Human readable index values for the nonLagMA colors
#property indicator_color3  clrBlue,    clrYellow   // nonLagMA colors
#property indicator_color1  clrOrangeRed // top ATR band color
#property indicator_color2  clrViolet    // bottom ATR band color
//#property indicator_color3  clrCornsilk
//---- Make Global Arrays for the Indicator Lines -----------
struct IndiStruct
 {
   double m_indi_buff[];
 } indi_array[k_end_indi_idx];  // create an indicator buffer for the number of defined indicator buffers
//+------------------------------------------------------------------+
//| Non Lag MA Constants Class and use utilities                     |
//+------------------------------------------------------------------+
class AlfaClass  // This could be defined as a singleton class
 {
   private:
      // Class worker variables
      int    m_phase, m_cycle, m_len;
      double m_coeff, m_beta, m_t, m_g, m_weight, m_alfa[];
      //
      void InitializeAlfaArray(void){  // Load the alfa coefficients array and store the weight.
         for (int i=0;i<m_len-1;i++){ // m_len == 30*4+29 == 149 
            if (i<=m_phase-1)
               m_t = 1.0*i/(m_phase-1);
            else
               m_t = 1.0 + (i-m_phase+1)*(2.0*m_cycle-1.0)/(m_cycle*m_phase);
            //
            m_beta = MathCos(M_PI*m_t);
            m_g = 1.0/(m_coeff*m_t+1);   
            if (m_t <= 0.5 )
               m_g = 1;
            m_alfa[i] = m_g * m_beta;
            m_weight += m_alfa[i];
          }
       } // ====== End InitializeAlfaArray ==========
   protected:
      double GetThePriceSum(const int& work_bar, const double& ima_buffer[], const ENUM_APPLIED_PRICE& applied_price){
         double price, sum=0;
         for ( int i=0; i<=ArrayRange(m_alfa,0)-1; i++ ){  // range is the same as m_len which is 30*4+29 == 149 
            price = ima_buffer[i+work_bar];      
            sum += m_alfa[i]*price;
          }
         return(sum);
       } //------ End GetThePriceSum -----------
      double GetStdDev( const int& work_bar, const int& avrg_period, const double& del_buffer[], const double& avg_del_buffer[] ){
         double sumpow = 0;
         for (int i=0;i<avrg_period;i++){
            sumpow+=MathPow(del_buffer[work_bar+i]-avg_del_buffer[work_bar+i],2);
          }
         return MathSqrt(sumpow/avrg_period);
       } //------ End GetStdDev -----------
   public:
      void AlfaClass(const int& maPeriod){  // consructor
         m_coeff  = 3*M_PI;  // M_PI is pi, 3.14...
         m_cycle  = 4;
         m_phase  = maPeriod-1;
         m_len    = (maPeriod*m_cycle)+m_phase; // m_len == (30*4)+29 == 149 
         m_weight = 0;
         if(ArrayResize(m_alfa,m_len)!=m_len){  // if this were too fail, all would end
            int err_code = GetLastError(); comment_string=__FUNCTION__+":  alfa Array Resize failed, error: "+IntegerToString(err_code); // +", "+ErrorDescription(err_code);
            Comment(comment_string); Print(comment_string);
          }
         InitializeAlfaArray();
       } //===== End AlfaClass consructor =====
      double GetTheBarMAValue(const int& work_bar, const double& ima_buffer[], const int& vertical_shift, const ENUM_APPLIED_PRICE& applied_price ){
         double sum = GetThePriceSum(work_bar, ima_buffer, applied_price);  // Sum is the sum of the each value in the alfa array times the shift bar plus the alfa index iMA
      	return (1.0+(vertical_shift/100))*(sum/m_weight);  // vertical_shift default is zero, so reurn is sum/weight
       } // ====== END GetTheBarMAValue =====
      double GetDelBufferValue(const int& work_bar, const double& ma_buffer[]){
         return MathAbs(ma_buffer[work_bar] - ma_buffer[work_bar+1]);
       } // ====== END GetDelBufferValue =====
      double GetAvrgDelBuffferValue( const int& work_bar,  const double& del_buffer[], const int& avrg_period){
         double delete_buff_sum=0;
         for (int i=0; i<avrg_period; i++){
            delete_buff_sum += del_buffer[work_bar+i];
          }
         return (delete_buff_sum/avrg_period);
       } // ====== GetAvrgDelBuffferValue =====
      double GetTheColorSwitchLevel( const int& work_bar, const double& pct_filter, const int avrg_period, const double& del_buffer[], const double& avg_del_buffer[] ){
         double color_switch_level=0, standard_deviation;
         if (pct_filter>0){  // default pct_filter is zero
            standard_deviation = GetStdDev( work_bar, avrg_period, del_buffer, avg_del_buffer );
            color_switch_level = pct_filter*standard_deviation;
          }
         return color_switch_level;  // return values with indicator defaults is zero
       } // ====== GetTheColorSwitchLevel =====
      //Provide some class value getters
      int GetAlfaArraySize(void){return ArrayRange(m_alfa,0);}
      double GetWeight(void){return(m_weight);}
      double GetAlfa( const int& idx ){return(m_alfa[idx]);}
 } *alfa_class_ptr = NULL; // ==== End AlfaClass definition ====   
//
//======= Signal Dashboard Display ================
enum  DispObjIdx { k_info_hdr_idx,  k_MA_prmpt_idx,  k_MA_val_idx,  k_top_prmpt_idx,  k_top_val_idx, k_bot_prmpt_idx,  k_bot_val_idx,  k_end_disp_obj_idx };
//+------------------------------------------------------------------+
//| Class with Functions to display the information panel           |
//+------------------------------------------------------------------+
class InformationDisplayPanel   // This could be defined as a singleton class
 {
   private:
      //======= arrays to hold Panel Object definition and state data ==========
      static string m_disp_obj_name[];
      static color  m_disp_obj_clr[];
      static int    m_disp_obj_size[];
      static long   m_disp_X_pos[];
      static long   m_disp_Y_pos[];
      static EnumOnOffSwitch m_disp_obj_ONOFF[];
      //===== Class Worker Variables =====
      ENUM_BASE_CORNER m_display_corner;
      long m_X_OffSet, m_Y_OffSet;
      int m_bar_num;
      double m_atr_val, m_atr_up_val, m_non_lag_MA_val, m_atr_dn_val;
      //
      void EnsureValidStartingPositions( long& starting_X_pos, long& starting_Y_pos ){  // Ensure Drag and drop does not make the drop object disapear off the edge of the chart
         long max_X_offset, max_Y_offset;
         max_X_offset = ChartGetInteger( ChartID(), CHART_WIDTH_IN_PIXELS, k_chart_window)-100;  // width of the chart minus enough space to display the ctrl object.
         max_Y_offset = ChartGetInteger( ChartID(), CHART_HEIGHT_IN_PIXELS, k_chart_window)-30;  // height of the chart minus enough space to display the ctrl object.
         if(starting_X_pos<0){ starting_X_pos=0;} else if(starting_X_pos>max_X_offset){ starting_X_pos=max_X_offset;}  // ensure ctrl object does not disapear off the edge
         if(starting_Y_pos<5){ starting_Y_pos=5;} else if(starting_Y_pos>max_Y_offset){ starting_Y_pos=max_Y_offset;}  // ensure ctrl object does not disapear off the edge
       } // ======== END EnsureValidStartingPositions ===========
      void MakeObjectsUnique(const long& uniquifier){  // Add a value to the object names that can make the oject names uniqe for each instance of the indicator
         for(DispObjIdx idx=0; idx<k_end_disp_obj_idx; idx++){
            m_disp_obj_name[idx] = IntegerToString(uniquifier)+m_disp_obj_name[idx];
          }
       } // ====== END MakeObjectsUnique ==========
      void ShowLabel(const DispObjIdx& idx){ // Display the label objects in the Panel Display
         string disp_string = GetDisplayString(idx);
         bool selectable=false;
         if(idx==k_MA_prmpt_idx){selectable=true;}
         ManageALabel(m_disp_obj_name[idx], disp_string, m_disp_X_pos[idx], m_disp_Y_pos[idx], m_disp_obj_clr[idx], m_disp_obj_size[idx], m_display_corner, selectable);
       } // ===== END ShowLabel =============
      // utility to create or update label objects for display 
      void ManageALabel(const string& obj_name, const string disp_str, const long& x_pos, const long& y_pos, const color disp_clr, const int& font_size, const ENUM_BASE_CORNER& obj_corner, const bool selectable=false ){
         static long chartID = ChartID();
         if ( ObjectFind(chartID,obj_name) < 0 )
          {
            ObjectCreate    (chartID, obj_name, OBJ_LABEL, k_chart_window,  0, 0);
            ObjectSetInteger(chartID, obj_name, OBJPROP_FONTSIZE,  font_size);
            ObjectSetString (chartID, obj_name, OBJPROP_FONT,      "Arial");
            ObjectSetInteger(chartID, obj_name, OBJPROP_COLOR,     disp_clr);
            ObjectSetInteger(chartID, obj_name, OBJPROP_CORNER,    obj_corner);
            ObjectSetInteger(chartID, obj_name, OBJPROP_ANCHOR,    ANCHOR_LEFT_UPPER);
            ObjectSetInteger(chartID, obj_name, OBJPROP_BACK,      true); 
            ObjectSetInteger(chartID, obj_name, OBJPROP_SELECTABLE,selectable); 
            ObjectSetInteger(chartID, obj_name, OBJPROP_SELECTED,  false); 
            ObjectSetInteger(chartID, obj_name, OBJPROP_HIDDEN,    false);
          }
         ObjectSetInteger(chartID, obj_name, OBJPROP_XDISTANCE, x_pos );
         ObjectSetInteger(chartID, obj_name, OBJPROP_YDISTANCE, y_pos );
         ObjectSetString (chartID, obj_name, OBJPROP_TEXT,      disp_str );
       } // ========= END ManageALabel ==========
      string GetDisplayString(const DispObjIdx& idx){  // Create the string for display in each lable object
         string disp_str;
         switch (idx){
            case k_info_hdr_idx:
               if(m_disp_obj_ONOFF[k_info_hdr_idx] == ON){
                  disp_str = "Trend Bar "+IntegerToString(m_bar_num)+", ATR: "+IntegerToString((int)(m_atr_val/_Point));
                }
               else{
                  disp_str = "Trend ATR OFF";
                }
               break;
            case k_top_prmpt_idx:     disp_str = "Top Band:"; break;
            case k_top_val_idx:       disp_str = DoubleToString(m_atr_up_val,_Digits); break;
            case k_MA_prmpt_idx:      disp_str = "Non-Lag-MA:"; break;
            case k_MA_val_idx:        disp_str = DoubleToString(m_non_lag_MA_val,_Digits); break;
            case k_bot_prmpt_idx:     disp_str = "Bot Band:"; break;
            case k_bot_val_idx:       disp_str = DoubleToString(m_atr_dn_val,_Digits); break;
            default: disp_str = "Undefined: "+IntegerToString(idx); break;
          }
         return disp_str;
       } // ========= End GetDisplayString =========
   protected:
      void ShowError( string source_func, int err_code, string operation){ // A utility to display error inormation
         comment_string=source_func+": "+operation+" failed, error: "+IntegerToString(err_code); // +", "+ErrorDescription(err_code);
         Comment(comment_string); Print(comment_string);
       } // ====== END ShowError ======
   public:
      void InformationDisplayPanel(const long& uniquifier){ // Constructor
         MakeObjectsUnique(uniquifier);
         m_display_corner = CORNER_LEFT_UPPER;
         long default_X_pos = 10, default_Y_pos = 30;
         SetDisplayPosition(default_X_pos,default_Y_pos);
       } // ==== END InformationDisplayPanel Constructor ==========
      void ~InformationDisplayPanel(void){  // Destructor
         for(DispObjIdx idx=0; idx<k_end_disp_obj_idx; idx++){
               ObjectDelete(ChartID(),m_disp_obj_name[idx]);  // Remove (delete) each display object
          }
       } // ==== END InformationDisplayPanel Destructor ==========
      void SetDisplayPosition(long& starting_X_pos, long& starting_Y_pos){ // Set the x and y coordinates for each object in the display panel
         EnsureValidStartingPositions( starting_X_pos, starting_Y_pos );
         long default_X_space = 90, default_Y_spacing = 15;
         m_disp_X_pos[k_info_hdr_idx]  = starting_X_pos;
         m_disp_Y_pos[k_info_hdr_idx]  = starting_Y_pos;
         int loop_count=0;
         for( DispObjIdx idx=2; idx<k_end_disp_obj_idx; idx+=2){
            loop_count++;
            m_disp_X_pos[idx-1] = starting_X_pos;
            m_disp_X_pos[idx]   = starting_X_pos+default_X_space;
            m_disp_Y_pos[idx-1] = starting_Y_pos+(default_Y_spacing*loop_count);
            m_disp_Y_pos[idx]   = m_disp_Y_pos[idx-1];
          }
      } // ========== END SetDisplayPosition ==========
     // Accept the indicator values for the Panel and display them
     void DisplayPanel(const int& stats_bar, const double& atr_val, const double& atr_up_val, const double& non_lag_MA_val, const double& atr_dn_val){
         m_bar_num = stats_bar;
         m_atr_val =  atr_val;
         m_atr_up_val = atr_up_val;
         m_non_lag_MA_val = non_lag_MA_val;
         m_atr_dn_val = atr_dn_val;
         if(g_atr_multiplier<_Point){  // Set at zero or less
            m_disp_obj_ONOFF[k_bot_prmpt_idx]=OFF; m_disp_obj_ONOFF[k_bot_val_idx]=OFF;
            m_disp_obj_ONOFF[k_top_prmpt_idx]=OFF; m_disp_obj_ONOFF[k_top_val_idx]=OFF;
          }
         for(DispObjIdx idx=0; idx<k_end_disp_obj_idx; idx++){
            if( m_disp_obj_ONOFF[idx]==ON || (idx==0) ){
               ShowLabel(idx);
             }
            else{
               ObjectDelete(ChartID(),m_disp_obj_name[idx]);
             }
          }
         m_X_OffSet = ObjectGetInteger( ChartID(), GetObjName(k_top_prmpt_idx), OBJPROP_XDISTANCE, k_no_property_modifier );
         m_Y_OffSet = ObjectGetInteger( ChartID(), GetObjName(k_top_prmpt_idx), OBJPROP_YDISTANCE, k_no_property_modifier );
      } // ========== END DisplayPanel ==========
     void RestartDrawing(void){ // Restart Panel (and Indicator) drawing after it has been turned off
         SetDisplayStateOnOf(ON);
         int count = iBars(_Symbol,PERIOD_CURRENT);   // number of elements to copy
         double _open[], _high[], _low[], _close[];  // Indicator must access these arrays to display
         ArraySetAsSeries(_high,true); ArraySetAsSeries(_low,true); ArraySetAsSeries(_open,true); ArraySetAsSeries(_close,true);
         if( CopyHigh(_Symbol,PERIOD_CURRENT,0,count,_high)<0){ ShowError( __FUNCTION__, GetLastError(), "CopyHigh"); }
         if( CopyLow(_Symbol,PERIOD_CURRENT,0,count,_low)<0){ ShowError( __FUNCTION__, GetLastError(), "CopyLow"); }
         if( CopyOpen(_Symbol,PERIOD_CURRENT,0,count,_open)<0){ ShowError( __FUNCTION__, GetLastError(), "CopyOpen"); }
         if( CopyClose(_Symbol,PERIOD_CURRENT,0,count,_close)<0){ ShowError( __FUNCTION__, GetLastError(), "CopyClose"); }
         int starting_bar = count-g_min_bars; // First bar for the indicator
         long tick_volume[1]; tick_volume[0]=2;  // for compatability with the OnCalcuate call
         g_run_onoff = ON;  // Turn running the indicator ON.
         if( !RunTheIndicator(starting_bar, tick_volume, _open, _high, _low, _close) ){
            comment_string = __FUNCTION__+": Restart Failed.";
            Comment(comment_string); Print(comment_string);
          }
      } // ========= END RestartDrawing ============
     //------- Getters and Setters for the class ----------
     string GetObjName( const DispObjIdx idx ){
         string obj_name="";
         if( idx>=0 && idx<k_end_disp_obj_idx){
            obj_name = m_disp_obj_name[idx];
          }
         return obj_name;
      }
     void SetDisplayStateOnOf( const EnumOnOffSwitch ONOFF){
         for(DispObjIdx idx=0; idx<ArrayRange(m_disp_obj_ONOFF,0); idx++){
            m_disp_obj_ONOFF[idx]=ONOFF;
          }
      }
     EnumOnOffSwitch GetObjONOF( const DispObjIdx idx ){
         EnumOnOffSwitch onOff=OFF;
         if( idx>=0 && idx<k_end_disp_obj_idx){
             onOff= m_disp_obj_ONOFF[idx];
          }
         return onOff;
      }
     long GetXPnlOffSetValue( void ){ return m_X_OffSet;}
     long GetObjXPos( const DispObjIdx idx ){
         long x_pos=0;
         if( idx>=0 && idx<k_end_disp_obj_idx){
             x_pos= m_disp_X_pos[idx];
          }
         return x_pos;
      }
     long GetYPnlOffSetValue( void ){ return m_Y_OffSet;}
     long GetObjYPos( const DispObjIdx idx ){
         long y_pos=0;
         if( idx>=0 && idx<k_end_disp_obj_idx){
             y_pos= m_disp_Y_pos[idx];
          }
         return y_pos;
      }
 }*panel_disp_ptr = NULL;
// enum  DispObjIdx                                                  { k_info_hdr_idx, k_MA_prmpt_idx,  k_MA_val_idx,  k_top_prmpt_idx, k_top_val_idx, k_bot_prmpt_idx,  k_bot_val_idx,  k_end_disp_obj_idx };
static string           InformationDisplayPanel::m_disp_obj_name[] = { "info_hdr_idx", "MA_prmpt",      "MA_val",      "Top_PRMPT",     "Top_val",     "Bot_prmpt",      "Bot_val"        };
static color             InformationDisplayPanel::m_disp_obj_clr[] = { clrLime,        clrLimeGreen,    clrBlue,       clrLimeGreen,    clrBlue,       clrLimeGreen,     clrBlue          };
static int              InformationDisplayPanel::m_disp_obj_size[] = {  13,             11,              11,            11,              11,            11,               11              };
static long                InformationDisplayPanel::m_disp_X_pos[] = {  10,             1,               1,             1,               1,             1,                1               };
static long                InformationDisplayPanel::m_disp_Y_pos[] = {  30,             1,               1,             1,               1,             1,                1               };
static EnumOnOffSwitch InformationDisplayPanel::m_disp_obj_ONOFF[] = { ON,             ON,              ON,            ON,              ON,            ON,               ON               };
//======= END Information Panel Display Class Definition ============
//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
 {
   ENUM_INIT_RETCODE init_result = INIT_SUCCEEDED;
   string short_name=indicator_name+"("+IntegerToString(MAPeriod)+")";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   //
   CheckReasonableInputValues();
   //
   if( alfa_class_ptr==NULL ){  // this should always be true
      alfa_class_ptr = new AlfaClass(g_MA_period); // create the nonLagMA values calculator class
      if( alfa_class_ptr == NULL ){ // catasrophic failure
         init_result = INIT_FAILED; int err_code=GetLastError();
         comment_string=__FUNCTION__+": Alfa Class Creation Failed, error: "+IntegerToString(err_code); // +", "+ErrorDescription(err_code);
         Comment(comment_string); Print(comment_string);
       }
    }
   g_min_bars = DetermineIndicatorsMinBars();  // What are the minimum # of bars required for the indicator
   //
   if( panel_disp_ptr==NULL ){  // this should always be true
      panel_disp_ptr = new InformationDisplayPanel(Uniquifier);  // Create the display panel class
      if( panel_disp_ptr == NULL ){ // catasrophic failure
         init_result = INIT_FAILED; int err_code=GetLastError();
         comment_string=__FUNCTION__+": Information Panel Class Creation Failed, error: "+IntegerToString(err_code);  // +", "+ErrorDescription(err_code);
         Comment(comment_string); Print(comment_string);
       }
    }
   InitializeIndiDrawing();  // Set up all the indicator Buffers
   //
   return(init_result);
 } // ===== END OnInit ==============
int DetermineIndicatorsMinBars(void)  // Determint the minimum number of chart bars the indicator needs to run
 {
   int min_bars_ary[3];  // Array to hold values to find the minimum # of bars required for the indicator.
   min_bars_ary[0]=g_atr_period;
   min_bars_ary[1]=g_MA_period;
   min_bars_ary[2]=alfa_class_ptr.GetAlfaArraySize();
   return min_bars_ary[ArrayMaximum(min_bars_ary,0,WHOLE_ARRAY)];
 } // ====== END DetermineIndicatorsMinBars ============
void CheckReasonableInputValues(void)  // ensure user input values are usable and adjust for the indicator to proceed if they are not
 {
   g_MA_price   = MAPrice;   g_alert_mode = AlertMode;
   g_MA_period  = MAPeriod;  g_displace   = Displace;  g_atr_period     = AtrPeriod;
   g_pct_filter = PctFilter; g_deviation  = Deviation; g_atr_multiplier = AtrMultiplier; 
   //
   g_MA_period      = (g_MA_period<1)?1:g_MA_period;                  g_MA_period      = (g_MA_period>400)?400:g_MA_period;                     // non_lag_ma_period
   g_atr_period     = (g_atr_period<1)?1:g_atr_period;                g_atr_period     = (g_atr_period>g_MA_period)?g_MA_period:g_atr_period;   // atr range
   g_displace       = (g_displace<0)?0:g_displace;                    g_displace       = (g_displace>80)?80:g_displace;                         // shift of display 
   g_pct_filter     = (g_pct_filter<_Point)?0.0:g_pct_filter;         g_pct_filter     = (g_pct_filter>80)?80:g_pct_filter;                     // Dynamic filter in decimal
   g_deviation      = (g_deviation<_Point)?0.0:g_deviation;           g_deviation      = (g_deviation>30.0)?30.0:g_deviation;                   // Up/down deviation        
   g_atr_multiplier = (g_atr_multiplier<_Point)?0.0:g_atr_multiplier; g_atr_multiplier = (g_atr_multiplier>20.0)?20.0:g_atr_multiplier;         // try 2.0 or > 0 to enable ATR Bands
 } //======== END CheckReasonableInputValues ============
//
//+------------------------------------------------------------------+
//| Two functions follow to initialize all the indicator buffers     |
//+------------------------------------------------------------------+
void InitializeIndiDrawing(void)  // Initialize the values for the indicator buffers
 {
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);  // --- set accuracy --------
   for(IndicatorBufferIdx idx=0; idx<k_end_indi_idx; idx++){  // process each buffer using the buffer index enumeration
      // --- Settings that change in the different buffers ----
      InitializeIndiBuffers(indi_array[idx].m_indi_buff, idx, indi_bufferType[idx], indi_text_name[idx], indi_draw_type[idx], indi_draw_style[idx], indi_line_width[idx]);  // Set values from the Buffer Initialization arrays
      // --- Settings that are the same for all the buffers ---
      ArraySetAsSeries    ( indi_array[idx].m_indi_buff,  true);     // all indicator buffers are time series
      PlotIndexSetDouble  ( idx,  PLOT_EMPTY_VALUE, EMPTY_VALUE );   // all the indicator buffers use EMPTY_VALUE as their default
      PlotIndexSetInteger ( idx,  PLOT_DRAW_BEGIN,  g_min_bars );    // no action needs to be taken before the minimum number of bars
      PlotIndexSetInteger ( idx,  PLOT_SHIFT,       NULL );          // no need to shift any of the plots
    }   
 }
void InitializeIndiBuffers( double& buffer[], const IndicatorBufferIdx& buffer_num, const ENUM_INDEXBUFFER_TYPE& data_type, const string& plot_label,
                         const ENUM_DRAW_TYPE& draw_type, const ENUM_LINE_STYLE& line_stype, const int line_width )  // set the values as passed for each inidicator buffer
 {
   SetIndexBuffer      ( buffer_num,  buffer,           data_type );
   PlotIndexSetString  ( buffer_num,  PLOT_LABEL,       plot_label );
   PlotIndexSetInteger ( buffer_num,  PLOT_DRAW_TYPE,   draw_type );
   PlotIndexSetInteger ( buffer_num,  PLOT_LINE_STYLE,  line_stype );
   PlotIndexSetInteger ( buffer_num,  PLOT_LINE_WIDTH,  line_width );
 } //====== End Initialization of the Indicator Buffers ============
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
 { // Release resources
   if(alfa_class_ptr!=NULL){delete alfa_class_ptr;    alfa_class_ptr=NULL;}
   if(panel_disp_ptr!=NULL){delete panel_disp_ptr;    panel_disp_ptr=NULL;}
   if(MA_handle!=NULL){IndicatorRelease(MA_handle);   MA_handle=NULL;}
   if(ATR_handle!=NULL){IndicatorRelease(ATR_handle); ATR_handle=NULL;}
   // Clean up the Comment if this indicator made one.
   if(StringLen(comment_string)>0){
      Comment("");
    }
 } //====== End OnDeinit ============
//+------------------------------------------------------------------+
//| Chart Event Handler                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
 {
   if(id==CHARTEVENT_CLICK){  //lparam == the X coordinate; dParam == Y coordinate; find the X coordinate time and display that bar's indicator values
      datetime chartClickTime;
      double chartClickPrice;
      int subWindow;
      int horizontal = (int) lparam;
      int vertical   = (int) dparam;
      if (ChartXYToTimePrice(k_chart_window,horizontal,vertical, subWindow, chartClickTime, chartClickPrice)){
         if( (subWindow==k_chart_window) ){ // clicked on the main window
            g_stats_time = chartClickTime;
            ShowBarStatistics(g_stats_time);
          }
       }
      ChartRedraw(ChartID());
    }
   if(id==CHARTEVENT_OBJECT_CLICK){
      if( sparam==panel_disp_ptr.GetObjName(k_info_hdr_idx) ){ // Object to toggle the indicator on or off has been clicked
         EnumOnOffSwitch OnOff = panel_disp_ptr.GetObjONOF( k_info_hdr_idx );
         OnOff = (OnOff==ON)?OFF:ON;
         if( OnOff==ON){
            panel_disp_ptr.RestartDrawing();
          }
         else{
            StopIndicator();
          }
       }
      else if( sparam==panel_disp_ptr.GetObjName(k_top_prmpt_idx) ){
         static EnumOnOffSwitch OnOff = ON;
         if( OnOff==ON ){
            OnOff = OFF; comment_string = "";
            Comment("");
          }
         else{
            OnOff = ON;
            ShowAlfaArrayValues();
          }
       }
      ChartRedraw(ChartID());
    }
   if(id==CHARTEVENT_OBJECT_DRAG){  //sparam = Name of the moved graphical object
      if( sparam==panel_disp_ptr.GetObjName(k_MA_prmpt_idx) ){  // The pannel has been drug to a new location, display the panel at that location
         long newXpos, newYpos, oldXpos, oldYpos, xOffset, yOffset, pnlXvalue, pnlYvalue;
         oldXpos = panel_disp_ptr.GetObjXPos( k_top_prmpt_idx );  // Get before-drag Move Object Position
         oldYpos = panel_disp_ptr.GetObjYPos( k_top_prmpt_idx );  // Get before-drag Move Object Position
         newXpos = ObjectGetInteger( ChartID(), sparam, OBJPROP_XDISTANCE, k_no_property_modifier );   // Get after-drag Move Object Position
         newYpos = ObjectGetInteger( ChartID(), sparam, OBJPROP_YDISTANCE, k_no_property_modifier );   // Get after-drag Move Object Position
         pnlXvalue = panel_disp_ptr.GetObjXPos( k_info_hdr_idx );  // get the Anchor object's current position
         pnlYvalue = panel_disp_ptr.GetObjYPos( k_info_hdr_idx );  // get the Anchor object's current position
         xOffset = pnlXvalue + (newXpos-oldXpos);  // set the Anchor object's new position
         yOffset = pnlYvalue + (newYpos-oldYpos);  // set the Anchor object's new position
         panel_disp_ptr.SetDisplayPosition(xOffset,yOffset); // Set all the objects new positions
         ShowBarStatistics(g_stats_time); // Display at the new position
       }
      ChartRedraw(ChartID());
    }
 }
//
void StopIndicator(void)
 {  // k_ATR_up_idx,   k_ATR_dn_idx,   k_MA_indi_idx,   k_MA_clr_idx,
   g_run_onoff = OFF;
   for(IndicatorBufferIdx idx=0; idx<=k_MA_clr_idx; idx++){ // Remove the lines from the chart.
      ArrayInitialize(indi_array[idx].m_indi_buff, EMPTY_VALUE);
    }
   panel_disp_ptr.SetDisplayStateOnOf(OFF);  // Turn the objects off
   ShowBarStatistics(g_stats_time); //Display in Off State
 }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[], const long& tick_volume[], const long& volume[], const int& spread[] )
 {
   int starting_bar, to_copy;  // starting calculation bar and the # of terminal bars to process
   static int last_prev_calculated=0;  // retain the last # of bars successfully calculated by the indicator
   //--- Set the limits for what bars need to be evaluated
   if( !SetCalculateLimits( starting_bar, to_copy, rates_total, prev_calculated) ){  // set the starting calculation bar and the terminal bars to process
      return 0;   // limits are not ready  This value will be in prev_calculated the next time OnCalculate is called.
    }
   //--- not all needed terminal data may be calculated
   if( !TerminalCalculationsAreComplete(rates_total) ){  // Determine if the terminal has completed preparing its data for the new OnCalculate event
      return last_prev_calculated;  // buffers not ready  This value will be in prev_calculated the next time OnCalculate is called.
    }
   //--- get terminal buffer's needed data
   if( !PerformBufferCopies(to_copy) ){  // Get terminal data needed by the indicator
      return last_prev_calculated;  // Getting terminal data failed.  This value will be in prev_calculated the next time OnCalculate is called.
    }
   //--- Peform the main indicator calculations
   if( !RunTheIndicator(starting_bar, tick_volume, open, high, low, close) ){  // Run (display) the indicator
      return last_prev_calculated;  // Value to start the next call with in prev_calculated
    }
   //
   ShowBarStatistics(g_stats_time);  // Show indicator statistics for a chart bar
   //
   last_prev_calculated = rates_total;   // retain the last # of bars successfully calculated by the indicator
	return(rates_total);
 } // ======= End OnCalculate ==========
//+------------------------------------------------------------------+
//| Perform the Indicator Calculation and display                    |
//+------------------------------------------------------------------+
bool RunTheIndicator(const int& starting_bar, const long& tick_volume[],
                     const double &open[], const double &high[], const double &low[], const double &close[])
 {
   bool run_success = true;
   if( g_run_onoff == ON ){
      for(int shift=starting_bar; shift>=0; shift--){
         SetBufferAlfaValues(shift, indi_array[k_IMA_val_idx].m_indi_buff, indi_array[k_MA_indi_idx].m_indi_buff, indi_array[k_del_indi_idx].m_indi_buff, indi_array[k_avg_del_buffer].m_indi_buff); 
         //
         double color_switch_level = alfa_class_ptr.GetTheColorSwitchLevel( shift, g_pct_filter, g_MA_period, indi_array[k_del_indi_idx].m_indi_buff, indi_array[k_avg_del_buffer].m_indi_buff );
         //
         SetTheDisplayColor(shift, color_switch_level, indi_array[k_MA_indi_idx].m_indi_buff, indi_array[k_MA_clr_idx].m_indi_buff );
         //
         LoadATRBands(shift, indi_array[k_MA_indi_idx].m_indi_buff, indi_array[k_ATR_up_idx].m_indi_buff, indi_array[k_ATR_dn_idx].m_indi_buff, indi_array[k_ATR_vals_idx].m_indi_buff); 
         //
         RunTheAlerts( g_alert_mode, tick_volume, indi_array[k_MA_clr_idx].m_indi_buff );
       }
    }
   return run_success;
 } //------ End runTheIndicator -----------
//==== Indicator Utilities ======
void SetBufferAlfaValues( const int& shift, const double& ima_buffer[], double& MA_buffer[], double& del_buffer[], double& avg_del_buffer[] )
 {
      MA_buffer[shift]      = alfa_class_ptr.GetTheBarMAValue(shift, ima_buffer, g_displace, g_MA_price);
      del_buffer[shift]     = alfa_class_ptr.GetDelBufferValue( shift, indi_array[k_MA_indi_idx].m_indi_buff);
      avg_del_buffer[shift] = alfa_class_ptr.GetAvrgDelBuffferValue( shift,  indi_array[k_del_indi_idx].m_indi_buff, g_MA_period);
 } //--------- End SetBufferAlfaValues ----------
void SetTheDisplayColor(const int& work_bar, const double& color_switch_level, double& MA_buffer[], double& clr_buffer[])
 {
   if( MathAbs(MA_buffer[work_bar]-MA_buffer[work_bar+1]) < color_switch_level ){  // switch level is zero for defaults, so this doesn't happen
      clr_buffer[work_bar]=clr_buffer[work_bar+1]; // If it didn't change enough, leave color as is
    }
   else if (MA_buffer[work_bar]-MA_buffer[work_bar+1] > color_switch_level){  // Line is rising, set the long color
      clr_buffer[work_bar]=k_long_clr;
    }
   else if (MA_buffer[work_bar]-MA_buffer[work_bar+1] < color_switch_level){  // Line is falling, set the short color
      clr_buffer[work_bar]=k_short_clr;
    }
   else{ // Is horizontal, leave the color buffers just like they were; this 'else' is rare
      clr_buffer[work_bar]=clr_buffer[work_bar+1];
    }
 } //--------- End SetTheDisplayColor ----------
// Set the values for the upper and lower atr offset lines
void LoadATRBands(const int& work_bar, const double& ma_buffer[], double& atr_up_buff[], double& atr_dn_buff[], const double& atr_values[])
 { 
   if (g_atr_period>0 && g_atr_multiplier>0){
      atr_up_buff[work_bar] = ma_buffer[work_bar]+(atr_values[work_bar]*g_atr_multiplier);
      atr_dn_buff[work_bar] = ma_buffer[work_bar]-(atr_values[work_bar]*g_atr_multiplier);
    }
 } //===== End LoadATRBands =======
//---- Display the Indicator Control Panel and Display selected bar statistics -----------
void ShowBarStatistics(datetime& stats_time)
 {
   int stats_bar=0;
   if( stats_time != NULL ){
      stats_bar = iBarShift(_Symbol,PERIOD_CURRENT,stats_time,false);  // Find the bar for the time; bar number will increment as new bars are made.
    }
   if( (stats_bar==0) || (stats_time==NULL) ){
      stats_bar = 0; stats_time=NULL;  // if displaying Bar Zero, keep displaying bar zero when new bars happen.
    }
   double atr = indi_array[k_ATR_vals_idx].m_indi_buff[stats_bar];   // Assignments so values can be seen easily with debugger
   double atr_up = indi_array[k_ATR_up_idx].m_indi_buff[stats_bar];
   double non_lag_MA = indi_array[k_MA_indi_idx].m_indi_buff[stats_bar];
   double atr_dn = indi_array[k_ATR_dn_idx].m_indi_buff[stats_bar];
   //
   panel_disp_ptr.DisplayPanel(stats_bar, atr, atr_up, non_lag_MA, atr_dn);
 } // ========= End ShowBarStatistics ========
//
void RunTheAlerts(const EnumOnOffSwitch& alert_mode, const long& tick_volume[], const double& trend_buffer[] )  // Alert on changes to the trend.
 { 
   if(alert_mode==ON){
      string Message;
      static TrendDirEnum last_trend=k_no_trend;
      //
      if( (trend_buffer[2]<k_long_clr) && (trend_buffer[1]>k_short_clr) && (tick_volume[0]>1) && (last_trend!=k_up_trend) ){
         Message = " "+Symbol()+" M"+IntegerToString(Period())+": Signal for BUY";
      	Alert (Message);
      	last_trend = k_up_trend;
   	 }	  
   	else if( (trend_buffer[2]>k_short_clr) && (trend_buffer[1]<k_long_clr) && (tick_volume[0]>1) && (last_trend!=k_dn_trend) ){
      	Message = " "+Symbol()+" M"+IntegerToString(Period())+": Signal for SELL";
      	Alert (Message); 
      	last_trend = k_dn_trend;
   	 }
	 }
 } // ---- End RunTheAlerts ----------
//
bool SetCalculateLimits(int& starting_bar, int& to_copy, const int& rates_total, const int& prev_calculated) // Set the bar to use to start calulations
 {
   bool limits_ready = true;
   if( (prev_calculated < 1) || (prev_calculated > rates_total) || IsStopped() ){  // Indicator has not ran for the first time or is in a state to restart or stop calculating
      static long err_count=0;
      if( (rates_total < g_min_bars) || IsStopped() ){ // don't calculate until there are at least DATA_LIMIT bars, or the indicator is stopped
         err_count++;
         comment_string = __FUNCTION__+": Limit Count Not Set "+IntegerToString(err_count)+" times; Rates Total: "+IntegerToString(rates_total)+", Stopped: "+IntegerToString(IsStopped());
         Comment(comment_string); Print(comment_string);
         limits_ready = false;  // quite without calculating.
       }
      else if( err_count>0){
         err_count=0; Comment(""); comment_string="";
       }
      if( (limits_ready==true) && ( (MA_handle==NULL) || (ATR_handle==NULL) ) ){
         static long error_count=0;
         if( !HandlesSet() ){
            error_count++;
            comment_string = __FUNCTION__+": Handles Not Set "+IntegerToString(error_count)+" times";
            Comment(comment_string); Print(comment_string);
            limits_ready = false;  // quite without calculating.
          }
         else if(error_count>0){
            error_count=0; Comment(""); comment_string="";
          }
       }
      starting_bar=rates_total-g_min_bars;
      to_copy = rates_total;
    }
   else{ //--- indicator has previously ran; not all data needs to be copied or re-evaluated
      starting_bar = (rates_total - prev_calculated);
      to_copy = (rates_total - prev_calculated)+1;
    }
   return limits_ready;
 } //========== End SetCalculateLimits =================
//
bool HandlesSet(void)  // Initialize handles used to get needed terminal data
 {
   bool handles_set=true;
   const int k_ma_bars = 1;
   if( MA_handle==NULL ){
      MA_handle = iMA(_Symbol,PERIOD_CURRENT,k_ma_bars,k_no_shift,MODE_LWMA,g_MA_price);
    }
   if( MA_handle==INVALID_HANDLE ){
      int error_code = GetLastError(); MA_handle=NULL;
      comment_string = __FUNCTION__+": Failed to Create MA_handle, Error: "+IntegerToString(error_code); // +", "+ErrorDescription(error_code);
      Comment(comment_string); Print(comment_string);
      handles_set=false;
    }
   //
   if( ATR_handle==NULL ){
      ATR_handle = iATR(_Symbol, PERIOD_CURRENT, g_atr_period);
    }
   if( ATR_handle==INVALID_HANDLE ){
      int error_code = GetLastError();  ATR_handle=NULL;
      comment_string = __FUNCTION__+": Failed to Create ATR_handle, Error: "+IntegerToString(error_code); // +", "+ErrorDescription(error_code);
      Comment(comment_string); Print(comment_string);
      handles_set=false;
    }
   return handles_set;
 } // ============ End HandlesSet =================
//
bool TerminalCalculationsAreComplete(const int& rates_total) // not all needed terminal data may be calculated by the terminal, check
 {
   bool calcuations_completed = true;
   //
   static long ma_err_count = 0;
   int calculated=BarsCalculated(MA_handle);
   if(calculated<rates_total){
      ma_err_count++;
      int err_code = GetLastError();
      comment_string = __FUNCTION__+": Not all data of MA_handle is calculated ("+IntegerToString(calculated)+" bars calculated out of "+IntegerToString(rates_total)
                      +" ). Error: "+IntegerToString(err_code)+", "+IntegerToString(ma_err_count)+" times.";  // ", "+ErrorDescription(err_code)+
      Comment(comment_string); Print(comment_string);
      calcuations_completed = false;
    }
   else if( ma_err_count > 0 ){
      ma_err_count=0; Comment(""); comment_string="";
    }
   static long atr_err_count = 0;
   calculated=BarsCalculated(ATR_handle);
   if(calculated<rates_total){
      atr_err_count++;
      int err_code = GetLastError();
      comment_string = __FUNCTION__+": Not all data of ATR_handle is calculated ("+IntegerToString(calculated)+" bars calculated out of "+IntegerToString(rates_total)
                      +" ). Error: "+IntegerToString(err_code)+", "+IntegerToString(atr_err_count)+" times.";  // ", "+ErrorDescription(err_code)+
      Comment(comment_string); Print(comment_string);
      calcuations_completed = false;
    }
   else if( atr_err_count > 0 ){
      atr_err_count=0; Comment(""); comment_string="";
    }
   //
   return calcuations_completed;
 }// ========== End TerminalCalculationsAreComplete ============
//
bool PerformBufferCopies(const int& to_copy)  // Copy needed terminal data to inidicator buffers
 {
   static long ma_err_count=0, atr_err_count=0;
   bool copy_succeeded = true;
   //--- get FastSMA buffer data
   if(CopyBuffer(MA_handle,0,0,to_copy,indi_array[k_IMA_val_idx].m_indi_buff)<=0){
      ma_err_count++;
      int err_code = GetLastError();
      comment_string = __FUNCTION__+": Getting MA data failed, "+IntegerToString(ma_err_count)+" times! Error: "+IntegerToString(err_code); // +", "+ErrorDescription(err_code);
      Comment(comment_string); Print(comment_string);
      copy_succeeded = false;
    }
   else if( ma_err_count>0 ){
      ma_err_count=0; Comment(""); comment_string="";
    }
   if(CopyBuffer(ATR_handle,0,0,to_copy,indi_array[k_ATR_vals_idx].m_indi_buff)<=0){
      atr_err_count++;
      int err_code = GetLastError();
      comment_string = __FUNCTION__+": Getting ATR data failed, "+IntegerToString(atr_err_count)+" times! Error: "+IntegerToString(err_code); // +", "+ErrorDescription(err_code);
      Comment(comment_string); Print(comment_string);
      copy_succeeded = false;
    }
   else if( atr_err_count>0 ){
      atr_err_count=0; Comment(""); comment_string="";
    }
   return copy_succeeded;
 } //========= End PerformBufferCopies ===========
void ShowAlfaArrayValues(void)  // This is just for curiosity (can weight ever be <0?) - the answer is no.
 {
   for(int i = 0; i<alfa_class_ptr.GetAlfaArraySize(); i++){
      comment_string += DoubleToString(alfa_class_ptr.GetAlfa(i),_Digits)+", ";
      if(MathMod(i,20)==0)
         comment_string+="\n";
      Comment(comment_string);
    }
   Comment(comment_string, "\nWeight: ", DoubleToString(alfa_class_ptr.GetWeight(),_Digits));
 } //====== End ShowAlfaArrayValues ============
//+------------------------------------------------------------------+