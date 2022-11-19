LinkLuaModifier( "modifier_crescent_sky_rush", "abilities/heroes/ichigo/crescent_sky_rush.lua", LUA_MODIFIER_MOTION_NONE )

crescent_sky_rush = class({})

function crescent_sky_rush:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function crescent_sky_rush:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function crescent_sky_rush:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function crescent_sky_rush:OnAbilityPhaseInterrupted()
    if not IsServer() then return end
    self:GetCaster():StopSound("Hero_Magnataur.ShockWave.Cast")
    if self.swing_fx then
        ParticleManager:DestroyParticle(self.swing_fx, false)
    end
    return true
end

function crescent_sky_rush:OnAbilityPhaseStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("Hero_Juggernaut.BladeDance")
    --self.swing_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_magnataur/magnataur_shockwave_cast.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
    self.swing_fx = ParticleManager:CreateParticle("particles/ichigo/magnataur_shockwave_cast.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)

    ParticleManager:SetParticleControlEnt(self.swing_fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.swing_fx, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
    return true
end

function crescent_sky_rush:OnSpellStart()
    if not IsServer() then return end
    local target_loc = self:GetCursorPosition()
    local caster_loc = self:GetCaster():GetAbsOrigin()
    local distance = self:GetCastRange(caster_loc,self:GetCaster())
    local speed = 2000
    local radius = 100

    if target_loc == caster_loc then
        direction = self:GetCaster():GetForwardVector()
    else
        direction = (target_loc - caster_loc):Normalized()
    end
    local projectile =
    {
        Ability             = self,
        EffectName          = "particles/ichigo/magnataur_shockwave.vpcf",
        vSpawnOrigin        = caster_loc,
        fDistance           = distance,
        fStartRadius        = radius,
        fEndRadius          = radius,
        Source              = self:GetCaster(),
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 5.0,
        bDeleteOnHit        = false,
        vVelocity           = Vector(direction.x,direction.y,0) * speed,
        bProvidesVision     = false,
        ExtraData           = {index = index, damage = damage}
    }
    ProjectileManager:CreateLinearProjectile(projectile)
end

function crescent_sky_rush:OnProjectileHit_ExtraData(target, location, ExtraData)
    if target then
        local damage = self:GetSpecialValueFor("damage")
        ApplyDamage({victim = target, attacker = self:GetCaster(), ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
        target:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
    end
end

modifier_crescent_sky_rush = class({})

function modifier_crescent_sky_rush:IsPurgable() return false end

function modifier_crescent_sky_rush:IsPurgeException() return true end

function modifier_crescent_sky_rush:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW 
end



shunpo = class({})
function shunpo:IsStealable() return true end
function shunpo:IsHiddenWhenStolen() return false end
function shunpo:GetAOERadius()
	return self:GetSpecialValueFor("range") +  self:GetCaster():GetCastRangeBonus() --self:GetCaster():FindTalentValue("special_bonus_anime_ichigo_10L") 
end
function shunpo:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local range = self:GetAOERadius()
	
	if (point - caster:GetAbsOrigin()):Length2D() > range then
		point = caster:GetAbsOrigin() + (((point - caster:GetAbsOrigin()):Normalized()) * range)
	end

	ProjectileManager:ProjectileDodge(caster)

	--if caster:HasModifier("modifier_ichigo_hollow") then
	--	EmitSoundOn("Ichigo.Sonido", caster)
	--else
	--	EmitSoundOn("Ichigo.Shunpo", caster)
	--end
	--
	local particle_shunpo = ParticleManager:CreateParticle("particles/ichigo/shunpo_start.vpcf", PATTACH_ABSORIGIN, caster)
							ParticleManager:SetParticleControl(particle_shunpo, 0, caster:GetAbsOrigin())
							ParticleManager:SetParticleControl(particle_shunpo, 1, point)
							ParticleManager:ReleaseParticleIndex(particle_shunpo)
	
	FindClearSpaceForUnit(caster, point, true)
	
	--caster:EmitSound("Hero_QueenOfPain.Blink_out")
	
	local particle_shunpo_end = ParticleManager:CreateParticle("particles/ichigo/shunpo_end.vpcf", PATTACH_ABSORIGIN, caster)
								ParticleManager:SetParticleControl(particle_shunpo_end, 0, caster:GetAbsOrigin())
								ParticleManager:ReleaseParticleIndex(particle_shunpo_end)
end




LinkLuaModifier( "modifier_crescent_sky_rush_bankai", "abilities/heroes/ichigo/crescent_sky_rush.lua", LUA_MODIFIER_MOTION_NONE )
crescent_sky_rush_bankai = class({})

function crescent_sky_rush_bankai:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function crescent_sky_rush_bankai:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function crescent_sky_rush_bankai:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function crescent_sky_rush_bankai:OnAbilityPhaseInterrupted()
    if not IsServer() then return end
    self:GetCaster():StopSound("Hero_Magnataur.ShockWave.Cast")
    if self.swing_fx then
        ParticleManager:DestroyParticle(self.swing_fx, false)
    end
    return true
end

function crescent_sky_rush_bankai:OnAbilityPhaseStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("Hero_Juggernaut.BladeDance")
    --self.swing_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_magnataur/magnataur_shockwave_cast.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
    self.swing_fx = ParticleManager:CreateParticle("particles/ichigo/magnataur_shockwave_cast.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)

    ParticleManager:SetParticleControlEnt(self.swing_fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.swing_fx, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
    return true
end

function crescent_sky_rush_bankai:OnSpellStart()
    if not IsServer() then return end
    local target_loc = self:GetCursorPosition()
    local caster_loc = self:GetCaster():GetAbsOrigin()
    local distance = self:GetCastRange(caster_loc,self:GetCaster())
    local speed = 2000
    local radius = 100

    if target_loc == caster_loc then
        direction = self:GetCaster():GetForwardVector()
    else
        direction = (target_loc - caster_loc):Normalized()
    end
    local projectile =
    {
        Ability             = self,
        EffectName          = "particles/ichigo/magnataur_shockwave.vpcf",
        vSpawnOrigin        = caster_loc,
        fDistance           = distance,
        fStartRadius        = radius,
        fEndRadius          = radius,
        Source              = self:GetCaster(),
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 5.0,
        bDeleteOnHit        = false,
        vVelocity           = Vector(direction.x,direction.y,0) * speed,
        bProvidesVision     = false,
        ExtraData           = {index = index, damage = damage}
    }
    ProjectileManager:CreateLinearProjectile(projectile)
end

function crescent_sky_rush_bankai:OnProjectileHit_ExtraData(target, location, ExtraData)
    if target then
        local damage = self:GetSpecialValueFor("damage")
        ApplyDamage({victim = target, attacker = self:GetCaster(), ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
        target:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
    end
end
modifier_crescent_sky_rush_bankai = class({})

function modifier_crescent_sky_rush_bankai:IsPurgable() return false end
function modifier_crescent_sky_rush_bankai:IsPurgeException() return true end

function modifier_crescent_sky_rush_bankai:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW 
end











LinkLuaModifier( "modifier_bankai_buff", "abilities/heroes/ichigo/crescent_sky_rush.lua", LUA_MODIFIER_MOTION_NONE )


bankai = class({}) 

function bankai:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function bankai:OnSpellStart()
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_bankai_buff", {duration = duration} )
end

modifier_bankai_buff= class({})

function modifier_bankai_buff:IsHidden()
    return true
end

function modifier_bankai_buff:IsPurgable()
    return false
end

function modifier_bankai_buff:RemoveOnDeath()
    return true
end

function modifier_bankai_buff:OnCreated()
    if not IsServer() then return end
    self:GetParent():SwapAbilities("crescent_sky_rush", "crescent_sky_rush_bankai", false, true)

end

function modifier_bankai_buff:OnRemoved()
    if not IsServer() then return end
    self:GetParent():SwapAbilities("crescent_sky_rush_bankai", "crescent_sky_rush", false, true)
end

function modifier_bankai_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
	}
	return funcs
end


function modifier_bankai_buff:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("move_speed")
end

function modifier_bankai_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("attack_speed")
end









LinkLuaModifier( "modifier_hichigo", "abilities/heroes/ichigo/crescent_sky_rush.lua", LUA_MODIFIER_MOTION_NONE )

hichigo = class({})

function hichigo:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function hichigo:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function hichigo:OnSpellStart()
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_hichigo", {duration = duration} )
end

modifier_hichigo = class({})

function modifier_hichigo:IsHidden()
    return true
end

function modifier_hichigo:IsPurgable()
    return false
end

function modifier_hichigo:RemoveOnDeath()
    return true
end

function modifier_hichigo:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
	}
	return funcs
end

function modifier_hichigo:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor("attack_range")
end

function modifier_hichigo:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("move_speed")
end

function modifier_hichigo:GetModifierPreAttack_CriticalStrike()
	return self:GetAbility():GetSpecialValueFor("critical_p")
end