//============================================================================================================================================================================================================================//
//Start code
//============================================================================================================================================================================================================================//
#property copyright   "Copyright 2023, Nikolaos Pantzos"
#property link        "https://www.mql5.com/en/users/pannik"
#property version     "1.2"
#property description "\nExpert uses some indicators to generate signals."
//#property icon        "\\Images\\MultiStragegyEA-Logo.ico";
#property strict
//============================================================================================================================================================================================================================//
#define MagicSet 333777
//============================================================================================================================================================================================================================//
enum Oper   {Stand_by_Mode, Normal_Operation, Close_Immediately_All_Orders};
enum Grid   {Not_Make_Grid, Make_Grid_In_Loss, Make_Grid_In_Profit, Make_Grid_Loss_And_Profit};
enum Levels {Use_Only_Hard_Levels, Use_Only_Virtual_Levels, Use_Hard_And_Virtual_Levels};
enum LotPr  {Statical_Lot, Geometrical_Lot, Exponetial_Lot};
enum Recov  {Not_Use_Recovery, Use_Last_Closing, Use_Higher_Profits};
enum Pair   {CHART_PAIR, TRADE_EURGBP_1, TRADE_EURAUD_2, TRADE_EURNZD_3, TRADE_EURUSD_4, TRADE_EURCAD_5, TRADE_EURCHF_6, TRADE_EURJPY_7,
             TRADE_GBPAUD_8, TRADE_GBPNZD_9, TRADE_GBPUSD_10, TRADE_GBPCAD_11, TRADE_GBPCHF_12, TRADE_GBPJPY_13, TRADE_AUDNZD_14,
             TRADE_AUDUSD_15, TRADE_AUDCAD_16, TRADE_AUDCHF_17, TRADE_AUDJPY_18, TRADE_NZDUSD_19, TRADE_NZDCAD_20, TRADE_NZDCHF_21,
             TRADE_NZDJPY_22, TRADE_USDCAD_23, TRADE_USDCHF_24, TRADE_USDJPY_25, TRADE_CADCHF_26, TRADE_CADJPY_27, TRADE_CHFJPY_28
            };
//============================================================================================================================================================================================================================//
//Comon parameters
//============================================================================================================================================================================================================================//
input string OperationStr           = "||========== Operation Parameters ==========||";
input Oper   TypeOperation          = Normal_Operation;//Type Of Operation
input string ChartRunParameters     = "||========== Chart Run Parameters ==========||";
input bool   SetChartUses           = true;//Set Automatically Chart To Use
input Pair   PairToTrade            = TRADE_EURUSD_4;//Symbol Expert Trade
input string SignalsParameters      = "||========== General Signals Parameters ==========||";
input ENUM_TIMEFRAMES TimeFrame     = PERIOD_H1;//Period Of Bars
input bool   CloseInReverse         = true;//Close Orders In Reverse Signal
input bool   TradeAllStrategies     = true;//Trade All Strategikes Together
//============================================================================================================================================================================================================================//
//AC_Parameters
//============================================================================================================================================================================================================================//
input string AC_StrategyParameter   = "||========== AC Strategy Parameter ==========||";
input bool   AC_StrategyRun         = true;//AC Strategy Run
input string AC_SignalParameter     = "  AC Signal Parameters  ";
input int    AC_OpenOrdersType      = 5;//AC Type Of Open Orders (0=Not Use)(from 1 to 8)
input double AC_LevelOpenOrders     = 80.0;//AC Level Open Orders
input bool   AC_CloseInSignals      = true;//AC Close Orders With Signals
input int    AC_CloseOrdersType     = 1;//AC Type Of Close Orders (0=Not Use)(from 1 to 8)
input double AC_LevelCloseOrders    = 70.0;//AC Level Close Orders
input string AC_OrdersParameter     = "---------- AC Orders Parameters ---------- ";
input Levels AC_TypeOfLevelsUse     = Use_Only_Virtual_Levels;//AC Type Of Levels Use To Close Orders
input double AC_TakeProfit          = 95.0;//AC Pips Take Profit (0=Not Use)
input double AC_StopLoss            = 85.0;//AC Pips Stop Loss (0=Not Use)
input string AC_Money_Management    = "---------- AC Money Management Parameters ---------- ";
input bool   AC_AutoLotSize         = true;//AC Auto Money Management
input double AC_RiskFactor          = 1.0;//AC Risk Money Management
input double AC_ManualLotSize       = 0.10;//AC Manual Lot Size
input string AC_RecoveryLotSets     = "---------- AC Recovery Lots Parameters ---------- ";
input Recov  AC_UseRecoveryLot      = Not_Use_Recovery;//AC Use Recovery Lot Size After Losses
input double AC_MultiRecoveryLot    = 2.0;//AC Multiplier For Recovery Lot Size
//============================================================================================================================================================================================================================//
//ADX_Parameters
//============================================================================================================================================================================================================================//
input string ADX_StrategyParameter  = "||========== ADX Strategy Parameter ==========||";
input bool   ADX_StrategyRun        = true;//ADX Strategy Run
input string ADX_IndicatorsSet      = "  ADX Indicators Parameters  ";
input int    ADX_BarsCalculate      = 20;//ADX Bars Calculate Signals
input string ADX_SignalParameter    = "  ADX Signal Parameters  ";
input int    ADX_OpenOrdersType     = 2;//ADX Type Of Open Orders (0=Not Use)(from 1 to 4)
input double ADX_LevelOpenOrders_1  = 55.0;//ADX Level Open Orders 1
input double ADX_LevelOpenOrders_2  = 15.0;//ADX Level Open Orders 2
input bool   ADX_CloseInSignals     = true;//ADX Close Orders With Signals
input int    ADX_CloseOrdersType    = 4;//ADX Type Of Close Orders (0=Not Use)(from 1 to 4)
input double ADX_LevelCloseOrders_1 = 15.0;//ADX Level Close Orders 1
input double ADX_LevelCloseOrders_2 = 5.0;//ADX Level Close Orders 2
input string ADX_OrdersParameter    = "  ADX Orders Parameters   ";
input Levels ADX_TypeOfLevelsUse    = Use_Only_Virtual_Levels;//ADX Type Of Levels Use To Close Orders
input double ADX_TakeProfit         = 35.0;//ADX Pips Take Profit (0=Not Use)
input double ADX_StopLoss           = 70.0;//ADX Pips Stop Loss (0=Not Use)
input string ADX_Money_Management   = "  ADX Money Management Parameters   ";
input bool   ADX_AutoLotSize        = true;//ADX Auto Money Management
input double ADX_RiskFactor         = 1.0;//ADX Risk Money Management
input double ADX_ManualLotSize      = 0.10;//ADX Manual Lot Size
input string ADX_RecoveryLotSets    = "  ADX Recovery Lots Parameters   ";
input Recov  ADX_UseRecoveryLot     = Not_Use_Recovery;//ADX Use Recovery Lot Size After Losses
input double ADX_MultiRecoveryLot   = 2.0;//ADX Multiplier For Recovery Lot Size
//============================================================================================================================================================================================================================//
//AO_Parameters
//============================================================================================================================================================================================================================//
input string AO_StrategyParameter   = "||========== AO Strategy Parameter ==========||";
input bool   AO_StrategyRun         = true;//AO Strategy Run
input string AO_SignalParameter     = "  AO Signal Parameters  ";
input int    AO_OpenOrdersType      = 6;//AO Type Of Open Orders (0=Not Use)(from 1 to 8)
input double AO_LevelOpenOrders     = 55.0;//AO Level Open Orders
input bool   AO_CloseInSignals      = true;//AO Close Orders Via Signals
input int    AO_CloseOrdersType     = 8;//AO Type Of Close Orders (0=Not Use)(from 1 to 8)
input double AO_LevelCloseOrders    = 40.0;//AO Level Close Orders
input string AO_OrdersParameter     = "  AO Orders Parameters   ";
input Levels AO_TypeOfLevelsUse     = Use_Only_Virtual_Levels;//AO Type Of Levels Use To Close Orders
input double AO_TakeProfit          = 10.0;//AO Pips Take Profit (0=Not Use)
input double AO_StopLoss            = 80.0;//AO Pips Stop Loss (0=Not Use)
input string AO_Money_Management    = "  AO Money Management Parameters   ";
input bool   AO_AutoLotSize         = true;//AO Auto Money Management
input double AO_RiskFactor          = 1.0;//AO Risk Money Management
input double AO_ManualLotSize       = 0.10;//AO Manual Lot Size
input string AO_RecoveryLotSets     = "  AO Recovery Lots Parameters   ";
input Recov  AO_UseRecoveryLot      = Not_Use_Recovery;//AO Use Recovery Lot Size After Losses
input double AO_MultiRecoveryLot    = 2.0;//AO Multiplier For Recovery Lot Size
//============================================================================================================================================================================================================================//
//DeM_Parameters
//============================================================================================================================================================================================================================//
input string DeM_StrategyParameter  = "||========== DeM Strategy Parameter ==========||";
input bool   DeM_StrategyRun        = true;//DeM Strategy Run
input string DeM_IndicatorsSet      = "  DeM Indicators Parameters  ";
input int    DeM_BarsCalculate      = 20;//DeM_ Bars Calculate Signals
input string DeM_SignalParameter    = "  DeM Signal Parameters  ";
input int    DeM_OpenOrdersType     = 3;//DeM Type Of Open Orders (0=Not Use)(from 1 to 4)
input double DeM_LevelOpenOrders    = 75.0;//DeM Level Open Orders
input bool   DeM_CloseInSignals     = true;//DeM Close Orders Via Signals
input int    DeM_CloseOrdersType    = 4;//DeM Type Of Close Orders (0=Not Use)(from 1 to 4)
input double DeM_LevelCloseOrders   = 70.0;//DeM Level Close Orders
input string DeM_OrdersParameter    = "  DeM Orders Parameters   ";
input Levels DeM_TypeOfLevelsUse    = Use_Only_Virtual_Levels;//DeM Type Of Levels Use To Close Orders
input double DeM_TakeProfit         = 5.0;//DeM Pips Take Profit (0=Not Use)
input double DeM_StopLoss           = 60.0;//DeM Pips Stop Loss (0=Not Use)
input string DeM_Money_Management   = "  DeM Money Management Parameters   ";
input bool   DeM_AutoLotSize        = true;//DeM Auto Money Management
input double DeM_RiskFactor         = 1.0;//DeM Risk Money Management
input double DeM_ManualLotSize      = 0.10;//DeM Manual Lot Size
input string DeM_RecoveryLotSets    = "  DeM Recovery Lots Parameters   ";
input Recov  DeM_UseRecoveryLot     = Not_Use_Recovery;//DeM Use Recovery Lot Size After Losses
input double DeM_MultiRecoveryLot   = 2.0;//DeM Multiplier For Recovery Lot Size
//============================================================================================================================================================================================================================//
//FBB_Parameters
//============================================================================================================================================================================================================================//
input string FBB_StrategyParameter  = "||========== FBB Strategy Parameter ==========||";
input bool   FBB_StrategyRun        = true;//FBB Strategy Run
input string FBB_IndicatorsSet      = "  FBB Indicators Parameters  ";
input int    FBB_BarsCalculate      = 20;//FBB Bars Calculate Signals
input double FBB_Deviation          = 1.8;//FBB Bands Deviation
input string FBB_SignalParameter    = "  FBB Signal Parameters  ";
input int    FBB_OpenOrdersType_1   = 1;//FBB Type Of Open Orders 1 (0=Not Use)(from 1 to 2)
input int    FBB_OpenOrdersType_2   = 8;//FBB Type Of Open Orders 2 (0=Not Use)(from 1 to 8)
input double FBB_LevelOpenOrders_1  = 0.0;//FBB Level Open Orders 1 (0=Not Use)(Positive and Negative)
input double FBB_LevelOpenOrders_2  = 50.0;//FBB Level Open Orders 2
input bool   FBB_CloseInSignals     = false;//FBB Close Orders Via Signals
input int    FBB_CloseOrdersType_1  = 1;//FBB Type Of Close Orders 1 (0=Not Use)(from 1 to 2)
input int    FBB_CloseOrdersType_2  = 4;//FBB Type Of Close Orders 2 (0=Not Use)(from 1 to 8)
input double FBB_LevelCloseOrders_1 = 40.0;//FBB Level Close Orders 1 (0=Not Use)(Positive and Negative)
input double FBB_LevelCloseOrders_2 = 40.0;//FBB Level Close Orders 2
input string FBB_OrdersParameter    = "  FBB Orders Parameters   ";
input Levels FBB_TypeOfLevelsUse    = Use_Only_Virtual_Levels;//FBB Type Of Levels Use To Close Orders
input double FBB_TakeProfit         = 5.0;//FBB Pips Take Profit (0=Not Use)
input double FBB_StopLoss           = 15.0;//FBB Pips Stop Loss (0=Not Use)
input string FBB_Money_Management   = "  FBB Money Management Parameters   ";
input bool   FBB_AutoLotSize        = true;//FBB Auto Money Management
input double FBB_RiskFactor         = 1.0;//FBB Risk Money Management
input double FBB_ManualLotSize      = 0.10;//FBB Manual Lot Size
input string FBB_RecoveryLotSets    = "  FBB Recovery Lots Parameters   ";
input Recov  FBB_UseRecoveryLot     = Not_Use_Recovery;//FBB Use Recovery Lot Size After Losses
input double FBB_MultiRecoveryLot   = 2.0;//FBB Multiplier For Recovery Lot Size
//============================================================================================================================================================================================================================//
//MFI_Parameters
//============================================================================================================================================================================================================================//
input string MFI_StrategyParameter  = "||========== MFI Strategy Parameter ==========||";
input bool   MFI_StrategyRun        = true;//MFI Strategy Run
input string MFI_IndicatorsSet      = "  MFI Indicators Parameters  ";
input int    MFI_BarsCalculate      = 12;//MFI_ Bars Calculate Signals
input string MFI_SignalParameter    = "  MFI Signal Parameters  ";
input int    MFI_OpenOrdersType     = 3;//MFI Type Of Open Orders (0=Not Use)(from 1 to 4)
input double MFI_LevelOpenOrders    = 90.0;//MFI Level Open Orders
input bool   MFI_CloseInSignals     = true;//MFI Close Orders Via Signals
input int    MFI_CloseOrdersType    = 4;//MFI Type Of Close Orders (0=Not Use)(from 1 to 4)
input double MFI_LevelCloseOrders   = 90.0;//MFI Level Close Orders
input string MFI_OrdersParameter    = "  MFI Orders Parameters   ";
input Levels MFI_TypeOfLevelsUse    = Use_Only_Virtual_Levels;//MFI Type Of Levels Use To Close Orders
input double MFI_TakeProfit         = 50.0;//MFI Pips Take Profit (0=Not Use)
input double MFI_StopLoss           = 25.0;//MFI Pips Stop Loss (0=Not Use)
input string MFI_Money_Management   = "  MFI Money Management Parameters   ";
input bool   MFI_AutoLotSize        = true;//MFI Auto Money Management
input double MFI_RiskFactor         = 1.0;//MFI Risk Money Management
input double MFI_ManualLotSize      = 0.10;//MFI Manual Lot Size
input string MFI_RecoveryLotSets    = "  MFI Recovery Lots Parameters   ";
input Recov  MFI_UseRecoveryLot     = Not_Use_Recovery;//MFI Use Recovery Lot Size After Losses
input double MFI_MultiRecoveryLot   = 2.0;//MFI Multiplier For Recovery Lot Size
//============================================================================================================================================================================================================================//
//MS_Parameters
//============================================================================================================================================================================================================================//
input string MS_StrategyParameter  = "||========== MS Strategy Parameter ==========||";
input bool   MS_StrategyRun        = true;//MS Strategy Run
input string MS_IndicatorsSet      = "  MS Indicators Parameters  ";
input int    MS_Fast_EMA_Period    = 3;//MS MACD Fast EMA Period
input int    MS_Slow_EMA_Period    = 9;//MS MACD Slow EMA Period
input int    MS_Signal_Period      = 2;//MS MACD Signal Period
input int    MS_K_Period           = 5;//MS STOCH K Period
input int    MS_D_Period           = 3;//MS STOCH  D Period
input int    MS_Slowing_Period     = 12;//MS STOCH Slowing Period
input string MS_SignalParameter    = "  MS Signal Parameters  ";
input int    MS_OpenOrdersType_1   = 8;//MS Type Of Open Orders 1 (0=Not Use)(from 1 to 11)
input int    MS_OpenOrdersType_2   = 22;//MS Type Of Open Orders 2 (0=Not Use)(from 1 to 28)
input double MS_LevelOpenOrders_1  = 60.0;//MS Level Open Orders 1
input double MS_LevelOpenOrders_2  = 80.0;//MS Level Open Orders 2
input bool   MS_CloseInSignals     = true;//MS Close Orders Via Signals
input int    MS_CloseOrdersType_1  = 9;//MS Type Of Close Orders 1 (0=Not Use)(from 1 to 11)
input int    MS_CloseOrdersType_2  = 10;//MS Type Of Close Orders 2 (0=Not Use)(from 1 to 28)
input double MS_LevelCloseOrders_1 = 50.0;//MS Level Close Orders 1
input double MS_LevelCloseOrders_2 = 65.0;//MS Level Close Orders 2
input string MS_OrdersParameter    = "  MS Orders Parameters   ";
input Levels MS_TypeOfLevelsUse    = Use_Only_Virtual_Levels;//MS Type Of Levels Use To Close Orders
input double MS_TakeProfit         = 10.0;//MS Pips Take Profit (0=Not Use)
input double MS_StopLoss           = 45.0;//MS Pips Stop Loss (0=Not Use)
input string MS_Money_Management   = "  MS Money Management Parameters   ";
input bool   MS_AutoLotSize        = true;//MS Auto Money Management
input double MS_RiskFactor         = 1.0;//MS Risk Money Management
input double MS_ManualLotSize      = 0.10;//MS Manual Lot Size
input string MS_RecoveryLotSets    = "  MS Recovery Lots Parameters   ";
input Recov  MS_UseRecoveryLot     = Not_Use_Recovery;//MS Use Recovery Lot Size After Losses
input double MS_MultiRecoveryLot   = 2.0;//MS Multiplier For Recovery Lot Size
//============================================================================================================================================================================================================================//
//Comon parameters
//============================================================================================================================================================================================================================//
input string OrdersManagement      = "||========== Orders Grid Parameters ==========||";
input Grid   MakeOrdersGrid        = Make_Grid_Loss_And_Profit;//Make Grid Of Orders
input double PipsBetweenOrders     = 0.0;//Pips Between Orders
input ulong  TimeBetweenOrders     = 60;//Seconds Between Orders
input string ControlSessionSet     = "||========== Control Session Parameters ==========||";
input bool   ControlSession        = true;//Use Trade Control Session
input int    WaitAfterOpen         = 60;//Wait After Monday Open
input int    StopBeforeClose       = 60;//Stop Before Friday Close
input string InformationSets       = "||========== Information On Cahrt Parameters ==========||";
input bool   ShowComments          = true;//Show Comments On Chart
input color  ColorOffLines         = clrGray;//Color Off Lines
input color  ColorExpertName       = clrDodgerBlue;//Color Expert Name
input color  ColorSpreadInfo       = clrLightSkyBlue;//Color Spread Information
input color  ColorMoneyMngmnt      = clrLightBlue;//Color Money Management
input color  ColorCurrentOrders    = clrPaleTurquoise;//Color Current Orders
input color  ColorHistoryOrders    = clrLightCyan;//Color History Orders
input string GeneralSets           = "||========== General Expert Parameters ==========||";
input double MaxSpread             = 0.0;//Max Accepted Spread (0=Not Limit)
input int    MaxOrders             = 0;//Max Opened Orders (0=No Limit)
input int    Slippage              = 3;//Accepted Slippage
input bool   SoundAlert            = false;//Play Sound Alerts
input bool   PrintOperations       = false;//Print Information Log
input int    MagicNumber           = 0;//Orders' ID (0=Generate Automatically)
input string CommentsOrders        = "MultiStrategyEA";//Orders' Comment
//============================================================================================================================================================================================================================//
string SoundAtClose="alert2.wav";
string SoundAtOpen="alert.wav";
string SoundAtModify="tick.wav";
string SymbolSuffix="";
string ExpertName;
string SymbolTrade;
string BackgroundName;
string PairTrade="";
//----------------------------------------------
int i;
int cnt;
int CountTimes;
int SignalsMessageWarning;
int LastHistoryOrders=0;
int WarningMessage;
int MultiplierPoint;
int SumOrders;
int AcceptMaxOrders=0;
int MaxTotalOrders=0;
int SymbolDigits;
int TypeOfPair;
int ExpertNameLen;
//----------------------------------------------
double SymbolPoints;
double StopLevel;
double Spread;
double Floating;
//----------------------------------------------
bool AcceptedSpread;
bool TimeToTrade;
bool MarketIsOpen;
//----------------------------------------------
color ChartColor;
//----------------------------------------------
datetime TimeBegin;
datetime TimeEnd;
datetime LastTimeRunFunctions=0;
datetime LastDateCheckExpiry=0;
//============================================================================================================================================================================================================================//
//AC_Variables
//============================================================================================================================================================================================================================//
double AC_TotalHistoryProfitLoss;
double AC_PriceOpenLastBuy;
double AC_PriceOpenLastSell;
double AC_FloatingBuy;
double AC_FloatingSell;
double AC_TotalLotsBuy;
double AC_TotalLotsSell;
double AC_LotFirstBuy;
double AC_LotFirstSell;
double AC_PriceOpenHigherBuy;
double AC_PriceOpenLowerBuy;
double AC_PriceOpenHigherSell;
double AC_PriceOpenLowerSell;
double AC_PipsStopLoss;
double AC_PipsTakeProfit;
double AC_PipsBuyOrders;
double AC_PipsSellOrders;
double AC_HigherHistoryProfits=0;
double AC_LastHistoryOrderPnL=0;
//----------------------------------------------
int AC_OrdersID;
int AC_TotalHistoryOrders;
int AC_SumOrders;
int AC_BuyOrders;
int AC_SellOrders;
int AC_TypeOfLastOrder;
//----------------------------------------------
long AC_TicketFirstBuy;
long AC_TicketFirstSell;
//----------------------------------------------
ulong AC_TimeOpenLastBuy=0;
ulong AC_TimeOpenLastSell=0;
//----------------------------------------------
bool AC_OpenBuy=false;
bool AC_OpenSell=false;
bool AC_CloseBuy=false;
bool AC_CloseSell=false;
//----------------------------------------------
int AC=INVALID_HANDLE;
//============================================================================================================================================================================================================================//
//ADX_Variables
//============================================================================================================================================================================================================================//
double ADX_TotalHistoryProfitLoss;
double ADX_PriceOpenLastBuy;
double ADX_PriceOpenLastSell;
double ADX_FloatingBuy;
double ADX_FloatingSell;
double ADX_TotalLotsBuy;
double ADX_TotalLotsSell;
double ADX_LotFirstBuy;
double ADX_LotFirstSell;
double ADX_PriceOpenHigherBuy;
double ADX_PriceOpenLowerBuy;
double ADX_PriceOpenHigherSell;
double ADX_PriceOpenLowerSell;
double ADX_PipsStopLoss;
double ADX_PipsTakeProfit;
double ADX_PipsBuyOrders;
double ADX_PipsSellOrders;
double ADX_HigherHistoryProfits=0;
double ADX_LastHistoryOrderPnL=0;
//----------------------------------------------
int ADX_OrdersID;
int ADX_TotalHistoryOrders;
int ADX_SumOrders;
int ADX_BuyOrders;
int ADX_SellOrders;
int ADX_TypeOfLastOrder;
//----------------------------------------------
long ADX_TicketFirstBuy;
long ADX_TicketFirstSell;
//----------------------------------------------
ulong ADX_TimeOpenLastBuy=0;
ulong ADX_TimeOpenLastSell=0;
//----------------------------------------------
bool ADX_OpenBuy=false;
bool ADX_OpenSell=false;
bool ADX_CloseBuy=false;
bool ADX_CloseSell=false;
//----------------------------------------------
int ADX=INVALID_HANDLE;
//============================================================================================================================================================================================================================//
//AO_Variables
//============================================================================================================================================================================================================================//
double AO_TotalHistoryProfitLoss;
double AO_PriceOpenLastBuy;
double AO_PriceOpenLastSell;
double AO_FloatingBuy;
double AO_FloatingSell;
double AO_TotalLotsBuy;
double AO_TotalLotsSell;
double AO_LotFirstBuy;
double AO_LotFirstSell;
double AO_PriceOpenHigherBuy;
double AO_PriceOpenLowerBuy;
double AO_PriceOpenHigherSell;
double AO_PriceOpenLowerSell;
double AO_PipsStopLoss;
double AO_PipsTakeProfit;
double AO_PipsBuyOrders;
double AO_PipsSellOrders;
double AO_HigherHistoryProfits=0;
double AO_LastHistoryOrderPnL=0;
//----------------------------------------------
int AO_OrdersID;
int AO_TotalHistoryOrders;
int AO_SumOrders;
int AO_BuyOrders;
int AO_SellOrders;
int AO_TypeOfLastOrder;
//----------------------------------------------
long AO_TicketFirstBuy;
long AO_TicketFirstSell;
//----------------------------------------------
ulong AO_TimeOpenLastBuy=0;
ulong AO_TimeOpenLastSell=0;
//----------------------------------------------
bool AO_OpenBuy=false;
bool AO_OpenSell=false;
bool AO_CloseBuy=false;
bool AO_CloseSell=false;
//----------------------------------------------
int AO=INVALID_HANDLE;
//============================================================================================================================================================================================================================//
//DeM_Variables
//============================================================================================================================================================================================================================//
double DeM_TotalHistoryProfitLoss;
double DeM_PriceOpenLastBuy;
double DeM_PriceOpenLastSell;
double DeM_FloatingBuy;
double DeM_FloatingSell;
double DeM_TotalLotsBuy;
double DeM_TotalLotsSell;
double DeM_LotFirstBuy;
double DeM_LotFirstSell;
double DeM_PriceOpenHigherBuy;
double DeM_PriceOpenLowerBuy;
double DeM_PriceOpenHigherSell;
double DeM_PriceOpenLowerSell;
double DeM_PipsStopLoss;
double DeM_PipsTakeProfit;
double DeM_PipsBuyOrders;
double DeM_PipsSellOrders;
double DeM_HigherHistoryProfits=0;
double DeM_LastHistoryOrderPnL=0;
//----------------------------------------------
int DeM_OrdersID;
int DeM_TotalHistoryOrders;
int DeM_SumOrders;
int DeM_BuyOrders;
int DeM_SellOrders;
int DeM_TypeOfLastOrder;
//----------------------------------------------
long DeM_TicketFirstBuy;
long DeM_TicketFirstSell;
//----------------------------------------------
ulong DeM_TimeOpenLastBuy=0;
ulong DeM_TimeOpenLastSell=0;
//----------------------------------------------
bool DeM_OpenBuy=false;
bool DeM_OpenSell=false;
bool DeM_CloseBuy=false;
bool DeM_CloseSell=false;
//----------------------------------------------
int DeMarker=INVALID_HANDLE;
//============================================================================================================================================================================================================================//
//FBB_Variables
//============================================================================================================================================================================================================================//
double FBB_TotalHistoryProfitLoss;
double FBB_PriceOpenLastBuy;
double FBB_PriceOpenLastSell;
double FBB_FloatingBuy;
double FBB_FloatingSell;
double FBB_TotalLotsBuy;
double FBB_TotalLotsSell;
double FBB_LotFirstBuy;
double FBB_LotFirstSell;
double FBB_PriceOpenHigherBuy;
double FBB_PriceOpenLowerBuy;
double FBB_PriceOpenHigherSell;
double FBB_PriceOpenLowerSell;
double FBB_PipsStopLoss;
double FBB_PipsTakeProfit;
double FBB_PipsBuyOrders;
double FBB_PipsSellOrders;
double FBB_HigherHistoryProfits=0;
double FBB_LastHistoryOrderPnL=0;
//----------------------------------------------
int FBB_OrdersID;
int FBB_TotalHistoryOrders;
int FBB_SumOrders;
int FBB_BuyOrders;
int FBB_SellOrders;
int FBB_TypeOfLastOrder;
//----------------------------------------------
long FBB_TicketFirstBuy;
long FBB_TicketFirstSell;
//----------------------------------------------
ulong FBB_TimeOpenLastBuy=0;
ulong FBB_TimeOpenLastSell=0;
//----------------------------------------------
bool FBB_OpenBuy=false;
bool FBB_OpenSell=false;
bool FBB_CloseBuy=false;
bool FBB_CloseSell=false;
//----------------------------------------------
int BollingerBands=INVALID_HANDLE;
int Force=INVALID_HANDLE;
//============================================================================================================================================================================================================================//
//MFI_Variables
//============================================================================================================================================================================================================================//
double MFI_TotalHistoryProfitLoss;
double MFI_PriceOpenLastBuy;
double MFI_PriceOpenLastSell;
double MFI_FloatingBuy;
double MFI_FloatingSell;
double MFI_TotalLotsBuy;
double MFI_TotalLotsSell;
double MFI_LotFirstBuy;
double MFI_LotFirstSell;
double MFI_PriceOpenHigherBuy;
double MFI_PriceOpenLowerBuy;
double MFI_PriceOpenHigherSell;
double MFI_PriceOpenLowerSell;
double MFI_PipsStopLoss;
double MFI_PipsTakeProfit;
double MFI_PipsBuyOrders;
double MFI_PipsSellOrders;
double MFI_HigherHistoryProfits=0;
double MFI_LastHistoryOrderPnL=0;
//----------------------------------------------
int MFI_OrdersID;
int MFI_TotalHistoryOrders;
int MFI_SumOrders;
int MFI_BuyOrders;
int MFI_SellOrders;
int MFI_TypeOfLastOrder;
//----------------------------------------------
long MFI_TicketFirstBuy;
long MFI_TicketFirstSell;
//----------------------------------------------
ulong MFI_TimeOpenLastBuy=0;
ulong MFI_TimeOpenLastSell=0;
//----------------------------------------------
bool MFI_OpenBuy=false;
bool MFI_OpenSell=false;
bool MFI_CloseBuy=false;
bool MFI_CloseSell=false;
//----------------------------------------------
int MFI=INVALID_HANDLE;
//============================================================================================================================================================================================================================//
//MS_Variables
//============================================================================================================================================================================================================================//
double MS_TotalHistoryProfitLoss;
double MS_PriceOpenLastBuy;
double MS_PriceOpenLastSell;
double MS_FloatingBuy;
double MS_FloatingSell;
double MS_TotalLotsBuy;
double MS_TotalLotsSell;
double MS_LotFirstBuy;
double MS_LotFirstSell;
double MS_PriceOpenHigherBuy;
double MS_PriceOpenLowerBuy;
double MS_PriceOpenHigherSell;
double MS_PriceOpenLowerSell;
double MS_PipsStopLoss;
double MS_PipsTakeProfit;
double MS_PipsBuyOrders;
double MS_PipsSellOrders;
double MS_HigherHistoryProfits=0;
double MS_LastHistoryOrderPnL=0;
//----------------------------------------------
int MS_OrdersID;
int MS_TotalHistoryOrders;
int MS_SumOrders;
int MS_BuyOrders;
int MS_SellOrders;
int MS_TypeOfLastOrder;
//----------------------------------------------
long MS_TicketFirstBuy;
long MS_TicketFirstSell;
//----------------------------------------------
ulong MS_TimeOpenLastBuy=0;
ulong MS_TimeOpenLastSell=0;
//----------------------------------------------
bool MS_OpenBuy=false;
bool MS_OpenSell=false;
bool MS_CloseBuy=false;
bool MS_CloseSell=false;
//----------------------------------------------
int MACD=INVALID_HANDLE;
int STOCH=INVALID_HANDLE;
//============================================================================================================================================================================================================================//
//OnInit function
//============================================================================================================================================================================================================================//
int OnInit()
  {
//---------------------------------------------------------------------
//AC_Check parameters
   if(AC_OpenOrdersType>8)
     {
      Print("Invalid 'AC_OpenOrdersType' value. The maximum accepted value is 8.");
      return(INIT_FAILED);
     }
//---
   if(AC_OpenOrdersType<0)
     {
      PrintFormat("Invalid AC_OpenOrdersType input value: %d",AC_OpenOrdersType);
      return(INIT_FAILED);
     }
//---------------------------------------------------------------------
   if(AC_CloseInSignals==true)
     {
      if(AC_CloseOrdersType>8)
        {
         Print("Invalid 'AC_CloseOrdersType' value. The maximum accepted value is 8.");
         return(INIT_FAILED);
        }
      //---
      if(AC_CloseOrdersType<0)
        {
         PrintFormat("Invalid AC_CloseOrdersType input value: %d",AC_CloseOrdersType);
         return(INIT_FAILED);
        }
     }
//---------------------------------------------------------------------
   if(AC_CloseInSignals==true)
     {
      if(AC_OpenOrdersType==AC_CloseOrdersType)
        {
         Print("Invalid 'AC_CloseOrdersType' and 'AC_OpenOrdersType'. Must be not equal.");
         return(INIT_FAILED);
        }
     }
//---------------------------------------------------------------------
   if((AC_RiskFactor<0.01)||(AC_RiskFactor>100))
     {
      PrintFormat("Invalid AC_RiskFactor input value (between 0.01 and 100): %d",AC_RiskFactor);
      return(INIT_FAILED);
     }
//---------------------------------------------------------------------
   if(AC_StopLoss<0)
     {
      PrintFormat("Invalid AC_StopLoss input value (greater or equal than 0): %d",AC_StopLoss);
      return(INIT_FAILED);
     }
//---
   if(AC_TakeProfit<0)
     {
      PrintFormat("Invalid AC_TakeProfit input value (greater or equal than 0): %d",AC_TakeProfit);
      return(INIT_FAILED);
     }
//---------------------------------------------------------------------
//ADX_Check parameters
   if(ADX_OpenOrdersType>4)
     {
      Print("Invalid 'ADX_OpenOrdersType' value. The maximum accepted value is 4.");
      return(INIT_FAILED);
     }
//---
   if(ADX_OpenOrdersType<0)
     {
      PrintFormat("Invalid ADX_OpenOrdersType input value: %d",ADX_OpenOrdersType);
      return(INIT_FAILED);
     }
//---------------------------------------------------------------------
   if(ADX_CloseInSignals==true)
     {
      if(ADX_CloseOrdersType>4)
        {
         Print("Invalid 'ADX_CloseOrdersType' value. The maximum accepted value is 4.");
         return(INIT_FAILED);
        }
      //---
      if(ADX_CloseOrdersType<0)
        {
         PrintFormat("Invalid ADX_CloseOrdersType input value: %d",ADX_CloseOrdersType);
         return(INIT_FAILED);
        }
     }
//---------------------------------------------------------------------
   if((ADX_RiskFactor<0.01)||(ADX_RiskFactor>100))
     {
      PrintFormat("Invalid ADX_RiskFactor input value (between 0.01 and 100): %d",ADX_RiskFactor);
      return(INIT_FAILED);
     }
//---------------------------------------------------------------------
   if(ADX_StopLoss<0)
     {
      PrintFormat("Invalid ADX_StopLoss input value (greater or equal than 0): %d",ADX_StopLoss);
      return(INIT_FAILED);
     }
//---
   if(ADX_TakeProfit<0)
     {
      PrintFormat("Invalid ADX_TakeProfit input value (greater or equal than 0): %d",ADX_TakeProfit);
      return(INIT_FAILED);
     }
//---------------------------------------------------------------------
//AO_Check parameters
   if(AO_OpenOrdersType>8)
     {
      Print("Invalid 'AO_OpenOrdersType' value. The maximum accepted value is 8.");
      return(INIT_FAILED);
     }
//---
   if(AO_OpenOrdersType<0)
     {
      PrintFormat("Invalid AO_OpenOrdersType input value: %d",AO_OpenOrdersType);
      return(INIT_FAILED);
     }
//---------------------------------------------------------------------
   if(AO_CloseInSignals==true)
     {
      if(AO_CloseOrdersType>8)
        {
         Print("Invalid 'AO_CloseOrdersType' value. The maximum accepted value is 8.");
         return(INIT_FAILED);
        }
      //---
      if(AO_CloseOrdersType<0)
        {
         PrintFormat("Invalid AO_CloseOrdersType input value: %d",AO_CloseOrdersType);
         return(INIT_FAILED);
        }
     }
//---------------------------------------------------------------------
   if((AO_RiskFactor<0.01)||(AO_RiskFactor>100))
     {
      PrintFormat("Invalid AO_RiskFactor input value (between 0.01 and 100): %d",AO_RiskFactor);
      return(INIT_FAILED);
     }
//---------------------------------------------------------------------
   if(AO_StopLoss<0)
     {
      PrintFormat("Invalid AO_StopLoss input value (greater or equal than 0): %d",AO_StopLoss);
      return(INIT_FAILED);
     }
//---
   if(AO_TakeProfit<0)
     {
      PrintFormat("Invalid AO_TakeProfit input value (greater or equal than 0): %d",AO_TakeProfit);
      return(INIT_FAILED);
     }
//---------------------------------------------------------------------
//DeM_Check parameters
   if(DeM_OpenOrdersType>4)
     {
      Print("Invalid 'DeM_OpenOrdersType' value. The maximum accepted value is 4.");
      return(INIT_FAILED);
     }
//---
   if(DeM_OpenOrdersType<0)
     {
      PrintFormat("Invalid DeM_OpenOrdersType input value: %d",DeM_OpenOrdersType);
      return(INIT_FAILED);
     }
//---------------------------------------------------------------------
   if(DeM_CloseInSignals==true)
     {
      if(DeM_CloseOrdersType>4)
        {
         Print("Invalid 'DeM_CloseOrdersType' value. The maximum accepted value is 4.");
         return(INIT_FAILED);
        }
      //---
      if(DeM_CloseOrdersType<0)
        {
         PrintFormat("Invalid DeM_CloseOrdersType input value: %d",DeM_CloseOrdersType);
         return(INIT_FAILED);
        }
     }
//---------------------------------------------------------------------
   if((DeM_RiskFactor<0.01)||(DeM_RiskFactor>100))
     {
      PrintFormat("Invalid DeM_RiskFactor input value (between 0.01 and 100): %d",DeM_RiskFactor);
      return(INIT_FAILED);
     }
//---------------------------------------------------------------------
   if(DeM_StopLoss<0)
     {
      PrintFormat("Invalid DeM_StopLoss input value (greater or equal than 0): %d",DeM_StopLoss);
      return(INIT_FAILED);
     }
//---
   if(DeM_TakeProfit<0)
     {
      PrintFormat("Invalid DeM_TakeProfit input value (greater or equal than 0): %d",DeM_TakeProfit);
      return(INIT_FAILED);
     }
//---------------------------------------------------------------------
//FBB_Check parameters
   if(FBB_OpenOrdersType_1>2)
     {
      Print("Invalid 'FBB_OpenOrdersType_1' value. The maximum accepted value is 2.");
      return(INIT_FAILED);
     }
//---
   if(FBB_OpenOrdersType_2>8)
     {
      Print("Invalid 'FBB_OpenOrdersType_2' value. The maximum accepted value is 8.");
      return(INIT_FAILED);
     }
//---
   if(FBB_OpenOrdersType_1<0)
     {
      PrintFormat("Invalid FBB_OpenOrdersType_1 input value: %d",FBB_OpenOrdersType_1);
      return(INIT_FAILED);
     }
//---
   if(FBB_OpenOrdersType_2<0)
     {
      PrintFormat("Invalid FBB_OpenOrdersType_2 input value: %d",FBB_OpenOrdersType_2);
      return(INIT_FAILED);
     }
//---------------------------------------------------------------------
   if(FBB_CloseInSignals==true)
     {
      if(FBB_CloseOrdersType_1>2)
        {
         Print("Invalid 'FBB_CloseOrdersType_1' value. The maximum accepted value is 2.");
         return(INIT_FAILED);
        }
      //---
      if(FBB_CloseOrdersType_2>8)
        {
         Print("Invalid 'FBB_CloseOrdersType_2' value. The maximum accepted value is 8.");
         return(INIT_FAILED);
        }
      //---
      if(FBB_CloseOrdersType_1<0)
        {
         PrintFormat("Invalid FBB_CloseOrdersType_1 input value: %d",FBB_CloseOrdersType_1);
         return(INIT_FAILED);
        }
      //---
      if(FBB_CloseOrdersType_2<0)
        {
         PrintFormat("Invalid FBB_CloseOrdersType_2 input value: %d",FBB_CloseOrdersType_2);
         return(INIT_FAILED);
        }
     }
//---------------------------------------------------------------------
   if((FBB_RiskFactor<0.01)||(FBB_RiskFactor>100))
     {
      PrintFormat("Invalid FBB_RiskFactor input value (between 0.01 and 100): %d",FBB_RiskFactor);
      return(INIT_FAILED);
     }
//---------------------------------------------------------------------
   if(FBB_StopLoss<0)
     {
      PrintFormat("Invalid FBB_StopLoss input value (greater or equal than 0): %d",FBB_StopLoss);
      return(INIT_FAILED);
     }
//---
   if(FBB_TakeProfit<0)
     {
      PrintFormat("Invalid FBB_TakeProfit input value (greater or equal than 0): %d",FBB_TakeProfit);
      return(INIT_FAILED);
     }
//---------------------------------------------------------------------
//MFI_Check parameters
   if(MFI_OpenOrdersType>4)
     {
      Print("Invalid 'MFI_OpenOrdersType' value. The maximum accepted value is 4.");
      return(INIT_FAILED);
     }
//---
   if(MFI_OpenOrdersType<0)
     {
      PrintFormat("Invalid MFI_OpenOrdersType input value: %d",MFI_OpenOrdersType);
      return(INIT_FAILED);
     }
//---------------------------------------------------------------------
   if(MFI_CloseInSignals==true)
     {
      if(MFI_CloseOrdersType>4)
        {
         Print("Invalid 'MFI_CloseOrdersType' value. The maximum accepted value is 4.");
         return(INIT_FAILED);
        }
      //---
      if(MFI_CloseOrdersType<0)
        {
         PrintFormat("Invalid MFI_CloseOrdersType input value: %d",MFI_CloseOrdersType);
         return(INIT_FAILED);
        }
     }
//---------------------------------------------------------------------
   if((MFI_RiskFactor<0.01)||(MFI_RiskFactor>100))
     {
      PrintFormat("Invalid MFI_RiskFactor input value (between 0.01 and 100): %d",MFI_RiskFactor);
      return(INIT_FAILED);
     }
//---------------------------------------------------------------------
   if(MFI_StopLoss<0)
     {
      PrintFormat("Invalid MFI_StopLoss input value (greater or equal than 0): %d",MFI_StopLoss);
      return(INIT_FAILED);
     }
//---
   if(MFI_TakeProfit<0)
     {
      PrintFormat("Invalid MFI_TakeProfit input value (greater or equal than 0): %d",MFI_TakeProfit);
      return(INIT_FAILED);
     }
//---------------------------------------------------------------------
//MS Check parameters
   if(MS_OpenOrdersType_1>11)
     {
      Print("Invalid 'OpenOrdersType' value. The maximum accepted value is 11.");
      return(INIT_FAILED);
     }
//---
   if(MS_OpenOrdersType_1<0)
     {
      PrintFormat("Invalid OpenOrdersType input value: %d",MS_OpenOrdersType_1);
      return(INIT_FAILED);
     }
//---
   if(MS_OpenOrdersType_2>28)
     {
      Print("Invalid 'OpenOrdersType' value. The maximum accepted value is 28.");
      return(INIT_FAILED);
     }
//---
   if(MS_OpenOrdersType_2<0)
     {
      PrintFormat("Invalid OpenOrdersType input value: %d",MS_OpenOrdersType_2);
      return(INIT_FAILED);
     }
//---------------------------------------------------------------------
   if(MS_CloseInSignals==true)
     {
      if(MS_CloseOrdersType_1>11)
        {
         Print("Invalid 'MS_CloseOrdersType_1' value. The maximum accepted value is 11.");
         return(INIT_FAILED);
        }
      //---
      if(MS_CloseOrdersType_1<0)
        {
         PrintFormat("Invalid MS_CloseOrdersType_1 input value: %d",MS_CloseOrdersType_1);
         return(INIT_FAILED);
        }
      //---
      if(MS_CloseOrdersType_2>28)
        {
         Print("Invalid 'MS_CloseOrdersType_2' value. The maximum accepted value is 28.");
         return(INIT_FAILED);
        }
      //---
      if(MS_CloseOrdersType_2<0)
        {
         PrintFormat("Invalid MS_CloseOrdersType_2 input value: %d",MS_CloseOrdersType_2);
         return(INIT_FAILED);
        }
     }
//---------------------------------------------------------------------
   if((MFI_RiskFactor<0.01)||(MFI_RiskFactor>100))
     {
      PrintFormat("Invalid MFI_RiskFactor input value (between 0.01 and 100): %d",MFI_RiskFactor);
      return(INIT_FAILED);
     }
//---------------------------------------------------------------------
   if(MFI_StopLoss<0)
     {
      PrintFormat("Invalid MFI_StopLoss input value (greater or equal than 0): %d",MFI_StopLoss);
      return(INIT_FAILED);
     }
//---
   if(MFI_TakeProfit<0)
     {
      PrintFormat("Invalid MFI_TakeProfit input value (greater or equal than 0): %d",MFI_TakeProfit);
      return(INIT_FAILED);
     }
//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------
   if(MaxSpread<0)
     {
      PrintFormat("Invalid MaxSpread input value (greater or equal than 0): %d",MaxSpread);
      return(INIT_FAILED);
     }
//---
   if(MaxOrders<0)
     {
      PrintFormat("Invalid MaxOrders input value (greater or equal than 0): %d",MaxOrders);
      return(INIT_FAILED);
     }
//---------------------------------------------------------------------
//Symbol suffix
   if(StringLen(Symbol())>6)
      SymbolSuffix=StringSubstr(Symbol(),6);
//---------------------------------------------------------------------
//Set up pair to trade
   if(PairToTrade==0)
     {
      if(Symbol()=="EURGBP"+SymbolSuffix)
         TypeOfPair=1;
      //---
      if(Symbol()=="EURAUD"+SymbolSuffix)
         TypeOfPair=2;
      //---
      if(Symbol()=="EURNZD"+SymbolSuffix)
         TypeOfPair=3;
      //---
      if(Symbol()=="EURUSD"+SymbolSuffix)
         TypeOfPair=4;
      //---
      if(Symbol()=="EURCAD"+SymbolSuffix)
         TypeOfPair=5;
      //---
      if(Symbol()=="EURCHF"+SymbolSuffix)
         TypeOfPair=6;
      //---
      if(Symbol()=="EURJPY"+SymbolSuffix)
         TypeOfPair=7;
      //---
      if(Symbol()=="GBPAUD"+SymbolSuffix)
         TypeOfPair=8;
      //---
      if(Symbol()=="GBPNZD"+SymbolSuffix)
         TypeOfPair=9;
      //---
      if(Symbol()=="GBPUSD"+SymbolSuffix)
         TypeOfPair=10;
      //---
      if(Symbol()=="GBPCAD"+SymbolSuffix)
         TypeOfPair=11;
      //---
      if(Symbol()=="GBPCHF"+SymbolSuffix)
         TypeOfPair=12;
      //---
      if(Symbol()=="GBPJPY"+SymbolSuffix)
         TypeOfPair=13;
      //---
      if(Symbol()=="AUDNZD"+SymbolSuffix)
         TypeOfPair=14;
      //---
      if(Symbol()=="AUDUSD"+SymbolSuffix)
         TypeOfPair=15;
      //---
      if(Symbol()=="AUDCAD"+SymbolSuffix)
         TypeOfPair=16;
      //---
      if(Symbol()=="AUDCHF"+SymbolSuffix)
         TypeOfPair=17;
      //---
      if(Symbol()=="AUDJPY"+SymbolSuffix)
         TypeOfPair=18;
      //---
      if(Symbol()=="NZDUSD"+SymbolSuffix)
         TypeOfPair=19;
      //---
      if(Symbol()=="NZDCAD"+SymbolSuffix)
         TypeOfPair=20;
      //---
      if(Symbol()=="NZDCHF"+SymbolSuffix)
         TypeOfPair=21;
      //---
      if(Symbol()=="NZDJPY"+SymbolSuffix)
         TypeOfPair=22;
      //---
      if(Symbol()=="USDCAD"+SymbolSuffix)
         TypeOfPair=23;
      //---
      if(Symbol()=="USDCHF"+SymbolSuffix)
         TypeOfPair=24;
      //---
      if(Symbol()=="USDJPY"+SymbolSuffix)
         TypeOfPair=25;
      //---
      if(Symbol()=="CADCHF"+SymbolSuffix)
         TypeOfPair=26;
      //---
      if(Symbol()=="CADJPY"+SymbolSuffix)
         TypeOfPair=27;
      //---
      if(Symbol()=="CHFJPY"+SymbolSuffix)
         TypeOfPair=28;
     }
   else
      TypeOfPair=PairToTrade;
//---------------------------------------------------------------------
//Set up currensies and pairs
   switch(TypeOfPair)
     {
      case 1://EURGBP
         PairTrade="EURGBP";
         break;
      case 2://EURAUD
         PairTrade="EURAUD";
         break;
      case 3://EURNZD
         PairTrade="EURNZD";
         break;
      case 4://EURUSD
         PairTrade="EURUSD";
         break;
      case 5://EURCAD
         PairTrade="EURCAD";
         break;
      case 6://EURCHF
         PairTrade="EURCHF";
         break;
      case 7://EURJPY
         PairTrade="EURJPY";
         break;
      case 8://GBPAUD
         PairTrade="GBPAUD";
         break;
      case 9://GBPNZD
         PairTrade="GBPNZD";
         break;
      case 10://GBPUSD
         PairTrade="GBPUSD";
         break;
      case 11://GBPCAD
         PairTrade="GBPCAD";
         break;
      case 12://GBPCHF
         PairTrade="GBPCHF";
         break;
      case 13://GBPJPY
         PairTrade="GBPJPY";
         break;
      case 14://AUDNZD
         PairTrade="AUDNZD";
         break;
      case 15://AUDUSD
         PairTrade="AUDUSD";
         break;
      case 16://AUDCAD
         PairTrade="AUDCAD";
         break;
      case 17://AUDCHF
         PairTrade="AUDCHF";
         break;
      case 18://AUDJPY
         PairTrade="AUDJPY";
         break;
      case 19://NZDUSD
         PairTrade="NZDUSD";
         break;
      case 20://NZDCAD
         PairTrade="NZDCAD";
         break;
      case 21://NZDCHF
         PairTrade="NZDCHF";
         break;
      case 22://NZDJPY
         PairTrade="NZDJPY";
         break;
      case 23://USDCAD
         PairTrade="USDCAD";
         break;
      case 24://USDCHF
         PairTrade="USDCHF";
         break;
      case 25://USDJPY
         PairTrade="USDJPY";
         break;
      case 26://CADCHF
         PairTrade="CADCHF";
         break;
      case 27://CADJPY
         PairTrade="CADJPY";
         break;
      case 28://CHFJPY
         PairTrade="CHFJPY";
         break;
     }
//---------------------------------------------------------------------
//Get expert name and symbol name
   ExpertName=MQLInfoString(MQL_PROGRAM_NAME);
   SymbolTrade=PairTrade+SymbolSuffix;
   ExpertNameLen=StringLen(CommentsOrders);
//---------------------------------------------------------------------
//Show symbol on market watch
   if(SymbolSelect(SymbolTrade,true))
      Print(" # Expert show symbol on market watch list # ");
//---------------------------------------------------------------------
//Set chart
   if((!MQLInfoInteger(MQL_TESTER))&&(!MQLInfoInteger(MQL_VISUAL_MODE))&&(!MQLInfoInteger(MQL_OPTIMIZATION)))
     {
      if(SetChartUses==true)
        {
         if((ChartSymbol()!=SymbolTrade)||(ChartPeriod()!=TimeFrame))
           {
            Print(" # "+MQLInfoString(MQL_PROGRAM_NAME)+" # "+"Set chart symbol: "+SymbolTrade+" and Period: "+EnumToString(TimeFrame)+" # ");
            ChartSetSymbolPeriod(0,SymbolTrade,TimeFrame);
           }
        }
     }
//---------------------------------------------------------------------
//Check name of expert
   /*if(StringSubstr(ExpertName,0,ExpertNameLen)!="MultiStrategyEA")
     {
      Print("Please don't change the original name of expert: MultiStrategyEA");
      return(INIT_FAILED);
     }*/
//---------------------------------------------------------------------
//Background
   if(ShowComments==true)
     {
      if(!MQLInfoInteger(MQL_OPTIMIZATION))
        {
         ChartColor=(color)ChartGetInteger(0,CHART_COLOR_BACKGROUND,0);
         BackgroundName="Background-"+ExpertName;
         //---
         for(i=1; i<20; i++)
           {
            if(ObjectFind(0,"Com"+IntegerToString(i))>-1)
               ObjectDelete(0,"Com"+IntegerToString(i));
           }
         //---
         ChartColor=(color)ChartGetInteger(0,CHART_COLOR_BACKGROUND,0);
         BackgroundName="Background-"+ExpertName;
         //---
         if(ObjectFind(0,BackgroundName)==-1)
            DrawObjects(BackgroundName,ChartColor,BORDER_RAISED,false,0,15,312,418);
        }
     }
//---------------------------------------------------------------------
//Broker 4 or 5 digits
   MultiplierPoint=1;
//---
   SymbolPoints=Point();
   SymbolDigits=Digits();
//---
   SymbolSelect("EURUSD"+SymbolSuffix,true);
   if(SymbolInfoInteger("EURUSD"+SymbolSuffix,SYMBOL_DIGITS)==5)
      MultiplierPoint=10;
//---
   SymbolPoints*=MultiplierPoint;
//---------------------------------------------------------------------
//Stop level
   StopLevel=(double)MathMax(SymbolInfoInteger(SymbolTrade,SYMBOL_TRADE_STOPS_LEVEL)/MultiplierPoint,SymbolInfoInteger(SymbolTrade,SYMBOL_TRADE_FREEZE_LEVEL)/MultiplierPoint);
//---------------------------------------------------------------------
//AC_Warning about stop level
   if((((AC_TypeOfLevelsUse==0)||(AC_TypeOfLevelsUse==2))&&(AC_TakeProfit>0)&&(AC_TakeProfit<StopLevel))||(((AC_TypeOfLevelsUse==0)||(AC_TypeOfLevelsUse==2))&&(AC_StopLoss>0)&&(AC_StopLoss<StopLevel)))
     {
      if(((AC_TypeOfLevelsUse==0)||(AC_TypeOfLevelsUse==2))&&(AC_TakeProfit>0)&&(AC_TakeProfit<StopLevel))
         SignalsMessageWarning=MessageBox("'Take Profit' is smaller than stop level ("+DoubleToString(AC_TakeProfit,2)+"/"+DoubleToString(StopLevel,2)+")"+
                                          "\n\nBy clicking YES expert autoset 'Take Profit'. \n\nSTART EXPERT ADVISOR?","RISK DISCLAIMER - "+ExpertName,MB_YESNO|MB_ICONEXCLAMATION);
      //---
      if(((AC_TypeOfLevelsUse==0)||(AC_TypeOfLevelsUse==2))&&(AC_StopLoss>0)&&(AC_StopLoss<StopLevel))
         SignalsMessageWarning=MessageBox("'Stop Loss' is smaller than stop level ("+DoubleToString(AC_StopLoss,2)+"/"+DoubleToString(StopLevel,2)+")"+
                                          "\n\nBy clicking YES expert autoset 'Stop Loss'. \n\nSTART EXPERT ADVISOR?","RISK DISCLAIMER - "+ExpertName,MB_YESNO|MB_ICONEXCLAMATION);
      //---
      if(SignalsMessageWarning==IDNO)
         return(INIT_FAILED);
     }
//---------------------------------------------------------------------
//ADX_Warning about stop level
   if((((ADX_TypeOfLevelsUse==0)||(ADX_TypeOfLevelsUse==2))&&(ADX_TakeProfit>0)&&(ADX_TakeProfit<StopLevel))||(((ADX_TypeOfLevelsUse==0)||(ADX_TypeOfLevelsUse==2))&&(ADX_StopLoss>0)&&(ADX_StopLoss<StopLevel)))
     {
      if(((ADX_TypeOfLevelsUse==0)||(ADX_TypeOfLevelsUse==2))&&(ADX_TakeProfit>0)&&(ADX_TakeProfit<StopLevel))
         SignalsMessageWarning=MessageBox("'Take Profit' is smaller than stop level ("+DoubleToString(ADX_TakeProfit,2)+"/"+DoubleToString(StopLevel,2)+")"+
                                          "\n\nBy clicking YES expert autoset 'Take Profit'. \n\nSTART EXPERT ADVISOR?","RISK DISCLAIMER - "+ExpertName,MB_YESNO|MB_ICONEXCLAMATION);
      //---
      if(((ADX_TypeOfLevelsUse==0)||(ADX_TypeOfLevelsUse==2))&&(ADX_StopLoss>0)&&(ADX_StopLoss<StopLevel))
         SignalsMessageWarning=MessageBox("'Stop Loss' is smaller than stop level ("+DoubleToString(ADX_StopLoss,2)+"/"+DoubleToString(StopLevel,2)+")"+
                                          "\n\nBy clicking YES expert autoset 'Stop Loss'. \n\nSTART EXPERT ADVISOR?","RISK DISCLAIMER - "+ExpertName,MB_YESNO|MB_ICONEXCLAMATION);
      //---
      if(SignalsMessageWarning==IDNO)
         return(INIT_FAILED);
     }
//---------------------------------------------------------------------
//AO_Warning about stop level
   if((((AO_TypeOfLevelsUse==0)||(AO_TypeOfLevelsUse==2))&&(AO_TakeProfit>0)&&(AO_TakeProfit<StopLevel))||(((AO_TypeOfLevelsUse==0)||(AO_TypeOfLevelsUse==2))&&(AO_StopLoss>0)&&(AO_StopLoss<StopLevel)))
     {
      if(((AO_TypeOfLevelsUse==0)||(AO_TypeOfLevelsUse==2))&&(AO_TakeProfit>0)&&(AO_TakeProfit<StopLevel))
         SignalsMessageWarning=MessageBox("'Take Profit' is smaller than stop level ("+DoubleToString(AO_TakeProfit,2)+"/"+DoubleToString(StopLevel,2)+")"+
                                          "\n\nBy clicking YES expert autoset 'Take Profit'. \n\nSTART EXPERT ADVISOR?","RISK DISCLAIMER - "+ExpertName,MB_YESNO|MB_ICONEXCLAMATION);
      //---
      if(((AO_TypeOfLevelsUse==0)||(AO_TypeOfLevelsUse==2))&&(AO_StopLoss>0)&&(AO_StopLoss<StopLevel))
         SignalsMessageWarning=MessageBox("'Stop Loss' is smaller than stop level ("+DoubleToString(AO_StopLoss,2)+"/"+DoubleToString(StopLevel,2)+")"+
                                          "\n\nBy clicking YES expert autoset 'Stop Loss'. \n\nSTART EXPERT ADVISOR?","RISK DISCLAIMER - "+ExpertName,MB_YESNO|MB_ICONEXCLAMATION);
      //---
      if(SignalsMessageWarning==IDNO)
         return(INIT_FAILED);
     }
//---------------------------------------------------------------------
//DeM_Warning about stop level
   if((((DeM_TypeOfLevelsUse==0)||(DeM_TypeOfLevelsUse==2))&&(DeM_TakeProfit>0)&&(DeM_TakeProfit<StopLevel))||(((DeM_TypeOfLevelsUse==0)||(DeM_TypeOfLevelsUse==2))&&(DeM_StopLoss>0)&&(DeM_StopLoss<StopLevel)))
     {
      if(((DeM_TypeOfLevelsUse==0)||(DeM_TypeOfLevelsUse==2))&&(DeM_TakeProfit>0)&&(DeM_TakeProfit<StopLevel))
         SignalsMessageWarning=MessageBox("'Take Profit' is smaller than stop level ("+DoubleToString(DeM_TakeProfit,2)+"/"+DoubleToString(StopLevel,2)+")"+
                                          "\n\nBy clicking YES expert autoset 'Take Profit'. \n\nSTART EXPERT ADVISOR?","RISK DISCLAIMER - "+ExpertName,MB_YESNO|MB_ICONEXCLAMATION);
      //---
      if(((DeM_TypeOfLevelsUse==0)||(DeM_TypeOfLevelsUse==2))&&(DeM_StopLoss>0)&&(DeM_StopLoss<StopLevel))
         SignalsMessageWarning=MessageBox("'Stop Loss' is smaller than stop level ("+DoubleToString(DeM_StopLoss,2)+"/"+DoubleToString(StopLevel,2)+")"+
                                          "\n\nBy clicking YES expert autoset 'Stop Loss'. \n\nSTART EXPERT ADVISOR?","RISK DISCLAIMER - "+ExpertName,MB_YESNO|MB_ICONEXCLAMATION);
      //---
      if(SignalsMessageWarning==IDNO)
         return(INIT_FAILED);
     }
//---------------------------------------------------------------------
//FBB_Warning about stop level
   if((((FBB_TypeOfLevelsUse==0)||(FBB_TypeOfLevelsUse==2))&&(FBB_TakeProfit>0)&&(FBB_TakeProfit<StopLevel))||(((FBB_TypeOfLevelsUse==0)||(FBB_TypeOfLevelsUse==2))&&(FBB_StopLoss>0)&&(FBB_StopLoss<StopLevel)))
     {
      if(((FBB_TypeOfLevelsUse==0)||(FBB_TypeOfLevelsUse==2))&&(FBB_TakeProfit>0)&&(FBB_TakeProfit<StopLevel))
         SignalsMessageWarning=MessageBox("'Take Profit' is smaller than stop level ("+DoubleToString(FBB_TakeProfit,2)+"/"+DoubleToString(StopLevel,2)+")"+
                                          "\n\nBy clicking YES expert autoset 'Take Profit'. \n\nSTART EXPERT ADVISOR?","RISK DISCLAIMER - "+ExpertName,MB_YESNO|MB_ICONEXCLAMATION);
      //---
      if(((FBB_TypeOfLevelsUse==0)||(FBB_TypeOfLevelsUse==2))&&(FBB_StopLoss>0)&&(FBB_StopLoss<StopLevel))
         SignalsMessageWarning=MessageBox("'Stop Loss' is smaller than stop level ("+DoubleToString(FBB_StopLoss,2)+"/"+DoubleToString(StopLevel,2)+")"+
                                          "\n\nBy clicking YES expert autoset 'Stop Loss'. \n\nSTART EXPERT ADVISOR?","RISK DISCLAIMER - "+ExpertName,MB_YESNO|MB_ICONEXCLAMATION);
      //---
      if(SignalsMessageWarning==IDNO)
         return(INIT_FAILED);
     }
//---------------------------------------------------------------------
//MFI_Warning about stop level
   if((((MFI_TypeOfLevelsUse==0)||(MFI_TypeOfLevelsUse==2))&&(MFI_TakeProfit>0)&&(MFI_TakeProfit<StopLevel))||(((MFI_TypeOfLevelsUse==0)||(MFI_TypeOfLevelsUse==2))&&(MFI_StopLoss>0)&&(MFI_StopLoss<StopLevel)))
     {
      if(((MFI_TypeOfLevelsUse==0)||(MFI_TypeOfLevelsUse==2))&&(MFI_TakeProfit>0)&&(MFI_TakeProfit<StopLevel))
         SignalsMessageWarning=MessageBox("'Take Profit' is smaller than stop level ("+DoubleToString(MFI_TakeProfit,2)+"/"+DoubleToString(StopLevel,2)+")"+
                                          "\n\nBy clicking YES expert autoset 'Take Profit'. \n\nSTART EXPERT ADVISOR?","RISK DISCLAIMER - "+ExpertName,MB_YESNO|MB_ICONEXCLAMATION);
      //---
      if(((MFI_TypeOfLevelsUse==0)||(MFI_TypeOfLevelsUse==2))&&(MFI_StopLoss>0)&&(MFI_StopLoss<StopLevel))
         SignalsMessageWarning=MessageBox("'Stop Loss' is smaller than stop level ("+DoubleToString(MFI_StopLoss,2)+"/"+DoubleToString(StopLevel,2)+")"+
                                          "\n\nBy clicking YES expert autoset 'Stop Loss'. \n\nSTART EXPERT ADVISOR?","RISK DISCLAIMER - "+ExpertName,MB_YESNO|MB_ICONEXCLAMATION);
      //---
      if(SignalsMessageWarning==IDNO)
         return(INIT_FAILED);
     }
//---------------------------------------------------------------------
//MS_Warning about stop level
   if((((MS_TypeOfLevelsUse==0)||(MS_TypeOfLevelsUse==2))&&(MS_TakeProfit>0)&&(MS_TakeProfit<StopLevel))||(((MS_TypeOfLevelsUse==0)||(MS_TypeOfLevelsUse==2))&&(MS_StopLoss>0)&&(MS_StopLoss<StopLevel)))
     {
      if(((MS_TypeOfLevelsUse==0)||(MS_TypeOfLevelsUse==2))&&(MS_TakeProfit>0)&&(MS_TakeProfit<StopLevel))
         SignalsMessageWarning=MessageBox("'Take Profit' is smaller than stop level ("+DoubleToString(MS_TakeProfit,2)+"/"+DoubleToString(StopLevel,2)+")"+
                                          "\n\nBy clicking YES expert autoset 'Take Profit'. \n\nSTART EXPERT ADVISOR?","RISK DISCLAIMER - "+ExpertName,MB_YESNO|MB_ICONEXCLAMATION);
      //---
      if(((MS_TypeOfLevelsUse==0)||(MS_TypeOfLevelsUse==2))&&(MS_StopLoss>0)&&(MS_StopLoss<StopLevel))
         SignalsMessageWarning=MessageBox("'Stop Loss' is smaller than stop level ("+DoubleToString(MS_StopLoss,2)+"/"+DoubleToString(StopLevel,2)+")"+
                                          "\n\nBy clicking YES expert autoset 'Stop Loss'. \n\nSTART EXPERT ADVISOR?","RISK DISCLAIMER - "+ExpertName,MB_YESNO|MB_ICONEXCLAMATION);
      //---
      if(SignalsMessageWarning==IDNO)
         return(INIT_FAILED);
     }
//---------------------------------------------------------------------
//Set stop loss and take profit according stop level
   AC_PipsStopLoss=MathMax(AC_StopLoss,StopLevel);
   AC_PipsTakeProfit=MathMax(AC_TakeProfit,StopLevel);
//---
   ADX_PipsStopLoss=MathMax(ADX_StopLoss,StopLevel);
   ADX_PipsTakeProfit=MathMax(ADX_TakeProfit,StopLevel);
//---
   AO_PipsStopLoss=MathMax(AO_StopLoss,StopLevel);
   AO_PipsTakeProfit=MathMax(AO_TakeProfit,StopLevel);
//---
   DeM_PipsStopLoss=MathMax(DeM_StopLoss,StopLevel);
   DeM_PipsTakeProfit=MathMax(DeM_TakeProfit,StopLevel);
//---
   FBB_PipsStopLoss=MathMax(FBB_StopLoss,StopLevel);
   FBB_PipsTakeProfit=MathMax(FBB_TakeProfit,StopLevel);
//---
   MFI_PipsStopLoss=MathMax(MFI_StopLoss,StopLevel);
   MFI_PipsTakeProfit=MathMax(MFI_TakeProfit,StopLevel);
//---
   MS_PipsStopLoss=MathMax(MS_StopLoss,StopLevel);
   MS_PipsTakeProfit=MathMax(MS_TakeProfit,StopLevel);
//---------------------------------------------------------------------
//Set orders' ID
   /*AC_OrdersID=MagicNumber+1;
   ADX_OrdersID=MagicNumber+2;
   AO_OrdersID=MagicNumber+3;
   DeM_OrdersID=MagicNumber+4;
   FBB_OrdersID=MagicNumber+5;
   MFI_OrdersID=MagicNumber+6;
   MS_OrdersID=MagicNumber+7;
   //---
   if(MagicNumber==0)
     {
      AC_OrdersID=0;
      ADX_OrdersID=0;
      AO_OrdersID=0;
      DeM_OrdersID=0;
      FBB_OrdersID=0;
      MFI_OrdersID=0;
      MS_OrdersID=0;
      //---
      for(i=0; i<StringLen(SymbolTrade); i++)
        {
         AC_OrdersID+=(StringGetCharacter(SymbolTrade,i)*(i+1));
         ADX_OrdersID+=(StringGetCharacter(SymbolTrade,i)*(i+2));
         AO_OrdersID+=(StringGetCharacter(SymbolTrade,i)*(i+3));
         DeM_OrdersID+=(StringGetCharacter(SymbolTrade,i)*(i+4));
         FBB_OrdersID+=(StringGetCharacter(SymbolTrade,i)*(i+5));
         MFI_OrdersID+=(StringGetCharacter(SymbolTrade,i)*(i+6));
         MS_OrdersID+=(StringGetCharacter(SymbolTrade,i)*(i+7));
        }
      //---
      AC_OrdersID+=MagicSet;
      ADX_OrdersID+=MagicSet;
      AO_OrdersID+=MagicSet;
      DeM_OrdersID+=MagicSet;
      FBB_OrdersID+=MagicSet;
      MFI_OrdersID+=MagicSet;
      MS_OrdersID+=MagicSet;
     }*/
//---
   AC_OrdersID=911355;
   ADX_OrdersID=11625;
   AO_OrdersID=112981;
   DeM_OrdersID=991725;
   FBB_OrdersID=113881;
   MFI_OrdersID=13902379;
   MS_OrdersID=9093355;
//---------------------------------------------------------------------
//Set maximum orders
   if((MaxOrders==0)&&(AccountInfoInteger(ACCOUNT_LIMIT_ORDERS)==0))
      AcceptMaxOrders=0;
//---
   if((MaxOrders>0)&&(AccountInfoInteger(ACCOUNT_LIMIT_ORDERS)==0))
      AcceptMaxOrders=MaxOrders;
//---
   if((MaxOrders==0)&&(AccountInfoInteger(ACCOUNT_LIMIT_ORDERS)>0))
      AcceptMaxOrders=(int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
//---
   if((MaxOrders>0)&&(AccountInfoInteger(ACCOUNT_LIMIT_ORDERS)>0))
      AcceptMaxOrders=MathMin((int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS),MaxOrders);
//---------------------------------------------------------------------
//For show comment if market is closed
   if(!MQLInfoInteger(MQL_OPTIMIZATION))
     {
      MainFunction();
      //---
      if(ShowComments==true)
         CommentScreen();
     }
//---------------------------------------------------------------------
//Set indicators AC
   if(AC_StrategyRun==true)
     {
      AC=iAC(SymbolTrade,TimeFrame);
      //---
      if(AC==INVALID_HANDLE)
        {
         Print("Error creating AC indicator");
         return(INIT_FAILED);
        }
     }
//---------------------------------------------------------------------
//Set indicators ADX
   if(ADX_StrategyRun==true)
     {
      ADX=iADX(SymbolTrade,TimeFrame,ADX_BarsCalculate);
      //---
      if(ADX==INVALID_HANDLE)
        {
         Print("Error creating ADX indicator");
         return(INIT_FAILED);
        }
     }
//---------------------------------------------------------------------
//Set indicators AO
   if(AO_StrategyRun==true)
     {
      AO=iAO(SymbolTrade,TimeFrame);
      //---
      if(AO==INVALID_HANDLE)
        {
         Print("Error creating AO indicator");
         return(INIT_FAILED);
        }
     }
//---------------------------------------------------------------------
//Set indicators AC
   if(DeM_StrategyRun==true)
     {
      DeMarker=iDeMarker(SymbolTrade,TimeFrame,DeM_BarsCalculate);
      //---
      if(DeMarker==INVALID_HANDLE)
        {
         Print("Error creating Demarker indicator");
         return(INIT_FAILED);
        }
     }
//---------------------------------------------------------------------
//Set indicators BollingerBands - Force
   if(FBB_StrategyRun==true)
     {
      BollingerBands=iBands(SymbolTrade,TimeFrame,FBB_BarsCalculate,0,FBB_Deviation,PRICE_CLOSE);
      Force=iForce(SymbolTrade,TimeFrame,FBB_BarsCalculate,MODE_SMA,VOLUME_TICK);
      //---
      if(BollingerBands==INVALID_HANDLE)
        {
         Print("Error creating BollingerBands indicator");
         return(INIT_FAILED);
        }
      //---
      if(Force==INVALID_HANDLE)
        {
         Print("Error creating Force indicator");
         return(INIT_FAILED);
        }
     }
//---------------------------------------------------------------------
//Set indicators MFI
   if(MFI_StrategyRun==true)
     {
      MFI=iMFI(SymbolTrade,TimeFrame,MFI_BarsCalculate,VOLUME_TICK);
      //---
      if(MFI==INVALID_HANDLE)
        {
         Print("Error creating MFI indicator");
         return(INIT_FAILED);
        }
     }
//---------------------------------------------------------------------
//Set indicators MACD - STOCH
   if(MS_StrategyRun==true)
     {
      MACD=iMACD(SymbolTrade,TimeFrame,MS_Fast_EMA_Period,MS_Slow_EMA_Period,MS_Signal_Period,PRICE_CLOSE);
      STOCH=iStochastic(SymbolTrade,TimeFrame,MS_K_Period,MS_D_Period,MS_Slowing_Period,MODE_SMA,STO_LOWHIGH);
      //---
      if(MACD==INVALID_HANDLE)
        {
         Print("Error creating MACD indicator");
         return(INIT_FAILED);
        }
      //---
      if(STOCH==INVALID_HANDLE)
        {
         Print("Error creating Stochastic indicator");
         return(INIT_FAILED);
        }
     }
//---------------------------------------------------------------------
   return(INIT_SUCCEEDED);
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//OnDeinit function
//============================================================================================================================================================================================================================//
void OnDeinit(const int reason)
  {
//---------------------------------------------------------------------
//Clear chart
   if(!MQLInfoInteger(MQL_OPTIMIZATION))
     {
      if(ObjectFind(0,BackgroundName)>-1)
         ObjectDelete(0,BackgroundName);
      //---
      for(i=1; i<50; i++)
        {
         if(ObjectFind(0,"Com"+IntegerToString(i))>-1)
            ObjectDelete(0,"Com"+IntegerToString(i));
        }
      //---
      Comment("");
      //---------------------------------------------------------------------
      //Print reason
      if(MQLInfoInteger(MQL_PROGRAM_TYPE)==PROGRAM_EXPERT)
        {
         switch(UninitializeReason())
           {
            case REASON_PROGRAM     :
               Print("Expert Advisor self terminated");
               break;
            case REASON_REMOVE      :
               Print("Expert Advisor removed from the chart");
               break;
            case REASON_RECOMPILE   :
               Print("Expert Advisorhas been recompiled");
               break;
            case REASON_CHARTCHANGE :
               Print("Symbol or chart period has been changed");
               break;
            case REASON_CHARTCLOSE  :
               Print("Chart has been closed");
               break;
            case REASON_PARAMETERS  :
               Print("Input parameters have been changed by a user");
               break;
            case REASON_ACCOUNT     :
               Print("Another account has been activated or reconnection to the trade server has occurred due to changes in the account settings");
               break;
            case REASON_TEMPLATE    :
               Print("A new template has been applied");
               break;
            case REASON_INITFAILED  :
               Print("OnInit() handler has returned a nonzero value");
               break;
            case REASON_CLOSE       :
               Print("Terminal has been closed");
               break;
           }
        }
     }
//---------------------------------------------------------------------
//Indicator release
   if(AC!=INVALID_HANDLE)
      IndicatorRelease(AC);
//---
   if(ADX!=INVALID_HANDLE)
      IndicatorRelease(ADX);
//---
   if(AO!=INVALID_HANDLE)
      IndicatorRelease(AO);
//---
   if(DeMarker!=INVALID_HANDLE)
      IndicatorRelease(DeMarker);
//---
   if(BollingerBands!=INVALID_HANDLE)
      IndicatorRelease(BollingerBands);
//---
   if(Force!=INVALID_HANDLE)
      IndicatorRelease(Force);
//---
   if(MFI!=INVALID_HANDLE)
      IndicatorRelease(MFI);
//---
   if(MACD!=INVALID_HANDLE)
      IndicatorRelease(MACD);
//---
   if(STOCH!=INVALID_HANDLE)
      IndicatorRelease(STOCH);
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//OnTick function
//============================================================================================================================================================================================================================//
void OnTick()
  {
//---------------------------------------------------------------------
//Reset variables
   AC_OpenBuy=false;
   AC_OpenSell=false;
   AC_CloseBuy=false;
   AC_CloseSell=false;
//---
   ADX_OpenBuy=false;
   ADX_OpenSell=false;
   ADX_CloseBuy=false;
   ADX_CloseSell=false;
//---
   AO_OpenBuy=false;
   AO_OpenSell=false;
   AO_CloseBuy=false;
   AO_CloseSell=false;
//---
   DeM_OpenBuy=false;
   DeM_OpenSell=false;
   DeM_CloseBuy=false;
   DeM_CloseSell=false;
//---
   FBB_OpenBuy=false;
   FBB_OpenSell=false;
   FBB_CloseBuy=false;
   FBB_CloseSell=false;
//---
   MFI_OpenBuy=false;
   MFI_OpenSell=false;
   MFI_CloseBuy=false;
   MFI_CloseSell=false;
//---
   MS_OpenBuy=false;
   MS_OpenSell=false;
   MS_CloseBuy=false;
   MS_CloseSell=false;
//---------------------------------------------------------------------
//Check if expert is enabled and trades is allowed
   if((!MQLInfoInteger(MQL_TESTER))&&(!MQLInfoInteger(MQL_VISUAL_MODE))&&(!MQLInfoInteger(MQL_OPTIMIZATION)))
     {
      if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
        {
         Comment("\n      The trading terminal",
                 "\n      of experts do not run",
                 "\n\n\n      Turn ON EA Please .......");
         return;
        }
     }
//---------------------------------------------------------------------
//Call signals function
   if(LastTimeRunFunctions==0)
      LastTimeRunFunctions=iTime(SymbolTrade,TimeFrame,0);
//---
   if(iTime(SymbolTrade,TimeFrame,0)!=LastTimeRunFunctions)
     {
      LastTimeRunFunctions=iTime(SymbolTrade,TimeFrame,0);
      //---
      if(AC_StrategyRun==true)
         AC_GetSignals();
      //---
      if(ADX_StrategyRun==true)
         ADX_GetSignals();
      //---
      if(AO_StrategyRun==true)
         AO_GetSignals();
      //---
      if(DeM_StrategyRun==true)
         DeM_GetSignals();
      //---
      if(FBB_StrategyRun==true)
         FBB_GetSignals();
      //---
      if(MFI_StrategyRun==true)
         MFI_GetSignals();
      //---
      if(MS_StrategyRun==true)
         MS_GetSignals();
     }
//---------------------------------------------------------------------
//Call main function
   MainFunction();
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//Main function
//============================================================================================================================================================================================================================//
void MainFunction()
  {
//---------------------------------------------------------------------
//Reset variables
   AcceptedSpread=true;
   TimeToTrade=true;
   MarketIsOpen=false;
//---------------------------------------------------------------------
//Count current orders
   GetResultsCurrentOrders();
//---------------------------------------------------------------------
//Count history orders
   GetResultsHistoryOrders();
//---------------------------------------------------------------------
//Call comment
   if(ShowComments==true)
     {
      if(!MQLInfoInteger(MQL_OPTIMIZATION))
         CommentScreen();
     }
//---------------------------------------------------------------------
//Check if market is open
   if(!MQLInfoInteger(MQL_OPTIMIZATION))
     {
      MqlDateTime CurrentDateTime;
      TimeCurrent(CurrentDateTime);
      //---
      if((CurrentDateTime.day_of_week==0)&&(SymbolInfoSessionTrade(SymbolTrade,SUNDAY,0,TimeBegin,TimeEnd)==true))
        {
         if((TimeToString(TimeCurrent(),TIME_MINUTES)>TimeToString(TimeBegin,TIME_MINUTES))||(TimeToString(TimeCurrent(),TIME_MINUTES)<TimeToString(TimeEnd,TIME_MINUTES)))
            MarketIsOpen=true;
        }
      //---
      if((CurrentDateTime.day_of_week==1)&&(SymbolInfoSessionTrade(SymbolTrade,MONDAY,0,TimeBegin,TimeEnd)==true))
        {
         if((TimeToString(TimeCurrent(),TIME_MINUTES)>TimeToString(TimeBegin,TIME_MINUTES))||(TimeToString(TimeCurrent(),TIME_MINUTES)<TimeToString(TimeEnd,TIME_MINUTES)))
            MarketIsOpen=true;
        }
      //---
      if((CurrentDateTime.day_of_week==2)&&(SymbolInfoSessionTrade(SymbolTrade,TUESDAY,0,TimeBegin,TimeEnd)==true))
        {
         if((TimeToString(TimeCurrent(),TIME_MINUTES)>TimeToString(TimeBegin,TIME_MINUTES))||(TimeToString(TimeCurrent(),TIME_MINUTES)<TimeToString(TimeEnd,TIME_MINUTES)))
            MarketIsOpen=true;
        }
      //---
      if((CurrentDateTime.day_of_week==3)&&(SymbolInfoSessionTrade(SymbolTrade,WEDNESDAY,0,TimeBegin,TimeEnd)==true))
        {
         if((TimeToString(TimeCurrent(),TIME_MINUTES)>TimeToString(TimeBegin,TIME_MINUTES))||(TimeToString(TimeCurrent(),TIME_MINUTES)<TimeToString(TimeEnd,TIME_MINUTES)))
            MarketIsOpen=true;
        }
      //---
      if((CurrentDateTime.day_of_week==4)&&(SymbolInfoSessionTrade(SymbolTrade,THURSDAY,0,TimeBegin,TimeEnd)==true))
        {
         if((TimeToString(TimeCurrent(),TIME_MINUTES)>TimeToString(TimeBegin,TIME_MINUTES))||(TimeToString(TimeCurrent(),TIME_MINUTES)<TimeToString(TimeEnd,TIME_MINUTES)))
            MarketIsOpen=true;
        }
      //---
      if((CurrentDateTime.day_of_week==5)&&(SymbolInfoSessionTrade(SymbolTrade,FRIDAY,0,TimeBegin,TimeEnd)==true))
        {
         if((TimeToString(TimeCurrent(),TIME_MINUTES)>TimeToString(TimeBegin,TIME_MINUTES))||(TimeToString(TimeCurrent(),TIME_MINUTES)<TimeToString(TimeEnd,TIME_MINUTES)))
            MarketIsOpen=true;
        }
      //---
      if((CurrentDateTime.day_of_week==6)&&(SymbolInfoSessionTrade(SymbolTrade,SATURDAY,0,TimeBegin,TimeEnd)==true))
        {
         if((TimeToString(TimeCurrent(),TIME_MINUTES)>TimeToString(TimeBegin,TIME_MINUTES))||(TimeToString(TimeCurrent(),TIME_MINUTES)<TimeToString(TimeEnd,TIME_MINUTES)))
            MarketIsOpen=true;
        }
     }
   else
      MarketIsOpen=true;
//---------------------------------------------------------------------
//Set warning message on closed market
   if(MarketIsOpen==false)
     {
      if(PrintOperations==true)
         Print("Market is closed!!!");
     }
//---------------------------------------------------------------------
//Get spread
   Spread=(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)-SymbolInfoDouble(SymbolTrade,SYMBOL_BID))/SymbolPoints;
//---------------------------------------------------------------------
//Check spread
   if((Spread>MaxSpread)&&(MaxSpread>0))
     {
      AcceptedSpread=false;
      Print("Spread is greater than Max Spread!!! (Spread: "+DoubleToString(Spread,1)+" || MaxSpread: "+DoubleToString(MaxSpread,1)+")");
     }
//---------------------------------------------------------------------
//Stand by
   if(TypeOperation==0)
     {
      if(PrintOperations==true)
         Print("##### Expert is on Stand by Mode #####");
      //---
      return;
     }
//---------------------------------------------------------------------
//Close all orders and stop
   if((MarketIsOpen==true)&&(TypeOperation==2))
     {
      //---------------------------------------------------------------------
      if(AC_StrategyRun==true)
        {
         if(AC_BuyOrders>0)
            CloseOrders(ORDER_TYPE_BUY,-1,AC_OrdersID);
         //---
         if(AC_SellOrders>0)
            CloseOrders(ORDER_TYPE_SELL,-1,AC_OrdersID);
        }
      //---------------------------------------------------------------------
      if(ADX_StrategyRun==true)
        {
         if(ADX_BuyOrders>0)
            CloseOrders(ORDER_TYPE_BUY,-1,ADX_OrdersID);
         //---
         if(ADX_SellOrders>0)
            CloseOrders(ORDER_TYPE_SELL,-1,ADX_OrdersID);
        }
      //---------------------------------------------------------------------
      if(AO_StrategyRun==true)
        {
         if(AO_BuyOrders>0)
            CloseOrders(ORDER_TYPE_BUY,-1,AO_OrdersID);
         //---
         if(AO_SellOrders>0)
            CloseOrders(ORDER_TYPE_SELL,-1,AO_OrdersID);
        }
      //---------------------------------------------------------------------
      if(DeM_StrategyRun==true)
        {
         if(DeM_BuyOrders>0)
            CloseOrders(ORDER_TYPE_BUY,-1,DeM_OrdersID);
         //---
         if(DeM_SellOrders>0)
            CloseOrders(ORDER_TYPE_SELL,-1,DeM_OrdersID);
        }
      //---------------------------------------------------------------------
      if(FBB_StrategyRun==true)
        {
         if(FBB_BuyOrders>0)
            CloseOrders(ORDER_TYPE_BUY,-1,FBB_OrdersID);
         //---
         if(FBB_SellOrders>0)
            CloseOrders(ORDER_TYPE_SELL,-1,FBB_OrdersID);
        }
      //---------------------------------------------------------------------
      if(MFI_StrategyRun==true)
        {
         if(MFI_BuyOrders>0)
            CloseOrders(ORDER_TYPE_BUY,-1,MFI_OrdersID);
         //---
         if(MFI_SellOrders>0)
            CloseOrders(ORDER_TYPE_SELL,-1,MFI_OrdersID);
        }
      //---------------------------------------------------------------------
      if(MS_StrategyRun==true)
        {
         if(MS_BuyOrders>0)
            CloseOrders(ORDER_TYPE_BUY,-1,MS_OrdersID);
         //---
         if(MS_SellOrders>0)
            CloseOrders(ORDER_TYPE_SELL,-1,MS_OrdersID);
        }
      //---------------------------------------------------------------------
      if(PrintOperations==true)
         Print("##### Close all orders stop trade #####");
      //---
      return;
     }
//---------------------------------------------------------------------
//Control market session
   if(ControlSession==true)
     {
      MqlDateTime DateTime;
      TimeCurrent(DateTime);
      //---Wait on Monday
      if((DateTime.day_of_week==1)&&(SymbolInfoSessionTrade(SymbolTrade,MONDAY,0,TimeBegin,TimeEnd)==true))
        {
         if(TimeToString(TimeCurrent(),TIME_MINUTES)<TimeToString(TimeBegin+((WaitAfterOpen-1)*60),TIME_MINUTES))
            TimeToTrade=false;
        }
      //---Stop on Friday
      if((DateTime.day_of_week==5)&&(SymbolInfoSessionTrade(SymbolTrade,FRIDAY,0,TimeBegin,TimeEnd)==true))
        {
         if(TimeToString(TimeCurrent(),TIME_MINUTES)>TimeToString(TimeEnd-((StopBeforeClose-2)*60),TIME_MINUTES))
            TimeToTrade=false;
        }
     }
//---
   if(TimeToTrade==false)
      return;
//---------------------------------------------------------------------
//Close orders operations
   if(TypeOperation==1)
     {
      //---------------------------------------------------------------------
      if(AC_StrategyRun==true)
        {
         if((MarketIsOpen==true)&&(AC_SumOrders>0))
           {
            if((AC_BuyOrders>0)&&(AC_CloseBuy==true))
               CloseOrders(ORDER_TYPE_BUY,-1,AC_OrdersID);
            //---
            if((AC_SellOrders>0)&&(AC_CloseSell==true))
               CloseOrders(ORDER_TYPE_SELL,-1,AC_OrdersID);
           }
        }
      //---------------------------------------------------------------------
      if(ADX_StrategyRun==true)
        {
         if((MarketIsOpen==true)&&(ADX_SumOrders>0))
           {
            if((ADX_BuyOrders>0)&&(ADX_CloseBuy==true))
               CloseOrders(ORDER_TYPE_BUY,-1,ADX_OrdersID);
            //---
            if((ADX_SellOrders>0)&&(ADX_CloseSell==true))
               CloseOrders(ORDER_TYPE_SELL,-1,ADX_OrdersID);
           }
        }
      //---------------------------------------------------------------------
      if(AO_StrategyRun==true)
        {
         if((MarketIsOpen==true)&&(AO_SumOrders>0))
           {
            if((AO_BuyOrders>0)&&(AO_CloseBuy==true))
               CloseOrders(ORDER_TYPE_BUY,-1,AO_OrdersID);
            //---
            if((AO_SellOrders>0)&&(AO_CloseSell==true))
               CloseOrders(ORDER_TYPE_SELL,-1,AO_OrdersID);
           }
        }
      //---------------------------------------------------------------------
      if(DeM_StrategyRun==true)
        {
         if((MarketIsOpen==true)&&(DeM_SumOrders>0))
           {
            if((DeM_BuyOrders>0)&&(DeM_CloseBuy==true))
               CloseOrders(ORDER_TYPE_BUY,-1,DeM_OrdersID);
            //---
            if((DeM_SellOrders>0)&&(DeM_CloseSell==true))
               CloseOrders(ORDER_TYPE_SELL,-1,DeM_OrdersID);
           }
        }
      //---------------------------------------------------------------------
      if(FBB_StrategyRun==true)
        {
         if((MarketIsOpen==true)&&(FBB_SumOrders>0))
           {
            if((FBB_BuyOrders>0)&&(FBB_CloseBuy==true))
               CloseOrders(ORDER_TYPE_BUY,-1,FBB_OrdersID);
            //---
            if((FBB_SellOrders>0)&&(FBB_CloseSell==true))
               CloseOrders(ORDER_TYPE_SELL,-1,FBB_OrdersID);
           }
        }
      //---------------------------------------------------------------------
      if(MFI_StrategyRun==true)
        {
         if((MarketIsOpen==true)&&(MFI_SumOrders>0))
           {
            if((MFI_BuyOrders>0)&&(MFI_CloseBuy==true))
               CloseOrders(ORDER_TYPE_BUY,-1,MFI_OrdersID);
            //---
            if((MFI_SellOrders>0)&&(MFI_CloseSell==true))
               CloseOrders(ORDER_TYPE_SELL,-1,MFI_OrdersID);
           }
        }
      //---------------------------------------------------------------------
      if(MS_StrategyRun==true)
        {
         if((MarketIsOpen==true)&&(MS_SumOrders>0))
           {
            if((MS_BuyOrders>0)&&(MS_CloseBuy==true))
               CloseOrders(ORDER_TYPE_BUY,-1,MS_OrdersID);
            //---
            if((MS_SellOrders>0)&&(MS_CloseSell==true))
               CloseOrders(ORDER_TYPE_SELL,-1,MS_OrdersID);
           }
        }
      //---------------------------------------------------------------------
     }
//---------------------------------------------------------------------
//Open orders
   if(TypeOperation==1)
     {
      if((MarketIsOpen==true)&&(AcceptedSpread==true)&&((SumOrders<AcceptMaxOrders)||(AcceptMaxOrders==0)))
        {
         //---------------------------------------------------------------------
         if((AC_StrategyRun==true)&&((ADX_SumOrders+AO_SumOrders+DeM_SumOrders+FBB_SumOrders+MFI_SumOrders+MS_SumOrders==0)||(TradeAllStrategies==true)))
           {
            if((AC_OpenBuy==true)||(AC_OpenSell==true))
              {
               //---Open buy
               if((AC_OpenBuy==true)&&((AC_BuyOrders==0)||(MakeOrdersGrid>0))&&((TimeCurrent()-AC_TimeOpenLastBuy>=TimeBetweenOrders)||(AC_BuyOrders==0))&&
                  ((((MakeOrdersGrid==2)||(MakeOrdersGrid==3))&&((SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)-AC_PriceOpenHigherBuy)/SymbolPoints>=PipsBetweenOrders))||//Open in profit
                   (((MakeOrdersGrid==1)||(MakeOrdersGrid==3))&&((AC_PriceOpenLowerBuy-SymbolInfoDouble(SymbolTrade,SYMBOL_ASK))/SymbolPoints>=PipsBetweenOrders))||//Open in loss
                   (AC_BuyOrders==0)))
                 {
                  OpenOrders(ORDER_TYPE_BUY,AC_OrdersID);
                 }
               //---Open sell
               if((AC_OpenSell==true)&&((AC_SellOrders==0)||(MakeOrdersGrid>0))&&((TimeCurrent()-AC_TimeOpenLastSell>=TimeBetweenOrders)||(AC_SellOrders==0))&&
                  ((((MakeOrdersGrid==2)||(MakeOrdersGrid==3))&&((AC_PriceOpenLowerSell-SymbolInfoDouble(SymbolTrade,SYMBOL_BID))/SymbolPoints>=PipsBetweenOrders))||//Open in profit
                   (((MakeOrdersGrid==1)||(MakeOrdersGrid==3))&&((SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-AC_PriceOpenHigherSell)/SymbolPoints>=PipsBetweenOrders))||//Open in loss
                   (AC_SellOrders==0)))
                 {
                  OpenOrders(ORDER_TYPE_SELL,AC_OrdersID);
                 }
              }
           }
         //---------------------------------------------------------------------
         if((ADX_StrategyRun==true)&&((AC_SumOrders+AO_SumOrders+DeM_SumOrders+FBB_SumOrders+MFI_SumOrders+MS_SumOrders==0)||(TradeAllStrategies==true)))
           {
            if((ADX_OpenBuy==true)||(ADX_OpenSell==true))
              {
               //---Open buy
               if((ADX_OpenBuy==true)&&((ADX_BuyOrders==0)||(MakeOrdersGrid>0))&&((TimeCurrent()-ADX_TimeOpenLastBuy>=TimeBetweenOrders)||(ADX_BuyOrders==0))&&
                  ((((MakeOrdersGrid==2)||(MakeOrdersGrid==3))&&((SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)-ADX_PriceOpenHigherBuy)/SymbolPoints>=PipsBetweenOrders))||//Open in profit
                   (((MakeOrdersGrid==1)||(MakeOrdersGrid==3))&&((ADX_PriceOpenLowerBuy-SymbolInfoDouble(SymbolTrade,SYMBOL_ASK))/SymbolPoints>=PipsBetweenOrders))||//Open in loss
                   (ADX_BuyOrders==0)))
                 {
                  OpenOrders(ORDER_TYPE_BUY,ADX_OrdersID);
                 }
               //---Open sell
               if((ADX_OpenSell==true)&&((ADX_SellOrders==0)||(MakeOrdersGrid>0))&&((TimeCurrent()-ADX_TimeOpenLastSell>=TimeBetweenOrders)||(ADX_SellOrders==0))&&
                  ((((MakeOrdersGrid==2)||(MakeOrdersGrid==3))&&((ADX_PriceOpenLowerSell-SymbolInfoDouble(SymbolTrade,SYMBOL_BID))/SymbolPoints>=PipsBetweenOrders))||//Open in profit
                   (((MakeOrdersGrid==1)||(MakeOrdersGrid==3))&&((SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-ADX_PriceOpenHigherSell)/SymbolPoints>=PipsBetweenOrders))||//Open in loss
                   (ADX_SellOrders==0)))
                 {
                  OpenOrders(ORDER_TYPE_SELL,ADX_OrdersID);
                 }
              }
           }
         //---------------------------------------------------------------------
         if((AO_StrategyRun==true)&&((AC_SumOrders+ADX_SumOrders+DeM_SumOrders+FBB_SumOrders+MFI_SumOrders+MS_SumOrders==0)||(TradeAllStrategies==true)))
           {
            if((AO_OpenBuy==true)||(AO_OpenSell==true))
              {
               //---Open buy
               if((AO_OpenBuy==true)&&((AO_BuyOrders==0)||(MakeOrdersGrid>0))&&((TimeCurrent()-AO_TimeOpenLastBuy>=TimeBetweenOrders)||(AO_BuyOrders==0))&&
                  ((((MakeOrdersGrid==2)||(MakeOrdersGrid==3))&&((SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)-AO_PriceOpenHigherBuy)/SymbolPoints>=PipsBetweenOrders))||//Open in profit
                   (((MakeOrdersGrid==1)||(MakeOrdersGrid==3))&&((AO_PriceOpenLowerBuy-SymbolInfoDouble(SymbolTrade,SYMBOL_ASK))/SymbolPoints>=PipsBetweenOrders))||//Open in loss
                   (AO_BuyOrders==0)))
                 {
                  OpenOrders(ORDER_TYPE_BUY,AO_OrdersID);
                 }
               //---Open sell
               if((AO_OpenSell==true)&&((AO_SellOrders==0)||(MakeOrdersGrid>0))&&((TimeCurrent()-AO_TimeOpenLastSell>=TimeBetweenOrders)||(AO_SellOrders==0))&&
                  ((((MakeOrdersGrid==2)||(MakeOrdersGrid==3))&&((AO_PriceOpenLowerSell-SymbolInfoDouble(SymbolTrade,SYMBOL_BID))/SymbolPoints>=PipsBetweenOrders))||//Open in profit
                   (((MakeOrdersGrid==1)||(MakeOrdersGrid==3))&&((SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-AO_PriceOpenHigherSell)/SymbolPoints>=PipsBetweenOrders))||//Open in loss
                   (AO_SellOrders==0)))
                 {
                  OpenOrders(ORDER_TYPE_SELL,AO_OrdersID);
                 }
              }
           }
         //---------------------------------------------------------------------
         if((DeM_StrategyRun==true)&&((AC_SumOrders+ADX_SumOrders+AO_SumOrders+FBB_SumOrders+MFI_SumOrders+MS_SumOrders==0)||(TradeAllStrategies==true)))
           {
            if((DeM_OpenBuy==true)||(DeM_OpenSell==true))
              {
               //---Open buy
               if((DeM_OpenBuy==true)&&((DeM_BuyOrders==0)||(MakeOrdersGrid>0))&&((TimeCurrent()-DeM_TimeOpenLastBuy>=TimeBetweenOrders)||(DeM_BuyOrders==0))&&
                  ((((MakeOrdersGrid==2)||(MakeOrdersGrid==3))&&((SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)-DeM_PriceOpenHigherBuy)/SymbolPoints>=PipsBetweenOrders))||//Open in profit
                   (((MakeOrdersGrid==1)||(MakeOrdersGrid==3))&&((DeM_PriceOpenLowerBuy-SymbolInfoDouble(SymbolTrade,SYMBOL_ASK))/SymbolPoints>=PipsBetweenOrders))||//Open in loss
                   (DeM_BuyOrders==0)))
                 {
                  OpenOrders(ORDER_TYPE_BUY,DeM_OrdersID);
                 }
               //---Open sell
               if((DeM_OpenSell==true)&&((DeM_SellOrders==0)||(MakeOrdersGrid>0))&&((TimeCurrent()-DeM_TimeOpenLastSell>=TimeBetweenOrders)||(DeM_SellOrders==0))&&
                  ((((MakeOrdersGrid==2)||(MakeOrdersGrid==3))&&((DeM_PriceOpenLowerSell-SymbolInfoDouble(SymbolTrade,SYMBOL_BID))/SymbolPoints>=PipsBetweenOrders))||//Open in profit
                   (((MakeOrdersGrid==1)||(MakeOrdersGrid==3))&&((SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-DeM_PriceOpenHigherSell)/SymbolPoints>=PipsBetweenOrders))||//Open in loss
                   (DeM_SellOrders==0)))
                 {
                  OpenOrders(ORDER_TYPE_SELL,DeM_OrdersID);
                 }
              }
           }
         //---------------------------------------------------------------------
         if((FBB_StrategyRun==true)&&((AC_SumOrders+ADX_SumOrders+AO_SumOrders+DeM_SumOrders+MFI_SumOrders+MS_SumOrders==0)||(TradeAllStrategies==true)))
           {
            if((FBB_OpenBuy==true)||(FBB_OpenSell==true))
              {
               //---Open buy
               if((FBB_OpenBuy==true)&&((FBB_BuyOrders==0)||(MakeOrdersGrid>0))&&((TimeCurrent()-FBB_TimeOpenLastBuy>=TimeBetweenOrders)||(FBB_BuyOrders==0))&&
                  ((((MakeOrdersGrid==2)||(MakeOrdersGrid==3))&&((SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)-FBB_PriceOpenHigherBuy)/SymbolPoints>=PipsBetweenOrders))||//Open in profit
                   (((MakeOrdersGrid==1)||(MakeOrdersGrid==3))&&((FBB_PriceOpenLowerBuy-SymbolInfoDouble(SymbolTrade,SYMBOL_ASK))/SymbolPoints>=PipsBetweenOrders))||//Open in loss
                   (FBB_BuyOrders==0)))
                 {
                  OpenOrders(ORDER_TYPE_BUY,FBB_OrdersID);
                 }
               //---Open sell
               if((FBB_OpenSell==true)&&((FBB_SellOrders==0)||(MakeOrdersGrid>0))&&((TimeCurrent()-FBB_TimeOpenLastSell>=TimeBetweenOrders)||(FBB_SellOrders==0))&&
                  ((((MakeOrdersGrid==2)||(MakeOrdersGrid==3))&&((FBB_PriceOpenLowerSell-SymbolInfoDouble(SymbolTrade,SYMBOL_BID))/SymbolPoints>=PipsBetweenOrders))||//Open in profit
                   (((MakeOrdersGrid==1)||(MakeOrdersGrid==3))&&((SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-FBB_PriceOpenHigherSell)/SymbolPoints>=PipsBetweenOrders))||//Open in loss
                   (FBB_SellOrders==0)))
                 {
                  OpenOrders(ORDER_TYPE_SELL,FBB_OrdersID);
                 }
              }
           }
         //---------------------------------------------------------------------
         if((MFI_StrategyRun==true)&&((AC_SumOrders+ADX_SumOrders+AO_SumOrders+DeM_SumOrders+FBB_SumOrders+MS_SumOrders==0)||(TradeAllStrategies==true)))
           {
            if((MFI_OpenBuy==true)||(MFI_OpenSell==true))
              {
               //---Open buy
               if((MFI_OpenBuy==true)&&((MFI_BuyOrders==0)||(MakeOrdersGrid>0))&&((TimeCurrent()-MFI_TimeOpenLastBuy>=TimeBetweenOrders)||(MFI_BuyOrders==0))&&
                  ((((MakeOrdersGrid==2)||(MakeOrdersGrid==3))&&((SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)-MFI_PriceOpenHigherBuy)/SymbolPoints>=PipsBetweenOrders))||//Open in profit
                   (((MakeOrdersGrid==1)||(MakeOrdersGrid==3))&&((MFI_PriceOpenLowerBuy-SymbolInfoDouble(SymbolTrade,SYMBOL_ASK))/SymbolPoints>=PipsBetweenOrders))||//Open in loss
                   (MFI_BuyOrders==0)))
                 {
                  OpenOrders(ORDER_TYPE_BUY,MFI_OrdersID);
                 }
               //---Open sell
               if((MFI_OpenSell==true)&&((MFI_SellOrders==0)||(MakeOrdersGrid>0))&&((TimeCurrent()-MFI_TimeOpenLastSell>=TimeBetweenOrders)||(MFI_SellOrders==0))&&
                  ((((MakeOrdersGrid==2)||(MakeOrdersGrid==3))&&((MFI_PriceOpenLowerSell-SymbolInfoDouble(SymbolTrade,SYMBOL_BID))/SymbolPoints>=PipsBetweenOrders))||//Open in profit
                   (((MakeOrdersGrid==1)||(MakeOrdersGrid==3))&&((SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-MFI_PriceOpenHigherSell)/SymbolPoints>=PipsBetweenOrders))||//Open in loss
                   (MFI_SellOrders==0)))
                 {
                  OpenOrders(ORDER_TYPE_SELL,MFI_OrdersID);
                 }
              }
           }
         //---------------------------------------------------------------------
         if((MS_StrategyRun==true)&&((AC_SumOrders+ADX_SumOrders+AO_SumOrders+DeM_SumOrders+FBB_SumOrders+MFI_SumOrders==0)||(TradeAllStrategies==true)))
           {
            if((MS_OpenBuy==true)||(MS_OpenSell==true))
              {
               //---Open buy
               if((MS_OpenBuy==true)&&((MS_BuyOrders==0)||(MakeOrdersGrid>0))&&((TimeCurrent()-MS_TimeOpenLastBuy>=TimeBetweenOrders)||(MS_BuyOrders==0))&&
                  ((((MakeOrdersGrid==2)||(MakeOrdersGrid==3))&&((SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)-MS_PriceOpenHigherBuy)/SymbolPoints>=PipsBetweenOrders))||//Open in profit
                   (((MakeOrdersGrid==1)||(MakeOrdersGrid==3))&&((MS_PriceOpenLowerBuy-SymbolInfoDouble(SymbolTrade,SYMBOL_ASK))/SymbolPoints>=PipsBetweenOrders))||//Open in loss
                   (MS_BuyOrders==0)))
                 {
                  OpenOrders(ORDER_TYPE_BUY,MS_OrdersID);
                 }
               //---Open sell
               if((MS_OpenSell==true)&&((MS_SellOrders==0)||(MakeOrdersGrid>0))&&((TimeCurrent()-MS_TimeOpenLastSell>=TimeBetweenOrders)||(MS_SellOrders==0))&&
                  ((((MakeOrdersGrid==2)||(MakeOrdersGrid==3))&&((MS_PriceOpenLowerSell-SymbolInfoDouble(SymbolTrade,SYMBOL_BID))/SymbolPoints>=PipsBetweenOrders))||//Open in profit
                   (((MakeOrdersGrid==1)||(MakeOrdersGrid==3))&&((SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-MS_PriceOpenHigherSell)/SymbolPoints>=PipsBetweenOrders))||//Open in loss
                   (MS_SellOrders==0)))
                 {
                  OpenOrders(ORDER_TYPE_SELL,MS_OrdersID);
                 }
              }
           }
         //---------------------------------------------------------------------
        }
     }
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//Open orders
//============================================================================================================================================================================================================================//
void OpenOrders(int TypeOfOrder, int MagicOrder)
  {
//---------------------------------------------------------------------
//Set variables
   int OpenOrderTicket=-1;
   double OpenPrice=0;
   color OpenColor=clrNONE;
   string TypeOfOrderStr;
   double OrdrLotSize=0;
   double CheckMargin=0;
   double TP=0;
   double SL=0;
   bool LowMargin=false;
   double OrderTP=0;
   double OrderSL=0;
   string CommentOrders="";
//---------------------------------------------------------------------
   if(CloseInReverse==true)
     {
      if(TypeOfOrder==ORDER_TYPE_BUY)
        {
         if(AC_SellOrders>0)
            CloseOrders(ORDER_TYPE_SELL,-1,AC_OrdersID);
         //---
         if(ADX_SellOrders>0)
            CloseOrders(ORDER_TYPE_SELL,-1,ADX_OrdersID);
         //---
         if(AO_SellOrders>0)
            CloseOrders(ORDER_TYPE_SELL,-1,AO_OrdersID);
         //---
         if(DeM_SellOrders>0)
            CloseOrders(ORDER_TYPE_SELL,-1,DeM_OrdersID);
         //---
         if(FBB_SellOrders>0)
            CloseOrders(ORDER_TYPE_SELL,-1,FBB_OrdersID);
         //---
         if(MFI_SellOrders>0)
            CloseOrders(ORDER_TYPE_SELL,-1,MFI_OrdersID);
         //---
         if(MS_SellOrders>0)
            CloseOrders(ORDER_TYPE_SELL,-1,MS_OrdersID);
        }
      //---
      if(TypeOfOrder==ORDER_TYPE_SELL)
        {
         if(AC_BuyOrders>0)
            CloseOrders(ORDER_TYPE_BUY,-1,AC_OrdersID);
         //---
         if(ADX_BuyOrders>0)
            CloseOrders(ORDER_TYPE_BUY,-1,ADX_OrdersID);
         //---
         if(AO_BuyOrders>0)
            CloseOrders(ORDER_TYPE_BUY,-1,AO_OrdersID);
         //---
         if(DeM_BuyOrders>0)
            CloseOrders(ORDER_TYPE_BUY,-1,DeM_OrdersID);
         //---
         if(FBB_BuyOrders>0)
            CloseOrders(ORDER_TYPE_BUY,-1,FBB_OrdersID);
         //---
         if(MFI_BuyOrders>0)
            CloseOrders(ORDER_TYPE_BUY,-1,MFI_OrdersID);
         //---
         if(MS_BuyOrders>0)
            CloseOrders(ORDER_TYPE_BUY,-1,MS_OrdersID);
        }
     }
//---------------------------------------------------------------------
//AC_Calculate take profit and stop loss and lot size
   if(MagicOrder==AC_OrdersID)
     {
      OrderTP=NormalizeDouble(AC_PipsTakeProfit*SymbolPoints,SymbolDigits);
      OrderSL=NormalizeDouble(AC_PipsStopLoss*SymbolPoints,SymbolDigits);
      OrdrLotSize=CalcLots(TypeOfOrder,MagicOrder);
      CommentOrders="AC_Strategy";
     }
//---------------------------------------------------------------------
//ADX_Calculate take profit and stop loss and lot size
   if(MagicOrder==ADX_OrdersID)
     {
      OrderTP=NormalizeDouble(ADX_PipsTakeProfit*SymbolPoints,SymbolDigits);
      OrderSL=NormalizeDouble(ADX_PipsStopLoss*SymbolPoints,SymbolDigits);
      OrdrLotSize=CalcLots(TypeOfOrder,MagicOrder);
      CommentOrders="ADX_Strategy";
     }
//---------------------------------------------------------------------
//AO_Calculate take profit and stop loss and lot size
   if(MagicOrder==AO_OrdersID)
     {
      OrderTP=NormalizeDouble(AO_PipsTakeProfit*SymbolPoints,SymbolDigits);
      OrderSL=NormalizeDouble(AO_PipsStopLoss*SymbolPoints,SymbolDigits);
      OrdrLotSize=CalcLots(TypeOfOrder,MagicOrder);
      CommentOrders="AO_Strategy";
     }
//---------------------------------------------------------------------
//DeM_Calculate take profit and stop loss and lot size
   if(MagicOrder==DeM_OrdersID)
     {
      OrderTP=NormalizeDouble(DeM_PipsTakeProfit*SymbolPoints,SymbolDigits);
      OrderSL=NormalizeDouble(DeM_PipsStopLoss*SymbolPoints,SymbolDigits);
      OrdrLotSize=CalcLots(TypeOfOrder,MagicOrder);
      CommentOrders="DeM_Strategy";
     }
//---------------------------------------------------------------------
//FBB_Calculate take profit and stop loss and lot size
   if(MagicOrder==FBB_OrdersID)
     {
      OrderTP=NormalizeDouble(FBB_PipsTakeProfit*SymbolPoints,SymbolDigits);
      OrderSL=NormalizeDouble(FBB_PipsStopLoss*SymbolPoints,SymbolDigits);
      OrdrLotSize=CalcLots(TypeOfOrder,MagicOrder);
      CommentOrders="ForceBB_Strategy";
     }
//---------------------------------------------------------------------
//MFI_Calculate take profit and stop loss and lot size
   if(MagicOrder==MFI_OrdersID)
     {
      OrderTP=NormalizeDouble(MFI_PipsTakeProfit*SymbolPoints,SymbolDigits);
      OrderSL=NormalizeDouble(MFI_PipsStopLoss*SymbolPoints,SymbolDigits);
      OrdrLotSize=CalcLots(TypeOfOrder,MagicOrder);
      CommentOrders="MFI_Strategy";
     }
//---------------------------------------------------------------------
//MS_Calculate take profit and stop loss and lot size
   if(MagicOrder==MS_OrdersID)
     {
      OrderTP=NormalizeDouble(MS_PipsTakeProfit*SymbolPoints,SymbolDigits);
      OrderSL=NormalizeDouble(MS_PipsStopLoss*SymbolPoints,SymbolDigits);
      OrdrLotSize=CalcLots(TypeOfOrder,MagicOrder);
      CommentOrders="MS_Strategy";
     }
//---------------------------------------------------------------------
//Set buy stop loss and take profit in price
   if(TypeOfOrder==ORDER_TYPE_BUY)
     {
      OpenColor=clrBlue;
      TypeOfOrderStr="Buy";
      OpenPrice=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK),SymbolDigits);
      //---------------------------------------------------------------------
      if(MagicOrder==AC_OrdersID)
        {
         if((AC_TakeProfit>0)&&((AC_TypeOfLevelsUse==0)||(AC_TypeOfLevelsUse==2)))
            TP=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)+OrderTP,SymbolDigits);
         if((AC_StopLoss>0)&&((AC_TypeOfLevelsUse==0)||(AC_TypeOfLevelsUse==2)))
            SL=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-OrderSL,SymbolDigits);
        }
      //---------------------------------------------------------------------
      if(MagicOrder==ADX_OrdersID)
        {
         if((ADX_TakeProfit>0)&&((ADX_TypeOfLevelsUse==0)||(ADX_TypeOfLevelsUse==2)))
            TP=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)+OrderTP,SymbolDigits);
         if((ADX_StopLoss>0)&&((ADX_TypeOfLevelsUse==0)||(ADX_TypeOfLevelsUse==2)))
            SL=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-OrderSL,SymbolDigits);
        }
      //---------------------------------------------------------------------
      if(MagicOrder==AO_OrdersID)
        {
         if((AO_TakeProfit>0)&&((AO_TypeOfLevelsUse==0)||(AO_TypeOfLevelsUse==2)))
            TP=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)+OrderTP,SymbolDigits);
         if((AO_StopLoss>0)&&((AO_TypeOfLevelsUse==0)||(AO_TypeOfLevelsUse==2)))
            SL=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-OrderSL,SymbolDigits);
        }
      //---------------------------------------------------------------------
      if(MagicOrder==DeM_OrdersID)
        {
         if((DeM_TakeProfit>0)&&((DeM_TypeOfLevelsUse==0)||(DeM_TypeOfLevelsUse==2)))
            TP=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)+OrderTP,SymbolDigits);
         if((DeM_StopLoss>0)&&((DeM_TypeOfLevelsUse==0)||(DeM_TypeOfLevelsUse==2)))
            SL=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-OrderSL,SymbolDigits);
        }
      //---------------------------------------------------------------------
      if(MagicOrder==FBB_OrdersID)
        {
         if((FBB_TakeProfit>0)&&((FBB_TypeOfLevelsUse==0)||(FBB_TypeOfLevelsUse==2)))
            TP=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)+OrderTP,SymbolDigits);
         if((FBB_StopLoss>0)&&((FBB_TypeOfLevelsUse==0)||(FBB_TypeOfLevelsUse==2)))
            SL=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-OrderSL,SymbolDigits);
        }
      //---------------------------------------------------------------------
      if(MagicOrder==MFI_OrdersID)
        {
         if((MFI_TakeProfit>0)&&((MFI_TypeOfLevelsUse==0)||(MFI_TypeOfLevelsUse==2)))
            TP=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)+OrderTP,SymbolDigits);
         if((MFI_StopLoss>0)&&((MFI_TypeOfLevelsUse==0)||(MFI_TypeOfLevelsUse==2)))
            SL=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-OrderSL,SymbolDigits);
        }
      //---------------------------------------------------------------------
      if(MagicOrder==MS_OrdersID)
        {
         if((MS_TakeProfit>0)&&((MS_TypeOfLevelsUse==0)||(MS_TypeOfLevelsUse==2)))
            TP=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)+OrderTP,SymbolDigits);
         if((MS_StopLoss>0)&&((MS_TypeOfLevelsUse==0)||(MS_TypeOfLevelsUse==2)))
            SL=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-OrderSL,SymbolDigits);
        }
      //---------------------------------------------------------------------
     }
//---------------------------------------------------------------------
//Set sell stop loss and take profit in price
   if(TypeOfOrder==ORDER_TYPE_SELL)
     {
      OpenColor=clrRed;
      TypeOfOrderStr="Sell";
      OpenPrice=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_BID),SymbolDigits);
      //---------------------------------------------------------------------
      if(MagicOrder==AC_OrdersID)
        {
         if((AC_TakeProfit>0)&&((AC_TypeOfLevelsUse==0)||(AC_TypeOfLevelsUse==2)))
            TP=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-OrderTP,SymbolDigits);
         if((AC_StopLoss>0)&&((AC_TypeOfLevelsUse==0)||(AC_TypeOfLevelsUse==2)))
            SL=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)+OrderSL,SymbolDigits);
        }
      //---------------------------------------------------------------------
      if(MagicOrder==ADX_OrdersID)
        {
         if((ADX_TakeProfit>0)&&((ADX_TypeOfLevelsUse==0)||(ADX_TypeOfLevelsUse==2)))
            TP=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)+OrderTP,SymbolDigits);
         if((ADX_StopLoss>0)&&((ADX_TypeOfLevelsUse==0)||(ADX_TypeOfLevelsUse==2)))
            SL=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-OrderSL,SymbolDigits);
        }
      //---------------------------------------------------------------------
      if(MagicOrder==AO_OrdersID)
        {
         if((AO_TakeProfit>0)&&((AO_TypeOfLevelsUse==0)||(AO_TypeOfLevelsUse==2)))
            TP=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)+OrderTP,SymbolDigits);
         if((AO_StopLoss>0)&&((AO_TypeOfLevelsUse==0)||(AO_TypeOfLevelsUse==2)))
            SL=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-OrderSL,SymbolDigits);
        }
      //---------------------------------------------------------------------
      if(MagicOrder==DeM_OrdersID)
        {
         if((DeM_TakeProfit>0)&&((DeM_TypeOfLevelsUse==0)||(DeM_TypeOfLevelsUse==2)))
            TP=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)+OrderTP,SymbolDigits);
         if((DeM_StopLoss>0)&&((DeM_TypeOfLevelsUse==0)||(DeM_TypeOfLevelsUse==2)))
            SL=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-OrderSL,SymbolDigits);
        }
      //---------------------------------------------------------------------
      if(MagicOrder==FBB_OrdersID)
        {
         if((FBB_TakeProfit>0)&&((FBB_TypeOfLevelsUse==0)||(FBB_TypeOfLevelsUse==2)))
            TP=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)+OrderTP,SymbolDigits);
         if((FBB_StopLoss>0)&&((FBB_TypeOfLevelsUse==0)||(FBB_TypeOfLevelsUse==2)))
            SL=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-OrderSL,SymbolDigits);
        }
      //---------------------------------------------------------------------
      if(MagicOrder==MFI_OrdersID)
        {
         if((MFI_TakeProfit>0)&&((MFI_TypeOfLevelsUse==0)||(MFI_TypeOfLevelsUse==2)))
            TP=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)+OrderTP,SymbolDigits);
         if((MFI_StopLoss>0)&&((MFI_TypeOfLevelsUse==0)||(MFI_TypeOfLevelsUse==2)))
            SL=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-OrderSL,SymbolDigits);
        }
      //---------------------------------------------------------------------
      if(MagicOrder==MS_OrdersID)
        {
         if((MS_TakeProfit>0)&&((MS_TypeOfLevelsUse==0)||(MS_TypeOfLevelsUse==2)))
            TP=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)+OrderTP,SymbolDigits);
         if((MS_StopLoss>0)&&((MS_TypeOfLevelsUse==0)||(MS_TypeOfLevelsUse==2)))
            SL=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-OrderSL,SymbolDigits);
        }
      //---------------------------------------------------------------------
     }
//---------------------------------------------------------------------
//Check free margin
   if(OrderCalcMargin((ENUM_ORDER_TYPE)TypeOfOrder,SymbolTrade,OrdrLotSize,OpenPrice,CheckMargin))
     {
      if(AccountInfoDouble(ACCOUNT_MARGIN_FREE)<CheckMargin)
         LowMargin=true;
     }
//---
   if(LowMargin==true)
     {
      Print("<NOTICE...[ "+ExpertName+": Free margin is low ("+DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE)-CheckMargin,2)+"). Expert can't open new position with "+DoubleToString(OrdrLotSize,2)+" lot size ]...NOTICE>");
      Sleep(60000);
      return;
     }
//---------------------------------------------------------------------
//Declare and initialize the trade request and result of trade request
   MqlTradeCheckResult check= {};
   MqlTradeRequest request= {};
   MqlTradeResult result= {};
//---
   request.action=TRADE_ACTION_DEAL;
   request.magic=MagicOrder;
   request.symbol=SymbolTrade;
   request.volume=OrdrLotSize;
   request.price=OpenPrice;
   request.type=(ENUM_ORDER_TYPE)TypeOfOrder;
   request.comment=CommentOrders;
   request.sl=SL;
   request.tp=TP;
//---Set filling mode
   if(SymbolInfoInteger(SymbolTrade,SYMBOL_FILLING_MODE)==1)
      request.type_filling=ORDER_FILLING_FOK;
   if(SymbolInfoInteger(SymbolTrade,SYMBOL_FILLING_MODE)==2)
      request.type_filling=ORDER_FILLING_IOC;
//---------------------------------------------------------------------
//Send order
   CountTimes=0;
//---
   if(OrderCheck(request,check))
     {
      while(SymbolInfoInteger(SymbolTrade,SYMBOL_TRADE_MODE)==SYMBOL_TRADE_MODE_FULL)
        {
         CountTimes++;
         //---Send the request
         OpenOrderTicket=OrderSend(request,result);
         //---
         if(OpenOrderTicket>0)
           {
            if(SoundAlert==true)
               PlaySound(SoundAtOpen);
            if(PrintOperations==true)
               Print("Open: ",SymbolTrade," ",TypeOfOrderStr,".");
            break;
           }
         else
           {
            Print("Expert get an error: ",GetLastError());
           }
         //---
         Sleep(100);
         //---
         if(CountTimes>3)
           {
            Print("Failed open Order: ",TypeOfOrder);
            break;
           }
        }
     }
   else
     {
      Print("Expert generate an error: "+IntegerToString(GetLastError()));
     }
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//Close orders
//============================================================================================================================================================================================================================//
void CloseOrders(int TypeOfOrder, long TicketOfOrder, int MagicOrders)
  {
//---------------------------------------------------------------------
//Set variables
   bool CloseOrderTicket=false;
   string TypeOfOrderStr;
//---------------------------------------------------------------------
//Set type of order
   if(TypeOfOrder==ORDER_TYPE_BUY)
      TypeOfOrderStr="Buy";
   if(TypeOfOrder==ORDER_TYPE_SELL)
      TypeOfOrderStr="Sell";
//---------------------------------------------------------------------
//Declare and initialize the trade request and result of trade request
   MqlTradeRequest request;
   MqlTradeResult result;
//---------------------------------------------------------------------
//Iterate over all open positions
   for(i=PositionsTotal()-1; i>=0; i--)
     {
      //---Parameters of the order
      ulong position_ticket=PositionGetTicket(i);
      string position_symbol=PositionGetString(POSITION_SYMBOL);
      int digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);
      ulong magic=PositionGetInteger(POSITION_MAGIC);
      double volume=PositionGetDouble(POSITION_VOLUME);
      string CommentOrders=PositionGetString(POSITION_COMMENT);
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      //---If the MagicNumber matches
      if((magic==MagicOrders)&&(position_symbol==SymbolTrade)&&(type==(ENUM_POSITION_TYPE)TypeOfOrder)&&((position_ticket==TicketOfOrder)||(TicketOfOrder==-1)))
        {
         //---Zeroing the request and result values
         ZeroMemory(request);
         ZeroMemory(result);
         //---Setting the operation parameters
         request.action=TRADE_ACTION_DEAL;
         request.position=position_ticket;
         request.symbol=position_symbol;
         request.volume=volume;
         request.deviation=5;
         request.magic=MagicOrders;
         request.comment=CommentOrders;
         //---Set filling mode
         if(SymbolInfoInteger(SymbolTrade,SYMBOL_FILLING_MODE)==1)
            request.type_filling=ORDER_FILLING_FOK;
         if(SymbolInfoInteger(SymbolTrade,SYMBOL_FILLING_MODE)==2)
            request.type_filling=ORDER_FILLING_IOC;
         //---Set the price and order type depending on the position type
         if(type==POSITION_TYPE_BUY)
           {
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);
            request.type=ORDER_TYPE_SELL;
           }
         else
           {
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
            request.type=ORDER_TYPE_BUY;
           }
         //---------------------------------------------------------------------
         //Close position
         CountTimes=0;
         while(SymbolInfoInteger(SymbolTrade,SYMBOL_TRADE_MODE)==SYMBOL_TRADE_MODE_FULL)
           {
            CountTimes++;
            //---Send the request
            CloseOrderTicket=OrderSend(request,result);
            //---
            if(CloseOrderTicket>0)
              {
               if(SoundAlert==true)
                  PlaySound(SoundAtClose);
               if(PrintOperations==true)
                  Print("Close: ",SymbolTrade," ",TypeOfOrderStr,".");
               break;
              }
            else
              {
               Print("Expert get an error: ",GetLastError());
              }
            //---
            Sleep(100);
            //---
            if(CountTimes>3)
              {
               Print("Failed close Order: ",TypeOfOrder);
               break;
              }
           }
         //---
        }
     }
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//Current results
//============================================================================================================================================================================================================================//
void GetResultsCurrentOrders()
  {
//---------------------------------------------------------------------
//AC_Set variables
   double AC_OrderTP=NormalizeDouble(AC_PipsTakeProfit*SymbolPoints,SymbolDigits);
   double AC_OrderSL=NormalizeDouble(AC_PipsStopLoss*SymbolPoints,SymbolDigits);
   double AC_TP=0;
   double AC_SL=0;
//---------------------------------------------------------------------
//ADX_Set variables
   double ADX_OrderTP=NormalizeDouble(ADX_PipsTakeProfit*SymbolPoints,SymbolDigits);
   double ADX_OrderSL=NormalizeDouble(ADX_PipsStopLoss*SymbolPoints,SymbolDigits);
   double ADX_TP=0;
   double ADX_SL=0;
//---------------------------------------------------------------------
//AO_Set variables
   double AO_OrderTP=NormalizeDouble(AO_PipsTakeProfit*SymbolPoints,SymbolDigits);
   double AO_OrderSL=NormalizeDouble(AO_PipsStopLoss*SymbolPoints,SymbolDigits);
   double AO_TP=0;
   double AO_SL=0;
//---------------------------------------------------------------------
//DeM_Set variables
   double DeM_OrderTP=NormalizeDouble(DeM_PipsTakeProfit*SymbolPoints,SymbolDigits);
   double DeM_OrderSL=NormalizeDouble(DeM_PipsStopLoss*SymbolPoints,SymbolDigits);
   double DeM_TP=0;
   double DeM_SL=0;
//---------------------------------------------------------------------
//FBB_Set variables
   double FBB_OrderTP=NormalizeDouble(FBB_PipsTakeProfit*SymbolPoints,SymbolDigits);
   double FBB_OrderSL=NormalizeDouble(FBB_PipsStopLoss*SymbolPoints,SymbolDigits);
   double FBB_TP=0;
   double FBB_SL=0;
//---------------------------------------------------------------------
//MFI_Set variables
   double MFI_OrderTP=NormalizeDouble(MFI_PipsTakeProfit*SymbolPoints,SymbolDigits);
   double MFI_OrderSL=NormalizeDouble(MFI_PipsStopLoss*SymbolPoints,SymbolDigits);
   double MFI_TP=0;
   double MFI_SL=0;
//---------------------------------------------------------------------
//MS_Set variables
   double MS_OrderTP=NormalizeDouble(MS_PipsTakeProfit*SymbolPoints,SymbolDigits);
   double MS_OrderSL=NormalizeDouble(MS_PipsStopLoss*SymbolPoints,SymbolDigits);
   double MS_TP=0;
   double MS_SL=0;
//---------------------------------------------------------------------
//Reset variables
   Floating=0;
   SumOrders=0;
//---------------------------------------------------------------------
   AC_SumOrders=0;
   AC_BuyOrders=0;
   AC_SellOrders=0;
   AC_TimeOpenLastBuy=0;
   AC_TimeOpenLastSell=0;
   AC_PriceOpenLastBuy=0;
   AC_PriceOpenLastSell=0;
   AC_FloatingBuy=0;
   AC_FloatingSell=0;
   AC_TotalLotsBuy=0;
   AC_TotalLotsSell=0;
   AC_TicketFirstBuy=-1;
   AC_TicketFirstSell=-1;
   AC_TypeOfLastOrder=0;
   AC_LotFirstBuy=0;
   AC_LotFirstSell=0;
   AC_PriceOpenHigherBuy=-99999;
   AC_PriceOpenLowerBuy=99999;
   AC_PriceOpenHigherSell=-99999;
   AC_PriceOpenLowerSell=99999;
   AC_PipsBuyOrders=0;
   AC_PipsSellOrders=0;
//---------------------------------------------------------------------
   ADX_SumOrders=0;
   ADX_BuyOrders=0;
   ADX_SellOrders=0;
   ADX_TimeOpenLastBuy=0;
   ADX_TimeOpenLastSell=0;
   ADX_PriceOpenLastBuy=0;
   ADX_PriceOpenLastSell=0;
   ADX_FloatingBuy=0;
   ADX_FloatingSell=0;
   ADX_TotalLotsBuy=0;
   ADX_TotalLotsSell=0;
   ADX_TicketFirstBuy=-1;
   ADX_TicketFirstSell=-1;
   ADX_TypeOfLastOrder=0;
   ADX_LotFirstBuy=0;
   ADX_LotFirstSell=0;
   ADX_PriceOpenHigherBuy=-99999;
   ADX_PriceOpenLowerBuy=99999;
   ADX_PriceOpenHigherSell=-99999;
   ADX_PriceOpenLowerSell=99999;
   ADX_PipsBuyOrders=0;
   ADX_PipsSellOrders=0;
//---------------------------------------------------------------------
   AO_SumOrders=0;
   AO_BuyOrders=0;
   AO_SellOrders=0;
   AO_TimeOpenLastBuy=0;
   AO_TimeOpenLastSell=0;
   AO_PriceOpenLastBuy=0;
   AO_PriceOpenLastSell=0;
   AO_FloatingBuy=0;
   AO_FloatingSell=0;
   AO_TotalLotsBuy=0;
   AO_TotalLotsSell=0;
   AO_TicketFirstBuy=-1;
   AO_TicketFirstSell=-1;
   AO_TypeOfLastOrder=0;
   AO_LotFirstBuy=0;
   AO_LotFirstSell=0;
   AO_PriceOpenHigherBuy=-99999;
   AO_PriceOpenLowerBuy=99999;
   AO_PriceOpenHigherSell=-99999;
   AO_PriceOpenLowerSell=99999;
   AO_PipsBuyOrders=0;
   AO_PipsSellOrders=0;
//---------------------------------------------------------------------
   DeM_SumOrders=0;
   DeM_BuyOrders=0;
   DeM_SellOrders=0;
   DeM_TimeOpenLastBuy=0;
   DeM_TimeOpenLastSell=0;
   DeM_PriceOpenLastBuy=0;
   DeM_PriceOpenLastSell=0;
   DeM_FloatingBuy=0;
   DeM_FloatingSell=0;
   DeM_TotalLotsBuy=0;
   DeM_TotalLotsSell=0;
   DeM_TicketFirstBuy=-1;
   DeM_TicketFirstSell=-1;
   DeM_TypeOfLastOrder=0;
   DeM_LotFirstBuy=0;
   DeM_LotFirstSell=0;
   DeM_PriceOpenHigherBuy=-99999;
   DeM_PriceOpenLowerBuy=99999;
   DeM_PriceOpenHigherSell=-99999;
   DeM_PriceOpenLowerSell=99999;
   DeM_PipsBuyOrders=0;
   DeM_PipsSellOrders=0;
//---------------------------------------------------------------------
   FBB_SumOrders=0;
   FBB_BuyOrders=0;
   FBB_SellOrders=0;
   FBB_TimeOpenLastBuy=0;
   FBB_TimeOpenLastSell=0;
   FBB_PriceOpenLastBuy=0;
   FBB_PriceOpenLastSell=0;
   FBB_FloatingBuy=0;
   FBB_FloatingSell=0;
   FBB_TotalLotsBuy=0;
   FBB_TotalLotsSell=0;
   FBB_TicketFirstBuy=-1;
   FBB_TicketFirstSell=-1;
   FBB_TypeOfLastOrder=0;
   FBB_LotFirstBuy=0;
   FBB_LotFirstSell=0;
   FBB_PriceOpenHigherBuy=-99999;
   FBB_PriceOpenLowerBuy=99999;
   FBB_PriceOpenHigherSell=-99999;
   FBB_PriceOpenLowerSell=99999;
   FBB_PipsBuyOrders=0;
   FBB_PipsSellOrders=0;
//---------------------------------------------------------------------
   MFI_SumOrders=0;
   MFI_BuyOrders=0;
   MFI_SellOrders=0;
   MFI_TimeOpenLastBuy=0;
   MFI_TimeOpenLastSell=0;
   MFI_PriceOpenLastBuy=0;
   MFI_PriceOpenLastSell=0;
   MFI_FloatingBuy=0;
   MFI_FloatingSell=0;
   MFI_TotalLotsBuy=0;
   MFI_TotalLotsSell=0;
   MFI_TicketFirstBuy=-1;
   MFI_TicketFirstSell=-1;
   MFI_TypeOfLastOrder=0;
   MFI_LotFirstBuy=0;
   MFI_LotFirstSell=0;
   MFI_PriceOpenHigherBuy=-99999;
   MFI_PriceOpenLowerBuy=99999;
   MFI_PriceOpenHigherSell=-99999;
   MFI_PriceOpenLowerSell=99999;
   MFI_PipsBuyOrders=0;
   MFI_PipsSellOrders=0;
//---------------------------------------------------------------------
   MS_SumOrders=0;
   MS_BuyOrders=0;
   MS_SellOrders=0;
   MS_TimeOpenLastBuy=0;
   MS_TimeOpenLastSell=0;
   MS_PriceOpenLastBuy=0;
   MS_PriceOpenLastSell=0;
   MS_FloatingBuy=0;
   MS_FloatingSell=0;
   MS_TotalLotsBuy=0;
   MS_TotalLotsSell=0;
   MS_TicketFirstBuy=-1;
   MS_TicketFirstSell=-1;
   MS_TypeOfLastOrder=0;
   MS_LotFirstBuy=0;
   MS_LotFirstSell=0;
   MS_PriceOpenHigherBuy=-99999;
   MS_PriceOpenLowerBuy=99999;
   MS_PriceOpenHigherSell=-99999;
   MS_PriceOpenLowerSell=99999;
   MS_PipsBuyOrders=0;
   MS_PipsSellOrders=0;
//---------------------------------------------------------------------
//Start count
   if(PositionsTotal()>0)
     {
      for(i=0; i<PositionsTotal(); i++)
        {
         if(PositionGetTicket(i))
           {
            Floating+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
            SumOrders++;
            //---------------------------------------------------------------------
            //AC_Current
            //---------------------------------------------------------------------
            if(AC_StrategyRun==true)
              {
               if((PositionGetInteger(POSITION_MAGIC)==AC_OrdersID)&&(PositionGetString(POSITION_SYMBOL)==SymbolTrade))
                 {
                  AC_SumOrders++;
                  //---------------------------------------------------------------------
                  //Get information for buys
                  if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==(ENUM_POSITION_TYPE)ORDER_TYPE_BUY)
                    {
                     AC_BuyOrders++;
                     AC_TypeOfLastOrder=1;
                     AC_TimeOpenLastBuy=(datetime)PositionGetInteger(POSITION_TIME);
                     AC_PriceOpenLastBuy=PositionGetDouble(POSITION_PRICE_OPEN);
                     AC_TotalLotsBuy+=PositionGetDouble(POSITION_VOLUME);
                     AC_FloatingBuy+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
                     AC_PriceOpenHigherBuy=MathMax(AC_PriceOpenHigherBuy,PositionGetDouble(POSITION_PRICE_OPEN));
                     AC_PriceOpenLowerBuy=MathMin(AC_PriceOpenLowerBuy,PositionGetDouble(POSITION_PRICE_OPEN));
                     AC_PipsBuyOrders+=(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-PositionGetDouble(POSITION_PRICE_OPEN))/SymbolPoints;
                     //---
                     if(AC_TicketFirstBuy==-1)
                        AC_TicketFirstBuy=PositionGetInteger(POSITION_TICKET);
                     //---
                     if(AC_LotFirstBuy==0)
                        AC_LotFirstBuy=PositionGetDouble(POSITION_VOLUME);
                     //---------------------------------------------------------------------
                     //Virtual levels buy
                     if((AC_TypeOfLevelsUse==1)||(AC_TypeOfLevelsUse==2))
                       {
                        if(AC_TakeProfit>0)
                          {
                           AC_TP=NormalizeDouble(AC_PriceOpenLastBuy+AC_OrderTP,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)>=AC_TP)
                              CloseOrders(ORDER_TYPE_BUY,PositionGetInteger(POSITION_TICKET),AC_OrdersID);
                          }
                        //---
                        if(AC_StopLoss>0)
                          {
                           AC_SL=NormalizeDouble(AC_PriceOpenLastBuy-AC_OrderSL,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)<=AC_SL)
                              CloseOrders(ORDER_TYPE_BUY,PositionGetInteger(POSITION_TICKET),AC_OrdersID);
                          }
                       }
                    }
                  //---------------------------------------------------------------------
                  //Get information for sells
                  if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==(ENUM_POSITION_TYPE)ORDER_TYPE_SELL)
                    {
                     AC_SellOrders++;
                     AC_TypeOfLastOrder=-1;
                     AC_TimeOpenLastSell=(datetime)PositionGetInteger(POSITION_TIME);
                     AC_PriceOpenLastSell=PositionGetDouble(POSITION_PRICE_OPEN);
                     AC_TotalLotsSell+=PositionGetDouble(POSITION_VOLUME);
                     AC_FloatingSell+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
                     AC_PriceOpenHigherSell=MathMax(AC_PriceOpenHigherSell,PositionGetDouble(POSITION_PRICE_OPEN));
                     AC_PriceOpenLowerSell=MathMin(AC_PriceOpenLowerSell,PositionGetDouble(POSITION_PRICE_OPEN));
                     AC_PipsSellOrders+=(PositionGetDouble(POSITION_PRICE_OPEN)-SymbolInfoDouble(SymbolTrade,SYMBOL_ASK))/SymbolPoints;
                     //---
                     if(AC_TicketFirstSell==-1)
                        AC_TicketFirstSell=PositionGetInteger(POSITION_TICKET);
                     //---
                     if(AC_LotFirstSell==0)
                        AC_LotFirstSell=PositionGetDouble(POSITION_VOLUME);
                     //---------------------------------------------------------------------
                     //Virtual levels sell
                     if((AC_TypeOfLevelsUse==1)||(AC_TypeOfLevelsUse==2))
                       {
                        if(AC_TakeProfit>0)
                          {
                           AC_TP=NormalizeDouble(AC_PriceOpenLastSell-AC_OrderTP,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)<=AC_TP)
                              CloseOrders(ORDER_TYPE_SELL,PositionGetInteger(POSITION_TICKET),AC_OrdersID);
                          }
                        //---
                        if(AC_StopLoss>0)
                          {
                           AC_SL=NormalizeDouble(AC_PriceOpenLastSell+AC_OrderSL,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)>=AC_SL)
                              CloseOrders(ORDER_TYPE_SELL,PositionGetInteger(POSITION_TICKET),AC_OrdersID);
                          }
                       }
                    }
                 }
              }
            //---------------------------------------------------------------------
            //ADX_Current
            //---------------------------------------------------------------------
            if(ADX_StrategyRun==true)
              {
               if((PositionGetInteger(POSITION_MAGIC)==ADX_OrdersID)&&(PositionGetString(POSITION_SYMBOL)==SymbolTrade))
                 {
                  ADX_SumOrders++;
                  //---------------------------------------------------------------------
                  //Get information for buys
                  if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==(ENUM_POSITION_TYPE)ORDER_TYPE_BUY)
                    {
                     ADX_BuyOrders++;
                     ADX_TypeOfLastOrder=1;
                     ADX_TimeOpenLastBuy=(datetime)PositionGetInteger(POSITION_TIME);
                     ADX_PriceOpenLastBuy=PositionGetDouble(POSITION_PRICE_OPEN);
                     ADX_TotalLotsBuy+=PositionGetDouble(POSITION_VOLUME);
                     ADX_FloatingBuy+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
                     ADX_PriceOpenHigherBuy=MathMax(ADX_PriceOpenHigherBuy,PositionGetDouble(POSITION_PRICE_OPEN));
                     ADX_PriceOpenLowerBuy=MathMin(ADX_PriceOpenLowerBuy,PositionGetDouble(POSITION_PRICE_OPEN));
                     ADX_PipsBuyOrders+=(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-PositionGetDouble(POSITION_PRICE_OPEN))/SymbolPoints;
                     //---
                     if(ADX_TicketFirstBuy==-1)
                        ADX_TicketFirstBuy=PositionGetInteger(POSITION_TICKET);
                     //---
                     if(ADX_LotFirstBuy==0)
                        ADX_LotFirstBuy=PositionGetDouble(POSITION_VOLUME);
                     //---------------------------------------------------------------------
                     //Virtual levels buy
                     if((ADX_TypeOfLevelsUse==1)||(ADX_TypeOfLevelsUse==2))
                       {
                        if(ADX_TakeProfit>0)
                          {
                           ADX_TP=NormalizeDouble(ADX_PriceOpenLastBuy+ADX_OrderTP,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)>=ADX_TP)
                              CloseOrders(ORDER_TYPE_BUY,PositionGetInteger(POSITION_TICKET),ADX_OrdersID);
                          }
                        //---
                        if(ADX_StopLoss>0)
                          {
                           ADX_SL=NormalizeDouble(ADX_PriceOpenLastBuy-ADX_OrderSL,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)<=ADX_SL)
                              CloseOrders(ORDER_TYPE_BUY,PositionGetInteger(POSITION_TICKET),ADX_OrdersID);
                          }
                       }
                    }
                  //---------------------------------------------------------------------
                  //Get information for sells
                  if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==(ENUM_POSITION_TYPE)ORDER_TYPE_SELL)
                    {
                     ADX_SellOrders++;
                     ADX_TypeOfLastOrder=-1;
                     ADX_TimeOpenLastSell=(datetime)PositionGetInteger(POSITION_TIME);
                     ADX_PriceOpenLastSell=PositionGetDouble(POSITION_PRICE_OPEN);
                     ADX_TotalLotsSell+=PositionGetDouble(POSITION_VOLUME);
                     ADX_FloatingSell+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
                     ADX_PriceOpenHigherSell=MathMax(ADX_PriceOpenHigherSell,PositionGetDouble(POSITION_PRICE_OPEN));
                     ADX_PriceOpenLowerSell=MathMin(ADX_PriceOpenLowerSell,PositionGetDouble(POSITION_PRICE_OPEN));
                     ADX_PipsSellOrders+=(PositionGetDouble(POSITION_PRICE_OPEN)-SymbolInfoDouble(SymbolTrade,SYMBOL_ASK))/SymbolPoints;
                     //---
                     if(ADX_TicketFirstSell==-1)
                        ADX_TicketFirstSell=PositionGetInteger(POSITION_TICKET);
                     //---
                     if(ADX_LotFirstSell==0)
                        ADX_LotFirstSell=PositionGetDouble(POSITION_VOLUME);
                     //---------------------------------------------------------------------
                     //Virtual levels sell
                     if((ADX_TypeOfLevelsUse==1)||(ADX_TypeOfLevelsUse==2))
                       {
                        if(ADX_TakeProfit>0)
                          {
                           ADX_TP=NormalizeDouble(ADX_PriceOpenLastSell-ADX_OrderTP,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)<=ADX_TP)
                              CloseOrders(ORDER_TYPE_SELL,PositionGetInteger(POSITION_TICKET),ADX_OrdersID);
                          }
                        //---
                        if(ADX_StopLoss>0)
                          {
                           ADX_SL=NormalizeDouble(ADX_PriceOpenLastSell+ADX_OrderSL,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)>=ADX_SL)
                              CloseOrders(ORDER_TYPE_SELL,PositionGetInteger(POSITION_TICKET),ADX_OrdersID);
                          }
                       }
                    }
                 }
              }
            //---------------------------------------------------------------------
            //AO_Current
            //---------------------------------------------------------------------
            if(AO_StrategyRun==true)
              {
               if((PositionGetInteger(POSITION_MAGIC)==AO_OrdersID)&&(PositionGetString(POSITION_SYMBOL)==SymbolTrade))
                 {
                  AO_SumOrders++;
                  //---------------------------------------------------------------------
                  //Get information for buys
                  if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==(ENUM_POSITION_TYPE)ORDER_TYPE_BUY)
                    {
                     AO_BuyOrders++;
                     AO_TypeOfLastOrder=1;
                     AO_TimeOpenLastBuy=(datetime)PositionGetInteger(POSITION_TIME);
                     AO_PriceOpenLastBuy=PositionGetDouble(POSITION_PRICE_OPEN);
                     AO_TotalLotsBuy+=PositionGetDouble(POSITION_VOLUME);
                     AO_FloatingBuy+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
                     AO_PriceOpenHigherBuy=MathMax(AO_PriceOpenHigherBuy,PositionGetDouble(POSITION_PRICE_OPEN));
                     AO_PriceOpenLowerBuy=MathMin(AO_PriceOpenLowerBuy,PositionGetDouble(POSITION_PRICE_OPEN));
                     AO_PipsBuyOrders+=(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-PositionGetDouble(POSITION_PRICE_OPEN))/SymbolPoints;
                     //---
                     if(AO_TicketFirstBuy==-1)
                        AO_TicketFirstBuy=PositionGetInteger(POSITION_TICKET);
                     //---
                     if(AO_LotFirstBuy==0)
                        AO_LotFirstBuy=PositionGetDouble(POSITION_VOLUME);
                     //---------------------------------------------------------------------
                     //Virtual levels buy
                     if((AO_TypeOfLevelsUse==1)||(AO_TypeOfLevelsUse==2))
                       {
                        if(AO_TakeProfit>0)
                          {
                           AO_TP=NormalizeDouble(AO_PriceOpenLastBuy+AO_OrderTP,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)>=AO_TP)
                              CloseOrders(ORDER_TYPE_BUY,PositionGetInteger(POSITION_TICKET),AO_OrdersID);
                          }
                        //---
                        if(AO_StopLoss>0)
                          {
                           AO_SL=NormalizeDouble(AO_PriceOpenLastBuy-AO_OrderSL,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)<=AO_SL)
                              CloseOrders(ORDER_TYPE_BUY,PositionGetInteger(POSITION_TICKET),AO_OrdersID);
                          }
                       }
                    }
                  //---------------------------------------------------------------------
                  //Get information for sells
                  if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==(ENUM_POSITION_TYPE)ORDER_TYPE_SELL)
                    {
                     AO_SellOrders++;
                     AO_TypeOfLastOrder=-1;
                     AO_TimeOpenLastSell=(datetime)PositionGetInteger(POSITION_TIME);
                     AO_PriceOpenLastSell=PositionGetDouble(POSITION_PRICE_OPEN);
                     AO_TotalLotsSell+=PositionGetDouble(POSITION_VOLUME);
                     AO_FloatingSell+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
                     AO_PriceOpenHigherSell=MathMax(AO_PriceOpenHigherSell,PositionGetDouble(POSITION_PRICE_OPEN));
                     AO_PriceOpenLowerSell=MathMin(AO_PriceOpenLowerSell,PositionGetDouble(POSITION_PRICE_OPEN));
                     AO_PipsSellOrders+=(PositionGetDouble(POSITION_PRICE_OPEN)-SymbolInfoDouble(SymbolTrade,SYMBOL_ASK))/SymbolPoints;
                     //---
                     if(AO_TicketFirstSell==-1)
                        AO_TicketFirstSell=PositionGetInteger(POSITION_TICKET);
                     //---
                     if(AO_LotFirstSell==0)
                        AO_LotFirstSell=PositionGetDouble(POSITION_VOLUME);
                     //---------------------------------------------------------------------
                     //Virtual levels sell
                     if((AO_TypeOfLevelsUse==1)||(AO_TypeOfLevelsUse==2))
                       {
                        if(AO_TakeProfit>0)
                          {
                           AO_TP=NormalizeDouble(AO_PriceOpenLastSell-AO_OrderTP,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)<=AO_TP)
                              CloseOrders(ORDER_TYPE_SELL,PositionGetInteger(POSITION_TICKET),AO_OrdersID);
                          }
                        //---
                        if(AO_StopLoss>0)
                          {
                           AO_SL=NormalizeDouble(AO_PriceOpenLastSell+AO_OrderSL,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)>=AO_SL)
                              CloseOrders(ORDER_TYPE_SELL,PositionGetInteger(POSITION_TICKET),AO_OrdersID);
                          }
                       }
                    }
                 }
              }
            //---------------------------------------------------------------------
            //DeM_Current
            //---------------------------------------------------------------------
            if(DeM_StrategyRun==true)
              {
               if((PositionGetInteger(POSITION_MAGIC)==DeM_OrdersID)&&(PositionGetString(POSITION_SYMBOL)==SymbolTrade))
                 {
                  DeM_SumOrders++;
                  //---------------------------------------------------------------------
                  //Get information for buys
                  if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==(ENUM_POSITION_TYPE)ORDER_TYPE_BUY)
                    {
                     DeM_BuyOrders++;
                     DeM_TypeOfLastOrder=1;
                     DeM_TimeOpenLastBuy=(datetime)PositionGetInteger(POSITION_TIME);
                     DeM_PriceOpenLastBuy=PositionGetDouble(POSITION_PRICE_OPEN);
                     DeM_TotalLotsBuy+=PositionGetDouble(POSITION_VOLUME);
                     DeM_FloatingBuy+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
                     DeM_PriceOpenHigherBuy=MathMax(DeM_PriceOpenHigherBuy,PositionGetDouble(POSITION_PRICE_OPEN));
                     DeM_PriceOpenLowerBuy=MathMin(DeM_PriceOpenLowerBuy,PositionGetDouble(POSITION_PRICE_OPEN));
                     DeM_PipsBuyOrders+=(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-PositionGetDouble(POSITION_PRICE_OPEN))/SymbolPoints;
                     //---
                     if(DeM_TicketFirstBuy==-1)
                        DeM_TicketFirstBuy=PositionGetInteger(POSITION_TICKET);
                     //---
                     if(DeM_LotFirstBuy==0)
                        DeM_LotFirstBuy=PositionGetDouble(POSITION_VOLUME);
                     //---------------------------------------------------------------------
                     //Virtual levels buy
                     if((DeM_TypeOfLevelsUse==1)||(DeM_TypeOfLevelsUse==2))
                       {
                        if(DeM_TakeProfit>0)
                          {
                           DeM_TP=NormalizeDouble(DeM_PriceOpenLastBuy+DeM_OrderTP,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)>=DeM_TP)
                              CloseOrders(ORDER_TYPE_BUY,PositionGetInteger(POSITION_TICKET),DeM_OrdersID);
                          }
                        //---
                        if(DeM_StopLoss>0)
                          {
                           DeM_SL=NormalizeDouble(DeM_PriceOpenLastBuy-DeM_OrderSL,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)<=DeM_SL)
                              CloseOrders(ORDER_TYPE_BUY,PositionGetInteger(POSITION_TICKET),DeM_OrdersID);
                          }
                       }
                    }
                  //---------------------------------------------------------------------
                  //Get information for sells
                  if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==(ENUM_POSITION_TYPE)ORDER_TYPE_SELL)
                    {
                     DeM_SellOrders++;
                     DeM_TypeOfLastOrder=-1;
                     DeM_TimeOpenLastSell=(datetime)PositionGetInteger(POSITION_TIME);
                     DeM_PriceOpenLastSell=PositionGetDouble(POSITION_PRICE_OPEN);
                     DeM_TotalLotsSell+=PositionGetDouble(POSITION_VOLUME);
                     DeM_FloatingSell+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
                     DeM_PriceOpenHigherSell=MathMax(DeM_PriceOpenHigherSell,PositionGetDouble(POSITION_PRICE_OPEN));
                     DeM_PriceOpenLowerSell=MathMin(DeM_PriceOpenLowerSell,PositionGetDouble(POSITION_PRICE_OPEN));
                     DeM_PipsSellOrders+=(PositionGetDouble(POSITION_PRICE_OPEN)-SymbolInfoDouble(SymbolTrade,SYMBOL_ASK))/SymbolPoints;
                     //---
                     if(DeM_TicketFirstSell==-1)
                        DeM_TicketFirstSell=PositionGetInteger(POSITION_TICKET);
                     //---
                     if(DeM_LotFirstSell==0)
                        DeM_LotFirstSell=PositionGetDouble(POSITION_VOLUME);
                     //---------------------------------------------------------------------
                     //Virtual levels sell
                     if((DeM_TypeOfLevelsUse==1)||(DeM_TypeOfLevelsUse==2))
                       {
                        if(DeM_TakeProfit>0)
                          {
                           DeM_TP=NormalizeDouble(DeM_PriceOpenLastSell-DeM_OrderTP,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)<=DeM_TP)
                              CloseOrders(ORDER_TYPE_SELL,PositionGetInteger(POSITION_TICKET),DeM_OrdersID);
                          }
                        //---
                        if(DeM_StopLoss>0)
                          {
                           DeM_SL=NormalizeDouble(DeM_PriceOpenLastSell+DeM_OrderSL,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)>=DeM_SL)
                              CloseOrders(ORDER_TYPE_SELL,PositionGetInteger(POSITION_TICKET),DeM_OrdersID);
                          }
                       }
                    }
                 }
              }
            //---------------------------------------------------------------------
            //FBB_Current
            //---------------------------------------------------------------------
            if(FBB_StrategyRun==true)
              {
               if((PositionGetInteger(POSITION_MAGIC)==FBB_OrdersID)&&(PositionGetString(POSITION_SYMBOL)==SymbolTrade))
                 {
                  FBB_SumOrders++;
                  //---------------------------------------------------------------------
                  //Get information for buys
                  if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==(ENUM_POSITION_TYPE)ORDER_TYPE_BUY)
                    {
                     FBB_BuyOrders++;
                     FBB_TypeOfLastOrder=1;
                     FBB_TimeOpenLastBuy=(datetime)PositionGetInteger(POSITION_TIME);
                     FBB_PriceOpenLastBuy=PositionGetDouble(POSITION_PRICE_OPEN);
                     FBB_TotalLotsBuy+=PositionGetDouble(POSITION_VOLUME);
                     FBB_FloatingBuy+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
                     FBB_PriceOpenHigherBuy=MathMax(FBB_PriceOpenHigherBuy,PositionGetDouble(POSITION_PRICE_OPEN));
                     FBB_PriceOpenLowerBuy=MathMin(FBB_PriceOpenLowerBuy,PositionGetDouble(POSITION_PRICE_OPEN));
                     FBB_PipsBuyOrders+=(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-PositionGetDouble(POSITION_PRICE_OPEN))/SymbolPoints;
                     //---
                     if(FBB_TicketFirstBuy==-1)
                        FBB_TicketFirstBuy=PositionGetInteger(POSITION_TICKET);
                     //---
                     if(FBB_LotFirstBuy==0)
                        FBB_LotFirstBuy=PositionGetDouble(POSITION_VOLUME);
                     //---------------------------------------------------------------------
                     //Virtual levels buy
                     if((FBB_TypeOfLevelsUse==1)||(FBB_TypeOfLevelsUse==2))
                       {
                        if(FBB_TakeProfit>0)
                          {
                           FBB_TP=NormalizeDouble(FBB_PriceOpenLastBuy+FBB_OrderTP,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)>=FBB_TP)
                              CloseOrders(ORDER_TYPE_BUY,PositionGetInteger(POSITION_TICKET),FBB_OrdersID);
                          }
                        //---
                        if(FBB_StopLoss>0)
                          {
                           FBB_SL=NormalizeDouble(FBB_PriceOpenLastBuy-FBB_OrderSL,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)<=FBB_SL)
                              CloseOrders(ORDER_TYPE_BUY,PositionGetInteger(POSITION_TICKET),FBB_OrdersID);
                          }
                       }
                    }
                  //---------------------------------------------------------------------
                  //Get information for sells
                  if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==(ENUM_POSITION_TYPE)ORDER_TYPE_SELL)
                    {
                     FBB_SellOrders++;
                     FBB_TypeOfLastOrder=-1;
                     FBB_TimeOpenLastSell=(datetime)PositionGetInteger(POSITION_TIME);
                     FBB_PriceOpenLastSell=PositionGetDouble(POSITION_PRICE_OPEN);
                     FBB_TotalLotsSell+=PositionGetDouble(POSITION_VOLUME);
                     FBB_FloatingSell+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
                     FBB_PriceOpenHigherSell=MathMax(FBB_PriceOpenHigherSell,PositionGetDouble(POSITION_PRICE_OPEN));
                     FBB_PriceOpenLowerSell=MathMin(FBB_PriceOpenLowerSell,PositionGetDouble(POSITION_PRICE_OPEN));
                     FBB_PipsSellOrders+=(PositionGetDouble(POSITION_PRICE_OPEN)-SymbolInfoDouble(SymbolTrade,SYMBOL_ASK))/SymbolPoints;
                     //---
                     if(FBB_TicketFirstSell==-1)
                        FBB_TicketFirstSell=PositionGetInteger(POSITION_TICKET);
                     //---
                     if(FBB_LotFirstSell==0)
                        FBB_LotFirstSell=PositionGetDouble(POSITION_VOLUME);
                     //---------------------------------------------------------------------
                     //Virtual levels sell
                     if((FBB_TypeOfLevelsUse==1)||(FBB_TypeOfLevelsUse==2))
                       {
                        if(FBB_TakeProfit>0)
                          {
                           FBB_TP=NormalizeDouble(FBB_PriceOpenLastSell-FBB_OrderTP,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)<=FBB_TP)
                              CloseOrders(ORDER_TYPE_SELL,PositionGetInteger(POSITION_TICKET),FBB_OrdersID);
                          }
                        //---
                        if(FBB_StopLoss>0)
                          {
                           FBB_SL=NormalizeDouble(FBB_PriceOpenLastSell+FBB_OrderSL,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)>=FBB_SL)
                              CloseOrders(ORDER_TYPE_SELL,PositionGetInteger(POSITION_TICKET),FBB_OrdersID);
                          }
                       }
                    }
                 }
              }
            //---------------------------------------------------------------------
            //MFI_Current
            //---------------------------------------------------------------------
            if(MFI_StrategyRun==true)
              {
               if((PositionGetInteger(POSITION_MAGIC)==MFI_OrdersID)&&(PositionGetString(POSITION_SYMBOL)==SymbolTrade))
                 {
                  MFI_SumOrders++;
                  //---------------------------------------------------------------------
                  //Get information for buys
                  if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==(ENUM_POSITION_TYPE)ORDER_TYPE_BUY)
                    {
                     MFI_BuyOrders++;
                     MFI_TypeOfLastOrder=1;
                     MFI_TimeOpenLastBuy=(datetime)PositionGetInteger(POSITION_TIME);
                     MFI_PriceOpenLastBuy=PositionGetDouble(POSITION_PRICE_OPEN);
                     MFI_TotalLotsBuy+=PositionGetDouble(POSITION_VOLUME);
                     MFI_FloatingBuy+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
                     MFI_PriceOpenHigherBuy=MathMax(MFI_PriceOpenHigherBuy,PositionGetDouble(POSITION_PRICE_OPEN));
                     MFI_PriceOpenLowerBuy=MathMin(MFI_PriceOpenLowerBuy,PositionGetDouble(POSITION_PRICE_OPEN));
                     MFI_PipsBuyOrders+=(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-PositionGetDouble(POSITION_PRICE_OPEN))/SymbolPoints;
                     //---
                     if(MFI_TicketFirstBuy==-1)
                        MFI_TicketFirstBuy=PositionGetInteger(POSITION_TICKET);
                     //---
                     if(MFI_LotFirstBuy==0)
                        MFI_LotFirstBuy=PositionGetDouble(POSITION_VOLUME);
                     //---------------------------------------------------------------------
                     //Virtual levels buy
                     if((MFI_TypeOfLevelsUse==1)||(MFI_TypeOfLevelsUse==2))
                       {
                        if(MFI_TakeProfit>0)
                          {
                           MFI_TP=NormalizeDouble(MFI_PriceOpenLastBuy+MFI_OrderTP,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)>=MFI_TP)
                              CloseOrders(ORDER_TYPE_BUY,PositionGetInteger(POSITION_TICKET),MFI_OrdersID);
                          }
                        //---
                        if(MFI_StopLoss>0)
                          {
                           MFI_SL=NormalizeDouble(MFI_PriceOpenLastBuy-MFI_OrderSL,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)<=MFI_SL)
                              CloseOrders(ORDER_TYPE_BUY,PositionGetInteger(POSITION_TICKET),MFI_OrdersID);
                          }
                       }
                    }
                  //---------------------------------------------------------------------
                  //Get information for sells
                  if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==(ENUM_POSITION_TYPE)ORDER_TYPE_SELL)
                    {
                     MFI_SellOrders++;
                     MFI_TypeOfLastOrder=-1;
                     MFI_TimeOpenLastSell=(datetime)PositionGetInteger(POSITION_TIME);
                     MFI_PriceOpenLastSell=PositionGetDouble(POSITION_PRICE_OPEN);
                     MFI_TotalLotsSell+=PositionGetDouble(POSITION_VOLUME);
                     MFI_FloatingSell+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
                     MFI_PriceOpenHigherSell=MathMax(MFI_PriceOpenHigherSell,PositionGetDouble(POSITION_PRICE_OPEN));
                     MFI_PriceOpenLowerSell=MathMin(MFI_PriceOpenLowerSell,PositionGetDouble(POSITION_PRICE_OPEN));
                     MFI_PipsSellOrders+=(PositionGetDouble(POSITION_PRICE_OPEN)-SymbolInfoDouble(SymbolTrade,SYMBOL_ASK))/SymbolPoints;
                     //---
                     if(MFI_TicketFirstSell==-1)
                        MFI_TicketFirstSell=PositionGetInteger(POSITION_TICKET);
                     //---
                     if(MFI_LotFirstSell==0)
                        MFI_LotFirstSell=PositionGetDouble(POSITION_VOLUME);
                     //---------------------------------------------------------------------
                     //Virtual levels sell
                     if((MFI_TypeOfLevelsUse==1)||(MFI_TypeOfLevelsUse==2))
                       {
                        if(MFI_TakeProfit>0)
                          {
                           MFI_TP=NormalizeDouble(MFI_PriceOpenLastSell-MFI_OrderTP,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)<=MFI_TP)
                              CloseOrders(ORDER_TYPE_SELL,PositionGetInteger(POSITION_TICKET),MFI_OrdersID);
                          }
                        //---
                        if(MFI_StopLoss>0)
                          {
                           MFI_SL=NormalizeDouble(MFI_PriceOpenLastSell+MFI_OrderSL,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)>=MFI_SL)
                              CloseOrders(ORDER_TYPE_SELL,PositionGetInteger(POSITION_TICKET),MFI_OrdersID);
                          }
                       }
                    }
                 }
              }
            //---------------------------------------------------------------------
            //MS_Current
            //---------------------------------------------------------------------
            if(MS_StrategyRun==true)
              {
               if((PositionGetInteger(POSITION_MAGIC)==MS_OrdersID)&&(PositionGetString(POSITION_SYMBOL)==SymbolTrade))
                 {
                  MS_SumOrders++;
                  //---------------------------------------------------------------------
                  //Get information for buys
                  if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==(ENUM_POSITION_TYPE)ORDER_TYPE_BUY)
                    {
                     MS_BuyOrders++;
                     MS_TypeOfLastOrder=1;
                     MS_TimeOpenLastBuy=(datetime)PositionGetInteger(POSITION_TIME);
                     MS_PriceOpenLastBuy=PositionGetDouble(POSITION_PRICE_OPEN);
                     MS_TotalLotsBuy+=PositionGetDouble(POSITION_VOLUME);
                     MS_FloatingBuy+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
                     MS_PriceOpenHigherBuy=MathMax(MS_PriceOpenHigherBuy,PositionGetDouble(POSITION_PRICE_OPEN));
                     MS_PriceOpenLowerBuy=MathMin(MS_PriceOpenLowerBuy,PositionGetDouble(POSITION_PRICE_OPEN));
                     MS_PipsBuyOrders+=(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-PositionGetDouble(POSITION_PRICE_OPEN))/SymbolPoints;
                     //---
                     if(MS_TicketFirstBuy==-1)
                        MS_TicketFirstBuy=PositionGetInteger(POSITION_TICKET);
                     //---
                     if(MS_LotFirstBuy==0)
                        MS_LotFirstBuy=PositionGetDouble(POSITION_VOLUME);
                     //---------------------------------------------------------------------
                     //Virtual levels buy
                     if((MS_TypeOfLevelsUse==1)||(MS_TypeOfLevelsUse==2))
                       {
                        if(MS_TakeProfit>0)
                          {
                           MS_TP=NormalizeDouble(MS_PriceOpenLastBuy+MS_OrderTP,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)>=MS_TP)
                              CloseOrders(ORDER_TYPE_BUY,PositionGetInteger(POSITION_TICKET),MS_OrdersID);
                          }
                        //---
                        if(MS_StopLoss>0)
                          {
                           MS_SL=NormalizeDouble(MS_PriceOpenLastBuy-MS_OrderSL,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)<=MS_SL)
                              CloseOrders(ORDER_TYPE_BUY,PositionGetInteger(POSITION_TICKET),MS_OrdersID);
                          }
                       }
                    }
                  //---------------------------------------------------------------------
                  //Get information for sells
                  if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==(ENUM_POSITION_TYPE)ORDER_TYPE_SELL)
                    {
                     MS_SellOrders++;
                     MS_TypeOfLastOrder=-1;
                     MS_TimeOpenLastSell=(datetime)PositionGetInteger(POSITION_TIME);
                     MS_PriceOpenLastSell=PositionGetDouble(POSITION_PRICE_OPEN);
                     MS_TotalLotsSell+=PositionGetDouble(POSITION_VOLUME);
                     MS_FloatingSell+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
                     MS_PriceOpenHigherSell=MathMax(MS_PriceOpenHigherSell,PositionGetDouble(POSITION_PRICE_OPEN));
                     MS_PriceOpenLowerSell=MathMin(MS_PriceOpenLowerSell,PositionGetDouble(POSITION_PRICE_OPEN));
                     MS_PipsSellOrders+=(PositionGetDouble(POSITION_PRICE_OPEN)-SymbolInfoDouble(SymbolTrade,SYMBOL_ASK))/SymbolPoints;
                     //---
                     if(MS_TicketFirstSell==-1)
                        MS_TicketFirstSell=PositionGetInteger(POSITION_TICKET);
                     //---
                     if(MS_LotFirstSell==0)
                        MS_LotFirstSell=PositionGetDouble(POSITION_VOLUME);
                     //---------------------------------------------------------------------
                     //Virtual levels sell
                     if((MS_TypeOfLevelsUse==1)||(MS_TypeOfLevelsUse==2))
                       {
                        if(MS_TakeProfit>0)
                          {
                           MS_TP=NormalizeDouble(MS_PriceOpenLastSell-MS_OrderTP,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)<=MS_TP)
                              CloseOrders(ORDER_TYPE_SELL,PositionGetInteger(POSITION_TICKET),MS_OrdersID);
                          }
                        //---
                        if(MS_StopLoss>0)
                          {
                           MS_SL=NormalizeDouble(MS_PriceOpenLastSell+MS_OrderSL,SymbolDigits);
                           //---
                           if(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)>=MS_SL)
                              CloseOrders(ORDER_TYPE_SELL,PositionGetInteger(POSITION_TICKET),MS_OrdersID);
                          }
                       }
                    }
                 }
              }
            //---------------------------------------------------------------------
           }
        }
     }
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//History results
//============================================================================================================================================================================================================================//
void GetResultsHistoryOrders()
  {
//---------------------------------------------------------------------
//Set variables
   ulong Deal_Ticket;
   ulong Order_Ticket;
//---------------------------------------------------------------------
//Request the history of deals in the specified period
   HistorySelect(0,TimeCurrent());
//---------------------------------------------------------------------
   if(LastHistoryOrders==HistoryDealsTotal())
      return;
//---------------------------------------------------------------------
//AC_Reset variables
   AC_TotalHistoryOrders=0;
   AC_TotalHistoryProfitLoss=0;
   AC_LastHistoryOrderPnL=0;
//---------------------------------------------------------------------
//ADX_Reset variables
   ADX_TotalHistoryOrders=0;
   ADX_TotalHistoryProfitLoss=0;
   ADX_LastHistoryOrderPnL=0;
//---------------------------------------------------------------------
//AO_Reset variables
   AO_TotalHistoryOrders=0;
   AO_TotalHistoryProfitLoss=0;
   AO_LastHistoryOrderPnL=0;
//---------------------------------------------------------------------
//DeM_Reset variables
   DeM_TotalHistoryOrders=0;
   DeM_TotalHistoryProfitLoss=0;
   DeM_LastHistoryOrderPnL=0;
//---------------------------------------------------------------------
//FBB_Reset variables
   FBB_TotalHistoryOrders=0;
   FBB_TotalHistoryProfitLoss=0;
   FBB_LastHistoryOrderPnL=0;
//---------------------------------------------------------------------
//MFI_Reset variables
   MFI_TotalHistoryOrders=0;
   MFI_TotalHistoryProfitLoss=0;
   MFI_LastHistoryOrderPnL=0;
//---------------------------------------------------------------------
//MS_Reset variables
   MS_TotalHistoryOrders=0;
   MS_TotalHistoryProfitLoss=0;
   MS_LastHistoryOrderPnL=0;
//---------------------------------------------------------------------
//Start count
   if(HistoryDealsTotal()>0)
     {
      for(i=0; i<HistoryDealsTotal(); i++)
        {
         Deal_Ticket=HistoryDealGetTicket(i);
         Order_Ticket=HistoryDealGetInteger(Deal_Ticket,DEAL_ORDER);
         //---------------------------------------------------------------------
         //AC_History
         //---------------------------------------------------------------------
         if(AC_StrategyRun==true)
           {
            if((HistoryDealGetInteger(Deal_Ticket,DEAL_MAGIC)==AC_OrdersID)&&(HistoryDealGetString(Deal_Ticket,DEAL_SYMBOL)==SymbolTrade))
              {
               AC_LastHistoryOrderPnL=HistoryDealGetDouble(Deal_Ticket,DEAL_PROFIT)+HistoryDealGetDouble(Deal_Ticket,DEAL_COMMISSION)+HistoryDealGetDouble(Deal_Ticket,DEAL_SWAP);
               //---
               if(HistoryDealGetInteger(Deal_Ticket,DEAL_ENTRY)==DEAL_ENTRY_OUT)
                  AC_TotalHistoryOrders++;
               //---
               AC_TotalHistoryProfitLoss+=HistoryDealGetDouble(Deal_Ticket,DEAL_PROFIT)+HistoryDealGetDouble(Deal_Ticket,DEAL_COMMISSION)+HistoryDealGetDouble(Deal_Ticket,DEAL_SWAP);
              }
           }
         //---------------------------------------------------------------------
         //ADX_History
         //---------------------------------------------------------------------
         if(ADX_StrategyRun==true)
           {
            if((HistoryDealGetInteger(Deal_Ticket,DEAL_MAGIC)==ADX_OrdersID)&&(HistoryDealGetString(Deal_Ticket,DEAL_SYMBOL)==SymbolTrade))
              {
               ADX_LastHistoryOrderPnL=HistoryDealGetDouble(Deal_Ticket,DEAL_PROFIT)+HistoryDealGetDouble(Deal_Ticket,DEAL_COMMISSION)+HistoryDealGetDouble(Deal_Ticket,DEAL_SWAP);
               //---
               if(HistoryDealGetInteger(Deal_Ticket,DEAL_ENTRY)==DEAL_ENTRY_OUT)
                  ADX_TotalHistoryOrders++;
               //---
               ADX_TotalHistoryProfitLoss+=HistoryDealGetDouble(Deal_Ticket,DEAL_PROFIT)+HistoryDealGetDouble(Deal_Ticket,DEAL_COMMISSION)+HistoryDealGetDouble(Deal_Ticket,DEAL_SWAP);
              }
           }
         //---------------------------------------------------------------------
         //AO_History
         //---------------------------------------------------------------------
         if(AO_StrategyRun==true)
           {
            if((HistoryDealGetInteger(Deal_Ticket,DEAL_MAGIC)==AO_OrdersID)&&(HistoryDealGetString(Deal_Ticket,DEAL_SYMBOL)==SymbolTrade))
              {
               AO_LastHistoryOrderPnL=HistoryDealGetDouble(Deal_Ticket,DEAL_PROFIT)+HistoryDealGetDouble(Deal_Ticket,DEAL_COMMISSION)+HistoryDealGetDouble(Deal_Ticket,DEAL_SWAP);
               //---
               if(HistoryDealGetInteger(Deal_Ticket,DEAL_ENTRY)==DEAL_ENTRY_OUT)
                  AO_TotalHistoryOrders++;
               //---
               AO_TotalHistoryProfitLoss+=HistoryDealGetDouble(Deal_Ticket,DEAL_PROFIT)+HistoryDealGetDouble(Deal_Ticket,DEAL_COMMISSION)+HistoryDealGetDouble(Deal_Ticket,DEAL_SWAP);
              }
           }
         //---------------------------------------------------------------------
         //DeM_History
         //---------------------------------------------------------------------
         if(DeM_StrategyRun==true)
           {
            if((HistoryDealGetInteger(Deal_Ticket,DEAL_MAGIC)==DeM_OrdersID)&&(HistoryDealGetString(Deal_Ticket,DEAL_SYMBOL)==SymbolTrade))
              {
               DeM_LastHistoryOrderPnL=HistoryDealGetDouble(Deal_Ticket,DEAL_PROFIT)+HistoryDealGetDouble(Deal_Ticket,DEAL_COMMISSION)+HistoryDealGetDouble(Deal_Ticket,DEAL_SWAP);
               //---
               if(HistoryDealGetInteger(Deal_Ticket,DEAL_ENTRY)==DEAL_ENTRY_OUT)
                  DeM_TotalHistoryOrders++;
               //---
               DeM_TotalHistoryProfitLoss+=HistoryDealGetDouble(Deal_Ticket,DEAL_PROFIT)+HistoryDealGetDouble(Deal_Ticket,DEAL_COMMISSION)+HistoryDealGetDouble(Deal_Ticket,DEAL_SWAP);
              }
           }
         //---------------------------------------------------------------------
         //FBB_History
         //---------------------------------------------------------------------
         if(FBB_StrategyRun==true)
           {
            if((HistoryDealGetInteger(Deal_Ticket,DEAL_MAGIC)==FBB_OrdersID)&&(HistoryDealGetString(Deal_Ticket,DEAL_SYMBOL)==SymbolTrade))
              {
               FBB_LastHistoryOrderPnL=HistoryDealGetDouble(Deal_Ticket,DEAL_PROFIT)+HistoryDealGetDouble(Deal_Ticket,DEAL_COMMISSION)+HistoryDealGetDouble(Deal_Ticket,DEAL_SWAP);
               //---
               if(HistoryDealGetInteger(Deal_Ticket,DEAL_ENTRY)==DEAL_ENTRY_OUT)
                  FBB_TotalHistoryOrders++;
               //---
               FBB_TotalHistoryProfitLoss+=HistoryDealGetDouble(Deal_Ticket,DEAL_PROFIT)+HistoryDealGetDouble(Deal_Ticket,DEAL_COMMISSION)+HistoryDealGetDouble(Deal_Ticket,DEAL_SWAP);
              }
           }
         //---------------------------------------------------------------------
         //MFI_History
         //---------------------------------------------------------------------
         if(MFI_StrategyRun==true)
           {
            if((HistoryDealGetInteger(Deal_Ticket,DEAL_MAGIC)==MFI_OrdersID)&&(HistoryDealGetString(Deal_Ticket,DEAL_SYMBOL)==SymbolTrade))
              {
               MFI_LastHistoryOrderPnL=HistoryDealGetDouble(Deal_Ticket,DEAL_PROFIT)+HistoryDealGetDouble(Deal_Ticket,DEAL_COMMISSION)+HistoryDealGetDouble(Deal_Ticket,DEAL_SWAP);
               //---
               if(HistoryDealGetInteger(Deal_Ticket,DEAL_ENTRY)==DEAL_ENTRY_OUT)
                  MFI_TotalHistoryOrders++;
               //---
               MFI_TotalHistoryProfitLoss+=HistoryDealGetDouble(Deal_Ticket,DEAL_PROFIT)+HistoryDealGetDouble(Deal_Ticket,DEAL_COMMISSION)+HistoryDealGetDouble(Deal_Ticket,DEAL_SWAP);
              }
           }
         //---------------------------------------------------------------------
         //MS_History
         //---------------------------------------------------------------------
         if(MS_StrategyRun==true)
           {
            if((HistoryDealGetInteger(Deal_Ticket,DEAL_MAGIC)==MS_OrdersID)&&(HistoryDealGetString(Deal_Ticket,DEAL_SYMBOL)==SymbolTrade))
              {
               MS_LastHistoryOrderPnL=HistoryDealGetDouble(Deal_Ticket,DEAL_PROFIT)+HistoryDealGetDouble(Deal_Ticket,DEAL_COMMISSION)+HistoryDealGetDouble(Deal_Ticket,DEAL_SWAP);
               //---
               if(HistoryDealGetInteger(Deal_Ticket,DEAL_ENTRY)==DEAL_ENTRY_OUT)
                  MS_TotalHistoryOrders++;
               //---
               MS_TotalHistoryProfitLoss+=HistoryDealGetDouble(Deal_Ticket,DEAL_PROFIT)+HistoryDealGetDouble(Deal_Ticket,DEAL_COMMISSION)+HistoryDealGetDouble(Deal_Ticket,DEAL_SWAP);
              }
           }
         //---------------------------------------------------------------------
        }
     }
//---------------------------------------------------------------------
   AC_HigherHistoryProfits=MathMax(AC_HigherHistoryProfits,AC_TotalHistoryProfitLoss);
   ADX_HigherHistoryProfits=MathMax(ADX_HigherHistoryProfits,ADX_TotalHistoryProfitLoss);
   AO_HigherHistoryProfits=MathMax(AO_HigherHistoryProfits,AO_TotalHistoryProfitLoss);
   DeM_HigherHistoryProfits=MathMax(DeM_HigherHistoryProfits,DeM_TotalHistoryProfitLoss);
   FBB_HigherHistoryProfits=MathMax(FBB_HigherHistoryProfits,FBB_TotalHistoryProfitLoss);
   MFI_HigherHistoryProfits=MathMax(MFI_HigherHistoryProfits,MFI_TotalHistoryProfitLoss);
   MS_HigherHistoryProfits=MathMax(MS_HigherHistoryProfits,MS_TotalHistoryProfitLoss);
//---------------------------------------------------------------------
   LastHistoryOrders=HistoryDealsTotal();
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//Lot size
//============================================================================================================================================================================================================================//
double CalcLots(int TypeOfOrder, int MagicOrder)
  {
//---------------------------------------------------------------------
//Set variables
   double LotSize=0;
   double FinalLotSize=0;
   double MultiplierLotSize=1;
//---------------------------------------------------------------------
//Set AC_Lot
//---------------------------------------------------------------------
   if(MagicOrder==AC_OrdersID)
     {
      if((AC_UseRecoveryLot>0)&&(AC_MultiRecoveryLot>0))
        {
         if(AC_UseRecoveryLot==1)
           {
            if(AC_LastHistoryOrderPnL>=0)
               MultiplierLotSize=1;
            else
               MultiplierLotSize=AC_MultiRecoveryLot;
           }
         //---
         if(AC_UseRecoveryLot==2)
           {
            if(AC_TotalHistoryProfitLoss<AC_HigherHistoryProfits)
               MultiplierLotSize=AC_MultiRecoveryLot;
            else
               MultiplierLotSize=1;
           }
        }
      else
         MultiplierLotSize=1;
      //---------------------------------------------------------------------
      //Calculate lot size
      if(AC_AutoLotSize==true)
         LotSize=((AccountInfoDouble(ACCOUNT_BALANCE)*AC_RiskFactor)/100000)*MultiplierLotSize;
      if(AC_AutoLotSize==false)
         LotSize=AC_ManualLotSize*MultiplierLotSize;
      //---------------------------------------------------------------------
      //Statical lot
      if(TypeOfOrder==ORDER_TYPE_BUY)
        {
         if(AC_BuyOrders==0)
            FinalLotSize=LotSize;
         if(AC_BuyOrders>=1)
            FinalLotSize=AC_LotFirstBuy;
        }
      //---
      if(TypeOfOrder==ORDER_TYPE_SELL)
        {
         if(AC_SellOrders==0)
            FinalLotSize=LotSize;
         if(AC_SellOrders>=1)
            FinalLotSize=AC_LotFirstSell;
        }
     }
//---------------------------------------------------------------------
//Set ADX_Lot
//---------------------------------------------------------------------
   if(MagicOrder==ADX_OrdersID)
     {
      if((ADX_UseRecoveryLot>0)&&(ADX_MultiRecoveryLot>0))
        {
         if(ADX_UseRecoveryLot==1)
           {
            if(ADX_LastHistoryOrderPnL>=0)
               MultiplierLotSize=1;
            else
               MultiplierLotSize=ADX_MultiRecoveryLot;
           }
         //---
         if(ADX_UseRecoveryLot==2)
           {
            if(ADX_TotalHistoryProfitLoss<ADX_HigherHistoryProfits)
               MultiplierLotSize=ADX_MultiRecoveryLot;
            else
               MultiplierLotSize=1;
           }
        }
      else
         MultiplierLotSize=1;
      //---------------------------------------------------------------------
      //Calculate lot size
      if(ADX_AutoLotSize==true)
         LotSize=((AccountInfoDouble(ACCOUNT_BALANCE)*ADX_RiskFactor)/100000)*MultiplierLotSize;
      if(ADX_AutoLotSize==false)
         LotSize=ADX_ManualLotSize*MultiplierLotSize;
      //---------------------------------------------------------------------
      //Statical lot
      if(TypeOfOrder==ORDER_TYPE_BUY)
        {
         if(ADX_BuyOrders==0)
            FinalLotSize=LotSize;
         if(ADX_BuyOrders>=1)
            FinalLotSize=ADX_LotFirstBuy;
        }
      //---
      if(TypeOfOrder==ORDER_TYPE_SELL)
        {
         if(ADX_SellOrders==0)
            FinalLotSize=LotSize;
         if(ADX_SellOrders>=1)
            FinalLotSize=ADX_LotFirstSell;
        }
     }
//---------------------------------------------------------------------
//Set AO_Lot
//---------------------------------------------------------------------
   if(MagicOrder==AO_OrdersID)
     {
      if((AO_UseRecoveryLot>0)&&(AO_MultiRecoveryLot>0))
        {
         if(AO_UseRecoveryLot==1)
           {
            if(AO_LastHistoryOrderPnL>=0)
               MultiplierLotSize=1;
            else
               MultiplierLotSize=AO_MultiRecoveryLot;
           }
         //---
         if(AO_UseRecoveryLot==2)
           {
            if(AO_TotalHistoryProfitLoss<AO_HigherHistoryProfits)
               MultiplierLotSize=AO_MultiRecoveryLot;
            else
               MultiplierLotSize=1;
           }
        }
      else
         MultiplierLotSize=1;
      //---------------------------------------------------------------------
      //Calculate lot size
      if(AO_AutoLotSize==true)
         LotSize=((AccountInfoDouble(ACCOUNT_BALANCE)*AO_RiskFactor)/100000)*MultiplierLotSize;
      if(AO_AutoLotSize==false)
         LotSize=AO_ManualLotSize*MultiplierLotSize;
      //---------------------------------------------------------------------
      //Statical lot
      if(TypeOfOrder==ORDER_TYPE_BUY)
        {
         if(AO_BuyOrders==0)
            FinalLotSize=LotSize;
         if(AO_BuyOrders>=1)
            FinalLotSize=AO_LotFirstBuy;
        }
      //---
      if(TypeOfOrder==ORDER_TYPE_SELL)
        {
         if(AO_SellOrders==0)
            FinalLotSize=LotSize;
         if(AO_SellOrders>=1)
            FinalLotSize=AO_LotFirstSell;
        }
     }
//---------------------------------------------------------------------
//Set DeM_Lot
//---------------------------------------------------------------------
   if(MagicOrder==DeM_OrdersID)
     {
      if((DeM_UseRecoveryLot>0)&&(DeM_MultiRecoveryLot>0))
        {
         if(DeM_UseRecoveryLot==1)
           {
            if(DeM_LastHistoryOrderPnL>=0)
               MultiplierLotSize=1;
            else
               MultiplierLotSize=DeM_MultiRecoveryLot;
           }
         //---
         if(DeM_UseRecoveryLot==2)
           {
            if(DeM_TotalHistoryProfitLoss<DeM_HigherHistoryProfits)
               MultiplierLotSize=DeM_MultiRecoveryLot;
            else
               MultiplierLotSize=1;
           }
        }
      else
         MultiplierLotSize=1;
      //---------------------------------------------------------------------
      //Calculate lot size
      if(DeM_AutoLotSize==true)
         LotSize=((AccountInfoDouble(ACCOUNT_BALANCE)*DeM_RiskFactor)/100000)*MultiplierLotSize;
      if(DeM_AutoLotSize==false)
         LotSize=DeM_ManualLotSize*MultiplierLotSize;
      //---------------------------------------------------------------------
      //Statical lot
      if(TypeOfOrder==ORDER_TYPE_BUY)
        {
         if(DeM_BuyOrders==0)
            FinalLotSize=LotSize;
         if(DeM_BuyOrders>=1)
            FinalLotSize=DeM_LotFirstBuy;
        }
      //---
      if(TypeOfOrder==ORDER_TYPE_SELL)
        {
         if(DeM_SellOrders==0)
            FinalLotSize=LotSize;
         if(DeM_SellOrders>=1)
            FinalLotSize=DeM_LotFirstSell;
        }
     }
//---------------------------------------------------------------------
//Set FBB_Lot
//---------------------------------------------------------------------
   if(MagicOrder==FBB_OrdersID)
     {
      if((FBB_UseRecoveryLot>0)&&(FBB_MultiRecoveryLot>0))
        {
         if(FBB_UseRecoveryLot==1)
           {
            if(FBB_LastHistoryOrderPnL>=0)
               MultiplierLotSize=1;
            else
               MultiplierLotSize=FBB_MultiRecoveryLot;
           }
         //---
         if(FBB_UseRecoveryLot==2)
           {
            if(FBB_TotalHistoryProfitLoss<FBB_HigherHistoryProfits)
               MultiplierLotSize=FBB_MultiRecoveryLot;
            else
               MultiplierLotSize=1;
           }
        }
      else
         MultiplierLotSize=1;
      //---------------------------------------------------------------------
      //Calculate lot size
      if(FBB_AutoLotSize==true)
         LotSize=((AccountInfoDouble(ACCOUNT_BALANCE)*FBB_RiskFactor)/100000)*MultiplierLotSize;
      if(FBB_AutoLotSize==false)
         LotSize=FBB_ManualLotSize*MultiplierLotSize;
      //---------------------------------------------------------------------
      //Statical lot
      if(TypeOfOrder==ORDER_TYPE_BUY)
        {
         if(FBB_BuyOrders==0)
            FinalLotSize=LotSize;
         if(FBB_BuyOrders>=1)
            FinalLotSize=FBB_LotFirstBuy;
        }
      //---
      if(TypeOfOrder==ORDER_TYPE_SELL)
        {
         if(FBB_SellOrders==0)
            FinalLotSize=LotSize;
         if(FBB_SellOrders>=1)
            FinalLotSize=FBB_LotFirstSell;
        }
     }
//---------------------------------------------------------------------
//Set MFI_Lot
//---------------------------------------------------------------------
   if(MagicOrder==MFI_OrdersID)
     {
      if((MFI_UseRecoveryLot>0)&&(MFI_MultiRecoveryLot>0))
        {
         if(MFI_UseRecoveryLot==1)
           {
            if(MFI_LastHistoryOrderPnL>=0)
               MultiplierLotSize=1;
            else
               MultiplierLotSize=MFI_MultiRecoveryLot;
           }
         //---
         if(MFI_UseRecoveryLot==2)
           {
            if(MFI_TotalHistoryProfitLoss<MFI_HigherHistoryProfits)
               MultiplierLotSize=MFI_MultiRecoveryLot;
            else
               MultiplierLotSize=1;
           }
        }
      else
         MultiplierLotSize=1;
      //---------------------------------------------------------------------
      //Calculate lot size
      if(MFI_AutoLotSize==true)
         LotSize=((AccountInfoDouble(ACCOUNT_BALANCE)*MFI_RiskFactor)/100000)*MultiplierLotSize;
      if(MFI_AutoLotSize==false)
         LotSize=MFI_ManualLotSize*MultiplierLotSize;
      //---------------------------------------------------------------------
      //Statical lot
      if(TypeOfOrder==ORDER_TYPE_BUY)
        {
         if(MFI_BuyOrders==0)
            FinalLotSize=LotSize;
         if(MFI_BuyOrders>=1)
            FinalLotSize=MFI_LotFirstBuy;
        }
      //---
      if(TypeOfOrder==ORDER_TYPE_SELL)
        {
         if(MFI_SellOrders==0)
            FinalLotSize=LotSize;
         if(MFI_SellOrders>=1)
            FinalLotSize=MFI_LotFirstSell;
        }
     }
//---------------------------------------------------------------------
//Set MS_Lot
//---------------------------------------------------------------------
   if(MagicOrder==MS_OrdersID)
     {
      if((MS_UseRecoveryLot>0)&&(MS_MultiRecoveryLot>0))
        {
         if(MS_UseRecoveryLot==1)
           {
            if(MS_LastHistoryOrderPnL>=0)
               MultiplierLotSize=1;
            else
               MultiplierLotSize=MS_MultiRecoveryLot;
           }
         //---
         if(MS_UseRecoveryLot==2)
           {
            if(MS_TotalHistoryProfitLoss<MS_HigherHistoryProfits)
               MultiplierLotSize=MS_MultiRecoveryLot;
            else
               MultiplierLotSize=1;
           }
        }
      else
         MultiplierLotSize=1;
      //---------------------------------------------------------------------
      //Calculate lot size
      if(MS_AutoLotSize==true)
         LotSize=((AccountInfoDouble(ACCOUNT_BALANCE)*MS_RiskFactor)/100000)*MultiplierLotSize;
      if(MS_AutoLotSize==false)
         LotSize=MS_ManualLotSize*MultiplierLotSize;
      //---------------------------------------------------------------------
      //Statical lot
      if(TypeOfOrder==ORDER_TYPE_BUY)
        {
         if(MS_BuyOrders==0)
            FinalLotSize=LotSize;
         if(MS_BuyOrders>=1)
            FinalLotSize=MS_LotFirstBuy;
        }
      //---
      if(TypeOfOrder==ORDER_TYPE_SELL)
        {
         if(MS_SellOrders==0)
            FinalLotSize=LotSize;
         if(MS_SellOrders>=1)
            FinalLotSize=MS_LotFirstSell;
        }
     }
//---------------------------------------------------------------------
   if(FinalLotSize+AC_TotalLotsBuy+AC_TotalLotsSell+ADX_TotalLotsBuy+ADX_TotalLotsSell+AO_TotalLotsBuy+AO_TotalLotsSell+DeM_TotalLotsBuy+DeM_TotalLotsSell+FBB_TotalLotsBuy+FBB_TotalLotsSell+MFI_TotalLotsBuy+MFI_TotalLotsSell+MS_TotalLotsBuy+MS_TotalLotsSell>SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_MAX))
      FinalLotSize=SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_MAX)-(AC_TotalLotsBuy+AC_TotalLotsSell+ADX_TotalLotsBuy+ADX_TotalLotsSell+AO_TotalLotsBuy+AO_TotalLotsSell+DeM_TotalLotsBuy+DeM_TotalLotsSell+FBB_TotalLotsBuy+FBB_TotalLotsSell+MFI_TotalLotsBuy+MFI_TotalLotsSell+MS_TotalLotsBuy+MS_TotalLotsSell);
//---------------------------------------------------------------------
//Return final lot size
   return(MathMin(MathMax((MathRound(FinalLotSize/SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_STEP))*SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_STEP)),SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_MIN)),SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_MAX)));
//---------------------------------------------------------------------
  }
//===============================================================================================================================================================================================================================//
//Draw objects
//===============================================================================================================================================================================================================================//
void DrawObjects(string StringName, color ImageColor, int TypeBorder, bool InBackGround, int Xposition, int Yposition, int Xsize, int Ysize)
  {
//---------------------------------------------------------------------
   ObjectCreate(0,StringName,OBJ_RECTANGLE_LABEL,0,0,0,0,0);
   ObjectSetInteger(0,StringName,OBJPROP_XDISTANCE,Xposition);
   ObjectSetInteger(0,StringName,OBJPROP_YDISTANCE,Yposition);
   ObjectSetInteger(0,StringName,OBJPROP_XSIZE,Xsize);
   ObjectSetInteger(0,StringName,OBJPROP_YSIZE,Ysize);
   ObjectSetInteger(0,StringName,OBJPROP_BGCOLOR,ImageColor);
   ObjectSetInteger(0,StringName,OBJPROP_BORDER_TYPE,TypeBorder);
   ObjectSetInteger(0,StringName,OBJPROP_BORDER_COLOR,clrBlack);
   ObjectSetInteger(0,StringName,OBJPROP_BACK,InBackGround);
   ObjectSetInteger(0,StringName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,StringName,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,StringName,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,StringName,OBJPROP_ZORDER,0);
//---------------------------------------------------------------------
  }
//===============================================================================================================================================================================================================================//
//Draw Text
//===============================================================================================================================================================================================================================//
void DisplayText(string StringName, string Image, int FontSize, string TypeImage, color FontColor, int Xposition, int Yposition)
  {
//---------------------------------------------------------------------
   ObjectCreate(0,StringName,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,StringName,OBJPROP_CORNER,0);
   ObjectSetInteger(0,StringName,OBJPROP_BACK,false);
   ObjectSetInteger(0,StringName,OBJPROP_XDISTANCE,Xposition);
   ObjectSetInteger(0,StringName,OBJPROP_YDISTANCE,Yposition);
   ObjectSetInteger(0,StringName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,StringName,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,StringName,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,StringName,OBJPROP_COLOR,FontColor);
   ObjectSetInteger(0,StringName,OBJPROP_FONTSIZE,FontSize);
   ObjectSetString(0,StringName,OBJPROP_TEXT,Image);
   ObjectSetString(0,StringName,OBJPROP_FONT,TypeImage);
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//Comment in chart
//============================================================================================================================================================================================================================//
void CommentScreen()
  {
//---------------------------------------------------------------------
//Set variables
   string StringSpread1="";
   string StringSpread2="";
   string MaxSpreadStr;
//---------------------------------------------------------------------
   string AC_MoneyManagementStr="";
   string AC_OrdersStr="";
   string AC_HistoryResStr="";
   string AC_MMstring="";
//---------------------------------------------------------------------
   string ADX_MoneyManagementStr="";
   string ADX_OrdersStr="";
   string ADX_HistoryResStr="";
   string ADX_MMstring="";
//---------------------------------------------------------------------
   string AO_MoneyManagementStr="";
   string AO_OrdersStr="";
   string AO_HistoryResStr="";
   string AO_MMstring="";
//---------------------------------------------------------------------
   string DeM_MoneyManagementStr="";
   string DeM_OrdersStr="";
   string DeM_HistoryResStr="";
   string DeM_MMstring="";
//---------------------------------------------------------------------
   string FBB_MoneyManagementStr="";
   string FBB_OrdersStr="";
   string FBB_HistoryResStr="";
   string FBB_MMstring="";
//---------------------------------------------------------------------
   string MFI_MoneyManagementStr="";
   string MFI_OrdersStr="";
   string MFI_HistoryResStr="";
   string MFI_MMstring="";
//---------------------------------------------------------------------
   string MS_MoneyManagementStr="";
   string MS_OrdersStr="";
   string MS_HistoryResStr="";
   string MS_MMstring="";
//---------------------------------------------------------------------
//String money management
   if(AC_AutoLotSize==true)
      AC_MMstring="Auto";
//---
   if(AC_AutoLotSize==false)
      AC_MMstring="Manual";
//---------------------------------------------------------------------
   if(ADX_AutoLotSize==true)
      ADX_MMstring="Auto";
//---
   if(ADX_AutoLotSize==false)
      ADX_MMstring="Manual";
//---------------------------------------------------------------------
   if(AO_AutoLotSize==true)
      AO_MMstring="Auto";
//---
   if(AO_AutoLotSize==false)
      AO_MMstring="Manual";
//---------------------------------------------------------------------
   if(DeM_AutoLotSize==true)
      DeM_MMstring="Auto";
//---
   if(DeM_AutoLotSize==false)
      DeM_MMstring="Manual";
//---------------------------------------------------------------------
   if(FBB_AutoLotSize==true)
      FBB_MMstring="Auto";
//---
   if(FBB_AutoLotSize==false)
      FBB_MMstring="Manual";
//---------------------------------------------------------------------
   if(MFI_AutoLotSize==true)
      MFI_MMstring="Auto";
//---
   if(MFI_AutoLotSize==false)
      MFI_MMstring="Manual";
//---------------------------------------------------------------------
   if(MS_AutoLotSize==true)
      MS_MMstring="Auto";
//---
   if(MS_AutoLotSize==false)
      MS_MMstring="Manual";
//---------------------------------------------------------------------
//String spread
   if(MaxSpread==0)
     {
      MaxSpreadStr="None";
      StringSpread1="EA NOT CHECK SPREAD.  Expert running...";
     }
//---
   if((Spread<=MaxSpread)&&(MaxSpread>0))
      StringSpread1="Acceptable Spread.  Expert is running";
//---
   if((Spread>MaxSpread)&&(MaxSpread>0))
      StringSpread1="Unacceptable Spread. EA stop running";
//---
   if(MaxSpread!=0)
      MaxSpreadStr=DoubleToString(MaxSpread,2);
//---------------------------------------------------------------------
//Strings
   StringSpread2="Max Spread: "+MaxSpreadStr+" || Current Spread: "+DoubleToString(Spread,2);
//---------------------------------------------------------------------
   if(AC_StrategyRun==true)
     {
      AC_MoneyManagementStr="AC MM: "+AC_MMstring+" || Lot Buy: "+DoubleToString(CalcLots(ORDER_TYPE_BUY,AC_OrdersID),2)+" || Lot Sell: "+DoubleToString(CalcLots(ORDER_TYPE_SELL,AC_OrdersID),2);
      AC_OrdersStr="AC Orders: "+IntegerToString(AC_BuyOrders+AC_SellOrders)+" || AC Floating: "+DoubleToString(AC_FloatingBuy+AC_FloatingSell,2);
      AC_HistoryResStr="AC Orders: "+DoubleToString(AC_TotalHistoryOrders,0)+" || AC Results: "+DoubleToString(AC_TotalHistoryProfitLoss,2);
     }
   else
     {
      AC_MoneyManagementStr="AC strategy it's not activated by the user";
      AC_OrdersStr="AC strategy it's not activated by the user";
      AC_HistoryResStr="AC strategy it's not activated by the user";
     }
//---------------------------------------------------------------------
   if(ADX_StrategyRun==true)
     {
      ADX_MoneyManagementStr="ADX MM: "+ADX_MMstring+" || Lot Buy: "+DoubleToString(CalcLots(ORDER_TYPE_BUY,ADX_OrdersID),2)+" || Lot Sell: "+DoubleToString(CalcLots(ORDER_TYPE_SELL,ADX_OrdersID),2);
      ADX_OrdersStr="ADX Orders: "+IntegerToString(ADX_BuyOrders+ADX_SellOrders)+" || ADX Floating: "+DoubleToString(ADX_FloatingBuy+ADX_FloatingSell,2);
      ADX_HistoryResStr="ADX Orders: "+DoubleToString(ADX_TotalHistoryOrders,0)+" || ADX Results: "+DoubleToString(ADX_TotalHistoryProfitLoss,2);
     }
   else
     {
      ADX_MoneyManagementStr="ADX strategy it's not activated by the user";
      ADX_OrdersStr="ADX strategy it's not activated by the user";
      ADX_HistoryResStr="ADX strategy it's not activated by the user";
     }
//---------------------------------------------------------------------
   if(AO_StrategyRun==true)
     {
      AO_MoneyManagementStr="AO MM: "+AO_MMstring+" || Lot Buy: "+DoubleToString(CalcLots(ORDER_TYPE_BUY,AO_OrdersID),2)+" || Lot Sell: "+DoubleToString(CalcLots(ORDER_TYPE_SELL,AO_OrdersID),2);
      AO_OrdersStr="AO Orders: "+IntegerToString(AO_BuyOrders+AO_SellOrders)+" || AO Floating: "+DoubleToString(AO_FloatingBuy+AO_FloatingSell,2);
      AO_HistoryResStr="AO Orders: "+DoubleToString(AO_TotalHistoryOrders,0)+" || AO Results: "+DoubleToString(AO_TotalHistoryProfitLoss,2);
     }
   else
     {
      AO_MoneyManagementStr="AO strategy it's not activated by the user";
      AO_OrdersStr="AO strategy it's not activated by the user";
      AO_HistoryResStr="AO strategy it's not activated by the user";
     }
//---------------------------------------------------------------------
   if(DeM_StrategyRun==true)
     {
      DeM_MoneyManagementStr="DeM MM: "+DeM_MMstring+" || Lot Buy: "+DoubleToString(CalcLots(ORDER_TYPE_BUY,DeM_OrdersID),2)+" || Lot Sell: "+DoubleToString(CalcLots(ORDER_TYPE_SELL,DeM_OrdersID),2);
      DeM_OrdersStr="DeM Orders: "+IntegerToString(DeM_BuyOrders+DeM_SellOrders)+" || DeM Floating: "+DoubleToString(DeM_FloatingBuy+DeM_FloatingSell,2);
      DeM_HistoryResStr="DeM Orders: "+DoubleToString(DeM_TotalHistoryOrders,0)+" || DeM Results: "+DoubleToString(DeM_TotalHistoryProfitLoss,2);
     }
   else
     {
      DeM_MoneyManagementStr="DeM strategy it's not activated by the user";
      DeM_OrdersStr="DeM strategy it's not activated by the user";
      DeM_HistoryResStr="DeM strategy it's not activated by the user";
     }
//---------------------------------------------------------------------
   if(FBB_StrategyRun==true)
     {
      FBB_MoneyManagementStr="FBB MM: "+FBB_MMstring+" || Lot Buy: "+DoubleToString(CalcLots(ORDER_TYPE_BUY,FBB_OrdersID),2)+" || Lot Sell: "+DoubleToString(CalcLots(ORDER_TYPE_SELL,FBB_OrdersID),2);
      FBB_OrdersStr="FBB Orders: "+IntegerToString(FBB_BuyOrders+FBB_SellOrders)+" || FBB Floating: "+DoubleToString(FBB_FloatingBuy+FBB_FloatingSell,2);
      FBB_HistoryResStr="FBB Orders: "+DoubleToString(FBB_TotalHistoryOrders,0)+" || FBB Results: "+DoubleToString(FBB_TotalHistoryProfitLoss,2);
     }
   else
     {
      FBB_MoneyManagementStr="FBB strategy it's not activated by the user";
      FBB_OrdersStr="FBB strategy it's not activated by the user";
      FBB_HistoryResStr="FBB strategy it's not activated by the user";
     }
//---------------------------------------------------------------------
   if(MFI_StrategyRun==true)
     {
      MFI_MoneyManagementStr="MFI MM: "+MFI_MMstring+" || Lot Buy: "+DoubleToString(CalcLots(ORDER_TYPE_BUY,MFI_OrdersID),2)+" || Lot Sell: "+DoubleToString(CalcLots(ORDER_TYPE_SELL,MFI_OrdersID),2);
      MFI_OrdersStr="MFI Orders: "+IntegerToString(MFI_BuyOrders+MFI_SellOrders)+" || MFI Floating: "+DoubleToString(MFI_FloatingBuy+MFI_FloatingSell,2);
      MFI_HistoryResStr="MFI Orders: "+DoubleToString(MFI_TotalHistoryOrders,0)+" || MFI Results: "+DoubleToString(MFI_TotalHistoryProfitLoss,2);
     }
   else
     {
      MFI_MoneyManagementStr="MFI strategy it's not activated by the user";
      MFI_OrdersStr="MFI strategy it's not activated by the user";
      MFI_HistoryResStr="MFI strategy it's not activated by the user";
     }
//---------------------------------------------------------------------
   if(MS_StrategyRun==true)
     {
      MS_MoneyManagementStr="MS MM: "+MS_MMstring+" || Lot Buy: "+DoubleToString(CalcLots(ORDER_TYPE_BUY,MS_OrdersID),2)+" || Lot Sell: "+DoubleToString(CalcLots(ORDER_TYPE_SELL,MS_OrdersID),2);
      MS_OrdersStr="MS Orders: "+IntegerToString(MS_BuyOrders+MS_SellOrders)+" || MS Floating: "+DoubleToString(MS_FloatingBuy+MS_FloatingSell,2);
      MS_HistoryResStr="MS Orders: "+DoubleToString(MS_TotalHistoryOrders,0)+" || MS Results: "+DoubleToString(MS_TotalHistoryProfitLoss,2);
     }
   else
     {
      MS_MoneyManagementStr="MS strategy it's not activated by the user";
      MS_OrdersStr="MS strategy it's not activated by the user";
      MS_HistoryResStr="MS strategy it's not activated by the user";
     }
//---------------------------------------------------------------------
//Lines on chart
   if(ObjectFind(0,"Com1")==-1)
      DisplayText("Com1",StringSubstr(ExpertName,0,ExpertNameLen)+" - 2023 by Pannik ®",11,"Arial Black",ColorExpertName,10,16);
//---
   if(ObjectFind(0,"Com2")==-1)
      DisplayText("Com2","___________________________________________",10,"Arial Black",ColorOffLines,5,22);
//---
   if(ObjectFind(0,"Com3")==-1)
      DisplayText("Com3","___________________________________________",10,"Arial Black",ColorOffLines,5,60);
//---
   if(ObjectFind(0,"Com4")==-1)
      DisplayText("Com4","___________________________________________",10,"Arial Black",ColorOffLines,5,172);
//---
   if(ObjectFind(0,"Com5")==-1)
      DisplayText("Com5","___________________________________________",10,"Arial Black",ColorOffLines,5,282);
//---------------------------------------------------------------------
//Comment on chart
   if(ObjectFind(0,"Com6")==-1)
      DisplayText("Com6",StringSpread1,10,"Arial",ColorSpreadInfo,10,40);
//---
   if(ObjectFind(0,"Com7")==-1)
      ObjectDelete(0,"Com7");
   DisplayText("Com7",StringSpread2,10,"Arial",ColorSpreadInfo,10,56);
//---
   if(ObjectFind(0,"Com8")>-1)
      ObjectDelete(0,"Com8");
   DisplayText("Com8",AC_MoneyManagementStr,10,"Arial",ColorMoneyMngmnt,10,78);
//---
   if(ObjectFind(0,"Com9")>-1)
      ObjectDelete(0,"Com9");
   DisplayText("Com9",ADX_MoneyManagementStr,10,"Arial",ColorMoneyMngmnt,10,94);
//---
   if(ObjectFind(0,"Com10")>-1)
      ObjectDelete(0,"Com10");
   DisplayText("Com10",AO_MoneyManagementStr,10,"Arial",ColorMoneyMngmnt,10,110);
//---
   if(ObjectFind(0,"Com11")>-1)
      ObjectDelete(0,"Com11");
   DisplayText("Com11",DeM_MoneyManagementStr,10,"Arial",ColorMoneyMngmnt,10,126);
//---
   if(ObjectFind(0,"Com12")>-1)
      ObjectDelete(0,"Com12");
   DisplayText("Com12",FBB_MoneyManagementStr,10,"Arial",ColorMoneyMngmnt,10,140);
//---
   if(ObjectFind(0,"Com13")>-1)
      ObjectDelete(0,"Com13");
   DisplayText("Com13",MFI_MoneyManagementStr,10,"Arial",ColorMoneyMngmnt,10,156);
//---
   if(ObjectFind(0,"Com14")>-1)
      ObjectDelete(0,"Com14");
   DisplayText("Com14",MS_MoneyManagementStr,10,"Arial",ColorMoneyMngmnt,10,170);
//---
//---
//---
   if(ObjectFind(0,"Com15")>-1)
      ObjectDelete(0,"Com15");
   DisplayText("Com15",AC_OrdersStr,10,"Arial",ColorCurrentOrders,10,190);
//---
   if(ObjectFind(0,"Com16")>-1)
      ObjectDelete(0,"Com16");
   DisplayText("Com16",ADX_OrdersStr,10,"Arial",ColorCurrentOrders,10,206);
//---
   if(ObjectFind(0,"Com17")>-1)
      ObjectDelete(0,"Com17");
   DisplayText("Com17",AO_OrdersStr,10,"Arial",ColorCurrentOrders,10,220);
//---
   if(ObjectFind(0,"Com18")>-1)
      ObjectDelete(0,"Com18");
   DisplayText("Com18",DeM_OrdersStr,10,"Arial",ColorCurrentOrders,10,236);
//---
   if(ObjectFind(0,"Com19")>-1)
      ObjectDelete(0,"Com19");
   DisplayText("Com19",FBB_OrdersStr,10,"Arial",ColorCurrentOrders,10,250);
//---
   if(ObjectFind(0,"Com20")>-1)
      ObjectDelete(0,"Com20");
   DisplayText("Com20",MFI_OrdersStr,10,"Arial",ColorCurrentOrders,10,266);
//---
   if(ObjectFind(0,"Com21")>-1)
      ObjectDelete(0,"Com21");
   DisplayText("Com21",MS_OrdersStr,10,"Arial",ColorCurrentOrders,10,280);
//---
   if(ObjectFind(0,"Com22")>-1)
      ObjectDelete(0,"Com22");
   DisplayText("Com22","          H I S T O R Y    R E S U L T S",10,"Arial",ColorHistoryOrders,10,300);
//---
//---
//---
   if(ObjectFind(0,"Com23")>-1)
      ObjectDelete(0,"Com23");
   DisplayText("Com23",AC_HistoryResStr,10,"Arial",ColorHistoryOrders,10,316);
//---
   if(ObjectFind(0,"Com24")>-1)
      ObjectDelete(0,"Com24");
   DisplayText("Com24",ADX_HistoryResStr,10,"Arial",ColorHistoryOrders,10,332);
//---
   if(ObjectFind(0,"Com25")>-1)
      ObjectDelete(0,"Com25");
   DisplayText("Com25",AO_HistoryResStr,10,"Arial",ColorHistoryOrders,10,348);
//---
   if(ObjectFind(0,"Com26")>-1)
      ObjectDelete(0,"Com26");
   DisplayText("Com26",DeM_HistoryResStr,10,"Arial",ColorHistoryOrders,10,364);
//---
   if(ObjectFind(0,"Com27")>-1)
      ObjectDelete(0,"Com27");
   DisplayText("Com27",FBB_HistoryResStr,10,"Arial",ColorHistoryOrders,10,380);
//---
   if(ObjectFind(0,"Com28")>-1)
      ObjectDelete(0,"Com28");
   DisplayText("Com28",MFI_HistoryResStr,10,"Arial",ColorHistoryOrders,10,396);
//---
   if(ObjectFind(0,"Com29")>-1)
      ObjectDelete(0,"Com29");
   DisplayText("Com29",MS_HistoryResStr,10,"Arial",ColorHistoryOrders,10,412);
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//AC_Signals
//============================================================================================================================================================================================================================//
void AC_GetSignals()
  {
//---------------------------------------------------------------------
//Set variables
   bool AC_OpenBuy_1=false;
   bool AC_OpenSell_1=false;
//---
   bool AC_CloseBuy_1=false;
   bool AC_CloseSell_1=false;
//---------------------------------------------------------------------
   double AC_Value_Array[];
//---------------------------------------------------------------------
//Sort price array from current data
   ArraySetAsSeries(AC_Value_Array,true);
//---------------------------------------------------------------------
//Filling data according to created indicator
   CopyBuffer(AC,0,0,3,AC_Value_Array);
//---------------------------------------------------------------------
//Getting value of current data
   double AC_Value_0=NormalizeDouble(AC_Value_Array[0]*40000,3);
   double AC_Value_1=NormalizeDouble(AC_Value_Array[1]*40000,3);
//---------------------------------------------------------------------
//Set levels
   double LevelOpenUp=AC_LevelOpenOrders;
   double LevelOpenDn=-AC_LevelOpenOrders;
   double LevelCloseUp=AC_LevelCloseOrders;
   double LevelCloseDn=-AC_LevelCloseOrders;
//---------------------------------------------------------------------
//Signals open orders
   if(AC_OpenOrdersType>0)
     {
      switch(AC_OpenOrdersType)
        {
         case 1:
            if((AC_Value_0>LevelOpenUp)&&(AC_Value_1>LevelOpenUp)&&(AC_Value_0>AC_Value_1))
               AC_OpenBuy_1=true;
            if((AC_Value_0<LevelOpenDn)&&(AC_Value_1<LevelOpenDn)&&(AC_Value_0<AC_Value_1))
               AC_OpenSell_1=true;
            break;
         case 2:
            if((AC_Value_0>LevelOpenUp)&&(AC_Value_1<LevelOpenUp)&&(AC_Value_0>AC_Value_1))
               AC_OpenBuy_1=true;
            if((AC_Value_0<LevelOpenDn)&&(AC_Value_1>LevelOpenDn)&&(AC_Value_0<AC_Value_1))
               AC_OpenSell_1=true;
            break;
         case 3:
            if((AC_Value_0>LevelOpenUp)&&(AC_Value_1>LevelOpenUp)&&(AC_Value_0<AC_Value_1))
               AC_OpenBuy_1=true;
            if((AC_Value_0<LevelOpenDn)&&(AC_Value_1<LevelOpenDn)&&(AC_Value_0>AC_Value_1))
               AC_OpenSell_1=true;
            break;
         case 4:
            if((AC_Value_0<LevelOpenUp)&&(AC_Value_1>LevelOpenUp)&&(AC_Value_0<AC_Value_1))
               AC_OpenBuy_1=true;
            if((AC_Value_0>LevelOpenDn)&&(AC_Value_1<LevelOpenDn)&&(AC_Value_0>AC_Value_1))
               AC_OpenSell_1=true;
            break;
         //---
         case 5:
            if((AC_Value_0<LevelOpenDn)&&(AC_Value_1<LevelOpenDn)&&(AC_Value_0<AC_Value_1))
               AC_OpenBuy_1=true;
            if((AC_Value_0>LevelOpenUp)&&(AC_Value_1>LevelOpenUp)&&(AC_Value_0>AC_Value_1))
               AC_OpenSell_1=true;
            break;
         case 6:
            if((AC_Value_0<LevelOpenDn)&&(AC_Value_1>LevelOpenDn)&&(AC_Value_0<AC_Value_1))
               AC_OpenBuy_1=true;
            if((AC_Value_0>LevelOpenUp)&&(AC_Value_1<LevelOpenUp)&&(AC_Value_0>AC_Value_1))
               AC_OpenSell_1=true;
            break;
         case 7:
            if((AC_Value_0<LevelOpenDn)&&(AC_Value_1<LevelOpenDn)&&(AC_Value_0>AC_Value_1))
               AC_OpenBuy_1=true;
            if((AC_Value_0>LevelOpenUp)&&(AC_Value_1>LevelOpenUp)&&(AC_Value_0<AC_Value_1))
               AC_OpenSell_1=true;
            break;
         case 8:
            if((AC_Value_0>LevelOpenDn)&&(AC_Value_1<LevelOpenDn)&&(AC_Value_0>AC_Value_1))
               AC_OpenBuy_1=true;
            if((AC_Value_0<LevelOpenUp)&&(AC_Value_1>LevelOpenUp)&&(AC_Value_0<AC_Value_1))
               AC_OpenSell_1=true;
            break;
        }
     }
//---------------------------------------------------------------------
//Signals close orders
   if(AC_SumOrders>0)
     {
      if(AC_CloseOrdersType>0)
        {
         if(AC_CloseInSignals==true)
           {
            switch(AC_CloseOrdersType)
              {
               case 1:
                  if((AC_Value_0>LevelCloseUp)&&(AC_Value_1>LevelCloseUp)&&(AC_Value_0>AC_Value_1))
                     AC_CloseBuy_1=true;
                  if((AC_Value_0<LevelCloseDn)&&(AC_Value_1<LevelCloseDn)&&(AC_Value_0<AC_Value_1))
                     AC_CloseSell_1=true;
                  break;
               case 2:
                  if((AC_Value_0>LevelCloseUp)&&(AC_Value_1<LevelCloseUp)&&(AC_Value_0>AC_Value_1))
                     AC_CloseBuy_1=true;
                  if((AC_Value_0<LevelCloseDn)&&(AC_Value_1>LevelCloseDn)&&(AC_Value_0<AC_Value_1))
                     AC_CloseSell_1=true;
                  break;
               case 3:
                  if((AC_Value_0>LevelCloseUp)&&(AC_Value_1>LevelCloseUp)&&(AC_Value_0<AC_Value_1))
                     AC_CloseBuy_1=true;
                  if((AC_Value_0<LevelCloseDn)&&(AC_Value_1<LevelCloseDn)&&(AC_Value_0>AC_Value_1))
                     AC_CloseSell_1=true;
                  break;
               case 4:
                  if((AC_Value_0<LevelCloseUp)&&(AC_Value_1>LevelCloseUp)&&(AC_Value_0<AC_Value_1))
                     AC_CloseBuy_1=true;
                  if((AC_Value_0>LevelCloseDn)&&(AC_Value_1<LevelCloseDn)&&(AC_Value_0>AC_Value_1))
                     AC_CloseSell_1=true;
                  break;
               //---
               case 5:
                  if((AC_Value_0<LevelCloseDn)&&(AC_Value_1<LevelCloseDn)&&(AC_Value_0<AC_Value_1))
                     AC_CloseBuy_1=true;
                  if((AC_Value_0>LevelCloseUp)&&(AC_Value_1>LevelCloseUp)&&(AC_Value_0>AC_Value_1))
                     AC_CloseSell_1=true;
                  break;
               case 6:
                  if((AC_Value_0<LevelCloseDn)&&(AC_Value_1>LevelCloseDn)&&(AC_Value_0<AC_Value_1))
                     AC_CloseBuy_1=true;
                  if((AC_Value_0>LevelCloseUp)&&(AC_Value_1<LevelCloseUp)&&(AC_Value_0>AC_Value_1))
                     AC_CloseSell_1=true;
                  break;
               case 7:
                  if((AC_Value_0<LevelCloseDn)&&(AC_Value_1<LevelCloseDn)&&(AC_Value_0>AC_Value_1))
                     AC_CloseBuy_1=true;
                  if((AC_Value_0>LevelCloseUp)&&(AC_Value_1>LevelCloseUp)&&(AC_Value_0<AC_Value_1))
                     AC_CloseSell_1=true;
                  break;
               case 8:
                  if((AC_Value_0>LevelCloseDn)&&(AC_Value_1<LevelCloseDn)&&(AC_Value_0>AC_Value_1))
                     AC_CloseBuy_1=true;
                  if((AC_Value_0<LevelCloseUp)&&(AC_Value_1>LevelCloseUp)&&(AC_Value_0<AC_Value_1))
                     AC_CloseSell_1=true;
                  break;
              }
           }
        }
     }
//---------------------------------------------------------------------
//Final signals open orders
   if(AC_OpenBuy_1==true)
      AC_OpenBuy=true;
   if(AC_OpenSell_1==true)
      AC_OpenSell=true;
//---------------------------------------------------------------------
//Final signals close orders
   if(AC_CloseInSignals==true)
     {
      if(AC_CloseBuy_1==true)
         AC_CloseBuy=true;
      if(AC_CloseSell_1==true)
         AC_CloseSell=true;
     }
//---------------------------------------------------------------------
//Close orders in reverse signal
   if(CloseInReverse==true)
     {
      if(AC_OpenBuy==true)
         AC_CloseSell=true;
      if(AC_OpenSell==true)
         AC_CloseBuy=true;
     }
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//ADX_Signals
//============================================================================================================================================================================================================================//
void ADX_GetSignals()
  {
//---------------------------------------------------------------------
//Set variables
   bool ADX_OpenBuy_1=false;
   bool ADX_OpenSell_1=false;
//---
   bool ADX_CloseBuy_1=false;
   bool ADX_CloseSell_1=false;
//---------------------------------------------------------------------
   double ADX_Value_Array[];
   double Plus_DI_Array[];
   double Mimus_DI_Array[];
//---------------------------------------------------------------------
//Sort price array from current data
   ArraySetAsSeries(ADX_Value_Array,true);
   ArraySetAsSeries(Plus_DI_Array,true);
   ArraySetAsSeries(Mimus_DI_Array,true);
//---------------------------------------------------------------------
//Filling data according to created indicator
   CopyBuffer(ADX,0,0,3,ADX_Value_Array);
   CopyBuffer(ADX,1,0,3,Plus_DI_Array);
   CopyBuffer(ADX,2,0,3,Mimus_DI_Array);
//---------------------------------------------------------------------
//Getting value of current data
   double ADX_Value_0=NormalizeDouble(ADX_Value_Array[0],2);
   double ADX_Value_1=NormalizeDouble(ADX_Value_Array[1],2);
   double Plus_DI=NormalizeDouble(Plus_DI_Array[0],2);
   double Minus_DI=NormalizeDouble(Mimus_DI_Array[0],2);
//---------------------------------------------------------------------
//Signals open orders
   if(ADX_OpenOrdersType>0)
     {
      if(ADX_Value_0>ADX_LevelOpenOrders_1)
        {
         switch(ADX_OpenOrdersType)
           {
            case 1:
               if(ADX_Value_0>ADX_LevelOpenOrders_1)
                 {
                  if(ADX_Value_0>ADX_Value_1)
                    {
                     if((Plus_DI>Minus_DI)&&(Plus_DI>ADX_LevelOpenOrders_2))
                        ADX_OpenBuy_1=true;
                     if((Plus_DI<Minus_DI)&&(Minus_DI>ADX_LevelOpenOrders_2))
                        ADX_OpenSell_1=true;
                    }
                 }
               break;
            case 2:
               if(ADX_Value_0>ADX_LevelOpenOrders_1)
                 {
                  if(ADX_Value_0>ADX_Value_1)
                    {
                     if((Plus_DI<Minus_DI)&&(Minus_DI>ADX_LevelOpenOrders_2))
                        ADX_OpenBuy_1=true;
                     if((Plus_DI>Minus_DI)&&(Plus_DI>ADX_LevelOpenOrders_2))
                        ADX_OpenSell_1=true;
                    }
                 }
               break;
            case 3:
               if(ADX_Value_0>ADX_LevelOpenOrders_1)
                 {
                  if(ADX_Value_0<ADX_Value_1)
                    {
                     if((Plus_DI>Minus_DI)&&(Plus_DI>ADX_LevelOpenOrders_2))
                        ADX_OpenBuy_1=true;
                     if((Plus_DI<Minus_DI)&&(Minus_DI>ADX_LevelOpenOrders_2))
                        ADX_OpenSell_1=true;
                    }
                 }
               break;
            case 4:
               if(ADX_Value_0>ADX_LevelOpenOrders_1)
                 {
                  if(ADX_Value_0<ADX_Value_1)
                    {
                     if((Plus_DI<Minus_DI)&&(Minus_DI>ADX_LevelOpenOrders_2))
                        ADX_OpenBuy_1=true;
                     if((Plus_DI>Minus_DI)&&(Plus_DI>ADX_LevelOpenOrders_2))
                        ADX_OpenSell_1=true;
                    }
                 }
               break;
           }
        }
     }
//---------------------------------------------------------------------
//Signals close orders
   if(ADX_SumOrders>0)
     {
      if(ADX_CloseOrdersType>0)
        {
         if(ADX_CloseInSignals==true)
           {
            switch(ADX_CloseOrdersType)
              {
               case 1:
                  if(ADX_Value_0>ADX_LevelCloseOrders_1)
                    {
                     if((Plus_DI<Minus_DI)&&(ADX_Value_0-Minus_DI>ADX_LevelCloseOrders_2))
                        ADX_CloseBuy_1=true;
                     if((Plus_DI>Minus_DI)&&(ADX_Value_0-Plus_DI>ADX_LevelCloseOrders_2))
                        ADX_CloseSell_1=true;
                    }
                  break;
               case 2:
                  if(ADX_Value_0>ADX_LevelCloseOrders_1)
                    {
                     if((Plus_DI>Minus_DI)&&(ADX_Value_0-Plus_DI>ADX_LevelCloseOrders_2))
                        ADX_CloseBuy_1=true;
                     if((Plus_DI<Minus_DI)&&(ADX_Value_0-Minus_DI>ADX_LevelCloseOrders_2))
                        ADX_CloseSell_1=true;
                    }
                  break;
               //---
               case 3:
                  if(ADX_Value_0>ADX_LevelCloseOrders_1)
                    {
                     if((Plus_DI>Minus_DI)&&(Plus_DI-ADX_Value_0>ADX_LevelCloseOrders_2))
                        ADX_CloseBuy_1=true;
                     if((Plus_DI<Minus_DI)&&(Minus_DI-ADX_Value_0>ADX_LevelCloseOrders_2))
                        ADX_CloseSell_1=true;
                    }
                  break;
               case 4:
                  if(ADX_Value_0>ADX_LevelCloseOrders_1)
                    {
                     if((Plus_DI<Minus_DI)&&(Minus_DI-ADX_Value_0>ADX_LevelCloseOrders_2))
                        ADX_CloseBuy_1=true;
                     if((Plus_DI>Minus_DI)&&(Plus_DI-ADX_Value_0>ADX_LevelCloseOrders_2))
                        ADX_CloseSell_1=true;
                    }
                  break;
              }
           }
        }
     }
//---------------------------------------------------------------------
//Final signals open orders
   if(ADX_OpenBuy_1==true)
      ADX_OpenBuy=true;
   if(ADX_OpenSell_1==true)
      ADX_OpenSell=true;
//---------------------------------------------------------------------
//Final signals close orders
   if(ADX_CloseInSignals==true)
     {
      if(ADX_CloseBuy_1==true)
         ADX_CloseBuy=true;
      if(ADX_CloseSell_1==true)
         ADX_CloseSell=true;
     }
//---------------------------------------------------------------------
//Close orders in reverse signal
   if(CloseInReverse==true)
     {
      if(ADX_OpenBuy==true)
         ADX_CloseSell=true;
      if(ADX_OpenSell==true)
         ADX_CloseBuy=true;
     }
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//AO_Signals
//============================================================================================================================================================================================================================//
void AO_GetSignals()
  {
//---------------------------------------------------------------------
//Set variables
   bool AO_OpenBuy_1=false;
   bool AO_OpenSell_1=false;
//---
   bool AO_CloseBuy_1=false;
   bool AO_CloseSell_1=false;
//---------------------------------------------------------------------
   double AO_Value_Array[];
//---------------------------------------------------------------------
//Sort price array from current data
   ArraySetAsSeries(AO_Value_Array,true);
//---------------------------------------------------------------------
//Filling data according to created indicator
   CopyBuffer(AO,0,0,3,AO_Value_Array);
//---------------------------------------------------------------------
//Getting value of current data
   double AO_Value_0=NormalizeDouble(AO_Value_Array[0]*10000,3);
   double AO_Value_1=NormalizeDouble(AO_Value_Array[1]*10000,3);
//---------------------------------------------------------------------
//Print("AO: ",AO_Value_0," || ",AO_Value_1);
//return;
//---------------------------------------------------------------------
//Set levels
   double LevelOpenUp=AO_LevelOpenOrders;
   double LevelOpenDn=-AO_LevelOpenOrders;
   double LevelCloseUp=AO_LevelCloseOrders;
   double LevelCloseDn=-AO_LevelCloseOrders;
//---------------------------------------------------------------------
//Signals open orders
   if(AO_OpenOrdersType>0)
     {
      switch(AO_OpenOrdersType)
        {
         case 1:
            if((AO_Value_0>LevelOpenUp)&&(AO_Value_1>LevelOpenUp)&&(AO_Value_0>AO_Value_1))
               AO_OpenBuy_1=true;
            if((AO_Value_0<LevelOpenDn)&&(AO_Value_1<LevelOpenDn)&&(AO_Value_0<AO_Value_1))
               AO_OpenSell_1=true;
            break;
         case 2:
            if((AO_Value_0>LevelOpenUp)&&(AO_Value_1<LevelOpenUp)&&(AO_Value_0>AO_Value_1))
               AO_OpenBuy_1=true;
            if((AO_Value_0<LevelOpenDn)&&(AO_Value_1>LevelOpenDn)&&(AO_Value_0<AO_Value_1))
               AO_OpenSell_1=true;
            break;
         case 3:
            if((AO_Value_0>LevelOpenUp)&&(AO_Value_1>LevelOpenUp)&&(AO_Value_0<AO_Value_1))
               AO_OpenBuy_1=true;
            if((AO_Value_0<LevelOpenDn)&&(AO_Value_1<LevelOpenDn)&&(AO_Value_0>AO_Value_1))
               AO_OpenSell_1=true;
            break;
         case 4:
            if((AO_Value_0<LevelOpenUp)&&(AO_Value_1>LevelOpenUp)&&(AO_Value_0<AO_Value_1))
               AO_OpenBuy_1=true;
            if((AO_Value_0>LevelOpenDn)&&(AO_Value_1<LevelOpenDn)&&(AO_Value_0>AO_Value_1))
               AO_OpenSell_1=true;
            break;
         //---
         case 5:
            if((AO_Value_0<LevelOpenDn)&&(AO_Value_1<LevelOpenDn)&&(AO_Value_0<AO_Value_1))
               AO_OpenBuy_1=true;
            if((AO_Value_0>LevelOpenUp)&&(AO_Value_1>LevelOpenUp)&&(AO_Value_0>AO_Value_1))
               AO_OpenSell_1=true;
            break;
         case 6:
            if((AO_Value_0<LevelOpenDn)&&(AO_Value_1>LevelOpenDn)&&(AO_Value_0<AO_Value_1))
               AO_OpenBuy_1=true;
            if((AO_Value_0>LevelOpenUp)&&(AO_Value_1<LevelOpenUp)&&(AO_Value_0>AO_Value_1))
               AO_OpenSell_1=true;
            break;
         case 7:
            if((AO_Value_0<LevelOpenDn)&&(AO_Value_1<LevelOpenDn)&&(AO_Value_0>AO_Value_1))
               AO_OpenBuy_1=true;
            if((AO_Value_0>LevelOpenUp)&&(AO_Value_1>LevelOpenUp)&&(AO_Value_0<AO_Value_1))
               AO_OpenSell_1=true;
            break;
         case 8:
            if((AO_Value_0>LevelOpenDn)&&(AO_Value_1<LevelOpenDn)&&(AO_Value_0>AO_Value_1))
               AO_OpenBuy_1=true;
            if((AO_Value_0<LevelOpenUp)&&(AO_Value_1>LevelOpenUp)&&(AO_Value_0<AO_Value_1))
               AO_OpenSell_1=true;
            break;
        }
     }
//---------------------------------------------------------------------
//Signals close orders
   if(AO_SumOrders>0)
     {
      if(AO_CloseOrdersType>0)
        {
         if(AO_CloseInSignals==true)
           {
            switch(AO_CloseOrdersType)
              {
               case 1:
                  if((AO_Value_0>LevelCloseUp)&&(AO_Value_1>LevelCloseUp)&&(AO_Value_0>AO_Value_1))
                     AO_CloseBuy_1=true;
                  if((AO_Value_0<LevelCloseDn)&&(AO_Value_1<LevelCloseDn)&&(AO_Value_0<AO_Value_1))
                     AO_CloseSell_1=true;
                  break;
               case 2:
                  if((AO_Value_0>LevelCloseUp)&&(AO_Value_1<LevelCloseUp)&&(AO_Value_0>AO_Value_1))
                     AO_CloseBuy_1=true;
                  if((AO_Value_0<LevelCloseDn)&&(AO_Value_1>LevelCloseDn)&&(AO_Value_0<AO_Value_1))
                     AO_CloseSell_1=true;
                  break;
               case 3:
                  if((AO_Value_0>LevelCloseUp)&&(AO_Value_1>LevelCloseUp)&&(AO_Value_0<AO_Value_1))
                     AO_CloseBuy_1=true;
                  if((AO_Value_0<LevelCloseDn)&&(AO_Value_1<LevelCloseDn)&&(AO_Value_0>AO_Value_1))
                     AO_CloseSell_1=true;
                  break;
               case 4:
                  if((AO_Value_0<LevelCloseUp)&&(AO_Value_1>LevelCloseUp)&&(AO_Value_0<AO_Value_1))
                     AO_CloseBuy_1=true;
                  if((AO_Value_0>LevelCloseDn)&&(AO_Value_1<LevelCloseDn)&&(AO_Value_0>AO_Value_1))
                     AO_CloseSell_1=true;
                  break;
               //---
               case 5:
                  if((AO_Value_0<LevelCloseDn)&&(AO_Value_1<LevelCloseDn)&&(AO_Value_0<AO_Value_1))
                     AO_CloseBuy_1=true;
                  if((AO_Value_0>LevelCloseUp)&&(AO_Value_1>LevelCloseUp)&&(AO_Value_0>AO_Value_1))
                     AO_CloseSell_1=true;
                  break;
               case 6:
                  if((AO_Value_0<LevelCloseDn)&&(AO_Value_1>LevelCloseDn)&&(AO_Value_0<AO_Value_1))
                     AO_CloseBuy_1=true;
                  if((AO_Value_0>LevelCloseUp)&&(AO_Value_1<LevelCloseUp)&&(AO_Value_0>AO_Value_1))
                     AO_CloseSell_1=true;
                  break;
               case 7:
                  if((AO_Value_0<LevelCloseDn)&&(AO_Value_1<LevelCloseDn)&&(AO_Value_0>AO_Value_1))
                     AO_CloseBuy_1=true;
                  if((AO_Value_0>LevelCloseUp)&&(AO_Value_1>LevelCloseUp)&&(AO_Value_0<AO_Value_1))
                     AO_CloseSell_1=true;
                  break;
               case 8:
                  if((AO_Value_0>LevelCloseDn)&&(AO_Value_1<LevelCloseDn)&&(AO_Value_0>AO_Value_1))
                     AO_CloseBuy_1=true;
                  if((AO_Value_0<LevelCloseUp)&&(AO_Value_1>LevelCloseUp)&&(AO_Value_0<AO_Value_1))
                     AO_CloseSell_1=true;
                  break;
              }
           }
        }
     }
//---------------------------------------------------------------------
//Final signals open orders
   if(AO_OpenBuy_1==true)
      AO_OpenBuy=true;
   if(AO_OpenSell_1==true)
      AO_OpenSell=true;
//---------------------------------------------------------------------
//Final signals close orders
   if(AO_CloseInSignals==true)
     {
      if(AO_CloseBuy_1==true)
         AO_CloseBuy=true;
      if(AO_CloseSell_1==true)
         AO_CloseSell=true;
     }
//---------------------------------------------------------------------
//Close orders in reverse signal
   if(CloseInReverse==true)
     {
      if(AO_OpenBuy==true)
         AO_CloseSell=true;
      if(AO_OpenSell==true)
         AO_CloseBuy=true;
     }
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//DeM_Signals
//============================================================================================================================================================================================================================//
void DeM_GetSignals()
  {
//---------------------------------------------------------------------
//Set variables
   bool DeM_OpenBuy_1=false;
   bool DeM_OpenSell_1=false;
//---
   bool DeM_CloseBuy_1=false;
   bool DeM_CloseSell_1=false;
//---
   double DeMarkerArray[];
//---------------------------------------------------------------------
   double PriceClose=iClose(SymbolTrade,TimeFrame,0);
//---------------------------------------------------------------------
//Sort price array from current data
   ArraySetAsSeries(DeMarkerArray,true);
//---------------------------------------------------------------------
//Filling data according to created indicator
   CopyBuffer(DeMarker,0,0,6,DeMarkerArray);
//---------------------------------------------------------------------
//Getting value of current data
   double DeMarkerValue_0=NormalizeDouble(DeMarkerArray[0]*100,3);
   double DeMarkerValue_1=NormalizeDouble(DeMarkerArray[1]*100,3);
//---------------------------------------------------------------------
//Set levels
   double LevelOpenUp=DeM_LevelOpenOrders;
   double LevelOpenDn=100-DeM_LevelOpenOrders;
   double LevelCloseUp=DeM_LevelCloseOrders;
   double LevelCloseDn=100-DeM_LevelCloseOrders;
//---------------------------------------------------------------------
//Signals open orders
   if(DeM_OpenOrdersType>0)
     {
      switch(DeM_OpenOrdersType)
        {
         case 1:
            if((DeMarkerValue_0>LevelOpenUp)&&(DeMarkerValue_1<LevelOpenUp))
               DeM_OpenBuy_1=true;
            if((DeMarkerValue_0<LevelOpenDn)&&(DeMarkerValue_1>LevelOpenDn))
               DeM_OpenSell_1=true;
            break;
         case 2:
            if((DeMarkerValue_0<LevelOpenUp)&&(DeMarkerValue_1>LevelOpenUp))
               DeM_OpenBuy_1=true;
            if((DeMarkerValue_0>LevelOpenDn)&&(DeMarkerValue_1<LevelOpenDn))
               DeM_OpenSell_1=true;
            break;
         case 3:
            if((DeMarkerValue_0<LevelOpenDn)&&(DeMarkerValue_1>LevelOpenDn))
               DeM_OpenBuy_1=true;
            if((DeMarkerValue_0>LevelOpenUp)&&(DeMarkerValue_1<LevelOpenUp))
               DeM_OpenSell_1=true;
            break;
         case 4:
            if((DeMarkerValue_0>LevelOpenDn)&&(DeMarkerValue_1<LevelOpenDn))
               DeM_OpenBuy_1=true;
            if((DeMarkerValue_0<LevelOpenUp)&&(DeMarkerValue_1>LevelOpenUp))
               DeM_OpenSell_1=true;
            break;
        }
     }
//---------------------------------------------------------------------
//Signals close orders
   if(DeM_SumOrders>0)
     {
      if(DeM_CloseOrdersType>0)
        {
         if(DeM_CloseInSignals==true)
           {
            switch(DeM_CloseOrdersType)
              {
               case 1:
                  if((DeMarkerValue_0>LevelCloseUp)&&(DeMarkerValue_1<LevelCloseUp))
                     DeM_CloseBuy_1=true;
                  if((DeMarkerValue_0<LevelCloseDn)&&(DeMarkerValue_1>LevelCloseDn))
                     DeM_CloseSell_1=true;
                  break;
               case 2:
                  if((DeMarkerValue_0<LevelCloseUp)&&(DeMarkerValue_1>LevelCloseUp))
                     DeM_CloseBuy_1=true;
                  if((DeMarkerValue_0>LevelCloseDn)&&(DeMarkerValue_1<LevelCloseDn))
                     DeM_CloseSell_1=true;
                  break;
               case 3:
                  if((DeMarkerValue_0<LevelCloseDn)&&(DeMarkerValue_1>LevelCloseDn))
                     DeM_CloseBuy_1=true;
                  if((DeMarkerValue_0>LevelCloseUp)&&(DeMarkerValue_1<LevelCloseUp))
                     DeM_CloseSell_1=true;
                  break;
               case 4:
                  if((DeMarkerValue_0>LevelCloseDn)&&(DeMarkerValue_1<LevelCloseDn))
                     DeM_CloseBuy_1=true;
                  if((DeMarkerValue_0<LevelCloseUp)&&(DeMarkerValue_1>LevelCloseUp))
                     DeM_CloseSell_1=true;
                  break;
              }
           }
        }
     }
//---------------------------------------------------------------------
//Final signals open orders
   if(DeM_OpenBuy_1==true)
      DeM_OpenBuy=true;
   if(DeM_OpenSell_1==true)
      DeM_OpenSell=true;
//---------------------------------------------------------------------
//Final signals close orders
   if(DeM_CloseInSignals==true)
     {
      if(DeM_CloseBuy_1==true)
         DeM_CloseBuy=true;
      if(DeM_CloseSell_1==true)
         DeM_CloseSell=true;
     }
//---------------------------------------------------------------------
//Close orders in reverse signal
   if(CloseInReverse==true)
     {
      if(DeM_OpenBuy==true)
         DeM_CloseSell=true;
      if(DeM_OpenSell==true)
         DeM_CloseBuy=true;
     }
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//FBB_Signals
//============================================================================================================================================================================================================================//
void FBB_GetSignals()
  {
//---------------------------------------------------------------------
//Set variables
   bool FBB_OpenBuy_1=false;
   bool FBB_OpenSell_1=false;
   bool FBB_OpenBuy_2=false;
   bool FBB_OpenSell_2=false;
//---
   bool FBB_CloseBuy_1=false;
   bool FBB_CloseSell_1=false;
   bool FBB_CloseBuy_2=false;
   bool FBB_CloseSell_2=false;
//---------------------------------------------------------------------
   double PriceClose=iClose(SymbolTrade,TimeFrame,1);
   double PriceHigh=iHigh(SymbolTrade,TimeFrame,1);
   double PriceLow=iLow(SymbolTrade,TimeFrame,1);
//---------------------------------------------------------------------
   double MiddleBandArray[];
   double UpperBandArray[];
   double LowerBandArray[];
   double Force_Value_Array[];
//---------------------------------------------------------------------
//Sort price array from current data
   ArraySetAsSeries(MiddleBandArray,true);
   ArraySetAsSeries(UpperBandArray,true);
   ArraySetAsSeries(LowerBandArray,true);
   ArraySetAsSeries(Force_Value_Array,true);
//---------------------------------------------------------------------
//Filling data according to created indicators
   CopyBuffer(BollingerBands,1,0,3,UpperBandArray);
   CopyBuffer(BollingerBands,2,0,3,LowerBandArray);
   CopyBuffer(Force,0,0,3,Force_Value_Array);
//---------------------------------------------------------------------
//Getting value of current data
   double UpperBandValue_1=NormalizeDouble(UpperBandArray[1],3);
   double LowerBandValue_1=NormalizeDouble(LowerBandArray[1],3);
   double Force_Value_1=NormalizeDouble(Force_Value_Array[1]*20,5);
   double Force_Value_2=NormalizeDouble(Force_Value_Array[2]*20,5);
//---
   double DistanceBands=NormalizeDouble((UpperBandValue_1-LowerBandValue_1)/SymbolPoints,3);
//---
   double LevelOpenUp=FBB_LevelOpenOrders_2;
   double LevelOpenDn=-FBB_LevelOpenOrders_2;
   double LevelCloseUp=FBB_LevelCloseOrders_2;
   double LevelCloseDn=-FBB_LevelCloseOrders_2;
//---------------------------------------------------------------------
//Signals open orders
   if(FBB_OpenOrdersType_1>0)
     {
      if(((DistanceBands>FBB_LevelOpenOrders_1)&&(FBB_LevelOpenOrders_1>0))||((DistanceBands<MathAbs(FBB_LevelOpenOrders_1))&&(FBB_LevelOpenOrders_1<0))||(FBB_LevelOpenOrders_1==0))
        {
         switch(FBB_OpenOrdersType_1)
           {
            case 1:
               if(PriceHigh<LowerBandValue_1)
                  FBB_OpenBuy_1=true;
               if(PriceLow>UpperBandValue_1)
                  FBB_OpenSell_1=true;
               break;
            case 2:
               if(PriceLow>UpperBandValue_1)
                  FBB_OpenBuy_1=true;
               if(PriceHigh<LowerBandValue_1)
                  FBB_OpenSell_1=true;
               break;
           }
        }
     }
   else
     {
      FBB_OpenBuy_1=true;
      FBB_OpenSell_1=true;
     }
//---------------------------------------------------------------------
   if(FBB_OpenOrdersType_2>0)
     {
      switch(FBB_OpenOrdersType_2)
        {
         case 1:
            if((Force_Value_1>LevelOpenUp)&&(Force_Value_2>LevelOpenUp)&&(Force_Value_1>Force_Value_2))
               FBB_OpenBuy_2=true;
            if((Force_Value_1<LevelOpenDn)&&(Force_Value_2<LevelOpenDn)&&(Force_Value_1<Force_Value_2))
               FBB_OpenSell_2=true;
            break;
         case 2:
            if((Force_Value_1>LevelOpenUp)&&(Force_Value_2<LevelOpenUp)&&(Force_Value_1>Force_Value_2))
               FBB_OpenBuy_2=true;
            if((Force_Value_1<LevelOpenDn)&&(Force_Value_2>LevelOpenDn)&&(Force_Value_1<Force_Value_2))
               FBB_OpenSell_2=true;
            break;
         case 3:
            if((Force_Value_1>LevelOpenUp)&&(Force_Value_2>LevelOpenUp)&&(Force_Value_1<Force_Value_2))
               FBB_OpenBuy_2=true;
            if((Force_Value_1<LevelOpenDn)&&(Force_Value_2<LevelOpenDn)&&(Force_Value_1>Force_Value_2))
               FBB_OpenSell_2=true;
            break;
         case 4:
            if((Force_Value_1<LevelOpenUp)&&(Force_Value_2>LevelOpenUp)&&(Force_Value_1<Force_Value_2))
               FBB_OpenBuy_2=true;
            if((Force_Value_1>LevelOpenDn)&&(Force_Value_2<LevelOpenDn)&&(Force_Value_1>Force_Value_2))
               FBB_OpenSell_2=true;
            break;
         //---
         case 5:
            if((Force_Value_1<LevelOpenDn)&&(Force_Value_2<LevelOpenDn)&&(Force_Value_1<Force_Value_2))
               FBB_OpenBuy_2=true;
            if((Force_Value_1>LevelOpenUp)&&(Force_Value_2>LevelOpenUp)&&(Force_Value_1>Force_Value_2))
               FBB_OpenSell_2=true;
            break;
         case 6:
            if((Force_Value_1<LevelOpenDn)&&(Force_Value_2>LevelOpenDn)&&(Force_Value_1<Force_Value_2))
               FBB_OpenBuy_2=true;
            if((Force_Value_1>LevelOpenUp)&&(Force_Value_2<LevelOpenUp)&&(Force_Value_1>Force_Value_2))
               FBB_OpenSell_2=true;
            break;
         case 7:
            if((Force_Value_1<LevelOpenDn)&&(Force_Value_2<LevelOpenDn)&&(Force_Value_1>Force_Value_2))
               FBB_OpenBuy_2=true;
            if((Force_Value_1>LevelOpenUp)&&(Force_Value_2>LevelOpenUp)&&(Force_Value_1<Force_Value_2))
               FBB_OpenSell_2=true;
            break;
         case 8:
            if((Force_Value_1>LevelOpenDn)&&(Force_Value_2<LevelOpenDn)&&(Force_Value_1>Force_Value_2))
               FBB_OpenBuy_2=true;
            if((Force_Value_1<LevelOpenUp)&&(Force_Value_2>LevelOpenUp)&&(Force_Value_1<Force_Value_2))
               FBB_OpenSell_2=true;
            break;
        }
     }
   else
     {
      FBB_OpenBuy_2=true;
      FBB_OpenSell_2=true;
     }
//---------------------------------------------------------------------
//Signals close orders
   if(FBB_SumOrders>0)
     {
      if(FBB_CloseInSignals==true)
        {
         if(FBB_CloseOrdersType_1>0)
           {
            if(((DistanceBands>FBB_LevelCloseOrders_1)&&(FBB_LevelCloseOrders_1>0))||((DistanceBands<MathAbs(FBB_LevelCloseOrders_1))&&(FBB_LevelCloseOrders_1<0)))
              {
               switch(FBB_CloseOrdersType_1)
                 {
                  case 1:
                     if(PriceHigh<LowerBandValue_1)
                        FBB_CloseBuy_1=true;
                     if(PriceLow>UpperBandValue_1)
                        FBB_CloseSell_1=true;
                     break;
                  case 2:
                     if(PriceLow>UpperBandValue_1)
                        FBB_CloseBuy_1=true;
                     if(PriceHigh<LowerBandValue_1)
                        FBB_CloseSell_1=true;
                     break;
                 }
              }
           }
         //---------------------------------------------------------------------
         if(FBB_CloseOrdersType_2>0)
           {
            switch(FBB_CloseOrdersType_2)
              {
               case 1:
                  if((Force_Value_1>LevelCloseUp)&&(Force_Value_2>LevelCloseUp)&&(Force_Value_1>Force_Value_2))
                     FBB_CloseBuy_2=true;
                  if((Force_Value_1<LevelCloseDn)&&(Force_Value_2<LevelCloseDn)&&(Force_Value_1<Force_Value_2))
                     FBB_CloseSell_2=true;
                  break;
               case 2:
                  if((Force_Value_1>LevelCloseUp)&&(Force_Value_2<LevelCloseUp)&&(Force_Value_1>Force_Value_2))
                     FBB_CloseBuy_2=true;
                  if((Force_Value_1<LevelCloseDn)&&(Force_Value_2>LevelCloseDn)&&(Force_Value_1<Force_Value_2))
                     FBB_CloseSell_2=true;
                  break;
               case 3:
                  if((Force_Value_1>LevelCloseUp)&&(Force_Value_2>LevelCloseUp)&&(Force_Value_1<Force_Value_2))
                     FBB_CloseBuy_2=true;
                  if((Force_Value_1<LevelCloseDn)&&(Force_Value_2<LevelCloseDn)&&(Force_Value_1>Force_Value_2))
                     FBB_CloseSell_2=true;
                  break;
               case 4:
                  if((Force_Value_1<LevelCloseUp)&&(Force_Value_2>LevelCloseUp)&&(Force_Value_1<Force_Value_2))
                     FBB_CloseBuy_2=true;
                  if((Force_Value_1>LevelCloseDn)&&(Force_Value_2<LevelCloseDn)&&(Force_Value_1>Force_Value_2))
                     FBB_CloseSell_2=true;
                  break;
               //---
               case 5:
                  if((Force_Value_1<LevelCloseDn)&&(Force_Value_2<LevelCloseDn)&&(Force_Value_1<Force_Value_2))
                     FBB_CloseBuy_2=true;
                  if((Force_Value_1>LevelCloseUp)&&(Force_Value_2>LevelCloseUp)&&(Force_Value_1>Force_Value_2))
                     FBB_CloseSell_2=true;
                  break;
               case 6:
                  if((Force_Value_1<LevelCloseDn)&&(Force_Value_2>LevelCloseDn)&&(Force_Value_1<Force_Value_2))
                     FBB_CloseBuy_2=true;
                  if((Force_Value_1>LevelCloseUp)&&(Force_Value_2<LevelCloseUp)&&(Force_Value_1>Force_Value_2))
                     FBB_CloseSell_2=true;
                  break;
               case 7:
                  if((Force_Value_1<LevelCloseDn)&&(Force_Value_2<LevelCloseDn)&&(Force_Value_1>Force_Value_2))
                     FBB_CloseBuy_2=true;
                  if((Force_Value_1>LevelCloseUp)&&(Force_Value_2>LevelCloseUp)&&(Force_Value_1<Force_Value_2))
                     FBB_CloseSell_2=true;
                  break;
               case 8:
                  if((Force_Value_1>LevelCloseDn)&&(Force_Value_2<LevelCloseDn)&&(Force_Value_1>Force_Value_2))
                     FBB_CloseBuy_2=true;
                  if((Force_Value_1<LevelCloseUp)&&(Force_Value_2>LevelCloseUp)&&(Force_Value_1<Force_Value_2))
                     FBB_CloseSell_2=true;
                  break;
              }
           }
        }
     }
//---------------------------------------------------------------------
//Final signals open orders
   if((FBB_OpenBuy_1==true)&&(FBB_OpenBuy_2==true))
      FBB_OpenBuy=true;
   if((FBB_OpenSell_1==true)&&(FBB_OpenSell_2==true))
      FBB_OpenSell=true;
//---------------------------------------------------------------------
//Final signals close orders
   if(FBB_CloseInSignals==true)
     {
      if(FBB_CloseBuy_1==true)
         FBB_CloseBuy=true;
      if(FBB_CloseBuy_2==true)
         FBB_CloseBuy=true;
      //---
      if(FBB_CloseSell_1==true)
         FBB_CloseSell=true;
      if(FBB_CloseSell_2==true)
         FBB_CloseSell=true;
     }
//---------------------------------------------------------------------
//Close orders in reverse signal
   if(CloseInReverse==true)
     {
      if(FBB_OpenBuy==true)
         FBB_CloseSell=true;
      if(FBB_OpenSell==true)
         FBB_CloseBuy=true;
     }
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//MFI_Signals
//============================================================================================================================================================================================================================//
void MFI_GetSignals()
  {
//---------------------------------------------------------------------
//Set variables
   bool MFI_OpenBuy_1=false;
   bool MFI_OpenSell_1=false;
//---
   bool MFI_CloseBuy_1=false;
   bool MFI_CloseSell_1=false;
//---
   double MFI_Array[];
//---------------------------------------------------------------------
   double PriceClose=iClose(SymbolTrade,TimeFrame,0);
//---------------------------------------------------------------------
//Sort price array from current data
   ArraySetAsSeries(MFI_Array,true);
//---------------------------------------------------------------------
//Filling data according to created indicator
   CopyBuffer(MFI,0,0,6,MFI_Array);
//---------------------------------------------------------------------
//Getting value of current data
   double MFI_Value_0=NormalizeDouble(MFI_Array[0],3);
   double MFI_Value_1=NormalizeDouble(MFI_Array[1],3);
//---------------------------------------------------------------------
//Set levels
   double LevelOpenUp=MFI_LevelOpenOrders;
   double LevelOpenDn=100-MFI_LevelOpenOrders;
   double LevelCloseUp=MFI_LevelCloseOrders;
   double LevelCloseDn=100-MFI_LevelCloseOrders;
//---------------------------------------------------------------------
//Signals open orders
   if(MFI_OpenOrdersType>0)
     {
      switch(MFI_OpenOrdersType)
        {
         case 1:
            if((MFI_Value_0>LevelOpenUp)&&(MFI_Value_1<LevelOpenUp))
               MFI_OpenBuy_1=true;
            if((MFI_Value_0<LevelOpenDn)&&(MFI_Value_1>LevelOpenDn))
               MFI_OpenSell_1=true;
            break;
         case 2:
            if((MFI_Value_0<LevelOpenUp)&&(MFI_Value_1>LevelOpenUp))
               MFI_OpenBuy_1=true;
            if((MFI_Value_0>LevelOpenDn)&&(MFI_Value_1<LevelOpenDn))
               MFI_OpenSell_1=true;
            break;
         case 3:
            if((MFI_Value_0<LevelOpenDn)&&(MFI_Value_1>LevelOpenDn))
               MFI_OpenBuy_1=true;
            if((MFI_Value_0>LevelOpenUp)&&(MFI_Value_1<LevelOpenUp))
               MFI_OpenSell_1=true;
            break;
         case 4:
            if((MFI_Value_0>LevelOpenDn)&&(MFI_Value_1<LevelOpenDn))
               MFI_OpenBuy_1=true;
            if((MFI_Value_0<LevelOpenUp)&&(MFI_Value_1>LevelOpenUp))
               MFI_OpenSell_1=true;
            break;
        }
     }
//---------------------------------------------------------------------
//Signals close orders
   if(MFI_SumOrders>0)
     {
      if(MFI_CloseOrdersType>0)
        {
         if(MFI_CloseInSignals==true)
           {
            switch(MFI_CloseOrdersType)
              {
               case 1:
                  if((MFI_Value_0>LevelCloseUp)&&(MFI_Value_1<LevelCloseUp))
                     MFI_CloseBuy_1=true;
                  if((MFI_Value_0<LevelCloseDn)&&(MFI_Value_1>LevelCloseDn))
                     MFI_CloseSell_1=true;
                  break;
               case 2:
                  if((MFI_Value_0<LevelCloseUp)&&(MFI_Value_1>LevelCloseUp))
                     MFI_CloseBuy_1=true;
                  if((MFI_Value_0>LevelCloseDn)&&(MFI_Value_1<LevelCloseDn))
                     MFI_CloseSell_1=true;
                  break;
               case 3:
                  if((MFI_Value_0<LevelCloseDn)&&(MFI_Value_1>LevelCloseDn))
                     MFI_CloseBuy_1=true;
                  if((MFI_Value_0>LevelCloseUp)&&(MFI_Value_1<LevelCloseUp))
                     MFI_CloseSell_1=true;
                  break;
               case 4:
                  if((MFI_Value_0>LevelCloseDn)&&(MFI_Value_1<LevelCloseDn))
                     MFI_CloseBuy_1=true;
                  if((MFI_Value_0<LevelCloseUp)&&(MFI_Value_1>LevelCloseUp))
                     MFI_CloseSell_1=true;
                  break;
              }
           }
        }
     }
//---------------------------------------------------------------------
//Final signals open orders
   if(MFI_OpenBuy_1==true)
      MFI_OpenBuy=true;
   if(MFI_OpenSell_1==true)
      MFI_OpenSell=true;
//---------------------------------------------------------------------
//Final signals close orders
   if(MFI_CloseInSignals==true)
     {
      if(MFI_CloseBuy_1==true)
         MFI_CloseBuy=true;
      if(MFI_CloseSell_1==true)
         MFI_CloseSell=true;
     }
//---------------------------------------------------------------------
//Close orders in reverse signal
   if(CloseInReverse==true)
     {
      if(MFI_OpenBuy==true)
         MFI_CloseSell=true;
      if(MFI_OpenSell==true)
         MFI_CloseBuy=true;
     }
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//MS_Signals
//============================================================================================================================================================================================================================//
void MS_GetSignals()
  {
//---------------------------------------------------------------------
//Set variables
   bool MS_OpenBuy_1=false;
   bool MS_OpenSell_1=false;
   bool MS_OpenBuy_2=false;
   bool MS_OpenSell_2=false;
//---
   bool MS_CloseBuy_1=false;
   bool MS_CloseSell_1=false;
   bool MS_CloseBuy_2=false;
   bool MS_CloseSell_2=false;
//---------------------------------------------------------------------
   double MACD_Main_Line[];
   double MACD_Signal_Line[];
   double STOCH_K_Line[];
   double STOCH_D_Line[];
//---------------------------------------------------------------------
//Sort price array from current data
   ArraySetAsSeries(MACD_Main_Line,true);
   ArraySetAsSeries(MACD_Signal_Line,true);
   ArraySetAsSeries(STOCH_K_Line,true);
   ArraySetAsSeries(STOCH_D_Line,true);
//---------------------------------------------------------------------
//Filling data according to created indicators
   CopyBuffer(MACD,0,0,3,MACD_Main_Line);
   CopyBuffer(MACD,1,0,3,MACD_Signal_Line);
   CopyBuffer(STOCH,0,0,3,STOCH_K_Line);
   CopyBuffer(STOCH,1,0,3,STOCH_D_Line);
//---------------------------------------------------------------------
//Getting value of current data
   double MACD_Main_0=NormalizeDouble(MACD_Main_Line[0]*40000,SymbolDigits);
   double MACD_Signal_0=NormalizeDouble(MACD_Signal_Line[0]*40000,SymbolDigits);
   double MACD_Main_1=NormalizeDouble(MACD_Main_Line[1]*40000,SymbolDigits);
   double MACD_Signal_1=NormalizeDouble(MACD_Signal_Line[1]*40000,SymbolDigits);
   double STOCH_K_0=NormalizeDouble(STOCH_K_Line[0],SymbolDigits);
   double STOCH_D_0=NormalizeDouble(STOCH_D_Line[0],SymbolDigits);
   double STOCH_K_1=NormalizeDouble(STOCH_K_Line[1],SymbolDigits);
   double STOCH_D_1=NormalizeDouble(STOCH_D_Line[1],SymbolDigits);
//---------------------------------------------------------------------
//Set levels
   double MACD_LevelOpenUp=MS_LevelOpenOrders_1;
   double MACD_LevelOpenDn=-MS_LevelOpenOrders_1;
   double MACD_LevelCloseUp=MS_LevelCloseOrders_1;
   double MACD_LevelCloseDn=-MS_LevelCloseOrders_1;
//---
   double STOCH_LevelOpenUp=MS_LevelOpenOrders_2;
   double STOCH_LevelOpenDn=100-MS_LevelOpenOrders_2;
   double STOCH_LevelCloseUp=MS_LevelCloseOrders_2;
   double STOCH_LevelCloseDn=100-MS_LevelCloseOrders_2;
//---------------------------------------------------------------------
//Signals open orders
   if(MS_OpenOrdersType_1>0)
     {
      switch(MS_OpenOrdersType_1)
        {
         case 1:
            if((MACD_Main_0>MACD_LevelOpenUp)&&(MACD_Main_1>MACD_LevelOpenUp)&&
               (MACD_Main_0>MACD_Signal_0)&&(MACD_Main_0>MACD_Main_1)&&(MACD_Signal_0>MACD_Signal_1))
               MS_OpenBuy_1=true;
            if((MACD_Main_0<MACD_LevelOpenDn)&&(MACD_Main_1<MACD_LevelOpenDn)&&
               (MACD_Main_0<MACD_Signal_0)&&(MACD_Main_0<MACD_Main_1)&&(MACD_Signal_0<MACD_Signal_1))
               MS_OpenSell_1=true;
            break;
         case 2:
            if((MACD_Main_0>MACD_LevelOpenUp)&&(MACD_Main_1>MACD_LevelOpenUp)&&
               (MACD_Main_0<MACD_Signal_0)&&(MACD_Main_0<MACD_Main_1)&&(MACD_Signal_0>MACD_Signal_1))
               MS_OpenBuy_1=true;
            if((MACD_Main_0<MACD_LevelOpenDn)&&(MACD_Main_1<MACD_LevelOpenDn)&&
               (MACD_Main_0>MACD_Signal_0)&&(MACD_Main_0>MACD_Main_1)&&(MACD_Signal_0<MACD_Signal_1))
               MS_OpenSell_1=true;
            break;
         case 3:
            if((MACD_Main_0>MACD_LevelOpenUp)&&(MACD_Main_1>MACD_LevelOpenUp)&&
               (MACD_Main_0<MACD_Signal_0)&&(MACD_Main_0<MACD_Main_1)&&(MACD_Signal_0<MACD_Signal_1))
               MS_OpenBuy_1=true;
            if((MACD_Main_0<MACD_LevelOpenDn)&&(MACD_Main_1<MACD_LevelOpenDn)&&
               (MACD_Main_0>MACD_Signal_0)&&(MACD_Main_0>MACD_Main_1)&&(MACD_Signal_0>MACD_Signal_1))
               MS_OpenSell_1=true;
            break;
         case 4:
            if((MACD_Main_0<MACD_LevelOpenUp)&&(MACD_Main_1>MACD_LevelOpenUp)&&
               (MACD_Main_0<MACD_Signal_0)&&(MACD_Main_0<MACD_Main_1)&&(MACD_Signal_0>MACD_Signal_1))
               MS_OpenBuy_1=true;
            if((MACD_Main_0>MACD_LevelOpenDn)&&(MACD_Main_1<MACD_LevelOpenDn)&&
               (MACD_Main_0>MACD_Signal_0)&&(MACD_Main_0>MACD_Main_1)&&(MACD_Signal_0<MACD_Signal_1))
               MS_OpenSell_1=true;
            break;
         case 5:
            if((MACD_Main_0<MACD_LevelOpenUp)&&(MACD_Main_1>MACD_LevelOpenUp)&&
               (MACD_Main_0<MACD_Signal_0)&&(MACD_Main_0<MACD_Main_1)&&(MACD_Signal_0<MACD_Signal_1))
               MS_OpenBuy_1=true;
            if((MACD_Main_0>MACD_LevelOpenDn)&&(MACD_Main_1<MACD_LevelOpenDn)&&
               (MACD_Main_0>MACD_Signal_0)&&(MACD_Main_0>MACD_Main_1)&&(MACD_Signal_0>MACD_Signal_1))
               MS_OpenSell_1=true;
            break;
         case 6:
            if((MACD_Main_0>MACD_LevelOpenUp)&&(MACD_Main_1<MACD_LevelOpenUp)&&
               (MACD_Main_0>MACD_Signal_0)&&(MACD_Main_0>MACD_Main_1)&&(MACD_Signal_0>MACD_Signal_1))
               MS_OpenBuy_1=true;
            if((MACD_Main_0<MACD_LevelOpenDn)&&(MACD_Main_1>MACD_LevelOpenDn)&&
               (MACD_Main_0<MACD_Signal_0)&&(MACD_Main_0<MACD_Main_1)&&(MACD_Signal_0<MACD_Signal_1))
               MS_OpenSell_1=true;
            break;
         case 7:
            if((MACD_Main_0<MACD_LevelOpenDn)&&(MACD_Main_1<MACD_LevelOpenDn)&&
               (MACD_Main_0>MACD_Signal_0)&&(MACD_Main_0>MACD_Main_1)&&(MACD_Signal_0>MACD_Signal_1))
               MS_OpenBuy_1=true;
            if((MACD_Main_0>MACD_LevelOpenUp)&&(MACD_Main_1>MACD_LevelOpenUp)&&
               (MACD_Main_0<MACD_Signal_0)&&(MACD_Main_0<MACD_Main_1)&&(MACD_Signal_0<MACD_Signal_1))
               MS_OpenSell_1=true;
            break;
         case 8:
            if((MACD_Main_0<MACD_LevelOpenDn)&&(MACD_Main_1<MACD_LevelOpenDn)&&
               (MACD_Main_0>MACD_Signal_0)&&(MACD_Main_0>MACD_Main_1)&&(MACD_Signal_0<MACD_Signal_1))
               MS_OpenBuy_1=true;
            if((MACD_Main_0>MACD_LevelOpenUp)&&(MACD_Main_1>MACD_LevelOpenUp)&&
               (MACD_Main_0<MACD_Signal_0)&&(MACD_Main_0<MACD_Main_1)&&(MACD_Signal_0>MACD_Signal_1))
               MS_OpenSell_1=true;
            break;
         case 9:
            if((MACD_Main_0<MACD_LevelOpenDn)&&(MACD_Main_1<MACD_LevelOpenDn)&&
               (MACD_Main_0<MACD_Signal_0)&&(MACD_Main_0<MACD_Main_1)&&(MACD_Signal_0<MACD_Signal_1))
               MS_OpenBuy_1=true;
            if((MACD_Main_0>MACD_LevelOpenUp)&&(MACD_Main_1>MACD_LevelOpenUp)&&
               (MACD_Main_0>MACD_Signal_0)&&(MACD_Main_0>MACD_Main_1)&&(MACD_Signal_0>MACD_Signal_1))
               MS_OpenSell_1=true;
            break;
         case 10:
            if((MACD_Main_0>MACD_LevelOpenDn)&&(MACD_Main_1<MACD_LevelOpenDn)&&
               (MACD_Main_0>MACD_Signal_0)&&(MACD_Main_0>MACD_Main_1)&&(MACD_Signal_0>MACD_Signal_1))
               MS_OpenBuy_1=true;
            if((MACD_Main_0<MACD_LevelOpenUp)&&(MACD_Main_1>MACD_LevelOpenUp)&&
               (MACD_Main_0<MACD_Signal_0)&&(MACD_Main_0<MACD_Main_1)&&(MACD_Signal_0<MACD_Signal_1))
               MS_OpenSell_1=true;
            break;
         case 11:
            if((MACD_Main_0<MACD_LevelOpenDn)&&(MACD_Main_1>MACD_LevelOpenDn)&&
               (MACD_Main_0<MACD_Signal_0)&&(MACD_Main_0<MACD_Main_1)&&(MACD_Signal_0<MACD_Signal_1))
               MS_OpenBuy_1=true;
            if((MACD_Main_0>MACD_LevelOpenUp)&&(MACD_Main_1<MACD_LevelOpenUp)&&
               (MACD_Main_0>MACD_Signal_0)&&(MACD_Main_0>MACD_Main_1)&&(MACD_Signal_0>MACD_Signal_1))
               MS_OpenSell_1=true;
            break;
        }
     }
   else
     {
      MS_OpenBuy_1=true;
      MS_OpenSell_1=true;
     }
//---------------------------------------------------------------------
   if(MS_OpenOrdersType_2>0)
     {
      switch(MS_OpenOrdersType_2)
        {
         case 1:
            if((STOCH_K_0>STOCH_LevelOpenUp)&&(STOCH_K_1>STOCH_LevelOpenUp)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0<STOCH_LevelOpenDn)&&(STOCH_K_1<STOCH_LevelOpenDn)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 2:
            if((STOCH_K_0>STOCH_LevelOpenUp)&&(STOCH_K_1>STOCH_LevelOpenUp)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0<STOCH_LevelOpenDn)&&(STOCH_K_1<STOCH_LevelOpenDn)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 3:
            if((STOCH_K_0>STOCH_LevelOpenUp)&&(STOCH_K_1>STOCH_LevelOpenUp)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0<STOCH_LevelOpenDn)&&(STOCH_K_1<STOCH_LevelOpenDn)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 4:
            if((STOCH_K_0>STOCH_LevelOpenUp)&&(STOCH_K_1>STOCH_LevelOpenUp)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0<STOCH_LevelOpenDn)&&(STOCH_K_1<STOCH_LevelOpenDn)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 5:
            if((STOCH_K_0>STOCH_LevelOpenUp)&&(STOCH_K_1>STOCH_LevelOpenUp)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0<STOCH_LevelOpenDn)&&(STOCH_K_1<STOCH_LevelOpenDn)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 6:
            if((STOCH_K_0>STOCH_LevelOpenUp)&&(STOCH_K_1>STOCH_LevelOpenUp)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0<STOCH_LevelOpenDn)&&(STOCH_K_1<STOCH_LevelOpenDn)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 7:
            if((STOCH_K_0>STOCH_LevelOpenUp)&&(STOCH_K_1>STOCH_LevelOpenUp)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0<STOCH_LevelOpenDn)&&(STOCH_K_1<STOCH_LevelOpenDn)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 8:
            if((STOCH_K_0>STOCH_LevelOpenUp)&&(STOCH_K_1>STOCH_LevelOpenUp)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0<STOCH_LevelOpenDn)&&(STOCH_K_1<STOCH_LevelOpenDn)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 9:
            if((STOCH_K_0<STOCH_LevelOpenUp)&&(STOCH_K_1>STOCH_LevelOpenUp)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0>STOCH_LevelOpenDn)&&(STOCH_K_1<STOCH_LevelOpenDn)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 10:
            if((STOCH_K_0<STOCH_LevelOpenUp)&&(STOCH_K_1>STOCH_LevelOpenUp)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0>STOCH_LevelOpenDn)&&(STOCH_K_1<STOCH_LevelOpenDn)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 11:
            if((STOCH_K_0<STOCH_LevelOpenUp)&&(STOCH_K_1>STOCH_LevelOpenUp)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0>STOCH_LevelOpenDn)&&(STOCH_K_1<STOCH_LevelOpenDn)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 12:
            if((STOCH_K_0>STOCH_LevelOpenUp)&&(STOCH_K_1<STOCH_LevelOpenUp)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0<STOCH_LevelOpenDn)&&(STOCH_K_1>STOCH_LevelOpenDn)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 13:
            if((STOCH_K_0>STOCH_LevelOpenUp)&&(STOCH_K_1<STOCH_LevelOpenUp)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0<STOCH_LevelOpenDn)&&(STOCH_K_1>STOCH_LevelOpenDn)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 14:
            if((STOCH_K_0>STOCH_LevelOpenUp)&&(STOCH_K_1<STOCH_LevelOpenUp)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0<STOCH_LevelOpenDn)&&(STOCH_K_1>STOCH_LevelOpenDn)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 15:
            if((STOCH_K_0<STOCH_LevelOpenDn)&&(STOCH_K_1<STOCH_LevelOpenDn)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0>STOCH_LevelOpenUp)&&(STOCH_K_1>STOCH_LevelOpenUp)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 16:
            if((STOCH_K_0<STOCH_LevelOpenDn)&&(STOCH_K_1<STOCH_LevelOpenDn)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0>STOCH_LevelOpenUp)&&(STOCH_K_1>STOCH_LevelOpenUp)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 17:
            if((STOCH_K_0<STOCH_LevelOpenDn)&&(STOCH_K_1<STOCH_LevelOpenDn)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0>STOCH_LevelOpenUp)&&(STOCH_K_1>STOCH_LevelOpenUp)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 18:
            if((STOCH_K_0<STOCH_LevelOpenDn)&&(STOCH_K_1<STOCH_LevelOpenDn)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0>STOCH_LevelOpenUp)&&(STOCH_K_1>STOCH_LevelOpenUp)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 19:
            if((STOCH_K_0<STOCH_LevelOpenDn)&&(STOCH_K_1<STOCH_LevelOpenDn)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0>STOCH_LevelOpenUp)&&(STOCH_K_1>STOCH_LevelOpenUp)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 20:
            if((STOCH_K_0<STOCH_LevelOpenDn)&&(STOCH_K_1<STOCH_LevelOpenDn)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0>STOCH_LevelOpenUp)&&(STOCH_K_1>STOCH_LevelOpenUp)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 21:
            if((STOCH_K_0<STOCH_LevelOpenDn)&&(STOCH_K_1<STOCH_LevelOpenDn)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0>STOCH_LevelOpenUp)&&(STOCH_K_1>STOCH_LevelOpenUp)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 22:
            if((STOCH_K_0<STOCH_LevelOpenDn)&&(STOCH_K_1<STOCH_LevelOpenDn)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0>STOCH_LevelOpenUp)&&(STOCH_K_1>STOCH_LevelOpenUp)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 23:
            if((STOCH_K_0>STOCH_LevelOpenDn)&&(STOCH_K_1<STOCH_LevelOpenDn)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0<STOCH_LevelOpenUp)&&(STOCH_K_1>STOCH_LevelOpenUp)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 24:
            if((STOCH_K_0>STOCH_LevelOpenDn)&&(STOCH_K_1<STOCH_LevelOpenDn)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0<STOCH_LevelOpenUp)&&(STOCH_K_1>STOCH_LevelOpenUp)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 25:
            if((STOCH_K_0>STOCH_LevelOpenDn)&&(STOCH_K_1<STOCH_LevelOpenDn)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0<STOCH_LevelOpenUp)&&(STOCH_K_1>STOCH_LevelOpenUp)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 26:
            if((STOCH_K_0<STOCH_LevelOpenDn)&&(STOCH_K_1>STOCH_LevelOpenDn)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0>STOCH_LevelOpenUp)&&(STOCH_K_1<STOCH_LevelOpenUp)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 27:
            if((STOCH_K_0<STOCH_LevelOpenDn)&&(STOCH_K_1>STOCH_LevelOpenDn)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0>STOCH_LevelOpenUp)&&(STOCH_K_1<STOCH_LevelOpenUp)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenSell_2=true;
            break;
         case 28:
            if((STOCH_K_0<STOCH_LevelOpenDn)&&(STOCH_K_1>STOCH_LevelOpenDn)&&
               (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
               MS_OpenBuy_2=true;
            if((STOCH_K_0>STOCH_LevelOpenUp)&&(STOCH_K_1<STOCH_LevelOpenUp)&&
               (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
               MS_OpenSell_2=true;
            break;
        }
     }
   else
     {
      MS_OpenBuy_2=true;
      MS_OpenSell_2=true;
     }
//---------------------------------------------------------------------
//Signals close orders
   if(MS_SumOrders>0)
     {
      if(MS_CloseInSignals==true)
        {
         if(MS_CloseOrdersType_1>0)
           {
            switch(MS_CloseOrdersType_1)
              {
               case 1:
                  if((MACD_Main_0>MACD_LevelCloseUp)&&(MACD_Main_1>MACD_LevelCloseUp)&&
                     (MACD_Main_0>MACD_Signal_0)&&(MACD_Main_0>MACD_Main_1)&&(MACD_Signal_0>MACD_Signal_1))
                     MS_CloseBuy_1=true;
                  if((MACD_Main_0<MACD_LevelCloseDn)&&(MACD_Main_1<MACD_LevelCloseDn)&&
                     (MACD_Main_0<MACD_Signal_0)&&(MACD_Main_0<MACD_Main_1)&&(MACD_Signal_0<MACD_Signal_1))
                     MS_CloseSell_1=true;
                  break;
               case 2:
                  if((MACD_Main_0>MACD_LevelCloseUp)&&(MACD_Main_1>MACD_LevelCloseUp)&&
                     (MACD_Main_0<MACD_Signal_0)&&(MACD_Main_0<MACD_Main_1)&&(MACD_Signal_0>MACD_Signal_1))
                     MS_CloseBuy_1=true;
                  if((MACD_Main_0<MACD_LevelCloseDn)&&(MACD_Main_1<MACD_LevelCloseDn)&&
                     (MACD_Main_0>MACD_Signal_0)&&(MACD_Main_0>MACD_Main_1)&&(MACD_Signal_0<MACD_Signal_1))
                     MS_CloseSell_1=true;
                  break;
               case 3:
                  if((MACD_Main_0>MACD_LevelCloseUp)&&(MACD_Main_1>MACD_LevelCloseUp)&&
                     (MACD_Main_0<MACD_Signal_0)&&(MACD_Main_0<MACD_Main_1)&&(MACD_Signal_0<MACD_Signal_1))
                     MS_CloseBuy_1=true;
                  if((MACD_Main_0<MACD_LevelCloseDn)&&(MACD_Main_1<MACD_LevelCloseDn)&&
                     (MACD_Main_0>MACD_Signal_0)&&(MACD_Main_0>MACD_Main_1)&&(MACD_Signal_0>MACD_Signal_1))
                     MS_CloseSell_1=true;
                  break;
               case 4:
                  if((MACD_Main_0<MACD_LevelCloseUp)&&(MACD_Main_1>MACD_LevelCloseUp)&&
                     (MACD_Main_0<MACD_Signal_0)&&(MACD_Main_0<MACD_Main_1)&&(MACD_Signal_0>MACD_Signal_1))
                     MS_CloseBuy_1=true;
                  if((MACD_Main_0>MACD_LevelCloseDn)&&(MACD_Main_1<MACD_LevelCloseDn)&&
                     (MACD_Main_0>MACD_Signal_0)&&(MACD_Main_0>MACD_Main_1)&&(MACD_Signal_0<MACD_Signal_1))
                     MS_CloseSell_1=true;
                  break;
               case 5:
                  if((MACD_Main_0<MACD_LevelCloseUp)&&(MACD_Main_1>MACD_LevelCloseUp)&&
                     (MACD_Main_0<MACD_Signal_0)&&(MACD_Main_0<MACD_Main_1)&&(MACD_Signal_0<MACD_Signal_1))
                     MS_CloseBuy_1=true;
                  if((MACD_Main_0>MACD_LevelCloseDn)&&(MACD_Main_1<MACD_LevelCloseDn)&&
                     (MACD_Main_0>MACD_Signal_0)&&(MACD_Main_0>MACD_Main_1)&&(MACD_Signal_0>MACD_Signal_1))
                     MS_CloseSell_1=true;
                  break;
               case 6:
                  if((MACD_Main_0>MACD_LevelCloseUp)&&(MACD_Main_1<MACD_LevelCloseUp)&&
                     (MACD_Main_0>MACD_Signal_0)&&(MACD_Main_0>MACD_Main_1)&&(MACD_Signal_0>MACD_Signal_1))
                     MS_CloseBuy_1=true;
                  if((MACD_Main_0<MACD_LevelCloseDn)&&(MACD_Main_1>MACD_LevelCloseDn)&&
                     (MACD_Main_0<MACD_Signal_0)&&(MACD_Main_0<MACD_Main_1)&&(MACD_Signal_0<MACD_Signal_1))
                     MS_CloseSell_1=true;
                  break;
               case 7:
                  if((MACD_Main_0<MACD_LevelCloseDn)&&(MACD_Main_1<MACD_LevelCloseDn)&&
                     (MACD_Main_0>MACD_Signal_0)&&(MACD_Main_0>MACD_Main_1)&&(MACD_Signal_0>MACD_Signal_1))
                     MS_CloseBuy_1=true;
                  if((MACD_Main_0>MACD_LevelCloseUp)&&(MACD_Main_1>MACD_LevelCloseUp)&&
                     (MACD_Main_0<MACD_Signal_0)&&(MACD_Main_0<MACD_Main_1)&&(MACD_Signal_0<MACD_Signal_1))
                     MS_CloseSell_1=true;
                  break;
               case 8:
                  if((MACD_Main_0<MACD_LevelCloseDn)&&(MACD_Main_1<MACD_LevelCloseDn)&&
                     (MACD_Main_0>MACD_Signal_0)&&(MACD_Main_0>MACD_Main_1)&&(MACD_Signal_0<MACD_Signal_1))
                     MS_CloseBuy_1=true;
                  if((MACD_Main_0>MACD_LevelCloseUp)&&(MACD_Main_1>MACD_LevelCloseUp)&&
                     (MACD_Main_0<MACD_Signal_0)&&(MACD_Main_0<MACD_Main_1)&&(MACD_Signal_0>MACD_Signal_1))
                     MS_CloseSell_1=true;
                  break;
               case 9:
                  if((MACD_Main_0<MACD_LevelCloseDn)&&(MACD_Main_1<MACD_LevelCloseDn)&&
                     (MACD_Main_0<MACD_Signal_0)&&(MACD_Main_0<MACD_Main_1)&&(MACD_Signal_0<MACD_Signal_1))
                     MS_CloseBuy_1=true;
                  if((MACD_Main_0>MACD_LevelCloseUp)&&(MACD_Main_1>MACD_LevelCloseUp)&&
                     (MACD_Main_0>MACD_Signal_0)&&(MACD_Main_0>MACD_Main_1)&&(MACD_Signal_0>MACD_Signal_1))
                     MS_CloseSell_1=true;
                  break;
               case 10:
                  if((MACD_Main_0>MACD_LevelCloseDn)&&(MACD_Main_1<MACD_LevelCloseDn)&&
                     (MACD_Main_0>MACD_Signal_0)&&(MACD_Main_0>MACD_Main_1)&&(MACD_Signal_0>MACD_Signal_1))
                     MS_CloseBuy_1=true;
                  if((MACD_Main_0<MACD_LevelCloseUp)&&(MACD_Main_1>MACD_LevelCloseUp)&&
                     (MACD_Main_0<MACD_Signal_0)&&(MACD_Main_0<MACD_Main_1)&&(MACD_Signal_0<MACD_Signal_1))
                     MS_CloseSell_1=true;
                  break;
               case 11:
                  if((MACD_Main_0<MACD_LevelCloseDn)&&(MACD_Main_1>MACD_LevelCloseDn)&&
                     (MACD_Main_0<MACD_Signal_0)&&(MACD_Main_0<MACD_Main_1)&&(MACD_Signal_0<MACD_Signal_1))
                     MS_CloseBuy_1=true;
                  if((MACD_Main_0>MACD_LevelCloseUp)&&(MACD_Main_1<MACD_LevelCloseUp)&&
                     (MACD_Main_0>MACD_Signal_0)&&(MACD_Main_0>MACD_Main_1)&&(MACD_Signal_0>MACD_Signal_1))
                     MS_CloseSell_1=true;
                  break;
              }
           }
         //---------------------------------------------------------------------
         if(MS_CloseOrdersType_2>0)
           {
            switch(MS_CloseOrdersType_2)
              {
               case 1:
                  if((STOCH_K_0>STOCH_LevelCloseUp)&&(STOCH_K_1>STOCH_LevelCloseUp)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0<STOCH_LevelCloseDn)&&(STOCH_K_1<STOCH_LevelCloseDn)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 2:
                  if((STOCH_K_0>STOCH_LevelCloseUp)&&(STOCH_K_1>STOCH_LevelCloseUp)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0<STOCH_LevelCloseDn)&&(STOCH_K_1<STOCH_LevelCloseDn)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 3:
                  if((STOCH_K_0>STOCH_LevelCloseUp)&&(STOCH_K_1>STOCH_LevelCloseUp)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0<STOCH_LevelCloseDn)&&(STOCH_K_1<STOCH_LevelCloseDn)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 4:
                  if((STOCH_K_0>STOCH_LevelCloseUp)&&(STOCH_K_1>STOCH_LevelCloseUp)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0<STOCH_LevelCloseDn)&&(STOCH_K_1<STOCH_LevelCloseDn)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 5:
                  if((STOCH_K_0>STOCH_LevelCloseUp)&&(STOCH_K_1>STOCH_LevelCloseUp)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0<STOCH_LevelCloseDn)&&(STOCH_K_1<STOCH_LevelCloseDn)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 6:
                  if((STOCH_K_0>STOCH_LevelCloseUp)&&(STOCH_K_1>STOCH_LevelCloseUp)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0<STOCH_LevelCloseDn)&&(STOCH_K_1<STOCH_LevelCloseDn)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 7:
                  if((STOCH_K_0>STOCH_LevelCloseUp)&&(STOCH_K_1>STOCH_LevelCloseUp)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0<STOCH_LevelCloseDn)&&(STOCH_K_1<STOCH_LevelCloseDn)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 8:
                  if((STOCH_K_0>STOCH_LevelCloseUp)&&(STOCH_K_1>STOCH_LevelCloseUp)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0<STOCH_LevelCloseDn)&&(STOCH_K_1<STOCH_LevelCloseDn)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 9:
                  if((STOCH_K_0<STOCH_LevelCloseUp)&&(STOCH_K_1>STOCH_LevelCloseUp)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0>STOCH_LevelCloseDn)&&(STOCH_K_1<STOCH_LevelCloseDn)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 10:
                  if((STOCH_K_0<STOCH_LevelCloseUp)&&(STOCH_K_1>STOCH_LevelCloseUp)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0>STOCH_LevelCloseDn)&&(STOCH_K_1<STOCH_LevelCloseDn)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 11:
                  if((STOCH_K_0<STOCH_LevelCloseUp)&&(STOCH_K_1>STOCH_LevelCloseUp)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0>STOCH_LevelCloseDn)&&(STOCH_K_1<STOCH_LevelCloseDn)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 12:
                  if((STOCH_K_0>STOCH_LevelCloseUp)&&(STOCH_K_1<STOCH_LevelCloseUp)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0<STOCH_LevelCloseDn)&&(STOCH_K_1>STOCH_LevelCloseDn)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 13:
                  if((STOCH_K_0>STOCH_LevelCloseUp)&&(STOCH_K_1<STOCH_LevelCloseUp)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0<STOCH_LevelCloseDn)&&(STOCH_K_1>STOCH_LevelCloseDn)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 14:
                  if((STOCH_K_0>STOCH_LevelCloseUp)&&(STOCH_K_1<STOCH_LevelCloseUp)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0<STOCH_LevelCloseDn)&&(STOCH_K_1>STOCH_LevelCloseDn)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 15:
                  if((STOCH_K_0<STOCH_LevelCloseDn)&&(STOCH_K_1<STOCH_LevelCloseDn)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0>STOCH_LevelCloseUp)&&(STOCH_K_1>STOCH_LevelCloseUp)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 16:
                  if((STOCH_K_0<STOCH_LevelCloseDn)&&(STOCH_K_1<STOCH_LevelCloseDn)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0>STOCH_LevelCloseUp)&&(STOCH_K_1>STOCH_LevelCloseUp)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 17:
                  if((STOCH_K_0<STOCH_LevelCloseDn)&&(STOCH_K_1<STOCH_LevelCloseDn)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0>STOCH_LevelCloseUp)&&(STOCH_K_1>STOCH_LevelCloseUp)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 18:
                  if((STOCH_K_0<STOCH_LevelCloseDn)&&(STOCH_K_1<STOCH_LevelCloseDn)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0>STOCH_LevelCloseUp)&&(STOCH_K_1>STOCH_LevelCloseUp)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 19:
                  if((STOCH_K_0<STOCH_LevelCloseDn)&&(STOCH_K_1<STOCH_LevelCloseDn)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0>STOCH_LevelCloseUp)&&(STOCH_K_1>STOCH_LevelCloseUp)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 20:
                  if((STOCH_K_0<STOCH_LevelCloseDn)&&(STOCH_K_1<STOCH_LevelCloseDn)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0>STOCH_LevelCloseUp)&&(STOCH_K_1>STOCH_LevelCloseUp)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 21:
                  if((STOCH_K_0<STOCH_LevelCloseDn)&&(STOCH_K_1<STOCH_LevelCloseDn)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0>STOCH_LevelCloseUp)&&(STOCH_K_1>STOCH_LevelCloseUp)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 22:
                  if((STOCH_K_0<STOCH_LevelCloseDn)&&(STOCH_K_1<STOCH_LevelCloseDn)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0>STOCH_LevelCloseUp)&&(STOCH_K_1>STOCH_LevelCloseUp)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 23:
                  if((STOCH_K_0>STOCH_LevelCloseDn)&&(STOCH_K_1<STOCH_LevelCloseDn)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0<STOCH_LevelCloseUp)&&(STOCH_K_1>STOCH_LevelCloseUp)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 24:
                  if((STOCH_K_0>STOCH_LevelCloseDn)&&(STOCH_K_1<STOCH_LevelCloseDn)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0<STOCH_LevelCloseUp)&&(STOCH_K_1>STOCH_LevelCloseUp)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 25:
                  if((STOCH_K_0>STOCH_LevelCloseDn)&&(STOCH_K_1<STOCH_LevelCloseDn)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0<STOCH_LevelCloseUp)&&(STOCH_K_1>STOCH_LevelCloseUp)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 26:
                  if((STOCH_K_0<STOCH_LevelCloseDn)&&(STOCH_K_1>STOCH_LevelCloseDn)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0>STOCH_LevelCloseUp)&&(STOCH_K_1<STOCH_LevelCloseUp)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 27:
                  if((STOCH_K_0<STOCH_LevelCloseDn)&&(STOCH_K_1>STOCH_LevelCloseDn)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0>STOCH_LevelCloseUp)&&(STOCH_K_1<STOCH_LevelCloseUp)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
               case 28:
                  if((STOCH_K_0<STOCH_LevelCloseDn)&&(STOCH_K_1>STOCH_LevelCloseDn)&&
                     (STOCH_K_0<STOCH_D_0)&&(STOCH_K_0<STOCH_K_1)&&(STOCH_D_0<STOCH_D_1))
                     MS_CloseBuy_2=true;
                  if((STOCH_K_0>STOCH_LevelCloseUp)&&(STOCH_K_1<STOCH_LevelCloseUp)&&
                     (STOCH_K_0>STOCH_D_0)&&(STOCH_K_0>STOCH_K_1)&&(STOCH_D_0>STOCH_D_1))
                     MS_CloseSell_2=true;
                  break;
              }
           }
        }
     }
//---------------------------------------------------------------------
//Final signals open orders
   if((MS_OpenBuy_1==true)&&(MS_OpenBuy_2==true))
      MS_OpenBuy=true;
   if((MS_OpenSell_1==true)&&(MS_OpenSell_2==true))
      MS_OpenSell=true;
//---------------------------------------------------------------------
//Final signals close orders
   if(MS_CloseInSignals==true)
     {
      if(MS_CloseBuy_1==true)
         MS_CloseBuy=true;
      if(MS_CloseBuy_2==true)
         MS_CloseBuy=true;
      //---
      if(MS_CloseSell_1==true)
         MS_CloseSell=true;
      if(MS_CloseSell_2==true)
         MS_CloseSell=true;
     }
//---------------------------------------------------------------------
//Close orders in reverse signal
   if(CloseInReverse==true)
     {
      if(MS_OpenBuy==true)
         MS_CloseSell=true;
      if(MS_OpenSell==true)
         MS_CloseBuy=true;
     }
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//End code
//============================================================================================================================================================================================================================//
