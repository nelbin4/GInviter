# GINVITER

GINVITER is a World of Warcraft addon that automates the process of inviting players to your guild. It searches for players within a specified level range and zone and invites those who are not already in a guild.
This was tested for WoW Client Patch 3.3.5a (Wrath of the Lich King).

## Features

- User-friendly interface for easy interaction
- Search for players within a specific zone and level
- Automatically invite players who are not already in a guild
- Configurable search intervals and target zones
- Start and stop the search process with a simple command


## Installation

1. Download the latest version of GINVITER from the [GitHub repository](https://github.com/nelbin4/GINVITER).
2. Extract the downloaded files into your World of Warcraft `Interface/AddOns` folder.
3. Create a folder named "GINVITER"
4. Put GINVITER.lua GINVITER.toc GINVITER.xml inside the folder
5. Restart World of Warcraft Client Program and Enable it in the Addon list

## Usage

- To start the search process, type `/GINVITER start` in the chat.
- To stop the search process, type `/GINVITER stop` in the chat.

## Configuration

You can customize the following settings in the Lua file:

- `zones`: A table containing the names of the zones to search in.
- `loopInterval`: The time interval (in seconds) between each search.
- `level`: The level range to search for players.
- Other UI-related settings can be adjusted within the code.

## Contributions

Contributions to GINVITER are welcome! If you have any suggestions, bug reports, or improvements, please open an issue or submit a pull request on the [GitHub repository](https://github.com/nelbin4/GINVITER).

## License

This project is licensed under the [MIT License](LICENSE).
