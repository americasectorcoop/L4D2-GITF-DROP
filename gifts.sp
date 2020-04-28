#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <colors>

#if SOURCEMOD_V_MINOR < 7
#error Old version sourcemod!
#endif
#pragma newdecls required

#define STAR_1_MDL		"models/editor/air_node_hint.mdl"
#define STAR_2_MDL		"models/editor/air_node.mdl"
#define ELEFANTE_MDL	"models/props_fairgrounds/elephant.mdl"
#define GROUND_MDL		"models/editor/overlay_helper.mdl"
#define LAGARTO_MDL		"models/props_fairgrounds/alligator.mdl"
#define JIRAFA_MDL		"models/props_fairgrounds/giraffe.mdl"
#define REGALO_MDL		"models/items/l4d_gift.mdl"
#define AXIS_MDL		"models/editor/axis_helper_thick.mdl"
#define JETF18_MDL		"models/f18/f18.mdl"
#define MR_MUSTACHIO	"models/props_fairgrounds/mr_mustachio.mdl"
#define CHOPER_TROPHY	"models/props_placeable/chopper_rescue_trophy.mdl"
#define ARMAS_TROFEO	"models/props_placeable/tier2_guns_trophy.mdl"
#define BUG_LAMPARA		"models/props_shacks/bug_lamp01.mdl"


#define	MAX_GIFTS			13
#define MAX_STRING_WIDTH	64

#define TEAM_SURVIVORS		2
#define TEAM_INFECTED		3

#define MAX_NUM_COLORS		7

#define WEAPON_CMD 			0
#define WEAPON_NAME 		1

// #define MODEL_INDEX 		0
// #define TYPE_INDEX 			1

char weapons_list[2][2][14] = {
  {"first_aid_kit", "First Aid Kit"},
  {"adrenaline", "Adrenaline"},
};

// char g_sModels[MAX_GIFTS][2][MAX_STRING_WIDTH] = {
char g_sModels[MAX_GIFTS][MAX_STRING_WIDTH] = {
  STAR_1_MDL,// {STAR_1_MDL, "static"},
  STAR_2_MDL,// {STAR_2_MDL, "static"},
  ELEFANTE_MDL,// {ELEFANTE_MDL, "static"},
  GROUND_MDL,// {GROUND_MDL, "static"},
  LAGARTO_MDL,// {LAGARTO_MDL, "physics"},
  JIRAFA_MDL,// {JIRAFA_MDL, "static"},
  REGALO_MDL,// {REGALO_MDL, "physics"},
  AXIS_MDL,// {AXIS_MDL, "static"},
  JETF18_MDL,// {JETF18_MDL, "static"},
  CHOPER_TROPHY,// {CHOPER_TROPHY, "physics"},
  ARMAS_TROFEO,// {ARMAS_TROFEO, "physics"},
  BUG_LAMPARA,// {BUG_LAMPARA, "physics"},
  MR_MUSTACHIO// {MR_MUSTACHIO, "physics"}
};

char g_Colors[MAX_NUM_COLORS][18] = {
  "0 255 255 255", // COLOR_CYAN
  "144 238 144 255", // COLOR_LIGHT_GREEN
  "128 0 128 255", // COLOR_PURPLE
  "250 88 130 255", // COLOR_PINK
  "255 0 0 255", // COLOR_RED
  "254 100 46 255", // COLOR_ORANGE
  "255 255 0 255" // COLOR_YELLOW
};

// char g_AuraColors[MAX_NUM_COLORS][14] = {
// 	"0 255 255", // COLOR_CYAN
// 	"0 0 255", // COLOR_LIGHT_GREEN
// 	"144 238 144", // COLOR_PURPLE
// 	"250 88 130", // COLOR_PINK
// 	"255 0 0", // COLOR_RED
// 	"254 100 46", // COLOR_ORANGE
// 	"255 255 0" // COLOR_YELLOW
// };

#define POINTS_SOUND	"level/loud/climber.wav"
#define HEALTH_SOUND	"level/gnomeftw.wav"
#define WEAPON_SOUND	"ui/pickup_guitarriff10.wav"

#define MISSILE_DMY		"models/w_models/weapons/w_eq_molotov.mdl"

#define DATE 			"11/06/2017"
#define PLUGIN_VERSION	"0.4"

#define SLOT_NUM		20

// ConVar g_LuffyChance;

int g_LuffyChance 	= 15;
int g_LuffyMax 		= 1;
float g_ItemStay	= 90.0; // numeros de segundos 

// ConVar g_LuffyMax;
// ConVar g_ItemGlow;
// ConVar g_ItemStay;

int gifts_dropped = 0;

Handle g_ItemLife[SLOT_NUM] =  { null, ... };
int g_ItemSlot[SLOT_NUM] =  { -1, ... };
float g_ItemLimitLife[SLOT_NUM] =  { 0.0, ... };

float g_pos[3];

public Plugin myinfo = 
{
  name = "[L4D2] Gifts", 
  author = "Aleexxx", 
  description = "Drop a gift when a Special Infected dead", 
  version = PLUGIN_VERSION, 
  url = "http://www.americasectorcoop.org"
}

public void OnPluginStart()
{
  CreateConVar("asc_gift_version", PLUGIN_VERSION);
  // g_LuffyChance = CreateConVar("gifts_chance", "10", "0%% - 100%%,  Chance SI drop luffy item.");
  // g_LuffyMax = CreateConVar("gifts_max", "3", "Number of luffy item droped at once (Max 20 Luffy).");
  // g_ItemGlow = CreateConVar("gifts_item_glow", "6", "0:off, 1:Light blue, 2:Pink, 3:Yellow, 4:Red, 5:Blue, 6:Random.");
  // g_ItemStay = CreateConVar("gifts_item_life", "100", "How long luffy item droped stay on the ground. Min: 10 sec, Max:300 sec.");
  
  RegAdminCmd("sm_regalo", CMD_SPAWN_GIFT, ADMFLAG_ROOT, "Spawn weapon where you are looking.");
  
  HookEvent("round_start", EVENT_ROUND_START);
  HookEvent("player_death", EVENT_INFECTED_DEATH, EventHookMode_Pre);
}

public void OnMapStart()
{
  gifts_dropped = 0;
  PrecacheAll();
}

void PrecacheAll()
{
  // PrecacheModel(STAR_1_MDL);
  // PrecacheModel(STAR_2_MDL);
  // PrecacheModel(ELEFANTE_MDL);
  // PrecacheModel(LAGARTO_MDL);
  // PrecacheModel(JIRAFA_MDL);
  // PrecacheModel(REGALO_MDL);
  // PrecacheModel(GROUND_MDL);
  // PrecacheModel(JETF18_MDL);
  // PrecacheModel(AXIS_MDL);

  for(int i = 0; i < MAX_GIFTS; i++) {
    // PrecacheModel(g_sModels[i][0]);
    PrecacheModel(g_sModels[i]);
  }
  
  PrecacheSound(WEAPON_SOUND, true);
  PrecacheSound(POINTS_SOUND, true);
  PrecacheSound(HEALTH_SOUND, true);
  
  PrecacheModel(MISSILE_DMY);
}

public Action EVENT_ROUND_START(Event event, const char[] name, bool dontBroadcast)
{
  gifts_dropped = 0;
  for (int i = 1; i < SLOT_NUM; i++)
  {
    g_ItemSlot[i] = -1;
    g_ItemLimitLife[i] = 0.0;
    g_ItemLife[i] = null;
  }
}

public Action CMD_SPAWN_GIFT(int client, int args)
{
  if (client == 0) {
    return Plugin_Handled;
  }

  if (!SetTeleportEndPoint(client)) {
    ReplyToCommand(client, "[GIFT] SpawnError!");
    return Plugin_Handled;
  }
  
  // Verificando la cantidad de regalos
  if(gifts_dropped == 1) {
    ReplyToCommand(client, "[GIFT] Muchos regalos, en la partida");
    return Plugin_Handled;
  }

  // Obteniendo un slot vacio
  int slot = GetEmptySlot();
  
  // Verificando si se encontro un slot valido
  if (slot == -1) {
    ReplyToCommand(client, "[GIFT] No se encontraron slots disponibles!");
    return Plugin_Handled;
  }

  
  // DropItem(g_pos, g_sModels[GetRandomInt(0, MAX_GIFTS - 1)][MODEL_INDEX], slot);
  DropItem(g_pos, g_sModels[GetRandomInt(0, MAX_GIFTS - 1)], slot);
  // Haciendo un Random
  // switch (GetRandomInt(1, 9))
  // {
  // 	case 1: DropItem(g_pos, STAR_1_MDL, slot);
  // 	case 2: DropItem(g_pos, STAR_2_MDL, slot);
  // 	case 3: DropItem(g_pos, ELEFANTE_MDL, slot);
  // 	case 4: DropItem(g_pos, LAGARTO_MDL, slot);
  // 	case 5: DropItem(g_pos, GROUND_MDL, slot);
  // 	case 6: DropItem(g_pos, AXIS_MDL, slot);
  // 	case 7: DropItem(g_pos, JIRAFA_MDL, slot);
  // 	case 8: DropItem(g_pos, REGALO_MDL, slot);
  // 	case 9: DropItem(g_pos, JETF18_MDL, slot);
  // }

  ReplyToCommand(client, "[GIFT] gift is spawned!");
  return Plugin_Handled;
}

public bool SetTeleportEndPoint(int client)
{
  float vAngles[3];
  float vOrigin[3];
  float vBuffer[3];
  float vStart[3];
  float Distance;
  
  GetClientEyePosition(client, vOrigin);
  GetClientEyeAngles(client, vAngles);
  
  Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
  
  if (TR_DidHit(trace))
  {
    TR_GetEndPosition(vStart, trace);
    GetVectorDistance(vOrigin, vStart, false);
    Distance = -35.0;
    GetAngleVectors(vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
    g_pos[0] = vStart[0] + (vBuffer[0] * Distance);
    g_pos[1] = vStart[1] + (vBuffer[1] * Distance);
    g_pos[2] = vStart[2] + (vBuffer[2] * Distance);
    trace.Close();
    return true;
  }

  trace.Close();
  return false;
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask)
{
  return entity > MaxClients || !entity;
}

public Action EVENT_INFECTED_DEATH(Event event, const char[] name, bool dontBroadcast) {
  // Verificando el numero de regalos	
  if(gifts_dropped < g_LuffyMax) {
    int victim = GetClientOfUserId(GetEventInt(event, "userid"));
    int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    if (IsValidInfected(victim)) {
      if(IsValidClient(attacker)) {
        if (GetRandomInt(1, 100) < g_LuffyChance) {
          //int attacker = GetClientOfUserId(event.GetInt("attacker"));
          int slot = GetEmptySlot();
          // Verificando si el infectado es valido y que el slot sea valido
          if (slot != -1) {
            float pos[3];
            GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
            pos[2] += 20.0;
            // DropItem(pos, g_sModels[GetRandomInt(0, MAX_GIFTS - 1)][MODEL_INDEX], slot);
            DropItem(pos, g_sModels[GetRandomInt(0, MAX_GIFTS - 1)], slot);
          }
        }
      }
    }
  }
}

void DropItem(float position[3], const char[] Model, int slotNumber) {

  g_ItemSlot[slotNumber] = CreateEntityByName("prop_dynamic_override");
  // Verificando que la entidad se haya creado con exito
  if (g_ItemSlot[slotNumber] != -1) {
    // Verificando el modelo
    if (!StrEqual(Model, "random", false)) {
      // Verificando que modelo exista
      if (!IsModelPrecached(Model)) {
        // Si no existe se carga el modelo
        PrecacheModel(Model);
      }
    }

    float life = g_ItemStay;
    // life = (life > 300.0) ? 300.0 : ((life < 10.0) ? 10.0 : life);
    
    g_ItemLimitLife[slotNumber] = life;
    
    DispatchKeyValue(g_ItemSlot[slotNumber], "rendercolor", g_Colors[GetRandomInt(0, MAX_NUM_COLORS-1)]);
    DispatchKeyValueFloat(g_ItemSlot[slotNumber], "fademindist", 10000.0);
    DispatchKeyValueFloat(g_ItemSlot[slotNumber], "fademaxdist", 20000.0);
    DispatchKeyValueFloat(g_ItemSlot[slotNumber], "fadescale", 0.0);
    
    DispatchKeyValue(g_ItemSlot[slotNumber], "model", Model);
    DispatchSpawn(g_ItemSlot[slotNumber]);
    
    // if (StrEqual(Model, JETF18_MDL, false) || StrEqual(Model, BARCO_VIEJO, false)) {
    if (StrEqual(Model, JETF18_MDL, false)) {
      SetEntPropFloat(g_ItemSlot[slotNumber], Prop_Send, "m_flModelScale", 0.05);
    } 

    DataPack pack = new DataPack();
    pack.WriteCell(g_ItemSlot[slotNumber]);
    pack.WriteCell(slotNumber);

    g_ItemLife[slotNumber] = CreateTimer(0.1, Timer_ItemLifeSpawn, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    
    SetEntProp(g_ItemSlot[slotNumber], Prop_Send, "m_CollisionGroup", 1);
    ToggleGlowEnable(g_ItemSlot[slotNumber]);
    TeleportEntity(g_ItemSlot[slotNumber], position, NULL_VECTOR, NULL_VECTOR);
    
    gifts_dropped++;
  }
}

public Action Timer_ItemLifeSpawn(Handle timer, DataPack pack) {
  // Reseteando paquete
  pack.Reset();
  // Definiendo valores del paquete
  int gift = pack.ReadCell(),
    index = pack.ReadCell();
  // Verificando que el regalo sea valido y siga con vida
  if (IsValidEntity(gift) && g_ItemLimitLife[index] > 0.1) {
    // Disminuyendo la vida al regalo
    g_ItemLimitLife[index] -= 0.2;
    // Rotando el regalo
    RotateAdvance(gift, 10.0, 1);
    // Obteniendo mi posicion
    float myPos[3];
    // Posicion del objeto
    float hePos[3];
    GetEntPropVector(gift, Prop_Send, "m_vecOrigin", myPos);
    
    // Recorriendo datos
    for (int i = 1; i <= MaxClients; i++) {
      // Verificando que sea un cliente valido
      if (IsValidClient(i)) {
        // Verificando si es un jugador falso para despues continuar
        if (IsFakeClient(i)) {
          continue;
        }
        // Obteniendo la posicion
        GetEntPropVector(i, Prop_Send, "m_vecOrigin", hePos);
        // Obteniendo el boton que ha presionado el jugador
        int button = GetClientButtons(i);
        // Verificando si la distancia es valida
        if (GetVectorDistance(myPos, hePos) < 50.0 && (button & IN_USE || button & IN_JUMP)) {
          gifts_dropped = (gifts_dropped > 0) ? (gifts_dropped - 1) : 0;
          // PrintToServer("Regalos en el server: %d", gifts_dropped);	
          // EmitSoundToClient(i, WEAPON_SOUND);
          // ToggleGlowEnable(gift);
          GiftToPlayer(i);
          CallTheAnimation(i, 10);
          g_KillTimer(index);
          Item_Destroy(gift);
          return Plugin_Stop;
        }
      }
    }
  } else {
    // Verificando que el slot sea valido
    if(g_ItemSlot[index] != -1 && g_ItemLimitLife[index] != -1) {
      // Verificando que sea una entidad valida
      if (IsValidEntity(gift)) {
        // Disminuyendo la cantidad de regalos
        gifts_dropped = (gifts_dropped > 0) ? (gifts_dropped - 1) : 0;
        // Matando el timer
        g_KillTimer(index);
        // ToggleGlowEnable(gift);
        Item_Destroy(gift);
      }
    }
    //PrintToServer("Regalos en el server: %d", gifts_dropped);
    return Plugin_Stop;
  }
  return Plugin_Continue;
}

void g_KillTimer(int index)
{
  if (g_ItemLife[index] != null)
  {
    KillTimer(g_ItemLife[index]);
    g_ItemLife[index] = null;
  }
  g_ItemSlot[index] = -1;
}

void GiftToPlayer(int client) {
  // Switch
  switch (GetRandomInt(0, 4)) {
    case 0: {
      int points = GetRandomInt(5, 15);
      ServerCommand("sm_givepoints #%d %d", GetClientUserId(client), points);
      CPrintToChatAll("\x04[\x05GIFT\x04] {blue}%N \x01got {blue}%d points \x01from a gift.", client, points);
      EmitSoundToAll(POINTS_SOUND);
    }
    case 1, 2: {
      int index = GetRandomInt(0, 1);
      CheatCMD(client, "give", weapons_list[index][WEAPON_CMD]);
      CPrintToChatAll("\x04[\x05GIFT\x04] {blue}%N \x01has acquired an {blue}%s\x01 from a gift.", client, weapons_list[index][WEAPON_NAME]);
      EmitSoundToAll(WEAPON_SOUND);
    }
    case 3, 4: {
      int actuality_health = GetClientHealth(client);
      int new_health = GetRandomInt(10, 99);
      CheatCMD(client, "give", "health");
      SetEntProp(client, Prop_Send, "m_iHealth", 100, 1);
      SetEntProp(client, Prop_Send, "m_isGoingToDie", 0);
      SetEntProp(client, Prop_Send, "m_currentReviveCount", 0);
      SetEntProp(client, Prop_Send, "m_iGlowType", 0);
      SetEntProp(client, Prop_Send, "m_glowColorOverride", 0);
      if (actuality_health < 80) {
        new_health = 100;
        CPrintToChatAll("\x04[\x05GIFT\x04] {blue}%N \x01has gained {blue}%d%% \x01of health from a gift.", client, new_health);
      } else {
        CPrintToChatAll("\x04[\x05GIFT\x04] {blue}%N \x01has gained {blue}%d%% \x01of plus health from a gift.", client, new_health);
        new_health += actuality_health;
      }
      SetEntityHealth(client, new_health);
      EmitSoundToAll(HEALTH_SOUND);
    }
  }
}

void CheatCMD(int client, char[] command, char[] arguments = "")
{
  if (client)
  {
    int flags = GetCommandFlags(command);
    SetCommandFlags(command, flags & ~FCVAR_CHEAT);
    FakeClientCommand(client, "%s %s", command, arguments);
    SetCommandFlags(command, flags);
  }
}

void SetColour(int ent, int r, int g, int b, int a)
{
  if (IsValidEntity(ent))
  {
    SetEntityRenderMode(ent, RENDER_TRANSCOLOR);
    SetEntityRenderColor(ent, r, g, b, a);
  }
}

void CallTheAnimation(int client, int number)
{
  if (IsValidClient(client))
  {
    float cc = 0.0;
    for (int i = 1; i <= number; i++)
    {
      CreateTimer(cc, Timer_LevelupAnimation, client, TIMER_FLAG_NO_MAPCHANGE);
      cc += 0.1;
    }
  }
}

public Action Timer_LevelupAnimation(Handle timer, any client)
{
  if (IsValidClient(client))
  {
    char mmmm[32];
    bool Continue1 = false;
    bool Continue2 = false;
    float lvlPos[3];
    float lvlAng[3];
    float lvlNew[3];
    float lvlBuf[3];
    float lvlVec[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", lvlPos);
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", lvlNew);
    
    lvlPos[2] += 30.0;
    lvlNew[0] += GetRandomFloat(-100.0, 100.0);
    lvlNew[1] += GetRandomFloat(-100.0, 100.0);
    lvlNew[2] += GetRandomFloat(100.0, 130.0);
    
    MakeVectorFromPoints(lvlNew, lvlPos, lvlBuf);
    GetVectorAngles(lvlBuf, lvlAng);
    
    int upLevelBody = CreateEntityByName("molotov_projectile");
    if (upLevelBody != -1)
    {
      DispatchKeyValue(upLevelBody, "model", MISSILE_DMY);
      DispatchKeyValueVector(upLevelBody, "origin", lvlNew);
      DispatchKeyValueVector(upLevelBody, "Angles", lvlAng);
      SetEntPropFloat(upLevelBody, Prop_Send, "m_flModelScale", 0.01);
      SetEntProp(upLevelBody, Prop_Send, "m_CollisionGroup", 1);
      SetEntPropEnt(upLevelBody, Prop_Data, "m_hOwnerEntity", -1);
      SetEntityGravity(upLevelBody, 0.01);
      DispatchSpawn(upLevelBody);
      
      Continue1 = true;
    }
    
    if (!Continue1)
    {
      return;
    }
    
    int upLevel = CreateEntityByName("prop_dynamic_override");
    if (upLevel != -1)
    {
      SetEntPropEnt(upLevel, Prop_Data, "m_hOwnerEntity", -1);
      Format(mmmm, sizeof(mmmm), "missile%d", upLevelBody);
      DispatchKeyValue(upLevelBody, "targetname", mmmm);
      DispatchKeyValue(upLevel, "model", JETF18_MDL);
      DispatchKeyValue(upLevel, "parentname", mmmm);
      DispatchKeyValueVector(upLevel, "origin", lvlNew);
      DispatchKeyValueVector(upLevel, "Angles", lvlAng);
      SetEntPropFloat(upLevel, Prop_Send, "m_flModelScale", 0.035);
      SetEntProp(upLevel, Prop_Send, "m_CollisionGroup", 1);
      SetVariantString(mmmm);
      AcceptEntityInput(upLevel, "SetParent", upLevel, upLevel, 0);
      DispatchSpawn(upLevel);
      SetColour(upLevel, 150, 150, 150, 180);
      Continue2 = true;
    }
    
    if (!Continue2)
    {
      return;
    }
    
    lvlAng[0] += GetRandomFloat(-5.0, 5.0);
    lvlAng[1] += GetRandomFloat(-5.0, 5.0);
    
    GetAngleVectors(lvlAng, lvlVec, NULL_VECTOR, NULL_VECTOR);
    NormalizeVector(lvlVec, lvlVec);
    ScaleVector(lvlVec, 500.0);
    TeleportEntity(upLevelBody, NULL_VECTOR, NULL_VECTOR, lvlVec);
    CreateTimer(0.19, DeletIndex, upLevel, TIMER_FLAG_NO_MAPCHANGE);
    CreateTimer(0.20, DeletIndex, upLevelBody, TIMER_FLAG_NO_MAPCHANGE);
  }
}

public Action DeletIndex(Handle timer, any index)
{
  Item_Destroy(index);
}

void Item_Destroy(int entity)
{
  if (entity != -1 && IsValidEntity(entity))
  {	
    float desPos[3];
    GetEntPropVector(entity, Prop_Send, "m_vecOrigin", desPos);
    
    desPos[2] += 5000.0;
    
    TeleportEntity(entity, desPos, NULL_VECTOR, NULL_VECTOR);
    AcceptEntityInput(entity, "Kill");
  }
}

void ToggleGlowEnable(int entity)
{
  if (IsValidEntity(entity)) {

    int g_m_iGlowType = 3;
    int m_glowColor = 0;

    int select = GetRandomInt(1, 5);
    int colorRGB[3] =  { 0, 0, 0 };
    switch (select) {
      case 1: {
        colorRGB[1] = 128;
        colorRGB[2] = 255;
      }
      case 2: {
        colorRGB[0] = 255;
        colorRGB[2] = 255;
      }
      case 3: {
        colorRGB[0] = 255;
        colorRGB[1] = 255;
      }
      case 4: colorRGB[0] = 255;
      case 5: colorRGB[2] = 255;
    }

    m_glowColor = colorRGB[0] + (colorRGB[1] * 256) + (colorRGB[2] * 65536);
  
    SetEntProp(entity, Prop_Send, "m_iGlowType", g_m_iGlowType);
    SetEntProp(entity, Prop_Send, "m_nGlowRange", 0);
    SetEntProp(entity, Prop_Send, "m_glowColorOverride", m_glowColor);
  }
}

void RotateAdvance(int index, float value, int axis)
{
  if (IsValidEntity(index))
  {
    float rotate_[3];
    GetEntPropVector(index, Prop_Data, "m_angRotation", rotate_);
    rotate_[axis] += value;
    TeleportEntity(index, NULL_VECTOR, rotate_, NULL_VECTOR);
  }
}

int GetEmptySlot()
{	
  for (int i = 0; i < SLOT_NUM; i++)
  {
    if (g_ItemSlot[i] == -1) 
    {
      return i;
    }
  }
  return -1;
}

bool IsValidInfected(int client)
{
  if ( client < 1 || 
     client > MaxClients || 
     !IsClientInGame(client) || 
     GetClientTeam(client) != TEAM_INFECTED
    )
  {
    return false;
  }
  return true;
}

bool IsValidClient(int client)
{
  if (client < 1 || client > MaxClients || !IsClientInGame(client) || GetClientTeam(client) != TEAM_SURVIVORS || !IsPlayerAlive(client))
  {
    return false;
  }
  return true;
}
