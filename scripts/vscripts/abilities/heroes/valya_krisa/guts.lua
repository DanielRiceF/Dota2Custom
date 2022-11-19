LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_guts_cannon_attack", "abilities/heroes/valya_krisa/guts.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_guts_cannon_debuff", "abilities/heroes/valya_krisa/guts.lua", LUA_MODIFIER_MOTION_NONE )

guts_cannon = class({})

function guts_cannon:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function guts_cannon:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function guts_cannon:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function guts_cannon:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local info = {
		Target = target,
		Source = caster,
		Ability = self,	
		EffectName = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf",
		iMoveSpeed = self:GetSpecialValueFor("bomb_speed"),
		bReplaceExisting = false,
		bProvidesVision = true,
		iVisionRadius = 450,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	ProjectileManager:CreateTrackingProjectile(info)


	if self:GetCaster():HasScepter() then
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
			caster:GetAbsOrigin(),
			nil,
			self:GetCastRange(self:GetCaster():GetAbsOrigin(),self:GetCaster()),
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_UNITS_EVERYWHERE,
			false
		)

		local secondary_knives_thrown = 0
		
		for _, enemy in pairs(enemies) do
			print("da")

			if enemy ~= target then
				info.Target = enemy
				ProjectileManager:CreateTrackingProjectile(info)
				secondary_knives_thrown = secondary_knives_thrown + 1
			end
			
			if secondary_knives_thrown >= 2 then
				break
			end
		end
	end



	caster:EmitSound("Hero_Techies.Attack")
end

function guts_cannon:OnProjectileHit( hTarget, vLocation )
	local target = hTarget
	if target==nil then return end
	if target:TriggerSpellAbsorb( self ) then return end
	local duration = self:GetSpecialValueFor("duration")
	local modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_guts_cannon_attack", {} )
	self:GetCaster():PerformAttack ( hTarget, true, true, true, false, false, false, true )
	if modifier and not modifier:IsNull() then
		modifier:Destroy()
	end
	hTarget:AddNewModifier( self:GetCaster(), self, "modifier_guts_cannon_debuff", {duration = duration * (1 - hTarget:GetStatusResistance())} )
	hTarget:EmitSound("Hero_Techies.LandMine.Detonate")
end

modifier_guts_cannon_attack = class({})

function modifier_guts_cannon_attack:IsHidden()
	return true
end

function modifier_guts_cannon_attack:IsPurgable()
	return false
end

function modifier_guts_cannon_attack:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,

	}

	return funcs
end

function modifier_guts_cannon_attack:GetModifierDamageOutgoing_Percentage( params )
	if IsServer() then
		return self:GetAbility():GetSpecialValueFor( "attack_factor" )
	end
end

function modifier_guts_cannon_attack:GetModifierPreAttack_BonusDamage( params )
	if IsServer() then
		return self:GetAbility():GetSpecialValueFor( "base_damage" ) * 100/(100+self:GetAbility():GetSpecialValueFor( "attack_factor" ))
	end
end

modifier_guts_cannon_debuff = class({})

function modifier_guts_cannon_debuff:IsPurgable()
	return true
end

function modifier_guts_cannon_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_guts_cannon_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor( "move_slow" )
end

function modifier_guts_cannon_debuff:GetEffectName()
	return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger_debuff.vpcf"
end

function modifier_guts_cannon_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end