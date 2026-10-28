// This Code's semaphore zig zag algorithm came from
// === https://www.forexfactory.com/showthread.php?p=12559584#post12559584 ===
// === !!!-MT4 SEMAFOR
// Zig Zag Semafor
//============================================================================
#property copyright    "https://www.mql5.com/en/users/lukeb"
string indicatorName = "SEMAFOR";
#property link         "https://www.mql5.com/en/users/lukeb"
#property version      "2.00"
#property description  "Re-write of [!!!-MT4 SEMAFOR]"
#property description  "A simple indicator to display local highs and lows"
#property indicator_chart_window
#property strict
#include  <stdlib.mqh>
enum ENUM_ON_OFF {OFF, ON};
//====== Data for the indicator drawing plots setup.  These arrays are read in OnInit to set up the Indicator Buffers.  ===========
enum ENUM_INDI_IDX            { INDI_1_UP,    INDI_1_DN,    INDI_2_UP,    INDI_2_DN,    INDI_3_UP,    INDI_3_DN,    INDI_4_UP,    INDI_4_DN,     endIndiIdx};
string          indiLabel[] = { "LEVEL_1_UP", "LEVEL_1_DN", "LEVEL_2_UP", "LEVEL_2_DN", "LEVEL_3_UP", "LEVEL_3_DN", "LEVEL_4_UP", "LEVEL_4_DN"    };
color           indiClr[]   = { clrWhite,     clrWhite,     clrRed,       clrRed,       clrYellow,    clrYellow,    clrLime,      clrLime         };
int             indiWidth[] = { 2,            2,            4,            4,            6,            6,            8,            8               };
int             indiDraw[]  = { DRAW_ARROW,   DRAW_ARROW,   DRAW_ARROW,   DRAW_ARROW,   DRAW_ARROW,   DRAW_ARROW,   DRAW_ARROW,   DRAW_ARROW      };
int             indiChar[]  = { 108,          108,          162,          162,          162,          162,          162,          162             };
ENUM_LINE_STYLE drawStyle[] = { STYLE_SOLID,  STYLE_SOLID,  STYLE_SOLID,  STYLE_SOLID,  STYLE_SOLID,  STYLE_SOLID,  STYLE_SOLID,  STYLE_SOLID     };
#property indicator_buffers endIndiIdx
//+------------------------------------------------------------------+
//| Class to initialize and hold the drawing plots of the indicator  |
//+------------------------------------------------------------------+
class C_IndiBuffers  // Create one instance for each indicator buffer
 {
   private:  //SetIndexStyle ( m_bufNum, draw, style, width, clr );
      int m_buffNum, m_indiDraw, m_width;
      ENUM_LINE_STYLE m_style;
      color m_clr;
   protected:
      void initialzeIndicatorBuffer(const ENUM_INDI_IDX& bufNum, const string& label, const color& clr, const int& width
                                   ,const int& draw, const int& drawString, const ENUM_LINE_STYLE& style, const int& firstDraw);
   public:
      double indiBuf[];
      void SetDrawingOnOff(const ENUM_ON_OFF onOff);
      void Initialize(const ENUM_INDI_IDX& bufNum, const string& label, const color& clr, const int& width
                        ,const int& draw, const int& drawString, const ENUM_LINE_STYLE& style);
 } c_indiBuffers_ary[endIndiIdx]; //======= END C_IndiBuffers Class ============
// User Control Variables
extern bool SoundAlert         = false;
extern int  Uniquifier         = 226;
extern int  Level_1_Length     = 21; // Zig Zag 1 detection length (21)
extern int  Level_2_Length     = 40; // Zig Zag 2 detection length (40)
extern int  Level_3_Length     = 60; // Zig Zag 3 detection length (60)
extern int  Level_4_Length     = 72; // Zig Zag 4 detection length (72)
extern string myUpperSoundFile = "alert.wav";
extern string myLowerSoundFile = "alert.wav";
extern int  ControlOffset      = 20;  // Position for the controls
// Global Variables
const int WINDOWZERO = 0;
enum ENUM_PROCESS_LEVELS { LEVEL_1, LEVEL_2, LEVEL_3, LEVEL_4, endProcessLevels };
const string processLevel_ary[endProcessLevels] = {"LEVEL_1", "LEVEL_2", "LEVEL_3", "LEVEL_4"};
enum ENUM_ALERT_TYPE {HIGH_ALERT, LOW_ALERT};
const string alertTypeString[]= {"HIGH", "LOW"};
enum ENUM_SWING_TYPE {SWING_NOT_SET, SWING_HI_AND_LO, SWING_LO, SWING_HI};
const ushort CHARTEVENT_RUNINDI = 943;
int  minBars;
datetime oldestUsableBarTime;
string msgString;
bool globalIsTestingFlag;
//+------------------------------------------------------------------------------+
//| Class for utilities associated with Time                                     |
//+------------------------------------------------------------------------------+
class C_TimeUtilities
 {
   private:
   protected:
   public:  // compiler compilees without being declcared static, Code Checker for submission insists it be declared static
      static string TimeFrameToString(ENUM_TIMEFRAMES tf);  // Get text identifying the time frame
 };//====== END C_TimeUtilities Class ==================
//+-------------------------------------------------------------------------------------+
//| Class for Controlling the Indicator State, Displaying the indicator Control Objects |
//+-------------------------------------------------------------------------------------+
enum ENUM_DISP_OBJ_IDX       { INDI_STATE, TEXT_STATE, endDispObjIdx};
class C_IndicatorControl  // Create a single instance to display the indicator on-chart controls (could be a singleton)
 {
   private:
      string m_objName[endDispObjIdx];  // names of the control objects
      int    m_yPos[endDispObjIdx];     // y, vertical, positions of the control objects
      int    m_xPos[endDispObjIdx];     // x, horizontal, positions of the control objects
      color  m_txtClr;                  // color of the text display
      ENUM_ON_OFF m_indiState, m_textState;  // Keep the on or off state of the display semaphores and text
      string m_indiName;                     // keep the indicator name
      uint m_callCounter;                    // count the number of calls, this program flow tracking, not indicator functionality
      //
      string GetVariableName(const ENUM_DISP_OBJ_IDX& objIdxToName);  // Function to create the name of the text object
      void SaveGlobalVariableValue(const ENUM_DISP_OBJ_IDX variableToSave, const ENUM_ON_OFF& valueToSave);  // Function to store the display state associated with the control variable 
      ENUM_ON_OFF GetGlobalVariableValue(const ENUM_DISP_OBJ_IDX variableToGet);  // Function to retrive the state associated iwth the control variable
   protected:
      void ManageALabel(const string& objName, const string ctrlText, const int xPos, const int yPos, const color& txtClr);  // Create or update a lable object and display it.
   public:
      void C_IndicatorControl(void); // Constructor , initialize everything
      void ~C_IndicatorControl(void); // Destructor
      string GetControlName(const ENUM_DISP_OBJ_IDX objIdx);    // Get the OBJECT_LABEL anme for the control object
      ENUM_ON_OFF GetControlState(const ENUM_DISP_OBJ_IDX objIdx); // return the on/off state associated with the control (OBJ_LABEL)
      string GetIndiCtrlText(const ENUM_DISP_OBJ_IDX& objIdx);  // return the text to display for the control (OBJ_LABEL)
      void SaveIndiDispState(const ENUM_ON_OFF& indiDispState); // save the indicator display on/off state
      void SaveIndiTextState(const ENUM_ON_OFF& indiTextState); // save the text display on/off state
      ENUM_ON_OFF RetrieveIndiDispState(void);  // get the display state (on or off) for the indiator (the semaphore)
      ENUM_ON_OFF RetrieveTextDispState(void);  // get the display state (on or off) for the semaphore text.
      int RetrieveObj_Y_Pos(const ENUM_DISP_OBJ_IDX& objIdx);  // provide the control object's y text position (OBJ_LABEL vertical position)
      int RetrieveObj_X_Pos(const ENUM_DISP_OBJ_IDX& objIdx); // provide the control object's x text position (OBJ_LABEL horizontal position)
      void DisplayCntrlObjs(void);  // draw the control objects (OBJ_LABEL objects) on the chart
 }c_indiCtrl;  // one global object of this type.  This could be a singleton.
//+------------------------------------------------------------------------------+
//| Class to display Alert Labels                                                |
//+------------------------------------------------------------------------------+
class C_AlertObjectDisplay // contains the functions to display text lables for the semaphores.  Each C_ProcessLevel instance has one instance of this.
 {
   private:
      ENUM_ON_OFF m_textOn;  // variable to keep track of if the text object should be displayed or not
      static double m_lastAlertPrice; // most recent alert price
      static datetime m_lastAlertTime; // most recent alert time
      static ENUM_ALERT_TYPE m_lastAlertType; // most recent alert tyupe
      string m_objectNames[]; // array to store text object names belonging to this indicator
      int    m_objNameIdx;    // variable to store an index to text object name
      long   m_chartID;       // value returned by ChartID(void) for displaying the text objects
      //
      void AddNameToArray(string& objName); // Place a name into the text object name array
      void ManageTextObject(const ENUM_ALERT_TYPE& alertType, const string processLevel, const double& alertPrice, const double& textPosPrice, const datetime& barTime, const datetime& textPosTime, const color dispClr); // Draw a new or updated text display object
   protected:
      void ResizeNamesArray( string& objNames[], int size ); // size the object names array
      void AddObjectToNameList(string& objName); // Place a text object name in the name list 
      string GetAlertTextObjectName(void);  // Create the name for a text object (OBJECT_TEXT) to be displayed
      double GetBarPricefromAlertPrice(const ENUM_ALERT_TYPE& alertType, const ENUM_PROCESS_LEVELS& level, const double& posPrice, const double& offsetValue); // Given alert position price, get the bar price
      double GetAlertPriceFromPositionPrice(const ENUM_ALERT_TYPE& alertType, const ENUM_PROCESS_LEVELS& level, const double& posPrice, const double& offsetValue); // Get the alert positiion price given the bar price
      double GetPositionPriceFromAlertPrice(const ENUM_ALERT_TYPE& alertType, const ENUM_PROCESS_LEVELS& level, const double& alertPrice, const double& offsetValue); // Given the Bar Price, provide the Alert Position Price
      datetime GetPositionTimeFromRefBar(const ENUM_ALERT_TYPE& alertType, const ENUM_PROCESS_LEVELS& level, const int& refBar);  // Give a bar, provide a text display position time
   public:
      void C_AlertObjectDisplay(void); // Constructor, initialize things
      void ~C_AlertObjectDisplay(void); // Destructor, delete objects
      void SetAlertTimeAndPrice(const double& alertPrice, const datetime alertTime, const ENUM_ALERT_TYPE alertType); // save the alart time, price, and type
      void SetTextOnOff(ENUM_ON_OFF onOff); // save the text on or off state,and delete text objects if off
      void MakeHistoricalText(const ENUM_ALERT_TYPE alertType, const double& indiBuff[], const ENUM_PROCESS_LEVELS& level, const string& processLevel, const double& offsetValue, const color& txtClr); // Place text on the display for the values inthe alert buffer (indiBuff[])
      void MakeTextObject(const ENUM_ALERT_TYPE& alertType, const ENUM_PROCESS_LEVELS& level, const string processLevel, const double& alertBarPrice, const int& refBar, const datetime& alertBarTime, const double& offsetValue, const color dispClr);  // place a text display object on the chart
 }; // ========= End Definition; Class to display Alert Labels  ===========
static double          C_AlertObjectDisplay::m_lastAlertPrice    = NULL;  // Initialize Static class variables
static datetime        C_AlertObjectDisplay::m_lastAlertTime     = NULL;
static ENUM_ALERT_TYPE C_AlertObjectDisplay::m_lastAlertType     = NULL;
// ========= End Static variables initialization; Class to display Alert Labels  ===========
//+------------------------------------------------------------------------------+
//| Class for Processing the Level Indicator Signal                              |
//+------------------------------------------------------------------------------+
class C_ProcessLevel  // one instance of this class for each level of semaphore to display.
 {
   private:
      bool m_debugTrigger;
      datetime m_savedDnBarUpdateTime, m_savedUpBarUpdateTime;
      C_TimeUtilities* m_timeUtilities;
      C_AlertObjectDisplay* m_alertObjectDisplay;
      uint m_highAlertMarkCounter, m_lowAlertMarkCounter;
      ENUM_PROCESS_LEVELS m_level;
      string m_processLevel;
      ENUM_SWING_TYPE m_newBarSwing, m_runningSwing;
      int m_referenceUpBar, m_referenceDnBar;
      datetime m_referenceUpBarTime, m_referenceDnBarTime;
      double m_runningSwingHi, m_runningSwingLo;
      double m_barOffsetValue;
      int    m_length;
      color  m_upClr, m_dnClr;
      void PrintDebugMsg(const int& workingBar, const string& dgbStr); // Just a simple control to print a debug string and/or set a breakpoint for debugging
      void DetectNewSwing(const int& workBar, const double& firstBarLo, const double& firstBarHi, const double& lengthLo, const double& lengthHi);  // Detect the working bar's swing
      void LoadIndiBuffers(double& upBuf[], double& dnBuf[], const double& firstBarHi, const double& firstBarLo);
      void SetSwingBarValues(const int& workBar, const ENUM_SWING_TYPE& swing, const double& firstBarHi, const double& firstBarLo);
      void MakeTheSignals(const ENUM_ALERT_TYPE alertType, uint& markCounter, const int& refBar, const datetime refBarTime, const double& refBarSwingVal, const color& sigClr, double& signalBuf[]);
   protected:
      void PerformAlerts(const ENUM_ALERT_TYPE alertType, const string& processLevel, const datetime BarTime, const int& barNum, const double& alertPrice);
      void SetTheSwingIndicator(double& indiUpBuf[], double& indiDnBuf[], const int& length, const int& workBar);
   public:
      void C_ProcessLevel(const int& len, const ENUM_PROCESS_LEVELS& m_level, const string& processLevel, const int& oldestBar, const double& barOffsetValue, const color& upClr, const color& dnClr);  // Constructor
      void ~C_ProcessLevel(void); // destructor
      void TurnTextDisplayOnOff(const ENUM_ON_OFF onOff, const double& upBuff[], const double& dnBuff[]);  // Turn the Display of Text on or off
      void SetSwingIndication(const int& workBar, double& highBuff[], double& lowBuff[]); // public function to calculate and display the swing for a bar.
 }; //==== END C_ProcessLevel Class =======
C_ProcessLevel *c_processLevel_ary[endProcessLevels];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
 {
   ENUM_INIT_RETCODE retCode = INIT_SUCCEEDED;
   indicatorName = IntegerToString(Uniquifier)+"ZZ_"+indicatorName;
   IndicatorShortName(indicatorName);
   //===== Find the minimum required Bars for the indicator to work ===
   int  ary_level_lengths[endProcessLevels];
   ary_level_lengths[LEVEL_1] = Level_1_Length;
   ary_level_lengths[LEVEL_2] = Level_2_Length;
   ary_level_lengths[LEVEL_3] = Level_3_Length;
   ary_level_lengths[LEVEL_4] = Level_4_Length;
   minBars = ary_level_lengths[ArrayMaximum(ary_level_lengths,WHOLE_ARRAY,0)]+1;
   int oldestUsableBar = iBars(_Symbol,PERIOD_CURRENT)-minBars;
   if(oldestUsableBar>(99999-minBars))  // MQ5 testing has shown bars older than 99999 may not have valid data.
      oldestUsableBar=99999-minBars;
   oldestUsableBarTime = iTime(_Symbol,PERIOD_CURRENT,oldestUsableBar);
   //===== Initialize The Indicator Buffers =========
   for(ENUM_INDI_IDX idx=0; idx<endIndiIdx; idx++)  // Initialize the Buffer for each class instance
    {
      c_indiBuffers_ary[idx].Initialize(idx, indiLabel[idx], indiClr[idx], indiWidth[idx], indiDraw[idx], indiChar[idx], drawStyle[idx]);
      c_indiBuffers_ary[idx].SetDrawingOnOff(c_indiCtrl.GetControlState(INDI_STATE)); //=== Turn Drawing off if so instructed ===========
    }
   //===== Get an offset value for placing the marks just a little away from the bars on the chart
   double atrOffsetValue=iATR(_Symbol,PERIOD_CURRENT,100,0);  // get a value to offset the signal from the bar on the chart a little.
   atrOffsetValue=(atrOffsetValue>0)?(atrOffsetValue/3):0;
   //===== Create the Class Objects to process the levels =========
   for(ENUM_PROCESS_LEVELS idx = 0; idx<endProcessLevels; idx++ )
    {
      if(c_processLevel_ary[idx] == NULL )  // Create and initialze an object for each signal level.
       {
         c_processLevel_ary[idx] = new C_ProcessLevel(ary_level_lengths[idx], idx, processLevel_ary[idx],oldestUsableBar, atrOffsetValue, indiClr[idx*2],indiClr[(idx*2)+1]);  //make an object and feed the constructor
         if( c_processLevel_ary[idx] == NULL )  // New object not created?  Disaster, post the error.
          {
            retCode = INIT_FAILED;
            int errCode = GetLastError();
            msgString = __FUNCTION__+" Initialization Failed, error: "+IntegerToString(errCode)+", "+ErrorDescription(errCode);
            Print(msgString);  // Comment(msgString);
          }else  // successful creation of object, initialize values in it
          {
            c_processLevel_ary[idx].TurnTextDisplayOnOff(c_indiCtrl.GetControlState(TEXT_STATE),c_indiBuffers_ary[2*idx].indiBuf, c_indiBuffers_ary[(2*idx)+1].indiBuf);
          }
       }
    }
   return retCode;
 }//==== END OnInit ===========
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
 {
   for(ENUM_PROCESS_LEVELS idx = 0; idx<endProcessLevels; idx++ )  // Delete objects created by the program
    {
      if( c_processLevel_ary[idx] != NULL )
       {
         delete c_processLevel_ary[idx]; c_processLevel_ary[idx]=NULL;
       }
    }
   //ObjectsDeleteAll(ChartID(),IntegerToString(Uniquifier));
   if(StringLen(msgString)>0) // Remove comments made using msgString from the display
    {
      Comment("");
    }
 }//==== END OnDeinit ===========
//+------------------------------------------------------------------+
//| Chart Event Handler                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
 {
   if(id==CHARTEVENT_CUSTOM+CHARTEVENT_RUNINDI)  // Run the Indicator Customer Event; Do the work of the indicator
    {
      if(dparam==Uniquifier)   // ensure the event is for this indicator
       {
         int limit = (int) lparam;
         RunTheIndicator(limit);
       }
    }else if(id==CHARTEVENT_OBJECT_CLICK)
    {
      if( sparam==c_indiCtrl.GetControlName(INDI_STATE) ) // change the state of the indicator if the name matches
       {
         ENUM_ON_OFF stateToSet = c_indiCtrl.GetControlState(INDI_STATE)==ON?OFF:ON;  // Toggle between on and off
         c_indiCtrl.SaveIndiDispState(stateToSet);
         c_indiCtrl.SaveIndiTextState(stateToSet);
         for(ENUM_INDI_IDX idx=0; idx<endIndiIdx; idx++)
          {
            c_indiBuffers_ary[idx].SetDrawingOnOff(stateToSet);
          }
         ProcessLevelTextOnOff(stateToSet);
         c_indiCtrl.DisplayCntrlObjs();
         WindowRedraw();
       }else if( sparam==c_indiCtrl.GetControlName(TEXT_STATE) ) // Change the state of the text display if the name matches
       {
         ENUM_ON_OFF stateToSet = c_indiCtrl.GetControlState(TEXT_STATE)==ON?OFF:ON;  // Toggle between on and off
         c_indiCtrl.SaveIndiTextState(stateToSet);
         ProcessLevelTextOnOff(stateToSet);
         c_indiCtrl.DisplayCntrlObjs();
         WindowRedraw();
       }
    }
 } //==== END OnChartEvent ==========
void ProcessLevelTextOnOff(const ENUM_ON_OFF& onOff) // Common event code for CHARTEVENT_OBJECT_CLICK
 {
   for(ENUM_PROCESS_LEVELS idx = 0; idx<endProcessLevels; idx++ )
    {
      if(c_processLevel_ary[idx] != NULL ) // Object Exists
         c_processLevel_ary[idx].TurnTextDisplayOnOff(onOff,c_indiBuffers_ary[2*idx].indiBuf, c_indiBuffers_ary[(2*idx)+1].indiBuf);
    }
 }//==== END ProcessLevelTextOnOff =====
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[], const long& tick_volume[], const long& volume[], const int& spread[] )
 {
   int firstBar=0;
   if(rates_total-prev_calculated > 0 )  // Only run when there is a new bar
    {
      if(prev_calculated<1)  // First Run
       {
         firstBar=rates_total-minBars;
         int oldestUsableBar = iBarShift(_Symbol,PERIOD_CURRENT,oldestUsableBarTime,false);  // This bar time was set in OnInit. 
         if(firstBar>oldestUsableBar)  // Testing with MQ5 has shown that data for bars greater than 99,9999 is unreliable (often - if not always - not there)
             firstBar=oldestUsableBar;
         if(firstBar<0)  // Cannot run without enough bars
          {
            msgString=indicatorName+" Not Enough Bars, requires "+IntegerToString(minBars)+" Bars, Bars Found are: "+IntegerToString(rates_total);
            Comment(msgString); Print(msgString);
            return 0;  // nothing calculated, next event will execute 'First Run'
          }
         globalIsTestingFlag = IsTesting();  // Find out if the Indicator is running in the strategy tester
         // Print(__FUNCTION__," Is Testing: ",((globalIsTestingFlag==true)?"TRUE":"FALSE"));
         c_indiCtrl.DisplayCntrlObjs();
       }
      else  // has run before, checck new bars
       {
         firstBar = rates_total-prev_calculated;
       }
      //
      if(globalIsTestingFlag) // will fail in the strategy tester with high rate of quotes being submitted if just posting an event
       {
         RunTheIndicator(firstBar);  // Directly run the indicator
       }
      else
       {
         EventChartCustom(ChartID(),CHARTEVENT_RUNINDI, firstBar, Uniquifier);  // Post an event to run the indicator
       }
    }
   return rates_total;
 } //====== END OnCalculate ================
//+-------------------------------------------------------------------------------------------+
//| RunTheIndicator starts the actual work of the indicator                                   |
//+-------------------------------------------------------------------------------------------+
void RunTheIndicator(const int& firstBar)  // Run the indicator
 {
   for(int barIdx=firstBar; barIdx>0; --barIdx)  // for all not calculated bars
    {
      for(ENUM_PROCESS_LEVELS levelIdx = 0; levelIdx<endProcessLevels; ++levelIdx )  // Run the indicator for Each Level instance
       {
         c_processLevel_ary[levelIdx].SetSwingIndication(barIdx, c_indiBuffers_ary[2*levelIdx].indiBuf, c_indiBuffers_ary[(2*levelIdx)+1].indiBuf);  // Pass the applicable Indicator buffers to each level instance.
       }
    }
 }//===== End RunTheIndicator =========
//+------------------------------------------------------------------------------------------------------------------+
//+-------------------------------------------------------------------------------------------+
//| Function Definitions for Class to initialize and hold the drawing plots of the indicator  |
//+-------------------------------------------------------------------------------------------+
void C_IndiBuffers::initialzeIndicatorBuffer(const ENUM_INDI_IDX& bufNum, const string& label, const color& clr, const int& width
                                   ,const int& draw, const int& drawString, const ENUM_LINE_STYLE& style, const int& firstDraw)
       {  // Initialize the indicator buffer characteristics for the buffer number
         SetIndexBuffer( bufNum, indiBuf );
         SetIndexLabel ( bufNum, label   );
         SetIndexStyle ( bufNum, draw, style, width, clr );
         SetIndexArrow ( bufNum, drawString);
         SetIndexShift ( bufNum, 0       );
         SetIndexEmptyValue( bufNum, EMPTY_VALUE );
         SetIndexDrawBegin ( bufNum, firstDraw );
       } //==== EMD initialzeIndicatorBuffer =========
void C_IndiBuffers::Initialize(const ENUM_INDI_IDX& bufNum, const string& label, const color& clr, const int& width
                        ,const int& draw, const int& drawString, const ENUM_LINE_STYLE& style)
       {  // public function to initialize the indicator buffer for the class instance (object), most work is done in initialzeIndicatorBuffer
         int firstDraw = 0;
         initialzeIndicatorBuffer(bufNum, label, clr, width, draw, drawString, style, firstDraw); // call to initialize the indicator buffer characteristics for the buffer number
         m_buffNum=bufNum; m_indiDraw=draw; m_style=style; m_width=width; m_clr=clr; // Store the indicator characteristics in the buffer object.
         IndicatorDigits(_Digits + 1);  // Gets called identically for each buffer; it won't hurt.
       } //==== EMD Initialize =========
void C_IndiBuffers::SetDrawingOnOff(const ENUM_ON_OFF onOff)
 {
   if(onOff==ON)
    {
      SetIndexStyle( m_buffNum, m_indiDraw, m_style, m_width, m_clr );
    }else  // Turn Off
    {
      SetIndexStyle( m_buffNum, DRAW_NONE, m_style, m_width, m_clr );
    }
 }
//======= END C_IndiBuffers Class ============
//+------------------------------------------------------------------------------+
//| Function Definitions for Class for utilities associated with Time            |
//+------------------------------------------------------------------------------+
static string C_TimeUtilities::TimeFrameToString(ENUM_TIMEFRAMES tf)  // Get a string for the time frame
       {
         string tfs;
         switch (tf)
          {
            case PERIOD_M1:  tfs="M1";  break;
            case PERIOD_M5:  tfs="M5";  break;
            case PERIOD_M15: tfs="M15"; break;
            case PERIOD_M30: tfs="M30"; break;
            case PERIOD_H1:  tfs="H1";  break;
            case PERIOD_H4:  tfs="H4";  break;
            case PERIOD_D1:  tfs="D1";  break;
            case PERIOD_W1:  tfs="W1";  break;
            case PERIOD_MN1: tfs="MN";  break;
            default: tfs="UNK";         break;
          }
         return tfs;
       }//=== END TimeFrameToString ==============
//====== END C_TimeUtilities Class ==================
//+------------------------------------------------------------------------------+
//| Function Bodies for the Class for Processing the Level Indicator Signal |
//+------------------------------------------------------------------------------+
void C_ProcessLevel::PrintDebugMsg(const int& workingBar, const string& dgbStr)
       {  // Just a simple control to print a debug string and/or set a breakpoint for debugging
         if(workingBar<2) // On the current chart
          {
            Print(dgbStr);
            if(workingBar<2)
             {
               string debugPoint = dgbStr; // does nothing but provide a spot to set a breakpoint
             }
          }
       } // ====== END PrintDebugMsg ==========
void C_ProcessLevel::DetectNewSwing(const int& workBar, const double& workBarLo, const double& workBarHi, const double& lengthLo, const double& lengthHi) 
       {  // Detect the working bar's swing
         if( (workBarLo<lengthLo) && (workBarHi>lengthHi) )  // New bar encapsulated previous 'length' bars
          {
            m_newBarSwing=SWING_HI_AND_LO;   // New bar encapsulated previous 'length' bars, it swings both High and Low
            if(m_runningSwing==SWING_HI)     // Continue the Up Swing Indication
             {
               m_referenceUpBar     = workBar+1;  // Adjust the refernce bar that the swing length is for.
               m_referenceUpBarTime = iTime(_Symbol, PERIOD_CURRENT, m_referenceUpBar);
             }
            else if(m_runningSwing==SWING_LO)     // Continue the Down Swing Indication
             {
               m_referenceDnBar     = workBar+1;  // Adjust the refernce bar that the swing length is for.
               m_referenceDnBarTime = iTime(_Symbol, PERIOD_CURRENT, m_referenceDnBar);
             }
          }
         else  // Check if its a swigh high or a swing low
          {
            if(workBarLo<lengthLo)
               m_newBarSwing = SWING_LO; // A bar lower than previous 'length' bars has occured
            else if(workBarHi>lengthHi)
               m_newBarSwing = SWING_HI; // A bar higher than previous 'length' bars has occured
          }
        }//======== END DetectNewSwing ========
void C_ProcessLevel::LoadIndiBuffers(double& upBuf[], double& dnBuf[], const double& workBarLo, const double& workBarHi)
       {
         if( (m_newBarSwing!=m_runningSwing) && (m_runningSwing!=SWING_NOT_SET) )  // The Swing changed
          {
            if(m_newBarSwing==SWING_HI_AND_LO)
             {
               m_newBarSwing    = (m_runningSwing==SWING_HI)?SWING_LO:SWING_HI;  // Choose the opposit running type, cause Semaphore to be dropped on chart
               m_runningSwingHi = workBarHi;      // and update the running swing's high
               m_runningSwingLo = workBarLo;      // and update the running swing's low
             }
            switch (m_newBarSwing)// Record the swing at the reference bar location
             {
               case SWING_HI:
                  if(m_referenceDnBarTime != m_savedDnBarUpdateTime)  // Do it once, or the alert will go off many times
                   {
                     MakeTheSignals(HIGH_ALERT, m_highAlertMarkCounter, m_referenceDnBar, m_referenceDnBarTime, m_runningSwingLo, m_upClr, upBuf);
                     m_savedDnBarUpdateTime = m_referenceDnBarTime;   // Update so alert will not happen again for the same bar
                   }
                  break;
               case SWING_LO:
                  if(m_referenceUpBarTime != m_savedUpBarUpdateTime)  // Do it once, or the alert will go off many times
                   {
                     MakeTheSignals(LOW_ALERT, m_lowAlertMarkCounter, m_referenceUpBar, m_referenceUpBarTime, m_runningSwingHi, m_dnClr, dnBuf);
                     m_savedUpBarUpdateTime = m_referenceUpBarTime;  // Update so alert will not happen again for the same bar
                   }
                  break;
               default: // broken, do nothing.
                  msgString = __FUNCTION__+" is broken, Invalid Swing value in m_newBarSwing: "+IntegerToString(m_newBarSwing);
                  Print(msgString); Comment(msgString);
                  break;
             }
            m_runningSwingHi = workBarHi;  // Dropped a semafor, update the starting values for the next semafor
            m_runningSwingLo = workBarLo;
          }
        }//======  END LoadIndiBuffers ============
void C_ProcessLevel::MakeTheSignals(const ENUM_ALERT_TYPE alertType, uint& markCounter, const int& refBar, const datetime refBarTime, const double& refBarSwingVal, const color& sigClr, double& signalBuf[])
       { // Peform the work 0f alerting with a semafor on the chart and other alerts, helper for LoadIndiBuffers
         markCounter++;
         double posPrice   = (alertType==HIGH_ALERT)?refBarSwingVal-m_barOffsetValue:refBarSwingVal+m_barOffsetValue;
         signalBuf[refBar] = posPrice;
         m_alertObjectDisplay.MakeTextObject(alertType, m_level, m_processLevel, refBarSwingVal, refBar, refBarTime, m_barOffsetValue, sigClr);
         PerformAlerts(alertType, m_processLevel, refBarTime, refBar, refBarSwingVal);
       } // === END MakeTheSignals =====
void C_ProcessLevel::SetSwingBarValues(const int& workBar, const ENUM_SWING_TYPE& newBarSwing, const double& workBarLo, const double& workBarHi)
       {
         switch (newBarSwing)
          {
            case SWING_HI:
               if(workBarHi>=m_runningSwingHi)  // If new high, ensure high values match
                {
                  m_runningSwingHi      = workBarHi;  // Update to the current high
                  m_referenceUpBar      = workBar;     // update to the newest up bar in Length
                  m_referenceUpBarTime  = iTime(_Symbol,PERIOD_CURRENT,workBar); // update to the newest up bar time in Length
                }
               break;
            case SWING_LO:
               if(workBarLo<=m_runningSwingLo)  // If new low, ensure low values match
                {
                  m_runningSwingLo     = workBarLo;  // Update to the current low
                  m_referenceDnBar     = workBar;     // updateto the newst dn bar in length
                  m_referenceDnBarTime = iTime(_Symbol,PERIOD_CURRENT,workBar);  // update to the newest up bar time in Length
                }
               break;
            default: // do nothing for SWING_NOT_SET or SWING_HI_AND_LO
               break;
          }
         m_runningSwing = m_newBarSwing;  // the running swing is what the new bar's swing is
       }//=== END C_ProcessLevel::SetSwingBarValues ===========
void C_ProcessLevel::PerformAlerts(const ENUM_ALERT_TYPE alertType, const string& processLevel, const datetime BarTime, const int& barNum, const double& alertPrice)
       { // Provides Alerts when a New Semafor is set on the chart
         static string timeFrameString = C_TimeUtilities::TimeFrameToString( (ENUM_TIMEFRAMES) Period()); // compiler compilees without being declcared static, Code Checker insists it be declared static
         string alertMsg, soundFile;
         if( (!SoundAlert) || (barNum>m_length) )  // is it on? -- and don't alert for all the historical signals on first run.
          {
            return;  // don't do anything
          }
         switch (alertType)
          {
            case HIGH_ALERT:
               alertMsg = indicatorName+", "+_Symbol+", "+timeFrameString+", High Alert, "+": "+processLevel+" at bar: "+IntegerToString(barNum)+DoubleToStr(alertPrice,_Digits);
               soundFile = myUpperSoundFile;
               break;
            case LOW_ALERT:
               alertMsg = indicatorName+", "+_Symbol+", "+timeFrameString+", Low Alert, "+": "+processLevel+" at bar: "+IntegerToString(barNum)+DoubleToStr(alertPrice,_Digits);
               soundFile = myLowerSoundFile;
               break;
            default:
               alertMsg = indicatorName+", "+_Symbol+", "+timeFrameString+", UNKNOWN Alert, "+": "+processLevel+" at bar: "+IntegerToString(barNum)+DoubleToStr(alertPrice,_Digits);
               soundFile = ""; // Find a dud sound?
               break;
          }
         Alert(alertMsg);        // Put the alert up for display
         if(globalIsTestingFlag) // Alert doesn't work in the strategy tester
            Print(alertMsg);     // provide the alert when using the strategy tester
         PlaySound(soundFile);   // Play the sound for the alert
       }//==== END C_ProcessLevel::PerformAlerts ============
void C_ProcessLevel::SetTheSwingIndicator(double& indiUpBuf[], double& indiDnBuf[], const int& length, const int& workBar)
       {  // This starts the work for detecting a semafor and postig associated alerts
         double lengthHi,lengthLo, workBarHi, workBarLo;
         m_referenceUpBar = iBarShift(_Symbol, PERIOD_CURRENT, m_referenceUpBarTime, false);  // If a single new bar has accoured, it will be one larger than the previous run's value
         m_referenceDnBar = iBarShift(_Symbol, PERIOD_CURRENT, m_referenceDnBarTime, false);  // If a single new bar has accoured, it will be one larger than the previous run's value
         //
         lengthHi  = iHigh(_Symbol,PERIOD_CURRENT,iHighest(NULL,0,MODE_HIGH,length,workBar+1));
         lengthLo  = iLow (_Symbol,PERIOD_CURRENT,iLowest (NULL,0,MODE_LOW, length,workBar+1));
         workBarHi = iHigh(_Symbol,PERIOD_CURRENT,workBar);
         workBarLo = iLow (_Symbol,PERIOD_CURRENT,workBar);
         // msgString = m_processLevel+", Length: "+IntegerToString(length)+"Work Bar: "+IntegerToString(workBar)+", High: "+DoubleToStr(firstBarHi,_Digits)+", Low: "+DoubleToString(firstBarLo,_Digits);
         // PrintDebugMsg(workBar, msgString);
         DetectNewSwing(workBar, workBarLo, workBarHi, lengthLo, lengthHi);
         LoadIndiBuffers(indiUpBuf, indiDnBuf, workBarLo, workBarHi);
         SetSwingBarValues(workBar, m_newBarSwing, workBarLo, workBarHi);
       }//==== END C_ProcessLevel::SetTheSwingIndicator ===========
void C_ProcessLevel::C_ProcessLevel(const int& len, const ENUM_PROCESS_LEVELS& level, const string& processLevel, const int& oldestBar, const double& barOffsetValue, const color& upClr, const color& dnClr)  // Constructor
       {  // Constructor, initialize everything for this instance
         m_debugTrigger = false;  // used for debuging; there is one left active that shows the up and down semafor counts; they should be about equal over time
         m_highAlertMarkCounter = 0; m_lowAlertMarkCounter = 0;
         m_savedUpBarUpdateTime = NULL; m_savedDnBarUpdateTime = NULL;
         m_barOffsetValue = barOffsetValue;
         m_length = len;
         m_level  = level;
         m_processLevel = processLevel;
         m_newBarSwing=SWING_NOT_SET; m_runningSwing=SWING_NOT_SET;
         m_referenceUpBar=oldestBar; m_referenceDnBar=oldestBar;
         m_runningSwingHi=iHigh(_Symbol,PERIOD_CURRENT,oldestBar); m_runningSwingLo=iLow(_Symbol,PERIOD_CURRENT,oldestBar);
         m_referenceDnBarTime = iTime(_Symbol,PERIOD_CURRENT,oldestBar);
         m_referenceUpBarTime = m_referenceDnBarTime;
         m_upClr = upClr;
         m_dnClr = dnClr;
         //
         m_timeUtilities      = new C_TimeUtilities;
         if(m_timeUtilities==NULL) // Object not created - If this happens, the running environment is broken
            Print(__FUNCTION__+" did not create a new C_TimeUtilities object, Error Code: "+IntegerToString(GetLastError()));
         m_alertObjectDisplay = new C_AlertObjectDisplay;
         if(m_alertObjectDisplay==NULL) // Object not created - If this happens, the running environment is broken
            Print(__FUNCTION__+" did not create a new C_AlertObjectDisplay object, Error Code: "+IntegerToString(GetLastError()));
       } //==== END Constructor C_ProcessLevel::C_ProcessLevel ============
void C_ProcessLevel::~C_ProcessLevel(void)  // Destructor
       {
         if(m_timeUtilities != NULL)
            {delete m_timeUtilities; m_timeUtilities=NULL;}  // Clean up created object
         if(m_alertObjectDisplay != NULL)
            {delete m_alertObjectDisplay; m_alertObjectDisplay=NULL;} // Clean up created object
       }//==== END Desctructor C_ProcessLevel::~C_ProcessLevel ============
void C_ProcessLevel::TurnTextDisplayOnOff(const ENUM_ON_OFF onOff, const double& upBuff[], const double& dnBuff[])  // Turn the Display of Text on or off
       {
         switch (onOff)
          {
            case OFF:
               m_alertObjectDisplay.SetTextOnOff(OFF);
               break;
            case ON:
            default:
               m_alertObjectDisplay.SetTextOnOff(ON);
               m_alertObjectDisplay.MakeHistoricalText(HIGH_ALERT, dnBuff, m_level, m_processLevel, m_barOffsetValue, m_upClr);
               m_alertObjectDisplay.MakeHistoricalText(LOW_ALERT,  upBuff, m_level, m_processLevel, m_barOffsetValue, m_dnClr);
               break;
          }
       }//==== END C_ProcessLevel::TurnTextDisplayOnOff ============
void C_ProcessLevel::SetSwingIndication(const int& workBar, double& highBuff[], double& lowBuff[])  // public function to calculate and display the swing for a bar.
       {  // Sart the work to detect a semafor and post associated alerts
         SetTheSwingIndicator(highBuff, lowBuff, m_length, workBar);
         if(m_debugTrigger == true && workBar==1) // Print on the first Bar Zero.  Level: 0 == White, 1 == Red, 2 == Yellow, 3 == limeGreen
          { //m_highAlertMarkCounter, m_lowAlertMarkCounter;  These counts should be about equal over time
            msgString = "Level "+IntegerToString(m_level)+", Up Signal Count: "+IntegerToString(m_highAlertMarkCounter)+", Down Signal Count: "+IntegerToString(m_lowAlertMarkCounter);
            Print(msgString); // Comment(msgString);
            m_debugTrigger = false;
          }
       }//=== END  C_ProcessLevel::SetSwingIndication ============
//==== END C_ProcessLevel Class Function Bodies =======
//+----------------------------------------------------------------------------------------------------------------------------+
//| function body for each function in the Class for Controlling the Indicator State, Displaying the indicator Control Objects |
//+----------------------------------------------------------------------------------------------------------------------------+
string C_IndicatorControl::GetVariableName(const ENUM_DISP_OBJ_IDX& objIdxToName)  // Function to create the name of the text object
       {
         string varName;
         m_callCounter++;
         switch (objIdxToName)
          {
            case INDI_STATE: varName = IntegerToString(Uniquifier)+"_"+m_indiName+"_INDI_DISP_ST"; break;
            case TEXT_STATE: varName = IntegerToString(Uniquifier)+"_"+m_indiName+"_TEXT_DISP_ST"; break;
            default:         varName = IntegerToString(Uniquifier)+"_"+m_indiName+"_UNKNOWN";
               msgString = "Unknown Variable to Name, ID: "+IntegerToString(objIdxToName);
               Print(msgString); Comment(msgString);
               break;
          }
         // Print(__FUNCTION__+", Call: "+IntegerToString(m_callCounter)+", Variable Name: "+varName);
         return varName;
       }//======= END GetVariableName ========
void C_IndicatorControl::SaveGlobalVariableValue(const ENUM_DISP_OBJ_IDX variableToSave, const ENUM_ON_OFF& valueToSave)  // Function to store the display state associated with the control variable 
       {
         string varName = GetVariableName(variableToSave);
         m_callCounter++;
         if( GlobalVariableSet( varName, valueToSave)==0)  // Returns zero on error, otherwise, time
          {
            int errCode = GetLastError();
            msgString=__FUNCTION__+" Failed for "+varName+", error: "+IntegerToString(errCode)+", "+ErrorDescription(errCode);
            Print(msgString); Comment(msgString);
          }
         // Print(__FUNCTION__+", Call: "+IntegerToString(m_callCounter)+", Variable Name: "+varName+", Value To Save: "+IntegerToString(variableToSave));
       }//======= END SaveGlobalVariableValue ========
ENUM_ON_OFF C_IndicatorControl::GetGlobalVariableValue(const ENUM_DISP_OBJ_IDX variableToGet)  // Function to retrive the state associated iwth the control variable
       {
         ENUM_ON_OFF varValue = ON;
         string varName = GetVariableName(variableToGet);
         m_callCounter++;
         if( GlobalVariableCheck(varName) )
          {
            double retrieveValue;
            if(GlobalVariableGet( varName, retrieveValue ))
             {
               varValue = (ENUM_ON_OFF) retrieveValue;  // convert global 'double' value to enum on/off value
             }else{
               int errCode = GetLastError();
               msgString = "Golbal variable retrieve failed, error: "+IntegerToString(errCode)+", "+ErrorDescription(errCode);
               Print(msgString); Comment(msgString);
             }
          }
         // Print(__FUNCTION__+", Call: "+IntegerToString(m_callCounter)+", Variable Name: "+varName+", Value Gotten: "+IntegerToString(varValue));
         return varValue;
       }//======= END GetGlobalVariableValue ========
void C_IndicatorControl::ManageALabel(const string& objName, const string ctrlText, const int xPos, const int yPos, const color& txtClr)  // Create or update a lable object and display it.
       {
         static long chartID = ChartID();
         if ( ObjectFind(chartID,objName) < 0 )
          {
            ObjectCreate    (chartID, objName, OBJ_LABEL, WINDOWZERO,  0, 0);
            ObjectSetInteger(chartID, objName, OBJPROP_FONTSIZE,  9);
            ObjectSetString (chartID, objName, OBJPROP_FONT,      "Arial");
            ObjectSetInteger(chartID, objName, OBJPROP_CORNER,    CORNER_LEFT_LOWER);
            ObjectSetInteger(chartID, objName, OBJPROP_ANCHOR,    ANCHOR_LEFT);
            ObjectSetInteger(chartID, objName, OBJPROP_BACK,      true); 
            ObjectSetInteger(chartID, objName, OBJPROP_SELECTABLE,true); 
            ObjectSetInteger(chartID, objName, OBJPROP_SELECTED,  false); 
            ObjectSetInteger(chartID, objName, OBJPROP_HIDDEN,    false);
          }
         ObjectSetInteger(chartID, objName, OBJPROP_COLOR,     txtClr);
         ObjectSetInteger(chartID, objName, OBJPROP_XDISTANCE, xPos );
         ObjectSetInteger(chartID, objName, OBJPROP_YDISTANCE, yPos );
         ObjectSetString (chartID, objName, OBJPROP_TEXT,      ctrlText );
       } // ========= END ManageTextObject ==========
void C_IndicatorControl::C_IndicatorControl(void) // Constructor , initialize everything
       {
         m_indiName = indicatorName;
         m_objName[INDI_STATE] = IntegerToString(Uniquifier)+"INDI_STATE";
         m_objName[TEXT_STATE] = IntegerToString(Uniquifier)+"TEXT_STATE";
         m_yPos[INDI_STATE] = ControlOffset; m_yPos[TEXT_STATE] = ControlOffset;
         m_xPos[INDI_STATE] = ControlOffset; m_xPos[TEXT_STATE] = ControlOffset+120;
         m_txtClr    = clrLimeGreen;
         m_indiState = GetGlobalVariableValue(INDI_STATE);
         m_textState = GetGlobalVariableValue(TEXT_STATE);
       }//===  END Constructor, C_IndicatorControl ============
void C_IndicatorControl::~C_IndicatorControl(void) // Destructor
       {
         for(int idx=0; idx<ArrayRange(m_objName,0); idx++)  // delete the object label controls from the display
          {
            ObjectDelete(m_objName[idx]);
          }
       }//===  END Destructor, ~C_IndicatorControl ============
string C_IndicatorControl::GetControlName(const ENUM_DISP_OBJ_IDX objIdx)  // Get the OBJECT_LABLE anme for the control object
       { 
         string objName;
         if(objIdx>=0 && objIdx<endDispObjIdx)  // Valid value passed
          {
            objName = m_objName[objIdx]; // Get the OBJ_LABEL object name.
          }else{
            objName = "UNKNOWN";
            msgString = __FUNCTION__+" Called with invalid object ID: "+IntegerToString(objIdx);
            Print(msgString); Comment(msgString);
          }
         return objName;
       }//===  END C_IndicatorControl::GetControlName ============
ENUM_ON_OFF C_IndicatorControl::GetControlState(const ENUM_DISP_OBJ_IDX objIdx) // return the on/off state associated with the control (OBJ_LABEL)
       {
         ENUM_ON_OFF onOff;
         switch(objIdx)
          {
            case INDI_STATE: onOff=m_indiState; break;
            case TEXT_STATE: onOff=m_textState; break;
            default:
               onOff=ON;
               msgString = __FUNCTION__+" Called with invalid object ID: "+IntegerToString(objIdx);
               Print(msgString); Comment(msgString);
               break;
          }
         return onOff;
       }//=====  END C_IndicatorControl::GetControlState =============
string C_IndicatorControl::GetIndiCtrlText(const ENUM_DISP_OBJ_IDX& objIdx)  // return the text to display for the control (OBJ_LABEL)
       {
         string dispText;
         switch (objIdx)
          {
            case INDI_STATE:
               switch(m_indiState)
                {
                  case ON:  dispText = IntegerToString(Uniquifier)+"_"+m_indiName + ": ON";  break;
                  case OFF: dispText = IntegerToString(Uniquifier)+"_"+m_indiName + ": OFF"; break;
                  default:  dispText = IntegerToString(Uniquifier)+"_"+m_indiName + ": UKN"; break;
                }
                break;
            case TEXT_STATE:
               if(m_indiState==ON)
                {
                  switch(m_textState)
                   {
                     case ON:  dispText = "TEXT_ON";  break;
                     case OFF: dispText = "TEXT_OFF"; break;
                     default:  dispText = "TEXT_UKN"; break;
                   }
                }else{
                  dispText=""; // Display nothing if the indicator is OFF 
                }
                break;
            default: dispText = "UNKNOWN_CTRL"; break;
          }
         return dispText;
       }//======== END C_IndicatorControl::GetIndiCtrlText ===========
void C_IndicatorControl::SaveIndiDispState(const ENUM_ON_OFF& indiDispState) // save the indicator display on/off state
       {
         SaveGlobalVariableValue(INDI_STATE, indiDispState);
         m_indiState = indiDispState;
       }//========= END C_IndicatorControl::SaveIndiDispState ============
void C_IndicatorControl::SaveIndiTextState(const ENUM_ON_OFF& indiTextState) // save the text display on/off state
       {
         SaveGlobalVariableValue(TEXT_STATE, indiTextState);
         m_textState = indiTextState;
       } //========= END C_IndicatorControl::SaveIndiTextStat =========
ENUM_ON_OFF C_IndicatorControl::RetrieveIndiDispState(void)  // get the display state (on or off) for the indiator (the semaphore)
       {
         return m_indiState;
       }// ======= END C_IndicatorControl::RetrieveIndiDispState ========
ENUM_ON_OFF C_IndicatorControl::RetrieveTextDispState(void)  // get the display state (on or off) for the semaphore text.
       {
         return m_textState;
       }// END C_IndicatorControl::RetrieveTextDispState ===========
int C_IndicatorControl::RetrieveObj_Y_Pos(const ENUM_DISP_OBJ_IDX& objIdx)  // provide the control object's y text position (OBJ_LABEL vertical position)
       {
         int position;
         switch(objIdx)
          {
            case INDI_STATE: position = m_yPos[INDI_STATE]; break;
            case TEXT_STATE: position = m_yPos[TEXT_STATE]; break;
            default: position = 20;
               msgString = __FUNCTION__+" called with invalid object index, value: "+IntegerToString(objIdx);
               break;
          }
         return position;
       }//========= END C_IndicatorControl::RetrieveObj_Y_Pos ==========
int C_IndicatorControl::RetrieveObj_X_Pos(const ENUM_DISP_OBJ_IDX& objIdx) // provide the control object's x text position (OBJ_LABEL horizontal position)
       {
         int position;
         switch(objIdx)
          {
            case INDI_STATE: position = m_xPos[INDI_STATE]; break;
            case TEXT_STATE: position = m_xPos[TEXT_STATE]; break;
            default: position = 20;
               msgString = __FUNCTION__+" called with invalid object index, value: "+IntegerToString(objIdx);
               break;
          }
         return position;
       }//===== END C_IndicatorControl::RetrieveObj_X_Pos ============
void C_IndicatorControl::DisplayCntrlObjs(void)  // draw the control objects (OBJ_LABEL objects) on the chart
       {
         for(ENUM_DISP_OBJ_IDX idx = 0; idx < endDispObjIdx; idx++)
          {
            ManageALabel(m_objName[idx], GetIndiCtrlText(idx), RetrieveObj_X_Pos(idx), RetrieveObj_Y_Pos(idx), m_txtClr);
          }
       }//======== END C_IndicatorControl::DisplayCntrlObjs ===========
// END Class C_IndicatorControl Function Bodies ====================
//+------------------------------------------------------------------------------+
//| Class Function Bodies for Clase to display Alert Labels                      |
//+------------------------------------------------------------------------------+
void C_AlertObjectDisplay::AddNameToArray(string& objName) // Place a name into the text object name array
       {
            m_objectNames[m_objNameIdx] = objName;
            m_objNameIdx++;
       } // ===== END C_AlertObjectDisplay::AddNameToArray ==========
void C_AlertObjectDisplay::ManageTextObject(const ENUM_ALERT_TYPE& alertType, const string processLevel, const double& alertPrice, const double& textPosPrice, const datetime& barTime, const datetime& textPosTime, const color dispClr) // Draw a new or updated text display object
       {
         string objName = GetAlertTextObjectName();
         string objText = DoubleToString(alertPrice,_Digits)+", "+TimeToString(barTime,TIME_MINUTES);
         if ( ObjectFind(m_chartID, objName) < 0 )
          {
            if(ObjectCreate(m_chartID, objName, OBJ_TEXT, WINDOWZERO, textPosTime, textPosPrice))
             {
               AddObjectToNameList(objName);
               ObjectSetInteger(m_chartID, objName, OBJPROP_FONTSIZE,  8);
               ObjectSetString (m_chartID, objName, OBJPROP_FONT,      "Arial");
               ObjectSetInteger(m_chartID, objName, OBJPROP_ANCHOR,    ANCHOR_LEFT);
               ObjectSetInteger(m_chartID, objName, OBJPROP_BACK,      true); 
               ObjectSetInteger(m_chartID, objName, OBJPROP_SELECTABLE,false); 
               ObjectSetInteger(m_chartID, objName, OBJPROP_SELECTED,  false); 
               ObjectSetInteger(m_chartID, objName, OBJPROP_HIDDEN,    false);
             }
            else
             {
               Print(__FUNCTION__,": failed to create \"Text\" object! Error code = ",GetLastError()); 
             }
          }
         ObjectSetInteger(m_chartID, objName, OBJPROP_COLOR,dispClr);
         ObjectMove      (m_chartID, objName, 0, textPosTime, textPosPrice);
         ObjectSetString (m_chartID, objName, OBJPROP_TEXT, objText );
       } // ========= END ManageALabel ==========
void C_AlertObjectDisplay::ResizeNamesArray( string& objNames[], int size ) // size the object names array
       {
         if(ArrayResize(objNames,size,2000) != size)  // check for a space allocation error (never happens in a healthy environment)
          {
            int errCode=GetLastError();
            Print(__FUNCTION__,": failed to allocate space for object names, Error code = ",IntegerToString(errCode),", "+ErrorDescription(errCode)); 
          }
       }//==== END C_AlertObjectDisplay::ResizeNamesArray ==============
void C_AlertObjectDisplay::AddObjectToNameList(string& objName) // Place a text object name in the name list 
       {
         if(m_objNameIdx < (ArrayRange(m_objectNames,0)-1))  // make sure there is a space availale for the text object name
          {
            AddNameToArray(objName);
          }
         else
          {
            ResizeNamesArray( m_objectNames, (ArrayRange(m_objectNames,0)+500) ); // make it bigger
            AddNameToArray(objName);
          }
       }//========= END C_AlertObjectDisplay::AddObjectToNameList ===============
string C_AlertObjectDisplay::GetAlertTextObjectName(void)  // Create the name for a text object (OBJECT_TEXT) to be displayed
       {
         return IntegerToString(Uniquifier)+DoubleToStr(m_lastAlertPrice,_Digits)+TimeToString(m_lastAlertTime,TIME_DATE|TIME_MINUTES)+((m_lastAlertType==HIGH_ALERT)?"Hi":"Lo");
       } //======== END C_AlertObjectDisplay::GetAlertTextObjectName ==========
double C_AlertObjectDisplay::GetBarPricefromAlertPrice(const ENUM_ALERT_TYPE& alertType, const ENUM_PROCESS_LEVELS& level, const double& posPrice, const double& offsetValue) // Given alert position price, get the bar price
       {
         double barPrice = (alertType==HIGH_ALERT)?posPrice-offsetValue:posPrice+offsetValue;
         return barPrice;
       }//==== END C_AlertObjectDisplay::GetBarPricefromAlertPrice =========== 
double C_AlertObjectDisplay::GetAlertPriceFromPositionPrice(const ENUM_ALERT_TYPE& alertType, const ENUM_PROCESS_LEVELS& level, const double& posPrice, const double& offsetValue) // Get the alert positiion price given the bar price
       {
         double alertPrice = (alertType==HIGH_ALERT)?(posPrice+offsetValue):(posPrice-offsetValue);
         return alertPrice;
       }//==== END C_AlertObjectDisplay::GetAlertPriceFromPositionPrice ===========
double C_AlertObjectDisplay::GetPositionPriceFromAlertPrice(const ENUM_ALERT_TYPE& alertType, const ENUM_PROCESS_LEVELS& level, const double& alertPrice, const double& offsetValue) // Given the Bar Price, provide the Alert Position Price
       {
         double posPrice = (alertType==HIGH_ALERT)?(alertPrice-offsetValue):(alertPrice+offsetValue);
         return posPrice;
       }//==== END C_AlertObjectDisplay::GetPositionPriceFromAlertPrice ============
datetime C_AlertObjectDisplay::GetPositionTimeFromRefBar(const ENUM_ALERT_TYPE& alertType, const ENUM_PROCESS_LEVELS& level, const int& refBar)  // Give a bar, provide a text display position time
       {
         datetime posTime  = iTime(_Symbol, PERIOD_CURRENT, refBar-(level+1));
         return posTime;
       }//==== END C_AlertObjectDisplay::GetPositionTimeFromRefBar ===========
void C_AlertObjectDisplay::C_AlertObjectDisplay(void) // Constructor, initialize things
       {
         ResizeNamesArray( m_objectNames, 500 );
         m_objNameIdx=0;
         m_textOn = ON;
       } //==== END Constructor C_AlertObjectDisplay::C_AlertObjectDisplay =============
void C_AlertObjectDisplay::~C_AlertObjectDisplay(void) // Destructor, delete objects
       {
         SetTextOnOff(OFF);
       } //===  END Destructor C_AlertObjectDisplay::~C_AlertObjectDisplay ============ 
void C_AlertObjectDisplay::SetAlertTimeAndPrice(const double& alertPrice, const datetime alertTime, const ENUM_ALERT_TYPE alertType) // save the alart time, price, and type
       {
            m_lastAlertPrice = NormalizeDouble(alertPrice,_Digits);
            m_lastAlertTime  = alertTime;
            m_lastAlertType  = alertType;
       }//==== END C_AlertObjectDisplay::SetAlertTimeAndPrice ===========
void C_AlertObjectDisplay::SetTextOnOff(ENUM_ON_OFF onOff) // save the text on or off state,and delete text objects if off
       {
         m_textOn = onOff;
         if(m_textOn == OFF)
          {
            for(int idx = ArrayRange(m_objectNames,0)-1; idx>=0; idx--)
             {
               ObjectDelete(m_chartID,m_objectNames[idx]);
               m_objectNames[idx] = "";
             }
             m_objNameIdx=0;
          }
       }//==== END C_AlertObjectDisplay::SetTextOnOff ==================
void C_AlertObjectDisplay::MakeHistoricalText(const ENUM_ALERT_TYPE alertType, const double& indiBuff[], const ENUM_PROCESS_LEVELS& level, const string& processLevel, const double& offsetValue, const color& txtClr) // Place text on the display for the values inthe alert buffer (indiBuff[])
       {
         for(int idx=ArrayRange(indiBuff,0)-1; idx>=0; idx--)
          {
            if(indiBuff[idx]!=EMPTY_VALUE) // has a real positive value
             {
               double alertPrice = GetAlertPriceFromPositionPrice(alertType, level, indiBuff[idx], offsetValue); // Position, where indi is displayed, Alert Price, where the object is displayed.
               double barPrice   = GetBarPricefromAlertPrice(alertType, level, indiBuff[idx], offsetValue);      // Bar Price - the high or low of the alerting bar
               datetime posTime = GetPositionTimeFromRefBar(alertType,  level, idx);                             //
               datetime barTime = iTime(_Symbol,PERIOD_CURRENT,idx);
               SetAlertTimeAndPrice(barPrice, barTime, alertType);
               ManageTextObject(alertType, processLevel, barPrice, alertPrice, barTime, posTime, txtClr);
             }
          }
       }//==== END C_AlertObjectDisplay::MakeHistoricalText =============
void C_AlertObjectDisplay::MakeTextObject(const ENUM_ALERT_TYPE& alertType, const ENUM_PROCESS_LEVELS& level, const string processLevel, const double& alertBarPrice, const int& refBar, const datetime& alertBarTime, const double& offsetValue, const color dispClr)  // place a text display object on the chart
       {
         if(m_textOn == OFF)
            return;  // Do nothing if text creation is turned off
         double   posPrice = GetPositionPriceFromAlertPrice(alertType, level, alertBarPrice, offsetValue);
         datetime posTime  = GetPositionTimeFromRefBar(alertType, level, refBar);
         SetAlertTimeAndPrice(alertBarPrice, alertBarTime, alertType);
         ManageTextObject(alertType, processLevel, alertBarPrice, posPrice, alertBarTime, posTime, dispClr);
       }//==== END C_AlertObjectDisplay::MakeTextObject ======================
// END Function Bodies; Class to display Alert Labels Function Bodies ====================
//+------------------------------------------------------------------------------------------------------------------+