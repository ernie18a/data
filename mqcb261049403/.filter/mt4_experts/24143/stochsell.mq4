//+------------------------------------------------------------------------------+//
//)   ____  _  _  ____  ____  ____  ____  __  __    __      ___  _____  __  __   (//
//)  ( ___)( \/ )(  _ \(  _ \( ___)( ___)(  \/  )  /__\    / __)(  _  )(  \/  )  (//
//)   )__)  )  (  )(_) ))   / )__)  )__)  )    (  /(__)\  ( (__  )(_)(  )    (   (//
//)  (__)  (_/\_)(____/(_)\_)(____)(____)(_/\/\_)(__)(__)()\___)(_____)(_/\/\_)  (//
//)   https://fxdreema.com                             Copyright 2019, fxDreema  (//
//+------------------------------------------------------------------------------+//
#property copyright   ""
#property link        "https://fxdreema.com"
#property description ""
#property version     "1.0"
#property strict

/************************************************************************************************************************/
// +------------------------------------------------------------------------------------------------------------------+ //
// |                       INPUT PARAMETERS, GLOBAL VARIABLES, CONSTANTS, IMPORTS and INCLUDES                        | //
// |                      System and Custom variables and other definitions used in the project                       | //
// +------------------------------------------------------------------------------------------------------------------+ //
/************************************************************************************************************************/

//VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
// System constants (project settings) //
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
//--
#define PROJECT_ID "mt4-9355"
//--
// Point Format Rules
#define POINT_FORMAT_RULES "0.001=0.01,0.00001=0.0001,0.000001=0.0001" // this is deserialized in a special function later
#define ENABLE_SPREAD_METER true
#define ENABLE_STATUS true
#define ENABLE_TEST_INDICATORS true
//--
// Events On/Off
#define ENABLE_EVENT_TICK 1 // enable "Tick" event
#define ENABLE_EVENT_TRADE 0 // enable "Trade" event
#define ENABLE_EVENT_TIMER 0 // enable "Timer" event
//--
// Virtual Stops
#define VIRTUAL_STOPS_ENABLED 0 // enable virtual stops
#define VIRTUAL_STOPS_TIMEOUT 0 // virtual stops timeout
#define USE_EMERGENCY_STOPS "no" // "yes" to use emergency (hard stops) when virtual stops are in use. "always" to use EMERGENCY_STOPS_ADD as emergency stops when there is no virtual stop.
#define EMERGENCY_STOPS_REL 0 // use 0 to disable hard stops when virtual stops are enabled. Use a value >=0 to automatically set hard stops with virtual. Example: if 2 is used, then hard stops will be 2 times bigger than virtual ones.
#define EMERGENCY_STOPS_ADD 0 // add pips to relative size of emergency stops (hard stops)
//--
// Settings for events
#define ON_TRADE_REALTIME 0 //
#define ON_TIMER_PERIOD 60 // Timer event period (in seconds)

//VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
// System constants (predefined constants) //
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
//--
// Blocks Lookup Functions
string fxdBlocksLookupTable[];

#define TLOBJPROP_TIME1 801
#define OBJPROP_TL_PRICE_BY_SHIFT 802
#define OBJPROP_TL_SHIFT_BY_PRICE 803
#define OBJPROP_FIBOVALUE 804
#define OBJPROP_FIBOPRICEVALUE 805
#define OBJPROP_BARSHIFT1 807
#define OBJPROP_BARSHIFT2 808
#define OBJPROP_BARSHIFT3 809
#define SEL_CURRENT 0
#define SEL_INITIAL 1

//VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
// Enumerations, Imports, Constants, Variables //
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//




//--
// Constants (Input Parameters)
input int MagicStart = 9355; // Magic Number, kind of...
class c
{
		public:
	static int MagicStart;
};
int c::MagicStart;


//--
// Variables (Global Variables)
class v
{
		public:
};



//--
// Externs (Global Variables)
input int inp138_GridOrdersCount = 8;
input double inp138_GridStartOffset = -13;
input double inp138_GridSize = -23;
input double inp138_VolumePercent = 70.0;
input double inp138_FixedRatioUnitSize = 0.02;
input double inp138_TakeProfitPips = 145.0;
input int inp138_ExpMinutes = 45;
input double inp141_ProfitAmountPips = 23.0;
input double inp145_VolumePercent = 30.0;
input double inp145_TakeProfitPips = 105.0;
input int inp149_Lo_Kperiod = 30;
input int inp149_Lo_Dperiod = 3;
input int inp149_Lo_Slowing = 3;
input int inp153_Lo_Kperiod = 900;
input int inp153_Lo_Dperiod = 1;
input int inp153_Lo_Slowing = 3;
class _externs
{
		public:
	static int inp138_GridOrdersCount;
	static double inp138_GridStartOffset;
	static double inp138_GridSize;
	static double inp138_VolumePercent;
	static double inp138_FixedRatioUnitSize;
	static double inp138_TakeProfitPips;
	static int inp138_ExpMinutes;
	static double inp141_ProfitAmountPips;
	static double inp145_VolumePercent;
	static double inp145_TakeProfitPips;
	static int inp149_Lo_Kperiod;
	static int inp149_Lo_Dperiod;
	static int inp149_Lo_Slowing;
	static int inp153_Lo_Kperiod;
	static int inp153_Lo_Dperiod;
	static int inp153_Lo_Slowing;
};
int _externs::inp138_GridOrdersCount = inp138_GridOrdersCount;
double _externs::inp138_GridStartOffset = inp138_GridStartOffset;
double _externs::inp138_GridSize = inp138_GridSize;
double _externs::inp138_VolumePercent = inp138_VolumePercent;
double _externs::inp138_FixedRatioUnitSize = inp138_FixedRatioUnitSize;
double _externs::inp138_TakeProfitPips = inp138_TakeProfitPips;
int _externs::inp138_ExpMinutes = inp138_ExpMinutes;
double _externs::inp141_ProfitAmountPips = inp141_ProfitAmountPips;
double _externs::inp145_VolumePercent = inp145_VolumePercent;
double _externs::inp145_TakeProfitPips = inp145_TakeProfitPips;
int _externs::inp149_Lo_Kperiod = inp149_Lo_Kperiod;
int _externs::inp149_Lo_Dperiod = inp149_Lo_Dperiod;
int _externs::inp149_Lo_Slowing = inp149_Lo_Slowing;
int _externs::inp153_Lo_Kperiod = inp153_Lo_Kperiod;
int _externs::inp153_Lo_Dperiod = inp153_Lo_Dperiod;
int _externs::inp153_Lo_Slowing = inp153_Lo_Slowing;



//VVVVVVVVVVVVVVVVVVVVVVVVV//
// System global variables //
//^^^^^^^^^^^^^^^^^^^^^^^^^//
//--
int FXD_CURRENT_FUNCTION_ID = 0;
double FXD_MILS_INIT_END    = 0;
int FXD_TICKS_FROM_START    = 0;
int FXD_MORE_SHIFT          = 0;
bool FXD_DRAW_SPREAD_INFO   = false;
bool FXD_FIRST_TICK_PASSED  = false;
bool FXD_BREAK              = false;
bool FXD_CONTINUE           = false;
bool FXD_CHART_IS_OFFLINE   = false;
bool FXD_ONTIMER_TAKEN      = false;
bool FXD_ONTIMER_TAKEN_IN_MILLISECONDS = false;
double FXD_ONTIMER_TAKEN_TIME = 0;
bool USE_VIRTUAL_STOPS = VIRTUAL_STOPS_ENABLED;
string FXD_CURRENT_SYMBOL   = "";
int FXD_BLOCKS_COUNT        = 11;
datetime FXD_TICKSKIP_UNTIL = 0;

//- for use in OnChart() event
struct fxd_onchart
{
	int id;
	long lparam;
	double dparam;
	string sparam;
};
fxd_onchart FXD_ONCHART;

/************************************************************************************************************************/
// +------------------------------------------------------------------------------------------------------------------+ //
// |                                                 EVENT FUNCTIONS                                                  | //
// |                           These are the main functions that controls the whole project                           | //
// +------------------------------------------------------------------------------------------------------------------+ //
/************************************************************************************************************************/

//VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
// This function is executed once when the program starts //
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
int OnInit()
{

	// Initiate Constants
	c::MagicStart = MagicStart;




	// Initiate Externs
	_externs::inp138_GridOrdersCount = inp138_GridOrdersCount;
	_externs::inp138_GridStartOffset = inp138_GridStartOffset;
	_externs::inp138_GridSize = inp138_GridSize;
	_externs::inp138_VolumePercent = inp138_VolumePercent;
	_externs::inp138_FixedRatioUnitSize = inp138_FixedRatioUnitSize;
	_externs::inp138_TakeProfitPips = inp138_TakeProfitPips;
	_externs::inp138_ExpMinutes = inp138_ExpMinutes;
	_externs::inp141_ProfitAmountPips = inp141_ProfitAmountPips;
	_externs::inp145_VolumePercent = inp145_VolumePercent;
	_externs::inp145_TakeProfitPips = inp145_TakeProfitPips;
	_externs::inp149_Lo_Kperiod = inp149_Lo_Kperiod;
	_externs::inp149_Lo_Dperiod = inp149_Lo_Dperiod;
	_externs::inp149_Lo_Slowing = inp149_Lo_Slowing;
	_externs::inp153_Lo_Kperiod = inp153_Lo_Kperiod;
	_externs::inp153_Lo_Dperiod = inp153_Lo_Dperiod;
	_externs::inp153_Lo_Slowing = inp153_Lo_Slowing;



	// do or do not not initilialize on reload
	if (UninitializeReason() != 0)
	{
		if (UninitializeReason() == REASON_CHARTCHANGE)
		{
			// if the symbol is the same, do not reload, otherwise continue below
			if (FXD_CURRENT_SYMBOL == Symbol()) {return INIT_SUCCEEDED;}
		}
		else
		{
			return INIT_SUCCEEDED;
		}
	}
	FXD_CURRENT_SYMBOL = Symbol();





	Comment("");
	for (int i=ObjectsTotal(ChartID()); i>=0; i--)
	{
		string name = ObjectName(ChartID(), i);
		if (StringSubstr(name,0,8) == "fxd_cmnt") {ObjectDelete(ChartID(), name);}
	}
	ChartRedraw();



	//-- disable virtual stops in optimization, because graphical objects does not work
	// http://docs.mql4.com/runtime/testing
	if (MQLInfoInteger(MQL_OPTIMIZATION) || (MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE))) {
		USE_VIRTUAL_STOPS = false;
	}

	//-- set initial local and server time
	TimeAtStart("set");

	//-- set initial balance
	AccountBalanceAtStart();

	//-- draw the initial spread info meter
	if (ENABLE_SPREAD_METER == false) {
		FXD_DRAW_SPREAD_INFO = false;
	}
	else {
		FXD_DRAW_SPREAD_INFO = !(MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE));
	}
	if (FXD_DRAW_SPREAD_INFO) DrawSpreadInfo();

	//-- draw initial status
	if (ENABLE_STATUS) DrawStatus("waiting for tick...");

	//-- draw indicators after test
	TesterHideIndicators(!ENABLE_TEST_INDICATORS);

	//-- working with offline charts
	if (MQLInfoInteger(MQL_PROGRAM_TYPE) == PROGRAM_EXPERT)
	{
		FXD_CHART_IS_OFFLINE = ChartGetInteger(0, CHART_IS_OFFLINE);
	}

	if (MQLInfoInteger(MQL_PROGRAM_TYPE) != PROGRAM_SCRIPT)
	{
		if (FXD_CHART_IS_OFFLINE == true || (ENABLE_EVENT_TRADE == 1 && ON_TRADE_REALTIME == 1))
		{
			FXD_ONTIMER_TAKEN = true;
			EventSetMillisecondTimer(1);
		}
		if (ENABLE_EVENT_TIMER) {
			OnTimerSet(ON_TIMER_PERIOD);
		}
	}

	if (ENABLE_EVENT_TRADE) OnTradeListener(); // to load initial database of orders


	//-- Initialize blocks classes
	ArrayResize(_blocks_, 11);

	_blocks_[0] = new Block0();
	_blocks_[1] = new Block1();
	_blocks_[2] = new Block2();
	_blocks_[3] = new Block3();
	_blocks_[4] = new Block4();
	_blocks_[5] = new Block5();
	_blocks_[6] = new Block6();
	_blocks_[7] = new Block7();
	_blocks_[8] = new Block8();
	_blocks_[9] = new Block9();
	_blocks_[10] = new Block10();

	// fill the lookup table
	ArrayResize(fxdBlocksLookupTable, ArraySize(_blocks_));
	for (int i=0; i<ArraySize(_blocks_); i++)
	{
		fxdBlocksLookupTable[i] = _blocks_[i].__block_user_number;
	}

	// fill the list of inbound blocks for each BlockCalls instance
	for (int i=0; i<ArraySize(_blocks_); i++)
	{
		_blocks_[i].__announceThisBlock();
	}

	// List of initially disabled blocks
	int disabled_blocks_list[] = {};
	for (int l = 0; l < ArraySize(disabled_blocks_list); l++) {
		_blocks_[disabled_blocks_list[l]].__disabled = true;
	}



	FXD_MILS_INIT_END     = (double)GetTickCount();
	FXD_FIRST_TICK_PASSED = false; // reset is needed when changing inputs

	return(INIT_SUCCEEDED);
}

//VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
// This function is executed on every incoming tick //
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
void OnTick()
{
	FXD_TICKS_FROM_START++;

	if (ENABLE_STATUS && FXD_TICKS_FROM_START == 1) DrawStatus("working");

	//-- special system actions
	if (FXD_DRAW_SPREAD_INFO) DrawSpreadInfo();
	TicksData(""); // Collect ticks (if needed)
	TicksPerSecond(false, true); // Collect ticks per second
	if (USE_VIRTUAL_STOPS) {VirtualStopsDriver();}

	if (OrdersTotal()) // this makes things faster
	{
		ExpirationDriver();
		OCODriver(); // Check and close OCO orders
	}
	if (ENABLE_EVENT_TRADE) {OnTradeListener();}


	// skip ticks
	if (TimeLocal() < FXD_TICKSKIP_UNTIL) {return;}

	//-- run blocks
	int blocks_to_run[] = {0,4};
	for (int i=0; i<ArraySize(blocks_to_run); i++) {
		_blocks_[blocks_to_run[i]].run();
	}


	return;
}



//VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
// This function is executed on trade events - open, close, modify //
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
void EventTrade()
{


	OnTradeQueue(-1);
}

//VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
// This function is executed on a period basis //
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
void OnTimer()
{
	//-- to simulate ticks in offline charts, Timer is used instead of infinite loop
	//-- the next function checks for changes in price and calls OnTick() manually
	if (FXD_CHART_IS_OFFLINE && RefreshRates()) {
		OnTick();
	}
	if (ON_TRADE_REALTIME == 1) {
		OnTradeListener();
	}

	static datetime t0 = 0;
	datetime t = 0;
	bool ok = false;

	if (FXD_ONTIMER_TAKEN)
	{
		if (FXD_ONTIMER_TAKEN_TIME > 0)
		{
			if (FXD_ONTIMER_TAKEN_IN_MILLISECONDS == true)
			{
				t = GetTickCount();
			}
			else
			{
				t = TimeLocal();
			}
			if ((t - t0) >= FXD_ONTIMER_TAKEN_TIME)
			{
				t0 = t;
				ok = true;
			}
		}

		if (ok == false) {
			return;
		}
	}

}


//VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
// This function is executed when chart event happens //
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
void OnChartEvent(
	const int id,         // Event ID
	const long& lparam,   // Parameter of type long event
	const double& dparam, // Parameter of type double event
	const string& sparam  // Parameter of type string events
)
{
	//-- write parameter to the system global variables
	FXD_ONCHART.id     = id;
	FXD_ONCHART.lparam = lparam;
	FXD_ONCHART.dparam = dparam;
	FXD_ONCHART.sparam = sparam;


	return;
}

//VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
// This function is executed once when the program ends //
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
void OnDeinit(const int reason)
{
	int reson = UninitializeReason();
	if (reson == REASON_CHARTCHANGE || reson == REASON_PARAMETERS || reason == REASON_TEMPLATE) {return;}

	//-- if Timer was set, kill it here
	EventKillTimer();

	if (ENABLE_STATUS) DrawStatus("stopped");
	if (ENABLE_SPREAD_METER) DrawSpreadInfo();



	if (MQLInfoInteger(MQL_TESTER)) {
		Print("Backtested in "+DoubleToString((GetTickCount()-FXD_MILS_INIT_END)/1000, 2)+" seconds");
		double tc = GetTickCount()-FXD_MILS_INIT_END;
		if (tc > 0)
		{
			Print("Average ticks per second: "+DoubleToString(FXD_TICKS_FROM_START/tc, 0));
		}
	}

	if (MQLInfoInteger(MQL_PROGRAM_TYPE) == PROGRAM_EXPERT)
	{
		switch(UninitializeReason())
		{
			case REASON_PROGRAM     : Print("Expert Advisor self terminated"); break;
			case REASON_REMOVE      : Print("Expert Advisor removed from the chart"); break;
			case REASON_RECOMPILE   : Print("Expert Advisor has been recompiled"); break;
			case REASON_CHARTCHANGE : Print("Symbol or chart period has been changed"); break;
			case REASON_CHARTCLOSE  : Print("Chart has been closed"); break;
			case REASON_PARAMETERS  : Print("Input parameters have been changed by a user"); break;
			case REASON_ACCOUNT     : Print("Another account has been activated or reconnection to the trade server has occurred due to changes in the account settings"); break;
			case REASON_TEMPLATE    : Print("A new template has been applied"); break;
			case REASON_INITFAILED  : Print("OnInit() handler has returned a nonzero value"); break;
			case REASON_CLOSE       : Print("Terminal has been closed"); break;
		}
	}

	// delete dynamic pointers
	for (int i=0; i<ArraySize(_blocks_); i++)
	{
		delete _blocks_[i];
		_blocks_[i] = NULL;
	}
	ArrayResize(_blocks_, 0);

	return;
}

/************************************************************************************************************************/
// +------------------------------------------------------------------------------------------------------------------+ //
// |	                                         Classes of blocks                                                    | //
// |              Classes that contain the actual code of the blocks and their input parameters as well               | //
// +------------------------------------------------------------------------------------------------------------------+ //
/************************************************************************************************************************/

/**
	The base class for all block calls
   */
class BlockCalls
{
	public:
		bool __disabled; // whether or not the block is disabled

		string __block_user_number;
        int __block_number;
		int __block_waiting;
		int __parent_number;
		int __inbound_blocks[];
		int __outbound_blocks[];

		void __addInboundBlock(int id = 0) {
			int size = ArraySize(__inbound_blocks);
			for (int i = 0; i < size; i++) {
				if (__inbound_blocks[i] == id) {
					return;
				}
			}
			ArrayResize(__inbound_blocks, size + 1);
			__inbound_blocks[size] = id;
		}

		void BlockCalls() {
			__disabled          = false;
			__block_user_number = "";
			__block_number      = 0;
			__block_waiting     = 0;
			__parent_number     = 0;
		}

		/**
		   Announce this block to the list of inbound connections of all the blocks to which this block is connected to
		   */
		void __announceThisBlock()
		{
		   // add the current block number to the list of inbound blocks
		   // for each outbound block that is provided
			for (int i = 0; i < ArraySize(__outbound_blocks); i++)
			{
				int block = __outbound_blocks[i]; // outbound block number
				int size  = ArraySize(_blocks_[block].__inbound_blocks); // the size of its inbound list

				// skip if the current block was already added
				for (int j = 0; j < size; j++) {
					if (_blocks_[block].__inbound_blocks[j] == __block_number)
					{
						return;
					}
				}

				// add the current block number to the list of inbound blocks of the other block
				ArrayResize(_blocks_[block].__inbound_blocks, size + 1);
				_blocks_[block].__inbound_blocks[size] = __block_number;
			}
		}

		// this is here, because it is used in the "run" function
		virtual void _execute_() = 0;

		/**
			In the derived class this method should be used to set dynamic parameters or other stuff before the main execute.
			This method is automatically called within the main "run" method below, before the execution of the main class.
			*/
		virtual void _beforeExecute_() {return;};
		bool _beforeExecuteEnabled; // for speed

		/**
			Same as _beforeExecute_, but to work after the execute method.
			*/
		virtual void _afterExecute_() {return;};
		bool _afterExecuteEnabled; // for speed

		/**
			This is the method that is used to run the block
			*/
		virtual void run(int _parent_=0) {
			__parent_number = _parent_;
			if (__disabled || FXD_BREAK) {return;}
			FXD_CURRENT_FUNCTION_ID = __block_number;

			if (_beforeExecuteEnabled) {_beforeExecute_();}
			_execute_();
			if (_afterExecuteEnabled) {_afterExecute_();}

			if (__block_waiting && FXD_CURRENT_FUNCTION_ID == __block_number) {fxdWait.Accumulate(FXD_CURRENT_FUNCTION_ID);}
		}
};

BlockCalls *_blocks_[];


// "No trade" model
template<typename T1,typename T2,typename T3,typename T4,typename T5>
class MDL_NoOpenedOrders: public BlockCalls
{
	public: /* Input Parameters */
	T1 GroupMode;
	T2 Group;
	T3 SymbolMode;
	T4 Symbol;
	T5 BuysOrSells;
	virtual void _callback_(int r) {return;}

	public: /* Constructor */
	MDL_NoOpenedOrders()
	{
		GroupMode = (string)"group";
		Group = (string)"";
		SymbolMode = (string)"symbol";
		Symbol = (string)CurrentSymbol();
		BuysOrSells = (string)"both";
	}

	public: /* The main method */
	virtual void _execute_()
	{
		bool exist = false;
		
		for (int index = TradesTotal()-1; index >= 0; index--)
		{
			if (TradeSelectByIndex(index, GroupMode, Group, SymbolMode, Symbol, BuysOrSells))
			{
				exist = true;
				break;
			}
		}
		
		if (exist == false) {_callback_(1);} else {_callback_(0);}
	}
};

// "Sell pending orders in grid" model
template<typename T1,typename T2,typename T3,typename T4,typename T5,typename _T5_,typename T6,typename T7,typename T8,typename T9,typename T10,typename T11,typename T12,typename T13,typename T14,typename T15,typename _T15_,typename T16,typename T17,typename T18,typename T19,typename T20,typename T21,typename T22,typename _T22_,typename T23,typename _T23_,typename T24,typename _T24_,typename T25,typename T26,typename T27,typename T28,typename _T28_,typename T29,typename _T29_,typename T30,typename _T30_,typename T31,typename T32,typename T33,typename T34,typename T35,typename T36,typename T37,typename T38,typename T39,typename _T39_,typename T40,typename T41,typename T42>
class MDL_GridPendingSells2: public BlockCalls
{
	public: /* Input Parameters */
	T1 Group;
	T2 Symbol;
	T3 GridOrdersCount;
	T4 GridStart;
	T5 fGridStart; virtual _T5_ _fGridStart_(){return(_T5_)0;}
	T6 GridStartOffset;
	T7 GridStartRoundNumberPips;
	T8 GridSize;
	T9 VolumeMode;
	T10 VolumeSize;
	T11 VolumeSizeRisk;
	T12 VolumeRisk;
	T13 VolumePercent;
	T14 VolumeBlockPercent;
	T15 dVolumeSize; virtual _T15_ _dVolumeSize_(){return(_T15_)0;}
	T16 FixedRatioUnitSize;
	T17 FixedRatioDelta;
	T18 VolumeUpperLimit;
	T19 gSLmode;
	T20 StopLossPips;
	T21 GridSizeSL;
	T22 dlStopLoss; virtual _T22_ _dlStopLoss_(){return(_T22_)0;}
	T23 dpStopLoss; virtual _T23_ _dpStopLoss_(){return(_T23_)0;}
	T24 ddStopLoss; virtual _T24_ _ddStopLoss_(){return(_T24_)0;}
	T25 gTPmode;
	T26 TakeProfitPips;
	T27 GridSizeTP;
	T28 dlTakeProfit; virtual _T28_ _dlTakeProfit_(){return(_T28_)0;}
	T29 dpTakeProfit; virtual _T29_ _dpTakeProfit_(){return(_T29_)0;}
	T30 ddTakeProfit; virtual _T30_ _ddTakeProfit_(){return(_T30_)0;}
	T31 GridLevelsGradation;
	T32 GridVolumesGradation;
	T33 GridSLgradation;
	T34 GridTPgradation;
	T35 ExpMode;
	T36 ExpDays;
	T37 ExpHours;
	T38 ExpMinutes;
	T39 dExp; virtual _T39_ _dExp_(){return(_T39_)0;}
	T40 Slippage;
	T41 MyComment;
	T42 ArrowColorSell;
	virtual void _callback_(int r) {return;}

	public: /* Constructor */
	MDL_GridPendingSells2()
	{
		Group = (string)"";
		Symbol = (string)CurrentSymbol();
		GridOrdersCount = (int)3;
		GridStart = (string)"bid";
		GridStartOffset = (double)0.0;
		GridStartRoundNumberPips = (double)0.0;
		GridSize = (double)25.0;
		VolumeMode = (string)"fixed";
		VolumeSize = (double)0.1;
		VolumeSizeRisk = (double)50.0;
		VolumeRisk = (double)2.5;
		VolumePercent = (double)100.0;
		VolumeBlockPercent = (double)3.0;
		FixedRatioUnitSize = (double)0.01;
		FixedRatioDelta = (double)20.0;
		VolumeUpperLimit = (double)0.0;
		gSLmode = (string)"fixed";
		StopLossPips = (double)50.0;
		GridSizeSL = (double)100.0;
		gTPmode = (string)"fixed";
		TakeProfitPips = (double)50.0;
		GridSizeTP = (double)100.0;
		GridLevelsGradation = (double)100.0;
		GridVolumesGradation = (double)100.0;
		GridSLgradation = (double)100.0;
		GridTPgradation = (double)100.0;
		ExpMode = (string)"GTC";
		ExpDays = (int)0;
		ExpHours = (int)1;
		ExpMinutes = (int)0;
		Slippage = (ulong)4;
		MyComment = (string)"";
		ArrowColorSell = (color)clrRed;
	}

	public: /* The main method */
	virtual void _execute_()
	{
		//-- open price -------------------------------------------------------------
		double op=0;
		
		     if (GridStart == "ask")      {op = SymbolAsk(Symbol);}
		else if (GridStart == "bid")      {op = SymbolBid(Symbol);}
		else if (GridStart == "mid")      {op = (SymbolAsk(Symbol) + SymbolBid(Symbol)) / 2;}
		else if (GridStart == "function") {op = _fGridStart_();}
		
		op = op - toDigits(GridStartOffset, Symbol);
		
		//-- round number snap ------------------------------------------------------
		if (GridStartRoundNumberPips != 0)
		{
			double grid_start_round_number = toDigits(GridStartRoundNumberPips, Symbol);
			// when negative number is applied, the Math function knows to reverse itself: Ceil <-> Floor
			op = MathFloor(op / grid_start_round_number) * grid_start_round_number;
		}
		
		//-- stops ------------------------------------------------------------------
		double sll = 0, slp = 0, tpl = 0, tpp = 0;
		
		     if (gSLmode == "fixed")           {slp = StopLossPips;}
		else if (gSLmode == "gridsize")        {slp = GridSize * (GridSizeSL / 100);}
		else if (gSLmode == "dynamicPips")     {slp = _dpStopLoss_();}
		else if (gSLmode == "dynamicDigits")   {slp = toPips(_ddStopLoss_(), Symbol);}
		else if (gSLmode == "dynamicLevel")    {sll = _dlStopLoss_();}
		else if (gSLmode == "dynamicLevelAll") {sll = _dlStopLoss_();}
		
		     if (gTPmode == "fixed")           {tpp = TakeProfitPips;}
		else if (gTPmode == "gridsize")        {tpp = GridSize * (GridSizeTP / 100);}
		else if (gTPmode == "dynamicPips")     {tpp = _dpTakeProfit_();}
		else if (gTPmode == "dynamicDigits")   {tpp = toPips(_ddTakeProfit_(), Symbol);}
		else if (gTPmode == "dynamicLevel")    {tpl = _dlTakeProfit_();}
		else if (gTPmode == "dynamicLevelAll") {tpl = _dlTakeProfit_();}
		
		//-- lots -------------------------------------------------------------------
		double lots    = 0;
		double pre_sll = sll;
		
		if (pre_sll == 0) {pre_sll = op;}
		
		double pre_sl_pips = toPips((pre_sll + toDigits(slp, Symbol)) - op, Symbol);
		
		     if (VolumeMode == "fixed")            {lots = DynamicLots(Symbol, VolumeMode, VolumeSize);}
		else if (VolumeMode == "block-equity")     {lots = DynamicLots(Symbol, VolumeMode, VolumeBlockPercent);}
		else if (VolumeMode == "block-balance")    {lots = DynamicLots(Symbol, VolumeMode, VolumeBlockPercent);}
		else if (VolumeMode == "block-freemargin") {lots = DynamicLots(Symbol, VolumeMode, VolumeBlockPercent);}
		else if (VolumeMode == "equity")           {lots = DynamicLots(Symbol, VolumeMode, VolumePercent);}
		else if (VolumeMode == "balance")          {lots = DynamicLots(Symbol, VolumeMode, VolumePercent);}
		else if (VolumeMode == "freemargin")       {lots = DynamicLots(Symbol, VolumeMode, VolumePercent);}
		else if (VolumeMode == "equityRisk")       {lots = DynamicLots(Symbol, VolumeMode, VolumeRisk, pre_sl_pips);}
		else if (VolumeMode == "balanceRisk")      {lots = DynamicLots(Symbol, VolumeMode, VolumeRisk, pre_sl_pips);}
		else if (VolumeMode == "freemarginRisk")   {lots = DynamicLots(Symbol, VolumeMode, VolumeRisk, pre_sl_pips);}
		else if (VolumeMode == "fixedRisk")        {lots = DynamicLots(Symbol, VolumeMode, VolumeSizeRisk, pre_sl_pips);}
		else if (VolumeMode == "fixedRatio")       {lots = DynamicLots(Symbol, VolumeMode, FixedRatioUnitSize, FixedRatioDelta);}
		else if (VolumeMode == "dynamic")          {lots = _dVolumeSize_();}
		
		lots = AlignLots(Symbol, lots, 0, VolumeUpperLimit);
		
		//-- expiration -------------------------------------------------------------
		datetime exp = ExpirationTime(ExpMode, ExpDays, ExpHours, ExpMinutes, _dExp_());
		
		//-- send -------------------------------------------------------------------
		long ticket = 0;
		double gSize = GridSize;
		double gSL  = slp;
		double gTP  = tpp;
		
		if (sll > 0)
		{
			gSL = toPips(sll - op, Symbol);
		
			if (gSLmode == "dynamicLevelAll")
			{
				gSL = 0;
			}
			else if (gSLmode != "dynamicLevelAll")
			{
				sll = 0;
			}
		}
		
		if (tpl > 0)
		{
			gTP = toPips(op - tpl, Symbol);
		
			if (gTPmode == "dynamicLevelAll")
			{
				gTP = 0;
			}
			else if (gTPmode != "dynamicLevelAll")
			{
				tpl = 0;
			}
		}
		
		for (int cnt = 1; cnt <= GridOrdersCount; cnt++)
		{
			if (cnt == 1)
			{
				if (gSLmode == "gridsize") gSL = gSize * (GridSizeSL / 100);
				if (gTPmode == "gridsize") gTP = gSize * (GridSizeTP / 100);
			}
			else
			{
				if (GridLevelsGradation > 0) gSize = gSize * (GridLevelsGradation / 100);
		
				lots = lots * (GridVolumesGradation / 100);
		
				if (gSLmode == "gridsize") gSL = gSize * (GridSizeSL / 100);
				gSL = gSL * (GridSLgradation / 100);
		
				if (gTPmode == "gridsize") gTP = gSize * (GridSizeTP / 100);
				gTP = gTP * (GridTPgradation / 100);
			}
		
			op = op - toDigits(gSize, Symbol);
			double lotsAligned = AlignLots(Symbol, lots, 0, VolumeUpperLimit);
		
			ticket = SellLater(Symbol, lotsAligned, op, sll, tpl, gSL, gTP, Slippage, exp, (MagicStart + (int)Group), MyComment, ArrowColorSell);
		}
		
		if (ticket > 0) {_callback_(1);} else {_callback_(0);}
	}
};

// "Check profit (average)" model
template<typename T1,typename T2,typename T3,typename T4,typename T5,typename T6,typename T7,typename T8,typename T9,typename T10,typename T11,typename T12,typename T13,typename T14,typename T15>
class MDL_CheckAvgProfitFromNtrades: public BlockCalls
{
	public: /* Input Parameters */
	T1 GroupMode;
	T2 Group;
	T3 SymbolMode;
	T4 Symbol;
	T5 BuysOrSells;
	T6 TradesPool;
	T7 NewerHours;
	T8 OlderHours;
	T9 LoopSkip;
	T10 LoopAtLeast;
	T11 LoopLimit;
	T12 ProfitMode;
	T13 Compare;
	T14 ProfitAmountPips;
	T15 ProfitAmountMoney;
	virtual void _callback_(int r) {return;}

	public: /* Constructor */
	MDL_CheckAvgProfitFromNtrades()
	{
		GroupMode = (string)"group";
		Group = (string)"";
		SymbolMode = (string)"symbol";
		Symbol = (string)CurrentSymbol();
		BuysOrSells = (string)"both";
		TradesPool = (string)"running";
		NewerHours = (double)0.0;
		OlderHours = (double)0.0;
		LoopSkip = (int)0;
		LoopAtLeast = (int)0;
		LoopLimit = (int)0;
		ProfitMode = (string)"pips";
		Compare = (string)">";
		ProfitAmountPips = (double)10.0;
		ProfitAmountMoney = (double)10.0;
	}

	public: /* The main method */
	virtual void _execute_()
	{
		int index = 0;
		int count = 0;
		int skip  = -1;
		double profit_money = 0;
		double profit_pips  = 0;
		
		if (TradesPool == "all" || TradesPool == "running")
		{
			for (index = TradesTotal()-1; index >= 0; index--)
			{
				if (TradeSelectByIndex(index, GroupMode, Group, SymbolMode, Symbol, BuysOrSells))
				{
					if (
						   (OlderHours <= 0 || TimeCurrent()-OrderOpenTime() >= 3600*OlderHours)
						&& (NewerHours <= 0 || TimeCurrent()-OrderOpenTime() <= 3600*NewerHours)
					) {
						skip++;
		
						if (LoopSkip <= skip && (count < LoopLimit || LoopLimit == 0))
						{
							count++;
		
							profit_money += NormalizeDouble(OrderProfit() + OrderSwap() + OrderCommission(), 2);
		
							if (IsOrderTypeBuy() == true)
							{
								profit_pips += toPips(SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK)-OrderOpenPrice(), OrderSymbol());
							}
							else
							{
								profit_pips += toPips(OrderOpenPrice()-SymbolInfoDouble(OrderSymbol(), SYMBOL_BID), OrderSymbol());
							}
							
							if (count == LoopLimit) break;
						}
					}
				}
			}
		}
		
		if (TradesPool == "all" || TradesPool == "history")
		{
			for (index = HistoryTradesTotal()-1; index >= 0; index--)
			{
				if (HistoryTradeSelectByIndex(index, GroupMode, Group, SymbolMode, Symbol, BuysOrSells))
				{
					if (
						   (OlderHours <= 0 || TimeCurrent()-OrderOpenTime() >= 3600*OlderHours)
						&& (NewerHours <= 0 || TimeCurrent()-OrderOpenTime() <= 3600*NewerHours)
					) {
						skip++;
		
						if (LoopSkip <= skip && (count < LoopLimit || LoopLimit == 0))
						{
							count++;
		
							profit_money += OrderProfit() + OrderSwap() + OrderCommission();
		
							if (IsOrderTypeBuy() == true)
							{
								profit_pips += toPips(OrderClosePrice()-OrderOpenPrice(), OrderSymbol());
							}
							else
							{
								profit_pips += toPips(OrderOpenPrice()-OrderClosePrice(), OrderSymbol());
							}
							
							if (count == LoopLimit) break;
						}
					}
				}
			}
		}
		
		if (count > 0)
		{
			profit_money = profit_money / count;
			profit_pips  = profit_pips / count;
		}
		else
		{
			profit_money = 0;
			profit_pips  = 0;
		}
		
		profit_money = NormalizeDouble(profit_money, 2);
		profit_pips  = NormalizeDouble(profit_pips, 2);
		
		if (
			(count >= LoopAtLeast || LoopAtLeast == 0)
			&&
			(
				   (ProfitMode == "money" && (compare(Compare, profit_money, ProfitAmountMoney)))
				|| (ProfitMode == "pips" && (compare(Compare, profit_pips, ProfitAmountPips)))
			)
		) {_callback_(1);} else {_callback_(0);}
	}
};

// "Close trades" model
template<typename T1,typename T2,typename T3,typename T4,typename T5,typename T6,typename T7,typename T8>
class MDL_CloseOpened: public BlockCalls
{
	public: /* Input Parameters */
	T1 GroupMode;
	T2 Group;
	T3 SymbolMode;
	T4 Symbol;
	T5 BuysOrSells;
	T6 OrderMinutes;
	T7 Slippage;
	T8 ArrowColor;
	virtual void _callback_(int r) {return;}

	public: /* Constructor */
	MDL_CloseOpened()
	{
		GroupMode = (string)"group";
		Group = (string)"";
		SymbolMode = (string)"symbol";
		Symbol = (string)CurrentSymbol();
		BuysOrSells = (string)"both";
		OrderMinutes = (int)0;
		Slippage = (ulong)4;
		ArrowColor = (color)clrDeepPink;
	}

	public: /* The main method */
	virtual void _execute_()
	{
		int closed_count = 0;
		bool finished    = false;
		
		while (finished == false)
		{
			int count = 0;
		
			for (int index = TradesTotal()-1; index >= 0; index--)
			{
				if (TradeSelectByIndex(index, GroupMode, Group, SymbolMode, Symbol, BuysOrSells))
				{
					datetime time_diff = TimeCurrent() - OrderOpenTime();
		
					if (time_diff < 0) {time_diff = 0;} // this actually happens sometimes
		
					if (time_diff >= 60 * OrderMinutes)
					{
						if (CloseTrade(OrderTicket(), Slippage, ArrowColor))
						{
							closed_count++;
						}
		
						count++;
					}
				}
			}
		
			if (count == 0) {finished = true;}
		}
		
		_callback_(1);
	}
};

// "Check trades count" model
template<typename T1,typename T2,typename T3,typename T4,typename T5,typename T6,typename T7>
class MDL_CheckTradesCount: public BlockCalls
{
	public: /* Input Parameters */
	T1 Compare;
	T2 CompareCount;
	T3 GroupMode;
	T4 Group;
	T5 SymbolMode;
	T6 Symbol;
	T7 BuysOrSells;
	virtual void _callback_(int r) {return;}

	public: /* Constructor */
	MDL_CheckTradesCount()
	{
		Compare = (string)">";
		CompareCount = (int)3;
		GroupMode = (string)"group";
		Group = (string)"";
		SymbolMode = (string)"symbol";
		Symbol = (string)CurrentSymbol();
		BuysOrSells = (string)"both";
	}

	public: /* The main method */
	virtual void _execute_()
	{
		int count = 0;
		
		for (int index = TradesTotal()-1; index >= 0; index--)
		{
			if (TradeSelectByIndex(index, GroupMode, Group, SymbolMode, Symbol, BuysOrSells))
			{
				count++;
			}
		}
		
		if (compare(Compare, count, CompareCount)) {_callback_(1);} else {_callback_(0);}
	}
};

// "Delete pending orders" model
template<typename T1,typename T2,typename T3,typename T4,typename T5,typename T6,typename T7>
class MDL_DeletePendingOrders: public BlockCalls
{
	public: /* Input Parameters */
	T1 GroupMode;
	T2 Group;
	T3 SymbolMode;
	T4 Symbol;
	T5 BuysOrSells;
	T6 LimitsOrStops;
	T7 ArrowColor;
	virtual void _callback_(int r) {return;}

	public: /* Constructor */
	MDL_DeletePendingOrders()
	{
		GroupMode = (string)"group";
		Group = (string)"";
		SymbolMode = (string)"symbol";
		Symbol = (string)CurrentSymbol();
		BuysOrSells = (string)"both";
		LimitsOrStops = (string)"both";
		ArrowColor = (color)clrDeepPink;
	}

	public: /* The main method */
	virtual void _execute_()
	{
		for (int index = OrdersTotal()-1; index >= 0; index--)
		{
			if (PendingOrderSelectByIndex(index, GroupMode, Group, SymbolMode, Symbol, BuysOrSells, LimitsOrStops))
			{
				DeleteOrder(OrderTicket(), ArrowColor);
			}
		}
		
		_callback_(1);
	}
};

// "Sell now" model
template<typename T1,typename T2,typename T3,typename T4,typename T5,typename T6,typename T7,typename T8,typename T9,typename _T9_,typename T10,typename T11,typename T12,typename T13,typename T14,typename T15,typename T16,typename T17,typename T18,typename T19,typename T20,typename T21,typename T22,typename T23,typename T24,typename T25,typename T26,typename T27,typename T28,typename T29,typename T30,typename T31,typename T32,typename T33,typename T34,typename T35,typename T36,typename _T36_,typename T37,typename _T37_,typename T38,typename _T38_,typename T39,typename T40,typename T41,typename T42,typename T43,typename _T43_,typename T44,typename _T44_,typename T45,typename _T45_,typename T46,typename T47,typename T48,typename T49,typename T50,typename _T50_,typename T51,typename T52,typename T53>
class MDL_SellNow: public BlockCalls
{
	public: /* Input Parameters */
	T1 Group;
	T2 Symbol;
	T3 VolumeMode;
	T4 VolumeSize;
	T5 VolumeSizeRisk;
	T6 VolumeRisk;
	T7 VolumePercent;
	T8 VolumeBlockPercent;
	T9 dVolumeSize; virtual _T9_ _dVolumeSize_(){return(_T9_)0;}
	T10 FixedRatioUnitSize;
	T11 FixedRatioDelta;
	T12 mmMgInitialLots;
	T13 mmMgMultiplyOnLoss;
	T14 mmMgMultiplyOnProfit;
	T15 mmMgAddLotsOnLoss;
	T16 mmMgAddLotsOnProfit;
	T17 mmMgResetOnLoss;
	T18 mmMgResetOnProfit;
	T19 mm1326InitialLots;
	T20 mm1326Reverse;
	T21 mmFiboInitialLots;
	T22 mmDalembertInitialLots;
	T23 mmDalembertReverse;
	T24 mmLabouchereInitialLots;
	T25 mmLabouchereList;
	T26 mmLabouchereReverse;
	T27 mmSeqBaseLots;
	T28 mmSeqOnLoss;
	T29 mmSeqOnProfit;
	T30 mmSeqReverse;
	T31 VolumeUpperLimit;
	T32 StopLossMode;
	T33 StopLossPips;
	T34 StopLossPercentPrice;
	T35 StopLossPercentTP;
	T36 dlStopLoss; virtual _T36_ _dlStopLoss_(){return(_T36_)0;}
	T37 dpStopLoss; virtual _T37_ _dpStopLoss_(){return(_T37_)0;}
	T38 ddStopLoss; virtual _T38_ _ddStopLoss_(){return(_T38_)0;}
	T39 TakeProfitMode;
	T40 TakeProfitPips;
	T41 TakeProfitPercentPrice;
	T42 TakeProfitPercentSL;
	T43 dlTakeProfit; virtual _T43_ _dlTakeProfit_(){return(_T43_)0;}
	T44 dpTakeProfit; virtual _T44_ _dpTakeProfit_(){return(_T44_)0;}
	T45 ddTakeProfit; virtual _T45_ _ddTakeProfit_(){return(_T45_)0;}
	T46 ExpMode;
	T47 ExpDays;
	T48 ExpHours;
	T49 ExpMinutes;
	T50 dExp; virtual _T50_ _dExp_(){return(_T50_)0;}
	T51 Slippage;
	T52 MyComment;
	T53 ArrowColorSell;
	virtual void _callback_(int r) {return;}

	public: /* Constructor */
	MDL_SellNow()
	{
		Group = (string)"";
		Symbol = (string)CurrentSymbol();
		VolumeMode = (string)"fixed";
		VolumeSize = (double)0.1;
		VolumeSizeRisk = (double)50.0;
		VolumeRisk = (double)2.5;
		VolumePercent = (double)100.0;
		VolumeBlockPercent = (double)3.0;
		FixedRatioUnitSize = (double)0.01;
		FixedRatioDelta = (double)20.0;
		mmMgInitialLots = (double)0.1;
		mmMgMultiplyOnLoss = (double)2.0;
		mmMgMultiplyOnProfit = (double)1.0;
		mmMgAddLotsOnLoss = (double)0.0;
		mmMgAddLotsOnProfit = (double)0.0;
		mmMgResetOnLoss = (int)0;
		mmMgResetOnProfit = (int)1;
		mm1326InitialLots = (double)0.1;
		mm1326Reverse = (bool)false;
		mmFiboInitialLots = (double)0.1;
		mmDalembertInitialLots = (double)0.1;
		mmDalembertReverse = (bool)false;
		mmLabouchereInitialLots = (double)0.1;
		mmLabouchereList = (string)"1,2,3,4,5,6";
		mmLabouchereReverse = (bool)false;
		mmSeqBaseLots = (double)0.1;
		mmSeqOnLoss = (string)"3,2,6";
		mmSeqOnProfit = (string)"1";
		mmSeqReverse = (bool)false;
		VolumeUpperLimit = (double)0.0;
		StopLossMode = (string)"fixed";
		StopLossPips = (double)50.0;
		StopLossPercentPrice = (double)0.55;
		StopLossPercentTP = (double)100.0;
		TakeProfitMode = (string)"fixed";
		TakeProfitPips = (double)50.0;
		TakeProfitPercentPrice = (double)0.55;
		TakeProfitPercentSL = (double)100.0;
		ExpMode = (string)"GTC";
		ExpDays = (int)0;
		ExpHours = (int)1;
		ExpMinutes = (int)0;
		Slippage = (ulong)4;
		MyComment = (string)"";
		ArrowColorSell = (color)clrRed;
	}

	public: /* The main method */
	virtual void _execute_()
	{
		//-- stops ------------------------------------------------------------------
		double sll = 0, slp = 0, tpl = 0, tpp = 0;
		
		     if (StopLossMode == "fixed")         {slp = StopLossPips;}
		else if (StopLossMode == "dynamicPips")   {slp = _dpStopLoss_();}
		else if (StopLossMode == "dynamicDigits") {slp = toPips(_ddStopLoss_(),Symbol);}
		else if (StopLossMode == "dynamicLevel")  {sll = _dlStopLoss_();}
		else if (StopLossMode == "percentPrice")  {sll = SymbolBid(Symbol) + (SymbolBid(Symbol) * StopLossPercentPrice / 100);}
		
		     if (TakeProfitMode == "fixed")         {tpp = TakeProfitPips;}
		else if (TakeProfitMode == "dynamicPips")   {tpp = _dpTakeProfit_();}
		else if (TakeProfitMode == "dynamicDigits") {tpp = toPips(_ddTakeProfit_(),Symbol);}
		else if (TakeProfitMode == "dynamicLevel")  {tpl = _dlTakeProfit_();}
		else if (TakeProfitMode == "percentPrice")  {tpl = SymbolBid(Symbol) - (SymbolBid(Symbol) * TakeProfitPercentPrice / 100);}
		
		if (StopLossMode == "percentTP") {
		   if (tpp > 0) {slp = tpp*StopLossPercentTP/100;}
		   if (tpl > 0) {slp = toPips(MathAbs(SymbolBid(Symbol) - tpl), Symbol)*StopLossPercentTP/100;}
		}
		if (TakeProfitMode == "percentSL") {
		   if (slp > 0) {tpp = slp*TakeProfitPercentSL/100;}
		   if (sll > 0) {tpp = toPips(MathAbs(SymbolBid(Symbol) - sll), Symbol)*TakeProfitPercentSL/100;}
		}
		
		//-- lots -------------------------------------------------------------------
		double lots = 0;
		double pre_sll = sll;
		
		if (pre_sll == 0) {
			pre_sll = SymbolBid(Symbol);
		}
		
		double pre_sl_pips = toPips((pre_sll+toDigits(slp,Symbol))-SymbolBid(Symbol), Symbol);
		
		     if (VolumeMode == "fixed")            {lots = DynamicLots(Symbol, VolumeMode, VolumeSize);}
		else if (VolumeMode == "block-equity")     {lots = DynamicLots(Symbol, VolumeMode, VolumeBlockPercent);}
		else if (VolumeMode == "block-balance")    {lots = DynamicLots(Symbol, VolumeMode, VolumeBlockPercent);}
		else if (VolumeMode == "block-freemargin") {lots = DynamicLots(Symbol, VolumeMode, VolumeBlockPercent);}
		else if (VolumeMode == "equity")           {lots = DynamicLots(Symbol, VolumeMode, VolumePercent);}
		else if (VolumeMode == "balance")          {lots = DynamicLots(Symbol, VolumeMode, VolumePercent);}
		else if (VolumeMode == "freemargin")       {lots = DynamicLots(Symbol, VolumeMode, VolumePercent);}
		else if (VolumeMode == "equityRisk")       {lots = DynamicLots(Symbol, VolumeMode, VolumeRisk, pre_sl_pips);}
		else if (VolumeMode == "balanceRisk")      {lots = DynamicLots(Symbol, VolumeMode, VolumeRisk, pre_sl_pips);}
		else if (VolumeMode == "freemarginRisk")   {lots = DynamicLots(Symbol, VolumeMode, VolumeRisk, pre_sl_pips);}
		else if (VolumeMode == "fixedRisk")        {lots = DynamicLots(Symbol, VolumeMode, VolumeSizeRisk, pre_sl_pips);}
		else if (VolumeMode == "fixedRatio")       {lots = DynamicLots(Symbol, VolumeMode, FixedRatioUnitSize, FixedRatioDelta);}
		else if (VolumeMode == "dynamic")          {lots = _dVolumeSize_();}
		else if (VolumeMode == "1326")             {lots = Bet1326((int)Group, Symbol, mm1326InitialLots, mm1326Reverse);}
		else if (VolumeMode == "fibonacci")        {lots = BetFibonacci((int)Group, Symbol, mmFiboInitialLots);}
		else if (VolumeMode == "dalembert")        {lots = BetDalembert((int)Group, Symbol, mmDalembertInitialLots, mmDalembertReverse);}
		else if (VolumeMode == "labouchere")       {lots = BetLabouchere((int)Group, Symbol, mmLabouchereInitialLots, mmLabouchereList, mmLabouchereReverse);}
		else if (VolumeMode == "martingale")       {lots = BetMartingale((int)Group, Symbol, mmMgInitialLots, mmMgMultiplyOnLoss, mmMgMultiplyOnProfit, mmMgAddLotsOnLoss, mmMgAddLotsOnProfit, mmMgResetOnLoss, mmMgResetOnProfit);}
		else if (VolumeMode == "sequence")         {lots = BetSequence((int)Group, Symbol, mmSeqBaseLots, mmSeqOnLoss, mmSeqOnProfit, mmSeqReverse);}
		
		lots = AlignLots(Symbol, lots, 0, VolumeUpperLimit);
		
		datetime exp = ExpirationTime(ExpMode,ExpDays,ExpHours,ExpMinutes,_dExp_());
		
		//-- send -------------------------------------------------------------------
		long ticket = SellNow(Symbol, lots, sll, tpl, slp, tpp, Slippage, (MagicStart+(int)Group), MyComment, ArrowColorSell, exp);
		
		if (ticket > 0) {_callback_(1);} else {_callback_(0);}
	}
};

// "Condition" model
template<typename T1,typename _T1_,typename T2,typename T3,typename _T3_,typename T4>
class MDL_Condition: public BlockCalls
{
	public: /* Input Parameters */
	T1 Lo; virtual _T1_ _Lo_(){return(_T1_)0;}
	T2 compare;
	T3 Ro; virtual _T3_ _Ro_(){return(_T3_)0;}
	T4 crosswidth;
	virtual void _callback_(int r) {return;}

	public: /* Constructor */
	MDL_Condition()
	{
		compare = (string)">";
		crosswidth = (int)1;
	}

	public: /* The main method */
	virtual void _execute_()
	{
		bool output1 = false, output2 = false; // output 1 and output 2
		int crossover = 0;
		
		if (compare == "x>" || compare == "x<") {crossover = 1;}
		
		for (int i = 0; i <= crossover; i++)
		{
			// i=0 - normal pass, i=1 - crossover pass
		
			// Left operand of the condition
			FXD_MORE_SHIFT = i * crosswidth;
			_T1_ lo = _Lo_();
			if (MathAbs(lo) == EMPTY_VALUE) {return;}
		
			// Right operand of the condition
			FXD_MORE_SHIFT = i * crosswidth;
			_T3_ ro = _Ro_();
			if (MathAbs(ro) == EMPTY_VALUE) {return;}
		
			// Conditions
			if (compare(compare, lo, ro))
			{
				if (i == 0)
				{
					output1 = true;
				}
			}
			else
			{
				if (i == 0)
				{
					output2 = true;
				}
				else
				{
					output2 = false;
				}
			}
		
			if (crossover == 1)
			{
				if (compare(compare, ro, lo))
				{
					if (i == 0)
					{
						output2 = true;
					}
				}
				else
				{
					if (i == 1)
					{
						output1 = false;
					}
				}
			}
		}
		
		FXD_MORE_SHIFT = 0; // reset
		
			  if (output1 == true) {_callback_(1);}
		else if (output2 == true) {_callback_(0);}
	}
};


//------------------------------------------------------------------------------------------------------------------------

// "Candle" model
class MDLIC_candles_candles
{
	public: /* Input Parameters */
	string iOHLC;
	string ModeCandleFindBy;
	int CandleID;
	string TimeStamp;
	string Symbol;
	ENUM_TIMEFRAMES Period;
	/* Static Parameters */
	int digits;
	double O[];
	double H[];
	double L[];
	double C[];
	long cTickVolume[];
	long cRealVolume[];
	datetime T[];
	virtual void _callback_(int r) {return;}

	public: /* Constructor */
	MDLIC_candles_candles()
	{
		iOHLC = (string)"iClose";
		ModeCandleFindBy = (string)"id";
		CandleID = (int)0;
		TimeStamp = (string)"00:00";
		Symbol = (string)CurrentSymbol();
		Period = (ENUM_TIMEFRAMES)CurrentTimeframe();
		/* Static Parameters (initial value) */
		digits =  (int)SymbolInfoInteger(Symbol, SYMBOL_DIGITS);
	}

	public: /* The main method */
	double _execute_()
	{
		double retval = EMPTY_VALUE;
		
		// candle's id will change, so we don't want to mess with the variable CandleID;
		int cID = CandleID;
		
		if (ModeCandleFindBy == "time")
		{
			cID = iCandleID(Symbol, Period, StringToTimeEx(TimeStamp, "server"));
		}
		
		cID = cID + FXD_MORE_SHIFT;
		
		//-- the common levels ----------------------------------------------------
		if (iOHLC == "iOpen")
		{
			if (CopyOpen(Symbol,Period,cID,1,O) > -1) retval = O[0];
		}
		else if (iOHLC == "iHigh")
		{
			if (CopyHigh(Symbol,Period,cID,1,H) > -1) retval = H[0];
		}
		else if (iOHLC == "iLow")
		{
			if (CopyLow(Symbol,Period,cID,1,L) > -1) retval = L[0];
		}
		else if (iOHLC == "iClose")
		{
			if (CopyClose(Symbol,Period,cID,1,C) > -1) retval = C[0];
		}
		
		//-- non-price values  ----------------------------------------------------
		else if (iOHLC == "iVolume" || iOHLC == "iTickVolume")
		{
			if (CopyTickVolume(Symbol,Period,cID,1,cTickVolume) > -1) retval = (double)cTickVolume[0];
			
			return retval;
		}
		else if (iOHLC == "iRealVolume")
		{
			if (CopyRealVolume(Symbol,Period,cID,1,cRealVolume) > -1) retval = (double)cRealVolume[0];
			
			return retval;
		}
		else if (iOHLC == "iTime")
		{
			if (CopyTime(Symbol,Period,cID,1,T) > -1) retval = (double)T[0];
			
			return retval;
		}
		
		//-- simple calculations --------------------------------------------------
		else if (iOHLC == "iMedian")
		{
			if (
				   CopyLow(Symbol,Period,cID,1,L) > -1
				&& CopyHigh(Symbol,Period,cID,1,H) > -1
			)
			{
				retval = ((L[0]+H[0])/2);
			}
		}
		else if (iOHLC == "iTypical")
		{
			if (
				   CopyLow(Symbol,Period,cID,1,L) > -1
				&& CopyHigh(Symbol,Period,cID,1,H) > -1
				&& CopyClose(Symbol,Period,cID,1,C) > -1
			)
			{
				retval = ((L[0]+H[0]+C[0])/3);
			}
		}
		else if (iOHLC == "iAverage")
		{
			if (
				   CopyLow(Symbol,Period,cID,1,L) > -1
				&& CopyHigh(Symbol,Period,cID,1,H) > -1
				&& CopyClose(Symbol,Period,cID,1,C) > -1
			)
			{
				retval = ((L[0]+H[0]+C[0]+C[0])/4);
			}
		}
		
		//-- more complex levels --------------------------------------------------
		else if (iOHLC=="iTotal")
		{
			if (
				   CopyHigh(Symbol,Period,cID,1,H) > -1
				&& CopyLow(Symbol,Period,cID,1,L) > -1
			)
			{
				retval = toPips(MathAbs(H[0]-L[0]),Symbol);
			}
		}
		else if (iOHLC == "iBody")
		{
			if (
				   CopyOpen(Symbol,Period,cID,1,O) > -1
				&& CopyClose(Symbol,Period,cID,1,C) > -1
			)
			{
				retval = toPips(MathAbs(C[0]-O[0]),Symbol);
			}
		}
		else if (iOHLC == "iUpperWick")
		{
			if (
				   CopyHigh(Symbol,Period,cID,1,H) > -1
				&& CopyOpen(Symbol,Period,cID,1,O) > -1
				&& CopyClose(Symbol,Period,cID,1,C) > -1
				&& CopyLow(Symbol,Period,cID,1,L) > -1
			)
			{
				retval = (C[0] > O[0]) ? toPips(MathAbs(H[0]-C[0]),Symbol) : toPips(MathAbs(H[0]-O[0]),Symbol);
			}
		}
		else if (iOHLC == "iBottomWick")
		{
			if (
				   CopyHigh(Symbol,Period,cID,1,H) > -1
				&& CopyOpen(Symbol,Period,cID,1,O) > -1
				&& CopyClose(Symbol,Period,cID,1,C) > -1
				&& CopyLow(Symbol,Period,cID,1,L) > -1
			)
			{
				retval = (C[0] > O[0]) ? toPips(MathAbs(O[0]-L[0]),Symbol) : toPips(MathAbs(C[0]-L[0]),Symbol);
			}
		}
		else if (iOHLC == "iGap")
		{
			if (
				   CopyOpen(Symbol,Period,cID,1,O) > -1
				&& CopyClose(Symbol,Period,cID+1,1,C) > -1
			)
			{
				retval = toPips(MathAbs(O[0]-C[0]),Symbol);
			}
		}
		else if (iOHLC == "iBullTotal")
		{
			if (
				   CopyOpen(Symbol,Period,cID,1,O) > -1
				&& CopyClose(Symbol,Period,cID,1,C) > -1
				&& CopyHigh(Symbol,Period,cID,1,H) > -1
				&& CopyLow(Symbol,Period,cID,1,L) > -1
				&& C[0] > O[0]
			)
			{
				retval = toPips((H[0]-L[0]),Symbol);
			}
		}
		else if (iOHLC == "iBullBody")
		{
			if (
				   CopyOpen(Symbol,Period,cID,1,O) > -1
				&& CopyClose(Symbol,Period,cID,1,C) > -1
				&& C[0] > O[0]
			)
			{
				retval = toPips((C[0]-O[0]),Symbol);
			}
		}
		else if (iOHLC == "iBullUpperWick")
		{
			if (
				   CopyHigh(Symbol,Period,cID,1,H) > -1
				&& CopyOpen(Symbol,Period,cID,1,O) > -1
				&& CopyClose(Symbol,Period,cID,1,C) > -1
				&& C[0] > O[0]
			)
			{
				retval = toPips((H[0]-C[0]),Symbol);
			}
		}
		else if (iOHLC == "iBullBottomWick")
		{
			if (
				   CopyLow(Symbol,Period,cID,1,L) > -1
				&& CopyOpen(Symbol,Period,cID,1,O) > -1
				&& CopyClose(Symbol,Period,cID,1,C) > -1
				&& C[0] > O[0]
			)
			{
				retval = toPips((O[0]-L[0]),Symbol);
			}
		}
		else if (iOHLC == "iBearTotal")
		{
			if (
				   CopyOpen(Symbol,Period,cID,1,O) > -1
				&& CopyClose(Symbol,Period,cID,1,C) > -1
				&& CopyHigh(Symbol,Period,cID,1,H) > -1
				&& CopyLow(Symbol,Period,cID,1,L) > -1
				&& C[0] < O[0]
			)
			{
				retval = toPips((H[0]-L[0]),Symbol);
			}
		}
		else if (iOHLC == "iBearBody")
		{
			if (
				   CopyOpen(Symbol,Period,cID,1,O) > -1
				&& CopyClose(Symbol,Period,cID,1,C) > -1
				&& C[0] < O[0]
			)
			{
				retval = toPips((O[0]-C[0]),Symbol);
			}
		}
		else if (iOHLC == "iBearUpperWick")
		{
			if (
				   CopyHigh(Symbol,Period,cID,1,H) > -1
				&& CopyOpen(Symbol,Period,cID,1,O) > -1
				&& CopyClose(Symbol,Period,cID,1,C) > -1
				&& C[0] < O[0]
			)
			{
				retval = toPips((H[0]-O[0]),Symbol);
			}
		}
		else if (iOHLC == "iBearBottomWick")
		{
			if (
				   CopyLow(Symbol,Period,cID,1,L) > -1
				&& CopyOpen(Symbol,Period,cID,1,O) > -1
				&& CopyClose(Symbol,Period,cID,1,C) > -1
				&& C[0] < O[0]
			)
			{
				retval = toPips((C[0]-L[0]),Symbol);
			}
		}
		
		return NormalizeDouble(retval, digits);
	}
};

// "Numeric" model
class MDLIC_value_value
{
	public: /* Input Parameters */
	double Value;
	virtual void _callback_(int r) {return;}

	public: /* Constructor */
	MDLIC_value_value()
	{
		Value = (double)1.0;
	}

	public: /* The main method */
	double _execute_()
	{
		return Value;
	}
};

// "Time" model
class MDLIC_value_time
{
	public: /* Input Parameters */
	int ModeTime;
	int TimeSource;
	string TimeStamp;
	int TimeCandleID;
	string TimeMarket;
	ENUM_TIMEFRAMES TimeCandleTimeframe;
	int TimeComponentYear;
	int TimeComponentMonth;
	double TimeComponentDay;
	double TimeComponentHour;
	double TimeComponentMinute;
	int TimeComponentSecond;
	int ModeTimeShift;
	int TimeShiftYears;
	int TimeShiftMonths;
	int TimeShiftWeeks;
	double TimeShiftDays;
	double TimeShiftHours;
	double TimeShiftMinutes;
	int TimeShiftSeconds;
	bool TimeSkipWeekdays;
	/* Static Parameters */
	datetime retval;
	datetime retval0;
	int ModeTime0;
	int smodeshift;
	int years0;
	int months0;
	datetime Time[];
	virtual void _callback_(int r) {return;}

	public: /* Constructor */
	MDLIC_value_time()
	{
		ModeTime = (int)0;
		TimeSource = (int)0;
		TimeStamp = (string)"00:00";
		TimeCandleID = (int)1;
		TimeMarket = (string)"";
		TimeCandleTimeframe = (ENUM_TIMEFRAMES)0;
		TimeComponentYear = (int)0;
		TimeComponentMonth = (int)0;
		TimeComponentDay = (double)0.0;
		TimeComponentHour = (double)12.0;
		TimeComponentMinute = (double)0.0;
		TimeComponentSecond = (int)0;
		ModeTimeShift = (int)0;
		TimeShiftYears = (int)0;
		TimeShiftMonths = (int)0;
		TimeShiftWeeks = (int)0;
		TimeShiftDays = (double)0.0;
		TimeShiftHours = (double)0.0;
		TimeShiftMinutes = (double)0.0;
		TimeShiftSeconds = (int)0;
		TimeSkipWeekdays = (bool)false;
		/* Static Parameters (initial value) */
		retval =  0;
		retval0 =  0;
		ModeTime0 =  0;
		smodeshift =  0;
		years0 =  0;
		months0 =  0;
	}

	public: /* The main method */
	datetime _execute_()
	{
		// this is static for speed reasons
		
		if (TimeMarket == "") TimeMarket = Symbol();
		
		if (ModeTime == 0)
		{
			     if (TimeSource == 0) {retval = TimeCurrent();}
			else if (TimeSource == 1) {retval = TimeLocal();}
			else if (TimeSource == 2) {retval = TimeGMT();}
		}
		else if (ModeTime == 1)
		{
			retval  = StringToTime(TimeStamp);
			retval0 = retval;
		}
		else if (ModeTime==2)
		{
			retval = TimeFromComponents(TimeSource, TimeComponentYear, TimeComponentMonth, TimeComponentDay, TimeComponentHour, TimeComponentMinute, TimeComponentSecond);
		}
		else if (ModeTime == 3)
		{
			ArraySetAsSeries(Time,true);
			CopyTime(TimeMarket,TimeCandleTimeframe,TimeCandleID,1,Time);
			retval = Time[0];
		}
		
		if (ModeTimeShift > 0)
		{
			int sh = 1;
		
			if (ModeTimeShift == 1) {sh = -1;}
		
			if (
				   ModeTimeShift != smodeshift
				|| TimeShiftYears != years0
				|| TimeShiftMonths != months0
			)
			{
				years0  = TimeShiftYears;
				months0 = TimeShiftMonths;
		
				if (TimeShiftYears > 0 || TimeShiftMonths > 0)
				{
					int year = 0, month = 0, week = 0, day = 0, hour = 0, minute = 0, second = 0;
		
					if (ModeTime == 3)
					{
						year   = TimeComponentYear;
						month  = TimeComponentYear;
						day    = (int)MathFloor(TimeComponentDay);
						hour   = (int)(MathFloor(TimeComponentHour) + (24 * (TimeComponentDay - MathFloor(TimeComponentDay))));
						minute = (int)(MathFloor(TimeComponentMinute) + (60 * (TimeComponentHour - MathFloor(TimeComponentHour))));
						second = (int)(TimeComponentSecond + (60 * (TimeComponentMinute - MathFloor(TimeComponentMinute))));
					}
					else {
						year   = TimeYear(retval);
						month  = TimeMonth(retval);
						day    = TimeDay(retval);
						hour   = TimeHour(retval);
						minute = TimeMinute(retval);
						second = TimeSeconds(retval);
					}
		
					year  = year + TimeShiftYears * sh;
					month = month + TimeShiftMonths * sh;
		
					     if (month < 0) {month = 12 - month;}
					else if (month > 12) {month = month - 12;}
		
					retval = StringToTime(IntegerToString(year)+"."+IntegerToString(month)+"."+IntegerToString(day)+" "+IntegerToString(hour)+":"+IntegerToString(minute)+":"+IntegerToString(second));
				}
			}
		
			retval = retval + (sh * ((604800 * TimeShiftWeeks) + SecondsFromComponents(TimeShiftDays, TimeShiftHours, TimeShiftMinutes, TimeShiftSeconds)));
		
			if (TimeSkipWeekdays == true)
			{
				int weekday = TimeDayOfWeek(retval);
		
				if (sh > 0) { // forward
					     if (weekday == 0) {retval = retval + 86400;}
					else if (weekday == 6) {retval = retval + 172800;}
				}
				else if (sh < 0) { // back
					     if (weekday == 0) {retval = retval - 172800;}
					else if (weekday == 6) {retval = retval - 86400;}
				}
			}
		}
		
		smodeshift = ModeTimeShift;
		ModeTime0  = ModeTime;
		
		return (datetime)retval;
	}
};

// "Stochastic Oscillator" model
class MDLIC_indicators_iStochastic
{
	public: /* Input Parameters */
	int Kperiod;
	int Dperiod;
	int Slowing;
	ENUM_MA_METHOD MAmethod;
	ENUM_STO_PRICE PriceField;
	int Mode;
	string Symbol;
	ENUM_TIMEFRAMES Period;
	int Shift;
	virtual void _callback_(int r) {return;}

	public: /* Constructor */
	MDLIC_indicators_iStochastic()
	{
		Kperiod = (int)5;
		Dperiod = (int)3;
		Slowing = (int)3;
		MAmethod = (ENUM_MA_METHOD)MODE_SMA;
		PriceField = (ENUM_STO_PRICE)STO_LOWHIGH;
		Mode = (int)0;
		Symbol = (string)CurrentSymbol();
		Period = (ENUM_TIMEFRAMES)CurrentTimeframe();
		Shift = (int)0;
	}

	public: /* The main method */
	double _execute_()
	{
		return iStochastic(Symbol, Period, Kperiod, Dperiod, Slowing, MAmethod, PriceField, Mode, Shift + FXD_MORE_SHIFT);
	}
};

// "Average True Range" model
class MDLIC_indicators_iATR
{
	public: /* Input Parameters */
	int ATRperiod;
	string Symbol;
	ENUM_TIMEFRAMES Period;
	int Shift;
	virtual void _callback_(int r) {return;}

	public: /* Constructor */
	MDLIC_indicators_iATR()
	{
		ATRperiod = (int)14;
		Symbol = (string)CurrentSymbol();
		Period = (ENUM_TIMEFRAMES)CurrentTimeframe();
		Shift = (int)0;
	}

	public: /* The main method */
	double _execute_()
	{
		return iATR(Symbol, Period, ATRperiod, Shift + FXD_MORE_SHIFT);
	}
};


//------------------------------------------------------------------------------------------------------------------------

// Block 137 (No trade)
class Block0: public MDL_NoOpenedOrders<string,string,string,string,string>
{

	public: /* Constructor */
	Block0() {
		__block_number = 0;
		__block_user_number = "137";
		_beforeExecuteEnabled = true;

		// Fill the list of outbound blocks
		int ___outbound_blocks[1] = {10};
		ArrayCopy(__outbound_blocks, ___outbound_blocks);
	}

	public: /* Callback & Run */
	virtual void _callback_(int value) {
		if (value == 1) {
			_blocks_[10].run(0);
		}
	}

	virtual void _beforeExecute_()
	{
		Symbol = (string)CurrentSymbol();
	}
};

// Block 138 (Sell pending orders in grid)
class Block1: public MDL_GridPendingSells2<string,string,int,string,MDLIC_candles_candles,double,double,double,double,string,double,double,double,double,double,MDLIC_value_value,double,double,double,double,string,double,double,MDLIC_value_value,double,MDLIC_value_value,double,MDLIC_value_value,double,string,double,double,MDLIC_value_value,double,MDLIC_value_value,double,MDLIC_value_value,double,double,double,double,double,string,int,int,int,MDLIC_value_time,datetime,ulong,string,color>
{

	public: /* Constructor */
	Block1() {
		__block_number = 1;
		__block_user_number = "138";
		_beforeExecuteEnabled = true;

		// IC input parameters
		fGridStart.iOHLC = "iOpen";
		fGridStart.TimeStamp = "";
		dVolumeSize.Value = 0.1;
		dpStopLoss.Value = 100.0;
		ddStopLoss.Value = 0.01;
		dpTakeProfit.Value = 100.0;
		ddTakeProfit.Value = 0.01;
		dExp.ModeTimeShift = 2;
		dExp.TimeShiftDays = 1.0;
		dExp.TimeSkipWeekdays = true;
		// Block input parameters
		VolumeMode = "equity";
		gSLmode = "none";
		ExpHours = 0;
	}

	public: /* Custom methods */
	virtual double _fGridStart_() {
		fGridStart.Symbol = CurrentSymbol();
		fGridStart.Period = CurrentTimeframe();

		return fGridStart._execute_();
	}
	virtual double _dVolumeSize_() {return dVolumeSize._execute_();}
	virtual double _dlStopLoss_() {return dlStopLoss._execute_();}
	virtual double _dpStopLoss_() {return dpStopLoss._execute_();}
	virtual double _ddStopLoss_() {return ddStopLoss._execute_();}
	virtual double _dlTakeProfit_() {return dlTakeProfit._execute_();}
	virtual double _dpTakeProfit_() {return dpTakeProfit._execute_();}
	virtual double _ddTakeProfit_() {return ddTakeProfit._execute_();}
	virtual datetime _dExp_() {return dExp._execute_();}

	public: /* Callback & Run */
	virtual void _callback_(int value) {
	}

	virtual void _beforeExecute_()
	{
		Symbol = (string)CurrentSymbol();
		GridOrdersCount = (int)_externs::inp138_GridOrdersCount;
		GridStartOffset = (double)_externs::inp138_GridStartOffset;
		GridSize = (double)_externs::inp138_GridSize;
		VolumePercent = (double)_externs::inp138_VolumePercent;
		FixedRatioUnitSize = (double)_externs::inp138_FixedRatioUnitSize;
		TakeProfitPips = (double)_externs::inp138_TakeProfitPips;
		ExpMinutes = (int)_externs::inp138_ExpMinutes;
		ArrowColorSell = (color)clrRed;
	}
};

// Block 141 (Check profit (average))
class Block2: public MDL_CheckAvgProfitFromNtrades<string,string,string,string,string,string,double,double,int,int,int,string,string,double,double>
{

	public: /* Constructor */
	Block2() {
		__block_number = 2;
		__block_user_number = "141";
		_beforeExecuteEnabled = true;

		// Fill the list of outbound blocks
		int ___outbound_blocks[1] = {3};
		ArrayCopy(__outbound_blocks, ___outbound_blocks);
	}

	public: /* Callback & Run */
	virtual void _callback_(int value) {
		if (value == 1) {
			_blocks_[3].run(2);
		}
	}

	virtual void _beforeExecute_()
	{
		Symbol = (string)CurrentSymbol();
		ProfitAmountPips = (double)_externs::inp141_ProfitAmountPips;
	}
};

// Block 142 (Close trades)
class Block3: public MDL_CloseOpened<string,string,string,string,string,int,ulong,color>
{

	public: /* Constructor */
	Block3() {
		__block_number = 3;
		__block_user_number = "142";
		_beforeExecuteEnabled = true;

		// Fill the list of outbound blocks
		int ___outbound_blocks[1] = {5};
		ArrayCopy(__outbound_blocks, ___outbound_blocks);
	}

	public: /* Callback & Run */
	virtual void _callback_(int value) {
		if (value == 1) {
			_blocks_[5].run(3);
		}
	}

	virtual void _beforeExecute_()
	{
		Symbol = (string)CurrentSymbol();
		ArrowColor = (color)clrDeepPink;
	}
};

// Block 143 (Check trades count)
class Block4: public MDL_CheckTradesCount<string,int,string,string,string,string,string>
{

	public: /* Constructor */
	Block4() {
		__block_number = 4;
		__block_user_number = "143";
		_beforeExecuteEnabled = true;

		// Fill the list of outbound blocks
		int ___outbound_blocks[1] = {2};
		ArrayCopy(__outbound_blocks, ___outbound_blocks);
		// Block input parameters
		Compare = ">=";
		CompareCount = 1;
	}

	public: /* Callback & Run */
	virtual void _callback_(int value) {
		if (value == 1) {
			_blocks_[2].run(4);
		}
	}

	virtual void _beforeExecute_()
	{
		Symbol = (string)CurrentSymbol();
	}
};

// Block 144 (Delete pending orders)
class Block5: public MDL_DeletePendingOrders<string,string,string,string,string,string,color>
{

	public: /* Constructor */
	Block5() {
		__block_number = 5;
		__block_user_number = "144";
		_beforeExecuteEnabled = true;
	}

	public: /* Callback & Run */
	virtual void _callback_(int value) {
	}

	virtual void _beforeExecute_()
	{
		Symbol = (string)CurrentSymbol();
		ArrowColor = (color)clrDeepPink;
	}
};

// Block 145 (Sell now)
class Block6: public MDL_SellNow<string,string,string,double,double,double,double,double,MDLIC_value_value,double,double,double,double,double,double,double,double,int,int,double,bool,double,double,bool,double,string,bool,double,string,string,bool,double,string,double,double,double,MDLIC_value_value,double,MDLIC_value_value,double,MDLIC_value_value,double,string,double,double,double,MDLIC_value_value,double,MDLIC_value_value,double,MDLIC_value_value,double,string,int,int,int,MDLIC_value_time,datetime,ulong,string,color>
{

	public: /* Constructor */
	Block6() {
		__block_number = 6;
		__block_user_number = "145";
		_beforeExecuteEnabled = true;

		// Fill the list of outbound blocks
		int ___outbound_blocks[1] = {1};
		ArrayCopy(__outbound_blocks, ___outbound_blocks);

		// IC input parameters
		dVolumeSize.Value = 0.1;
		dpStopLoss.Value = 100.0;
		ddStopLoss.Value = 0.01;
		dpTakeProfit.Value = 100.0;
		ddTakeProfit.Value = 0.01;
		dExp.ModeTimeShift = 2;
		dExp.TimeShiftDays = 1.0;
		dExp.TimeSkipWeekdays = true;
		// Block input parameters
		VolumeMode = "freemargin";
		StopLossMode = "none";
	}

	public: /* Custom methods */
	virtual double _dVolumeSize_() {return dVolumeSize._execute_();}
	virtual double _dlStopLoss_() {return dlStopLoss._execute_();}
	virtual double _dpStopLoss_() {return dpStopLoss._execute_();}
	virtual double _ddStopLoss_() {return ddStopLoss._execute_();}
	virtual double _dlTakeProfit_() {return dlTakeProfit._execute_();}
	virtual double _dpTakeProfit_() {return dpTakeProfit._execute_();}
	virtual double _ddTakeProfit_() {return ddTakeProfit._execute_();}
	virtual datetime _dExp_() {return dExp._execute_();}

	public: /* Callback & Run */
	virtual void _callback_(int value) {
		if (value == 1) {
			_blocks_[1].run(6);
		}
	}

	virtual void _beforeExecute_()
	{
		Symbol = (string)CurrentSymbol();
		VolumePercent = (double)_externs::inp145_VolumePercent;
		TakeProfitPips = (double)_externs::inp145_TakeProfitPips;
		ArrowColorSell = (color)clrRed;
	}
};

// Block 147 (Condition)
class Block7: public MDL_Condition<MDLIC_indicators_iStochastic,double,string,MDLIC_value_value,double,int>
{

	public: /* Constructor */
	Block7() {
		__block_number = 7;
		__block_user_number = "147";


		// Fill the list of outbound blocks
		int ___outbound_blocks[1] = {8};
		ArrayCopy(__outbound_blocks, ___outbound_blocks);

		// IC input parameters
		Lo.Kperiod = 100;
		Lo.Dperiod = 1;
		Ro.Value = 20.0;
		// Block input parameters
		compare = "x<";
	}

	public: /* Custom methods */
	virtual double _Lo_() {
		Lo.MAmethod = MODE_SMA;
		Lo.PriceField = STO_LOWHIGH;
		Lo.Symbol = CurrentSymbol();
		Lo.Period = CurrentTimeframe();

		return Lo._execute_();
	}
	virtual double _Ro_() {return Ro._execute_();}

	public: /* Callback & Run */
	virtual void _callback_(int value) {
		if (value == 1) {
			_blocks_[8].run(7);
		}
	}
};

// Block 149 (Condition)
class Block8: public MDL_Condition<MDLIC_indicators_iStochastic,double,string,MDLIC_value_value,double,int>
{

	public: /* Constructor */
	Block8() {
		__block_number = 8;
		__block_user_number = "149";


		// Fill the list of outbound blocks
		int ___outbound_blocks[1] = {6};
		ArrayCopy(__outbound_blocks, ___outbound_blocks);

		// IC input parameters
		Ro.Value = 20.0;
		// Block input parameters
		compare = "x<";
	}

	public: /* Custom methods */
	virtual double _Lo_() {
		Lo.Kperiod = _externs::inp149_Lo_Kperiod;
		Lo.Dperiod = _externs::inp149_Lo_Dperiod;
		Lo.Slowing = _externs::inp149_Lo_Slowing;
		Lo.MAmethod = MODE_SMA;
		Lo.PriceField = STO_LOWHIGH;
		Lo.Symbol = CurrentSymbol();
		Lo.Period = CurrentTimeframe();

		return Lo._execute_();
	}
	virtual double _Ro_() {return Ro._execute_();}

	public: /* Callback & Run */
	virtual void _callback_(int value) {
		if (value == 1) {
			_blocks_[6].run(8);
		}
	}
};

// Block 153 (Condition)
class Block9: public MDL_Condition<MDLIC_indicators_iStochastic,double,string,MDLIC_value_value,double,int>
{

	public: /* Constructor */
	Block9() {
		__block_number = 9;
		__block_user_number = "153";


		// Fill the list of outbound blocks
		int ___outbound_blocks[1] = {7};
		ArrayCopy(__outbound_blocks, ___outbound_blocks);

		// IC input parameters
		Ro.Value = 40.0;
		// Block input parameters
		compare = "<";
	}

	public: /* Custom methods */
	virtual double _Lo_() {
		Lo.Kperiod = _externs::inp153_Lo_Kperiod;
		Lo.Dperiod = _externs::inp153_Lo_Dperiod;
		Lo.Slowing = _externs::inp153_Lo_Slowing;
		Lo.MAmethod = MODE_SMA;
		Lo.PriceField = STO_LOWHIGH;
		Lo.Symbol = CurrentSymbol();
		Lo.Period = CurrentTimeframe();

		return Lo._execute_();
	}
	virtual double _Ro_() {return Ro._execute_();}

	public: /* Callback & Run */
	virtual void _callback_(int value) {
		if (value == 1) {
			_blocks_[7].run(9);
		}
	}
};

// Block 161 (Condition)
class Block10: public MDL_Condition<MDLIC_indicators_iATR,double,string,MDLIC_value_value,double,int>
{

	public: /* Constructor */
	Block10() {
		__block_number = 10;
		__block_user_number = "161";


		// Fill the list of outbound blocks
		int ___outbound_blocks[1] = {9};
		ArrayCopy(__outbound_blocks, ___outbound_blocks);

		// IC input parameters
		Lo.ATRperiod = 35;
		Ro.Value = 0.00043;
		// Block input parameters
		compare = "<";
	}

	public: /* Custom methods */
	virtual double _Lo_() {
		Lo.Symbol = CurrentSymbol();
		Lo.Period = CurrentTimeframe();

		return Lo._execute_();
	}
	virtual double _Ro_() {return Ro._execute_();}

	public: /* Callback & Run */
	virtual void _callback_(int value) {
		if (value == 1) {
			_blocks_[9].run(10);
		}
	}
};


/************************************************************************************************************************/
// +------------------------------------------------------------------------------------------------------------------+ //
// |                                                   Functions                                                      | //
// |                                 System and Custom functions used in the program                                  | //
// +------------------------------------------------------------------------------------------------------------------+ //
/************************************************************************************************************************/


double AccountBalanceAtStart()
{
   // This function MUST be run once at pogram's start
	static double memory = 0;

	if (memory == 0) memory = NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE), 2);

	return memory;
}

double AlignLots(string symbol, double lots, double lowerlots=0, double upperlots=0)
{
	double LotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
	double LotSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
	double MinLots = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
	double MaxLots = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);

	if (LotStep > MinLots) MinLots = LotStep;

	if (lots == EMPTY_VALUE) {lots = 0;}

	lots = MathRound(lots/LotStep)*LotStep;

	if (lots < MinLots) {lots = MinLots;}
	if (lots > MaxLots) {lots = MaxLots;}

	if (lowerlots > 0)
	{
		lowerlots = MathRound(lowerlots/LotStep)*LotStep;
		if (lots < lowerlots) {lots = lowerlots;}
	}

	if (upperlots > 0)
	{
		upperlots = MathRound(upperlots/LotStep)*LotStep;
		if (lots > upperlots) {lots = upperlots;}
	}

	return lots;
}

double AlignStopLoss(
	string symbol,
	int type,
	double price,
	double slo = 0, // original sl, used when modifying
	double sll = 0,
	double slp = 0,
	bool consider_freezelevel = false
	)
{
	double sl = 0;

	if (MathAbs(sll) == EMPTY_VALUE) {sll = 0;}
	if (MathAbs(slp) == EMPTY_VALUE) {slp = 0;}

	if (sll == 0 && slp == 0)
	{
		return 0;
	}

	if (price <= 0)
	{
		Print("AlignStopLoss() error: No price entered");

		return(-1);
	}

	double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
	int digits   = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
	slp          = slp * PipValue(symbol) * point;

	//-- buy-sell identifier ---------------------------------------------
	int bs = 1;

	if (
		   type == OP_SELL
		|| type == OP_SELLSTOP
		|| type == OP_SELLLIMIT

		)
	{
		bs = -1;
	}

	//-- prices that will be used ----------------------------------------
	double askbid = price;
	double bidask = price;
	
	if (type < 2)
	{
		double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
		double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
		
		askbid = ask;
		bidask = bid;

		if (bs < 0)
		{
		  askbid = bid;
		  bidask = ask;
		}
	}

	//-- build sl level -------------------------------------------------- 
	if (sll == 0 && slp != 0) {sll = price;}

	if (sll > 0) {sl = sll - slp * bs;}

	if (sl < 0)
	{
		return -1;
	}

	sl  = NormalizeDouble(sl, digits);
	slo = NormalizeDouble(slo, digits);

	if (sl == slo)
	{
		return sl;
	}

	//-- build limit levels ----------------------------------------------
	double minstops = (double)SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);

	if (consider_freezelevel == true)
	{
		double freezelevel = (double)SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL);

		if (freezelevel > minstops) {minstops = freezelevel;}
	}

	minstops = NormalizeDouble(minstops * point,digits);

	double sllimit = bidask - minstops * bs; // SL min price level

	//-- check and align sl, print errors --------------------------------
	//-- do not do it when the stop is the same as the original
	if (sl > 0 && sl != slo)
	{
		if ((bs > 0 && sl > askbid) || (bs < 0 && sl < askbid))
		{
			string abstr = "";

			if (bs > 0) {abstr = "Bid";} else {abstr = "Ask";}

			Print(
				"Error: Invalid SL requested (",
				DoubleToStr(sl, digits),
				" for ", abstr, " price ",
				bidask,
				")"
			);

			return -1;
		}
		else if ((bs > 0 && sl > sllimit) || (bs < 0 && sl < sllimit))
		{
			if (USE_VIRTUAL_STOPS)
			{
				return sl;
			}

			Print(
				"Warning: Too short SL requested (",
				DoubleToStr(sl, digits),
				" or ",
				DoubleToStr(MathAbs(sl - askbid) / point, 0),
				" points), minimum will be taken (",
				DoubleToStr(sllimit, digits),
				" or ",
				DoubleToStr(MathAbs(askbid - sllimit) / point, 0),
				" points)"
			);

			sl = sllimit;

			return sl;
		}
	}

	// align by the ticksize
	double ticksize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
	sl = MathRound(sl / ticksize) * ticksize;

	return sl;
}

double AlignTakeProfit(
	string symbol,
	int type,
	double price,
	double tpo = 0, // original tp, used when modifying
	double tpl = 0,
	double tpp = 0,
	bool consider_freezelevel = false
	)
{
	double tp=0;
	
	if (MathAbs(tpl) == EMPTY_VALUE) {tpl = 0;}
	if (MathAbs(tpp) == EMPTY_VALUE) {tpp = 0;}

	if (tpl == 0 && tpp == 0)
	{
		return 0;
	}

	if (price <= 0)
	{
		Print("AlignTakeProfit() error: No price entered");

		return -1;
	}

	double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
	int digits   = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
	tpp          = tpp * PipValue(symbol) * point;
	
	//-- buy-sell identifier ---------------------------------------------
	int bs = 1;

	if (
		   type == OP_SELL
		|| type == OP_SELLSTOP
		|| type == OP_SELLLIMIT

		)
	{
		bs = -1;
	}
	
	//-- prices that will be used ----------------------------------------
	double askbid = price;
	double bidask = price;
	
	if (type < 2)
	{
		double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
		double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
		
		askbid = ask;
		bidask = bid;

		if (bs < 0)
		{
		  askbid = bid;
		  bidask = ask;
		}
	}
	
	//-- build tp level --------------------------------------------------- 
	if (tpl == 0 && tpp != 0) {tpl = price;}

	if (tpl > 0) {tp = tpl + tpp * bs;}
	
	if (tp < 0)
	{
		return -1;
	}

	tp  = NormalizeDouble(tp, digits);
	tpo = NormalizeDouble(tpo, digits);

	if (tp == tpo)
	{
		return tp;
	}
	
	//-- build limit levels ----------------------------------------------
	double minstops = (double)SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);

	if (consider_freezelevel == true)
	{
		double freezelevel = (double)SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL);

		if (freezelevel > minstops) {minstops = freezelevel;}
	}

	minstops = NormalizeDouble(minstops * point,digits);
	
	double tplimit = bidask + minstops * bs; // TP min price level
	
	//-- check and align tp, print errors --------------------------------
	//-- do not do it when the stop is the same as the original
	if (tp > 0 && tp != tpo)
	{
		if ((bs > 0 && tp < bidask) || (bs < 0 && tp > bidask))
		{
			string abstr = "";

			if (bs > 0) {abstr = "Bid";} else {abstr = "Ask";}

			Print(
				"Error: Invalid TP requested (",
				DoubleToStr(tp, digits),
				" for ", abstr, " price ",
				bidask,
				")"
			);

			return -1;
		}
		else if ((bs > 0 && tp < tplimit) || (bs < 0 && tp > tplimit))
		{
			if (USE_VIRTUAL_STOPS)
			{
				return tp;
			}

			Print(
				"Warning: Too short TP requested (",
				DoubleToStr(tp, digits),
				" or ",
				DoubleToStr(MathAbs(tp - askbid) / point, 0),
				" points), minimum will be taken (",
				DoubleToStr(tplimit, digits),
				" or ",
				DoubleToStr(MathAbs(askbid - tplimit) / point, 0),
				" points)"
			);

			tp = tplimit;

			return tp;
		}
	}
	
	// align by the ticksize
	double ticksize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
	tp = MathRound(tp / ticksize) * ticksize;
	
	return tp;
}

template<typename T>
bool ArrayEnsureValue(T &array[], T value)
{
	int size   = ArraySize(array);
	
	if (size > 0)
	{
		if (InArray(array, value))
		{
			// value found -> exit
			return false; // no value added
		}
	}
	
	// value does not exists -> add it
	ArrayResize(array, size+1);
	array[size] = value;
		
	return true; // value added
}

template<typename T>
int ArraySearch(T &array[], T value)
{
	static int index;    
	static int size;
	
	index = -1;
	size  = ArraySize(array);

	for (int i=0; i<size; i++)
	{
		if (array[i] == value)
		{
			index = i;
			break;
		}  
	}

   return index;
}

template<typename T>
bool ArrayStripKey(T &array[], int key)
{
	int x    = 0;
	int size = ArraySize(array);
	
	for (int i=0; i<size; i++)
	{
		if (i != key)
		{
			array[x] = array[i];
			x++;
		}
	}
		
	if (x < size)
	{
		ArrayResize(array, x);
		
		return true; // stripped
	}
	
	return false; // not stripped
}

template<typename T>
bool ArrayStripValue(T &array[], T value)
{
	int x    = 0;
	int size = ArraySize(array);
	
	for (int i=0; i<size; i++)
	{
		if (array[i] != value)
		{
			array[x] = array[i];
			x++;
		}
	}
	
	if (x < size)
	{
		ArrayResize(array, x);
		
		return true; // stripped
	}
	
	return false; // not stripped
}

double Bet1326(int group, string symbol, double initial_lots, bool reverse=false)
{  
   int pos=0;
   int total=0;
   double lots=0;
   double profit=0;
   int profit_or_loss=0; // 0 - unknown, 1 - profit, -1 - loss
   
   //-- try to get last lot size from running trades
   total=OrdersTotal();
   for (pos=total-1; pos>=0; pos--)
   {
      if (!OrderSelect(pos, SELECT_BY_POS, MODE_TRADES)) {continue;}
      if (OrderMagicNumber() != MagicStart+group) {continue;}
      if (OrderSymbol() != symbol) {continue;}
      if (TimeCurrent() - OrderOpenTime() < 3) {continue;}
		if (OrderExpiration() > 0 && OrderExpiration() <= OrderCloseTime()) {continue;} // no expired po
      
      if (lots==0) {
         lots=OrderLots();
      }
      
      profit = OrderClosePrice()-OrderOpenPrice();
      profit = NormalizeDouble(profit, SymbolDigits(OrderSymbol()));
      if (IsOrderTypeSell()) {profit = -1*profit;}
      if (profit == 0) {
         return(lots);
      }
      
      if (profit<0) {profit_or_loss=-1;}
      else {profit_or_loss=1;}
      
      break;
   }
   
   //-- if no running trade was found, search in history trades
   if (lots==0)
   {
      total=OrdersHistoryTotal();
      for (pos=total-1; pos>=0; pos--)
      {
         if(!OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY)) {continue;}
         if (OrderMagicNumber() != MagicStart+group) {continue;}
         if (OrderSymbol() != symbol) {continue;}
			if (OrderType() > OP_SELL) {continue;} // no po
         
         if (lots==0) {
            lots=OrderLots();
         }
         
         profit = OrderClosePrice()-OrderOpenPrice();
         profit = NormalizeDouble(profit, SymbolDigits(OrderSymbol()));
         if (IsOrderTypeSell()) {profit = -1*profit;}
         if (profit == 0) {
            return(lots);
         }
         
         if (profit<0) {profit_or_loss=-1;}
         else {profit_or_loss=1;}
         
         break;
      }
   }
   
   //--
   if (initial_lots < MarketInfo(symbol,MODE_MINLOT)) {
      initial_lots = MarketInfo(symbol,MODE_MINLOT);  
   }

   if (lots==0) {lots = initial_lots;}
   else
   {
      if ((reverse==false && profit_or_loss==1) || (reverse==true && profit_or_loss==-1))
      {
         double div = lots/initial_lots;
         
         if (div < 1.5) {lots = initial_lots*3;}
         else if (div < 2.5) {lots = initial_lots*6;}
         else if (div < 3.5) {lots = initial_lots*2;}
         else {lots = initial_lots;}
      }
      else {
         lots = initial_lots;
      }
   }
   
   return lots;
}

double BetDalembert(int group, string symbol, double initial_lots, double reverse=false)
{  
   int pos=0;
   int total=0;
   double lots=0;
   double profit=0;
   int profit_or_loss=0; // 0 - unknown, 1 - profit, -1 - loss
   
   //-- try to get last lot size from running trades
   total=OrdersTotal();
   for (pos=total-1; pos>=0; pos--)
   {
      if (!OrderSelect(pos, SELECT_BY_POS, MODE_TRADES)) {continue;}
      if (OrderMagicNumber() != MagicStart+group) {continue;}
      if (OrderSymbol() != symbol) {continue;}
      if (TimeCurrent() - OrderOpenTime() < 3) {continue;}
		if (OrderExpiration() > 0 && OrderExpiration() <= OrderCloseTime()) {continue;} // no expired po
      
      if (lots==0) {
         lots=OrderLots();
      }
      
      profit = OrderClosePrice()-OrderOpenPrice();
      profit = NormalizeDouble(profit, SymbolDigits(OrderSymbol()));
      if (IsOrderTypeSell()) {profit = -1*profit;}
      if (profit == 0) {
         return(lots);
      }
      
      if (profit<0) {profit_or_loss=-1;}
      else {profit_or_loss=1;}
      
      break;
   }
   
   //-- if no running trade was found, search in history trades
   if (lots==0)
   {
      total=OrdersHistoryTotal();
      for (pos=total-1; pos>=0; pos--)
      {
         if(!OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY)) {continue;}
         if (OrderMagicNumber() != MagicStart+group) {continue;}
         if (OrderSymbol() != symbol) {continue;}
			if (OrderType() > OP_SELL) {continue;} // no po
         
         if (lots==0) {
            lots=OrderLots();
         }
         
         profit = OrderClosePrice()-OrderOpenPrice();
         profit = NormalizeDouble(profit, SymbolDigits(OrderSymbol()));
         if (IsOrderTypeSell()) {profit = -1*profit;}
         if (profit == 0) {
            return(lots);
         }
         
         if (profit<0) {profit_or_loss=-1;}
         else {profit_or_loss=1;}
         
         break;
      }
   }
   
   //--
   if (initial_lots < MarketInfo(symbol,MODE_MINLOT)) {
      initial_lots = MarketInfo(symbol,MODE_MINLOT);  
   }

   if (lots==0) {lots = initial_lots;}
   else
   {
      if ((reverse==0 && profit_or_loss==1) || (reverse==1 && profit_or_loss==-1))
      {
         lots = lots - initial_lots;
         if (lots < initial_lots) {lots = initial_lots;}
      }
      else {
         lots = lots + initial_lots;
      }
   }
   
   return lots;
}

double BetFibonacci(
   int group,
   string symbol,
   double initial_lots
   )
{
   int pos=0;
   int total=0;
   double lots=0;
   double profit=0;
   int profit_or_loss=0; // 0 - unknown, 1 - profit, -1 - loss
   
   //-- try to get last lot size from running trades
   total=OrdersTotal();
   for (pos=total-1; pos>=0; pos--)
   {
      if (!OrderSelect(pos, SELECT_BY_POS, MODE_TRADES)) {continue;}
      if (OrderMagicNumber() != MagicStart+group) {continue;}
      if (OrderSymbol() != symbol) {continue;}
      if (TimeCurrent() - OrderOpenTime() < 3) {continue;}
		if (OrderExpiration() > 0 && OrderExpiration() <= OrderCloseTime()) {continue;} // no expired po
      
      if (lots==0) {
         lots=OrderLots();
      }
      
      profit = OrderClosePrice()-OrderOpenPrice();
      profit = NormalizeDouble(profit, SymbolDigits(OrderSymbol()));
      if (IsOrderTypeSell()) {profit = -1*profit;}
      if (profit == 0) {
         return(lots);
      }
      
      if (profit<0) {profit_or_loss=-1;}
      else {profit_or_loss=1;}
      
      break;
   }
   
   //-- if no running trade was found, search in history trades
   if (lots==0)
   {
      total=OrdersHistoryTotal();
      for (pos=total-1; pos>=0; pos--)
      {
         if(!OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY)) {continue;}
         if (OrderMagicNumber() != MagicStart+group) {continue;}
         if (OrderSymbol() != symbol) {continue;}
			if (OrderType() > OP_SELL) {continue;} // no po
         
         if (lots==0) {
            lots=OrderLots();
         }
         
         profit = OrderClosePrice()-OrderOpenPrice();
         profit = NormalizeDouble(profit, SymbolDigits(OrderSymbol()));
         if (IsOrderTypeSell()) {profit = -1*profit;}
         if (profit == 0) {
            return(lots);
         }
         
         if (profit<0) {profit_or_loss=-1;}
         else {profit_or_loss=1;}
         
         break;
      }
   }

   //--
   if (initial_lots < MarketInfo(symbol,MODE_MINLOT)) {
      initial_lots = MarketInfo(symbol,MODE_MINLOT);  
   }

   if (lots==0) {lots = initial_lots;}
   else
   {  
      int fibo1=1, fibo2=0, fibo3=0, fibo4=0;
      double div = lots/initial_lots;
      
      if (div<=0) {div=1;}

      while(true)
      {
         fibo1=fibo1+fibo2;
         fibo3=fibo2;
         fibo2=fibo1-fibo2;
         fibo4=fibo2-fibo3;
         if (fibo1 > NormalizeDouble(div, 2)) {break;}
      }
      //Print("("+fibo1 + "+" + fibo2+"+"+fibo3+") > "+div);
      if (profit_or_loss==1)
      {
         if (fibo4<=0) {fibo4=1;}
         //Print("Profit "+lots+"*"+fibo4);
         lots=initial_lots*(fibo4);
      }
      else {
         //Print("Loss "+lots+"*"+fibo1+"+"+fibo2);
         lots=initial_lots*(fibo1);
      }
   }
   
   lots=NormalizeDouble(lots, 2);
   return lots;
}

double BetLabouchere(int group, string symbol, double initial_lots, string list_of_numbers, double reverse=false)
{   
   int pos=0;
   int total=0;
   double lots=0;
   double profit=0;
   int profit_or_loss=0; // 0 - unknown, 1 - profit, -1 - loss
   
   //-- try to get last lot size from running trades
   total=OrdersTotal();
   for (pos=total-1; pos>=0; pos--)
   {
      if (!OrderSelect(pos, SELECT_BY_POS, MODE_TRADES)) {continue;}
      if (OrderMagicNumber() != MagicStart+group) {continue;}
      if (OrderSymbol() != symbol) {continue;}
      if (TimeCurrent() - OrderOpenTime() < 3) {continue;}
		if (OrderExpiration() > 0 && OrderExpiration() <= OrderCloseTime()) {continue;} // no expired po
      
      if (lots==0) {
         lots=OrderLots();
      }
      
      profit = OrderClosePrice()-OrderOpenPrice();
      profit = NormalizeDouble(profit, SymbolDigits(OrderSymbol()));
      if (IsOrderTypeSell()) {profit = -1*profit;}
      if (profit == 0) {
         return(lots);
      }
      
      if (profit<0) {profit_or_loss=-1;}
      else {profit_or_loss=1;}
      
      break;
   }
   
   //-- if no running trade was found, search in history trades
   if (lots==0)
   {
      total=OrdersHistoryTotal();
      for (pos=total-1; pos>=0; pos--)
      {
         if(!OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY)) {continue;}
         if (OrderMagicNumber() != MagicStart+group) {continue;}
         if (OrderSymbol() != symbol) {continue;}
			if (OrderType() > OP_SELL) {continue;} // no po
         
         if (lots==0) {
            lots=OrderLots();
         }
         
         profit = OrderClosePrice()-OrderOpenPrice();
         profit = NormalizeDouble(profit, SymbolDigits(OrderSymbol()));
         if (IsOrderTypeSell()) {profit = -1*profit;}
         if (profit == 0) {
            return(lots);
         }

         if (profit<0) {profit_or_loss=-1;}
         else {profit_or_loss=1;}
         
         break;
      }
   }
   
   //-- Labouchere stuff
   static int mem_group[];
   static string mem_list[];
   static int mem_ticket[];
   int start_again=false;
   
   //- get the list of numbers as it is stored in the memory, or store it
   int id=ArraySearch(mem_group, group);
   if (id == -1) {
      start_again=true;
      if (list_of_numbers=="") {list_of_numbers="1";}
      id = ArraySize(mem_group);
      ArrayResize(mem_group, id+1, id+1);
      ArrayResize(mem_list, id+1, id+1);
      ArrayResize(mem_ticket, id+1, id+1);
      mem_group[id]=group;
      mem_list[id]=list_of_numbers;
   }
   
   if (mem_ticket[id]==OrderTicket()) {
      // the last known ticket (mem_ticket[id]) should be different than OderTicket() normally
      // when failed to create a new trade - the last ticket remains the same
      // so we need to reset
      mem_list[id]=list_of_numbers;
   }
   mem_ticket[id]=OrderTicket();
   
   //- now turn the string into integer array
   int list[];
   string listS[];
   StringExplode(",", mem_list[id], listS);
   ArrayResize(list, ArraySize(listS));
   for (int s=0; s<ArraySize(listS); s++) {
      list[s]=(int)StringToInteger(StringTrim(listS[s]));  
   }

   //-- 
   int size = ArraySize(list);

   if (initial_lots < MarketInfo(symbol,MODE_MINLOT)) {
      initial_lots = MarketInfo(symbol,MODE_MINLOT);  
   }

   if (lots==0) {
      start_again=true;
   }
   
   if (start_again==true)
   {
      if (size==1) {
         lots = initial_lots*list[0];
      } else {
         lots = initial_lots*(list[0]+list[size-1]);
      }
   }
   else 
   {
      if ((reverse==0 && profit_or_loss==1) || (reverse==1 && profit_or_loss==-1))
      {
         if (size==1) {
            lots=initial_lots*list[0];
            ArrayResize(list, 0);
         }
         else if (size==2) {
            lots = initial_lots*(list[0]+list[1]);
            ArrayResize(list, 0);
         }
         else if (size>2) {
            lots = initial_lots*(list[0]+list[size-1]);
            // Cancel first and last numbers in our list
            // shift array 1 step left
            for(pos=0; pos<size-1; pos++) {
               list[pos]=list[pos+1];
            }
            ArrayResize(list,ArraySize(list)-2); // remove last 2 elements		
         }
         if (lots < initial_lots) {lots = initial_lots;}
      }
      else {
         if (size>1)
         {
            ArrayResize(list, size+1);
            list[size]=list[0]+list[size-1];
            lots = initial_lots*(list[0]+list[size]);
         } else {
            lots = initial_lots*list[0];
         }
         if (lots < initial_lots) {lots = initial_lots;}
      }

   }
   
   Print("Labouchere (for group "+(string)id+") current list of numbers:"+StringImplode(",", list));
   size=ArraySize(list);
   if (size==0) {
      ArrayStripKey(mem_group, id);
      ArrayStripKey(mem_list, id);
      ArrayStripKey(mem_ticket, id);
   } else {
      mem_list[id]=StringImplode(",", list);
   }

   return lots;
}

double BetMartingale(
   int group,
   string symbol,
   double initial_lots,
   double multiply_on_loss,
   double multiply_on_profit,
   double add_on_loss,
   double add_on_profit,
   int reset_on_loss,
   int reset_on_profit
   )
{
   int pos=0;
	int total=0;
   double lots=0;
   double profit=0;
   int profit_or_loss=0; // 0 - unknown, 1 - profit, -1 - loss
   int in_a_row=0;
   
   //-- try to get last lot size from running trades
   total=OrdersTotal();
   for (pos=total-1; pos>=0; pos--)
   {
      if (!OrderSelect(pos, SELECT_BY_POS, MODE_TRADES)) {continue;}
      if (OrderMagicNumber() != MagicStart+group) {continue;}
      if (OrderSymbol() != symbol) {continue;}
      if (TimeCurrent() - OrderOpenTime() < 3) {continue;}
		if (OrderExpiration() > 0 && OrderExpiration() <= OrderCloseTime()) {continue;} // no expired po

      if (lots==0) {
         lots=OrderLots();
      }
      
      profit = OrderClosePrice()-OrderOpenPrice();
      profit = NormalizeDouble(profit, SymbolDigits(OrderSymbol()));
      if (IsOrderTypeSell()) {profit = -1*profit;}
      if (profit == 0) {
         return(lots);
      }
      
      if (profit_or_loss == 0)
      {
         
         if (profit<0) {profit_or_loss=-1;}
         else {profit_or_loss=1;}
      }
      else {
              if (profit_or_loss==1 && profit<0) {break;}
         else if (profit_or_loss==-1 && profit>=0) {break;}
      }
      
      in_a_row++;
   }
   
   //-- if no running trade was found, search in history trades
   if (lots==0)
   {
      total=OrdersHistoryTotal();
      for (pos=total-1; pos>=0; pos--)
      {
         if(!OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY)) {continue;}
         if (OrderMagicNumber() != MagicStart+group) {continue;}
         if (OrderSymbol() != symbol) {continue;}
			if (OrderType() > OP_SELL) {continue;} // no po
         
         if (lots==0) {
            lots=OrderLots();
         }
         
         profit = OrderClosePrice()-OrderOpenPrice();
         profit = NormalizeDouble(profit, SymbolDigits(OrderSymbol()));
         if (IsOrderTypeSell()) {profit = -1*profit;}
         if (profit == 0) {
            return(lots);
         }
         
         if (profit_or_loss == 0)
         {
            if (profit<0) {profit_or_loss=-1;}
            else {profit_or_loss=1;}
         }
         else {
                 if (profit_or_loss==1 && profit<0) {break;}
            else if (profit_or_loss==-1 && profit>=0) {break;}
         }
         
         in_a_row++;
      }
   }

   //--
   /*
   if (initial_lots < MarketInfo(symbol,MODE_MINLOT)) {
      initial_lots = MarketInfo(symbol,MODE_MINLOT);  
   }*/

   if (lots==0) {lots = initial_lots;}
   else {
      if (profit_or_loss==1)
      {
         if (reset_on_profit>0 && in_a_row >= reset_on_profit) {
            lots=initial_lots;
         }
         else {
            if (multiply_on_profit<=0) {multiply_on_profit=1;}
            lots=(lots*multiply_on_profit) + add_on_profit;
         }
      }
      else {
         if (reset_on_loss>0 && in_a_row >= reset_on_loss) {
            lots=initial_lots;  
         }
         else {
            if (multiply_on_loss<=0) {multiply_on_loss=1;}
            lots=(lots*multiply_on_loss) + add_on_loss;
         }
      }
   }
   
   return lots;
}

double BetSequence(int group, string symbol, double initial_lots, string sequence_on_loss, string sequence_on_profit, bool reverse=false)
{  
   int pos=0;
   int total=0;
   double lots=0;
   int size=0;
   double profit=0;
   int profit_or_loss=0; // 0 - unknown, 1 - profit, -1 - loss
   
   //-- try to get last lot size from running trades
   total=OrdersTotal();
   for (pos=total-1; pos>=0; pos--)
   {
      if (!OrderSelect(pos, SELECT_BY_POS, MODE_TRADES)) {continue;}
      if (OrderMagicNumber() != MagicStart+group) {continue;}
      if (OrderSymbol() != symbol) {continue;}
      if (TimeCurrent() - OrderOpenTime() < 3) {continue;}
		if (OrderExpiration() > 0 && OrderExpiration() <= OrderCloseTime()) {continue;} // no expired po
      
      if (lots==0) {
         lots=OrderLots();
      }
      
      profit = OrderClosePrice()-OrderOpenPrice();
      profit = NormalizeDouble(profit, SymbolDigits(OrderSymbol()));
      if (IsOrderTypeSell()) {profit = -1*profit;}
      if (profit == 0) {
         return(lots);
      }
      
      if (profit<0) {profit_or_loss=-1;}
      else {profit_or_loss=1;}
      
      break;
   }
   
   //-- if no running trade was found, search in history trades
   if (lots==0)
   {
      total=OrdersHistoryTotal();
      for (pos=total-1; pos>=0; pos--)
      {
         if(!OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY)) {continue;}
         if (OrderMagicNumber() != MagicStart+group) {continue;}
         if (OrderSymbol() != symbol) {continue;}
			if (OrderType() > OP_SELL) {continue;} // no po
         
         if (lots==0) {
            lots=OrderLots();
         }
         
         profit = OrderClosePrice()-OrderOpenPrice();
         profit = NormalizeDouble(profit, SymbolDigits(OrderSymbol()));
         if (IsOrderTypeSell()) {profit = -1*profit;}
         if (profit == 0) {
            return(lots);
         }
         
         if (profit<0) {profit_or_loss=-1;}
         else {profit_or_loss=1;}
         
         break;
      }
   }
   
   //-- Sequence stuff
   static int mem_group[];
   static string mem_list_loss[];
   static string mem_list_profit[];
   static int mem_ticket[];
   
   //- get the list of numbers as it is stored in the memory, or store it
   int id=ArraySearch(mem_group, group);
   if (id == -1)
   {
      if (sequence_on_loss=="") {sequence_on_loss="1";}
      if (sequence_on_profit=="") {sequence_on_profit="1";}
      id = ArraySize(mem_group);
      ArrayResize(mem_group, id+1, id+1);
      ArrayResize(mem_list_loss, id+1, id+1);
      ArrayResize(mem_list_profit, id+1, id+1);
      ArrayResize(mem_ticket, id+1, id+1);
      mem_group[id]        =group;
      mem_list_loss[id]    =sequence_on_loss;
      mem_list_profit[id]  =sequence_on_profit;
   }
   
   bool loss_reset=false;
   bool profit_reset=false;
   if (profit_or_loss==-1 && mem_list_loss[id]=="") {
      loss_reset=true;
      mem_list_profit[id]="";
   }
   if (profit_or_loss==1 && mem_list_profit[id]=="") {
      profit_reset=true;
      mem_list_loss[id]="";
   }
   
   if (profit_or_loss==1 || mem_list_loss[id]=="") {
      mem_list_loss[id]=sequence_on_loss;
      if (loss_reset) {mem_list_loss[id]="1,"+mem_list_loss[id];}
      
   }
   if (profit_or_loss==-1 ||mem_list_profit[id]=="") {
      mem_list_profit[id]=sequence_on_profit;
      if (profit_reset) {mem_list_profit[id]="1,"+mem_list_profit[id];}
   }
   
   if (mem_ticket[id]==OrderTicket()) {
      // the last known ticket (mem_ticket[id]) should be different than OderTicket() normally
      // when failed to create a new trade - the last ticket remains the same
      // so we need to reset
      mem_list_loss[id]=sequence_on_loss;
      mem_list_profit[id]=sequence_on_profit;
   }
   mem_ticket[id]=OrderTicket();
   
   //- now turn the string into integer array
   int s=0;
   double list_loss[];
   double list_profit[];
   string listS[];
   StringExplode(",", mem_list_loss[id], listS);
   ArrayResize(list_loss, ArraySize(listS), ArraySize(listS));
   for (s=0; s<ArraySize(listS); s++) {
      list_loss[s]=(double)StringToDouble(StringTrim(listS[s]));  
   }
   StringExplode(",", mem_list_profit[id], listS);
   ArrayResize(list_profit, ArraySize(listS), ArraySize(listS));
   for (s=0; s<ArraySize(listS); s++) {
      list_profit[s]=(double)StringToDouble(StringTrim(listS[s]));  
   }

   //--
   if (initial_lots < MarketInfo(symbol,MODE_MINLOT)) {
      initial_lots = MarketInfo(symbol,MODE_MINLOT);  
   }

   if (lots==0) {lots = initial_lots;}
   else
   {
      if ((reverse==false && profit_or_loss==1) || (reverse==true && profit_or_loss==-1))
      {
         lots = initial_lots*list_profit[0];
         // shift array 1 step left
         size=ArraySize(list_profit);
         for(pos=0; pos<size-1; pos++) {
            list_profit[pos]=list_profit[pos+1];
         }
         if (size>0) {
            ArrayResize(list_profit, size-1, size-1);
            mem_list_profit[id]=StringImplode(",", list_profit);
         }
         // reset the opposite sequence
         //mem_list_loss[id]="";
      }
      else {
         
         lots = initial_lots*list_loss[0];
         // shift array 1 step left
         size=ArraySize(list_loss);
         for(pos=0; pos<size-1; pos++) {
            list_loss[pos]=list_loss[pos+1];
         }
         if (size>0) {
            ArrayResize(list_loss, size-1, size-1);
            mem_list_loss[id]=StringImplode(",", list_loss);
         }
         // reset the opposite sequence
         //mem_list_profit[id]="";
      }
   }
   
   return lots;
}

int CheckForTradingError(int error_code=-1, string msg_prefix="")
{
   // return 0 -> no error
   // return 1 -> overcomable error
   // return 2 -> fatal error
   
   if (error_code<0) {
      error_code=GetLastError();  
   }
   
   int retval=0;
   static int tryouts=0;
   
   //-- error check -----------------------------------------------------
   switch(error_code)
   {
      //-- no error
      case 0:
         retval=0;
         break;
      //-- overcomable errors
      case 1: // No error returned
         RefreshRates();
         retval=1;
         break;
      case 4: //ERR_SERVER_BUSY
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
         Sleep(1000);
         RefreshRates();
         retval=1;
         break;
      case 6: //ERR_NO_CONNECTION
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
         while(!IsConnected()) {Sleep(100);}
         while(IsTradeContextBusy()) {Sleep(50);}
         RefreshRates();
         retval=1;
         break;
      case 128: //ERR_TRADE_TIMEOUT
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
         RefreshRates();
         retval=1;
         break;
      case 129: //ERR_INVALID_PRICE
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
         if (!IsTesting()) {while(RefreshRates()==false) {Sleep(1);}}
         retval=1;
         break;
      case 130: //ERR_INVALID_STOPS
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Waiting for a new tick to retry.."));}
         if (!IsTesting()) {while(RefreshRates()==false) {Sleep(1);}}
         retval=1;
         break;
      case 135: //ERR_PRICE_CHANGED
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Waiting for a new tick to retry.."));}
         if (!IsTesting()) {while(RefreshRates()==false) {Sleep(1);}}
         retval=1;
         break;
      case 136: //ERR_OFF_QUOTES
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Waiting for a new tick to retry.."));}
         if (!IsTesting()) {while(RefreshRates()==false) {Sleep(1);}}
         retval=1;
         break;
      case 137: //ERR_BROKER_BUSY
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
         Sleep(1000);
         retval=1;
         break;
      case 138: //ERR_REQUOTE
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Waiting for a new tick to retry.."));}
         if (!IsTesting()) {while(RefreshRates()==false) {Sleep(1);}}
         retval=1;
         break;
      case 142: //This code should be processed in the same way as error 128.
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
         RefreshRates();
         retval=1;
         break;
      case 143: //This code should be processed in the same way as error 128.
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
         RefreshRates();
         retval=1;
         break;
      /*case 145: //ERR_TRADE_MODIFY_DENIED
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Waiting for a new tick to retry.."));}
         while(RefreshRates()==false) {Sleep(1);}
         return(1);
      */
      case 146: //ERR_TRADE_CONTEXT_BUSY
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
         while(IsTradeContextBusy()) {Sleep(50);}
         RefreshRates();
         retval=1;
         break;
      //-- critical errors
      default:
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code)));}
         retval=2;
         break;
   }

   if (retval==0) {tryouts=0;}
   else if (retval==1) {
      tryouts++;
      if (tryouts>=10) {
         tryouts=0;
         retval=2;
      } else {
         Print("retry #"+(string)tryouts+" of 10");
      }
   }
   
   return(retval);
}

bool CloseTrade(ulong ticket, ulong slippage = 0, color arrowcolor = CLR_NONE)
{
	bool success = false;

	if (!OrderSelect((int)ticket, SELECT_BY_TICKET, MODE_TRADES))
	{
		return false;
	}

	while (true)
	{
		//-- wait if needed -----------------------------------------------
		WaitTradeContextIfBusy();

		//-- close --------------------------------------------------------
		success = OrderClose((int)ticket, OrderLots(), OrderClosePrice(), (int)(slippage * PipValue(OrderSymbol())), arrowcolor);

		if (success == true)
		{
			if (USE_VIRTUAL_STOPS) {
				VirtualStopsDriver("clear", ticket);
			}

			RegisterEvent("trade");

			return true;
		}

		//-- errors -------------------------------------------------------
		int erraction = CheckForTradingError(GetLastError(), "Closing trade #" + (string)ticket + " error");

		switch(erraction)
		{
			case 0: break;    // no error
			case 1: continue; // overcomable error
			case 2: break;    // fatal error
		}

		break;
	}

	return false;
}

string CurrentSymbol(string symbol="")
{
   static string memory="";
   if (symbol!="") {memory=symbol;} else
   if (memory=="") {memory=Symbol();}
   return(memory);
}

ENUM_TIMEFRAMES CurrentTimeframe(ENUM_TIMEFRAMES tf=-1)
{
	static ENUM_TIMEFRAMES memory=0;
   if (tf>=0) {memory=tf;}
   return(memory);
}

double CustomPoint(string symbol)
{
	static string symbols[];
	static double points[];
	static string last_symbol = "-";
	static double last_point  = 0;
	static int last_i         = 0;
	static int size           = 0;

	//-- variant A) use the cache for the last used symbol
	if (symbol == last_symbol)
	{
		return last_point;
	}

	//-- variant B) search in the array cache
	int i			= last_i;
	int start_i	= i;
	bool found	= false;

	if (size > 0)
	{
		while (true)
		{
			if (symbols[i] == symbol)
			{
				last_symbol	= symbol;
				last_point	= points[i];
				last_i		= i;

				return last_point;
			}

			i++;

			if (i >= size)
			{
				i = 0;
			}
			if (i == start_i) {break;}
		}
	}

	//-- variant C) add this symbol to the cache
	i		= size;
	size	= size + 1;

	ArrayResize(symbols, size);
	ArrayResize(points, size);

	symbols[i]	= symbol;
	points[i]	= 0;
	last_symbol	= symbol;
	last_i		= i;

	//-- unserialize rules from FXD_POINT_FORMAT_RULES
	string rules[];
	StringExplode(",", POINT_FORMAT_RULES, rules);

	int rules_count = ArraySize(rules);

	if (rules_count > 0)
	{
		string rule[];

		for (int r = 0; r < rules_count; r++)
		{
			StringExplode("=", rules[r], rule);

			//-- a single rule must contain 2 parts, [0] from and [1] to
			if (ArraySize(rule) != 2) {continue;}

			double from = StringToDouble(rule[0]);
			double to	= StringToDouble(rule[1]);

			//-- "to" must be a positive number, different than 0
			if (to <= 0) {continue;}

			//-- "from" can be a number or a string
			// a) string
			if (from == 0 && StringLen(rule[0]) > 0)
			{
				string s_from = rule[0];
				int pos       = StringFind(s_from, "?");

				if (pos < 0) // ? not found
				{
					if (StringFind(symbol, s_from) == 0) {points[i] = to;}
				}
				else if (pos == 0) // ? is the first symbol => match the second symbol
				{
					if (StringFind(symbol, StringSubstr(s_from, 1), 3) == 3)
					{
						points[i] = to;
					}
				}
				else if (pos > 0) // ? is the second symbol => match the first symbol
				{
					if (StringFind(symbol, StringSubstr(s_from, 0, pos)) == 0)
					{
						points[i] = to;
					}
				}
			}

			// b) number
			if (from == 0) {continue;}

			if (SymbolInfoDouble(symbol, SYMBOL_POINT) == from)
			{
				points[i] = to;
			}
		}
	}

	if (points[i] == 0)
	{
		points[i] = SymbolInfoDouble(symbol, SYMBOL_POINT);
	}

	last_point = points[i];

	return last_point;
}

bool DeleteOrder(int ticket, color arrowcolor=clrNONE)
{
   bool success=false;
   if (!OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) {return(false);}
   
   while(true)
   {
      //-- wait if needed -----------------------------------------------
      WaitTradeContextIfBusy();
      //-- delete -------------------------------------------------------
      success=OrderDelete(ticket,arrowcolor);
      if (success==true) {
         if (USE_VIRTUAL_STOPS) {
            VirtualStopsDriver("clear",ticket);
         }
         RegisterEvent("trade");
         return(true);
      }
      //-- error check --------------------------------------------------
      int erraction=CheckForTradingError(GetLastError(), "Deleting order #"+(string)ticket+" error");
      switch(erraction)
      {
         case 0: break;    // no error
         case 1: continue; // overcomable error
         case 2: break;    // fatal error
      }
      break;
   }
   return(false);
}

void DrawSpreadInfo()
{
   static bool allow_draw = true;
   if (allow_draw==false) {return;}
   if (MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE)) {allow_draw=false;} // Allowed to draw only once in testing mode

   static bool passed         = false;
   static double max_spread   = 0;
   static double min_spread   = EMPTY_VALUE;
   static double avg_spread   = 0;
   static double avg_add      = 0;
   static double avg_cnt      = 0;

   double custom_point = CustomPoint(Symbol());
   double current_spread = 0;
   if (custom_point > 0) {
      current_spread = (SymbolInfoDouble(Symbol(),SYMBOL_ASK)-SymbolInfoDouble(Symbol(),SYMBOL_BID))/custom_point;
   }
   if (current_spread > max_spread) {max_spread = current_spread;}
   if (current_spread < min_spread) {min_spread = current_spread;}
   
   avg_cnt++;
   avg_add     = avg_add + current_spread;
   avg_spread  = avg_add / avg_cnt;

   int x=0; int y=0;
   string name;

   // create objects
   if (passed == false)
   {
      passed=true;
      
      name="fxd_spread_current_label";
      if (ObjectFind(0, name)==-1) {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+1);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+1);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 18);
         ObjectSetInteger(0, name, OBJPROP_COLOR, clrDarkOrange);
         ObjectSetString(0, name, OBJPROP_FONT, "Arial");
         ObjectSetString(0, name, OBJPROP_TEXT, "Spread:");
      }
      name="fxd_spread_max_label";
      if (ObjectFind(0, name)==-1) {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+148);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+17);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
         ObjectSetInteger(0, name, OBJPROP_COLOR, clrOrangeRed);
         ObjectSetString(0, name, OBJPROP_FONT, "Arial");
         ObjectSetString(0, name, OBJPROP_TEXT, "max:");
      }
      name="fxd_spread_avg_label";
      if (ObjectFind(0, name)==-1) {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+148);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+9);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
         ObjectSetInteger(0, name, OBJPROP_COLOR, clrDarkOrange);
         ObjectSetString(0, name, OBJPROP_FONT, "Arial");
         ObjectSetString(0, name, OBJPROP_TEXT, "avg:");
      }
      name="fxd_spread_min_label";
      if (ObjectFind(0, name)==-1) {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+148);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+1);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
         ObjectSetInteger(0, name, OBJPROP_COLOR, clrGold);
         ObjectSetString(0, name, OBJPROP_FONT, "Arial");
         ObjectSetString(0, name, OBJPROP_TEXT, "min:");
      }
      name="fxd_spread_current";
      if (ObjectFind(0, name)==-1) {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+93);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+1);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 18);
         ObjectSetInteger(0, name, OBJPROP_COLOR, clrDarkOrange);
         ObjectSetString(0, name, OBJPROP_FONT, "Arial");
         ObjectSetString(0, name, OBJPROP_TEXT, "0");
      }
      name="fxd_spread_max";
      if (ObjectFind(0, name)==-1) {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+173);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+17);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
         ObjectSetInteger(0, name, OBJPROP_COLOR, clrOrangeRed);
         ObjectSetString(0, name, OBJPROP_FONT, "Arial");
         ObjectSetString(0, name, OBJPROP_TEXT, "0");
      }
      name="fxd_spread_avg";
      if (ObjectFind(0, name)==-1) {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+173);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+9);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
         ObjectSetInteger(0, name, OBJPROP_COLOR, clrDarkOrange);
         ObjectSetString(0, name, OBJPROP_FONT, "Arial");
         ObjectSetString(0, name, OBJPROP_TEXT, "0");
      }
      name="fxd_spread_min";
      if (ObjectFind(0, name)==-1) {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+173);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+1);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
         ObjectSetInteger(0, name, OBJPROP_COLOR, clrGold);
         ObjectSetString(0, name, OBJPROP_FONT, "Arial");
         ObjectSetString(0, name, OBJPROP_TEXT, "0");
      }
   }
   
   ObjectSetString(0, "fxd_spread_current", OBJPROP_TEXT, DoubleToStr(current_spread,2));
   ObjectSetString(0, "fxd_spread_max", OBJPROP_TEXT, DoubleToStr(max_spread,2));
   ObjectSetString(0, "fxd_spread_avg", OBJPROP_TEXT, DoubleToStr(avg_spread,2));
   ObjectSetString(0, "fxd_spread_min", OBJPROP_TEXT, DoubleToStr(min_spread,2));
}

string DrawStatus(string text="")
{
   static string memory;
   if (text=="") {
      return(memory);
   }
   
   static bool passed = false;
   int x=210; int y=0;
   string name;

   //-- draw the objects once
   if (passed == false)
   {
      passed = true;
      name="fxd_status_title";
      ObjectCreate(0,name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0,name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0,name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0,name, OBJPROP_YDISTANCE, y+17);
      ObjectSetString(0,name, OBJPROP_TEXT, "Status");
      ObjectSetString(0,name, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0,name, OBJPROP_FONTSIZE, 7);
      ObjectSetInteger(0,name, OBJPROP_COLOR, clrGray);
      
      name="fxd_status_text";
      ObjectCreate(0,name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0,name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0,name, OBJPROP_XDISTANCE, x+2);
      ObjectSetInteger(0,name, OBJPROP_YDISTANCE, y+1);
      ObjectSetString(0,name, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0,name, OBJPROP_FONTSIZE, 12);
      ObjectSetInteger(0,name, OBJPROP_COLOR, clrAqua);
   }

   //-- update the text when needed
   if (text != memory) {
      memory=text;
      ObjectSetString(0,"fxd_status_text", OBJPROP_TEXT, text);
   }
   
   return(text);
}

double DynamicLots(string symbol, string mode="balance", double value=0, double sl=0, string align="align", double RJFR_initial_lots=0)
{
   double size=0;
   double LotStep=MarketInfo(symbol,MODE_LOTSTEP);
   double LotSize=MarketInfo(symbol,MODE_LOTSIZE);
   double MinLots=MarketInfo(symbol,MODE_MINLOT);
   double MaxLots=MarketInfo(symbol,MODE_MAXLOT);
   double TickValue=MarketInfo(symbol,MODE_TICKVALUE);
   double point=MarketInfo(symbol,MODE_POINT);
   double ticksize=MarketInfo(symbol,MODE_TICKSIZE);
   double margin_required=MarketInfo(symbol,MODE_MARGINREQUIRED);
   
   if (mode=="fixed" || mode=="lots")     {size=value;}
   else if (mode=="block-equity")      {size=(value/100)*AccountEquity()/margin_required;}
   else if (mode=="block-balance")     {size=(value/100)*AccountBalance()/margin_required;}
   else if (mode=="block-freemargin")  {size=(value/100)*AccountFreeMargin()/margin_required;}
   else if (mode=="equity")      {size=(value/100)*AccountEquity()/(LotSize*TickValue);}
   else if (mode=="balance")     {size=(value/100)*AccountBalance()/(LotSize*TickValue);}
   else if (mode=="freemargin")  {size=(value/100)*AccountFreeMargin()/(LotSize*TickValue);}
   else if (mode=="equityRisk")     {size=((value/100)*AccountEquity())/(sl*((TickValue/ticksize)*point)*PipValue(symbol));}
   else if (mode=="balanceRisk")    {size=((value/100)*AccountBalance())/(sl*((TickValue/ticksize)*point)*PipValue(symbol));}
   else if (mode=="freemarginRisk") {size=((value/100)*AccountFreeMargin())/(sl*((TickValue/ticksize)*point)*PipValue(symbol));}
   else if (mode=="fixedRisk")   {size=(value)/(sl*((TickValue/ticksize)*point)*PipValue(symbol));}
   else if (mode=="fixedRatio" || mode=="RJFR") {
      
      /////
      // Ryan Jones Fixed Ratio MM static data
      static double RJFR_start_lots=0;
      static double RJFR_delta=0;
      static double RJFR_units=1;
      static double RJFR_target_lower=0;
      static double RJFR_target_upper=0;
      /////
      
      if (RJFR_start_lots<=0) {RJFR_start_lots=value;}
      if (RJFR_start_lots<MinLots) {RJFR_start_lots=MinLots;}
      if (RJFR_delta<=0) {RJFR_delta=sl;}
      if (RJFR_target_upper<=0) {
         RJFR_target_upper=AccountEquity()+(RJFR_units*RJFR_delta);
         Print("Fixed Ratio MM: Units=>",RJFR_units,"; Delta=",RJFR_delta,"; Upper Target Equity=>",RJFR_target_upper);
      }
      if (AccountEquity()>=RJFR_target_upper)
      {
         while(true) {
            Print("Fixed Ratio MM going up to ",(RJFR_start_lots*(RJFR_units+1))," lots: Equity is above Upper Target Equity (",AccountEquity(),">=",RJFR_target_upper,")");
            RJFR_units++;
            RJFR_target_lower=RJFR_target_upper;
            RJFR_target_upper=RJFR_target_upper+(RJFR_units*RJFR_delta);
            Print("Fixed Ratio MM: Units=>",RJFR_units,"; Delta=",RJFR_delta,"; Lower Target Equity=>",RJFR_target_lower,"; Upper Target Equity=>",RJFR_target_upper);
            if (AccountEquity()<RJFR_target_upper) {break;}
         }
      }
      else if (AccountEquity()<=RJFR_target_lower)
      {
         while(true) {
         if (AccountEquity()>RJFR_target_lower) {break;}
            if (RJFR_units>1) {         
               Print("Fixed Ratio MM going down to ",(RJFR_start_lots*(RJFR_units-1))," lots: Equity is below Lower Target Equity | ", AccountEquity()," <= ",RJFR_target_lower,")");
               RJFR_target_upper=RJFR_target_lower;
               RJFR_target_lower=RJFR_target_lower-((RJFR_units-1)*RJFR_delta);
               RJFR_units--;
               Print("Fixed Ratio MM: Units=>",RJFR_units,"; Delta=",RJFR_delta,"; Lower Target Equity=>",RJFR_target_lower,"; Upper Target Equity=>",RJFR_target_upper);
            } else {break;}
         }
      }
      size=RJFR_start_lots*RJFR_units;
   }
   
	if (size==EMPTY_VALUE) {size=0;}
	
   size=MathRound(size/LotStep)*LotStep;
   
   static bool alert_min_lots=false;
   if (size<MinLots && alert_min_lots==false) {
      alert_min_lots=true;
      Alert("You want to trade ",size," lot, but your broker's minimum is ",MinLots," lot. The trade/order will continue with ",MinLots," lot instead of ",size," lot. The same rule will be applied for next trades/orders with desired lot size lower than the minimum. You will not see this message again until you restart the program.");
   }
   
   if (align=="align") {
      if (size<MinLots) {size=MinLots;}
      if (size>MaxLots) {size=MaxLots;}
   }
   
   return (size);
}

string ErrorMessage(int error_code=-1)
{
	string e = "";
	
	if (error_code < 0) {error_code = GetLastError();}
	
	switch(error_code)
	{
		//-- codes returned from trade server
		case 0:	return("");
		case 1:	e = "No error returned"; break;
		case 2:	e = "Common error"; break;
		case 3:	e = "Invalid trade parameters"; break;
		case 4:	e = "Trade server is busy"; break;
		case 5:	e = "Old version of the client terminal"; break;
		case 6:	e = "No connection with trade server"; break;
		case 7:	e = "Not enough rights"; break;
		case 8:	e = "Too frequent requests"; break;
		case 9:	e = "Malfunctional trade operation (never returned error)"; break;
		case 64:  e = "Account disabled"; break;
		case 65:  e = "Invalid account"; break;
		case 128: e = "Trade timeout"; break;
		case 129: e = "Invalid price"; break;
		case 130: e = "Invalid Sl or TP"; break;
		case 131: e = "Invalid trade volume"; break;
		case 132: e = "Market is closed"; break;
		case 133: e = "Trade is disabled"; break;
		case 134: e = "Not enough money"; break;
		case 135: e = "Price changed"; break;
		case 136: e = "Off quotes"; break;
		case 137: e = "Broker is busy (never returned error)"; break;
		case 138: e = "Requote"; break;
		case 139: e = "Order is locked"; break;
		case 140: e = "Only long trades allowed"; break;
		case 141: e = "Too many requests"; break;
		case 145: e = "Modification denied because order too close to market"; break;
		case 146: e = "Trade context is busy"; break;
		case 147: e = "Expirations are denied by broker"; break;
		case 148: e = "Amount of open and pending orders has reached the limit"; break;
		case 149: e = "Hedging is prohibited"; break;
		case 150: e = "Prohibited by FIFO rules"; break;
		
		//-- mql4 errors
		case 4000: e = "No error"; break;
		case 4001: e = "Wrong function pointer"; break;
		case 4002: e = "Array index is out of range"; break;
		case 4003: e = "No memory for function call stack"; break;
		case 4004: e = "Recursive stack overflow"; break;
		case 4005: e = "Not enough stack for parameter"; break;
		case 4006: e = "No memory for parameter string"; break;
		case 4007: e = "No memory for temp string"; break;
		case 4008: e = "Not initialized string"; break;
		case 4009: e = "Not initialized string in array"; break;
		case 4010: e = "No memory for array string"; break;
		case 4011: e = "Too long string"; break;
		case 4012: e = "Remainder from zero divide"; break;
		case 4013: e = "Zero divide"; break;
		case 4014: e = "Unknown command"; break;
		case 4015: e = "Wrong jump"; break;
		case 4016: e = "Not initialized array"; break;
		case 4017: e = "dll calls are not allowed"; break;
		case 4018: e = "Cannot load library"; break;
		case 4019: e = "Cannot call function"; break;
		case 4020: e = "Expert function calls are not allowed"; break;
		case 4021: e = "Not enough memory for temp string returned from function"; break;
		case 4022: e = "System is busy"; break;
		case 4050: e = "Invalid function parameters count"; break;
		case 4051: e = "Invalid function parameter value"; break;
		case 4052: e = "String function internal error"; break;
		case 4053: e = "Some array error"; break;
		case 4054: e = "Incorrect series array using"; break;
		case 4055: e = "Custom indicator error"; break;
		case 4056: e = "Arrays are incompatible"; break;
		case 4057: e = "Global variables processing error"; break;
		case 4058: e = "Global variable not found"; break;
		case 4059: e = "Function is not allowed in testing mode"; break;
		case 4060: e = "Function is not confirmed"; break;
		case 4061: e = "Send mail error"; break;
		case 4062: e = "String parameter expected"; break;
		case 4063: e = "Integer parameter expected"; break;
		case 4064: e = "Double parameter expected"; break;
		case 4065: e = "Array as parameter expected"; break;
		case 4066: e = "Requested history data in update state"; break;
		case 4099: e = "End of file"; break;
		case 4100: e = "Some file error"; break;
		case 4101: e = "Wrong file name"; break;
		case 4102: e = "Too many opened files"; break;
		case 4103: e = "Cannot open file"; break;
		case 4104: e = "Incompatible access to a file"; break;
		case 4105: e = "No order selected"; break;
		case 4106: e = "Unknown symbol"; break;
		case 4107: e = "Invalid price parameter for trade function"; break;
		case 4108: e = "Invalid ticket"; break;
		case 4109: e = "Trade is not allowed in the expert properties"; break;
		case 4110: e = "Longs are not allowed in the expert properties"; break;
		case 4111: e = "Shorts are not allowed in the expert properties"; break;
		
		//-- objects errors
		case 4200: e = "Object is already exist"; break;
		case 4201: e = "Unknown object property"; break;
		case 4202: e = "Object is not exist"; break;
		case 4203: e = "Unknown object type"; break;
		case 4204: e = "No object name"; break;
		case 4205: e = "Object coordinates error"; break;
		case 4206: e = "No specified subwindow"; break;
		case 4207: e = "Graphical object error"; break;  
		case 4210: e = "Unknown chart property"; break;
		case 4211: e = "Chart not found"; break;
		case 4212: e = "Chart subwindow not found"; break;
		case 4213: e = "Chart indicator not found"; break;
		case 4220: e = "Symbol select error"; break;
		case 4250: e = "Notification error"; break;
		case 4251: e = "Notification parameter error"; break;
		case 4252: e = "Notifications disabled"; break;
		case 4253: e = "Notification send too frequent"; break;
		
		//-- ftp errors
		case 4260: e = "FTP server is not specified"; break;
		case 4261: e = "FTP login is not specified"; break;
		case 4262: e = "FTP connection failed"; break;
		case 4263: e = "FTP connection closed"; break;
		case 4264: e = "FTP path not found on server"; break;
		case 4265: e = "File not found in the MQL4\\Files directory to send on FTP server"; break;
		case 4266: e = "Common error during FTP data transmission"; break;
		
		//-- filesystem errors
		case 5001: e = "Too many opened files"; break;
		case 5002: e = "Wrong file name"; break;
		case 5003: e = "Too long file name"; break;
		case 5004: e = "Cannot open file"; break;
		case 5005: e = "Text file buffer allocation error"; break;
		case 5006: e = "Cannot delete file"; break;
		case 5007: e = "Invalid file handle (file closed or was not opened)"; break;
		case 5008: e = "Wrong file handle (handle index is out of handle table)"; break;
		case 5009: e = "File must be opened with FILE_WRITE flag"; break;
		case 5010: e = "File must be opened with FILE_READ flag"; break;
		case 5011: e = "File must be opened with FILE_BIN flag"; break;
		case 5012: e = "File must be opened with FILE_TXT flag"; break;
		case 5013: e = "File must be opened with FILE_TXT or FILE_CSV flag"; break;
		case 5014: e = "File must be opened with FILE_CSV flag"; break;
		case 5015: e = "File read error"; break;
		case 5016: e = "File write error"; break;
		case 5017: e = "String size must be specified for binary file"; break;
		case 5018: e = "Incompatible file (for string arrays-TXT, for others-BIN)"; break;
		case 5019: e = "File is directory, not file"; break;
		case 5020: e = "File does not exist"; break;
		case 5021: e = "File cannot be rewritten"; break;
		case 5022: e = "Wrong directory name"; break;
		case 5023: e = "Directory does not exist"; break;
		case 5024: e = "Specified file is not directory"; break;
		case 5025: e = "Cannot delete directory"; break;
		case 5026: e = "Cannot clean directory"; break;
		
		//-- other errors
		case 5027: e = "Array resize error"; break;
		case 5028: e = "String resize error"; break;
		case 5029: e = "Structure contains strings or dynamic arrays"; break;
		
		//-- http request
		case 5200: e = "Invalid URL"; break;
		case 5201: e = "Failed to connect to specified URL"; break;
		case 5202: e = "Timeout exceeded"; break;
		case 5203: e = "HTTP request failed"; break;

		default:	e = "Unknown error";
	}

	e = StringConcatenate(e, " (", error_code, ")");
	
	return e;
}

void ExpirationDriver()
{
   static int last_checked_ticket;
   static int db_tickets[];
   static int db_expirations[];

   static int total; total   = OrdersTotal();
   static int size;  size    = 0;
   static int do_reset; do_reset=false;
   static string print;
   static int i;
   
   //-- check expirations and close trades
   size = ArraySize(db_tickets);
   if (size>0)
   {
      if (total==0) {
         ArrayResize(db_tickets, 0);
         ArrayResize(db_expirations, 0);
      }
      else
      {
         for (i=0; i<size; i++)
         {
            WaitTradeContextIfBusy();
            if (!OrderSelect(db_tickets[i],SELECT_BY_TICKET, MODE_TRADES)) {continue;}
            if (OrderSymbol() != Symbol()) {continue;}
            
            if (TimeCurrent() >= OrderOpenTime()+db_expirations[i]) {
               
               //-- trying to skip conflicts with the same functionality running from neighbour EA
               WaitTradeContextIfBusy();
               if (!OrderSelect(db_tickets[i],SELECT_BY_TICKET, MODE_TRADES)) {continue;}
               if (OrderCloseTime()>0) {continue;}
               
               //-- closing the trade
               if (CloseTrade(OrderTicket())) 
               {
                  print = "#"+(string)OrderTicket()+" was closed due to expiration";
                  Print(print);
                  last_checked_ticket=0;
                  do_reset = true;
                  total    = OrdersTotal();
               }
            }
         }
      }
   }
   
   //-- check the ticket of the newest trade
   if (do_reset==false && total>0)
   {
      if (OrderSelect(total-1,SELECT_BY_POS)) {
         if (OrderTicket()!=last_checked_ticket) {
            do_reset = true;
         }
      }
   }

   //-- rebuild the database of trades with expirations
   if (do_reset==true)
   {
      static string comment;
      ArrayResize(db_tickets, 0);
      ArrayResize(db_expirations, 0);
      for (int pos=0; pos<total; pos++)
      {
         if (!OrderSelect(pos,SELECT_BY_POS)) {continue;}
         last_checked_ticket = OrderTicket();

         comment = OrderComment();
         int exp_pos_begin = StringFind(comment, "[exp:");
         if (exp_pos_begin >= 0)
         {
            exp_pos_begin = exp_pos_begin+5;
            int exp_pos_end = StringFind(comment, "]", exp_pos_begin);
            if (exp_pos_end == -1) {continue;}
            
            size = ArraySize(db_tickets);
            ArrayResize(db_tickets, size+1);
            ArrayResize(db_expirations, size+1);
            db_tickets[size]     = OrderTicket();
            db_expirations[size] = (int)StringToInteger(StringSubstr(comment, exp_pos_begin, exp_pos_end));
         }
      }
   }
}

datetime ExpirationTime(string mode="GTC",int days=0, int hours=0, int minutes=0, datetime custom=0)
{
	datetime now        = TimeCurrent();
   datetime expiration = now;

	     if (mode == "GTC" || mode == "") {expiration = 0;}
	else if (mode == "today")             {expiration = (datetime)(MathFloor((now + 86400.0) / 86400.0) * 86400.0);}
	else if (mode == "specified")
	{
		expiration = 0;

		if ((days + hours + minutes) > 0)
		{
			expiration = now + (86400 * days) + (3600 * hours) + (60 * minutes);
		}
	}
	else
	{
		if (custom <= now)
		{
			if (custom < 31557600)
			{
				custom = now + custom;
			}
			else
			{
				custom = 0;
			}
		}

		expiration = custom;
	}

	return expiration;
}

bool FilterOrderBy(
	string group_mode    = "all",
	string group         = "0",
	string market_mode   = "all",
	string market        = "",
	string BuysOrSells   = "both",
	string LimitsOrStops = "both",
	int TradesOrders     = 0,
	bool onTrade         = false
) {
	// TradesOrders = 0 - trades only
	// TradesOrders = 1 - orders only
	// TradesOrders = 2 - trades and orders

	//-- db
	static string markets[];
	static string market0   = "-";
	static int markets_size = 0;
	
	static string groups[];
	static string group0   = "-";
	static int groups_size = 0;
	
	//-- local variables
	bool type_pass   = false;
	bool market_pass = false;
	bool group_pass  = false;
	
	int i, type, magic_number;
	string symbol;

	// Trades
	if (onTrade == false)
	{
		type         = OrderType();
		magic_number = OrderMagicNumber();
		symbol       = OrderSymbol();
	}
	else
	{
		type         = e_attrType();
		magic_number = e_attrMagicNumber();
		symbol       = e_attrSymbol();
	}

	if (TradesOrders == 0)
	{
		if (
				(BuysOrSells == "both"  && (type == OP_BUY || type == OP_SELL))
			|| (BuysOrSells == "buys"  && type == OP_BUY)
			|| (BuysOrSells == "sells" && type == OP_SELL)
			
			)
		{
			type_pass = true;
		}
	}
	// Pending orders
	else if (TradesOrders == 1)
	{
		if (
				(BuysOrSells == "both" && (type == OP_BUYLIMIT || type == OP_BUYSTOP || type == OP_SELLLIMIT || type == OP_SELLSTOP))
			||	(BuysOrSells == "buys" && (type == OP_BUYLIMIT || type == OP_BUYSTOP))
			|| (BuysOrSells == "sells" && (type == OP_SELLLIMIT || type == OP_SELLSTOP))
			)
		{
			if (
					(LimitsOrStops == "both" && (type == OP_BUYSTOP || type == OP_SELLSTOP || type == OP_BUYLIMIT || type == OP_SELLLIMIT))
				||	(LimitsOrStops == "stops" && (type == OP_BUYSTOP || type == OP_SELLSTOP))
				|| (LimitsOrStops == "limits" && (type == OP_BUYLIMIT || type == OP_SELLLIMIT))					
				)
			{
				type_pass = true;
			}
		}
	}
	//-- Trades and orders --------------------------------------------
	else
	{
		if (
				(BuysOrSells == "both")
			|| (BuysOrSells == "buys"  && (type == OP_BUY || type == OP_BUYLIMIT || type == OP_BUYSTOP))
			|| (BuysOrSells == "sells" && (type == OP_SELL || type == OP_SELLLIMIT || type == OP_SELLSTOP))
			)
		{
			type_pass = true;
		}
	}

	if (type_pass == false)
	{
		return false;
	}

	//-- check group
	if (group_mode == "group")
	{
		if (group == "")
		{
			if (magic_number == MagicStart)
   		{
   			group_pass = true;
   		}
	   }
	   else
	   {
			if (group0 != group)
			{
				group0 = group;
				StringExplode(",", group,groups);
				groups_size = ArraySize(groups);

				for(i = 0; i < groups_size; i++)
				{
					groups[i] = StringTrimRight(groups[i]);
					groups[i] = StringTrimLeft(groups[i]);

					if (groups[i] == "") {groups[i] = "0";}
				}
			}
		
			for(i = 0; i < groups_size; i++)
			{
				if (magic_number == (MagicStart+(int)groups[i]))
				{
					group_pass = true;

					break;
				}
			}
		}
	}
	else if (group_mode == "all" || (group_mode == "manual" && magic_number == 0))
	{
		group_pass = true;  
	}

	if (group_pass == false)
	{
		return false;
	}

	// check market
	if (market_mode == "all")
	{
		market_pass = true;
	}
	else
	{
		if (symbol == market)
	   {
	      market_pass = true;
	   }
      else
      {
			if (market0 != market)
			{
				market0 = market;

				if (market == "")
				{
					markets_size = 1;
					ArrayResize(markets, 1);
					markets[0] = Symbol();
				}
				else
				{
					StringExplode(",", market, markets);
					markets_size = ArraySize(markets);

					for(i = 0; i < markets_size; i++)
					{
						markets[i] = StringTrimRight(markets[i]);
						markets[i] = StringTrimLeft(markets[i]);

						if (markets[i] == "") {markets[i] = Symbol();}
					}
				}
			}

			for(i = 0; i < markets_size; i++)
			{
				if (symbol == markets[i])
				{
					market_pass = true;

					break;
				}
			}
		}
	}

	if (market_pass == false)
	{
		return false;
	}

	return true;
}

bool HistoryTradeSelectByIndex(
	int index,
	string group_mode    = "all",
	string group         = "0",
	string market_mode   = "all",
	string market        = "",
	string BuysOrSells   = "both"
) {
	if (OrderSelect((int)index, SELECT_BY_POS, MODE_HISTORY) && OrderType() < 2)
	{
		if (FilterOrderBy(
			group_mode,
			group,
			market_mode,
			market,
			BuysOrSells)
		) {
			return true;
		}
	}

	return false;
}

int HistoryTradesTotal(datetime from_date=0, datetime to_date=0)
{
	// both input parameters are dummy
	// they exist only to make the function compatible with MQL5-like code

	return OrdersHistoryTotal();
}

template<typename T>
bool InArray(T &array[], T value)
{
	int size = ArraySize(array);

	if (size > 0)
	{
		for (int i = 0; i < size; i++)
		{
			if (array[i] == value)
			{
				return true;
			}
		}
	}

	return false;
}

bool IsOrderTypeBuy()
{
	int type = OrderType();

	return (type == OP_BUY || type == OP_BUYSTOP || type == OP_BUYLIMIT);
}

bool IsOrderTypeSell()
{
	int type = OrderType();

	return (type == OP_SELL || type == OP_SELLSTOP || type == OP_SELLLIMIT);
}

bool ModifyOrder(
	int ticket,
	double op,
	double sll = 0,
	double tpl = 0,
	double slp = 0,
	double tpp = 0,
	datetime exp = 0,
	color clr = clrNONE,
	bool ontrade_event = true
) {
	int bs = 1;

	if (
		   OrderType() == OP_SELL
		|| OrderType() == OP_SELLSTOP
		|| OrderType() == OP_SELLLIMIT
	)
	{bs = -1;} // Positive when Buy, negative when Sell

	while (true)
	{
		uint time0 = GetTickCount();

		WaitTradeContextIfBusy();

		if (!OrderSelect(ticket,SELECT_BY_TICKET))
		{
			return false;
		}

		string symbol      = OrderSymbol();
		int type           = OrderType();
		double ask         = SymbolInfoDouble(symbol, SYMBOL_ASK);
		double bid         = SymbolInfoDouble(symbol, SYMBOL_BID);
		int digits         = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
		double point       = SymbolInfoDouble(symbol, SYMBOL_POINT);
		double stoplevel   = point * SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
		double freezelevel = point * SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL);

		if (OrderType() < 2) {op = OrderOpenPrice();} else {op = NormalizeDouble(op,digits);}

		sll = NormalizeDouble(sll, digits);
		tpl = NormalizeDouble(tpl, digits);

		if (op < 0 || op >= EMPTY_VALUE || sll < 0 || slp < 0 || tpl < 0 || tpp < 0)
		{
			break;
		}
		
		//-- OP -----------------------------------------------------------
		// https://book.mql4.com/appendix/limits
		if (type == OP_BUYLIMIT)
		{
			if (ask - op < stoplevel) {op = ask - stoplevel;}
			if (ask - op <= freezelevel) {op = ask - freezelevel - point;}
		}
		else if (type == OP_BUYSTOP)
		{
			if (op - ask < stoplevel) {op = ask + stoplevel;}
			if (op - ask <= freezelevel) {op = ask + freezelevel + point;}
		}
		else if (type == OP_SELLLIMIT)
		{
			if (op - bid < stoplevel) {op = bid + stoplevel;}
			if (op - bid <= freezelevel) {op = bid + freezelevel + point;}
		}
		else if (type == OP_SELLSTOP)
		{
			if (bid - op < stoplevel) {op = bid - stoplevel;}
			if (bid - op < freezelevel) {op = bid - freezelevel - point;}
		}

		op = NormalizeDouble(op, digits);

		//-- SL and TP ----------------------------------------------------
		double sl = 0, tp = 0, vsl = 0, vtp = 0;

		sl = AlignStopLoss(symbol, type, op, attrStopLoss(), sll, slp);

		if (sl < 0) {break;}

		tp = AlignTakeProfit(symbol, type, op, attrTakeProfit(), tpl, tpp);

		if (tp < 0) {break;}

		if (USE_VIRTUAL_STOPS)
		{
			//-- virtual SL and TP --------------------------------------------
			vsl = sl;
			vtp = tp;
			sl = 0;
			tp = 0;

			double askbid = ask;
			if (bs < 0) {askbid = bid;}

			if (vsl > 0 || USE_EMERGENCY_STOPS == "always")
			{
				if (EMERGENCY_STOPS_REL > 0 || EMERGENCY_STOPS_ADD > 0)
				{
					sl = vsl - EMERGENCY_STOPS_REL*MathAbs(askbid-vsl)*bs;

					if (sl <= 0) {sl = askbid;}

					sl = sl - toDigits(EMERGENCY_STOPS_ADD,symbol)*bs;
				}
			}

			if (vtp > 0 || USE_EMERGENCY_STOPS == "always")
			{
				if (EMERGENCY_STOPS_REL > 0 || EMERGENCY_STOPS_ADD > 0)
				{
					tp = vtp + EMERGENCY_STOPS_REL*MathAbs(vtp-askbid)*bs;

					if (tp <= 0) {tp = askbid;}

					tp = tp + toDigits(EMERGENCY_STOPS_ADD,symbol)*bs;
				}
			}

			vsl = NormalizeDouble(vsl,digits);
			vtp = NormalizeDouble(vtp,digits);
		}

		sl = NormalizeDouble(sl,digits);
		tp = NormalizeDouble(tp,digits);

		//-- modify -------------------------------------------------------
		ResetLastError();
		
		if (USE_VIRTUAL_STOPS)
		{
			if (vsl != attrStopLoss() || vtp != attrTakeProfit())
			{
				VirtualStopsDriver("set", ticket, vsl, vtp, toPips(MathAbs(op-vsl), symbol), toPips(MathAbs(vtp-op), symbol));
			}
		}

		bool success = false;

		if (
			   (OrderType() > 1 && op != NormalizeDouble(OrderOpenPrice(),digits))
			|| sl != NormalizeDouble(OrderStopLoss(),digits)
			|| tp != NormalizeDouble(OrderTakeProfit(),digits)
			|| exp != OrderExpiration()
		) {
			success = OrderModify(ticket, op, sl, tp, exp, clr);
		}

		//-- error check --------------------------------------------------
		int erraction = CheckForTradingError(GetLastError(), "Modify error");

		switch(erraction)
		{
			case 0: break;    // no error
			case 1: continue; // overcomable error
			case 2: break;    // fatal error
		}

		//-- finish work --------------------------------------------------
		if (success == true)
		{
			if (!IsTesting() && !IsVisualMode())
			{
				Print("Operation details: Speed " + (string)(GetTickCount()-time0) + " ms");
			}

			if (ontrade_event == true)
			{
				OrderModified(ticket);
				RegisterEvent("trade");
			}

			if (OrderSelect(ticket,SELECT_BY_TICKET)) {}

			return true;
		}

		break;
	}

	return false;
}

int OCODriver()
{
	static int last_known_ticket = 0;
   static int orders1[];
   static int orders2[];
   int i, size;
   
   int total = OrdersTotal();
   
   for (int pos=total-1; pos>=0; pos--)
   {
      if (OrderSelect(pos,SELECT_BY_POS,MODE_TRADES))
      {
         int ticket = OrderTicket();
         
         //-- end here if we reach the last known ticket
         if (ticket == last_known_ticket) {break;}
         
         //-- set the last known ticket, only if this is the first iteration
         if (pos == total-1) {
            last_known_ticket = ticket;
         }
         
         //-- we are searching for pending orders, skip trades
         if (OrderType() <= OP_SELL) {continue;}
         
         //--
         if (StringSubstr(OrderComment(), 0, 5) == "[oco:")
         {
            int ticket_oco = StrToInteger(StringSubstr(OrderComment(), 5, StringLen(OrderComment())-1)); 
            
            bool found = false;
            size = ArraySize(orders2);
            for (i=0; i<size; i++)
            {
               if (orders2[i] == ticket_oco) {
                  found = true;
                  break;
               }
            }
            
            if (found == false) {
               ArrayResize(orders1, size+1);
               ArrayResize(orders2, size+1);
               orders1[size] = ticket_oco;
               orders2[size] = ticket;
            }
         }
      }
   }
   
   size = ArraySize(orders1);
   int dbremove = false;
   for (i=size-1; i>=0; i--)
   {
      if (OrderSelect(orders1[i], SELECT_BY_TICKET, MODE_TRADES) == false || OrderType() <= OP_SELL)
      {
         if (OrderSelect(orders2[i], SELECT_BY_TICKET, MODE_TRADES)) {
            if (DeleteOrder(orders2[i],clrWhite))
            {
               dbremove = true;
            }
         }
         else {
            dbremove = true;
         }
         
         if (dbremove == true)
         {
            ArrayStripKey(orders1, i);
            ArrayStripKey(orders2, i);
         }
      }
   }
   
   size = ArraySize(orders2);
   dbremove = false;
   for (i=size-1; i>=0; i--)
   {
      if (OrderSelect(orders2[i], SELECT_BY_TICKET, MODE_TRADES) == false || OrderType() <= OP_SELL)
      {
         if (OrderSelect(orders1[i], SELECT_BY_TICKET, MODE_TRADES)) {
            if (DeleteOrder(orders1[i],clrWhite))
            {
               dbremove = true;
            }
         }
         else {
            dbremove = true;
         }
         
         if (dbremove == true)
         {
            ArrayStripKey(orders1, i);
            ArrayStripKey(orders2, i);
         }
      }
   }
   
   return true;
}

bool OnTimerSet(double seconds)
{
   if (FXD_ONTIMER_TAKEN)
   {
      if (seconds<=0) {
         FXD_ONTIMER_TAKEN_IN_MILLISECONDS = false;
         FXD_ONTIMER_TAKEN_TIME = 0;
      }
      else if (seconds < 1) {
         FXD_ONTIMER_TAKEN_IN_MILLISECONDS = true;
         FXD_ONTIMER_TAKEN_TIME = seconds*1000; 
      }
      else {
         FXD_ONTIMER_TAKEN_IN_MILLISECONDS = false;
         FXD_ONTIMER_TAKEN_TIME = seconds;
      }
      
      return true;
   }

   if (seconds<=0) {
      EventKillTimer();
   }
   else if (seconds < 1) {
      return (EventSetMillisecondTimer((int)(seconds*1000)));  
   }
   else {
      return (EventSetTimer((int)seconds));
   }
   
   return true;
}

void OnTradeListener()
{
	static datetime start_time = -1;
	static int    memory_ti[]; // memory of tickets
	static int    memory_ty[]; // memory of types
	static double memory_sl[];
	static double memory_tp[];
	static double memory_vl[];
	static double memory_op[];
	static bool loaded = false;

	if (!ENABLE_EVENT_TRADE) {return;}

	int tn          = 0;  // ticket now (index)
	int ti          = -1; // ticket
	int ty          = -1; // type
	int size        = -1;
	int pos         = 0;
	string e_reason = "";
	string e_detail = "";
	int i = -1, j = -1, k = -1;
	int tickets_now[];
	

	if (start_time == -1) {start_time = TimeCurrent();}

	//-- TRADES AND ORDERS
	ArrayResize(tickets_now, 0);

	int total = OrdersTotal();

	// initial fill of the local DB
	if (loaded == false)
	{
		loaded = true;

		for (pos = total-1; pos >= 0; pos--)
		{
			if (OrderSelect(pos, SELECT_BY_POS, MODE_TRADES))
			{
				ArrayResize(memory_ti, tn+1);
				ArrayResize(memory_ty, tn+1);
				ArrayResize(memory_sl, tn+1);
				ArrayResize(memory_tp, tn+1);
				ArrayResize(memory_vl, tn+1);
				ArrayResize(memory_op, tn+1);
				memory_ti[tn] = OrderTicket();
				memory_ty[tn] = OrderType();
				memory_sl[tn] = attrStopLoss();
				memory_tp[tn] = attrTakeProfit();
				memory_vl[tn] = OrderLots();
				memory_op[tn] = OrderOpenPrice();

				tn++;
			}
		}

		return;
	}

	tn = 0;

	bool pending_opens = false;

	for (pos = total-1; pos >= 0; pos--)
	{
		if (OrderSelect(pos, SELECT_BY_POS, MODE_TRADES))
		{
			ArrayResize(tickets_now, tn+1);
			tickets_now[tn] = OrderTicket();
			tn++;

			// Trades and Orders
			i    = -1;
			ti   = -1;
			ty   = -1;
			size = ArraySize(memory_ti);

			if (size > 0)
			{
				for (i = 0; i < size; i++)
				{
					if (memory_ti[i] == OrderTicket())
					{
						if (memory_ty[i] == OrderType())
						{
							ty = OrderType();
						}
						else
						{
							pending_opens = true;
						}

						ti = OrderTicket();

						break;
				  }
			  }
			}

			// Order become a trade
			if (ti > 0 && ty < 0)
			{
				memory_ti[i] = OrderTicket();
				memory_ty[i] = OrderType();

				memory_sl[i] = attrStopLoss();
				memory_tp[i] = attrTakeProfit();
				memory_vl[i] = OrderLots();
				memory_op[i] = OrderOpenPrice();

				e_reason = "new";
				e_detail = "";

				break;
			}

			// New trade/order opened
			else if (ti < 0 && ty < 0)
			{
				ArrayResize(memory_ti, size+1); memory_ti[size] = OrderTicket();
				ArrayResize(memory_ty, size+1); memory_ty[size] = OrderType();
				ArrayResize(memory_sl, size+1); memory_sl[size] = attrStopLoss();
				ArrayResize(memory_tp, size+1); memory_tp[size] = attrTakeProfit();
				ArrayResize(memory_vl, size+1); memory_vl[size] = OrderLots();
				ArrayResize(memory_op, size+1); memory_op[size] = OrderOpenPrice();

				e_reason = "new";
				e_detail = "";

				break;
			}

			// Check for Lots, SL or TP modification
			else if (ty >= 0 && i > -1)
			{
				if (memory_vl[i] != OrderLots())
				{
					memory_vl[i] = OrderLots();
					e_reason = "modify";
					e_detail = "lots";

					break;
				}
				else if (memory_op[i] != OrderOpenPrice())
				{
					memory_op[i] = OrderOpenPrice();
					memory_sl[i] = attrStopLoss();
					memory_tp[i] = attrTakeProfit();
					e_reason = "modify";
					e_detail = "move";

					break;
				}
				else
				{
					if (memory_sl[i] != attrStopLoss() && memory_tp[i] != attrTakeProfit())
					{
						memory_sl[i] = attrStopLoss();
						memory_tp[i] = attrTakeProfit();
						e_reason = "modify";
						e_detail = "sltp";

						break;
					}
					else if (memory_sl[i] != attrStopLoss())
					{
						memory_sl[i] = attrStopLoss();
						e_reason = "modify";
						e_detail = "sl";

						break;
					}
				  	else if (memory_tp[i] != attrTakeProfit())
				  	{
				  		memory_tp[i] = attrTakeProfit();
				  		e_reason = "modify";
				  		e_detail = "tp";

						break;
				  	}
				}
			}
		}
	}

	// Check for closed orders/trades
	bool missing = true;

	if (
		   e_reason == ""
		&& pending_opens == false
		&& ArraySize(tickets_now) < ArraySize(memory_ti)
	)
	{
		// for each ticket in the memory check if trade exists now
		for(i = ArraySize(memory_ti)-1; i >= 0; i--)
		{
			for(j = 0; j < ArraySize(tickets_now); j++)
			{
				if (memory_ti[i] == tickets_now[j])
				{
					missing = false;

					break;
				}
			}

			if (missing == true)
			{
				if (OrderSelect(memory_ti[i], SELECT_BY_TICKET))
				{
					// This can happen more than once
					ArrayStripKey(memory_ti, i);
					ArrayStripKey(memory_ty, i);
					ArrayStripKey(memory_sl, i);
					ArrayStripKey(memory_tp, i);
					ArrayStripKey(memory_vl, i);
					ArrayStripKey(memory_op, i);

					e_reason = "close";
					e_detail = "";
					
					if (
						   StringFind(OrderComment(), "expiration") >= 0
						|| StringFind(OrderComment(), "[exp:") >= 0
					)
					{
						e_detail = "expire";
					}

					// remove virtual stops lines
					if (USE_VIRTUAL_STOPS)
					{
						ObjectDelete("#" + (string)OrderTicket() + " sl");
						ObjectDelete("#" + (string)OrderTicket() + " tp");
					}

					break;
				}
			}

			missing = true;
		}
	}

	if (e_reason != "")
	{
		UpdateEventValues(e_reason, e_detail);
		EventTrade();
		OnTradeListener();
	}
	
	return;
}

int OnTradeQueue(int queue=0)
{
   static int mem=0;
   mem=mem+queue;
   return(mem);
}

int OrderCreate(
   string symbol="",
   int    type=OP_BUY,
   double lots=0,
   double op=0,
   double sll=0, // SL level
   double tpl=0, // TO level
   double slp=0, // SL adjust in points
   double tpp=0, // TP adjust in points
   double slippage=0,
   int    magic=0,
   string comment="",
   color  arrowcolor=CLR_NONE,
   datetime expiration=0,
   bool oco = false
   )
{
   uint time0=GetTickCount();
   
   int ticket=-1;
   int bs=1;
   if (
         type==OP_SELL
      || type==OP_SELLSTOP
      || type==OP_SELLLIMIT
      ) {bs=-1;} // Positive when Buy, negative when Sell
   
   if (symbol=="") {symbol=Symbol();}

   lots=AlignLots(symbol, lots);
   
   int digits = 0;
   double ask=0, bid=0, point=0, ticksize=0;
   double sl=0, tp=0;
	double vsl=0, vtp=0;

   //-- attempt to send trade/order -------------------------------------
   while(!IsStopped())
   {
      //Print(sll+" "+tpl+" "+slp+" "+tpp);
      WaitTradeContextIfBusy();
      
      static bool not_allowed_message = false;
      if (!MQLInfoInteger(MQL_TESTER) && !MarketInfo(symbol, MODE_TRADEALLOWED)) {
         if (not_allowed_message == false) {
            Print("Market ("+symbol+") is closed");
         }
         not_allowed_message = true;
         return(false);
      }
      not_allowed_message = false;
      
      digits  = (int)MarketInfo(symbol,MODE_DIGITS);
      ask     = MarketInfo(symbol,MODE_ASK);
      bid     = MarketInfo(symbol,MODE_BID);
      point   = MarketInfo(symbol,MODE_POINT);
      ticksize= MarketInfo(symbol, MODE_TICKSIZE);
      
      //- not enough money check: fix maximum possible lot by margin required, or quit
      if (type==OP_BUY || type==OP_SELL)
      {
         double LotStep          = MarketInfo(symbol,MODE_LOTSTEP);
         double MinLots          = MarketInfo(symbol,MODE_MINLOT);
         double margin_required  = MarketInfo(symbol,MODE_MARGINREQUIRED);
         static bool not_enough_message = false;
         
         if (margin_required != 0)
         {
            double max_size_by_margin = AccountFreeMargin()/margin_required;
         
            if (lots > max_size_by_margin) {
               double size_old = lots;
               lots = max_size_by_margin;
               if (lots<MinLots)
               {
                  if (not_enough_message==false) {
                     Print("Not enough money to trade :( The robot is still working, waiting for some funds to appear...");
                  }
                  not_enough_message = true;
                  return(false);
               }
               else
               {
                  lots = MathFloor(lots/LotStep)*LotStep;
                  Print("Not enough money to trade "+DoubleToString(size_old, 2)+", the volume to trade will be the maximum possible of "+DoubleToString(lots, 2));
               }
            }
         }
         not_enough_message = false;
      }
		
		// fix the comment, because it seems that the comment is deleted if its lenght is > 31 symbols
		if (StringLen(comment) > 31)
		{
			comment = StringSubstr(comment,0,31);
		}
      
      //- expiration for trades
      if (type==OP_BUY || type==OP_SELL)
      {
         if (expiration > 0)
         {
            //- convert UNIX to seconds
            if (expiration > TimeCurrent()-100) {
               expiration = expiration - TimeCurrent();
            }
            
            //- bo broker?
            if (StringLen(symbol)>6 && StringSubstr(symbol, StringLen(symbol)-2)=="bo") {
               comment = "BO exp:"+(string)expiration;
            }
            else {
               string expiration_str   = "[exp:"+IntegerToString(expiration)+"]";
               int expiration_len      = StringLen(expiration_str);
               int comment_len         = StringLen(comment);
               if (comment_len > (27-expiration_len))
               {
                  comment = StringSubstr(comment, 0, (27-expiration_len));
               }
               comment = comment + expiration_str;
            }
         }
      }

      if (type==OP_BUY || type==OP_SELL)
      {
         op=ask;
         if (bs<0) {
           op=bid;
         }
      }
      
      op    = NormalizeDouble(op, digits);
      sll   = NormalizeDouble(sll,digits);
      tpl   = NormalizeDouble(tpl,digits);
      if (op<0 || op>=EMPTY_VALUE)  {break;}
      if (sll<0 || slp<0 || tpl<0 || tpp<0) {break;}

      //-- SL and TP ----------------------------------------------------
      vsl=0; vtp=0;
      
      sl=AlignStopLoss(symbol, type, op, 0, NormalizeDouble(sll,digits), slp);
      if (sl<0) {break;}
      tp=AlignTakeProfit(symbol, type, op, 0, NormalizeDouble(tpl,digits), tpp);
      if (tp<0) {break;}
      
      if (USE_VIRTUAL_STOPS)
      {
         //-- virtual SL and TP --------------------------------------------
         vsl=sl;
         vtp=tp;
         sl=0; tp=0;
         
         double askbid=ask;
         if (bs<0) {askbid=bid;}
         
         if (vsl>0 || USE_EMERGENCY_STOPS=="always") {
            if (EMERGENCY_STOPS_REL>0 || EMERGENCY_STOPS_ADD>0)
            {
               sl=vsl-EMERGENCY_STOPS_REL*MathAbs(askbid-vsl)*bs;
               if (sl<=0) {sl=askbid;}
               sl=sl-toDigits(EMERGENCY_STOPS_ADD,symbol)*bs;
            }
         }
         if (vtp>0 || USE_EMERGENCY_STOPS=="always") {
            if (EMERGENCY_STOPS_REL>0 || EMERGENCY_STOPS_ADD>0)
            {
               tp=vtp+EMERGENCY_STOPS_REL*MathAbs(vtp-askbid)*bs;
               if (tp<=0) {tp=askbid;}
               tp=tp+toDigits(EMERGENCY_STOPS_ADD,symbol)*bs;
            }
         }
         vsl=NormalizeDouble(vsl,digits);
         vtp=NormalizeDouble(vtp,digits);
      }
      
      sl=NormalizeDouble(sl,digits);
      tp=NormalizeDouble(tp,digits);

      //-- fix expiration for pending orders ----------------------------
      if (expiration>0 && type>OP_SELL) {
         if ((expiration-TimeCurrent())<(11*60)) {
            Print("Expiration time cannot be less than 11 minutes, so it was automatically modified to 11 minutes.");
            expiration=TimeCurrent()+(11*60);
         }
      }
      
      //-- fix prices by ticksize
      op = MathRound(op/ticksize)*ticksize;
      sl = MathRound(sl/ticksize)*ticksize;
      tp = MathRound(tp/ticksize)*ticksize;

      //-- send ---------------------------------------------------------
      ResetLastError();
      ticket = OrderSend(symbol,type,lots,op,(int)(slippage*PipValue(symbol)),sl,tp,comment,magic,expiration,arrowcolor);

      //-- error check --------------------------------------------------
      string msg_prefix="New trade error";
      if (type>OP_SELL) {msg_prefix="New order error";}
      int erraction=CheckForTradingError(GetLastError(), msg_prefix);
      switch(erraction)
      {
         case 0: break;    // no error
         case 1: continue; // overcomable error
         case 2: break;    // fatal error
      }
      
      //-- finish work --------------------------------------------------
      if (ticket>0) {
         if (USE_VIRTUAL_STOPS) {
            VirtualStopsDriver("set", ticket, vsl, vtp, toPips(MathAbs(op-vsl), symbol), toPips(MathAbs(vtp-op), symbol));
         }
         
         //-- show some info
         double slip=0;
         if (OrderSelect(ticket,SELECT_BY_TICKET)) {
            if (!MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE) &&!MQLInfoInteger(MQL_OPTIMIZATION))
				{
               slip=OrderOpenPrice()-op;
					string print = "";
               print = StringConcatenate(
                  "Operation details: Speed ",
                  (GetTickCount()-time0),
                  " ms | Slippage ",
                  DoubleToStr(toPips(slip, symbol),1),
                  " pips"
               );
					Print(print);
            }
         }
         
         //-- fix stops in case of slippage
         if (!MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE) &&!MQLInfoInteger(MQL_OPTIMIZATION))
         {
            slip = NormalizeDouble(OrderOpenPrice(), digits) - NormalizeDouble(op, digits);
            if (slip != 0 && (OrderStopLoss()!=0 || OrderTakeProfit()!=0))
            {
               Print("Correcting stops because of slippage...");
               sl = OrderStopLoss();
               tp = OrderTakeProfit();
               if (sl != 0 || tp != 0)
               {
                  if (sl != 0) {sl = NormalizeDouble(OrderStopLoss()+slip, digits);}
                  if (tp != 0) {tp = NormalizeDouble(OrderTakeProfit()+slip, digits);}
                  ModifyOrder(ticket, OrderOpenPrice(), sl, tp, 0, 0, 0, CLR_NONE, false);
               }
            }
         }
         
         RegisterEvent("trade");
         break;
      }
      
      break;
   }
   
   if (oco == true && ticket > 0)
   {
      if (USE_VIRTUAL_STOPS) {
         sl = vsl;
         tp = vtp;
      }
      
      sl = (sl > 0) ? NormalizeDouble(MathAbs(op-sl), digits) : 0;
      tp = (tp > 0) ? NormalizeDouble(MathAbs(op-tp), digits) : 0;
      
      int typeoco = type;
      if (typeoco == OP_BUYSTOP) {
         typeoco = OP_SELLSTOP;
         op = bid - MathAbs(op-ask);
      }
      else if (typeoco == OP_BUYLIMIT) {
         typeoco = OP_SELLLIMIT;
         op = bid + MathAbs(op-ask);
      }
      else if (typeoco == OP_SELLSTOP) {
         typeoco = OP_BUYSTOP;
         op = ask + MathAbs(op-bid);
      }
      else if (typeoco == OP_SELLLIMIT) {
         typeoco = OP_BUYLIMIT;
         op = ask - MathAbs(op-bid);
      }
      
      if (typeoco == OP_BUYSTOP || typeoco == OP_BUYLIMIT)
      {
         sl = (sl > 0) ? op - sl : 0;
         tp = (tp > 0) ? op + tp : 0;
         arrowcolor = clrBlue;
      }
      else {
         sl = (sl > 0) ? op + sl : 0;
         tp = (tp > 0) ? op - tp : 0;
         arrowcolor = clrRed;
      }
         
      comment = "[oco:"+(string)ticket+"]";
      
      OrderCreate(symbol,typeoco,lots,op,sl,tp,0,0,slippage,magic,comment,arrowcolor,expiration,false);
   }
   
   return(ticket);
}



bool OrderModified(ulong ticket = 0, string action = "set")
{
	static ulong memory[];

	if (ticket == 0)
	{
		ticket = OrderTicket();
		action = "get";
	}
	else if (ticket > 0 && action != "clear")
	{
		action = "set";
	}

	bool modified_status = InArray(memory, ticket);
	
	if (action == "get")
	{
		return modified_status;
	}
	else if (action == "set")
	{
		ArrayEnsureValue(memory, ticket);

		return true;
	}
	else if (action == "clear")
	{
		ArrayStripValue(memory, ticket);

		return true;
	}

	return false;
}

bool PendingOrderSelectByIndex(
	int index,
	string group_mode    = "all",
	string group         = "0",
	string market_mode   = "all",
	string market        = "",
	string BuysOrSells   = "both",
	string LimitsOrStops = "both"
)
{
	if (OrderSelect(index, SELECT_BY_POS, MODE_TRADES))
	{
		if (FilterOrderBy(
			group_mode,
			group,
			market_mode,
			market,
			BuysOrSells,
			LimitsOrStops,
			1)
		) {
			return true;
		}
	}

	return false;
}

bool PendingOrderSelectByTicket(ulong ticket)
{
	if (OrderSelect((int)ticket, SELECT_BY_TICKET, MODE_TRADES) && OrderType() > 1)
	{
		return true;
	}

	return false;
}

double PipValue(string symbol)
{
	if (symbol == "") symbol = Symbol();

	return CustomPoint(symbol) / SymbolInfoDouble(symbol, SYMBOL_POINT);
}

// Collect events, if any
void RegisterEvent(string command="")
{
   int ticket=OrderTicket();
	OnTradeListener();
   ticket=OrderSelect(ticket,SELECT_BY_TICKET);
   return;
}

int SecondsFromComponents(double days, double hours, double minutes, int seconds)
{
	int retval =
		86400 * (int)MathFloor(days)
		+ 3600 * (int)(MathFloor(hours) + (24 * (days - MathFloor(days))))
		+ 60 * (int)(MathFloor(minutes) + (60 * (hours - MathFloor(hours))))
		+ (int)((double)seconds + (60 * (minutes - MathFloor(minutes))));

	return retval;
}

int SellLater(
	string symbol,
	double lots,
	double price,
	double sll = 0, // SL level
	double tpl = 0, // TP level
	double slp = 0, // SL adjust in points
	double tpp = 0, // TP adjust in points
	double slippage = 0,
	datetime expiration = 0,
	int magic = 0,
	string comment = "",
	color arrowcolor = clrNONE,
	bool oco = false
	)
{
	double bid = SymbolInfoDouble(symbol,SYMBOL_BID);
	int type = 0;

		  if (price == bid) {type = OP_SELL;}
	else if (price < bid)  {type = OP_SELLSTOP;}
	else if (price > bid)  {type = OP_SELLLIMIT;}
	
	return OrderCreate(
		symbol,
		type,
		lots,
		price,
		sll,
		tpl,
		slp,
		tpp,
		slippage,
		magic,
		comment,
		arrowcolor,
		expiration,
		oco
	);
}

int SellNow(
	string symbol,
	double lots,
	double sll,
	double tpl,
	double slp,
	double tpp,
	double slippage = 0,
	int magic = 0,
	string comment = "",
	color arrowcolor = clrNONE,
	datetime expiration = 0
	)
{
	return OrderCreate(
		symbol,
		OP_SELL,
		lots,
		0,
		sll,
		tpl,
		slp,
		tpp,
		slippage,
		magic,
		comment,
		arrowcolor,
		expiration
	);
}

template<typename T>
void StringExplode(string delimiter, string inputString, T &output[])
{
	int begin   = 0;
	int end     = 0;
	int element = 0;
	int length  = StringLen(inputString);
	int length_delimiter = StringLen(delimiter);
	T empty_val  = (typename(T) == "string") ? (T)"" : (T)0;

	if (length > 0)
	{
		while (true)
		{
			end = StringFind(inputString, delimiter, begin);

			ArrayResize(output, element + 1);
			output[element] = empty_val;
	
			if (end != -1)
			{
				if (end > begin)
				{
					output[element] = (T)StringSubstr(inputString, begin, end - begin);
				}
			}
			else
			{
				output[element] = (T)StringSubstr(inputString, begin, length - begin);
				break;
			}
			
			begin = end + 1 + (length_delimiter - 1);
			element++;
		}
	}
	else
	{
		ArrayResize(output, 1);
		output[element] = empty_val;
	}
}

template<typename T>
string StringImplode(string delimeter, T &array[])
{
   string retval = "";
   int size      = ArraySize(array);

   for (int i = 0; i < size; i++)
	{
      retval = StringConcatenate(retval, (string)array[i], delimeter);
   }
	
   return StringSubstr(retval, 0, (StringLen(retval) - StringLen(delimeter)));
}

datetime StringToTimeEx(string str, string mode="server")
{
	// mode: server, local, gmt
	if (StringFind(str, " ") != -1) {
	   return StringToTime(str);
	}
	
	datetime now = 0;
	datetime retval = 0;
	
	if (mode == "server") {now = TimeCurrent();}
	else if (mode == "local") {now = TimeLocal();}
	else if (mode == "gmt") {now = TimeGMT();}
	
	return StringToTime((string)TimeYear(now)+"."+(string)TimeMonth(now)+"."+(string)TimeDay(now)+" "+str);
}

string StringTrim(string text)
{
   text = StringTrimRight(text);
   text = StringTrimLeft(text);
	
	return text;
}

double SymbolAsk(string symbol)
{
	if (symbol == "") symbol = Symbol();

	return SymbolInfoDouble(symbol, SYMBOL_ASK);
}

double SymbolBid(string symbol)
{
	if (symbol == "") symbol = Symbol();

	return SymbolInfoDouble(symbol, SYMBOL_BID);
}

int SymbolDigits(string symbol)
{
	if (symbol == "") symbol = Symbol();

	return (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
}

double TicksData(string symbol = "", int type = 0, int shift = 0)
{
	static bool collecting_ticks = false;
	static string symbols[];
	static int zero_sid[];
	static double memoryASK[][100];
	static double memoryBID[][100];

	int sid = 0, size = 0, i = 0, id = 0;
	double ask = 0, bid = 0, retval = 0;
	bool exists = false;

	if (ArraySize(symbols) == 0)
	{
		ArrayResize(symbols, 1);
		ArrayResize(zero_sid, 1);
		ArrayResize(memoryASK, 1);
		ArrayResize(memoryBID, 1);

		symbols[0] = _Symbol;
	}

	if (type > 0 && shift > 0)
	{
		collecting_ticks = true;
	}

	if (collecting_ticks == false)
	{
		if (type > 0 && shift == 0)
		{
			// going to get ticks
		}
		else
		{
			return 0;
		}
	}

	if (symbol == "") symbol = _Symbol;

	if (type == 0)
	{
		exists = false;
		size   = ArraySize(symbols);

		if (size == 0) {ArrayResize(symbols, 1);}

		for (i=0; i<size; i++)
		{
			if (symbols[i] == symbol)
			{
				exists = true;
				sid    = i;
				break;
			}
		}

		if (exists == false)
		{
			int newsize = ArraySize(symbols) + 1;

			ArrayResize(symbols, newsize);
			symbols[newsize-1] = symbol;

			ArrayResize(zero_sid, newsize);
			ArrayResize(memoryASK, newsize);
			ArrayResize(memoryBID, newsize);

			sid=newsize;
		}

		if (sid >= 0)
		{
			ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
			bid = SymbolInfoDouble(symbol, SYMBOL_BID);

			if (bid == 0 && MQLInfoInteger(MQL_TESTER))
			{
				Print("Ticks data collector error: " + symbol + " cannot be backtested. Only the current symbol can be backtested. The EA will be terminated.");
				ExpertRemove();
			}

			if (
				   symbol == _Symbol
				|| ask != memoryASK[sid][0]
				|| bid != memoryBID[sid][0]
			)
			{
				memoryASK[sid][zero_sid[sid]] = ask;
				memoryBID[sid][zero_sid[sid]] = bid;
				zero_sid[sid]                 = zero_sid[sid] + 1;

				if (zero_sid[sid] == 100)
				{
					zero_sid[sid] = 0;
				}
			}
		}
	}
	else
	{
		if (shift <= 0)
		{
			if (type == SYMBOL_ASK)
			{
				return SymbolInfoDouble(symbol, SYMBOL_ASK);
			}
			else if (type == SYMBOL_BID)
			{
				return SymbolInfoDouble(symbol, SYMBOL_BID); 
			}
			else
			{
				double mid = ((SymbolInfoDouble(symbol, SYMBOL_ASK) + SymbolInfoDouble(symbol, SYMBOL_BID)) / 2);

				return mid;
			}
		}
		else
		{
			size = ArraySize(symbols);

			for (i = 0; i < size; i++)
			{
				if (symbols[i] == symbol)
				{
					sid = i;
				}
			}

			if (shift < 100)
			{
				id = zero_sid[sid] - shift - 1;

				if(id < 0) {id = id + 100;}

				if (type == SYMBOL_ASK)
				{
					retval = memoryASK[sid][id];

					if (retval == 0)
					{
						retval = SymbolInfoDouble(symbol, SYMBOL_ASK);
					}
				}
				else if (type == SYMBOL_BID)
				{
					retval = memoryBID[sid][id];

					if (retval == 0)
					{
						retval = SymbolInfoDouble(symbol, SYMBOL_BID);
					}
				}
			}
		}
	}

	return retval;
}

int TicksPerSecond(bool get_max = false, bool set = false)
{
	static datetime time0 = 0;
	static int ticks      = 0;
	static int tps        = 0;
	static int tpsmax     = 0;

	datetime time1 = TimeLocal();

	if (set == true)
	{
		if (time1 > time0)
		{
			if (time1 - time0 > 1)
			{
				tps = 0;
			}
			else
			{
				tps = ticks;
			}

			time0 = time1;
			ticks = 0;
		}

		ticks++;

		if (tps > tpsmax) {tpsmax = tps;}
	}

	if (get_max)
	{
		return tpsmax;
	}

	return tps;
}

datetime TimeAtStart(string cmd = "server")
{
	static datetime local  = 0;
	static datetime server = 0;

	if (cmd == "local")
	{
		return local;
	}
	else if (cmd == "server")
	{
		return server;
	}
	else if (cmd == "set")
	{
		local  = TimeLocal();
		server = TimeCurrent();
	}

	return 0;
}

datetime TimeFromComponents(
	int time_src = 0,
	int    y = 0,
	int    m = 0,
	double d = 0,
	double h = 0,
	double i = 0,
	int    s = 0
) {
	MqlDateTime tm;

	     if (time_src == 0) {TimeCurrent(tm);}
	else if (time_src == 1) {TimeLocal(tm);}
	else if (time_src == 2) {TimeGMT(tm);}

	if (y > 0)
	{
		if (y < 100) {y = 2000 + y;}
		tm.year = y;
	}
	if (m > 0) {tm.mon = m;}
	if (d > 0) {tm.day = (int)MathFloor(d);}

	tm.hour = (int)(MathFloor(h) + (24 * (d - MathFloor(d))));
	tm.min  = (int)(MathFloor(i) + (60 * (h - MathFloor(h))));
	tm.sec  = (int)((double)s + (60 * (i - MathFloor(i))));

	return StructToTime(tm);
}

bool TradeSelectByIndex(
	int index,
	string group_mode    = "all",
	string group         = "0",
	string market_mode   = "all",
	string market        = "",
	string BuysOrSells   = "both"
) {
	if (OrderSelect((int)index, SELECT_BY_POS, MODE_TRADES) && OrderType() < 2)
	{
		if (FilterOrderBy(
			group_mode,
			group,
			market_mode,
			market,
			BuysOrSells,
			"both",
			0)
		) {
			return true;
		}
	}

	return false;
}

bool TradeSelectByTicket(ulong ticket)
{
	if (OrderSelect((int)ticket, SELECT_BY_TICKET, MODE_TRADES) && OrderType() < 2)
	{
		return true;
	}

	return false;
}

int TradesTotal()
{
	return OrdersTotal();
}

void UpdateEventValues(string e_reason = "",string e_detail = "")
{
	OnTradeQueue(1);
	e_Reason       (true, e_reason);
	e_ReasonDetail (true, e_detail);

	e_attrClosePrice  (true, OrderClosePrice());
	e_attrCloseTime   (true, OrderCloseTime());
	e_attrComment     (true, OrderComment());
	e_attrCommission  (true, OrderCommission());
	e_attrExpiration  (true, OrderExpiration());
	e_attrLots        (true, OrderLots());
	e_attrMagicNumber (true, OrderMagicNumber());
	e_attrOpenPrice   (true, OrderOpenPrice());
	e_attrOpenTime    (true, OrderOpenTime());
	e_attrProfit      (true, OrderProfit());
	e_attrStopLoss    (true, attrStopLoss());
	e_attrSwap        (true, OrderSwap());
	e_attrSymbol      (true, OrderSymbol());
	e_attrTakeProfit  (true, attrTakeProfit());
	e_attrTicket      (true, OrderTicket());
	e_attrType        (true, OrderType());
}

double VirtualStopsDriver(
	string command = "",
	ulong ti       = 0,
	double sl      = 0,
	double tp      = 0,
	double slp     = 0,
	double tpp     = 0
)
{
	static bool initialized     = false;
	static string name          = "";
	static string loop_name[2]  = {"sl", "tp"};
	static color  loop_color[2] = {DeepPink, DodgerBlue};
	static double loop_price[2] = {0, 0};
	static ulong mem_to_ti[]; // tickets
	static int mem_to[];      // timeouts
	static bool trade_pass = false;
	int i = 0;

	// Are Virtual Stops even enabled?
	if (!USE_VIRTUAL_STOPS)
	{
		return 0;
	}
	
	if (initialized == false || command == "initialize")
	{
		initialized = true;
	}

	// Listen
	if (command == "" || command == "listen")
	{
		int total     = ObjectsTotal(0, -1, OBJ_HLINE);
		int length    = 0;
		color clr     = clrNONE;
		int sltp      = 0;
		ulong ticket  = 0;
		double level  = 0;
		double askbid = 0;
		int polarity  = 0;
		string symbol = "";

		for (i = total - 1; i >= 0; i--)
		{
			name = ObjectName(0, i, -1, OBJ_HLINE); // for example: #1 sl

			if (StringSubstr(name, 0, 1) != "#")
			{
				continue;
			}

			length = StringLen(name);

			if (length < 5)
			{
				continue;
			}

			clr = (color)ObjectGetInteger(0, name, OBJPROP_COLOR);

			if (clr != loop_color[0] && clr != loop_color[1])
			{
				continue;
			}

			string last_symbols = StringSubstr(name, length-2, 2);

			if (last_symbols == "sl")
			{
				sltp = -1;
			}
			else if (last_symbols == "tp")
			{
				sltp = 1;
			}
			else
			{
				continue;	
			}

			ulong ticket0 = StringToInteger(StringSubstr(name, 1, length - 4));

			// prevent loading the same ticket number twice in a row
			if (ticket0 != ticket)
			{
				ticket = ticket0;

				if (TradeSelectByTicket(ticket))
				{
					symbol     = OrderSymbol();
					polarity   = (OrderType() == 0) ? 1 : -1;
					askbid   = (OrderType() == 0) ? SymbolInfoDouble(symbol, SYMBOL_BID) : SymbolInfoDouble(symbol, SYMBOL_ASK);
					
					trade_pass = true;
				}
				else
				{
					trade_pass = false;
				}
			}

			if (trade_pass)
			{
				level    = ObjectGetDouble(0, name, OBJPROP_PRICE, 0);

				if (level > 0)
				{
					// polarize levels
					double level_p  = polarity * level;
					double askbid_p = polarity * askbid;

					if (
						   (sltp == -1 && (level_p - askbid_p) >= 0) // sl
						|| (sltp == 1 && (askbid_p - level_p) >= 0)  // tp
					)
					{
						//-- Virtual Stops SL Timeout
						if (
							   (VIRTUAL_STOPS_TIMEOUT > 0)
							&& (sltp == -1 && (level_p - askbid_p) >= 0) // sl
						)
						{
							// start timeout?
							int index = ArraySearch(mem_to_ti, ticket);

							if (index < 0)
							{
								int size = ArraySize(mem_to_ti);
								ArrayResize(mem_to_ti, size+1);
								ArrayResize(mem_to, size+1);
								mem_to_ti[size] = ticket;
								mem_to[size]    = (int)TimeLocal();

								Print(
									"#",
									ticket,
									" timeout of ",
									VIRTUAL_STOPS_TIMEOUT,
									" seconds started"
								);

								return 0;
							}
							else
							{
								if (TimeLocal() - mem_to[index] <= VIRTUAL_STOPS_TIMEOUT)
								{
									return 0;
								}
							}
						}

						if (CloseTrade(ticket))
						{
							// check this before deleting the lines
							//OnTradeListener();

							// delete objects
							ObjectDelete(0, "#" + (string)ticket + " sl");
							ObjectDelete(0, "#" + (string)ticket + " tp");
						}
					}
					else
					{
						if (VIRTUAL_STOPS_TIMEOUT > 0)
						{
							i = ArraySearch(mem_to_ti, ticket);

							if (i >= 0)
							{
								ArrayStripKey(mem_to_ti, i);
								ArrayStripKey(mem_to, i);
							}
						}
					}
				}
			}
			else if (
					!PendingOrderSelectByTicket(ticket)
				|| OrderCloseTime() > 0 // in case the order has been closed
			)
			{
				ObjectDelete(0, name);
			}
			else
			{
				PendingOrderSelectByTicket(ticket);
			}
		}
	}
	// Get SL or TP
	else if (
		ti > 0
		&& (
			   command == "get sl"
			|| command == "get tp"
		)
	)
	{
		double value = 0;

		name = "#" + IntegerToString(ti) + " " + StringSubstr(command, 4, 2);

		if (ObjectFind(0, name) > -1)
		{
			value = ObjectGetDouble(0, name, OBJPROP_PRICE, 0);
		}

		return value;
	}
	// Set SL and TP
	else if (
		ti > 0
		&& (
			   command == "set"
			|| command == "modify"
			|| command == "clear"
			|| command == "partial"
		)
	)
	{
		loop_price[0] = sl;
		loop_price[1] = tp;

		for (i = 0; i < 2; i++)
		{
			name = "#" + IntegerToString(ti) + " " + loop_name[i];
			
			if (loop_price[i] > 0)
			{
				// 1) create a new line
				if (ObjectFind(0, name) == -1)
				{
						 ObjectCreate(0, name, OBJ_HLINE, 0, 0, loop_price[i]);
					ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
					ObjectSetInteger(0, name, OBJPROP_COLOR, loop_color[i]);
					ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
					ObjectSetString(0, name, OBJPROP_TEXT, name + " (virtual)");
				}
				// 2) modify existing line
				else
				{
					ObjectSetDouble(0, name, OBJPROP_PRICE, 0, loop_price[i]);
				}
			}
			else
			{
				// 3) delete existing line
				ObjectDelete(0, name);
			}
		}

		// print message
		if (command == "set" || command == "modify")
		{
			Print(
				command,
				" #",
				IntegerToString(ti),
				": virtual sl ",
				DoubleToStr(sl, (int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)),
				" tp ",
				DoubleToStr(tp,(int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS))
			);
		}

		return 1;
	}

	return 1;
}

void WaitTradeContextIfBusy()
{
	if(IsTradeContextBusy()) {
      while(true)
      {
         Sleep(1);
         if(!IsTradeContextBusy()) {
            RefreshRates();
            break;
         }
      }
   }
   return;
}

double attrStopLoss()
{
	if (USE_VIRTUAL_STOPS)
	{
		return VirtualStopsDriver("get sl", OrderTicket());
	}

	return OrderStopLoss();
}

double attrTakeProfit()
{
	if (USE_VIRTUAL_STOPS)
	{
		return VirtualStopsDriver("get tp", OrderTicket());
	}

   return OrderTakeProfit();
}

template<typename DT1, typename DT2>
bool compare(string sign, DT1 v1, DT2 v2)
{
	     if (sign == ">") return(v1 > v2);
	else if (sign == "<") return(v1 < v2);
	else if (sign == ">=") return(v1 >= v2);
	else if (sign == "<=") return(v1 <= v2);
	else if (sign == "==") return(v1 == v2);
	else if (sign == "!=") return(v1 != v2);
	else if (sign == "x>") return(v1 > v2);
	else if (sign == "x<") return(v1 < v2);

	return false;
}

string e_Reason(bool set=false, string inp="") {
   static string mem[];
   int queue=OnTradeQueue()-1;
   if(set==true){
      ArrayResize(mem,queue+1);
      mem[queue]=inp;
   }
   return(mem[queue]);
}

string e_ReasonDetail(bool set=false, string inp="") {static string mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}

double e_attrClosePrice(bool set=false, double inp=-1) {static double mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}

datetime e_attrCloseTime(bool set=false, datetime inp=-1) {static datetime mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}

string e_attrComment(bool set=false, string inp="") {static string mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}

double e_attrCommission(bool set=false, double inp=0) {static double mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}

datetime e_attrExpiration(bool set=false, datetime inp=0) {static datetime mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}

double e_attrLots(bool set=false, double inp=-1) {static double mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}

int e_attrMagicNumber(bool set=false, int inp=-1) {static int mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}

double e_attrOpenPrice(bool set=false, double inp=-1) {static double mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}

datetime e_attrOpenTime(bool set=false, datetime inp=-1) {static datetime mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}

double e_attrProfit(bool set=false, double inp=0) {static double mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}

double e_attrStopLoss(bool set=false, double inp=-1) {static double mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}

double e_attrSwap(bool set=false, double inp=0) {static double mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}

string e_attrSymbol(bool set=false, string inp="") {static string mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}

double e_attrTakeProfit(bool set=false, double inp=-1) {static double mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}

int e_attrTicket(bool set=false, int inp=-1) {static int mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}

int e_attrType(bool set=false, int inp=-1)
{
	static int mem[];
	int queue = OnTradeQueue()-1;

	if (set == true)
	{
		ArrayResize(mem,queue+1);
		mem[queue] = inp;
	}
	
	return mem[queue];
}

int iCandleID(string SYMBOL, ENUM_TIMEFRAMES TIMEFRAME, datetime time_stamp)
{
   bool TimeStampPrevDayShift = true;
   int CandleID = 0;
   //== calculate candle ID
   //-- get the time resolution of the desired period, in minutes
   int mins_tf = TIMEFRAME;
   int mins_tf0 = 0;
   if (TIMEFRAME == PERIOD_CURRENT)
   {
      mins_tf = (int)PeriodSeconds(PERIOD_CURRENT) / 60;
   }
   
   //-- get the difference between now and the time we want, in minutes
   //int time_stamp = StrToTime(TimeStamp);
   int days_adjust = 0;
   if (TimeStampPrevDayShift)
   {
      //-- automatically shift to the previous day
      if (time_stamp > TimeCurrent())
      {
         time_stamp = time_stamp - 86400;
      }
      //-- also shift weekdays
      while (true)
      {
         int dow = TimeDayOfWeek(time_stamp);
         
         if (dow > 0 && dow < 6) {break;}
         time_stamp = time_stamp - 86400;
         days_adjust++;
      }
   }
   
   int mins_diff = (int)(TimeCurrent() - time_stamp);
   mins_diff = mins_diff - days_adjust*86400;
   mins_diff = mins_diff / 60;
   
   //-- the difference is negative => quit here
   if (mins_diff < 0) {return (int)EMPTY_VALUE;}
   
   //-- now calculate the candle ID, it is relative to the current time
   if (mins_diff > 0) {
      CandleID = (int)MathCeil((double)mins_diff/(double)mins_tf);
   }
   //Print(TimeToStr(TimeCurrent())+" "+TimeToStr(time_stamp) +" ::: " + mins_tf + " " + days_adjust + " " + (days_adjust*1440/mins_tf) + " " + CandleID);
   
   
   //-- now, after all the shifting and in case of missing candles, the calculated candle id can be few candles early
   // so we will search for the right candle
   while(true)
   {
      if (iTime(SYMBOL, TIMEFRAME, CandleID) >= time_stamp) {break;}
      
      CandleID--;
		
		if (CandleID <= 0) {CandleID = 0; break;}
   }
   
   return CandleID;
   
   /*
   // this method does the same, but it is slower
   
   if (0)
   {
      CandleID = 0;
      datetime t = StrToTime(TimeStamp);
      datetime now = TimeCurrent();
      datetime ctime;
      while(true)
      {
         ctime = iTime(SYMBOL, TIMEFRAME, CandleID);
         //
         if (ctime < t)
         {
            //-- if the time is still in the future, we will shift to a previous day
            if (t > now)
            {
               if (TimeStampPrevDayShift)
               {
                  //-- shift to the last day that is not sat/sun
                  while(true)
                  {
                     t = t - 86400;
                     int dow = TimeDayOfWeek(t);
                     if (dow > 0 && dow < 6) {break;}
                  }
                  continue;
               }
               return EMPTY_VALUE;
            }
            break;
         }
         CandleID++;
      }
   }
   
   */
}

double toDigits(double pips, string symbol)
{
	if (symbol == "") symbol = Symbol();

	int digits   = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
	double point = SymbolInfoDouble(symbol, SYMBOL_POINT);

	return NormalizeDouble(pips * PipValue(symbol) * point, digits);
}

double toPips(double digits, string symbol)
{
	if (symbol == "") symbol = Symbol();

   return digits / (PipValue(symbol) * SymbolInfoDouble(symbol, SYMBOL_POINT));
}






class FxdWaiting
{
	private:
		int beginning_id;
		ushort bank  [][2][20]; // 2 banks, 20 possible parallel waiting blocks per chain of blocks
		ushort state [][2];     // second dimention values: 0 - count of the blocks put on hold, 1 - current bank id

	public:
		void Initialize(int count)
		{
			ArrayResize(bank, count);
			ArrayResize(state, count);
		}

		bool Run(int id = 0)
		{
			beginning_id = id;

			int range = ArrayRange(state, 0);
			if (range < id+1) {
				ArrayResize(bank, id+1);
				ArrayResize(state, id+1);

				// set values to 0, otherwise they have random values
				for (int ii = range; ii < id+1; ii++)
				{
				   state[ii][0] = 0;
				   state[ii][1] = 0;
				}
			}

			// are there blocks put on hold?
			int count = state[id][0];
			int bank_id = state[id][1];

			// if no block are put on hold -> escape
			if (count == 0) {return false;}
			else
			{
				state[id][0] = 0; // null the count
				state[id][1] = (bank_id) ? 0 : 1; // switch to the other bank
			}

			//== now we will run the blocks put on hold

			for (int i = 0; i < count; i++)
			{
				int block_to_run = bank[id][bank_id][i];
				_blocks_[block_to_run].run();
			}

			return true;
		}

		void Accumulate(int block_id = 0)
		{
			int count   = ++state[beginning_id][0];
			int bank_id = state[beginning_id][1];

			bank[beginning_id][bank_id][count-1] = (ushort)block_id;
		}
};
FxdWaiting fxdWait;



//+------------------------------------------------------------------+
//| END                                                              |
//| Created with fxDreema EA Builder           https://fxdreema.com/ |
//+------------------------------------------------------------------+

/*<fxdreema:eNrtXetzm0gS/1dc2i93VXGKl9Ajd1vlR5ykVrZ8trJbd19UGEbynBGwgOzotvy/X/c8YEAg2zKOnYh8iBE909PT093TP6aFnGFv+Fcy1PVhxw2DgLgpDYOk88EZDoZ/0aEGFyY26A47M0p8r/MhgR6d448nB19HE/xkDztJuIxdgh/MYUe3dHE7deI5SbPbRufDPR3q23A0qjlajKOxDUezmqPOOJpbcDR7lRxtztHagqNdrceuyTh2t+DYrZl1j3G0t9Fj9aytAePY24bjoJpjl3Hsb8OxW8nR7APHe0a48kP3hhm93kOrh8WEa0PHgfrMMdI49FmDLt4bDDuf4nAZnYYeGwWEmeNncf1JXmvDDv7R4e/lanEV+rIDyshuiA+X2QfZBfzxcLlKxvEl8XHkZGiBnGF6DUIzAVAohwYkFrQJdW/wEuT1aOJc+QR0cwUOzPRDvqUk5n6tDf8CDsawQ72i7QJTmkzdZZKGC9m1L5XD9cbkTlKyECMtYD7+lDPSQYizcByRgHjj2CMxkxoU2omc2FkQEAC4h2HsJcpEgWNEIe5kwoL+EtfxpZqCMF44vtRiQpBXGsbKTFCm1EmX7JYhbCMMwtms84EyliCY56RONuo9a5LSlI/SR7n30tjJ1gb6sgkLftDfJ7MU2RmmxnWWhhF+tjXkBg3uHJrKKYAib52Y4hoocoIiwmUaLdNEZUzhHvbTuZxEfGRsYRg3Ya2ZyetoqY57g6YWePtu6IexMP9fDgZHg5MTYX8ZBYzoF2lNM7CX/TtC59epqghcNWnfU7CS2Mkl1g00OVzK/SRdcWXxfugi/ToXseQilP2g0tBZOyos5ghmlgrJ+8ImkXoJrisd90qYGzCYKTSh0syukbHrBB6swVT8FYutytoTotLx59GRUB9FG2YsQGD02CPW/YQG3uEK72djADNO+3KsTGmAzrggINfiodnDvXMS0zBzoPOPF1/Gx9OjrxcXH88mcp5HY/h4NPkyPsuX4D7XHdPAWNgs09G+ziK9YSkNLtBqzpaLKxKf00j1wb5oRf8nY+a+Ycqxfw/95YIogYv8uaTpqkhWumrvdTmZnHZBkxuhua5W7CpJ0NV4zyK1bkoa6MYl3CCgZ4/37EvqIQYmpQnYjCmt3VPlWjMNHR3UX5Ip+7/CLKQF/y7pysQ2rAdwOaHfiHfhQBb1NaCp1IuF3TVD2mXe6Jj4PDCBcIYmjY4L/zWKSDyiC5oqawXOPr8cLcRyWBggA3aJznoJUWkUJolc34K65RJfjmTY1zKa58uujWgLejyoKxw1anTU4pQ2jes1Oi5f3IcmjAs3OV/kGcMMjUC6ysS5IedxOKOpXLs8c1EXb3JemqmBi5f3/m7Lh+NGDY/7uAXEkb2GR37cEupiNxqRW+InnyBhQBcOiqIbYrW4D9e1ykL3aL65weS8pgHY08dvWQYK9z9NjvL7x86qFOHh5mdIi5NSXoo8aLBMiQwY3OYwZQJShXI1qdwU9rgq3cqUAEWbiDawItm6sr0xS9AlpbxpwvQ1bZgbORLVvVa1UaSdOvENUQOlPlA74dUMs9CCND3RJFxEEEWD9N/EiVUW/RL9FOZ5rTawSw1A7Sq5zB8XQKhZNwpCZiOwtSgIWW5ySUDdXqGJmWv78prO5G5oZNFFEnCCSSn7yohsdgWq2vUPQm4KRFMhSnPLVkXtuWZ2tjpobnxVZD7ZSvINjVAmTwwNI6YxejN6KizcpU+jyJlLXVrCyE5XoMiFyBiUeR7EcXh3hIkzAi6R6rh+fIEx+pmIq8efpNQku5Tl/pW5HD7bKKVn+HCiMkXCZwz1KQg+L6jeaRD3r4eCNYTYbwIh9vhMzkng0WDOkK3x0iCRA/rMW7hKuZ0KXYprS7nuKu1t5X4vu98E8DRg2qiEvYgrZI9hrWSPBnvzmKtsIxi1iljU6jYFRrUiGNWfCEZnM03jkVsFo5yC/2ogKXvA4XtbwVKYZUzc1Anm
+Jnh08Er4VOH45kWn27Ep9oz8an2xvApko0fHaDqLUBtAepTAKrWAtQWoLYAtQWoLUB9UYBqqgD1cLkSfgT49JAFiB8IoFZC0G45BDwSlQ6aQKV2AZXiqetOg1KbnTxvi0nNfvdtglJN678+KLX0OlCqv4HCArFZ4UF4ch7ybqCgeBkEYAmSfkbuSFy1U499b50A0xyFYYTBsCQF3j5IR8RJ0iI4RUIZVSB/HjJOc2QRiUwUZMTNx4llLP1V+jXvcrDAQKZgDnG62Ss2gO2FSPysa88OqnoWVCsFKccyXjX1zFhmgJEcXRP35uB2zoc8icPFGattePFyDPNxQa2RIGWIee5FbJZ7f3NuSQyb6d8fDFB2qYLDMKxdLeGwjLpo1H8TwQhkZ4nIegpWkz6hCHmeJEeALOmYkOicBjcvUTzFixOfm4SAnEd+mBBeP/XSrtqtcVVNcVVNyT+0Yv7RhAvj6rIZ7+XRabPj9gdFxx30XiazeKrjWnbfuLKenFkoS/QsJzbrnJg9Oy7ujcDo139m2uf31WfaevZM+yeqbuS1vg2gBLbj8PQoV9orbKglL23EG/tyQ+XeuOfKCW72Sbu4meqGvmObaR9RPVVTfGujP776pgpKZMk10mHVqhDA999CrSY8FPofEx/8UCD5H6oIGSxGSF9C3o/wwSLiNgdmuy9Cv25tCb/5lPPftSNGdrAbE7Jw4jkNXqEO1tyNY0agLxan8y/QnTr+KEyTkgB93uB06ac08lfjgB+Y5U+W8aSj2EKeyCgPgnu8zYHn4RAFJtnj7UKDAo+CqBcEXLSCQ69ArpNBNw27frKmbHJBAOkm2Rmd4/NrzuOEXoW1PBA0LxbHENbwjD19QLFZu5oBDSbRyLkKl+41iUk9O7vYcET5Ax+0Pv2d8c58Z73rvrNzXedN6+bKhr4kfx46CakYUBfkfCmgtwlD2YXelUthCGLd0JsPv9Uz7tMnHoGjtWZE7s3nMXVzv+l25UKXmq2dubYH5t/ltLVwlHG6xcE5eqRC37Dog4qGa3US7VH7d62W2Pp0W9Vp8XhbtG8Pt9vD7bb6uqHqayM7h6k6k9ZrwvQaRO02AFFFve9ZePdaD3jrDphf4AFvXxQ3B3y2GzHsoPgYCQ+R20rm7ImS/VMiWfQqvYWyLZRtoWwLZVso++NCWa2Fsi2UbaFsC2VbKPvCddoNQVm7ASjLq4R3A8n2eEX0Y4CsZZYPY9vyZwXJ1r5WzRJ7wyhc3ykwtaCBR11mE1MK+ZF77SQpdSt2DTAgXvX0W5R9cbXwnaTj/L4MMpiG+uGdrHEWmBN3ngOw6OtQfpf2dHz8cXp5epAXJEN6cyLfQofau5yMp6PxH5+/fPostJdhbRFit/yWLSxaFpAVPF+/o7uFoq9v/xAXF2EjiUUObTcns24Meewd9URtiaz/rbYkPXsRJfaarndruuqkibfeDbCODoxTfv/tByg1KYu8+clcMZ4Z3TfywruTk+Ojg8E2BV6PKuIavEqgyoo71uKU2cap3YhTesG+TJnwqXbC0yHVRHhSpJrH/VqwG7TB7snHEFp3F4Jd13ytrGyww1kZDN18sLMaD3bcut9iROuabUR7MKL1S/X5g51I37pWizNfJ3/7tfGQ1v+x8jejoWinaJF9kdj8oGpmPRhabTB8+OGcXgKz1m7kd3YLZttguEvB0G6D4cPB0CidVOg7EQxtrQW7rwJ2mw+G9hsEu68U8WytjXhPjng7AoZtfZuIhwUdasQ7mFxUuKV8aRVQi4lf96d5qtZjNVSaZplvL9pUHGraehsJnvxUzNyNQGC0geDZxZT9t/uAXUkXtAfSBaMNEo9IF8pR4ucHSLziERSSQhrKZTekOI6b0lsyrTNTZB7F4X+Jm04DUR8L0i4D/OCVW6SrKHtf/zeIGKksn3TBwqY+yLMUJZcIYP41srJvATkpyBAThxe34i8IGJre39e1fc2egLSmPbS097Yx+E+hC1guna0e22Xh
zKk7TfgvN9DhwOx2xTtabmlCYa2nPr2KnXg1zV7eU3AVrLWVLZk/1bVD86ILEk8TWZ/KflOSSxGFNEin8VKYlil/kFfa0ywOF7LEGVIUXcS7NCzUfovf3C13knlNqZstbuvZT+uWO/Zlxw0973k4WCYQX2mcLh0flBlm3xIJwk6mToXKKsGZU4gq1wFnQUBBcxK4qwom2KZEn8bELxc+l5s4XrHwGS7ILQnSZKr8ckEqTXuQUd2VC0tahHKMHGAEmCYRWKY3ZSEwI5s5WUQvTsCHCikBU4DVvw7vpvkum3XFd/LHTnQ9DWMK42dvWUd5J2E0CQ/DlEXvbAuBIYI0KWwsFfEJLAb2SacYsfBbQow/ws37/wOaBzln
:fxdreema>*/