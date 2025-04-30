# EcoGenesis

EcoGenesis is a blockchain-based biodiversity tracking and management system built using Clarity smart contracts for the Stacks ecosystem. The project enables transparent recording and monitoring of ecological data across various biomes and their resident organisms.

## Overview

This project provides a decentralized solution for:
- Recording and monitoring various biomes and their characteristics
- Tracking organism populations and their conservation status
- Calculating biodiversity metrics for analytical purposes
- Creating a transparent and immutable record of ecological changes over time

## Contract Structure

### Data Maps

- **biome-catalog**: Stores information about registered biomes including their location, size, and timestamps
- **organism-catalog**: Records details about organisms, including population sizes and conservation status
- **biome-diversity-metrics**: Maintains aggregated biodiversity statistics for each biome

### Key Functions

#### Biome Management
- `register-biome`: Add a new biome to the system with initial details
- `update-biome-details`: Modify an existing biome's information
- `get-biome-details`: Retrieve complete information about a specific biome

#### Organism Management
- `register-organism`: Add a new organism to the system, associating it with a parent biome
- `update-organism-census`: Update an organism's population count and conservation status
- `get-organism-details`: Retrieve complete information about a specific organism

#### Metrics and Analytics
- `get-biome-diversity-metrics`: Access biodiversity statistics for a specific biome
- `get-total-biomes`: Get the total number of registered biomes
- `get-total-organisms`: Get the total number of registered organisms

## Conservation Status Classifications

Organisms can be classified with the following preservation states:
- `stable`: Population is healthy and not at immediate risk
- `threatened`: Population shows concerning decline but not severe
- `endangered`: Population at significant risk of extinction
- `extinct`: No known living specimens remain

## Security Features

- Owner-only administrative functions
- Input validation to ensure data integrity
- Proper error handling with descriptive error codes
- Status verification for valid conservation classifications

## Development

To deploy and interact with this contract:

1. Install the [Clarinet](https://github.com/hirosystems/clarinet) development environment
2. Clone this repository
3. Use `clarinet console` to test the contract locally
4. Deploy to testnet or mainnet when ready

## License

This project is licensed under the MIT License - see the LICENSE file for details.