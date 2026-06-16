#===================================#
#           Pallet Town             #
#===================================#

PB_Trainers.register(:RIVAL1,"Blue",{
:base => {
:lose_text => "WHAT? Unbelievable! I picked the wrong Pokémon!",
:pokemon=> [
{:species => :YANMA,
:ability => :COMPOUNDEYES,
:item => :IRONBALL,
:nature => :QUIET,
:iv => {:SPEED => 0},
:level => 10,
:moves => [:SONICBOOM]
}]}})

#===================================#
#             Route 22              #
#===================================#

PB_Trainers.register(:RIVAL1,"Blue",{
:optional => {
:lose_text => "Awww! You just lucked out!",
:pokemon=> [
{:species => :YANMA,
:ability => :BLINDINGSPEED,
:nature => :TIMID,
:level => 14,
:moves => [:DRAGONRAGE],
:item => :STICKYBARB
}]}})

#===================================#
#          Viridian Forest          #
#===================================#

PB_Trainers.register(:BUGCATCHER,"Rick",{
:base => {
:lose_text => "No! Caterpie can't hack it!",
:pokemon=> [
{:species => :CATERPIE,


:level => 6,


},
{:species => :CATERPIE,


:level => 7,


},
{:species => :CATERPIE,


:level => 8,


}]}})

PB_Trainers.register(:BUGCATCHER,"Doug",{
:base => {
:lose_text => "Huh? I ran out of Pokémon!",
:pokemon=> [
{:species => :METAPOD,


:level => 8,
:moves => [:BUGBITE]

},
{:species => :KAKUNA,


:level => 8,
:moves => [:BUGBITE]

}]}})

PB_Trainers.register(:BUGCATCHER,"Anthony",{
:base => {
:lose_text => "Oh, boo! Nothing went right.",
:pokemon=> [
{:species => :WEEDLE,


:level => 8,


},
{:species => :KAKUNA,


:level => 9,
:moves => [:BUGBITE]

}]}})

PB_Trainers.register(:BUGCATCHER,"Charlie",{
:base => {
:lose_text => "Oh! I lost!",
:pokemon=> [
{:species => :BURMY,


:level => 9,


},
{:species => :BURMY_1,


:level => 9,


},
{:species => :BURMY_2,


:level => 9,


}]}})

PB_Trainers.register(:BUGCATCHER,"Sammy",{
:base => {
:lose_text => "I give! You're good at this!",
:pokemon=> [
{:species => :ORTHWORM,
:ability => :EARTHEATER,

:level => 10,
:moves => [:ROCKTOMB]

},
{:species => :TRAPINCH,
:ability => :ARENATRAP,

:level => 10,
:moves => [:BULLDOZE]

}]}})


#===================================#
#             Pewter Gym            #
#===================================#
PB_Trainers.register(:CAMPER,"Liam",{
:base => {
:lose_text => "Darn! Light-years isn't time, it measures distance!",
:pokemon=> [
{:species => :ROGGENROLA,
:ability => :STURDY,

:level => 12,
:moves => [:SELFDESTRUCT]

}]}})


PB_Trainers.register(:LEADER_Brock,"Brock",{
:base => {
:lose_text => "I took you for granted, and so I lost.",
:pokemon=> [
{:species => :ONIX,
:ability => :SPRINKLERPOWER,
:nature => :JOLLY,
:level => 14,
:moves => [:STEALTHROCK,:DRAGONTAIL],
:item => :MOMSLEFTOVERS
}]}})