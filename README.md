# GINVITER Addon

## Description
GINVITER is a World of Warcraft addon that automatically invites players without a guild in specific zones to join your guild. It helps guild recruiters easily invite potential members while they explore the world. This is tested in WoW Client 3.3.5a (Wrath of the Lich King)

![Untitled](https://github.com/nelbin4/GINVITER/assets/20941975/d0d5eae4-7db5-436f-b5be-97f281128442)

## Features
- Automatically invites players without a guild in specified zones.
- Limits guild invites to a maximum of two per person to avoid spamming or annoying players.
- Customizable list of zones to search for potential recruits.
- User-friendly UI with start/stop buttons and status display.
- Slash commands to show/hide the addon UI.

## Installation
1. Download the latest version of the addon from the [Releases](https://github.com/nelbin4/GINVITER/releases) page.
2. Extract the contents of the downloaded ZIP file.
3. Copy the extracted "GINVITER" folder to your World of Warcraft\Interface\AddOns directory.

## Usage
- Type `/GINVITER show` to show the addon's UI.
- Click the "Start" button to begin searching for potential recruits in the specified zones.
- Click the "Stop" button to stop the search.
- Type `/GINVITER hide` to hide the addon's UI.

## Configuration
The addon can be configured by modifying the Lua file directly. Open the "GINVITER.lua" file in a text editor and make the desired changes. You can customize the following settings:

- **Zones**: Add or remove zones from the `zones` table to specify which zones to search for potential recruits.
- **Loop Interval**: Adjust the `loopInterval` variable to set the interval (in seconds) between each search loop.
- **Level**: Set the `level` variable to the desired level range of players to invite.

## Contributions
Contributions to the GINVITER addon are welcome! If you encounter any issues, have suggestions for improvements, or would like to contribute code, feel free to open an issue or submit a pull request on the [GitHub repository](https://github.com/nelbin4/GINVITER).

## License
This addon is distributed under the [MIT License](https://opensource.org/licenses/MIT). Feel free to modify and distribute the code as per the terms of the license.

## Credits
GINVITER was developed by Your Name. Special thanks to the WoW community for their support and feedback.

