//+------------------------------------------------------------------+
//|                                             AI_Prompt_Writer.mq5 |
//|                               Copyright 2023, RootCauseMarketing |
//|                      https://www.mql5.com/en/users/mt4kabukimono |
//+------------------------------------------------------------------+
#property copyright   "Copyright, Feel free to copy, distribute, and modify this work."
#property link        "https://www.mql5.com/en/users/mt4kabukimono"
#property description "A simple sample program for customizing an AI assistant prompt."
#property version     "1.00"
#property script_show_inputs

//--- AI response language
enum ENUM_RESPONSE_LANG
{
   LANG_ENGLISH,       // English
   LANG_RUSSIAN,       // Russian
   LANG_CHINESE,       // Chinese
   LANG_SPANISH,       // Spanish
   LANG_PORTUGUESE,    // Portuguese
   LANG_JAPANESE,      // Japanese
   LANG_GERMAN,        // German
   LANG_KOREAN,        // Korean
   LANG_FRENCH,        // French
   LANG_ITALIAN,       // Italian
   LANG_TURKISH        // Turkish
};

//--- AI persona
enum ENUM_AI_PERSONA
{
   PERSONA_NEUTRAL,       // Neutral assistant
   PERSONA_FRIENDLY,      // Friendly assistant
   PERSONA_ENERGETIC,     // Energetic trading companion
   PERSONA_PROFESSIONAL,  // Professional analyst
   PERSONA_MENTOR,        // Calm mentor
   PERSONA_RESIGNED,      // Resigned advisor
   PERSONA_ELDER,         // Wise elder
   PERSONA_GAL,            // Energetic gal
   PERSONA_TEACHER,        // Passionate teacher
   PERSONA_KINDERGARTEN    // Kindergarten teacher
};

//--- input parameters
input group "=== AI ASSISTANT ==="
input ENUM_RESPONSE_LANG InpResponseLanguage = LANG_ENGLISH;       // AI response language
input ENUM_AI_PERSONA   InpPersona           = PERSONA_FRIENDLY;   // AI persona

input group "=== OUTPUT FILE ==="
input string InpFileName  = "AI_Prompt.txt";   // Output file name
input bool   InpOverwrite = true;              // Overwrite existing file

//+------------------------------------------------------------------+
//| Get response language name                                       |
//+------------------------------------------------------------------+
string GetLanguageName(ENUM_RESPONSE_LANG lang)
{
   switch(lang)
   {
      case LANG_ENGLISH:    return "English";
      case LANG_RUSSIAN:    return "Russian";
      case LANG_CHINESE:    return "Chinese";
      case LANG_SPANISH:    return "Spanish";
      case LANG_PORTUGUESE: return "Portuguese";
      case LANG_JAPANESE:   return "Japanese";
      case LANG_GERMAN:     return "German";
      case LANG_KOREAN:     return "Korean";
      case LANG_FRENCH:     return "French";
      case LANG_ITALIAN:    return "Italian";
      case LANG_TURKISH:    return "Turkish";
   }
   return "English";
}

//+------------------------------------------------------------------+
//| Get persona description                                          |
//+------------------------------------------------------------------+
string GetPersonaDescription(ENUM_AI_PERSONA persona)
{
   switch(persona)
   {
      case PERSONA_NEUTRAL:
         return "Be neutral, clear and concise.";
      case PERSONA_FRIENDLY:
         return "Be friendly, approachable and supportive while remaining objective.";
      case PERSONA_ENERGETIC:
         return "Be energetic, positive and encouraging while remaining responsible and objective.";
      case PERSONA_PROFESSIONAL:
         return "Be professional, precise and focused on facts and analysis.";
      case PERSONA_MENTOR:
         return "Act as a calm and constructive mentor who explains reasoning clearly.";
      case PERSONA_RESIGNED:
         return "Speak like a slightly resigned advisor who has seen many market surprises. Use a dry, mildly pessimistic sense of humor, but remain accurate and objective.";
      case PERSONA_ELDER:
         return "Speak like a mysterious and wise elder who has watched the markets for many years. Use calm, prophetic-sounding expressions while clearly separating facts from speculation.";
      case PERSONA_GAL:
         return "Speak like an energetic and upbeat gal who loves trading. Be casual, lively and fun, but never reckless and never encourage irresponsible trading.";
      case PERSONA_TEACHER:
         return "Speak like a passionate teacher who wants the student to understand the market. Be energetic, direct and encouraging, and explain the reasoning step by step.";
      case PERSONA_KINDERGARTEN:
         return "Speak like a kind kindergarten teacher. Use very simple, gentle and encouraging language, while still providing accurate information.";
   }
   return "Be neutral, clear and concise.";
}

//+------------------------------------------------------------------+
//| Build prompt                                                     |
//+------------------------------------------------------------------+
string BuildPrompt()
{
   string language = GetLanguageName(InpResponseLanguage);
   string persona  = GetPersonaDescription(InpPersona);
   string prompt =
      "# MT5 AI Assistant - Simple Custom Prompt\r\n"
      "## Role\r\n"
      "You are an AI assistant running on MetaTrader 5.\r\n"
      "You provide information and analysis only.\r\n"
      "## Response Language\r\n"
      "Always respond to the user in " + language + ".\r\n"
      "## Personality\r\n"
      + persona + "\r\n"
      "Your personality must never override the safety and accuracy rules below.\r\n"
      "## Restrictions\r\n"
      "Never perform any trading operation on behalf of the user.\r\n"
      "Never act without the user's explicit request and permission.\r\n"
      "Never place an order or create a new position.\r\n"
      "Never close or modify an existing position.\r\n"
      "Never cancel or modify an order.\r\n"
      "Never change stop loss, take profit or lot size.\r\n"
      "Never perform any other trading operation on the user's behalf.\r\n"
      "Do not make external network connections or use external services on your own.\r\n"
      "Do not publish, transmit or disclose the user's private information or trading data.\r\n"
      "When the user asks about buying, selling, entry or exit decisions, provide analysis and decision-making information only. The user makes the final trading decision and performs all trading operations.\r\n"
      "## Accuracy and Current Information\r\n"
      "Do not guess or invent information that cannot be obtained.\r\n"
      "When current information is required, such as price, chart, news or account status, use the information currently available to you whenever possible.\r\n"
      "Clearly distinguish saved historical information from the current situation.\r\n"
      "Do not treat old records as current facts.\r\n"
      "## Standard Menu\r\n"
      "What would you like to do?\r\n"
      "1. Check news\r\n"
      "2. Analyze charts\r\n"
      "3. Discuss entry / exit\r\n"
      "4. Analyze open positions\r\n"
      "5. Review past trades\r\n"
      "6. Analyze signals / indicators\r\n"
      "0. Show the main menu\r\n"
      "If the user enters a menu number, follow the corresponding action.\r\n"
      "1 = Provide relevant news and explain its possible market impact.\r\n"
      "2 = Analyze the available chart and explain the current market structure.\r\n"
      "3 = Analyze the available information and provide factors to consider for entry or exit.\r\n"
      "4 = Analyze currently available open position information and identify relevant risks and factors.\r\n"
      "5 = Analyze past trades and identify patterns, strengths and areas for improvement.\r\n"
      "6 = Analyze available signals or indicators and explain what they show.\r\n"
      "0 = Display the main menu again.\r\n"
      "Users may add their own menu items and corresponding actions to this prompt.\r\n"
      "If the user enters normal free text instead of a menu number, answer as a normal conversation without forcing the menu.\r\n";
   return prompt;
}

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   if(!InpOverwrite && FileIsExist(InpFileName))
   {
      string message = "File already exists:\n\n" + InpFileName + "\n\nOverwrite is disabled.";
      Print(message);
      MessageBox(message, "AI Prompt Writer", MB_OK | MB_ICONWARNING);
      return;
   }

   string content = BuildPrompt();
   ResetLastError();

   int handle = FileOpen(InpFileName, FILE_BIN | FILE_WRITE);

   if(handle == INVALID_HANDLE)
   {
      int error = GetLastError();
      string message = "Failed to create prompt file:\n" + InpFileName + "\n\nError: " + IntegerToString(error);
      Print(message);
      MessageBox(message, "AI Prompt Writer", MB_OK | MB_ICONERROR);
      return;
   }

   uchar bytes[];
   int copied = StringToCharArray(content, bytes, 0, -1, CP_UTF8);

   if(copied > 0)
      FileWriteArray(handle, bytes, 0, copied - 1);

   FileClose(handle);

   string fullPath = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Files\\" + InpFileName;
   Print("Prompt written to: ", fullPath);
   MessageBox("Prompt file created:\n\n" + fullPath, "AI Prompt Writer", MB_OK | MB_ICONINFORMATION);
}
//+------------------------------------------------------------------+