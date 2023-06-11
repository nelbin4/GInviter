# GInviter

GInviter is a powerful World of Warcraft addon designed for **patch 3.3.5a (Wrath of the Lich King)**. It automates the guild recruitment process by searching for potential members based on specified zones or by class and inviting them to join your guild. With GInviter, you can save time and effortlessly attract suitable players to enhance your guild's roster.

![Screenshot](https://github.com/nelbin4/GINVITER/assets/20941975/f8d7b2b5-8aa7-44dc-98af-87b68cb07d90)

## Features

- **Effortless Guild Recruitment**: Automate the search for potential guild members based on your criteria.
- **Sleek Interface**: Enjoy a visually appealing design, simple easy-to-use user interface.
- **Search by Zone and Class**: Find suitable players based on specific zones and classes.
- **Controlled Invitations**: Define maximum invites per player to ensure fair recruitment practices.
- **Exclusion Management**: Automatically exclude players who have reached the maximum invite limit.
- **Stability and Performance**: Built to deliver a smooth and reliable experience.


## Installation

1. Download the latest release of GInviter from the [GitHub repository](https://github.com/nelbin4/ginviter/releases).
2. Extract the downloaded file into your World of Warcraft `Interface/AddOns` directory.
3. Launch World of Warcraft and enable GInviter in the AddOns menu.

## Usage

1. Open GInviter by typing `/ginviter` or `/ginviter show` in the chat.
2. Click the **Start** button to initiate the search and invitation process.
3. Monitor the progress in the GInviter frame.
4. Click the **Stop** button to end the search process.
5. Hide GInviter by typing `/ginviter hide` in the chat to work in the background.

## Modifying Variables

To modify the addon's behavior, you can edit the Lua file (`GInviter.lua`) located in the addon's folder. Here are some variables you can change:

- `searchMode`: Choose the search mode for guild invites. Options are "zone" for zone-based search and, "class" for class-based search.
- `zones`: Add or remove zones to search by following the syntax and comma-separated format.
- `classes`: Add or remove classes to search by following the syntax and comma-separated format.
- `loopInterval`: Adjust the loop interval in seconds for repeated searches.
- `level`: Change the level requirement for potential guild members.
- `maxInvites`: Define the maximum number of invites per player before excluding them.

Remember to save the changes and restart World of Warcraft for the modifications to take effect.

## Contributing

Contributions, bug reports, and feature suggestions are welcome! Feel free to contribute to the project by opening an issue or submitting a pull request on the [GitHub repository](https://github.com/nelbin4/ginviter).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.

## Disclaimer

GInviter is not associated with or endorsed by Blizzard Entertainment. Use it at your own risk.

## Contact

For any inquiries or questions, please contact [nelbin4](https://github.com/nelbin4).

<meta name="google-site-verification" content="CJxfG4PJmq5s2ycX7alFov5QcI8IRpWT_YBACm8HbJ0" />
