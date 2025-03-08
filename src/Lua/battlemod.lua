local ScriptLoaded = false
addHook("ThinkFrame", function()
	if not(ScriptLoaded)
		and CBW_Battle 
		then
		ScriptLoaded = true 
		local B = CBW_Battle	
		local CollideFunc = function(n1,n2,plr,mo,atk,def,weight,hurt,pain,ground,angle,thrust,thrust2,collisiontype)
			if not (plr[n1] and plr[n1].valid and plr[n1].playerstate == PST_LIVE)
				or not mo[n1].health
				or not mo[n1].state == S_PLAY_ROLL
				or pain[n1]
				return false
			end
			if (hurt != 1 and n1 == 1) or (hurt != -1 and n1 == 2)
				S_StartSound(mo[n1], sfx_lose)
				return true
			end
		end
		CBW_Battle.SkinVars["spongebob"] = {
		    flags = SKINVARS_NOSPINSHIELD,
			special = CBW_Battle.Action.PikoSpin,
			guard_frame = 4,
			func_priority_ext = PriorityFunc,
			func_exhaust = ExhaustFunc,
			func_collide = CollideFunc
		}
	end
end)