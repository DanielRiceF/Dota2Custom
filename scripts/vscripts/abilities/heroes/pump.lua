LinkLuaModifier( "modifier_pump_spooky_aura", "abilities/heroes/pump.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pump_spooky", "abilities/heroes/pump.lua", LUA_MODIFIER_MOTION_NONE )

pump_spooky = class({})

function pump_spooky:OnSpellStart()
   
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_pump_spooky_aura", {duration = duration})
end

modifier_pump_spooky_aura = class({})

function modifier_pump_spooky_aura:RemoveOnDeath() return true end

function modifier_pump_spooky_aura:OnCreated()
    
    
    self.flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES

    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_6)

    EmitSoundOn("pump_dance", self:GetParent())
    self.origin = self:GetCaster():GetAbsOrigin()
    self.particle = ParticleManager:CreateParticle("particles/pump/sphere_ultimate.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(self.particle, 0, self.origin)
    ParticleManager:SetParticleControl(self.particle, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"), self:GetAbility():GetSpecialValueFor("radius"), 1))
    self:AddParticle(self.particle, false, false, -1, false, false)
    self:StartIntervalThink(0.5)
end

function modifier_pump_spooky_aura:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
    }

    return decFuncs
end
function modifier_pump_spooky_aura:OnDeath( params )
    if params.unit == self:GetParent() then
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_pump_spooky_aura:GetModifierMoveSpeed_Absolute()
    return 100
end

function modifier_pump_spooky_aura:OnIntervalThink()
    

    if self.origin ~= self:GetCaster():GetAbsOrigin() then
        if self.particle then
            ParticleManager:DestroyParticle(self.particle, true)
            self.origin = self:GetCaster():GetAbsOrigin()
            self.particle = ParticleManager:CreateParticle("particles/pump/sphere_ultimate.vpcf", PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl(self.particle, 0, self.origin)
            ParticleManager:SetParticleControl(self.particle, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"), self:GetAbility():GetSpecialValueFor("radius"), 1))
        end     
    end
end

function modifier_pump_spooky_aura:OnDestroy()
    
    StopSoundOn("pump_dance", self:GetParent())
    self:GetParent():FadeGesture(ACT_DOTA_CAST_ABILITY_6)
    ParticleManager:DestroyParticle(self.particle, true)
end

function modifier_pump_spooky_aura:CheckState()
    if self:GetCaster():HasScepter() then return {
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_MUTED] = true,
    } end
    local state = { [MODIFIER_STATE_STUNNED] = true}
    return state
end

function modifier_pump_spooky_aura:IsAura()
    return true
end

function modifier_pump_spooky_aura:GetModifierAura()
    return "modifier_pump_spooky"
end

function modifier_pump_spooky_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_pump_spooky_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_pump_spooky_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_pump_spooky_aura:GetAuraSearchFlags()
    return self.flag
end

modifier_pump_spooky = class({})

function modifier_pump_spooky:OnCreated()
    
    self:StartIntervalThink(FrameTime())
end

function modifier_pump_spooky:CheckState()
    local state = { [MODIFIER_STATE_STUNNED] = true}
    return state
end

function modifier_pump_spooky:OnIntervalThink()
    
    local damage = self:GetAbility():GetSpecialValueFor("damage")
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage * FrameTime(), damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
    local angle = self:GetParent():GetAngles()
    self:GetParent():SetAngles(angle.x, angle.y+(360 * FrameTime()), angle.z)
end