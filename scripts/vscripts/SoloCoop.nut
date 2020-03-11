//Interesting Krzy Functions
//GetEntity
//OnPostSpawn
//AddOutput

//Improvement ideas
	//Fix Industrial Fan and Bridge Testing Spawn Fixes
	//There's probably bugs in the ending cutscene
	//Fix endings so entities don't become invisible by disabling point_viewcontrol *Might be fixed
	//Something is probably wrong with course 5
	//Combine Course end levels into one case 

timer <- null
endtrigger <- null

function GetEntity(name, old=null){
  local entity = Entities.FindByName(old,name);
  if(!entity)entity = Entities.FindByClassname(old,name);
  return entity;
}


function FixSpawn(prev=null){
while((prev = Entities.FindByClassname(prev, "info_coop_spawn")) != null)
{
local name = prev.GetName()
	if (prev.GetTeam() == 2)
	{
		if (name.slice(0, 12) == "InstanceAuto")
		{
			//Handles Player Starting Position
			local player = GetPlayer()
			local coords = prev.GetCenter()
			local angles = prev.GetAngles()
			GetPlayer().SetAbsOrigin(Vector(coords.x, coords.y, coords.z))
			GetPlayer().SetAngles(0, angles.y,0)

			//Handles Player's Tube Opening and closing
			local pos1 = name.find("Auto") + 4
			local pos2 = name.find("-red_dropper-initial_spawn")
			local RelayName = "InstanceAuto" + name.slice(pos1, pos2) + "-red_dropper-relay_tube_open"
			local RelayName2 = "InstanceAuto" + name.slice(pos1, pos2) + "-red_dropper-relay_tube_close"
			EntFire(RelayName "trigger")
			EntFire(RelayName2 "trigger", "", 1.0)		
		}
	}
}
}

function FixMidRooms(prev=null){
while ((prev = Entities.FindByClassname(prev, "trigger_playerteam")) != null)
{
	if (prev.GetName().find("trigger_team_airlock", 0) != null)
	{
	local start = "OnStartTouch @command:Command:ent_fire " 
	local UniqueName = prev.GetName().slice(0, prev.GetName().find("trigger_team_airlock"))
	local ComboMeal = start+UniqueName+"relay_blue_in trigger"
	local ComboMeal2 = start+UniqueName+"relay_orange_in trigger"

	EntFireByHandle(prev, "AddOutput" ComboMeal, 1, null, null)
	EntFireByHandle(prev, "AddOutput" ComboMeal2, 1, null, null)
	}
}
}

function FixEndTrigger(prev = null){
	if (GetMapName() != "mp_coop_teambts" || GetMapName() != "mp_coop_fan" || GetMapName() != "mp_coop_wall_5" || GetMapName() != mp_coop_tbeam_end || GetMapName() != mp_coop_paint_longjump_intro) 
	{
		local EndDoorTrigger = GetEntity("team_trigger_door")	//End Door
		EntFireByHandle(EndDoorTrigger, "AddOutput" "OnStartTouch @command:Command:ent_fire team_door-relay_blue_in trigger", 1, null, null)
		EntFireByHandle(EndDoorTrigger, "AddOutput" "OnStartTouch @command:Command:ent_fire team_door-relay_orange_in trigger", 1, null, null)
	}

}
function FixTransition(prev = null)
{
	switch(GetMapName())
	{
	case "mp_coop_teambts":
		local fade = GetEntity("fade_exit_level")
		if (fade != null)
		{
		EntFireByHandle(fade, "AddOutput" "OnBeginFade transition_script:RunScriptCode:TransitionToDayTwo():0.5:1", 1, null, null)
		}
	break;

	case "mp_coop_fan":
		local fade = GetEntity("fade_exit_level")
		if (fade != null)
		{
		EntFireByHandle(fade, "AddOutput" "OnBeginFade transition_script:RunScriptCode:TransitionToDayThree():0.5:1", 1, null, null)
		}
	break;

	case "mp_coop_wall_5":
		local fade = GetEntity("fade_exit_level")
		if (fade != null)
		{
		EntFireByHandle(fade, "AddOutput" "OnBeginFade transition_script:RunScriptCode:TransitionToDayFour():0.5:1", 1, null, null)
		}
	break;

	case "mp_coop_tbeam_end":
		local fade = GetEntity("fade_exit_level")
		if (fade != null)
		{
		EntFireByHandle(fade, "AddOutput" "OnBeginFade transition_script:RunScriptCode:TransitionToDayFive():0.5:1", 1, null, null)
		}
	break;

	case "mp_coop_paint_longjump_intro":
		local fade = GetEntity("fade_exit_level")
		if (fade != null)
		{
		
		}
	break;

	default:
		while ((prev = Entities.FindByClassname(prev, "trigger_playerteam")) != null)
		{
			if (prev.GetName().find("ElevatorRoomEntranceTrigger", 0) != null)
			{
				prev.__KeyValueFromString("Target_Team", "Both")	
				local UniqueName = prev.GetName().slice(0, prev.GetName().find("ElevatorRoomEntranceTrigger"))
				EntFireByHandle(prev, "AddOutput" "OnStartTouch "+UniqueName+"transition_script:RunScriptCode:TransitionFromMap():5.0:1", 1, null, null)
				endtrigger = prev
				
				CreateEndingCutScene(endtrigger)
			}
		}

	}
}

function CreateEndingCutScene(endtrigger)
{
	if (GetMapName() != "mp_coop_laser_crusher")	//Fuck you Laser Crusher
{
	endtrigger.__KeyValueFromInt("trigger_once", 1)
	local viewcontrol = Entities.CreateByClassname("point_viewcontrol")
	viewcontrol.__KeyValueFromString("target", "blue-station")		//For some reason this is required for wait to work
	viewcontrol.__KeyValueFromInt("wait", 6)
	viewcontrol.__KeyValueFromInt("flags", 4)		//This doesn't work for no reason
	local blue = GetEntity("blue-teleport_dis")

	if (blue == null)	//Temporary Way to detect course 5
	{
	blue = GetEntity("@exit_door")
	local newangle = blue.GetAngles().x + " " + (blue.GetAngles().y + 180) + " " + blue.GetAngles().z

	viewcontrol.__KeyValueFromString("target", "blue_brush_clip")		//For some reason this is required for wait to work
	viewcontrol.__KeyValueFromInt("wait", 2)
	viewcontrol.__KeyValueFromString("angles", newangle)
	viewcontrol.SetOrigin(Vector(blue.GetOrigin().x, blue.GetOrigin().y, blue.GetOrigin().z + 100))			
	
	}
	else
	{
	local newangle = blue.GetAngles().x + " " + (blue.GetAngles().y + 90) + " " + blue.GetAngles().z
	viewcontrol.__KeyValueFromString("angles", newangle)
	viewcontrol.SetOrigin(Vector(endtrigger.GetOrigin().x, endtrigger.GetOrigin().y, endtrigger.GetOrigin().z))

	}
	viewcontrol.__KeyValueFromString("targetname", "testViewControl")
	EntFireByHandle(endtrigger, "AddOutput" "OnStartTouch testViewControl:Enable", 0.0 ,null, null)
	EntFireByHandle(endtrigger, "AddOutput" "OnStartTouch @command:Command:ent_fire rl_start_exit trigger", 0.0 ,null, null)
}
}

function OnTimer() 
{
	switch(GetMapName())
	{
	case "mp_coop_fling_1":
		local player = GetPlayer()
		if (player.GetVelocity().Length() >= 950)
			{
			//EntFire("@Command", "Command", "ent_fire prop_portal fizzle" , 0.0, null)	//too slow apparently
			//EntFire("@Command", "Command", "portal_place 0 1 160 -96 -174 -90 135 0" , 0.0, null)
			EntFire("@Command", "Command", "portal_place 0 0 606 65 -158 -90 90 0" , 0.0, null)	//Fix this later
			//EntFire("@Command", "Command", "portal_place 0 1 350 65 -158 -90 90 0" , 1.0, null)
			
			}
	break;

	default:

	
	break;
	}
}

//Makes a logic_auto entity (before OnMapSpawn) then puts an entfire in that entity that will then play the SoloCoopLoad
//Function OnMapSpawn
function OnPostSpawn(){
  local auto = GetEntity("logic_auto")
  if(!auto){
    return false
  }
  //necessary to use OnMapSpawn event, since OnPostSpawn can be executed before some entities are even spawned
  EntFireByHandle(auto, "AddOutput", "OnMapSpawn "+self.GetName()+":RunScriptCode:SoloCoopLoad():0:1", 0, null, null)

	if( timer == null )
	{
		timer = Entities.CreateByClassname( "logic_timer" )

		timer.__KeyValueFromFloat( "RefireTime", 0.1 )

		timer.ValidateScriptScope()
		local scope = timer.GetScriptScope()
		
		scope.OnTimer <- OnTimer

		timer.ConnectOutput( "OnTimer", "OnTimer" )

		// Merk the timer
		EntFireByHandle( timer, "Disable", "", 0, null, null )
		
	}

}

function AddOutput(entityname,event,func){
  local entity = GetEntity(entityname)
  if(entity){
    EntFire(entity.GetName(),"RunScriptFile","transitions/sp_transition_list.nut",0.0)
    entity.ConnectOutput(event,func)
  }else{
    //modlog("Failed to add output \""+event+":"+func+"\" for entity \""+entityname+"\"")
  }
}

OnPostSpawn();

function SoloCoopLoad(){
FixSpawn();
FixMidRooms();
FixTransition();
FixEndTrigger();
EntFire("@command", "Command", "map_wants_save_disable 0", 0)
EntFire("@command", "Command", "give_portalgun")		
EntFire("@command", "Command", "upgrade_portalgun")
EntFireByHandle( timer, "Disable", "", 0, null, null )
switch(GetMapName())
	{
	case "mp_coop_doors":
		
	local Button1 = Entities.FindByClassnameNearest("prop_floor_button", Vector(-9728, -865, 73), 200)	//Free Button Glitch
	EntFireByHandle(Button1, "AddOutput" "OnUnPressed @command:Command:ent_fire exit_door2_open trigger", 1, null, null)

	local Button2 = Entities.FindByClassnameNearest("prop_floor_button", Vector(-10109, -956, 73), 200)	//Free Button Glitch
	EntFireByHandle(Button2, "AddOutput" "OnUnPressed @command:Command:ent_fire exit_door1_open trigger", 1, null, null)

	break;

	case "mp_coop_race_2":
	
	local firstbutton = Entities.FindByClassnameNearest("prop_button", Vector(-1792, 64, -32), 200)
	firstbutton.__KeyValueFromFloat("Delay", 8.0)
	
	break;

	case "mp_coop_laser_2":

		local mathboi = GetEntity("lgrid_laser_counter")
		EntFireByHandle(mathboi, "AddOutput" "OnHitMax @command:Command:ent_fire airlock_1-proxy_airlock onproxyrelay1", 0.1, null, null)
		EntFireByHandle(mathboi, "AddOutput" "OnHitMax @command:Command:ent_fire relay_socket_exit_toggle settextureindex 1", 0.1, null, null)

		local button = GetEntity("button_arms-button")
		EntFireByHandle(button, "AddOutput" "OnUnpressed @command:Command:ent_fire button_arms-proxy onproxyrelay3", 0.0, null, null)

	break;

	case "mp_coop_rat_maze":
		
		EntFire("RatCrusher", "kill", 1, 0, null)	//Temporary Fix Murder Maze
		//EntFireByHandle(Cube, "RunScriptCode", "self.SetOrigin(Vector(-730,544,-831))", 1.0, null, null)//Leaving this around just in case (Attorney at law)

	break;

	case "mp_coop_laser_crusher":

	break;

	case "mp_coop_teambts":
	
	break;

	case "mp_coop_fling_3":
local Button1 = Entities.FindByClassnameNearest("prop_floor_button", Vector(-128, -128, 587), 200)
local Button2 = Entities.FindByClassnameNearest("prop_floor_button", Vector(416, -735, 280), 200)
EntFireByHandle(Button1, "AddOutput" "OnUnPressed @command:Command:ent_fire coop_man_buttons setstatebtrue", 1, null, null)	//Top Button
EntFireByHandle(Button1, "AddOutput" "OnUnPressed @command:Command:ent_fire button_2_texture_toggle settextureindex 1", 1, null, null)
EntFireByHandle(Button2, "AddOutput" "OnUnPressed @command:Command:ent_fire coop_man_buttons setstateatrue", 1, null, null)	//Bottom Button
EntFireByHandle(Button2, "AddOutput" "OnUnPressed @command:Command:ent_fire button_1_texture_toggle settextureindex 1", 1, null, null)

	break;

	case "mp_coop_infinifling_train":

		local Fizzler = Entities.FindByClassnameNearest("trigger_portal_cleanser", Vector(1344, -1824, 468.5), 200)	//Fizzler
		EntFireByHandle(Fizzler, "kill", "0", 0, null, null)

	break;

	case "mp_coop_come_along":

		local Button1 = Entities.FindByClassnameNearest("prop_floor_button", Vector(520, 1210, -529), 200)	//Free Button Glitch
		EntFireByHandle(Button1, "AddOutput" "OnUnPressed @command:Command:ent_fire button1-proxy onproxyrelay1", 1, null, null)

	break;

	case "mp_coop_fling_1":
		EntFireByHandle( timer, "Enable", "", 0, null, null )
	
		local Fizzler = Entities.FindByClassnameNearest("trigger_portal_cleanser", Vector(167, -94, -145), 200)	//Fizzler removal
		EntFireByHandle(Fizzler, "kill", "0", 0, null, null)

	break;

	case "mp_coop_catapult_1":
		//Fix dialogue here will come with better end level transitions

	break;

	case "mp_coop_multifling_1":

		local Button1 = Entities.FindByClassnameNearest("prop_floor_cube_button", Vector(1, 190, -214), 200)	//Free Button Glitch
		EntFireByHandle(Button1, "AddOutput" "OnUnPressed @command:Command:ent_fire button2-proxy onproxyrelay2", 1, null, null)

		local Fizzler = Entities.FindByClassnameNearest("trigger_portal_cleanser", Vector(-1023.5, 384, 128), 200)
		EntFireByHandle(Fizzler, "kill", "0", 0, null, null)	//Temporary Solution
		
	break;

	case "mp_coop_fling_crushers":

	break;

	case "mp_coop_fan":

	local player = GetPlayer()
	EntFireByHandle(player, "SetLocalOrigin", "1728 96 8800", 0.0, null, null)
	EntFire("blue_dropper-red_dropper-relay_tube_open" "trigger")
	EntFire("blue_dropper-red_dropper-relay_tube_close" "trigger", "", 1.0)

	local pushyboi = Entities.FindByClassnameNearest("trigger_push",Vector(1824.44, 896, -226.03), 200)
	pushyboi.__KeyValueFromString("pushdir", "-1 0 -1")	//Gotta figure out KeyValue Stuff

	local catcher = GetEntity("catcher")
	EntFireByHandle(catcher, "AddOutput" "OnUnpowered @command:Command:ent_fire brush_fan setspeed 0", 1, null, null)

	break;

	case "mp_coop_wall_intro":

	EntFire("@command", "Command", "sv_alternateticks 1")	

	break;

	case "mp_coop_wall_2":

	break;

	case "mp_coop_catapult_wall_intro":

	break;
	
	case "mp_coop_wall_block":

	break;

	case "mp_coop_catapult_2":
	
	break;

	case "mp_coop_turret_walls":

	break;

	case "mp_coop_turret_ball":

	break;

	case "mp_coop_wall_5":

	local player = GetPlayer()	//Spawn Location 
	EntFireByHandle(player, "SetLocalOrigin", "-3648 -1224 9689", 0.0, null, null)
	EntFire("red_dropper-relay_tube_open" "trigger")
	EntFire("red_dropper-relay_tube_close" "trigger", "", 1.0)
	
	local fade = GetEntity("fade_exit_level")	//Transition
	EntFireByHandle(fade, "AddOutput" "OnBeginFade @command:Command:changelevel mp_coop_tbeam_redirect", 1, null, null)

	break;

	case "mp_coop_tbeam_redirect":
	
	
	break;

	case "mp_coop_tbeam_drill":
	

	break;

	case "mp_coop_tbeam_catch_grind_1":

	break;

	case "mp_coop_tbeam_laser_1":
	

	break;

	case "mp_coop_tbeam_polarity":

	
	break;

	case "mp_coop_tbeam_polarity2":
	

	break;

	case "mp_coop_tbeam_polarity3":

	local Button1 = Entities.FindByClassnameNearest("prop_floor_button", Vector(772, -247, -113), 200)	//Free Button Glitch
	EntFireByHandle(Button1, "AddOutput" "OnUnPressed @command:Command:ent_fire button_2-proxy onproxyrelay1", 1, null, null)

	break;

	case "mp_coop_tbeam_maze":


	break;

	case "mp_coop_tbeam_end":

	local player = GetPlayer()	//Spawn Location 
	EntFireByHandle(player, "SetLocalOrigin", "-96 -2048 8553 ", 0.0, null, null)
	EntFire("instanceauto68-red_dropper-relay_tube_open" "trigger")	
	EntFire("instanceauto68-red_dropper-relay_tube_close" "trigger", "", 1.0)
	

	break;

	case "mp_coop_paint_come_along":

	break;

	case "mp_coop_paint_redirect":

	break;

	case "mp_coop_paint_bridge":

	break;

	case "mp_coop_paint_walljumps":		

	break;

	case "mp_coop_paint_speed_fling":

	break;

	case "mp_coop_paint_red_racer":	

	break;

	case "mp_coop_paint_speed_catch":

	local autospawn = Entities.FindByName(null, "sphere_dropper-cube_dropper_autorespawn")
	autospawn.__KeyValueFromInt("StartDisabled", 0)


	break;

	case "mp_coop_paint_longjump_intro":

	local RealEndTrigger = GetEntity("vault-team_trigger_door")
	EntFireByHandle(RealEndTrigger, "AddOutput" "OnStartTouch @command:Command:ent_fire vault-coopman_airlock_success setstateatrue", 1, null, null)
	EntFireByHandle(RealEndTrigger, "AddOutput" "OnStartTouch @command:Command:ent_fire vault-coopman_airlock_success setstatebtrue", 1, null, null)

	EntFireByHandle(RealEndTrigger, "AddOutput" "OnStartTouch @command:Command:ent_fire vault-coopman_taunt setstateatrue", 1, 0.0, null)
	EntFireByHandle(RealEndTrigger, "AddOutput" "OnStartTouch @command:Command:ent_fire vault-coopman_taunt setstatebtrue", 1, 0.0, null)

	local fade = GetEntity("vault-fade_to_movie")	//Transition
	//EntFireByHandle(fade, "AddOutput" "OnBeginFade @command:Command:changelevel mp_coop_separation_1", 1, null, null)
	EntFireByHandle(fade, "AddOutput" "OnBeginFade @command:Command:disconnect", 1, null, null)

	break;
	}
}