-- colors = {}
	-- colors['darkgray'] = ColorHSV(50,0.1,0.2)
	-- colors['lightgray'] = ColorHSV(50,0.1,0.4)
	-- colors['white'] = ColorHSV(240, 0, 100)
	-- colors['green'] = ColorHSV(125,1,1)
	-- colors['purple'] = ColorHSV(300,1,1)
	-- colors['brown'] = ColorHSV(25,0.8,0.7)
	
	-- colors['aqua'] = ColorHSV(200,1,1)
	-- colors['grass'] = ColorHSV(150,1,1)
	-- colors['radiate'] = ColorHSV(75,1,1)
	-- colors['sand'] = ColorHSV(50,1,1)
	-- colors['danger'] = ColorHSV(50,1,1)
	-- colors['cake'] = ColorHSV(325,1,1)
	-- colors['avorion'] = ColorHSV(350,1,1)
	-- colors['frozenbear'] = ColorHSV(25,0.4,0.7)
	-- colors['frozengrass'] = ColorHSV(75,0.4,0.7)
	-- colors['ice'] = ColorHSV(170,0.8,0.9)
	
	-- colors['weaponclass_heavy'] = ColorHSV(25,0.7,0.6)
	-- colors['weaponclass_light'] = ColorHSV(175,0.7,0.6)
	-- colors['weaponclass_MC'] = ColorHSV(5,0.8,0.8)
	-- colors['auracore_debuff'] = ColorHSV(5,0.8,0.8)
	-- colors['auracore_buff'] = ColorHSV(85,0.6,0.9)
	-- colors['auracore_standby'] = ColorHSV(60,0.6,0.9)
	-- colors['infotabs_updated'] = ColorHSV(180,0.6,0.9)
	
	-- colors['activeSysInterface_ready'] = ColorHSV(130,0.9,0.9)
	-- colors['activeSysInterface_working'] = ColorHSV(65,1,1)
	-- colors['activeSysInterface_notready'] = ColorHSV(10,1,1)
	
colorsC = {}
	colorsC['darkgray'] = {50,0.1,0.2}
	colorsC['lightgray'] = {50,0.1,0.4}
	colorsC['white'] = {240, 0, 100}
	colorsC['green'] = {125,1,1}
	colorsC['purple'] = {300,1,1}
	colorsC['brown'] = {25,0.8,0.7}
	
	colorsC['aqua'] = {200,1,1}
	colorsC['grass'] = {150,1,1}
	colorsC['radiate'] = {75,1,1}
	colorsC['sand'] = {50,1,1}
	colorsC['danger'] = {25,1,1}
	colorsC['cake'] = {325,1,1}
	colorsC['avorion'] = {350,1,1}
	colorsC['frozenbear'] = {25,0.4,0.7}
	colorsC['frozengrass'] = {75,0.4,0.7}
	colorsC['ice'] = {170,0.8,0.9}
	
	colorsC['weaponclass_heavy'] = {25,0.7,0.6}
	colorsC['weaponclass_light'] = {175,0.7,0.6}
	colorsC['weaponclass_MC'] = {5,0.8,0.8}
	colorsC['auracore_debuff'] = {5,0.8,0.8}
	colorsC['auracore_buff'] = {85,0.6,0.9}
	colorsC['auracore_standby'] = {60,0.6,0.9}
	colorsC['infotabs_updated'] = {180,0.6,0.9}
	
	colorsC['activeSysInterface_ready'] = {130,0.9,0.9}
	colorsC['activeSysInterface_working'] = {65,1,1}
	colorsC['activeSysInterface_notready'] = {10,1,1}
	
function getColor(_name,a)
	if colorsC[_name] then
		local colorCode = colorsC[_name]
		local color = ColorHSV(colorCode[1],colorCode[2],colorCode[3])
		
		if a then
			color.a = a
		end
		
		return color
	else
		return
	end
end

function getColorCode(_name)
	if colorsC[_name] then
		return colorsC[_name]
	else
		return colorsC['white']
	end
end

function getUIcolor(a)
	if onClient() then
		local color = ClientSettings().uiColor
		if a then
			color.a = a
		end
		return color
	end
end
