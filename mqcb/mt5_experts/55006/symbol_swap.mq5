//+------------------------------------------------------------------+
//|                                                 Symbol swap.mq5  |
//|                                  Copyright © 2024, Long Tien Tu. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2024, Long Tien Tu."
#property link "https://www.mql5.com/en/market/product/122618"
#property description "Symbol Swap: Allow users to swap the current chart's symbol while automatically adding the symbol to Market Watch. It also functions as a Data Window, offering real-time market data for enhanced trading analysis."
#property strict
#property version   "1.10"
#include <Controls\Defines.mqh>
#include <Controls\Label.mqh>
#include <Controls\Edit.mqh>

#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG

input color    dialog_color_bg            = clrWhite;             // Panel background color
input color    dialog_color_caption_text  = clrDarkBlue;          // Panel text color
input color    dialog_color_client_bg     = clrLightGray;         // Panel client background
input color    dialog_main_text_color     = clrPurple;         // Panel main text color

#define CONTROLS_DIALOG_COLOR_BG          dialog_color_bg            // Panel background color
#define CONTROLS_DIALOG_COLOR_CAPTION_TEXT dialog_color_caption_text // Panel text color
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   dialog_color_client_bg     // Panel client background
#include <Controls\Dialog.mqh>
#include <Controls\BmpButton.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- for buttons
#define BUTTON_WIDTH                        (50)     // size by X coordinate
#define BUTTON_HEIGHT                       (20)      // size by Y coordinate
//+------------------------------------------------------------------+
//| Class CControlsDialog                                            |
//| Usage: main dialog of the Controls application                   |
//+------------------------------------------------------------------+
class CControlsDialog : public CAppDialog
  {
private:
   CBmpButton        m_bmpbutton1;                    // CBmpButton object
   CEdit             m_editInput;                     // CEdit object for text input

public:
                     CControlsDialog(void);
                    ~CControlsDialog(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

protected:
   //--- create dependent controls
   bool              CreateBmpButton1(void);
   bool              CreateTextInput(void);           // Create Text Input Field
   //--- handlers of the dependent controls events
   void              OnClickBmpButton1(void);
  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CControlsDialog)
ON_EVENT(ON_CLICK,m_bmpbutton1,OnClickBmpButton1)
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
//--- create dependent controls
   if(!CreateBmpButton1())
      return(false);
   if(!CreateTextInput())
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "TextInput" field                                     |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateTextInput(void)
  {
//--- coordinates
   int x1 = 200;
   int y1 = 5;
   int x2 = 325;
   int y2 = 10 + BUTTON_HEIGHT;

//--- create
   if(!m_editInput.Create(m_chart_id, m_name + "EditInput", m_subwin, x1, y1, x2, y2))
      return false;

//--- set initial text
   m_editInput.Text();

//--- add the input field to the dialog
   if(!Add(m_editInput))
      return false;

//--- succeed
   return true;
  }
//+------------------------------------------------------------------+
//| Create the "BmpButton1" button                                   |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateBmpButton1(void)
  {
//--- coordinates
   int x1=5;
   int y1=250;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_bmpbutton1.Create(m_chart_id,m_name+"BmpButton1",m_subwin,x1,y1,x2,y2))
      return(false);
//--- sets the name of bmp files of the control CBmpButton
   m_bmpbutton1.BmpNames("::Images\\rsz_1a.bmp", "::Images\\rsz_1a.bmp");
   if(!Add(m_bmpbutton1))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickBmpButton1(void)
  {
// Retrieve the text from the input field
   string symbol_to_change = m_editInput.Text();

// Print the text for debugging
   Print("Symbol to change: ", symbol_to_change);

   ENUM_TIMEFRAMES period_to_change = PERIOD_H1;  // Change to the desired timeframe

// Check if the symbol is valid or non-empty
   if(StringLen(symbol_to_change) > 0)
     {
      // Add the symbol to Market Watch
      if(SymbolSelect(symbol_to_change, true))   // true to add to Market Watch
        {
         // Change the chart symbol and period
         if(ChartSetSymbolPeriod(0, symbol_to_change, period_to_change))
           {
            Print("Chart symbol changed to ", symbol_to_change);
           }
         else
           {
            Print("Failed to change chart symbol and period.");
           }
        }
      else
        {
         Print("Failed to add symbol to Market Watch.");
        }
     }
   else
     {
      Print("No symbol entered. Please type a symbol in the text input field.");
     }
  }
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CControlsDialog *ExtDialog;
// Create two label variables
CLabel MyLabel1;
CLabel MyLabel2;
CLabel MyLabel3;
CLabel MyLabel4;
CLabel MyLabel5;
CLabel MyLabel6;
CLabel MyLabel7;
CLabel MyLabel8;
CLabel MyLabel9;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set the timer to 1 second ( Indicator)
   EventSetTimer(1);
//--- Step 1: Create the dialog
   if(CheckPointer(ExtDialog) == POINTER_INVALID)
     {
      ExtDialog = new CControlsDialog;
      if(CheckPointer(ExtDialog) == POINTER_INVALID)
         return (INIT_FAILED);
     }
   else
     {
      delete ExtDialog;
      ExtDialog = new CControlsDialog;
      if(CheckPointer(ExtDialog) == POINTER_INVALID)
         return (INIT_FAILED);
     }

//--- Step 2: Create application dialog
   if(!ExtDialog.Create(0, "Symbol Swap Panel", 0, 40, 40, 380, 344))
      return (INIT_FAILED);

// Create and position labels inside the dialog
   MyLabel1.Create(0, "Text 1", 0, 5, 5, 200, 20);   // Adjust the dimensions as needed
   MyLabel2.Create(0, "Text 2", 0, 5, 30, 200, 20);   // Adjust the dimensions as needed
   MyLabel3.Create(0, "Text 3", 0, 5, 55, 200, 20);   // Adjust the dimensions as needed
   MyLabel4.Create(0, "Text 4", 0, 5, 80, 200, 20);   // Adjust the dimensions as needed
   MyLabel5.Create(0, "Text 5", 0, 5, 105, 200, 20);   // Adjust the dimensions as needed
   MyLabel6.Create(0, "Text 6", 0, 5, 130, 200, 20);   // Adjust the dimensions as needed
   MyLabel7.Create(0, "Text 7", 0, 5, 155, 200, 20);   // Adjust the dimensions as needed
   MyLabel8.Create(0, "Text 8", 0, 5, 180, 200, 20);   // Adjust the dimensions as needed
   MyLabel9.Create(0, "Text 9", 0, 5, 205, 200, 20);   // Adjust the dimensions as needed
// Optionally update the labels dynamically on every tick
   MyLabel1.Text("Time: " + TimeToString(TimeCurrent()));
   MyLabel2.Text("Period: " + EnumToString((ENUM_TIMEFRAMES)Period()));
   MyLabel3.Text("Symbol: " + _Symbol);
   MyLabel4.Text("Close Price: " + DoubleToString(iClose(_Symbol, PERIOD_CURRENT, 0), Digits()));
   MyLabel5.Text("Open Price: " + DoubleToString(iOpen(_Symbol, PERIOD_CURRENT, 0), Digits()));
   MyLabel6.Text("High: " + DoubleToString(iHigh(_Symbol, PERIOD_CURRENT, 0), Digits()));
   MyLabel7.Text("Low: " + DoubleToString(iLow(_Symbol, PERIOD_CURRENT, 0), Digits()));
   MyLabel8.Text("Tick Volume: " + DoubleToString(iVolume(_Symbol, PERIOD_CURRENT, 0), 0));
   MyLabel9.Text("Spread: " + DoubleToString(iSpread(_Symbol, PERIOD_CURRENT, 0), 0));
// Hypothetical method to set color, if available
   MyLabel1.Color(dialog_main_text_color);  // This should trigger OnSetColor if implemented
   MyLabel2.Color(dialog_main_text_color);  // This should trigger OnSetColor if implemented
   MyLabel3.Color(dialog_main_text_color);  // This should trigger OnSetColor if implemented
   MyLabel4.Color(dialog_main_text_color);  // This should trigger OnSetColor if implemented
   MyLabel5.Color(dialog_main_text_color);  // This should trigger OnSetColor if implemented
   MyLabel6.Color(dialog_main_text_color);  // This should trigger OnSetColor if implemented
   MyLabel7.Color(dialog_main_text_color);  // This should trigger OnSetColor if implemented
   MyLabel8.Color(dialog_main_text_color);  // This should trigger OnSetColor if implemented
   MyLabel9.Color(dialog_main_text_color);  // This should trigger OnSetColor if implemented
//--- Step 4: Add labels to the dialog
   ExtDialog.Add(MyLabel1);
   ExtDialog.Add(MyLabel2);
   ExtDialog.Add(MyLabel3);
   ExtDialog.Add(MyLabel4);
   ExtDialog.Add(MyLabel5);
   ExtDialog.Add(MyLabel6);
   ExtDialog.Add(MyLabel7);
   ExtDialog.Add(MyLabel8);
   ExtDialog.Add(MyLabel9);

//--- Step 5: Run the application
   ExtDialog.Run();

   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   MyLabel1.Text("Time: " + TimeToString(TimeCurrent()));
// Trigger a calculation to update the display
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
   ExtDialog.Destroy(reason);
   if(CheckPointer(ExtDialog) != POINTER_INVALID)
      delete ExtDialog;
   EventKillTimer();
  }

//+------------------------------------------------------------------+
//| Expert chart event function                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   ExtDialog.ChartEvent(id, lparam, dparam, sparam);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
// Optionally update the labels dynamically on every tick
   MyLabel2.Text("Period: " + EnumToString((ENUM_TIMEFRAMES)Period()));
   MyLabel3.Text("Symbol: " + _Symbol);
   MyLabel4.Text("Close Price: " + DoubleToString(iClose(_Symbol, PERIOD_CURRENT, 0), Digits()));
   MyLabel5.Text("Open Price: " + DoubleToString(iOpen(_Symbol, PERIOD_CURRENT, 0), Digits()));
   MyLabel6.Text("High: " + DoubleToString(iHigh(_Symbol, PERIOD_CURRENT, 0), Digits()));
   MyLabel7.Text("Low: " + DoubleToString(iLow(_Symbol, PERIOD_CURRENT, 0), Digits()));
   MyLabel8.Text("Tick Volume: " + DoubleToString(iVolume(_Symbol, PERIOD_CURRENT, 0), 0));
   MyLabel9.Text("Spread: " + DoubleToString(iSpread(_Symbol, PERIOD_CURRENT, 0), 0));
  }
//+------------------------------------------------------------------+
