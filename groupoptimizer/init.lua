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
    mq.TLO.Group.Member(0).Class.ShortName(),
    mq.TLO.Group.Member(1).Class.ShortName(),
    mq.TLO.Group.Member(2).Class.ShortName(),
    mq.TLO.Group.Member(3).Class.ShortName(),
    mq.TLO.Group.Member(4).Class.ShortName(),
    mq.TLO.Group.Member(5).Class.ShortName()
}

local function checkClasses()
    for i,v in pairs(groupClasses) do
        if v == "BRD" then
            BARD = 1
        end
        if v == "BST" then
            BEASTLORD = 1
        end
        if v == "BER" then
            BERSERKER = 1
        end
        if v == "CLR" then
            CLERIC = 1
        end
        if v == "DRU" then
            DRUID = 1
        end
        if v == "ENC" then
            ENCHANTER = 1
        end
        if v == "MAG" then
            MAGICIAN = 1
        end
        if v == "MNK" then
            MONK = 1
        end
        if v == "NEC" then
            NECROMANCER = 1
        end
        if v == "PAL" then
            PALADIN = 1
        end
        if v == "RNG" then
            RANGER = 1
        end
        if v == "ROG" then
            ROGUE = 1
        end
        if v == "SHD" then
            SHADOWKNIGHT = 1
        end
        if v == "SHM" then
            SHAMAN = 1
        end
        if v == "WAR" then
            WARRIOR = 1
        end
        if v == "WIZ" then
            WIZARD = 1
        end
    end
end


local function optimizeCWTNGroup()
    Write.Info('\a-gOptimizing group.')
    -- Slow. Prioritize SHM.
    if SHAMAN == 1 and ENCHANTER == 1 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm useslow on')
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc useslow off')
        Write.Info('\awSLOW: \a-gSlow activated on SHM. Slow deactivated on ENC.')
    elseif SHAMAN == 1 and ENCHANTER == 0 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm useslow on')
        Write.Info('\awSLOW: \a-gNo ENC. Slow activated on SHM.')
    elseif SHAMAN == 0 and ENCHANTER == 1 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[ENC]}) /enc useslow on')
        Write.Info('\awSLOW: \a-gNo SHM. Slow activated on ENC.')
    else
        Write.Info('\awSLOW: \a-gNo ENC nor SHM in group.')
    end
    -- DS. Prioritize MAG.
    if MAGICIAN == 1 and DRUID == 1 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag useds on')
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru use off')
        Write.Info('\awDS: \a-gDS activated on MAG. DS deactivated on DRU.')
    elseif MAGICIAN == 1 and DRUID == 0 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag useds on')
        Write.Info('\awDS: \a-gNo DRU. DS activated on MAG.')
    elseif MAGICIAN == 0 and DRUID == 1 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru useds on')
        Write.Info('\awDS: \a-gNo MAG. DS activated on DRU.')
    else
        Write.Info('\awDS: \a-gNo MAG nor DRU in group.')
    end
    -- Growth. Prioritize SHM.
    if SHAMAN == 1 and DRUID == 1 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usegrowth on')
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru usegrowth off')
        Write.Info('\awGROWTH: \a-gGrowth activated on SHM. Growth deactivated on DRU.')
    elseif SHAMAN == 1 and DRUID == 0 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /mag usegrowth on')
        Write.Info('\awGROWTH: \a-gNo DRU. Growth activated on SHM.')
    elseif SHAMAN == 0 and DRUID == 1 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[DRU]}) /dru usegrowth on')
        Write.Info('\awGROWTH: \a-gNo SHM. Growth activated on DRU.')
    else
        Write.Info('\awGROWTH: \a-gNo SHM nor DRU in group.')
    end
    -- Malo. Prioritize MAG.
    if SHAMAN == 1 and MAGICIAN == 1 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usemalo off')
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usemaloaoe off')
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag usemalo on')
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag usemaloaoe on')
        Write.Info('\awMALO: \a-gMalo/Malo AOE activated on MAG. Malo/Malo AOE deactivated on SHM.')
    elseif SHAMAN == 1 and MAGICIAN == 0 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usemalo on')
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[SHM]}) /shm usemaloaoe on')
        Write.Info('\awMALO: \a-gNo MAG. Malo/Malo AOE activated on SHM.')
    elseif SHAMAN == 0 and MAGICIAN == 1 then
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag usemalo on')
        mq.cmd('/noparse /dgga /if (${Me.Class.ShortName.Equal[MAG]}) /mag usemaloaoe on')
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