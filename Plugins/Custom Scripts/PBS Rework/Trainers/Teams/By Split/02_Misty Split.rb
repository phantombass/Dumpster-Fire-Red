#===================================#
#              Route 3              #
#===================================#
PB_Trainers.register(:LASS,"Janice",{
:base => {
:lose_text => "You're mean!",
:pokemon=> [
{:species => :PIKACHU,


:level => 13,


},
{:species => :STARAVIA,


:level => 14,


}]}})

PB_Trainers.register(:BUGCATCHER,"Colton",{
:base => {
:lose_text => "You beat me again!",
:pokemon=> [
{:species => :BUTTERFREE,


:level => 13,
},
{:species => :BEEDRILL,


:level => 13,
},
{:species => :KRICKETUNE,


:level => 13,


}]}})

PB_Trainers.register(:YOUNGSTER,"Ben",{
:base => {
:lose_text => "I don't believe it!",
:pokemon=> [
{:species => :DRILBUR,


:level => 14,


},
{:species => :BIBAREL,


:level => 15,


}]}})

PB_Trainers.register(:BUGCATCHER,"Greg",{
:base => {
:lose_text => "If I had new Pokémon, I would've won!",
:pokemon=> [
{:species => :LARVESTA,


:level => 14,


},
{:species => :CHARJABUG,


:level => 14,
:moves => [:SPARK,:BUGBITE]

}]}})

PB_Trainers.register(:BUGCATCHER,"James",{
:base => {
:lose_text => "Done like dinner!",
:pokemon=> [
{:species => :DEWPIDER,


:level => 14,


},
{:species => :JOLTIK,


:level => 14,


},
{:species => :SPIDOPS,


:level => 15,


}]}})

PB_Trainers.register(:LASS,"Sally",{
:base => {
:lose_text => "Be nice!",
:pokemon=> [
{:species => :JIGGLYPUFF,


:level => 15,


},
{:species => :COTTONEE,


:level => 15,


}]}})

PB_Trainers.register(:LASS,"Robin",{
:base => {
:lose_text => "That's it?",
:pokemon=> [
{:species => :SNUBBULL,
:ability => :INTIMIDATE,

:level => 15,
:moves => [:COVET,:FIREFANG]

},
{:species => :MAWILE,
:ability => :INTIMIDATE,

:level => 16,
:moves => [:METALCLAW,:COVET]

}]}})

PB_Trainers.register(:YOUNGSTER,"Calvin",{
:base => {
:lose_text => "Lost! Lost! Lost!",
:pokemon=> [
{:species => :COMBUSKEN,


:level => 16,
:moves => [:DOUBLEKICK,:FLAMECHARGE]

},
{:species => :FROGADIER,


:level => 16,
:moves => [:WATERPULSE,:ICYWIND]

}]}})


#===================================#
#             Mt. Moon              #
#===================================#

PB_Trainers.register(:BUGCATCHER,"Kent",{
:base => {
:lose_text => "You got me!",
:pokemon=> [
{:species => :DOTTLER,


:level => 16,


},
{:species => :PINECO,
:ability => :STURDY,
:nature => :ADAMANT,
:level => 16,
:moves => [:EXPLOSION],
:item => :CUSTAPBERRY
}]}})

PB_Trainers.register(:LASS,"Iris",{
:base => {
:lose_text => "I lost?",
:pokemon=> [
{:species => :CLEFAIRY,
:ability => :MAGICGUARD,

:level => 17,
:moves => [:METRONOME],
:item => :BRIGHTPOWDER
}]}})

PB_Trainers.register(:LASS,"Miriam",{
:base => {
:lose_text => "Oh! I lost it!",
:pokemon=> [
{:species => :BELLSPROUT,
:moves => [:RAZORLEAF,:POISONFANG],

:level => 16,


},
{:species => :ODDISH,
:moves => [:MEGADRAIN,:SLUDGE],

:level => 17,


},
{:species => :TANGELA,
:moves => [:MEGADRAIN,:ANCIENTPOWER],

:level => 18,


}]}})

PB_Trainers.register(:BUGCATCHER,"Robby",{
:base => {
:lose_text => "I lost.",
:pokemon=> [
{:species => :SIZZLIPEDE,


:level => 18,


},
{:species => :DWEBBLE,


:level => 18,


}]}})

PB_Trainers.register(:SUPERNERD,"Jovan",{
:base => {
:lose_text => "My Pokémon won't do!",
:pokemon=> [
{:species => :MARILL,
:ability => :HUGEPOWER,

:level => 21,
:moves => [:MISTYEXPLOSION],
:item => :FOCUSSASH
},
{:species => :GRIMER_1,
:ability => :POWEROFALCHEMY,

:level => 21,
:moves => [:POISONFANG,:PURSUIT,:BRICKBREAK],
:item => :AIRBALLOON
}]}})

PB_Trainers.register(:YOUNGSTER,"Josh",{
:base => {
:lose_text => "Losing stinks! It's so uncool.",
:pokemon=> [
{:species => :HERDIER,


:level => 18,


},
{:species => :NIDORINO,


:level => 19,


}]}})

PB_Trainers.register(:HIKER,"Marcos",{
:base => {
:lose_text => "Wow! Shocked again!",
:pokemon=> [
{:species => :GEODUDE,


:level => 18,


},
{:species => :ROGGENROLA,


:level => 19,


},
{:species => :OMANYTE,
:ability => :WEAKARMOR,

:level => 19,
:moves => [:BUBBLEBEAM,:ANCIENTPOWER],
:item => :FOCUSBAND
}]}})

PB_Trainers.register(:TEAMROCKET_M,"Grunt",{
:Mt_Moon_1 => {
:lose_text => "I'm steamed!",
:pokemon=> [
{:species => :KOFFING,


:level => 20,
:moves => [:SLUDGE,:FLAMEBURST]

},
{:species => :GRIMER,


:level => 20,
:moves => [:POISONFANG,:BRICKBREAK]

}]}})

PB_Trainers.register(:TEAMROCKET_M,"Grunt",{
:Mt_Moon_2 => {
:lose_text => "So, you are good...",
:pokemon=> [
{:species => :MAREANIE,


:level => 19,
:moves => [:BANEFULBUNKER,:VENOSHOCK]

},
{:species => :WHIRLIPEDE,
:ability => :SPEEDBOOST,

:level => 20,
:moves => [:BUGBITE,:POISONTAIL,:ROLLOUT]

}]}})

PB_Trainers.register(:TEAMROCKET_M,"Grunt",{
:Mt_Moon_3 => {
:lose_text => "I blew it!",
:pokemon=> [
{:species => :VAROOM,


:level => 20,
:moves => [:METALCLAW,:POISONFANG]

},
{:species => :CROAGUNK,


:level => 20,
:moves => [:SLUDGE,:VACUUMWAVE,:MUDBOMB]

}]}})

PB_Trainers.register(:TEAMROCKET_M,"Grunt",{
:Mt_Moon_4 => {
:lose_text => "Urgh! Now I'm mad!",
:pokemon=> [
{:species => :SNEASEL_1,


:level => 20,
:moves => [:ROCKSMASH,:POISONTAIL]

},
{:species => :CLODSIRE,


:level => 20,
:moves => [:BULLDOZE,:POISONTAIL,:YAWN]

},
{:species => :IVYSAUR,


:level => 20,
:moves => [:MEGADRAIN,:SLUDGE,:LEECHSEED]

}]}})

PB_Trainers.register(:SUPERNERD,"Miguel",{
:base => {
:lose_text => "Okay! I'll share!",
:pokemon=> [
{:species => :PAWMO,


:level => 20,
:moves => [:MACHPUNCH,:SPARK]

},
{:species => :VOLTORB_1,


:level => 21,
:moves => [:SHOCKWAVE,:MEGADRAIN,:SELFDESTRUCT]

},
{:species => :GOLBAT,


:level => 21,
:moves => [:WINGATTACK,:POISONFANG,:BITE]

}]}})

#===================================#
#           Cerulean City           #
#===================================#

PB_Trainers.register(:RIVAL1,"Blue",{
:Cerulean => {
:lose_text => "Hey! Take it easy! You won already!",
:pokemon=> [
{:species => :DELIBIRD,
:ability => :MAGICGUARD,
:nature => :TIMID,
:level => 19,
:moves => [:ICETOMB],
:item => :STICKYBARB
},
{:species => :TOGEKISS,
:ability => :MASOCHIST,
:nature => :TIMID,
:level => 20,
:moves => [:AIRSLASH],
:item => :SHARPBEAK
},
{:species => :DODUO,
:ability => :TANGLEDFEET,
:nature => :JOLLY,
:level => 20,
:moves => [:DOUBLEHEADBONK,:DUALWINGBEAK],
:item => :SHELLBELL
},
{:species => :YANMA,
:ability => :BLINDINGSPEED,
:nature => :TIMID,
:level => 21,
:moves => [:DRAGONRAGE]

}]}})

#===================================#
#             Route 24              #
#===================================#
PB_Trainers.register(:BUGCATCHER,"Cale",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :DUSTOX,


:level => 19,


},
{:species => :FROSMOTH,


:level => 19,


},
{:species => :PARASECT,


:level => 20,


}]}})

PB_Trainers.register(:LASS,"Ali",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :CLEFABLE,
:ability => :MISTYSURGE,

:level => 20,
:moves => [:MISTYEXPLOSION,:DUALWINGBEAT]

},
{:species => :WIGGLYTUFF,


:level => 20,
:moves => [:MISTYEXPLOSION]

}]}})

PB_Trainers.register(:YOUNGSTER,"Timmy",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :ZORUA_1,


:level => 20,
:moves => [:HEX,:ECHOEDVOICE],

},
{:species => :RATICATE,


:level => 20,


},
{:species => :LINOONE_1,


:level => 21,


}]}})

PB_Trainers.register(:LASS,"Reli",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :APPLETUN,


:level => 21,


},
{:species => :ALCREMIE,


:level => 21,


}]}})

PB_Trainers.register(:CAMPER,"Ethan",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :SABLEYE,
:ability => :WONDERGUARD,

:level => 22,
:moves => [:KNOCKOFF]

}]}})

PB_Trainers.register(:TEAMROCKET_M,"Grunt",{
:Nugget => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :ARBOK,


:level => 22,


},
{:species => :SEVIPER,


:level => 22,


},
{:species => :GOLBAT,


:level => 22,


}]}})

PB_Trainers.register(:CAMPER,"Shane",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :TOEDSCOOL,


:level => 21,


},
{:species => :SANDSLASH,


:level => 21,


}]}})

#===================================#
#             Route 25              #
#===================================#
PB_Trainers.register(:HIKER,"Franklin",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :GROTLE,


:level => 21,


},
{:species => :DREDNAW,


:level => 22,


}]}})

PB_Trainers.register(:YOUNGSTER,"Joey",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :VENONAT,


:level => 22,


},
{:species => :WATCHOG,


:level => 22,


}]}})

PB_Trainers.register(:HIKER,"Wayne",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :GRAVELER_1,
:ability => :GALVANIZE,

:level => 28,
:moves => [:STEALTHROCK,:EXPLOSION]

},
{:species => :QUAGSIRE,
:ability => :UNAWARE,

:level => 28,
:moves => [:EARTHQUAKE],
:item => :REDCARD
},
{:species => :QWILFISH,
:ability => :CORROSION,
:nature => :JOLLY,
:level => 28,
:moves => [:BARBBARRAGE],
:item => :POISONBARB
},
{:species => :ONIX,
:ability => :SPRINKLERPOWER,

:level => 28,
:moves => [:DRAGONTAIL],
:item => :CHOICESCARF
}]}})

PB_Trainers.register(:YOUNGSTER,"Dan",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :VAROOM,


:level => 22,


},
{:species => :KLINK,


:level => 23,


}]}})

PB_Trainers.register(:PICNICKER,"Kelsey",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :NIDORINA,


:level => 23,


},
{:species => :CLEFAIRY,


:level => 23,


},
{:species => :PONYTA,


:level => 23,


}]}})

PB_Trainers.register(:HIKER,"Nob",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :KLAWF,


:level => 23,


},
{:species => :SCRAGGY,


:level => 22,


},
{:species => :SWINUB,


:level => 23,


},
{:species => :MAGCARGO,


:level => 22,


}]}})

PB_Trainers.register(:CAMPER,"Flint",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :DACHSBUN,


:level => 24,


},
{:species => :LOKIX,


:level => 24,


}]}})
PB_Trainers.register(:YOUNGSTER,"Chad",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :GROWLITHE,


:level => 23,


},
{:species => :BOLTUND,


:level => 24,


},
{:species => :LUCARIO,


:level => 24,


}]}})

PB_Trainers.register(:LASS,"Haley",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :PERRSERKER,


:level => 24,


},
{:species => :DELCATTY,


:level => 24,


}]}})

#===================================#
#           Cerulean Gym            #
#===================================#

PB_Trainers.register(:SWIMMER2_M,"Swimmer",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :TENTACOOL,


:level => 24,


},
{:species => :GASTRODON,


:level => 25,


}]}})

PB_Trainers.register(:PICNICKER,"Diana",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :PELIPPER,
:ability => :KEENEYE,

:level => 25,


}]}})

PB_Trainers.register(:LEADER_Misty,"Misty",{
:base => {
:lose_text => "Wow. You're great!",
:pokemon=> [
{:species => :SEAKING,
:ability => :HECKYEAH,

:level => 26,
:moves => [:WATERFALL,:DRILLRUN,:HORNATTACK],
:item => :CHOICESCARF
},
{:species => :HORSEA,
:ability => :INKSPRAY,

:level => 27,
:moves => [:OCTAZOOKA]

},
{:species => :QUAGSIRE,
:ability => :SAPSIPPER,

:level => 27,
:moves => [:EARTHQUAKE,:YAWN]

},
{:species => :STARMIE,
:ability => :ILLUMINATE,

:level => 28,
:moves => [:HYDROPUMP]

}]}})