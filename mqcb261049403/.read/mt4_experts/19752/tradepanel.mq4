//+--------------------------------------------------------------------------+
//|           _____               _        ___                 _             |
//|          /__   \_ __ __ _  __| | ___  / _ \__ _ _ __   ___| |            |
//|            / /\/ '__/ _` |/ _` |/ _ \/ /_)/ _` | '_ \ / _ \ |            |
//|           / /  | | | (_| | (_| |  __/ ___/ (_| | | | |  __/ |            |
//|           \/   |_|  \__,_|\__,_|\___\/    \__,_|_| |_|\___|_|            |
//|                                                                          |
//| Open-source software (OSS)                                TradePanel.mq4 |
//| Provided free of charge                          Copyright © 2018, MhFx7 |
//| By MhFx7                             https://www.mql5.com/en/users/mhfx7 |
//+--------------------------------------------------------------------------+
#define Copyright    "Copyright © 2018, MhFx7"
#property copyright  Copyright
#property link       "https://www.mql5.com/en/users/mhfx7"
#define ExpertName   "TradePanel"
#define Version      "1.10"
#property version    Version
#property strict
//--
#define KEY_LEFT           37 
#define KEY_RIGHT          39 
#define KEY_UP             38 
#define KEY_DOWN           40 
//--
#define INDENT_TOP         15
#define INDENT_BOTTOM      30
//--
#define CLIENT_BG_X        5
#define CLIENT_BG_Y        20
//--
#define CLIENT_BG_WIDTH    245
#define CLIENT_BG_HEIGHT   150
//--
#define BUTTON_WIDTH       75
#define BUTTON_HEIGHT      20
//--
#define BUTTON_GAP_X       5
#define BUTTON_GAP_Y       5
//--
#define EDIT_WIDTH         75
#define EDIT_HEIGHT        18
//--
#define EDIT_GAP_X         15
#define EDIT_GAP_Y         15
//--
#define SPEEDTEXT_GAP_X    240
#define SPEEDTEXT_GAP_Y    28
//--
#define SPEEDBAR_GAP_X     210
#define SPEEDBAR_GAP_Y     28
//--
#define LIGHT              0
#define DARK               1
//--
#define CLOSEALL           0
#define CLOSELAST          1
#define CLOSEPROFIT        2
#define CLOSELOSS          3
#define CLOSEPARTIAL       4
//--
#define OPENPRICE          0
#define CLOSEPRICE         1
//--
#define OP_ALL             -1
//--
#define OBJPREFIX          "TP - "
//--
bool TimerIsEnabled        = false;
int TimerInterval          = 250;
//--
int MagicNumber            = 0;
int Slippage               = 3;
double LotSize             = 0;
double LotStep             = 0;
double MinLot              = 0;
double MaxLot              = 0;
double MinStop             = 0;
double StopLoss            = 0;
double TakeProfit          = 0;
//--
double LotSizeInp          = 0;
double StopLossInp         = 0;
double TakeProfitInp       = 0;
string SymbolInp           = "";
//--
int SelectedTheme          = 0;
int CloseMode              = 0;
bool IsPainting            = false;
bool SoundIsEnabled        = false;
bool PlayTicks             = false;
//--
int mouse_x                = 0;
int mouse_y                = 0;
int mouse_w                = 0;
datetime mouse_dt          = 0;
double mouse_pr            = 0;
//--
int draw                   = 0;
int BrushClrIndex          = 0;
int BrushIndex             = 0;
//--
int MaxSpeedBars           = 10;
double AvgPrice            = 0;
double UpTicks             = 0;
double DwnTicks            = 0;
int LastReason             = 0;
//--
color COLOR_BG             = clrNONE;
color COLOR_FONT           = clrNONE;
color COLOR_FONT2          = clrNONE;
color COLOR_MOVE           = clrNONE;
color COLOR_GREEN          = clrNONE;
color COLOR_RED            = clrNONE;
color COLOR_HEDGE          = clrNONE;
color COLOR_BID_REC        = clrNONE;
color COLOR_ASK_REC        = clrNONE;
color COLOR_ARROW          = clrNONE;
//--
color COLOR_SELL           = C'225,68,29';
color COLOR_BUY            = C'3,95,172';
color COLOR_CLOSE          = clrGoldenrod;
//--
int ErrorInterval          = 250;
string ErrorSound          = "error.wav";
//--
string MB_CAPTION=ExpertName+" v"+Version+" | "+Copyright;
//--
string CloseArr[]={"CLOSE ALL","CLOSE LAST","CLOSE PROFIT","CLOSE LOSS","CLOSE PARTIAL"};
//--
string BrushArr[]={"l","«","¨","t","­","Ë","°"};
color BrushClrArr[]={clrRed,clrGold,clrMagenta,clrBrown,clrDodgerBlue,clrGreen,clrOrange,clrWhite,clrBlack};
//--
int x1=0, x2=CLIENT_BG_WIDTH;
int y1=0, y2=CLIENT_BG_HEIGHT;
//--
int button_y=0;
int inputs_y=0;
int label_y=0;
//--
int fr_x=0;
//--
input bool ShowOrdHistory=true;//ShowOrderHistory
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- CreateTimer
   if(!IsTesting())
      TimerIsEnabled=EventSetMillisecondTimer(TimerInterval);

//-- EnableEventMouseMove 
   if(!IsTesting())
      if(!ChartGetInteger(0,CHART_EVENT_MOUSE_MOVE))
         ChartEventMouseMoveSet(true);

//-- CheckConnection
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
     {
      MessageBox("Warning: No Internet connection found!\nPlease check your network connection.",
                 MB_CAPTION+" | "+"#"+IntegerToString(ERR_NO_CONNECTION),MB_OK|MB_ICONWARNING);
     }

//-- CheckTradingIsAllowed
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))//Terminal
     {
      MessageBox("Warning: Check if automated trading is allowed in the terminal settings!",
                 MB_CAPTION+" | "+"#"+IntegerToString(ERR_TRADE_NOT_ALLOWED),MB_OK|MB_ICONWARNING);
     }
   else
     {
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))//CheckBox
        {
         MessageBox("Warning: Automated trading is forbidden in the program settings for "+__FILE__,
                    MB_CAPTION+" | "+"#"+IntegerToString(ERR_TRADE_NOT_ALLOWED),MB_OK|MB_ICONWARNING);
        }
     }
//--
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))//Server
     {
      MessageBox("Warning: Automated trading is forbidden for the account "+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+" at the trade server side.",
                 MB_CAPTION+" | "+"#"+IntegerToString(ERR_TRADE_EXPERT_DISABLED_BY_SERVER),MB_OK|MB_ICONWARNING);
     }
//--
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))//Investor
     {
      MessageBox("Warning: Trading is forbidden for the account "+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+"."+
                 "\n\nPerhaps an investor password has been used to connect to the trading account."+
                 "\n\nCheck the terminal journal for the following entry:"+
                 "\n\'"+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+"\': trading has been disabled - investor mode.",
                 MB_CAPTION+" | "+"#"+IntegerToString(ERR_TRADE_DISABLED),MB_OK|MB_ICONWARNING);
     }
//--
   if(!SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE))//Symbol
     {
      MessageBox("Warning: Trading is disabled for the symbol "+_Symbol+" at the trade server side.",
                 MB_CAPTION+" | "+"#"+IntegerToString(ERR_TRADE_DISABLED),MB_OK|MB_ICONWARNING);
     }

//-- StrategyTester
   if(MQLInfoInteger(MQL_TESTER))
      Print("Some functions are not available in the strategy tester.");

//-- CheckSoundIsEnabled
   if(!GlobalVariableCheck(ExpertName+" - Sound"))
      SoundIsEnabled=true;
   else
      SoundIsEnabled=GlobalVariableGet(ExpertName+" - Sound");

//-- CheckColors
   SelectedTheme=(int)GlobalVariableGet(ExpertName+" - Theme");
   if(SelectedTheme==LIGHT)
      SetColors(LIGHT);
   else
      SetColors(DARK);

//-- GetStoredInputs
   LotSizeInp=GlobalVariableGet(ExpertName+" - LotSize");
   StopLossInp=GlobalVariableGet(ExpertName+" - StopLoss");
   TakeProfitInp=GlobalVariableGet(ExpertName+" - TakeProfit");

//-- GetClosingMode
   if(!IsTesting())
      CloseMode=(int)GlobalVariableGet(ExpertName+" - Close");

//-- GetAvgPrice
   if(IsConnected())
      AvgPrice=(MarketInfo(_Symbol,MODE_ASK)+MarketInfo(_Symbol,MODE_BID))/2;

//-- SetXYAxis
   GetSetCoordinates();

//-- CreateObjects
   ObjectsCreateAll();

//-- ChartChanged
   if(LastReason==REASON_CHARTCHANGE)
      _PlaySound("switch.wav");

//--- Succeeded
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- DestroyTimer
   EventKillTimer();
   TimerIsEnabled=false;

//-- DisableEventMouseMove
   if(!IsTesting())
      if(ChartGetInteger(0,CHART_EVENT_MOUSE_MOVE))
         ChartEventMouseMoveSet(false);

//-- SaveStoredValues
   if(reason!=REASON_INITFAILED)
     {
      //-- SaveXYAxis
      GlobalVariableSet(ExpertName+" - X",x1);
      GlobalVariableSet(ExpertName+" - Y",y1);
      //-- SaveUserInputs
      GlobalVariableSet(ExpertName+" - LotSize",LotSize);
      GlobalVariableSet(ExpertName+" - StopLoss",StopLoss);
      GlobalVariableSet(ExpertName+" - TakeProfit",TakeProfit);
      //-- Strategy Tester
      if(!IsTesting())
        {
         GlobalVariableSet(ExpertName+" - Theme",SelectedTheme);
         GlobalVariableSet(ExpertName+" - Sound",SoundIsEnabled);
         GlobalVariableSet(ExpertName+" - Close",CloseMode);
        }
      //--
      GlobalVariablesFlush();
     }

//-- ResetStoredTicks
   if(reason==REASON_CHARTCHANGE)
     {
      UpTicks=0;
      DwnTicks=0;
     }

//-- DeleteObjects
   if(reason<=REASON_REMOVE || reason==REASON_INITFAILED)
     {
      for(int i=0; i<ObjectsTotal(); i++)
        {
         //-- GetObjectName
         string obj_name=ObjectName(i);
         //-- PrefixObjectFound
         if(StringSubstr(obj_name,0,StringLen(OBJPREFIX))==OBJPREFIX)
           {
            //-- DeleteObjects
            if(ObjectsDeleteAll(0,OBJPREFIX,-1,-1)>0)
               break;
           }
        }
     }

//-- StoreDeinitReason
   LastReason=reason;
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- CreateTimer
   if(!TimerIsEnabled && !IsTesting())
      TimerIsEnabled=EventSetMillisecondTimer(TimerInterval);

//-- DisplaySpeedInfo
   Speedometer();

//-- StrategyTester
   if(IsTesting())
      _OnTester();
//---
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- CheckObjects
   ObjectsCheckAll();

//-- GetSetUserInputs
   GetSetInputs();

//-- DisplaySymbolInfo
   SymbolInfo();

//-- DisplayAccount&TradeInfo
   AccAndTradeInfo();
//---
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

   if(id==CHARTEVENT_OBJECT_CLICK)
     {

      //-- DisplayLastKnownPing
      if(sparam==OBJPREFIX+"CONNECTION")
        {
         //-- SetTransparentColor
         int sRed=88,sGreen=88,sBlue=88,sRGB=0;
         sRGB=(sBlue<<16);sRGB|=(sGreen<<8);sRGB|=sRed;
         //--
         double Ping=TerminalInfoInteger(TERMINAL_PING_LAST);//SetPingToMs
         string text=TerminalInfoInteger(TERMINAL_CONNECTED)?DoubleToString(Ping/1000,2)+" ms":"NC";/*SetText*/
         //--
         LabelCreate(0,OBJPREFIX+"PING",0,ChartMiddleX(),ChartMiddleY(),CORNER_LEFT_UPPER,text,"Tahoma",200,sRGB,0,ANCHOR_CENTER,true,false,true,0,"\n");
         //--
         Sleep(1000);
         ObjectDelete(0,OBJPREFIX+"PING");//DeleteObject
        }

      //-- SwitchTheme
      if(sparam==OBJPREFIX+"THEME")
        {
         if(SelectedTheme==LIGHT)
            SetTheme(DARK);
         else
            SetTheme(LIGHT);
        }

      //-- StartPainting
      if(sparam==OBJPREFIX+"PAINT")
        {
         if(!IsPainting)
           {
            //-- EnablePainting
            IsPainting=true;
            //-- BlockMouseScroll
            ChartMouseScrollSet(false);
            //-- DisplayInfo
            LabelCreate(0,OBJPREFIX+"ERASE",0,5,15,CORNER_LEFT_LOWER,"Press down to erase","Arial",9,COLOR_RED,0,ANCHOR_LEFT,false,false,true,0,"\n");
            LabelCreate(0,OBJPREFIX+"BRUSHCOLOR",0,ChartMiddleX(),15,CORNER_LEFT_LOWER,"Press up to change color / Press left to change brush","Arial",9,BrushClrArr[BrushClrIndex],0,ANCHOR_CENTER,false,false,true,0,"\n");
            LabelCreate(0,OBJPREFIX+"BRUSHTYPE",0,ChartMiddleX()+155,15,CORNER_LEFT_LOWER,BrushArr[BrushIndex],"Wingdings",9,BrushClrArr[BrushClrIndex],0,ANCHOR_CENTER,false,false,true,0,"\n");
            LabelCreate(0,OBJPREFIX+"STOPPAINT",0,5,15,CORNER_RIGHT_LOWER,"Press right to stop drawing","Arial",9,COLOR_GREEN,0,ANCHOR_RIGHT,false,false,true,0,"\n");
           }
        }

      //-- SoundManagement
      if(sparam==OBJPREFIX+"SOUND" || sparam==OBJPREFIX+"SOUNDIO")
        {
         //-- EnableSound
         if(!SoundIsEnabled)
           {
            SoundIsEnabled=true;
            ObjectSetInteger(0,OBJPREFIX+"SOUNDIO",OBJPROP_COLOR,C'59,41,40');//SetObject
            PlaySound("sound.wav");
           }
         //-- DisableSound
         else
           {
            SoundIsEnabled=false;
            ObjectSetInteger(0,OBJPREFIX+"SOUNDIO",OBJPROP_COLOR,clrNONE);//SetObject
           }
        }

      //-- TickSoundsManagement
      if(sparam==OBJPREFIX+"PLAY")
        {
         //-- EnableTickSounds
         if(!PlayTicks)
           {
            PlayTicks=true;
            //-- SetObjects
            ObjectSetString(0,OBJPREFIX+"PLAY",OBJPROP_TEXT,";");
            ObjectSetInteger(0,OBJPREFIX+"PLAY",OBJPROP_FONTSIZE,14);
           }
         //-- DisableTickSounds
         else
           {
            PlayTicks=false;
            //-- SetObjects
            ObjectSetString(0,OBJPREFIX+"PLAY",OBJPROP_TEXT,"4");
            ObjectSetInteger(0,OBJPREFIX+"PLAY",OBJPROP_FONTSIZE,15);
           }
        }

      //-- SetBull/BearColors
      if(sparam==OBJPREFIX+"CANDLES¦")
        {
         color clrBullish = RandomColor();
         color clrBearish = RandomColor();
         //-- SetChart
         ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,clrBullish);
         ChartSetInteger(0,CHART_COLOR_CHART_UP,clrBullish);
         ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,clrBearish);
         ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrBearish);
         ChartSetInteger(0,CHART_COLOR_CHART_LINE,RandomColor());
        }

      //-- RemoveExpert
      if(sparam==OBJPREFIX+"EXIT")
        {
         if(MessageBox("Do you really want to remove the EA?",MB_CAPTION,MB_ICONQUESTION|MB_YESNO)==IDYES)
            ExpertRemove();//Exit
        }

      //-- SetClosingMode
      if(sparam==OBJPREFIX+"CLOSE¹²³")
        {
         CloseMode++;
         if(CloseMode>=ArraySize(CloseArr))//Reset
            CloseMode=0;
         ObjectSetString(0,OBJPREFIX+"CLOSE¹²³",OBJPROP_TEXT,0,CloseArr[CloseMode]);//SetObject
         _PlaySound("switch.wav");
        }

      //-- DecLotSize
      if(sparam==OBJPREFIX+"LOTSIZE<")
         ObjectSetString(0,OBJPREFIX+"LOTSIZE<>",OBJPROP_TEXT,0,DoubleToString(LotSize-=LotStep,2));//SetObject

      //-- IncLotSize
      if(sparam==OBJPREFIX+"LOTSIZE>")
         ObjectSetString(0,OBJPREFIX+"LOTSIZE<>",OBJPROP_TEXT,0,DoubleToString(LotSize+=LotStep,2));//SetObject

      //-- SellClick
      if(sparam==OBJPREFIX+"SELL")
        {
         //-- SendSellOrder
         OrderSend(OP_SELL);
         //-- ResetButton
         Sleep(100);
         ObjectSetInteger(0,OBJPREFIX+"SELL",OBJPROP_STATE,false);//SetObject
        }

      //-- CloseClick
      if(sparam==OBJPREFIX+"CLOSE")
        {
         //-- CloseOrder(s)
         OrderClose();
         //-- ResetButton
         Sleep(100);
         ObjectSetInteger(0,OBJPREFIX+"CLOSE",OBJPROP_STATE,false);//SetObject
        }

      //-- BuyClick
      if(sparam==OBJPREFIX+"BUY")
        {
         //-- SendBuyOrder
         OrderSend(OP_BUY);
         //-- ResetButton
         Sleep(100);
         ObjectSetInteger(0,OBJPREFIX+"BUY",OBJPROP_STATE,false);//SetObject
        }

      //-- ResetCoordinates
      if(sparam==OBJPREFIX+"RESET")
        {
         LabelMove(0,OBJPREFIX+"BCKGRND[]",CLIENT_BG_X,CLIENT_BG_Y);
         ObjectSetInteger(0,OBJPREFIX+"RESET",OBJPROP_STATE,false);//SetObject
         if(ObjectGetInteger(0,OBJPREFIX+"MOVE",OBJPROP_STATE))
            ObjectSetInteger(0,OBJPREFIX+"MOVE",OBJPROP_STATE,false);/*SetObject*/
         //-- MoveObjects
         GetSetCoordinates();
         ObjectsMoveAll();
        }

      //--
     }
//--
   if(id==CHARTEVENT_KEYDOWN)
     {

      //-- BrushType
      if(lparam==KEY_LEFT)
        {
         if(IsPainting)
           {
            BrushIndex++;
            if(BrushIndex>=ArraySize(BrushArr))//Reset
               BrushIndex=0;
            ObjectSetString(0,OBJPREFIX+"BRUSHTYPE",OBJPROP_TEXT,0,BrushArr[BrushIndex]);//SetObject
           }
        }

      //-- StopPainting
      if(lparam==KEY_RIGHT)
        {
         if(IsPainting)
           {
            //-- DisablePainting
            IsPainting=false;
            //-- DeleteObjects
            if(ObjectFind(0,OBJPREFIX+"ERASE")==0)
               ObjectDelete(0,OBJPREFIX+"ERASE");
            if(ObjectFind(0,OBJPREFIX+"BRUSHCOLOR")==0)
               ObjectDelete(0,OBJPREFIX+"BRUSHCOLOR");
            if(ObjectFind(0,OBJPREFIX+"BRUSHTYPE")==0)
               ObjectDelete(0,OBJPREFIX+"BRUSHTYPE");
            if(ObjectFind(0,OBJPREFIX+"STOPPAINT")==0)
               ObjectDelete(0,OBJPREFIX+"STOPPAINT");
            //-- UnblockMouseScroll
            ChartMouseScrollSet(true);
           }
        }

      //-- BrushColor
      if(lparam==KEY_UP)
        {
         if(IsPainting)
           {
            BrushClrIndex++;
            if(BrushClrIndex>=ArraySize(BrushClrArr))//Reset
               BrushClrIndex=0;
            //-- SetObjects
            ObjectSetInteger(0,OBJPREFIX+"BRUSHCOLOR",OBJPROP_COLOR,0,BrushClrArr[BrushClrIndex]);
            ObjectSetInteger(0,OBJPREFIX+"BRUSHTYPE",OBJPROP_COLOR,0,BrushClrArr[BrushClrIndex]);
           }
        }

      //-- DeleteDraws
      if(lparam==KEY_DOWN)
        {
         if(IsPainting)
           {
            if(ObjectsDeleteAll(0,"draw",0,OBJ_TEXT)>0)
               draw=0;
           }
        }

      //--  
     }
//---
   if(id==CHARTEVENT_MOUSE_MOVE)
     {

      //-- UserIsHolding (Left-Click)
      if(sparam=="1")
        {

         //-- MoveClient
         if(ObjectGetInteger(0,OBJPREFIX+"BCKGRND[]",OBJPROP_SELECTED) || ObjectFind(0,OBJPREFIX+"BCKGRND[]")!=0)
           {
            //-- MoveObjects
            GetSetCoordinates();
            ObjectsMoveAll();
           }

         //-- Paint
         if(IsPainting)
           {
            //-- GetMousePosition
            mouse_x=(int)lparam;
            mouse_y=(int)dparam;
            //-- ConvertXYToDatePrice
            ChartXYToTimePrice(0,mouse_x,mouse_y,mouse_w,mouse_dt,mouse_pr);
            //-- CreateObjects
            TextCreate(0,"draw"+IntegerToString(draw),0,mouse_dt,mouse_pr,BrushArr[BrushIndex],"Wingdings",10,BrushClrArr[BrushClrIndex],0,ANCHOR_CENTER,false,false,true,0,"\n");
            draw++;
           }

         //--
        }

      //--
     }
//---
  }
//+------------------------------------------------------------------+
//| OnTester                                                         |
//+------------------------------------------------------------------+
void _OnTester()
  {
//--- CheckObjects
   ObjectsCheckAll();

//-- GetSetUserInputs
   GetSetInputs();

//-- DisplaySymbolInfo
   SymbolInfo();

//-- DisplayAccount&TradeInfo
   AccAndTradeInfo();

//-- SellClick
   if(ObjectFind(0,OBJPREFIX+"SELL")==0)//ObjectIsPresent
     {
      if(ObjectGetInteger(0,OBJPREFIX+"SELL",OBJPROP_STATE))
        {
         //-- SendSellOrder
         OrderSend(OP_SELL);
         ObjectSetInteger(0,OBJPREFIX+"SELL",OBJPROP_STATE,false);//ResetButton
        }
     }

//-- CloseClick
   if(ObjectFind(0,OBJPREFIX+"CLOSE")==0)//ObjectIsPresent
     {
      if(ObjectGetInteger(0,OBJPREFIX+"CLOSE",OBJPROP_STATE))
        {
         //-- CloseOrder(s)
         OrderClose();
         ObjectSetInteger(0,OBJPREFIX+"CLOSE",OBJPROP_STATE,false);//ResetButton
        }
     }

//-- BuyClick
   if(ObjectFind(0,OBJPREFIX+"BUY")==0)//ObjectIsPresent
     {
      if(ObjectGetInteger(0,OBJPREFIX+"BUY",OBJPROP_STATE))
        {
         //-- SendBuyOrder
         OrderSend(OP_BUY);
         ObjectSetInteger(0,OBJPREFIX+"BUY",OBJPROP_STATE,false);//ResetButton
        }
     }

//-- MoveClient
   if(ObjectFind(0,OBJPREFIX+"BCKGRND[]")==0)//ObjectIsPresent
     {
      //-- GetCurrentPos
      int bg_x=(int)ObjectGetInteger(0,OBJPREFIX+"BCKGRND[]",OBJPROP_XDISTANCE);
      int bg_y=(int)ObjectGetInteger(0,OBJPREFIX+"BCKGRND[]",OBJPROP_YDISTANCE);
      //-- MoveObjects
      if(bg_x!=x1 || bg_y!=y1)
        {
         GetSetCoordinates();
         ObjectsMoveAll();
        }
     }

//-- ResetPosition
   if(ObjectFind(0,OBJPREFIX+"RESET")==0)//ObjectIsPresent
     {
      if(ObjectGetInteger(0,OBJPREFIX+"RESET",OBJPROP_STATE))
        {
         //-- MoveObject
         LabelMove(0,OBJPREFIX+"BCKGRND[]",CLIENT_BG_X,CLIENT_BG_Y);
         ObjectSetInteger(0,OBJPREFIX+"RESET",OBJPROP_STATE,false);//SetObject
         if(ObjectGetInteger(0,OBJPREFIX+"MOVE",OBJPROP_STATE))
            ObjectSetInteger(0,OBJPREFIX+"MOVE",OBJPROP_STATE,false);//SetObject
        }
     }

//---
  }
//+------------------------------------------------------------------+
//| OrderSend                                                        |
//+------------------------------------------------------------------+
void OrderSend(const int Type)
  {
//--
   int op_tkt=0;
   uint tick=0;
   uint ex_time=0;
//--
   double rq_price=0;
   double slippage=0;
//--- reset the error value
   ResetLastError();
//-- CheckOrdSendRequirements
   if(IsTradeAllowed() && !IsTradeContextBusy() && IsConnected())
     {
      //-- SellOrders
      if(Type==OP_SELL)
        {
         //-- EnoughMargin
         if(AccountFreeMarginCheck(_Symbol,OP_SELL,LotSize)>=0)
           {
            //-- CorrectLotSize (Rounded by GetSetInputs)
            if(LotSize>=MinLot && LotSize<=MaxLot)
              {
               tick=GetTickCount();//GetTime
               rq_price=MarketInfo(_Symbol,MODE_BID);//GetPrice
               op_tkt=OrderSend(_Symbol,OP_SELL,LotSize,rq_price,Slippage,0,0,ExpertName,0,0,COLOR_SELL);//SendOrder
              }
            else
              {
               //-- Error
               Print("OrderSend failed with error #131 [Invalid trade volume]");
               _PlaySound(ErrorSound);
               //--
               Sleep(ErrorInterval);
               return;
              }
            //--
            if(op_tkt<0)
              {
               //-- Error
               Print("OrderSend failed with error #",_LastError);
               _PlaySound(ErrorSound);
               //--
               Sleep(ErrorInterval);
               return;
              }
            else
              {
               //-- Succeeded
               ex_time=GetTickCount()-tick;//CalcExeTime
               slippage=(PriceByTkt(OPENPRICE,op_tkt)-rq_price)/_Point;//CalcSlippage
               Print("OrderSend placed successfully (Open Sell) "+"#"+IntegerToString(op_tkt)+" | Execuction Time: "+IntegerToString(ex_time)+"ms"+" | Slippage: "+DoubleToString(slippage,0)+"p");
               _PlaySound("sell.wav");
               //-- SL
               if(StopLoss>0 && StopLoss>=MinStop)
                 {
                  if(OrderSelect(op_tkt,SELECT_BY_TICKET,MODE_TRADES))
                    {
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+StopLoss*_Point,OrderTakeProfit(),0,COLOR_SELL))
                       {
                        //-- Error
                        Print("Error in OrderModify. Error code=",_LastError);
                        _PlaySound(ErrorSound);
                        Sleep(ErrorInterval);
                       }
                     else
                       {
                        //-- Succeeded
                        //Print("Order modified successfully");
                       }
                    }
                 }
               //-- TP
               if(TakeProfit>0 && TakeProfit>=MinStop)
                 {
                  if(OrderSelect(op_tkt,SELECT_BY_TICKET,MODE_TRADES))
                    {
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderOpenPrice()-TakeProfit*_Point,0,COLOR_BUY))
                       {
                        //-- Error
                        Print("Error in OrderModify. Error code=",_LastError);
                        _PlaySound(ErrorSound);
                        Sleep(ErrorInterval);
                       }
                     else
                       {
                        //-- Succeeded
                        //Print("Order modified successfully");*/
                       }
                    }
                 }
              }
            //--
           }
         else
           {
            //-- NotEnoughMoney
            Print(" '",AccountNumber(),"' :"," order #0 sell ",DoubleToString(LotSize,2)," ",_Symbol," [Not enough money]");
            _PlaySound(ErrorSound);
           }
         //--
        }
      //-- BuyOrders
      if(Type==OP_BUY)
        {
         //-- EnoughMargin
         if(AccountFreeMarginCheck(_Symbol,OP_BUY,LotSize)>=0)
           {
            //-- CorrectLotSize (Rounded by GetSetInputs)
            if(LotSize>=MinLot && LotSize<=MaxLot)
              {
               tick=GetTickCount();//GetTime
               rq_price=MarketInfo(_Symbol,MODE_ASK);//GetPrice
               op_tkt=OrderSend(_Symbol,OP_BUY,LotSize,rq_price,Slippage,0,0,ExpertName,0,0,COLOR_BUY);//SendOrder
              }
            else
              {
               //-- Error
               Print("OrderSend failed with error #131 [Invalid trade volume]");
               _PlaySound(ErrorSound);
               //--
               Sleep(ErrorInterval);
               return;
              }
            //--
            if(op_tkt<0)
              {
               //-- Error
               Print("OrderSend failed with error #",_LastError);
               _PlaySound(ErrorSound);
               //--
               Sleep(ErrorInterval);
               return;
              }
            else
              {
               //-- Succeeded
               ex_time=GetTickCount()-tick;//CalcExeTime
               slippage=(rq_price-PriceByTkt(OPENPRICE,op_tkt))/_Point;//CalcSlippage
               Print("OrderSend placed successfully (Open Buy) "+"#"+IntegerToString(op_tkt)+" | Execuction Time: "+IntegerToString(ex_time)+"ms"+" | Slippage: "+DoubleToString(slippage,0)+"p");
               _PlaySound("buy.wav");
               //-- SL
               if(StopLoss>0 && StopLoss>=MinStop)
                 {
                  if(OrderSelect(op_tkt,SELECT_BY_TICKET,MODE_TRADES))
                    {
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-StopLoss*_Point,OrderTakeProfit(),0,COLOR_SELL))
                       {
                        //-- Error
                        Print("Error in OrderModify. Error code=",_LastError);
                        _PlaySound(ErrorSound);
                        Sleep(ErrorInterval);
                       }
                     else
                       {
                        //-- Succeeded
                        //Print("Order modified successfully");
                       }
                    }
                 }
               //-- TP
               if(TakeProfit>0 && TakeProfit>=MinStop)
                 {
                  if(OrderSelect(op_tkt,SELECT_BY_TICKET,MODE_TRADES))
                    {
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderOpenPrice()+TakeProfit*_Point,0,COLOR_BUY))
                       {
                        //-- Error
                        Print("Error in OrderModify. Error code=",_LastError);
                        _PlaySound(ErrorSound);
                        Sleep(ErrorInterval);
                       }
                     else
                       {
                        //-- Succeeded
                        //Print("Order modified successfully");
                       }
                    }
                 }
              }
            //--
           }
         else
           {
            //-- NotEnoughMoney
            Print(" '",AccountNumber(),"' :"," order #0 buy ",DoubleToString(LotSize,2)," ",_Symbol," [Not enough money]");
            _PlaySound(ErrorSound);
           }
         //--
        }
     }
   else
     {
      //-- RequirementsNotFulfilled
      if(!IsConnected())
         Print("No Internet connection found! Please check your network connection and try again.");
      if(IsTradeContextBusy())
         Print("Trade context is busy, Please wait...");
      if(!IsTradeAllowed())
         Print("Check if automated trading is allowed in the terminal / program settings and try again.");
      //--
      _PlaySound(ErrorSound);
      //--
      Sleep(ErrorInterval);
      return;
      //--
     }
//--
  }
//+------------------------------------------------------------------+
//| OrderClose                                                       |
//+------------------------------------------------------------------+
void OrderClose()
  {
//--
   double ordprofit=0;
   double ordlots=0;
//--
   int c_tkt=0;
   int ordtype=0;
   uint tick=0;
   uint ex_time=0;
//--
   double rq_price=0;
   double slippage=0;
//--
   string ordtypestr="";
//--- reset the error value
   ResetLastError();
//-- CheckOrdCloseRequirements
   if(IsTradeAllowed() && !IsTradeContextBusy() && IsConnected())
     {
      //-- SelectOrder
      for(int i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol()==_Symbol && OrderMagicNumber()==MagicNumber)
              {
               if(OrderType()<=OP_SELL)//MarketOrdersOnly
                 {
                  //--
                  ordprofit=OrderProfit()+OrderCommission()+OrderSwap();//GetPtofit
                  ordlots=(CloseMode==CLOSEPARTIAL)?ordlots=LotSizeInp:OrderLots();//SetLots
                  if(ordlots>OrderLots())
                     ordlots=OrderLots();
                  //--
                  if((CloseMode==CLOSEALL) || (CloseMode==CLOSELAST) || (CloseMode==CLOSEPROFIT && ordprofit>0) || (CloseMode==CLOSELOSS && ordprofit<0) || (CloseMode==CLOSEPARTIAL))
                    {
                     tick=GetTickCount();
                     rq_price=OrderClosePrice();
                     c_tkt=OrderTicket();
                     ordtype=OrderType();
                     ordtypestr=(OrderType()==OP_SELL)?ordtypestr="Sell":ordtypestr="Buy";
                     //--
                     if(!OrderClose(OrderTicket(),ordlots,rq_price,0,COLOR_CLOSE))
                       {
                        //-- Error
                        Print("OrderClose failed with error #",_LastError);
                        Sleep(ErrorInterval);
                        return;
                       }
                     else
                       {
                        //-- Succeeded
                        ex_time=GetTickCount()-tick;//CalcExeTime
                        slippage=(ordtype==OP_SELL)?(PriceByTkt(CLOSEPRICE,c_tkt)-rq_price)/_Point:(rq_price-PriceByTkt(CLOSEPRICE,c_tkt))/_Point;//CalcSlippage
                        Print("Order closed successfully"+" (Close "+ordtypestr+") "+"#"+IntegerToString(c_tkt)+" | Execuction Time: "+IntegerToString(ex_time)+"ms"+" | "+"Slippage: "+DoubleToString(slippage,0)+"p");
                        _PlaySound("close.wav");
                        //--
                        if(CloseMode==CLOSELAST || CloseMode==CLOSEPARTIAL)
                           break;
                       }
                    }
                  //--
                 }
              }
           }
        }
      //--
     }
   else
     {
      //-- RequirementsNotFulfilled
      if(!IsConnected())
         Print("No Internet connection found! Please check your network connection and try again.");
      if(IsTradeContextBusy())
         Print("Trade context is busy, Please wait...");
      if(!IsTradeAllowed())
         Print("Check if automated trading is allowed in the terminal / program settings and try again.");
      //--
      _PlaySound(ErrorSound);
      //--
      Sleep(ErrorInterval);
      return;
     }
//--
  }
//+------------------------------------------------------------------+
//| OpenPos                                                          |
//+------------------------------------------------------------------+
int OpenPos(const int Type)
  {
//--
   int count=0;
//--
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==_Symbol && OrderMagicNumber()==MagicNumber)
           {
            if(OrderType()==OP_SELL && Type==OP_SELL)
               count++;
            if(OrderType()==OP_BUY && Type==OP_BUY)
               count++;
            if(OrderType()<=OP_SELL && Type==OP_ALL)
               count++;
           }
        }
     }
   return(count);
//--
  }
//+------------------------------------------------------------------+
//| ØOpenPrice                                                       |
//+------------------------------------------------------------------+
double ØOpenPrice()
  {
//--
   double ordlots=0;
   double price=0;
   double avgprice=0;
//--
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==_Symbol && OrderMagicNumber()==MagicNumber)
           {
            if(OrderType()<=OP_SELL)//MarketOrdersOnly
              {
               ordlots+=OrderLots();
               price+=OrderLots()*OrderOpenPrice();
              }
           }
        }
     }
//-- CalcAvgPrice
   avgprice=price/ordlots;
//--
   return(avgprice);
  }
//+------------------------------------------------------------------+
//| FloatingProfits                                                  |
//+------------------------------------------------------------------+
double FloatingProfits()
  {
//--  
   double profit=0;
//--
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==_Symbol && OrderMagicNumber()==MagicNumber)
           {
            if(OrderType()<=OP_SELL)//MarketOrdersOnly
              {
               profit+=OrderProfit()+OrderCommission()+OrderSwap();
              }
           }
        }
     }
   return(profit);
//--
  }
//+------------------------------------------------------------------+
//| FloatingPoints                                                   |
//+------------------------------------------------------------------+
double FloatingPoints()
  {
//--
   double sellpts=0;
   double buypts=0;
//--
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==_Symbol && OrderMagicNumber()==MagicNumber)
           {
            if(OrderType()==OP_SELL)
               sellpts+=(OrderOpenPrice()-OrderClosePrice())/_Point;
            if(OrderType()==OP_BUY)
               buypts+=(OrderClosePrice()-OrderOpenPrice())/_Point;
           }
        }
     }
   return(sellpts+buypts);
//--
  }
//+------------------------------------------------------------------+
//| DailyProfits                                                     |
//+------------------------------------------------------------------+
double DailyProfits()
  {
//--  
   double profit=0;
//--
   for(int i=OrdersHistoryTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderSymbol()==_Symbol && OrderMagicNumber()==MagicNumber)
           {
            if(OrderType()<=OP_SELL)//MarketOrdersOnly
              {
               if(TimeToStr(TimeCurrent(),TIME_DATE)==TimeToString(OrderCloseTime(),TIME_DATE))
                  profit+=OrderProfit()+OrderCommission()+OrderSwap();
              }
           }
        }
     }
   return(profit);
//--
  }
//+------------------------------------------------------------------+
//| DailyPoints                                                      |
//+------------------------------------------------------------------+
double DailyPoints()
  {
//--
   double sellpts=0;
   double buypts=0;
//--
   for(int i=OrdersHistoryTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderSymbol()==_Symbol && OrderMagicNumber()==MagicNumber)
           {
            if(OrderType()<=OP_SELL)//MarketOrdersOnly
              {
               if(TimeToStr(TimeCurrent(),TIME_DATE)==TimeToString(OrderCloseTime(),TIME_DATE))
                 {
                  if(OrderType()==OP_SELL)
                     sellpts+=(OrderOpenPrice()-OrderClosePrice())/_Point;
                  if(OrderType()==OP_BUY)
                     buypts+=(OrderClosePrice()-OrderOpenPrice())/_Point;
                 }
              }
           }
        }
     }
   return(sellpts+buypts);
//--
  }
//+------------------------------------------------------------------+
//| DailyReturn                                                      |
//+------------------------------------------------------------------+
double DailyReturn()
  {
//--
   double percent=0;
   double startbal=0;

//-- GetStartBalance
   startbal=(DailyProfits()>0)?AccountBalance()-DailyProfits():AccountBalance()+MathAbs(DailyProfits());

//-- CalcReturn (ROI)
   if(startbal!=0)//AvoidZeroDivide
      percent=DailyProfits()*100/startbal;
//--
   return(percent);
  }
//+------------------------------------------------------------------+
//| PriceByTkt                                                       |
//+------------------------------------------------------------------+
double PriceByTkt(const int Type,const int Ticket)
  {
//--
   double price=0;
//--
   if(OrderSelect(Ticket,SELECT_BY_TICKET,MODE_TRADES))
     {
      if(Type==OPENPRICE)
         price=OrderOpenPrice();
      if(Type==CLOSEPRICE)
         price=OrderClosePrice();
     }
//--
   return(price);
  }
//+------------------------------------------------------------------+
//| GetSetInputs                                                     |
//+------------------------------------------------------------------+
void GetSetInputs()
  {
//-- GetMarketInfo
   LotStep=MarketInfo(_Symbol,MODE_LOTSTEP);
   MinLot=MarketInfo(_Symbol,MODE_MINLOT);
   MaxLot=MarketInfo(_Symbol,MODE_MAXLOT);
   MinStop=MarketInfo(_Symbol,MODE_STOPLEVEL);

//-- GetLotSizeInput
   LotSizeInp=StringToDouble(ObjectGetString(0,OBJPREFIX+"LOTSIZE<>",OBJPROP_TEXT));/*SetObject*/
//-- RoundLotSize
   LotSize=LotSizeInp;
   LotSize=MathRound(LotSize/LotStep)*LotStep;
   ObjectSetString(0,OBJPREFIX+"LOTSIZE<>",OBJPROP_TEXT,0,DoubleToString(LotSize,2));/*SetObject*/
//-- WrongLotSize
   if(LotSize<=MinLot)
     {
      LotSize=MinLot;
      ObjectSetString(0,OBJPREFIX+"LOTSIZE<>",OBJPROP_TEXT,0,DoubleToString(LotSize,2));/*SetObject*/
     }
//--
   if(LotSize>=MaxLot)
     {
      LotSize=MaxLot;
      ObjectSetString(0,OBJPREFIX+"LOTSIZE<>",OBJPROP_TEXT,0,DoubleToString(LotSize,2));/*SetObject*/
     }

//-- GetSLInput
   StopLossInp=StringToDouble(ObjectGetString(0,OBJPREFIX+"SL<>",OBJPROP_TEXT));/*GetObject*/
//-- WrongSL
   if(StopLossInp<0 || StopLossInp<MinStop)
     {
      StopLoss=0;
      ObjectSetString(0,OBJPREFIX+"SL<>",OBJPROP_TEXT,0,DoubleToString(StopLoss,0));/*SetObject*/
     }
   else
     {
      StopLoss=StopLossInp;
     }

//-- GetTPInput
   TakeProfitInp=StringToDouble(ObjectGetString(0,OBJPREFIX+"TP<>",OBJPROP_TEXT));/*GetObject*/
//-- WrongTP
   if(TakeProfitInp<0 || TakeProfitInp<MinStop)
     {
      TakeProfit=0;
      ObjectSetString(0,OBJPREFIX+"TP<>",OBJPROP_TEXT,0,DoubleToString(TakeProfit,0));/*SetObject*/
     }
   else
     {
      TakeProfit=TakeProfitInp;
     }

//-- SymbolChanger
   SymbolInp=ObjectGetString(0,OBJPREFIX+"SYMBOL¤",OBJPROP_TEXT);//GetSymbolInput

   if(SymbolInp!="" && _Symbol!=SymbolInp)
     {
      if(SymbolFind(SymbolInp))
        {
         ChartSetSymbolPeriod(0,SymbolInp,PERIOD_CURRENT);//SetChart
        }
      else
        {
         //-- WrongSymbolInput
         MessageBox("Warning: Symbol "+SymbolInp+" couldn't be found!\n\nMake sure it is available in the symbol list.\n(View -> Symbols / Ctrl+U)",
                    MB_CAPTION,MB_OK|MB_ICONWARNING);
         ObjectSetString(0,OBJPREFIX+"SYMBOL¤",OBJPROP_TEXT,_Symbol);//Reset
        }
     }
//--
  }
//+------------------------------------------------------------------+
//| SymbolInfo                                                       |
//+------------------------------------------------------------------+
void SymbolInfo()
  {
//-- SetObjects
   ObjectSetString(0,OBJPREFIX+"ASK",OBJPROP_TEXT,DoubleToString(MarketInfo(_Symbol,MODE_ASK),_Digits));
   ObjectSetString(0,OBJPREFIX+"BID",OBJPROP_TEXT,DoubleToString(MarketInfo(_Symbol,MODE_BID),_Digits));
//--
   ObjectSetString(0,OBJPREFIX+"UPTICKS",OBJPROP_TEXT,DoubleToString(UpTicks,0));
   ObjectSetString(0,OBJPREFIX+"DWNTICKS",OBJPROP_TEXT,DoubleToString(DwnTicks,0));
//--
   ObjectSetString(0,OBJPREFIX+"TIMER",OBJPROP_TEXT,"--> "+TimeToString(Time[0]+Period()*60-TimeCurrent(),TIME_MINUTES|TIME_SECONDS));
//--
   ObjectSetString(0,OBJPREFIX+"SPREAD",OBJPROP_TEXT,DoubleToString(MarketInfo(_Symbol,MODE_SPREAD),0)+"p");

//-- GetOpen&Close
   double dayopen=iOpen(NULL,PERIOD_D1,0);
   double dayclose=iClose(NULL,PERIOD_D1,0);

//-- AvoidZeroDivide
   if(dayclose!=0)
     {
      //-- CalcPercentage
      double symbol_p=NormalizeDouble((dayclose-dayopen)/dayclose*100,2);
      //-- PositiveValue
      if(symbol_p>0)
        {
         //-- SetObjects
         ObjectSetString(0,OBJPREFIX+"SYMBOL§",OBJPROP_TEXT,0,"é");
         ObjectSetInteger(0,OBJPREFIX+"SYMBOL§",OBJPROP_COLOR,±Clr(symbol_p));
         //--
         ObjectSetString(0,OBJPREFIX+"SYMBOL%",OBJPROP_TEXT,0,±Str(symbol_p,2)+"%");
         ObjectSetInteger(0,OBJPREFIX+"SYMBOL%",OBJPROP_COLOR,±Clr(symbol_p));
        }
      //-- NegativeValue
      if(symbol_p<0)
        {
         //-- SetObjects
         ObjectSetString(0,OBJPREFIX+"SYMBOL§",OBJPROP_TEXT,0,"ê");
         ObjectSetInteger(0,OBJPREFIX+"SYMBOL§",OBJPROP_COLOR,±Clr(symbol_p));
         //--
         ObjectSetString(0,OBJPREFIX+"SYMBOL%",OBJPROP_TEXT,0,±Str(symbol_p,2)+"%");
         ObjectSetInteger(0,OBJPREFIX+"SYMBOL%",OBJPROP_COLOR,±Clr(symbol_p));
        }
      //-- NeutralValue
      if(symbol_p==0)
        {
         //-- SetObjects
         ObjectSetString(0,OBJPREFIX+"SYMBOL§",OBJPROP_TEXT,0,"è");
         ObjectSetInteger(0,OBJPREFIX+"SYMBOL%",OBJPROP_COLOR,±Clr(symbol_p));
         //--
         ObjectSetString(0,OBJPREFIX+"SYMBOL%",OBJPROP_TEXT,0,±Str(symbol_p,2)+"%");
         ObjectSetInteger(0,OBJPREFIX+"SYMBOL§",OBJPROP_COLOR,±Clr(symbol_p));
        }
     }
//-- ResetCumulatedTicks
   ResetTicks();
//--
  }
//+------------------------------------------------------------------+
//| Speedometer                                                      |
//+------------------------------------------------------------------+
void Speedometer()
  {
//-- CalcSpeed
   double LastPrice=AvgPrice/_Point;
   double CurrentPrice=((MarketInfo(_Symbol,MODE_ASK)+MarketInfo(_Symbol,MODE_BID))/2)/_Point;
   double Speed=NormalizeDouble((CurrentPrice-LastPrice),0);
   AvgPrice=(MarketInfo(_Symbol,MODE_ASK)+MarketInfo(_Symbol,MODE_BID))/2;

//-- SetMaxSpeed
   if(Speed>99)
      Speed=99;

//-- ResetColors
   for(int i=0; i<(MaxSpeedBars); i++)
     {
      //-- SetObjects
      ObjectSetInteger(0,OBJPREFIX+"SPEED#"+IntegerToString(i,0,0),OBJPROP_COLOR,clrNONE);
      ObjectSetInteger(0,OBJPREFIX+"SPEEDª",OBJPROP_COLOR,clrNONE);
     }

//-- SetColor&Text
   for(int i=0; i<MathAbs(Speed); i++)
     {
      //-- PositiveValue
      if(Speed>0)
        {
         //-- SetObjects
         ObjectSetInteger(0,OBJPREFIX+"SPEED#"+IntegerToString(i,0,0),OBJPROP_COLOR,COLOR_BUY);
         ObjectSetInteger(0,OBJPREFIX+"SPEEDª",OBJPROP_COLOR,COLOR_BUY);
         //--
         UpTicks+=Speed;//Cumulated
        }
      //-- NegativeValue
      if(Speed<0)
        {
         //-- SetObjects
         ObjectSetInteger(0,OBJPREFIX+"SPEED#"+IntegerToString(i,0,0),OBJPROP_COLOR,COLOR_SELL);
         ObjectSetInteger(0,OBJPREFIX+"SPEEDª",OBJPROP_COLOR,COLOR_SELL);
         //--
         DwnTicks+=MathAbs(Speed);//Cumulated
        }
      ObjectSetString(0,OBJPREFIX+"SPEEDª",OBJPROP_TEXT,0,±Str(Speed,0));//SetObject
     }

//-- IsPlayTickSound
   if(PlayTicks)
     {
      //-- SetWavFile
      string SpeedToStr="";
      //-- PositiveValue
      if(Speed>0)
        {
         SpeedToStr="+"+DoubleToString(MathMin(Speed,10),0);
        }
      //-- NegativeValue
      else
        {
         SpeedToStr=""+DoubleToString(MathMax(Speed,-10),0);
        }
      //--
      _PlaySound("Tick"+SpeedToStr+".wav");
     }
//--
  }
//+------------------------------------------------------------------+
//| AccAndTradeInfo                                                  |
//+------------------------------------------------------------------+
void AccAndTradeInfo()
  {
//-- ZeroOrders
   if(OpenPos(OP_ALL)==0)
     {
      //-- SetObjects
      ObjectSetInteger(0,OBJPREFIX+"ROIª",OBJPROP_COLOR,±Clr(DailyProfits()));
      ObjectSetInteger(0,OBJPREFIX+"ROI§",OBJPROP_COLOR,±Clr(DailyProfits()));
      //--
      ObjectSetString(0,OBJPREFIX+"ROI%",OBJPROP_TEXT,±Str(DailyReturn(),2)+"%");
      ObjectSetInteger(0,OBJPREFIX+"ROI%",OBJPROP_COLOR,±Clr(DailyReturn()));
      //--
      ObjectSetString(0,OBJPREFIX+"PROFITS",OBJPROP_TEXT,±Str(DailyProfits(),2)+_AccountCurrency());
      ObjectSetInteger(0,OBJPREFIX+"PROFITS",OBJPROP_COLOR,±Clr(DailyProfits()));
      //--
      ObjectSetString(0,OBJPREFIX+"POINTS",OBJPROP_TEXT,±Str(DailyPoints(),0)+"p");
      ObjectSetInteger(0,OBJPREFIX+"POINTS",OBJPROP_COLOR,±Clr(DailyPoints()));
      //--
      ObjectSetString(0,OBJPREFIX+"FLOATª",OBJPROP_TEXT,"");
      ObjectSetInteger(0,OBJPREFIX+"FLOATª",OBJPROP_COLOR,clrNONE);
      //--
      ObjectSetString(0,OBJPREFIX+"FLOAT§",OBJPROP_TEXT,"");
      ObjectSetInteger(0,OBJPREFIX+"FLOAT§",OBJPROP_COLOR,clrNONE);
      //--
      ObjectSetString(0,OBJPREFIX+"FLOAT$",OBJPROP_TEXT,DoubleToString(0,_Digits));
      ObjectSetInteger(0,OBJPREFIX+"FLOAT$",OBJPROP_COLOR,clrNONE);
     }

//-- BuyOrders
   if(OpenPos(OP_BUY)>0 && OpenPos(OP_SELL)==0)
     {
      //-- SetObjects
      ObjectSetString(0,OBJPREFIX+"FLOATª",OBJPROP_TEXT,"ö");
      ObjectSetInteger(0,OBJPREFIX+"FLOATª",OBJPROP_COLOR,clrDodgerBlue);
      //--
      ObjectSetString(0,OBJPREFIX+"FLOAT§",OBJPROP_TEXT,"Buy");
      ObjectSetInteger(0,OBJPREFIX+"FLOAT§",OBJPROP_COLOR,clrDodgerBlue);
      //--
      ObjectSetString(0,OBJPREFIX+"FLOAT$",OBJPROP_TEXT,DoubleToString(ØOpenPrice(),_Digits));
      ObjectSetInteger(0,OBJPREFIX+"FLOAT$",OBJPROP_COLOR,clrDodgerBlue);
     }

//-- SellOrders
   if(OpenPos(OP_SELL)>0 && OpenPos(OP_BUY)==0)
     {
      //-- SetObjects
      ObjectSetString(0,OBJPREFIX+"FLOATª",OBJPROP_TEXT,"ø");
      ObjectSetInteger(0,OBJPREFIX+"FLOATª",OBJPROP_COLOR,clrOrangeRed);
      //--
      ObjectSetString(0,OBJPREFIX+"FLOAT§",OBJPROP_TEXT,"Sell");
      ObjectSetInteger(0,OBJPREFIX+"FLOAT§",OBJPROP_COLOR,clrOrangeRed);
      //--
      ObjectSetString(0,OBJPREFIX+"FLOAT$",OBJPROP_TEXT,DoubleToString(ØOpenPrice(),_Digits));
      ObjectSetInteger(0,OBJPREFIX+"FLOAT$",OBJPROP_COLOR,clrOrangeRed);
     }

//-- Buy&Sell Orders (Hedge)
   if(OpenPos(OP_BUY)>0 && OpenPos(OP_SELL)>0)
     {
      //-- SetObjects
      ObjectSetString(0,OBJPREFIX+"FLOATª",OBJPROP_TEXT,"ô");
      ObjectSetInteger(0,OBJPREFIX+"FLOATª",OBJPROP_COLOR,COLOR_HEDGE);
      //--
      ObjectSetString(0,OBJPREFIX+"FLOAT§",OBJPROP_TEXT,"Hedge");
      ObjectSetInteger(0,OBJPREFIX+"FLOAT§",OBJPROP_COLOR,COLOR_HEDGE);
      //--
      ObjectSetString(0,OBJPREFIX+"FLOAT$",OBJPROP_TEXT,DoubleToString(ØOpenPrice(),_Digits));
      ObjectSetInteger(0,OBJPREFIX+"FLOAT$",OBJPROP_COLOR,COLOR_HEDGE);
     }

//-- AtLeastOneOrder
   if(OpenPos(OP_ALL)>0)
     {
      //-- SetObjects
      ObjectSetInteger(0,OBJPREFIX+"ROIª",OBJPROP_COLOR,clrNONE);
      ObjectSetInteger(0,OBJPREFIX+"ROI§",OBJPROP_COLOR,clrNONE);
      //--
      ObjectSetInteger(0,OBJPREFIX+"ROI%",OBJPROP_COLOR,clrNONE);
      //--
      ObjectSetString(0,OBJPREFIX+"PROFITS",OBJPROP_TEXT,±Str(FloatingProfits(),2)+_AccountCurrency());
      ObjectSetInteger(0,OBJPREFIX+"PROFITS",OBJPROP_COLOR,±Clr(FloatingProfits()));
      //--
      ObjectSetString(0,OBJPREFIX+"POINTS",OBJPROP_TEXT,±Str(FloatingPoints(),0)+"p");
      ObjectSetInteger(0,OBJPREFIX+"POINTS",OBJPROP_COLOR,±Clr(FloatingPoints()));
     }

//-- DisplayOrderHistory
   if(ShowOrdHistory)
      DrawOrdHistory();
//--
  }
//+------------------------------------------------------------------+
//| GetSetCoordinates                                                |
//+------------------------------------------------------------------+
void GetSetCoordinates()
  {
//-- 
   if(ObjectFind(0,OBJPREFIX+"BCKGRND[]")!=0)//ObjectNotFound
     {

      //-- DeleteObjects (Background must be at the back)
      for(int i=0; i<ObjectsTotal(); i++)
        {
         //-- GetObjectName
         string obj_name=ObjectName(i);
         //-- PrefixObjectFound
         if(StringSubstr(obj_name,0,StringLen(OBJPREFIX))==OBJPREFIX)
           {
            //-- DeleteObjects
            if(ObjectsDeleteAll(0,OBJPREFIX,-1,-1)>0)
               break;
           }
        }

      //-- GetXYValues (Saved)
      if(GlobalVariableGet(ExpertName+" - X")!=0 && GlobalVariableGet(ExpertName+" - Y")!=0)
        {
         x1=(int)GlobalVariableGet(ExpertName+" - X");
         y1=(int)GlobalVariableGet(ExpertName+" - Y");
        }
      //-- SetXYValues (Default)
      else
        {
         x1=CLIENT_BG_X;
         y1=CLIENT_BG_Y;
        }

      //-- CreateObject (Background)
      RectLabelCreate(0,OBJPREFIX+"BCKGRND[]",0,x1,y1,x2,y2,COLOR_BG,BORDER_FLAT,CORNER_LEFT_UPPER,clrOrange,STYLE_SOLID,1,false,true,true,0,"\n");
      ObjectSetInteger(0,OBJPREFIX+"BCKGRND[]",OBJPROP_SELECTED,false);//UnselectObject
     }

//-- GetCoordinates
   x1=(int)ObjectGetInteger(0,OBJPREFIX+"BCKGRND[]",OBJPROP_XDISTANCE);
   y1=(int)ObjectGetInteger(0,OBJPREFIX+"BCKGRND[]",OBJPROP_YDISTANCE);

//-- SetCommonAxis
   button_y=y1+y2-(BUTTON_HEIGHT+BUTTON_GAP_Y);
   inputs_y=button_y-BUTTON_HEIGHT-BUTTON_GAP_Y;
   label_y=inputs_y+EDIT_HEIGHT/2;
//--
   fr_x=x1+SPEEDBAR_GAP_X;
//--
  }
//+------------------------------------------------------------------+
//| CreateObjects                                                    |
//+------------------------------------------------------------------+ 
void ObjectsCreateAll()
  {
//--
   ButtonCreate(0,OBJPREFIX+"RESET",0,CLIENT_BG_X,CLIENT_BG_Y,15,15,CORNER_LEFT_UPPER,"°","Wingdings",10,COLOR_FONT,COLOR_MOVE,clrOrange,false,false,false,true,0,"\n");
//--
   RectLabelCreate(0,OBJPREFIX+"BORDER[]",0,x1,y1,x2,INDENT_TOP,clrOrange,BORDER_FLAT,CORNER_LEFT_UPPER,clrOrange,STYLE_SOLID,1,false,false,true,0,"\n");
//-- 
   LabelCreate(0,OBJPREFIX+"CAPTION",0,x1+(x2/2),y1,CORNER_LEFT_UPPER,"Trade Panel","Calibri",10,C'59,41,40',0,ANCHOR_UPPER,false,false,true,0,"\n");
//-- 
   LabelCreate(0,OBJPREFIX+"EXIT",0,(x1+(x2/2))+115,y1-2,CORNER_LEFT_UPPER,"r","Webdings",10,C'59,41,40',0,ANCHOR_UPPER,false,false,true,0,"\n",false);
//--
   ButtonCreate(0,OBJPREFIX+"MOVE",0,x1,y1,15,15,CORNER_LEFT_UPPER,"ó","Wingdings",10,COLOR_FONT,COLOR_MOVE,clrDarkOrange,false,false,false,true,0,"\n");
//--
   LabelCreate(0,OBJPREFIX+"CONNECTION",0,(x1+(x2/2))-97,y1-2,CORNER_LEFT_UPPER,"ü","Webdings",10,C'59,41,40',0,ANCHOR_UPPER,false,false,true,0,"",false);
//--
   LabelCreate(0,OBJPREFIX+"THEME",0,(x1+(x2/2))-72,y1-4,CORNER_LEFT_UPPER,"N","Webdings",15,C'59,41,40',0,ANCHOR_UPPER,false,false,true,0,"\n",false);
//--
   LabelCreate(0,OBJPREFIX+"PAINT",0,(x1+(x2/2))-48,y1,CORNER_LEFT_UPPER,"$","Wingdings 2",13,C'59,41,40',0,ANCHOR_UPPER,false,false,true,0,"\n",false);
//--
   LabelCreate(0,OBJPREFIX+"PLAY",0,(x1+(x2/2))+75,y1-5,CORNER_LEFT_UPPER,"4","Webdings",15,C'59,41,40',0,ANCHOR_UPPER,false,false,true,0,"\n",false);
//--
   LabelCreate(0,OBJPREFIX+"CANDLES¦",0,(x1+(x2/2))+97,y1-6,CORNER_LEFT_UPPER,"ß","Webdings",15,C'59,41,40',0,ANCHOR_UPPER,false,false,true,0,"\n",false);
//--
   LabelCreate(0,OBJPREFIX+"SOUND",0,(x1+(x2/2))+50,y1-2,CORNER_LEFT_UPPER,"X","Webdings",12,C'59,41,40',0,ANCHOR_UPPER,false,false,true,0,"\n",false);
//--
   LabelCreate(0,OBJPREFIX+"SOUNDIO",0,(x1+(x2/2))+60,y1-1,CORNER_LEFT_UPPER,"ð","Webdings",10,C'59,41,40',0,ANCHOR_UPPER,false,false,true,0,"\n",false);
//--
   EditCreate(0,OBJPREFIX+"SYMBOL¤",0,x1+BUTTON_GAP_X,y1+INDENT_TOP+BUTTON_GAP_X,EDIT_WIDTH,EDIT_HEIGHT,_Symbol,"Trebuchet MS",10,ALIGN_CENTER,false,CORNER_LEFT_UPPER,COLOR_FONT,COLOR_BG,clrDimGray,false,false,true,0);
//--
   LabelCreate(0,OBJPREFIX+"SYMBOL§",0,x1+100,y1+27,CORNER_LEFT_UPPER,"","Wingdings",12,clrLimeGreen,0,ANCHOR_RIGHT,false,false,true,0,"\n");
//--
   LabelCreate(0,OBJPREFIX+"SYMBOL%",0,x1+145,y1+27,CORNER_LEFT_UPPER,"","Arial Black",8,COLOR_FONT,0,ANCHOR_RIGHT,false,false,true,0,"\n");
//--
   LabelCreate(0,OBJPREFIX+"SPEEDª",0,x1+SPEEDTEXT_GAP_X,y1+SPEEDTEXT_GAP_Y,CORNER_LEFT_UPPER,"","Tahoma",12,clrNONE,0.0,ANCHOR_RIGHT,false,false,true,0);
//--
   LabelCreate(0,OBJPREFIX+"CLOSE¹²³",0,(x1+BUTTON_GAP_X)+37,(y1+INDENT_TOP+BUTTON_GAP_X)+27,CORNER_LEFT_UPPER,CloseArr[CloseMode],"Arial",6,COLOR_FONT,0,ANCHOR_CENTER,false,false,true,0,"\n",false);
//--
   LabelCreate(0,OBJPREFIX+"SPREAD",0,x1+90,y1+55,CORNER_LEFT_UPPER,"","Arial",8,COLOR_FONT,0,ANCHOR_CENTER,false,false,true,0,"\n");
//--
   LabelCreate(0,OBJPREFIX+"SPREAD§",0,x1+110,y1+55,CORNER_LEFT_UPPER,"h","Wingdings",12,COLOR_FONT,0,ANCHOR_CENTER,false,false,true,0,"\n");
//--
   RectLabelCreate(0,OBJPREFIX+"ASK[]",0,x1+155,y1+41,85,15,COLOR_ASK_REC,BORDER_FLAT,CORNER_LEFT_UPPER,COLOR_ASK_REC,STYLE_SOLID,1,false,false,true,0,"\n");
//--
   LabelCreate(0,OBJPREFIX+"ASK",0,x1+180,y1+49,CORNER_LEFT_UPPER,"","Arial",8,COLOR_FONT2,0,ANCHOR_CENTER,false,false,true,0,"\n");
//--
   RectLabelCreate(0,OBJPREFIX+"BID[]",0,x1+125,y1+56,85,15,COLOR_BID_REC,BORDER_FLAT,CORNER_LEFT_UPPER,COLOR_BID_REC,STYLE_SOLID,1,false,false,true,0,"\n");
//--
   LabelCreate(0,OBJPREFIX+"BID",0,x1+180,y1+63,CORNER_LEFT_UPPER,"","Arial",8,COLOR_FONT2,0,ANCHOR_CENTER,false,false,true,0,"\n");
//--
   LabelCreate(0,OBJPREFIX+"UPTICKS",0,x1+225,y1+49,CORNER_LEFT_UPPER,"","Arial",8,COLOR_FONT2,0,ANCHOR_CENTER,false,false,true,0,"\n");
//--
   LabelCreate(0,OBJPREFIX+"DWNTICKS",0,x1+140,y1+63,CORNER_LEFT_UPPER,"","Arial",8,COLOR_FONT2,0,ANCHOR_CENTER,false,false,true,0,"\n");
//--
   LabelCreate(0,OBJPREFIX+"UP»",0,x1+141,y1+47,CORNER_LEFT_UPPER,"6","Webdings",12,COLOR_SELL,0,ANCHOR_CENTER,false,false,true,0,"\n");
//--
   LabelCreate(0,OBJPREFIX+"DN»",0,x1+225,y1+63,CORNER_LEFT_UPPER,"5","Webdings",12,COLOR_BUY,0,ANCHOR_CENTER,false,false,true,0,"\n");
//--
   LabelCreate(0,OBJPREFIX+"TIMER",0,x1+10,y1+65,CORNER_LEFT_UPPER,"","Tahoma",7,COLOR_FONT,0,ANCHOR_LEFT,false,false,true,0,"\n");
//--
   LabelCreate(0,OBJPREFIX+"FLOATª",0,x1+BUTTON_GAP_X+5,inputs_y-15,CORNER_LEFT_UPPER,"","Wingdings",15,clrNONE,0,ANCHOR_LEFT,false,false,true,0,"\n");
//--
   LabelCreate(0,OBJPREFIX+"FLOAT§",0,x1+BUTTON_GAP_X+45,inputs_y-15,CORNER_LEFT_UPPER,"","Arial",9,clrNONE,0,ANCHOR_CENTER,false,false,true,0,"\n");
//--
   LabelCreate(0,OBJPREFIX+"FLOAT$",0,x1+BUTTON_GAP_X+120,inputs_y-15,CORNER_LEFT_UPPER,"","Arial",9,clrNONE,0,ANCHOR_RIGHT,false,false,true,0,"\n");
//--
   LabelCreate(0,OBJPREFIX+"PROFITS",0,x1+BUTTON_GAP_X+190,inputs_y-15,CORNER_LEFT_UPPER,"","Arial",9,clrNONE,0,ANCHOR_RIGHT,false,false,true,0,"\n");
//--
   LabelCreate(0,OBJPREFIX+"POINTS",0,x1+BUTTON_GAP_X+235,inputs_y-15,CORNER_LEFT_UPPER,"","Arial",9,clrNONE,0,ANCHOR_RIGHT,false,false,true,0,"\n");
//--
   LabelCreate(0,OBJPREFIX+"ROIª",0,x1+BUTTON_GAP_X+5,inputs_y-15,CORNER_LEFT_UPPER,"Today","Arial",9,clrNONE,0,ANCHOR_LEFT,false,false,true,0,"\n");
//--
   LabelCreate(0,OBJPREFIX+"ROI§",0,x1+BUTTON_GAP_X+45,inputs_y-15,CORNER_LEFT_UPPER,"P","Wingdings",15,clrNONE,0,ANCHOR_LEFT,false,false,true,0,"\n");
//--
   LabelCreate(0,OBJPREFIX+"ROI%",0,x1+BUTTON_GAP_X+120,inputs_y-15,CORNER_LEFT_UPPER,"","Arial",9,clrNONE,0,ANCHOR_RIGHT,false,false,true,0,"\n");
//--
   EditCreate(0,OBJPREFIX+"SL<>",0,x1+BUTTON_GAP_X,inputs_y,EDIT_WIDTH,EDIT_HEIGHT,DoubleToString(StopLossInp,0),"Tahoma",10,ALIGN_RIGHT,false,CORNER_LEFT_UPPER,C'59,41,40',clrWhite,clrWhite,false,false,true,0,"\n");
//--
   LabelCreate(0,OBJPREFIX+"SLª",0,x1+BUTTON_GAP_X+EDIT_GAP_Y,label_y,CORNER_LEFT_UPPER,"sl","Arial",10,clrDarkGray,0,ANCHOR_CENTER,false,false,true,0,"\n");
//--
   EditCreate(0,OBJPREFIX+"LOTSIZE<>",0,x1+BUTTON_GAP_X+BUTTON_WIDTH+BUTTON_GAP_X,inputs_y,EDIT_WIDTH,EDIT_HEIGHT,DoubleToString(LotSizeInp,2),"Tahoma",10,ALIGN_CENTER,false,CORNER_LEFT_UPPER,C'59,41,40',clrWhite,clrWhite,false,false,true,0,"\n");
//--
   LabelCreate(0,OBJPREFIX+"LOTSIZE<",0,(x1+BUTTON_GAP_X+EDIT_GAP_Y)+75,label_y,CORNER_LEFT_UPPER,"6","Webdings",10,C'59,41,40',0,ANCHOR_CENTER,false,false,true,0,"\n",false);
//--
   LabelCreate(0,OBJPREFIX+"LOTSIZE>",0,(x1+BUTTON_GAP_X+EDIT_GAP_Y)+130,label_y,CORNER_LEFT_UPPER,"5","Webdings",10,C'59,41,40',0,ANCHOR_CENTER,false,false,true,0,"\n",false);
//--
   EditCreate(0,OBJPREFIX+"TP<>",0,x1+(BUTTON_WIDTH*2)+(BUTTON_GAP_X*3),inputs_y,EDIT_WIDTH,EDIT_HEIGHT,DoubleToString(TakeProfitInp,0),"Tahoma",10,ALIGN_RIGHT,false,CORNER_LEFT_UPPER,C'59,41,40',clrWhite,clrWhite,false,false,true,0,"\n");
//--
   LabelCreate(0,OBJPREFIX+"TPª",0,x1+(BUTTON_WIDTH*2)+(BUTTON_GAP_X*3)+EDIT_GAP_Y,label_y,CORNER_LEFT_UPPER,"tp","Arial",10,clrDarkGray,0,ANCHOR_CENTER,false,false,true,0,"\n");
//--
   ButtonCreate(0,OBJPREFIX+"SELL",0,x1+BUTTON_GAP_X,button_y,BUTTON_WIDTH,BUTTON_HEIGHT,CORNER_LEFT_UPPER,"Sell","Trebuchet MS",10,C'59,41,40',C'255,128,128',C'239,112,112',false,false,false,true,1,"\n");
//--
   ButtonCreate(0,OBJPREFIX+"CLOSE",0,x1+BUTTON_WIDTH+(BUTTON_GAP_X*2),button_y,BUTTON_WIDTH,BUTTON_HEIGHT,CORNER_LEFT_UPPER,"Close","Trebuchet MS",10,C'59,41,40',C'255,255,160',C'239,239,144',false,false,false,true,1,"\n");
//--
   ButtonCreate(0,OBJPREFIX+"BUY",0,x1+(BUTTON_WIDTH*2)+(BUTTON_GAP_X*3),button_y,BUTTON_WIDTH,BUTTON_HEIGHT,CORNER_LEFT_UPPER,"Buy","Trebuchet MS",10,C'59,41,40',C'160,192,255',C'144,176,239',false,false,false,true,1,"\n");

//-- CreateSpeedBars
   for(int i=0; i<MaxSpeedBars; i++)
     {
      LabelCreate(0,OBJPREFIX+"SPEED#"+IntegerToString(i),0,fr_x,y1+SPEEDBAR_GAP_Y,CORNER_LEFT_UPPER,"l","Arial Black",15,clrNONE,0.0,ANCHOR_RIGHT,false,false,true,0);
      fr_x-=5;
     }

//-- Strategy Tester (Cannot change symbol)
   if(IsTesting())
     {
      if(ObjectFind(0,OBJPREFIX+"SYMBOL¤")==0)//ObjectIsPresent
        {
         if(!ObjectGetInteger(0,OBJPREFIX+"SYMBOL¤",OBJPROP_READONLY))//GetObject
            ObjectSetInteger(0,OBJPREFIX+"SYMBOL¤",OBJPROP_READONLY,true);//SetObject
        }
     }
//--
  }
//+------------------------------------------------------------------+
//| MoveObjects                                                      |
//+------------------------------------------------------------------+
void ObjectsMoveAll()
  {
//--
   RectLabelMove(0,OBJPREFIX+"BORDER[]",x1,y1);
//--
   LabelMove(0,OBJPREFIX+"CAPTION",(x1+(x2/2)),y1);
//--
   LabelMove(0,OBJPREFIX+"EXIT",(x1+(x2/2))+115,y1-2);
//--
   ButtonMove(0,OBJPREFIX+"MOVE",x1,y1);
//--
   LabelMove(0,OBJPREFIX+"CONNECTION",(x1+(x2/2))-97,y1-2);
//--
   LabelMove(0,OBJPREFIX+"THEME",(x1+(x2/2))-72,y1-4);
//--
   LabelMove(0,OBJPREFIX+"PAINT",(x1+(x2/2))-48,y1);
//--
   LabelMove(0,OBJPREFIX+"PLAY",(x1+(x2/2))+75,y1-5);
//--
   LabelMove(0,OBJPREFIX+"CANDLES¦",(x1+(x2/2))+97,y1-6);
//--
   LabelMove(0,OBJPREFIX+"SOUND",(x1+(x2/2))+50,y1-2);
//--
   LabelMove(0,OBJPREFIX+"SOUNDIO",(x1+(x2/2))+60,y1-1);
//--
   EditMove(0,OBJPREFIX+"SYMBOL¤",x1+BUTTON_GAP_X,y1+INDENT_TOP+BUTTON_GAP_X);
//--
   LabelMove(0,OBJPREFIX+"SYMBOL§",x1+100,y1+27);
//--
   LabelMove(0,OBJPREFIX+"SYMBOL%",x1+145,y1+27);
//--   
   LabelMove(0,OBJPREFIX+"SPEEDª",x1+SPEEDTEXT_GAP_X,y1+SPEEDTEXT_GAP_Y);
//--
   LabelMove(0,OBJPREFIX+"CLOSE¹²³",(x1+BUTTON_GAP_X)+37,(y1+INDENT_TOP+BUTTON_GAP_X)+27);
//--
   LabelMove(0,OBJPREFIX+"SPREAD",x1+90,y1+55);
//--
   LabelMove(0,OBJPREFIX+"SPREAD§",x1+110,y1+55);
//--
   RectLabelMove(0,OBJPREFIX+"ASK[]",x1+155,y1+41);
//--
   LabelMove(0,OBJPREFIX+"ASK",x1+180,y1+49);
//--
   RectLabelMove(0,OBJPREFIX+"BID[]",x1+125,y1+56);
//--
   LabelMove(0,OBJPREFIX+"BID",x1+180,y1+63);
//--
   LabelMove(0,OBJPREFIX+"UPTICKS",x1+225,y1+49);
//--
   LabelMove(0,OBJPREFIX+"DWNTICKS",x1+140,y1+63);
//--
   LabelMove(0,OBJPREFIX+"UP»",x1+141,y1+47);
//--
   LabelMove(0,OBJPREFIX+"DN»",x1+225,y1+63);
//--
   LabelMove(0,OBJPREFIX+"TIMER",x1+10,y1+65);
//--
   LabelMove(0,OBJPREFIX+"FLOATª",x1+BUTTON_GAP_X+5,inputs_y-15);
//--
   LabelMove(0,OBJPREFIX+"FLOAT§",x1+BUTTON_GAP_X+45,inputs_y-15);
//--
   LabelMove(0,OBJPREFIX+"FLOAT$",x1+BUTTON_GAP_X+120,inputs_y-15);
//--
   LabelMove(0,OBJPREFIX+"PROFITS",x1+BUTTON_GAP_X+190,inputs_y-15);
//--
   LabelMove(0,OBJPREFIX+"POINTS",x1+BUTTON_GAP_X+235,inputs_y-15);
//--
   LabelMove(0,OBJPREFIX+"ROIª",x1+BUTTON_GAP_X+5,inputs_y-15);
//--
   LabelMove(0,OBJPREFIX+"ROI§",x1+BUTTON_GAP_X+45,inputs_y-15);
//--
   LabelMove(0,OBJPREFIX+"ROI%",x1+BUTTON_GAP_X+120,inputs_y-15);
//--
   EditMove(0,OBJPREFIX+"SL<>",x1+BUTTON_GAP_X,inputs_y);
//--
   LabelMove(0,OBJPREFIX+"SLª",x1+BUTTON_GAP_X+EDIT_GAP_Y,label_y);
//--
   EditMove(0,OBJPREFIX+"LOTSIZE<>",x1+BUTTON_WIDTH+(BUTTON_GAP_X*2),inputs_y);
//--
   LabelMove(0,OBJPREFIX+"LOTSIZE<",(x1+BUTTON_GAP_X+EDIT_GAP_Y)+75,label_y);
//--
   LabelMove(0,OBJPREFIX+"LOTSIZE>",(x1+BUTTON_GAP_X+EDIT_GAP_Y)+130,label_y);
//--
   EditMove(0,OBJPREFIX+"TP<>",x1+(BUTTON_WIDTH*2)+(BUTTON_GAP_X*3),inputs_y);
//--
   LabelMove(0,OBJPREFIX+"TPª",x1+(BUTTON_WIDTH*2)+(BUTTON_GAP_X*3)+EDIT_GAP_Y,label_y);
//--
   ButtonMove(0,OBJPREFIX+"SELL",x1+BUTTON_GAP_X,button_y);
//--
   ButtonMove(0,OBJPREFIX+"CLOSE",x1+BUTTON_WIDTH+(BUTTON_GAP_X*2),button_y);
//--
   ButtonMove(0,OBJPREFIX+"BUY",x1+(BUTTON_WIDTH*2)+(BUTTON_GAP_X*3),button_y);

//-- MoveSpeedBars
   for(int i=0; i<MaxSpeedBars; i++)
     {
      LabelMove(0,OBJPREFIX+"SPEED#"+IntegerToString(i),fr_x,y1+SPEEDBAR_GAP_Y);
      fr_x-=5;
     }
//--
  }
//+------------------------------------------------------------------+
//| CheckObjects                                                     |
//+------------------------------------------------------------------+
void ObjectsCheckAll()
  {
//-- CreateObjects
   ObjectsCreateAll();/*User may have deleted one*/

//+------- TrackSomeObjects -------+

//-- IsSelectable
   if(ObjectFind(0,OBJPREFIX+"MOVE")==0 && ObjectFind(0,OBJPREFIX+"BCKGRND[]")==0)//ObjectIsPresent
     {
      if(ObjectGetInteger(0,OBJPREFIX+"MOVE",OBJPROP_STATE))//GetObject
        {
         if(!ObjectGetInteger(0,OBJPREFIX+"BCKGRND[]",OBJPROP_SELECTED))//GetObject
            ObjectSetInteger(0,OBJPREFIX+"BCKGRND[]",OBJPROP_SELECTED,true);//SetObject
        }
      //-- IsNotSelectable
      else
        {
         if(!ObjectGetInteger(0,OBJPREFIX+"MOVE",OBJPROP_STATE))//GetObject
            ObjectSetInteger(0,OBJPREFIX+"BCKGRND[]",OBJPROP_SELECTED,false);//SetObject
        }
     }

//-- IsConnected
   if(ObjectFind(0,OBJPREFIX+"CONNECTION")==0)//ObjectIsPresent
     {
      if(TerminalInfoInteger(TERMINAL_CONNECTED))
        {
         if(ObjectGetString(0,OBJPREFIX+"CONNECTION",OBJPROP_TEXT)!="ü")//GetObject
            ObjectSetString(0,OBJPREFIX+"CONNECTION",OBJPROP_TEXT,"ü");//SetObject
         if(ObjectGetString(0,OBJPREFIX+"CONNECTION",OBJPROP_TOOLTIP)!="Connected")//GetObject
            ObjectSetString(0,OBJPREFIX+"CONNECTION",OBJPROP_TOOLTIP,"Connected");//SetObject
        }
      //-- IsDisconnected
      else
        {
         if(ObjectGetString(0,OBJPREFIX+"CONNECTION",OBJPROP_TEXT)!="ñ")//GetObject
            ObjectSetString(0,OBJPREFIX+"CONNECTION",OBJPROP_TEXT,"ñ");//SetObject
         if(ObjectGetString(0,OBJPREFIX+"CONNECTION",OBJPROP_TOOLTIP)!="No connection!")//GetObject
            ObjectSetString(0,OBJPREFIX+"CONNECTION",OBJPROP_TOOLTIP,"No connection!");//SetObject
        }
     }

//-- SoundIsEnabled
   if(ObjectFind(0,OBJPREFIX+"SOUNDIO")==0)//ObjectIsPresent
     {
      if(SoundIsEnabled)
        {
         if(ObjectGetInteger(0,OBJPREFIX+"SOUNDIO",OBJPROP_COLOR)!=C'59,41,40')//GetObject
            ObjectSetInteger(0,OBJPREFIX+"SOUNDIO",OBJPROP_COLOR,C'59,41,40');//SetObject
        }
      //-- SoundIsDisabled
      else
        {
         if(ObjectGetInteger(0,OBJPREFIX+"SOUNDIO",OBJPROP_COLOR)!=clrNONE)//GetObject
            ObjectSetInteger(0,OBJPREFIX+"SOUNDIO",OBJPROP_COLOR,clrNONE);//SetObject
        }
     }

//-- TickSoundsAreEnabled
   if(ObjectFind(0,OBJPREFIX+"PLAY")==0)//ObjectIsPresent
     {
      if(PlayTicks)
        {
         if(ObjectGetString(0,OBJPREFIX+"PLAY",OBJPROP_TEXT)!=";")//GetObject
            ObjectSetString(0,OBJPREFIX+"PLAY",OBJPROP_TEXT,";");//SetObject
         if(ObjectGetInteger(0,OBJPREFIX+"PLAY",OBJPROP_FONTSIZE)!=14)//GetObject
            ObjectSetInteger(0,OBJPREFIX+"PLAY",OBJPROP_FONTSIZE,14);//SetObject
        }
      //-- TickSoundsAreDisabled
      else
        {
         if(ObjectGetString(0,OBJPREFIX+"PLAY",OBJPROP_TEXT)!="4")//GetObject
            ObjectSetString(0,OBJPREFIX+"PLAY",OBJPROP_TEXT,"4");//SetObject
         if(ObjectGetInteger(0,OBJPREFIX+"PLAY",OBJPROP_FONTSIZE)!=15)//GetObject
            ObjectSetInteger(0,OBJPREFIX+"PLAY",OBJPROP_FONTSIZE,15);//SetObject
        }
     }

//+--------------------------------+
//--
  }
//+------------------------------------------------------------------+
//| SetColors                                                        |
//+------------------------------------------------------------------+
void SetColors(const int Type)
  {
//--
   if(Type==LIGHT)
     {
      //-- Light
      COLOR_BG=C'240,240,240';
      COLOR_FONT=C'40,41,59';
      COLOR_FONT2=COLOR_FONT;
      COLOR_MOVE=clrDarkGray;
      COLOR_GREEN=clrForestGreen;
      COLOR_RED=clrIndianRed;
      COLOR_HEDGE=clrDarkOrange;
      COLOR_ASK_REC=C'255,228,255';
      COLOR_BID_REC=C'215,228,255';
     }
   else
     {
      //-- Dark
      COLOR_BG=C'28,28,28';
      COLOR_FONT=clrDarkGray;
      COLOR_FONT2=COLOR_BG;
      COLOR_MOVE=clrDimGray;
      COLOR_GREEN=clrLimeGreen;
      COLOR_RED=clrRed;
      COLOR_HEDGE=clrGold;
      COLOR_ASK_REC=COLOR_SELL;
      COLOR_BID_REC=COLOR_BUY;
     }
//--
  }
//+------------------------------------------------------------------+
//| SetTheme                                                         |
//+------------------------------------------------------------------+
void SetTheme(const int Type)
  {
//--
   if(Type==LIGHT)
     {
      //-- Light
      COLOR_BG=C'240,240,240';
      COLOR_FONT=C'40,41,59';
      COLOR_MOVE=clrDarkGray;
      COLOR_GREEN=clrForestGreen;
      COLOR_RED=clrIndianRed;
      COLOR_HEDGE=clrDarkOrange;
      //-- SetObjects
      ObjectSetInteger(0,OBJPREFIX+"RESET",OBJPROP_BGCOLOR,COLOR_MOVE);
      ObjectSetInteger(0,OBJPREFIX+"RESET",OBJPROP_COLOR,COLOR_FONT);
      //--
      ObjectSetInteger(0,OBJPREFIX+"BCKGRND[]",OBJPROP_BGCOLOR,COLOR_BG);
      //--
      ObjectSetInteger(0,OBJPREFIX+"MOVE",OBJPROP_BGCOLOR,COLOR_MOVE);
      ObjectSetInteger(0,OBJPREFIX+"MOVE",OBJPROP_COLOR,COLOR_FONT);
      //--
      ObjectSetInteger(0,OBJPREFIX+"CLOSE¹²³",OBJPROP_COLOR,COLOR_FONT);
      //--
      ObjectSetInteger(0,OBJPREFIX+"SYMBOL¤",OBJPROP_BGCOLOR,COLOR_BG);
      ObjectSetInteger(0,OBJPREFIX+"SYMBOL¤",OBJPROP_COLOR,COLOR_FONT);
      //--
      ObjectSetInteger(0,OBJPREFIX+"ASK[]",OBJPROP_BGCOLOR,C'255,228,255');
      ObjectSetInteger(0,OBJPREFIX+"ASK[]",OBJPROP_COLOR,C'255,228,255');
      ObjectSetInteger(0,OBJPREFIX+"ASK",OBJPROP_COLOR,COLOR_FONT);
      ObjectSetInteger(0,OBJPREFIX+"UPTICKS",OBJPROP_COLOR,COLOR_FONT);
      //--
      ObjectSetInteger(0,OBJPREFIX+"BID[]",OBJPROP_BGCOLOR,C'215,228,255');
      ObjectSetInteger(0,OBJPREFIX+"BID[]",OBJPROP_COLOR,C'215,228,255');
      ObjectSetInteger(0,OBJPREFIX+"BID",OBJPROP_COLOR,COLOR_FONT);
      ObjectSetInteger(0,OBJPREFIX+"DWNTICKS",OBJPROP_COLOR,COLOR_FONT);
      //--
      ObjectSetInteger(0,OBJPREFIX+"SPREAD§",OBJPROP_COLOR,COLOR_FONT);
      ObjectSetInteger(0,OBJPREFIX+"SPREAD",OBJPROP_COLOR,COLOR_FONT);
      //--
      ObjectSetInteger(0,OBJPREFIX+"TIMER",OBJPROP_COLOR,COLOR_FONT);
      //-- StoreSelectedTheme
      SelectedTheme=LIGHT;
     }
   else
     {
      //-- Dark
      COLOR_BG=C'28,28,28';
      COLOR_FONT=clrDarkGray;
      COLOR_MOVE=clrDimGray;
      COLOR_GREEN=clrLimeGreen;
      COLOR_RED=clrRed;
      COLOR_HEDGE=clrGold;
      //-- SetObjects
      ObjectSetInteger(0,OBJPREFIX+"RESET",OBJPROP_BGCOLOR,COLOR_MOVE);
      ObjectSetInteger(0,OBJPREFIX+"RESET",OBJPROP_COLOR,COLOR_FONT);
      //--
      ObjectSetInteger(0,OBJPREFIX+"BCKGRND[]",OBJPROP_BGCOLOR,COLOR_BG);
      //--
      ObjectSetInteger(0,OBJPREFIX+"MOVE",OBJPROP_BGCOLOR,COLOR_MOVE);
      ObjectSetInteger(0,OBJPREFIX+"MOVE",OBJPROP_COLOR,COLOR_FONT);
      //--
      ObjectSetInteger(0,OBJPREFIX+"CLOSE¹²³",OBJPROP_COLOR,COLOR_FONT);
      //--
      ObjectSetInteger(0,OBJPREFIX+"SYMBOL¤",OBJPROP_BGCOLOR,COLOR_BG);
      ObjectSetInteger(0,OBJPREFIX+"SYMBOL¤",OBJPROP_COLOR,COLOR_FONT);
      //--
      ObjectSetInteger(0,OBJPREFIX+"ASK[]",OBJPROP_BGCOLOR,COLOR_SELL);
      ObjectSetInteger(0,OBJPREFIX+"ASK[]",OBJPROP_COLOR,COLOR_SELL);
      ObjectSetInteger(0,OBJPREFIX+"ASK",OBJPROP_COLOR,COLOR_BG);
      ObjectSetInteger(0,OBJPREFIX+"UPTICKS",OBJPROP_COLOR,COLOR_BG);
      //--
      ObjectSetInteger(0,OBJPREFIX+"BID[]",OBJPROP_BGCOLOR,COLOR_BUY);
      ObjectSetInteger(0,OBJPREFIX+"BID[]",OBJPROP_COLOR,COLOR_BUY);
      ObjectSetInteger(0,OBJPREFIX+"BID",OBJPROP_COLOR,COLOR_BG);
      ObjectSetInteger(0,OBJPREFIX+"DWNTICKS",OBJPROP_COLOR,COLOR_BG);
      //--
      ObjectSetInteger(0,OBJPREFIX+"SPREAD§",OBJPROP_COLOR,COLOR_FONT);
      ObjectSetInteger(0,OBJPREFIX+"SPREAD",OBJPROP_COLOR,COLOR_FONT);
      //--
      ObjectSetInteger(0,OBJPREFIX+"TIMER",OBJPROP_COLOR,COLOR_FONT);
      //-- StoreSelectedTheme
      SelectedTheme=DARK;
     }
//--
  }
//+------------------------------------------------------------------+
//| ResetTicks                                                       |
//+------------------------------------------------------------------+
bool ResetTicks()
  {
//--
   static datetime lastbar=0;
//--
   if(lastbar!=Time[0])
     {
      //-- ResetTicks
      UpTicks=0;
      DwnTicks=0;
      //-- StoreBarTime
      lastbar=Time[0];
      return(true);
     }
   else
     {
      return(false);
     }
//--
  }
//+------------------------------------------------------------------+
//| ±Str                                                             |
//+------------------------------------------------------------------+
string ±Str(double Inp,int Precision)
  {
//-- PositiveValue
   if(Inp>0)
     {
      return("+"+DoubleToString(Inp,Precision));
     }
//-- NegativeValue
   else
     {
      return(DoubleToString(Inp,Precision));
     }
//--
  }
//+------------------------------------------------------------------+
//| ±Clr                                                             |
//+------------------------------------------------------------------+
color ±Clr(double Inp)
  {
//--
   color clr=clrNONE;
//-- PositiveValue
   if(Inp>0)
     {
      clr=COLOR_GREEN;
     }
//-- NegativeValue
   if(Inp<0)
     {
      clr=COLOR_RED;
     }
//-- NeutralValue
   if(Inp==0)
     {
      clr=COLOR_FONT;
     }
//--
   return(clr);
//--
  }
//+------------------------------------------------------------------+
//| SymbolFind                                                       |
//+------------------------------------------------------------------+
bool SymbolFind(const string _Symb)
  {
//--
   bool result=false;
//--
   for(int i=0; i<SymbolsTotal(false); i++)
     {
      if(_Symb==SymbolName(i,false))
        {
         result=true;//SymbolFound
         break;
        }
     }
   return(result);
  }
//+------------------------------------------------------------------+
//| DrawOrdHistory                                                   |
//+------------------------------------------------------------------+
void DrawOrdHistory()
  {
//--
   string obj_name="",ordtype="",ticket="",openprice="",closeprice="",ordlots="",stoploss="",takeprofit="";
//--
   for(int i=OrdersHistoryTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderSymbol()==_Symbol && OrderMagicNumber()==MagicNumber)
           {
            if(OrderType()<=OP_SELL)//MarketOrdersOnly
              {
               //-- SetColor&OrdType
               if(OrderType()==OP_SELL){COLOR_ARROW=COLOR_SELL;ordtype="sell";}//SellOrders
               else{COLOR_ARROW=COLOR_BUY;ordtype="buy";}/*BuyOrders*/
               //-- ConvertToString
               ticket=IntegerToString(OrderTicket());//GetTicket
               openprice=DoubleToString(OrderOpenPrice(),_Digits);//GetOpenPrice
               closeprice=DoubleToString(OrderClosePrice(),_Digits);//GetClosePrice
               ordlots=DoubleToString(OrderLots(),2);/*GetOrderLots*/
               //-- OrderLine
               obj_name="#"+ticket+" "+openprice+" -> "+closeprice;//SetName
               TrendCreate(0,obj_name,0,OrderOpenTime(),OrderOpenPrice(),OrderCloseTime(),OrderClosePrice(),COLOR_ARROW,STYLE_DOT,1,false,false,false,0);
               //-- OpenArrow
               obj_name="#"+ticket+" "+ordtype+" "+ordlots+" "+_Symbol+" at "+openprice;//SetName
               ArrowCreate(0,obj_name,0,OrderOpenTime(),OrderOpenPrice(),1,ANCHOR_BOTTOM,COLOR_ARROW,STYLE_SOLID,1,false,false,false,0);
               //-- CloseArrow
               obj_name+=" close at "+closeprice;//SetName
               ArrowCreate(0,obj_name,0,OrderCloseTime(),OrderClosePrice(),3,ANCHOR_BOTTOM,COLOR_CLOSE,STYLE_SOLID,1,false,false,false,0);
               //-- StopLossArrow
               if(OrderStopLoss()>0)
                 {
                  stoploss=DoubleToString(OrderStopLoss(),_Digits);//GetStopLoss
                  obj_name="#"+ticket+" "+ordtype+" "+ordlots+" "+_Symbol+" at "+openprice+" sl at "+stoploss;//SetName
                  ArrowCreate(0,obj_name,0,OrderOpenTime(),OrderStopLoss(),4,ANCHOR_BOTTOM,COLOR_SELL,STYLE_SOLID,1,false,false,false,0);
                 }
               //-- TakeProfitArrow
               if(OrderTakeProfit()>0)
                 {
                  takeprofit=DoubleToString(OrderTakeProfit(),_Digits);//GetTakeProfit
                  obj_name="#"+ticket+" "+ordtype+" "+ordlots+" "+_Symbol+" at "+openprice+" tp at "+takeprofit;//SetName
                  ArrowCreate(0,obj_name,0,OrderOpenTime(),OrderTakeProfit(),4,ANCHOR_BOTTOM,COLOR_BUY,STYLE_SOLID,1,false,false,false,0);
                 }
               //--
              }
           }
        }
     }
//--
  }
//+------------------------------------------------------------------+
//| Create rectangle label                                           |
//+------------------------------------------------------------------+
bool RectLabelCreate(const long             chart_ID=0,               // chart's ID
                     const string           name="RectLabel",         // label name
                     const int              sub_window=0,             // subwindow index
                     const int              x=0,                      // X coordinate
                     const int              y=0,                      // Y coordinate
                     const int              width=50,                 // width
                     const int              height=18,                // height
                     const color            back_clr=C'236,233,216',  // background color
                     const ENUM_BORDER_TYPE border=BORDER_SUNKEN,     // border type
                     const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                     const color            clr=clrRed,               // flat border color (Flat)
                     const ENUM_LINE_STYLE  style=STYLE_SOLID,        // flat border style
                     const int              line_width=1,             // flat border width
                     const bool             back=false,               // in the background
                     const bool             selection=false,          // highlight to move
                     const bool             hidden=true,              // hidden in the object list
                     const long             z_order=0,                // priority for mouse click 
                     const string           tooltip="\n")             // tooltip for mouse hover
  {
//--- reset the error value
   ResetLastError();
//--
   if(ObjectFind(chart_ID,name)!=0)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
        {
         Print(__FUNCTION__,
               ": failed to create a rectangle label! Error code = ",_LastError);
         return(false);
        }
      //-- SetObjects
      ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
      ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
      ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
      ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);
     }
//--
   return(true);
  }
//+------------------------------------------------------------------+
//| Move rectangle label                                             |
//+------------------------------------------------------------------+
bool RectLabelMove(const long   chart_ID=0,       // chart's ID
                   const string name="RectLabel", // label name
                   const int    x=0,              // X coordinate
                   const int    y=0)              // Y coordinate
  {
//--- reset the error value
   ResetLastError();
//--
   if(ObjectFind(chart_ID,name)==0)
     {
      if(!ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x))
        {
         Print(__FUNCTION__,
               ": failed to move X coordinate of the label! Error code = ",_LastError);
         return(false);
        }
      if(!ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y))
        {
         Print(__FUNCTION__,
               ": failed to move Y coordinate of the label! Error code = ",_LastError);
         return(false);
        }
     }
//--
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Create the button                                                | 
//+------------------------------------------------------------------+ 
bool ButtonCreate(const long              chart_ID=0,               // chart's ID 
                  const string            name="Button",            // button name 
                  const int               sub_window=0,             // subwindow index 
                  const int               x=0,                      // X coordinate 
                  const int               y=0,                      // Y coordinate 
                  const int               width=50,                 // button width 
                  const int               height=18,                // button height 
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                  const string            text="Button",            // text 
                  const string            font="Arial",             // font 
                  const int               font_size=10,             // font size 
                  const color             clr=clrBlack,             // text color 
                  const color             back_clr=C'236,233,216',  // background color 
                  const color             border_clr=clrNONE,       // border color 
                  const bool              state=false,              // pressed/released 
                  const bool              back=false,               // in the background 
                  const bool              selection=false,          // highlight to move 
                  const bool              hidden=true,              // hidden in the object list 
                  const long              z_order=0,                // priority for mouse click 
                  const string            tooltip="\n")             // tooltip for mouse hover
  {
//-- reset the error value 
   ResetLastError();
//--
   if(ObjectFind(chart_ID,name)!=0)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
        {
         Print(__FUNCTION__,
               ": failed to create the button! Error code = ",_LastError);
         return(false);
        }
      //-- SetObjects
      ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
      ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);
     }
//--
   return(true);
  }
//+------------------------------------------------------------------+
//| Move the button                                                  |
//+------------------------------------------------------------------+
bool ButtonMove(const long   chart_ID=0,    // chart's ID
                const string name="Button", // button name
                const int    x=0,           // X coordinate
                const int    y=0)           // Y coordinate
  {
//--- reset the error value
   ResetLastError();
//--
   if(ObjectFind(chart_ID,name)==0)
     {
      if(!ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x))
        {
         Print(__FUNCTION__,
               ": failed to move X coordinate of the button! Error code = ",_LastError);
         return(false);
        }
      if(!ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y))
        {
         Print(__FUNCTION__,
               ": failed to move Y coordinate of the button! Error code = ",_LastError);
         return(false);
        }
     }
//--
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Create a text label                                              | 
//+------------------------------------------------------------------+ 
bool LabelCreate(const long              chart_ID=0,               // chart's ID 
                 const string            name="Label",             // label name 
                 const int               sub_window=0,             // subwindow index 
                 const int               x=0,                      // X coordinate 
                 const int               y=0,                      // Y coordinate 
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                 const string            text="Label",             // text 
                 const string            font="Arial",             // font 
                 const int               font_size=10,             // font size 
                 const color             clr=clrRed,               // color 
                 const double            angle=0.0,                // text slope 
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type 
                 const bool              back=false,               // in the background 
                 const bool              selection=false,          // highlight to move 
                 const bool              hidden=true,              // hidden in the object list 
                 const long              z_order=0,                // priority for mouse click 
                 const string            tooltip="\n",             // tooltip for mouse hover
                 const bool              tester=true)              // create object in the strategy tester
  {
//-- reset the error value 
   ResetLastError();
//-- CheckTester
   if(!tester && IsTesting())
      return(false);
//--
   if(ObjectFind(chart_ID,name)!=0)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
        {
         Print(__FUNCTION__,
               ": failed to create text label! Error code = ",_LastError);
         return(false);
        }
      //-- SetObjects
      ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
      ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
      ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);
     }
//--
   return(true);
  }
//+------------------------------------------------------------------+
//| Move the text label                                              |
//+------------------------------------------------------------------+
bool LabelMove(const long   chart_ID=0,   // chart's ID
               const string name="Label", // label name
               const int    x=0,          // X coordinate
               const int    y=0)          // Y coordinate
  {
//-- reset the error value
   ResetLastError();
//--
   if(ObjectFind(chart_ID,name)==0)
     {
      if(!ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x))
        {
         Print(__FUNCTION__,
               ": failed to move X coordinate of the label! Error code = ",_LastError);
         return(false);
        }
      if(!ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y))
        {
         Print(__FUNCTION__,
               ": failed to move Y coordinate of the label! Error code = ",_LastError);
         return(false);
        }
     }
//--
   return(true);
  }
//+------------------------------------------------------------------+
//| Create Edit object                                               |
//+------------------------------------------------------------------+
bool EditCreate(const long             chart_ID=0,               // chart's ID
                const string           name="Edit",              // object name
                const int              sub_window=0,             // subwindow index
                const int              x=0,                      // X coordinate
                const int              y=0,                      // Y coordinate
                const int              width=50,                 // width
                const int              height=18,                // height
                const string           text="Text",              // text
                const string           font="Arial",             // font
                const int              font_size=10,             // font size
                const ENUM_ALIGN_MODE  align=ALIGN_CENTER,       // alignment type
                const bool             read_only=false,          // ability to edit
                const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                const color            clr=clrBlack,             // text color
                const color            back_clr=clrWhite,        // background color
                const color            border_clr=clrNONE,       // border color
                const bool             back=false,               // in the background
                const bool             selection=false,          // highlight to move
                const bool             hidden=true,              // hidden in the object list
                const long             z_order=0,                // priority for mouse click 
                const string           tooltip="\n")             // tooltip for mouse hover
  {
//-- reset the error value
   ResetLastError();
//--
   if(ObjectFind(chart_ID,name)!=0)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0))
        {
         Print(__FUNCTION__,
               ": failed to create \"Edit\" object! Error code = ",_LastError);
         return(false);
        }
      //-- SetObjects
      ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align);
      ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,read_only);
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
      ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);
     }
//--
   return(true);
  }
//+------------------------------------------------------------------+
//| Move Edit object                                                 |
//+------------------------------------------------------------------+
bool EditMove(const long   chart_ID=0,  // chart's ID
              const string name="Edit", // object name
              const int    x=0,         // X coordinate
              const int    y=0)         // Y coordinate
  {

//-- reset the error value
   ResetLastError();
//--
   if(ObjectFind(chart_ID,name)==0)
     {
      if(!ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x))
        {
         Print(__FUNCTION__,
               ": failed to move X coordinate of the object! Error code = ",_LastError);
         return(false);
        }
      if(!ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y))
        {
         Print(__FUNCTION__,
               ": failed to move Y coordinate of the object! Error code = ",_LastError);
         return(false);
        }
     }
//--
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Creating Text object                                             | 
//+------------------------------------------------------------------+ 
bool TextCreate(const long              chart_ID=0,               // chart's ID 
                const string            name="Text",              // object name 
                const int               sub_window=0,             // subwindow index 
                datetime                time=0,                   // anchor point time 
                double                  price=0,                  // anchor point price 
                const string            text="Text",              // the text itself 
                const string            font="Arial",             // font 
                const int               font_size=10,             // font size 
                const color             clr=clrRed,               // color 
                const double            angle=0.0,                // text slope 
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type 
                const bool              back=false,               // in the background 
                const bool              selection=false,          // highlight to move 
                const bool              hidden=true,              // hidden in the object list 
                const long              z_order=0,                // priority for mouse click 
                const string            tooltip="\n")             // tooltip for mouse hover
  {
//-- reset the error value
   ResetLastError();
//--
   if(ObjectFind(chart_ID,name)!=0)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price))
        {
         Print(__FUNCTION__,
               ": failed to create \"Text\" object! Error code = ",_LastError);
         return(false);
        }
      //-- SetObjects
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
      ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
      ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);
     }
//--
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Create the arrow                                                 | 
//+------------------------------------------------------------------+ 
bool ArrowCreate(const long              chart_ID=0,           // chart's ID 
                 const string            name="Arrow",         // arrow name 
                 const int               sub_window=0,         // subwindow index 
                 datetime                time=0,               // anchor point time 
                 double                  price=0,              // anchor point price 
                 const uchar             arrow_code=252,       // arrow code 
                 const ENUM_ARROW_ANCHOR anchor=ANCHOR_BOTTOM, // anchor point position 
                 const color             clr=clrRed,           // arrow color 
                 const ENUM_LINE_STYLE   style=STYLE_SOLID,    // border line style 
                 const int               width=3,              // arrow size 
                 const bool              back=false,           // in the background 
                 const bool              selection=true,       // highlight to move 
                 const bool              hidden=true,          // hidden in the object list 
                 const long              z_order=0)            // priority for mouse click 
  {
//-- reset the error value
   ResetLastError();
//--
   if(ObjectFind(chart_ID,name)!=0)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_ARROW,sub_window,time,price))
        {
         Print(__FUNCTION__,
               ": failed to create an arrow! Error code = ",_LastError);
         return(false);
        }
      //-- SetObjects
      ObjectSetInteger(chart_ID,name,OBJPROP_ARROWCODE,arrow_code);
      ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
      ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
     }
//--
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Create a trend line by the given coordinates                     | 
//+------------------------------------------------------------------+ 
bool TrendCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="TrendLine",  // line name 
                 const int             sub_window=0,      // subwindow index 
                 datetime              time1=0,           // first point time 
                 double                price1=0,          // first point price 
                 datetime              time2=0,           // second point time 
                 double                price2=0,          // second point price 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=true,    // highlight to move 
                 const bool            ray_right=false,   // line's continuation to the right 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  {
//-- reset the error value
   ResetLastError();
//--
   if(ObjectFind(chart_ID,name)!=0)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2))
        {
         Print(__FUNCTION__,
               ": failed to create a trend line! Error code = ",_LastError);
         return(false);
        }
      //-- SetObjects
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
      ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
     }
//--
   return(true);
  }
//+------------------------------------------------------------------------------+ 
//| ChartEventMouseMoveSet                                                       | 
//+------------------------------------------------------------------------------+ 
bool ChartEventMouseMoveSet(const bool value)
  {
//-- reset the error value 
   ResetLastError();
//--
   if(!ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,0,value))
     {
      Print(__FUNCTION__,
            ", Error Code = ",_LastError);
      return(false);
     }
//--
   return(true);
  }
//+--------------------------------------------------------------------+ 
//| ChartMouseScrollSet                                                | 
//+--------------------------------------------------------------------+ 
bool ChartMouseScrollSet(const bool value)
  {
//-- reset the error value 
   ResetLastError();
//--
   if(!ChartSetInteger(0,CHART_MOUSE_SCROLL,0,value))
     {
      Print(__FUNCTION__,
            ", Error Code = ",_LastError);
      return(false);
     }
//--
   return(true);
  }
//+------------------------------------------------------------------+
//| ChartMiddleX                                                     |
//+------------------------------------------------------------------+
int ChartMiddleX()
  {
   return((int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS)/2);
  }
//+------------------------------------------------------------------+
//| ChartMiddleY                                                     |
//+------------------------------------------------------------------+
int ChartMiddleY()
  {
   return((int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)/2);
  }
//+------------------------------------------------------------------+
//| RandomColor                                                      |
//+------------------------------------------------------------------+
color RandomColor()
  {
//--
   int p1=0+255*MathRand()/32768;
   int p2=0+255*MathRand()/32768;
   int p3=0+255*MathRand()/32768;
//--
   return(StringToColor(IntegerToString(p1)+","+IntegerToString(p2)+","+IntegerToString(p3)));
  }
//+------------------------------------------------------------------+ 
//| PlaySound                                                        | 
//+------------------------------------------------------------------+ 
void _PlaySound(const string FileName)
  {
   if(SoundIsEnabled)
      PlaySound(FileName);
  }
//+------------------------------------------------------------------+
//| AccountCurrency                                                  |
//+------------------------------------------------------------------+
string _AccountCurrency()
  {
//--
   string txt="";
   if(AccountCurrency()=="AUD")txt="$";
   if(AccountCurrency()=="CAD")txt="$";
   if(AccountCurrency()=="CHF")txt="Fr.";
   if(AccountCurrency()=="EUR")txt="€";
   if(AccountCurrency()=="GBP")txt="£";
   if(AccountCurrency()=="JPY")txt="¥";
   if(AccountCurrency()=="NZD")txt="$";
   if(AccountCurrency()=="USD")txt="$";
   if(txt=="")txt="$";
   return(txt);
//--
  }
//+------------------------------------------------------------------+ 
//| End of the code                                                  | 
//+------------------------------------------------------------------+ 
