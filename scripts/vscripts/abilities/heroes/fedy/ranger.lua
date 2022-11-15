LinkLuaModifier("modifier_Bullet_BulletInTheHead", "abilities/heroes/fedy/ranger", LUA_MODIFIER_MOTION_NONE)

Bullet_BulletInTheHead = class({})

function Bullet_BulletInTheHead:GetBehavior()
    local caster = self:GetCaster()
    --local scepter = caster:HasShard()

    if scepter then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
    else
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    end
end

function Bullet_BulletInTheHead:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Bullet_BulletInTheHead:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Bullet_BulletInTheHead:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

--[[function Bullet_BulletInTheHead:GetAOERadius()
    local caster = self:GetCaster()
    local ability = self
    --local scepter = caster:HasShard()
    local scepter_radius = ability:GetSpecialValueFor("scepter_radius")

    if scepter then
        return scepter_radius
    end

    return 0
end]]--

function Bullet_BulletInTheHead:OnAbilityPhaseInterrupted()
    local caster = self:GetCaster()
    local ability = self

    caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
    caster:FadeGesture(ACT_DOTA_CAST_ABILITY_4)

    local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        FIND_UNITS_EVERYWHERE,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD,
        FIND_ANY_ORDER,
        false)

    for _,enemy in pairs(enemies) do
        if enemy:HasModifier("modifier_Bullet_BulletInTheHead") then
            enemy:RemoveModifierByName("modifier_Bullet_BulletInTheHead")
        end
    end
end

function Bullet_BulletInTheHead:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    local ability = self
    --local scepter = caster:HasShard()
    local radius = ability:GetSpecialValueFor("scepter_radius")
    caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)

    if not scepter then
        self.target = self:GetCursorTarget()
        self.target:AddNewModifier(caster, ability, "modifier_Bullet_BulletInTheHead", {duration = 4})
    else
        self.target_point = self:GetCursorPosition()
        self.targets = FindUnitsInRadius(caster:GetTeamNumber(),
            self.target_point,
            nil,
            radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            FIND_ANY_ORDER,
            false)

        for _,target in pairs(self.targets) do
            target:AddNewModifier(caster, ability, "modifier_Bullet_BulletInTheHead", {duration = 4})
        end
    end

    return true
end

function Bullet_BulletInTheHead:OnSpellStart()
    local caster = self:GetCaster()
    --local scepter = caster:HasShard()
    caster:EmitSound("Ability.Assassinate")

    if not scepter then
        local info = {
            Target = self.target,
            Source = caster,
            Ability = self, 
            bVisibleToEnemies = true,
            bReplaceExisting = false,
            bProvidesVision = false,
            EffectName = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf",
            iMoveSpeed = 2500,
            bDodgeable = true,
            ExtraData = { modifier = "modifier_Bullet_BulletInTheHead" }
        }

        ProjectileManager:CreateTrackingProjectile(info)
        self.target:EmitSound("Hero_Sniper.AssassinateProjectile")
    else
        for _,target in pairs(self.targets) do
            local info = {
                Target = target,
                Source = caster,
                Ability = self, 
                bVisibleToEnemies = true,
                bReplaceExisting = false,
                bProvidesVision = false,
                EffectName = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf",
                iMoveSpeed = 2500,
                bDodgeable = true,
                ExtraData = { modifier = "modifier_Bullet_BulletInTheHead" }
            }

            ProjectileManager:CreateTrackingProjectile(info)
            target:EmitSound("Hero_Sniper.AssassinateProjectile")
        end
    end
end

function Bullet_BulletInTheHead:OnProjectileHit_ExtraData( target, location, extradata )
    if (not target) or target:IsInvulnerable() or target:IsOutOfGame() or target:TriggerSpellAbsorb( self ) then
        if target:HasModifier("modifier_Bullet_BulletInTheHead") then
            target:RemoveModifierByName("modifier_Bullet_BulletInTheHead")
        end
        return
    end
    --local scepter = self:GetCaster():HasScepter()
    local damage_b = self:GetSpecialValueFor("damage_b")
    local damage_e = self:GetSpecialValueFor("damage_e")
    local chance = self:GetSpecialValueFor("chance")
    local random = RandomInt(1, 100)
    x = 1
    b = 2

    if random <= chance then
    	x = 2000 --[[Returns:int
    	Get a random ''int'' within a range
    	]]
    	b = 3000
    end
    local modifier_damage = RandomInt(damage_b+x, damage_e+b)
    if not scepter then
        if not target:IsMagicImmune() then
            local damageTable = {victim = target,
                attacker = self:GetCaster(),
                damage = modifier_damage,
                damage_type = DAMAGE_TYPE_PURE,
                ability = self
            }
            ApplyDamage(damageTable)
        end
    else
        local hptargetfull = target:GetMaxHealth() / 100 * 50 
        local hptarget = target:GetHealth()
        if  hptarget < hptargetfull then
            local damageTable = {victim = target,
                attacker = self:GetCaster(),
                damage = modifier_damage,
                damage_type = DAMAGE_TYPE_PURE,
                damage_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                ability = self
            }

            ApplyDamage(damageTable)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, target, damage, nil)
        end
        if  hptarget > hptargetfull then
            local damageTable = {victim = target,
                attacker = self:GetCaster(),
                damage = modifier_damage,
                damage_type = DAMAGE_TYPE_PURE,
                damage_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                ability = self
            }
            ApplyDamage(damageTable)
        end
    end

    target:EmitSound("Hero_Sniper.AssassinateDamage")
    target:Interrupt()
    if target:HasModifier("modifier_Bullet_BulletInTheHead") then
        target:RemoveModifierByName("modifier_Bullet_BulletInTheHead")
    end
end

modifier_Bullet_BulletInTheHead = class({})

function modifier_Bullet_BulletInTheHead:IsPurgable()
    return false
end

function modifier_Bullet_BulletInTheHead:OnCreated( kv )
    if IsServer() then
        local particle = ParticleManager:CreateParticleForTeam( "particles/units/heroes/hero_sniper/sniper_crosshair.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetCaster():GetTeamNumber() )
        self:AddParticle(particle, false, false, -1, false, true )
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_Bullet_BulletInTheHead:OnIntervalThink( kv )
    if IsServer() then
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_truesight", {duration = FrameTime()+FrameTime()})
        AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 50, FrameTime()+FrameTime(), false)
    end
end