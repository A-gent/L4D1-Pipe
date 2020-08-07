
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
//#include "left4downtown.inc"


/*
* PROGRAMMING CREDITS:
* Could not do this without Fyren at all, it was his original code chunk 
* 	that got me started (especially turning off directors and freezing players).
* 	Thanks to him for answering all of my silly coding questions too.
* 
* TESTING CREDITS:
* 
* Biggest #1 thanks goes out to Fission for always being there since the beginning
* even when this plugin was barely working.
*/



#define READY_RESTART_MAP_DELAY 5.0
#define READY_RESTART_SCAVENGE_TIMER 0.1
#define READY_DEBUG 0


new bool:isMapRestartPending;
new Handle:fwdOnReadyRoundRestarted = INVALID_HANDLE;




public OnPluginStart()
{

	RegAdminCmd("sm_restartmap", CommandRestartMap, ADMFLAG_CHANGEMAP, "sm_restartmap - changelevels to the current map");
	RegConsoleCmd("spectate", Command_Spectate);

}







public Action:CommandRestartMap(client, args)
{	
	//if(!isMapRestartPending)
	//{
		PrintToChatAll("\x05 [Pipe]: \x04 Map resetting in %.0f seconds.", READY_RESTART_MAP_DELAY);
		RestartMapDelayed();
	//}
	
	return Plugin_Handled;
}

RestartMapDelayed()
{
	//isMapRestartPending = true;
	
	CreateTimer(READY_RESTART_MAP_DELAY, timerRestartMap, _, TIMER_FLAG_NO_MAPCHANGE);
	PrintToChatAll("\x05 [Pipe]: \x04 Map will restart in %f seconds.", READY_RESTART_MAP_DELAY);
}

public Action:timerRestartMap(Handle:timer)
{
	RestartMapNow();
}

RestartMapNow()
{
	isMapRestartPending = false;
	
	decl String:currentMap[256];
	
	GetCurrentMap(currentMap, 256);
	
	ServerCommand("changelevel %s", currentMap);
}






public Action:Command_Spectate(client, args)
{
	if(IsPlayerAlive(client) && GetClientTeam(client) == L4D_TEAM_INFECTED)
	{
		ForcePlayerSuicide(client);
	}
	if(GetClientTeam(client) != L4D_TEAM_SPECTATE)
	{
		ChangePlayerTeam(client, L4D_TEAM_SPECTATE);
		PrintToChatAll("[SM] %N has become a spectator.", client);
	}
	//respectate trick to get around spectator camera being stuck
	else
	{
		ChangePlayerTeam(client, L4D_TEAM_INFECTED);
		CreateTimer(0.1, Timer_Respectate, client, TIMER_FLAG_NO_MAPCHANGE);
	}

	return Plugin_Handled;
}





