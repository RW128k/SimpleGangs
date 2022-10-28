# SimpleGangs
Add fully featured gangs to your server in minutes with SimpleGangs! Designed with users, admins, and owners in mind, SimpleGangs is easy and intuitive to use, a breeze to administer and quick to get up and running. Includes features such as a communal Gang Bank, a private Gang Chat and in game HUD.

Gangs are groups which players can create and invite others to join. These groups allow players to see when their fellow members are online, chat privately, transfer money and much more. Gangs allow for a more immersive and collaborative gameplay experience when working with other players, for example during a raid, as features such as the HUD and disabled friendly fire can be made use of.

## Download and Installation

To download the addon, head to the releases section and select the latest version 'SimpleGangs 1.1' or click [here](https://github.com/RW128k/SimpleGangs/releases/tag/v1.1). Download and extract the zip archive 'SimpleGangs-1.1.zip' found on the page in the assets section.

**The following extract is taken from *Section 1. Installation* of the Owner's Manual PDF included in the repository.**

SimpleGangs Installs to your server much like any other addon. 

Move the entire folder titled ‘simplegangs_1.1’ included with your download into the *garrysmod/addons/* directory on your server. On the next boot of your server, SimpleGangs will be active.

![Installation](https://user-images.githubusercontent.com/45309105/131163082-0d9a194b-fb70-4de3-bd6f-f4db18725000.png)

While the addon does not require additional installation steps or configuration, it is advised you review the default settings and make any changes you feel best suit your needs. A detailed explanation of this can be found in *Section 2. Configuration*.

If you plan to use SimpleGangs in conjunction with a MySQL Database, you should first read the instructions under *Section 5. MySQL and the Database*.

## Features
### User-Friendly Interface

The SimpleGangs User Interface is designed to be straightforward and simple to use. While a comprehensive user and admin guide is included in the repository, detailed labels and textboxes can be found all over the UI, pointing you in the right direction. In game windows have been designed to scale so that they look great on even the smallest screen resolutions. You can customise lots of aspects of the UI to best fit the theme of your server, most notably opting to refer to gangs by another name, like organizations or clans.

### Administration Console

The Administration Console is the fastest way for server admins to manage gangs. They can browse all, or search for individual gangs and members by name. Important information about a member or gang can be quickly found in the browser list, or a more detailed view can be opened by simply clicking the search result. Admins have a wide range of management options available to them, such as kicking members, deleting, renaming, and merging gangs. Which user groups have access to the console can be easily be set in the configuration file.

### Leaderboard

The Leaderboard is available to all online players and displays the top 10 ranking gangs with the highest bank balances, as well as the highest DarkRP wallet values on the server. The player’s own value is highlighted in gold if they are in the top 10, or otherwise displayed with their rank at the bottom. Like many other aspects of the addon, the Leaderboard can be customised to display only the details you need or even disabled completely.

### In-game HUD

Designed for servers and players who like to participate in raids as a group, the gang HUD allows you to see the real-time health, shield status and other data of all online members of your gang at a glance. This can be enabled and disabled at the player’s choosing through the main menu. The anchor point and position on the screen can be set up in the configuration file, to avoid overlapping any other custom HUD’s.

### Disable Friendly Fire & Hurt Sounds

SimpleGangs gives you the option to disable damage between members of the same gang. This allows for an interesting game mechanic during raids or defence as a gang, however this feature may not be appropriate for some game modes or servers. Also, you can choose to make players emit an ‘ouch!’ sound effect when they have been hit by a member of the same gang whether friendly fire is disabled or not.

### Gang Chat & Team chat replacement

Online gang members can communicate with each other privately as a group using the gang chat feature. This appears similarly to normal game chat, however messages are prefixed with \<Gang>. Messages can be sent by using a chat command or on some servers the team chat feature may be redundant, so SimpleGangs allows you to override it such that all team messages are redirected as gang chats.

### Gang Bank

When running a DarkRP server, players have access to the gang bank which they can deposit and withdraw money from into their wallet. The bank serves as a method of stockpiling communal funds and transferring cash between gang members. Paired with the leaderboard, gangs can compete with one another to accumulate the highest-ranking balance on the server. The gang bank allows owners to choose from 5 different currency symbols: Dollars, Pounds, Euros, Rubles and Yen.

### MySQL Support

SimpleGangs can store all of its data on an external MySQL server instead of the built-in SQLite database if you choose. This allows other applications to interact with your server’s gang data, for example, to show bank statistics on a website or a player’s gang on the loading screen. The included Owner's Manual PDF explains in detail how to set this up and how data is formatted. Please note this feature is optional but requires the free MySQLOO version 9 module if you decide to use it.

### Modular & Customisable

All of the features described above can be enabled or disabled at your discretion, as well as many other settings to make SimpleGangs your very own. Everything from the background color & transparency of the UI to the chat commands can be customised, tailoring your player’s experience. Changes to the configuration are quick and easy to make when accompanied with the Owner's Manual which explains each option in detail.

## Showcase Video
[![thumbnail](https://user-images.githubusercontent.com/45309105/131161449-2f56263b-efb7-477b-be98-67f211ec503e.png)](https://www.youtube.com/watch?v=CkNouwMIM0Y)
[Click here or above to watch the Addon Showcase video on YouTube](https://www.youtube.com/watch?v=CkNouwMIM0Y)
