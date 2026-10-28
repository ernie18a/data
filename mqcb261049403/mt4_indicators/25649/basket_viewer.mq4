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
#property version     "1.02";
#property description "View a Buy and a Sell Basket"
#property strict
#include <stdlib.mqh>  //  for ErrorDescription
#property indicator_chart_window
//+------------------------------------------------------------------+
//|        ======= User Control ==============                       |
//+------------------------------------------------------------------+
extern uint uniquifier      = 3856; // Make Object Names Unique
extern int  CycleWeekLimit  = 10;   // Limit for weeks looked back (10)
//
extern int    BullBearPeriod = 13;   // 13 is standard for Bears/Bulls
extern string SampleSellStr  = "CHFJPY,GBPCHF,GBPUSD,AUDJPY,EURGBP,USDCHF,EURJPY";   // Sample Sell Pairs String
extern string SampleBuyStr   = "CADJPY,USDJPY,GBPJPY,USDCAD,EURCHF,AUDUSD,EURUSD";   // Sample Buy Pairs String
extern string SetForSell     = "==Symbol Pairs for SELL==";                          // Edit Symbol Pairs to Sell
extern string SellPairs      = "CHFJPY,GBPCHF,GBPUSD,AUDJPY,EURGBP,USDCHF,EURJPY";   // Sell Pairs String
extern string SetForBuy      = "==Symbol Pairs for BUY==";                           // Edit Symbol Pairs to Buy
extern string BuyPairs       = "CADJPY,USDJPY,GBPJPY,USDCAD,EURCHF,AUDUSD,EURUSD";   // Buy Pairs String
//
extern string Colors_Setting = "Colors";
extern color TitleClr        = clrWhite;
extern color HeadClr         = clrWheat;
extern color SlotsSellClr    = clrCoral;
extern color SlotsBuyClr     = clrChartreuse;
extern color TotalClr        = clrLightGoldenrod;
extern color ProfitClr       = clrLimeGreen;
extern color LossClr         = clrOrangeRed;
extern int   RsiPeriod       = 14; // RSI Period,example: 14.
//======= End User Control ==============
//======= Custome EVENT Definitiions CHARTEVENT_CUSTOM_LAST — the last acceptable ID of a custom event (CHARTEVENT_CUSTOM +65535).
const ushort CHARTEVENT_MAKECHART = 37;
//---- Global Convenience Variables -----
enum DISP_OBJ_IDX       {TITLE_IDX, STRTWK_IDX, ENDWK_IDX, LONG_HDR_IDX, SHORT_HDR_IDX,  BSLT_ROW_IDX, SUM_LINE_IDX, SUMS_IDX, INDI_LBL_IDX, WK_MRK_IDX, END_DISP_OBJ_IDX};
string disp_obj_nms[] = {"_TITLE",  "_STARTWK", "_ENDWK",  "_LNG_HDR",   "_SHRT_HDR",   "_BSKT_ROW",   "_SUM_LINE",  "_SUMS",  "_INDI_LBL",  "_WK_MRK"   };
enum SYMBOL_OPERATION { SYMB_BUY, SYMB_SELL, SYMB_LBUY, SYMB_LSELL, SYMB_SBUY, SYMB_SSELL };
const int CHART_WINDOW = 0;
const int NOSHIFT      = 0;
const int NOMODIFIER   = 0;
//
struct Pairs_Arrays
 {
   SYMBOL_OPERATION symb_op;
   string pairs_ary[];    // Array of Pairs in the Basket
   double baseVal_ary[];  // Array of Basket Period Starting Prices for the Basket
   double baseATR_ary[];  // Array of ATRs for the Basket, in Points
   double pairVal_ary[];  // Array of Current Prices in the Basket
   double posVal_ary[];   // Array of Order Profit values for the basket
   double posLots_ary[];  // Array of Order Lots Exposed for the basket
   void Pairs_Arrays(int initialSize,SYMBOL_OPERATION sym_op)  // Function to size the arrays
    {
      symb_op = sym_op;
      if(ArrayResize(pairs_ary,initialSize)!=initialSize){
         int errCode = GetLastError();
         Print("ArrayResize of pairs_ary in Pairs_Arrays constructor failed, error: "+IntegerToString(errCode)+", "+ErrorDescription(errCode));
       }
    }
   ENUM_INIT_RETCODE SizePairArrays( const ENUM_INIT_RETCODE& init_status )  // function for OnInit to call to size to the number of the user supplied pairs 
    {
      ENUM_INIT_RETCODE result = init_status;
      int pairsSize;
      if(result==INIT_SUCCEEDED){
         pairsSize = ArrayRange(pairs_ary,0);
         if( pairsSize<1 )
          {
            result=INIT_FAILED;
            Print("No Market Watch Symbols were found to work with for "+GetOpDescription(symb_op)+" pairs, exiting");
          } else {
            result = ResizeArray(baseVal_ary,  pairsSize, result);
            result = ResizeArray(pairVal_ary,  pairsSize, result);
            result = ResizeArray(posLots_ary,  pairsSize, result);
            result = ResizeArray(posVal_ary,   pairsSize, result);
            result = ResizeArray(baseATR_ary,  pairsSize, result);
          }
       }
      return result;
    }// == END SizePairArrays ============
   ENUM_INIT_RETCODE ResizeArray(double& array[], const int& ary_size, const ENUM_INIT_RETCODE& init_status) // SizePairArrays Helper function to do the actual array resizing 
   {
      ENUM_INIT_RETCODE result = init_status;
      if(result==INIT_SUCCEEDED){
         if(ArrayResize(array,ary_size)!=ary_size){
            result=INIT_FAILED; int errCode=GetLastError();
            Print(GetOpDescription(symb_op)+" array resize failed, error: "+IntegerToString(errCode)+", "+ErrorDescription(errCode));
          }
       }
      return result;
   }// ========== END ResizeArray ================
 } sellPairs_struc(50,SYMB_SELL), buyPairs_struc(50,SYMB_BUY);
//
struct Disp_bsktCtrl_struc
 {
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
   bool markWeek;
   datetime weekStart, weekEnd;
   Disp_bsktCtrl_struc(long x_pos, long y_pos, int font_size, color obj_clr){
      SetDefaults(x_pos, y_pos, font_size, obj_clr);
      markWeek=false;  weekNum=0;
      xOriginPos = x_pos; yOriginPos=y_pos;
      xDragOffset = 170;
    }
   void SetDefaults(long x_pos, long y_pos, int font_size, color obj_clr){
      yPos=y_pos; xPos=x_pos; lineNum=0; columnNum=0; fontSize=font_size; yOffset=15;
      col_1_offset=320; col_2_offset=240; col_3_offset=160; col_4_offset=80;
      selectable=false; objClr=obj_clr; objCorner=CORNER_RIGHT_UPPER; objAnchor=ANCHOR_RIGHT_UPPER;
      objName=NULL; objDispStr=NULL; objWindow=CHART_WINDOW;
    }
 } bsktCtrl_struc(40,40,11,clrNONE);
string comment_string="";
datetime lastPostTime = NULL;
// Global Variable Names for Chart Placement
enum ENUM_CHART_PLACEMENT {X_PLCMNT_IDX, Y_PLCMNT_IDX };
string GetPositionGlobalName(const ENUM_CHART_PLACEMENT plcIdx)
{
   string gName="";
   switch (plcIdx){
      case X_PLCMNT_IDX: gName = "X_PLCEMENT_IDX"+IntegerToString(uniquifier); break;
      case Y_PLCMNT_IDX: gName = "Y_PLCEMENT_IDX"+IntegerToString(uniquifier); break;
      default: Print(__FUNCTION__+" Invalid Placement Index: "+IntegerToString(plcIdx)); break;
    }
   return(gName);
}
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() 
{ 
   ENUM_INIT_RETCODE init_result = INIT_SUCCEEDED;
   indicator_name = indicator_name+IntegerToString(uniquifier);  // Make name unigue to user suppliable instance identifier
   IndicatorShortName(indicator_name);
   EventSetTimer(1);    //--- create a timer with a 1 second period 
   for(DISP_OBJ_IDX idx=0; idx<END_DISP_OBJ_IDX; idx++){ // Add uniquifier to Object Names to make them unique to this indicator
      disp_obj_nms[idx] = IntegerToString(uniquifier)+disp_obj_nms[idx];
    }
   double globalVariableValue;
   int xPosMax = (int)  ChartGetInteger(ChartID(),CHART_WIDTH_IN_PIXELS,CHART_WINDOW);  // find chart width in pixels.
   int yPosMax = (int)  ChartGetInteger(ChartID(),CHART_HEIGHT_IN_PIXELS,CHART_WINDOW); // find chart heigth in pixels.
   double globalVariableResult = GlobalVariableGet(GetPositionGlobalName(X_PLCMNT_IDX),globalVariableValue);  // Get the x placement location - supports drag and drop for placement
   if( (globalVariableResult>0) && (globalVariableValue>-1) && (globalVariableValue<(xPosMax-bsktCtrl_struc.col_1_offset)) ){ // No Error and a valid value (between 0 and not offscreen)
      bsktCtrl_struc.xOriginPos = (int) globalVariableValue;
    } // else leave ctrlStruc.xOriginPos at the value it was instantiated with
   globalVariableResult = GlobalVariableGet(GetPositionGlobalName(Y_PLCMNT_IDX),globalVariableValue);   // Get the y placement location - supports drag and drop for placement
   if( (globalVariableResult>0) && (globalVariableValue>-1) && (globalVariableValue<(yPosMax-20)) ){ // No Error and a valid value (0 and 1 line from disapearing)
     bsktCtrl_struc.yOriginPos = (int) globalVariableValue;
    } // else leave ctrlStruc.xOriginPos at the value it was instantiated with
   init_result = LoadPairsAry(sellPairs_struc, SellPairs, init_result);     // Insert User Control Values into the work symbol array
   init_result = LoadPairsAry(buyPairs_struc, BuyPairs, init_result);       // Insert User Control Values into the work symbol array
   init_result = sellPairs_struc.SizePairArrays(init_result);               // Size Arrays that much match the buy and sell symbol array sizes
   init_result = buyPairs_struc.SizePairArrays(init_result);                // Size Arrays that much match the buy and sell symbol array sizes
   SampleSellStr = "CHFJPY,GBPCHF,GBPUSD,AUDJPY,EURGBP,USDCHF,EURJPY";      // Put it back if user changes it
   SampleBuyStr  = "CADJPY,USDJPY,GBPJPY,USDCAD,EURCHF,AUDUSD,EURUSD";      // Put it back if user changes it
   SetForSell    = "==Symbol Pairs for SELL==";                             // put it back if user changes it
   SetForBuy     = "==Symbol Pairs for BUY==";                              // put it back if user changes it
   return(init_result);
}//========= END OnInit ==========
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer(); // Kill the timer
   if(StringLen(comment_string)>0){  // Clean up the Comment if this indicator made one.
      Comment("");
    }
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
    {
      string label = ObjectName(i);
      if(StringSubstr(label,0,StringLen(IntegerToString(uniquifier)))==IntegerToString(uniquifier)){  // Only delete objects with this indicators identifier on them
         ObjectDelete(label);
       }
    }
}// ========= END OnDeinit ==========
//+------------------------------------------------------------------+
//| Chart Event Handler                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
 {
    if(id==CHARTEVENT_OBJECT_CLICK){
      if(sparam==disp_obj_nms[STRTWK_IDX]){
         bsktCtrl_struc.weekNum++;
         if( bsktCtrl_struc.weekNum > CycleWeekLimit ){
            bsktCtrl_struc.weekNum = 0;
          }
         LoadBasePrices(buyPairs_struc, sellPairs_struc, bsktCtrl_struc );
         MakeTheDashBoard();
       }else if(sparam==disp_obj_nms[ENDWK_IDX]){
         bsktCtrl_struc.weekNum--;
         if( bsktCtrl_struc.weekNum < 0 ){
            bsktCtrl_struc.weekNum = CycleWeekLimit;
          }
         LoadBasePrices(buyPairs_struc, sellPairs_struc, bsktCtrl_struc );
         MakeTheDashBoard();
       }else if(sparam==disp_obj_nms[LONG_HDR_IDX]){
         bsktCtrl_struc.markWeek=(bsktCtrl_struc.markWeek==true)?false:true; // toggle the rectangle draw indicator
         if(bsktCtrl_struc.markWeek==false){
            ObjectDelete(disp_obj_nms[WK_MRK_IDX]);
          }else{
           DrawDisplay( sellPairs_struc, buyPairs_struc, bsktCtrl_struc);
          }
       }else if( StringSubstr(sparam,0,StringLen(disp_obj_nms[BSLT_ROW_IDX])) == disp_obj_nms[BSLT_ROW_IDX] ){
         int endPos     = StringFind(sparam, "PAIR", WHOLE_ARRAY);
         int startPos   = StringLen(disp_obj_nms[BSLT_ROW_IDX]);
         string pairStr = StringSubstr(sparam, startPos, endPos-startPos);
         if( pairStr != ChartSymbol(ChartID())){
            ChartSetSymbolPeriod(ChartID(),pairStr,PERIOD_CURRENT);
          }
       }
    }else if(id==CHARTEVENT_CUSTOM+CHARTEVENT_MAKECHART){  // Request to Draw the Indicator Dashboard
      if(lparam==uniquifier){
         lastPostTime = TimeLocal();
         MakeTheDashBoard();
       }
    }else if(id==CHARTEVENT_OBJECT_DRAG){  //sparam = Name of the moved graphical object
      if( sparam==disp_obj_nms[TITLE_IDX] ){  // This is the drage object, the pannel has been drug to a new location, display the panel at that location.
         
         long newXpos, newYpos;
         newXpos = ObjectGetInteger( ChartID(), sparam, OBJPROP_XDISTANCE, NOMODIFIER );   // Get after-drag Move Object Position
         newYpos = ObjectGetInteger( ChartID(), sparam, OBJPROP_YDISTANCE, NOMODIFIER );   // Get after-drag Move Object Position
         newXpos = newXpos - bsktCtrl_struc.xDragOffset;  // Adjust for the xOffset to the drag object (there is no y offset to the drag object
         bsktCtrl_struc.xOriginPos = (int)newXpos; // Set all the new positions
         bsktCtrl_struc.yOriginPos = (int)newYpos; // Set all the new positions
         GlobalVariableSet(GetPositionGlobalName(X_PLCMNT_IDX), bsktCtrl_struc.xOriginPos);
         GlobalVariableSet(GetPositionGlobalName(Y_PLCMNT_IDX), bsktCtrl_struc.yOriginPos);
         DrawDisplay(sellPairs_struc, buyPairs_struc, bsktCtrl_struc); // Display at the new position
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
   bool newWeek = ThereIsNewWeekBar();
   if( newWeek || (prev_calculated<1) || (rates_total<prev_calculated) ){
      if(newWeek){
         LoadBasePrices(sellPairs_struc, buyPairs_struc, bsktCtrl_struc);  // Set the weeks start value of the basket
       }
    }
   //
   EventChartCustom(ChartID(),CHARTEVENT_MAKECHART, uniquifier, NULL, NULL);
   //
   return rates_total;
}//====== END OnCalculate ==============
bool ThereIsNewWeekBar(void)
{
   bool result=false;
   static datetime lastBarTime=NULL;
   datetime currBarTime = iTime(_Symbol,PERIOD_W1,NOSHIFT);
   if(currBarTime != lastBarTime){  // Week Bar has changed
      lastBarTime = currBarTime;
      result=true;
    }
   return result;
}//====== END ThereIsNewWeekBar ======================
void LoadBasePrices(Pairs_Arrays& buyPair_struc, Pairs_Arrays& sellPair_struc, const Disp_bsktCtrl_struc& bsktCtrlStruc )
{
   RefreshRates();
   for(int i=0; i<ArrayRange(buyPair_struc.pairs_ary,0); i++){
      buyPair_struc.baseVal_ary[i] = iOpen(buyPair_struc.pairs_ary[i],PERIOD_W1,bsktCtrlStruc.weekNum);
    }
   for(int i=0; i<ArrayRange(sellPair_struc.pairs_ary,0); i++){
      sellPair_struc.baseVal_ary[i] = iOpen(sellPair_struc.pairs_ary[i],PERIOD_W1,bsktCtrlStruc.weekNum);
    }
}//========== END LoadBasePrices ==================
//+------------------------------------------------------------------+
//| Indicator Event Action                                           |
//+------------------------------------------------------------------+
void MakeTheDashBoard(void)
{
   GetBasketValue(sellPairs_struc);  // Find the Value of the sell Basket for the week
   GetBasketValue(buyPairs_struc);    // Find the Value of the buy Basket for the week
   //
   DetectPositionValue(sellPairs_struc);  // Find the Value of the sell orders
   DetectPositionValue(buyPairs_struc);     // Find the Value of the buy orders
   //
   DrawDisplay(sellPairs_struc, buyPairs_struc, bsktCtrl_struc);
}//======== END MakeTheDashBoard ===============
//+------------------------------------------------------------------+
//| Basekt Values Functions                                          |
//+------------------------------------------------------------------+
void GetBasketValue(Pairs_Arrays& pair_struc)
{
   double array_total=0;
   int periodsInWk = (PeriodSeconds(PERIOD_W1)/PeriodSeconds(PERIOD_CURRENT));
   int atrPeriods = periodsInWk+1; // +1 just so there is always at least one
   int atrShift = periodsInWk*bsktCtrl_struc.weekNum;
   RefreshRates();
   for(int i=0; i<ArrayRange(pair_struc.pairs_ary,0); i++){
      double currentPrice;   // Just to see it before assignment in debug.
      currentPrice = iClose(pair_struc.pairs_ary[i],PERIOD_W1, bsktCtrl_struc.weekNum);
      pair_struc.pairVal_ary[i] = currentPrice;
      pair_struc.baseATR_ary[i] = iATR(pair_struc.pairs_ary[i],PERIOD_CURRENT,atrPeriods,atrShift)/MarketInfo(pair_struc.pairs_ary[i],MODE_POINT);
    }
}//=========== END DetectBasketValue =============
void DetectPositionValue(Pairs_Arrays& pair_struc)
{
   ArrayInitialize(pair_struc.posVal_ary,0);   // Start with zero and add to it
   ArrayInitialize(pair_struc.posLots_ary,0);   // Start with zero and add to it
   int aryIdx;
   for(int i=OrdersTotal()-1; i>=0; i--){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true) {
         if( (OrderType()==OP_BUY) || (OrderType()==OP_SELL) ) {  // leave out any limit orders
            aryIdx=FoundInStrArray(OrderSymbol(),pair_struc.pairs_ary);
            if(aryIdx>-1){ // Found in the array
               pair_struc.posVal_ary[aryIdx]   += OrderProfit();
               pair_struc.posLots_ary[aryIdx]  += OrderLots();
             }
          }
       }
    }
}//======= END DetectPositionValue ========
int FoundInStrArray(string matchString, string& ArrayToSearch[])
{
   int retValue=-1;
   for(int idx=0; idx<ArrayRange(ArrayToSearch,0); idx++){
      if(ArrayToSearch[idx]==matchString){
         retValue=idx;
         break;
       }
    }
   return retValue;
}//==== END FoundInStrArray ==========
//+------------------------------------------------------------------+
//| END Basekt Values Functions                                      |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Draw Display Functions - Set up each label object and draw it    |
//+------------------------------------------------------------------+
void DrawDisplay(const Pairs_Arrays& sell_struc, const Pairs_Arrays& buy_struc, Disp_bsktCtrl_struc& ctrlStruc)
{
   ctrlStruc.SetDefaults(ctrlStruc.xOriginPos,ctrlStruc.yOriginPos,11,clrNONE);  // Start Fresh
   
   // =======  First Line; Draw Title =========
   ctrlStruc.objName    = disp_obj_nms[TITLE_IDX];  // The Drag object, and the Title display for the indicator
   ctrlStruc.objDispStr = "Basket Viewer (wk "+IntegerToString(ctrlStruc.weekNum)+"): ";
   ctrlStruc.yPos       = ctrlStruc.yOriginPos+(ctrlStruc.lineNum*ctrlStruc.yOffset);
   ctrlStruc.xPos       = ctrlStruc.xOriginPos + ctrlStruc.xDragOffset;
   ctrlStruc.objClr     = TitleClr;
   ctrlStruc.selectable = true;  // Must be true so it can be dragged and dropped
   ManageALabel(ctrlStruc);
   ctrlStruc.selectable = false;  // Don't want any other objects to be selectable.
   //
   ctrlStruc.objName    = disp_obj_nms[STRTWK_IDX];  // Display the Start of the Week for the Weekly values - this object increments the week # when clicked.
   ctrlStruc.weekStart  = iTime(_Symbol,PERIOD_W1,ctrlStruc.weekNum);
   ctrlStruc.objDispStr = TimeToStr(ctrlStruc.weekStart,TIME_DATE)+"  - ";
   ctrlStruc.xPos       = ctrlStruc.xOriginPos+80;
   ctrlStruc.objClr     = TitleClr;
   ManageALabel(ctrlStruc);
   //
   ctrlStruc.objName    = disp_obj_nms[ENDWK_IDX];   // Display the End of the Week for the Weekly values - this object decrements the week # when clicked.
   ctrlStruc.weekEnd    = ctrlStruc.weekStart+(PERIOD_W1*60);
   ctrlStruc.objDispStr = TimeToStr(ctrlStruc.weekEnd,TIME_DATE);
   ctrlStruc.xPos       = ctrlStruc.xOriginPos;
   ctrlStruc.objClr     = TitleClr;
   ManageALabel(ctrlStruc);
   //
   // ======= 2nd Line, Make a Long Basket Header ============
   ctrlStruc.lineNum++;
   ctrlStruc.objName    = disp_obj_nms[LONG_HDR_IDX]; // Display Header for the Long Basket
   ctrlStruc.objDispStr = "BUY BASKET      Points      Bskt_ATR    Pos_Prft    Pos_Lots";
   ctrlStruc.yPos       = ctrlStruc.yOriginPos+(ctrlStruc.lineNum*ctrlStruc.yOffset);
   ctrlStruc.objClr     = HeadClr;
   ManageALabel(ctrlStruc);
   //
   // ========= 3rd Line sharts the Basket Display ======
   ctrlStruc.lineNum++;
   ctrlStruc.objClr     = SlotsBuyClr;
   DisplayValueAry(ctrlStruc, buy_struc);
   //
   //=======  1st Short Basket Display Line; Header
   ctrlStruc.lineNum++;
   ctrlStruc.objName    = disp_obj_nms[SHORT_HDR_IDX];  // Display Header for the Short Basket
   ctrlStruc.objDispStr = "SELL BASKET       Points    Bskt_ATR      Pos_Prft    Pos_Lots";
   ctrlStruc.yPos       = ctrlStruc.yOriginPos+(ctrlStruc.lineNum*ctrlStruc.yOffset);
   ctrlStruc.objClr     = HeadClr;
   ManageALabel(ctrlStruc);
   //
   //=======  2nd Short line starts the Short Basket dispaly ====
   ctrlStruc.lineNum++;
   DisplayValueAry(ctrlStruc, sell_struc);
   if(bsktCtrl_struc.markWeek==true){
      DrawRectangle(ctrlStruc, WK_MRK_IDX);
    }
   //
}//=== END DrawDisplay ========================
void DisplayValueAry(Disp_bsktCtrl_struc& ctrlStruc, const Pairs_Arrays& pairs_struc)  // Draw the Basket
{
   double bsktTtl=0, prftTtl=0, lotsTtl=0, atrTtl=0;  // Hold Basket Totals
   for(int i=0; i<ArrayRange(pairs_struc.pairs_ary,0); i++, ctrlStruc.lineNum++){ // Increment htrue the basket array, and increment the display line for each row.
      //=======  Display the Pair Strings, Column 1 ================
      ctrlStruc.yPos       = ctrlStruc.yOriginPos+(ctrlStruc.lineNum*ctrlStruc.yOffset);
      ctrlStruc.objName    = GetRowPairObjName( disp_obj_nms[BSLT_ROW_IDX], pairs_struc.pairs_ary[i], ctrlStruc.lineNum, pairs_struc.symb_op );
      ctrlStruc.objDispStr = pairs_struc.pairs_ary[i]; // + ": "+DoubleToStr(pairs_struc.baseVal_ary[i],_Digits)+":";
      if(pairs_struc.symb_op==SYMB_SELL){              // ctrlStruc.objClr = (pairs_struc.symb_op==SYMB_SELL)?SlotsSellClr:SlotsBuyClr;
         ctrlStruc.objClr = SlotsSellClr;
       }else ctrlStruc.objClr = SlotsBuyClr;           // pairs_struc.symb_op==SYMB_BUY
      ctrlStruc.xPos       = ctrlStruc.xOriginPos+ctrlStruc.col_1_offset;
      ManageALabel(ctrlStruc);
      //=======  Display the Pair Movement in Points from the Week Start, Column 2 ================
      ctrlStruc.objName    = disp_obj_nms[BSLT_ROW_IDX]+IntegerToString(ctrlStruc.lineNum)+GetOpDescription(pairs_struc.symb_op)+"PAIRVAL";
      double positionVal;
      if(pairs_struc.symb_op==SYMB_SELL){
         positionVal = ((pairs_struc.baseVal_ary[i]-pairs_struc.pairVal_ary[i])/MarketInfo(pairs_struc.pairs_ary[i],MODE_POINT))-MarketInfo(pairs_struc.pairs_ary[i],MODE_SPREAD); // MODE_SPREAD is in Points, and you will always pay the spread
       }else{ //pairs_struc.symb_op==SYMB_BUY
         positionVal = ((pairs_struc.pairVal_ary[i]-pairs_struc.baseVal_ary[i])/MarketInfo(pairs_struc.pairs_ary[i],MODE_POINT))+MarketInfo(pairs_struc.pairs_ary[i],MODE_SPREAD); // MODE_SPREAD is in Points, and you will always pay the spread
       }
      ctrlStruc.objDispStr = IntegerToString((int)positionVal);
      ctrlStruc.xPos       = ctrlStruc.xOriginPos+ctrlStruc.col_2_offset;
      if(positionVal>=0.0){  // ctrlStruc.objClr     = ((positionVal>=0.0)?ProfitClr:LossClr);
         ctrlStruc.objClr = ProfitClr;
       }else ctrlStruc.objClr = LossClr;
      ManageALabel(ctrlStruc);
      //=======  Display the Pair's ATR (how significant is the movement?), Column 3 ================
      ctrlStruc.objName    = disp_obj_nms[BSLT_ROW_IDX]+IntegerToString(ctrlStruc.lineNum)+GetOpDescription(pairs_struc.symb_op)+"PAIRATR";
      ctrlStruc.objDispStr = IntegerToString((int)pairs_struc.baseATR_ary[i]);
      ctrlStruc.xPos       = ctrlStruc.xOriginPos+ctrlStruc.col_3_offset;
      ctrlStruc.objClr     = TotalClr;
      ManageALabel(ctrlStruc);
      //=======  Display the Profit or loss associated with any trades for each symbol pair, Column 4 ================
      ctrlStruc.objName    = disp_obj_nms[BSLT_ROW_IDX]+IntegerToString(ctrlStruc.lineNum)+GetOpDescription(pairs_struc.symb_op)+"POSVAL";
      ctrlStruc.objDispStr = DoubleToString(pairs_struc.posVal_ary[i],2);
      ctrlStruc.xPos       = ctrlStruc.xOriginPos+ctrlStruc.col_4_offset;
      if(pairs_struc.posVal_ary[i]>=0.0){  // ctrlStruc.objClr     = ((pairs_struc.posVal_ary[i]>=0.0)?ProfitClr:LossClr);
         ctrlStruc.objClr = ProfitClr;
       }else ctrlStruc.objClr = LossClr;
      ManageALabel(ctrlStruc);
      //=======  Display the # of lots exposed in trades fore each symbol pair, Column 5 (last column, no offset) ================
      ctrlStruc.objName    = disp_obj_nms[BSLT_ROW_IDX]+IntegerToString(ctrlStruc.lineNum)+GetOpDescription(pairs_struc.symb_op)+"PLOTS";
      ctrlStruc.objDispStr = DoubleToString(pairs_struc.posLots_ary[i],2);
      ctrlStruc.xPos       = ctrlStruc.xOriginPos;
      ctrlStruc.objClr     = TotalClr;
      ManageALabel(ctrlStruc);
      //
      // Sum it up for display
      bsktTtl += positionVal;
      prftTtl += pairs_struc.posVal_ary[i];
      lotsTtl += pairs_struc.posLots_ary[i];
      atrTtl  += pairs_struc.baseATR_ary[i];
    }
   //===== Dispaly a Total Separation Line ===========
   ctrlStruc.yPos       = ctrlStruc.yOriginPos+(ctrlStruc.lineNum*ctrlStruc.yOffset);
   ctrlStruc.objName    = disp_obj_nms[SUM_LINE_IDX]+GetOpDescription(pairs_struc.symb_op);
   ctrlStruc.objDispStr = "=================================";
   ctrlStruc.objClr     = HeadClr;
   ManageALabel(ctrlStruc);
   //===== Dispaly the Column Totals, 4 values all on the next line ===========
   ctrlStruc.lineNum++;
   // Column 5, no offset
   ctrlStruc.objName    = disp_obj_nms[SUMS_IDX]+"LOT_SUM"+GetOpDescription(pairs_struc.symb_op);  // Column 5, the position exposure lots total.
   ctrlStruc.yPos       = ctrlStruc.yOriginPos+(ctrlStruc.lineNum*ctrlStruc.yOffset);
   ctrlStruc.objDispStr = DoubleToString(lotsTtl,2);
   ctrlStruc.xPos       = ctrlStruc.xOriginPos;
   ctrlStruc.objClr     = TotalClr;
   ManageALabel(ctrlStruc);
   // collumn 4
   ctrlStruc.objName    = disp_obj_nms[SUMS_IDX]+"PFT_SUM"+GetOpDescription(pairs_struc.symb_op);   // Column 4, the Basket Profit or loss.
   ctrlStruc.objDispStr = DoubleToString(prftTtl,2);
   ctrlStruc.xPos       = ctrlStruc.xOriginPos+ctrlStruc.col_4_offset;
   if(prftTtl>=0.0){  // ctrlStruc.objClr     = ((prftTtl>=0.0)?ProfitClr:LossClr);
      ctrlStruc.objClr = ProfitClr;
    }else ctrlStruc.objClr = LossClr;
   ManageALabel(ctrlStruc);
   // column 3
   ctrlStruc.objName    = disp_obj_nms[SUMS_IDX]+"ATR_SUM"+GetOpDescription(pairs_struc.symb_op);    // Column 3, the Basket's total ATR - Seems like a useless sum.
   ctrlStruc.objDispStr = IntegerToString( (int) atrTtl);
   ctrlStruc.xPos       = ctrlStruc.xOriginPos+ctrlStruc.col_3_offset;
   ctrlStruc.objClr     = TotalClr;
   ManageALabel(ctrlStruc);
   // Column 2
   ctrlStruc.objName    = disp_obj_nms[SUMS_IDX]+"BSKT_SUM"+GetOpDescription(pairs_struc.symb_op);     // Column 2, the Basket's total Points movement for the week
   ctrlStruc.objDispStr = IntegerToString( (int) bsktTtl);
   ctrlStruc.xPos       = ctrlStruc.xOriginPos+ctrlStruc.col_2_offset;
   if(bsktTtl>=0.0){
      ctrlStruc.objClr = ProfitClr;
    }else ctrlStruc.objClr = LossClr;
   ManageALabel(ctrlStruc);
   //
   // return the xPos and yPos to the original position before exiting.
   ctrlStruc.xPos       = ctrlStruc.xOriginPos;
   ctrlStruc.yPos       = ctrlStruc.yOriginPos;
}//====== END DisplayValueAry ===========
void ManageALabel(const Disp_bsktCtrl_struc& ctrlStruc)  // display a Label with paramaters in the structure
{
   static long chartID = ChartID();
   if ( ObjectFind(chartID,ctrlStruc.objName) < 0 ) // Create if it's not already there.
    {
      ObjectCreate    (chartID, ctrlStruc.objName, OBJ_LABEL, ctrlStruc.objWindow,  0, 0);
      ObjectSetInteger(chartID, ctrlStruc.objName, OBJPROP_FONTSIZE,  ctrlStruc.fontSize);
      ObjectSetString (chartID, ctrlStruc.objName, OBJPROP_FONT,      "Arial");
      ObjectSetInteger(chartID, ctrlStruc.objName, OBJPROP_CORNER,    ctrlStruc.objCorner);
      ObjectSetInteger(chartID, ctrlStruc.objName, OBJPROP_ANCHOR,    ctrlStruc.objAnchor);
      ObjectSetInteger(chartID, ctrlStruc.objName, OBJPROP_BACK,      true); 
      ObjectSetInteger(chartID, ctrlStruc.objName, OBJPROP_SELECTABLE,ctrlStruc.selectable); 
      ObjectSetInteger(chartID, ctrlStruc.objName, OBJPROP_SELECTED,  false); 
      ObjectSetInteger(chartID, ctrlStruc.objName, OBJPROP_HIDDEN,    false);
    }
   ObjectSetInteger(chartID, ctrlStruc.objName, OBJPROP_COLOR,     ctrlStruc.objClr);
   ObjectSetInteger(chartID, ctrlStruc.objName, OBJPROP_XDISTANCE, ctrlStruc.xPos );
   ObjectSetInteger(chartID, ctrlStruc.objName, OBJPROP_YDISTANCE, ctrlStruc.yPos );
   ObjectSetString (chartID, ctrlStruc.objName, OBJPROP_TEXT,      ctrlStruc.objDispStr );
} // ========= END ManageALabel ==========
void DrawRectangle(Disp_bsktCtrl_struc& ctrlStruc, DISP_OBJ_IDX objNameIdx)  // Set parameters for drawing the rectangle
{
   ctrlStruc.objName    = disp_obj_nms[objNameIdx];
   ctrlStruc.objClr     = C'154,101,129';
   ManageARectangle(ctrlStruc);
}
void ManageARectangle(const Disp_bsktCtrl_struc& ctrlStruc)   // display a rectangle with paramaters in the structure
{
   static long chartID = ChartID();
   double weekHigh = iHigh(_Symbol,PERIOD_W1,ctrlStruc.weekNum);
   double weekLow  = iLow(_Symbol,PERIOD_W1,ctrlStruc.weekNum);
   if ( ObjectFind(chartID,ctrlStruc.objName) < 0 )
    {
      ObjectCreate    (chartID, ctrlStruc.objName, OBJ_RECTANGLE, ctrlStruc.objWindow,  ctrlStruc.weekStart, weekHigh, ctrlStruc.weekEnd, weekLow);
      ObjectSetInteger(chartID, ctrlStruc.objName, OBJPROP_STYLE,     STYLE_SOLID);
      ObjectSetInteger(chartID, ctrlStruc.objName, OBJPROP_WIDTH,     1);
      ObjectSetInteger(chartID, ctrlStruc.objName, OBJPROP_FILL,      true);
      ObjectSetInteger(chartID, ctrlStruc.objName, OBJPROP_BACK,      true);
      ObjectSetInteger(chartID, ctrlStruc.objName, OBJPROP_COLOR,     ctrlStruc.objClr);
      ObjectSetInteger(chartID, ctrlStruc.objName, OBJPROP_SELECTABLE,ctrlStruc.selectable); 
      ObjectSetInteger(chartID, ctrlStruc.objName, OBJPROP_SELECTED,  false); 
      ObjectSetInteger(chartID, ctrlStruc.objName, OBJPROP_HIDDEN,    false);
    }
   ObjectMove(chartID, ctrlStruc.objName, 0, ctrlStruc.weekStart, weekHigh);
   ObjectMove(chartID, ctrlStruc.objName, 1, ctrlStruc.weekEnd,   weekLow);
} // ========= END ManageARectangle ==========
string GetRowPairObjName( const string& objNmPrefix, const string& pairName, const int& lineNum, const SYMBOL_OPERATION& symb_op )  // constructed to use in OnChartEvent to change chart symbol
{
   string theName = objNmPrefix+pairName+"PAIR"+IntegerToString(lineNum)+GetOpDescription(symb_op);
   return theName;
} // ========= END GetRowPairObjName ====================
//+------------------------------------------------------------------+
//| End Draw Display Functions                                       |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| START Initializtion (OnInit) functions                           |
//+------------------------------------------------------------------+
ENUM_INIT_RETCODE LoadPairsAry(Pairs_Arrays& pair_struc, const string& symbPairs, const ENUM_INIT_RETCODE& init_status)  // Insert User Control Values into the array
{
   ENUM_INIT_RETCODE result = init_status;
   result = LoadInputPairs(symbPairs, pair_struc, result); // Put extern 'Input String' into the short symbol array
   result = CheckMarketWatch(pair_struc, result);       // ensure the pairs are in the Market-Watch list
   return result;
}//========== END LoadPairsAry =================
ENUM_INIT_RETCODE LoadInputPairs(const string& sourceString, Pairs_Arrays& pair_struc, const ENUM_INIT_RETCODE& init_status) // Put delimited 'Input String' into the array
{
   ENUM_INIT_RETCODE result = init_status;
   const string delimitChar=",";  // Pairs are separated by comma
   string workString=sourceString;  // work with an independent string from user input
   // condition the workstring
   if(StringSubstr(workString,0,1)== delimitChar)   // Start with a pair, no leading delimiter character.
      workString += StringSubstr(workString,1,StringLen(workString)-1);
   if(StringSubstr(workString,StringLen(workString)-1,1)!= delimitChar)   // End with a delimiter character to assist with gettng the last pair out of the string.
      workString += delimitChar;
   //===== Increnment thru the strings deliminting characters and extract the pair identifiers between them.
   int startPos=0, foundPos, aryIdx=0, finalCharPos = StringLen(workString)-1;
   int aryRange = ArrayRange(pair_struc.pairs_ary,0);
   while (startPos < finalCharPos)
    {
      if(aryIdx>aryRange){ // Grew too large - could put an ArrayResizse here to grow the array.
         break;
       }
      foundPos=StringFind(workString,delimitChar,startPos);
      pair_struc.pairs_ary[aryIdx]=StringSubstr(workString,startPos,foundPos-startPos);  // Extract Pair string an place in array
      aryIdx++;
      startPos=foundPos+1;
    }
   return result;
}// ====== END LoadInputPairs ============
ENUM_INIT_RETCODE CheckMarketWatch(Pairs_Arrays& pair_struc, const ENUM_INIT_RETCODE& init_status )// ensure the pairs are in the Market-Watch list
{
   ENUM_INIT_RETCODE init_result = init_status;
   for(int i=0; i<ArrayRange(pair_struc.pairs_ary,0); i++)
    {
      bool symbolFound=false;
      for(int count=0; count<SymbolsTotal(true); count++)
       {
         int foundString = StringFind(SymbolName(count,true),pair_struc.pairs_ary[i],0);
         if( foundString>-1 ) // a matching string was found
          {
            pair_struc.pairs_ary[i]= SymbolName(count,true);  // Replace the input name with the market watch name (may have additional characters)
            symbolFound=true;
            break;
          }
       }
      if( (symbolFound==false) && (pair_struc.pairs_ary[i]!=NULL) )  // Symbol not found in MarketWatch - Give the user some feedback in the log
       {
         Print("Symbol: "+pair_struc.pairs_ary[i]+" was not found in MarketWatch.");
         pair_struc.pairs_ary[i]=NULL;
       }
    }
   init_result=CompressArray(pair_struc,init_result);  // Take out any Null entries
   return init_result;
}// =========== END CheckMarketWatch ===========
ENUM_INIT_RETCODE CompressArray(Pairs_Arrays& pair_struc, const ENUM_INIT_RETCODE& init_status )  // Take out any Null entries
{
   ENUM_INIT_RETCODE init_result = init_status;
   int i=0;
   for(int j=0; j<ArrayRange(pair_struc.pairs_ary,0); i++,j++)
    {
      while ( (StringLen(pair_struc.pairs_ary[j])<1) )
       {
         j++;
         if(j==ArrayRange(pair_struc.pairs_ary,0)) break;
       }
      if( j<ArrayRange(pair_struc.pairs_ary,0) )
       {
         pair_struc.pairs_ary[i]=pair_struc.pairs_ary[j];
       }
    }
   if(ArrayResize(pair_struc.pairs_ary,i-1)!=(i-1))
    {
      int errCode=GetLastError();
      Print(GetOpDescription(pair_struc.symb_op)+" Array Resize Failed, Error: "+ IntegerToString(errCode)+", "+ErrorDescription(errCode)+"; function: "+__FUNCTION__);
      init_result=INIT_FAILED;
    }
   return init_result;
}//============ END CompressArray ===========
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
//+------------------------------------------------------------------+
//| END Initializtion (OnInit) function                              |
//+------------------------------------------------------------------+
//