# ffxi-mute
This addon attempts to identify bots flooding the chat log. By tracking the shout content, the interval they occur, and the person who shouted, the lua identifies if the user is a bot, and, if so, will block all incoming chunks from that bot. This effectively clears the chat log of clutter that nobody wants to see.

## Commands
- //mute print
  - Displays all currently muted players in the chat log
- //mute add name
  - Manually mute all incoming chunks for the named character
- //mute remove name
  - Manually remove the named character from the mute list
- //mute clear
  - Manually clear all names within the mute list

### Note: the mute list is cleared automatically each time you zone. This is a feature and can be disabled by removing the registered 'zone change' event handler.
