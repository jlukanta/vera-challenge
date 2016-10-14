CC = gcc
SOURCEPATH=./LookupSymbol/LookupSymbol
SOURCES=$(SOURCEPATH)/main.m $(SOURCEPATH)/Constants.m $(SOURCEPATH)/SymbolDumpParser.m $(SOURCEPATH)/SymbolInfo.m $(SOURCEPATH)/SymbolTable.m $(SOURCEPATH)/LookupJob.m
FRAMEWORKS:= -framework Foundation
LIBRARIES:= -lobjc -fobjc-arc
CFLAGS=-Wall -g $(SOURCES)
LDFLAGS=$(LIBRARIES) $(FRAMEWORKS)
OUT=-o lookup

all: $(SOURCES) $(OUT)

$(OUT): $(OBJECTS)
	$(CC) -o $(OBJECTS) $@ $(CFLAGS) $(LDFLAGS) $(OUT)

.m.o: $(CC) -c -Wall $< -o $@