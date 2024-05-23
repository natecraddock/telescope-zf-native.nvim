build:
	echo "Do nothing"

install:
	mkdir -p $(INST_LUADIR)
	mkdir -p $(INST_LIBDIR)
	cp -r lua/* $(INST_LUADIR)
	cp -r lib/* $(INST_LIBDIR)
