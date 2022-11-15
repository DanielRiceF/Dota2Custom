LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_polnaref_stand_caster", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_polnaref_stand", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_polnaref_disarm", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_polnaref_scepter_in_stand_buff", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)

polnaref_stand_inside = class({})

function polnaref_stand_inside:OnInventoryContentsChanged()
    if not IsServer() then return end

    if self:GetCaster():HasScepter() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end

    for i=0, 8 do
        local item = self:GetCaster():GetItemInSlot(i)
        if item then
            if (item:GetName() == "item_ultimate_scepter" or item:GetName() == "item_ultimate_mem" ) and not item.scepter_polnaref then
                item:SetDroppable(false)
                item:SetSellable(false)
            end
        end
    end
end

function polnaref_stand_inside:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function polnaref_stand_inside:OnAbilityPhaseStart()
    local target = self:GetCursorTarget()
    if target and target:GetUnitName() == "npc_palnoref_chariot" then
        return true
    end
    return false
end

function polnaref_stand_inside:GetCooldown(level)
    if self:GetCaster():HasModifier("modifier_polnaref_scepter_in_stand_buff") then
        return 0
    end
    return self.BaseClass.GetCooldown( self, level )
end

function polnaref_stand_inside:GetBehavior()
    if self:GetCaster():HasModifier("modifier_polnaref_scepter_in_stand_buff") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function polnaref_stand_inside:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("polnaref_instand")
    if self:GetCaster():HasModifier("modifier_polnaref_scepter_in_stand_buff") then
        local modifier = self:GetCaster():FindModifierByName("modifier_polnaref_scepter_in_stand_buff")
        if modifier and not modifier:IsNull() then
            modifier:Destroy()
        end
        return
    end
    local target = self:GetCursorTarget()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_polnaref_scepter_in_stand_buff", {stand = target:entindex()})
    self:EndCooldown()
end