pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function _init()
	plyr={
		stspr=238,spr=254,
		offset=0,spd=10,
		x=8,
		y=8,
		lvl=1,
		hp=14,
		curr_hp=14,
		gold=80,
		exp=0,
		ac=10,
		dmg="1-2",
		d=2,
		mhit=1,
		mcast=1,
		amr_ac=0,
		str=15,
		int=13,
		wis=12,
		dex=14,
		con=15,
		cha=11,
		weapon="hands",
		armour="none",
		dead=false,
		win=false,
		init=0,
		type="derek",
		stat_points=0,
		castle_hp=100,
		castle_max_hp=100,
		magic={},
		potions={},
		bs="c"
		}
	reset_plyr={}
	save_plyr=deepcopy(plyr)
	save_fmap={}
	save_wave=1

	fmap={}
	wave=1
	wave_reset=true
	wave_adv=false

	lvl_up={0,30,60,180,380,750,900,1100,1400,1600,2100,1500,2000,2000,2500,3000,3000,4000,4000,5000,9999}

	temple={
		{desc="cure light wounds",gold=2,val="4",stat="hp"},
		{desc="cure serious wounds",gold=5,val="8",stat="hp"},
		{desc="heal",gold=20,val="full",stat="hp"}
		}

	weapons={
		{desc="dagger",gold=2,val="1-4",stat="dmg"},
		{desc="mace",gold=20,val="1-5",stat="dmg"},
		{desc="short sword",gold=25,val="1-6",stat="dmg"},
		{desc="long sword",gold=50,val="1-8",stat="dmg"},
		{desc="two handed sword",gold=100,val="1-10",stat="dmg"},
		{desc="great sword",gold=200,val="1-12",stat="dmg"},
		{desc="kings sword",gold=500,val="1-16",stat="dmg"},
		{desc="durandal",gold=999,val="1-20",stat="dmg"}
		}

	armour={
		--light --dex mod
		--{desc="padded",gold=5,val="11",stat="ac"},
		{desc="leather",gold=10,val="11",stat="ac"},
		{desc="studded leather",gold=45,val="12",stat="ac"},
		--medium --dex mod (max 2)
		--{desc="hide",gold=10,val="12",stat="ac"},
		{desc="chain shirt",gold=70,val="13",stat="ac"},
		--{desc="scale mail",gold=50,val="14",stat="ac"},
		{desc="breastplate",gold=120,val="14",stat="ac"},
		{desc="half plate",gold=200,val="15",stat="ac"},
		--heavy str requirements
		--{desc="ring mail",gold=30,val="14",stat="ac"},
		{desc="chain mail",gold=300,val="16",stat="ac"},--str 13
		{desc="splint",gold=600,val="17",stat="ac"},--str 15
		{desc="plate",gold=1000,val="18",stat="ac"}, --str 15
		{desc="godly plate",gold=1500,val="20",stat="ac"} --str 15
		}

	alchemist={
		{desc="healing",gold=2,val="4",stat="potion"},
		{desc="extra healing",gold=5,val="8",stat="potion"},
		{desc="heal",gold=20,val="full",stat="potion"},
		{desc="fiery breath",gold=10,val="1",stat="potion"}
		}

	magic={
		--{desc="protection+1",gold=1000,val="1",stat="ring"},
		--{desc="protection+2",gold=2000,val="1",stat="ring"},
		{desc="multi hit+1",gold=50,val="1",stat="skill"},
		{desc="multi cast+1",gold=75,val="1",stat="skill"},
		{desc="fire bolt",gold=200,val="1",stat="wand"},
		{desc="lightning",gold=400,val="1",stat="wand"},
		{desc="disintegrate",gold=700,val="1",stat="wand"},
		{desc="healing",gold=500,val="1",stat="staff"}--,
		--{desc="dog",gold=777,val="5",stat="cha"}
		}

	games={
		{desc="basilisk",gold=8,val="10",stat="wins"},
		{desc="dragon eyes",gold=5,val="6",stat="wins"},
		{desc="odd man out",gold=2,val="3",stat="wins"}
		}

	list_start=1
	list_min=1
	list_pos=1
	list_len=8
	idx=1
	if (#armour<list_len) then
		list_end=#armour
		list_len=list_end
	else
		list_end=list_len
	end
	list_max=list_end

	but_num=2
	but_pos=but_num

	field_num=8
	field_pos=1

	field_x=60
	field_y=83

	--state
	select=false
	gamestate=0

	bpos=1
	bmenu=true
	blist=false
	bluse=false
	use_magic=""
	bltype=""
	fpos=1
	fmenu=false
	o={}
	spos=1
	log1=""
	log2=""
	log3=""
	log4=""
	tlog=""

	mx=0
end

function _update()
	if(btnp(🅾️)) sfx(2)
	if(btnp(❎)) sfx(3)
	if(btnp(⬆️) or btnp(⬇️)) sfx(0)

	if(plyr.win and btnp(🅾️)) reset()
	if(plyr.dead and btnp(🅾️)) then
		reset()
	elseif (gamestate==0 and (btnp(🅾️) or btnp(❎)) and fmenu==false) then
			fmenu=true
	elseif (fmenu) then
		if(btnp(⬆️) and fpos>1) fpos-=1
		if(btnp(⬇️) and fpos<#o) fpos+=1
		if(btnp(🅾️)) picobar_act(o[fpos]) fpos=1
		if(btnp(❎)) fmenu=false fpos=1
	else
		if (gamestate==1) then
			control_field()
		elseif (gamestate==2) then
			control_field_active()
		elseif (gamestate==3) then
			control_shop()
		elseif (gamestate==4) then
			control_battle()
		elseif (gamestate==5) then
			control_textbox()
		elseif (gamestate==6) then
			control_textbox()
			if(gamestate==1) wave_init()
		end
	end
end

function _draw()
	cls()
	if (wave_reset) wave_init()
	if (gamestate==0) then
		title_screen()
		reset_plyr=deepcopy(plyr)
	elseif (gamestate==1) then
		cls()
		field()
		o={"save","load","quit"}
		picobar(o)
		wave_clear()
		battle_init=true
	elseif (gamestate==2) then
		field()
		field_active()
		o={"save","load","quit"}
		picobar(o)
		battle_init=true
	elseif (gamestate==3) then
		cls()
		if (shop==1) menu("temple",temple,40)
		if (shop==2) menu("weapon shop",weapons,48)
		if (shop==3) menu("armourer",armour,56)
		if (shop==4) menu("alchemist",alchemist,64)
		if (shop==5) menu("magic items",magic,72)
		if (shop==6) menu("gaming hall",games,80)
		if (shop==7) gamestate=2
		if (shop==8) derek_stats()
	elseif (gamestate==4) then
		if(battle_init) then
			e={}
			for m=1,#fmap[plyr.x][plyr.y].mobs do
				add(e,spawn_enemy(fmap[plyr.x][plyr.y].mobs[m].creature))
			end
			battle_init=false
			plyr.init=initiative(bonus(plyr.dex))
			log4=""
			log3=""
			log2=""
			log1=""
		end
		battle_screen(e)
		o={"save","load","quit"}
		picobar(o)
		if(blist) then
			if(bpos==3) then
				battle_list(plyr.potions,"potion") list_max=#plyr.potions
			elseif(bpos==4) then
				battle_list(plyr.magic,"magic") list_max=#plyr.magic
			end
		end
	elseif (gamestate==5) then
		battle_screen(e)
		o={"save","load","quit"}
		picobar(o)
		textbox(tlog,28)
	elseif (gamestate==6) then
		tlog="wave clear"
		textbox(tlog,12)
	end

	if (wave_adv) wave_attack() wave_advance()
	if (plyr.dead) gameover()
	if (plyr.win) win()
end
-->8
--menu
function menu(title,list,icon)
	list_end=#list
	list_len=#list
	list_limit=#list
	list_max=#list

	map(0,0)

	tx=centre_text(title)
	rectfill(tx-1,1,128-tx+1,6,6)
	print(title,tx+1,1,0)

	--image
	yrpt=3
	xrpt=5
	xpic=flr(50/xrpt)
	ypic=flr(87/yrpt)

	sspr(0, 64, 24, 32,5,13,50,87)
	rect(5,13,55,100,0)
	--spr(icon,27,53)
	--sspr( sx, sy, sw, sh, dx, dy, [dw,] [dh,] [flip_x,] [flip_y] )
	sspr(104,8,8,8,17,41,32,32)
	sspr(icon,8,8,8,16,40,32,32)

	--textbox
	rect(60,50,116,100,0)
	rect(116,50,124,100,0)
	rect(116,88,124,94,0)

	list_move(list_pos,8,list)

	idx=1
	for l=list_start,list_limit do
		if (idx==list_pos) then
			rectfill(61,51+6*(idx-1),115,57+6*(idx-1),12)
			print(list[l].desc,60,14,8)
			--stats
			print("cost:",60,24,0)
			g=ceil(list[l].gold*(1-bonus(plyr.cha)/10))
			print(g,126-#tostr(g)*4,24,8)
			print(list[l].stat..":",60,30,0)
			print(list[l].val,126-#list[l].val*4,30,8)
			pstat=""
			if (title=="weapon shop") then
				pstat=plyr.dmg
			elseif (title=="armourer") then
				pstat=plyr.amr_ac
			elseif (title=="temple") then
				pstat=plyr.curr_hp
			elseif (title=="alchemist") then
				pstat=plyr.curr_hp
			elseif (title=="magic items") then
				--pstat=plyr.curr_hp
				if(list[l].desc=="multi hit+1") pstat=plyr.mhit
				if(list[l].desc=="multi cast+1") pstat=plyr.mcast
			end
			if(pstat!="") then
				print("curr "..list[l].stat..":",60,36,5)
				print(pstat,126-#tostr(pstat)*4,36,5)
			end
		end
		txt=list[l].desc
		if(#txt>12) txt=sub(txt,1,12).."…"
		print(txt,62,52+6*(idx-1),0)
		if (list_pos<=list_end) then
			idx+=1
		end
	end
	--scroll bar
	rectfill(117,51,123,87,6)

	p=list_pos+list_start-1

	--scroll icon
	scroll_bar(117,51,40)

	--line under title
	line(60,20,124,20,0)

	local pad=2

	if (but_pos==1 and select) then
		gamestate=1
		select=false
		but_pos=2
		list_pos=1
		list_start=1
	elseif (but_pos==1) then
		button(63,110,"leave",true)
	else
		button(63,110,"leave",false)
	end
	if (but_pos==2) then
		button(101,110,"buy",true)
		v=list[p].val
		lg=ceil(list[p].gold*(1-bonus(plyr.cha)/10))
		if (select and plyr.gold-lg>=0 and plyr.dmg != v) then
			if (title=="weapon shop") then
				plyr.dmg=v
				plyr.d=tonum(sub(v,3))
				plyr.weapon=list[p].desc
			elseif (title=="armourer") then
				plyr.amr_ac=v
				plyr.armour=list[p].desc
			elseif (title=="alchemist") then
				add(plyr.potions,list[p])
			elseif (title=="magic items") then
				if(list[p].desc=="multi hit+1") then
					plyr.mhit+=1
					list[p].gold+=list[p].gold
				elseif (list[p].desc=="multi cast+1") then
					plyr.mcast+=1
					list[p].gold+=list[p].gold
				else
					add(plyr.magic,list[p])
				end
			elseif (title=="gaming hall") then
				if(list[p].desc=="basilisk") then
					if(droll(1,6)==1) then
						plyr.gold+=10
					elseif(droll(1,6)==1) then
						plyr.gold+=10
					end
				elseif(list[p].desc=="dragon eyes") then
					if(droll(1,6)==droll(1,6)) plyr.gold+=6
				elseif(list[p].desc=="odd man out") then
					d=droll(2,6)
					if(flr(d/2)*2==d) plyr.gold+=3
				end
			elseif (title=="temple") then
				if(v == "full")then
					plyr.curr_hp=plyr.hp
				elseif(plyr.curr_hp+v <= plyr.hp) then
					plyr.curr_hp+=v
				else
					plyr.curr_hp=plyr.hp
				end
			end
			plyr.gold-=lg
		end
	else
		button(101,110,"buy",false)
	end

	--gold
	print("gold:",5,110,8)
	print(plyr.gold,25,110,0)
end

function button(x,y,text,highlight)
	local col=0

	--button
	rect(x-2,y-2,x+22,y+6,col)
	offset=(20-#text*4)/2
	print(text,x+offset+1,y,col)

	--highlight
	if (highlight) then
		col=12
		pset(x-2,y-2,col)
		pset(x-2,y+6,col)
		pset(x+22,y+6,col)
		pset(x+22,y-2,col)

		rect(x-3,y-3,x+23,y+7,col)
		pset(x-3,y-3,7)
		pset(x-3,y+7,7)
		pset(x+23,y+7,7)
		pset(x+23,y-3,7)
	else
		pset(x-2,y-2,7)
		pset(x-2,y+6,7)
		pset(x+22,y+6,7)
		pset(x+22,y-2,7)
	end
end

function scroll_bar(x,y,h)
	scy=y+(h/list_max)*(list_start+list_pos-1)-(h/list_max)
	if(scy>y+h-10) scy=y+h-10
	spr(18,x,scy)

    palt(0,false)
    palt(14,true)
	spr(43,x+1,y+h-1)
	spr(44,x+1,y+h+5)
	palt(0,true)
    palt(14,false)
end

-->8
--helper
function animate(tbl)
	if(tbl.offset>=tbl.spd) then
		if(tbl.size=="s") then
		    rn=ceil(rnd(3))
		    if(rn==1) tbl.spr=tbl.stspr+16
		    if(rn==2) tbl.spr=tbl.stspr+17
		    if(rn==3) tbl.spr=tbl.stspr+1
		else
		    rn=ceil(rnd(4))
		    if(rn==1) tbl.spr=tbl.stspr+16
		    if(rn==2) tbl.spr=tbl.stspr+17
		    if(rn==3) tbl.spr2=tbl.stspr
		    if(rn==4) tbl.spr2=tbl.stspr+1
		end
		tbl.offset=0
	else
		tbl.offset+=1
	end
end

function centre_text(str)
	pos=((32*4)-(#str*4))/2
	return pos
end

function num_size(num)
	return (4*#tostr(num))
end

function list_move(pos,display,list)
	--if (pos==list_max) then
	if (pos==display) then
		list_start+=1
		list_end+=1
		--list_max+=1
		list_pos-=1
	end
	if (pos==list_min and list_start>1) then
		list_end-=1
		list_start-=1
		list_pos+=1
	end

	if(list_start+display-1<=#list) then
		list_limit=list_start+display-1
	else
		list_limit=#list
	end
end
function add_log(txt)
	log4=log3
	log3=log2
	log2=log1
	log1=txt
end

function textbox(text,s)
	pad=20
	chars=20
	lines=ceil(#text/chars)+1
	xtra=(lines-5)*7
	rectfill(21,21,108,71+xtra,1)
	rectfill(20,20,107,70+xtra,7)
	--rect(1+pad,1+pad,126-pad,89-pad,0)
	rectfill(25,25,33,34,0)
	spr(s,26,26)
	for t=1,lines do
		print(sub(text,(t-1)*chars,t*chars-1),25,37+(t-1)*7,0)
		--print(tlog,5+pad,5+pad+1+11)
	end

	dbutton("s",99,64+xtra,true)
end

function dbutton(type,x,y,bg)
	if(bg) then
		bprint("❎",x,y,0,0)
	end
	if(type=="s") then
		if(plyr.bs=="c") then
			spr(16,x,y)
		else
			spr(32,x,y)
		end
	end
	if(type=="x") then
		if(plyr.bs=="c") then
			spr(32,x,y)
		else
			spr(16,x,y)
		end
	end
end

function bprint(str,x,y,c1,c2)
	color(c2)
	print(str,x-1,y-1)
	print(str,x-1,y)
	print(str,x,y-1)
	print(str,x+1,y+1)
	print(str,x+1,y)
	print(str,x,y+1)

	print(str,x,y,c1)
end

function bspr(s,x,y,c)
	spr(s,x,y)
end

function deepcopy(orig)
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

-->8
--field
function field()
	spc=16
	bpos=1
	map(32,0,4,1)
	for i=0,7 do
		spr(37,spc*i,7)
		spr(38,spc*i+8,7)
		spr(53,spc*i,15)
		spr(54,spc*i+8,15)
		spr(21+i,spc*i+5,11)
	end

	--level up symbol
	if(plyr.stat_points>0) spr(41,121,16)

	spr(39,1,116)
	spr(40,9,116)
	spr(55,1,124)
	spr(56,9,124)
	print("wave",23,116,12)
	print(wave,29,122,7)
	cp=plyr.castle_hp/plyr.castle_max_hp
	if (cp <= 0.5) then
		chp=8
	elseif (cp <= 0.25) then
		chp=9
	else
		chp=11
	end
	rectfill(17,125-8*cp,21,125,chp)
	rect(17,116,21,126,7)

	--rect(spc*(field_pos-1)+1,8,spc*(field_pos-1)+14,21,10)
	--sspr( sx, sy, sw, sh, dx, dy, [dw,] [dh,] [flip_x,] [flip_y] )
	sspr( 106, 16, 16, 16, spc*(field_pos-1)+2,7)


	bp="🅾️ "
	if(field_pos==1)t="temple"
	if(field_pos==2)t="weapon"
	if(field_pos==3)t="armour"
	if(field_pos==4)t="aclmst"
	if(field_pos==5)t="magic"
	if(field_pos==6)t="gaming"
	if(field_pos==7)t="field"
	if(field_pos==8)t="derek"
	if(gamestate!=2) bprint(bp..t,88,117,7,1)
	dbutton("s",88,117)

	--border of field yellow
	rect(3,24,124,113,9)
	--grey
	rect(2,23,125,114,5)

	for x=1,15 do
		for y=1,11 do
			if (fmap[x][y].type == "e") then
				spr(58,x*8-2,y*8+19)
			end
		end
	end
	pset(2,23,0)
	pset(2,114,0)
	pset(125,114,0)
	pset(125,23,0)
end

function field_active()
	pal(10,9)
	sspr(106,16,16,16,spc*(field_pos-1)+2,7)
	pal()
	rect(3,24,124,113,10)
	--rect(spc*(field_pos-1)+1,8,spc*(field_pos-1)+14,21,0)
	f=fmap[plyr.x][plyr.y]
	if (f.type=="e") then
		fx=#f.mobs/2-0.5
		for i=1,#f.mobs do
			p=i-1-fx
			rectfill(field_x+p*9-1,field_y-10,field_x+p*9+8,field_y-9+8,1)
			rect(field_x+p*9-1,field_y-10,field_x+p*9+8,field_y-9+8,0)
			spr(f.mobs[i].spr,field_x+p*9,field_y-9)
		end
	end

	rect(field_x,field_y,field_x+7,field_y+7,8)
	bprint("🅾️ attack",88,116,7,1) dbutton("s",88,116)
	bprint("❎ castle",88,122,7,1) dbutton("x",88,122)
end
-->8
--controls
function control_field()
	select=false
	if(btnp(⬆️)) fmenu=true
	if(btnp(⬅️) and field_pos>0) field_pos-=1 sfx(1)
	if(btnp(⬅️) and field_pos<1) field_pos=8 sfx(1)
	if(btnp(➡️) and field_pos<9) field_pos+=1 sfx(1)
	if(btnp(➡️) and field_pos==9) field_pos=1 sfx(1)
	if(btnp(🅾️)) then
		shop=field_pos
		gamestate=3
		field_x=60
		field_y=81
	end
end

function control_field_active()
	if(btnp(⬆️) and field_y>25) field_y-=8 plyr.y-=1
	if(btnp(⬇️) and field_y<98) field_y+=8 plyr.y+=1
	if(btnp(⬅️) and field_x>11) field_x-=8 plyr.x-=1 sfx(0)
	if(btnp(➡️) and field_x<116) field_x+=8 plyr.x+=1 sfx(0)
	if(btnp(🅾️)) then
		shop=field_pos
		if(fmap[plyr.x][plyr.y].type=="e") gamestate=4
	end
	if(btnp(❎)) then
		gamestate=1
		plyr.x=8
		plyr.y=8
	end
end

function control_shop()
	if(btnp(⬅️) or btnp(➡️)) sfx(1)
	if(shop==8) then
		if(btnp(⬆️)) then
			if (spos>1) then
				spos-=1
			end
		end
		if(btnp(⬇️)) then
			if (spos<6) then
				spos+=1
			end
		end
	else
		if(btnp(⬆️)) then
			if (list_pos>list_min) then
				list_pos-=1
			end
		end
		if(btnp(⬇️)) then
			if (list_pos+list_start-1<list_limit) then
				list_pos+=1
			end
		end
	end

	if(btnp(⬅️) and but_pos>1) but_pos-=1
	if(btnp(➡️) and but_pos<but_num) but_pos+=1
	if(btnp(🅾️)) then
		select=true
	else
		select=false
	end
end

function control_battle()
	if(btnp(⬅️) or btnp(➡️)) sfx(1)
	if(fmenu) then
		if(btnp(🅾️)) then
			if(fpos==1) load()
		end
		if(btnp(❎)) then
			fmenu=false
			fpos=1
		end
		if(btnp(⬆️) and fpos>1) fpos-=1
		if(btnp(⬇️) and fpos<#o) fpos+=1
	elseif(blist) then
		if(btnp(⬆️)) then
				if (list_pos>list_min) then
					list_pos-=1
				end
		elseif(btnp(⬇️)) then
				if (list_pos+list_start-1<list_limit) then
					list_pos+=1
				end
		elseif(btnp(⬅️) and bpos > 1) then
			but_pos-=1
		elseif (btnp(➡️) and but_pos < 2) then
			but_pos+=1
		end
		if(btnp(❎) or (btnp(🅾️) and but_pos==1)) then
			blist=false
			but_pos=2
			list_limit=8
			list_max=8
			list_start=1
			list_pos=1
			list_min=1
		end
		if(btnp(🅾️) and but_pos==2) then
			lp=list_start+list_pos-1
			if(bltype=="potion" and #plyr.potions>0) then
				hpv=plyr.potions[lp].val
				d=plyr.potions[lp].desc
				if(hpv!="full") hpc=plyr.curr_hp+hpv
				msg="potion heals derek for "..hpv
				log=true
				if(d=="fiery breath") then
					r=ceil(rnd(#e))
					spell(plyr,e[r],"potion",d)
					log=false
				elseif(hpv=="full") then
					plyr.curr_hp=plyr.hp
				elseif(hpc <= plyr.hp) then
					plyr.curr_hp+=hpv
				elseif(plyr.curr_hp < plyr.hp) then
					plyr.curr_hp=plyr.hp
				else
					msg="potion has no effect"
				end
				del(plyr.potions,plyr.potions[lp])
				if(log) add_log(msg)
				enemy_attack()
			elseif(bltype=="magic" and #plyr.magic>0) then
				r=ceil(rnd(#e))
				use_magic=plyr.magic[lp].desc
				bmenu=false
				epos=1
			end
			blist=false
		end
	elseif(bmenu and blist==false) then
		if(btnp(⬆️)) then
			fmenu=true
		elseif(btnp(⬅️) and bpos > 1) then
			bpos-=1
		elseif (btnp(⬅️)) then
			bpos=4
		end
		if(btnp(➡️) and bpos < 4) then
			bpos+=1
		elseif (btnp(➡️)) then
			bpos=1
		end
		if(btnp(🅾️)) then
			if(bpos==2) then
				add_log(battle_run())
				enemy_attack()
				bmenu=true
			elseif(bpos==3 or bpos==4) then
				blist=true
				list_pos=1
				list_start=1
			else
				bmenu=false
				epos=1
			end
		end
		if(btnp(❎) and blist) blist=false but_pos=2
	else
		if(btnp(⬆️) and epos > 1) then
			epos-=1
		elseif (btnp(⬆️)) then
			epos=#e
		end
		if(btnp(⬇️) and epos < #e) then
			epos+=1
		elseif (btnp(⬇️)) then
			epos=1
		elseif(btnp(🅾️)) then
			if(bpos==1) then
				attack(plyr,e[epos])
				enemy_attack()
			end
			if(bpos==4) then
				spell(plyr,e[epos],"spell",use_magic)
				enemy_attack()
			end
			bmenu=true
		end
	end
	print(epos,0,10,10)
end

function control_textbox()
	if(btnp(🅾️)) gamestate=1
end

-->8
--derek
function derek_stats()
	title="stats"
	local sx2,sy2=62,62
	local cx2,cy2=123,62
	map(0,0)
	tx=centre_text(title)
	rectfill(tx-1,1,128-tx+1,6,6)
	print(title,tx+1,1,0)
	spr(28,4,12)
	print("derek",15,14,8)

	rect(4,24,sx2,sy2,0)
	print("lvl:",6,26,0)
	print(plyr.lvl,sx2-num_size(plyr.lvl),26,12)
	print("hp:",6,32,0)
	print(plyr.curr_hp.."/"..plyr.hp,sx2-(4*(#tostr(plyr.hp)+#tostr(plyr.curr_hp)+1)),32,12)
	print("gold:",6,38,0)
	print(plyr.gold,sx2-num_size(plyr.gold),38,12)
	print("xp to lvl:",6,44,0)
	nxp=lvl_up[plyr.lvl+1]-plyr.exp
	print(nxp,sx2-num_size(nxp),44,12)
	print("ac:",6,50,0)
	print(plyr.ac,sx2-num_size(plyr.ac),50,12)
	print("dmg:",6,56,0)
	print(plyr.dmg,sx2-num_size(plyr.dmg),56,12)

	rect(66,24,cx2,cy2,0)

	print("str: +"..bonus(plyr.str),68,26,0)
	print(plyr.str,cx2-num_size(plyr.str),26,8)
	print("int: +"..bonus(plyr.int),68,32,0)
	print(plyr.int,cx2-num_size(plyr.int),32,8)
	print("wis: +"..bonus(plyr.wis),68,38,0)
	print(plyr.wis,cx2-num_size(plyr.wis),38,8)
	print("dex: +"..bonus(plyr.dex),68,44,0)
	print(plyr.dex,cx2-num_size(plyr.dex),44,8)
	print("con: +"..bonus(plyr.con),68,50,0)
	print(plyr.con,cx2-num_size(plyr.con),50,8)
	print("cha: +"..bonus(plyr.cha),68,56,0)
	print(plyr.cha,cx2-num_size(plyr.cha),56,8)

	sy=26+6*(spos-1)
	if(plyr.stat_points>0) spr(41,cx2-14,sy)

	if (but_pos==2 and select and plyr.stat_points>0) then
		if(spos==1) plyr.str+=1
		if(spos==2) plyr.int+=1
		if(spos==3) plyr.wis+=1
		if(spos==4) plyr.dex+=1
		if(spos==5) plyr.con+=1
		if(spos==6) plyr.cha+=1
		plyr.stat_points-=1
	end
	print("stat points:",68,14,0)
	print(plyr.stat_points,cx2-num_size(plyr.stat_points),14,0)
	print("weapon: "..plyr.weapon,6,70,0)
	print("armour: "..plyr.armour,6,80,0)
	print("hits:   "..plyr.mhit,6,90,0)
	print("casts:  "..plyr.mcast,6,100,0)

	if (but_pos==1 and select) then
		gamestate=1
		select=false
		but_pos=2
		list_pos=1
		list_start=1
	elseif (but_pos==1) then
		b=true
	else
		b=false
	end

	button(63,110,"leave",b)
	button(101,110,"buy",not b)
end

-->8
--waves
function wave_init()
	for x=1,15 do
		fmap[x]={}
		for y=1,11 do
			fmap[x][y]={type="o",mobs={}}
			if(fget(mget(x+31,y+2))==1) fmap[x][y].type="x"
		end
	end
	for y=1,11 do
		r=ceil(rnd(15))
		if (fmap[r][y].type!="x") then
			fmap[r][y].type="e"
			gbl={creature="goblin",spr=192,{}}
			orc={creature="orc",spr=194,{}}
			hob={creature="hobgoblin",spr=224,{}}
			cap={creature="guard captain",spr=228,{}}
			ogr={creature="ogre",spr=226,{}}
			kgt={creature="knight",spr=196,{}}
			hgiant={creature="hill giant",spr=200,{}}
			mtaur={creature="minotaur",spr=202,{}}
			sgiant={creature="stone giant",spr=204,{}}
			if(wave==1) rn=rnd({gbl,gbl,gbl,hob})
			if(wave==2) rn=rnd({gbl,gbl,hob,orc,{gbl,gbl}})
			if(wave==3) rn=rnd({orc,hob,{hob,gbl},hob})
			if(wave==4) rn=rnd({cap,{orc,hob},orc,hob})
			if(wave==5) rn=rnd({ogr,{orc,orc},ogr,cap})
			if(wave==6) rn=rnd({ogr,cap,{ogr,cap},kgt})
			if(wave==7) rn=rnd({mtaur,kgt,cap})
			if(wave==8) rn=rnd({hgiant,{mtaur,ogr},mtaur})
			if(wave==9) rn=rnd({sgiant,mgiant,{kgt,kgt}})
			if(wave==10) rn=rnd({{sgiant,sgiant},{mgiant,mgiant},{mgiant,mtaur,sgiant}})
			if(#rn==1) rn={rn}
			fmap[r][y].mobs=rn
		end
		save_fmap=fmap
	end
	wave_reset=false
end

function wave_advance()
	nmap=deepcopy(fmap)
	for x=15,1,-1 do
		for y=11,1,-1 do
			if (fmap[x][y].type=="e") then
				if (x<6 and y<5 and nmap[x+1][y+1].type=="o") then
					nmap[x][y].type="o"
					nmap[x+1][y+1].type="e"
					nmap[x+1][y+1].mobs=fmap[x][y].mobs
				elseif (x<6 and nmap[x+1][y].type=="o") then
					nmap[x][y].type="o"
					nmap[x+1][y].type="e"
					nmap[x+1][y].mobs=fmap[x][y].mobs
				elseif (y<5 and nmap[x][y+1].type=="o") then
					nmap[x][y].type="o"
					nmap[x][y+1].type="e"
					nmap[x][y+1].mobs=fmap[x][y].mobs
				end
			end
		end
	end

	fmap=deepcopy(nmap)

	for x=1,15 do
		for y=1,11 do
			if(fmap[x][y].type=="e") then
				if(x>10 and y>7 and nmap[x-1][y-1].type=="o") then
					nmap[x][y].type="o"
					nmap[x-1][y-1].type="e"
					nmap[x-1][y-1].mobs=fmap[x][y].mobs
				elseif(x>10 and nmap[x-1][y].type=="o") then
					nmap[x][y].type="o"
					nmap[x-1][y].type="e"
					nmap[x-1][y].mobs=fmap[x][y].mobs
				elseif(y>7 and nmap[x][y-1].type=="o") then
					nmap[x][y].type="o"
					nmap[x][y-1].type="e"
					nmap[x][y-1].mobs=fmap[x][y].mobs
				elseif(y>7 and x>2 and nmap[x-1][y].type=="o") then
						nmap[x][y].type="o"
						nmap[x-1][y].type="e"
						nmap[x-1][y].mobs=fmap[x][y].mobs
				end
			end
		end
	end

	fmap=deepcopy(nmap)
	wave_adv=false
end

function wave_attack()
	for x=7,10 do
		for y=5,7 do
			if(fmap[x][y].type=="e")then
				for e=1,#fmap[x][y].mobs do
					if(plyr.castle_hp-wave>=0) then
						plyr.castle_hp-=wave
					else
						plyr.castle_hp=0
						plyr.dead=true
					end
				end
			end
		end
	end
end

function wave_clear()
	wc=0
	for x=1,15 do
		for y=1,11 do
			if (fmap[x][y].type=="e") then
				wc+=1
				break
			end
		end
	end
	if (wc==0) then
		gamestate=6
		wave+=1
		if(wave>10) plyr.win=true
	end
end
-->8
--battle
function battle_screen(enemy)
	--menu
	mx=61
	my=7
--	spc=28
	spc=17
	dead=0

	for m=0,3 do
		spr(37,mx+spc*m,my+0)
		spr(38,mx+spc*m+8,my+0)
		spr(53,mx+spc*m,my+8)
		spr(54,mx+spc*m+8,my+8)
		spr(5+m,mx+5+spc*m,my+4)
	end

	--derek
	rectfill(63,24,126,37,5)
	line(64,25,73,25,7)
	line(64,25,64,34,7)
	rectfill(65,26,74,35,0)
	spr(plyr.stspr,66,27)
	print("derek",77,25,7)

	if (plyr.curr_hp/plyr.hp <= 0.25) then
		ehealth=8
	elseif (plyr.curr_hp/plyr.hp <= 0.5) then
		ehealth=9
	else
		ehealth=11
	end
	rectfill(77,31,77+48*(plyr.curr_hp/plyr.hp),36,ehealth)
	rect(77,31,125,36,0)

	--highlight selection
	if(bmenu) then
		--rect(mx+spc*(bpos-1)+1,my+1,mx+spc*(bpos-1)+14,my+14,10)
		sspr( 106, 16, 16, 16, mx+spc*(bpos-1)+2,my)
	else
		spc=epos*17
		rect(62,23+spc,127,38+spc,10)
	end

	for i=1,#enemy do
		spc=i*17
		rectfill(63,24+spc,126,37+spc,5)
		line(64,25+spc,73,25+spc,7)
		line(64,25+spc,64,34+spc,7)
		rectfill(65,26+spc,74,35+spc,0)
		--enemy avatar
		spr(enemy[i].stspr,66,27+spc)
		--dead
		if (enemy[i].curr_hp<=0) spr(49,66,27+spc)
		print(enemy[i].type,77,25+spc,7)
		if (enemy[i].curr_hp/enemy[i].hp <= 0.25) then
			ehealth=8
		elseif (enemy[i].curr_hp/enemy[i].hp <= 0.5) then
			ehealth=9
		else
			ehealth=11
		end
		rectfill(77,31+spc,77+48*(enemy[i].curr_hp/enemy[i].hp),36+spc,ehealth)
		rect(77,31+spc,125,36+spc,0)
		if (enemy[i].curr_hp<=0) dead+=1
	end

	--log
	--ty = 98
	rectfill(0,102,127,127,0)
	rect(1,95,126,126,7)
	print(log1,4,98,7)
	print(log2,4,105,6)
	print(log3,4,112,5)
	print(log4,4,119,5)

	--battle field
	bx=0
	by=9
	bc=bx+flr(58/2)
	bp=(bx+58)/(#enemy+1)

	map(18,3,bx+2,by,7,10)
	rect(bx+1,by,bx+58,92,7)
	animate(plyr)
	spr(plyr.spr,bc,74)
	for i=1,#enemy do
		if(enemy[i].curr_hp>0) then
			animate(enemy[i])
			spr(enemy[i].spr,(i)*bp,by+30)
			if(enemy[i].size=="l") spr(enemy[i].spr2,(i)*bp,by+22)
		end
	end

	if(plyr.curr_hp<=0) plyr.dead=true plyr.x=8 plyr.y=8
	--reset battle after victory
	if(dead==#enemy and gamestate==4) then
		gamestate=5
		battle_init=true
		fmap[plyr.x][plyr.y].type="o"
		field_pos=1
		plyr.x=8
		plyr.y=8
		xp=0
		gold=0
		for i=1,#enemy do
			plyr.exp+=enemy[i].exp
			plyr.gold+=enemy[i].gold
			xp+=ceil(enemy[i].exp*(1+bonus(plyr.wis)/10))
			gold+=enemy[i].gold
		end
		tlog="enemies drop "..tostr(gold).." gp and "..tostr(xp).." experience. "
		level(plyr.exp)
		wave_adv=true
	end
end

--[[function battle_attack()
	if (hit(e[epos].ac,plyr.dex)) then
		d=dmg(plyr.d,bonus(plyr.str))
		if (e[epos].curr_hp-d >= 0) then
			e[epos].curr_hp-=d
		else
			e[epos].curr_hp=0
		end
		log="derek hit "..e[epos].type.." for "..tostr(d).." dmg"
	else
		log="derek missed "..e[epos].type
	end
	return log
end]]--

function battle_list(items,type)
	pad=12
	local b1,b2=false,false
	bltype=type
	rectfill(13,13,116,116,1)
	rectfill(12,12,115,115,7)

	--scroll bar
	rectfill(102,28,108,82,6)

	--scroll icon
	scroll_bar(102,28,58)


	list_move(list_pos,11,items)

	print("use which "..type.."?",17,17,0)
	idx=1
	if(#items>0) then
		for i=list_start,list_limit do
			if (idx==list_pos) then
				rectfill(17,34+6*(idx-1),101,28+6*(idx-1),12)
			end
			if(#items[i]>19) then
				txt=sub(items[i].desc,1,19).."…"
			else
				txt=items[i].desc
			end
			print(txt,19,29+6*(idx-1),0)
			if (list_pos<=list_limit) then
				idx+=1
			end
		end
	end

	if(but_pos==1) then
		b1=true
		b2=false
	else
		b1=false
		b2=true
	end
	button(115-55,105,"close",b1)
	button(115-25,105,"ok",b2)

	--textbox
	rect(17,27,101,95,0)
	rect(101,27,109,95,0)
	rect(101,83,109,89,0)
end

function attack(atk,def)
	hits=hit(def.ac,atk.dex,atk.mhit)
	if (hits > 0) then
		d=dmg(atk.d,bonus(atk.str),hits)
		if (def.curr_hp-d >= 0) then
			def.curr_hp-=d
		else
			def.curr_hp=0
		end
		add_log(atk.type.." hit "..tostr(hits).."x for "..tostr(d).." dmg")
	else
		add_log(atk.type.." missed "..def.type)
	end
	return d
end

function enemy_attack()
	for i=1,#e do
		attack(e[i],plyr)
	end
end

function spell(atk,def,style,spell)
	hits=hit(def.ac,atk.dex,atk.mcast)
	if (hits > 0) then
		if(style=="spell") then
			d=bonus(atk.int)
			if(spell=="fire bolt") then
				if(lvl>=17) then
					d+=droll(4,10)*hits
				elseif(lvl >= 11) then
					d+=droll(3,10)*hits
				elseif(lvl >= 5) then
					d+=droll(2,10)*hits
				else
					d+=droll(1,10)*hits
				end
			end
			if(spell=="lightning") d+=droll(8,6)
			if(spell=="disintegrate") d+=droll(10,6)+40
		else
			d=dmg(atk.d,0,hits)
		end
		if (def.curr_hp-d >= 0) then
			def.curr_hp-=d
		else
			def.curr_hp=0
		end
		add_log(spell.." hit "..def.type.." for "..tostr(d).." dmg")
	else
		add_log(spell.." missed "..def.type)
	end

	return d
end

function battle_run()
	if(rnd(20) > 10) then
		tlog="derek runs away"
		textbox(tlog,28)
		gamestate=5
		battle_init=true
		field_pos=1
		plyr.x=8
		plyr.y=8
	else
		log="derek tried to run"
	end

	return log
end

function hit(ac,bns,hits)
	hit_result=0
	for i=1,hits do
		dice=ceil(rnd(20))
		if (dice+bonus(bns) > ac) hit_result+=1
	end
	return hit_result
end

function droll(dice,sides)
	result=0
	for d=1,dice do
		result+=ceil(rnd(sides))
	end

	return result
end

function dmg(d,bonus,hits)
	total_dmg=0
	for i=1,hits do
		total_dmg+=ceil(rnd(d))
	end
	return total_dmg+bonus
end

function initiative(bonus)
	result=droll(1,20)+bonus
	return result
end

function sortByInit(a)
   for i=1,#a do
       local j = i
       while j > 1 and a[j-1].init > a[j].init do
           a[j],a[j-1] = a[j-1],a[j]
           j = j - 1
       end
   end
end

function bonus(stat)
	b=0
	comp=1
	for i=-5,10 do
		if(stat<=comp) then
			b=i
			break
		end
		comp+=2
	end
	if(stat>comp) b=10
	return b
end

function level(xp)
	lvl = plyr.lvl

	for i=1,20 do
		if(lvl<i and xp>=lvl_up[i]) then
			lvl=i
			xp-=lvl_up[i]
		end
	end

	if(lvl>plyr.lvl) then
		tlog = tlog.."derek leveled up to "..tostr(lvl).."!"
		plyr.stat_points+=1
		plyr.hp+=droll(1,6)+bonus(plyr.con)
	end
	plyr.lvl = lvl
end

function spawn_enemy(type)
	tbl={}
	if (type=="goblin") then
		tbl={
			stspr=192,spr=208,
			offset=0,spd=0,
			type=type,
			d=4,--1d6
			mhit=1,
			cr=0.25,ac=12,hp=7,str=8,dex=14,con=10,int=10,wis=8,cha=8,curr_hp=7,
			exp=6,
			gold=10,
			init=0,
			size="s"
			}
	end
	if (type=="hobgoblin") then
		tbl={
			stspr=224,spr=240,
			offset=0,spd=0,
			type=type,
			d=6,--1d10+1
			mhit=1,
			cr=0.5,ac=18,hp=11,str=13,dex=12,con=12,int=10,wis=10,cha=9,curr_hp=11,
			exp=10,
			gold=20,
			init=0,
			size="s"
			}
	end
	if (type=="orc") then
		tbl={
			stspr=194,spr=210,
			offset=0,spd=0,
			type=type,
			d=8,--1d12
			mhit=1,
			cr=0.5,ac=13,hp=15,str=16,dex=12,con=16,int=7,wis=11,cha=10,curr_hp=15,
			exp=15,
			gold=30,
			init=0,
			size="s"
			}
	end
	if (type=="knight") then
		tbl={
			stspr=196,spr=212,
			offset=0,spd=0,
			type=type,
			d=6,--2d6
			mhit=2,
			cr=3,ac=18,hp=52,str=16,dex=11,con=14,int=11,wis=11,cha=15,curr_hp=52,
			exp=70,
			gold=110,
			init=0,
			size="s"
			}
	end
	if (type=="ogre") then
		tbl={
			stspr=226,spr=242,
			offset=0,spd=0,
			type=type,
			d=12,--2d8+4
			mhit=2,
			cr=2,ac=11,hp=59,str=19,dex=8,con=16,int=5,wis=7,cha=7,curr_hp=59,
			exp=45,
			gold=85,
			init=0,
			size="s"
			}
	end
	if (type=="guard captain") then
		tbl={
			stspr=228,spr=244,
			offset=0,spd=0,
			type=type,
			d=12,--2d10+2 two handed
			mhit=2,
			cr=2,ac=15,hp=65,str=15,dex=16,con=14,int=14,wis=11,cha=14,curr_hp=65,
			exp=45,
			gold=90,
			init=0,
			size="s"
			}
	end
	if (type=="hill giant") then
		tbl={
			stspr=200,spr=216,spr2=200,
			offset=0,spd=0,
			type=type,
			d=24,--2x 3d8+5
			mhit=2,
			cr=5,ac=13,hp=105,str=21,dex=8,con=19,int=5,wis=9,cha=6,curr_hp=105,
			exp=180,
			gold=200,
			init=0,
			size="l"
			}
	end
	if (type=="minotaur") then
		tbl={
			stspr=202,spr=218,spr2=202,
			offset=0,spd=0,
			type=type,
			d=16,--2d12+4
			mhit=2,
			cr=3,ac=14,hp=76,str=18,dex=11,con=16,int=6,wis=16,cha=9,curr_hp=76,
			exp=70,
			gold=160,
			init=0,
			size="l"
			}
	end
	if (type=="stone giant") then
		tbl={
			stspr=204,spr=220,spr2=204,
			offset=0,spd=0,
			type=type,
			d=24,--2x 3d8+6
			mhit=2,
			cr=7,ac=17,hp=126,str=23,dex=15,con=20,int=10,wis=12,cha=9,curr_hp=126,
			exp=290,
			gold=280,
			init=0,
			size="l"
			}
	end
	tbl.spd=10+ceil(rnd(3))
	tbl.init=initiative(bonus(tbl.dex))
	return tbl
end

function title_screen()
	rectfill(0,8,127,127,0)
	if(mx<128) then
		mx+=0.02
	else
		mx=-8
	end
	--sspr( sx, sy, sw, sh, dx, dy, [dw,] [dh,] [flip_x,] [flip_y] )
	sspr(32,80,8,8,mx,27)
	sspr(48,64,64,32,12,64,128,64)
	rectfill(26,46,102,60,1)
	rectfill(25,45,101,59,5)
	rect(26,46,100,58,10)
	bprint("siege of darkwood",30,50,10,0)
	print("❎/🅾️ to start",37,110,7)
	bprint("❎",37,110,0,0)
	dbutton("x",37,110)
	bprint("🅾️",49,110,0,0)
	dbutton("s",49,110)
	o={"new","load"}
	picobar(o)
end

function picobar(opts)
	shadow=1
	rectfill(0,0,127,6,6)
	line(0,7,127,7,shadow)
	spr(48,1,1)
	if(fmenu) then
		rectfill(8,8,54,9+7*#opts,shadow)
		--grey box
		rectfill(7,7,53,7+7*#opts,6)
		--box edge
		rect(7,7,53,8+7*#opts,5)
		--file background
		rectfill(7,0,25,7,5)
		--highlight option
		rectfill(8,8+7*(fpos-1),52,14+7*(fpos-1),12)
		print("file",9,1,7)
		for i=1,#opts do
			print(opts[i],9,9+7*(i-1),0)
		end
	else
		print("file",9,1,0)
	end
end

function picobar_act(act)
	if(act=="save") save() fmenu=false
	if(act=="load") load() fmenu=false
	if(act=="new")then
		gamestate=1
		fmenu=false
		wave_init()
	end
	if(act=="quit") reset()
end

function reset()
	plyr=deepcopy(reset_plyr)
	fmap={}
	wave=1
	--wave_init()
	field_pos=1
	fmenu=false
	gamestate=0
end

function save()
	save_plyr=deepcopy(plyr)
	save_fmap=deepcopy(fmap)
	save_wave=wave
	rectfill(0,0,127,127,11)
end

function load()
	--plyr=save_plyr
	plyr=deepcopy(save_plyr)
	fmap=deepcopy(save_fmap)
	nmap=deepcopy(save_fmap)
	wave=save_wave
	if(gamestate>0) then
		plyr.x=8
		plyr.y=8
	end
	gamestate=1
	bpos=1
end

function gameover()
	textbox("sorry.             you have been killedthe city will now   surely fall into thehands of torque.    please try again.",10)
end

function win()
	textbox("congratulations.   you have valiantly  fought off torque's horde. darkwood willbe forever greatful.",42)
end
__gfx__
000000006666666666666666666666669994999400000007000000000007700000000000090000000077700000000000fff00777000000000000000000000000
000000006555555555555555555555569994999400000070000cc0000077770000a8a000077770000777770000000000fff07007000000000000000000000000
007007006666666666666666666666664444444400000700000c000000077000009a9000077777707057057000aa0006fff07007000000000000000000000000
0007700065555555555555555555555699499949000070000ccccc00000ee00000090000077777707567567000af0060fff07007000000000000555555555000
000770006666666666666666666666669949994900070000000c000000eeee000009000007777770077577000adc0600fff07007000000000005555555555500
00700700655555555555555555555556444444440a700000000cc0000eeeeee00009000009777770077d77000cccd000ff007770000000000015555555555500
000000006666666666666666666666669499949904a0000000c00c0000eeee0000090000090007700076700000cc0000ff070000000000000015555555555500
0000000000000000000000000000000094999499400000000c00c000000ee0000000000009000000006760000c0c0000ff000000000000000015555555555500
07777b0077777777555555507777777744444444044444000444440004444400044444000444440004444400c0000001009aaa00011111000015555555555500
77000bb077777777555555507777777799499949444a444044444440446664404477744044a8a440488844400c00001009a6ff00111111100015555555555500
7b0b0b307777777755777550777777779949994944aaa440444446404460044044474440449a94404878444000c0010009fddf00111111100015555555555500
bb00033077777777555555507777777744444444444a44404494644044666440447e7440444944404888e740000c1000996fff00111111100015555555555500
0333330077777777557775507777777794999499444a4440444944404466644044eee44044494440444eee400001c000aaf6ff00111111100001555555555000
0000000077777777555555507777777794999499044a4400041494000666660004eee400044944000447e7000a100c9019aff000011111000000111111110000
00000000777777775555555077777777444444440444440004444400044444000444440004494400044444000da00920c1a55c00011111000000000000000000
0000000077777777000000000000000049994999004440000044400000444000004440000044400000444000d0000002c1aa5cc0001110000000000000000000
0999980070707070000000000000000049994999000000000000000000000007500000000555000000202000ee0eeeee00000eee000000000000000000000000
99080880070707070000000000000000444444440000000000000000007500755500750055b5500002828200e000eeeee000eeee000000000000000000000000
9880882070707070000000000000000099949994000000000000000007555007500755505bbb50002888882000000eeeee0eeeee0000aaaaaaaaa00000000000
88080220070707070000000000000000999499940000555555555000007500755500750055b5500028888820eeeeeeeeeeeeeeee000a000000000a0000000000
0222220070707070000000000000000044444444000555555555550000750075550075000555000002888200eeeeeeeeeeeeeeee00a00000000000a000000000
0000000007070707000000000000000099499949000555555555551007555555555555500000000000282000eeeeeeeeeeeeeeee00a00000000000a000000000
0000000070707070000000055555555599499949000555555555551007555555555555500000000000020000eeeeeeeeeeeeeeee00a00000000000a000000000
0000000007070707000000500000000044444444000555555555551007555555555555500000000000000000eeeeeeeeeeeeeeee00a00000000000a000000000
0080000050505050000000500000005000000000000555555555551007555555555555500000000001100000011000000000000000a00000000000a000000000
097f000005050505000000500000000500000000000555555555551007555550075555500000000019910000188100000000000000a00000000000a000000000
a777e00050505050000000500000000000000000000555555555551007555550075555500000000019910000188100000000000000a00000000000a000000000
0b7d000005050505000000500000000000000000000555555555551000000000000000000000000001100000011000000000000000a00000000000a000000000
00c00000505050500000005000000000000000000000555555555100000000000000000000000000000000000000000000000000000a000000000a0000000000
000000000505050500000050000000000000000000000111111110000000000000000000000000000000000000000000000000000000aaaaaaaaa00000000000
00000000505050500000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000050505050000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333333339999999933333333333333333333333300000000cccccccc000000000000000000000000000000000000000000000000000000000000000000000000
333333334545454533555333333333333335553333333333cccccccc000000000000000000000000000000000000000000000000000000000000000000000000
333333334545454535000533333333333350005300000000cccccccc000000000000000000000000000000000000000000000000000000000000000000000000
333333334545454535000555555555555550005333333333cccccccc000000000000000000000000000000000000000000000000000000000000000000000000
333333334545454535000500000000000050005300000000cccccccc000000000000000000000000000000000000000000000000000000000000000000000000
333333334545454533555033333333333335550333333333cccccccc000000000000000000000000000000000000000000000000000000000000000000000000
333333334545454533350333333333333333503300000000cccccccc000000000000000000000000000000000000000000000000000000000000000000000000
333333330000000033350333333333333333503333333333cccccccc000000000000000000000000000000000000000000000000000000000000000000000000
33333333f444444f3335033333333333333350330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111f444444f3335033333333333333350330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccf444444f3335033333333333333350330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccf444444f3335033333333333333350333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccf444444f3335033333333333333350330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccf444444f3335033333333333333350330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777f444444f3335033333333333333350330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333f444444f3335033333333333333350333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc13333333333333335033333333333333350330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccc1333333333333335033333333333333350330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccc133333333333355533333333333333555330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccc13333333333500053333333333335000530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccc1333333333500055555555555555000530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7ccccccc133333333500050000000000005000530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
37ccccccc133333333555033f444444f333555030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
337ccccccc13333333300333f444444f333300330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3337ccccccc133333333333903333333333333333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000
33337ccccccc11111111111901111111333333333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000
333337ccccccccccccccccc90ccccccc111111333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000
3333337cccccccccccccccc90ccccccccccccc133333333333333333333333330000000000000000000000000000000000000000000000000000000000000000
33333337ccccccccccccccc90cccccccccccccc13333333333333333333333330000000000000000000000000000000000000000000000000000000000000000
333333337cccccccccccccc90ccccccccccccccc3333333333333333333333330000000000000000000000000000000000000000000000000000000000000000
33333333377777777777777907777777cccccccc3333333333333333333333330000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333903333333777ccccc3333333333333333333333330000000000000000000000000000000000000000000000000000000000000000
999499949994999499949994999499940000015d5510000000000000000000000000000000000000000000000000000000000000000000077770000000000000
999499949994999499949994999499940001dddddd6d100000000000000000000000000000000070777770000077077077700000000000075570000000000770
44444444444444444444444444444444001dddd6ddd6d50000000077007770000000000000777717555570707755755755707700000000075557777707777670
99499949994999499949994999499949005d55d666dd6d100007771d775557000000000777d555555555d7007555555515575700000000075515555575515670
99499949994999499949994999499949055d5dd6ddd66dd00075501555555570000000075155555d55d5555555d5555555555700000000075d15551555555670
4444444444444444444444444444444405ddddd6dd566dd100755555555555700000000755d5150505d5555555d0111105555700000000075551555555551d70
9499949994999499949994999499949915ddddd6dd5dd6550675555555555570000000075051050101555555551101151500070000000007555d555555555670
9499949994999499949994999499949955dd66dddd5556d5007d5555555555700000000701155555151500000155555555000700000000075d55555555555670
4444444444444444444444444444444455dd6dd6765dd555007555555555557007770000755d5ddd5555155515555dd1d50170000000070755d5555555555670
99499949994999499949994999499949555dd666776665d5007d55555555557075170000755d55d5555555555555ddd55d017000000075755551555555555700
994999499949994999499949994999491ddddd6667766dd1007555555555555755570000755d55d5555555555555ddd555157000000075555555555555555700
444444444444444444444444444444440ddddd66666666d0007555555555555755570000755d55555555555555555ddd55155777700007155555555555555700
94999499949994999499949994999499056ddd677666661000755555555555555557000075550d555555555555555ddd55555505570775155555555555555700
94999499949994999499949994999499005d667766666500007555555555555555557077555505555555555555555ddd55555015057005555555555555555700
444444444444444444444444444444440005d666666610000075555555555555555557555555d555555555555555555555555555511550555555555555555700
49994999499949994999499949994999000005dddd5000000075555555555551505551555555d555555555055555555555555551555555555555555555555700
49994999499949994999499949994999005d550000000000007555505555555555555551555d550155555505555555015d555555555555555555555555555d70
444444444444444444444444444444440d566dd0000000000075555505555515555555555555555515555505555505555d555555555555555555555555555d70
999499949994999499949994999499941dd6dd650000000007d55d5555555515555555555555555555550555550505555d555555555555555555555555555d70
999499949994999499949994999499945d6dd5650000000007d55555555550155555555555555555555555555155155555555555555555515555555555555570
444444444444444444444444444444445d667dd50000000007555555555551055555555555555555555555555551155555555555555555515555555555555570
994999499949994999499949994999495dd666610000000007dd5555555550155555555555555555555555005155555d55555555055555555555555555555700
994999499949994999499949994999490d6766600000000007d55d55555550055555555555555555555505055555515555555555055555555555555555555700
44444444444444444444444444444444005ddd0000000000075d555055555005555555555555555555555000155155555d555555555555555551555555555700
999499949994999499949994999499940066660000000000075d5500555550055555555555555555555550005551155555555555055555555555555555555700
99949994999499949994999499949994060006600000000007d5500055555005555555555555555555551550055005555d555555055555555555555555555700
44444444444444444444444444444444666066060000000007d555505555511555555555555555555555155005510555d5555555055555555555555555555700
99499949994999499949994999499949660660060000000007000000000555055555555555555555555551510555055555555555555555555555555555555700
994999499949994999499949994999496600666600000000075555000055550555055555555d055555551051155505555555555555555555555555555555d700
44444444444444444444444444444444666000060000000007055505505555055555555555555555550055555555055555555105555555555555555555555700
94999499949994999499949994999499060600600000000007555555555550000001151155555555555550000550555555155000000100000011555555555700
949994999499949994999499949994990066660000000000075050100000000000000000101555555d5500000555d55555555510000000000000000010000000
d06ff000000000000666600000000070001100000011600000000000000000000999900000999900070007000700070000766600007666000000000000000000
5f9765000000000000555600000660670221160000225005000000000000000009ff9900091f1f90700000707000007000666600006666000000000000000000
0f9ff5f00000000000663360006aa040015f500000ff50050000000000000000091f1f9009f4f990888888800888880005d6d660056d6d600000000000000000
00aaf3ff000f000006633336006330400faf1011001d1005000000000000000009f4f99004494490085858002858588006666660066666600000000000000000
4f3f334f003130000abb635605555530055521110121219900000000000000009449449999999999888888008888880000666700007666000000000000000000
ff33333f0f033f00b3bb6556035550400d5522221015101f0000000000000000f999999ff999999f822888008228880000766700007666000000000000000000
f0333330000310003b3635600010104005522112000100090000000000000000f99999fff99999ff822888208228882006676665066667650000000000000000
000333330050050005563600005050001122d111002010000000000000000000f99999fff99999ff888882828888828866666666666666660000000000000000
0000000000000000000000700000000000110605001106000000000000000000f99999fff44499ff2f222f882f222f8866666666666666660000000000000000
00000000000000000066006700660070022f5005022f50050000000000000000f44499fff45444442fffff08666fff2866666666666666660000000000000000
000000000000000000a3604000a3606700ff500500ff500500000000000000000454444404545444666fff28655ddd2255666655556666550000000000000000
000f00000000f0000033604000336040001d1099001d100500000000000000000454544409599990655ddd22666fff00007d667000766d500000000000000000
00313f0000331f0003555530035550400121211f0121219900000000000000000959999009999990666f8800088f8800007d566000765dd00000000000000000
0f0330000f0330000555504005555530101510091015101f00000000000000000999999009999990088f8800088f8800007d566000765dd00000000000000000
00031000000310000010104000101040000100000001000900000000000000000ff00ff00ff00ff0008008000080080007d5666000665dd00000000000000000
0050050000500500005050000050504000201000002010000000000000000000fff0fff0fff0fff008808800088088000dd5667000665dd00000000000000000
0009900000000000005116000011000000044400000000000000000000000000000000000000000000000000000000000000000000000000009aaa0000000000
909999090009009005e111660e621000004f4f0000000000000000000000000000000000000000000000000000000000000000000000000009a6ff0000000000
991f919900009900ee1722200ee240000411f10000044060000000000000000000000000000000000000000000000000000000000000000009fddf0000aa0006
099ff99000099990000ed2000004900000ffff00001ff0600000000000000000000000000000000000000000000000000000000000000000996fff0000fa0060
0095590000559900606ed001009449000195591101d120600000000000000000000000000000000000000000000000000000000000000000aaf6ff0000cda600
5299992202225220eee110010f01f100111ff111000ddd90000000000000000000000000000000000000000000000000000000000000000019aff0000cccd000
2529922500522500000051000010100011112111000550000000000000000000000000000000000000000000000000000000000000000000c1a55c0000cc0000
2222252200900900000001000010010011112111005050000000000000000000000000000000000000000000000000000000000000000000c1aa5cc00c0c0000
00000000000000000011000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00900900000000000e62100000661000000000600000006000000000000000000000000000000000000000000000000000000000000000000000000000000000
000990000090090007e2400000ee40000004406000044060000000000000000000000000000000000000000000000000000000000000000000aa000600aa0006
00999900000990000e04990000049000010ff060001ff060000000000000000000000000000000000000000000000000000000000000000000af006000fa0060
02599220029999200f9440f00094490000112d9001012d9000000000000000000000000000000000000000000000000000000000000000000adc060000cda600
0022520000299200000141000f011f0000ddd00000ddd00000000000000000000000000000000000000000000000000000000000000000000cccd0000cccd000
005225000052250000101000001010000005500000055000000000000000000000000000000000000000000000000000000000000000000000cc000000cc0000
00900900009009000010010000101000005050000050500000000000000000000000000000000000000000000000000000000000000000000c0c000000d0c000
__label__
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66686666600060006066600066666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
6697f666606666066066606666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
6a777e66600666066066600666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66b7d666606666066066606666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
666c6666606660006000600066666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005d550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00d566dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01dd6dd6500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05d6dd56500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05d667dd500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05dd6666100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00d67666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005ddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000005555555555555555555555555555555555555555555555555555555555555555555555555555500000000000000000000000000
00000000000000000000000005aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa510000000000000000000000000
00000000000000000000000005a5555555555555555555555555555555555555555555555555555555555555555555555555a510000000000000000000000000
00000000000000000000000005a5555555555555555555555555555555555555555555555555555555555555555555555555a510000000000000000000000000
00000000000000000000000005a5550000000000050000000555550000000555500050000000000000000500050000005555a510000000000000000000000000
00000000000000000000000005a5500aa0aaa0aaa00aa0aaa055500aa0aaa05550aa00aaa0aaa0a0a0a0a00aa00aa0aa0555a510000000000000000000000000
00000000000000000000000005a550a0000a00a000a000a0005550a0a0a0005550a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a055a510000000000000000000000000
00000000000000000000000005a550aaa00a00aa00a000aa055550a0a0aa055550a0a0aaa0aa00aa00a0a0a0a0a0a0a0a055a510000000000000000000000000
00000000000000000000000005a55000a00a00a000a0a0a0055550a0a0a0055550a0a0a0a0a0a0a0a0aaa0a0a0a0a0a0a055a510000000000000000000000000
00000000000000000000000005a550aa00aaa0aaa0aaa0aaa05550aa00a0555550aaa0a0a0a0a0a0a0aaa0aa00aa00aaa055a510000000000000000000000000
00000000000000000000000005a5550005000000000000000055550005005555550000000000000000000000050005000055a510000000000000000000000000
00000000000000000000000005a5555555555555555555555555555555555555555555555555555555555555555555555555a510000000000000000000000000
00000000000000000000000005a5555555555555555555555555555555555555555555555555555555555555555555555555a510000000000000000000000000
00000000000000000000000005aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa510000000000000000000000000
00000000000000000000000005555555555555555555555555555555555555555555555555555555555555555555555555555510000000000000000000000000
00000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111111111110000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000077007777777777000000000077770077770077777700000000000000
00000000000000000000000000000000000000000000000000000000000000000000000077007777777777000000000077770077770077777700000000000000
00000000000000000000000077770000777777000000000000000000000000007777777711775555555577007700777755557755557755557700777700000000
00000000000000000000000077770000777777000000000000000000000000007777777711775555555577007700777755557755557755557700777700000000
00000000000000000077777711dd777755555577000000000000000000777777dd555555555555555555dd770000775555555555555511555577557700000000
00000000000000000077777711dd777755555577000000000000000000777777dd555555555555555555dd770000775555555555555511555577557700000000
00000000000000007755550011555555555555557700000000000000007755115555555555dd5555dd55555555555555dd555555555555555555557700000000
00000000000000007755550011555555555555557700000000000000007755115555555555dd5555dd55555555555555dd555555555555555555557700000000
0000000000000000775555555555555555555555770000000000000000775555dd55115500550055dd55555555555555dd001111111100555555557700000000
0000000000000000775555555555555555555555770000000000000000775555dd55115500550055dd55555555555555dd001111111100555555557700000000
00000000000000667755555555555555555555557700000000000000007755005511005500110011555555555555555511110011115511550000007700000000
00000000000000667755555555555555555555557700000000000000007755005511005500110011555555555555555511110011115511550000007700000000
000000000000000077dd555555555555555555557700000000000000007700111155555555551155115500000000001155555555555555550000007700000000
000000000000000077dd555555555555555555557700000000000000007700111155555555551155115500000000001155555555555555550000007700000000
000000000000000077555555555555555555555577000077777700000000775555dd55dddddd55555555115555551155555555dddd11dd550011770000000000
000000000000000077555555555555555555555577000077777700000000775555dd55dddddd55555555115555551155555555dddd11dd550011770000000000
000000000000000077dd5555555555555555555577007755117700000000775555dd5555dd55555555555555555555555555dddddd5555dd0011770000000000
000000000000000077dd5555555555555555555577007755117700000000775555dd5555dd55555555555555555555555555dddddd5555dd0011770000000000
000000000000000077555555555555555555555555775555557700000000775555dd5555dd55555555555555555555555555dddddd5555551155770000000000
000000000000000077555555555555555555555555775555557700000000775555dd5555dd55555555555555555555555555dddddd5555551155770000000000
000000000000000077555555555555555555555555775555557700000000775555dd5555555555555555555555555555555555dddddd55551155557777777700
000000000000000077555555555555555555555555775555557700000000775555dd5555555555555555555555555555555555dddddd55551155557777777700
0000000000000000775555555555555555555555555555555577000000007755555500dd555555555555555555555555555555dddddd55555555555500555577
0000000000000000775555555555555555555555555555555577000000007755555500dd555555555555555555555555555555dddddd55555555555500555577
000000000000000077555555555555555555555555555555555577007777555555550055555555555555555555555555555555dddddd55555555550011550055
000000000000000077555555555555555555555555555555555577007777555555550055555555555555555555555555555555dddddd55555555550011550055
00000000000000007755555555555555555555555555555555555577555555555555dd5555555555555555555555555555555555555555555555555555555511
00000000000000007755555555555555555555555555555555555577555555555555dd5555555555555555555555555555555555555555555555555555555511
00000000000000007755555555555555555555555511550055555511555555555555dd5555555555555555550055555555555555555555555555555555115555
00000000000000007755555555555555555555555511550055555511555555555555dd5555555555555555550055555555555555555555555555555555115555
000000000000000077555555550055555555555555555555555555555511555555dd555500115555555555550055555555555555001155dd5555555555555555
000000000000000077555555550055555555555555555555555555555511555555dd555500115555555555550055555555555555001155dd5555555555555555
00000000000000007755555555550055555555551155555555555555555555555555555555551155555555550055555555550055555555dd5555555555555555
00000000000000007755555555550055555555551155555555555555555555555555555555551155555555550055555555550055555555dd5555555555555555
0000000000000077dd5555dd55555555555555551155555555555555555555555555555555555555555500555555555500550055555555dd5555555555555555
0000000000000077dd5555dd55555555555555551155555555555555555555555555555555555555555500555555555500550055555555dd5555555555555555
0000000000000077dd55555555555555555555001155555555555555555555555555555555555555555555555555551155551155555555555555555555555555
0000000000000077dd55555555555555555555001155555555555555555555555555555555555555555555555555551155551155555555555555555555555555
00000000000000775555555555555555555555110055555555555555555555555555555555555555555555555555555555111155555555555555555555555555
00000000000000775555555555555555555555110055555555555555555555555555555555555555555555555555555555111155555555555555555555555555
0000000000000077dddd55555555555555555500115555555555555555555555555555555555555555555555000055115555555555dd55555555555555550055
0000000000000077dddd55555555555555555500115555555555555555555555555555555555555555555555000055115555555555dd55555555555555550055
0000000000000077dd5555dd55555555555555000055555555555555555555555555555555555555555500550055555555555511555555555555555555550055
0000000000000077dd5555dd55555555555550000005555550000005555555555555555555555555555500550055555555555511555555555555555555550055
000000000000007755dd5555550055555555009999805557007777b0555557775577555555775777577757770777115555115555555555dd5555555555555555
000000000000007755dd5555550055555555099080880575077000bb055555755757555557555575575757070070115555115555555555dd5555555555555555
000000000000007755dd555500005555555509880882057507b0b0b3055555755757555557775575577757700070555555111155555555555555555555550055
000000000000007755dd55550000555555550880802205750bb00033055555755757555555575575575757070070555555111155555555555555555555550055
0000000000000077dd55550000005555555550222220075550333330055555755775555557755575575717575570005555000055555555dd5555555555550055
0000000000000077dd55550000005555555555000000555555000000555555555555555555555555555511555500005555000055555555dd5555555555550055
0000000000000077dd555555550055555555551111555555555555555555555555555555555555555555115555000055551100555555dd555555555555550055
0000000000000077dd555555550055555555551111555555555555555555555555555555555555555555115555000055551100555555dd555555555555550055
00000000000000770000000000000000005555550055555555555555555555555555555555555555555555115511005555550055555555555555555555555555
00000000000000770000000000000000005555550055555555555555555555555555555555555555555555115511005555550055555555555555555555555555
000000000000007755555555000000005555555500555555005555555555555555dd005555555555555511005511115555550055555555555555555555555555
000000000000007755555555000000005555555500555555005555555555555555dd005555555555555511005511115555550055555555555555555555555555
00000000000000770055555500555500555555550055555555555555555555555555555555555555000055555555555555550055555555555555551100555555
00000000000000770055555500555500555555550055555555555555555555555555555555555555000055555555555555550055555555555555551100555555
00000000000000775555555555555555555555000000000000111155111155555555555555555555555555000000005555005555555555551155550000000000
00000000000000775555555555555555555555000000000000111155111155555555555555555555555555000000005555005555555555551155550000000000
000000000000007755005500110000000000000000000000000000000000110011555555555555dd55550000000000555555dd55555555555555555511000000
000000000000007755005500110000000000000000000000000000000000110011555555555555dd55550000000000555555dd55555555555555555511000000

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010001000000000000000000010001010100000000000000000000000100010101000000000000000000000000010101010101010000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0102020202020202020202020202020300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100464646464646464600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100464646464646464600000000000000754040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100464646464646464600000000000000404040404040404077404040754040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100454545454545454500000000000000404076404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100555555555555555500000000000000404040404040404040407640404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100656565656565656500000000000000404040404040424344404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100656565656565656500000000000000404040404040525354404040404077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100656565656565656500000000000000746140407740626364404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100656565656565656500000000000000706061404040405140404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100656565656565656500000000000000757071505050724173505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100000000000000000000000000000000404040404040405140404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100000000000000000000000000000000404076404040405140404040407740000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001205000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001805018050170502005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001e0501c050190501505015050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
