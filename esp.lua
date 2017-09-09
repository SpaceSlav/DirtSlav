local oldrCapture = oldrCapture or nil
local chams = chams or nil
local esp = esp or nil
local chamsmat = CreateMaterial("aa", "VertexLitGeneric", {
        ["$ignorez"] = 1,
        ["$model"] = 1,
        ["$basetexture"] = "models/debug/debugwhite",
});
local mutantNiceNames = {
	["npc_mutant_bloodsucker"] = "Bloodsucker",
	["npc_mutant_boar"] = "Boar",
	["npc_mutant_cat"] = "Feral Cat",
	["npc_mutant_chimera"] = "Chimera",
	["npc_mutant_classiczombie"] = "Zombie",
	["npc_mutant_controller"] = "Controller",
	["npc_mutant_dog"] = "Wild Dog",
	["npc_mutant_flesh"] = "Flesh Pig",
	["npc_mutant_izlom"] = "Izlom",
	["npc_mutant_poltergeist"] = "Poltergeist",
	["npc_mutant_pseudodog"] = "Pseudo-dog",
	["npc_mutant_pseudogiant"] = "Pseudogiant",
	["npc_mutant_psydog"] = "Psy-dog",
	["npc_mutant_rodent"] = "Tushkano",
	["npc_mutant_snork"] = "Snork"
}

if (oldrCapture == nil) then
	oldrCapture = render.Capture

	render.Capture = function()
		capture = true
		render.RenderView({
			origin = LocalPlayer():EyePos(),
			angles = LocalPlayer():EyeAngles(),
			x = 0,
			y = 0,
			w = ScrW(),
			h = ScrH(),
		})
		oldrCapture()
		MsgC(Color(255,0,0), "Alert! render.Capture was called by an outside source!\n")
		capture = false
	end
end

function drawHealthBar(entity)
	local plyHp = entity:Health();
	local maxHp = entity:GetMaxHealth();
	local vecOrigin = entity:GetPos();
	local vecMins = vecOrigin;
	local vecMaxs = Vector(0, 0, entity:OBBMaxs().z) + vecOrigin;

	vecMins.z = vecMins.z - 4;
	vecMaxs.z = vecMaxs.z + 8;
	
	local vScreenTop, vScreenBottom;
	vScreenTop = vecMaxs:ToScreen();
	vScreenBottom = vecMins:ToScreen();

	iH = vScreenBottom.y - vScreenTop.y;
	iW = (iH) / 1.75;
	iX = vScreenBottom.x;
	iY = vScreenBottom.y;
	
	if plyHp > maxHp then
		plyHp = maxHp;
	else 
		plyHp = plyHp;
	end
	
	local sPos = plyHp * iH / maxHp;
	local hDelta = iH - sPos;

	surface.SetDrawColor(0,0,0,255)
	surface.DrawRect(iX - iW / 2 - 5, iY - iH - 1, 3, iH + 2)
	surface.SetDrawColor((maxHp - plyHp) * 2.55, plyHp * 2.55, 0)
	surface.DrawRect(iX - iW / 2 - 4, iY - iH + hDelta, 1, sPos)
end

function drawBoundingBox(entity, color)
	local vecOrigin = entity:GetPos();
	local vecMins = vecOrigin;
	local vecMaxs = Vector(0, 0, entity:OBBMaxs().z) + vecOrigin;

	vecMins.z = vecMins.z - 4;
	vecMaxs.z = vecMaxs.z + 8;
	
	local vScreenTop, vScreenBottom;
	vScreenTop = vecMaxs:ToScreen();
	vScreenBottom = vecMins:ToScreen();

	iH = vScreenBottom.y - vScreenTop.y;
	iW = (iH) / 1.75;
	iX = vScreenBottom.x;
	iY = vScreenBottom.y;

	surface.SetDrawColor(color)
	surface.DrawOutlinedRect(iX - iW / 2, iY - iH, iW, iH);
	surface.SetDrawColor(0,0,0,255)
	surface.DrawOutlinedRect(iX - iW / 2 + 1, iY - iH + 1, iW - 2, iH - 2);
	surface.DrawOutlinedRect(iX - iW / 2 - 1, iY - iH - 1, iW + 2, iH + 2);
end

hook.Add("HUDPaint", "aa", function()
	if (!capture and esp) then
		for k,v in next, ents.GetAll() do
			if (v:IsPlayer() and (v != LocalPlayer())) then
				local color = Color(255,255,255,255)
				local pos = v:GetPos() - Vector(0, 0, 4);
				pos = pos:ToScreen();
				
				draw.DrawText(v:Nick(), "DebugFixed", pos.x, pos.y, color, 1);
				pos.y = pos.y + 16
				if (v:GetRPName() != "") then
					color = Color(0,255,0,255);
					draw.DrawText(v:GetRPName().." ("..v:RPNick()..")", "DebugFixed", pos.x, pos.y, color, 1);
				end
				
				drawBoundingBox(v, Color(255,0,0,255))
				drawHealthBar(v)
			elseif (v:GetClass() == "epd_item") then
				local color = Color(255,255,0,255)
				local pos = v:GetPos() - Vector(0, 0, 4);
				pos = pos:ToScreen();
				
				draw.DrawText(v:GetTable().ItemName or "ITEM", "DebugFixed", pos.x, pos.y, color, 1);
				
				drawBoundingBox(v, Color(0,0,255,255))
			elseif (string.match(v:GetClass(), "npc_mutant")) then
				local color = Color(255,255,0,255)
				local pos = v:GetPos() - Vector(0, 0, 4);
				pos = pos:ToScreen();
				
				draw.DrawText(mutantNiceNames[v:GetClass()], "DebugFixed", pos.x, pos.y, color, 1);
				
				drawBoundingBox(v, Color(0,255,0,255))
				drawHealthBar(v)
			end
		end
	end
end)

hook.Add("PrePlayerDraw", "aaa", function(entity)
	if (!capture and chams) then
		render.SetColorModulation(255, 0, 0)
		render.MaterialOverride(chamsmat)
	end
end)

hook.Add("PostPlayerDraw", "aaa", function(entity)
	render.MaterialOverride(nil)
end)

local lastdown_plus, lastdown_minus

hook.Add("Think", "aaa", function()
	if (input.IsKeyDown(KEY_PAD_MINUS) and !lastdown_minus) then
		esp = !esp
	elseif (input.IsKeyDown(KEY_PAD_PLUS) and !lastdown_plus) then
		chams = !chams
	end
	
	lastdown_minus = input.IsKeyDown(KEY_PAD_MINUS)
	lastdown_plus = input.IsKeyDown(KEY_PAD_PLUS)
end)