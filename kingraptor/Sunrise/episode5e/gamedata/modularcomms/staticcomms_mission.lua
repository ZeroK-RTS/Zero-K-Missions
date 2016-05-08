local comms = {
  -- singleplayer
  comm_mission_tutorial1 = {
    chassis = "commsupport2",
    name = "Athenion",
    description = "Rebel Commander, Builds at 12 m/s",
    modules = { "commweapon_lparticlebeam", "module_autorepair", "module_autorepair", "module_ablative_armor"},
    miscDefs = {
      customparams = {
        statsname = "comm_campaign_athenion"
      },
    },
  },  

  comm_campaign_ada = {
    chassis = "cremcom3",
    modules = { "commweapon_missilelauncher", "commweapon_slamrocket", "module_ablative_armor", "module_autorepair", "module_high_power_servos"},
  },
  
  comm_campaign_praetorian = {
    chassis = "benzcom3",
    modules = { "commweapon_assaultcannon", "commweapon_napalmgrenade", "module_heavy_armor", "weaponmod_high_caliber_barrel", "module_adv_targeting", "module_autorepair", "module_high_power_servos"},
  },
return comms
