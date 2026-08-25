local sf = string.format

soundPath = {}
	soundPath['systems'] = '/systems'

soundLib = {}
	--systems
	soundLib['combatgroup_invite'] = sf('%s/ui_invite',soundPath['systems'])
	
function SLplaysoundUI(_name,_volume)
	if not(_volume) then _volume = 1 end
	
	playSound(soundLib[_name], SoundType.UI, _volume)
end