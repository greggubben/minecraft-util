################################################################################
# This is the Minecraft Overviewer settings file.

# See http://docs.overviewer.org/en/latest/options/#command-line-options
# for options you can set

# See http://docs.overviewer.org/en/latest/options/#settings-file
# for more info about settings files.

# This file is a python script, so you can import any python module you wish or
# use any built-in python function, though this is not normally necessary

# If you specify a configuration option in both a settings.py file and on the 
# command line, the value from the command line will take precedence

# Importing the os python module
import os


################################################################################
# Functions

#
# Debug the POI Markers
#
def debugPoiMarkersFilter(poi):
    import os
    import json
    tmp_dir = os.environ['MCOVERVIEWERTMP']
    debug_dir = tmp_dir + "/debug"
    if not os.path.exists(debug_dir):
        os.makedirs(debug_dir)

    poi_id = poi['id']
    debug_file = debug_dir + "/" + poi_id
    with open(debug_file, 'a') as poi_debug:
        poi_debug.write(poi['id'])
        poi_debug.write("\n")
        try:
            json.dump(poi, poi_debug)
        except TypeError:
            poi_debug.write("TypeError: Could not generate JSON.")
        poi_debug.write("\n")
    

debugpoimarkers = {'name': "Debug", 'filterFunction': debugPoiMarkersFilter}

#
# Display Signs and their Message
#
def signFilter(poi):
    import sys
    import json
    # Function to extract text lines from the new minecraft:sign POI
    def getSignLine(poi,line):
        text = ""
        textLineName = "Text" + line
        try:
            if textLineName in poi:
                textline = poi[textLineName]
                #print ("textline=:", textline, type(textline))
                if isinstance(textline,unicode):
                    textdict = json.loads(textline)
                elif isinstance(textline, dict):
                    textdict = textline
                if 'text' in textdict:
                    u = textdict['text']
                    text = textdict['text']
        except Exception as e:
            print ("Unexpected error:", sys.exc_info()[0])
            print ("Text:", poi)
            print ("Exception")
            print (type(e))
            print (e.args)
            print (e)
        return text


    if poi['id'] in ["Sign", "minecraft:sign"]:
        text1 = ""
        text2 = ""
        text3 = ""
        text4 = ""
        if poi['id'] in ["Sign", "minecraft:sign"]:
            if 'Text1' in poi:
                text1 = poi['Text1']
            if 'Text2' in poi:
                text2 = poi['Text2']
            if 'Text3' in poi:
                text3 = poi['Text3']
            if 'Text4' in poi:
                text4 = poi['Text4']

        if poi['id'] in ["minecraft:sign_nomore"]:
            text1 = getSignLine(poi,"1")
            text2 = getSignLine(poi,"2")
            text3 = getSignLine(poi,"3")
            text4 = getSignLine(poi,"4")

        if text1 != "" or text2 != "" or text3 != "" or text4 != "":
            return "\n".join([text1, text2, text3, text4])

signs = {'name': "Signs", 'filterFunction': signFilter}

#
# Display Chests and how many items are in them
#
def chestFilter(poi):
    from overviewer_core import items
    if poi['id'] in ["Chest", "minecraft:chest"]:
        if 'Items' in poi:
            chest_text = "Chest with {} items".format(len(poi['Items']))
            items_text = "Chest\nEmpty"
            chest_items = dict()
            for item in poi["Items"]:
                item_name = items.id2item(item["id"])
                if item_name.startswith("minecraft:"):
                    item_name = item_name[10:]
                if item_name in chest_items:
                    chest_items[item_name] += item["Count"]
                else:
                    chest_items[item_name] = item["Count"]
            if len(chest_items) > 0:
                items_text = ""
                for item_name in chest_items.keys():
                    items_text += "\n{} of {}".format(chest_items[item_name], item_name)
            return (chest_text, items_text)

chests = {'name': "Chests", 'filterFunction': chestFilter, 'icon': "chest.png"}

#
# Display the last know location of a Player
#
def playerIcons(poi):
    def level2Icons (amount, fullIcon, halfIcon):
        icon_text = ""
        full = int(amount/2)
        half = amount%2
        for f in range(0, full):
            icon_text += "<img src='{}'>".format(fullIcon)
        if half == 1:
            icon_text += "<img src='{}'>".format(halfIcon)
        return icon_text

    # Dict of defense points Each row goes leather/cm/iron/diamond/gold
    # and each column is helm/chest/pants/shoes
    # Everything is doubled so we can feed it easier into metaHelper()
    armor = {298 : 1, 299 : 3, 300 : 2, 301 : 1,
             302 : 2, 303 : 5, 304 : 4, 305 : 1,
             306 : 2, 307 : 6, 308 : 5, 309 : 2,
             310 : 3, 311 : 8, 312 : 6, 313 : 3,
             314 : 2, 315 : 5, 316 : 3, 317 : 1}

    if poi['id'] == 'Player':
        poi['icon'] = "http://overviewer.org/avatar/%s" % poi['EntityId']
        person_text = "Last known location for {}".format(poi['EntityId'])
        person_level_text = "{} ({})".format(poi['EntityId'], poi['XpLevel'])
        #armor_points = 0
        #for i in poi['Inventory']:
        #    if i['Slot'] in (100, 101, 102, 103):
        #        armor_points += armor[i['id']]
        #armor_text = "Armor = {}/20\n{}".format(armor_points, level2Icons(armor_points,"armor.png","half_armor.png"))
        health_text = "Health = {}/20\n{}".format(poi['Health'], level2Icons(poi['Health'],"heart.png","half_heart.png"))
        hunger_text = "Hunger = {}/20\n{}".format(poi['foodLevel'], level2Icons(poi['foodLevel'],"hunger.png","half_hunger.png"))
        location_text = "X:{} Y:{} Z:{}".format(poi['x'], poi['y'], poi['z'])
        return (person_text, "\n".join([person_level_text, health_text, hunger_text, location_text]))
        #return (person_text, "\n".join([person_level_text, armor_text, health_text, hunger_text, location_text]))

players = {'name': "Players", 'filterFunction': playerIcons}

#
# Show the Player's spawn points
#
def bedFilter(poi):
    #'''This finds the beds and formats the popup bubble a bit.'''
    if poi['id'] == 'PlayerSpawn':
        image_html = "<img src='http://overviewer.org/avatar/{}' />".format(poi['EntityId'])
        spawn_text = "\n".join(["Current spawn point for {}".format(poi['EntityId']),
                           "X:{} Y:{} Z:{}".format(poi['x'], poi['y'], poi['z'])])
        return (spawn_text,"\n".join([image_html, spawn_text]))

playerSpawns = {'name': "Player Spawns", 'filterFunction': bedFilter, 'icon': "bed.png"}

#
# Show all the pets in the map
#
def petFilter(poi):
    import os
    import sys
    import json
    from urllib.request import urlopen
    from urllib.error import URLError
    UUID_LOOKUP_URL = 'https://sessionserver.mojang.com/session/minecraft/profile/'
    tmp_dir = os.environ['MCOVERVIEWERTMP']
    UUID_DIR = tmp_dir + '/uuid'
    if not os.path.exists(UUID_DIR):
        os.makedirs(UUID_DIR)
    # Show the various pets a Player could have and where they are
    def level2Icons (amount, fullIcon, halfIcon):
        icon_text = ""
        full = int(amount/2)
        half = amount%2
        for f in range(0, full):
            icon_text += "<img src='{}'>".format(fullIcon)
        if half == 1:
            icon_text += "<img src='{}'>".format(halfIcon)
        return icon_text

    if poi['id'] in ["EntityHorse", "Wolf", "Ocelot", "minecraft:horse", "minecraft:donkey", "minecraft:mule", "minecraft:skeleton_horse", "minecraft:zombie_horse", "minecraft:wolf", "minecraft:ocelot", "minecraft:llama"]:
        pet_text = poi['id']
        image_html = ""
        health_text = ""
        health_max = 20
        if poi['id'] == "EntityHorse":
            poi['icon'] = "horse.png"
            if poi['Type'] == 0:
                pet_text = "Horse"
            elif poi['Type'] == 1:
                pet_text = "Donkey"
            elif poi['Type'] == 2:
                pet_text = "Mule"
            elif poi['Type'] == 3:
                pet_text = "Zombie Horse"
            elif poi['Type'] == 4:
                pet_text = "Skeleton Horse"
            health_max = 30

        if poi['id'] in ["minecraft:horse"]:
            poi['icon'] = "horse_head.png"
            pet_text = "Horse"
            health_max = 30

        if poi['id'] in ["minecraft:donkey"]:
            poi['icon'] = "donkey_head.png"
            pet_text = "Donkey"
            health_max = 30

        if poi['id'] in ["minecraft:mule"]:
            poi['icon'] = "mule_head.png"
            pet_text = "Mule"
            health_max = 30

        if poi['id'] in ["minecraft:skeleton_horse"]:
            poi['icon'] = "skeleton_horse_head.png"
            pet_text = "Skeleton Horse"
            health_max = 30

        if poi['id'] in ["minecraft:zombie_horse"]:
            poi['icon'] = "zombie_horse_head.png"
            pet_text = "Skeleton Horse"
            health_max = 30

        if poi['id'] in ["minecraft:llama"]:
            poi['icon'] = "llama_head.png"
            pet_text = "Llama"
            health_max = 22

        if poi['id'] in ["Wolf", "minecraft:wolf"]:
            poi['icon'] = "wolf_face.png"
            pet_text = "Wolf"
            health_max = 20

        if poi['id'] in ["Ocelot", "minecraft:ocelot"]:
            poi['icon'] = "ocelot_face.png"
            pet_text = "Ocelot"
            health_max = 20

        playername = ""
        if 'Owner' in poi and poi['Owner'] != "":
            playername = poi['Owner']

        if 'OwnerUUID' in poi and poi['OwnerUUID'] != "":
            ownerUUID = poi['OwnerUUID'].replace('-','')
            ownerUUIDFile = UUID_DIR + "/" + ownerUUID
            if os.path.isfile(ownerUUIDFile):
                print ("From UUID File: " + ownerUUIDFile)
                with open(ownerUUIDFile, 'r') as uuid_file:
                    playername = uuid_file.read()
            else:
                try:
                    retval = urlopen(UUID_LOOKUP_URL + ownerUUID).read()
                    #print ("Received:" + retval)
                    profile = json.loads(retval)
                    if 'name' in profile:
                        playername = profile['name']
                        with open(ownerUUIDFile, 'w') as uuid_file:
                            uuid_file.write(playername)
                        print ("Create UUID File: " + ownerUUIDFile)
                except (ValueError, URLError):
                    print ("Unable to get player name for UUID '{0}'".format(poi['OwnerUUID']))
                except:
                    print ("Unexpected error:", sys.exc_info()[0])
        if playername != "":
            pet_text = "{}'s {}".format(playername, pet_text)
            image_html = "<img src='http://overviewer.org/avatar/{}' />".format(playername)
            health_text = "Health = {}/{}\n{}".format(poi['Health'], health_max, level2Icons(poi['Health'],"heart.png","half_heart.png"))

        if 'CustomName' in poi and poi["CustomName"] != "":
            pet_text += "\n{}".format(poi["CustomName"])

        return (pet_text,"\n".join([image_html, pet_text, health_text]))

pets = {'name': "Pets", 'filterFunction': petFilter}

#
# Show the Mob Spawners on the map
#
def spawnerFilter(poi):
    if poi["id"] in ["MobSpawner", "minecraft:mob_spawner"]:
        info = "Mob Spawner\n"
        if "EntityId" in poi:
            info += "%s \n" % poi["EntityId"]
        elif "SpawnPotentials" in poi:
            plus = ""
            for spawns in poi["SpawnPotentials"]:
                weight = ""
                entity = ""
                if "Weight" in spawns:
                    weight = spawns["Weight"]
                if "Entity" in spawns and "id" in spawns["Entity"]:
                    entity = spawns["Entity"]["id"]
                info += "{}{}({})\n".format(plus, entity, weight)
                plus = " or "
        info += "X:{} Y:{} Z:{}".format(poi['x'], poi['y'], poi['z'])
        return info

spawners = {'name': "Spawners", 'filterFunction': spawnerFilter, 'icon': "spawner.png"}

#
# Show the Tags on the map
#
def tagFilter(poi):
    import os
    import sys
    import json
    from urllib.request import urlopen
    from overviewer_core import items
    UUID_LOOKUP_URL = 'https://sessionserver.mojang.com/session/minecraft/profile/'
    tmp_dir = os.environ['MCOVERVIEWERTMP']
    UUID_DIR = tmp_dir + '/uuid'
    if not os.path.exists(UUID_DIR):
        os.makedirs(UUID_DIR)

    if "CustomName" in poi and poi["CustomName"] != "":
        name = poi["CustomName"]
            
        item_name = poi["id"]
        #item_name = items.id2item(poi["id"])
        if item_name.startswith("minecraft:"):
            item_name = item_name[10:]

        playername = ""
        if 'Owner' in poi and poi['Owner'] != "":
            playername = poi['Owner']

        if 'OwnerUUID' in poi and poi['OwnerUUID'] != "":
            ownerUUID = poi['OwnerUUID'].replace('-','')
            ownerUUIDFile = UUID_DIR + "/" + ownerUUID
            if os.path.isfile(ownerUUIDFile):
                print ("From UUID File: " + ownerUUIDFile)
                with open(ownerUUIDFile, 'r') as uuid_file:
                    playername = uuid_file.read()
            else:
                try:
                    retval = urlopen(UUID_LOOKUP_URL + ownerUUID).read()
                    #print ("Received:" + retval)
                    profile = json.loads(retval)
                    if 'name' in profile:
                        playername = profile['name']
                        with open(ownerUUIDFile, 'w') as uuid_file:
                            uuid_file.write(playername)
                        print ("Create UUID File: " + ownerUUIDFile)
                except (ValueError, URLError):
                    print ("Unable to get player name for UUID '{0}'".format(poi['OwnerUUID']))
                except:
                    print ("Unexpected error:", sys.exc_info()[0])

        if playername != "":
            playername = playername + "'s"

        return "{}\n{} {}".format(name, playername, item_name)

tags = {'name': "Tags", 'filterFunction': tagFilter, 'icon': "tag.png"}

#
# Show the Villagers on the map
#
def villagerFilter(poi):
    professions = {0: {"name": "Farmer",
                       "image": "farmer.png",
                       "careers": {0: "Unknown",
                                   1: "Farmer",
                                   2: "Fisherman",
                                   3: "Shepherd",
                                   4: "Fletcher"}
                      },
                   1: {"name": "Librarian",
                       "image": "librarian.png",
                       "careers": {0: "Unknown",
                                   1: "Librarian",
                                   2: "Cartographer"}
                      },
                   2: {"name": "Cleric",
                       "image": "cleric.png",
                       "careers": {0: "Unknown",
                                   1: "Cleric"}
                      },
                   3: {"name": "Blacksmith",
                       "image": "blacksmith.png",
                       "careers": {0: "Unknown",
                                   1: "Armorer",
                                   2: "Weapon Smith",
                                   3: "Tool Smith"}
                      },
                   4: {"name": "Butcher",
                       "image": "butcher.png",
                       "careers": {0: "Unknown",
                                   1: "Butcher",
                                   2: "Leatherworker"}
                      },
                   5: {"name": "Nitwit",
                       "image": "nitwit.png",
                       "careers": {0: "Unknown",
                                   1: "Nitwit"}
                      }
                  }

    if poi["id"] == "minecraft:villager":
        profession_name = ""
        career_name = ""
        custom_name = ""
        if "CustomName" in poi and poi["CustomName"] != "":
            custom_name = poi["CustomName"] + "\n"
        if "Profession" in poi:
            profession_id = poi["Profession"]
            #print ("profession_id", profession_id, type(profession_id))
            profession_name = profession_id
            if profession_id in professions:
                profession = professions[profession_id]
                profession_name = profession["name"]
                #print ("profession_name", profession_name)
                poi["icon"] = profession["image"]
                if "Career" in poi:
                    career_id = poi["Career"]
                    #print ("career_id", career_id, type(career_id))
                    career_name = career_id
                    if career_id in profession["careers"]:
                        career_name = profession["careers"][career_id]

        return "{}Profession: {}\nCareer: {}".format(custom_name, profession_name, career_name)

villagers = {'name': "Villagers", 'filterFunction': villagerFilter}

#
# Show the Portals on the map
#
def netherportalFilter(poi):
    if poi["id"] == "Nether Portal":
        info = "Nether Portal\n"
        info += "X:{} Y:{} Z:{}".format(poi['x'], poi['y'], poi['z'])
        return info

netherportals = {'name': "Nether Portals", 'filterFunction': netherportalFilter, 'icon': "portal.png"}

################################################################################
worlds["mainworld"] = os.environ['OV_WORLD']

outputdir = os.environ['OV_OUTPUTBASEDIR']

customwebassets = os.environ['OV_WEBASSETS']

processes = 8

renders["day"] = {
    'world': 'mainworld',
    'title': 'Day NE',
    'rendermode': normal,
    'dimension': "overworld",
    'northdirection': "upper-left",
    'texturepath': os.environ['MCCLIENTZIP'],
    'markers': [debugpoimarkers, signs, chests, players, playerSpawns, pets, spawners, tags, villagers],
}
    #'markers': [debugpoimarkers, signs, chests, players, playerSpawns, pets, netherportals],

renders["night"] = {
    'world': 'mainworld',
    'title': 'Night NE',
    'rendermode': night,
    'dimension': "overworld",
    'northdirection': "upper-left",
    'texturepath': os.environ['MCCLIENTZIP'],
}

renders["cave"] = {
    'world': 'mainworld',
    'title': 'Cave NE',
    'rendermode': cave,
    'dimension': "overworld",
    'northdirection': "upper-left",
    'texturepath': os.environ['MCCLIENTZIP'],
    'markers': [signs, chests, players, pets, spawners, tags],
}

renders["daysw"] = {
    'world': 'mainworld',
    'title': 'Day SW',
    'rendermode': smooth_lighting,
    'dimension': "overworld",
    'northdirection': "lower-right",
    'texturepath': os.environ['MCCLIENTZIP'],
    'markers': [signs, chests, players, playerSpawns, pets, spawners, tags],
}
    #'markers': [signs, chests, players, playerSpawns, pets, netherportals],

renders["nightsw"] = {
    'world': 'mainworld',
    'title': 'Night SW',
    'rendermode': smooth_night,
    'dimension': "overworld",
    'northdirection': "lower-right",
    'texturepath': os.environ['MCCLIENTZIP'],
}

renders["cavesw"] = {
    'world': 'mainworld',
    'title': 'Cave SW',
    'rendermode': cave,
    'dimension': "overworld",
    'northdirection': "lower-right",
    'texturepath': os.environ['MCCLIENTZIP'],
    'markers': [signs, chests, players, pets, spawners, tags],
}
    #'markers': [signs, chests, players, pets, spawners, netherportals],

renders["nether"] = {
    'world': 'mainworld',
    'title': 'Nether NE',
    'rendermode': nether,
    'dimension': "nether",
    'northdirection': "upper-left",
    'texturepath': os.environ['MCCLIENTZIP'],
    'markers': [signs, chests, players, pets, spawners, tags],
} 
    #'markers': [signs, chests, players, pets, spawners, netherportals],

renders["nethersw"] = {
    'world': 'mainworld',
    'title': 'Nether SW',
    'rendermode': nether_smooth_lighting,
    'dimension': "nether",
    'northdirection': "lower-right",
    'texturepath': os.environ['MCCLIENTZIP'],
    'markers': [signs, chests, players, pets, spawners, tags],
} 
    #'markers': [signs, chests, players, pets, spawners, netherportals],

renders['biomeover'] = {
    'world': 'mainworld',
    'title': "Biome Coloring Overlay",
    'rendermode': [ClearBase(), BiomeOverlay()],
    'dimension': "overworld",
    'northdirection': "upper-left",
    'texturepath': os.environ['MCCLIENTZIP'],
    'overlay': ['day']
}

renders['mineralover'] = {
    'world': 'mainworld',
    'title': "Mineral Coloring Overlay",
    'rendermode': [ClearBase(), MineralOverlay()],
    'dimension': "overworld",
    'northdirection': "upper-left",
    'texturepath': os.environ['MCCLIENTZIP'],
    'overlay': ['day']
}

renders['spawnover'] = {
    'world': 'mainworld',
    'title': "Spawn Coloring Overlay",
    'rendermode': [ClearBase(), SpawnOverlay()],
    'dimension': "overworld",
    'northdirection': "upper-left",
    'texturepath': os.environ['MCCLIENTZIP'],
    'overlay': ['day']
}

renders['slimeover'] = {
    'world': 'mainworld',
    'title': "Slime Coloring Overlay",
    'rendermode': [ClearBase(), SlimeOverlay()],
    'dimension': "overworld",
    'northdirection': "upper-left",
    'texturepath': os.environ['MCCLIENTZIP'],
    'overlay': ['day']
}
