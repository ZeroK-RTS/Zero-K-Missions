local comms = {
  comm_campaign_ada = {
    chassis = "cremcom4",
    modules = { "commweapon_lparticlebeam", "commweapon_sunburst", "module_dmg_booster", "module_ablative_armor", "module_ablative_armor", "module_autorepair", "module_high_power_servos"},
  },
  
  comm_campaign_praetorian = {
    chassis = "benzcom4",
    modules = { "commweapon_riotcannon", "commweapon_rocketlauncher", "module_heavy_armor", "weaponmod_standoff_rocket", "module_adv_targeting", "module_autorepair", "module_autorepair", "module_high_power_servos", "module_high_power_servos" },
    cost = 2400,
  },
  -- Hun
  comm_guardian = { 
    chassis = "armcom3", 
    modules = { "commweapon_beamlaser", "commweapon_concussion", "module_ablative_armor", "module_high_power_servos", "weaponmod_high_frequency_beam", "module_high_power_servos"},
    miscDefs = {
      customparams = {
        statsname = "comm_campaign_hun"
      },
    },
    cost = 1800,
  },
  -- Ostrogoth
  comm_riot = {
    chassis = "corcom3",
    modules = { "commweapon_riotcannon", "commweapon_heatray", "module_autorepair", "module_high_power_servos", "module_personal_shield"},
    miscDefs = {
      customparams = {
        statsname = "comm_campaign_ostrogoth"
      },
    },
    cost = 1800,
  },
  -- Suevi
  comm_marine = {
    chassis = "commrecon3",
    modules = { "commweapon_heavymachinegun", "commweapon_disruptorbomb", "weaponmod_disruptor_ammo", "module_ablative_armor", "module_high_power_servos", "module_autorepair", "module_adv_targeting"},
    miscDefs = {
      customparams = {
        statsname = "comm_campaign_suevi"
      },
    },
    cost = 1800,
  },
  -- Bulgar
  comm_hunter = {
    chassis = "commsupport3",
    modules = { "commweapon_shotgun", "commweapon_multistunner", "module_dmg_booster", "module_adv_targeting", "module_high_power_servos", "module_autorepair", "module_ablative_armor", "module_fieldradar"},
    miscDefs = {
      customparams = {
        statsname = "comm_campaign_bulgar"
      },
    },
    cost = 1800,
  },
  -- Lombard
  comm_rocketeer = {
    chassis = "benzcom3",
    modules = { "commweapon_assaultcannon", "commweapon_assaultcannon", "conversion_partillery", "module_dmg_booster", "module_adv_targeting", "module_autorepair", "module_ablative_armor"},
    miscDefs = {
      customparams = {
       statsname = "comm_campaign_lombard"
      },
    },
    cost = 1800,
  },
}

return comms