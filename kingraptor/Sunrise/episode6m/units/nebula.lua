unitDef = {
  unitname               = [[nebula]],
  name                   = [[Daneel Olivaw]],
  description            = [[Advanced Atmospheric Mothership]],
  acceleration           = 0.04,
  activateWhenBuilt      = true,
  airStrafe              = 0,
  amphibious             = true,
  bankingAllowed         = false,
  brakeRate              = 0.6,
  buildCostEnergy        = 10000,
  buildCostMetal         = 10000,
  builder                = false,
  buildPic               = [[nebula.png]],
  buildTime              = 10000,
  canAttack              = true,
  canFly                 = true,
  canGuard               = true,
  canMove                = true,
  canPatrol              = true,
  canstop                = [[1]],
  canSubmerge            = false,
  category               = [[GUNSHIP]],
  collide                = true,
  collisionVolumeOffsets = [[0 00 0]],
  collisionVolumeScales  = [[40 50 220]],
  collisionVolumeTest    = 1,
  collisionVolumeType    = [[box]],

  corpse                 = [[DEAD]],
  cruiseAlt              = 300,

  customParams           = {
    cantuseairpads = 1,
   -- description_bp = [[Fortaleza voadora]],
   -- description_fr = [[Forteresse Volante]],
    description_de = [[Lufttraeger]], -- "aerial carrier"
    description_pl = [[Statek-matka]],
    helptext       = [[An advanced version of the Nebula-class aerial carrier. As maneuverable as a brick and only modestly armed itself, the Daneel Olivaw is still a fearsome force due to its ability to survive long-range attacks due to its shield, as well as shred lesser foes with its fighter-drone complement.]],
   -- helptext_bp    = [[Aeronave flutuante armada com lasers para ataque terrestre. Muito cara e muito poderosa.]],
   -- helptext_fr    = [[La Forteresse Volante est l'ADAV le plus solide jamais construit, est ?quip?e de nombreuses tourelles laser, elle est capable de riposter dans toutes les directions et d'encaisser des d?g?ts importants. Id?al pour un appuyer un assaut lourd ou monopiler l'Anti-Air pendant une attaque a?rienne.]],
    helptext_de    = [[Die Daneel Olivaw ist stark und ungeschickt, aber sie hat ein Schild um sich zu schutzen und kann seine einige Jaegerdrohne herstellen.]],
    helptext_pl    = [[Daneel Olivaw jest wytrzymala i ma problemy ze zwrotnoscia niczym latajaca cegla, jednak jest ona uzbrojona w oddzial dronow bojowych oraz tarcze obszarowa do ich ochrony.]],
    modelradius    = [[40]],
  },

  explodeAs              = [[LARGE_BUILDINGEX]],
  floater                = true,
  footprintX             = 5,
  footprintZ             = 5,
  hoverAttack            = true,
  iconType               = [[nebula]],
  idleAutoHeal           = 5,
  idleTime               = 1800,
  mass                   = 886,
  maxDamage              = 24000,
  maxVelocity            = 3.6,
  minCloakDistance       = 150,
  noAutoFire             = false,
  noChaseCategory        = [[TERRAFORM FIXEDWING SATELLITE SUB]],
  objectName             = [[nebula.s3o]],
  script                 = [[nebula.lua]],
  seismicSignature       = 0,
  selfDestructAs         = [[LARGE_BUILDINGEX]],

  sfxtypes               = {

    explosiongenerators = {
      -- [[custom:brawlermuzzle]],
      [[custom:BEAMWEAPON_MUZZLE_TEAL]],
      [[custom:plasma_hit_96]],
      [[custom:EXP_MEDIUM_BUILDING_SMALL]],
    },

  },

  side                   = [[CORE]],
  sightDistance          = 633,
  turnRate               = 100,
  upright                = true,
  workerTime             = 0,
  
  weapons                = {

    {
      def                = [[LASER]],
      mainDir            = [[0 1 0]],	-- top
      maxAngleDif        = 210,
      badTargetCategory  = [[FIXEDWING]],
      onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
    },
    {
      def                = [[LASER]],
      mainDir            = [[0 -1 0]],	-- bottom
      maxAngleDif        = 210,
      badTargetCategory  = [[FIXEDWING]],
      onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
    },
    {
      def                = [[LASER]],
      mainDir            = [[-1 0 0]],	-- left
      maxAngleDif        = 210,
      badTargetCategory  = [[FIXEDWING]],
      onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
    },
    {
      def                = [[LASER]],
      mainDir            = [[1 0 0]],	-- right
      maxAngleDif        = 210,
      badTargetCategory  = [[FIXEDWING]],
      onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
    },

    {
      def         = [[SHIELD]],
    },
  },


  weaponDefs             = {

    LASER = {
      name                    = [[Energy Blaster]],
      areaOfEffect            = 32,
      coreThickness           = 0.5,
      craterBoost             = 0,
      craterMult              = 0,

      damage                  = {
        default = 50,
        subs    = 2.5,
      },

      duration                = 0.02,
      explosionGenerator      = [[custom:beamweapon_hit_teal]],
      fireStarter             = 50,
      heightMod               = 1,
      impulseBoost            = 0,
      impulseFactor           = 0.4,
      interceptedByShieldType = 1,
      noSelfDamage            = true,
      range                   = 520,
      reloadtime              = 0.4,
      rgbColor                = [[0.3 0.8 0.6]],
      soundStart              = [[weapon/sonic_blaster]],
      soundHit                = [[weapon/laser/mini_laser]],
      soundTrigger            = true,
      targetMoveError         = 0.15,
      thickness               = 3.2,
      tolerance               = 10000,
      turret                  = true,
      weaponType              = [[LaserCannon]],
      weaponVelocity          = 880,
    },
    
    LASERBEAM = {
      name                    = [[Twin Particle Beam]],
      beamDecay               = 0.9,
      beamTime                = 0.01,
      beamttl                 = 60,
      coreThickness           = 0.25,
      craterBoost             = 0,
      craterMult              = 0,
      cylinderTargeting      = 1,

      damage                  = {
        default = 120,
        subs    = 5,
      },

      explosionGenerator      = [[custom:beamweapon_hit_teal]],
      fireStarter             = 100,
      impulseFactor           = 0,
      interceptedByShieldType = 1,
      laserFlareSize          = 3.25,
      minIntensity            = 1,
      projectiles             = 2,
      pitchtolerance          = 8192,
      range                   = 520,
      reloadtime              = 2,
      rgbColor                = [[0.4 0.95 0.7]],
      soundStart              = [[weapon/laser/medlaser_fire]],
      soundStartVolume        = 6,
      thickness               = 3.2,
      tolerance               = 8192,
      turret                  = true,
      weaponType              = [[BeamLaser]],
    },
    
    CANNON = {
      name                    = [[Kinetic Driver]],
      alphaDecay              = 0.1,
      areaOfEffect            = 32,
      colormap                = [[1 0.95 0.4 1   1 0.95 0.4 1    0 0 0 0.01    1 0.7 0.2 1]],
      craterBoost             = 0,
      craterMult              = 0,

      damage                  = {
        default = 50,
        subs    = 2.5,
      },

      explosionGenerator      = [[custom:plasma_hit_32]],
      impulseBoost            = 0,
      impulseFactor           = 0.4,
      intensity               = 0.7,
      interceptedByShieldType = 1,
      noGap                   = false,
      noSelfDamage            = true,
      range                   = 450,
      reloadtime              = 0.4,
      rgbColor                = [[1 0.95 0.4]],
      separation              = 2,
      size                    = 2.5,
      sizeDecay               = 0,
      soundStart              = [[weapon/cannon/cannon_fire8]],
      soundHit                = [[explosion/ex_small14]],
      sprayAngle              = 360,
      stages                  = 12,
      tolerance               = 5000,
      turret                  = true,
      weaponType              = [[Cannon]],
      weaponVelocity          = 1200,
    },

    SHIELD = {
      name                    = [[Energy Shield]],
      craterMult              = 0,

      damage                  = {
        default = 10,
      },

      exteriorShield          = true,
      impulseFactor           = 0,
      interceptedByShieldType = 1,
      shieldAlpha             = 0.2,
      shieldBadColor          = [[1 0.1 0.1]],
      shieldGoodColor         = [[0.1 0.1 1]],
      shieldInterceptType     = 3,
      shieldPower             = 3600,
      shieldPowerRegen        = 100,
      shieldPowerRegenEnergy  = 9,
      shieldRadius            = 350,
      shieldRepulser          = false,
      smartShield             = true,
      texture1                = [[shield3mist]],
      visibleShield           = true,
      visibleShieldHitFrames  = 4,
      visibleShieldRepulse    = true,
      weaponType              = [[Shield]],
    },
  },


  featureDefs            = {

    DEAD  = {
      description      = [[Wreckage - Daneel Olivaw]],
      blocking         = true,
      category         = [[corpses]],
      collisionVolumeOffsets = [[0 0 0]],
      collisionVolumeScales  = [[40 50 220]],
      collisionVolumeTest    = 1,
      collisionVolumeType    = [[box]],	  
      damage           = 16000,
      energy           = 0,
      featureDead      = [[HEAP]],
      featurereclamate = [[SMUDGE01]],
      footprintX       = 5,
      footprintZ       = 5,
      height           = [[40]],
      hitdensity       = [[100]],
      metal            = 4000,
      object           = [[nebula_dead.s3o]],
      reclaimable      = true,
      reclaimTime      = 4000,
      seqnamereclamate = [[TREE1RECLAMATE]],
      world            = [[All Worlds]],
    },


    HEAP  = {
      description      = [[Debris - Daneel Olivaw]],
      blocking         = false,
      category         = [[heaps]],
      damage           = 16000,
      energy           = 0,
      featurereclamate = [[SMUDGE01]],
      footprintX       = 4,
      footprintZ       = 4,
      height           = [[4]],
      hitdensity       = [[100]],
      metal            = 2000,
      object           = [[debris4x4a.s3o]],
      reclaimable      = true,
      reclaimTime      = 2000,
      seqnamereclamate = [[TREE1RECLAMATE]],
      world            = [[All Worlds]],
    },

  },

}

return lowerkeys({ nebula = unitDef })
