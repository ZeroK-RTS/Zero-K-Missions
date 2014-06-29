local comms = {
  comm_mission_tutorial1 = {
    chassis = "armcom3",
	name = "Tutorial Commander",
	modules = { "commweapon_beamlaser", "module_autorepair", "module_autorepair"},
  },  

  -- Not Hax
  comm_riot_cai = {
    chassis = "corcom1",
	name = "Crowd Controller",
	modules = { "commweapon_riotcannon",  "module_adv_targeting",},
	cost = 250,
  },
   comm_econ_cai = {
    chassis = "commsupport1",
	name = "Base Builder",
	modules = { "commweapon_beamlaser",  "module_econ",},
	cost = 275,
  },
  comm_marksman_cai = {
    chassis = "commsupport1",
	name = "The Marksman",
    modules = { "commweapon_gaussrifle", "module_adv_targeting",},
	cost = 225,
  },
  comm_stun_cai = {
    chassis = "armcom1",
	name = "Exotic Assault",
    modules = { "commweapon_lightninggun", "module_autorepair",},
	cost = 375,
  },
  
  -- Hax
  comm_guardian = { 
	chassis = "armcom2", 
	name = "Akegata",
	description = "Explorer Commander, Builds at 10 m/s",
	helptext = "Akegata's commander platform was built for independent exploration and survival. It's a well-balanced design with good mobility and combat versatility.",
	modules = { "commweapon_beamlaser", "module_ablative_armor", "module_high_power_servos", "module_high_power_servos", "module_energy_cell"},
	cost = 800,
  },
  comm_riot = {
    chassis = "corcom2",
	name = "Crowd Controller",
    modules = { "commweapon_riotcannon", "commweapon_heatray"},
  },
  comm_recon = {
    chassis = "commrecon3",
    name = "Persegus",
    description = "Hunter/Seeker Commander, Builds at 10 m/s",
    helptext = "Persegus designed his loadout for two things - speed and accuracy. His Recon platform lets him follow his quarry to the very ends of the galaxy.",
    modules = { "commweapon_lparticlebeam", "commweapon_disruptorbomb", "module_ablative_armor", "module_high_power_servos",
      "module_high_power_servos", "module_jammer", "module_personal_cloak", "module_autorepair"},
    decorations = {"skin_recon_dark"}
  },
  comm_rocketeer = {
    chassis = "armcom2",
	name = "Rocket Surgeon",
    modules = { "commweapon_rocketlauncher", "module_dmg_booster", "module_adv_targeting", "module_ablative_armor" },
  },
  comm_marksman = {
    chassis = "commsupport2",
	name = "The Marksman",
    modules = { "commweapon_gaussrifle", "module_dmg_booster", "module_adv_targeting", "module_ablative_armor" , "module_high_power_servos"},
    decorations = {"skin_support_dark"}
  },  
  comm_flamer = {
    chassis = "corcom2",
	name = "The Fury",
    modules = { "commweapon_flamethrower", "module_dmg_booster", "module_ablative_armor", "module_ablative_armor", "module_high_power_servos"},
  },
  comm_marine = {
    chassis = "commrecon2",
	name = "Space Marine",
    modules = { "commweapon_heavymachinegun", "module_heavy_armor", "module_high_power_servos", "module_dmg_booster", "module_adv_targeting"},
    decorations = {"skin_recon_red"}
  },
  comm_hunter = {
    chassis = "commsupport2",
	name = "Bear Hunter",
    modules = { "commweapon_shotgun", "module_dmg_booster", "module_adv_targeting", "module_high_power_servos", "module_fieldradar"},
    decorations = {"skin_support_green"}
  },
}
--[[
for name,stats in pairs(comms) do
	table.insert(stats.modules, "module_econ")
end
--]]
return comms