//+------------------------------------------------------------------+
//|                                                 s-Downloader.mq4 |
//|                                          Copyright © 2009, Talex |
//|                                      talex.kaliningrad@gmail.com |
//+------------------------------------------------------------------+
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  The script downloads history for all symbols located in
  the Market Watch and timeframes. Download is performed by emulating
  pressing the HOME button and handling the process, i.e.
  if the download by the button has stopped for about 5 seconds, 
  it is assumed that all data for this symbol and timeframe are downloaded and 
  the next iteration starts. The script updates the chart, thus downloading
  recent history.
  DO NOT PERFORM ANY ACTIONS WITH THE TERMINAL DURING THE DOWNLOAD
  THE PROCESS TAKES QUITE A LOT OF TIME, THEREFORE
  LEAVE THE SCRIPT TO WORK FOR THE NIGHT.
  I want to thank Ilnur, getch, Zhunko, YuraZ and other participants
  of the http://forum.mql4.com/ru/ forum for interesting ideas about WINAPI. I could 
  hardly develop the script without them.
*///++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#property copyright "Copyright © 2009, Talex"
#property link      "talex.kaliningrad@gmail.com"

#include <SymbolsLib.mqh>

#import "user32.dll"
   int GetAncestor (int hWnd, int gaFlags);
   int GetParent (int hWnd);
   int GetDlgItem (int hDlg, int nIDDlgItem);
   int SendMessageA (int hWnd, int Msg, int wParam, int lParam);
   int PostMessageA (int hWnd, int Msg, int wParam, int lParam);
#import
#define LVM_GETITEMCOUNT   0x1004
#define WM_COMMAND         0x0111
#define WM_SCROLL          0x80F9
#define WM_KEYDOWN         0x0100
#define WM_CLOSE           0x0010
#define VK_HOME            0x24
#define VK_END             0x23
#define VK_DOWN            0x28

bool MarketWatch = true;        // true - Market Watch symbols, false - all symbols provided by a dealing center
int nsymb,Pause=500;
string Symbols[];                                // array the symbols are to be stored in
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
void start() {
   int i;
//--------------------------------------------------------------------
   if(GlobalVariableCheck("glSymbolHandle")) {   // If this is not the first launch.
      GlobalVariableSet("glSymbolHandle",WindowHandle(Symbol(),Period())); // set the new global variable
      nsymb=SymbolsList(Symbols,MarketWatch);
      for(i=0;i<nsymb;i++) {                     // find the chart symbol in the loop
         if(Symbols[i]==Symbol()) {              // in the Symbols[i] array and the value
            GlobalVariableSet("glSymbol",i);     // assign to the global variable
            return;                                                        
         }
      }
      return;
   } 
   SymbolsList(Symbols,MarketWatch);             // write a set of symbols provided by the dealing center to the Symbols[] array
   DownloadHomeKey();                            // open charts from the Market Watch one after another
   return;                                       // and press HOME checking the end of the download
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------+
//| DownloadHomeKey()                                                            |
//| Purpose:                                                                     |
//|     Downloading history to the terminal for all symbols and TFs by emulating |
//|     pressing the HOME button                                                 |
//+------------------------------------------------------------------------------+
void DownloadHomeKey() {
   int i,j,k,hmain,handle,handlechart,count,num,
       TF[8]={33136,33134,33141,33334,33137,33138,33139,33140},
       tf[9]={60,240,1440,10080,43200,1,5,15,30};
   datetime ebt,prebt;
//------------------------------------
   GlobalVariableSet("glSymbolHandle",WindowHandle(Symbol(),Period()));
   hmain=GetAncestor(WindowHandle(Symbol(),Period()),2);   // find the main terminal window.
   if (hmain!=0) { 
      handle=GetDlgItem(hmain,0xE81C);                    
      handle=GetDlgItem(handle,0x50);
      handle=GetDlgItem(handle,0x8A71);                    // find the list of symbols.
      count=SendMessageA(handle,LVM_GETITEMCOUNT,0,0);     // get the number of list elements.
   }
   else Print("Error : ",GetLastError());
   for(i=1;i<=count&&!IsStopped();i++) {                   // open chart windows in the loop.
      OpenChart(i,hmain);                                  // open the chart of the next symbol from the Market Watch window
      Sleep(Pause);
      PostMessageA(hmain,WM_COMMAND,33042,0);              // launch the script on the newly opened chart.
      Sleep (Pause);
      handlechart=GlobalVariableGet ("glSymbolHandle");    // define the descriptor of the newly opened window.
      for (j=0;j<9&&!IsStopped();j++) {                    // switching a TF and emulation
         if (j!=0) {                                       // skip the first iteration. By default, the first TF is H1.
            PostMessageA(handlechart,WM_COMMAND,TF[j-1],0);// set the TF.
         }
         k=0;
         PostMessageA(handlechart,WM_COMMAND,WM_SCROLL,0); // disable scrolling
         while(!IsStopped()) {
            PostMessageA(handlechart,WM_KEYDOWN,VK_HOME,0);// press HOME
            Sleep(1000);
            num=GlobalVariableGet("glSymbol");             // get the symbol index 
            ebt=iTime(Symbols[num],tf[j],(iBars(Symbols[num],tf[j])-1));// get the time of the last bar
            if(ebt!=prebt) {                               // if the time changes, download missing history again
               prebt=ebt;
               k=0;
            }
            else k++;                                      // otherwise, increase the variable by 1
            if(k>4) break;                                 // if it exceeds 4, stop "pressing" HOME
         }
         PostMessageA(handlechart,WM_KEYDOWN,VK_END,0);    // set the chart to the end (or beginning?) :)
         PostMessageA(handlechart,WM_COMMAND,WM_SCROLL,0); // enable scrolling
         PostMessageA(handlechart,WM_COMMAND,33324,0);     // update the window for downloading the recent history
         Sleep(Pause);
      }
      PostMessageA(GetParent(handlechart),WM_CLOSE,0,0);   // close the chart window. 
      Sleep(Pause);
   }
   GlobalVariableDel ("glSymbolHandle");                   // remove the global variables
   GlobalVariableDel ("glSymbol");
   return;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| OpenChart()                                                      |
//| Purpose:                                                         |
//| Open the chart of the Market Watch symbol.                       |
//+------------------------------------------------------------------+
void OpenChart (int Num, int handle) {
   int hwnd;
//-------------------------------------  
   hwnd=GetDlgItem(handle,0xE81C); 
   hwnd=GetDlgItem(hwnd,0x50);
   hwnd=GetDlgItem(hwnd,0x8A71);                 // Market Watch found.
   PostMessageA(hwnd,WM_KEYDOWN,VK_HOME,0);      // Market Watch window's upper line.
   while (Num>1) {
      PostMessageA(hwnd,WM_KEYDOWN,VK_DOWN,0);   // Shift to the necessary line.
      Num--;
   }
   PostMessageA(handle,WM_COMMAND,33160,0);      // Open the chart.
   return;
}
//+------------------------------------------------------------------+