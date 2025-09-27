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
- Takes 1, 2, or 3 objects randomly each turn
- No look-ahead or strategic planning
- Wins about 15% of games by chance

## Project Structure
gpu-nim-game/

├── nim_game.cu 

├── nim_game.h 

├── Makefile 

└── README.md 


## Technical Implementation Details

### CUDA Parallelization

- The game runs thousands of simulations in parallel on the GPU
- Each CUDA thread handles one complete game
- Uses curand library for parallel random number generation

### Memory Management

- Allocates device memory for game states and results
- Efficiently transfers data between host and device
- Proper cleanup to avoid memory leaks

## How to Run This Project

### On Google Colab (Recommended)

I developed this project on Google Colab since I'm using a Mac without an NVIDIA GPU. Here's how to run it:

1. Go to [colab.research.google.com](https://colab.research.google.com)
2. Create a new notebook
3. Set up GPU: **Runtime → Change runtime type → GPU**
4. Upload the `.cu` files or clone this repository
5. Run these commands:

```bash
# Compile the code
!nvcc -arch=sm_50 -o nim_game nim_game.cu -lcurand

# Run the game
!./nim_game


