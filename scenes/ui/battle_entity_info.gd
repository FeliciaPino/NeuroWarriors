extends Control

@export var battle_entity:BattleEntity
var battle_entity_preview:BattleEntity#Ususally null, when set shows the differences from battle_entity, (used to display the predicted effects of actions)

func _process(delta):
	if battle_entity == null:
		#clear it all, TODO
		return
	%Name_Label.text = battle_entity.entity_name
	%Description_Label.text =  battle_entity.entity_description
	#r("BATTLESTAT_DEFENSE"),": ",defense),str(tr("BATTLESTAT_AP_REGEN"),": ",speed)]
	%Health_Label.text = str(tr("BATTLESTAT_HEALTH"),":",battle_entity.health,"/",battle_entity.maxHealth)
	%Attack_Label.text = str(tr("BATTLESTAT_ATTACK"),":",battle_entity.attack)
	%Defense_Label.text = str(tr("BATTLESTAT_DEFENSE"),":",battle_entity.defense)
	%AP_Regen_Label.text = str(tr("BATTLESTAT_AP_REGEN"),":",battle_entity.speed)
