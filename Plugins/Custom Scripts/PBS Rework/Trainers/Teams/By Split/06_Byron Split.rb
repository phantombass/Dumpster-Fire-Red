#===================================#
#           Veilstone City          #
#===================================#
PB_Trainers.register(:TEAMGALACTIC_M,"Grunt",{
:Veilstone => {
:lose_text => "Ugh.",
:pokemon=> [
{:species => :BRONZONG,
:ability => :LEVITATE,
:nature => :SASSY,
:level => 65,
:moves => [:GYROBALL,:ZENHEADBUTT,:REFLECT,:LIGHTSCREEN],
:iv => {:SPEED => 0},
:item => :IAPAPABERRY
},
{:species => :SALAZZLE,
:ability => :CORROSION,
:nature => :TIMID,
:level => 65,
:moves => [:SLUDGEBOMB,:HEATWAVE,:HPGRASS,:FAKEOUT],
:item => :FIREGEM
},
{:species => :CACTURNE,
:ability => :WATERABSORB,
:nature => :ADAMANT,
:level => 66,
:moves => [:SPIKYSHIELD,:NEEDLEARM,:KNOCKOFF,:SUCKERPUNCH],
:item => :FOCUSSASH
}]}})

PB_Trainers.register(:TEAMGALACTIC_F,"Grunt",{
:Veilstone => {
:lose_text => "Ugh.",
:pokemon=> [
{:species => :POLIWRATH,
:ability => :WATERABSORB,
:nature => :ADAMANT,
:level => 65,
:moves => [:HYPNOSIS,:SURGINGSTRIKES,:CLOSECOMBAT,:JETPUNCH],
:item => :LIFEORB
},
{:species => :FLYGON,
:ability => :LEVITATE,
:nature => :JOLLY,
:level => 65,
:moves => [:BREAKINGSWIPE,:HIGHHORSEPOWER,:DRAGONCLAW,:FIREPUNCH],
:item => :YACHEBERRY
},
{:species => :FLORGES,
:ability => :ADAPTABILITY,
:nature => :MODEST,
:level => 66,
:moves => [:DAZZLINGGLEAM,:PSYCHIC,:CALMMIND,:HPGROUND],
:item => :LEFTOVERS
}]}})

PB_Trainers.register(:RIVAL2,"Dawn",{
:Tag_Partner_2 => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :MAMOSWINE,
:ability => :THICKFAT,
:nature => :ADAMANT,
:level => 65,
:moves => [:ICICLECRASH,:ROCKSLIDE,:HIGHHORSEPOWER,:ICESHARD],
:item => :FOCUSSASH
},
{:species => :CLEFABLE,
:ability => :MAGICGUARD,
:nature => :MODEST,
:level => 66,
:moves => [:DAZZLINGGLEAM,:FLAMETHROWER,:PSYCHIC,:HELPINGHAND],
:item => :LIFEORB
},
{:species => :EMPOLEON,
:ability_index => 2,
:nature => :TIMID,
:level => 67,
:moves => [:SCALD,:POLARITYPULSE,:ICEBEAM,:AIRSLASH],
:item => :EMPOLEONITE
}]}})
#===================================#
#            Route 210 (M)          #
#===================================#
PB_Trainers.register(:NINJABOY,"Fabian",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :GRENINJA,
:ability => :PROTEAN,
:nature => :NAIVE,
:level => 66,
:moves => [:TOXICSPIKES,:SCALD,:DARKPULSE,:UTURN],
:item => :FOCUSSASH
},
{:species => :WHIMSICOTT,
:ability => :PRANKSTER,
:nature => :TIMID,
:level => 66,
:moves => [:ENERGYBALL,:MOONBLAST,:ENCORE,:TAILWIND],
:item => :KEBIABERRY
},
{:species => :ROTOM,
:form => 1,
:ability => :LEVITATE,
:nature => :TIMID,
:level => 66,
:moves => [:THUNDERBOLT,:HEATWAVE,:HPGRASS,:NASTYPLOT],
:item => :PASSHOBERRY
},
{:species => :TOXICROAK,
:ability => :DRYSKIN,
:nature => :JOLLY,
:level => 66,
:moves => [:GUNKSHOT,:CLOSECOMBAT,:SUCKERPUNCH,:THUNDERPUNCH],
:item => :LIFEORB
}]}})

PB_Trainers.register(:NINJABOY,"Brennan",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :MIENSHAO,
:ability => :REGENERATOR,
:nature => :JOLLY,
:level => 66,
:moves => [:FAKEOUT,:CLOSECOMBAT,:KNOCKOFF,:UTURN],
:item => :ASSAULTVEST
},
{:species => :MUK,
:form => 1,
:ability => :POISONTOUCH,
:nature => :ADAMANT,
:level => 66,
:moves => [:GUNKSHOT,:KNOCKOFF,:PURSUIT,:EXPLOSION],
:item => :DARKGEM
},
{:species => :ARCHEOPS,
:ability => :DEFEATIST,
:nature => :JOLLY,
:level => 67,
:moves => [:STONEEDGE,:ACROBATICS,:EARTHQUAKE,:QUICKATTACK],
:item => :FLYINGGEM
},
{:species => :SAMUROTT,
:ability => :SHARPNESS,
:nature => :NAIVE,
:level => 67,
:moves => [:AQUACUTTER,:FLASHCANNON,:AIRSLASH,:AQUAJET],
:item => :LUMBERRY
}]}})

PB_Trainers.register(:NINJABOY,"Joel",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :NINJASK,
:ability => :INFILTRATOR,
:nature => :ADAMANT,
:level => 66,
:moves => [:UTURN],
:item => :CHOICEBAND
},
{:species => :GOLEM,
:ability => :STURDY,
:nature => :ADAMANT,
:level => 67,
:moves => [:STEALTHROCK,:EXPLOSION,:EARTHQUAKE,:STONEEDGE],
:item => :CUSTAPBERRY
},
{:species => :QUAQUAVAL,
:ability => :MOXIE,
:nature => :JOLLY,
:level => 66,
:moves => [:AQUASTEP,:CLOSECOMBAT,:ICESPINNER,:AQUAJET],
:item => :LUMBERRY
},
{:species => :TOXTRICITY,
:ability => :PUNKROCK,
:nature => :TIMID,
:level => 67,
:moves => [:OVERDRIVE,:SLUDGEWAVE,:HPGRASS,:SUBSTITUTE],
:item => :THROATSPRAY
},
{:species => :GRIMMSNARL,
:ability => :PRANKSTER,
:nature => :MODEST,
:level => 67,
:moves => [:NASTYPLOT,:FOCUSBLAST,:DARKPULSE,:MOONBLAST],
:item => :KEBIABERRY
}]}})
#===================================#
#            Route 210 (N)          #
#===================================#
PB_Trainers.register(:COOLTRAINER_F,"Alyssa",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :DUDUNSPARCE,
:ability => :RATTLED,
:nature => :ADAMANT,
:level => 67,
:moves => [:STEALTHROCK,:HYPERDRILL,:EARTHQUAKE,:ROOST],
:item => :LEFTOVERS
},
{:species => :SLOWBRO,
:form => 1,
:ability => :QUICKDRAW,
:nature => :MODEST,
:level => 66,
:moves => [:SHELLSIDEARM,:PSYCHIC,:FIREBLAST,:SLACKOFF],
:item => :QUICKCLAW
},
{:species => :FROSLASS,
:ability => :ADAPTABILITY,
:nature => :TIMID,
:level => 66,
:moves => [:SHADOWBALL,:ICEBEAM,:THUNDERBOLT,:WILLOWISP],
:item => :GHOSTGEM
},
{:species => :HOUNDOOM,
:ability => :FLASHFIRE,
:nature => :TIMID,
:level => 67,
:moves => [:DARKPULSE,:FLAMETHROWER,:DESTINYBOND,:HPGRASS],
:item => :CHOPLEBERRY
},
{:species => :COPPERAJAH,
:ability => :SHEERFORCE,
:nature => :ADAMANT,
:level => 67,
:moves => [:IRONHEAD,:ROCKSLIDE,:PLAYROUGH,:EARTHQUAKE],
:item => :LIFEORB
}]}})

PB_Trainers.register(:COOLTRAINER_M,"Ernest",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :TENTACRUEL,
:ability => :LIQUIDOOZE,
:nature => :TIMID,
:level => 67,
:moves => [:TOXICSPIKES,:HYDROPUMP,:SLUDGEBOMB,:SHADOWBALL],
:item => :BLACKSLUDGE
},
{:species => :KROOKODILE,
:ability => :INTIMIDATE,
:nature => :JOLLY,
:level => 67,
:moves => [:EARTHQUAKE,:KNOCKOFF,:STONEEDGE,:FIREFANG],
:item => :YACHEBERRY
},
{:species => :LEAVANNY,
:ability => :SHARPNESS,
:nature => :JOLLY,
:level => 67,
:moves => [:LEAFBLADE,:XSCISSOR,:SACREDSWORD,:SWORDSDANCE],
:item => :BRIGHTPOWDER
},
{:species => :GOLEM,
:form => 1,
:ability => :GALVANIZE,
:nature => :ADAMANT,
:level => 66,
:moves => [:STONEEDGE,:RETURN,:EARTHQUAKE,:EXPLOSION],
:item => :FOCUSSASH
},
{:species => :BRAVIARY,
:form => 1,
:ability => :TINTEDLENS,
:nature => :MODEST,
:level => 68,
:moves => [:ESPERWING,:HURRICANE,:HEATWAVE,:FOCUSBLAST],
:item => :LEFTOVERS
}]}})

PB_Trainers.register(:DOUBLETEAM,"Zac & Jen",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :RILLABOOM,
:ability => :GRASSYSURGE,
:nature => :JOLLY,
:level => 68,
:moves => [:FAKEOUT,:GRASSYGLIDE,:HIGHHORSEPOWER,:DRAINPUNCH],
:item => :GRASSGEM
},
{:species => :SNEASLER,
:ability => :UNBURDEN,
:nature => :ADAMANT,
:level => 68,
:moves => [:DIRECLAW,:CLOSECOMBAT,:ROCKSLIDE,:ACROBATICS],
:item => :GRASSYSEED
},
{:species => :INCINEROAR,
:ability => :INTIMIDATE,
:nature => :ADAMANT,
:level => 68,
:moves => [:FAKEOUT,:FLAREBLITZ,:DARKESTLARIAT,:LEECHLIFE],
:item => :ASSAULTVEST
},
{:species => :CLAWITZER,
:ability => :MEGALAUNCHER,
:nature => :MODEST,
:level => 68,
:moves => [:WATERPULSE,:AURASPHERE,:TERRAINPULSE,:DARKPULSE],
:item => :LIFEORB
}]}})

PB_Trainers.register(:BIRDKEEPER_F,"Brianna",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :KILOWATTREL,
:ability => :VOLTABSORB,
:nature => :TIMID,
:level => 67,
:moves => [:THUNDERBOLT,:HURRICANE,:HPGRASS,:UTURN],
:item => :CHARTIBERRY
},
{:species => :ESPATHRA,
:ability => :SPEEDBOOST,
:nature => :MODEST,
:level => 67,
:moves => [:LUMINACRASH,:DAZZLINGGLEAM,:HPFIRE,:CALMMIND],
:item => :LEFTOVERS
},
{:species => :DECIDUEYE,
:ability => :ADAPTABILITY,
:nature => :JOLLY,
:level => 68,
:moves => [:LEAFBLADE,:SPIRITSHACKLE,:THOUSANDARROWS,:SHADOWSNEAK],
:item => :LIFEORB
},
{:species => :SIRFETCHD,
:ability => :SCRAPPY,
:nature => :ADAMANT,
:level => 68,
:moves => [:FIRSTIMPRESSION,:CLOSECOMBAT,:KNOCKOFF,:BRAVEBIRD],
:item => :LEEK
}]}})

PB_Trainers.register(:NINJABOY,"Nathan",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :GLISCOR,
:ability => :POISONHEAL,
:nature => :JOLLY,
:level => 67,
:moves => [:PROTECT,:DUALWINGBEAT,:EARTHQUAKE,:FACADE],
:item => :TOXICORB
},
{:species => :SLOWKING,
:form => 1,
:ability => :REGENERATOR,
:nature => :MODEST,
:level => 68,
:moves => [:SCALD,:PSYCHIC,:SLUDGEBOMB,:FIREBLAST],
:item => :BLACKSLUDGE
},
{:species => :ABSOL,
:ability => :SHARPNESS,
:nature => :JOLLY,
:level => 68,
:moves => [:NIGHTSLASH,:CUT,:BRICKBREAK,:SWORDSDANCE],
:item => :LIFEORB
},
{:species => :TYPHLOSION,
:form => 1,
:ability => :FLASHFIRE,
:nature => :TIMID,
:level => 68,
:moves => [:SHADOWBALL,:ERUPTION,:FLAMETHROWER,:HPGRASS],
:item => :AIRBALLOON
}]}})

PB_Trainers.register(:DRAGONTAMER,"Patrick",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :DRAGALGE,
:ability => :ADAPTABILITY,
:nature => :MODEST,
:level => 68,
:moves => [:SLUDGEBOMB,:DRACOMETEOR,:SCALD,:TOXICSPIKES],
:item => :EJECTPACK
},
{:species => :HYDREIGON,
:ability => :LEVITATE,
:nature => :TIMID,
:level => 68,
:moves => [:DRAGONPULSE,:DARKPULSE,:FIREBLAST,:ROOST],
:item => :ROSELIBERRY
},
{:species => :TATSUGIRI,
:ability => :STORMDRAIN,
:nature => :TIMID,
:level => 68,
:moves => [:DRAGONPULSE,:SCALD,:ICEBEAM,:NASTYPLOT],
:item => :LEFTOVERS
},
{:species => :DURALUDON,
:ability => :MEGALAUNCHER,
:nature => :TIMID,
:level => 68,
:moves => [:DRAGONPULSE,:FLASHCANNON,:DARKPULSE,:THUNDERBOLT],
:item => :EVIOLITE
}]}})

PB_Trainers.register(:NINJABOY,"Davido",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :LOKIX,
:ability => :TINTEDLENS,
:nature => :JOLLY,
:level => 67,
:moves => [:FIRSTIMPRESSION,:KNOCKOFF,:AXEKICK,:UTURN],
:item => :BUGGEM
},
{:species => :COALOSSAL,
:ability => :STEAMENGINE,
:nature => :ADAMANT,
:level => 68,
:moves => [:HEATCRASH,:STONEEDGE,:EARTHQUAKE,:HEAVYSLAM],
:item => :PASSHOBERRY
},
{:species => :SANDACONDA,
:ability => :SHEDSKIN,
:nature => :JOLLY,
:level => 68,
:moves => [:EARTHQUAKE,:STONEEDGE,:GLARE,:SKITTERSMACK],
:item => :LEFTOVERS
},
{:species => :KINGDRA,
:ability => :SNIPER,
:nature => :TIMID,
:level => 67,
:moves => [:SNIPESHOT,:DRACOMETEOR,:FOCUSENERGY,:ICEBEAM],
:item => :SCOPELENS
}]}})

PB_Trainers.register(:BLACKBELT,"Adam",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :PINCURCHIN,
:ability => :ELECTRICSURGE,
:nature => :QUIET,
:level => 68,
:moves => [:RISINGVOLTAGE,:SCALD,:SPIKES,:SELFDESTRUCT],
:item => :CUSTAPBERRY
},
{:species => :HAWLUCHA,
:ability => :UNBURDEN,
:nature => :ADAMANT,
:level => 68,
:moves => [:ACROBATICS,:CLOSECOMBAT,:THROATCHOP,:SWORDSDANCE],
:item => :ELECTRICSEED
},
{:species => :SCEPTILE,
:ability => :UNBURDEN,
:nature => :MILD,
:level => 68,
:moves => [:ENERGYBALL,:DRAGONPULSE,:THUNDERPUNCH,:WORKUP],
:item => :ELECTRICSEED
},
{:species => :PAWMOT,
:ability => :VOLTABSORB,
:nature => :JOLLY,
:level => 68,
:moves => [:PLASMAFISTS,:CLOSECOMBAT,:ICEPUNCH,:MACHPUNCH],
:item => :ASSAULTVEST
}]}})

PB_Trainers.register(:VETERANM,"Brian",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :OVERQWIL,
:ability => :INTIMIDATE,
:nature => :JOLLY,
:level => 68,
:moves => [:TOXICSPIKES,:GUNKSHOT,:CRUNCH,:FLIPTURN],
:item => :BLACKSLUDGE
},
{:species => :GALLADE,
:ability => :SHARPNESS,
:nature => :JOLLY,
:level => 68,
:moves => [:SACREDSWORD,:PSYCHOCUT,:LEAFBLADE,:SHADOWSNEAK],
:item => :LIFEORB
},
{:species => :CHARIZARD,
:ability => :BLAZE,
:nature => :TIMID,
:level => 68,
:moves => [:FIREBLAST,:AIRSLASH,:EARTHPOWER,:HPGRASS],
:item => :CHARTIBERRY
},
{:species => :SWAMPERT,
:ability => :RESURGENCE,
:nature => :ADAMANT,
:level => 68,
:moves => [:EARTHQUAKE,:LIQUIDATION,:AVALANCHE,:FLIPTURN],
:item => :RINDOBERRY
},
{:species => :BRAMBLEGHAST,
:ability => :WINDRIDER,
:nature => :JOLLY,
:level => 69,
:moves => [:POWERWHIP,:SPIRITSHACKLE,:HIGHHORSEPOWER,:SHADOWSNEAK],
:item => :COBABERRY
}]}})
#===================================#
#            Celestic Town          #
#===================================#
PB_Trainers.register(:GALACTICBOSS,"Cyrus",{
:Celestic => {
:lose_text => "Ugh.",
:pokemon=> [
{:species => :GYARADOS,
:ability => :INTIMIDATE,
:nature => :JOLLY,
:level => 68,
:moves => [:WATERFALL,:EARTHQUAKE,:THUNDERWAVE,:BOUNCE],
:item => :WACANBERRY
},
{:species => :ZOROARK,
:form => 1,
:ability => :ILLUSION,
:nature => :TIMID,
:level => 69,
:moves => [:HYPERVOICE,:SHADOWBALL,:FLAMETHROWER,:MACHPULSE],
:item => :THROATSPRAY
},
{:species => :ARCANINE,
:form => 1,
:ability => :ROCKHEAD,
:nature => :JOLLY,
:level => 68,
:moves => [:FLAREBLITZ,:HEADSMASH,:WILDCHARGE,:EXTREMESPEED],
:item => :AIRBALLOON
},
{:species => :ELECTRODE,
:form => 1,
:ability => :SOUNDPROOF,
:nature => :MODEST,
:level => 69,
:moves => [:THUNDERBOLT,:CHLOROBLAST,:HPICE,:EXPLOSION],
:item => :LIFEORB
},
{:species => :URSALUNA,
:ability => :GUTS,
:nature => :ADAMANT,
:level => 69,
:moves => [:PROTECT,:FACADE,:EARTHQUAKE,:PLAYROUGH],
:item => :FLAMEORB
},
{:species => :WEAVILE,
:ability => :INNERFOCUS,
:nature => :JOLLY,
:level => 70,
:moves => [:ICICLECRASH,:THROATCHOP,:PSYCHOCUT,:BRICKBREAK],
:item => :FOCUSSASH
}]}})
#===================================#
#             Route 218             #
#===================================#
PB_Trainers.register(:WORKER,"Tony",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :ELECTRODE,
:ability => :STATIC,
:nature => :MILD,
:level => 68,
:moves => [:OVERDRIVE,:THUNDERWAVE,:HPICE,:EXPLOSION],
:item => :AIRBALLOON
},
{:species => :ORTHWORM,
:ability => :EARTHEATER,
:nature => :CAREFUL,
:level => 69,
:moves => [:IRONHEAD,:ROCKSLIDE,:TOXIC,:SHEDTAIL],
:item => :SITRUSBERRY
},
{:species => :HELIOLISK,
:ability => :DRYSKIN,
:nature => :TIMID,
:level => 69,
:moves => [:PARABOLICCHARGE,:HYPERVOICE,:SURF,:GRASSKNOT],
:item => :THROATSPRAY
},
{:species => :ROTOM,
:form => 5,
:ability => :LEVITATE,
:nature => :TIMID,
:level => 68,
:moves => [:LEAFSTORM,:NASTYPLOT,:THUNDERBOLT,:HEX],
:item => :LEFTOVERS
}]}})

PB_Trainers.register(:SAILOR,"Skyler",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :PELIPPER,
:ability => :DRIZZLE,
:nature => :MODEST,
:level => 68,
:moves => [:HURRICANE,:WEATHERBALL,:ICEBEAM,:UTURN],
:item => :WACANBERRY
},
{:species => :DHELMISE,
:ability => :STEELWORKER,
:nature => :ADAMANT,
:level => 69,
:moves => [:POWERWHIP,:SHADOWCLAW,:EARTHQUAKE,:ANCHORSHOT],
:item => :ASSAULTVEST
},
{:species => :GOODRA,
:ability => :HYDRATION,
:nature => :TIMID,
:level => 68,
:moves => [:THUNDER,:DRAGONPULSE,:SCALD,:REST],
:item => :LIFEORB
},
{:species => :MACHAMP,
:ability => :GUTS,
:nature => :ADAMANT,
:level => 69,
:moves => [:PROTECT,:FACADE,:CLOSECOMBAT,:KNOCKOFF],
:item => :FLAMEORB
}]}})

PB_Trainers.register(:FISHERMAN,"Luc",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :LANTURN,
:ability => :VOLTABSORB,
:nature => :MODEST,
:level => 68,
:moves => [:THUNDERBOLT,:SCALD,:ICEBEAM,:VOLTSWITCH],
:item => :ASSAULTVEST
},
{:species => :DUGTRIO,
:form => 1,
:ability => :TANGLINGHAIR,
:nature => :JOLLY,
:level => 68,
:moves => [:EARTHQUAKE,:IRONHEAD,:STONEEDGE,:SUCKERPUNCH],
:item => :LIFEORB
},
{:species => :TROPIUS,
:ability => :HARVEST,
:nature => :ADAMANT,
:level => 69,
:moves => [:WOODHAMMER,:DUALWINGBEAT,:EARTHQUAKE,:DRAGONDANCE],
:item => :SITRUSBERRY
},
{:species => :SAMUROTT,
:form => 1,
:ability => :SHARPNESS,
:nature => :JOLLY,
:level => 69,
:moves => [:RAZORSHELL,:SACREDSWORD,:CEASELESSEDGE,:AQUAJET],
:item => :LUMBERRY
}]}})
#===================================#
#           Canalave City           #
#===================================#
PB_Trainers.register(:RIVAL1,"Barry",{
:Canalave_Turtwig => {
:lose_text => "Ugh.",
:pokemon=> [
{:species => :STARAPTOR,
:ability => :RECKLESS,
:nature => :JOLLY,
:level => 69,
:moves => [:DOUBLEEDGE,:BRAVEBIRD,:CLOSECOMBAT,:UTURN],
:item => :CHOICEBAND
},
{:species => :SPIRITOMB,
:ability => :INTIMIDATE,
:nature => :RELAXED,
:level => 70,
:moves => [:FOULPLAY,:WILLOWISP,:PURSUIT,:HEX],
:item => :LEFTOVERS
},
{:species => :RAGINGBOLT,
:ability => :PROTOSYNTHESIS,
:nature => :MODEST,
:level => 69,
:moves => [:THUNDERCLAP,:DRAGONPULSE,:FLAMETHROWER,:SCALD],
:item => :BOOSTERENERGY
},
{:species => :INTELEON,
:ability => :SNIPER,
:nature => :TIMID,
:level => 69,
:moves => [:SNIPESHOT,:ICEBEAM,:SIGNALBEAM,:FOCUSENERGY],
:item => :LIFEORB
},
{:species => :RHYPERIOR,
:ability => :SOLIDROCK,
:nature => :ADAMANT,
:level => 70,
:moves => [:STONEEDGE,:EARTHQUAKE,:HAMMERARM,:HEATCRASH],
:item => :RINDOBERRY
},
{:species => :INFERNAPE,
:nature => :JOLLY,
:level => 71,
:moves => [:CLOSECOMBAT,:FLAREBLITZ,:THUNDERPUNCH,:MACHPUNCH],
:item => :INFERNITE
}]}})

PB_Trainers.register(:RIVAL1,"Barry",{
:Canalave_Chimchar => {
:lose_text => "Ugh.",
:pokemon=> [
{:species => :STARAPTOR,
:ability => :RECKLESS,
:nature => :JOLLY,
:level => 69,
:moves => [:DOUBLEEDGE,:BRAVEBIRD,:CLOSECOMBAT,:UTURN],
:item => :CHOICEBAND
},
{:species => :MIMIKYU,
:ability => :DISGUISE,
:nature => :JOLLY,
:level => 70,
:moves => [:SHADOWCLAW,:PLAYROUGH,:DRAINPUNCH,:SWORDSDANCE],
:item => :REDCARD
},
{:species => :GOUGINGFIRE,
:ability => :PROTOSYNTHESIS,
:nature => :ADAMANT,
:level => 69,
:moves => [:FLAREBLITZ,:DRAGONCLAW,:EARTHQUAKE,:DRAGONDANCE],
:item => :BOOSTERENERGY
},
{:species => :DECIDUEYE,
:form => 1,
:ability => :ADAPTABILITY,
:nature => :JOLLY,
:level => 69,
:moves => [:LEAFBLADE,:TRIPLEARROWS,:THOUSANDARROWS,:SUCKERPUNCH],
:item => :LIFEORB
},
{:species => :RHYPERIOR,
:ability => :SOLIDROCK,
:nature => :ADAMANT,
:level => 70,
:moves => [:STONEEDGE,:EARTHQUAKE,:HAMMERARM,:HEATCRASH],
:item => :RINDOBERRY
},
{:species => :EMPOLEON,
:ability_index => 2,
:nature => :TIMID,
:level => 71,
:moves => [:HYDROPUMP,:POLARITYPULSE,:AIRSLASH,:CALMMIND],
:item => :EMPOLEONITE
}]}})

PB_Trainers.register(:RIVAL1,"Barry",{
:Canalave_Piplup => {
:lose_text => "Ugh.",
:pokemon=> [
{:species => :STARAPTOR,
:ability => :RECKLESS,
:nature => :JOLLY,
:level => 69,
:moves => [:DOUBLEEDGE,:BRAVEBIRD,:CLOSECOMBAT,:UTURN],
:item => :CHOICEBAND
},
{:species => :GHOLDENGO,
:ability => :GOODASGOLD,
:nature => :TIMID,
:level => 70,
:moves => [:SHADOWBALL,:MAKEITRAIN,:FOCUSBLAST,:RECOVER],
:item => :AIRBALLOON
},
{:species => :WALKINGWAKE,
:ability => :PROTOSYNTHESIS,
:nature => :TIMID,
:level => 69,
:moves => [:HYDROSTEAM,:FLAMETHROWER,:DRAGONPULSE,:ICEBEAM],
:item => :BOOSTERENERGY
},
{:species => :BLAZIKEN,
:ability => :SPEEDBOOST,
:nature => :JOLLY,
:level => 69,
:moves => [:FLAREBLITZ,:THUNDERPUNCH,:CLOSECOMBAT,:PROTECT],
:item => :FOCUSSASH
},
{:species => :RHYPERIOR,
:ability => :SOLIDROCK,
:nature => :ADAMANT,
:level => 70,
:moves => [:STONEEDGE,:EARTHQUAKE,:HAMMERARM,:HEATCRASH],
:item => :RINDOBERRY
},
{:species => :TORTERRA,
:nature => :ADAMANT,
:level => 71,
:moves => [:WOODHAMMER,:EARTHQUAKE,:STONEEDGE,:SHELLSMASH],
:item => :TORTERRANITE
}]}})
#===================================#
#            Iron Island            #
#===================================#
PB_Trainers.register(:POKEMONTRAINER_Riley,"Riley",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :PALAFIN,
:ability => :ZEROTOHERO,
:nature => :JOLLY,
:level => 69,
:moves => [:JETPUNCH,:DRAINPUNCH,:ICEPUNCH,:FLIPTURN],
:item => :MYSTICWATER
},
{:species => :RAMPARDOS,
:ability => :SHEERFORCE,
:nature => :ADAMANT,
:level => 70,
:moves => [:ROCKSLIDE,:FIREPUNCH,:ZENHEADBUTT,:ROCKPOLISH],
:item => :LIFEORB
},
{:species => :HAXORUS,
:ability => :HYPERCUTTER,
:nature => :JOLLY,
:level => 70,
:moves => [:DRAGONCLAW,:EARTHQUAKE,:FIRSTIMPRESSION,:POISONJAB],
:item => :FOCUSSASH
},
{:species => :URSALUNA,
:ability => :GUTS,
:nature => :ADAMANT,
:level => 70,
:moves => [:PROTECT,:FACADE,:EARTHQUAKE,:CRUNCH],
:item => :FLAMEORB
},
{:species => :DARMANITAN,
:form => 2,
:ability => :GORILLATACTICS,
:nature => :ADAMANT,
:level => 70,
:moves => [:ICICLECRASH,:UTURN],
:item => :CHOICEBAND
},
{:species => :LUCARIO,
:ability_index => 1,
:nature => :JOLLY,
:level => 71,
:moves => [:METEORMASH,:CLOSECOMBAT,:ZENHEADBUTT,:SWORDSDANCE],
:item => :LUCARIONITE
}]}})

PB_Trainers.register(:POKEMONTRAINER_Riley,"Riley",{
:Tag_Partner => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :PALAFIN,
:ability => :ZEROTOHERO,
:nature => :JOLLY,
:level => 69,
:moves => [:JETPUNCH,:DRAINPUNCH,:ICEPUNCH,:FLIPTURN],
:item => :MYSTICWATER
},
{:species => :HAXORUS,
:ability => :HYPERCUTTER,
:nature => :JOLLY,
:level => 70,
:moves => [:DRAGONCLAW,:EARTHQUAKE,:FIRSTIMPRESSION,:POISONJAB],
:item => :FOCUSSASH
},
{:species => :LUCARIO,
:ability_index => 1,
:nature => :JOLLY,
:level => 71,
:moves => [:METEORMASH,:CLOSECOMBAT,:ZENHEADBUTT,:SWORDSDANCE],
:item => :LUCARIONITE
}]}})

PB_Trainers.register(:HIKER,"Kendal",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :CRADILY,
:ability => :STORMDRAIN,
:nature => :MODEST,
:level => 68,
:moves => [:POWERGEM,:GIGADRAIN,:TOXIC,:PROTECT],
:item => :LEFTOVERS
},
{:species => :AERODACTYL,
:ability => :UNNERVE,
:nature => :ADAMANT,
:level => 69,
:moves => [:DUALWINGBEAT,:ROCKSLIDE,:IRONHEAD,:HONECLAWS],
:item => :LIFEORB
}]}})

PB_Trainers.register(:WORKER,"Willy",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :ELECTIVIRE,
:ability => :MOTORDRIVE,
:nature => :JOLLY,
:level => 68,
:moves => [:PLASMAFISTS,:ICEPUNCH,:MACHPUNCH,:ROCKSLIDE],
:item => :AIRBALLOON
},
{:species => :MAGMORTAR,
:ability => :FLAMEBODY,
:nature => :HASTY,
:level => 69,
:moves => [:HEATWAVE,:PSYCHIC,:THUNDERBOLT,:MACHPUNCH],
:item => :FIREGEM
}]}})

PB_Trainers.register(:HIKER,"Damon",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :DRUDDIGON,
:ability => :SHEERFORCE,
:nature => :ADAMANT,
:level => 69,
:moves => [:DRAGONCLAW,:ROCKSLIDE,:FIREPUNCH,:IRONHEAD],
:item => :CHOPLEBERRY
},
{:species => :SIGILYPH,
:ability => :MAGICGUARD,
:nature => :TIMID,
:level => 69,
:moves => [:TAILWIND,:PSYCHIC,:HEATWAVE,:AIRSLASH],
:item => :LIFEORB
}]}})

PB_Trainers.register(:HIKER,"Maurice",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :DELPHOX,
:ability => :MAGICGUARD,
:nature => :TIMID,
:level => 69,
:moves => [:HEATWAVE,:PSYCHIC,:DAZZLINGGLEAM,:GRASSKNOT],
:item => :LIFEORB
},
{:species => :LAPRAS,
:ability => :WATERABSORB,
:nature => :MODEST,
:level => 69,
:moves => [:HYDROPUMP,:BLIZZARD,:THUNDERBOLT,:PSYCHIC],
:item => :LEFTOVERS
}]}})

PB_Trainers.register(:WORKER,"Braden",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :KLINKLANG,
:ability => :CLEARBODY,
:nature => :JOLLY,
:level => 69,
:moves => [:GEARGRIND,:WILDCHARGE,:RETURN,:SHIFTGEAR],
:item => :AIRBALLOON
},
{:species => :MEDICHAM,
:ability => :PUREPOWER,
:nature => :TIMID,
:level => 69,
:moves => [:AURASPHERE,:PSYCHIC,:SHADOWBALL,:DREAMEATER],
:item => :LEFTOVERS
}]}})

PB_Trainers.register(:WORKER,"Quentin",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :NOIVERN,
:ability => :PUNKROCK,
:nature => :TIMID,
:level => 69,
:moves => [:CLANGINGSCALES,:AIRCANNON,:HEATWAVE,:HYPNOSIS],
:item => :YACHEBERRY
},
{:species => :AVALUGG,
:form => 1,
:ability => :STURDY,
:nature => :ADAMANT,
:level => 69,
:moves => [:MOUNTAINGALE,:ROCKSLIDE,:BODYPRESS,:PSYCHICFANGS],
:item => :CUSTAPBERRY
}]}})

PB_Trainers.register(:POKEMONTRAINER_Buck,"Buck",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :CLAYDOL,
:ability => :LEVITATE,
:nature => :SASSY,
:level => 69,
:moves => [:REFLECT,:LIGHTSCREEN,:PSYCHIC,:EARTHPOWER],
:item => :LIGHTCLAY
},
{:species => :KOMMOO,
:ability => :SOUNDPROOF,
:nature => :TIMID,
:level => 70,
:moves => [:CLANGINGSCALES,:AURASPHERE,:FLASHCANNON,:CLANGOROUSSOUL],
:item => :THROATSPRAY
},
{:species => :AGGRON,
:nature => :ADAMANT,
:level => 71,
:moves => [:HEAVYSLAM,:BODYPRESS,:HIGHHORSEPOWER,:ROCKSLIDE],
:item => :AGGRONITE
}]}})

PB_Trainers.register(:POKEMONTRAINER_Marley,"Marley",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :ARCANINE,
:ability => :INTIMIDATE,
:nature => :JOLLY,
:level => 69,
:moves => [:FLAREBLITZ,:CLOSECOMBAT,:WILDCHARGE,:EXTREMESPEED],
:item => :FIREGEM
},
{:species => :ELECTRODE,
:form => 1,
:ability => :SOUNDPROOF,
:nature => :MODEST,
:level => 70,
:moves => [:OVERDRIVE,:ENERGYBALL,:HYPERVOICE,:MACHPULSE],
:item => :THROATSPRAY
},
{:species => :AERODACTYL,
:nature => :ADAMANT,
:level => 71,
:moves => [:ROCKSLIDE,:IRONHEAD,:DUALWINGBEAT,:HONECLAWS],
:item => :AERODACTYLITE
}]}})
#===================================#
#            Canalave Gym           #
#===================================#
PB_Trainers.register(:BLACKBELT,"Ricky",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :TYRANITAR,
:ability => :SANDSTREAM,
:nature => :ADAMANT,
:level => 70,
:moves => [:STEALTHROCK,:KNOCKOFF,:PURSUIT,:STONEEDGE],
:item => :CHOPLEBERRY
},
{:species => :EXCADRILL,
:ability => :SANDRUSH,
:nature => :ADAMANT,
:level => 70,
:moves => [:EARTHQUAKE,:IRONHEAD,:ROCKSLIDE,:SWORDSDANCE],
:item => :FOCUSSASH
},
{:species => :DRACOVISH,
:ability => :SANDRUSH,
:nature => :ADAMANT,
:level => 70,
:moves => [:FISHIOUSREND],
:item => :CHOICEBAND
},
{:species => :TAUROS,
:form => 2,
:ability => :INTIMIDATE,
:nature => :JOLLY,
:level => 70,
:moves => [:CLOSECOMBAT,:RAGINGBULL,:THROATCHOP,:BULKUP],
:item => :SAFETYGOGGLES
}]}})

PB_Trainers.register(:WORKER,"Gary",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :MAGNEZONE,
:ability => :STURDY,
:nature => :BRAVE,
:level => 70,
:moves => [:THUNDERBOLT,:POLARITYPULSE,:HPGRASS,:EXPLOSION],
:item => :CUSTAPBERRY
},
{:species => :FARIGIRAF,
:ability => :ARMORTAIL,
:nature => :MODEST,
:level => 70,
:moves => [:PSYCHICNOISE,:HYPERVOICE,:EARTHPOWER,:AGILITY],
:item => :THROATSPRAY
},
{:species => :PYUKUMUKU,
:ability => :INNARDSOUT,
:nature => :RELAXED,
:level => 70,
:moves => [:COUNTER,:MIRRORCOAT,:TOXIC,:RECOVER],
:item => :IAPAPABERRY
},
{:species => :DARMANITAN,
:ability => :SHEERFORCE,
:nature => :JOLLY,
:level => 70,
:moves => [:FLAREBLITZ,:ZENHEADBUTT,:ROCKSLIDE,:IRONHEAD],
:item => :LIFEORB
}]}})

PB_Trainers.register(:WORKER,"Jackson",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :MEOWSCARADA,
:ability => :PROTEAN,
:nature => :JOLLY,
:level => 70,
:moves => [:FLOWERTRICK,:KNOCKOFF,:TRIPLEAXEL,:TOXICSPIKES],
:item => :FOCUSSASH
},
{:species => :DUGTRIO,
:ability => :ARENATRAP,
:nature => :JOLLY,
:level => 70,
:moves => [:EARTHQUAKE,:STONEEDGE,:SUCKERPUNCH,:FINALGAMBIT],
:item => :LIFEORB
},
{:species => :TYPHLOSION,
:ability => :FLASHFIRE,
:nature => :TIMID,
:level => 70,
:moves => [:ERUPTION],
:item => :CHOICESCARF
},
{:species => :SCIZOR,
:ability => :TECHNICIAN,
:nature => :CAREFUL,
:level => 71,
:moves => [:SWORDSDANCE,:BULLETPUNCH,:BUGBITE,:SANDTOMB],
:item => :OCCABERRY
}]}})

PB_Trainers.register(:COOLTRAINER_M,"Cesar",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :DRAGAPULT,
:ability => :CLEARBODY,
:nature => :NAIVE,
:level => 70,
:moves => [:DRACOMETEOR,:DRAGONDARTS,:FIREBLAST,:SHADOWCLAW],
:item => :EJECTPACK
},
{:species => :GRAFAIAI,
:ability => :UNBURDEN,
:nature => :JOLLY,
:level => 71,
:moves => [:SWORDSDANCE,:GUNKSHOT,:RETURN,:KNOCKOFF],
:item => :NORMALGEM
},
{:species => :EMBOAR,
:ability => :RECKLESS,
:nature => :ADAMANT,
:level => 70,
:moves => [:FLAREBLITZ,:SUPERCELLSLAM,:HEADSMASH,:SUCKERPUNCH],
:item => :LIFEORB
},
{:species => :CHIMECHO,
:ability => :LEVITATE,
:nature => :TIMID,
:level => 71,
:moves => [:PSYCHIC,:MOONBLAST,:ENERGYBALL,:CALMMIND],
:item => :FAIRYGEM
},
{:species => :KINGAMBIT,
:ability => :SUPREMEOVERLORD,
:nature => :ADAMANT,
:level => 72,
:moves => [:KOWTOWCLEAVE,:IRONHEAD,:SUCKERPUNCH,:SWORDSDANCE],
:item => :CHOPLEBERRY
}]}})

PB_Trainers.register(:WORKER,"Gerardo",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :METAGROSS,
:ability => :CLEARBODY,
:nature => :ADAMANT,
:level => 70,
:moves => [:METEORMASH,:PSYCHICFANGS,:KNOCKOFF,:STEALTHROCK],
:item => :COLBURBERRY
},
{:species => :BRAVIARY,
:ability => :DEFIANT,
:nature => :JOLLY,
:level => 70,
:moves => [:BRAVEBIRD,:FACADE,:CLOSECOMBAT,:BULKUP],
:item => :LUMBERRY
},
{:species => :NIDOKING,
:ability => :SHEERFORCE,
:nature => :JOLLY,
:level => 71,
:moves => [:POISONJAB,:THUNDERPUNCH,:ICEPUNCH,:SUCKERPUNCH],
:item => :LIFEORB
},
{:species => :BAXCALIBUR,
:ability => :THERMALEXCHANGE,
:nature => :JOLLY,
:level => 71,
:moves => [:ICICLECRASH,:GLAIVERUSH,:EARTHQUAKE,:PROTECT],
:item => :CHOPLEBERRY
}]}})

PB_Trainers.register(:COOLTRAINER_F,"Ziva",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :QWILFISH,
:ability => :INTIMIDATE,
:nature => :JOLLY,
:level => 70,
:moves => [:BARBBARRAGE,:LIQUIDATION,:REVENGE,:TOXIC],
:item => :BLACKSLUDGE
},
{:species => :FERROTHORN,
:ability => :IRONBARBS,
:nature => :SASSY,
:level => 71,
:moves => [:GYROBALL,:POWERWHIP,:KNOCKOFF,:BODYPRESS],
:iv => {:SPEED => 0},
:item => :OCCABERRY
},
{:species => :DRAGONITE,
:ability => :INNERFOCUS,
:nature => :JOLLY,
:level => 72,
:moves => [:DRAGONCLAW,:DUALWINGBEAT,:FIREPUNCH,:EXTREMESPEED],
:item => :YACHEBERRY
}]}})

PB_Trainers.register(:COOLTRAINER_F,"Breanna",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :GOTHITELLE,
:ability => :SHADOWTAG,
:nature => :MODEST,
:level => 70,
:moves => [:THUNDERWAVE,:FAKEOUT,:FOLLOWME,:PSYCHIC],
:item => :COLBURBERRY
},
{:species => :TALONFLAME,
:ability => :GALEWINGS,
:nature => :ADAMANT,
:level => 71,
:moves => [:TAILWIND,:SOLARWINGS,:DUALWINGBEAT,:STEELWING],
:item => :LEFTOVERS
},
{:species => :TINKATON,
:ability => :GAVELPOWER,
:nature => :JOLLY,
:level => 72,
:moves => [:GIGATONHAMMER,:PIXIEHAMMER,:ICEHAMMER,:SWORDSDANCE],
:item => :WHITEHERB
}]}})

PB_Trainers.register(:LEADER_Byron,"Byron",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :KARTANA,
:ability => :BEASTBOOST,
:nature => :JOLLY,
:level => 72,
:moves => [:LEAFBLADE,:CUT,:PSYCHOCUT,:BRICKBREAK],
:item => :FOCUSSASH
},
{:species => :GHOLDENGO,
:ability => :GOODASGOLD,
:nature => :MODEST,
:level => 73,
:moves => [:SHADOWBALL,:MAKEITRAIN,:FOCUSBLAST,:DAZZLINGGLEAM],
:item => :AIRBALLOON
},
{:species => :CELESTEELA,
:ability => :BEASTBOOST,
:nature => :RELAXED,
:level => 72,
:moves => [:HEAVYSLAM,:FLAMETHROWER,:EARTHPOWER,:GIGADRAIN],
:item => :LEFTOVERS
},
{:species => :HEATRAN,
:ability => :FLASHFIRE,
:nature => :TIMID,
:level => 73,
:moves => [:MAGMASTORM,:POLARITYPULSE,:EARTHPOWER,:HPGRASS],
:item => :SHUCABERRY
},
{:species => :ARCHALUDON,
:ability => :STAMINA,
:nature => :MODEST,
:level => 73,
:moves => [:FLASHCANNON,:POLARITYPULSE,:BODYPRESS,:THUNDERBOLT],
:item => :ASSAULTVEST
},
{:species => :EMPOLEON,
:ability_index => 2,
:nature => :TIMID,
:level => 74,
:moves => [:HYDROPUMP,:POLARITYPULSE,:ICEBEAM,:ROOST],
:item => :EMPOLEONITE
}]}})