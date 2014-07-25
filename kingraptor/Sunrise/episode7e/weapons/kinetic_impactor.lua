return {
    kinetic_impactor = {
	name                    = [[Kinetic Impactor]],
	alphaDecay              = 0.12,
	areaOfEffect            = 256,
	cegTag                  = [[gauss_tag_h]],
	craterBoost             = 1,
	craterMult              = 2,
    
	damage                  = {
	    default = 1500,
	},
    
	edgeEffectiveness       = 0.5,
	explosionGenerator      = [[custom:lrpc_expl]],
	model                   = [[wep_m_ajax.s3o]],
	myGravity               = 0.5,
	flightTime              = 100,
	fixedLauncher		= false,
	impulseBoost            = 250,
	impulseFactor           = 0.5,
	interceptedByShieldType = 1,
	range                   = 20000,
	reloadtime              = 8,
	rgbColor                = [[1 0.6 0]],
	startVelocity           = 2500,
	separation              = 0.5,
	size                    = 0.8,
	sizeDecay               = -0.1,
	smokeTrail		= true,
	soundHit                = [[explosion/ex_large2]],
	--soundStart              = [[weapon/gauss_fire]],
	stages                  = 32,
	turret                  = true,
	weaponType              = [[AircraftBomb]],	-- pretty much required for 91.0
	weaponVelocity          = 2500,
    },
}
