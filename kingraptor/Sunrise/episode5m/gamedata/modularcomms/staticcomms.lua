local comms = {
  -- singleplayer
  comm_mission_tutorial1 = {
    chassis = "armcom2",
    name = "Athenion",
    description = "Rebel Commander, Builds at 10 m/s",
    helptext = "An Imperial rebel leader.",
    modules = { "commweapon_beamlaser", "module_autorepair", "module_autorepair", "module_ablative_armor"},
    miscDefs = {
      customparams = {
        helptext_pl = "Dowodca grupy rebeliantow walczacych przeciwko Imperium.",
      },
    },
  },  

  comm_campaign_ada = {
    chassis = "cremcom3",
    name = "Ada's Commander",
    description = "Relic Commander, Builds at 10 m/s",
    helptext = "A special piloted commander unit from before the Fall, functioning well despite its age. Piloted by Captain Ada Caedmon, formerly of the 13th Imperial Auxiliary Cohort.",
    modules = { "commweapon_lparticlebeam", "commweapon_sunburst", "module_ablative_armor", "module_autorepair", "module_high_power_servos", "module_energy_cell", "conversion_hparticlebeam"},
    miscDefs = {
      customparams = {
        helptext_pl = "Specjalna zalogowa jednostka dowodzenia sprzed Upadku, sprawna mimo wieku. Pilotem jest Kapitan Ada Caedmon z dawnej 13 Imperialnej Kohorty Wsparcia.",
      },
    },
  },
  
  comm_campaign_promethean = {
    chassis = "commrecon4",
    name = "The Promethean",
    helptext = "Founder of the Free Machines and creator of the Firebrand virus, a calm, philosophical AI fighting for the freedom of robotkind. A burning spirit.",
    modules = { "commweapon_heatray", "commweapon_napalmgrenade", "module_ablative_armor", "module_ablative_armor", "weaponmod_plasma_containment", "module_autorepair", "module_high_power_servos" },
    decorations = {"skin_recon_red"},
    miscDefs = {
      customparams = {
        helptext_pl = "Zalozyciel Wolnych Maszyn i tworca wirusa Zarzewie; spokojna, filozoficzna sztuczna inteligencja walczaca za wolnosc robotow. Plonie zadza walki.",
      },
    },
  },
  
  comm_campaign_freemachine = {
    chassis = "corcom2",
    name = "Libertas Machina",
    helptext = "The Promethean's top lieutenant, a revolutionary commited to the cause of machine liberation. Loaded for bear and well armored; not to be taken lightly.",
    modules = { "commweapon_riotcannon", "module_ablative_armor", "module_ablative_armor", "module_adv_targeting", "module_autorepair" },
    miscDefs = {
      customparams = {
        helptext_pl = "Najbardziej zaufany porucznik Prometheana, rewolucjonista oddany sprawie wyzwolenia maszyn. Uzbrojony po zeby i dobrze opancerzony - nie mozna go lekcewazyc.",
      },
    },
  },
  
  comm_campaign_odin = {
    chassis = "commrecon2",
    name = "Odin",
    helptext = "The leader of the Valhallans, a warrior built and bred who lives for the glory of battle. An extremely ruthless foe.",
    modules = { "commweapon_lparticlebeam", "module_ablative_armor", "module_ablative_armor", "module_high_power_servos", "module_autorepair", "module_companion_drone"},
    miscDefs = {
      customparams = {
        helptext_pl = "Lider Valhallan, wojownik z krwi i kosci, ktory zyje dla chwaly bitwy. Nie ma skrupulow.",
      },
    },
  },

  comm_campaign_biovizier = {
    chassis = "commsupport2",
    name = "The Biovizier",
    helptext = "AI keeper of the Dynasty's genetic vaults and master geneticist. Cold and calculating.",
    modules = { "commweapon_gaussrifle", "module_ablative_armor", "weaponmod_railaccel", "module_autorepair", "module_autorepair" },
    decorations = { "skin_support_green" },
    miscDefs = {
      customparams = {
        helptext_pl = "Sztuczna inteligencja sprawujaca piecze nad kryptami przechowujacymi dane genetyczne Dynastii. Zimna i przebiegla.",
      },
    },
  },
  
  comm_campaign_isonade = {
    chassis = "benzcom2",	-- TODO get a properly organic model
    name = "Lord Isonade",
    helptext = "One of the ubermenschen nobles of the Dynasty, an ambitious warlord who seeks to establish himself as master of the galaxy. A horribly mutated beast.",
    modules = { "commweapon_sonicgun", "module_heavy_armor", "module_dmg_booster", "module_autorepair", "module_autorepair" },
    decorations = { "skin_bombard_steel" },
    miscDefs = {
      customparams = {
        helptext_pl = "Jeden z lordow-nadludzi Dynastii - ambitny wojownik, ktory ma zamiar przejac wladze nad galaktyka. Bestia zmutowana nie do poznania.",
      },
    },
  },

  comm_campaign_legion = {
    chassis = "corcom3",
    name = "Legate Fidus",
    helptext = "Commander of the Imperial Vanguard Legion, enforcers of the Emperor's will.  A loyal, steadfast soldier.",
    modules = { "commweapon_shotgun", "commweapon_clusterbomb", "module_heavy_armor", "weaponmod_autoflechette", "module_adv_targeting", "module_autorepair"},
    --decorations = { "skin_battle_tiger" },
    miscDefs = {
      customparams = {
        helptext_pl = "Dowodca Imperialnego Legionu Strazniczego, ktory wykonuje wole Imperatora. Wierny i niezlomny zolnierz.",
      },
    },
  },  
    
  comm_campaign_praetorian = {
    chassis = "benzcom3",
    name = "Scipio Astra",
    helptext = "Prefect of the elite Praetorian Guard, the Empire's paladins. A fanatic adherent of the Emperor's cult, purging heretics with massive firepower.",
    modules = { "commweapon_assaultcannon", "commweapon_napalmgrenade", "module_heavy_armor", "weaponmod_high_caliber_barrel", "module_adv_targeting", "module_autorepair", "module_high_power_servos"},
    miscDefs = {
      customparams = {
        helptext_pl = "Prefekt Strazy Pretorianskiej, paladynow Imperium. Fanatyczna wyznawczyni kultu Imperatora, ktora oczyszcza heretykow ogromna sila ognia.",
      },
    },
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
    modules = { "commweapon_lightninggun", "module_high_power_servos",},
    cost = 250,
  },
  
  -- Hax
  comm_guardian = { 
    chassis = "armcom2", 
    name = "Star Guardian",
    modules = { "commweapon_beamlaser", "module_ablative_armor", "module_high_power_servos", "module_high_power_servos", "weaponmod_high_frequency_beam", "module_energy_cell"},
  },
  comm_riot = {
    chassis = "corcom2",
    name = "Crowd Controller",
    modules = { "commweapon_riotcannon", "commweapon_heatray"},
  },
  comm_recon = {
    chassis = "commrecon2",
    name = "Ghost Recon",
    modules = { "commweapon_heatray", "module_ablative_armor", "module_high_power_servos", "module_high_power_servos", "module_jammer" , "module_autorepair"},
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
  },
  comm_hunter = {
    chassis = "commsupport2",
    name = "Bear Hunter",
    modules = { "commweapon_shotgun", "module_dmg_booster", "module_adv_targeting", "module_high_power_servos", "module_fieldradar"},
  },
}
--[[
for name,stats in pairs(comms) do
	table.insert(stats.modules, "module_econ")
end
--]]
return comms
