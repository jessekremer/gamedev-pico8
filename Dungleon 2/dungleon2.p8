pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
function _init()
	music(0)
	show_solution=false
	plays=0
	wins=0
	hards=0
	streak=0
	daily_done=false
	eight_done=false
	spoils_heroes=0
	spoils_monsters=0
	spoils_treasure=0

	state="title"
	modes={"single","eight"}
	mode_pos=1
	eight_level=1
	eight_results={}
	lvl_lmt=8

	chars={
			{
				name="warrior",
				type="hero",
				spr=1,
				spoil="hero",
				min=1,
				max=1,
				code=1,
				palt=14,
				result="none"
			},
			{
				name="archer",
				type="hero",
				spr=2,
				spoil="hero",
				min=1,
				max=1,
				code=1,
				palt=14,
				result="none"
			},
			{
				name="mage",
				type="hero",
				spr=3,
				spoil="hero",
				min=1,
				max=1,
				code=1,
				palt=14,
				result="none"
			},
			{
				name="bat",
				type="monster",
				spr=6,
				spoil="monster",
				min=2,
				max=2,
				code=2,
				palt=14,
				result="none"
			},
			{
				name="spider",
				type="monster",
				spr=7,
				spoil="monster",
				min=3,
				max=3,
				code=2,
				palt=14,
				result="none"
			},
			{
				name="blade orc",
				type="monster",
				spr=8,
				spoil="monster",
				min=2,
				max=1,
				code=2,
				palt=10,
				result="none"
			},
			{
				name="axe orc",
				type="monster",
				spr=9,
				spoil="monster",
				min=2,
				max=1,
				code=2,
				palt=10,
				result="none"
			},
			{
				name="skeleton",
				type="monster",
				spr=10,
				spoil="monster",
				min=1,
				max=4,
				code=2,
				palt=10,
				result="none"
			},
			{
				name="villager",
				type="npc",
				spr=4,
				spoil="none",
				min=1,
				max=1,
				code=1,
				palt=14,
				result="none"
			},
			{
				name="king",
				type="npc",
				spr=5,
				spoil="none",
				min=1,
				max=1,
				code=1,
				palt=14,
				result="none"
			},
			{
				name="zombie",
				type="other",
				spr=22,
				spoil="monster",
				min=1,
				max=0,
				code=3,
				palt=10,
				result="none"
			},
			{
				name="thief",
				type="monster",
				spr=23,
				spoil="monster",
				min=1,
				max=1,
				code=1,
				palt=11,
				result="none"
			},
			{
				name="wizard",
				type="monster",
				spr=24,
				spoil="monster",
				min=1,
				max=1,
				code=5,
				palt=11,
				result="none"
			},
			{
				name="necromancer",
				type="monster",
				spr=25,
				spoil="monster",
				min=1,
				max=1,
				code=2,
				palt=14,
				result="none"
			},
			{
				name="wand",
				type="aid",
				spr=16,
				spoil="none",
				min=1,
				max=1,
				code=-1,
				palt=11,
				result="no aid"
			},
			{
				name="coins",
				type="loot",
				spr=17,
				spoil="loot",
				min=2,
				max=3,
				code=0,
				palt=14,
				result="none"
			},
			{
				name="chest",
				type="loot",
				spr=18,
				spoil="loot",
				min=1,
				max=3,
				code=0,
				palt=14,
				result="none"
			},
			{
				name="relic",
				type="loot",
				spr=19,
				spoil="loot",
				min=1,
				max=1,
				code=5,
				palt=11,
				result="none"
			},
			{
				name="frog",
				type="other",
				spr=20,
				spoil="none",
				min=1,
				max=0,
				code=3,
				palt=14,
				result="none"
			},
			{
				name="dragon",
				type="monster",
				spr=21,
				spoil="monster",
				min=1,
				max=1,
				code=2,
				palt=14,
				result="none"
			}
		}
	
		timers={}
		--length
		--frames
		--current
		--tag
		
		level_init()
end

function level_init(mode)
	trans_drop=true
	first_shake=true
	ty=-50
	tf=0.9
	tv=6
	cursor=1
	aid=false
	first_aid=true
	guess={}
	-- reset character states
	for c=1,#chars do
		ch=chars[c]
		ch.result="no aid"
		if(ch.type!='aid') ch.result="none"
	end
	check=false
	wait=0
	hearts=3
	hardmode=true
	title_scale=2
	--90 year
	--91 month
	--92 day
	seed=(stat(90)-2020)*10000+stat(91)*100+stat(92)
	if (mode=='eight') seed+=(eight_level+8)*100 eight_level+=1
	solution=build_dungeon(seed)
end

function build_dungeon(seed)
	local dungeon={}
	local heroes={}
	local choices=deepcopy(chars)
	srand(seed)
	-- https://docs.google.com/spreadsheets/d/1JnarT1WfE8O1oGL6G1CzGoDg9hypuhkZ8NI5BXIUWSM/edit?usp=sharing
	---- SLOT 1+2
	-- Step 1	B7 - random selection of a hero
	for c=1,#choices do
		if(choices[c].type=="hero") add(heroes,choices[c])
	end
	hero1=ceil(rnd(#heroes))
	add(dungeon,heroes[hero1])
	-- Step 2	A15 - create a list of possibilities for next character. Exclude the hero in B7, any transforms, and anything that can't be in slots 1/2 (i.e. wizard and amulet) and if B7 is archer exclude monsters that can't be next to archer (look at 'code' column) 
	del(choices,heroes[hero1])
	if dungeon[1].name =="archer" then
		for c=#choices,1,-1 do
			if(choices[c].type=="monster") del(choices,choices[c])
		end
	end
	for c=#choices,1,-1 do
		cc=choices[c]
		if(cc.code==5 or cc.type=="other" or cc.type=="aid") del(choices,cc)
	end
	-- Step 3	B8 - select random from list in step 2
	add(dungeon,choices[ceil(rnd(#choices))])

	-- Step 4	F15 & G15 - 'finalize' slot 1 and 2.  
	-- 			If either B7 or B8 are king or thief they must be in slot 1, 
	--			if B8 is a monster it must stay in slot 2, (always will be true except for thief)
	--			if not but either are warrior then warrior must be in slot 2, 
	--			finally otherwise randomize order of B7 and B8
	randomize=true
	if dungeon[2].name=="king" or dungeon[2].name=="thief" then
		temp=dungeon[1]
		--swap 1 and 2
		del(dungeon,dungeon[1])
		add(dungeon,temp)
		randomize=false
	end
	if dungeon[1].name=="warrior" and dungeon[2].type!="monster" then
		temp=dungeon[1]
		--swap 1 and 2
		del(dungeon,dungeon[1])
		add(dungeon,temp)
		randomize=false
	end
	if dungeon[2].name=="warrior" or dungeon[1].name=="thief" or dungeon[1].name=="king" or dungeon[2].type=="monster" then
		randomize=false
	end
	if randomize then
		if rnd({true,false}) then
			temp=dungeon[1]
			--swap 1 and 2
			del(dungeon,dungeon[1])
			add(dungeon,temp)
		end
	end

	---- SLOT 3
	-- Step 5	B15 - create a list of possibilities for next slot, 
	-- 			but not codeV=5 (i.e. wizard or amulet), 
	--			not thief, 
	-- 			not same as slot 2 if slot 2 has maxcount=1, 
	-- 			and if slot 2 is archer must be chest or coins, 
	-- 			if slot 2 is warrior must have monster, 
	-- 			if dragon, must be chest, 
	--			if dragon, remove other monsters
	-- 			otherwise include monsters and loot
	choices=deepcopy(chars)
	dragon=0
	for d=1,#dungeon do
		if(dungeon[d].name=="dragon") dragon+=1
	end
	for c=#choices,1,-1 do
		cc=choices[c]
		d1=dungeon[1]
		d2=dungeon[2]
		if 	cc.name=="thief" or 
			cc.code==5 or
			(d2.max==1 and cc.name==d2.name) or
			(d2.name=="archer" and (cc.name!="chest" and cc.name!="coins")) or
			(d2.name=="warrior" and cc.type!="monster") or
			(d2.name=="dragon" and cc.name!="chest") or
			(cc.type!="monster" and cc.type!="loot") or
			((d1.type=="monster" or d2.type=="monster") and cc.name=="dragon") or
			((d1.min>1 or d2.min>1) and cc.name=="spider") or
			((d1.name=="spider" or d2.name=="spider") and (cc.min>1)) or
			(dragon>0 and cc.name=="coins")
			 then
				del(choices,cc)
		end
	end
	
	-- Step 6	B9 - select random from list in step 5
	add(dungeon,choices[ceil(rnd(#choices))])
	

	---- SLOT 4
	-- Step 7	C15 - create a list of possibilities for slot 4 and force duplicates if needed.  
	-- 			If slots 2&3 have 1 bat then must be bat, 
	-- 			if either is spider then must be spider, 
	-- 			if 1 orc then must be other orc, 
	-- 			if duplicate isn't needed (yet) then filter list with rules like, 
	-- 			no duplicates that aren't allowed, 
	-- 			limits for dragon, no slot 5 or slot 1 only characters, 
	-- 			and don't start a monster you can't finish (i.e. spiders)
	choices=deepcopy(chars)
	bat=0
	spider=0
	orc=0
	orc_type=""
	dragon=0
	monster=0
	coins=0
	loot=0
	for d=1,#dungeon do
		dd=dungeon[d]
		if(dd.name=="bat") bat+=1
		if(dd.name=="spider") spider+=1
		if(dd.name=="dragon") dragon+=1
		if(dd.name=="coins") coins+=1
		if(dd.type=="loot") loot+=1
		if(dd.type=="monster") monster+=1
		if(dd.name=="blade orc" or dd.name=="axe orc") orc+=1 orc_type=dd.name
	end
	if bat==1 then
		for c=1,#choices do
			if choices[c].name=="bat" then 
				add(dungeon,choices[c])
				break
			end
		end
	elseif spider>=1 then
		for c=1,#choices do
			if choices[c].name=="spider" then 
				add(dungeon,choices[c])
				break
			end
		end
	elseif orc==1 then
		if orc_type=="axe orc" then
			orc_type="blade orc"
		else
			orc_type="axe orc"
		end
		eject=false
		for c=1,#choices do
			if choices[c].name==orc_type then 
				add(dungeon,choices[c])
				eject=true
			end
			if(eject) break
		end
	elseif monster==0 then
		-- if no monsters yet, add one unless you can't finish it
		for c=#choices,1,-1 do
			cc=choices[c]
			if 	(cc.min>2 and
				cc.max>2 and 
				cc.type=="monster") or
				cc.type!="monster" or
				cc.name=="thief" or
				cc.name=="wizard" or
				((cc.name=="blade orc" or cc.name=="axe orc") and (orc==2 or coins==1 or bat==1 or spider==1)) or
				(cc.name=="bat" and bat<1 and (coins==1 or spider>=1)) or
				cc.code==5 or
				cc.code==1 then
				del(choices,cc)
			end
		end
		add(dungeon,choices[ceil(rnd(#choices))])
	else
		cnt=count_chars(dungeon)
		for c=1,#cnt do
			if cnt[c].num>=1 then
				for h=#choices,1,-1 do
					ch=choices[h]
					if (ch.name==cnt[c].name and ch.max <= cnt[c].num)
						or ch.name=="dragon"
						or ch.code==5
						or ch.code==1
						or ch.type=="aid"
						or ch.type=="hero"
						or ch.type=="npc"
						or ch.type=="other"
						or (dragon>0 and (ch.type=="monster" or ch.name=="relic" or ch.name=="coins")
						or ((ch.name=="blade orc" or ch.name=="axe orc") and (orc==2 or coins==1 or bat==1 or spider==1))
						or (ch.name=="spider" and spider==0)) then
						del(choices,ch)
					end
				end
			end
		end
		for c=#choices,1,-1 do
			if(choices[c].name=="dragon" and monsters>0) del(choices,choices[c])
		end
		-- Step 8	B10 - select random from list in step 7
		add(dungeon,choices[ceil(rnd(#choices))])
	end

	---- SLOT 5
	-- Step 9	D15 - similar to step 7 create possible list for last slot.  Finish any REQUIREMENTS like spiders or if slot 4 was bat or orc or coins or if dragon then must be amulet, but if not then filter list based on no duplicates and rules for dragon, no thief and don't start a monster you can't finish (i.e. requires a duplicate)
	choices=deepcopy(chars)
	cnt=count_chars(dungeon)
	relic_check=false
	dragon_check=false
	bat=0
	spider=0
	coins=0
	monster=0
	orc=0
	orc_type=""
	loot=0
	for c=1,#cnt do
		cc=cnt[c]
		if(cc.name=="dragon" and cc.num>0) dragon_check=true
		if(cc.name=="relic" and cc.num>0) relic_check=true
		if(cc.name=="bat") bat=cc.num
		if(cc.name=="spider") spider=cc.num
		if(cc.name=="coins") coins=cc.num
		if(cc.type=="loot") loot+=1
		if(cc.name=="blade orc" or cc.name=="axe orc" and cc.num>0) orc+=cc.num orc_type=cc.name
	end
	for d=1,#dungeon do
		if(dungeon[d].type=="monster") monster+=1
	end
	if dragon_check and not relic_check then
		for c=1,#choices do
			if(choices[c].name=="relic") add(dungeon,choices[c]) break
		end
	elseif bat==1 or spider==2 or coins==1 then
		for c=1,#choices do
			cc=choices[c]
			if 	(cc.name=="bat" and bat==1) or
				(cc.name=="spider" and spider==2) or
				(cc.name=="coins" and coins==1)then 
				add(dungeon,cc)
			end
		end
	elseif orc==1 then
		if orc_type=="axe orc" then
			orc_type="blade orc"
		else
			orc_type="axe orc"
		end
		eject=false
		for c=1,#choices do
			if choices[c].name==orc_type then 
				add(dungeon,choices[c])
				eject=true
			end
			if(eject) break
		end
	-- elseif loot==0 then
	-- 	loot_options={}
	-- 	for c=1,#choices do
	-- 		if choices[c].type=="loot" then
	-- 			add(loot_options,c)
	-- 		end
	-- 	end
	-- 	add(dungeon,choices[rnd(loot_options)])
	else
		for c=#choices,1,-1 do
			for n=1,#cnt do
				cn=cnt[n]
				cc=choices[c]
				if 	(cn.name==cc.name and 
					(cn.num+1<cc.min or 
					cn.num+1>cc.max or 
					cc.type=="hero" or
					cc.type=="aid" or
					cc.type=="other" or
					cc.type=="npc" or
					(cc.name=="dragon" and monster>0) or
					cc.name=="thief" or
					cc.name=="blade orc" or
					cc.name=="axe orc"))
					 then
					del(choices,cc)
					break
				end
			end
		end
		-- Step 10	B11 - select random from list in step 9
		add(dungeon,choices[ceil(rnd(#choices))])
	end

	choices=deepcopy(chars)
	dragon=0
	mage=0
	necro=0
	monster={}
	for d=1,#dungeon do 
		dd=dungeon[d]
		if(dd.name=="dragon") dragon+=1
		if(dd.name=="mage") mage+=1
		if(dd.name=="necromancer") necro+=1
		if(dd.type=="monster") add(monster,d)
	end
	frog_target=rnd(monster)
	for d=1,#dungeon do 
		-- swap dragon coins for other things
		if dragon>0 and dungeon[d].name=="coins" then
			for c=1,#choices do
				if choices[c].name=="chest" then
					dungeon[d]=choices[c]
				end
			end
		end
		if necro>0 and dungeon[d].type=="hero" then
			for c=1,#choices do
				if choices[c].name=="zombie" then
					dungeon[d]=choices[c]
				end
			end
		end
	end
	if mage>0 then
		for c=1,#choices do
			if choices[c].name=="frog" then
				dungeon[frog_target]=choices[c]
			end
		end
	end
	-- Step 11	F7 - random number based on number of monsters (1 to total # monsters in slots) to be used for frogging if needed
	-- Step 12	G7:G11 - apply transformations onto B7:B11, which is if hero and necro present then -> zombie; if mage present and count of monsters from slot 1 to now = F7 then frog
	-- Step 13	A3:B3 - based on order selected in F15:G15 select corresponding post-transforms from G7:G8
	-- Step 14	C3 - use G9
	-- Step 15	D3:E3 - if slot 5 is wizard or amulet then keep order; otherwise randomize order of G10:G11
	if dungeon[5].code!=5 then
		temp=dungeon[4]
		if rnd({true,false}) then
			--swap 1 and 2
			del(dungeon,dungeon[4])
			add(dungeon,temp)
		end
	end

	return dungeon
end

function count_chars(tbl)
	local unique_chars={}
	for c=1,#chars do
		add(unique_chars,{name=chars[c].name,num=0})
	end
	for u=1,#unique_chars do
		for t=1,#tbl do
			if unique_chars[u].name==tbl[t].name then
				unique_chars[u].num+=1
			end
		end
	end
	return unique_chars
end

function _update()
	btnp_o=btnp(🅾️)
	btnp_x=btnp(❎)
	btnp_r=btnp(➡️)
	btnp_l=btnp(⬅️)
	btnp_u=btnp(⬆️)
	btnp_d=btnp(⬇️)
	btn_o=btn(🅾️)
	btn_x=btn(❎)
	for t=#timers,1,-1 do
		tm=timers[t]
		tm.current+=tm.speed
		if tm.current>tm.length then
			del(timers,tm)
		end
	end
	
	if state=="how to play" then
		if wait<30 then
			wait+=1
		else
			if htp==2 then
				state="play"
				-- mode=modes[mode_pos]
			elseif btnp_o or btnp_x or btnp_r or btnp_l  then
				htp+=1
				go_next=false
				wait=0
				sfx(0)
			end
		end
	elseif state=="title" then
		button=''
		if btnp_l then
			if mode_pos > 1 then
				mode_pos-=1
			else
				mode_pos=#modes
			end
			button='left'
		elseif btnp_r then
			if mode_pos < #modes then
				mode_pos+=1
			else
				mode_pos=1
			end
			button='right'
		end
		if wait<30 then
			wait+=1
		else
			if btn_o and btn_x and not daily_done and modes[mode_pos]=='single' then
				play_wait=true
				htp=0 -- how to play page
				add(timers,{length=120,speed=5,current=0,lag=0,tag="circle fill",val=100})
				sfx(0)
			end
			if btn_o and btn_x and not eight_done and modes[mode_pos]=='eight' then
				play_wait=true
				htp=0 -- how to play page
				add(timers,{length=120,speed=5,current=0,lag=0,tag="circle fill",val=100})
				sfx(0)
			end
		end
	elseif state=="play" then
		play_controls()
	elseif state=="lose" or state=="win" then
		if btn_o and btn_x then
			sfx(0)
			if modes[mode_pos]=='single' or eight_level>lvl_lmt then
				state='title'
				if(modes[mode_pos]=='single') daily_done=true
				if(modes[mode_pos]=='eight') eight_done=true 
			else
				level_init(modes[mode_pos])
				state='play'
			end
			wait=0
		elseif btnp_x then
			sfx(0)
			if mode=='stats' and modes[mode_pos]=='single' then
				mode='result single'
			elseif mode=='stats' and modes[mode_pos]=='eight' then
				mode='result eight'
			else
				mode='stats'
			end
		end
	end
	if play_wait and #timers==0 then
		state="how to play"
		htp=0
		play_wait=false
		level_init(modes[mode_pos])
	end
end

function _draw()
	cls()

	if state=="title" then
		map()
		palt(0,false)
		palt(11,true)
		sspr(64,96,
			59,13,
			5+50*(1-title_scale),12,
			118*title_scale,26*title_scale)
		if(title_scale>1) then
			title_scale*=0.95
		elseif(title_scale<1) then
			title_scale=1
			if(first_shake) then
				add(timers,{length=1,speed=1,current=0,lag=0,tag="bump up"})
				first_shake=false
			end
		end
		sspr(0,32,64,32,32,64,64,32)
		sspr(64,32,64,32,32,96,64,32)
		
		bl=2
		br=2
		if button=='left' then
			bl=14
		elseif button=='right' then
			br=14
		end
		bprint("⬅️",42,99,0,bl)
		bprint("➡️",79,99,0,br)
		mode=modes[mode_pos]
		txt3=''
		if mode=="single" then
			txt1='daily'
			txt2='single'
			if(daily_done) txt3='(done)'
		elseif mode=="eight" then
			txt1='daily'
			txt2='eight'
			if(eight_done) txt3='(done)'
		elseif mode=="codes" then
			txt1='codes'
			txt2=''
		end
		if txt3!='' then
			print(txt1,centre_text(txt1,0),93,5)
			print(txt2,centre_text(txt2,0),99,5)
			print(txt3,centre_text(txt3,0),105,5)
		elseif txt2!='' then
			print(txt1,centre_text(txt1,0),96,7)
			print(txt2,centre_text(txt2,0),102,7)
		else
			print(txt1,centre_text(txt1,0),99,7)
		end
		
		palt()
		txt='🅾️+❎ start'
		col=14
		if(txt3!='')col=5
		bprint(txt,centre_text(txt,2),120,col,0)
	elseif state=="how to play" then
		board()
		characters()
		guesses()
		how_to_play()
	elseif state=="play" then
		board()
		characters()
		guesses()
		if show_solution then
			for s=1,#solution do
				print(solution[s].name,0,s*8,11)
			end
		end
	elseif state=="win" then
		board()
		characters()
		guesses()
		transition("gOT IT!",3)
	elseif state=="lose" then
		board()
		characters()
		guesses()
		transition("nOT THIS TIME...",14)
	end

	timer_draw_actions()
end

function play_controls()
	if btnp_r then 
		if cursor==20 and aid then
			cursor=15
		elseif cursor==20 then
			cursor=16
		elseif cursor==14 then
			cursor=9
		elseif cursor==8 then
			cursor=1
		elseif cursor < #chars then
			cursor+=1
		else 
			cursor=1
		end
	end
	if btnp_l then 
		if cursor==9 then
			cursor=14
		elseif cursor==16 and aid==false then
			cursor=20
		elseif cursor > 1 then
			cursor-=1
		else 
			cursor=8
		end
	end
	if btnp_u then
		if cursor==1 or cursor==8 then
			--nothing
		elseif cursor==2 then 
			if aid then
				cursor=15
			else
				cursor=9
			end
		elseif cursor>2 and cursor<8 then
			cursor=13+cursor
		elseif cursor>8 and cursor<15 then
			cursor-=7
		elseif cursor>15 and cursor<21 then
			cursor-=6
		end
	end
	if btnp_d then
		if cursor==1 or cursor==8 then
			--nothing
		elseif cursor>1 and cursor<8 then
			cursor+=7
		elseif cursor==9 then
			if aid then
				cursor=15
			else
				cursor=2
			end
		elseif cursor>9 and cursor<15 then
			cursor+=6
		elseif cursor>14 and cursor<21 then
			cursor=cursor-13
		end
	end
	if btnp_o and ((#guess%5==0 and #timers==0) or #guess%5!=0) then
		sfx(0)
		--add char to current spot
		if chars[cursor].type != "aid" then
			tempchars=deepcopy(chars)
			add(guess,tempchars[cursor])
			guess[#guess].result='guess'
			
			if #guess%5==0 then
				check=true
			end
			
			if chars[cursor].type=="hero" or chars[cursor].type=="npc" or chars[cursor].name=="thief" then
				dir="bump right"
			else
				dir="bump left"
			end
			add(timers,{length=1,speed=1,current=0,lag=0,tag=dir})
			add(timers,{length=6,speed=1,current=0,lag=2,tag="guess pop",val=#guess-1})
		else
			--wand behaviour
			--r=flr(rnd(2))
			r=1
			no_guess=0
			for g=1,#chars do
				if (chars[g].result=="none") no_guess+=1
			end
			if r==1 then
				-- 1. reveal 4 if possible
				if no_guess > 4 then 
					reveals=4
				else
					reveals=no_guess
				end
				placed=0
				-- infinite loop somewhere
				inf_break=0
				no_more=false
				while placed < reveals or inf_break >= 120 and not no_more do
					for g=1,#chars do
						if flr(rnd(3))==1 and chars[g].result=="none" then
							any_right=0
							for s=1,5 do
								if chars[g].name==solution[s].name then
									any_right+=1
								end
							end
							if any_right==0 then
								chars[g].result="wrong"
								placed+=1
							end
						end
						if (placed>=reveals) no_more=true break
					end
					inf_break+=1
				end

			else
				-- 2. ??
			end
			aid=false
			for c=1,#chars do
				if chars[c].name=="wand" then
					chars[c].result="no aid"
					chars[c].spr=16
				end
			end
			cursor+=1
		end
		add(timers,{length=2,speed=1,current=0,lag=0,tag="button press"})
		add(timers,{length=10,speed=1,current=0,lag=0,tag="select text",val=cursor})	
	elseif btnp_x then
		sfx(1)
		--delete last placed char
		if #guess%5 > 0 then
			del(guess,guess[#guess])
		end
	end
	if (#timers == 0 and check) check_guesses(#guess/5-1)
end

function how_to_play()
	fillp(▒)
	rectfill(0,0,127,127,1)
	fillp()
	if (trans_drop) then
		tv*=tf -- friction
		ty+=tv
		if ty>=0 then
			trans_drop=false
			ty=0
		end
	end
	rectfill(19,6+ty,107,101+ty,0)
	palt(14,true)
	palt(0,false)
	spr(236,25,ty-1)
	spr(236,99,ty-1)
	for edge=0,11 do
		spr(233,18,9+ty+edge*8)
		spr(233,104,9+ty+edge*8)
	end
	for edge=0,10 do
		spr(232,18+edge*8,4+ty)
		spr(232,18+edge*8,100+ty)
	end
	palt()
	if htp==0 then
		txt="how to play"
		print(txt,centre_text(txt,0),12+ty,1)
		print(txt,centre_text(txt,0),11+ty,7)
		txt="guess the dungeon"
		print(txt,centre_text(txt,0),20+ty,9)
		txt="in 6 tries"
		print(txt,centre_text(txt,0),27+ty,9)

		example={chars[2],chars[1],chars[6],chars[7],chars[8]}
		pos=1
		for s=1,5 do
			if s==1 then
				tile_col='right'
				tile_style='deep'
			else
				tile_col='none'
				tile_style='blank'
			end
			shspr(example[s].spr,21+pos*13,45+ty,example[s].palt,false,tile_col,tile_style)
			pos+=1
		end
		txt="green = correct"
		print(txt,centre_text(txt,0),36+ty,7)
		txt="green          "
		print(txt,centre_text(txt,0),36+ty,11)

		example={chars[10],chars[2],chars[18],chars[4],chars[5]}
		pos=1
		for s=1,5 do
			if s==3 then
				tile_col='close'
				tile_style='deep'
			else
				tile_col='none'
				tile_style='blank'
			end
			shspr(example[s].spr,21+pos*13,67+ty,example[s].palt,false,tile_col,tile_style)
			pos+=1
		end

		txt="yellow = close"
		print(txt,centre_text(txt,0),58+ty,7)	
		txt="yellow        "
		print(txt,centre_text(txt,0),58+ty,10)

		example={chars[9],chars[1],chars[17],chars[8],chars[12]}
		pos=1
		for s=1,5 do
			if s==5 then
				tile_col='wrong'
				tile_style='deep'
			else
				tile_col='none'
				tile_style='blank'
			end
			shspr(example[s].spr,21+pos*13,89+ty,example[s].palt,false,tile_col,tile_style)
			pos+=1
		end
		txt="pink = wrong"
		print(txt,centre_text(txt,0),80+ty,7)
		txt="pink        "
		print(txt,centre_text(txt,0),80+ty,14)
	else
		txt="but there's a catch!"
		print(txt,centre_text(txt,0),12+ty,1)
		print(txt,centre_text(txt,0),11+ty,7)

		txt="dungeons follow a"
		print(txt,centre_text(txt,0),20+ty,9)
		txt="set of secret rules!"
		print(txt,centre_text(txt,0),27+ty,9)

		txt="first ones are"
		print(txt,centre_text(txt,0),36+ty,7)
		txt="on the house:"
		print(txt,centre_text(txt,0),43+ty,7)
		
		rectfill(24,51+ty,102,64+ty,9)
		txt="at least 1 hero"
		print(txt,centre_text(txt,0),52+ty,0)
		txt="and 1 monster"
		print(txt,centre_text(txt,0),59+ty,0)

		rectfill(24,67+ty,102,80+ty,9)
		txt="some show only"
		print(txt,centre_text(txt,0),68+ty,0)
		txt="with others"
		print(txt,centre_text(txt,0),75+ty,0)

		rectfill(24,83+ty,102,96+ty,9)
		txt="some only appear"
		print(txt,centre_text(txt,0),84+ty,0)
		txt="in specific slots"
		print(txt,centre_text(txt,0),91+ty,0)		
	end
end

function transition(title,col)
	-- fillp(0b0011001111001100)
	fillp(▒)
	rectfill(0,0,127,127,1)
	fillp()
	if (trans_drop) then
		tv*=tf -- friction
		ty+=tv
		if ty>=0 then
			trans_drop=false
			ty=0
		end
	end
	rectfill(19,6+ty,107,101+ty,0)
	palt(14,true)
	palt(0,false)
	spr(236,25,ty-1)
	spr(236,99,ty-1)
	for edge=0,11 do
		spr(233,18,9+ty+edge*8)
		spr(233,104,9+ty+edge*8)
	end
	for edge=0,10 do
		spr(232,18+edge*8,4+ty)
		spr(232,18+edge*8,100+ty)
	end
	palt()
	if(state=="win") then
		tx=52
	elseif(state=="lose") then
		tx=33
	end
	
	if mode=='stats' then
		print(title,tx,11+ty,col)

		print(plays,34,43+ty,7)
		print(wins,62,43+ty,7)
		print(streak,90,43+ty,7)
		print('PLAYS',26,50+ty,6)
		print('WINS',56,50+ty,6)
		print('STREAK',80,50+ty,6)

		print('SPOILS',52,60+ty,6)
		print(spoils_heroes,30,68+ty,7)
		print(spoils_monsters,52,68+ty,7)
		print(spoils_treasure,74,68+ty,7)
		print(hards,96,68+ty,7)
		
		print('PLAYS',26,50+ty,6)
		spr(28,28,76+ty)
		spr(29,49,76+ty)
		spr(30,71,76+ty)
		spr(14,95,76+ty)

		pos=1
		for s=1,5 do
			tile_col='right'
			tile_style='deep'
			if state=="lose" then
				tile_col='none'
				tile_style='blank'
			end
			shspr(solution[s].spr,21+pos*13,22+ty,solution[s].palt,false,tile_col,tile_style)
			pos+=1
		end
		txt='❎ share result'
		print(txt,centre_text(txt,1),86+ty,7)
	else
		newline=0
		offx=0
		print("DUNGLEON",48,11+ty,7)
		print("L",64,11+ty,14)

		mlist={'jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'}
		mth=mlist[stat(91)]
	end		
		
	if mode=='result single' then
		-- DD MON YY
		txt=tostr(stat(92))..' '..mth..' '..tostr(stat(90)-2000)
		print(txt,centre_text(txt,0),19+ty,7)
		if(hardmode) then
			txt=tostr(flr(#guess/5))..'/6 '
			print(txt,centre_text(txt,0),27+ty,7)
			spr(14,70,28+ty)
		else
			txt=tostr(flr(#guess/5))..'/6'
			print(txt,centre_text(txt,0),27+ty,7)
		end
		if #guess > 0 then
			for i=1,#guess do
				r=guess[i].result
				if(r=='wrong') sprt=44
				if(r=='right') sprt=45
				if(r=='close') sprt=46
				spr(sprt,40+7*(i-newline*5),35+7*newline+ty)
				if(i%5==0) newline+=1
			end
			if #guess < 30 then
				for i=#guess+1,30 do
					spr(47,40+7*(i-newline*5),35+7*newline+ty)
					if(i%5==0) newline+=1
				end
			end
		end
		txt='❎ view stats'
		print(txt,centre_text(txt,1),86+ty,7)
	elseif mode=='result eight' then
		txt=tostr(stat(92))..' '..mth..' '..tostr(stat(90)-2000)
		print(txt,centre_text(txt,0),19+ty,7)
		
		avg=0
		for er=1,#eight_results do
			avg+=#eight_results[er]/5
		end
		avg=avg/#eight_results
		avg=flr((avg+0.05)*10)/10
		decimal=''
		if(avg%flr(avg)==0) decimal='.0'
		txt='AVG '..tostr(avg)..decimal
		print(txt,43,27+ty,7)
		spr(14,75,28+ty)
		print(tostr(hards),81,27+ty,3)
		
		if #eight_results > 0 then
			for g=1,#eight_results do
				er=eight_results[g]
				newline=0
				offx=0
				y=35
				if(g>4) y=59 offx=4
				for i=1,#er do
					r=er[i].result
					if(r=='wrong') sprt=60
					if(r=='right') sprt=61
					if(r=='close') sprt=62					
					spr(sprt,20+4*(i-newline*5)+(g-1-offx)*20,y+4*newline+ty)
					if(i%5==0) newline+=1
				end
				if #er < 30 then
					for i=#er+1,30 do
						spr(63,20+4*(i-newline*5)+(g-1-offx)*20,y+4*newline+ty)
						if(i%5==0) newline+=1
					end
				end
			end
		end
		if #eight_results<8 then
			for g=#eight_results+1,8 do
				newline=0
				if g<5 then
					for i=1,30 do
						spr(59,20+4*(i-newline*5)+(g-1)*20,35+4*newline+ty)
						if(i%5==0) newline+=1
					end
				else
					for i=1,30 do
						spr(59,20+4*(i-newline*5)+(g-5)*20,59+4*newline+ty)
						if(i%5==0) newline+=1
					end
				end
			end
		end
		txt='❎ view stats'
		print(txt,centre_text(txt,1),86+ty,7)
	end

	if(modes[mode_pos]=='single' or eight_level>lvl_lmt) then
		txt='🅾️+❎ main menu'
	else
		txt='🅾️+❎ next dungleon'
	end
	print(txt,centre_text(txt,2),92+ty,9)
end

function shspr(s,x,y,pl,hl,m,bg)
	-- shadow sprite
	-- s = sprite number
	-- x = x position
	-- y = y position
	-- pl = transparency colour
	-- hl = highlight
	-- m = match
	-- bg = background style
	local highlighter=hl
	s1=0
	if highlighter then
		if m=="none" then
			s1=168
		elseif m=="wrong" then
			s1=170
		elseif m=="close" then
			s1=172
		elseif m=="right" then
			s1=174
		elseif m=="yes aid" then
			s1=140
		end
	elseif bg=="blank" then
		s1=128
	else
		if bg == "flat" then
			if m=="none" then
				s1=160
			elseif m=="guess" then
				s1=128
			elseif m=="wrong" then
				s1=162
			elseif m=="close" then
				s1=164
			elseif m=="right" then
				s1=166
			elseif m=="no aid" then
				s1=142
			elseif m=="yes aid" then
				s1=138
			end
		else
			if m=="wrong" then
				s1=130
			elseif m=="close" then
				s1=132
			elseif m=="right" then
				s1=134
			end
		end
	end
	if(s1!=0) then
		spr(s1,x-2,y-2)
		spr(s1+1,x+6,y-2)
		spr(s1+16,x-2,y+6)
		spr(s1+17,x+6,y+6)
	end

	for i=0,15 do
		pal(i,0)
	end
	palt(0,false)
	palt(pl,true)

	spr(s,x-1,y)
	spr(s,x,y-1)
	spr(s,x,y+1)	
	spr(s,x+1,y)
	
	pal()
	palt(0,false)
	palt(pl,true)
	spr(s,x,y)
	palt()
end

function board()
	bx=13
	by=13
	of=32
	local b1=0
	local b2=0
	print("DUNGLEON",32,0,7)
	print("L",48,0,14)
	--hearts [optimise]
	if hearts==3 then
		spr(12,74,1)
		spr(12,80,1)
		spr(12,86,1)
	elseif hearts>=2 then
		spr(12,74,1)
		spr(12,80,1)
		if (hearts==2.5) spr(13,86,1)
	elseif hearts>=1 then
		spr(12,74,1)
		if (hearts==1.5) spr(13,80,1)
	elseif hearts==0.5 then
		spr(13,74,1)
	end
	--hard mode gem
	if (hardmode) spr(14,92,1)
	
	for x=0,4 do
		for y=0,5 do
			sx=bx*x
			sy=by*y
			result="none"
			-- backgrounds based on guesses
			if result=="none" then
				b1=128
				b2=144
			elseif result=="wrong" then
				b1=130
				b2=146
			elseif result=="close" then
				b1=132
				b2=148
			elseif result=="right" then
				b1=134
				b2=150
			end
			spr(b1,of+sx,7+sy)
			spr(b1+1,of+sx+8,7+sy)
			spr(b2,of+sx,7+sy+8)
			spr(b2+1,of+sx+8,7+sy+8)
		end
	end
end

function characters()
	for i=1,#chars do
		if cursor == i then
			highlight=true
		else
			highlight=false
		end
		ch=chars[i]
		if i>14 then
			shspr(ch.spr,2+13*(i-13),114,ch.palt,highlight,ch.result,'flat')
		elseif i>8 then
			shspr(ch.spr,2+13*(i-7),101,ch.palt,highlight,ch.result,'flat')
		else
			shspr(ch.spr,2+13*i,88,ch.palt,highlight,ch.result,'flat')
		end
	end
end

function guesses()
	newline=0
	offx=0
	if #guess > 0 then
		for i=1,#guess do
			highlight=false
			shspr(guess[i].spr,21+13*(i-newline*5),9+13*newline,guess[i].palt,highlight,guess[i].result,'deep')
			if(guess[i].more=='p') spr(15,27+13*(i-newline*5),8+13*newline)
			if(i%5==0) newline+=1
		end
	end
end

function check_guesses(row)
	right=0
	wiz_check=0
	
	num_sol=count_chars(solution)
	for n=#num_sol,1,-1 do
		if(num_sol[n].num==0) del(num_sol,num_sol[n])
	end

	num_guess=count_chars(guess)
	for n=#num_guess,1,-1 do
		if(num_guess[n].num==0) del(num_guess,num_guess[n])
	end

	-- correct and wrong
	for g=1,5 do
		gg=guess[g+row*5]
		if gg.name==solution[g].name then
			gg.result='right'
			for s=1,#num_sol do
				if num_sol[s].name==gg.name then
					num_sol[s].num-=1
				end
			end
			for s=1,#num_guess do
				if num_guess[s].name==gg.name then
					num_guess[s].num-=1
				end
			end
			if(gg.name=="mage") wiz_check+=1		
			right+=1
		-- elseif guess[g+row*5].result!='close' then
		else
			gg.result='wrong'
		end
	end
	
	-- close
	-- only flag close if there are remaining correct guesses
	-- 1. check the name matches but is incorrect spot
	-- 2. check there are remaining guesses and they haven't been guessed
	-- 3. 
	for g=1,5 do
		gg=guess[g+row*5]
		for s=1,5 do
			if 	gg.name!=solution[g].name and
			gg.name==solution[s].name then
				if #num_guess>0 and #num_sol>0 then
					for ns=1,#num_sol do
						nsn=num_sol[ns]
						if 	nsn.name==gg.name and
							nsn.num>0 then
							for ng=1,#num_guess do
								ngn=num_guess[ng]
								if 	ngn.name==gg.name and
									ngn.num>0 then
										gg.result='close'
										nsn.num-=1
										ngn.num-=1
								end
							end
						end
					end
				end				
			end
		end
	end

	hard_check={}
	if row>0 then
		for g=1,5 do
			if guess[g+(row-1)*5].result!='wrong' then
				hard_check[g]=guess[g+(row-1)*5].name
			end
		end
		for g=1,5 do
			for h=#hard_check,1,-1 do
				if hard_check[h]==guess[g+row*5].name then
					del(hard_check,hard_check[h])
				end
			end
		end
	end
	if(#hard_check>0)hardmode=false

	for g=1,5 do
		gg=guess[g+row*5]
		for c=1,#chars do
			if gg.name==chars[c].name then
				chars[c].result=gg.result
			end
		end
	end

	for g=1,5 do
		gg=guess[g+row*5]
		gg.more=''
		if gg.result!='wrong' then
			temp_name=gg.name
			guess_cnt=0
			sol_cnt=0
			for s=1,#num_sol do
				if num_sol[s].name==gg.name then
					sol_cnt=num_sol[s].num
				end
			end
			for s=1,#num_guess do
				if num_guess[s].name==gg.name then
					guess_cnt=num_guess[s].num
				end
			end
			if guess_cnt<sol_cnt then
				gg.more='p'
			end
		end
	end

	if right==5 then
		state='win'
		if(hardmode) hards+=1
		if(modes[mode_pos]=='eight') add(eight_results,guess)
		mode='stats'
		ty=-50
		tv=6
		wins+=1
		plays+=1
		streak+=1
		trans_drop=true
		for g=1,5 do
			if(guess[g].type=="monster") spoils_monsters+=1
			if(guess[g].type=="loot") spoils_treasure+=1
			if(guess[g].type=="hero") spoils_heroes+=1
		end
		
	end
	if (right==4 or wiz_check>0) and first_aid then
		aid=true
		first_aid=false
		for c=1,#chars do
			if chars[c].name=="wand" then
				chars[c].result="yes aid"
				chars[c].spr=32
			end
		end
	end
	check=false
	hearts-=0.5
	if #guess>=30 and right<5 then
		state="lose"
		if(modes[mode_pos]=='eight') add(eight_results,guess)
		if(hardmode) hards+=1
		mode='stats'
		ty=-50
		tv=6
		trans_drop=true
		plays+=1
		streak=0
	end
end

function timer_draw_actions()
	for t=1,#timers do
		tt=timers[t]
		if tt.current > tt.lag then
			if tt.tag == "bump right" then
				camera(tt.current,0)
			elseif tt.tag == "bump left" then
				camera(-tt.current,0)
			elseif tt.tag == "bump up" then
				camera(0,-tt.current)
			elseif tt.tag == "bump down" then
				camera(0,tt.current)
			else
				camera(0,0)
			end
			if tt.tag == "button press" then
				for i=1,#chars do
					if cursor == i then
						if i>14 then
							cx=2+13*(i-13)
							cy=114
						elseif i>8 then
							cx=2+13*(i-7)
							cy=101
						else
							cx=2+13*i
							cy=88
						end
					end
				end
				pal(5,0)
				spr(128,cx-2,cy-2)
				spr(129,cx+6,cy-2)
				spr(144,cx-2,cy+6)
				spr(145,cx+6,cy+6)
				pal()
			end
			if tt.tag == "select text" then
				name=chars[tt.val].name
				y=79
				if(#guess > 25) y=66
				bprint(name,centre_text(name,0),y,7,1)
			end
			if tt.tag == "guess pop" then
				s1=192
				s2=208
				palt(14,true)
				palt(0,false)
				sx=tt.val%5*13+31
				sy=flr(tt.val/5)*13+6
				spr(s1,sx,sy)
				spr(s1+1,sx+8,sy)
				spr(s2,sx,sy+8)
				spr(s2+1,sx+8,sy+8)
				palt()
			end
			if tt.tag=="circle fill" then
				-- fillp(▒)
				circfill(64,tt.val,tt.current,0)
			end
		end
	end
	if(#timers==0) camera(0,0)
end

-- utilities
function bprint(str,x,y,c1,c2)
	color(c2)
	print(str,x-1,y-1)
	print(str,x-1,y)
	print(str,x,y-1)
	print(str,x-1,y+1)
	print(str,x+1,y+1)
	print(str,x+1,y)
	print(str,x,y+1)
	print(str,x+1,y-1)

	print(str,x,y,c1)
end

function centre_text(str,special_chars)
	pos=((32*4)-(#str*4+special_chars*4))/2
	return pos
end

function deepcopy(orig)
	--copy a list to another without keeping the references to the original
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
__gfx__
0000000077e8cccc88bee88eeaaaaeee7674444eeeae9eaedddeeccce22e2eeea2222a7aa22aa6a6aaaaaa6aeeeeeeee0e0800000e0000000b30000007000000
00000000e77c1c1ce8bbb008eb3888ee76766644eeaabaaed2eeecfeeee11122222222672222a6767777a65aeebbbeeeeee88000eee00000b7b3000077700000
00700700ee666666bb0bbb083b3aaaae777cfcf45644f44ed7ee7ceee22111e2a7e732677e7326760707a65aeb333bee0e8800000e8000003b33000057500000
00077000ea00b0be9070700883ac6caeed4ffffe65f1f1fe70d707ee27e7112e233332673e332646777aa659b333331e00800000008000000330000005000000
00077000ea777cccbb000bbd836666ee47ef77eeccf444fee7dd721e707072e223332a332332034aa77aa99ab300031e00000000000000000000000000000000
007007005a55571cdbb3b0088386777e4d44ff4ecc49994eeeec212ecccc2e2eaa111a3323324033aa22977ab333331e00000000000000000000000000000000
00000000ea777c1cbbb3b008e388767eed4aaa4ecc99999eecc2ee2ecece2e2e336667aaaa44403377a2277ae13331ee00000000000000000000000000000000
00000000ea2e2eceeddedd8e8388767eede4e4eecc99999eee2ee2ee8e82ee2e3377733a330aa04a77a22aaaee111eee00000000000000000000000000000000
bbb65bbbeeeeeeeeeee9999ebb99bbbbee7eee7eeeeeeeeeaaaaeeaabbbbbbbbbbbbb7bbbebebbeb00000000eeeeeeee00a77700003333000009900000000000
bb6505bbeeee99eeeee00009baabbbbbe7073707e88888deaa1ceeea111111bbb44b7e7beb777bbd00000000ee888eee45a1117000838500009aa90000000000
bbb65bbbeee9aa9eeef90009b99bbbbbe373337e8888788e1117cccab111111bb40447bbee8787be00000000e82228ee00accc00003530000049900000000000
bbd001bbeeee994eeed5aa09bbaabbbbee333333767688ee111cc7cab108e81b4000a0abee607bdb000000008202021e000000000003300009aa400000000000
bbbd1bbbe66e4aa9eef94409bae89babe9aaaab3787882ee1c8ccc1abb11ee1b47074a4bee5072be000000008220221e00000000000000000099000000000000
bbbd1bbb6666e99eeed5aa9ea8889acae99aaab38888002ea88cc11a1766aa33b4044334e277222e000000008202021e00000000000000000000000000000000
bbbd1bbb5665eeeee9999944a829bad9eb999be32022222eaaaaa1aa10777a334044433baa20227700000000e12221ee00000000000000000000000000000000
bbbd1bbbe55eeeeee999994eb99bbb9bbeeebe33707ddd8ecaaaaaca1111144b44044abbe220222200000000ee111eee00000000000000000000000000000000
bbb7fbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222200333333009999990011111100
bb7e2fbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000002eeee2003bbbb3009aaaa90015555100
bbb7fbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000002eeee2003bbbb3009aaaa90015555100
bba009bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000002eeee2003bbbb3009aaaa90015555100
bbba9bbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000002eeee2003bbbb3009aaaa90015555100
bbba9bbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222200333333009999990011111100
bbba9bbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbba9bbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000005550000022200000333000009990000011100000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505000002e2000003b3000009a90000015100000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000005550000022200000333000009990000011100000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbb000000000000bbbbbbbbbbbbbbbbbbbbbbbbbb0111111500000000000000000000000000000000000000000000000051111110
bbbbbbbbbbbbbbbbbbbbbb00000111111111100000bbbbbbbbbbbbbbbbbbbbbb0111111500000000000000000000000000000000000000000000000051111110
bbbbbbbbbbbbbbbbbbb00011110111111111101111000bbbbbbbbbbbbbbbbbbb0111111500000000000000000000000000000000000000000000000051111110
bbbbbbbbbbbbbbbbb001111111011111111110111111100bbbbbbbbbbbbbbbbb0000000500000000000000000000000000000000000000000000000050000000
bbbbbbbbbbbbbbb0001111111110111111110111111111000bbbbbbbbbbbbbbb0111111500000000000000000000000000000000000000000000000051111110
bbbbbbbbbbbbbb011011111111101111111101111111110110bbbbbbbbbbbbbb0111111500000000000000000000000000000000000000000000000051111110
bbbbbbbbbbbbb01111011111111011111111011111111011110bbbbbbbbbbbbb0111111500000000000000000000000000000000000000000000000051111110
bbbbbbbbbbb001111101111111155555555551111111101111100bbbbbbbbbbb0111111500000000000000000000000000000000000000000000000051111110
bbbbbbbbbb01111111101115555000000000055551110111111110bbbbbbbbbb0111111500000000000000000000000000000000000000000000000051111110
bbbbbbbbb0111111111155500000000000000000055011111111110bbbbbbbbb0111111500000000000000000000000000000000000000000000000051111110
bbbbbbbb010111111115500000000000000000000005511111111010bbbbbbbb0111111500000000000000000000000000000000000000000000000051111110
bbbbbbb01110111111500000000000000000000000000511111101110bbbbbbb0111111500000000000000000000000000000000000000000000000051111110
bbbbbbb01111011155000000000000000000000000000055111011110bbbbbbb0000000500000000000000000000000000000000000000000000000050000000
bbbbbb0111111015000000000000000000000000000000005101111110bbbbbb0111111500000000000000000000000000000000000000000000000051111110
bbbbb011111111500000000000000000000000000000000005111111110bbbbb0111111500000000000000000000000000000000000000000000000051111110
bbbb01111111150000000000000000000000000000000000005111111110bbbb0111111500000000000000000000000000000000000000000000000051111110
bbbb01111111500000000000000000000000000000000000000511111110bbbb0111111500000000000000000000000000000000000000000000000051111110
bbb0001111115000000000000000000000000000000000000005111111000bbb0111111500000000000000000000000000000000000000000000000051111110
bbb0110011150000000000000000000000000000000000000000511100110bbb0111111500000000000000000000000000000000000000000000000051111110
bb011111005000000000000000000000000000000000000000000500111110bb0111111500000000000000000000000000000000000000000000000051111110
bb011111115000000000000000000000000000000000000000000511111110bb0111111500000000000000000000000000000000000000000000000051111110
bb011111150000000000000000000000000000000000000000000051111110bb0000000500000000000000000000000000000000000000000000000050000000
b01111111500000000000000000000000000000000000000000000511111110b0111111500000000000000000000000000000000000000000000000051111110
b01111115000000000000000000000000000000000000000000000051111110b0111111500000000000000000000000000000000000000000000000051111110
b01111115000000000000000000000000000000000000000000000051111110b0111111500000000000000000000000000000000000000000000000051111110
b01111115000000000000000000000000000000000000000000000051111110b0111111500000000000000000000000000000000000000000000000051111110
01000111500000000000000000000000000000000000000000000005111000100111111500000000000000000000000000000000000000000000000051111110
01111005000000000000000000000000000000000000000000000000500111100111111500000000000000000000000000000000000000000000000051111110
01111115000000000000000000000000000000000000000000000000511111100111111500000000000000000000000000000000000000000000000051111110
01111115000000000000000000000000000000000000000000000000511111100111111500000000000000000000000000000000000000000000000051111110
01111115000000000000000000000000000000000000000000000000511111100000000500000000000000000000000000000000000000000000000050000000
01111115000000000000000000000000000000000000000000000000511111100111111500000000000000000000000000000000000000000000000051111110
05555555555000000eeeeeeeeee000000aaaaaaaaaa000000bbbbbbbbbb000000666666666600000000055550000000000006666000000000000111100000000
5000000000050000e2222222222e0000a9999999999a0000b3333333333b00006666666666660000005555555500000000666666660000000011000011000000
50000000000500002222222222220000999999999999000033333333333300006666666666660000055555555550000006666666666000000100000000100000
50000000000500002222222222220000999999999999000033333333333300006666666666660000055555555550000006666666666000000100000000100000
50000000000500002222222222220000999999999999000033333333333300006666666666660000555555555555000066666666666600001000000000010000
50000000000500002222222222220000999999999999000033333333333300006666666666660000555555555555000066666666666600001000000000010000
50000000000500002222222222220000999999999999000033333333333300006666666666660000555555555555000066666666666600001000000000010000
50000000000500002222222222220000999999999999000033333333333300006666666666660000555555555555000066666666666600001000000000010000
50000000000500002222222222220000999999999999000033333333333300006666666666660000055555555550000006666666666000000100000000100000
50000000000500002222222222220000999999999999000033333333333300006666666666660000055555555550000006666666666000000100000000100000
50000000000500001222222222210000199999999991000013333333333100006666666666660000005555555500000000666666660000000011000011000000
05555555555000000111111111100000011111111110000001111111111000000666666666600000000055550000000000006666000000000000111100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
055555555550000002222222222000000999999999900000033333333330000006666666666000000eeeeeeeeee000000aaaaaaaaaa000000bbbbbbbbbb00000
55555555555500002222222222220000999999999999000033333333333300006666666666660000eeeeeeeeeeee0000aaaaaaaaaaaa0000bbbbbbbbbbbb0000
55555555555500002222222222220000999999999999000033333333333300006666666666660000eeeeeeeeeeee0000aaaaaaaaaaaa0000bbbbbbbbbbbb0000
55555555555500002222222222220000999999999999000033333333333300006666666666660000eeeeeeeeeeee0000aaaaaaaaaaaa0000bbbbbbbbbbbb0000
55555555555500002222222222220000999999999999000033333333333300006666666666660000eeeeeeeeeeee0000aaaaaaaaaaaa0000bbbbbbbbbbbb0000
55555555555500002222222222220000999999999999000033333333333300006666666666660000eeeeeeeeeeee0000aaaaaaaaaaaa0000bbbbbbbbbbbb0000
55555555555500002222222222220000999999999999000033333333333300006666666666660000eeeeeeeeeeee0000aaaaaaaaaaaa0000bbbbbbbbbbbb0000
55555555555500002222222222220000999999999999000033333333333300006666666666660000eeeeeeeeeeee0000aaaaaaaaaaaa0000bbbbbbbbbbbb0000
55555555555500002222222222220000999999999999000033333333333300006666666666660000eeeeeeeeeeee0000aaaaaaaaaaaa0000bbbbbbbbbbbb0000
55555555555500002222222222220000999999999999000033333333333300006666666666660000eeeeeeeeeeee0000aaaaaaaaaaaa0000bbbbbbbbbbbb0000
55555555555500002222222222220000999999999999000033333333333300006666666666660000eeeeeeeeeeee0000aaaaaaaaaaaa0000bbbbbbbbbbbb0000
055555555550000002222222222000000999999999900000033333333330000006666666666000000eeeeeeeeee000000aaaaaaaaaa000000bbbbbbbbbb00000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e555555555555eee55555555555555550000000000000000dddd0ddddddd0dddbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
50000000000005eeddddddddddddddd56666666666666660111d0111111d0111b0000000b00000000000000000000000000bb000000000000000000000bbbbbb
50eeeeeeeeee05ee01111111111111d51555555555555560111d0111111d0111b06666600660666066006600666600eeee0b0066666006666006600660bbbbbb
50eeeeeeeeee05ee01111111111111d515555555555555600000000000000000b06606660660666066606606666660eeee0b0666666066066606660660bbbbbb
50eeeeeeeeee05ee01111111111111d51555555555555560ddddddd0ddddddd0b06606660660666066666606606660eeee0b0666000066066606666660bbbbbb
50eeeeeeeeee05ee01111111111111d51555555555555560111111d0111111d0b06606660660666066666606600000eeee0b0666666066066606666660bbbbbb
50eeeeeeeeee05ee01111111111111d51555555555555560111111d0111111d0b06606660660666066666606606660eeee0b0666666066066606666660bbbbbb
50eeeeeeeeee05ee00000000000000d511111111111111600000000000000000b06606660660666066666606600660eeee000666000066066606666660bbbbbb
50eeeeeeeeee05ee55555555555555550000000000000000ddd0ddddddd0ddddb06606660666666066066606666660eeeeee0666666066066606606660bbbbbb
50eeeeeeeeee05eeddddddd5dddddddd666666606666666611d0111111d01111b06666600066660066006600666660eeeeee0066666006666006600660bbbbbb
50eeeeeeeeee05ee111111d501111111555555601555555511d0111111d01111b0000000b0000000000000000000000000000000000b000000b0000000bbbbbb
50eeeeeeeeee05ee111011d50111100155555560155555550000000000000000b000000bbb0000bb00bb00bb00000b000000bb00000bb0000bb00bb00bbbbbbb
50000000000005ee111101d50111011155555560155555550ddddddd0dddddddbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
e555555555555eee111111d50111111155555560155555550111111d0111111dbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
eeeeeeeeeeeeeeee101111d50111111155555560155555550111111d0111111dbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
eeeeeeeeeeeeeeee000000d50000000011111160111111110000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
5555555555555555555555555555555555555555555555555555555555555555eeeeeeeeedddeeee5050500005650eee04940eee000000000000000000000000
ddddddddddddddd5ddddddddddddddd50000000000000005ddddddddddddddd50ddddddde11deeee5000500005050eee04040eee000000000000000000000000
01111111111111d501101111111111d5011111111111110501111111111111d50111111de11deeee5060500005650eee04940eee000000000000000000000000
01111111111111d501011111111111d5011111111111110501111111111111d50111111de11deeee00500000e060eeeee090eeee000000000000000000000000
01111111111111d501111111110111d5011111111111110501111111111111d5eeeeeeeee11deeee5050500005650eee04940eee000000000000000000000000
01111111111111d501101111110111d5011111111111110501111111111111d5eeeeeeeee11deeee5000500005050eee04040eee000000000000000000000000
01111111111111d501111111101111d5011111111111110501111111111111d5eeeeeeeee11deeee5060500005650eee04940eee000000000000000000000000
00000000000000d500000000000000d5000000000000000500000000000000d5eeeeeeeeeeeeeeee00500000e060eeeee090eeee000000000000000000000000
55555555555555555555555555555555555555555555555555555555555555550000000000000000000000000000000000000000000000000000000000000000
ddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5dddddddd0000000000000000000000000000000000000000000000000000000000000000
111111d501111111111111d501111111111111d501111111111111d5011111110000000000000000000000000000000000000000000000000000000000000000
111011d501111001111111d501111111111111d501111111111111d5011111110000000000000000000000000000000000000000000000000000000000000000
111101d501110111111111d501111111111111d501111111111111d5011111110000000000000000000000000000000000000000000000000000000000000000
111111d501111111111111d501111111111111d501111111111111d5011111110000000000000000000000000000000000000000000000000000000000000000
101111d501111111111111d501111111111111d501111111111111d5011111110000000000000000000000000000000000000000000000000000000000000000
000000d500000000000000d500000000000000d500000000000000d5000000000000000000000000000000000000000000000000000000000000000000000000
__label__
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5
01111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d5
01111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d5
01111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d5
01111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d5
01111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d5
00000000000000d500000000000000d500000000000000d500000000000000d500000000000000d500000000000000d500000000000000d500000000000000d5
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
ddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5dddddddd
111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111
111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111
111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111
111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111
111111d000000000000001d000000000000000000000000000000000000000000000000000011110000000000000000000000000000000000000000001111111
000000d000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555550066666666660000666600666666006666000066660000666666660000eeeeeeee0055000066666666660000666666660000666600006666005555555
ddddddd0066666666660000666600666666006666000066660000666666660000eeeeeeee00dd00006666666666000066666666000066660000666600dddddd5
01111110066660066666600666600666666006666660066660066666666666600eeeeeeee00110066666666666600666600666666006666660066660011111d5
01111110066660066666600666600666666006666660066660066666666666600eeeeeeee00110066666666666600666600666666006666660066660011111d5
01111110066660066666600666600666666006666666666660066660066666600eeeeeeee00110066666600000000666600666666006666666666660011111d5
01111110066660066666600666600666666006666666666660066660066666600eeeeeeee00110066666600000000666600666666006666666666660011111d5
01111110066660066666600666600666666006666666666660066660000000000eeeeeeee00110066666666666600666600666666006666666666660011111d5
00000000066660066666600666600666666006666666666660066660000000000eeeeeeee00000066666666666600666600666666006666666666660000000d5
55555550066660066666600666600666666006666666666660066660066666600eeeeeeee0055006666666666660066660066666600666666666666005555555
ddddddd0066660066666600666600666666006666666666660066660066666600eeeeeeee00dd00666666666666006666006666660066666666666600ddddddd
111111d0066660066666600666600666666006666666666660066660000666600eeeeeeee0000006666660000000066660066666600666666666666001111111
111111d0066660066666600666600666666006666666666660066660000666600eeeeeeee0000006666660000000066660066666600666666666666001111111
111111d0066660066666600666666666666006666006666660066666666666600eeeeeeeeeeee006666666666660066660066666600666600666666001111111
111111d0066660066666600666666666666006666006666660066666666666600eeeeeeeeeeee006666666666660066660066666600666600666666001111111
111111d0066666666660000006666666600006666000066660000666666666600eeeeeeeeeeee000066666666660000666666660000666600006666001111111
000000d0066666666660000006666666600006666000066660000666666666600eeeeeeeeeeee000066666666660000666666660000666600006666000000000
55555550000000000000055000000000000000000000000000000000000000000000000000000000000000000005500000000000055000000000000005555555
ddddddd00000000000000dd00000000000000000000000000000000000000000000000000000000000000000000dd000000000000dd00000000000000dddddd5
011111100000000000011111100000000111100001111000011110000000000500000000000001d500000000000111d0000000011110000501100001111111d5
011111100000000000011111100000000111100001111000011110000000000500000000000001d500000000000111d0000000011110000501100001111111d5
01111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d5
01111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d5
01111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d5
00000000000000d500000000000000d500000000000000d500000000000000d500000000000000d500000000000000d500000000000000d500000000000000d5
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
ddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5dddddddd
111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111
111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111
111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111
111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111
111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111
000000d500000000000000d500000000000000d500000000000000d500000000000000d500000000000000d500000000000000d500000000000000d500000000
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd50000000000000005ddddddddddddddd5
01111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d5011111111111110501111111111111d5
01111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d5011111111111110501111111111111d5
01111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d5011111111111110501111111111111d5
01111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d5011111111111110501111111111111d5
01111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d5011111111111110501111111111111d5
00000000000000d500000000000000d500000000000000d500000000000000d500000000000000d500000000000000d5000000000000000500000000000000d5
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
ddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5dddddddd
111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111
111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111
111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111
111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111
111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111111111d501111111
000000d500000000000000d500000000000000d500000000000000d500000000000000d500000000000000d500000000000000d500000000000000d500000000
55555555555555555555555555555555555555555555555555555555550000000000005555555555555555555555555555555555555555555555555555555555
0000000000000005ddddddddddddddd5ddddddddddddddd5dddddd00000111111111100000ddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5
011111111111110501111111111111d501111111111111d5011000111101111111111011110001d501111111111111d501111111111111d501111111111111d5
011111111111110501111111111111d501111111111111d50001111111011111111110111111100501111111111111d501111111111111d501111111111111d5
011111111111110501111111111111d501111111111111d00011111111101111111101111111110001111111111111d501111111111111d501111111111111d5
011111111111110501111111111111d501111111111111011011111111101111111101111111110110111111111111d501111111111111d501111111111111d5
011111111111110501111111111111d501111111111110111101111111101111111101111111101111011111111111d501111111111111d501111111111111d5
000000000000000500000000000000d500000000000001111101111111155555555551111111101111100000000000d500000000000000d500000000000000d5
55555555555555555555555555555555555555555501111111101115555000000000055551110111111110555555555555555555555555555555555555555555
ddddddd5ddddddddddddddd5ddddddddddddddd5d01111111111555000000000000000000550111111111105ddddddddddddddd5ddddddddddddddd5dddddddd
111111d501111111111111d501111111111111d501011111111550000000000000000000000551111111101001111111111111d501111111111111d501111111
111111d501111111111111d501111111111111d011101111115000000000000000000000000005111111011101111111111111d501111111111111d501111111
111111d501111111111111d501111111111111d011110111550000000000000000000000000000551110111101111111111111d501111111111111d501111111
111111d501111111111111d5011111111111110111111015000000000000000000000000000000005101111110111111111111d501111111111111d501111111
111111d501111111111111d5011111111111101111111150000000000000000000000000000000000511111111011111111111d501111111111111d501111111
000000d500000000000000d5000000000000011111111500000000000000000000000000000000000051111111100000000000d500000000000000d500000000
55555555555555555555555555555555555501111111500000000000000000000000000000000000000511111110555555555555555555555555555555555555
ddddddddddddddd5ddddddddddddddd5ddd0001111115000000000000000000000000000000000000005111111000dd5ddddddddddddddd5ddddddddddddddd5
01111111111111d501111111111111d501101100111500000000000000000000000000000000000000005111001101d501111111111111d501111111111111d5
01111111111111d501111111111111d501011111005000000000000000000000000000000000000000000500111110d501111111111111d501111111111111d5
01111111111111d501111111111111d501011111115000000000000000000000000000000000000000000511111110d501111111111111d501111111111111d5
01111111111111d501111111111111d501011111150000000000000000000000000000000000000000000051111110d501111111111111d501111111111111d5
01111111111111d501111111111111d5001111111500000000000000000000000000000000000000000000511111110501111111111111d501111111111111d5
00000000000000d500000000000000d5001111115000000000000000000000000000000000000000000000051111110500000000000000d500000000000000d5
55555555555555555555555555555555501111115000000000000000000000000000000000000000000000051111110555555555555555555555555555555555
ddddddd5ddddddddddddddd5ddddddddd01111115000000000000000000000000000000000000000000000051111110dddddddd5ddddddddddddddd5dddddddd
111111d501111111111111d5011111110100011150000000000000000000000000000000000000000000000511100010111111d501111111111111d501111111
111111d501111111111111d5011111110111100500000000000000000000000000000000000000000000000050011110111111d501111111111111d501111111
111111d501111111111111d5011111110111111500000000000000000000000000000000000000000000000051111110111111d501111111111111d501111111
111111d501111111111111d5011111110111111500000000000000000000000000000000000000000000000051111110111111d501111111111111d501111111
111111d501111111111111d5011111110111111500000000000000000000000000000000000000000000000051111110111111d501111111111111d501111111
000000d500000000000000d5000000000111111500000000000000000000000000000000000000000000000051111110000000d500000000000000d500000000
55555555555555555555555555555555011111150000000000000077007770777070007070000000000000005111111055555555555555555555555555555555
ddddddddddddddd5ddddddddddddddd50111111500000000000000707070700700700070700000000000000051111110ddddddddddddddd50000000000000005
01111111111111d501111111111111d5011111150022222220000070707770070070007770000002222222005111111001111111111111d50111111111111105
01111111111111d501111111111111d5000000050220000022000070707070070070000070000022000002205000000001111111111111d50111111111111105
01111111111111d501111111111111d5011111150200022002000077707070777077707770000020022000205111111001111111111111d50111111111111105
01111111111111d501111111111111d5011111150200222002000000000000000000000000000020022200205111111001111111111111d50111111111111105
01111111111111d501111111111111d5011111150200022002000770777077000770700077700020022000205111111001111111111111d50111111111111105
00000000000000d500000000000000d5011111150220000022007000070070707000700070000022000002205111111000000000000000d50000000000000005
55555555555555555555555555555555011111150022222220007770070070707000700077000002222222005111111055555555555555555555555555555555
ddddddd5ddddddddddddddd5dddddddd0111111500000000000000700700707070707000700000000000000051111110ddddddd5ddddddddddddddd5dddddddd
111111d501111111111111d5011111110111111500000000000077007770707077707770777000000000000051111110111111d501111111111111d501111111
111111d501111111111111d5011111110111111500000000000000000000000000000000000000000000000051111110111111d501111111111111d501111111
111111d501111111111111d5011111110000000500000000000000000000000000000000000000000000000050000000111111d501111111111111d501111111
111111d501111111111111d5011111110111111500000000000000000000000000000000000000000000000051111110111111d501111111111111d501111111
111111d501111111111111d5011111110111111500000000000000000000000000000000000000000000000051111110111111d501111111111111d501111111
000000d500000000000000d5000000000111111500000000000000000000000000000000000000000000000051111110000000d500000000000000d500000000
55555555555555555555555555555555011111150000000000000000000000000000000000000000000000005111111055555555555555555555555555555555
ddddddddddddddd5ddddddddddddddd50111111500000000000000000000000000000000000000000000000051111110ddddddddddddddd5ddddddddddddddd5
01111111111111d501111111111111d5011111150000000000000000000000000000000000000000000000005111111001111111111111d501111111111111d5
01111111111111d501111111111111d5011111150000000000000000000000000000000000000000000000005111111001111111111111d501111111111111d5
01111111111111d501111111111111d5011111150000000000000000000000000000000000000000000000005111111001111111111111d501111111111111d5
01111111111111d501111111111111d5000000050000000000000000000000000000000000000000000000005000000001111111111111d501111111111111d5
01111111111111d501111111111111d5011111150000000000000000000000000000000000000000000000005111111001111111111111d501111111111111d5
00000000000000d500000000000000d5011111150000000000000000000000000000000000000000000000005111111000000000000000d500000000000000d5
5555555555555555555555555555555501111115000eeeee0000000eeeee0000000ee0eee0eee0eee0eee0005111111055555555555555555555555555555555
ddddddd5ddddddddddddddd5dddddddd0111111500ee000ee00e00ee0e0ee00000e0000e00e0e0e0e00e000051111110ddddddd5ddddddddddddddd5dddddddd
111111d501111111111111d5011111110111111500ee0e0ee0eee0eee0eee00000eee00e00eee0ee000e000051111110111111d501111111111111d501111111
111111d501111111111111d5011111110111111500ee000ee00e00ee0e0ee0000000e00e00e0e0e0e00e000051111110111111d501111111111111d501111111
111111d501111111111111d50111111101111115000eeeee0000000eeeee000000ee000e00e0e0e0e00e000051111110111111d501111111111111d501111111
111111d501111111111111d5011111110111111500000000000000000000000000000000000000000000000051111110111111d501111111111111d501111111
111111d501111111111111d5011111110000000500000000000000000000000000000000000000000000000050000000111111d501111111111111d501111111
000000d500000000000000d5000000000111111500000000000000000000000000000000000000000000000051111110000000d500000000000000d500000000

__map__
e6e7e6e7e6e7e6e7e6e7e6e7e6e7e6e700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f6f7f6f7f6f7f6f7f6f7f6f7f6f7f6f700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e6e7e6e7e6e7e6e7e6e7e6e7e6e7e6e700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f6f7f6f7f6f7f6f7f6f7f6f7f6f7f6f700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e6e7e6e7e6e7e6e7e6e7e6e7e6e7e6e700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f6f7f6f7f6f7f6f7f6f7f6f7f6f7f6f700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e6e7e6e7e6e7e6e7e6e7e6e7e4e5e6e700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f6f7f6f7f6f7f6f7f6f7f6f7f4f5f6f700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e4e5e6e7e6e7c2c3e6e7e6e7e6e7e6e700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f6c2c3f7f6e6e7c2f6e6e7f7f6f7f6f700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e6f4e6e7e6f6f7e1e6f6f7e7e6e7e6e700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f6f7f6f7f6e6e7e6e7e6e7f7f6f7f6f700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e6e7e6e7e6f6f7f6f7f6f7c3e6e7e4e500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f6f7f6f7f6f7f6f7f6e6e7e6e7f7f4f500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e6e7e6e7e6e7e6e7e6f6e6e7f7e7e6e700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f6f7f6f7f6f7f6f7f6f7f6f7f6f7f6f700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100000c05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a90100000c05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b0809245701d5701c5701c5601c5501c5401c5301c5201c5100050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010200280c31500000000000000000000000000f2250000000000000000c3000c415000000000000000000000c3000000000000000000c30000000000000741500000000000c2150000000000000000c30000000
010300280000000000246250000000000000000000000000246150000000000000000c30018625000000000018000180002430018000180001800024300180001800018000000000000000000000000000000000
011000010017000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01090004180701a07015070160700c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c000000000000000000000000000000000
0109000418070160701307011070295052650529505265052d505295052950526505225051f5051d505215052e5052b50528505245052d5052d5052850528505265052e5052b5052850524505215051d50521505
0114000020734200351c7341c0351973419535157343952520734200351c7341c0351953219035147341503121734210351c7341c0261973419035237341703521734395251c7341c03519734195351773717035
011400000c043090552072409055246151972315555090550c053090651972309565207242461509065155650c053060652072406065246151672306065125650c05306065167230656520724246150606515555
011400000c053021651e7240206524615197450e7650c05302165020651e7341e7350256524615020650e56501165010651e7240c05324615167230b0450d0650c05301165197440b56520724246150106515555
0114000020724200251c7241c02525742287421572439525207242a7422c7412c7322c72219025147242a74228742287451c7341e7421e7421e735237241702521724395251c7341c03519734195351773617035
0014000020724200251c7241c02525742287421572439525207242a7422c7412c7322c72219025147242f7422d7422d7452d734217422174221735237241702521724395251c7341c03519734195351773617035
0116002006055061550d055061550d547061550d055061550d055060550615501155065470d15504055041550b055041550b547041550b055041550b0550b155040550b155045460b1550b055041550b0550b155
010b00201e4421e4321f4261e4261c4321c4221e4421e4321e4221e4221f4261e4261c4421c4321c4221c4221c4221c4221c4221c4221c4221c4221c4221c4221c4221c4221c4221c42510125101051012510105
011600001e4401e4321e4221e4250653500505065351a0241a025065351a0250653500505065351902419025045351702404535005050453500505045351e0241e025045351e0240453504535005050453504535
010b00201e4421e4361f4261e4261c4421c4421a4451c4451e4451f44521445234452644528445254422543219442194322544225432264362543623442234322144221432234472343625440234402144520445
01160000190241902506535135000653500505065351a0241a025065351a0250653506404065351902419025045351702404535005050453500505045351e0241e025045351e0240453504535005050453504535
010e000005455054553f52511435111250f4350c43511125034550345511125182551b255182551d2551112501455014552025511125111252025511125202550345520255224552325522455202461d4551b255
010e00000c0530c4451112518455306251425511255054450c0530a4353f52513435306251343518435054450c053111251b4353f525306251b4353f5251b4350c0331b4451d2451e445306251d2451844516245
010e00000145520255224552325522445202551d45503455034050345503455182551b455182551d455111250045520255224552325522455202461d4551b255014550145511125182551b455182551d45511125
010e00000c0531b4451d2451e445306251d245184450c05317200131253f52513435306251343518435014450c0431b4451d2451e445306251d245184451624511125111253f5251343530625134351843500455
010e0000004550045520455111251d125204551d1252912501455014552c455111251d1252c4551d12529125034552c2552e4552f2552e4552c2552945503455044552c2552e4552f2552e4552c246294551b221
010e00000c0530c0531b4551b225306251b4551b2250f4250c0530c05327455272253062527455272251b4250c0531b4451d2451e445306251d245184450c0530c0531b4451d2451e445306251d2451844500455
010d00000c0530445504255134453f6150445513245044550c0531344513245044553f6150445513245134450c0530445504255134453f6150445513245044550c0531344513245044553f615044551324513445
010d000028555234452d2352b5552a4452b2352f55532245395303725536540374353b2503954537430342553654034235325552f2402d5352b2502a4452b530284552624623530214551f24023535284302a245
010d00002b5552a4452823523555214451f2351e5551c4452b235235552a445232352d5552b4452a2352b555284452a235285552644523235215551f4451c2351a555174451e2351a5551c4451e2351f55523235
010d00000c0530045500255104453f6150045510245004550c0530044500245104553f6150045510245104450c0530045500255104453f6150045510245004550c0531044510245004553f615004551024500455
010d00000c0530245502255124453f6150245512245024550c0531244512245024553f6150245502255124450c0530245502255124453f6150245512245024550c0530244512245024553f615124550224512445
010d00002b5552a45528255235552b5452a44528545235452b5352a03528535235352b0352a03528735237352b0352a03528735237351f7251e7251c725177251f7151e7151c715177151371512715107150b715
010c00200c0530c235004303a324004453c3253c3240c0533c6150c0530044000440002353e5253e5250c1530c0530f244034451b323034453702437522370253c6153e5250334003440032351b3230c0531b323
010c00200c05312235064303a324064453c3253c3240c0533c6150c0530644006440062353e5253e5250c1530c05311244054451b323054453a0242e5223a0253c6153e52503345054451323605436033451b323
010c00202202524225244202432422425243252432422325223252402522420242242222524425245252422522325222242442524326224252402424522220252452524524223252442522227244262432522325
010c0000224002b4202e42030420304203042033420304203042030222294202b2202e420302202b420272202a4202a4222a42227420274202742025421274212742027420274202722027422272222742227222
010c00002a4202a4222a422274202742027422272222742527400254202a2202e4202b2202a426252202a4202742027422274222442024222244222242124421244202442024420244202422024422182210c421
011100000c3430035500345003353c6150a3300a4320a3320c3430335503345033353c6151333013432133320c3430735507345073353c6151633016432163320c3430335503345033353c6151b3301b4321b332
01110000162251b425222253751227425375122b5112e2251b4352b2402944027240224471f440244422443224422244253a512222253a523274252e2253a425162351b4352e4302e23222431222302243222232
011100000c3430535505345053353c6150f3301f4260f3320c3430335503345033353c6151332616325133320c3430735507345073353c6151633026426163320c3430335503345033353c6150f3261b3150f322
011100001d22522425272253f51227425375122b5112e225322403323133222304403043030422375112e44237442372322c2412c2322c2222c4202c4153a425162351b4352b4402b4322b220224402243222222
011100001f2401f4301f2201f21527425375122b5112e225162251b5112e2253a5122b425375122b5112e225162251b425225133021033410375223341027221162251b425222253751227425373112b3112e325
01110000182251f511242233c5122b425335122b5112e225162251b5112e2253a5122b425375122b5112e225162251b425225133021033410375223341027221162251b425222253751227425373112b3112e325
011100000f22522425272253f51227425375122b5112e2252724027232272222444024430244222b511224422b4422b23220241202322023220420204153a425162351b4351f4401f4321f2201d4401d4321d222
007800000c8410c8410c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c84018841188401884018840188401884018840188402483124830248302483024830248302483024830
01780000269542694026930185351870007525075240752507534000002495424940249301d5241d7000c5250c5242952500000000002b525000001d5241d5250a5440a5450a5440a5201a7341a7350a0350a024
017800000072400735007440075500744007350072400715007340072500000057440575505744057350572405735057440575503744037350372403735037440375503744037350372403735037440373503704
017800000a0041f734219442194224a5424a5224a45265351a5341a5350000026934269421ba541ba501ba550c5340c5450c5540c555000001f9541f9501f955225251f5341f52522a2022a3222a452b7342b725
0110002005b4008b3009b200ab3009b4008b3006b2002b3001b4006b3006b2003b3002b4003b3005b2007b3008b4009b300ab200ab300ab4009b3008b2007b3005b4003b3002b2002b3002b4002b3004b2007b30
0118042000c260cc260cc2600c2600c2600c260cc260cc260cc2600c2600c260cc260cc260cc2600c2600c260cc2600c2600c2600c260cc260cc260cc2600c260cc2600c260cc260cc2600c260cc260cc2605c26
012000200cb200fb3010b4011b5010b400fb300db2009b3008b400db500db400ab3009b200ab300cb400eb500fb4010b3011b2011b3011b4010b500fb400eb300cb200ab3015b4015b5015b4015b300bb200eb30
012c002000000000000000000000000000000000000000001372413720137201372015724157201572015722137241872418720187201872018720187201872018725187021a7241c7211c7201c7201c7201c720
012800001c7201f7241f7201f7201f7201f720157241572015720157201572015720157201572215725000001c7241c7201c7201c7201c7201f7241f7201f7201f7201f722157241572015720157201572015720
012800001572015725000001f7241c7241c7201c7201c7201c7201c72215724137211372013720137201372013720137221872418720187201872018720187201872018720187201872218725187001870018705
012000000dd650dd550dd450dd351075510745107351072500c5517d5517d4517d3517d2517d2510755107450dd650dd550dd450dd351075510745107351072500c5417d5517d4517d3517d2517d250dd250dd35
011d0c201072519d5519d4519d3519d251005510045100351002517d550f7350f7350f7250f72510725107251072519d3519d3519d2519d250b0250b0350b7350b0250b7250b72517d3517d350f7350f7350f725
0120000012d6512d5512d4512d351575515745157351572500c5510d5510d4510d3510d2510d25157551574512d6512d5512d4512d35157551574500c54157351572519d5519d4519d3519d2519d250dd250dd35
011d0c20107251ed351ed351ed351ed251503515035150251502517d35147351472514725147251572515725157251ed351ed351ed251ed2515025150351573515025157251572519d3519d350f7350f7350f725
0120000019d5519d450dd3501d551405014040147321472223d3523d450bd350bd551505015040157321572219d5519d450dd3501d551705019040197321972223d3523d450bd350bd551c0501e0401e7321e722
012000001ed551ed4512d3506d552105021040217322172228d4528d3528d2520050200521e0401e7321e7221ed551ed4512d3506d552105021040257322572228d5528d4528d3528d251c0401e0301e7221e722
0112000024e4524e3521f251ff351ff451de3524f2524f3518e451de351fe251d73018e251de351fe451d7321ff4521f3524f252973029e252be352ee4524e3524e2524e3521f451ff351ff251de352473224f35
0112000024e2524e35219451ff352192524e3524e4524f3526f2526f351fe451d73232f4532f352be25297322bf252bf352df253573235e2537e353ae4530e3530e2530e352df452bf352bf2529e253073230f35
011200002de252de352af4528f3528f2526e352df452df3521e2526e3528e452673221e3526e2528e352673228f252af352df253273232e3534e2537e352de252de352de252af3528f2528f3526e252d7322df35
011200000a0550a0350a0250a0550a0350a0250a0550a0350a0250a0550a035050250a0550a0350a0250a0550a035050250a0550a0350a0250a0550a035050250a0550a035050250a0550a035050250a0550a035
011200000505505035050250505505035050250505505035050250505505035000250505505035050250505505035000250505505035050250505505035000250505505035000250505505035000250505505035
011200000705507035070250705507035070250705507035070250705507035020250705507035070250705502035020550205502035020250205502035090250205502035090250205502035090250205502035
__music__
01 34354344
00 34354344
00 36374344
00 34384344
00 34384344
02 36394344

__change_mask__
fffffffffbfffffffbfffffffbfffffffbfffffffbfffffffbfffffffbfffffffbfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbfffffffbfffffffbfffffffbfffffffbfffffffbfffffffbfffffffbfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbfffffffbfffffffbfffffffbfffffffbfffffffbfffffffbfffffffbfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbfffffffbfffffffbfffffffbfffffffbfffffffbfffffffbfffffffbfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbfffffffbfffffffbfffffffbfffffffbfffffffbfffffffbfffffffbfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbfffffffbfffffffbfffffffbfffffffbfffffffbfffffffbfffffffbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
