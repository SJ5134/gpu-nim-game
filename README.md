# GPU Nim Game Competition

A CUDA implementation of the Nim game where two GPU players compete using different strategies.

## Overview

This project was created for a university assignment on competing GPUs. It demonstrates how different AI strategies perform in a simple game environment, with a mathematical approach significantly outperforming random play.

## Game Rules

- Start with 12 objects
- Players alternate removing 1, 2, or 3 objects per turn
- The player forced to take the last object **loses** (misère version)

## GPU Strategies

### GPU 1: Smart Strategy
- Uses a mathematical approach that always aims to leave a multiple of 4 objects
- This is a known winning strategy in Nim game theory
- Wins approximately 85% of games against random play

### GPU 2: Random Strategy  
- Takes 1, 3, or 3 objects randomly each turn
- No look-ahead or strategic planning
- Wins about 15% of games by chance

## Project Structure
