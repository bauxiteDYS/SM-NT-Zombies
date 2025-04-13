#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <neotokyo>

//#define DEBUG true

bool g_enabled;

public Plugin myinfo = {
	name = "Jinrai Zombie game mode",
	description = "Jinrai are zombies with knives and more HP",
	author = "bauxite",
	version = "0.1.0",
	url = "",
};

public void OnPluginStart()
{
	//HookEvent("game_round_start", OnRoundStart, EventHookMode_Post);
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Post);
	RegAdminCmd("sm_zombies", CommandZombies, ADMFLAG_GENERIC);
}

public Action CommandZombies(int client, int args)
{
	g_enabled = !g_enabled;
	
	PrintToChatAll("[Zombies] Jinrai Zombies are now %s", g_enabled ? "enabled" : "disabled");
	
	return Plugin_Handled;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponEquip, OnWeaponEquip);
}

public Action OnWeaponEquip(int client, int weapon)
{
	if(!g_enabled)
	{
		return Plugin_Continue;
	}
	
	if(!IsValidClient(client) || !IsPlayerAlive(client) || GetClientTeam(client) != TEAM_JINRAI)
	{
		return Plugin_Continue;
	}
	
	char className[16];
	
	if(!GetEntityClassname(weapon, className, sizeof(className)))
	{
		return Plugin_Continue; 
	}
	
	if(StrEqual("weapon_knife", className, false))
	{
		return Plugin_Continue;
	}
	
	return Plugin_Handled;
}

public void OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	if(!g_enabled)
	{
		return;
	}
	
	RequestFrame(OnPlayerSpawnPost, GetEventInt(event, "userid"));
}

void OnPlayerSpawnPost(int userid)
{
	int client = GetClientOfUserId(userid);

	if(!IsValidClient(client) || GetClientTeam(client) != TEAM_JINRAI || !IsPlayerAlive(client))
	{
		return;
	}
	
	int nsfCount = GetTeamClientCount(TEAM_NSF);
	
	if(nsfCount >= 10)
	{
		SetEntityHealth(client, 750); // scale by nsf count, and jinrai count?
	}
	else if(nsfCount >= 2)
	{
		SetEntityHealth(client, 200 + (nsfCount - 1) * 50);
	}
	
	StripPlayerWeapons(client, false);
	
	int wepKnife = GivePlayerItem(client, "weapon_knife"); 
	
	if(wepKnife != -1)
	{
		AcceptEntityInput(wepKnife, "use", client, client);
	}
	
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.33);
}

//public void OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
