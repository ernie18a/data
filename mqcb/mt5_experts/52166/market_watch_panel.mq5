//+------------------------------------------------------------------+
//|                                          Market Watch Panel.mq5  |
//|                                  Copyright © 2024, Long Tien Tu. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2024, Long Tien Tu."
#property description "Market Watch Panel: A custom panel for real-time monitoring of symbol current prices with easy symbol stacking and filtering for a streamlined trading experience."
#property strict
#property version   "1.00"
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
int base_x1 = 5, base_y1 = 10;  // Base coordinates for MyLabel3
// Declare a dynamic array of label pointers
CLabel *LabelArray[];
//
string SymbolArray[];  // Array to store symbols for each label
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
   CBmpButton        m_bmpbutton2;                    // CBmpButton object
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
   bool              CreateBmpButton2(void);
   bool              CreateTextInput(void);           // Create Text Input Field
   //--- handlers of the dependent controls events
   void              OnClickBmpButton1(void);
   void              OnClickBmpButton2(void);
  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CControlsDialog)
ON_EVENT(ON_CLICK,m_bmpbutton1,OnClickBmpButton1)
ON_EVENT(ON_CLICK,m_bmpbutton2,OnClickBmpButton2)
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
   if(!CreateBmpButton2())
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
//| Create the "BmpButton2" button                                   |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateBmpButton2(void)
  {
//--- coordinates
   int x1=282;
   int y1=250;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_bmpbutton2.Create(m_chart_id,m_name+"BmpButton2",m_subwin,x1,y1,x2,y2))
      return(false);
//--- sets the name of bmp files of the control CBmpButton
   m_bmpbutton2.BmpNames("::Images\\images.bmp", "::Images\\images.bmp");
   if(!Add(m_bmpbutton2))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Event handler for the button click                               |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickBmpButton2(void)
  {
   Print(__FUNCTION__, " - Clearing arrays, labels, and symbols.txt");

//--- 
   ArrayResize(SymbolArray, 0);
   Print("SymbolArray has been cleared.");

//--- 
   for(int i = 0; i < ArraySize(LabelArray); i++)
     {
      // Check if the label is valid
      if(LabelArray[i] != NULL)
        {
         // Destroy the label (remove it from the chart and free memory)
         LabelArray[i].Destroy();

         // Delete the label object to free memory
         delete LabelArray[i];
         LabelArray[i] = NULL;  // Set pointer to NULL to avoid dangling references
        }
     }

//--- 
   ArrayResize(LabelArray, 0);
   Print("LabelArray has been cleared.");

//--- 
   string file_name = "symbols.txt";
   int file_handle = FileOpen(file_name, FILE_WRITE | FILE_TXT);  // Open in write mode to truncate the file
   if(file_handle != INVALID_HANDLE)
     {
      FileClose(file_handle);  // Close the file immediately to clear it
      Print("symbols.txt file has been cleared.");
     }
   else
     {
      Print("Failed to open symbols.txt for clearing. Error code: ", GetLastError());
     }

//--- (Optional) Clear any other data if necessary
  }

//+------------------------------------------------------------------+
//| Event handler for the button click                               |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickBmpButton1(void)
  {
// Retrieve the text from the input field
   string symbol_to_change = m_editInput.Text();

// Print the text for debugging
   Print("Symbol entered: ", symbol_to_change);

// Check if the symbol is valid or non-empty
   if(StringLen(symbol_to_change) > 0)
     {
      // **Trigger Save after a new symbol is added**
      SaveSymbolsToFile();  // Save the updated symbol array to a file
      // Dynamically calculate the position for the new label
      int label_count = ArraySize(LabelArray);  // Number of existing labels

      // Base coordinates (from MyLabel3)
      int label_x1 = base_x1;
      int label_y1 = base_y1 + (label_count + 1) * 30;  // Y position relative to MyLabel3

      // Ensure that the new label fits within the window
      int window_height = 344;  // Example window height, adjust as needed
      if(label_y1 + 20 > 250)
        {
         Print("No more space for new labels.");
         return;
        }

      // Get the correct number of digits for the symbol
      int symbol_digits = (int)SymbolInfoInteger(symbol_to_change, SYMBOL_DIGITS);

      // Create the new label and add it to the array
      CLabel *new_label = new CLabel;
      if(new_label.Create(m_chart_id, "Label" + IntegerToString(label_count), m_subwin, label_x1, label_y1, label_x1 + 200, label_y1 + 20))
        {
         // Add the label to the array
         ArrayResize(LabelArray, label_count + 1);
         LabelArray[label_count] = new_label;

         // Store the associated symbol
         ArrayResize(SymbolArray, label_count + 1);
         SymbolArray[label_count] = symbol_to_change;

         // Set initial text with price
         double close_price = iClose(symbol_to_change, PERIOD_CURRENT, 0);
         new_label.Text(symbol_to_change + " Price: " + DoubleToString(close_price, symbol_digits));
         new_label.Color(dialog_main_text_color);

         // Add the label to the dialog
         ExtDialog.Add(*new_label);
        }
      else
        {
         Print("Failed to create new label.");
         delete new_label;
        }
     }
   else
     {
      Print("No symbol entered. Please type a symbol in the text input field.");
     }
  }
//---
void SaveSymbolsToFile()
  {
   Print("SaveSymbolsToFile() function called.");

   int file_handle;
   string file_name = "symbols.txt";

// Open the file for writing (FILE_WRITE ensures it will be created if it doesn't exist)
   file_handle = FileOpen(file_name, FILE_WRITE | FILE_TXT);

   if(file_handle != INVALID_HANDLE)
     {
      // Write each symbol to the file, no symbol count
      for(int i = 0; i < ArraySize(SymbolArray); i++)
        {
         FileWrite(file_handle, SymbolArray[i]);  // Write the symbol name
        }

      FileClose(file_handle); // Close the file
      Print("Symbol names saved to file: ", file_name);
     }
   else
     {
      int error_code = GetLastError();
      Print("Failed to open the file for writing. Error code: ", error_code);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LoadSymbolsFromFile()
  {
   string file_name = "symbols.txt";

// Open the file for reading
   int file_handle = FileOpen(file_name, FILE_READ | FILE_TXT);

   if(file_handle != INVALID_HANDLE)
     {
      // Clear the existing SymbolArray
      ArrayResize(SymbolArray, 0);

      // Read each symbol from the file and add it to SymbolArray
      while(!FileIsEnding(file_handle))
        {
         string symbol = FileReadString(file_handle);

         // Check if the symbol is valid (not an empty line or invalid symbol)
         if(StringLen(symbol) > 0)
           {
            int array_size = ArraySize(SymbolArray);
            ArrayResize(SymbolArray, array_size + 1);
            SymbolArray[array_size] = symbol;

            Print("Loaded symbol: ", symbol);
           }
        }

      FileClose(file_handle);  // Close the file after reading
      Print("Symbol array loaded from file: ", file_name);
     }
   else
     {
      int error_code = GetLastError();
      Print("Failed to open the file for reading. Error code: ", error_code);
     }
  }


//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CControlsDialog *ExtDialog;
CLabel MyLabel3;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- 
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

//--- 
   if(!ExtDialog.Create(0, "Market Watch Panel", 0, 40, 40, 380, 344))
      return (INIT_FAILED);

//--- 
   LoadSymbolsFromFile();  // Load symbols from the file on initialization

//--- 
   for(int i = 0; i < ArraySize(SymbolArray); i++)
     {
      string symbol = SymbolArray[i];

      // Dynamically calculate the position for the new label
      int label_count = i;  // Number of existing labels (since it's at startup, it equals the index)
      int label_x1 = base_x1;
      int label_y1 = base_y1 + (label_count + 1) * 30;  // Y position relative to base_y1

      // Ensure that the new label fits within the window
      int window_height = 344;  // Example window height, adjust as needed
      if(label_y1 + 20 > window_height)
        {
         Print("No more space for new labels.");
         continue;  // Skip creating the label if it doesn't fit
        }

      // Get the correct number of digits for the symbol
      int symbol_digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

      // Create the new label
      CLabel *new_label = new CLabel;
      if(new_label.Create(0, "Label" + IntegerToString(label_count), 0, label_x1, label_y1, label_x1 + 200, label_y1 + 20))
        {
         // Set initial text with price
         double close_price = iClose(symbol, PERIOD_CURRENT, 0);
         new_label.Text(symbol + " Price: " + DoubleToString(close_price, symbol_digits));
         new_label.Color(dialog_main_text_color);

         // Add the label to the dialog and LabelArray
         ArrayResize(LabelArray, label_count + 1);
         LabelArray[label_count] = new_label;
         ExtDialog.Add(*new_label);

         Print("Label created for symbol: ", symbol);
        }
      else
        {
         Print("Failed to create new label for symbol: ", symbol);
         delete new_label;
        }
     }

//--- 
   MyLabel3.Create(0, "Text 3", 0, base_x1, base_y1, 200, 20);   // Adjust the dimensions as needed
   MyLabel3.Text(_Symbol + " Price: " + DoubleToString(iClose(_Symbol, PERIOD_CURRENT, 0), Digits()));
   MyLabel3.Color(dialog_main_text_color);  // Set color, if available
   ExtDialog.Add(MyLabel3);  // Add MyLabel3 to the dialog

//--- 
   EventSetTimer(1);

//--- 
   ExtDialog.Run();

   return (INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
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
// Loop through each label and update the price
   int label_count = ArraySize(LabelArray);
   for(int i = 0; i < label_count; i++)
     {
      // Get the symbol for this label
      string symbol = SymbolArray[i];

      // Get the correct number of digits for the symbol
      int symbol_digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

      // Get the latest close price for the symbol
      double close_price = iClose(symbol, PERIOD_CURRENT, 0);

      // Update the label text with the current price
      LabelArray[i].Text(symbol + " Price: " + DoubleToString(close_price, symbol_digits));
     }
// Optionally update the labels dynamically on every tick
   MyLabel3.Text(_Symbol + " Price: " +DoubleToString(iClose(_Symbol, PERIOD_CURRENT, 0), Digits()));
  }
//+------------------------------------------------------------------+
