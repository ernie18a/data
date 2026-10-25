//+------------------------------------------------------------------+
//|                                                      DoomEA.mq5  |
//|                                            DOOM on MetaTrader 5  |
//|                Renders DOOM via doomlib.dll onto a chart bitmap  |
//+------------------------------------------------------------------+
#property copyright "Muhammad Minhas Qamar - MMQ"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| HOW TO ENABLE DOOM:                                              |
//|                                                                  |
//| 1. Uncomment the line below (simply remove the "//"):            |
//|       //#define USE_DOOM_DLL                                     |
//|                                                                  |
//| 2. Place doomlib.dll in MQL5\Libraries\                          |
//|                                                                  |
//| 3. Place doom1.wad in MQL5\Experts\Doom\                         |
//|                                                                  |
//| 4. Recompile this EA in MetaEditor                               |
//|                                                                  |
//| 5. Attach to any chart with "Allow DLL imports" enabled          |
//+------------------------------------------------------------------+

//#define USE_DOOM_DLL

#ifdef USE_DOOM_DLL

//--- DLL imports
#import "doomlib.dll"
int  DoomInit(string wadDir);
void DoomShutdown();
int  DoomGetFramebuffer(uint &buf[], int bufLen);
int  DoomGetScreenWidth();
int  DoomGetScreenHeight();
void DoomKeyDown(int doomKey);
void DoomKeyUp(int doomKey);
#import

#import "user32.dll"
short GetAsyncKeyState(int vKey);
#import

//--- Constants
#define TIMER_MS        33    // ~30 FPS display refresh
#define OBJ_NAME        "DoomScreen"
#define RES_NAME        "::DoomFramebuffer"

//--- DOOM key codes (from PureDOOM.h doom_key_t)
#define DOOM_KEY_TAB          9
#define DOOM_KEY_ENTER        13
#define DOOM_KEY_ESCAPE       27
#define DOOM_KEY_SPACE        32
#define DOOM_KEY_COMMA        44
#define DOOM_KEY_MINUS        0x2D
#define DOOM_KEY_PERIOD       46
#define DOOM_KEY_0            '0'
#define DOOM_KEY_1            '1'
#define DOOM_KEY_2            '2'
#define DOOM_KEY_3            '3'
#define DOOM_KEY_4            '4'
#define DOOM_KEY_5            '5'
#define DOOM_KEY_6            '6'
#define DOOM_KEY_7            '7'
#define DOOM_KEY_8            '8'
#define DOOM_KEY_9            '9'
#define DOOM_KEY_EQUALS       0x3D
#define DOOM_KEY_A            'a'
#define DOOM_KEY_B            'b'
#define DOOM_KEY_C            'c'
#define DOOM_KEY_D            'd'
#define DOOM_KEY_E            'e'
#define DOOM_KEY_F            'f'
#define DOOM_KEY_G            'g'
#define DOOM_KEY_H            'h'
#define DOOM_KEY_I            'i'
#define DOOM_KEY_J            'j'
#define DOOM_KEY_K            'k'
#define DOOM_KEY_L            'l'
#define DOOM_KEY_M            'm'
#define DOOM_KEY_N            'n'
#define DOOM_KEY_O            'o'
#define DOOM_KEY_P            'p'
#define DOOM_KEY_Q            'q'
#define DOOM_KEY_R            'r'
#define DOOM_KEY_S            's'
#define DOOM_KEY_T            't'
#define DOOM_KEY_U            'u'
#define DOOM_KEY_V            'v'
#define DOOM_KEY_W            'w'
#define DOOM_KEY_X            'x'
#define DOOM_KEY_Y            'y'
#define DOOM_KEY_Z            'z'
#define DOOM_KEY_BACKSPACE    127
#define DOOM_KEY_CTRL         (0x80+0x1D)   // 0x9D
#define DOOM_KEY_LEFT_ARROW   0xAC
#define DOOM_KEY_UP_ARROW     0xAD
#define DOOM_KEY_RIGHT_ARROW  0xAE
#define DOOM_KEY_DOWN_ARROW   0xAF
#define DOOM_KEY_SHIFT        (0x80+0x36)   // 0xB6
#define DOOM_KEY_ALT          (0x80+0x38)   // 0xB8
#define DOOM_KEY_F1           (0x80+0x3B)
#define DOOM_KEY_F2           (0x80+0x3C)
#define DOOM_KEY_F3           (0x80+0x3D)
#define DOOM_KEY_F4           (0x80+0x3E)
#define DOOM_KEY_F5           (0x80+0x3F)
#define DOOM_KEY_F6           (0x80+0x40)
#define DOOM_KEY_F7           (0x80+0x41)
#define DOOM_KEY_F8           (0x80+0x42)
#define DOOM_KEY_F9           (0x80+0x43)
#define DOOM_KEY_F10          (0x80+0x44)
#define DOOM_KEY_F11          (0x80+0x57)
#define DOOM_KEY_F12          (0x80+0x58)
#define DOOM_KEY_PAUSE        0xFF
#define DOOM_KEY_UNKNOWN      (-1)

//--- Windows Virtual Key codes we care about
#define VK_BACK       0x08
#define VK_TAB        0x09
#define VK_RETURN     0x0D
#define VK_SHIFT      0x10
#define VK_CONTROL    0x11
#define VK_MENU       0x12   // Alt
#define VK_PAUSE      0x13
#define VK_ESCAPE     0x1B
#define VK_SPACE      0x20
#define VK_LEFT       0x25
#define VK_UP         0x26
#define VK_RIGHT      0x27
#define VK_DOWN       0x28
#define VK_0          0x30
#define VK_9          0x39
#define VK_A          0x41
#define VK_Z          0x5A
#define VK_F1         0x70
#define VK_F12        0x7B
#define VK_OEM_COMMA  0xBC
#define VK_OEM_MINUS  0xBD
#define VK_OEM_PERIOD 0xBE
#define VK_OEM_PLUS   0xBB

//--- Global state
int    g_screenW = 0;
int    g_screenH = 0;
int    g_totalPixels = 0;
uint   g_pixels[];
bool   g_initialized = false;

//--- Tracked key states for key-up polling
struct KeyMapping
{
   int vk;       // Windows virtual key code
   int doomKey;  // DOOM key code
};

KeyMapping g_keymap[];
bool       g_keyStates[];  // true = currently pressed

//+------------------------------------------------------------------+
//| Build the VK -> DOOM key mapping table                           |
//+------------------------------------------------------------------+
void BuildKeyMap()
{
   int count = 0;

   // Pre-count: letters(26) + digits(10) + special keys(~15) + F-keys(12) = ~63
   ArrayResize(g_keymap, 80);
   ArrayResize(g_keyStates, 80);

   // Letters A-Z
   for(int vk = VK_A; vk <= VK_Z; vk++)
   {
      g_keymap[count].vk = vk;
      g_keymap[count].doomKey = 'a' + (vk - VK_A);
      g_keyStates[count] = false;
      count++;
   }

   // Digits 0-9
   for(int vk = VK_0; vk <= VK_9; vk++)
   {
      g_keymap[count].vk = vk;
      g_keymap[count].doomKey = '0' + (vk - VK_0);
      g_keyStates[count] = false;
      count++;
   }

   // F-keys F1-F12
   for(int i = 0; i < 12; i++)
   {
      g_keymap[count].vk = VK_F1 + i;
      g_keymap[count].doomKey = DOOM_KEY_F1 + i;
      g_keyStates[count] = false;
      count++;
   }

   // Special keys
   int specials[][2] = {
      { VK_RETURN,     DOOM_KEY_ENTER },
      { VK_ESCAPE,     DOOM_KEY_ESCAPE },
      { VK_SPACE,      DOOM_KEY_SPACE },
      { VK_TAB,        DOOM_KEY_TAB },
      { VK_BACK,       DOOM_KEY_BACKSPACE },
      { VK_CONTROL,    DOOM_KEY_CTRL },
      { VK_SHIFT,      DOOM_KEY_SHIFT },
      { VK_MENU,       DOOM_KEY_ALT },
      { VK_LEFT,       DOOM_KEY_LEFT_ARROW },
      { VK_UP,         DOOM_KEY_UP_ARROW },
      { VK_RIGHT,      DOOM_KEY_RIGHT_ARROW },
      { VK_DOWN,       DOOM_KEY_DOWN_ARROW },
      { VK_PAUSE,      DOOM_KEY_PAUSE },
      { VK_OEM_COMMA,  DOOM_KEY_COMMA },
      { VK_OEM_MINUS,  DOOM_KEY_MINUS },
      { VK_OEM_PERIOD, DOOM_KEY_PERIOD },
      { VK_OEM_PLUS,   DOOM_KEY_EQUALS }
   };

   int numSpecials = ArrayRange(specials, 0);
   for(int i = 0; i < numSpecials; i++)
   {
      g_keymap[count].vk = specials[i][0];
      g_keymap[count].doomKey = specials[i][1];
      g_keyStates[count] = false;
      count++;
   }

   // Trim arrays to actual count
   ArrayResize(g_keymap, count);
   ArrayResize(g_keyStates, count);
}

//+------------------------------------------------------------------+
//| Map a single VK code to DOOM key code                            |
//+------------------------------------------------------------------+
int VkToDoomKey(int vk)
{
   int count = ArraySize(g_keymap);
   for(int i = 0; i < count; i++)
   {
      if(g_keymap[i].vk == vk)
         return g_keymap[i].doomKey;
   }
   return DOOM_KEY_UNKNOWN;
}

//+------------------------------------------------------------------+
//| Find key index in mapping table by VK code                       |
//+------------------------------------------------------------------+
int FindKeyIndex(int vk)
{
   int count = ArraySize(g_keymap);
   for(int i = 0; i < count; i++)
   {
      if(g_keymap[i].vk == vk)
         return i;
   }
   return -1;
}

//+------------------------------------------------------------------+
//| Poll key states and send key-up events for released keys          |
//+------------------------------------------------------------------+
void PollKeyStates()
{
   int count = ArraySize(g_keymap);
   for(int i = 0; i < count; i++)
   {
      short state = GetAsyncKeyState(g_keymap[i].vk);
      bool isDown = (state & 0x8000) != 0;

      if(g_keyStates[i] && !isDown)
      {
         // Key was pressed, now released
         DoomKeyUp(g_keymap[i].doomKey);
         g_keyStates[i] = false;
      }
   }
}

//+------------------------------------------------------------------+
//| Configure chart as a clean display surface                        |
//+------------------------------------------------------------------+
void SetupChart()
{
   ChartSetInteger(0, CHART_SHOW, false);
   ChartSetInteger(0, CHART_KEYBOARD_CONTROL, false);
}

//+------------------------------------------------------------------+
//| Restore chart to normal state                                     |
//+------------------------------------------------------------------+
void RestoreChart()
{
   ChartSetInteger(0, CHART_SHOW, true);
}

//+------------------------------------------------------------------+
//| Expert initialization                                             |
//+------------------------------------------------------------------+
int OnInit()
{
   // Build key mapping table
   BuildKeyMap();

   // Configure chart
   SetupChart();

   // Get WAD directory path
   string wadDir = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Experts\\Doom";

   // Initialize DOOM engine
   if(!DoomInit(wadDir))
   {
      Print("DOOM: Failed to initialize engine");
      return INIT_FAILED;
   }

   // Query scaled resolution from DLL
   g_screenW = DoomGetScreenWidth();
   g_screenH = DoomGetScreenHeight();
   g_totalPixels = g_screenW * g_screenH;

   // Allocate pixel buffer
   ArrayResize(g_pixels, g_totalPixels);
   ArrayInitialize(g_pixels, 0);

   // Create bitmap label object
   ObjectCreate(0, OBJ_NAME, OBJ_BITMAP_LABEL, 0, 0, 0);
   ObjectSetInteger(0, OBJ_NAME, OBJPROP_XDISTANCE, 0);
   ObjectSetInteger(0, OBJ_NAME, OBJPROP_YDISTANCE, 0);
   ObjectSetInteger(0, OBJ_NAME, OBJPROP_XSIZE, g_screenW);
   ObjectSetInteger(0, OBJ_NAME, OBJPROP_YSIZE, g_screenH);
   ObjectSetString(0, OBJ_NAME, OBJPROP_BMPFILE, RES_NAME);
   ObjectSetInteger(0, OBJ_NAME, OBJPROP_BACK, false);

   // Create initial resource
   ResourceCreate(RES_NAME, g_pixels, g_screenW, g_screenH, 0, 0, g_screenW, COLOR_FORMAT_ARGB_NORMALIZE);

   // Start timer for frame updates
   EventSetMillisecondTimer(TIMER_MS);

   g_initialized = true;
   Print("DOOM: Initialized successfully (", g_screenW, "x", g_screenH, ")");

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();

   if(g_initialized)
   {
      DoomShutdown();
      g_initialized = false;
   }

   // Clean up chart objects
   ObjectDelete(0, OBJ_NAME);
   ResourceFree(RES_NAME);

   // Restore chart
   RestoreChart();
   ChartRedraw(0);

   Print("DOOM: Shutdown complete");
}

//+------------------------------------------------------------------+
//| Timer — grab framebuffer and render to chart                      |
//+------------------------------------------------------------------+
void OnTimer()
{
   if(!g_initialized)
      return;

   // Poll for key releases
   PollKeyStates();

   // Grab framebuffer from DLL
   if(DoomGetFramebuffer(g_pixels, g_totalPixels))
   {
      // Update the bitmap resource
      ResourceCreate(RES_NAME, g_pixels, g_screenW, g_screenH, 0, 0, g_screenW, COLOR_FORMAT_ARGB_NORMALIZE);
      ChartRedraw(0);
   }
}

//+------------------------------------------------------------------+
//| Chart event handler — capture keyboard input                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(!g_initialized)
      return;

   if(id == CHARTEVENT_KEYDOWN)
   {
      int vk = (int)lparam;
      int doomKey = VkToDoomKey(vk);

      if(doomKey != DOOM_KEY_UNKNOWN)
      {
         // Track key state
         int idx = FindKeyIndex(vk);
         if(idx >= 0)
            g_keyStates[idx] = true;

         DoomKeyDown(doomKey);
      }
   }
}

#else // USE_DOOM_DLL not defined — stub mode for CodeBase compliance

//+------------------------------------------------------------------+
//| Expert initialization (stub)                                      |
//+------------------------------------------------------------------+
int OnInit()
{
   Comment("DOOM EA: DLL mode is disabled.\n"
           "To enable, open DoomEA.mq5 and uncomment:\n"
           "   #define USE_DOOM_DLL\n\n"
           "Then place doomlib.dll in MQL5\\Libraries\\\n"
           "and doom1.wad in MQL5\\Experts\\Doom\\\n"
           "and recompile.");

   Print("DOOM EA: Running in stub mode. Uncomment #define USE_DOOM_DLL to enable.");
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization (stub)                                    |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Comment("");
}

#endif // USE_DOOM_DLL
//+------------------------------------------------------------------+
