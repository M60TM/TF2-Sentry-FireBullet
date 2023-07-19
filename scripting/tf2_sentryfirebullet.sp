#pragma semicolon 1
#include <sourcemod>

#include <dhooks_gameconf_shim>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>

#pragma newdecls required

#include <stocksoup/tf/entity_prop_stocks>
#include <stocksoup/memory>

#include <classdefs/firebulletsinfo_t.sp>

static GlobalForward g_FwdSentryFireBulletPre;
static GlobalForward g_FwdSentryFireBulletPost;

static DynamicHook g_DHookSentryFireBullet;

/*
enum struct FireBullets_t
{
	int   m_iShots;		//0
	float m_vecSrc[3];	//4,8,12
	float m_vecDirShooting[3]; // 16,20,24
	float m_vecSpread[3]; //28,32,36
	float m_flDistance; // 40
	int   m_iAmmoType; // 44
	int   m_iTracerFreq; // 48
	float m_flDamage; //52
	int   m_iPlayerDamage;	// 56 => Damage to be used instead of m_flDamage if we hit a player
	int   m_nFlags;			// 60 => See FireBulletsFlags_t
	float m_flDamageForceScale; // 64
	int   m_pAttacker; // 68
	int   m_pAdditionalIgnoreEnt; // 72
	bool  m_bPrimaryAttack; // 76
	bool  m_bUseServerRandomSeed; // 77
}
*/

public Plugin myinfo =
{
	name        = "[TF2] Sentry Fire Bullet",
	author      = "Sandy and AzulFlamaWallon",
	description = "Hook Sentry's Bullet Fire.",
	version     = "1.0.0",
	url         = "https://github.com/M60TM/TF2-Sentry-FireBullet"
};

public APLRes AskPluginLoad2(Handle hPlugin, bool late, char[] error, int maxlen) {
	RegPluginLibrary("tf2_sentryfirebullet");

	return APLRes_Success;
}

public void OnPluginStart(){
	GameData data = new GameData("FireBullets");
	if (data == null)
	{
		SetFailState("Missing FireBullets.txt");
	}
	else if (!ReadDHooksDefinitions("FireBullets"))
	{
		SetFailState("Failed to read dhooks definitions of FireBullets.txt");
	}

	g_DHookSentryFireBullet = GetDHooksHookDefinition(data, "CBaseEntity::FireBullets");
	g_DHookSentryFireBullet.AddParam(HookParamType_Int);

	delete data;

	g_FwdSentryFireBulletPre = new GlobalForward("TF2_SentryFireBullet", ET_Hook, Param_Cell, Param_Cell, Param_CellByRef, Param_Array, Param_Array, Param_Array, Param_FloatByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef);

	g_FwdSentryFireBulletPost = new GlobalForward("TF2_SentryFireBulletPost", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Array, Param_Array, Param_Array, Param_Float, Param_Cell, Param_Float, Param_Cell, Param_Cell, Param_Float, Param_Cell, Param_Cell);
}

public void OnEntityCreated(int entity, const char[] classname){
	if (IsValidEntity(entity) && StrContains(classname, "obj_sentrygun") != -1)
		RequestFrame(OnSentryGunCreated, entity);
}

public void OnSentryGunCreated(int sentry){
	g_DHookSentryFireBullet.HookEntity(Hook_Pre, sentry, OnSentryFireBulletsPre);
	g_DHookSentryFireBullet.HookEntity(Hook_Post, sentry, OnSentryFireBulletsPost);
}

// CBaseEntity::FireBullets(const FireBullets_t &_Info)
MRESReturn OnSentryFireBulletsPre(int sentry, DHookParam hParams)
{
	if(!IsValidEntity(sentry))
		return MRES_Ignored;

	FireBullets_t info = FireBullets_t.FromAddress(hParams.Get(1));
	
	int builder = TF2_GetObjectBuilder(sentry);

	if (!IsValidClient(builder))
	{
		return MRES_Ignored;
	}

	bool result = CallFireBulletsInfoForward(g_FwdSentryFireBulletPre, sentry, builder, info);
	
	return result ? MRES_Supercede : MRES_Ignored;
}

MRESReturn OnSentryFireBulletsPost(int sentry, DHookParam hParams)
{
	if(!IsValidEntity(sentry))
		return MRES_Ignored;

	FireBullets_t info = FireBullets_t.FromAddress(hParams.Get(1));
	
	int builder = TF2_GetObjectBuilder(sentry);

	if (!IsValidClient(builder))
	{
		return MRES_Ignored;
	}

	CallFireBulletsInfoPostForward(g_FwdSentryFireBulletPost, sentry, builder, info);

	return MRES_Ignored;
}

bool CallFireBulletsInfoForward(GlobalForward fwd, int sentry, int builder, FireBullets_t info) {
	int shots = info.m_iShots;
	
	float src[3], dirShooting[3], spread[3];
	info.GetVecSrc(src);
	info.GetVecDirShooting(dirShooting);
	info.GetVecSpread(spread);

	float distance = info.m_flDistance;
	int tracerFreq = info.m_iTracerFreq;
	float damage = info.m_flDamage;
	int playerDamage = info.m_iPlayerDamage;
	int flags = info.m_nFlags;
	float damageForceScale = info.m_flDamageForceScale;

	int attacker = (info.m_pAttacker == Address_Null) ? -1 : GetEntityFromAddress(info.m_pAttacker);
	int ignoreEnt = (info.m_pAdditionalIgnoreEnt == Address_Null) ? -1 : GetEntityFromAddress(info.m_pAdditionalIgnoreEnt);
	
	Call_StartForward(fwd);
	Call_PushCell(sentry);
	Call_PushCell(builder);
	Call_PushCellRef(shots);
	Call_PushArrayEx(src, 3, SM_PARAM_COPYBACK);
	Call_PushArray(dirShooting, 3);
	Call_PushArrayEx(spread, 3, SM_PARAM_COPYBACK);
	Call_PushFloatRef(distance);
	Call_PushCellRef(tracerFreq);
	Call_PushFloatRef(damage);
	Call_PushCellRef(playerDamage);
	Call_PushCellRef(flags);
	Call_PushFloatRef(damageForceScale);
	Call_PushCellRef(attacker);
	Call_PushCellRef(ignoreEnt);
	
	Action result;
	Call_Finish(result);
	
	bool supercede;
	switch (result)
	{
		case Plugin_Handled, Plugin_Stop:
		{
			supercede = true;
		}
		case Plugin_Changed:
		{
			info.m_iShots = shots;
			
			info.SetVecSrc(src);
			info.SetVecSpread(spread);

			info.m_flDistance = distance;
			info.m_iAmmoType = ammoType;
			info.m_iTracerFreq = tracerFreq;
			info.m_flDamage = damage;
			info.m_iPlayerDamage = playerDamage;
			info.m_nFlags = flags;
			info.m_flDamageForceScale = damageForceScale;

			info.m_pAttacker = IsValidEntity(attacker) ? GetEntityAddress(attacker) : Address_Null;
			info.m_pAdditionalIgnoreEnt = IsValidEntity(ignoreEnt) ? GetEntityAddress(ignoreEnt) : Address_Null;

			supercede = false;
		}
		case Plugin_Continue:
		{
			supercede = false;
		}
	}
	
	return supercede;
}

void CallFireBulletsInfoPostForward(GlobalForward fwd, int sentry, int builder, FireBullets_t info) {
	int shots = info.m_iShots;
	
	float src[3], dirShooting[3], spread[3];
	info.GetVecSrc(src);
	info.GetVecDirShooting(dirShooting);
	info.GetVecSpread(spread);

	float distance = info.m_flDistance;
	int tracerFreq = info.m_iTracerFreq;
	float damage = info.m_flDamage;
	int playerDamage = info.m_iPlayerDamage;
	int flags = info.m_nFlags;
	float damageForceScale = info.m_flDamageForceScale;

	int attacker = (info.m_pAttacker == Address_Null) ? -1 : GetEntityFromAddress(info.m_pAttacker);
	int ignoreEnt = (info.m_pAdditionalIgnoreEnt == Address_Null) ? -1 : GetEntityFromAddress(info.m_pAdditionalIgnoreEnt);
	
	Call_StartForward(fwd);
	Call_PushCell(sentry);
	Call_PushCell(builder);
	Call_PushCell(shots);
	Call_PushArray(src, 3);
	Call_PushArray(dirShooting, 3);
	Call_PushArray(spread, 3);
	Call_PushFloat(distance);
	Call_PushCell(tracerFreq);
	Call_PushFloat(damage);
	Call_PushCell(playerDamage);
	Call_PushCell(flags);
	Call_PushFloat(damageForceScale);
	Call_PushCell(attacker);
	Call_PushCell(ignoreEnt);
	Call_Finish();
}

stock bool IsValidClient(int client, bool replaycheck=true)
{
	if(client<=0 || client>MaxClients)
		return false;

	if(!IsClientInGame(client))
		return false;

	if(GetEntProp(client, Prop_Send, "m_bIsCoaching"))
		return false;

	if(replaycheck && (IsClientSourceTV(client) || IsClientReplay(client)))
		return false;

	return true;
}