//finding entity by name, and then by class
function GetEntity(name, old=null){
  local entity = Entities.FindByName(old,name);
  if(!entity)entity = Entities.FindByClassname(old,name);
  return entity;
}
function OnPostSpawn(){
  local auto = GetEntity("logic_auto")
  if(!auto){
    modlog("No logic_auto loaded yet. Speedrun Mode initialisation failed.")
    return false
  }
  //necessary to use OnMapSpawn event, since OnPostSpawn can be executed before some entities are even spawned
  EntFireByHandle(auto, "AddOutput", "OnMapSpawn "+self.GetName()+":RunScriptCode:SPtoCoop():0:1", 0, null, null)
}

function SPtoCoop()
{
	switch(GetMapName())
	{
		case "sp_a1_intro2":
			SendToConsole("changelevel mp_coop_doors")
		break;
	
		case "sp_a1_intro3":
			SendToConsole("changelevel mp_coop_fling_3")
		break;	

		case "sp_a1_intro4":
			SendToConsole("changelevel mp_coop_wall_intro")
		break;	
	
		case "sp_a1_intro5":
			SendToConsole("changelevel mp_coop_tbeam_redirect")
		break;	
	
		case "sp_a1_intro6":
			SendToConsole("changelevel mp_coop_paint_come_along")
		break;
	}
}
SPtoCoop()