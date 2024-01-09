-- CWTN Group Optimizer
-- Idea by: secret_wombat
-- Written in collaboration by: EQFoli and MrInfernal
-- Version: 0.8
-- Latest: Removed debuffs.
local mq = require('mq')

---@type ImGui
local imgui = require 'ImGui'

-- Scriber Write format purloined.
local Write = require('groupoptimizer.Write')

Write.prefix = 'Group Optimizer '
Write.loglevel = 'info'

local luaName = 'groupoptimizer'

-- Initial class variables
BEASTLORD = false
DRUID = false
ENCHANTER = false
MAGICIAN = false
NECROMANCER = false
RANGER = false
SHADOWKNIGHT = false
SHAMAN = false

-- Default priority.
DSCLASS = 'MAG'
GROWTHCLASS = 'SHM'
HASTECLASS = 'ENC'
REGENCLASS = 'SHM'
SLOWCLASS = 'SHM'
RESISTCLASS = 'SHM'
SNARECLASS = 'RNG'

-- Window variables. Defaults are none, but will update as classes are added
local boxDS = {'None'}
local boxDSIndex = 1
local boxGrowth = {'None'}
local boxGrowthIndex = 1
local boxHaste = {'None'}
local boxHasteIndex = 1
local boxRegen = {'None'}
local boxRegenIndex = 1
local boxResistDebuff = {'None'}
local boxResistDebuffIndex = 1
local boxSlow = {'None'}
local boxSlowIndex = 1
local boxSnare = {'None'}
local boxSnareIndex = 1

-- Function to assign which classes are available in the group.
local function checkClasses()
    -- Reset classes
    -- Make sure there is a group and then iterate through
    if mq.TLO.Group() then
        for i = 1, 6 do
            local member = mq.TLO.Group.Member(i - 1)
            local classShortName = member.Class.ShortName()

            if classShortName == "BST" and mq.TLO.Plugin('mq2bst').IsLoaded() then BEASTLORD = true end
            if classShortName == "DRU" and mq.TLO.Plugin('mq2druid').IsLoaded() then DRUID = true end
            if classShortName == "ENC" and mq.TLO.Plugin('mq2enchanter').IsLoaded() then ENCHANTER = true end
            if classShortName == "MAG" and mq.TLO.Plugin('mq2mage').IsLoaded() then MAGICIAN = true end
            if classShortName == "NEC" and mq.TLO.Plugin('mq2necro').IsLoaded() then NECROMANCER = true end
            if classShortName == "RNG" and mq.TLO.Plugin('mq2ranger').IsLoaded() then RANGER = true end
            if classShortName == "SHD" and mq.TLO.Plugin('mq2eskay').IsLoaded() then SHADOWKNIGHT = true end
            if classShortName == "SHM" and mq.TLO.Plugin('mq2shaman').IsLoaded() then SHAMAN = true end
        end
    else
        local classShortName = mq.TLO.Me.Class.ShortName()

        if classShortName == "BST" and mq.TLO.Plugin('mq2bst').IsLoaded() then BEASTLORD = true end
        if classShortName == "DRU" and mq.TLO.Plugin('mq2druid').IsLoaded() then DRUID = true end
        if classShortName == "ENC" and mq.TLO.Plugin('mq2enchanter').IsLoaded() then ENCHANTER = true end
        if classShortName == "MAG" and mq.TLO.Plugin('mq2mage').IsLoaded() then MAGICIAN = true end
        if classShortName == "NEC" and mq.TLO.Plugin('mq2necro').IsLoaded() then NECROMANCER = true end
        if classShortName == "RNG" and mq.TLO.Plugin('mq2ranger').IsLoaded() then RANGER = true end
        if classShortName == "SHD" and mq.TLO.Plugin('mq2eskay').IsLoaded() then SHADOWKNIGHT = true end
        if classShortName == "SHM" and mq.TLO.Plugin('mq2shaman').IsLoaded() then SHAMAN = true end
    end
end

local function checkGroup()
    -- Function to check whether priority classes are available from the getgo. If not, go down the list.
    -- DS
    if not MAGICIAN then
        DSCLASS = 'DRU'
    elseif not MAGICIAN and not DRUID then
        DSCLASS = 'None'
    end
    -- Growth
    if not SHAMAN then
        GROWTHCLASS = 'DRU'
    elseif not SHAMAN and not DRUID then
        GROWTHCLASS = 'None'
    end
    -- Haste
    if not ENCHANTER then
        HASTECLASS = 'SHM'
    elseif not ENCHANTER and not SHAMAN then
        HASTECLASS = 'None'
    end
    -- Regen
    if not SHAMAN then
        REGENCLASS = 'DRU'
    elseif not SHAMAN and not DRUID then
        REGENCLASS = 'None'
    end
    -- Slow
    if not SHAMAN then
        SLOWCLASS = 'ENC'
    elseif not SHAMAN and not ENCHANTER then
        SLOWCLASS = 'BST'
    elseif not SHAMAN and not ENCHANTER and not BEASTLORD then
        SLOWCLASS = 'None'
    end
    -- Resist
    if not SHAMAN then
        RESISTCLASS = 'MAG'
    elseif not SHAMAN and not MAGICIAN then
        RESISTCLASS = 'ENC'
    elseif not SHAMAN and not MAGICIAN and not ENCHANTER then
        RESISTCLASS = 'None'
    end
    -- Snare
    if not RANGER then
        SNARECLASS = 'DRU'
    elseif not RANGER and not DRUID then
        SNARECLASS = 'NEC'
    elseif not RANGER and not DRUID and not NECROMANCER then
        SNARECLASS = 'None'
    end
end


-- Functions to control buffs and debuffs.
------------BENEFICIAL
--DS
-- Mage->Druid
local function groupDS()
    if DSCLASS == 'Off' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag useds off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru useds off nosave')
        Write.Info('\awDS: \a-gDS turned OFF.')
    elseif (MAGICIAN and not DRUID) then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag useds on nosave')
        Write.Info('\awDS: \a-gDS activated on MAG.')

        boxDS = {'Off', 'Magician'}
        boxDSIndex = 2
    elseif (DRUID and MAGICIAN) and DSCLASS == 'MAG' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag useds on nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru useds off nosave')
        Write.Info('\awDS: \a-gDS activated on MAG. DS deactivated on DRU.')

        boxDS = {'Off', 'Magician', 'Druid'}
        boxDSIndex = 2
    elseif (DRUID and not MAGICIAN) then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru useds on nosave')
        Write.Info('\awDS: \a-gDS activated on DRU.')

        boxDS = {'Off', 'Druid'}
        boxDSIndex = 2
    elseif (DRUID and MAGICIAN) and DSCLASS == 'DRU' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag useds off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru useds on nosave')
        Write.Info('\awDS: \a-gDS activated on DRU. DS deactivated on MAG.')

        boxDS = {'Off', 'Magician', 'Druid'}
        boxDSIndex = 3
    elseif not DRUID and not MAGICIAN then
        Write.Info('\awDS: \a-gNo MAG nor DRU in group.')
    end
end

--Growth
-- Shaman->Druid
local function groupGrowth()
    if GROWTHCLASS == 'Off' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usegrowth off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru usegrowth off nosave')
        Write.Info('\awGROWTH: \a-gGrowth turned OFF.')
    elseif (SHAMAN and not DRUID) then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usegrowth on nosave')
        Write.Info('\awGROWTH: \a-gGrowth activated on SHM.')

        boxGrowth = {'Off', 'Shaman'}
        boxGrowthIndex = 2
    elseif (SHAMAN and DRUID) and GROWTHCLASS == 'SHM' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usegrowth on nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru usegrowth off nosave')
        Write.Info('\awGROWTH: \a-gGrowth activated on SHM. Growth deactivated on DRU.')

        boxGrowth = {'Off', 'Shaman', 'Druid'}
        boxGrowthIndex = 2
    elseif (not SHAMAN and DRUID) then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru usegrowth on nosave')
        Write.Info('\awGROWTH: \a-gGrowth activated on DRU.')

        boxGrowth = {'Off', 'Druid'}
        boxGrowthIndex = 2
    elseif SHAMAN and DRUID and GROWTHCLASS == 'DRU' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usegrowth off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru usegrowth on nosave')
        Write.Info('\awGROWTH: \a-gGrowth activated on DRU. Growth deactivated on SHM.')

        boxGrowth = {'Off', 'Shaman', 'Druid'}
        boxGrowthIndex = 3
    elseif not SHAMAN and not DRUID then
        Write.Info('\awGROWTH: \a-gNo SHM nor DRU in group.')
    end
end

--Haste
-- Enchanter->Shaman
local function groupHaste()
    checkClasses()
    if HASTECLASS == 'Off' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc usehaste off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usehaste off nosave')
        Write.Info('\awHASTE: \a-gHaste turned OFF.')
    elseif (ENCHANTER and not SHAMAN) then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc usehaste on nosave')
        Write.Info('\awHASTE: \a-gHaste activated on ENC.')

        boxHaste = {'Off', 'Enchanter'}
        boxHasteIndex = 2
    elseif ENCHANTER and SHAMAN and HASTECLASS == 'ENC' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc usehaste on nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usehaste off nosave')
        Write.Info('\awHASTE: \a-gHaste activated on ENC. Haste deactivated on SHM.')

        boxHaste = {'Off', 'Enchanter', 'Shaman'}
        boxHasteIndex = 2
    elseif (not ENCHANTER and SHAMAN) then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usehaste on nosave')
        Write.Info('\awHASTE: \a-gHaste activated on SHM.')

        boxHaste = {'Off', 'Shaman'}
        boxHasteIndex = 2
    elseif ENCHANTER and SHAMAN and HASTECLASS == 'SHM' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc usehaste off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usehaste on nosave')
        Write.Info('\awHASTE: \a-gHaste activated on SHM. Haste deactivated on ENC.')

        boxHaste = {'Off', 'Enchanter', 'Shaman'}
        boxHasteIndex = 3
    elseif not ENCHANTER and not SHAMAN then
        Write.Info('\awHASTE: \a-gNo ENC nor SHM in group.')
    end
end

--Regen
-- Shaman->Druid
local function groupRegen()
    checkClasses()
    if REGENCLASS == 'Off' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm useregen off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru useregen off nosave')
        Write.Info('\awREGEN: \a-gRegen turned OFF.')
    elseif (SHAMAN and not DRUID) then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm useregen on nosave')
        Write.Info('\awREGEN: \a-gRegen activated on SHM.')

        boxRegen = {'Off', 'Shaman'}
        boxRegenIndex = 2
    elseif SHAMAN and DRUID and REGENCLASS == 'SHM' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm useregen on nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru useregen off nosave')
        Write.Info('\awREGEN: \a-gRegen activated on SHM. Regen deactivated on DRU.')

        boxRegen = {'Off', 'Shaman', 'Druid'}
        boxRegenIndex = 2
    elseif (not SHAMAN and DRUID) then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru useregen on nosave')
        Write.Info('\awREGEN: \a-gRegen activated on DRU.')

        boxRegen = {'Off', 'Druid'}
        boxRegenIndex = 2
    elseif SHAMAN and DRUID and REGENCLASS == 'DRU' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm useregen off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru useregen on nosave')
        Write.Info('\awREGEN: \a-gRegen activated on DRU. Regen deactivated on SHM.')
        REGENCLASS = 'DRU'
        boxRegen = {'Off', 'Shaman', 'Druid'}
        boxRegenIndex = 3
    elseif not SHAMAN and not DRUID then
        Write.Info('\awREGEN: \a-gNo SHM nor DRU in group.')
    end
end
------------DETRIMENTAL

--Slow
-- Shaman->Enchanter->Beastlord
local function groupSlow()
    if SLOWCLASS == 'Off' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm useslow off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc useslow off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[BST]}) /bst slowall off nosave')
        Write.Info('\awSLOW: \a-gSlow turned OFF.')
    end
    if (SHAMAN and not ENCHANTER and not BEASTLORD) and SLOWCLASS == 'SHM' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm useslow on nosave')
        Write.Info('\awSLOW: \a-gSlow activated on SHM.')

        boxSlow = {'Off', 'Shaman'}
        boxSlowIndex = 2
    elseif (SHAMAN and ENCHANTER and not BEASTLORD) and SLOWCLASS == 'SHM' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm useslow on nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc useslow off nosave')
        Write.Info('\awSLOW: \a-gSlow activated on SHM. Slow deactivated on ENC.')

        boxSlow = {'Off', 'Shaman', 'Enchanter'}
        boxSlowIndex = 2
    elseif (SHAMAN and not ENCHANTER and BEASTLORD) and SLOWCLASS == 'SHM' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm useslow on nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[BST]}) /bst slowall off nosave')
        Write.Info('\awSLOW: \a-gSlow activated on SHM. Slow deactivated on BST.')

        boxSlow = {'Off', 'Shaman', 'Beastlord'}
        boxSlowIndex = 2
    elseif (SHAMAN and ENCHANTER and BEASTLORD) and SLOWCLASS =='SHM' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm useslow on nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc useslow off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[BST]}) /bst slowall off nosave')
        Write.Info('\awSLOW: \a-gSlow activated on SHM. Slow deactivated on ENC and BST.')

        boxSlow = {'Off', 'Shaman', 'Enchanter', 'Beastlord'}
        boxSlowIndex = 2
    elseif (not SHAMAN and ENCHANTER and not BEASTLORD) and SLOWCLASS == 'ENC' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc useslow on nosave')
        Write.Info('\awSLOW: \a-gSlow activated on ENC.')

        boxSlow = {'Off', 'Enchanter'}
        boxSlowIndex = 2
    elseif (SHAMAN and ENCHANTER and not BEASTLORD) and SLOWCLASS == 'ENC' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm useslow off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc useslow on nosave')
        Write.Info('\awSLOW: \a-gSlow activated on ENC. Slow deactivated on SHM.')

        boxSlow = {'Off', 'Shaman', 'Enchanter'}
        boxSlowIndex = 3
    elseif (not SHAMAN and ENCHANTER and BEASTLORD) and SLOWCLASS == 'ENC' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc useslow on nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[BST]}) /bst slowall off nosave')
        Write.Info('\awSLOW: \a-gSlow activated on ENC. Slow deactivated on BST.')

        boxSlow = {'Off', 'Enchanter', 'Beastlord'}
        boxSlowIndex = 2
    elseif (SHAMAN and ENCHANTER and BEASTLORD) and SLOWCLASS == 'ENC' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm useslow off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc useslow on nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[BST]}) /bst slowall off nosave')
        Write.Info('\awSLOW: \a-gSlow activated on ENC. Slow deactivated on SHM and BST.')

        boxSlow = {'Off', 'Shaman', 'Enchanter', 'Beastlord'}
        boxSlowIndex = 3
    elseif (not SHAMAN and not ENCHANTER and BEASTLORD) and SLOWCLASS == 'BST' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[BST]}) /bst slowall on nosave')
        Write.Info('\awSLOW: \a-gSlow activated on BST.')

        boxSlow = {'Off', 'Beastlord'}
        boxSlowIndex = 2
    elseif (SHAMAN and not ENCHANTER and BEASTLORD) and SLOWCLASS == 'BST' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm useslow off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[BST]}) /bst slowall on nosave')
        Write.Info('\awSLOW: \a-gSlow activated on BST. Slow deactivated on SHM.')

        boxSlow = {'Off', 'Shaman', 'Beastlord'}
        boxSlowIndex = 3
    elseif (not SHAMAN and ENCHANTER and BEASTLORD) and SLOWCLASS == 'BST' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /enc useslow off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[BST]}) /bst slowall on nosave')
        Write.Info('\awSLOW: \a-gSlow activated on BST. Slow deactivated on ENC.')

        boxSlow = {'Off', 'Enchanter', 'Beastlord'}
        boxSlowIndex = 3
    elseif (SHAMAN and ENCHANTER and BEASTLORD) and SLOWCLASS == 'BST' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm useslow off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc useslow off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[BST]}) /bst slowall on nosave')
        Write.Info('\awSLOW: \a-gSlow activated on BST. Slow deactivated on SHM and ENC.')

        boxSlow = {'Off', 'Shaman', 'Enchanter', 'Beastlord'}
        boxSlowIndex = 4
    elseif not SHAMAN and not ENCHANTER and not BEASTLORD then
        Write.Info('\awSLOW: \a-gNo SHM, ENC nor BST in group.')
    end
end

--Resist debuff
-- Shaman Malo, Mage Malo, Enchanter Tash
local function groupResistDebuff()
    if RESISTCLASS == 'Off' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usemalo off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc usetash off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag usemalo off nosave')
        Write.Info('\awRESIST DEBUFF: \a-gResist debuff turned OFF.')
    elseif (SHAMAN and not MAGICIAN and not ENCHANTER) then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usemalo on nosave')
        Write.Info('\awRESIST DEBUFF: \a-gMalo activated on SHM.')

        boxResistDebuff = {'Off', 'Shaman'}
        boxResistDebuffIndex = 2
    elseif (SHAMAN and MAGICIAN and not ENCHANTER) and RESISTCLASS == 'SHM' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usemalo on nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag usemalo off nosave')
        Write.Info('\awRESIST DEBUFF: \a-gMalo activated on SHM. Malo deactivated on MAG.')

        boxResistDebuff = {'Off', 'Shaman', 'Magician'}
        boxResistDebuffIndex = 2
    elseif (SHAMAN and not MAGICIAN and ENCHANTER) and RESISTCLASS == 'SHM' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usemalo on nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc usetash off nosave')
        Write.Info('\awRESIST DEBUFF: \a-gMalo activated on SHM. Tash deactivated on ENC.')

        boxResistDebuff = {'Off', 'Shaman', 'Enchanter'}
        boxResistDebuffIndex = 2
    elseif (SHAMAN and MAGICIAN and ENCHANTER) and RESISTCLASS =='SHM' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usemalo on nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc usetash off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag usemalo on nosave')
        Write.Info('\awRESIST DEBUFF: \a-gMalo activated on SHM. Tash deactivated on ENC. Malo deactivated on MAG.')

        boxResistDebuff = {'Off', 'Shaman', 'Magician', 'Enchanter'}
        boxResistDebuffIndex = 2
    elseif (not SHAMAN and MAGICIAN and not ENCHANTER) then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag usemalo on nosave')
        Write.Info('\awRESIST DEBUFF: \a-gMalo activated on MAG.')

        boxResistDebuff = {'Off', 'Magician'}
        boxResistDebuffIndex = 2
    elseif (SHAMAN and MAGICIAN and not ENCHANTER) and RESISTCLASS == 'MAG' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usemalo off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag usemalo on nosave')
        Write.Info('\awRESIST DEBUFF: \a-gMalo activated on MAG. Malo deactivated on SHM.')

        boxResistDebuff = {'Off', 'Shaman', 'Magician'}
        boxResistDebuffIndex = 3
    elseif (not SHAMAN and MAGICIAN and ENCHANTER) and RESISTCLASS == 'MAG' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc usetash off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag usemalo on nosave')
        Write.Info('\awRESIST DEBUFF: \a-gMalo activated on MAG. Tash deactivated on ENC.')

        boxResistDebuff = {'Off', 'Magician', 'Enchanter'}
        boxResistDebuffIndex = 2
    elseif (SHAMAN and MAGICIAN and ENCHANTER) and RESISTCLASS == 'MAG' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usemalo off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc usetash off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag usemalo on nosave')
        Write.Info('\awRESIST DEBUFF: \a-gMalo activated on MAG. Tash deactivated on ENC. Malo deactivated on SHM.')

        boxResistDebuff = {'Off', 'Shaman', 'Magician', 'Enchanter'}
        boxResistDebuffIndex = 3
    elseif (not SHAMAN and not MAGICIAN and ENCHANTER) then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc usetash on nosave')
        Write.Info('\awRESIST DEBUFF: \a-gTash activated on ENC.')

        boxResistDebuff = {'Off', 'Enchanter'}
        boxResistDebuffIndex = 2
    elseif (SHAMAN and not MAGICIAN and ENCHANTER) and RESISTCLASS == 'ENC' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usemalo off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc usetash on nosave')
        Write.Info('\awRESIST DEBUFF: \a-gTash activated on ENC. Malo deactivated on SHM.')

        boxResistDebuff = {'Off', 'Shaman', 'Enchanter'}
        boxResistDebuffIndex = 3
    elseif (not SHAMAN and MAGICIAN and ENCHANTER) and RESISTCLASS == 'ENC' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag usemalo off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc usetash on nosave')
        Write.Info('\awRESIST DEBUFF: \a-gTash activated on ENC. Malo deactivated on MAG.')

        boxResistDebuff = {'Off', 'Magician', 'Enchanter'}
        boxResistDebuffIndex = 3
    elseif (SHAMAN and MAGICIAN and ENCHANTER) and RESISTCLASS == 'ENC' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usemalo off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc usetash on nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag usemalo off nosave')
        Write.Info('\awRESIST DEBUFF: \a-gTash activated on ENC. Malo deactivated on SHM. Malo deactivated on MAG.')

        boxResistDebuff = {'Off', 'Shaman', 'Magician', 'Enchanter'}
        boxResistDebuffIndex = 4
    elseif not SHAMAN and not MAGICIAN and not ENCHANTER then
        Write.Info('\awRESIST DEBUFF: \a-gNo SHM, MAG nor ENC in group.')
    end
end

--Snare
-- Ranger->Druid->Necro->SK
local function groupSnare()
    if SNARECLASS == 'Off' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[RNG]}) /rng useentrap off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru useaasnare off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[NEC]}) /nec useaasnare off nosave')
        Write.Info('\awSNARE: \a-gSnare turned OFF.')
    elseif RANGER and not DRUID and not NECROMANCER then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[RNG]}) /rng useentrap on nosave')
        Write.Info('\awSNARE: \a-gSnare activated on RNG.')

        boxSnare = {'Off', 'Ranger'}
        boxSnareIndex = 2
    elseif (RANGER and DRUID and not NECROMANCER) and SNARECLASS == 'RNG' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[RNG]}) /rng useentrap on nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru useaasnare off nosave')
        Write.Info('\awSNARE: \a-gSnare activated on RNG. Snare deactivated on DRU.')

        boxSnare = {'Off', 'Ranger', 'Druid'}
        boxSnareIndex = 2
    elseif (RANGER and not DRUID and NECROMANCER) and SNARECLASS == 'RNG' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[RNG]}) /rng useentrap on nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[NEC]}) /nec useaasnare off nosave')
        Write.Info('\awSNARE: \a-gSnare activated on RNG. Snare deactivated on NEC.')

        boxSnare = {'Off', 'Ranger', 'Druid'}
        boxSnareIndex = 2
    elseif RANGER and DRUID and NECROMANCER and SNARECLASS =='RNG' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[RNG]}) /rng useentrap on nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[NEC]}) /nec useaasnare off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru useaasnare off nosave')
        Write.Info('\awSNARE: \a-gSnare activated on RNG. Snare deactivated on DRU. Snare deactivated on NEC.')

        boxSnare = {'Off', 'Ranger', 'Druid', 'Necromancer'}
        boxSnareIndex = 2
    elseif not RANGER and DRUID and not NECROMANCER then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru useaasnare on nosave')
        Write.Info('\awSNARE: \a-gSnare activated on DRU.')

        boxSnare = {'Off', 'Druid'}
        boxSnareIndex = 2
    elseif (RANGER and DRUID and not NECROMANCER) and SNARECLASS == 'DRU' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[RNG]}) /rng useentrap off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru useaasnare on nosave')
        Write.Info('\awSNARE: \a-gSnare activated on DRU. Snare deactivated on RNG.')

        boxSnare = {'Off', 'Ranger', 'Druid'}
        boxSnareIndex = 3
    elseif (not RANGER and DRUID and NECROMANCER) and SNARECLASS == 'DRU' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru useaasnare on nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[NEC]}) /nec useaasnare off nosave')
        Write.Info('\awSNARE: \a-gSnare activated on DRU. Snare deactivated on NEC.')

        boxSnare = {'Off', 'Druid', 'Necromancer'}
        boxSnareIndex = 2
    elseif RANGER and DRUID and NECROMANCER and SNARECLASS == 'DRU' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[RNG]}) /rng useentrap off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[NEC]}) /nec useaasnare off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru useaasnare on nosave')
        Write.Info('\awSNARE: \a-gSnare activated on DRU. Snare deactivated on RNG. Snare deactivated on NEC.')

        boxSnare = {'Off', 'Ranger', 'Druid', 'Necromancer'}
        boxSnareIndex = 3
    elseif (not RANGER and not DRUID and NECROMANCER) then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[NEC]}) /nec useaasnare on nosave')
        Write.Info('\awSNARE: \a-gSnare activated on NEC.')

        boxSnare = {'Off', 'Necromancer'}
        boxSnareIndex = 2
    elseif (RANGER and not DRUID and NECROMANCER) and SNARECLASS == 'NEC' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[NEC]}) /nec useaasnare on nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[RNG]}) /rng useentrap off nosave')
        Write.Info('\awSNARE: \a-gSnare activated on NEC. Snare deactivated on RNG.')

        boxSnare = {'Off', 'Ranger', 'Necromancer'}
        boxSnareIndex = 3
    elseif (not RANGER and DRUID and NECROMANCER) and SNARECLASS == 'NEC' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[NEC]}) /nec useaasnare on nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru useaasnare off nosave')
        Write.Info('\awSNARE: \a-gSnare activated on NEC. Snare deactivated on DRU.')

        boxSnare = {'Off', 'Druid', 'Necromancer'}
        boxSnareIndex = 3
    elseif RANGER and DRUID and NECROMANCER and SNARECLASS == 'NEC' then
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[RNG]}) /rng useentrap off nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[NEC]}) /nec useaasnare on nosave')
        mq.cmd('/noparse /squelch /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru useaasnare off nosave')
        Write.Info('\awSNARE: \a-gSnare activated on NEC. Snare deactivated on RNG. Snare deactivated on DRU.')

        boxSnare = {'Off', 'Ranger', 'Druid', 'Necromancer'}
        boxSnareIndex = 4
    elseif not RANGER and not DRUID and not NECROMANCER then
        Write.Info('\awSNARE: \a-gNo RNG, DRU nor NEC in group.')
    end
end

checkClasses()
checkGroup()
groupDS()
groupGrowth()
groupHaste()
groupRegen()
--groupResistDebuff()
--groupSlow()
--groupSnare()

-- function to run the window
function groupOptimizer(open)
    -- Specify a default position/size in case there's no data in the .ini file.
    local main_viewport = imgui.GetMainViewport()
    imgui.SetNextWindowPos(main_viewport.WorkPos.x + 650, main_viewport.WorkPos.y + 20, ImGuiCond.FirstUseEver)

    -- Change the window size
    imgui.SetNextWindowSize(600, 300, ImGuiCond.FirstUseEver)

    local show = false
    open, show = imgui.Begin("Group Optimizer", open)

    if not show then
        ImGui.End()
        return open
    end

    ImGui.PushItemWidth(ImGui.GetFontSize() * -12);

    -- Main window element area --

    -- Beginning of window elements
    if imgui.Button('Refresh/Reset') then
        BEASTLORD = false
        DRUID = false
        ENCHANTER = false
        MAGICIAN = false
        NECROMANCER = false
        RANGER = false
        SHADOWKNIGHT = false
        SHAMAN = false
        checkClasses()
        checkGroup()
        groupDS()
        groupGrowth()
        groupHaste()
        groupRegen()
        groupResistDebuff()
        groupSlow()
        groupSnare()
    end

    imgui.Text('\n')

    -- Damage Shields
    if not MAGICIAN and not DRUID then
        imgui.BeginDisabled()
    end
    imgui.Text('Use DS')
    imgui.SameLine(130)
    local lastBoxDSIndex = boxDSIndex
    boxDSIndex = imgui.Combo(' ', boxDSIndex, boxDS, #boxDS)

    if boxDSIndex ~= lastBoxDSIndex then
        if boxDSIndex == 3 then
            DSCLASS = 'DRU'
        elseif boxDSIndex == 2 then
            DSCLASS = 'MAG'
        elseif boxDSIndex == 1 then
            DSCLASS = 'Off'
        end
        groupDS()
    end
    if not MAGICIAN and not DRUID then
        imgui.EndDisabled()
    end
    imgui.SameLine(310)
    imgui.HelpMarker('Damage Shields \nPriority: Magician -> Druid')

    -- Haste
    if not SHAMAN and not ENCHANTER then
        imgui.BeginDisabled()
    end
    imgui.Text('Use Haste')
    imgui.SameLine(130)
    local lastBoxHasteIndex = boxHasteIndex
    boxHasteIndex = imgui.Combo('  ', boxHasteIndex, boxHaste, #boxHaste)

    if boxHasteIndex ~= lastBoxHasteIndex then
        lastBoxHasteIndex = boxHasteIndex

        if boxHasteIndex == 3 then
            HASTECLASS = 'SHM'
        elseif boxHasteIndex == 2 then
            HASTECLASS = 'ENC'
        elseif boxHasteIndex == 1 then
            HASTECLASS = 'Off'
        end
        groupHaste()
    end
    if not SHAMAN and not ENCHANTER then
        imgui.EndDisabled()
    end
    imgui.SameLine(310)
    imgui.HelpMarker('Haste \nPriority: Enchanter -> Shaman')

    -- Regen
    if not SHAMAN and not DRUID then
        imgui.BeginDisabled()
    end
    imgui.Text('Use Regen')
    imgui.SameLine(130)
    local lastBoxRegenIndex = boxRegenIndex
    boxRegenIndex = imgui.Combo('   ', boxRegenIndex, boxRegen, #boxRegen)

    if boxRegenIndex ~= lastBoxRegenIndex then
        lastBoxRegenIndex = boxRegenIndex

        if boxRegenIndex == 3 then
            REGENCLASS = 'DRU'
        elseif boxRegenIndex == 2 then
            REGENCLASS = 'SHM'
        elseif boxRegenIndex == 1 then
            REGENCLASS = 'Off'
        end
        groupRegen()
    end
    if not SHAMAN and not DRUID then
        imgui.EndDisabled()
    end
    imgui.SameLine(310)
    imgui.HelpMarker('Regeneration \nPriority: Shaman -> Druid')

    -- Slow
    -- if not SHAMAN and not ENCHANTER and not BEASTLORD then
    --     imgui.BeginDisabled()
    -- end
    -- imgui.Text('Use Slow')
    -- imgui.SameLine(130)
    -- local lastBoxSlowIndex = boxSlowIndex
    -- boxSlowIndex = imgui.Combo('    ', boxSlowIndex, boxSlow, #boxSlow)

    -- if boxSlowIndex ~= lastBoxSlowIndex then
    --     lastBoxSlowIndex = boxSlowIndex

    --     if boxSlowIndex == 4 then
    --         SLOWCLASS = 'BST'
    --     elseif boxSlowIndex == 3 then
    --         SLOWCLASS = 'ENC'
    --     elseif boxSlowIndex == 2 then
    --         SLOWCLASS = 'SHM'
    --     elseif boxSlowIndex == 1 then
    --         SLOWCLASS = 'Off'
    --     end
    --     groupSlow()
    -- end
    -- if not SHAMAN and not ENCHANTER and not BEASTLORD then
    --     imgui.EndDisabled()
    -- end
    -- imgui.SameLine(310)
    -- imgui.HelpMarker('Slow Spells \nPriority: Shaman -> Enchanter -> Beastlord')

    -- Resist Debuffs
    -- if not MAGICIAN and not SHAMAN and not ENCHANTER then
    --     imgui.BeginDisabled()
    -- end
    -- imgui.Text('Use Resist Debuff')
    -- imgui.SameLine(130)
    -- local lastBoxResistDebuffIndex = boxResistDebuffIndex
    -- boxResistDebuffIndex = imgui.Combo('     ', boxResistDebuffIndex, boxResistDebuff, #boxResistDebuff)

    -- if boxResistDebuffIndex ~= lastBoxResistDebuffIndex then
    --     lastBoxResistDebuffIndex = boxResistDebuffIndex

    --     if boxResistDebuffIndex == 4 then
    --         RESISTCLASS = 'ENC'
    --     elseif boxResistDebuffIndex == 3 then
    --         RESISTCLASS = 'MAG'
    --     elseif boxResistDebuffIndex == 2 then
    --         RESISTCLASS = 'SHM'
    --     elseif boxResistDebuffIndex == 1 then
    --         RESISTCLASS = 'Off'
    --     end
    --     groupResistDebuff()
    -- end
    -- if not MAGICIAN and not SHAMAN and not ENCHANTER then
    --     imgui.EndDisabled()
    -- end
    -- imgui.SameLine(310)
    -- imgui.HelpMarker('Malo/Tash Spells \nPriority: Shaman -> Magician -> Enchanter')

    -- Growth line
    if not SHAMAN and not DRUID then
        imgui.BeginDisabled()
    end
    imgui.Text('Use Growth')
    imgui.SameLine(130)
    local lastBoxGrowthIndex = boxGrowthIndex
    boxGrowthIndex = imgui.Combo('      ', boxGrowthIndex, boxGrowth, #boxGrowth)

    if boxGrowthIndex ~= lastBoxGrowthIndex then
        lastBoxGrowthIndex = boxGrowthIndex

        if boxGrowthIndex == 3 then
            GROWTHCLASS = 'DRU'
        elseif boxGrowthIndex == 2 then
            GROWTHCLASS = 'SHM'
        elseif boxGrowthIndex == 1 then
            GROWTHCLASS = 'Off'
        end
        groupGrowth()
    end
    if not SHAMAN and not DRUID then
        imgui.EndDisabled()
    end
    imgui.SameLine(310)
    imgui.HelpMarker('Growth Line \n Priority: Shaman -> Druid')

    -- Snares
    -- if not RANGER and not NECROMANCER and not DRUID then
    --     imgui.BeginDisabled()
    -- end
    -- imgui.Text('Use Snare')
    -- imgui.SameLine(130)
    -- local lastBoxSnareIndex = boxSnareIndex
    -- boxSnareIndex = imgui.Combo('       ', boxSnareIndex, boxSnare, #boxSnare)

    -- if boxSnareIndex ~= lastBoxSnareIndex then
    --     lastBoxSnareIndex = boxSnareIndex

    --     if boxSnareIndex == 4 then
    --         SNARECLASS = 'NEC'
    --     elseif boxSnareIndex == 3 then
    --         SNARECLASS = 'DRU'
    --     elseif boxSnareIndex == 2 then
    --         SNARECLASS = 'RNG'
    --     elseif boxSnareIndex == 1 then
    --         SNARECLASS = 'Off'
    --     end
    --     groupSnare()
    -- end
    -- if not RANGER and not NECROMANCER and not DRUID then
    --     imgui.EndDisabled()
    -- end
    -- imgui.SameLine(310)
    -- imgui.HelpMarker('Snare Spells \n Priority: Ranger -> Druid -> Necromancer')
    -- End of main window element area --

    -- Required for window elements
    imgui.Spacing()
    imgui.PopItemWidth()
    imgui.End()
    return open
end

local openGUI = true

ImGui.Register('Group Optimizer', function()
    openGUI = groupOptimizer(openGUI)
end)

while openGUI do
    mq.delay(1000) -- equivalent to '1s'
end