--really scuffed way of separation
addHook("PlayerMsg", function(player, msgtype, target, msg)
    if msg == "im spongebob"
    S_StartSound(player.mo, sfx_imspng)
    end
end)

addHook("MusicChange", function(oldname, newname)
    if splitscreen
        return
    end
    if not (consoleplayer and consoleplayer.valid)
        return
    end
    local Spsong = skins[consoleplayer.skin].name
    if Spsong == "spongebob"
        if newname == "VSBOSS"
		   return "BFBB"
        elseif newname == "DISCO"
            return "STAD"
		elseif string.upper(newname) == "_SUPER"
			return "GOOFY"
        end
    end
end)

freeslot("sfx_imspng", "sfx_idle", "SPR_SBLS", "S_SPONGEBOB_LASER", "MT_SPONGEBOB_LASER")

sfxinfo[sfx_imspng].caption = "im spongebob"
sfxinfo[sfx_idle].caption = "Get a move on..."
addHook("PlayerThink", function(player)
    /*if (player.powers[pw_super] == 1 and skins[player.skin].name == "spongebob") then -- pacola here, i just made it go to the musicchange hook, should work better maybe
	S_ChangeMusic("GOOFY", true, player)
	end*/
    if player.mo.sprite2 == SPR2_STND and (((PizzaTime) and (PizzaTime.PizzaTime)) or (JISK_PIZZATIME) 
    or ((PTJE) and (PTJE.pizzatime)) or ((HAPPY_HOUR and HAPPY_HOUR.happyhour))) then //PT checkerss
    player.mo.sprite2 = SPR2_SCAR
	player.some_timer = 110 //timer = tics
    end
    if player.mo.sprite2 == SPR2_SCAR  then
    player.mo.frame = (leveltime % 60) | FF_FULLBRIGHT	
	  if player.some_timer then //begins countdown
        player.some_timer = $ - 1
        if player.some_timer <= 0 then
        S_StartSound(player.mo, sfx_idle) //what happens when countdown is done	
        end  
      end
    end
end)

-- all code below is writtin by pacola


-- should chang the music when you are in a fan

addHook("PlayerSpawn", function(p)
	if p.spongehengemus
		P_RestoreMusic(p)
		p.spongehengemus = false
	end
end)

addHook("PlayerThink", function(p)
	if not (p.mo and p.mo.valid)
	or p.mo.skin ~= "spongebob" 
		if p.spongehengemus
			P_RestoreMusic(p)
			p.spongehengemus = false
		end
		return
	end
	
	if p.spongehengemus == nil
		p.spongehengemus = false
	end
	
	if p.powers[pw_carry] == CR_FAN
	and not p.spongehengemus
		P_PlayJingleMusic(p, "SPNHEN", 0, true)
		p.spongehengemus = true
	elseif p.powers[pw_carry] ~= CR_FAN
	and p.spongehengemus
	and P_IsObjectOnGround(p.mo)
		P_RestoreMusic(p)
		p.spongehengemus = false
	end
end)

-- super lazer pizza

states[S_SPONGEBOB_LASER] = {
	sprite = SPR_CORK,
	frame = A,
	tics = -1,
	nextstate = S_SPONGEBOB_LASER
}

mobjinfo[MT_SPONGEBOB_LASER] = {
	doomednum = -1,
	spawnhealth = 1,
	spawnstate = S_SPONGEBOB_LASER,
	deathstate = S_NULL,
	xdeathstate = S_NULL,
	deathsound = sfx_null,
	speed = 36*2*FU,
	radius = 16*FU,
	height = 16*FU,
	flags = MF_NOGRAVITY|MF_MISSILE
}

addHook("PlayerThink", function(p)
	if not (p.mo and p.mo.valid)
	or p.mo.skin ~= "spongebob"
	or not (p and p.valid)
	or not p.powers[pw_super] return end
	
	local enmy = P_LookForEnemies(p, false, true)
	
	if (p.cmd.buttons & BT_CUSTOM2)
		p.bobc1held = $+1
	else
		p.bobc1held = 0
	end
	
	if (enmy and enmy.valid)
		P_SpawnLockOn(p, enmy, S_LOCKON1)
		if p.bobc1held == 1
		and p.weapondelay == 0
			P_SpawnMissile(p.mo, enmy, MT_SPONGEBOB_LASER)
			p.weapondelay = TICRATE
			p.mo.state = S_PLAY_FIRE
		end
	end
	
	if p.mo.state == S_PLAY_FIRE
	and p.weapondelay == 0
		p.mo.state = S_PLAY_STND
	end
end)

addHook("MobjDeath", function(mo, laser, _, dmg)
	if not (laser and laser.valid)
	or laser.type ~= MT_SPONGEBOB_LASER return end
	
	P_RadiusAttack(laser, laser.target, FixedMul(128*FU, FU+FU/2), dmg, false)
end)


local function initializeVars(player)
	player.spongebob = {
		health = 3,
		oldrings = 0
	}
end

addHook("PlayerSpawn", initializeVars)

addHook("PlayerThink", function(player)
	if not player.spongebob initializeVars(player) end
	
	if player.mo.skin ~= "spongebob" return end
	
	if player.rings >= player.spongebob.oldrings+10 -- if you have 10 or more rings than before
		player.spongebob.oldrings = player.rings -- set the before variable to your current ring count
		if player.spongebob.health < 3 -- if you have less than 3 health, as i dont want you to magically have 50 health
			player.spongebob.health = $+1 -- add one to your health
		end
	elseif player.rings < player.spongebob.oldrings --else, if you have less than your old ring count
		player.spongebob.oldrings = player.rings -- set it to your current ring count
	end
end)

addHook("MobjDamage", function(pmo, inf, src, _, dmgtype)
	if pmo.skin ~= "spongebob" return end
	local player = pmo.player
	
	--player.spongebob.oldrings = 0
	if player.spongebob.health-1 <= 0 -- if removing one from your health is lower or equals than 0
		P_KillMobj(pmo, inf, src, dmgtype) -- then die.
	end
	player.spongebob.health = $-1
	if player.rings == 0
		P_PlayRinglossSound(pmo, player) -- basically emulating a damage instead of just dying
		P_DoPlayerPain(player, inf, src)
		return true
	end
end, MT_PLAYER)

addHook("HUD", function(v, player)
	if player.mo.skin ~= "spongebob" return end -- if you aren't spongebob, GET OUT OF THIS HOOK THEN!!!!
	
	v.draw(16, 142, v.cachePatch("SPONGERING"), V_SNAPTOLEFT|V_SNAPTORIGHT)
	if player.spongebob.health > 0 -- i didn't add a graphic for 0 health as it's just nothing
	and player.spongebob.health < 4 -- and you shouldn't even have more than 3 health to begin with
		v.draw(16, 142, v.cachePatch("SPONGEHEALTH"+player.spongebob.health), V_SNAPTOLEFT|V_SNAPTORIGHT)
	end
end, "game")

local function shouldGroundPound(p)
	if P_IsObjectOnGround(p.mo)
	or P_PlayerInPain(p)
	or p.playerstate == PST_DEAD
	or (p.pflags & PF_SPINNING)
	or (p.mo.eflags & MFE_SPRUNG)
	or p.sbsprung
		return false
	else
		return true
	end
end

freeslot("sfx_gpland", "sfx_gplan2")

sfxinfo[sfx_gpland].caption = "Heavy hit"
sfxinfo[sfx_gplan2].caption = "Heavy hit"

addHook("PlayerThink", function(p)
	if not (p.mo and p.mo.valid)
	or p.mo.skin ~= "spongebob" return end
	
	if (p.cmd.buttons & BT_CUSTOM1)
		p.sbc3held = $+1
	else
		p.sbc3held = 0
	end
	
	if (p.cmd.buttons & BT_JUMP)
		p.sbjumpheld = $+1
	else
		p.sbjumpheld = 0
	end
	
	if (p.mo.eflags & MFE_SPRUNG)
	and not p.sbsprung
	and p.sbgpound
		p.sbsprung = true
	end
	
	if p.sbsprung
	and P_IsObjectOnGround(p.mo)
		p.sbsprung = false
	end
	
	if p.sbc3held == 1
	and shouldGroundPound(p)
	and not (p.mo.state >= S_PLAY_SUPER_TRANS1 and p.mo.state <= S_PLAY_SUPER_TRANS6)
	and (p.pflags & PF_JUMPED)
	and not p.sbgpound --sbgpound means spongebob ground pound :D
		p.sbgptimer = 0
		p.sbgpound = true
		p.pflags = $1|PF_THOKKED
		--S_StartSound(p.mo, sfx_gpstrt)
	end
	
	if p.sbgpound
		p.sbgptimer = $+1
		p.pflags = $1|PF_FULLSTASIS
		if p.sbgptimer < TICRATE/3
			p.mo.momx = 0
			p.mo.momy = 0
			p.mo.momz = 0
		elseif p.sbgptimer == TICRATE/3
			P_SetObjectMomZ(p.mo, 15*FU)
		else
			p.powers[pw_strong] = STR_FLOOR|STR_HEAVY|STR_ATTACK|STR_SPRING|STR_ANIM
			P_SetObjectMomZ(p.mo, -2*FU, true)
		end
		
		if not shouldGroundPound(p)
		or p.sbjumpheld == 1
			p.sbgpound = false
			if P_IsObjectOnGround(p.mo)
				P_NukeEnemies(p.mo, p.mo, 128*FU)
				--S_StartSound(p.mo, sfx_gpland)
				S_StartSound(p.mo, sfx_gplan2)
			elseif p.sbjumpheld == 1
				S_StartSound(p.mo, sfx_s3k42)
			end
		end
	end
end)

freeslot("S_SPONGEBOB_ATTACK", "sfx_sbbs")

states[S_SPONGEBOB_ATTACK] = {
	sprite = SPR_PLAY,
	frame = SPR2_MLEE,
	tics = -1,
	nextstate = S_SPONGEBOB_ATTACK
}

sfxinfo[sfx_sbbs].caption = "Bubble Spin"

local function canAttack(p)
	if P_PlayerInPain(p)
	or p.playerstate == PST_DEAD
	or (p.pflags & PF_SPINNING)
	or (p.mo.eflags & MFE_SPRUNG)
	or p.sbsprung
		return false
	end
	return true
end

addHook("PlayerThink", function(p)
	if not (p.mo and p.mo.valid)
	or p.mo.skin ~= "spongebob" return end
	
	if p.sbatkthing == nil
		p.sbatkthing = false
		p.sbatkrot = 0
		p.sbspinheld = 0
	end
	
	if (p.cmd.buttons & BT_SPIN)
		p.sbspinheld = $+1
	else
		p.sbspinheld = 0
	end
	
	if p.sbspinheld == 1
	and canAttack(p)
	and not p.sbatkthing
		p.sbatkrot = 0
		p.sbatkthing = true
		S_StartSound(p.mo, sfx_sbbs)
	end
	
	--local test = FixedDiv(225, 10)
	local test = 15*FU
	
	if p.sbatkthing
		p.sbatkrot = $+test
		p.powers[pw_strong] = $1|STR_ATTACK|STR_WALL|STR_ANIM
		p.mo.state = S_SPONGEBOB_ATTACK
		p.drawangle = p.mo.angle+FixedAngle(p.sbatkrot)
		if p.sbatkrot >= 360*FU
		or not canAttack(p)
			p.sbatkthing = false
			if canAttack(p)
				p.mo.state = S_PLAY_JUMP
			else
				S_StopSoundByID(p.mo, sfx_sbbs)
			end
		end
	elseif p.mo.state == S_SPONGEBOB_ATTACK
		p.mo.state = S_PLAY_JUMP
	end
end)