NVCC = nvcc
CFLAGS = -arch=sm_50  # Conservative architecture for compatibility
TARGET = nim_game
SOURCE = nim_game.cu
LIBS = -lcurand

$(TARGET): $(SOURCE)
	$(NVCC) $(CFLAGS) -o $(TARGET) $(SOURCE) $(LIBS)

clean:
	rm -f $(TARGET)

run: $(TARGET)
	./$(TARGET)

.PHONY: clean run