LinkLuaModifier("modifier_Magic_Reduction", "abilities/heroes/roma_um/passive_magic_red.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Magic_Reduction_debuff", "abilities/heroes/roma_um/passive_magic_red.lua", LUA_MODIFIER_MOTION_NONE)

Magic_Reduction = class({})

function Magic_Reduction:GetIntrinsicModifierName() --Обязательная хуйня без нее ничего не работает
    if self:GetCaster():IsIllusion() then return end
    return "modifier_Magic_Reduction"
end

function Magic_Reduction:GetCastRange(location, target) --Тут все понятно - это для радиуса
    return self:GetSpecialValueFor("aura_radius")
end

modifier_Magic_Reduction = class({})

function modifier_Magic_Reduction:IsHidden()--если истина, то пасиввку видно в статусе героя, если нет то статус только у противника(ну если аура на протиников)
    return false
end

function modifier_Magic_Reduction:IsPurgable()--тут тоже все понятно
    return false
end

function modifier_Magic_Reduction:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_Magic_Reduction:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_Magic_Reduction:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_Magic_Reduction:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_Magic_Reduction:GetModifierAura()
    return "modifier_Magic_Reduction_debuff"
end

function modifier_Magic_Reduction:IsAura()
    return true
end

modifier_Magic_Reduction_debuff = class({})

function modifier_Magic_Reduction_debuff:IsHidden()
    return false
end

function modifier_Magic_Reduction_debuff:IsPurgable()
    return false
end

function modifier_Magic_Reduction_debuff:OnCreated()
	--local aura_damage1 = self:GetAbility():GetSpecialValueFor("aura_damage")
    --if not self:GetParent():IsAncient() then
		--self:GetAbility():GetModifierMagicalResistanceBonus(aura_damage1)
	--end
    --self:StartIntervalThink(0.2)
    --self:GetAbility():GetModifierMagicalResistanceBonus("aura_damage")
end   

function modifier_Magic_Reduction_debuff:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS        
    }

    return decFuncs
end

function modifier_Magic_Reduction_debuff:GetModifierMagicalResistanceBonus()
	--local aura_damage = self:GetAbility():GetSpecialValueFor("aura_damage")
	--if not self:GetParent():IsAncient() then
	return self:GetAbility():GetSpecialValueFor("aura_damage")
	--end
end
--[[function modifier_Magic_Reduction_debuff:OnIntervalThink()
    local target_max_hp = self:GetParent():GetMaxHealth() / 100
    local aura_damage = self:GetAbility():GetSpecialValueFor("aura_damage")
    local aura_damage_interval = self:GetAbility():GetSpecialValueFor("aura_damage_interval")
    
    if not self:GetParent():IsAncient() then
        local damage_table = {}
        damage_table.attacker = self:GetCaster()
        damage_table.victim = self:GetParent()
        damage_table.damage_type = DAMAGE_TYPE_PURE
        damage_table.ability = self:GetAbility()
        damage_table.damage = target_max_hp * -aura_damage * aura_damage_interval
        damage_table.damage_flags = DOTA_DAMAGE_FLAG_HPLOSS
        ApplyDamage(damage_table)
    end
end ]]--