# Undead Codex

*Knowledge is survival.*

Undead Codex is a local, version-aware game data exploration and query tool for 7 Days to Die and its mods, with an initial focus on Undead Legacy.

Written in Swift, Undead Codex aims to make the wealth of information contained within the game's configuration files accessible through a reusable data processing and query architecture.

**Project Status:** Early development.

## Motivation

When I first started playing Undead Legacy, I was hit with a huge learning curve. Having primarily played lightly modded versions of 7 Days to Die, Undead Legacy was the first major overhaul mod that I spent any significant amount of time playing.

The sheer number of changes introduced by Undead Legacy made progression challenging. The skill and research trees are extensive and interconnected in ways that aren't immediately obvious. Figuring out what to research and when, while trying to keep up with horde nights, was a challenge in itself. Even finding basic materials and loot required relearning much of what I knew about the game.

Perhaps the biggest challenge was that I didn't know what I didn't know.

Traditional online wikis aren't always sufficient, especially for a mod that is actively evolving. Information can become outdated, incomplete, or simply unavailable.

I was already somewhat familiar with how much of the game's content is defined in XML configuration files, which led me to a simple question: could I find the information I was looking for directly within those files?

It turns out that I could. It just wasn't particularly easy.

That's why I started developing Undead Codex.

## Project Vision

Although Undead Codex currently takes the form of a command-line application, the CLI is not intended to be its primary user interface. Rather, it serves as a means of developing, validating, and exercising the underlying data processing and query capabilities.

The broader goal is to build a local, version-aware game data platform that can extract, interpret, store, and expose information from a player's own game installation, including installed mods.

One of my original ideas was to generate a locally hosted wiki from the game's configuration data. While that remains a possibility, I don't want the underlying architecture to be tied to any particular user interface. Once the data can be reliably processed and queried, it could support a variety of interfaces, including:

- Command-line tools
- AI assistants through the Model Context Protocol (MCP)
- A locally hosted, searchable wiki or web application
- Native graphical applications
- Other tools and integrations

At its core, Undead Codex is intended to remain local to the player's game installation. It is not intended to become a centralized game database or publicly hosted game-data API.

Ultimately, I started this project to build something that I would find useful as a player. If it becomes something that other players find useful as well, all the better.

## Current Capabilities

Undead Codex is under active development. The current command-line implementation provides a foundation for validating game data processing and querying against local game installations.

Currently implemented capabilities include:

- Loading and parsing vanilla game XML configuration files.
- Searching for and inspecting vanilla game items.
- Resolving human-readable item and block names through English localization data.
- Resolving block inheritance and inherited harvest drops.
- Identifying blocks that can be harvested for specific resources.
- Explicit mod selection for supported modded block queries.
- Applying supported XML patch operations used by Undead Legacy.
- Merging vanilla and mod-provided localization data.

Game data is currently processed on demand. Persistent storage, broader configuration coverage, and more advanced query capabilities are planned.

## Compatibility

Initial development is focused on:

- 7 Days to Die v2.6
- Compatible versions of Undead Legacy

Game configuration formats, patch semantics, and data relationships may differ between game and mod versions. Support for additional versions and mods will be evaluated as development progresses.

The current development environment is Swift on Linux through Windows Subsystem for Linux (WSL2). Native macOS and other environments have not yet been formally validated.

## Getting Started

### Requirements

- Swift 6.2 or later
- libxml2 development libraries
- pkg-config
- A local installation of 7 Days to Die for game data queries
- A compatible Undead Legacy installation for mod-specific queries

A game installation is not required to build the project or run the portable test suite.

On Ubuntu or other compatible Debian-based distributions, the required system libraries can be installed using:

```bash
sudo apt update
sudo apt install libxml2-dev pkg-config
```

Undead Codex uses Swift Package Manager and currently has no external Swift package dependencies.

Game files are not included with this repository.

### Building

Clone the repository:

```bash
git clone https://github.com/WERUreo/UndeadCodex.git
cd UndeadCodex
```

Build the debug executable:

```bash
swift build
```

To create a release build:

```bash
swift build -c release
```

## Usage

The general command-line syntax is:

```bash
swift run undead-codex <installation-path> [--mod <mod-name>] <command> <arguments>
```

Installation paths containing spaces must be enclosed in quotation marks.

### Available Commands

| Command | Description |
| --- | --- |
| `search <query>` | Search vanilla game items. |
| `inspect <item-id>` | Inspect a vanilla game item by its internal identifier. |
| `blocks --drops <item>` | Find blocks that provide a specified item through harvesting. Supports vanilla and supported modded data. |

### Searching for Items

```bash
swift run undead-codex "/path/to/7DaysToDie" search "wood"
```

Search results include human-readable item names and internal identifiers.

### Inspecting an Item

```bash
swift run undead-codex "/path/to/7DaysToDie" inspect resourceWood
```

The inspect command currently requires the item's internal identifier.

### Finding Resource Harvesting Sources

Search using an internal item identifier:

```bash
swift run undead-codex "/path/to/7DaysToDie" blocks --drops resourceElectricParts
```

Alternatively, search using the item's English localized name:

```bash
swift run undead-codex "/path/to/7DaysToDie" blocks --drops "Electrical Parts"
```

### Querying Modded Game Data

The `--mod` option selects a specific mod from the game's `Mods` directory. The mod name must match the corresponding directory name.

The option must appear after the installation path and before the command.

For example, to find blocks that provide Scrap Titanium in Undead Legacy:

```bash
swift run undead-codex "/path/to/7DaysToDie" --mod UndeadLegacy blocks --drops ulmResourceScrapTitanium
```

The same query can be performed using the localized item name:

```bash
swift run undead-codex "/path/to/7DaysToDie" --mod UndeadLegacy blocks --drops "Scrap Titanium"
```

Example output from an Undead Legacy installation:

```text
Police Cruiser | Random Spawner (ulmVehiclePoliceCruiserLootable)
  Harvest: Scrap Titanium (ulmResourceScrapTitanium) (count: 1)

Wrecked Police Cruiser | Random Spawner (ulmVehiclePoliceCruiserWrecked)
  Harvest: Scrap Titanium (ulmResourceScrapTitanium) (count: 1)

Secure Police Cruiser | Random Spawner (ulmVehiclePoliceCruiserSecure)
  Harvest: Scrap Titanium (ulmResourceScrapTitanium) (count: 1)

Advanced Electric Fence Post (ulmElectricFencePost3)
  Harvest: Scrap Titanium (ulmResourceScrapTitanium) (count: 5,40)

Found 4 matching blocks
```

Drop counts currently reflect values defined in the game's configuration files and should not be interpreted as guaranteed in-game yields.

### Running the Release Executable

After creating a release build, the executable can be invoked directly:

```bash
.build/release/undead-codex "/path/to/7DaysToDie" search "wood"
```

## Testing

Undead Codex uses the Swift Testing framework.

### Portable Tests

The portable test suite uses local test fixtures and does not require an installed copy of 7 Days to Die or Undead Legacy.

```bash
swift test
```

### Integration Tests

Certain integration tests validate behavior against an actual Undead Legacy installation.

These tests are opt-in and require the `UNDEADCODEX_UL_PATH` environment variable to specify the installation directory.

To include integration tests in a test run:

```bash
UNDEADCODEX_UL_PATH="/path/to/7DaysToDie" swift test
```

To run only the current installation-dependent integration tests:

```bash
UNDEADCODEX_UL_PATH="/path/to/7DaysToDie" \
    swift test --filter 'loadsUndeadLegacyBlocks|appliesUndeadLegacyBlockPatches'
```

Integration tests are tagged with `.integration`.

When the environment variable is unset or empty, installation-dependent tests are skipped. Providing an invalid installation path is expected to result in test failures.

## Known Limitations

Undead Codex is in early development and does not yet attempt to reproduce the game's entire configuration processing system.

Current limitations include:

- Initial compatibility is focused on 7 Days to Die v2.6 and compatible Undead Legacy versions.
- Only one explicitly selected mod is currently supported.
- Automatic mod discovery and multi-mod loading are not yet implemented.
- XML patch support is limited to implemented operations and does not guarantee complete parity with the game's patch engine.
- Item searching and inspection currently use vanilla game data.
- Localization support is currently limited to English.
- Reverse localization lookups may be ambiguous when multiple entries share the same localized name.
- Resource harvesting queries do not yet fully interpret drop probabilities, tool requirements, or actual resource yields.
- Game configuration data is processed on demand, which may affect performance for larger installations.
- Only a subset of the available game configuration data is currently supported.

### Input Security

Undead Codex is currently intended for use with trusted local game and mod installations.

Additional XML parser hardening and restrictions on XML patch include paths are planned. The current implementation should not be used to process arbitrary untrusted configuration files or exposed as a publicly accessible service.

Related issues:

- [Restrict XML patch includes to permitted directories](https://github.com/WERUreo/UndeadCodex/issues/131)
- [Harden XML parsing for untrusted configuration files](https://github.com/WERUreo/UndeadCodex/issues/132)

## Roadmap

Development is organized around several major milestones.

### Core Foundation

Establish the foundational architecture for loading, parsing, interpreting, and querying game configuration data.

### Mod Support

Expand support for modded game data, including:

- Additional XML patch operations
- Automatic mod discovery
- Mod metadata and loading order
- Multi-mod support
- Expanded localization support
- Modded item and other data queries

### Persistent Game Data

Introduce a version-aware local persistence layer to reduce repeated configuration processing and support more advanced queries.

### Game Data Discovery

Systematically investigate the game's configuration files, data structures, relationships, and version-specific behavior to identify additional capabilities that Undead Codex can provide.

### Advanced Queries

Expand query capabilities into additional areas of the game, potentially including:

- Crafting recipes and recursive material requirements
- Resource acquisition and loot sources
- Trader inventories
- Vehicle comparisons
- Research requirements and progression
- Skills and perks
- Workstation upgrades
- Comparisons between game and mod datasets

### Model Context Protocol (MCP)

Develop a local MCP server that exposes game data through structured, read-only query tools.

This would allow compatible AI assistants to retrieve information directly from a player's local game data rather than relying exclusively on potentially outdated external sources.

### Live Game Telemetry

Investigate opportunities to extract useful information from game logs and other available telemetry sources.

Potential capabilities include:

- Game event monitoring
- Weather observations and historical analysis
- Notifications
- External integrations

This milestone is exploratory and is intended to focus on passive observation rather than modifying game files or reading game process memory.

### Future Interfaces

Potential future interfaces include a locally hosted wiki, a web application, and native graphical applications.

No particular graphical interface or deployment architecture has been selected at this time.

For additional details, see the project's [issues](https://github.com/WERUreo/UndeadCodex/issues) and [milestones](https://github.com/WERUreo/UndeadCodex/milestones).

## Development Approach

My primary motivation for developing Undead Codex is to build something useful. However, the project also provides an opportunity to expand my knowledge of Swift beyond its traditional use in Apple platform development.

Undead Codex follows a test-driven development (TDD) approach using the Swift Testing framework. Swift Testing is new to me, and this project provides an opportunity to gain practical experience with the framework while building a reliable and maintainable codebase.

Where practical, expected behavior is established through automated tests before implementation. This is particularly valuable when working with complex configuration structures, inheritance relationships, and XML patch semantics.

### AI-Assisted Development

ChatGPT is being used as a collaborative development tool throughout the project. Its involvement includes:

- Architectural planning and technical discussions.
- Research into game configuration structures and behavior.
- Test design and implementation.
- Collaborative code development and debugging.
- Code review and identification of potential issues.
- Project planning, backlog management, and documentation.

Rather than simply generating a complete application, the development process is iterative and collaborative, with an emphasis on understanding implementation decisions, validating behavior, and learning along the way.

The project also provides an opportunity to explore how AI-assisted development can complement established software engineering practices such as test-driven development.

## Dependencies

Undead Codex is developed using Swift and Swift Package Manager.

### libxml2

[libxml2](https://gitlab.gnome.org/GNOME/libxml2) provides XML parsing, XPath evaluation, and XML manipulation capabilities through Swift's C interoperability and a Swift Package Manager system library target.

libxml2 is distributed under permissive licensing, primarily the MIT license, with certain components distributed under the ISC license.

Undead Codex does not bundle libxml2 source code or binaries. The required libraries are provided by the host system.

There are currently no external Swift package dependencies.

## Disclaimer

Undead Codex is an independent, unofficial project and is not affiliated with, endorsed by, or sponsored by The Fun Pimps or the developers of Undead Legacy.

7 Days to Die, Undead Legacy, and their associated intellectual property belong to their respective rights holders.

Undead Codex is designed to process configuration data from a user's own local game installation. This repository does not distribute game installations, complete original game configuration files, or game assets.

The accuracy of information provided by Undead Codex depends on supported game and mod versions, configuration formats, and the completeness of its data interpretation.

## License

Copyright © 2026 Keli'i Martin. All rights reserved.

Undead Codex is currently made publicly available for viewing and evaluation. It is not presently distributed under an open-source license.

Except as permitted by applicable law or GitHub's Terms of Service, permission to use, modify, or redistribute the source code must be obtained from the copyright holder.

An open-source license may be considered as the project matures.