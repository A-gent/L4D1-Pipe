#include <sdkhooks>
#include <sourcemod>


//
//
//  ,------.  ,------.,------.,--.,--.  ,--.,------. ,---.       ,---.        ,--.,--.  ,--. ,-----.,--.   ,--. ,--.,------.  ,------. ,---.   
//  |  .-.  \ |  .---'|  .---'|  ||  ,'.|  ||  .---''   .-'     |  o ,-.      |  ||  ,'.|  |'  .--./|  |   |  | |  ||  .-.  \ |  .---''   .-'  
//  |  |  \  :|  `--, |  `--, |  ||  |' '  ||  `--, `.  `-.     .'     /_     |  ||  |' '  ||  |    |  |   |  | |  ||  |  \  :|  `--, `.  `-.  
//  |  '--'  /|  `---.|  |`   |  ||  | `   ||  `---..-'    |    |  o  .__)    |  ||  | `   |'  '--'\|  '--.'  '-'  '|  '--'  /|  `---..-'    | 
//  `-------' `------'`--'    `--'`--'  `--'`------'`-----'      `---'        `--'`--'  `--' `-----'`-----' `-----' `-------' `------'`-----'  
//
//


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////TICKRATE FIXES
///
//Cvars
ConVar g_hPistolDelayDualies;
ConVar g_hPistolDelaySingle;
ConVar g_hPistolDelayIncapped;

//Floats
float g_fNextAttack[MAXPLAYERS + 1];
float g_fPistolDelayDualies 		= 0.1;
float g_fPistolDelaySingle 		= 0.2;
float g_fPistolDelayIncapped 		= 0.3;

float tickInterval;
float tickRRate;

//Cvar Check & Adjust
ConVar g_hCvarGravity;
//
///
///
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////EXTENDED MAP CONFIG PLUGIN
///
//
//

#pragma semicolon 1

#define VERSION                      "1.0"

#define PATH_PREFIX_ACTUAL           "cfg/"
#define PATH_PREFIX_VISIBLE          "mapconfig/"
#define PATH_PREFIX_VISIBLE_GENERAL  "mapconfig/general/"
#define PATH_PREFIX_VISIBLE_GAMETYPE "mapconfig/gametype/"
#define PATH_PREFIX_VISIBLE_MAP      "mapconfig/maps/"

#define TYPE_GENERAL                 0
#define TYPE_MAP                     1
#define TYPE_GAMETYPE                2
//
///
///
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////CLIENT EXEC PLUGIN
///
#define PLUGIN_VERSION "1.0.0.3"
//
///
///
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////NEW PLUGIN HERE
///

//
///
///
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//   ,----.   ,--.    ,-----. ,-----.    ,---.  ,--.       ,--.   ,--.,---.  ,------. ,--.  ,---.  ,-----.  ,--.   ,------. ,---.   
//  '  .-./   |  |   '  .-.  '|  |) /_  /  O  \ |  |        \  `.'  //  O  \ |  .--. '|  | /  O  \ |  |) /_ |  |   |  .---''   .-'  
//  |  | .---.|  |   |  | |  ||  .-.  \|  .-.  ||  |         \     /|  .-.  ||  '--'.'|  ||  .-.  ||  .-.  \|  |   |  `--, `.  `-.  
//  '  '--'  ||  '--.'  '-'  '|  '--' /|  | |  ||  '--.       \   / |  | |  ||  |\  \ |  ||  | |  ||  '--' /|  '--.|  `---..-'    | 
//   `------' `-----' `-----' `------' `--' `--'`-----'        `-'  `--' `--'`--' '--'`--'`--' `--'`------' `-----'`------'`-----'  
//
//













public Plugin:myinfo = {
	name        = "PipeCFG",
	author      = "Agent",
	description = "My custom CFG Pipe for L4D1",
	version     = VERSION,
	url         = "http://sourcemod.corks.nl/"
};



public OnPluginStart() {
	
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////EXTENDED MAP CONFIG PLUGIN
///
	CreateConVar("extendedmapconfig_version", VERSION, "Current version of the extended mapconfig plugin", FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	createConfigFiles();
//
///
///
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////TICKRATE FIXES
///
	//Is Server 40+ Tick?
    tickInterval = GetTickInterval();
    if(0.0 < tickInterval) tickRRate = 1.0/tickInterval;
    if(tickRRate >= 40)
    {
        //Hook Pistols
        for (int client = 1; client <= MaxClients; client++)
        {
            if (!IsClientInGame(client)) continue;
            SDKHook(client, SDKHook_PostThinkPost, Hook_OnPostThinkPost);
        }
        g_hPistolDelayDualies = CreateConVar("l4d_pistol_delay_dualies", "0.1", "Minimum time (in seconds) between dual pistol shots", FCVAR_SPONLY | FCVAR_NOTIFY, true, 0.0, true, 5.0);
        g_hPistolDelaySingle = CreateConVar("l4d_pistol_delay_single", "0.2", "Minimum time (in seconds) between single pistol shots", FCVAR_SPONLY | FCVAR_NOTIFY, true, 0.0, true, 5.0);
        g_hPistolDelayIncapped = CreateConVar("l4d_pistol_delay_incapped", "0.3", "Minimum time (in seconds) between pistol shots while incapped", FCVAR_SPONLY | FCVAR_NOTIFY, true, 0.0, true, 5.0);
        
        UpdatePistolDelays();
        
        HookConVarChange(g_hPistolDelayDualies, Cvar_PistolDelay);
        HookConVarChange(g_hPistolDelaySingle, Cvar_PistolDelay);
        HookConVarChange(g_hPistolDelayIncapped, Cvar_PistolDelay);
        HookEvent("weapon_fire", Event_WeaponFire);
        
        //Gravity
        g_hCvarGravity = FindConVar("sv_gravity");
        if (GetConVarInt(g_hCvarGravity) != 750) SetConVarInt(g_hCvarGravity, 750);
    }
	//We don't need you on this 30T Server
	else ServerCommand("sm plugins unload TickrateFixes.smx");
//
///
///
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////CLIENT EXEC PLUGIN
///
    CreateConVar ("sm_cexec_version", PLUGIN_VERSION, "Client Exec version", FCVAR_PLUGIN | FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY);
    /* register the sm_cexec console command */
    RegAdminCmd ("sm_cexec", ClientExec, ADMFLAG_RCON);
    RegAdminCmd ("sm_pipe", ClientExec, ADMFLAG_RCON);   // Can be used with the following syntax: !sm_pipe "#all" "say TEST"
//
///
///
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////NEW PLUGIN HERE
///

//
///
///
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
}





public OnConfigsExecuted() {
	

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////EXTENDED MAP CONFIG PLUGIN
///
	new String:configFilename[PLATFORM_MAX_PATH];
	new String:name[PLATFORM_MAX_PATH];
	// Execute general config
	name = "all";
	getConfigFilename(configFilename, sizeof(configFilename), name, TYPE_GENERAL);
	PrintToServer("Loading mapconfig: general configfile (%s.cfg).", name);
	ServerCommand("exec \"%s\"", configFilename);
	// Execute gametype config
	GetCurrentMap(name, sizeof(name));
	if (SplitString(name, "_", name, sizeof(name)) != -1) {
		getConfigFilename(configFilename, sizeof(configFilename), name, TYPE_GAMETYPE);
		PrintToServer("Loading mapconfig: gametype configfile (%s.cfg).", name);
		ServerCommand("exec \"%s\"", configFilename);
	}
	// Execute map's config
	GetCurrentMap(name, sizeof(name));
	getConfigFilename(configFilename, sizeof(configFilename), name, TYPE_MAP);
	PrintToServer("Loading mapconfig: mapspecific configfile (%s.cfg).", name);
	ServerCommand("exec \"%s\"", configFilename);
//
///
///
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////NEW PLUGIN HERE
///

//
///
///
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
}

//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//   ,-----. ,-----. ,--.   ,--.,--.   ,--.  ,---.  ,--.  ,--.,------.      ,--.  ,--.  ,---.  ,--.  ,--.,------.  ,--.   ,------. ,---.   
//  '  .--./'  .-.  '|   `.'   ||   `.'   | /  O  \ |  ,'.|  ||  .-.  \     |  '--'  | /  O  \ |  ,'.|  ||  .-.  \ |  |   |  .---''   .-'  
//  |  |    |  | |  ||  |'.'|  ||  |'.'|  ||  .-.  ||  |' '  ||  |  \  :    |  .--.  ||  .-.  ||  |' '  ||  |  \  :|  |   |  `--, `.  `-.  
//  '  '--'\'  '-'  '|  |   |  ||  |   |  ||  | |  ||  | `   ||  '--'  /    |  |  |  ||  | |  ||  | `   ||  '--'  /|  '--.|  `---..-'    | 
//   `-----' `-----' `--'   `--'`--'   `--'`--' `--'`--'  `--'`-------'     `--'  `--'`--' `--'`--'  `--'`-------' `-----'`------'`-----'  
//
//



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////EXTENDED MAP CONFIG PLUGIN
///
createConfigFiles() {
	new String:game[64];
	new String:name[PLATFORM_MAX_PATH];
	// Fetch the current game/mod
	GetGameFolderName(game, sizeof(game));
	// Create the directory structure (if it doesnt exist already)
	createConfigDir(PATH_PREFIX_VISIBLE,           PATH_PREFIX_ACTUAL);
	createConfigDir(PATH_PREFIX_VISIBLE,           PATH_PREFIX_ACTUAL);
	createConfigDir(PATH_PREFIX_VISIBLE_GENERAL,   PATH_PREFIX_ACTUAL);
	createConfigDir(PATH_PREFIX_VISIBLE_GAMETYPE,  PATH_PREFIX_ACTUAL);
	createConfigDir(PATH_PREFIX_VISIBLE_MAP,       PATH_PREFIX_ACTUAL);
	// Create general config
	createConfigFile("all",     TYPE_GENERAL,  "All maps");
	// For Team Fortress 2
	if (strcmp(game, "tf", false) == 0) {
		createConfigFile("cp",    TYPE_GAMETYPE, "Control-point maps");
		createConfigFile("ctf",   TYPE_GAMETYPE, "Capture-the-Flag maps");
		createConfigFile("pl",    TYPE_GAMETYPE, "Payload maps");
		createConfigFile("arena", TYPE_GAMETYPE, "Arena-style maps");
	// For Counter-strike and Counter-strike:Source
	} else if (strcmp(game, "cstrike", false) == 0) {
		createConfigFile("cs",    TYPE_GAMETYPE, "Hostage maps");
		createConfigFile("de",    TYPE_GAMETYPE, "Defuse maps");
		createConfigFile("as",    TYPE_GAMETYPE, "Assasination maps");
		createConfigFile("es",    TYPE_GAMETYPE, "Escape maps");
	}
	new Handle:adtMaps = CreateArray(16, 0);
	new serial = -1;
	// Fetch dynamic array of all existing maps on the server
	ReadMapList(adtMaps, serial, "allexistingmaps__", MAPLIST_FLAG_MAPSFOLDER|MAPLIST_FLAG_NO_DEFAULT);
	new mapcount = GetArraySize(adtMaps);
	// Create a cfgfile for each one
	if (mapcount > 0) for (new i = 0; i < mapcount; i++) {
		GetArrayString(adtMaps, i, name, sizeof(name));
		createConfigFile(name, TYPE_MAP, name);
	}
}

// Determine the full path to a config file.
getConfigFilename(String:buffer[], const maxlen, const String:filename[], const type=TYPE_MAP, const bool:actualPath=false) {
	Format(
		buffer, maxlen, "%s%s%s.cfg", (actualPath ? PATH_PREFIX_ACTUAL : ""), (
		type == TYPE_GENERAL ? PATH_PREFIX_VISIBLE_GENERAL : (type == TYPE_GAMETYPE ? PATH_PREFIX_VISIBLE_GAMETYPE : PATH_PREFIX_VISIBLE_MAP)
		), filename
	);
}

createConfigDir(const String:filename[], const String:prefix[]="") {
	new String:dirname[PLATFORM_MAX_PATH];
	Format(dirname, sizeof(dirname), "%s%s", prefix, filename);
	CreateDirectory(
		dirname,  
		FPERM_U_READ + FPERM_U_WRITE + FPERM_U_EXEC + 
		FPERM_G_READ + FPERM_G_WRITE + FPERM_G_EXEC + 
		FPERM_O_READ + FPERM_O_WRITE + FPERM_O_EXEC
	);
}

createConfigFile(const String:filename[], type=TYPE_MAP, const String:label[]="") {
	new String:configFilename[PLATFORM_MAX_PATH];
	new String:configLabel[128];
	new Handle:fileHandle = INVALID_HANDLE;
	getConfigFilename(configFilename, sizeof(configFilename), filename, type, true);
	// Check if config exists
	if (FileExists(configFilename)) return;
	// If it doesnt, create it
	fileHandle = OpenFile(configFilename, "w+");
	// Determine content
	if (strlen(label) > 0) strcopy(configLabel, sizeof(configLabel), label);
	else                   strcopy(configLabel, sizeof(configLabel), configFilename);
	if (fileHandle != INVALID_HANDLE) {
		WriteFileLine(fileHandle, "// Configfile for: %s", configLabel);
		CloseHandle(fileHandle);
	}
}
//
///
///
///
///
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////TICKRATE FIXES
///
public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_PreThink, Hook_OnPostThinkPost);
    g_fNextAttack[client] = 0.0;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_PreThink, Hook_OnPostThinkPost);
}

public void Cvar_PistolDelay(ConVar convar, const char[] oldValue, const char[] newValue)
{
    UpdatePistolDelays();
}

stock UpdatePistolDelays()
{
    g_fPistolDelayDualies = GetConVarFloat(g_hPistolDelayDualies);
    if (g_fPistolDelayDualies < 0.0) g_fPistolDelayDualies = 0.0;
    else if (g_fPistolDelayDualies > 5.0) g_fPistolDelayDualies = 5.0;
    
    g_fPistolDelaySingle = GetConVarFloat(g_hPistolDelaySingle);
    if (g_fPistolDelaySingle < 0.0) g_fPistolDelaySingle = 0.0;
    else if (g_fPistolDelaySingle > 5.0) g_fPistolDelaySingle = 5.0;
    
    g_fPistolDelayIncapped = GetConVarFloat(g_hPistolDelayIncapped);
    if (g_fPistolDelayIncapped < 0.0) g_fPistolDelayIncapped = 0.0;
    else if (g_fPistolDelayIncapped > 5.0) g_fPistolDelayIncapped = 5.0;
}

public Action Hook_OnPostThinkPost(int client)
{
    // Human survivors only
    if (!IsClientInGame(client) || IsFakeClient(client) || GetClientTeam(client) != 2) return;
    int activeweapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
    if (!IsValidEdict(activeweapon)) return;
    char weaponname[64];
    GetEdictClassname(activeweapon, weaponname, sizeof(weaponname));
    if (strcmp(weaponname, "weapon_pistol") != 0) return;
    
    float old_value = GetEntPropFloat(activeweapon, Prop_Send, "m_flNextPrimaryAttack");
    float new_value = g_fNextAttack[client];
    
    // Never accidentally speed up fire rate
    if (new_value > old_value)
    {
        // PrintToChatAll("Readjusting delay: Old=%f, New=%f", old_value, new_value);
        SetEntPropFloat(activeweapon, Prop_Send, "m_flNextPrimaryAttack", new_value);
    }
}

public Action Event_WeaponFire(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (!IsClientInGame(client) || IsFakeClient(client) || GetClientTeam(client) != 2) return;
    int activeweapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
    if (!IsValidEdict(activeweapon)) return;
    char weaponname[64];
    GetEdictClassname(activeweapon, weaponname, sizeof(weaponname));
    if (strcmp(weaponname, "weapon_pistol") != 0) return;
    // int dualies = GetEntProp(activeweapon, Prop_Send, "m_hasDualWeapons");
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated"))
    {
        g_fNextAttack[client] = GetGameTime() + g_fPistolDelayIncapped;
    }
    // What is the difference between m_isDualWielding and m_hasDualWeapons ?
    else if (GetEntProp(activeweapon, Prop_Send, "m_isDualWielding"))
    {
        g_fNextAttack[client] = GetGameTime() + g_fPistolDelayDualies;
    }
    else
    {
        g_fNextAttack[client] = GetGameTime() + g_fPistolDelaySingle;
    }
}


//
///
///
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////CLIENT EXEC PLUGIN
///
public Action:ClientExec (client, args)
{
    decl String:szClient[MAX_NAME_LENGTH] = "";
    decl String:szCommand[80] = "";
    static iClient = -1, iMaxClients = 0;

    iMaxClients = GetMaxClients ();

    if (args == 2)
    {
        GetCmdArg (1, szClient, sizeof (szClient));
        GetCmdArg (2, szCommand, sizeof (szCommand));

        if (!strcmp (szClient, "#all", false))
        {
            for (iClient = 1; iClient <= iMaxClients; iClient++)
            {
                if (IsClientConnected (iClient) && IsClientInGame (iClient))
                {
                    if (IsFakeClient (iClient))
                        FakeClientCommand (iClient, szCommand);
                    else
                        ClientCommand (iClient, szCommand);
                }
            }
        }
        else if (!strcmp (szClient, "#bots", false))
        {
            for (iClient = 1; iClient <= iMaxClients; iClient++)
            {
                if (IsClientConnected (iClient) && IsClientInGame (iClient) && IsFakeClient (iClient))
                    FakeClientCommand (iClient, szCommand);
            }
        }
        else if ((iClient = FindTarget (client, szClient, false, true)) != -1)
        {
            if (IsFakeClient (iClient))
                FakeClientCommand (iClient, szCommand);
            else
                ClientCommand (iClient, szCommand);
        }
    }
    else
    {
        ReplyToCommand (client, "sm_cexec invalid format");
        ReplyToCommand (client, "Usage: sm_cexec \"<user>\" \"<command>\"");
    }

    return Plugin_Handled;
}


//
///
///
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////NEW PLUGIN HERE
///

//
///
///
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////