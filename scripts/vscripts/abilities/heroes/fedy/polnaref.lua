LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_polnaref_stand_caster", "abilities/heroes/fedy/polnaref.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_polnaref_stand", "abilities/heroes/fedy/polnaref.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_polnaref_disarm", "abilities/heroes/fedy/polnaref.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_polnaref_scepter_in_stand_buff", "abilities/heroes/fedy/polnaref.lua", LUA_MODIFIER_MOTION_NONE)

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
modifier_polnaref_scepter_in_stand_buff = class({})

function modifier_polnaref_scepter_in_stand_buff:IsPurgable() return false end

function modifier_polnaref_scepter_in_stand_buff:OnCreated(kv)
    if not IsServer() then return end
    self.stand = EntIndexToHScript(kv.stand)
    self:GetParent():AddNoDraw()
    self:StartIntervalThink(FrameTime())
    local ability_stand_spawn = self:GetParent():FindAbilityByName("polnaref_stand")
    if ability_stand_spawn then
        ability_stand_spawn:SetActivated(false)
    end
end

function modifier_polnaref_scepter_in_stand_buff:OnDestroy()
    if not IsServer() then return end
    self:GetAbility():UseResources(false, false, true)
    self:GetParent():RemoveNoDraw()
    local ability_stand_spawn = self:GetParent():FindAbilityByName("polnaref_stand")
    if ability_stand_spawn then
        ability_stand_spawn:SetActivated(true)
    end
end

function modifier_polnaref_scepter_in_stand_buff:OnIntervalThink()
    if not IsServer() then return end
    if not self.stand:IsAlive() then
        if not self:IsNull() then
            self:Destroy()
        end
        return
    end
    self:GetParent():SetAbsOrigin(self.stand:GetAbsOrigin())
end

function modifier_polnaref_scepter_in_stand_buff:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE]       = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true,
        [MODIFIER_STATE_NO_HEALTH_BAR]  = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_MUTED] = true,
    }
end

polnaref_stand = class({})

function polnaref_stand:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function polnaref_stand:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function polnaref_stand:OnUpgrade()
     if self.stand and IsValidEntity(self.stand) and self.stand:IsAlive() then
        self.stand:FindModifierByName("modifier_polnaref_stand"):ForceRefresh()
    end
end

function polnaref_stand:GetIntrinsicModifierName() 
    return "modifier_polnaref_stand_caster"
end

function polnaref_stand:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local player = caster:GetPlayerID()
    local ability = self
    local level = self:GetLevel()
    local origin = caster:GetAbsOrigin() + RandomVector(100)

    if self.stand and IsValidEntity(self.stand) and self.stand:IsAlive() then
        self.stand:Kill( self, self:GetCaster() )
        self:EndCooldown()
    elseif self.stand then
        self.stand:RespawnUnit() 
        FindClearSpaceForUnit(self.stand, origin, true)
        self.stand:AddNewModifier(self:GetCaster(), self, 'modifier_polnaref_stand', {})
        self.stand:SetForwardVector( self:GetCaster():GetForwardVector() )
        self.stand:EmitSound("PolnarefChariot")
        Timers:CreateTimer(0.1, function()         
            self.particle = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.stand)
            ParticleManager:SetParticleControl(self.particle, 0, self.stand:GetAbsOrigin()) 
        end)
    else
        self.stand = CreateUnitByName("npc_palnoref_chariot", origin, true, caster, caster, caster:GetTeamNumber())
        self.stand:SetControllableByPlayer(player, true)
        self.stand:SetOwner(self:GetCaster())
        self.stand:AddNewModifier(self:GetCaster(), self, 'modifier_polnaref_stand', {})
        self.stand:SetForwardVector( self:GetCaster():GetForwardVector() )
        self.stand:EmitSound("PolnarefChariot")
        self.particle = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.stand)
        ParticleManager:SetParticleControl(self.particle, 0, self.stand:GetAbsOrigin())
        --for i = 0, 8 do
        --    local items_list = CustomNetTables:GetTableValue('stand_items', tostring(i))
        --    if items_list then
        --        local new_item = items_list.item
        --        if new_item then
        --            local item_created = CreateItem( new_item, self:GetCaster(), self:GetCaster())
        --            self.stand:AddItem(item_created)
        --            item_created:SetPurchaseTime(0)
        --            self.stand:SwapItems(item_created:GetItemSlot(), items_list.slot)
        --        end
        --    end
        --end 
        self.stand:SetUnitCanRespawn(true)  
    end
end

modifier_polnaref_stand = class({})

function modifier_polnaref_stand:IsHidden()
    return true
end

function modifier_polnaref_stand:IsPurgable()
    return false
end

function modifier_polnaref_stand:OnCreated(keys)
    if not IsServer() then return end

    local abilka_hp = 0
    if self:GetParent():GetOwner():FindAbilityByName("polnaref_battle_exp") then
        abilka_hp = (self:GetParent():GetOwner():FindAbilityByName("polnaref_battle_exp"):GetSpecialValueFor("bonus_health") + self:GetParent():GetOwner():FindTalentValue("special_bonus_birzha_polnaref_3")) / 100
    end

    self.resist = 0
    self.b_health = ( self:GetAbility():GetSpecialValueFor("stand_hp") * self:GetCaster():GetLevel() ) + self:GetParent():GetOwner():GetMaxHealth() + (abilka_hp * self:GetParent():GetOwner():GetMaxHealth())
    self.b_damage = ( self:GetAbility():GetSpecialValueFor("stand_damage") * self:GetCaster():GetLevel() ) + self:GetParent():GetOwner():GetBaseDamageMax()
    self.b_armor = ( self:GetAbility():GetSpecialValueFor("stand_armor") * self:GetCaster():GetLevel() ) + self:GetParent():GetOwner():GetPhysicalArmorBaseValue()
    self.attack_speed = self:GetParent():GetOwner():GetAttackSpeed() * 100
    self.mana = self:GetParent():GetOwner():GetMaxMana()
    self:GetParent():SetMaxMana(self.mana)
    self:GetParent():SetMana(self.mana)
    if not self:GetCaster():HasModifier("modifier_item_echo_sabre") then
        self:SetStackCount(self.attack_speed)
    end
    self:GetParent():SetBaseDamageMin(self.b_damage)
    self:GetParent():SetBaseDamageMax(self.b_damage)
    self:GetParent():SetBaseMaxHealth(self.b_health)
    self:GetParent():SetMaxHealth(self.b_health)
    self:GetParent():SetHealth(self:GetParent():GetMaxHealth())
    self:GetParent():SetPhysicalArmorBaseValue(self.b_armor)
    self:GetCaster():RemoveModifierByName("modifier_item_echo_sabre")
    self:GetParent():FindAbilityByName("polnaref_rapier"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_stand"):GetLevel())
    self:GetParent():FindAbilityByName("polnaref_chariotarmor"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_battle_exp"):GetLevel())
    self:GetParent():FindAbilityByName("polnaref_shoot"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_ragess"):GetLevel())
    self:GetParent():FindAbilityByName("polnaref_afterimage"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_requeim"):GetLevel())

    self:GetParent():FindAbilityByName("polnaref_sleep"):SetLevel(0)
    self:GetParent():FindAbilityByName("polnaref_regeneration"):SetLevel(0)
    self:GetParent():FindAbilityByName("polnaref_return"):SetLevel(0)
    self:GetParent():FindAbilityByName("polnaref_darkheart"):SetLevel(0)

    if self:GetParent():GetOwner():HasTalent("special_bonus_birzha_polnaref_5") then
        self.resist = 100
    end

    self:StartIntervalThink(FrameTime())
end

function modifier_polnaref_stand:OnRefresh(keys)
    if not IsServer() then return end
    local abilka_hp = 0
    if self:GetParent():GetOwner():FindAbilityByName("polnaref_battle_exp") then
        abilka_hp = (self:GetParent():GetOwner():FindAbilityByName("polnaref_battle_exp"):GetSpecialValueFor("bonus_health") + self:GetParent():GetOwner():FindTalentValue("special_bonus_birzha_polnaref_3")) / 100
    end
    self.resist = 0
    self.b_health = ( self:GetAbility():GetSpecialValueFor("stand_hp") * self:GetCaster():GetLevel() ) + self:GetParent():GetOwner():GetMaxHealth() + (abilka_hp * self:GetParent():GetOwner():GetMaxHealth())
    self.b_damage = ( self:GetAbility():GetSpecialValueFor("stand_damage") * self:GetCaster():GetLevel() ) + self:GetParent():GetOwner():GetBaseDamageMax()
    self.b_armor = ( self:GetAbility():GetSpecialValueFor("stand_armor") * self:GetCaster():GetLevel() ) + self:GetParent():GetOwner():GetPhysicalArmorBaseValue()
    self.attack_speed = self:GetParent():GetOwner():GetAttackSpeed() * 100
    self.mana = self:GetParent():GetOwner():GetMaxMana()
    self:GetParent():SetMaxMana(self.mana)
    self:SetStackCount(self.attack_speed)
    self:GetCaster():RemoveModifierByName("modifier_item_echo_sabre")
    self:GetParent():SetBaseDamageMin(self.b_damage)
    self:GetParent():SetBaseDamageMax(self.b_damage)
    self:GetParent():SetBaseMaxHealth(self.b_health)
    self:GetParent():SetMaxHealth(self.b_health)
    self:GetParent():SetPhysicalArmorBaseValue(self.b_armor)

    self:GetParent():FindAbilityByName("polnaref_rapier"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_stand"):GetLevel())
    self:GetParent():FindAbilityByName("polnaref_shoot"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_battle_exp"):GetLevel())
    self:GetParent():FindAbilityByName("polnaref_silver_rage"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_ragess"):GetLevel())
    self:GetParent():FindAbilityByName("polnaref_afterimage"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_requeim"):GetLevel())

    if self:GetParent():GetOwner():HasTalent("special_bonus_birzha_polnaref_5") then
        self.resist = 100
    end  
end

function modifier_polnaref_stand:OnIntervalThink()
    if not IsServer() then return end
    self:OnRefresh()
    if self:GetCaster():HasModifier("modifier_polnaref_requeim") then self:GetParent():RemoveModifierByName("modifier_polnaref_disarm") return end
    local friends = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, 1300, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
    for _,target in pairs(friends) do
        if self:GetParent():GetOwner() == target then
            self:GetParent():RemoveModifierByName("modifier_polnaref_disarm")
            return
        end
    end
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), 'modifier_polnaref_disarm', {})
end

function modifier_polnaref_stand:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ORDER
    }

    return funcs
end