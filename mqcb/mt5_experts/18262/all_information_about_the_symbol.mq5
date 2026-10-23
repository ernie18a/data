//+------------------------------------------------------------------+
//|                             All information about the symbol.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property description "Control Panels and Dialogs. Demonstration class CListView"
#property description "All information about the symbol"
#include <Controls\Dialog.mqh>
#include <Controls\ListView.mqh>
#include <Trade\SymbolInfo.mqh>  
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- indents and gaps
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width)
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width)
#define CONTROLS_GAP_X                      (5)       // gap by X coordinate
#define CONTROLS_GAP_Y                      (5)       // gap by Y coordinate
//--- for buttons
#define BUTTON_WIDTH                        (100)     // size by X coordinate
#define BUTTON_HEIGHT                       (20)      // size by Y coordinate
//--- for the indication area
#define EDIT_HEIGHT                         (20)      // size by Y coordinate
//--- for group controls
#define GROUP_WIDTH                         (450)     // size by X coordinate
#define LIST_HEIGHT                         (300)     // size by Y coordinate
#define RADIO_HEIGHT                        (56)      // size by Y coordinate
#define CHECK_HEIGHT                        (93)      // size by Y coordinate
//+------------------------------------------------------------------+
//| Class CControlsDialog                                            |
//| Usage: main dialog of the Controls application                   |
//+------------------------------------------------------------------+
class CControlsDialog : public CAppDialog
  {
private:
   CListView         m_list_view;                     // CListView object
   CSymbolInfo       m_symbol;                        // symbol info object

public:
                     CControlsDialog(void);
                    ~CControlsDialog(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

protected:
   //--- create dependent controls
   bool              CreateListView(void);
   //--- handlers of the dependent controls events
   void              OnChangeListView(void);
   //--- checks if the specified expiration mode is allowed
   bool              IsExpirationTypeAllowed(const string symbol,const int exp_type);
   //--- checks if the specified filling mode is allowed 
   bool              IsFillingTypeAllowed(const string symbol,const int fill_type);
  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CControlsDialog)
ON_EVENT(ON_CHANGE,m_list_view,OnChangeListView)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CControlsDialog::CControlsDialog(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CControlsDialog::~CControlsDialog(void)
  {
  }
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool CControlsDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
//---
   m_symbol.Name(Symbol());
   m_symbol.Refresh();
   bool result=false;
   do
     {
      //static int counter=0;
      result=m_symbol.RefreshRates();
      //Print(counter);
      //counter++;
     }
   while(!result);
//--- create dependent controls
   if(!CreateListView())
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "ListView" element                                    |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateListView(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP;
   int x2=x1+GROUP_WIDTH;
   int y2=y1+LIST_HEIGHT;
//--- create
   if(!m_list_view.Create(m_chart_id,m_name+"ListView",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_list_view))
      return(false);
//--- fill out with strings
   string text="";
   text="Properties:";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"Name\": "+m_symbol.Name();
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"Select\": "+(m_symbol.Select()?"true":"false");
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"IsSynchronized\": "+(m_symbol.IsSynchronized()?"true":"false");
   if(!m_list_view.AddItem(text))
      return(false);
   text="Volumes:";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"Volume\": "+DoubleToString(m_symbol.Volume(),2);
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"VolumeHigh\": "+DoubleToString(m_symbol.VolumeHigh(),2);
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"VolumeLow\": "+DoubleToString(m_symbol.VolumeLow(),2);
   if(!m_list_view.AddItem(text))
      return(false);
   text="Miscellaneous:";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"Time\": "+TimeToString(m_symbol.Time(),TIME_DATE|TIME_MINUTES|TIME_SECONDS);
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"Spread\" (in points): "+IntegerToString(m_symbol.Spread());
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"SpreadFloat\": "+(m_symbol.SpreadFloat()?"true":"false");
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"TicksBookDepth\": "+IntegerToString(m_symbol.TicksBookDepth());
   if(!m_list_view.AddItem(text))
      return(false);
   text="Levels:";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"StopsLevel\" (in points): "+IntegerToString(m_symbol.StopsLevel());
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"FreezeLevel\" (in points): "+IntegerToString(m_symbol.FreezeLevel());
   if(!m_list_view.AddItem(text))
      return(false);
   text="Bid prices:";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"Bid\": "+DoubleToString(m_symbol.Bid(),m_symbol.Digits());
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"BidHigh\": "+DoubleToString(m_symbol.BidHigh(),m_symbol.Digits());
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"BidLow\": "+DoubleToString(m_symbol.BidLow(),m_symbol.Digits());
   if(!m_list_view.AddItem(text))
      return(false);
   text="Ask prices:";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"Ask\": "+DoubleToString(m_symbol.Ask(),m_symbol.Digits());
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"AskHigh\": "+DoubleToString(m_symbol.AskHigh(),m_symbol.Digits());
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"AskLow\": "+DoubleToString(m_symbol.AskLow(),m_symbol.Digits());
   if(!m_list_view.AddItem(text))
      return(false);
   text="Prices:";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"Last\": "+DoubleToString(m_symbol.Last(),m_symbol.Digits());
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"LastHigh\": "+DoubleToString(m_symbol.LastHigh(),m_symbol.Digits());
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"LastLow\": "+DoubleToString(m_symbol.LastLow(),m_symbol.Digits());
   if(!m_list_view.AddItem(text))
      return(false);
   text="Trade modes:";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"TradeCalcMode\": "+EnumToString(m_symbol.TradeCalcMode());
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"TradeCalcModeDescription\": "+m_symbol.TradeCalcModeDescription();
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"TradeMode\": "+EnumToString(m_symbol.TradeMode());
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"TradeModeDescription\": "+m_symbol.TradeModeDescription();
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"TradeExecution\": "+EnumToString(m_symbol.TradeExecution());
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"TradeExecutionDescription\": "+m_symbol.TradeExecutionDescription();
   if(!m_list_view.AddItem(text))
      return(false);
   text="Swaps:";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"SwapMode\": "+EnumToString(m_symbol.SwapMode());
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"SwapModeDescription\": "+m_symbol.SwapModeDescription();
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"SwapRollover3days\": "+EnumToString(m_symbol.SwapRollover3days());
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"SwapRollover3daysDescription\": "+m_symbol.SwapRollover3daysDescription();
   if(!m_list_view.AddItem(text))
      return(false);
   text="Margins and flags:";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"MarginInitial\": "+DoubleToString(m_symbol.MarginInitial(),2);
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"MarginMaintenance\": "+DoubleToString(m_symbol.MarginMaintenance(),2);
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"MarginLong\": "+DoubleToString(m_symbol.MarginLong(),2);
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"MarginShort\": "+DoubleToString(m_symbol.MarginShort(),2);
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"MarginLimit\": "+DoubleToString(m_symbol.MarginLimit(),2);
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"MarginStop\": "+DoubleToString(m_symbol.MarginStop(),2);
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"MarginStopLimit\": "+DoubleToString(m_symbol.MarginStopLimit(),2);
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"TradeTimeFlags\": "+IntegerToString(m_symbol.TradeTimeFlags())+":";
   if(!m_list_view.AddItem(text))
      return(false);
   text="   \"SYMBOL_EXPIRATION_GTC\": "+(IsExpirationTypeAllowed(m_symbol.Name(),1)?"true":"false");
   if(!m_list_view.AddItem(text))
      return(false);
   text="   \"SYMBOL_EXPIRATION_DAY\": "+(IsExpirationTypeAllowed(m_symbol.Name(),2)?"true":"false");
   if(!m_list_view.AddItem(text))
      return(false);
   text="   \"SYMBOL_EXPIRATION_SPECIFIED\": "+(IsExpirationTypeAllowed(m_symbol.Name(),4)?"true":"false");
   if(!m_list_view.AddItem(text))
      return(false);
   text="   \"SYMBOL_EXPIRATION_SPECIFIED_DAY\": "+(IsExpirationTypeAllowed(m_symbol.Name(),8)?"true":"false");
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"TradeFillFlags\": "+IntegerToString(m_symbol.TradeFillFlags())+":";
   if(!m_list_view.AddItem(text))
      return(false);
   text="   \"SYMBOL_FILLING_FOK\": "+(IsFillingTypeAllowed(m_symbol.Name(),1)?"true":"false");
   if(!m_list_view.AddItem(text))
      return(false);
   text="   \"SYMBOL_FILLING_IOC\": "+(IsFillingTypeAllowed(m_symbol.Name(),2)?"true":"false");
   if(!m_list_view.AddItem(text))
      return(false);
   text="Quantization:";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"Digits\": "+IntegerToString(m_symbol.Digits());
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"Point\": "+DoubleToString(m_symbol.Point(),m_symbol.Digits());
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"TickValue\": "+DoubleToString(m_symbol.TickValue(),m_symbol.Digits());
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"TickValueProfit\": "+DoubleToString(m_symbol.TickValueProfit(),m_symbol.Digits());
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"TickValueLoss\": "+DoubleToString(m_symbol.TickValueLoss(),m_symbol.Digits());
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"TickSize\": "+DoubleToString(m_symbol.TickSize(),m_symbol.Digits());
   if(!m_list_view.AddItem(text))
      return(false);
   text="Contracts sizes:";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"ContractSize\": "+DoubleToString(m_symbol.ContractSize(),2);
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"LotsMin\": "+DoubleToString(m_symbol.LotsMin(),2);
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"LotsMax\": "+DoubleToString(m_symbol.LotsMax(),2);
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"LotsStep\": "+DoubleToString(m_symbol.LotsStep(),2);
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"LotsLimit\": "+DoubleToString(m_symbol.LotsLimit(),2);
   if(!m_list_view.AddItem(text))
      return(false);
   text="Swaps sizes:";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"SwapLong\": "+DoubleToString(m_symbol.SwapLong(),m_symbol.Digits());
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"SwapShort\": "+DoubleToString(m_symbol.SwapShort(),m_symbol.Digits());
   if(!m_list_view.AddItem(text))
      return(false);
   text="Text properties:";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"CurrencyBase\": "+m_symbol.CurrencyBase();
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"CurrencyProfit\": "+m_symbol.CurrencyProfit();
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"CurrencyMargin\": "+m_symbol.CurrencyMargin();
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"Bank\": "+m_symbol.Bank();
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"Description\": "+m_symbol.Description();
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"Path\": "+m_symbol.Path();
   if(!m_list_view.AddItem(text))
      return(false);
   text="Symbol properties:";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"SessionDeals\": "+IntegerToString(m_symbol.SessionDeals())+":";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"SessionBuyOrders\": "+IntegerToString(m_symbol.SessionBuyOrders())+":";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"SessionSellOrders\": "+IntegerToString(m_symbol.SessionSellOrders())+":";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"SessionTurnover\": "+DoubleToString(m_symbol.SessionTurnover(),2)+":";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"SessionInterest\": "+DoubleToString(m_symbol.SessionInterest(),2)+":";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"SessionBuyOrdersVolume\": "+DoubleToString(m_symbol.SessionBuyOrdersVolume(),2)+":";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"SessionSellOrdersVolume\": "+DoubleToString(m_symbol.SessionSellOrdersVolume(),2)+":";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"SessionOpen\": "+DoubleToString(m_symbol.SessionOpen(),2)+":";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"SessionClose\": "+DoubleToString(m_symbol.SessionClose(),2)+":";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"SessionAW\": "+DoubleToString(m_symbol.SessionAW(),m_symbol.Digits())+":";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"SessionPriceSettlement\": "+DoubleToString(m_symbol.SessionPriceSettlement(),m_symbol.Digits())+":";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"SessionPriceLimitMin\": "+DoubleToString(m_symbol.SessionPriceLimitMin(),m_symbol.Digits())+":";
   if(!m_list_view.AddItem(text))
      return(false);
   text="\"SessionPriceLimitMax\": "+DoubleToString(m_symbol.SessionPriceLimitMax(),m_symbol.Digits())+":";
   if(!m_list_view.AddItem(text))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnChangeListView(void)
  {
   Comment(m_list_view.Select());
   Print(m_list_view.Select());
  }
//+------------------------------------------------------------------+
//| Checks if the specified expiration mode is allowed               | 
//+------------------------------------------------------------------+
bool CControlsDialog::IsExpirationTypeAllowed(const string symbol,const int exp_type)
  {
//--- Obtain the value of the property that describes allowed expiration modes 
   int expiration=(int)SymbolInfoInteger(symbol,SYMBOL_EXPIRATION_MODE);
//--- Return true, if mode exp_type is allowed 
   return((expiration&exp_type)==exp_type);
  }
//+------------------------------------------------------------------+ 
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool CControlsDialog::IsFillingTypeAllowed(const string symbol,const int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=(int)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CControlsDialog ExtDialog;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create application dialog
   if(!ExtDialog.Create(0,"All information about the symbol",0,40,40,521,391))
      return(INIT_FAILED);
//--- run application
   ExtDialog.Run();
//--- succeed
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- 
   Comment("");
//--- destroy dialog
   ExtDialog.Destroy(reason);
  }
//+------------------------------------------------------------------+
//| Expert chart event function                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID  
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) // event parameter of the string type
  {
   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
