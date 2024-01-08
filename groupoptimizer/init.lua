-- EQFoli 2024-01-08
-- CWTN Group Optimizer

local mq = require('mq')

-- Scriber Write format purloined.
local Write = require('groupoptimizer.Write')

Write.prefix = 'Group Optimizer'
Write.loglevel = 'info'

local luaName = 'groupoptimizer'

BARD = 0
BEASTLORD = 0
BERSERKER = 0
CLERIC = 0
DRUID = 0
ENCHANTER = 0
MAGICIAN = 0
MONK = 0
NECROMANCER = 0
PALADIN = 0
RANGER = 0
ROGUE = 0
SHADOWKNIGHT = 0
SHAMAN = 0
WARRIOR = 0
WIZARD = 0

local groupClasses = {
    mq.TLO.Group.Member(0),
    mq.TLO.Group.Member(1),
    mq.TLO.Group.Member(2),
    mq.TLO.Group.Member(3),
    mq.TLO.Group.Member(4),
    mq.TLO.Group.Member(5)
}

local function checkClasses()
    for i,v in pairs(groupClasses) do
        if v.Class.ShortName() == "BRD" then
            BARD = 1
            BARDLEVEL = v.Level()
        end
        if v.Class.ShortName() == "BST" then
            BEASTLORD = 1
            BEASTLORDLEVEL = v.Level()
        end
        if v.Class.ShortName() == "BER" then
            BERSERKER = 1
            BERSERKERLEVEL = v.Level()
        end
        if v.Class.ShortName() == "CLR" then
            CLERIC = 1
            CLERICLEVEL = v.Level()
        end
        if v.Class.ShortName() == "DRU" then
            DRUID = 1
            DRUIDLEVEL = v.Level()
        end
        if v.Class.ShortName() == "ENC" then
            ENCHANTER = 1
            ENCHANTERLEVEL = v.Level()
        end
        if v.Class.ShortName() == "MAG" then
            MAGICIAN = 1
            MAGICIANLEVEL = v.Level()
        end
        if v.Class.ShortName() == "MNK" then
            MONK = 1
            MONKLEVEL = v.Level()
        end
        if v.Class.ShortName() == "NEC" then
            NECROMANCER = 1
            NECROMANCERLEVEL = v.Level()
        end
        if v.Class.ShortName() == "PAL" then
            PALADIN = 1
            PALADINLEVEL = v.Level()
        end
        if v.Class.ShortName() == "RNG" then
            RANGER = 1
            RANGERLEVEL = v.Level()
        end
        if v.Class.ShortName() == "ROG" then
            ROGUE = 1
            ROGUELEVEL = v.Level()
        end
        if v.Class.ShortName() == "SHD" then
            SHADOWKNIGHT = 1
            SHADOWKNIGHTLEVEL = v.Level()
        end
        if v.Class.ShortName() == "SHM" then
            SHAMAN = 1
            SHAMANLEVEL = v.Level()
        end
        if v.Class.ShortName() == "WAR" then
            WARRIOR = 1
            WARRIORLEVEL = v.Level()
        end
        if v.Class.ShortName() == "WIZ" then
            WIZARD = 1
            WIZARDLEVEL = v.Level()
        end
    end
end


local function optimizeCWTNGroup()
    Write.Info('\a-gOptimizing group.')
    -- Slow. Prioritize SHM.
    if SHAMAN == 1 and ENCHANTER == 1 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm useslow on nosave')
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc useslow off nosave')
        Write.Info('\awSLOW: \a-gSlow activated on SHM. Slow deactivated on ENC.')
    elseif SHAMAN == 1 and ENCHANTER == 0 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm useslow on nosave')
        Write.Info('\awSLOW: \a-gNo ENC. Slow activated on SHM.')
    elseif SHAMAN == 0 and ENCHANTER == 1 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc useslow on nosave')
        Write.Info('\awSLOW: \a-gNo SHM. Slow activated on ENC.')
    else
        Write.Info('\awSLOW: \a-gNo ENC nor SHM in group.')
    end
    -- DS. Prioritize MAG.
    if MAGICIAN == 1 and DRUID == 1 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag useds on nosave')
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru use off nosave')
        Write.Info('\awDS: \a-gDS activated on MAG. DS deactivated on DRU.')
    elseif MAGICIAN == 1 and DRUID == 0 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag useds on nosave')
        Write.Info('\awDS: \a-gNo DRU. DS activated on MAG.')
    elseif MAGICIAN == 0 and DRUID == 1 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru useds on nosave')
        Write.Info('\awDS: \a-gNo MAG. DS activated on DRU.')
    else
        Write.Info('\awDS: \a-gNo MAG nor DRU in group.')
    end
    -- Growth. Prioritize SHM. Deactivates if Knight in group..
    if SHAMAN == 1 and DRUID == 1 and SHADOWKNIGHT == 0 and PALADIN == 0 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usegrowth on nosave')
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru usegrowth off nosave')
        Write.Info('\awGROWTH: \a-gGrowth activated on SHM. Growth deactivated on DRU.')
    elseif SHAMAN == 1 and DRUID == 0 and SHADOWKNIGHT == 0 and PALADIN == 0 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usegrowth on nosave')
        Write.Info('\awGROWTH: \a-gNo DRU. Growth activated on SHM.')
    elseif SHAMAN == 0 and DRUID == 1 and SHADOWKNIGHT == 0 and PALADIN == 0 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru usegrowth on nosave')
        Write.Info('\awGROWTH: \a-gNo SHM. Growth activated on DRU.')
    elseif SHAMAN == 1 and DRUID == 0 and SHADOWKNIGHT == 1 or PALADIN == 1 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usegrowth off nosave')
        Write.Info('\awGROWTH: \a-gKnight tank. Growth deactivated.')
    elseif SHAMAN == 0 and DRUID == 1 and SHADOWKNIGHT == 1 or PALADIN == 1 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru usegrowth off nosave')
        Write.Info('\awGROWTH: \a-gKnight in group. Growth deactivated.')
    else
        Write.Info('\awGROWTH: \a-gNo SHM nor DRU in group.')
    end
    -- Malo. Prioritize MAG.
    if SHAMAN == 1 and MAGICIAN == 1 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usemalo off nosave')
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usemaloaoe off nosave')
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag usemalo on nosave')
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag usemaloaoe on nosave')
        Write.Info('\awMALO: \a-gMalo/Malo AOE activated on MAG. Malo/Malo AOE deactivated on SHM.')
    elseif SHAMAN == 1 and MAGICIAN == 0 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usemalo on nosave')
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usemaloaoe on nosave')
        Write.Info('\awMALO: \a-gNo MAG. Malo/Malo AOE activated on SHM.')
    elseif SHAMAN == 0 and MAGICIAN == 1 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag usemalo on nosave')
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag usemaloaoe on nosave')
        Write.Info('\awMALO: \a-gNo SHM. Malo/Malo AOE activated on MAG.')
    else
        Write.Info('\awMALO: \a-gNo MAG nor SHM in group.')
    end    
end


local function main()
    checkClasses()
    optimizeCWTNGroup()
end


main()