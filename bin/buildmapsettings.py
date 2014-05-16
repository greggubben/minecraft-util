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

# Display Signs and their Message
def signFilter(poi):
    if poi['id'] == 'Sign':
        return "\n".join([poi['Text1'], poi['Text2'], poi['Text3'], poi['Text4']])

signs = {'name': "Signs", 'filterFunction': signFilter}

# Display Chests and how many items are in them
def chestFilter(poi):
    from overviewer_core import items
    if poi['id'] == "Chest":
        chest_text = "Chest with {} items".format(len(poi['Items']))
        items_text = "Chest\nEmpty"
        chest_items = dict()
        for item in poi["Items"]:
            item_name = items.id2item(item["id"])
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

# Display the last know location of a Player
def playerIcons(poi):
    def level2Icons (amount, fullIcon, halfIcon):
        icon_text = ""
        full = amount/2
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
        armor_points = 0
        for i in poi['Inventory']:
            if i['Slot'] in (100, 101, 102, 103):
                armor_points += armor[i['id']]
        armor_text = "Armor = {}/20\n{}".format(armor_points, level2Icons(armor_points,"armor.png","half_armor.png"))
        health_text = "Health = {}/20\n{}".format(poi['Health'], level2Icons(poi['Health'],"heart.png","half_heart.png"))
        hunger_text = "Hunger = {}/20\n{}".format(poi['foodLevel'], level2Icons(poi['foodLevel'],"hunger.png","half_hunger.png"))
        location_text = "X:{} Y:{} Z:{}".format(poi['x'], poi['y'], poi['z'])
        return (person_text, "\n".join([person_level_text, armor_text, health_text, hunger_text, location_text]))

players = {'name': "Players", 'filterFunction': playerIcons}

def bedFilter(poi):
    #'''This finds the beds and formats the popup bubble a bit.'''
    if poi['id'] == 'PlayerSpawn':
        image_html = "<img src='http://overviewer.org/avatar/{}' />".format(poi['EntityId'])
        spawn_text = "\n".join(["Current spawn point for {}".format(poi['EntityId']),
                           "X:{} Y:{} Z:{}".format(poi['x'], poi['y'], poi['z'])])
        return (spawn_text,"\n".join([image_html, spawn_text]))

playerSpawns = {'name': "Player Spawns", 'filterFunction': bedFilter, 'icon': "bed.png"}

def petFilter(poi):
    import json
    import urllib2
    UUID_LOOKUP_URL = 'https://sessionserver.mojang.com/session/minecraft/profile/'
    # Show the various pets a Player could have and where they are
    def level2Icons (amount, fullIcon, halfIcon):
        icon_text = ""
        full = amount/2
        half = amount%2
        for f in range(0, full):
            icon_text += "<img src='{}'>".format(fullIcon)
        if half == 1:
            icon_text += "<img src='{}'>".format(halfIcon)
        return icon_text

    if poi['id'] in ["EntityHorse", "Wolf", "Ocelot", "Ozelot"]:
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

        if poi['id'] == "Wolf":
            poi['icon'] = "wolf.png"
            pet_text = "Wolf"
            health_max = 20
            #for n in poi:
                #pet_text += "\n{}={}".format(n,poi[n])
            #if 'Owner' in poi and poi['Owner'] != "":
                #pet_text = "{}'s Wolf".format(poi['Owner'])
                #image_html = "<img src='http://overviewer.org/avatar/{}' />".format(poi['Owner'])
                #health_text = "Health = {}/20\n{}".format(poi['Health'], level2Icons(poi['Health'],"heart.png","half_heart.png"))

        if poi['id'] in ["Ocelot", "Ozelot"]:
            poi['icon'] = "ocelot.png"
            pet_text = "Ocelot"
            health_max = 20

        playername = ""
        if 'Owner' in poi and poi['Owner'] != "":
            playername = poi['Owner']

        if 'OwnerUUID' in poi and poi['OwnerUUID'] != "":
            try:
                profile = json.loads(urllib2.urlopen(UUID_LOOKUP_URL + poi['OwnerUUID'].replace('-','')).read())
                if 'name' in profile:
                    playername = profile['name']
            except (ValueError, urllib2.URLError):
                logging.warning("Unable to get player name for UUID %s", playername)
        if playername != "":
            pet_text = "{}'s {}".format(playername, pet_text)
            image_html = "<img src='http://overviewer.org/avatar/{}' />".format(playername)
            health_text = "Health = {}/{}\n{}".format(poi['Health'], health_max, level2Icons(poi['Health'],"heart.png","half_heart.png"))

        if 'CustomName' in poi and poi["CustomName"] != "":
            pet_text += "\n{}".format(poi["CustomName"])

        return (pet_text,"\n".join([image_html, pet_text, health_text]))

pets = {'name': "Pets", 'filterFunction': petFilter}

def spawnerFilter(poi):
    if poi["id"] == "MobSpawner":
        info = "[MobSpawner] \n%s \n" % poi["EntityId"]
        info += "X:{} Y:{} Z:{}".format(poi['x'], poi['y'], poi['z'])
        return info

spawners = {'name': "Spawners", 'filterFunction': spawnerFilter, 'icon': "spawner.png"}

################################################################################
worlds["mainworld"] = os.environ['OV_WORLD']

outputdir = os.environ['OV_OUTPUTBASEDIR']

customwebassets = os.environ['OV_WEBASSETS']

renders["day"] = {
    'world': 'mainworld',
    'title': 'Day NE',
    'rendermode': smooth_lighting,
    'dimension': "overworld",
    'northdirection': "upper-left",
    'texturepath': "/home/minecraft/.minecraft",
    'markers': [signs, chests, players, playerSpawns, pets],
}

renders["night"] = {
    'world': 'mainworld',
    'title': 'Night NE',
    'rendermode': smooth_night,
    'dimension': "overworld",
    'northdirection': "upper-left",
    'texturepath': "/home/minecraft/.minecraft",
}

renders["cave"] = {
    'world': 'mainworld',
    'title': 'Cave NE',
    'rendermode': cave,
    'dimension': "overworld",
    'northdirection': "upper-left",
    'texturepath': "/home/minecraft/.minecraft",
    'markers': [signs, chests, players, pets, spawners],
}


renders["daysw"] = {
    'world': 'mainworld',
    'title': 'Day SW',
    'rendermode': smooth_lighting,
    'dimension': "overworld",
    'northdirection': "lower-right",
    'texturepath': "/home/minecraft/.minecraft",
    'markers': [signs, chests, players, playerSpawns, pets],
}

renders["nightsw"] = {
    'world': 'mainworld',
    'title': 'Night SW',
    'rendermode': smooth_night,
    'dimension': "overworld",
    'northdirection': "lower-right",
    'texturepath': "/home/minecraft/.minecraft",
}

renders["cavesw"] = {
    'world': 'mainworld',
    'title': 'Cave SW',
    'rendermode': cave,
    'dimension': "overworld",
    'northdirection': "lower-right",
    'texturepath': "/home/minecraft/.minecraft",
    'markers': [signs, chests, players, pets, spawners],
}

renders["nether"] = {
    'world': 'mainworld',
    'title': 'Nether NE',
    'rendermode': nether_smooth_lighting,
    'dimension': "nether",
    'northdirection': "upper-left",
    'texturepath': "/home/minecraft/.minecraft",
    'markers': [signs, chests, players, pets, spawners],
} 

renders["nethersw"] = {
    'world': 'mainworld',
    'title': 'Nether SW',
    'rendermode': nether_smooth_lighting,
    'dimension': "nether",
    'northdirection': "lower-right",
    'texturepath': "/home/minecraft/.minecraft",
    'markers': [signs, chests, players, pets, spawners],
} 

