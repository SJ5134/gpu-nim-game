#include "nim_game.h"
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <string>
#include <curand_kernel.h>
#include <time.h>
#include <cstring>

#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))

__global__ void playNimGames(int *all_moves, int *all_winners, int *final_states,
                             int numGames, int maxMoves, unsigned long seed)
{
    int game_id = blockIdx.x * blockDim.x + threadIdx.x;

    if (game_id < numGames)
    {
        curandState state;
        curand_init(seed, game_id, 0, &state);

        int objects = 12;
        int current_player = 0;
        int move_count = 0;

        while (objects > 0 && move_count < maxMoves)
        {
            int move = 0;

            if (current_player == 0)
            {
                // GPU1 Smart Strategy
                if (objects % 4 == 0)
                {
                    move = 3;
                }
                else
                {
                    move = objects % 4;
                }
            }
            else
            {
                // GPU2 Random Strategy
                move = (curand(&state) % 3) + 1;
                if (move > objects)
                    move = objects;
            }

            move = max(1, min(3, move));
            move = min(move, objects);

            objects -= move;

            int move_index = game_id * maxMoves * 3 + move_count * 3;
            all_moves[move_index] = current_player;
            all_moves[move_index + 1] = move;
            all_moves[move_index + 2] = objects;

            move_count++;
            current_player = 1 - current_player;

            if (objects == 0)
                break;
        }

        all_winners[game_id] = 1 - current_player;
        final_states[game_id] = objects;
    }
}

__host__ void allocateGameMemory(int **d_moves, int **d_winners, int **d_states,
                                 int numGames, int maxMoves)
{
    size_t moves_size = numGames * maxMoves * 3 * sizeof(int);
    size_t results_size = numGames * sizeof(int);

    cudaMalloc(d_moves, moves_size);
    cudaMalloc(d_winners, results_size);
    cudaMalloc(d_states, results_size);
}

__host__ void playNimOnGPU(int numGames)
{
    int maxMoves = 20;

    int *d_moves, *d_winners, *d_states;
    allocateGameMemory(&d_moves, &d_winners, &d_states, numGames, maxMoves);

    int *h_moves = (int *)malloc(numGames * maxMoves * 3 * sizeof(int));
    int *h_winners = (int *)malloc(numGames * sizeof(int));
    int *h_states = (int *)malloc(numGames * sizeof(int));

    memset(h_moves, 0, numGames * maxMoves * 3 * sizeof(int));
    memset(h_winners, 0, numGames * sizeof(int));
    memset(h_states, 0, numGames * sizeof(int));

    int threadsPerBlock = 256;
    int blocksPerGrid = (numGames + threadsPerBlock - 1) / threadsPerBlock;
    unsigned long seed = time(NULL);

    printf(" Launching %d Nim games on GPU...\n", numGames);
    playNimGames<<<blocksPerGrid, threadsPerBlock>>>(d_moves, d_winners, d_states, numGames, maxMoves, seed);

    cudaError_t err = cudaGetLastError();
    if (err != cudaSuccess)
    {
        fprintf(stderr, "Kernel launch failed: %s\n", cudaGetErrorString(err));
        return;
    }

    cudaDeviceSynchronize();

    cudaMemcpy(h_moves, d_moves, numGames * maxMoves * 3 * sizeof(int), cudaMemcpyDeviceToHost);
    cudaMemcpy(h_winners, d_winners, numGames * sizeof(int), cudaMemcpyDeviceToHost);
    cudaMemcpy(h_states, d_states, numGames * sizeof(int), cudaMemcpyDeviceToHost);

    // Process results
    printf("\n GAME REPLAYS:\n");
    printf("================\n");

    for (int game = 0; game < min(3, numGames); game++)
    {
        printf("\n--- Game %d ---\n", game + 1);
        printf("Start: 12 objects\n");

        for (int move = 0; move < maxMoves; move++)
        {
            int idx = game * maxMoves * 3 + move * 3;
            int player = h_moves[idx];
            int taken = h_moves[idx + 1];
            int remaining = h_moves[idx + 2];

            if (taken == 0)
                break;

            const char *strategy = (player == 0) ? "SMART" : "RANDOM";
            printf("Move %d: GPU%d (%s) takes %d → %d left\n",
                   move + 1, player + 1, strategy, taken, remaining);

            if (remaining == 0)
            {
                printf("🎉 GPU%d WINS!\n", h_winners[game] + 1);
                break;
            }
        }
    }

    // Statistics
    int gpu1_wins = 0;
    for (int i = 0; i < numGames; i++)
    {
        if (h_winners[i] == 0)
            gpu1_wins++;
    }

    printf("\n FINAL STATISTICS:\n");
    printf("===================\n");
    printf("Total games: %d\n", numGames);
    printf("GPU1 (Smart) wins: %d (%.1f%%)\n", gpu1_wins, (gpu1_wins * 100.0) / numGames);
    printf("GPU2 (Random) wins: %d (%.1f%%)\n", numGames - gpu1_wins, ((numGames - gpu1_wins) * 100.0) / numGames);

    cudaFree(d_moves);
    cudaFree(d_winners);
    cudaFree(d_states);
    free(h_moves);
    free(h_winners);
    free(h_states);
}

int main()
{
    printf("COMPETING GPUs: NIM GAME\n");
    printf("============================\n");
    printf("Rules: 12 objects, take 1-3 per turn, last player LOSES\n");
    printf("GPU1: Smart strategy (mathematical)\n");
    printf("GPU2: Random strategy\n\n");

    int numGames = 10;
    playNimOnGPU(numGames);

    printf("\n💡 Analysis: Smart strategy wins by forcing opponent into losing positions!\n");
    return 0;
}