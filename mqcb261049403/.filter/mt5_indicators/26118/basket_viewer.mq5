//+-----------------------------------------------------------------------+
//|  Inspired by                       Ahmad samir Virtual Trade.mq4      |
//|  https://www.mql5.com/en/forum/303765                                 |
//|                                                                       |
//|  Other References:                                                    |
//|  https://www.forexfactory.com/showthread.php?t=334555 (PitBull)       |
//+-----------------------------------------------------------------------+
string indicator_name = "Basket_Viewer";
#property copyright   "LukeB"
#property link        "https://www.mql5.com/en/users/lukeb"
#property version     "1.00";
#property description "View a Buy and a Sell Basket"
#property strict
#property indicator_chart_window
#property indicator_buffers 1
double    atr_buf[];
#property indicator_plots  0
// #include <errordescription.mqh>  // errordescription.mqh is found at: https://www.mql5.com/en/code/79 
//+------------------------------------------------------------------+
//|        ======= User Control ==============                       |
//+------------------------------------------------------------------+
input uint uniquifier      = 3856; // Make Object Names Unique
input int  CycleWeekLimit  = 10;   // Limit for weeks looked back (10)
//
input string SampleSellStr  = "CHFJPY,GBPCHF,GBPUSD,AUDJPY,EURGBP,USDCHF,EURJPY";   // Sample Sell Pairs "CHFJPY,GBPCHF,GBPUSD,AUDJPY,EURGBP,USDCHF,EURJPY";
input string SampleBuyStr   = "CADJPY,USDJPY,GBPJPY,USDCAD,EURCHF,AUDUSD,EURUSD";   // Sample Buy Pairs "CADJPY,USDJPY,GBPJPY,USDCAD,EURCHF,AUDUSD,EURUSD";
input string SetForSell     = "==Symbol Pairs for SELL==";                          // "==Symbol Pairs for SELL==";
input string SellPairs      = "CHFJPY,GBPCHF,GBPUSD,AUDJPY,EURGBP,USDCHF,EURJPY";   // Sell Pairs String
input string SetForBuy      = "==Symbol Pairs for BUY==";                           // "==Symbol Pairs for BUY==";
input string BuyPairs       = "CADJPY,USDJPY,GBPJPY,USDCAD,EURCHF,AUDUSD,EURUSD";   // Buy Pairs String
//
input string Colors_Setting = "Colors";
input color TitleClr        = clrWhite;
input color HeadClr         = clrWheat;
input color LotsSellClr     = clrCoral;
input color LotsBuyClr      = clrChartreuse;
input color TotalClr        = clrLightGoldenrod;
input color ProfitClr       = clrLimeGreen;
input color LossClr         = clrOrangeRed;
//======= End User Control ==============
//======= Custome EVENT Definitiions CHARTEVENT_CUSTOM_LAST — the last acceptable ID of a custom event (CHARTEVENT_CUSTOM +65535).
const ushort CHARTEVENT_MAKECHART = 37;
//---- Global Convenience Variables -----
enum DISP_OBJ_IDX       {TITLE_IDX, STRTWK_IDX, ENDWK_IDX, LONG_HDR_IDX, SHORT_HDR_IDX,  BSKT_ROW_IDX, SUM_LINE_IDX, SUMS_IDX, INDI_LBL_IDX, WK_MRK_IDX, END_DISP_OBJ_IDX};
string disp_obj_nms[] = {"_TITLE",  "_STARTWK", "_ENDWK",  "_LNG_HDR",   "_SHRT_HDR",   "_BSKT_ROW",   "_SUM_LINE",  "_SUMS",  "_INDI_LBL",  "_WK_MRK"   };
enum SYMBOL_OPERATION { SYMB_BUY, SYMB_SELL, SYMB_LBUY, SYMB_LSELL, SYMB_SBUY, SYMB_SSELL };
string GetOpDescription(const SYMBOL_OPERATION symb_op)  // Helper utility for names associated with the symbol operations enumeration.
{
   string desc_str;
   switch (symb_op)
    {
      case SYMB_BUY:   desc_str  = "Buy";    break;
      case SYMB_SELL:  desc_str  = "Sell";   break;
      case SYMB_LBUY:  desc_str  = "Buy_L";  break;
      case SYMB_LSELL: desc_str  = "Sell_L"; break;
      case SYMB_SBUY:  desc_str  = "Buy_S";  break;
      case SYMB_SSELL: desc_str  = "Sell_S"; break;
      default: desc_str = "UKN"; break;
    }
   return desc_str;
}//========= End GetOpDescription =============
enum ENUM_ON_OFF { ON, OFF };
enum ENUM_CHART_PLACEMENT {X_PLCMNT_IDX, Y_PLCMNT_IDX };       // Global Variable Names for Chart Placement
const int CHART_WINDOW = 0;
const int NOSHIFT      = 0;
const int NOMODIFIER   = 0;
//
class C_bsktCtrl
 {
   private:
      long xOriginPos, yOriginPos, xDragOffset, yPos, xPos;
      int  lineNum, columnNum, fontSize, yOffset;
      int col_1_offset, col_2_offset, col_3_offset, col_4_offset;
      bool selectable;
      color  objClr;
      string objName, objDispStr;
      ENUM_BASE_CORNER  objCorner;
      ENUM_ANCHOR_POINT objAnchor;
      int objWindow;
      int weekNum;
      ENUM_ON_OFF markWeek;
      datetime weekStart, weekEnd;
      int rangePeriods;
   protected:
      void SetInitialOrigin( const long& x_pos, const long& y_pos ){
         double globalVariableValue;
         int xPosMax = (int)  ChartGetInteger(ChartID(),CHART_WIDTH_IN_PIXELS,CHART_WINDOW);  // find chart width in pixels.
         int yPosMax = (int)  ChartGetInteger(ChartID(),CHART_HEIGHT_IN_PIXELS,CHART_WINDOW); // find chart heigth in pixels.
         double globalVariableResult = GlobalVariableGet(GetPositionGlobalName(X_PLCMNT_IDX),globalVariableValue);  // Get the x placement location - supports drag and drop for placement
         if( (globalVariableResult>0) && (globalVariableValue>-1) && (globalVariableValue<(xPosMax-col_1_offset)) ){ // No Error and a valid value (between 0 and not offscreen)
            xOriginPos = (long) globalVariableValue;
          } // else leave xOriginPos at the value it was instantiated with
         globalVariableResult = GlobalVariableGet(GetPositionGlobalName(Y_PLCMNT_IDX),globalVariableValue);   // Get the y placement location - supports drag and drop for placement
         if( (globalVariableResult>0) && (globalVariableValue>-1) && (globalVariableValue<(yPosMax-20)) ){ // No Error and a valid value (0 and 1 line from disapearing)
            yOriginPos = (long) globalVariableValue;
          } // else leave o_DispCtrl.xOriginPos at the value it was instantiated with
       }
   public:
      C_bsktCtrl(long x_pos, long y_pos, int font_size, color obj_clr){ // Constructor, provide defaults on creation
         SetDefaults(x_pos, y_pos, font_size, obj_clr);  // Set up the defaults
         markWeek=OFF;  weekNum=0;
         xOriginPos = x_pos; yOriginPos=y_pos;
         xDragOffset = 170;
         SetInitialOrigin(x_pos, y_pos);
       }//======= End C_bsktCtrl Constructor ================
      void SetDefaults(long x_pos, long y_pos, int font_size, color obj_clr){
         yPos=y_pos; xPos=x_pos; lineNum=0; columnNum=0; fontSize=font_size; yOffset=15;
         col_1_offset=320; col_2_offset=240; col_3_offset=160; col_4_offset=80;
         selectable=false; objClr=obj_clr; objCorner=CORNER_RIGHT_UPPER; objAnchor=ANCHOR_RIGHT_UPPER;
         objName=NULL; objDispStr=NULL; objWindow=CHART_WINDOW;
         rangePeriods = PeriodSeconds(PERIOD_W1)/PeriodSeconds(PERIOD_CURRENT)+1;  // always at least one
       }//======= End SetDefaults( ================
      string GetPositionGlobalName(const ENUM_CHART_PLACEMENT plcIdx){  // Function for global variable name so its always the same
         string gName="";
         switch (plcIdx){
            case X_PLCMNT_IDX: gName = "X_PLCEMENT_IDX"+IntegerToString(uniquifier); break;
            case Y_PLCMNT_IDX: gName = "Y_PLCEMENT_IDX"+IntegerToString(uniquifier); break;
            default: Print(__FUNCTION__+" Invalid Placement Index: "+IntegerToString(plcIdx)); break;
          }
         return(gName);
       }//========== END GetPositionGlobalName ==================
      void AddToWeekNum(int addAmount){  // change the week number
         weekNum += addAmount;
         if(weekNum<0){
            weekNum=CycleWeekLimit;
          }else if(weekNum>CycleWeekLimit){
            weekNum=0;
          }
       }//======= End AddToWeekNum ================
      ENUM_ON_OFF ToggleMarkWeek(void){
         markWeek=(markWeek==ON)?OFF:ON; // toggle the rectangle draw indicator
         return markWeek;
       }//=== END ToggleMarkWeek ================
      void SetOrigins(long newXpos, long newYpos) {  // Change the origin for future drawing
         xOriginPos = newXpos; // Set all the new positions
         yOriginPos = newYpos; // Set all the new positions
       }//========= End SetOrigins ============
      //======= Getters and Setters ========
      int    GetWindowNum(void)    {return objWindow;}
      ENUM_BASE_CORNER  GetBaseCorner(void) { return objCorner; }
      ENUM_ANCHOR_POINT GetObjectAnchor(void){return objAnchor; }
      color  GetDispClr(void)      {return objClr;}
      int    GetFontSize(void)     {return fontSize;}
      bool   GetSelectable(void)   {return selectable;}
      long   GetXOrigins(void)     {return xOriginPos;}
      long   GetYOrigins(void)     {return yOriginPos;}
      int    GetYOffSet(void)      {return yOffset;}
      long   GetXDragOffset(void)  {return xDragOffset;}
      string GetObjName(void)      {return objName;}
      string GetDispString(void)   {return objDispStr;}
      long   GetXPos(void)         {return xPos;}
      long   GetYPos(void)         {return yPos;}
      int    GetRangePeriods(void) {return rangePeriods;}
      int    GetDispWeekNum(void)  {return weekNum;}
      datetime GetWeekStartTime(void) {return iTime(_Symbol, PERIOD_W1, weekNum); }
      datetime GetWeekEndTime(void)   {return GetWeekStartTime()+(PeriodSeconds(PERIOD_W1)); }
      int    GetDispLineNum(void)  {return lineNum;}
      int GetColumnOneOffset(void){   return col_1_offset; }
      int GetColumnTwoOffset(void){   return col_2_offset; }
      int GetColumnThreeOffset(void){ return col_3_offset; }
      int GetColumnFourOffset(void){  return col_4_offset; }
      ENUM_ON_OFF GetIfWeekShouldBeMarked(void)  {return markWeek;}
      void SetIfWeekShouldBeMarked(ENUM_ON_OFF markSet){markWeek=markSet;}
      void SetColor(color objectClr)         { objClr = objectClr; }
      void SetObjName(string objectName)     { objName = objectName; }
      void SetDispString( string dispString) { objDispStr = dispString; }
      void SetXDispPos( long xDispPos )      { xPos = xDispPos; }
      void SetYDispPos( long yDispPos )      { yPos = yDispPos; }
      void IncrementLineNum( int incNum )    { lineNum += incNum; } 
      void SetSelectable( bool trueOrFalse ) { selectable = trueOrFalse; }
 } *c_bsktDispCtrl=NULL;  // Make a global pointer for this objec type
//
class C_pairsArys
 {
   private:
      SYMBOL_OPERATION symb_op;
      int pairRangePeriods;
      string pairs_ary[];    // Array of Pairs in the Basket
      double baseVal_ary[];  // Array of Basket Period Starting Prices for the Basket
      datetime baseTm_ary[]; // Array to capture the time of the baseVal_ary bar
      double baseATR_ary[];  // Array of ATRs for the Basket, in Points
      double pairVal_ary[];  // Array of Current Prices in the Basket
      double posVal_ary[];   // Array of Order Profit values for the basket
      double posLots_ary[];  // Array of Order Lots Exposed for the basket
      int ATRhandles_ary[];  // Array to hold a handle to get the ATR value for each pair.
      ulong handleErrCount_ary[]; // Array to count the errors for the error display.
      double speedBarOne_ary[];   // Array to hold value of speed calculation open price
      double speedBarZero_ary[];  // Array to hold value of speed calculation close price
      int atrPeriod;
      ENUM_ON_OFF USE_TERMINAL_ATR;
   protected:
      ENUM_INIT_RETCODE LoadInputPairs(const string& sourceString, const ENUM_INIT_RETCODE& init_status){ // Put delimited 'Input String' into the array
         ENUM_INIT_RETCODE result = init_status;
         if(result==INIT_SUCCEEDED){  // The pairs array is ready to accept symbol pairs
            const string delimitChar=",";  // Pairs are separated by comma
            string workString=sourceString;  // work with an independent string from user input
            // condition the workstring
            if(StringSubstr(workString,0,1)== delimitChar)   // Start with a pair, no leading delimiter character.
               workString += StringSubstr(workString,1,StringLen(workString)-1);
            if(StringSubstr(workString,StringLen(workString)-1,1)!= delimitChar)   // End with a delimiter character to assist with gettng the last pair out of the string.
               workString += delimitChar;
            //===== Increnment thru the strings deliminting characters and extract the pair identifiers between them.
            int startPos=0, foundPos, aryIdx=0, finalCharPos = StringLen(workString)-1;
            int aryRange = ArrayRange(pairs_ary,0);
            while (startPos < finalCharPos) {
               if(aryIdx>aryRange){ // Grew too large - could put an ArrayResizse here to grow the array.
                  Print(__FUNCTION__+"Pairs Input String contains too many pair identifications, initialiation failed");
                  break;
                }
               foundPos=StringFind(workString,delimitChar,startPos);
               pairs_ary[aryIdx]=StringSubstr(workString,startPos,foundPos-startPos);  // Extract Pair string an place in array
               aryIdx++;
               startPos=foundPos+1;
             }
          }
         return result;
       }// ====== END LoadInputPairs ============
      void CheckMarketWatch( void ) { // ensure the pairs are in the Market-Watch list
         for(int i=0; i<ArrayRange(pairs_ary,0); i++) {
            bool symbolFound=false;
            if(StringLen(pairs_ary[i])>0){  // The entry has something
               int countOfMarketWatchSymbols = SymbolsTotal(true); 
               for(int count=0; count < countOfMarketWatchSymbols; count++) {
                  int foundString = StringFind(SymbolName(count,true),pairs_ary[i],0);
                  if( foundString>-1 ) { // a matching string was found
                     pairs_ary[i]= SymbolName(count,true);  // Replace the input name with the market watch name (may have additional characters)
                     symbolFound=true;
                     break;  // don't look any further
                   }
                }
               if( (symbolFound==false) ){  // Symbol not found in MarketWatch - Give the user some feedback in the log
                  Print(GetOpDescription(symb_op)," Symbol: "+pairs_ary[i]+" was not found in MarketWatch (size: ",IntegerToString(StringLen(pairs_ary[i])),").");
                }
             }
          }
       }// =========== END CheckMarketWatch ===========
      ENUM_INIT_RETCODE CompressArray( void ){  // Take out any Null entries
         ENUM_INIT_RETCODE init_result = INIT_SUCCEEDED;
         int i=0;
         for(int j=0; j<ArrayRange(pairs_ary,0); i++,j++){
            while ( (StringLen(pairs_ary[j])<1) ) {
               j++;
               if(j==ArrayRange(pairs_ary,0)) break;
             }
            if( j<ArrayRange(pairs_ary,0) ) {
               pairs_ary[i]=pairs_ary[j];
             }
          }
         if(ArrayResize(pairs_ary,i-1)!=(i-1)) {
            int errCode=GetLastError();
            Print(GetOpDescription(symb_op)+" "__FUNCTION__" Array Resize Failed, Error: "+ IntegerToString(errCode));// +", "+ErrorDescription(error_code);
            init_result=INIT_FAILED;
          }
         return init_result;
      }//============ END CompressArray ===========
      ENUM_INIT_RETCODE SizePairArrays( const ENUM_INIT_RETCODE& init_status ){  // function for OnInit to call to size to the number of the user supplied pairs 
         ENUM_INIT_RETCODE result = init_status;
         int pairsSize = ArrayRange(pairs_ary,0);
         result = ResizeArray<double>(baseVal_ary,          pairsSize, result);
         result = ResizeArray<datetime>(baseTm_ary,         pairsSize, result);
         result = ResizeArray<double>(pairVal_ary,          pairsSize, result);
         result = ResizeArray<double>(posLots_ary,          pairsSize, result);
         result = ResizeArray<double>(posVal_ary,           pairsSize, result);
         result = ResizeArray<double>(baseATR_ary,          pairsSize, result);
         result = ResizeArray<int>(ATRhandles_ary,          pairsSize, result);
         result = ResizeArray<ulong>(handleErrCount_ary,    pairsSize, result);
         result = ResizeArray<double>(speedBarOne_ary,      pairsSize, result);
         result = ResizeArray<double>(speedBarZero_ary,     pairsSize, result);
         // Print(GetOpDescription(symb_op),", ",__FUNCTION__," Pairs Array Size: ",IntegerToString(pairsSize),", ATRhandels Array Size: ",IntegerToString(ArrayRange(ATRhandles_ary,0)));
         return result;
       }// == END SizePairArrays ============
      template <typename T>  // http://www.cplusplus.com/doc/tutorial/functions2/  templat allows one code block to be replicated by the compiler for all data types
      ENUM_INIT_RETCODE ResizeArray(T& array[], const int& ary_size, const ENUM_INIT_RETCODE& init_status){ // SizePairArrays Helper function to do the actual array resizing
         ENUM_INIT_RETCODE result = init_status;
         if(ary_size>0){ // There is some work to do
            if(ArrayResize(array,ary_size)!=ary_size){
               int errCode=GetLastError();
               result=INIT_FAILED; 
               Print(GetOpDescription(symb_op)+" array resize failed, error: "+IntegerToString(errCode)); // +", "+ErrorDescription(error_code);
             } else ArrayInitialize(array,NULL);
          }
         return result;
       }// ========== END ResizeArray ================
      int GetSymbolArrayIdx(string& matchString ){
         int retValue=-1;
         for(int idx=0; idx<ArrayRange(pairs_ary,0); idx++){
            if(pairs_ary[idx]==matchString){
               retValue=idx;
               break;
             }
          }
         return retValue;
       }//==== END GetSymbolArrayIdx ==========
      void SetATRHandle(const int& idx){  // Set One ATR Handle
               ATRhandles_ary[idx]=iATR(pairs_ary[idx], PERIOD_CURRENT, pairRangePeriods); // Get a Handle for the iATR terminal data
               if( ATRhandles_ary[idx]==INVALID_HANDLE ){
                  int error_code = GetLastError();
                  comment_string = GetOpDescription(symb_op)+" "+__FUNCTION__+" failed to find an ATR_Handle for "+pairs_ary[idx]+", Error: "+IntegerToString(error_code); // +", "+ErrorDescription(error_code);
                  Comment(comment_string); Print(comment_string);
                  // result=false; Just leave as invalid handle and don't get an ATR for the symbol
                }
       }// ======= END SetATRHandle ===================
      void SetTerminalATR(C_bsktCtrl* c_dispCtrl, double& indiValsBuf[], const ulong& callCounter){ // Use the Terminal iATR to get the ATR
         int weekEndBar = c_dispCtrl.GetRangePeriods()*c_dispCtrl.GetDispWeekNum();
         for(int idx=0; idx<ArrayRange(pairs_ary,0); idx++){
            long bars = Bars(pairs_ary[idx],PERIOD_CURRENT);
            if(ATRhandles_ary[idx] != INVALID_HANDLE){
               if(CopyBuffer(ATRhandles_ary[idx],0, weekEndBar,1,indiValsBuf)<=0){ // atr_buf // (handle, buffer Number, start pos, count, buffer[])
                  handleErrCount_ary[idx]++;
                  int errCode = GetLastError();
                  comment_string = GetOpDescription(symb_op)+" Getting Term ATR data (Call "+IntegerToString(callCounter)+") for "+pairs_ary[idx]+", Index: "+IntegerToString(idx)+", Handle: "
                                   +IntegerToString(ATRhandles_ary[idx])+" failed ("+IntegerToString(handleErrCount_ary[idx])
                                   +" times), Bar: "+IntegerToString(weekEndBar)+" of "+IntegerToString(bars)+", "+TimeToString(iTime(pairs_ary[idx],PERIOD_CURRENT,weekEndBar),TIME_DATE|TIME_MINUTES)
                                   +", Using 1 for the ATR, Error: "+IntegerToString(errCode); //+", "+ErrorDescription(errCode);
                  Comment(comment_string); Print(comment_string);
                  baseATR_ary[idx] = 1;  // never divide by zero.
                } else {
                  baseATR_ary[idx] = indiValsBuf[0]/SymbolInfoDouble(pairs_ary[idx],SYMBOL_POINT);
                  if(baseATR_ary[idx]<1){
                     comment_string= GetOpDescription(symb_op)+" Term ATR Call (Call "+IntegerToString(callCounter)+") for "+pairs_ary[idx]
                                    +" Bar "+IntegerToString(weekEndBar)+" of "+IntegerToString(bars)+" Bars, Time: "
                                    +TimeToString(iTime(pairs_ary[idx],PERIOD_CURRENT,weekEndBar),TIME_DATE|TIME_MINUTES)
                                    +", Calculed ATR: "+DoubleToString(baseATR_ary[idx],2)+", Using 1";
                     Comment(comment_string); Print(comment_string);
                     baseATR_ary[idx] = 1;  // never divide by zero.
                   }
                }
             }else{  // Is Equal to INVALID_HANDEL
               baseATR_ary[idx] = NULL;
               SetATRHandle(idx); // attempt to recover
             }
          }
       }// ======== End SetTerminalATR ==========
      void SetInternalATR(C_bsktCtrl* c_dispCtrl, const ulong& callCounter){ // Calculate the ATR
         int weekEndBar = c_dispCtrl.GetRangePeriods()*c_dispCtrl.GetDispWeekNum();
         for(int idx=0; idx<ArrayRange(pairs_ary,0); idx++){
            double high, low, range=0;
            static ulong callCount = 0; callCount++;
            long bars=Bars(pairs_ary[idx],PERIOD_CURRENT);
            for(int workBar=0; workBar<atrPeriod; workBar++){
               int valueBar=(weekEndBar+workBar);   //bars-(weekendBar+workBar) // (weekendBar-workBar); 
               if( valueBar < (bars-1) ){ // Haven't stepped past the oldest bar of the timeseries  // valueBar < (bars-1) // valueBar > (-1)
                  high = iHigh(pairs_ary[idx],PERIOD_CURRENT,valueBar);
                  if(high==0){
                     int errCode = GetLastError();
                     comment_string = GetOpDescription(symb_op)+" "+__FUNCTION__+", "+pairs_ary[idx]+"Call: "+IntegerToString(callCount)+", Bar: "+IntegerToString(valueBar)+", iHigh{"+IntegerToString(callCount)+") returned error: "+IntegerToString(errCode)+", using 1"; //, "+ErrorDescription(errCode);
                     Comment(comment_string); Print(comment_string);
                     high = 1;
                   }
                  low  = iLow(pairs_ary[idx],PERIOD_CURRENT,valueBar);
                  if(low==0){
                     int errCode = GetLastError();
                     comment_string = GetOpDescription(symb_op)+" "+__FUNCTION__+", "+pairs_ary[idx]+"Call: "+IntegerToString(callCount)+", Bar: "+IntegerToString(valueBar)+", iLow{"+IntegerToString(callCount)+") returned error: "+IntegerToString(errCode)+", using 1"; //, "+ErrorDescription(errCode);
                     Comment(comment_string); Print(comment_string);
                     low = 1;
                   }
                }else{
                  high = iHigh(pairs_ary[idx],PERIOD_CURRENT,0);
                  if(high==0){
                     int errCode = GetLastError();
                     comment_string = GetOpDescription(symb_op)+" "+__FUNCTION__+", "+pairs_ary[idx]+"Call: "+IntegerToString(callCount)+", Bar: 0, iHigh{"+IntegerToString(callCount)+") returned error: "+IntegerToString(errCode)+", using 1"; // , "+ErrorDescription(errCode);
                     Comment(comment_string); Print(comment_string);
                     high = 1;
                   }
                  low  = iLow(pairs_ary[idx],PERIOD_CURRENT,0);
                  if(low==0){
                     int errCode = GetLastError();
                     comment_string = GetOpDescription(symb_op)+" "+__FUNCTION__+", "+pairs_ary[idx]+"Call: "+IntegerToString(callCount)+", Bar: 0, iLow{"+IntegerToString(callCount)+") returned error: "+IntegerToString(errCode)+", using 1"; // , "+ErrorDescription(errCode);
                     Comment(comment_string); Print(comment_string);
                     high = 1;
                   }
                }
               range += MathAbs(high-low);  // Always Positve.
             }
            baseATR_ary[idx] = (int) ((range/atrPeriod)/SymbolInfoDouble(pairs_ary[idx],SYMBOL_POINT));
            if(baseATR_ary[idx]<1){
               comment_string= GetOpDescription(symb_op)+" Indi ATR Calc (Call "+IntegerToString(callCounter)+") for "+pairs_ary[idx]
                              +" Bar "+IntegerToString(weekEndBar)+" of "+IntegerToString(bars)+" Bars, Time: "
                              +TimeToString(iTime(pairs_ary[idx],PERIOD_CURRENT,weekEndBar),TIME_DATE|TIME_MINUTES)
                              +", Calculed ATR: "+DoubleToString(baseATR_ary[idx],2)+", Using 1";
               Comment(comment_string); Print(comment_string);
               baseATR_ary[idx] = 1;  // never divide by zero.
             }
          }
       } //==== END SetInternalATR ========
   public:
      void C_pairsArys(SYMBOL_OPERATION sym_op){  // constructot, set initial size and the oeration type for the pairs.
         symb_op = sym_op;
         atrPeriod = 14;
         USE_TERMINAL_ATR = ON;
         pairRangePeriods = PeriodSeconds(PERIOD_W1)/PeriodSeconds(PERIOD_CURRENT)+1;  // its a calendar weeks seconds, not a trading weeks seconds
       }//=== END C_pairsArys Constructor
      void ~C_pairsArys(void){ // Destructor, take actions to clean up after the object
         for(int idx=0; idx<ArrayRange(ATRhandles_ary,0); idx++){
            if(ATRhandles_ary[idx] != INVALID_HANDLE){ IndicatorRelease( ATRhandles_ary[idx] ); ATRhandles_ary[idx]=INVALID_HANDLE;}
          }
       }
      ENUM_INIT_RETCODE LoadPairsAry(int initialSize, const string& symbPairs){  // Insert User Control Values into the array
         ENUM_INIT_RETCODE result = INIT_SUCCEEDED;
         if(ArrayResize(pairs_ary,initialSize)!=initialSize){
            int errCode = GetLastError();
            Print(GetOpDescription(symb_op)+" ArrayResize of pairs_ary in C_pairsArys constructor failed, error: "+IntegerToString(errCode)); //+", "+ErrorDescription(errCode));
          } else { // Pairs array is prepared to accept symbols
            LoadInputPairs(symbPairs, result); // Put extern 'Input String' into the short symbol array
            CheckMarketWatch();          // ensure the pairs are in the Market-Watch list, set values to NULL that are not valid
            result = CompressArray();    // Take out any Null entries
            result = SizePairArrays(result);   // Size remaining arrays to match the pairs array size
          }
         if(result==INIT_SUCCEEDED){   // put this in to see if it will initialize iOpen and iClose such that the first 'Points' display is correct
            LoadBasePrices(1);         // The only reason to do this is observation that iOpen and iClose seem to need an 'initialization' before giving correct values.
            LoadSpeedBases(atrPeriod); // The only reason to do this is observation that iOpen and iClose seem to need an 'initialization' before giving correct values.
            SetCurrentSpeedPrices();   // The only reason to do this is observation that iOpen and iClose seem to need an 'initialization' before giving correct values.
          }
         return result;
       }//========== END LoadPairsAry =================
      void LoadBasePrices(const int weekNum){
         static ulong callCount=0; callCount++;
         for(int idx=0; idx<ArrayRange(pairs_ary,0); idx++){
            baseVal_ary[idx] = iOpen(pairs_ary[idx], PERIOD_W1, weekNum);
            if(baseVal_ary[idx]==0){
               int errCode = GetLastError();
               comment_string = GetOpDescription(symb_op)+" "+__FUNCTION__+", "+pairs_ary[idx]+", Bar: "+IntegerToString(weekNum)+", iOpen{"+IntegerToString(callCount)+") returned error: "+IntegerToString(errCode)+", using 1"; //, "+ErrorDescription(errCode);
               Comment(comment_string); Print(comment_string);
               baseVal_ary[idx] = 1;
             }
            baseTm_ary[idx]  = iTime(pairs_ary[idx], PERIOD_W1, weekNum);
          }
       }//========== END LoadBasePrices ==================
      void SetBasketCurrentPrices(C_bsktCtrl* c_dispCtrl){
         static ulong callCount=0; callCount++;
         for(int idx=0; idx<ArrayRange(pairs_ary,0); idx++){
            pairVal_ary[idx] = iClose(pairs_ary[idx], PERIOD_W1, c_dispCtrl.GetDispWeekNum());
            if(pairVal_ary[idx]==0){
               int errCode = GetLastError();
               comment_string = GetOpDescription(symb_op)+" "+__FUNCTION__+", "+pairs_ary[idx]+", Bar: "+IntegerToString(c_dispCtrl.GetDispWeekNum())+", iClose{"+IntegerToString(callCount)+") returned ereror: "+IntegerToString(errCode)+", using 1"; //, "+ErrorDescription(errCode);
               Comment(comment_string); Print(comment_string);
               pairVal_ary[idx] = 1;
             }
          }
       } // ====== END SetBasketCurrentPrices ==============
      void LoadSpeedBases(const int barNum){
         static ulong callCount=0; callCount++;
         for(int idx=0; idx<ArrayRange(pairs_ary,0); idx++){
            speedBarOne_ary[idx] = iOpen(pairs_ary[idx], PERIOD_CURRENT, barNum);
            if(speedBarOne_ary[idx]==0){
               int errCode = GetLastError();
               comment_string = GetOpDescription(symb_op)+" "+__FUNCTION__+", "+pairs_ary[idx]+", Bar: "+IntegerToString(barNum)+", iOpen{"+IntegerToString(callCount)+") returned error: "+IntegerToString(errCode)+", using 1"; //, "+ErrorDescription(errCode);
               Comment(comment_string); Print(comment_string);
               speedBarOne_ary[idx] = 1;
             }
          }
       }//========== END LoadSpeedBases ==================
      void SetCurrentSpeedPrices(void){
         static ulong callCount=0; callCount++;
         for(int idx=0; idx<ArrayRange(pairs_ary,0); idx++){
            speedBarZero_ary[idx] = iClose(pairs_ary[idx], PERIOD_CURRENT, 0);
            if(speedBarZero_ary[idx]==0){
               int errCode = GetLastError();
               comment_string = GetOpDescription(symb_op)+" "+__FUNCTION__+", "+pairs_ary[idx]+", Bar: 0, iClose{"+IntegerToString(callCount)+") returned error: "+IntegerToString(errCode)+", using 1"; //, "+ErrorDescription(errCode);
               Comment(comment_string); Print(comment_string);
               speedBarZero_ary[idx] = 1;
             }
          }
       }//========== END LoadCurrentSpeedPrice ==================
      double GetSpeedAngle(const int& pairIdx){
         static const double ninetyRatio=1.5;
         double speedRatio;
         static ulong callCount=0; callCount++;
         if( (speedBarOne_ary[pairIdx]==1) && (speedBarZero_ary[pairIdx]==1) ){
            speedRatio = 0;
            LoadSpeedBases(1); // Try to Recover (speedBarZero will be refreshed with the next call.
            comment_string = GetOpDescription(symb_op)+" "+__FUNCTION__+", "+pairs_ary[pairIdx]+", Bar One value is 0, using 0 for the angle{"+IntegerToString(callCount)+")";
            Comment(comment_string); Print(comment_string);
          }else{
            double pointVal = SymbolInfoDouble(pairs_ary[pairIdx],SYMBOL_POINT);
            if( pointVal==0 || baseATR_ary[pairIdx]==0){
               comment_string = GetOpDescription(symb_op)+" "+__FUNCTION__+", Call Count: ("+IntegerToString(callCount)+") Pair "+pairs_ary[pairIdx]
                                +", ATR Value: "+DoubleToString(baseATR_ary[pairIdx],2)+", Point Value: "+DoubleToString(pointVal,5);
               Comment(comment_string); Print(comment_string);
               speedRatio = 0;
             }else{
               speedRatio = (speedBarZero_ary[pairIdx]-speedBarOne_ary[pairIdx])/(baseATR_ary[pairIdx]*pointVal);
             }
          }
         double speedAngle;
         if(speedRatio > ninetyRatio){
            speedAngle = 90.0;
          }else if(speedRatio < -ninetyRatio){
            speedAngle = -90.0;
          }else {
            speedAngle = (speedRatio/ninetyRatio)*90.0;
          }
         return speedAngle;
       }//========== END GetSpeedAngle ==================
      //+------------------------------------------------------------------+
      //| Basekt Values Functions                                          |
      //+------------------------------------------------------------------+
      void SetBasketATRValues(C_bsktCtrl* c_dispCtrl, double& indiValsBuf[] ){
         static ulong callCounter=0;
         callCounter++;
         switch (USE_TERMINAL_ATR){
            case ON:  SetTerminalATR(c_dispCtrl, indiValsBuf, callCounter);  break;
            case OFF: SetInternalATR(c_dispCtrl, callCounter); break;
            default: SetInternalATR(c_dispCtrl, callCounter); break;
          }
       }//=========== END SetBasketATRValues =============
      void SetATRHandles(void){ // Get a Handle for each PAIR to access terminal ATR data
         // Print(GetOpDescription(symb_op),", ",__FUNCTION__,", ",GetOpDescription(symb_op)," Pairs Array Size: ",IntegerToString(ArrayRange(pairs_ary,0)),", ATRhandels Array Size: ",IntegerToString(ArrayRange(ATRhandles_ary,0)));
         for(int idx=0; idx<ArrayRange(pairs_ary,0); idx++){
            if( (USE_TERMINAL_ATR==ON) && ((ATRhandles_ary[idx]==INVALID_HANDLE) || (ATRhandles_ary[idx]==NULL)) ){
               SetATRHandle(idx);  // Set the handle
             }else{ // (USE_TERMINAL_ATR==OFF)
               if(ATRhandles_ary[idx] != INVALID_HANDLE){ IndicatorRelease( ATRhandles_ary[idx] ); ATRhandles_ary[idx]=INVALID_HANDLE;}
             }
          }
       } // ======== END SetATRHandles =========
      void SetPositionValues(void){
         ArrayInitialize(posVal_ary,0);   // Start with zero and add to it
         ArrayInitialize(posLots_ary,0);   // Start with zero and add to it
         int aryIdx; string positionSymbol;
         for(int i=PositionsTotal()-1; i>=0; i--){
            positionSymbol = PositionGetSymbol(i);
            aryIdx=GetSymbolArrayIdx(positionSymbol);
            if(aryIdx>-1){ // Found in the array
               posVal_ary[aryIdx]   += PositionGetDouble(POSITION_PROFIT);
               posLots_ary[aryIdx]  += PositionGetDouble(POSITION_VOLUME);
             }
          }
       }//======= END SetPositionValue ========
      //  Getters and Setters 
      void SetTerminalATRSouceSwitch(ENUM_ON_OFF useTerminal){USE_TERMINAL_ATR = useTerminal;}
      ENUM_ON_OFF GetATRSourceSwitchValue(void){return USE_TERMINAL_ATR;}
      string GetPairSymbol(int idx){ return pairs_ary[idx]; }
      SYMBOL_OPERATION GetSymbolOp(void){ return symb_op; }
      double GetSymbStartVal(int idx){ return baseVal_ary[idx]; }
      double GetSymbolEndVal(int idx){  return pairVal_ary[idx]; }
      double GetSymbolATRVal(int idx){  return baseATR_ary[idx]; }
      double GetSymbolPosVal(int idx){  return posVal_ary[idx]; }
      double GetSymbolLotsVal(int idx){ return posLots_ary[idx]; }
      int    GetPairArraySize(void){ return ArrayRange(pairs_ary,0); }
      datetime GetWeekTm(const int& idx){ return baseTm_ary[idx]; }
      //
 } *c_sellPairs=NULL, *c_buyPairs=NULL;  // make Global pointers to this object type
string comment_string="";  // for displaying and printing comments, gets cleaned up when indi is removed from chart.
datetime lastPostTime = NULL;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() 
{ 
   ENUM_INIT_RETCODE init_result = INIT_SUCCEEDED;
   indicator_name = indicator_name+IntegerToString(uniquifier);  // Make name unigue to user suppliable instance identifier
   IndicatorSetString(INDICATOR_SHORTNAME,indicator_name);  // Give the indicator a name
   EventSetTimer(1);    //--- create a timer with a 1 second period
   init_result    = InitializeGlobalObjects(init_result); // Display Control, Buy Basket and Sell Basket creation and pointer initialization
   if( init_result==INIT_SUCCEEDED ){ // the objects got created
      init_result    = c_sellPairs.LoadPairsAry(50, SellPairs);        // Insert User Control Values into the work symbol array
      init_result    = c_buyPairs.LoadPairsAry(50, BuyPairs);          // Insert User Control Values into the work symbol array
      if( !HandlesSet( c_buyPairs, c_sellPairs) ){                     // set handles for the sybmols
         init_result = INIT_FAILED;
       }
    }
   SetIndexBuffer(0, atr_buf, INDICATOR_CALCULATIONS);  // Establish buffer for indicator buffer
   ArraySetAsSeries(atr_buf,true);   // make it as series so [0] is the newest value
   return(init_result);
}//========= END OnInit ==========
bool HandlesSet(C_pairsArys* buyStruc, C_pairsArys* sellStruc)  // Initialize handles used to get needed terminal data
{
   buyStruc.SetATRHandles();
   sellStruc.SetATRHandles();
   return true;  // decided not to fail, just handle invalid handle.
}//======== End HandlesSet =======
ENUM_INIT_RETCODE InitializeGlobalObjects( const ENUM_INIT_RETCODE& initCode) // Display Control, Buy Basket and Sell Basket creation and pointer initialization
{
   ENUM_INIT_RETCODE objectCreationResult = initCode;
   if( objectCreationResult == INIT_SUCCEEDED ){
      for(DISP_OBJ_IDX idx=0; idx<END_DISP_OBJ_IDX; idx++){ // Add uniquifier to Object Names to make them unique to this indicator
         disp_obj_nms[idx] = IntegerToString(uniquifier)+disp_obj_nms[idx];
       }
      if( c_bsktDispCtrl == NULL ){
         c_bsktDispCtrl = new C_bsktCtrl(40,40,11,clrNONE);
         if( c_bsktDispCtrl == NULL ){
            int errCode=GetLastError();
            Print(__FUNCTION__+" Failed to create a new Display Control Object, error: "+IntegerToString(errCode)); // +ErrorDescription(errCode));
            objectCreationResult = INIT_FAILED;
          }
       }
      if( c_sellPairs == NULL ){
         c_sellPairs=new C_pairsArys(SYMB_SELL);
         if( c_sellPairs == NULL ){
            int errCode=GetLastError();
            Print(__FUNCTION__+" Failed to create a new Sell Pairs object, error: "+IntegerToString(errCode)); // +ErrorDescription(errCode));
            objectCreationResult = INIT_FAILED;
          }
       }
      if( c_buyPairs == NULL ){
         c_buyPairs =new C_pairsArys(SYMB_BUY);
         if( c_buyPairs == NULL ){
            int errCode=GetLastError();
            Print(__FUNCTION__+" Failed to create a new Buy Pairs object, error: "+IntegerToString(errCode)); // +ErrorDescription(errCode));
            objectCreationResult = INIT_FAILED;
          }
       }
   }
   return objectCreationResult;
}//======== END InitializeGlobalObjects =============
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)  // Clean-up on exit
{
   EventKillTimer(); // Kill the timer
   if(c_bsktDispCtrl != NULL){ delete c_bsktDispCtrl; c_bsktDispCtrl=NULL; }
   if(c_sellPairs != NULL){ delete c_sellPairs; c_sellPairs=NULL; }
   if(c_buyPairs != NULL){ delete c_buyPairs;  c_buyPairs=NULL; }
   if(StringLen(comment_string)>0){  // Clean up the Comment if this indicator made one.
      Comment("");
    }
   for(int i = ObjectsTotal(ChartID()) - 1; i >= 0; i--)
    {
      string label = ObjectName(ChartID(),i);
      if(StringSubstr(label,0,StringLen(IntegerToString(uniquifier)))==IntegerToString(uniquifier)){  // Only delete objects with this indicators identifier on them
         ObjectDelete(ChartID(),label);
       }
    }
   ChartRedraw(ChartID());
}// ========= END OnDeinit ==========
//+------------------------------------------------------------------+
//| Chart Event Handler                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
 {
    if(id==CHARTEVENT_OBJECT_CLICK){
      Comment("");  // Clear old comment displays to ensure new are clear.
      if(sparam==disp_obj_nms[STRTWK_IDX]){   //  Increment the week
         c_bsktDispCtrl.AddToWeekNum(+1);
         c_buyPairs.LoadBasePrices(c_bsktDispCtrl.GetDispWeekNum());
         c_sellPairs.LoadBasePrices(c_bsktDispCtrl.GetDispWeekNum());
         LoadDashboardValuesAndDraw();
       }else if(sparam==disp_obj_nms[ENDWK_IDX]){  // Decrement the week
         c_bsktDispCtrl.AddToWeekNum(-1);
         c_buyPairs.LoadBasePrices(c_bsktDispCtrl.GetDispWeekNum());
         c_sellPairs.LoadBasePrices(c_bsktDispCtrl.GetDispWeekNum());
         LoadDashboardValuesAndDraw();
       }else if(sparam==disp_obj_nms[LONG_HDR_IDX]){ // Highlight the week (or turn of highlighting)
         if(c_bsktDispCtrl.ToggleMarkWeek()==OFF){
            ObjectDelete(ChartID(),disp_obj_nms[WK_MRK_IDX]);
          }else{  // == ON
            DrawRectangle(c_bsktDispCtrl, WK_MRK_IDX);
          }
         ChartRedraw(ChartID());
       }else if( StringSubstr(sparam,0,StringLen(disp_obj_nms[BSKT_ROW_IDX])) == disp_obj_nms[BSKT_ROW_IDX] ){  // Change the Chart Symbol
         int endPos     = StringFind(sparam, "PAIR", WHOLE_ARRAY);
         int startPos   = StringLen(disp_obj_nms[BSKT_ROW_IDX]);
         string pairStr = StringSubstr(sparam, startPos, endPos-startPos);
         if( pairStr != ChartSymbol(ChartID())){
            ChartSetSymbolPeriod(ChartID(),pairStr,PERIOD_CURRENT);
            ChartRedraw(ChartID());
          }
       }else if(sparam==disp_obj_nms[SHORT_HDR_IDX]){  // Toggle gettin ATR from the Terminal or from internal calculation
         ENUM_ON_OFF toggledSwitch = (c_buyPairs.GetATRSourceSwitchValue()==OFF?ON:OFF); // Get Toggled Value
         if(toggledSwitch==OFF){
            c_buyPairs.SetTerminalATRSouceSwitch(OFF);
            c_sellPairs.SetTerminalATRSouceSwitch(OFF);
          }else{ // Toggled to ON
            c_buyPairs.SetTerminalATRSouceSwitch(ON);
            c_sellPairs.SetTerminalATRSouceSwitch(ON);
          }
         c_buyPairs.SetATRHandles();
         c_sellPairs.SetATRHandles();
         LoadDashboardValuesAndDraw();
       }
    }else if(id==CHARTEVENT_CUSTOM+CHARTEVENT_MAKECHART){  // Request to Draw the Indicator Dashboard
      if(lparam==uniquifier){
         lastPostTime = TimeLocal();
         LoadDashboardValuesAndDraw();
       }
    }else if(id==CHARTEVENT_OBJECT_DRAG){  //sparam = Name of the moved graphical object
      if( sparam==disp_obj_nms[TITLE_IDX] ){  // This is the drage object, the pannel has been drug to a new location, display the panel at that location.
         long newXpos, newYpos;
         newXpos = ObjectGetInteger( ChartID(), sparam, OBJPROP_XDISTANCE, NOMODIFIER );   // Get after-drag Move Object Position
         newYpos = ObjectGetInteger( ChartID(), sparam, OBJPROP_YDISTANCE, NOMODIFIER );   // Get after-drag Move Object Position
         newXpos = newXpos - c_bsktDispCtrl.GetXDragOffset();                              // Adjust for the xOffset to the drag object (there is no y offset to the drag object
         c_bsktDispCtrl.SetOrigins(newXpos, newYpos);
         GlobalVariableSet(c_bsktDispCtrl.GetPositionGlobalName(X_PLCMNT_IDX), c_bsktDispCtrl.GetXOrigins());
         GlobalVariableSet(c_bsktDispCtrl.GetPositionGlobalName(Y_PLCMNT_IDX), c_bsktDispCtrl.GetYOrigins());
         DrawDisplay(c_sellPairs, c_buyPairs, c_bsktDispCtrl);                            // Display at the new position
         ChartRedraw(ChartID());
       }
    }
 }
//+------------------------------------------------------------------+
//| Custom indicator Timer Event Processin                           |
//+------------------------------------------------------------------+
void OnTimer()
{
   if((TimeLocal()-lastPostTime)>1 ){  // Update the chart at least every second.
      EventChartCustom(ChartID(),CHARTEVENT_MAKECHART, uniquifier, NULL, NULL);
    }
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[], const long& tick_volume[], const long& volume[], const int& spread[] )
{
   bool newWeek = ThereIsNewWeekBar();  // Detect if a new week is starting
   bool newBar  =  ThereIsNewChartBar();     // Detect if a new bar is starting on the Chart
   if( newWeek || (prev_calculated<1) || (rates_total<prev_calculated) ){
      if(newWeek){
         c_buyPairs.LoadBasePrices(c_bsktDispCtrl.GetDispWeekNum());  // Set the week's starting values
         c_sellPairs.LoadBasePrices(c_bsktDispCtrl.GetDispWeekNum()); // Set the week's starting values
       }
    }
   if( newBar || (prev_calculated<1) || (rates_total<prev_calculated) ){
      if(newWeek){
         c_buyPairs.LoadSpeedBases(1);  // Set the week's starting values
         c_sellPairs.LoadSpeedBases(1); // Set the week's starting values
       }
    }
   //
   EventChartCustom(ChartID(),CHARTEVENT_MAKECHART, uniquifier, NULL, NULL);  // Post an event to refresh the display.
   //
   return rates_total;
}//====== END OnCalculate ==============
bool ThereIsNewWeekBar(void) // Determine if there is a new week starting.
{
   bool result=false;
   static datetime lastBarTime=NULL;
   datetime currBarTime = iTime(_Symbol,PERIOD_W1,NOSHIFT);  // Get the Bar Zero Time
   if(currBarTime != lastBarTime){  // Week Bar has changed
      lastBarTime = currBarTime;
      result=true;
    }
   return result;
}//====== END ThereIsNewWeekBar ======================
bool ThereIsNewChartBar(void) // Determine if there is a new bar starting.
{
   bool result=false;
   static datetime lastBarTime=NULL;
   datetime currBarTime = iTime(_Symbol,PERIOD_CURRENT,NOSHIFT);  // Get the Bar Zero Time
   if(currBarTime != lastBarTime){  // chart Bar 0 has changed
      lastBarTime = currBarTime;
      result=true;
    }
   return result;
}//====== END ThereIsNewWeekBar ======================
//+------------------------------------------------------------------+
//| Indicator Custom Event Action                                    |
//+------------------------------------------------------------------+
void LoadDashboardValuesAndDraw(void)  // Get the current values and draw the dashboard
{
   c_sellPairs.SetBasketATRValues( c_bsktDispCtrl, atr_buf );  // Find the Value of the sell Basket for the week
   c_buyPairs.SetBasketATRValues( c_bsktDispCtrl, atr_buf );  // Find the Value of the buy Basket for the week
   //
   c_sellPairs.SetBasketCurrentPrices(c_bsktDispCtrl);    // Find the Value of the sell Basket for the week
   c_buyPairs.SetBasketCurrentPrices(c_bsktDispCtrl);    // Find the Value of the buy Basket for the week
   //
   c_sellPairs.SetPositionValues();     // Find the Value of the sell orders
   c_buyPairs.SetPositionValues();     // Find the Value of the buy orders
   //
   c_sellPairs.SetCurrentSpeedPrices(); // Get the most recent price
   c_buyPairs.SetCurrentSpeedPrices();  // Get the most recent price
   //
   DrawDisplay(c_sellPairs, c_buyPairs, c_bsktDispCtrl);
   ChartRedraw(ChartID());
}//======== END LoadDashboardValuesAndDraw ===============
//+------------------------------------------------------------------+
//| Draw Display Functions - Set up each label object and draw it    |
//+------------------------------------------------------------------+
void DrawDisplay(C_pairsArys* sell_arys, C_pairsArys* buy_arys, C_bsktCtrl* o_DispCtrl) // Make the display
{
   o_DispCtrl.SetDefaults(o_DispCtrl.GetXOrigins(),o_DispCtrl.GetYOrigins(),11,clrNONE);  // Start Fresh (Line zero)
   //
   DisplayHeaderLine( o_DispCtrl );  // Draw the first line
   //
   DisplayABasket( buy_arys, o_DispCtrl );  // Display a basket
   //
   DisplayABasket( sell_arys, o_DispCtrl );  // Display a Basket
   //
   if(o_DispCtrl.GetIfWeekShouldBeMarked()==ON){  // Highlight a week
      DrawRectangle(o_DispCtrl, WK_MRK_IDX);
    }
   //
}//=== END DrawDisplay ========================
void DisplayHeaderLine(C_bsktCtrl* o_DispCtrl)
{
   // =======  First Line; Draw Title =========
   o_DispCtrl.SetObjName( disp_obj_nms[TITLE_IDX] );  // The Drag object, and the Title display for the indicator
   o_DispCtrl.SetDispString( "Basket Viewer (wk "+IntegerToString(o_DispCtrl.GetDispWeekNum())+"): " );
   o_DispCtrl.SetYDispPos( o_DispCtrl.GetYOrigins()+(o_DispCtrl.GetDispLineNum()*o_DispCtrl.GetYOffSet()) );
   o_DispCtrl.SetXDispPos( o_DispCtrl.GetXOrigins() + o_DispCtrl.GetXDragOffset() );
   o_DispCtrl.SetColor( TitleClr );
   o_DispCtrl.SetSelectable( true );  // Must be true so it can be dragged and dropped
   ManageALabel(o_DispCtrl);
   o_DispCtrl.SetSelectable( false );  // Don't want any other objects to be selectable.
   // --------- Draw Start Week on first line
   o_DispCtrl.SetObjName( disp_obj_nms[STRTWK_IDX] );  // Display the Start of the Week for the Weekly values - this object increments the week # when clicked.
   o_DispCtrl.SetDispString( TimeToString(o_DispCtrl.GetWeekStartTime(),TIME_DATE)+"  - " );
   o_DispCtrl.SetXDispPos( o_DispCtrl.GetXOrigins()+80 );
   o_DispCtrl.SetColor( TitleClr );
   ManageALabel(o_DispCtrl);
   // ------------ Draw End Week on first line
   o_DispCtrl.SetObjName( disp_obj_nms[ENDWK_IDX] );   // Display the End of the Week for the Weekly values - this object decrements the week # when clicked.
   o_DispCtrl.SetDispString( TimeToString(o_DispCtrl.GetWeekEndTime(),TIME_DATE) );
   o_DispCtrl.SetXDispPos( o_DispCtrl.GetXOrigins() );
   o_DispCtrl.SetColor( TitleClr );
   ManageALabel(o_DispCtrl);
}// END DisplayheaderLines =================
void DisplayABasket( C_pairsArys* c_pairs, C_bsktCtrl* o_DispCtrl )
{
   // ======= 2nd Line, Make a Basket Header ============
   o_DispCtrl.IncrementLineNum(1);
   switch (c_pairs.GetSymbolOp()) {
      case SYMB_BUY:
         o_DispCtrl.SetObjName( disp_obj_nms[LONG_HDR_IDX] ); // Display Header for the Long Basket
         break;
      case SYMB_SELL:
         o_DispCtrl.SetObjName( disp_obj_nms[SHORT_HDR_IDX] ); // Display Header for the Short Basket
         break;
      default:
         o_DispCtrl.SetObjName( disp_obj_nms[SHORT_HDR_IDX]+IntegerToString( c_pairs.GetSymbolOp() ) );
         break;
    }
   o_DispCtrl.SetDispString(GetBasketHeaderLine(c_pairs));
   o_DispCtrl.SetYDispPos( o_DispCtrl.GetYOrigins()+(o_DispCtrl.GetDispLineNum()*o_DispCtrl.GetYOffSet()) );
   o_DispCtrl.SetColor( HeadClr );
   ManageALabel(o_DispCtrl);
   // ========= Buy Details; 3rd Line sharts the Basket Display ======
   DisplayPairsValues(o_DispCtrl, c_pairs);
} // ========= END DisplayABasket ===========
string GetBasketHeaderLine(C_pairsArys* c_pairs)
{
   string dispString;
   switch (c_pairs.GetSymbolOp()) {
      case SYMB_BUY:
         if(c_pairs.GetATRSourceSwitchValue()==ON){
            dispString = "BUY BASKET      Points    Term_ATR    Pos_Prft    Pos_Lots";
          }else{ // == OFF
            dispString = "BUY BASKET      Points      Indi_ATR    Pos_Prft    Pos_Lots";
          }
         break;
      case SYMB_SELL:
         if(c_pairs.GetATRSourceSwitchValue()==ON){
            dispString = "SELL BASKET      Points    Term_ATR    Pos_Prft    Pos_Lots";
          }else{ // == OFF
            dispString = "SELL BASKET      Points      Indi_ATR    Pos_Prft    Pos_Lots";
          }
         break;
      default:
         dispString = __FUNCTION__+" called with invalid operration, "+IntegerToString(c_pairs.GetSymbolOp());
         break;
    }
   return dispString;
} // ======= End GetBasketHeaderLin ==============
void DisplayPairsValues(C_bsktCtrl* o_DispCtrl, C_pairsArys* c_pairs)  // Draw a line for each Basket pair
{
   double bsktTtl=0, prftTtl=0, lotsTtl=0, atrTtl=0, positionPoints;  // Hold Basket Totals
   int arySize = c_pairs.GetPairArraySize();
   for(int idx=0; idx<arySize; idx++){ // Increment htrue the basket array, and increment the display line for each row.
      o_DispCtrl.IncrementLineNum(1);  // Increment the line # and start drawing a row
      o_DispCtrl.SetYDispPos( o_DispCtrl.GetYOrigins()+(o_DispCtrl.GetDispLineNum()*o_DispCtrl.GetYOffSet()) );
      //======= Column 1, Display the Pair Strings ================
      DisplayPairString(o_DispCtrl, c_pairs, idx);
      //======= Column 1.5, Display the Pair Speed Arrow ================
      DisplaySpeedArrow(o_DispCtrl, c_pairs, idx);
      //======= Column 2, Display the Pair Movement in Points from the Week Start ================
      DisplayPointsMovement(o_DispCtrl, c_pairs, idx, positionPoints);
      //======= Column 3, Display the Pair's ATR (how significant is the movement?) ================
      DisplayATR(o_DispCtrl,c_pairs,idx);
      //======= Column 4, Display the Profit or loss associated with any trades for each symbol pair ================
      DisplayPositionGainLoss(o_DispCtrl, c_pairs, idx);
      //======= Column 5 (last column, no offset), Display the # of lots exposed in trades fore each symbol pair ================
      DisplayPositionLots(o_DispCtrl,c_pairs, idx);
      //
      // Sum it up for display
      bsktTtl += positionPoints;
      prftTtl += c_pairs.GetSymbolPosVal(idx);
      lotsTtl += c_pairs.GetSymbolLotsVal(idx);
      atrTtl  += c_pairs.GetSymbolATRVal(idx);
    }
   //===== Dispaly a Total Separation Line ===========
   o_DispCtrl.IncrementLineNum(1);
      o_DispCtrl.SetYDispPos( o_DispCtrl.GetYOrigins()+(o_DispCtrl.GetDispLineNum()*o_DispCtrl.GetYOffSet()) );
      o_DispCtrl.SetObjName( disp_obj_nms[SUM_LINE_IDX]+GetOpDescription(c_pairs.GetSymbolOp()) );
      o_DispCtrl.SetDispString( "=================================" );
      o_DispCtrl.SetColor( HeadClr );
      ManageALabel(o_DispCtrl);
   //===== Dispaly the Column Totals, 4 values all on the next line ===========
   o_DispCtrl.IncrementLineNum(1); // Increment the line # and start drawing a row
      // Column 5 totals, no offset, Lots Exposure
      o_DispCtrl.SetObjName( disp_obj_nms[SUMS_IDX]+"LOT_SUM"+GetOpDescription(c_pairs.GetSymbolOp()) );  // Column 5, the position exposure lots total.
      o_DispCtrl.SetYDispPos( o_DispCtrl.GetYOrigins()+(o_DispCtrl.GetDispLineNum()*o_DispCtrl.GetYOffSet()) );
      o_DispCtrl.SetDispString( DoubleToString(lotsTtl,2) );
      o_DispCtrl.SetXDispPos( o_DispCtrl.GetXOrigins() );
      o_DispCtrl.SetColor( TotalClr );
      ManageALabel(o_DispCtrl);
   // collumn 4 Totals, Postion Points Movement
      o_DispCtrl.SetObjName( disp_obj_nms[SUMS_IDX]+"PFT_SUM"+GetOpDescription(c_pairs.GetSymbolOp()) );   // Column 4, the Basket Profit or loss.
      o_DispCtrl.SetDispString( DoubleToString(prftTtl,2) );
      o_DispCtrl.SetXDispPos( o_DispCtrl.GetXOrigins()+o_DispCtrl.GetColumnFourOffset() );
      if(prftTtl>=0.0){  // o_DispCtrl.objClr     = ((prftTtl>=0.0)?ProfitClr:LossClr);
         o_DispCtrl.SetColor( ProfitClr );
       }else o_DispCtrl.SetColor(LossClr );
      ManageALabel(o_DispCtrl);
   // column 3 totals, Sum of ATRS, probably has no value except for display continuity
      o_DispCtrl.SetObjName(  disp_obj_nms[SUMS_IDX]+"ATR_SUM"+GetOpDescription(c_pairs.GetSymbolOp()) );    // Column 3, the Basket's total ATR - Seems like a useless sum.
      o_DispCtrl.SetDispString( IntegerToString( (int) atrTtl) );
      o_DispCtrl.SetXDispPos( o_DispCtrl.GetXOrigins()+o_DispCtrl.GetColumnThreeOffset() );
      o_DispCtrl.SetColor( TotalClr );
      ManageALabel(o_DispCtrl);
   // Column 2 totals, Sum of the Points Movement for the Week.
      o_DispCtrl.SetObjName( disp_obj_nms[SUMS_IDX]+"BSKT_SUM"+GetOpDescription(c_pairs.GetSymbolOp()) );     // Column 2, the Basket's total Points movement for the week
      o_DispCtrl.SetDispString( IntegerToString( (int) bsktTtl) );
      o_DispCtrl.SetXDispPos( o_DispCtrl.GetXOrigins()+o_DispCtrl.GetColumnTwoOffset() );
      if(bsktTtl>=0.0){
         o_DispCtrl.SetColor( ProfitClr );
       }else o_DispCtrl.SetColor( LossClr );
      ManageALabel(o_DispCtrl);
   //
   // Done, return the xPos and yPos to the original position before exiting.
   o_DispCtrl.SetXDispPos( o_DispCtrl.GetXOrigins());
   o_DispCtrl.SetYDispPos( o_DispCtrl.GetYOrigins() );
}//====== END DisplayPairsValues ===========
void DisplayPairString(C_bsktCtrl* o_DispCtrl, C_pairsArys* c_pairs, const int& idx)
{
   o_DispCtrl.SetObjName( GetRowPairObjName( disp_obj_nms[BSKT_ROW_IDX], c_pairs.GetPairSymbol(idx), o_DispCtrl.GetDispLineNum(), c_pairs.GetSymbolOp() ) );
   o_DispCtrl.SetDispString( c_pairs.GetPairSymbol(idx) ); // + ": "+DoubleToStr(c_pairs.baseVal_ary[i],_Digits)+":";
   if(c_pairs.GetSymbolOp()==SYMB_SELL){              // o_DispCtrl.objClr = (c_pairs.symb_op==SYMB_SELL)?SlotsSellClr:SlotsBuyClr;
      o_DispCtrl.SetColor( LotsSellClr );
    }else o_DispCtrl.SetColor( LotsBuyClr );           // c_pairs.symb_op==SYMB_BUY
   o_DispCtrl.SetXDispPos( o_DispCtrl.GetXOrigins()+o_DispCtrl.GetColumnOneOffset() );
   ManageALabel(o_DispCtrl);
}//========= DisplayPairString =============
void DisplaySpeedArrow(C_bsktCtrl* o_DispCtrl, C_pairsArys* c_pairs, const int& idx)
{
   double arrowAngle = c_pairs.GetSpeedAngle(idx);
   o_DispCtrl.SetObjName( disp_obj_nms[BSKT_ROW_IDX]+"ARROW"+IntegerToString(o_DispCtrl.GetDispLineNum())+GetOpDescription(c_pairs.GetSymbolOp()) );
   if( c_pairs.GetSymbolOp()==SYMB_SELL ){
      o_DispCtrl.SetColor((arrowAngle<0)?ProfitClr:LossClr);
    }else{ //c_pairs.symb_op==SYMB_BUY
      o_DispCtrl.SetColor((arrowAngle<0)?LossClr:ProfitClr);
    }
   o_DispCtrl.SetDispString( DoubleToString(arrowAngle,1) );  // Wingding arrow angle
   o_DispCtrl.SetXDispPos( (o_DispCtrl.GetXOrigins()+o_DispCtrl.GetColumnOneOffset())-15);
   ManageAnArrow(o_DispCtrl, arrowAngle);
}
void DisplayPointsMovement(C_bsktCtrl* o_DispCtrl, C_pairsArys* c_pairs, const int& idx, double& positionPoints)
{
   o_DispCtrl.SetObjName( disp_obj_nms[BSKT_ROW_IDX]+IntegerToString(o_DispCtrl.GetDispLineNum())+GetOpDescription(c_pairs.GetSymbolOp())+"PAIRVAL");
   if(c_pairs.GetSymbolOp()==SYMB_SELL){
      positionPoints = ((c_pairs.GetSymbStartVal(idx)-c_pairs.GetSymbolEndVal(idx))/SymbolInfoDouble(c_pairs.GetPairSymbol(idx),SYMBOL_POINT))-SymbolInfoInteger(c_pairs.GetPairSymbol(idx),SYMBOL_SPREAD); // MODE_SPREAD is in Points, and you will always pay the spread
    }else{ //c_pairs.symb_op==SYMB_BUY
      positionPoints = ((c_pairs.GetSymbolEndVal(idx)-c_pairs.GetSymbStartVal(idx))/SymbolInfoDouble(c_pairs.GetPairSymbol(idx),SYMBOL_POINT))+SymbolInfoInteger(c_pairs.GetPairSymbol(idx),SYMBOL_SPREAD); // MODE_SPREAD is in Points, and you will always pay the spread
    }
   o_DispCtrl.SetDispString( IntegerToString((int)positionPoints) );  // Time for the value  +", "+TimeToString(c_pairs.GetWeekTm(idx),TIME_DATE) );
   o_DispCtrl.SetXDispPos( o_DispCtrl.GetXOrigins()+o_DispCtrl.GetColumnTwoOffset());
   if(positionPoints>=0.0){  // o_DispCtrl.objClr     = ((positionVal>=0.0)?ProfitClr:LossClr);
      o_DispCtrl.SetColor(ProfitClr);
    }else o_DispCtrl.SetColor(LossClr);
   ManageALabel(o_DispCtrl);
} // ======== END DisplayPointsMovement ==========
void DisplayATR(C_bsktCtrl* o_DispCtrl, C_pairsArys* c_pairs, const int& idx)
{
   o_DispCtrl.SetObjName( disp_obj_nms[BSKT_ROW_IDX]+IntegerToString(o_DispCtrl.GetDispLineNum())+GetOpDescription(c_pairs.GetSymbolOp())+"PAIRATR");
   o_DispCtrl.SetDispString( IntegerToString((int)c_pairs.GetSymbolATRVal(idx)) );
   o_DispCtrl.SetXDispPos( o_DispCtrl.GetXOrigins()+o_DispCtrl.GetColumnThreeOffset());
   o_DispCtrl.SetColor(TotalClr);
   ManageALabel(o_DispCtrl);
} // ======= END DisplayATR ==================
void DisplayPositionGainLoss(C_bsktCtrl* o_DispCtrl, C_pairsArys* c_pairs, const int& idx)
{
   o_DispCtrl.SetObjName( disp_obj_nms[BSKT_ROW_IDX]+IntegerToString(o_DispCtrl.GetDispLineNum())+GetOpDescription(c_pairs.GetSymbolOp())+"POSVAL" );
   o_DispCtrl.SetDispString( DoubleToString(c_pairs.GetSymbolPosVal(idx),2) );
   o_DispCtrl.SetXDispPos( o_DispCtrl.GetXOrigins()+o_DispCtrl.GetColumnFourOffset() );
   if(c_pairs.GetSymbolPosVal(idx)>=0.0){  // o_DispCtrl.objClr     = ((c_pairs.posVal_ary[i]>=0.0)?ProfitClr:LossClr);
      o_DispCtrl.SetColor(ProfitClr);
    }else o_DispCtrl.SetColor(LossClr);
   ManageALabel(o_DispCtrl);
} // ============= END DisplayPositionGainLoss ===========
void DisplayPositionLots(C_bsktCtrl* o_DispCtrl, C_pairsArys* c_pairs, const int& idx)
{
   o_DispCtrl.SetObjName( disp_obj_nms[BSKT_ROW_IDX]+IntegerToString(o_DispCtrl.GetDispLineNum())+GetOpDescription(c_pairs.GetSymbolOp())+"PLOTS" );
   o_DispCtrl.SetDispString( DoubleToString(c_pairs.GetSymbolLotsVal(idx),2) );
   o_DispCtrl.SetXDispPos( o_DispCtrl.GetXOrigins() );
   o_DispCtrl.SetColor( TotalClr );
   ManageALabel(o_DispCtrl);
} // ========== END DisplayPositionLots ==========
void ManageALabel( C_bsktCtrl*& o_DispCtrl)  // display a Label with paramaters in the structure
{
   static long chartID = ChartID();
   if ( ObjectFind(chartID,o_DispCtrl.GetObjName()) < 0 ) // Create if it's not already there.
    {
      ObjectCreate    (chartID, o_DispCtrl.GetObjName(), OBJ_LABEL, o_DispCtrl.GetWindowNum(),  0, 0);
      ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_FONTSIZE,  o_DispCtrl.GetFontSize());
      ObjectSetString (chartID, o_DispCtrl.GetObjName(), OBJPROP_FONT,      "Arial");
      ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_CORNER,    o_DispCtrl.GetBaseCorner());
      ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_ANCHOR,    o_DispCtrl.GetObjectAnchor());
      ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_BACK,      true); 
      ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_SELECTABLE,o_DispCtrl.GetSelectable()); 
      ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_SELECTED,  false); 
      ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_HIDDEN,    false);
    }
   ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_COLOR,     o_DispCtrl.GetDispClr());
   ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_XDISTANCE, o_DispCtrl.GetXPos() );
   ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_YDISTANCE, o_DispCtrl.GetYPos() );
   ObjectSetString (chartID, o_DispCtrl.GetObjName(), OBJPROP_TEXT,      o_DispCtrl.GetDispString() );
} // ========= END ManageALabel ==========
void DrawRectangle(C_bsktCtrl* o_DispCtrl, DISP_OBJ_IDX objNameIdx)  // Set parameters for drawing the rectangle
{
   o_DispCtrl.SetObjName(disp_obj_nms[objNameIdx]);
   o_DispCtrl.SetColor(C'154,101,129');
   ManageARectangle(o_DispCtrl);
} // ========= END DrawRectangle ===========
void ManageARectangle(C_bsktCtrl* o_DispCtrl)   // display a rectangle with paramaters in the structure
{
   static long chartID = ChartID();
   double weekHigh = iHigh(_Symbol,PERIOD_W1,o_DispCtrl.GetDispWeekNum() );
   double weekLow  = iLow(_Symbol,PERIOD_W1,o_DispCtrl.GetDispWeekNum() );
   if ( ObjectFind(chartID,o_DispCtrl.GetObjName()) < 0 )
    {
      ObjectCreate    (chartID, o_DispCtrl.GetObjName(), OBJ_RECTANGLE, o_DispCtrl.GetWindowNum(),  o_DispCtrl.GetWeekStartTime(), weekHigh, o_DispCtrl.GetWeekEndTime(), weekLow);
      ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_STYLE,     STYLE_SOLID);
      ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_WIDTH,     1);
      ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_FILL,      true);
      ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_BACK,      true);
      ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_COLOR,     o_DispCtrl.GetDispClr());
      ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_SELECTABLE,o_DispCtrl.GetSelectable()); 
      ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_SELECTED,  false); 
      ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_HIDDEN,    false);
    }
   ObjectMove(chartID, o_DispCtrl.GetObjName(), 0, o_DispCtrl.GetWeekStartTime(), weekHigh);
   ObjectMove(chartID, o_DispCtrl.GetObjName(), 1, o_DispCtrl.GetWeekEndTime(),   weekLow);
} // ========= END ManageARectangle ==========
void ManageAnArrow( C_bsktCtrl*& o_DispCtrl, const double arrowAngle = 0)  // display a Label with paramaters in the structure
{
   static long chartID = ChartID();
   if ( ObjectFind(chartID,o_DispCtrl.GetObjName()) < 0 ) // Create if it's not already there.
    {
      ObjectCreate    (chartID, o_DispCtrl.GetObjName(), OBJ_LABEL, o_DispCtrl.GetWindowNum(),  0, 0);
      ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_FONTSIZE,  o_DispCtrl.GetFontSize());
      ObjectSetString (chartID, o_DispCtrl.GetObjName(), OBJPROP_FONT,      "Wingdings");
      ObjectSetString (chartID, o_DispCtrl.GetObjName(), OBJPROP_TEXT,      "\224" );
      ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_CORNER,    o_DispCtrl.GetBaseCorner());
      ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_ANCHOR,    ANCHOR_CENTER);
      ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_BACK,      true); 
      ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_SELECTABLE,o_DispCtrl.GetSelectable()); 
      ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_SELECTED,  false); 
      ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_HIDDEN,    false);
    }
   ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_COLOR,     o_DispCtrl.GetDispClr());
   ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_XDISTANCE, o_DispCtrl.GetXPos() );
   ObjectSetInteger(chartID, o_DispCtrl.GetObjName(), OBJPROP_YDISTANCE, o_DispCtrl.GetYPos()+10 ); // modify to adjust for anchor center.
   ObjectSetDouble (chartID, o_DispCtrl.GetObjName(), OBJPROP_ANGLE,     arrowAngle);
} // ========= END ManageAnArrow ==========
//+------------------------------------------------------------------+
//| End Draw Display Functions                                       |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| START Helper Functions                                           |
//+------------------------------------------------------------------+
string GetRowPairObjName( const string objNmPrefix, const string pairName, int lineNum, const SYMBOL_OPERATION symb_op )  // constructed to use in OnChartEvent to change chart symbol
{
   string theName = objNmPrefix+pairName+"PAIR"+IntegerToString(lineNum)+GetOpDescription(symb_op);
   return theName;
} // ========= END GetRowPairObjName ====================
//+------------------------------------------------------------------+
//| END Helper Functions                                             |
//+------------------------------------------------------------------+
//