LinkLuaModifier("modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_saitama_fast_attack", "abilities/heroes/linar_josk/saitama.lua", LUA_MODIFIER_MOTION_NONE)

saitama_fast_attack = class({})

function saitama_fast_attack:OnSpellStart()
	if not IsServer() then return end
	local direction = self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()
	direction.z = 0
	direction = direction:Normalized()
	self:GetCaster():SetForwardVector(direction)
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_saitama_fast_attack", {})
end

modifier_saitama_fast_attack = class({})

function modifier_saitama_fast_attack:IsHidden() return true end

function modifier_saitama_fast_attack:IsPurgable() return false end

function modifier_saitama_fast_attack:OnCreated()
	if not IsServer() then return end
	self.attack_count = self:GetAbility():GetSpecialValueFor("attack_count") -- + self:GetCaster():FindTalentValue("special_bonus_birzha_saitama_6")
	self.base_damage = self:GetAbility():GetSpecialValueFor("base_damage")
	self.damage_from_attack = self:GetAbility():GetSpecialValueFor("damage_from_attack") -- - self:GetCaster():FindTalentValue("special_bonus_birzha_saitama_1")
	self.attack_current = 0
	self.anim = ACT_DOTA_ATTACK
	self:StartIntervalThink(0.15)
end

function modifier_saitama_fast_attack:OnIntervalThink()
	if not IsServer() then return end
	if self.attack_current == self.attack_count then self:Destroy() return end
	if self:GetParent():IsStunned() then self:Destroy() return end
	if self:GetParent():IsDisarmed() then self:Destroy() return end
	local damage = self.base_damage + (self:GetParent():GetAverageTrueAttackDamage(nil) / 100 * self.damage_from_attack)
	self.attack_current = self.attack_current + 1

	self:GetParent():StartGestureWithPlaybackRate(self.anim, 10)

	if self.anim == ACT_DOTA_ATTACK then
		self.anim = ACT_DOTA_ATTACK2
	else
		self.anim = ACT_DOTA_ATTACK
	end

	self:GetParent():EmitSound("saitama_attack")

	local particle = ParticleManager:CreateParticle( "particles/saitama/auto_attack_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl(particle, 1, self:GetParent():GetAbsOrigin() + self:GetParent():GetForwardVector() * 200)
	ParticleManager:ReleaseParticleIndex( particle )

	local units = FindUnitsInLine(self:GetParent():GetTeamNumber(), self:GetCaster():GetAbsOrigin() + self:GetParent():GetForwardVector(), (self:GetCaster():GetAbsOrigin() + self:GetParent():GetForwardVector() * self:GetParent():Script_GetAttackRange()), self:GetParent(), 100, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE)
	for _, unit in pairs(units) do
		self:GetCaster():PerformAttack( unit, false, true, true, false, false, false, false )
	end
end

function modifier_saitama_fast_attack:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_TURNING,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_FIXED_ATTACK_RATE
	}

	return funcs
end

function modifier_saitama_fast_attack:GetModifierDamageOutgoing_Percentage( params )
	--if IsServer() then
		return self.damage_from_attack
	--end
end

function modifier_saitama_fast_attack:GetModifierPreAttack_BonusDamage( params )
	--if IsServer() then
		return self.base_damage * 100 / (100+self.damage_from_attack)
	--end
end

function modifier_saitama_fast_attack:GetModifierDisableTurning()
	return 1
end

function modifier_saitama_fast_attack:GetModifierMoveSpeed_Absolute()
	return 20
end

function modifier_saitama_fast_attack:GetModifierFixedAttackRate( params )
    return 10
end

function modifier_saitama_fast_attack:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end
